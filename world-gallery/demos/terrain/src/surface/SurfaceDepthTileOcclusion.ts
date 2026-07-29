import {
  Buffer,
  BufferBindFlag,
  BufferUsage,
  ComputePass,
  Engine,
  Shader,
  ShaderLanguage
} from "@galacean/engine";
import {
  SURFACE_COMPACTION_INDIRECT_WORD_STRIDE,
  SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE
} from "./SurfaceStaticCompaction";
import {
  SurfaceDepthTiles,
  type SurfaceDepthTileConsumer,
  type SurfaceDepthTileFrame
} from "./SurfaceDepthTiles";

const SHADER_NAME = "Terrain/SurfaceDepthTileOcclusion";
const COMMAND_VECTOR_STRIDE = 2;

const SHADER_SOURCE = `
Shader "${SHADER_NAME}" {
  SubShader "Default" {
    Pass "CopyVisibleSurvivors" {
      readonly buffer vec4 visibleInstances[];
      readonly buffer uint visibleIndirectArguments[];
      readonly buffer uvec4 occlusionCommands[];
      buffer vec4 outputInstances[];
      buffer uint outputIndirectArguments[];

      void copyVisibleSurvivors() {
        uint batchIndex = gl_WorkGroupID.x;
        uvec4 offsets = occlusionCommands[batchIndex * uint(${COMMAND_VECTOR_STRIDE})];
        uvec4 shape = occlusionCommands[batchIndex * uint(${COMMAND_VECTOR_STRIDE}) + uint(1)];
        uint instanceCount =
          visibleIndirectArguments[offsets.z + uint(1)];
        uint localIndex = gl_LocalInvocationID.x;
        while (localIndex < instanceCount) {
          uint sourceVector =
            (offsets.x + localIndex) * uint(${SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE});
          uint outputVector =
            (offsets.y + localIndex) * uint(${SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE});
          outputInstances[outputVector] = visibleInstances[sourceVector];
          outputInstances[outputVector + uint(1)] = visibleInstances[sourceVector + uint(1)];
          outputInstances[outputVector + uint(2)] = visibleInstances[sourceVector + uint(2)];
          outputInstances[outputVector + uint(3)] = visibleInstances[sourceVector + uint(3)];
          localIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
        }

        uint indirectIndex = gl_LocalInvocationID.x;
        while (indirectIndex < shape.x) {
          outputIndirectArguments[
            offsets.w +
            indirectIndex * uint(${SURFACE_COMPACTION_INDIRECT_WORD_STRIDE}) +
            uint(1)
          ] = instanceCount;
          indirectIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
        }
      }

      ComputeShader = copyVisibleSurvivors;
    }
  }
}
`;

/** One eligible Surface batch copied into an isolated after-depth output slice. */
export interface SurfaceDepthTileOcclusionBatch {
  /** First instance in the existing frustum-compaction atlas. */
  readonly inputInstanceOffset: number;
  /** First instance in the isolated output atlas. */
  readonly outputInstanceOffset: number;
  /** First uint of this batch's source indexed-indirect record. */
  readonly inputIndirectWordOffset: number;
  /** First uint of this batch's isolated indexed-indirect record. */
  readonly outputIndirectWordOffset: number;
  /** Number of indexed-indirect records sharing the instance count. */
  readonly indirectRecordCount: number;
}

/** Runtime diagnostics for the isolated after-depth Surface output. */
export interface SurfaceDepthTileOcclusionSnapshot {
  /** Number of eligible prototype LOD batches. */
  readonly batchCount: number;
  /** Maximum number of instance records reserved across eligible batches. */
  readonly instanceCapacity: number;
  /** Number of indexed-indirect records consumed by eligible Forward draws. */
  readonly indirectRecordCount: number;
  /** Number of after-depth compaction dispatches encoded since construction. */
  readonly dispatchCount: number;
}

/**
 * Owns the isolated Forward instance and indirect streams consumed after depth-tile reduction.
 */
export class SurfaceDepthTileOcclusion {
  /** Instance atlas consumed by eligible Forward renderers. */
  readonly outputInstanceBuffer: Buffer;
  /** Indexed-indirect atlas consumed by eligible Forward renderers. */
  readonly outputIndirectBuffer: Buffer;

  private readonly _depthTiles: SurfaceDepthTiles;
  private readonly _pass: ComputePass;
  private readonly _commandBuffer: Buffer;
  private readonly _batchCount: number;
  private readonly _instanceCapacity: number;
  private readonly _indirectRecordCount: number;
  private readonly _consumeTiles: SurfaceDepthTileConsumer = (frame) => this._dispatch(frame);
  private _dispatchCount = 0;

