import {
  AssetType,
  Camera,
  Material,
  MeshRenderer,
  PrimitiveMesh,
  RenderTarget,
  Scene,
  Shader,
  SphericalHarmonics3,
  Texture2D,
  TextureCube,
  TextureCubeFace,
  TextureFilterMode,
  TextureFormat,
  WebGLEngine
} from "@galacean/engine";
import { panoramaToCube } from "../../../../../editor/packages/asset-bundle-utils/src/panorama-to-cube";
import iblBakerShaderSource from "../../../../../editor/galacean-tools-root/packages/baker/compiledShaders/IBLBaker.shaderc?raw";

const BAKE_RESOLUTION = 256;
const DECODE_MODE_LINEAR = 0;

declare global {
  interface Window {
    /** Resolves when the offline ambient-light bake has produced a downloadable asset. */
    terrainAmbientBake?: Promise<void>;
  }
}

const status = document.querySelector<HTMLOutputElement>("#status")!;

window.terrainAmbientBake = bake().catch((error: unknown) => {
  status.value = error instanceof Error ? error.message : String(error);
  throw error;
});

async function bake(): Promise<void> {
  status.value = "loading HDR";
  const engine = await WebGLEngine.create({ canvas: "bake-canvas" });
  const hdr = await engine.resourceManager.load<Texture2D>({
    type: AssetType.Texture,
    url: new URL("../data/environment/terrain-sky.hdr", import.meta.url).href,
    params: { mipmap: false }
  });
  const pixels = readHdrPixels(hdr);
  const { faceSize, faces } = panoramaToCube(pixels, hdr.width, hdr.height, 512);
  const source = new TextureCube(engine, faceSize, TextureFormat.R16G16B16A16, true, false);
  for (let face = 0; face < 6; face++) {
    source.setPixelBuffer(TextureCubeFace.PositiveX + face, toHalfFloat(faces[face]));
  }
  source.generateMipmaps();

  status.value = "prefiltering environment";
  const baked = bakeSpecularEnvironment(source, BAKE_RESOLUTION, DECODE_MODE_LINEAR);
  const sh = bakeSphericalHarmonics(baked);
  const asset = serializeAmbientLight(baked, sh);
  download(asset);
  status.value = `done (${Math.round(asset.byteLength / 1024)} KiB)`;
  source.destroy();
  baked.destroy();
  engine.destroy();
}

function readHdrPixels(texture: Texture2D): Float32Array {
  const source = new Uint16Array(texture.width * texture.height * 4);
  texture.getPixelBuffer(source);
  const result = new Float32Array(source.length);
  for (let index = 0; index < source.length; index++) result[index] = halfToFloat(source[index]);
  return result;
}

function toHalfFloat(pixels: Float32Array): Uint16Array {
  const result = new Uint16Array(pixels.length);
  for (let index = 0; index < pixels.length; index++) result[index] = floatToHalfFloat(pixels[index]);
  return result;
}

function floatToHalfFloat(value: number): number {
  const view = new Float32Array(1);
  const bits = new Uint32Array(view.buffer);
  view[0] = value;
  const word = bits[0];
  const exponent = (word >>> 23) & 0xff;
  const mantissa = word & 0x7fffff;
  const sign = (word >>> 16) & 0x8000;
  if (exponent <= 112) return sign;
  if (exponent >= 143) return sign | 0x7c00;
  return sign | ((exponent - 112) << 10) | (mantissa >>> 13);
}

function download(asset: ArrayBuffer): void {
  const link = document.createElement("a");
  link.href = URL.createObjectURL(new Blob([asset], { type: "application/octet-stream" }));
  link.download = "terrain-sky.ambLight";
  link.click();
  setTimeout(() => URL.revokeObjectURL(link.href), 0);
}

