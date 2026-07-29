import { BoundingBox, Plane, Vector3 } from "@galacean/engine-math";
import { describe, expect, it } from "vitest";
import { isSurfaceShadowRangeVisible } from "../../../world-gallery/demos/terrain/src/surface/SurfaceStaticBatcher";

describe("SurfaceStaticBatcher shadow range visibility", () => {
  const positiveX = new Plane(new Vector3(1, 0, 0), 0);

  it("keeps ranges in front of or intersecting a shadow plane", () => {
    const front = new BoundingBox(new Vector3(1, -1, -1), new Vector3(2, 1, 1));
    const intersecting = new BoundingBox(new Vector3(-1, -1, -1), new Vector3(1, 1, 1));

    expect(isSurfaceShadowRangeVisible(front, 1, [positiveX])).toBe(true);
    expect(isSurfaceShadowRangeVisible(intersecting, 1, [positiveX])).toBe(true);
  });

  it("rejects ranges wholly behind any active shadow plane", () => {
    const back = new BoundingBox(new Vector3(-2, -1, -1), new Vector3(-1, 1, 1));
    const maximumX = new Plane(new Vector3(-1, 0, 0), 2);
    const beyondMaximum = new BoundingBox(new Vector3(3, -1, -1), new Vector3(4, 1, 1));

    expect(isSurfaceShadowRangeVisible(back, 1, [positiveX])).toBe(false);
    expect(isSurfaceShadowRangeVisible(beyondMaximum, 2, [positiveX, maximumX])).toBe(false);
  });

  it("uses only the active prefix of the core shadow planes", () => {
    const range = new BoundingBox(new Vector3(1, -1, -1), new Vector3(2, 1, 1));
    const rejectingTail = new Plane(new Vector3(-1, 0, 0), 0);

    expect(isSurfaceShadowRangeVisible(range, 1, [positiveX, rejectingTail])).toBe(true);
    expect(isSurfaceShadowRangeVisible(range, 2, [positiveX, rejectingTail])).toBe(false);
  });
});
