import { GLTFResource } from "./GLTFResource";
import { AnimationParser } from "./parser/AnimationParser";
import { BufferParser } from "./parser/BufferParser";
import { EntityParser } from "./parser/EntityParser";
import { MaterialParser } from "./parser/MaterialParser";
import { MeshParser } from "./parser/MeshParser";
import { Parser } from "./parser/Parser";
import { SceneParser } from "./parser/SceneParser";
import { SkinParser } from "./parser/SkinParser";
import { TextureParser } from "./parser/TextureParser";
import { Validator } from "./parser/Validator";

export class GLTFParser {
  static instance = new GLTFParser([
    BufferParser,
    Validator,
    TextureParser,
    MaterialParser,
    MeshParser,
    EntityParser,
    SkinParser,
    AnimationParser,
    SceneParser
  ]);

  private static _isPromise(value: any): boolean {
    return value && typeof value.then === "function";
  }

  private _pipelinePasses: Parser[] = [];

  /**
   * @private
   */
  constructor(passes: (new () => Parser)[]) {
    passes.forEach((pass: new () => Parser, index: number) => {
      this._pipelinePasses[index] = new pass();
    });
  }

  parse(context: GLTFResource): Promise<GLTFResource> {
    let lastPipeOutput: void | Promise<void> = void 0;

    return new Promise((resolve, reject) => {
      this._pipelinePasses.forEach((parser: Parser) => {
        if (GLTFParser._isPromise(lastPipeOutput)) {
          lastPipeOutput = (lastPipeOutput as Promise<void>).then(() => {
            return parser.parse(context);
          });
        } else {
          lastPipeOutput = parser.parse(context);
        }
      });

      if (GLTFParser._isPromise(lastPipeOutput)) {
        (lastPipeOutput as Promise<void>)
          .then(() => {
            resolve(context);
          })
          .catch(reject);
      } else {
        resolve(context);
      }
    });
  }
}
