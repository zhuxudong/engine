import type { CompiledSurfaceManifest, SurfaceCategory, SurfaceRule } from "./SurfaceContract";

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
}

/** One compiled density mask exposed by the surface inspector. */
export interface SurfaceDebugMaskSpec {
  readonly id: string;
  readonly url: string;
}

/** Mutable category-level runtime controls that never alter compiled placement data. */
export interface SurfaceRuntimeTuning {
  readonly enabled: Readonly<Record<SurfaceCategory, boolean>>;
  readonly density: Readonly<Record<SurfaceCategory, number>>;
  readonly wind: {
    readonly enabled: boolean;
    readonly strength: number;
    readonly direction: readonly [x: number, y: number, z: number];
  };
  readonly lod: {
    readonly enabled: boolean;
    readonly distanceScale: number;
  };
  readonly debugView: "surface" | "normal";
}

/** Partial runtime-only update accepted by a surface world. */
export interface SurfaceRuntimeTuningUpdate {
  readonly enabled?: Partial<Record<SurfaceCategory, boolean>>;
  readonly density?: Partial<Record<SurfaceCategory, number>>;
  readonly wind?: Partial<SurfaceRuntimeTuning["wind"]>;
  readonly lod?: Partial<SurfaceRuntimeTuning["lod"]>;
  readonly debugView?: SurfaceRuntimeTuning["debugView"];
}

/** Observable runtime counts used by the inspector and E2E. */
export interface SurfaceRuntimeSnapshot {
  readonly totalInstances: number;
  readonly totalRanges: number;
  readonly prototypes: number;
  readonly rendererBatches: number;
  readonly visibleRanges: number;
  readonly visibleInstances: number;
  readonly transitioningRanges: number;
  readonly lodCounts: readonly number[];
  readonly categoryCounts: Readonly<Record<SurfaceCategory, number>>;
  readonly impostorInstances: number;
  readonly debugMasks: readonly SurfaceDebugMaskSpec[];
  readonly sourceRules: readonly SurfaceRule[];
  readonly tuning: SurfaceRuntimeTuning;
}
