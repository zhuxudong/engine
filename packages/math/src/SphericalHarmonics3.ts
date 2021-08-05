import { IClone } from "@oasis-engine/design";
import { Color } from "./Color";
import { Vector3 } from "./Vector3";

/**
 * Use SH3 to represent irradiance environment maps efficiently, allowing for interactive rendering of diffuse objects under distant illumination.
 * @remarks
 * https://graphics.stanford.edu/papers/envmap/envmap.pdf
 * http://www.ppsloan.org/publications/StupidSH36.pdf
 * https://google.github.io/filament/Filament.md.html#annex/sphericalharmonics
 */
export class SphericalHarmonics3 implements IClone {
  /** The coefficients of SphericalHarmonics3. */
  coefficients: Float32Array = new Float32Array(27);

  /**
   * Add direction light to SphericalHarmonics3.
   * @param color - Light color
   * @param direction - Light direction
   * @param intensity - Intensity of light
   */
  addDirectionalLight(color: Color, direction: Vector3, intensity: number): void {
    //Implements `EvalSHBasis` from [Projection from Cube maps] in http://www.ppsloan.org/publications/StupidSH36.pdf.

    /**
     * Basis constants
     *
     * 0: 1/2 * Math.sqrt(1 / Math.PI)
     *
     * 1: -1/2 * Math.sqrt(3 / Math.PI)
     * 2: 1/2 * Math.sqrt(3 / Math.PI)
     * 3: -1/2 * Math.sqrt(3 / Math.PI)
     *
     * 4: 1/2 * Math.sqrt(15 / Math.PI)
     * 5: -1/2 * Math.sqrt(15 / Math.PI)
     * 6: 1/4 * Math.sqrt(5 / Math.PI)
     * 7: -1/2 * Math.sqrt(15 / Math.PI)
     * 8: 1/4 * Math.sqrt(15 / Math.PI)
     */

    const src = this.coefficients;
    const { x, y, z } = direction;
    const xy = x * y;
    const yz = y * z;
    const z3 = 3 * z * z - 1;
    const xz = x * z;
    const x2y2 = x * x - y * y;

    color.scale(intensity);

    src[0] += color.r * 0.282095; // basis0
    src[1] += color.g * 0.282095;
    src[2] += color.b * 0.282095;

    src[3] += color.r * -0.488603 * y; // basis1
    src[4] += color.g * -0.488603 * y;
    src[5] += color.b * -0.488603 * y;
    src[6] += color.r * 0.488603 * z; // basis2
    src[7] += color.g * 0.488603 * z;
    src[8] += color.b * 0.488603 * z;
    src[9] += color.r * -0.488603 * x; // basis3
    src[10] += color.g * -0.488603 * x;
    src[11] += color.b * -0.488603 * x;

    src[12] += color.r * 1.092548 * xy; // basis4
    src[13] += color.g * 1.092548 * xy;
    src[14] += color.b * 1.092548 * xy;
    src[15] += color.r * -1.092548 * yz; // basis5
    src[16] += color.g * -1.092548 * yz;
    src[17] += color.b * -1.092548 * yz;
    src[18] += color.r * 0.315392 * z3; // basis6
    src[19] += color.g * 0.315392 * z3;
    src[20] += color.b * 0.315392 * z3;
    src[21] += color.r * -1.092548 * xz; // basis7
    src[22] += color.g * -1.092548 * xz;
    src[23] += color.b * -1.092548 * xz;
    src[24] += color.r * 0.546274 * x2y2; // basis8
    src[25] += color.g * 0.546274 * x2y2;
    src[26] += color.b * 0.546274 * x2y2;
  }

  /**
   * Scale the coefficients.
   * @param s - The amount by which to scale the SphericalHarmonics3
   */
  scale(s: number): void {
    const src = this.coefficients;

    src[0] *= s;
    src[1] *= s;
    src[2] *= s;
    src[3] *= s;
    src[4] *= s;
    src[5] *= s;
    src[6] *= s;
    src[7] *= s;
    src[8] *= s;
    src[9] *= s;
    src[10] *= s;
    src[11] *= s;
    src[12] *= s;
    src[13] *= s;
    src[14] *= s;
    src[15] *= s;
    src[16] *= s;
    src[17] *= s;
    src[18] *= s;
    src[19] *= s;
    src[20] *= s;
    src[21] *= s;
    src[22] *= s;
    src[23] *= s;
    src[24] *= s;
    src[25] *= s;
    src[26] *= s;
  }

  /**
   * Set the value of this spherical harmonics by an array.
   * @param array - The array
   * @param offset - The start offset of the array
   */
  setValueByArray(array: ArrayLike<number>, offset: number = 0): void {
    const src = this.coefficients;

    src[0] = array[offset];
    src[1] = array[1 + offset];
    src[2] = array[2 + offset];
    src[3] = array[3 + offset];
    src[4] = array[4 + offset];
    src[5] = array[5 + offset];
    src[6] = array[6 + offset];
    src[7] = array[7 + offset];
    src[8] = array[8 + offset];
    src[9] = array[9 + offset];
    src[10] = array[10 + offset];
    src[11] = array[11 + offset];
    src[12] = array[12 + offset];
    src[13] = array[13 + offset];
    src[14] = array[14 + offset];
    src[15] = array[15 + offset];
    src[16] = array[16 + offset];
    src[17] = array[17 + offset];
    src[18] = array[18 + offset];
    src[19] = array[19 + offset];
    src[20] = array[20 + offset];
    src[21] = array[21 + offset];
    src[22] = array[22 + offset];
    src[23] = array[23 + offset];
    src[24] = array[24 + offset];
    src[25] = array[25 + offset];
    src[26] = array[26 + offset];
  }

  /**
   * Clone the value of this spherical harmonics to an array.
   * @param out - The array
   * @param outOffset - The start offset of the array
   */
  toArray(out: number[] | Float32Array | Float64Array, outOffset: number = 0): void {
    const src = this.coefficients;

    out[0 + outOffset] = src[0];
    out[1 + outOffset] = src[1];
    out[2 + outOffset] = src[2];

    out[3 + outOffset] = src[3];
    out[4 + outOffset] = src[4];
    out[5 + outOffset] = src[5];
    out[6 + outOffset] = src[6];
    out[7 + outOffset] = src[7];
    out[8 + outOffset] = src[8];
    out[9 + outOffset] = src[9];
    out[10 + outOffset] = src[10];
    out[11 + outOffset] = src[11];

    out[12 + outOffset] = src[12];
    out[13 + outOffset] = src[13];
    out[14 + outOffset] = src[14];
    out[15 + outOffset] = src[15];
    out[16 + outOffset] = src[16];
    out[17 + outOffset] = src[17];
    out[18 + outOffset] = src[18];
    out[19 + outOffset] = src[19];
    out[20 + outOffset] = src[20];
    out[21 + outOffset] = src[21];
    out[22 + outOffset] = src[22];
    out[23 + outOffset] = src[23];
    out[24 + outOffset] = src[24];
    out[25 + outOffset] = src[25];
    out[26 + outOffset] = src[26];
  }

  /**
   * Creates a clone of this SphericalHarmonics3.
   * @returns A clone of this SphericalHarmonics3
   */
  clone(): SphericalHarmonics3 {
    const v = new SphericalHarmonics3();
    this.cloneTo(v);

    return v;
  }

  /**
   * Clones this SphericalHarmonics3 to the specified SphericalHarmonics3.
   * @param out - The specified SphericalHarmonics3
   * @returns The specified SphericalHarmonics3
   */
  cloneTo(out: SphericalHarmonics3): void {
    this.toArray(out.coefficients);
  }
}
