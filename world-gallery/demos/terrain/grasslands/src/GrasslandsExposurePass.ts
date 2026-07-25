import {
  Blitter,
  type Camera,
  type Engine,
  Material,
  PostProcessPass,
  PostProcessPassEvent,
  type RenderTarget,
  Shader,
  ShaderProperty,
  type Texture2D
} from "@galacean/engine-core";

const EXPOSURE_SHADER_NAME = "Terrain/GrasslandsExposure";
const EXPOSURE_PROPERTY = ShaderProperty.getByName("material_ExposureMultiplier");
const EXPOSURE_SHADER_SOURCE = `
Shader "${EXPOSURE_SHADER_NAME}" {
  SubShader "Default" {
    Pass "Exposure" {
      DepthState = {
        Enabled = false;
        WriteEnabled = false;
      }

      VertexShader = vert;
      FragmentShader = frag;

      sampler2D renderer_BlitTexture;
      float material_ExposureMultiplier;

      struct Attributes {
        vec4 POSITION_UV;
      };

      struct Varyings {
        vec2 uv;
      };

      Varyings vert(Attributes attributes) {
        Varyings varyings;
        gl_Position = vec4(attributes.POSITION_UV.xy, 0.0, 1.0);
        varyings.uv = attributes.POSITION_UV.zw;
        return varyings;
      }

      void frag(Varyings varyings) {
        vec4 color = texture2D(renderer_BlitTexture, varyings.uv);
        gl_FragColor = vec4(color.rgb * material_ExposureMultiplier, color.a);
      }
    }
  }
}`;

/** Grasslands-only pre-tonemapping exposure matching Unity's post-exposure EV. */
export class GrasslandsExposurePass extends PostProcessPass {
  private readonly _material: Material;
  private _exposure = 0;

  /**
   * Allocates the fullscreen exposure pass.
   * @param engine Engine owning the pass and fullscreen material.
   */
  constructor(engine: Engine) {
    super(engine);
    this.event = PostProcessPassEvent.BeforeUber;
    const shader = Shader.find(EXPOSURE_SHADER_NAME) ?? Shader.create(EXPOSURE_SHADER_SOURCE);
    this._material = new Material(engine, shader);
    this.exposure = 0;
  }

  /** Exposure in stops, applied as `2^exposure` before ACES and Bloom. */
  get exposure(): number {
    return this._exposure;
  }

  set exposure(value: number) {
    this._exposure = value;
    this._material.shaderData.setFloat(EXPOSURE_PROPERTY, Math.pow(2, value));
  }

  /**
   * Multiplies the HDR scene color before the engine uber pass.
   * @param camera Rendering camera.
   * @param srcTexture HDR source color.
   * @param destTarget Destination selected by the post-process manager.
   */
  override onRender(camera: Camera, srcTexture: Texture2D, destTarget: RenderTarget): void {
    const viewport = destTarget === camera.renderTarget ? camera.viewport : undefined;
    Blitter.blitTexture(camera.engine, srcTexture, destTarget, 0, viewport, this._material);
  }

  override _onDestroy(): void {
    this._material.destroy();
    super._onDestroy();
  }
}
