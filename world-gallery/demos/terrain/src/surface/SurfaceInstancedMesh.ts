import {
  BoundingBox,
  Buffer,
  BufferBindFlag,
  BufferMesh,
  BufferUsage,
  Engine,
  GLTFResource,
  IndexBufferBinding,
  IndexFormat,
  ModelMesh,
  Vector3,
  VertexBufferBinding,
  VertexElement,
  VertexElementFormat
} from "@galacean/engine";
import type { SurfacePrototypeRendererSpec } from "./SurfaceRuntimeContract";

export const SURFACE_INSTANCE_STRIDE = 64;

const indexBindings = new WeakMap<ModelMesh, IndexBufferBinding>();

/**
 * Creates an instanced view of one source primitive while sharing its immutable vertex/index buffers.
 * @param engine Engine that owns the instance mesh.
 * @param source Source glTF primitive.
 * @param instanceBuffer Interleaved surface transform/color stream.
 * @param bounds Complete world-space bounds for every instance in this mesh.
 * @param instanceCount Initial active instance count.
 * @param instanceBufferOffset Byte offset of this mesh's first instance record.
 * @returns BufferMesh sharing source geometry and owning the instance binding.
 */
export function createSurfaceInstancedMesh(
  engine: Engine,
  source: ModelMesh,
  instanceBuffer: Buffer,
  bounds: BoundingBox,
  instanceCount: number,
  instanceBufferOffset: number = 0
): BufferMesh {
  const mesh = new BufferMesh(engine, `${source.name}-surface-instances`);
  source.vertexBufferBindings.forEach((binding, index) => mesh.setVertexBufferBinding(binding, index));
  const indexBufferBinding = getIndexBufferBinding(engine, source);
  if (indexBufferBinding) mesh.setIndexBufferBinding(indexBufferBinding);
  const bindingIndex = source.vertexBufferBindings.length;
  mesh.setVertexBufferBinding(
    new VertexBufferBinding(instanceBuffer, SURFACE_INSTANCE_STRIDE, instanceBufferOffset),
    bindingIndex
  );
  mesh.setVertexElements([
    ...source.vertexElements,
    new VertexElement("INSTANCE_POSITION_META", 0, VertexElementFormat.Vector4, bindingIndex, 1),
    new VertexElement("INSTANCE_ROTATION", 16, VertexElementFormat.Vector4, bindingIndex, 1),
    new VertexElement("INSTANCE_SCALE_WIND", 32, VertexElementFormat.Vector4, bindingIndex, 1),
    new VertexElement("INSTANCE_COLOR", 48, VertexElementFormat.Vector4, bindingIndex, 1)
  ]);
  for (const subMesh of source.subMeshes) mesh.addSubMesh(subMesh.start, subMesh.count, subMesh.topology);
  mesh.bounds = bounds;
  mesh.instanceCount = instanceCount;
  return mesh;
}

/**
 * Rebinds the growable instance stream while preserving shared prototype geometry.
 * @param mesh Instanced surface mesh created by `createSurfaceInstancedMesh`.
 * @param instanceBuffer Replacement interleaved instance buffer.
 * @param instanceBufferOffset Replacement byte offset, or the existing offset when omitted.
 */
export function rebindSurfaceInstanceBuffer(
  mesh: BufferMesh,
  instanceBuffer: Buffer,
  instanceBufferOffset?: number
): void {
  const bindingIndex = mesh.vertexBufferBindings.length - 1;
  const previousBinding = mesh.vertexBufferBindings[bindingIndex];
  mesh.setVertexBufferBinding(
    new VertexBufferBinding(instanceBuffer, SURFACE_INSTANCE_STRIDE, instanceBufferOffset ?? previousBinding.offset),
    bindingIndex
  );
}

/**
 * Expands compiled placement bounds by the transformed prototype extent.
 * @param rangeBounds Compiled instance-position bounds.
 * @param prototypeBounds Prototype renderer bounds after local transform.
 * @param maxScale Largest instance scale in the range.
 * @returns Conservative complete mesh bounds.
 */
