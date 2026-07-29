import { ComputePass, Engine, Shader, ShaderLanguage } from "@galacean/engine";

const SHADER_NAME = "Terrain/SurfaceStaticCompaction";

/** @internal Number of vec4 values in one surface instance record. */
export const SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE = 4;
/** @internal Number of float values in one surface instance record. */
export const SURFACE_COMPACTION_INSTANCE_FLOAT_STRIDE = SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE * 4;
/** @internal Number of uint values in one indexed indirect draw record. */
export const SURFACE_COMPACTION_INDIRECT_WORD_STRIDE = 5;
/** @internal Number of uint values in one compaction command. */
export const SURFACE_COMPACTION_COMMAND_WORD_STRIDE = 4;

const SHADER_SOURCE = `
Shader "${SHADER_NAME}" {
  SubShader "Default" {
    Pass "Compact" {
      readonly buffer vec4 sourceInstances[];
      readonly buffer uvec4 compactionCommands[];
      buffer vec4 outputInstances[];
      buffer uint indirectArguments[];

      void compactInstances() {
        uint workGroupIndex = gl_WorkGroupID.x;
        uvec4 header = compactionCommands[0];
        uint localIndex = gl_LocalInvocationID.x;
        if (workGroupIndex < header.y) {
          uvec4 command = compactionCommands[uint(1) + header.x + workGroupIndex];
          while (localIndex < command.z) {
            uint sourceVector =
              (command.x + localIndex) * uint(${SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE});
            uint outputVector =
              (command.y + localIndex) * uint(${SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE});
            vec4 positionMetadata = sourceInstances[sourceVector];
            if (command.w > uint(0)) {
              uint encodedHue = uint(round(clamp(positionMetadata.w, 0.0, 1.0) * 255.0));
              positionMetadata.w = float(encodedHue * uint(65536) + command.w - uint(1));
            }
            outputInstances[outputVector] = positionMetadata;
            outputInstances[outputVector + uint(1)] = sourceInstances[sourceVector + uint(1)];
            outputInstances[outputVector + uint(2)] = sourceInstances[sourceVector + uint(2)];
            outputInstances[outputVector + uint(3)] = sourceInstances[sourceVector + uint(3)];
            localIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
          }
        }
        if (workGroupIndex < header.w) {
          uvec4 batch = compactionCommands[uint(1) + workGroupIndex];
          uint indirectIndex = gl_LocalInvocationID.x;
          while (indirectIndex < batch.y) {
            indirectArguments[
              batch.x + indirectIndex * uint(${SURFACE_COMPACTION_INDIRECT_WORD_STRIDE}) + uint(1)
            ] = batch.z;
            indirectIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
          }
        }
      }

      ComputeShader = compactInstances;
    }

    Pass "ResetFineCullCounters" {
      readonly buffer uvec4 compactionCommands[];
      buffer uint fineCullCounters[];

      void resetFineCullCounters() {
        uvec4 header = compactionCommands[0];
        uint fineBatchCount = header.x - header.w;
        uint localIndex = gl_LocalInvocationID.x;
        while (localIndex < fineBatchCount) {
          uvec4 batch = compactionCommands[uint(1) + header.w + localIndex];
          atomicStore(fineCullCounters[batch.w], batch.z);
          localIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
        }
      }

      ComputeShader = resetFineCullCounters;
    }

    Pass "FineCull" {
      shared uint groupCount;
      shared uint groupBase;
      readonly buffer vec4 sourceInstances[];
      readonly buffer uvec4 compactionCommands[];
      readonly buffer vec4 fineCullBatches[];
      readonly buffer vec4 fineCullParameters[];
      buffer vec4 outputInstances[];
      buffer uint fineCullCounters[];

      bool isFineCullCandidateVisible(vec4 positionMetadata, vec4 instanceScale, vec4 batch) {
        float instanceRadius =
          batch.y *
          max(abs(instanceScale.x), max(abs(instanceScale.y), abs(instanceScale.z))) *
          batch.z;
        float distanceLimit = batch.x * fineCullParameters[0].w + instanceRadius;
        vec3 delta = positionMetadata.xyz - fineCullParameters[0].xyz;
        return dot(delta, delta) <= distanceLimit * distanceLimit;
      }

      void fineCullInstances() {
        uvec4 header = compactionCommands[0];
        uint workGroupIndex = gl_WorkGroupID.x;
        uint commandStart = uint(1) + header.x + header.y;
        uvec4 command = compactionCommands[commandStart + workGroupIndex];
        vec4 batch = fineCullBatches[command.w];
        if (gl_LocalInvocationID.x == 0u) {
          atomicStore(groupCount, 0u);
        }
        barrier();

        uint localIndex = gl_LocalInvocationID.x;
        uint sourceVector = 0u;
        vec4 positionMetadata = vec4(0.0);
        vec4 instanceScale = vec4(0.0);
        bool visible = localIndex < command.z;
        if (visible) {
          sourceVector =
            (command.x + localIndex) * uint(${SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE});
          positionMetadata = sourceInstances[sourceVector];
          instanceScale = sourceInstances[sourceVector + uint(2)];
          visible = isFineCullCandidateVisible(positionMetadata, instanceScale, batch);
        }

        uint localSlot = 0u;
        if (visible) {
          localSlot = atomicAdd(groupCount, 1u);
        }
        barrier();

        if (gl_LocalInvocationID.x == 0u) {
          uint survivorCount = atomicLoad(groupCount);
          groupBase = command.y;
          if (survivorCount > 0u) {
            groupBase += atomicAdd(fineCullCounters[command.w], survivorCount);
          }
        }
        barrier();

        if (visible) {
          uint outputVector =
            (groupBase + localSlot) * uint(${SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE});
          outputInstances[outputVector] = positionMetadata;
          outputInstances[outputVector + uint(1)] = sourceInstances[sourceVector + uint(1)];
          outputInstances[outputVector + uint(2)] = instanceScale;
          outputInstances[outputVector + uint(3)] = sourceInstances[sourceVector + uint(3)];
        }
      }

      ComputeShader = fineCullInstances;
    }

    Pass "FinalizeFineCull" {
      readonly buffer uvec4 compactionCommands[];
      buffer uint fineCullCounters[];
      buffer uint indirectArguments[];

      void finalizeFineCull() {
        uvec4 header = compactionCommands[0];
        uint fineBatchIndex = gl_WorkGroupID.x;
        uint fineBatchCount = header.x - header.w;
        if (fineBatchIndex < fineBatchCount) {
          uvec4 batch = compactionCommands[uint(1) + header.w + fineBatchIndex];
          uint instanceCount = atomicLoad(fineCullCounters[batch.w]);
          uint indirectIndex = gl_LocalInvocationID.x;
          while (indirectIndex < batch.y) {
            indirectArguments[
              batch.x + indirectIndex * uint(${SURFACE_COMPACTION_INDIRECT_WORD_STRIDE}) + uint(1)
            ] = instanceCount;
            indirectIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
          }
        }
      }

      ComputeShader = finalizeFineCull;
    }

    Pass "ResetShadowCounters" {
      readonly buffer vec4 shadowData[];
      readonly buffer vec4 shadowParameters[];
      buffer uint shadowCounters[];

      void resetShadowCounters() {
        uint index =
          gl_WorkGroupID.x * uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X) + gl_LocalInvocationID.x;
        uint batchCount = uint(shadowData[0].x);
        uint counterCount = batchCount * uint(shadowParameters[0].x);
        if (index < counterCount) {
          atomicStore(shadowCounters[index], 0u);
        }
      }

      ComputeShader = resetShadowCounters;
    }

    Pass "CullShadowInstances" {
      shared uint groupCounts[4];
      shared uint groupBases[4];
      readonly buffer vec4 sourceInstances[];
      readonly buffer vec4 shadowData[];
      readonly buffer vec4 shadowParameters[];
      buffer vec4 shadowInstances[];
      buffer uint shadowCounters[];

      bool intersectsShadowSlice(vec3 position, float radius, uint cascadeIndex) {
        uint parameterOffset = uint(2) + cascadeIndex * uint(11);
        uint planeCount = uint(shadowParameters[parameterOffset].x);
        for (uint planeIndex = 0u; planeIndex < planeCount; planeIndex++) {
          vec4 plane = shadowParameters[parameterOffset + uint(1) + planeIndex];
          if (dot(plane.xyz, position) + plane.w < -radius) {
            return false;
          }
        }
        return true;
      }

      void cullShadowInstances() {
        uint batchCount = uint(shadowData[0].x);
        uint commandIndex = gl_WorkGroupID.x;
        uint commandStart = uint(1) + batchCount * uint(2);
        vec4 command = shadowData[commandStart + commandIndex];
        uint batchIndex = uint(command.z);
        vec4 batch = shadowData[uint(1) + batchIndex * uint(2)];
        vec4 geometry = shadowData[uint(2) + batchIndex * uint(2)];
        if (gl_LocalInvocationID.x == 0u) {
          for (uint cascadeIndex = 0u; cascadeIndex < uint(4); cascadeIndex++) {
            atomicStore(groupCounts[cascadeIndex], 0u);
          }
        }
        barrier();

        uint localIndex = gl_LocalInvocationID.x;
        uint sourceVector = 0u;
        vec4 positionMetadata = vec4(0.0);
        vec4 instanceScale = vec4(0.0);
        float metadataCode = command.w;
        bool fineCulling = metadataCode < 0.0;
        if (fineCulling) {
          metadataCode = -metadataCode - 1.0;
        }
        bool candidateVisible = localIndex < uint(command.y);
        float instanceRadius = 0.0;
        if (candidateVisible) {
          sourceVector =
            (uint(command.x) + localIndex) * uint(${SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE});
          positionMetadata = sourceInstances[sourceVector];
          instanceScale = sourceInstances[sourceVector + uint(2)];
          instanceRadius =
            geometry.x *
              max(abs(instanceScale.x), max(abs(instanceScale.y), abs(instanceScale.z))) *
              geometry.y +
            geometry.z;
          if (fineCulling) {
            vec3 cameraDelta = positionMetadata.xyz - shadowParameters[uint(1)].xyz;
            float distanceRadius =
              geometry.x *
              max(abs(instanceScale.x), max(abs(instanceScale.y), abs(instanceScale.z))) *
              geometry.y;
            float distanceLimit = geometry.w + distanceRadius;
            candidateVisible = dot(cameraDelta, cameraDelta) <= distanceLimit * distanceLimit;
          }
        }

        uint localSlots[4];
        bool visibleByCascade[4];
        uint cascadeCount = uint(shadowParameters[0].x);
        for (uint cascadeIndex = 0u; cascadeIndex < uint(4); cascadeIndex++) {
          bool visible =
            candidateVisible &&
            cascadeIndex < cascadeCount &&
            intersectsShadowSlice(positionMetadata.xyz, instanceRadius, cascadeIndex);
          visibleByCascade[cascadeIndex] = visible;
          localSlots[cascadeIndex] = visible
            ? atomicAdd(groupCounts[cascadeIndex], 1u)
            : uint(0);
        }
        barrier();

        if (gl_LocalInvocationID.x == 0u) {
          uint outputCapacity = uint(shadowParameters[0].y);
          uint batchCount = uint(shadowParameters[0].w);
          for (uint cascadeIndex = 0u; cascadeIndex < uint(4); cascadeIndex++) {
            uint survivorCount = atomicLoad(groupCounts[cascadeIndex]);
            uint outputBase = cascadeIndex * outputCapacity + uint(batch.x);
            if (cascadeIndex < cascadeCount && survivorCount > 0u) {
              uint counterIndex = cascadeIndex * batchCount + uint(batch.w);
              outputBase += atomicAdd(shadowCounters[counterIndex], survivorCount);
            }
            groupBases[cascadeIndex] = outputBase;
          }
        }
        barrier();

        if (candidateVisible) {
          if (metadataCode > 0.0) {
            uint encodedHue = uint(round(clamp(positionMetadata.w, 0.0, 1.0) * 255.0));
            positionMetadata.w =
              float(encodedHue * uint(65536) + uint(metadataCode) - uint(1));
          }
          for (uint cascadeIndex = 0u; cascadeIndex < uint(4); cascadeIndex++) {
            if (visibleByCascade[cascadeIndex]) {
              uint outputVector =
                (groupBases[cascadeIndex] + localSlots[cascadeIndex]) *
                uint(${SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE});
              shadowInstances[outputVector] = positionMetadata;
              shadowInstances[outputVector + uint(1)] = sourceInstances[sourceVector + uint(1)];
              shadowInstances[outputVector + uint(2)] = instanceScale;
              shadowInstances[outputVector + uint(3)] = sourceInstances[sourceVector + uint(3)];
            }
          }
        }
      }

      ComputeShader = cullShadowInstances;
    }

    Pass "FinalizeShadowCulling" {
      readonly buffer vec4 shadowData[];
      readonly buffer vec4 shadowParameters[];
      buffer uint shadowCounters[];
      buffer uint shadowIndirectArguments[];

      void finalizeShadowCulling() {
        uint batchIndex = gl_WorkGroupID.x;
        uint batchCount = uint(shadowData[0].x);
        if (batchIndex < batchCount) {
          vec4 batch = shadowData[uint(1) + batchIndex * uint(2)];
          uint cascadeCount = uint(shadowParameters[0].x);
          uint indirectWordCapacity = uint(shadowParameters[0].z);
          for (uint cascadeIndex = 0u; cascadeIndex < cascadeCount; cascadeIndex++) {
            uint counterIndex = cascadeIndex * batchCount + uint(batch.w);
            uint instanceCount = atomicLoad(shadowCounters[counterIndex]);
            uint indirectIndex = gl_LocalInvocationID.x;
            while (indirectIndex < uint(batch.z)) {
              uint wordOffset =
                cascadeIndex * indirectWordCapacity +
                uint(batch.y) +
                indirectIndex * uint(${SURFACE_COMPACTION_INDIRECT_WORD_STRIDE});
              shadowIndirectArguments[wordOffset + uint(1)] = instanceCount;
              indirectIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
            }
          }
        }
      }

      ComputeShader = finalizeShadowCulling;
    }
  }
}
`;

