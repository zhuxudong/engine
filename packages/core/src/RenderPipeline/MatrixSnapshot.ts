import { Matrix } from "@galacean/engine-math";

/** Tracks exact matrix values, including edits made through the public elements array. */
export class MatrixSnapshot {
  private static _nextRevision = 0;
  private readonly _values = new Float32Array(16);
  revision = -1;

  update(matrix: Matrix): boolean {
    const current = matrix.elements;
    const previous = this._values;
    if (this.revision >= 0) {
      let i = 0;
      while (i < 16 && current[i] === previous[i]) ++i;
      if (i === 16) return false;
    }
    previous.set(current);
    this.revision = ++MatrixSnapshot._nextRevision;
    return true;
  }
}

const original = Symbol("calculated matrix");
type CalculatedMatrix = Matrix & { [original]: Float32Array | null };

/** A normal Matrix with a backup allocated only if an external caller can mutate its elements. */
export function createCalculatedMatrix(): CalculatedMatrix {
  const matrix = new Matrix() as CalculatedMatrix;
  matrix[original] = null;
  return matrix;
}

export function exposeCalculatedMatrix(value: unknown): void {
  const matrix = value as CalculatedMatrix | undefined;
  if (matrix?.[original] === null) matrix[original] = matrix.elements.slice();
}

export function saveCalculatedMatrix(matrix: CalculatedMatrix): void {
  matrix[original]?.set(matrix.elements);
}

export function restoreCalculatedMatrix(matrix: CalculatedMatrix): void {
  const values = matrix[original];
  if (values) matrix.elements.set(values);
}
