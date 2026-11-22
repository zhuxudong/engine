import { TextureFormat } from "@galacean/engine-core";

/** Logical legacy pixel layouts stored in a native RGBA8 texture. */
export interface PixelPacking {
  bytes: number;
  bits?: readonly [number, number, number, number];
}
const rgb8: PixelPacking = { bytes: 3 };
const rgba4: PixelPacking = { bytes: 2, bits: [4, 4, 4, 4] };
const rgb5a1: PixelPacking = { bytes: 2, bits: [5, 5, 5, 1] };
const rgb565: PixelPacking = { bytes: 2, bits: [5, 6, 5, 0] };

export function pixelPacking(format: TextureFormat): PixelPacking | undefined {
  switch (format) {
    case TextureFormat.R8G8B8_UNorm:
      return rgb8;
    case TextureFormat.R4G4B4A4_UNorm:
      return rgba4;
    case TextureFormat.R5G5B5A1_UNorm:
      return rgb5a1;
    case TextureFormat.R5G6B5_UNorm:
      return rgb565;
  }
}

export function unpackRGBA8(input: ArrayBufferView, pixelCount: number, packing: PixelPacking): Uint8Array {
  if (input.byteLength < pixelCount * packing.bytes) throw new RangeError("Packed texture upload is too small.");
  const bytes = new Uint8Array(input.buffer, input.byteOffset, input.byteLength);
  const out = new Uint8Array(pixelCount * 4);
  for (let i = 0; i < pixelCount; i++) {
    const src = i * packing.bytes,
      dst = i * 4;
    if (!packing.bits) {
      out[dst] = bytes[src];
      out[dst + 1] = bytes[src + 1];
      out[dst + 2] = bytes[src + 2];
      out[dst + 3] = 255;
    } else {
      const value = bytes[src] | (bytes[src + 1] << 8);
      let shift = 16;
      for (let channel = 0; channel < 4; channel++) {
        const bits = packing.bits[channel],
          mask = (1 << bits) - 1;
        shift -= bits;
        out[dst + channel] = bits ? Math.round((((value >> shift) & mask) * 255) / mask) : 255;
      }
    }
  }
  return out;
}

export function packRGBA8Row(
  src: Uint8Array,
  srcStart: number,
  dst: Uint8Array,
  dstStart: number,
  width: number,
  packing: PixelPacking
): void {
  for (let i = 0; i < width; i++) {
    const read = srcStart + i * 4,
      write = dstStart + i * packing.bytes;
    if (!packing.bits) {
      dst[write] = src[read];
      dst[write + 1] = src[read + 1];
      dst[write + 2] = src[read + 2];
    } else {
      let value = 0;
      for (let channel = 0; channel < 4; channel++) {
        const bits = packing.bits[channel],
          mask = (1 << bits) - 1;
        value = (value << bits) | Math.round((src[read + channel] * mask) / 255);
      }
      dst[write] = value & 255;
      dst[write + 1] = value >> 8;
    }
  }
}
