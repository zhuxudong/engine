import {
  Buffer,
  BufferBindFlag,
  BufferUsage,
  Camera,
  ComputePass,
  Engine,
  Shader,
  ShaderLanguage,
  Texture
} from "@galacean/engine";

const SHADER_NAME = "Terrain/SurfaceDepthTiles";

interface AfterDepthPrepassPipeline {
  _addAfterDepthPrepassConsumer(consumer: (depthTexture: Texture) => void): void;
  _removeAfterDepthPrepassConsumer(consumer: (depthTexture: Texture) => void): void;
}

const SHADER_SOURCE = `
Shader "${SHADER_NAME}" {
  SubShader "Default" {
    Pass "BuildFarDepthTiles" {
      shared uint tileFarDepthBits;
      sampler2D camera_DepthTexture;
      readonly buffer uvec4 depthTileParameters[];
      buffer uint farDepthBits[];

      void buildFarDepthTiles() {
        uvec4 parameters = depthTileParameters[0u];
        uint tileEdge = parameters.z;
        uint localIndex = gl_LocalInvocationID.x;
        if (localIndex == 0u) {
          atomicStore(tileFarDepthBits, 0u);
        }
        barrier();

        uint tilePixelCount = tileEdge * tileEdge;
        uint tileOriginX = gl_WorkGroupID.x * tileEdge;
        uint tileOriginY = gl_WorkGroupID.y * tileEdge;
        while (localIndex < tilePixelCount) {
          uint pixelX = tileOriginX + localIndex % tileEdge;
          uint pixelY = tileOriginY + localIndex / tileEdge;
          if (pixelX < parameters.x && pixelY < parameters.y) {
            float depth = texelFetch(camera_DepthTexture, ivec2(int(pixelX), int(pixelY)), 0).x;
            atomicMax(tileFarDepthBits, floatBitsToUint(depth));
          }
          localIndex += uint(GALACEAN_COMPUTE_WORKGROUP_SIZE_X);
        }
        barrier();

        if (gl_LocalInvocationID.x == 0u) {
          uint tileIndex = gl_WorkGroupID.y * parameters.w + gl_WorkGroupID.x;
          farDepthBits[tileIndex] = atomicLoad(tileFarDepthBits);
        }
      }

      ComputeShader = buildFarDepthTiles;
    }
  }
}
`;

/** Runtime shape and dispatch diagnostics for the conservative depth-tile buffer. */
export interface SurfaceDepthTileSnapshot {
  /** Source depth width in physical pixels. */
  readonly width: number;
  /** Source depth height in physical pixels. */
  readonly height: number;
  /** Square tile edge derived from the selected compute workgroup size. */
  readonly tileEdge: number;
  /** Number of horizontal tiles. */
  readonly tilesX: number;
  /** Number of vertical tiles. */
  readonly tilesY: number;
  /** Number of depth-prepass dispatches encoded since construction. */
  readonly dispatchCount: number;
}

/** Same-frame far-depth tile resource delivered after its reduction dispatch is encoded. */
export interface SurfaceDepthTileFrame {
  /** Storage buffer containing one normal-Z far-depth bit pattern per tile. */
  readonly farDepthBits: Buffer;
  /** Source depth width in physical pixels. */
  readonly width: number;
  /** Source depth height in physical pixels. */
  readonly height: number;
  /** Square tile edge in physical pixels. */
  readonly tileEdge: number;
  /** Number of horizontal tiles. */
  readonly tilesX: number;
  /** Number of vertical tiles. */
  readonly tilesY: number;
}

/** Consumer encoded after the far-depth reduction and before Forward rendering. */
export type SurfaceDepthTileConsumer = (frame: SurfaceDepthTileFrame) => void;

/**
 * Builds one conservative far-depth value per screen tile after the camera depth prepass.
 */
export class SurfaceDepthTiles {
  private readonly _camera: Camera;
  private readonly _pipeline: AfterDepthPrepassPipeline;
  private readonly _pass: ComputePass;
  private readonly _parameterBuffer: Buffer;
  private readonly _consumers = new Set<SurfaceDepthTileConsumer>();
  private readonly _afterDepthPrepass = (depthTexture: Texture): void => this._build(depthTexture);
  private _outputBuffer: Buffer | null = null;
  private _width = 0;
  private _height = 0;
  private _tileEdge = 0;
  private _tilesX = 0;
  private _tilesY = 0;
  private _dispatchCount = 0;

