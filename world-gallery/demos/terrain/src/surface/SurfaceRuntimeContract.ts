import type { CompiledSurfaceManifest, SurfaceCategory, SurfaceRule } from "./SurfaceContract";

/** Minimum live prototype scale accepted by the shared surface runtime. */
export const SURFACE_RUNTIME_SCALE_MIN = 0.1;

/** Maximum live prototype scale reserved by renderer bounds and accepted by the inspector. */
export const SURFACE_RUNTIME_SCALE_MAX = 4;

/** World-space triplanar coverage values exported from a source surface material. */
export interface SurfaceCoverageSpec {
  readonly albedo: string;
  readonly normal: string;
  readonly metallicSmoothness?: string;
  readonly mask?: string;
  /** Linear-RGB tint multiplied with the decoded albedo texture. */
  readonly color: readonly [r: number, g: number, b: number, a: number];
  readonly tiling: number;
  readonly normalScale: number;
  readonly metallic: number;
  readonly roughness: number;
  readonly smoothnessSource: "albedo-alpha" | "metallic-alpha";
  readonly overlayMethod: "perturbed-normal" | "vertex-normal";
  readonly offset: number;
  readonly balance: number;
  readonly maskContrast: number;
  readonly normalBlending: number;
  readonly maskTiling: readonly [x: number, y: number];
}

/** Material parameters consumed by the instanced surface shader. */
export interface SurfaceMaterialSpec {
  readonly id: string;
  readonly kind: "vegetation" | "pbr" | "impostor";
  readonly albedo?: string;
  readonly normal?: string;
  readonly metallicSmoothness?: string;
  readonly occlusion?: string;
  /** Linear-RGB primary tint multiplied with the decoded albedo texture. */
  readonly baseColor: readonly [r: number, g: number, b: number, a: number];
  /** Linear-RGB secondary tint used by deterministic color variation. */
  readonly secondColor: readonly [r: number, g: number, b: number, a: number];
  readonly alphaCutoff: number;
  readonly metallic?: number;
  readonly roughness: number;
  readonly occlusionStrength?: number;
  readonly normalScale: number;
  readonly coverage?: SurfaceCoverageSpec;
  readonly wind: {
    readonly enabled: boolean;
    readonly force: number;
    readonly wavesScale: number;
    readonly flowDensity: number;
    readonly baseLock: boolean;
    /** Whether the imported mesh flipped source UV.y while converting to glTF. */
    readonly baseLockUvInverted: boolean;
  };
  readonly colorVariation: {
    readonly enabled: boolean;
    readonly mode: "world-noise-2d" | "world-noise-3d" | "vertex-gradient" | "uv-gradient";
    readonly scale: number;
    readonly offset: number;
    readonly fade: number;
  };
  readonly lightingFlatness: number;
  readonly translucency: number;
  /** Linear-RGB back-light tint. */
  readonly translucencyColor: readonly [r: number, g: number, b: number, a: number];
  /** Back-light model; the Unity additive mode is reserved for source-parity scene materials. */
  readonly translucencyModel: "none" | "unity-additive-albedo";
  readonly fadeEnabled: boolean;
  readonly fadeDistance: number;
  readonly fadeFalloff: number;
}

/** One renderer within a prototype LOD. */
export interface SurfacePrototypeRendererSpec {
  readonly model: string;
  readonly meshName: string;
  readonly localPosition: readonly [x: number, y: number, z: number];
  readonly localRotation: readonly [x: number, y: number, z: number, w: number];
  readonly localScale: readonly [x: number, y: number, z: number];
  readonly materials: readonly string[];
  readonly castShadows: boolean;
  readonly receiveShadows: boolean;
}

/** One mesh LOD and its source screen-relative threshold. */
export interface SurfacePrototypeLodSpec {
  readonly index: number;
  readonly screenRelativeHeight: number;
  readonly crossfadeWidth: number;
  readonly renderers: readonly SurfacePrototypeRendererSpec[];
}