const IBL_BAKER_SHADER_NAME = "Galacean-IBL-baker";
function bakeSpecularEnvironment(texture: TextureCube, resolution: number, decodeMode: number): TextureCube {
  const engine = texture.engine;
  const originalFilterMode = texture.filterMode;
  const originalScene = engine.sceneManager.activeScene;
  const wasPaused = engine.isPaused;

  engine.pause();
  const shaderRegistry = Shader as typeof Shader & { _createFromPrecompiled(data: unknown): Shader };
  Shader.find(IBL_BAKER_SHADER_NAME) || shaderRegistry._createFromPrecompiled(JSON.parse(iblBakerShaderSource));

  const scene = new Scene(engine);
  engine.sceneManager.activeScene = scene;
  const entity = scene.createRootEntity("Ambient Bake");
  const camera = entity.addComponent(Camera);
  camera.enableFrustumCulling = false;
  const material = new Material(engine, Shader.find(IBL_BAKER_SHADER_NAME));
  const renderer = entity.addComponent(MeshRenderer);
  renderer.mesh = PrimitiveMesh.createPlane(engine, 2, 2);
  renderer.setMaterial(material);

  const output = new TextureCube(engine, resolution, TextureFormat.R16G16B16A16, undefined, false);
  texture.filterMode = TextureFilterMode.Trilinear;
  output.filterMode = TextureFilterMode.Trilinear;
  const renderTarget = new RenderTarget(engine, resolution, resolution, output);
  renderTarget.autoGenerateMipmaps = false;
  camera.renderTarget = renderTarget;

  const shaderData = material.shaderData;
  shaderData.setTexture("environmentMap", texture);
  shaderData.setFloat("u_textureSize", resolution);
  shaderData.enableMacro("DECODE_MODE", decodeMode + "");

  for (let face = 0; face < 6; face++) {
    for (let lod = 0; lod < output.mipmapCount; lod++) {
      shaderData.setFloat("face", face);
      shaderData.setFloat("lodRoughness", lod / (output.mipmapCount - 1));
      camera.render(TextureCubeFace.PositiveX + face, lod);
    }
  }

  camera.renderTarget = null;
  scene.destroy();
  renderTarget.destroy();
  engine.sceneManager.activeScene = originalScene;
  texture.filterMode = originalFilterMode;
  !wasPaused && engine.resume();
  return output;
}

function bakeSphericalHarmonics(texture: TextureCube): SphericalHarmonics3 {
  const size = texture.width;
  const coefficients = new Float32Array(27);
  let solidAngleSum = 0;

  for (let face = 0; face < 6; face++) {
    const pixels = new Uint16Array(size * size * 4);
    texture.getPixelBuffer(TextureCubeFace.PositiveX + face, 0, 0, size, size, 0, pixels);
    solidAngleSum = decodeCubeFace(pixels, face, size, solidAngleSum, coefficients);
  }

  const normalization = (4 * Math.PI) / solidAngleSum;
  for (let index = 0; index < coefficients.length; index++) coefficients[index] *= normalization;
  const result = new SphericalHarmonics3();
  result.copyFromArray(coefficients);
  return result;
}

function decodeCubeFace(
  pixels: Uint16Array,
  face: number,
  size: number,
  previousSolidAngleSum: number,
  coefficients: Float32Array
): number {
  let solidAngleSum = previousSolidAngleSum;
  const direction = [0, 0, 0];
  const color = [0, 0, 0];
  const inverseSize = 1 / size;

  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const offset = (y * size + x) * 4;
      color[0] = halfToFloat(pixels[offset]);
      color[1] = halfToFloat(pixels[offset + 1]);
      color[2] = halfToFloat(pixels[offset + 2]);
      const u = (x + 0.5) * 2 * inverseSize - 1;
      const v = (y + 0.5) * 2 * inverseSize - 1;
      setCubeDirection(face, u, v, direction);
      const directionLength = Math.hypot(direction[0], direction[1], direction[2]);
      direction[0] /= directionLength;
      direction[1] /= directionLength;
      direction[2] /= directionLength;
      const solidAngle = cubeTexelSolidAngle(size, x, y);
      solidAngleSum += solidAngle;
      addSphericalHarmonics(direction, color, solidAngle, coefficients);
    }
  }
  return solidAngleSum;
}