/**
 * ShaderLab compute passes used by the shared finite-surface storage atlas.
 * @internal
 */
export interface SurfaceStaticCompactionPasses {
  /** Copies ranges that retain CPU visibility and LOD selection. */
  readonly copy: ComputePass;
  /** Clears fine-cull counters in command order on the GPU timeline. */
  readonly resetFineCullCounters: ComputePass;
  /** Applies instance-distance culling and workgroup-aggregated compaction. */
  readonly fineCull: ComputePass;
  /** Writes fine-cull survivor counts into indexed indirect records. */
  readonly finalizeFineCull: ComputePass;
  /** Clears the per-cascade shadow compaction counters. */
  readonly resetShadowCounters: ComputePass;
  /** Compacts one cascade's conservative shadow-caster stream. */
  readonly cullShadowInstances: ComputePass;
  /** Writes one cascade's survivor counts into indexed indirect records. */
  readonly finalizeShadowCulling: ComputePass;
}

/**
 * Creates the GPU compaction passes shared by all finite prototype LOD batches.
 * @param engine - WebGPU engine that owns the compute pipeline.
 * @returns Compute passes compiled from the same ShaderLab source.
 */
export function createSurfaceStaticCompactionPasses(engine: Engine): SurfaceStaticCompactionPasses {
  const shader = Shader.find(SHADER_NAME) ?? Shader.create(SHADER_SOURCE, ShaderLanguage.WGSL);
  return {
    copy: new ComputePass(engine, shader, 0, 0),
    resetFineCullCounters: new ComputePass(engine, shader, 0, 1),
    fineCull: new ComputePass(engine, shader, 0, 2),
    finalizeFineCull: new ComputePass(engine, shader, 0, 3),
    resetShadowCounters: new ComputePass(engine, shader, 0, 4),
    cullShadowInstances: new ComputePass(engine, shader, 0, 5),
    finalizeShadowCulling: new ComputePass(engine, shader, 0, 6)
  };
}