/** Runtime geometry, material and distance policy for one surface prototype. */
export interface SurfacePrototypeSpec {
  readonly id: string;
  readonly category: SurfaceCategory;
  readonly lods: readonly SurfacePrototypeLodSpec[];
  readonly lodCrossfade: boolean;
  readonly maxDistance: number;
  readonly impostor: boolean;
}

/** Deterministic streamed placement rule for terrain outside finite authored regions. */
export interface SurfaceWorldRule {
  readonly id: string;
  readonly prototype: string;
  readonly category: SurfaceCategory;
  readonly mode: "coverage" | "scatter";
  readonly densityPerSquareMetre: number;
  readonly spacing: number;
  readonly scale: {
    readonly horizontal: readonly [min: number, max: number];
    readonly vertical: readonly [min: number, max: number];
  };
  readonly yaw: readonly [minRadians: number, maxRadians: number];
  readonly height: readonly [min: number, max: number];
  readonly slope: readonly [min: number, max: number];
  /** World-space ecology noise frequency in cycles per metre. */
  readonly biomeScale: number;
  /** Accepted inclusive ecology-noise interval. */
  readonly biomeRange: readonly [min: number, max: number];
  /** Soft transition width around both ecology interval edges. */
  readonly biomeFeather: number;
  /** Independent world-space ecology offset for this category. */
  readonly biomeOffset: readonly [x: number, z: number];
  /** Stable world-space partition used by the cell diagnostic. */
  readonly cellSize: number;
  /** Hard runtime buffer budget; exceeding candidates are deterministically rejected by priority. */
  readonly maxInstances: number;
}

/** Infinite deterministic surface input independent from finite region masks. */
export interface SurfaceWorldDistributionSpec {
  readonly enabled: boolean;
  readonly seed: number;
  /** Camera movement in metres before visible world cells are regenerated. */
  readonly rebuildDistance: number;
  /** Explicit fractal parameters for the shared world-space ecology field. */
  readonly biomeNoise: {
    readonly octaves: number;
    readonly lacunarity: number;
    readonly persistence: number;
    readonly rotationRadians: number;
  };
  readonly rules: readonly SurfaceWorldRule[];
}

/** Author-defined live controls applied when a surface bundle is first loaded. */
export interface SurfaceRuntimeDefaults {
  /** Linear-RGB category multipliers shown by the shared surface inspector. */
  readonly color?: Partial<Record<SurfaceCategory, readonly [r: number, g: number, b: number]>>;
  /** Uniform category scale multipliers constrained by the shared runtime bounds. */
  readonly scale?: Partial<Record<SurfaceCategory, number>>;
}

/** Camera-local generation policy for finite-region coverage rules. */
export interface SurfaceCoverageStreamingSpec {
  readonly enabled: boolean;
  /** World-space edge length of one cached coverage cell. */
  readonly cellSize: number;
  /** Camera movement in metres before visible coverage buffers are rebuilt. */
  readonly rebuildDistance: number;
  /** Coverage rule ids resolved from `sourceRules`. */
  readonly ruleIds: readonly string[];
}

/** Compiled instance manifest plus all runtime prototype resources. */
export interface SurfaceRuntimeManifest extends CompiledSurfaceManifest {
  /** Color space used by all material color tuples in this manifest. */
  readonly colorSpace: "linear";
  readonly lodDitherTexture: string;
  readonly lodCrossfadeDuration: number;
  readonly prototypeLibrary: readonly SurfacePrototypeSpec[];
  readonly materials: readonly SurfaceMaterialSpec[];
  readonly debugMasks?: readonly SurfaceDebugMaskSpec[];
  readonly sourceRules?: readonly SurfaceRule[];
  readonly worldDistribution?: SurfaceWorldDistributionSpec;
  readonly runtimeDefaults?: SurfaceRuntimeDefaults;
  readonly coverageStreaming?: SurfaceCoverageStreamingSpec;
}

/** One compiled density mask exposed by the surface inspector. */
export interface SurfaceDebugMaskSpec {
  readonly id: string;
  readonly url: string;
  /** World-space XZ coordinate represented by the mask's lower-left texel boundary. */
  readonly origin: readonly [x: number, z: number];
  /** World-space width and depth represented by the complete mask. */
  readonly size: readonly [width: number, depth: number];
}