function setCubeDirection(face: number, u: number, v: number, direction: number[]): void {
  switch (face) {
    case TextureCubeFace.PositiveX:
      direction[0] = 1; direction[1] = -v; direction[2] = -u;
      break;
    case TextureCubeFace.NegativeX:
      direction[0] = -1; direction[1] = -v; direction[2] = u;
      break;
    case TextureCubeFace.PositiveY:
      direction[0] = u; direction[1] = 1; direction[2] = v;
      break;
    case TextureCubeFace.NegativeY:
      direction[0] = u; direction[1] = -1; direction[2] = -v;
      break;
    case TextureCubeFace.PositiveZ:
      direction[0] = u; direction[1] = -v; direction[2] = 1;
      break;
    default:
      direction[0] = -u; direction[1] = -v; direction[2] = -1;
  }
}

function addSphericalHarmonics(direction: number[], color: number[], solidAngle: number, coefficients: Float32Array): void {
  const x = direction[0];
  const y = direction[1];
  const z = direction[2];
  const r = color[0] * solidAngle;
  const g = color[1] * solidAngle;
  const b = color[2] * solidAngle;
  const basis = [
    0.282095,
    -0.488603 * y,
    0.488603 * z,
    -0.488603 * x,
    1.092548 * x * y,
    -1.092548 * y * z,
    0.315392 * (3 * z * z - 1),
    -1.092548 * x * z,
    0.546274 * (x * x - y * y)
  ];
  for (let index = 0; index < basis.length; index++) {
    const offset = index * 3;
    coefficients[offset] += r * basis[index];
    coefficients[offset + 1] += g * basis[index];
    coefficients[offset + 2] += b * basis[index];
  }
}

function cubeTexelSolidAngle(size: number, x: number, y: number): number {
  const inverseSize = 1 / size;
  const s = (x + 0.5) * 2 * inverseSize - 1;
  const t = (y + 0.5) * 2 * inverseSize - 1;
  return sphereQuadrantArea(s - inverseSize, t - inverseSize) -
    sphereQuadrantArea(s - inverseSize, t + inverseSize) -
    sphereQuadrantArea(s + inverseSize, t - inverseSize) +
    sphereQuadrantArea(s + inverseSize, t + inverseSize);
}

function sphereQuadrantArea(x: number, y: number): number {
  return Math.atan2(x * y, Math.sqrt(x * x + y * y + 1));
}

function halfToFloat(halfBits: number): number {
  const sign = halfBits & 0x8000 ? -1 : 1;
  const exponent = (halfBits >> 10) & 0x1f;
  const mantissa = halfBits & 0x03ff;
  if (exponent === 0x1f) return mantissa === 0 ? sign * Infinity : NaN;
  if (exponent === 0) return sign * 2 ** -14 * (mantissa / 1024);
  return sign * 2 ** (exponent - 15) * (1 + mantissa / 1024);
}

function serializeAmbientLight(texture: TextureCube, sh: SphericalHarmonics3): ArrayBuffer {
  const header = new TextEncoder().encode("AmbientLight");
  const headerLength = ((4 + 4 + 1 + 2 + header.length + 2) + 3) & ~3;
  const coefficients = new Float32Array(27);
  sh.copyToArray(coefficients);
  const faces: Uint16Array[] = [];
  let faceByteLength = 0;
  for (let mip = 0; mip < texture.mipmapCount; mip++) {
    const size = texture.width >> mip;
    for (let face = 0; face < 6; face++) {
      const pixels = new Uint16Array(size * size * 4);
      texture.getPixelBuffer(TextureCubeFace.PositiveX + face, 0, 0, size, size, mip, pixels);
      faces.push(pixels);
      faceByteLength += pixels.byteLength;
    }
  }

  const buffer = new ArrayBuffer(headerLength + 27 * 4 + 2 + faceByteLength);
  const view = new DataView(buffer);
  view.setUint32(0, 0x4e434c47, true);
  view.setUint32(4, buffer.byteLength, true);
  view.setUint8(8, 1);
  view.setUint16(9, header.length, true);
  new Uint8Array(buffer, 11, header.length).set(header);
  view.setUint16(11 + header.length, 0, true);
  for (let index = 0; index < coefficients.length; index++) view.setFloat32(headerLength + index * 4, coefficients[index], true);
  view.setUint16(headerLength + 27 * 4, texture.width, true);

  let offset = headerLength + 27 * 4 + 2;
  for (const pixels of faces) {
    for (let index = 0; index < pixels.length; index++, offset += 2) view.setUint16(offset, pixels[index], true);
  }
  return buffer;
}
