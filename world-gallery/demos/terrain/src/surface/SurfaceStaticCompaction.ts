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
      readonly buffer uvec4 copyCommands[];
      buffer vec4 outputInstances[];
      buffer uint indirectArguments[];

      void compactInstances() {
        uint workGroupIndex = gl_WorkGroupID.x;
        uvec4 header = copyCommands[0];
        uint localIndex = gl_LocalInvocationID.x;
        if (workGroupIndex < header.x) {
          uvec4 command = copyCommands[uint(1) + header.y + workGroupIndex];
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
        if (workGroupIndex < header.y) {
          uvec4 batch = copyCommands[uint(1) + workGroupIndex];
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
  }
}
`;

/**
 * Creates the GPU compaction pass shared by all finite prototype LOD batches.
 * @param engine - WebGPU engine that owns the compute pipeline.
 * @returns Compute pass compiled from ShaderLab.
 */
export function createSurfaceStaticCompactionPass(engine: Engine): ComputePass {
  const shader = Shader.find(SHADER_NAME) ?? Shader.create(SHADER_SOURCE, ShaderLanguage.WGSL);
  return new ComputePass(engine, shader);
}
