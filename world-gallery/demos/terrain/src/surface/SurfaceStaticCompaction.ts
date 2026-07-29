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
    finalizeFineCull: new ComputePass(engine, shader, 0, 3)
  };
}
