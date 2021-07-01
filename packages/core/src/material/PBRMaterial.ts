import { Engine } from "../Engine";
import { Texture2D } from "../texture/Texture2D";
import { PBRBaseMaterial } from "./PBRBaseMaterial";

/**
 * PBR (Metallic-Roughness Workflow) Material.
 */
export class PBRMaterial extends PBRBaseMaterial {
  private _metallicFactor: number = 1;
  private _roughnessFactor: number = 1;
  private _metallicTexture: Texture2D;
  private _roughnessTexture: Texture2D;
  private _metallicRoughnessTexture: Texture2D;
  private _clearcoatFactor: number;
  private _clearcoatTexture: Texture2D;
  private _clearcoatRoughnessFactor: number;
  private _clearcoatRoughnessTexture: Texture2D;
  private _clearcoatNormalTexture: Texture2D;

  get clearcoatFactor(): number {
    return this._clearcoatFactor;
  }
  set clearcoatFactor(value: number) {
    this._clearcoatFactor = value;
    this.shaderData.setFloat("u_clearcoatFactor", value);

    if (value === 0) {
      this.shaderData.disableMacro("CLEARCOAT");
    } else {
      this.shaderData.enableMacro("CLEARCOAT");
    }
  }

  get clearcoatTexture(): Texture2D {
    return this._clearcoatTexture;
  }
  set clearcoatTexture(value: Texture2D) {
    this._clearcoatTexture = value;

    if (value) {
      this.shaderData.enableMacro("HAS_CLEARCOATTEXTURE");
      this.shaderData.setTexture("u_clearcoatTexture", value);
    } else {
      this.shaderData.disableMacro("HAS_CLEARCOATTEXTURE");
    }
  }

  get clearcoatRoughnessFactor(): number {
    return this._clearcoatRoughnessFactor;
  }
  set clearcoatRoughnessFactor(value: number) {
    this._clearcoatRoughnessFactor = value;
    this.shaderData.setFloat("u_clearcoatRoughnessFactor", value);
  }

  get clearcoatRoughnessTexture(): Texture2D {
    return this._clearcoatRoughnessTexture;
  }
  set clearcoatRoughnessTexture(value: Texture2D) {
    this._clearcoatRoughnessTexture = value;

    if (value) {
      this.shaderData.enableMacro("HAS_CLEARCOATROUGHNESSTEXTURE");
      this.shaderData.setTexture("u_clearcoatRoughnessTexture", value);
    } else {
      this.shaderData.disableMacro("HAS_CLEARCOATROUGHNESSTEXTURE");
    }
  }

  get clearcoatNormalTexture(): Texture2D {
    return this._clearcoatNormalTexture;
  }
  set clearcoatNormalTexture(value: Texture2D) {
    this._clearcoatNormalTexture = value;

    if (value) {
      this.shaderData.enableMacro("HAS_CLEARCOATNORMALTEXTURE");
      this.shaderData.setTexture("u_clearcoatNormalTexture", value);
    } else {
      this.shaderData.disableMacro("HAS_CLEARCOATNORMALTEXTURE");
    }
  }

  /**
   * Metallic factor.
   */
  get metallicFactor(): number {
    return this._metallicFactor;
  }

  set metallicFactor(v: number) {
    this._metallicFactor = v;
    this.shaderData.setFloat("u_metal", v);
  }

  /**
   * Rough factor.
   */
  get roughnessFactor(): number {
    return this._roughnessFactor;
  }

  set roughnessFactor(v: number) {
    this._roughnessFactor = v;
    this.shaderData.setFloat("u_roughness", v);
  }

  /**
   * Metallic texture.
   */
  get metallicTexture(): Texture2D {
    return this._metallicTexture;
  }

  set metallicTexture(v: Texture2D) {
    this._metallicTexture = v;

    if (v) {
      this.shaderData.enableMacro("HAS_METALMAP");
      this.shaderData.setTexture("u_metallicSampler", v);
    } else {
      this.shaderData.disableMacro("HAS_METALMAP");
    }
  }

  /**
   * Rough texture.
   */
  get roughnessTexture(): Texture2D {
    return this._roughnessTexture;
  }

  set roughnessTexture(v: Texture2D) {
    this._roughnessTexture = v;

    if (v) {
      this.shaderData.enableMacro("HAS_ROUGHNESSMAP");
      this.shaderData.setTexture("u_roughnessSampler", v);
    } else {
      this.shaderData.disableMacro("HAS_ROUGHNESSMAP");
    }
  }

  /**
   * Metallic rough texture.
   */
  get metallicRoughnessTexture(): Texture2D {
    return this._metallicRoughnessTexture;
  }

  set metallicRoughnessTexture(v: Texture2D) {
    this._metallicRoughnessTexture = v;

    if (v) {
      this.shaderData.enableMacro("HAS_METALROUGHNESSMAP");
      this.shaderData.setTexture("u_metallicRoughnessSampler", v);
    } else {
      this.shaderData.disableMacro("HAS_METALROUGHNESSMAP");
    }
  }

  /**
   * Create a pbr metallic-roughness workflow material instance.
   * @param engine - Engine to which the material belongs
   */
  constructor(engine: Engine) {
    super(engine);
    this.shaderData.enableMacro("IS_METALLIC_WORKFLOW");

    this.metallicFactor = this._metallicFactor;
    this.roughnessFactor = this._roughnessFactor;
  }

  /**
   * @override
   */
  clone(): PBRMaterial {
    const dest = new PBRMaterial(this._engine);
    this.cloneTo(dest);
    return dest;
  }
}
