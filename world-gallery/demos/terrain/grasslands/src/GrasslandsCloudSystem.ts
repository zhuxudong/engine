import {
  AssetType,
  BaseMaterial,
  BoundingBox,
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Color,
  Engine,
  Entity,
  IndexFormat,
  MeshRenderer,
  Quaternion,
  RenderFace,
  Script,
  Shader,
  ShaderProperty,
  Texture2D,
  TextureFilterMode,
  TextureWrapMode,
  Vector3,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import cloudShaderSource from "./shaders/GrasslandsCloud.shader?raw";

const CLOUD_SHADER_NAME = "Terrain/GrasslandsCloud";
const QUAD_VERTICES = new Float32Array([
  -0.5, -0.5, 0, 1,
  0.5, -0.5, 1, 1,
  0.5, 0.5, 1, 0,
  -0.5, 0.5, 0, 0
]);
const QUAD_INDICES = new Uint16Array([0, 1, 2, 0, 2, 3]);
const INSTANCE_STRIDE = 80;

/** Exact exported Unity particle settings shared by one cloud preset. */
export interface GrasslandsCloudPresetSpec {
  readonly texture: string;
  readonly simulationSpeed: number;
  readonly lifetime: readonly [minimum: number, maximum: number];
  readonly speed: readonly [minimum: number, maximum: number];
  readonly size: readonly [width: number, height: number, depth: number];
  readonly softness: number;
  readonly color: readonly [r: number, g: number, b: number, a: number];
}

/** Authored transform and deterministic seed for one cloud emitter. */
export interface GrasslandsCloudPlacementSpec {
  readonly preset: number;
  readonly position: readonly [x: number, y: number, z: number];
  readonly rotation: readonly [x: number, y: number, z: number, w: number];
  readonly scale: readonly [x: number, y: number, z: number];
  readonly seed: number;
}

/** Mutable scene-only cloud switches. */
export interface GrasslandsCloudTuning {
  readonly visible: boolean;
  readonly animation: boolean;
}

/** Read-only cloud batching and animation diagnostics. */
export interface GrasslandsCloudSnapshot extends GrasslandsCloudTuning {
  readonly instances: number;
  readonly drawGroups: number;
  readonly time: number;
}

/**
 * Four-preset instanced cloud renderer driven only by exported transforms and seeds.
 */
export class GrasslandsCloudSystem {
  readonly root: Entity;

  private readonly _materials: GrasslandsCloudMaterial[];
  private readonly _instances: number;
  private readonly _animator: GrasslandsCloudAnimator;
  private _visible = true;
  private _animation = true;

  private constructor(
    root: Entity,
    materials: GrasslandsCloudMaterial[],
    instances: number,
    animator: GrasslandsCloudAnimator
  ) {
    this.root = root;
    this._materials = materials;
    this._instances = instances;
    this._animator = animator;
  }

  /**
   * Creates one GPU-instanced draw group per cloud preset.
   * @param engine Engine owning cloud buffers, textures, and materials.
   * @param parent Parent entity for the scene-only cloud layer.
   * @param presets Exact exported Unity particle settings.
   * @param placements Authored emitter transforms and deterministic seeds.
   * @param layoutUrl URL used to resolve preset textures.
   * @returns Ready cloud renderer and runtime diagnostics.
   */
  static async create(
    engine: Engine,
    parent: Entity,
    presets: readonly GrasslandsCloudPresetSpec[],
    placements: readonly GrasslandsCloudPlacementSpec[],
    layoutUrl: string
  ): Promise<GrasslandsCloudSystem> {
    const root = parent.createChild("grasslands-clouds");
    const materials = await Promise.all(
      presets.map((preset) => GrasslandsCloudMaterial.create(engine, preset, layoutUrl))
    );
    for (let presetIndex = 0; presetIndex < presets.length; presetIndex++) {
      const instances = placements.filter((placement) => placement.preset === presetIndex);
      if (instances.length === 0) continue;
      const entity = root.createChild(`cloud-preset-${presetIndex + 1}`);
      const renderer = entity.addComponent(MeshRenderer);
      renderer.mesh = createCloudMesh(engine, presetIndex, presets[presetIndex], instances);
      renderer.setMaterial(materials[presetIndex]);
      renderer.castShadows = false;
      renderer.receiveShadows = false;
    }
    const animator = root.addComponent(GrasslandsCloudAnimator);
    animator.materials = materials;
    return new GrasslandsCloudSystem(root, materials, placements.length, animator);
  }

  /**
   * Applies scene-only cloud visibility and animation controls.
   * @param values Partial cloud switches.
   */
  setTuning(values: Partial<GrasslandsCloudTuning>): void {
    if (values.visible !== undefined) {
      this._visible = values.visible;
      this.root.isActive = values.visible;
    }
    if (values.animation !== undefined) {
      this._animation = values.animation;
      this._animator.animation = values.animation;
    }
  }

  /** Returns cloud visibility, animation time, instance count, and draw-group count. */
  inspect(): GrasslandsCloudSnapshot {
    return {
      visible: this._visible,
      animation: this._animation,
      instances: this._instances,
      drawGroups: this._materials.length,
      time: this._animator.time
    };
  }
}

class GrasslandsCloudMaterial extends BaseMaterial {
  private static readonly _texture = ShaderProperty.getByName("material_CloudTexture");
  private static readonly _time = ShaderProperty.getByName("material_Time");
  private static readonly _simulationSpeed = ShaderProperty.getByName("material_SimulationSpeed");
  private static readonly _softness = ShaderProperty.getByName("material_Softness");
  private static readonly _color = ShaderProperty.getByName("material_CloudColor");

  private constructor(engine: Engine, preset: GrasslandsCloudPresetSpec) {
    const shader = Shader.find(CLOUD_SHADER_NAME) ?? Shader.create(cloudShaderSource);
    super(engine, shader);
    this.isTransparent = true;
    this.renderFace = RenderFace.Double;
    this.shaderData.setFloat(GrasslandsCloudMaterial._time, 0);
    this.shaderData.setFloat(GrasslandsCloudMaterial._simulationSpeed, preset.simulationSpeed);
    this.shaderData.setFloat(GrasslandsCloudMaterial._softness, preset.softness);
    this.shaderData.setColor(GrasslandsCloudMaterial._color, new Color(...preset.color));
  }

  static async create(
    engine: Engine,
    preset: GrasslandsCloudPresetSpec,
    layoutUrl: string
  ): Promise<GrasslandsCloudMaterial> {
    const material = new GrasslandsCloudMaterial(engine, preset);
    const texture = await engine.resourceManager.load<Texture2D>({
      type: AssetType.Texture,
      url: new URL(preset.texture, layoutUrl).href,
      params: {
        isSRGBColorSpace: true,
        mipmap: true,
        wrapModeU: TextureWrapMode.Clamp,
        wrapModeV: TextureWrapMode.Clamp,
        filterMode: TextureFilterMode.Trilinear,
        anisoLevel: 4
      }
    });
    if (!(texture instanceof Texture2D)) {
      throw new Error(`[GrasslandsCloudSystem] ${preset.texture} did not resolve to Texture2D`);
    }
    material.shaderData.setTexture(GrasslandsCloudMaterial._texture, texture);
    return material;
  }

  setTime(time: number): void {
    this.shaderData.setFloat(GrasslandsCloudMaterial._time, time);
  }
}

class GrasslandsCloudAnimator extends Script {
  materials: GrasslandsCloudMaterial[] = [];
  animation = true;
  time = 0;

  override onUpdate(deltaTime: number): void {
    if (!this.animation) return;
    this.time += deltaTime;
    for (const material of this.materials) material.setTime(this.time);
  }
}

function createCloudMesh(
  engine: Engine,
  presetIndex: number,
  preset: GrasslandsCloudPresetSpec,
  placements: readonly GrasslandsCloudPlacementSpec[]
): BufferMesh {
  const instanceData = new Float32Array(placements.length * (INSTANCE_STRIDE / 4));
  const mirroredLocalForward = new Vector3(0, 0, -1);
  const meshRightAfterStartRotation = new Vector3(0, 0, -1);
  const meshUpAfterStartRotation = new Vector3(0, 1, 0);
  const direction = new Vector3();
  const right = new Vector3();
  const up = new Vector3();
  let maximumRadius = 0;
  for (let index = 0; index < placements.length; index++) {
    const placement = placements[index];
    const quaternion = new Quaternion(...placement.rotation);
    Vector3.transformByQuat(mirroredLocalForward, quaternion, direction);
    Vector3.transformByQuat(meshRightAfterStartRotation, quaternion, right);
    Vector3.transformByQuat(meshUpAfterStartRotation, quaternion, up);
    direction.normalize();
    right.normalize();
    up.normalize();
    const firstRandom = hashToUnit(placement.seed);
    const secondRandom = hashToUnit(hashInteger(placement.seed ^ 0x9e3779b9));
    const lifetime = lerp(preset.lifetime[0], preset.lifetime[1], firstRandom);
    const speed = lerp(preset.speed[0], preset.speed[1], secondRandom);
    const phase = hashToUnit(hashInteger(placement.seed ^ 0x85ebca6b)) * lifetime;
    const width = preset.size[0] * Math.abs(placement.scale[2]);
    const height = preset.size[1] * Math.abs(placement.scale[1]);
    const offset = index * (INSTANCE_STRIDE / 4);
    instanceData.set([placement.position[0], placement.position[1], placement.position[2], phase], offset);
    instanceData.set([direction.x, direction.y, direction.z, speed], offset + 4);
    instanceData.set([right.x, right.y, right.z, lifetime], offset + 8);
    instanceData.set([up.x, up.y, up.z, width], offset + 12);
    instanceData[offset + 16] = height;
    const travel = speed * lifetime * preset.simulationSpeed;
    maximumRadius = Math.max(
      maximumRadius,
      Math.hypot(width, height) * 0.5 + travel
    );
  }

  const mesh = new BufferMesh(engine, `grasslands-cloud-preset-${presetIndex + 1}`);
  mesh.setVertexBufferBinding(
    new Buffer(engine, BufferBindFlag.VertexBuffer, QUAD_VERTICES, BufferUsage.Static),
    16,
    0
  );
  mesh.setVertexBufferBinding(
    new Buffer(engine, BufferBindFlag.VertexBuffer, instanceData, BufferUsage.Static),
    INSTANCE_STRIDE,
    1
  );
  mesh.setVertexElements([
    new VertexElement("POSITION_UV", 0, VertexElementFormat.Vector4, 0),
    new VertexElement("INSTANCE_POSITION_PHASE", 0, VertexElementFormat.Vector4, 1, 1),
    new VertexElement("INSTANCE_DIRECTION_SPEED", 16, VertexElementFormat.Vector4, 1, 1),
    new VertexElement("INSTANCE_RIGHT_LIFETIME", 32, VertexElementFormat.Vector4, 1, 1),
    new VertexElement("INSTANCE_UP_WIDTH", 48, VertexElementFormat.Vector4, 1, 1),
    new VertexElement("INSTANCE_HEIGHT", 64, VertexElementFormat.Vector4, 1, 1)
  ]);
  mesh.setIndexBufferBinding(
    new Buffer(engine, BufferBindFlag.IndexBuffer, QUAD_INDICES, BufferUsage.Static),
    IndexFormat.UInt16
  );
  mesh.addSubMesh(0, QUAD_INDICES.length);
  mesh.instanceCount = placements.length;
  mesh.bounds = placementBounds(placements, maximumRadius);
  return mesh;
}

function placementBounds(
  placements: readonly GrasslandsCloudPlacementSpec[],
  radius: number
): BoundingBox {
  const minimum = new Vector3(
    Number.POSITIVE_INFINITY,
    Number.POSITIVE_INFINITY,
    Number.POSITIVE_INFINITY
  );
  const maximum = new Vector3(
    Number.NEGATIVE_INFINITY,
    Number.NEGATIVE_INFINITY,
    Number.NEGATIVE_INFINITY
  );
  for (const placement of placements) {
    minimum.x = Math.min(minimum.x, placement.position[0] - radius);
    minimum.y = Math.min(minimum.y, placement.position[1] - radius);
    minimum.z = Math.min(minimum.z, placement.position[2] - radius);
    maximum.x = Math.max(maximum.x, placement.position[0] + radius);
    maximum.y = Math.max(maximum.y, placement.position[1] + radius);
    maximum.z = Math.max(maximum.z, placement.position[2] + radius);
  }
  return new BoundingBox(minimum, maximum);
}

function hashInteger(value: number): number {
  let hash = value >>> 0;
  hash ^= hash >>> 16;
  hash = Math.imul(hash, 0x7feb352d);
  hash ^= hash >>> 15;
  hash = Math.imul(hash, 0x846ca68b);
  return (hash ^ (hash >>> 16)) >>> 0;
}

function hashToUnit(value: number): number {
  return hashInteger(value) / 0x100000000;
}

function lerp(minimum: number, maximum: number, t: number): number {
  return minimum + (maximum - minimum) * t;
}