export function expandSurfaceBounds(
  rangeBounds: readonly [number, number, number, number, number, number],
  prototypeBounds: BoundingBox,
  maxScale: number
): BoundingBox {
  const sourceRadius =
    Math.max(
      Math.abs(prototypeBounds.min.x),
      Math.abs(prototypeBounds.min.y),
      Math.abs(prototypeBounds.min.z),
      Math.abs(prototypeBounds.max.x),
      Math.abs(prototypeBounds.max.y),
      Math.abs(prototypeBounds.max.z)
    ) * maxScale;
  return new BoundingBox(
    new Vector3(rangeBounds[0] - sourceRadius, rangeBounds[1] - sourceRadius, rangeBounds[2] - sourceRadius),
    new Vector3(rangeBounds[3] + sourceRadius, rangeBounds[4] + sourceRadius, rangeBounds[5] + sourceRadius)
  );
}

/**
 * Resolves all primitives belonging to one named glTF mesh.
 * @param resource Loaded glTF resource.
 * @param meshName Exact exported mesh name.
 * @returns All source primitives belonging to the mesh.
 */
export function findSurfaceModelMeshes(resource: GLTFResource, meshName: string): readonly ModelMesh[] {
  const meshGroups = resource.meshes ?? [];
  const exact = meshGroups.find((meshes) => meshes[0]?.name === meshName);
  if (exact) return exact;
  const normalized = meshGroups.find((meshes) => meshes[0]?.name.replace(/\.\d{3}$/, "") === meshName);
  if (normalized) return normalized;
  throw new Error(`[SurfaceWorld] ${resource.url} does not contain mesh ${meshName}`);
}

/**
 * Applies one prototype renderer's local transform to source mesh bounds.
 * @param bounds Source model-space bounds.
 * @param spec Renderer transform from the surface manifest.
 * @returns Bounds relative to the prototype instance origin.
 */
export function transformSurfaceBounds(bounds: BoundingBox, spec: SurfacePrototypeRendererSpec): BoundingBox {
  const minimum = new Vector3(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY);
  const maximum = new Vector3(Number.NEGATIVE_INFINITY, Number.NEGATIVE_INFINITY, Number.NEGATIVE_INFINITY);
  for (const x of [bounds.min.x, bounds.max.x]) {
    for (const y of [bounds.min.y, bounds.max.y]) {
      for (const z of [bounds.min.z, bounds.max.z]) {
        const point = rotateVector(
          [x * spec.localScale[0], y * spec.localScale[1], z * spec.localScale[2]],
          spec.localRotation
        );
        point[0] += spec.localPosition[0];
        point[1] += spec.localPosition[1];
        point[2] += spec.localPosition[2];
        minimum.x = Math.min(minimum.x, point[0]);
        minimum.y = Math.min(minimum.y, point[1]);
        minimum.z = Math.min(minimum.z, point[2]);
        maximum.x = Math.max(maximum.x, point[0]);
        maximum.y = Math.max(maximum.y, point[1]);
        maximum.z = Math.max(maximum.z, point[2]);
      }
    }
  }
  return new BoundingBox(minimum, maximum);
}

function getIndexBufferBinding(engine: Engine, source: ModelMesh): IndexBufferBinding | null {
  const cached = indexBindings.get(source);
  if (cached) return cached;
  const indices = source.getIndices();
  if (!indices) return null;
  const format =
    indices instanceof Uint8Array
      ? IndexFormat.UInt8
      : indices instanceof Uint16Array
        ? IndexFormat.UInt16
        : IndexFormat.UInt32;
  const binding = new IndexBufferBinding(
    new Buffer(engine, BufferBindFlag.IndexBuffer, indices, BufferUsage.Static),
    format
  );
  indexBindings.set(source, binding);
  return binding;
}

function rotateVector(
  value: readonly [number, number, number],
  rotation: readonly [number, number, number, number]
): [number, number, number] {
  const [x, y, z] = value;
  const [qx, qy, qz, qw] = rotation;
  const tx = 2 * (qy * z - qz * y);
  const ty = 2 * (qz * x - qx * z);
  const tz = 2 * (qx * y - qy * x);
  return [x + qw * tx + (qy * tz - qz * ty), y + qw * ty + (qz * tx - qx * tz), z + qw * tz + (qx * ty - qy * tx)];
}
