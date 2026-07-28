/**
 * Computes the stable RGB diagnostic color for a compiled surface cell.
 * @param x Integer surface-cell X coordinate.
 * @param z Integer surface-cell Z coordinate.
 * @returns RGB components in the diagnostic display range.
 */
export function surfaceCellDebugColor(x: number, z: number): [number, number, number] {
  const hue = surfaceCellDebugHue(x, z);
  const rainbow = [Math.abs(hue * 6 - 3) - 1, 2 - Math.abs(hue * 6 - 2), 2 - Math.abs(hue * 6 - 4)];
  return rainbow.map((component) => 0.35 + Math.min(1, Math.max(0, component)) * 0.65) as [number, number, number];
}

/**
 * Computes the stable scalar hue stored in a sorted finite-surface instance record.
 * @param x Integer surface-cell X coordinate.
 * @param z Integer surface-cell Z coordinate.
 * @returns Hue in the half-open 0..1 interval.
 */
export function surfaceCellDebugHue(x: number, z: number): number {
  let value = Math.imul(x, 0x9e3779b1) ^ Math.imul(z, 0x85ebca77);
  value ^= value >>> 16;
  value = Math.imul(value, 0x7feb352d);
  value ^= value >>> 15;
  return (value >>> 0) / 0x100000000;
}