  /**
   * Create isolated output streams for eligible Surface batches.
   * @param engine - WebGPU engine that owns the compute resources.
   * @param depthTiles - Same-frame depth-tile producer that defines dispatch order.
   * @param inputInstanceBuffer - Existing frustum-compaction instance atlas.
   * @param inputIndirectBuffer - Existing frustum-compaction indexed-indirect atlas.
   * @param batches - Eligible batch slice mappings.
   * @param instanceCapacity - Total records reserved in the isolated instance atlas.
   * @param indirectArguments - Static indexed-indirect fields for the isolated records.
   * @throws If an output buffer or dispatch dimension exceeds the active device limits.
   */
  constructor(
    engine: Engine,
    depthTiles: SurfaceDepthTiles,
    inputInstanceBuffer: Buffer,
    inputIndirectBuffer: Buffer,
    batches: readonly SurfaceDepthTileOcclusionBatch[],
    instanceCapacity: number,
    indirectArguments: Uint32Array
  ) {
    if (batches.length === 0) {
      throw new Error("Surface depth-tile occlusion requires at least one eligible batch.");
    }
    const indirectRecordCount = indirectArguments.length / SURFACE_COMPACTION_INDIRECT_WORD_STRIDE;
    if (!Number.isInteger(indirectRecordCount)) {
      throw new RangeError("Surface depth-tile indirect arguments do not contain complete records.");
    }
    validateCapacity(engine, batches.length, instanceCapacity, indirectArguments.byteLength);

    const commands = new Uint32Array(batches.length * COMMAND_VECTOR_STRIDE * 4);
    for (let index = 0; index < batches.length; index++) {
      const batch = batches[index];
      const offset = index * COMMAND_VECTOR_STRIDE * 4;
      commands[offset] = batch.inputInstanceOffset;
      commands[offset + 1] = batch.outputInstanceOffset;
      commands[offset + 2] = batch.inputIndirectWordOffset;
      commands[offset + 3] = batch.outputIndirectWordOffset;
      commands[offset + 4] = batch.indirectRecordCount;
    }

    const shader = Shader.find(SHADER_NAME) ?? Shader.create(SHADER_SOURCE, ShaderLanguage.WGSL);
    this._depthTiles = depthTiles;
    this._batchCount = batches.length;
    this._instanceCapacity = instanceCapacity;
    this._indirectRecordCount = indirectRecordCount;
    this.outputInstanceBuffer = new Buffer(
      engine,
      BufferBindFlag.VertexBuffer | BufferBindFlag.StorageBuffer,
      instanceCapacity * SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE * 4 * Float32Array.BYTES_PER_ELEMENT,
      BufferUsage.Dynamic
    );
    this.outputIndirectBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer | BufferBindFlag.IndirectBuffer,
      indirectArguments,
      BufferUsage.Dynamic
    );
    this._commandBuffer = new Buffer(engine, BufferBindFlag.StorageBuffer, commands, BufferUsage.Static);
    this._pass = new ComputePass(engine, shader);
    this._pass.setBuffer("visibleInstances", inputInstanceBuffer);
    this._pass.setBuffer("visibleIndirectArguments", inputIndirectBuffer);
    this._pass.setBuffer("occlusionCommands", this._commandBuffer);
    this._pass.setBuffer("outputInstances", this.outputInstanceBuffer);
    this._pass.setBuffer("outputIndirectArguments", this.outputIndirectBuffer);
    depthTiles.addConsumer(this._consumeTiles);
  }

  /**
   * Return immutable allocation and dispatch diagnostics.
   * @returns Current isolated-output snapshot.
   */
  inspect(): SurfaceDepthTileOcclusionSnapshot {
    return {
      batchCount: this._batchCount,
      instanceCapacity: this._instanceCapacity,
      indirectRecordCount: this._indirectRecordCount,
      dispatchCount: this._dispatchCount
    };
  }

  /**
   * Stop after-depth compaction and release owned GPU resources.
   */
  destroy(): void {
    this._depthTiles.removeConsumer(this._consumeTiles);
    this._pass.destroy();
    this._commandBuffer.destroy(true);
    this.outputInstanceBuffer.destroy(true);
    this.outputIndirectBuffer.destroy(true);
  }

  private _dispatch(_frame: SurfaceDepthTileFrame): void {
    this._pass.dispatch(this._batchCount);
    this._dispatchCount++;
  }
}

function validateCapacity(
  engine: Engine,
  batchCount: number,
  instanceCapacity: number,
  indirectByteLength: number
): void {
  const limits = engine.computeCapabilities;
  if (batchCount > limits.maxWorkgroupsPerDimension) {
    throw new RangeError(
      `Surface depth-tile compaction requires ${batchCount} workgroups, exceeding ` +
        `${limits.maxWorkgroupsPerDimension}.`
    );
  }
  const storageByteLengths = [
    instanceCapacity * SURFACE_COMPACTION_INSTANCE_VECTOR_STRIDE * 4 * Float32Array.BYTES_PER_ELEMENT,
    indirectByteLength,
    batchCount * COMMAND_VECTOR_STRIDE * 4 * Uint32Array.BYTES_PER_ELEMENT
  ];
  for (const byteLength of storageByteLengths) {
    if (byteLength > limits.maxStorageBufferBindingSize) {
      throw new RangeError(
        `Surface depth-tile storage requires ${byteLength} bytes, exceeding ` +
          `${limits.maxStorageBufferBindingSize}.`
      );
    }
  }
}
