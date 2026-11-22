import assert from "node:assert/strict";
import test from "node:test";
import { measureSubmissionBlocks } from "./metrics.mjs";

test("block timing includes native queue completion and excludes yields, old work and inspections", async () => {
  let clock = 0,
    engineFrames = 0,
    queuedMs = 25;
  const events = [];
  const result = await measureSubmissionBlocks({
    frames: 5,
    blockFrames: 2,
    now: () => clock,
    completed: () => engineFrames,
    yieldTask: async () => {
      events.push("yield");
      clock += 50;
    },
    drain: async () => {
      events.push("drain");
      await Promise.resolve();
      clock += queuedMs;
      queuedMs = 0;
    },
    update(index) {
      events.push(index);
      ++engineFrames;
      ++clock;
      queuedMs += 3;
    },
    afterBlock(last) {
      events.push("inspect" + last);
      clock += 20;
      queuedMs += 5;
    }
  });
  assert.deepEqual(events, [
    "yield",
    "drain",
    0,
    1,
    "drain",
    "inspect1",
    "yield",
    "drain",
    2,
    3,
    "drain",
    "inspect3",
    "yield",
    "drain",
    4,
    "drain",
    "inspect4"
  ]);
  assert.deepEqual(
    result.blocks.map(({ frames, milliseconds }) => [frames, milliseconds]),
    [
      [2, 8],
      [2, 8],
      [1, 4]
    ]
  );
  assert.equal(result.totalMs, 20);
  assert.equal(result.frames, 5);
  assert.equal(result.millisecondsPerFrame, 4);
  assert.equal(result.completedFramesPerSecond, 250);
  assert.deepEqual(result.blockDurationMs, { samples: 3, median: 8, p90: 8, p99: 8 });
});

test("an engine update that skips its native endFrame invalidates the block", async () => {
  let time = 0;
  const options = {
    frames: 4,
    blockFrames: 2,
    update() {},
    drain() {},
    yieldTask() {},
    completed: () => 0,
    now: () => time++
  };
  await assert.rejects(measureSubmissionBlocks(options), /Incomplete/);
  for (const blockFrames of [0, -1, 1.5, NaN]) {
    await assert.rejects(measureSubmissionBlocks({ ...options, blockFrames }), /Invalid submission block length/);
  }
});