/** Mutable category-level runtime controls that never alter compiled placement data. */
export interface SurfaceRuntimeTuning {
  readonly enabled: Readonly<Record<SurfaceCategory, boolean>>;
  readonly density: Readonly<Record<SurfaceCategory, number>>;
  /** Live linear-RGB multiplier per category. */
  readonly color: Readonly<Record<SurfaceCategory, readonly [r: number, g: number, b: number]>>;
  /** Live uniform prototype scale per category. */
  readonly scale: Readonly<Record<SurfaceCategory, number>>;
  readonly wind: {
    readonly enabled: boolean;
    readonly strength: number;
    readonly direction: readonly [x: number, y: number, z: number];
  };
  readonly lod: {
    readonly enabled: boolean;
    readonly distanceScale: number;
  };
  readonly world: {
    readonly enabled: boolean;
    /** Multiplies streamed rule spacing without changing finite authored placements. */
    readonly spacing: Readonly<Record<SurfaceCategory, number>>;
    /** World-space ecology-mask translation in metres. */
    readonly biomeOffset: readonly [x: number, z: number];
  };
  readonly debugView: "surface" | "normal" | "wind-weight" | "category" | "cell" | "world-biome";
}

/** Partial runtime-only update accepted by a surface world. */
export interface SurfaceRuntimeTuningUpdate {
  readonly enabled?: Partial<Record<SurfaceCategory, boolean>>;
  readonly density?: Partial<Record<SurfaceCategory, number>>;
  readonly color?: Partial<Record<SurfaceCategory, readonly [r: number, g: number, b: number]>>;
  readonly scale?: Partial<Record<SurfaceCategory, number>>;
  readonly wind?: Partial<SurfaceRuntimeTuning["wind"]>;
  readonly lod?: Partial<SurfaceRuntimeTuning["lod"]>;
  readonly world?: {
    readonly enabled?: boolean;
    readonly spacing?: Partial<Record<SurfaceCategory, number>>;
    readonly biomeOffset?: readonly [x: number, z: number];
  };
  readonly debugView?: SurfaceRuntimeTuning["debugView"];
}

/** Observable runtime counts used by the inspector and E2E. */
export interface SurfaceRuntimeSnapshot {
  /** Scatter and explicit instances serialized in `surface-instances.bin`. */
  readonly totalInstances: number;
  readonly totalRanges: number;
  readonly prototypes: number;
  /** Renderer batches allocated for every static and streamed LOD. */
  readonly rendererBatches: number;
  /** Renderer batches active after distance and LOD selection. */
  readonly visibleRendererBatches: number;
  readonly visibleRanges: number;
  readonly visibleInstances: number;
  /** Visible finite-region instances grouped by category after runtime density filtering. */
  readonly visibleCategoryCounts: Readonly<Record<SurfaceCategory, number>>;
  readonly transitioningRanges: number;
  readonly lodCounts: readonly number[];
  readonly categoryCounts: Readonly<Record<SurfaceCategory, number>>;
  readonly impostorInstances: number;
  readonly worldSurfaceAvailable: boolean;
  readonly worldInstances: number;
  readonly worldRendererBatches: number;
  readonly worldActiveRendererBatches: number;
  readonly worldRejectedByBudget: number;
  readonly worldCategoryCounts: Readonly<Record<SurfaceCategory, number>>;
  /** Stable 32-bit fingerprint of the currently streamed candidate identities. */
  readonly worldFingerprint: number;
  readonly coverageAvailable: boolean;
  /** Camera-local finite-region coverage instances currently submitted. */
  readonly coverageInstances: number;
  readonly coverageRendererBatches: number;
  readonly coverageActiveRendererBatches: number;
  readonly coverageCategoryCounts: Readonly<Record<SurfaceCategory, number>>;
  /** Stable 32-bit fingerprint of the current finite coverage identities. */
  readonly coverageFingerprint: number;
  readonly tuning: SurfaceRuntimeTuning;
}