  /**
   * Create a depth-tile builder owned by one camera pipeline.
   * @param engine - WebGPU engine that owns the compute device.
   * @param camera - Camera whose same-frame prepass depth is reduced.
   * @throws If compute is unavailable on the selected backend.
   */
  constructor(engine: Engine, camera: Camera) {
    if (!engine.computeCapabilities.supported) {
      throw new Error("Surface depth tiles require a compute-capable backend.");
    }
    const shader = Shader.find(SHADER_NAME) ?? Shader.create(SHADER_SOURCE, ShaderLanguage.WGSL);
    this._camera = camera;
    this._pipeline = (camera as unknown as { _renderPipeline: AfterDepthPrepassPipeline })._renderPipeline;
    this._pass = new ComputePass(engine, shader);
    this._parameterBuffer = new Buffer(
      engine,
      BufferBindFlag.StorageBuffer,
      Uint32Array.BYTES_PER_ELEMENT * 4,
      BufferUsage.Dynamic
    );
    this._pass.setBuffer("depthTileParameters", this._parameterBuffer);
    this._pipeline._addAfterDepthPrepassConsumer(this._afterDepthPrepass);
  }

  /**
   * Return the current depth-tile shape and dispatch count.
   * @returns Immutable runtime diagnostics.
   */
  inspect(): SurfaceDepthTileSnapshot {
    return {
      width: this._width,
      height: this._height,
      tileEdge: this._tileEdge,
      tilesX: this._tilesX,
      tilesY: this._tilesY,
      dispatchCount: this._dispatchCount
    };
  }

  /**
   * Subscribe work that must consume the same-frame tile buffer before Forward rendering.
   * @param consumer - Consumer invoked in registration order after each reduction dispatch.
   */
  addConsumer(consumer: SurfaceDepthTileConsumer): void {
    this._consumers.add(consumer);
  }

  /**
   * Remove a previously registered tile consumer.
   * @param consumer - Callback passed to `addConsumer`.
   */
  removeConsumer(consumer: SurfaceDepthTileConsumer): void {
    this._consumers.delete(consumer);
  }

  /**
   * Stop depth-prepass dispatches and release owned compute resources.
   */
  destroy(): void {
    this._pipeline._removeAfterDepthPrepassConsumer(this._afterDepthPrepass);
    this._consumers.clear();
    this._pass.destroy();
    this._parameterBuffer.destroy(true);
    this._outputBuffer?.destroy(true);
    this._outputBuffer = null;
  }

  private _build(depthTexture: Texture): void {
    const width = depthTexture.width;
    const height = depthTexture.height;
    if (width !== this._width || height !== this._height) {
      this._resize(width, height);
    }
    this._pass.setTexture("camera_DepthTexture", depthTexture);
    this._pass.dispatch(this._tilesX, this._tilesY);
    this._dispatchCount++;
    const frame: SurfaceDepthTileFrame = {
      farDepthBits: this._outputBuffer!,
      width: this._width,
      height: this._height,
      tileEdge: this._tileEdge,
      tilesX: this._tilesX,
      tilesY: this._tilesY
    };
    for (const consumer of this._consumers) {
      consumer(frame);
    }
  }

  private _resize(width: number, height: number): void {
    const workgroupSize = this._pass.workgroupSize[0];
    const tileEdge = Math.ceil(Math.sqrt(workgroupSize));
    const tilesX = Math.ceil(width / tileEdge);
    const tilesY = Math.ceil(height / tileEdge);
    const maximum = this._camera.engine.computeCapabilities.maxWorkgroupsPerDimension;
    if (tilesX > maximum || tilesY > maximum) {
      throw new RangeError(`Depth tile dispatch ${tilesX}x${tilesY} exceeds the device limit ${maximum}.`);
    }

    const outputBuffer = new Buffer(
      this._camera.engine,
      BufferBindFlag.StorageBuffer,
      tilesX * tilesY * Uint32Array.BYTES_PER_ELEMENT,
      BufferUsage.Dynamic
    );
    this._pass.setBuffer("farDepthBits", outputBuffer);
    this._outputBuffer?.destroy(true);
    this._outputBuffer = outputBuffer;
    this._parameterBuffer.setData(new Uint32Array([width, height, tileEdge, tilesX]));
    this._width = width;
    this._height = height;
    this._tileEdge = tileEdge;
    this._tilesX = tilesX;
    this._tilesY = tilesY;
  }
}
