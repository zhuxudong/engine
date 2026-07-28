import { ComputePass, Engine, Shader, ShaderLanguage } from "@galacean/engine";

const SHADER_NAME = "Terrain/SurfaceStaticCompaction";

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
          uvec4 command = copyCommands[uint(1) + workGroupIndex];
          while (localIndex < command.z) {
            uint sourceVector = (command.x + localIndex) * uint(4);
            uint outputVector = (command.y + localIndex) * uint(4);
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
        } else if (workGroupIndex == header.x) {
          while (localIndex < header.y) {
            indirectArguments[localIndex * uint(5) + uint(1)] = header.z;
            localIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
          }
        }
      }

      ComputeShader = compactInstances;
    }
  }
}
`;

/**
 * Create the GPU compaction pass shared by one finite prototype LOD batch.
 * @param engine - WebGPU engine that owns the compute pipeline.
 * @returns Compute pass compiled from ShaderLab.
 */
export function createSurfaceStaticCompactionPass(engine: Engine): ComputePass {
  const shader = Shader.find(SHADER_NAME) ?? Shader.create(SHADER_SOURCE, ShaderLanguage.WGSL);
  return new ComputePass(engine, shader);
}
