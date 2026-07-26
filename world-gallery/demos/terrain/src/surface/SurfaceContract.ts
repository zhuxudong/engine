/** Surface placement category understood by the generic runtime. */
export type SurfaceCategory = "grass" | "flower" | "shrub" | "tree" | "rock" | "cliff";

/** Offline placement algorithm selected by a surface rule. */
export type SurfaceCompileMode = "coverage" | "scatter" | "explicit";

/** One immutable grayscale mask supplied to the offline compiler. */
export interface SurfaceMask {
  readonly id: string;
  readonly width: number;
  readonly height: number;
  readonly pixels: Uint8Array;
}

/** Terrain values sampled by placement constraints. */
export interface SurfaceTerrainSample {
  readonly height: number;
  readonly slope: number;
  readonly control: number;
  readonly hole: boolean;
}

/** Terrain query boundary used by the offline compiler. */
export interface SurfaceTerrainSampler {
  /**
   * Samples exported terrain data at a world-space XZ position.
   * @param worldX World-space X coordinate in metres.
   * @param worldZ World-space Z coordinate in metres.
   * @returns Height, slope, control and hole values, or undefined outside authored terrain.
   */
  sample(worldX: number, worldZ: number): SurfaceTerrainSample | undefined;
}

/** Scale range applied independently to horizontal and vertical axes. */
export interface SurfaceScaleRange {
  readonly horizontal: readonly [min: number, max: number];
  readonly vertical: readonly [min: number, max: number];
}

/** Height, slope and terrain-layer filters for one placement rule. */
export interface SurfacePlacementConstraints {
  readonly height: readonly [min: number, max: number];
  readonly slope: readonly [min: number, max: number];
  readonly terrainLayers?: readonly number[];
  /** Minimum summed top-two control weight for the selected terrain layers. */
  readonly minimumLayerWeight?: number;
  readonly excludeHoles: boolean;
}

/** One deterministic coverage or scatter rule. */
export interface SurfaceRule {
  readonly id: string;
  readonly prototype: string;
  readonly category: SurfaceCategory;
  readonly mode: Exclude<SurfaceCompileMode, "explicit">;
  readonly mask: string;
  readonly densityPerSquareMetre: number;
  /** Candidate lattice spacing; scatter additionally enforces this as the minimum accepted distance. */
  readonly spacing: number;
  readonly scale: SurfaceScaleRange;
  readonly yaw: readonly [minRadians: number, maxRadians: number];
  readonly constraints: SurfacePlacementConstraints;
  readonly cellSize: number;
  readonly wind: boolean;
}

/** Designer-authored placement retained without procedural relocation. */
export interface SurfaceExplicitPlacement {
  readonly id: number;
  readonly prototype: string;
  readonly category: SurfaceCategory;
  readonly position: readonly [x: number, y: number, z: number];
  readonly rotation: readonly [x: number, y: number, z: number, w: number];
  readonly scale: readonly [x: number, y: number, z: number];
  readonly color: readonly [r: number, g: number, b: number, a: number];
  readonly windPhase?: number;
  readonly cellSize: number;
}

/** Complete deterministic input supplied to the offline surface compiler. */
export interface SurfaceCompileInput {
  readonly version: "1";
  readonly seed: number;
  readonly origin: readonly [x: number, z: number];
  readonly size: readonly [width: number, depth: number];
  readonly masks: readonly SurfaceMask[];
  readonly rules: readonly SurfaceRule[];
  readonly explicitPlacements: readonly SurfaceExplicitPlacement[];
  readonly terrain: SurfaceTerrainSampler;
}

/** Runtime instance encoded in `surface-instances.bin`. */
export interface SurfaceInstance {
  readonly prototype: string;
  readonly category: SurfaceCategory;
  readonly position: readonly [x: number, y: number, z: number];
  readonly rotation: readonly [x: number, y: number, z: number, w: number];
  readonly scale: readonly [x: number, y: number, z: number];
  readonly windPhase: number;
  readonly color: number;
  readonly sourceId: number;
  readonly cell: readonly [x: number, z: number];
}

/** Contiguous binary range sharing one prototype and spatial cell. */
export interface SurfaceCellRange {
  readonly prototype: string;
  readonly category: SurfaceCategory;
  readonly cell: readonly [x: number, z: number];
  readonly bounds: readonly [minX: number, minY: number, minZ: number, maxX: number, maxY: number, maxZ: number];
  readonly offset: number;
  readonly count: number;
}

/** Versioned manifest generated beside the binary instance payload. */
export interface CompiledSurfaceManifest {
  readonly version: "1";
  readonly seed: number;
  readonly binary: {
    readonly url: string;
    readonly format: "surface-instances-v1-le";
    readonly stride: 56;
    readonly count: number;
    readonly checksum: number;
  };
  readonly prototypes: readonly string[];
  readonly ranges: readonly SurfaceCellRange[];
}

/** Result of one deterministic offline compilation. */
export interface SurfaceCompileResult {
  readonly manifest: CompiledSurfaceManifest;
  readonly instances: readonly SurfaceInstance[];
  readonly binary: Uint8Array;
}
