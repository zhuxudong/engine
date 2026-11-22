import type { Engine } from "../Engine";
import { Buffer } from "../graphic/Buffer";
import { BufferBindFlag } from "../graphic/enums/BufferBindFlag";
import { BufferUsage } from "../graphic/enums/BufferUsage";

interface Page {
  buffer?: Buffer;
  generation: number;
}

interface Entry {
  owner: number;
  words: Uint32Array;
  frame: number;
  generation: number;
  page: Page;
  offset: number;
}

/** Promotes byte-identical renderer data seen in separate frames to a stable, aligned GPU range. */
export class RendererUniformCache {
  private static readonly _budget = 2 * 1024 * 1024;
  private static readonly _pageSlots = 64;
  private readonly _entries = new Map<number, Entry>();
  private readonly _slots: Entry[] = [];
  private readonly _pages: Page[] = [];
  private _used = 0;
  private _reclaim = 0;
  private _reserved = 0;

  constructor(
    private readonly _engine: Engine,
    private readonly _binding: number,
    private readonly _stride: number
  ) {}

  bind(owner: number, words: Uint32Array): boolean {
    const frame = this._engine.time.frameCount;
    let entry = this._entries.get(owner);
    if (!entry) {
      entry = this._claim(words.length, frame);
      if (!entry) return false;
      entry.owner = owner;
      entry.words.set(words);
      entry.frame = frame;
      entry.generation = 0;
      this._entries.set(owner, entry);
      return false;
    }

    const previousFrame = entry.frame;
    entry.frame = frame;
    const previous = entry.words;
    for (let i = 0; i < words.length; i++) {
      if (words[i] !== previous[i]) {
        previous.set(words);
        entry.generation = 0;
        return false;
      }
    }

    const page = entry.page;
    let buffer = page.buffer;
    if (buffer && !buffer.isContentLost && entry.generation === page.generation) {
      buffer._bindUniformRange(this._binding, entry.offset, words.byteLength);
      return true;
    }
    // Changes within a frame use the dynamic ring. A previously drawn slice is never overwritten in that frame.
    if (previousFrame === frame) return false;
    if (!buffer) {
      buffer = page.buffer = new Buffer(
        this._engine,
        BufferBindFlag.ConstantBuffer,
        this._stride * RendererUniformCache._pageSlots,
        BufferUsage.Dynamic
      );
      buffer.isGCIgnored = true;
    }
    if (buffer.isContentLost) page.generation++;
    buffer._bindUniformRange(this._binding, entry.offset, words.byteLength, words);
    entry.generation = page.generation;
    return true;
  }

  destroy(): void {
    for (const page of this._pages) page.buffer?.destroy();
    this._engine._rendererUniformCacheBytes -= this._reserved;
  }

  private _claim(wordCount: number, frame: number): Entry | undefined {
    const slots = this._slots;
    if (this._used < slots.length) return slots[this._used++];
    const count = RendererUniformCache._pageSlots;
    // Reserve both the future GPU page and compact comparison records before admitting candidates.
    // The minimum charge also bounds the number of indexed entries under small device alignments.
    const charge = count * Math.max(256, this._stride + 4 * wordCount + 64);
    const engine = this._engine;
    if (engine._rendererUniformCacheBytes + charge <= RendererUniformCache._budget) {
      const page: Page = { generation: 1 };
      const snapshots = new Uint32Array(wordCount * count);
      for (let i = 0; i < count; ++i) {
        slots.push({
          owner: 0,
          words: snapshots.subarray(i * wordCount, (i + 1) * wordCount),
          frame: -1,
          generation: 0,
          page,
          offset: i * this._stride
        });
      }
      this._pages.push(page);
      this._reserved += charge;
      engine._rendererUniformCacheBytes += charge;
      return slots[this._used++];
    }
    if (slots.length) {
      const entry = slots[this._reclaim];
      this._reclaim = (this._reclaim + 1) % slots.length;
      // Keep active renderers resident; recycle a cold candidate without allocating a new record.
      if (entry.frame < frame - 1) {
        this._entries.delete(entry.owner);
        return entry;
      }
    }
  }
}
