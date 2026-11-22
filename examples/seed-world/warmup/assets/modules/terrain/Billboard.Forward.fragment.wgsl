diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ProjectionParams: vec4<f32>,
    camera_ViewMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    scene_GrassSeasonColor: vec4<f32>,
    scene_TreeLeafSeasonColor: vec4<f32>,
    scene_TreeBarkSeasonColor: vec4<f32>,
}

struct gs_Auto_1_ {
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    renderer_NormalMat: mat4x4<f32>,
    material_WindForce: f32,
    material_WindWavesScale: f32,
    material_WindFlowDensity: f32,
    material_UVBaseLock: f32,
    material_GrassDistanceFadeEnable: f32,
    material_GrassFadeDistance: f32,
    material_GrassFalloff: f32,
    scene_WindVelocity: vec3<f32>,
    scene_WindSpectrumAdvectionOffset: vec3<f32>,
    scene_WindAnimationEnabled: f32,
    scene_WindFieldParams: vec4<f32>,
    scene_WindLayerMultipliers: vec3<f32>,
    scene_WindSpectrumParams: vec4<f32>,
    scene_WindLocalFieldTransform: vec4<f32>,
    scene_WindLocalFieldTemporalParams: vec4<f32>,
    scene_WindGroundResponseParams: vec4<f32>,
    scene_WindFlowerResponseParams: vec4<f32>,
    scene_WindGroundReferenceGustHistory: vec4<f32>,
    scene_WindTreeResponseParams: vec4<f32>,
    scene_WindGroundResponseRampDuration: f32,
    scene_WindGrassProfile0_: vec4<f32>,
    scene_WindGrassProfile1_: vec4<f32>,
    scene_WindGrassProfile2_: vec4<f32>,
    scene_WindFlowerProfile0_: vec4<f32>,
    scene_WindFlowerProfile1_: vec4<f32>,
    scene_WindFlowerProfile2_: vec4<f32>,
    scene_WindLeafProfile0_: vec4<f32>,
    scene_WindLeafProfile1_: vec4<f32>,
    scene_WindLeafProfile2_: vec4<f32>,
    scene_WindShrubProfile0_: vec4<f32>,
    scene_WindShrubProfile1_: vec4<f32>,
    scene_WindShrubProfile2_: vec4<f32>,
    scene_WindBranchProfile0_: vec4<f32>,
    scene_WindBranchProfile1_: vec4<f32>,
    scene_WindBranchProfile2_: vec4<f32>,
    scene_WindBillboardProfile0_: vec4<f32>,
    scene_WindBillboardProfile1_: vec4<f32>,
    scene_WindBillboardProfile2_: vec4<f32>,
    camera_Forward: vec3<f32>,
    material_BaseColor: vec4<f32>,
    material_Tiling: f32,
    material_AlphaCutoff: f32,
    material_Smoothness: f32,
    material_NormalScale: f32,
    scene_SurfaceClimate: vec4<f32>,
    scene_SurfaceSnowColor: vec4<f32>,
    renderer_Layer: vec4<i32>,
}

struct SurfaceData {
    albedoColor: vec3<f32>,
    emissiveColor: vec3<f32>,
    metallic: f32,
    roughness: f32,
    ambientOcclusion: f32,
    opacity: f32,
    IOR: f32,
    position: vec3<f32>,
    positionCS: vec4<f32>,
    normal: vec3<f32>,
    viewDir: vec3<f32>,
    dotNV: f32,
    specularIntensity: f32,
    specularColor: vec3<f32>,
}

struct BSDFData {
    diffuseColor: vec3<f32>,
    roughness: f32,
    envSpecularDFG: vec3<f32>,
    diffuseAO: f32,
    specularF0_: vec3<f32>,
    resolvedSpecularF0_: vec3<f32>,
    specularF90_: f32,
    energyCompensation: vec3<f32>,
}

struct EnvMapLight {
    diffuse: vec3<f32>,
    mipMapLevel: f32,
    diffuseIntensity: f32,
    specularIntensity: f32,
    mipMapLevel2_: f32,
    specularTextureBlend: f32,
}

struct gs_Auto_2_ {
    words: array<vec4<u32>, 2>,
}

struct TerrainProjectLightingResult {
    directDiffuse: vec3<f32>,
    directSpecular: vec3<f32>,
    environmentDiffuse: vec3<f32>,
    environmentSpecular: vec3<f32>,
    shadowAttenuation: f32,
}

struct FragmentOutput {
    @location(0) output_color: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> output_color: vec4<f32>;
var<private> uv_5: vec2<f32>;
var<private> positionWS_3: vec3<f32>;
var<private> normalWS_3: vec3<f32>;
var<private> positionCS_1: vec4<f32>;
@group(2) @binding(2) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;
var<private> gl_FragCoord_1: vec4<f32>;

fn pow2_(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e115: f32 = x_1;
    let _e116: f32 = x_1;
    return (_e115 * _e116);
}

fn sRGBToLinear(value: f32) -> f32 {
    var value_1: f32;
    var linearRGBLo: f32;
    var linearRGBHi: f32;
    var local: f32;
    var linearRGB: f32;

    value_1 = value;
    let _e115: f32 = value_1;
    linearRGBLo = (_e115 / 12.92f);
    let _e119: f32 = value_1;
    linearRGBHi = pow(((_e119 + 0.055f) / 1.055f), 2.4f);
    let _e127: f32 = value_1;
    if (_e127 <= 0.04045f) {
        let _e130: f32 = linearRGBLo;
        local = _e130;
    } else {
        let _e131: f32 = linearRGBHi;
        local = _e131;
    }
    let _e133: f32 = local;
    linearRGB = _e133;
    let _e135: f32 = linearRGB;
    return _e135;
}

fn sRGBToLinear_1(value_2: vec4<f32>) -> vec4<f32> {
    var value_3: vec4<f32>;

    value_3 = value_2;
    let _e115: vec4<f32> = value_3;
    let _e117: f32 = sRGBToLinear(_e115.x);
    let _e118: vec4<f32> = value_3;
    let _e120: f32 = sRGBToLinear(_e118.y);
    let _e121: vec4<f32> = value_3;
    let _e123: f32 = sRGBToLinear(_e121.z);
    let _e124: vec4<f32> = value_3;
    return vec4<f32>(_e117, _e120, _e123, _e124.w);
}

fn texture2DSRGB(gs_wgpu_tex_tex: texture_2d<f32>, gs_wgpu_samp_tex: sampler, uv_1: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;
    var color: vec4<f32>;

    uv_2 = uv_1;
    let _e117: vec2<f32> = uv_2;
    let _e118: vec4<f32> = textureSample(gs_wgpu_tex_tex, gs_wgpu_samp_tex, _e117);
    color = _e118;
    let _e120: vec4<f32> = color;
    return _e120;
}

fn inverseMat(m: mat2x2<f32>) -> mat2x2<f32> {
    var m_1: mat2x2<f32>;

    m_1 = m;
    let _e119: f32 = m_1[1][1];
    let _e124: f32 = m_1[0][1];
    let _e130: f32 = m_1[1][0];
    let _e136: f32 = m_1[0][0];
    let _e139: mat2x2<f32> = mat2x2<f32>(vec2<f32>(_e119, -(_e124)), vec2<f32>(-(_e130), _e136));
    let _e144: f32 = m_1[0][0];
    let _e149: f32 = m_1[1][1];
    let _e155: f32 = m_1[0][1];
    let _e160: f32 = m_1[1][0];
    let _e163: vec2<f32> = vec2(((_e144 * _e149) - (_e155 * _e160)));
    return mat2x2<f32>((_e139[0] / _e163), (_e139[1] / _e163));
}

fn inverseMat_1(m_2: mat3x3<f32>) -> mat3x3<f32> {
    var m_3: mat3x3<f32>;
    var a00_: f32;
    var a01_: f32;
    var a02_: f32;
    var a10_: f32;
    var a11_: f32;
    var a12_: f32;
    var a20_: f32;
    var a21_: f32;
    var a22_: f32;
    var b01_: f32;
    var b11_: f32;
    var b21_: f32;
    var det: f32;

    m_3 = m_2;
    let _e119: f32 = m_3[0][0];
    a00_ = _e119;
    let _e125: f32 = m_3[0][1];
    a01_ = _e125;
    let _e131: f32 = m_3[0][2];
    a02_ = _e131;
    let _e137: f32 = m_3[1][0];
    a10_ = _e137;
    let _e143: f32 = m_3[1][1];
    a11_ = _e143;
    let _e149: f32 = m_3[1][2];
    a12_ = _e149;
    let _e155: f32 = m_3[2][0];
    a20_ = _e155;
    let _e161: f32 = m_3[2][1];
    a21_ = _e161;
    let _e167: f32 = m_3[2][2];
    a22_ = _e167;
    let _e169: f32 = a22_;
    let _e170: f32 = a11_;
    let _e172: f32 = a12_;
    let _e173: f32 = a21_;
    b01_ = ((_e169 * _e170) - (_e172 * _e173));
    let _e177: f32 = a22_;
    let _e179: f32 = a10_;
    let _e181: f32 = a12_;
    let _e182: f32 = a20_;
    b11_ = ((-(_e177) * _e179) + (_e181 * _e182));
    let _e186: f32 = a21_;
    let _e187: f32 = a10_;
    let _e189: f32 = a11_;
    let _e190: f32 = a20_;
    b21_ = ((_e186 * _e187) - (_e189 * _e190));
    let _e194: f32 = a00_;
    let _e195: f32 = b01_;
    let _e197: f32 = a01_;
    let _e198: f32 = b11_;
    let _e201: f32 = a02_;
    let _e202: f32 = b21_;
    det = (((_e194 * _e195) + (_e197 * _e198)) + (_e201 * _e202));
    let _e206: f32 = b01_;
    let _e207: f32 = a22_;
    let _e209: f32 = a01_;
    let _e211: f32 = a02_;
    let _e212: f32 = a21_;
    let _e215: f32 = a12_;
    let _e216: f32 = a01_;
    let _e218: f32 = a02_;
    let _e219: f32 = a11_;
    let _e222: f32 = b11_;
    let _e223: f32 = a22_;
    let _e224: f32 = a00_;
    let _e226: f32 = a02_;
    let _e227: f32 = a20_;
    let _e230: f32 = a12_;
    let _e232: f32 = a00_;
    let _e234: f32 = a02_;
    let _e235: f32 = a10_;
    let _e238: f32 = b21_;
    let _e239: f32 = a21_;
    let _e241: f32 = a00_;
    let _e243: f32 = a01_;
    let _e244: f32 = a20_;
    let _e247: f32 = a11_;
    let _e248: f32 = a00_;
    let _e250: f32 = a01_;
    let _e251: f32 = a10_;
    let _e257: mat3x3<f32> = mat3x3<f32>(vec3<f32>(_e206, ((-(_e207) * _e209) + (_e211 * _e212)), ((_e215 * _e216) - (_e218 * _e219))), vec3<f32>(_e222, ((_e223 * _e224) - (_e226 * _e227)), ((-(_e230) * _e232) + (_e234 * _e235))), vec3<f32>(_e238, ((-(_e239) * _e241) + (_e243 * _e244)), ((_e247 * _e248) - (_e250 * _e251))));
    let _e258: f32 = det;
    let _e259: vec3<f32> = vec3(_e258);
    return mat3x3<f32>((_e257[0] / _e259), (_e257[1] / _e259), (_e257[2] / _e259));
}

fn inverseMat_2(m_4: mat4x4<f32>) -> mat4x4<f32> {
    var m_5: mat4x4<f32>;
    var a00_1: f32;
    var a01_1: f32;
    var a02_1: f32;
    var a03_: f32;
    var a10_1: f32;
    var a11_1: f32;
    var a12_1: f32;
    var a13_: f32;
    var a20_1: f32;
    var a21_1: f32;
    var a22_1: f32;
    var a23_: f32;
    var a30_: f32;
    var a31_: f32;
    var a32_: f32;
    var a33_: f32;
    var b00_: f32;
    var b01_1: f32;
    var b02_: f32;
    var b03_: f32;
    var b04_: f32;
    var b05_: f32;
    var b06_: f32;
    var b07_: f32;
    var b08_: f32;
    var b09_: f32;
    var b10_: f32;
    var b11_1: f32;
    var det_1: f32;

    m_5 = m_4;
    let _e119: f32 = m_5[0][0];
    a00_1 = _e119;
    let _e125: f32 = m_5[0][1];
    a01_1 = _e125;
    let _e131: f32 = m_5[0][2];
    a02_1 = _e131;
    let _e137: f32 = m_5[0][3];
    a03_ = _e137;
    let _e143: f32 = m_5[1][0];
    a10_1 = _e143;
    let _e149: f32 = m_5[1][1];
    a11_1 = _e149;
    let _e155: f32 = m_5[1][2];
    a12_1 = _e155;
    let _e161: f32 = m_5[1][3];
    a13_ = _e161;
    let _e167: f32 = m_5[2][0];
    a20_1 = _e167;
    let _e173: f32 = m_5[2][1];
    a21_1 = _e173;
    let _e179: f32 = m_5[2][2];
    a22_1 = _e179;
    let _e185: f32 = m_5[2][3];
    a23_ = _e185;
    let _e191: f32 = m_5[3][0];
    a30_ = _e191;
    let _e197: f32 = m_5[3][1];
    a31_ = _e197;
    let _e203: f32 = m_5[3][2];
    a32_ = _e203;
    let _e209: f32 = m_5[3][3];
    a33_ = _e209;
    let _e211: f32 = a00_1;
    let _e212: f32 = a11_1;
    let _e214: f32 = a01_1;
    let _e215: f32 = a10_1;
    b00_ = ((_e211 * _e212) - (_e214 * _e215));
    let _e219: f32 = a00_1;
    let _e220: f32 = a12_1;
    let _e222: f32 = a02_1;
    let _e223: f32 = a10_1;
    b01_1 = ((_e219 * _e220) - (_e222 * _e223));
    let _e227: f32 = a00_1;
    let _e228: f32 = a13_;
    let _e230: f32 = a03_;
    let _e231: f32 = a10_1;
    b02_ = ((_e227 * _e228) - (_e230 * _e231));
    let _e235: f32 = a01_1;
    let _e236: f32 = a12_1;
    let _e238: f32 = a02_1;
    let _e239: f32 = a11_1;
    b03_ = ((_e235 * _e236) - (_e238 * _e239));
    let _e243: f32 = a01_1;
    let _e244: f32 = a13_;
    let _e246: f32 = a03_;
    let _e247: f32 = a11_1;
    b04_ = ((_e243 * _e244) - (_e246 * _e247));
    let _e251: f32 = a02_1;
    let _e252: f32 = a13_;
    let _e254: f32 = a03_;
    let _e255: f32 = a12_1;
    b05_ = ((_e251 * _e252) - (_e254 * _e255));
    let _e259: f32 = a20_1;
    let _e260: f32 = a31_;
    let _e262: f32 = a21_1;
    let _e263: f32 = a30_;
    b06_ = ((_e259 * _e260) - (_e262 * _e263));
    let _e267: f32 = a20_1;
    let _e268: f32 = a32_;
    let _e270: f32 = a22_1;
    let _e271: f32 = a30_;
    b07_ = ((_e267 * _e268) - (_e270 * _e271));
    let _e275: f32 = a20_1;
    let _e276: f32 = a33_;
    let _e278: f32 = a23_;
    let _e279: f32 = a30_;
    b08_ = ((_e275 * _e276) - (_e278 * _e279));
    let _e283: f32 = a21_1;
    let _e284: f32 = a32_;
    let _e286: f32 = a22_1;
    let _e287: f32 = a31_;
    b09_ = ((_e283 * _e284) - (_e286 * _e287));
    let _e291: f32 = a21_1;
    let _e292: f32 = a33_;
    let _e294: f32 = a23_;
    let _e295: f32 = a31_;
    b10_ = ((_e291 * _e292) - (_e294 * _e295));
    let _e299: f32 = a22_1;
    let _e300: f32 = a33_;
    let _e302: f32 = a23_;
    let _e303: f32 = a32_;
    b11_1 = ((_e299 * _e300) - (_e302 * _e303));
    let _e307: f32 = b00_;
    let _e308: f32 = b11_1;
    let _e310: f32 = b01_1;
    let _e311: f32 = b10_;
    let _e314: f32 = b02_;
    let _e315: f32 = b09_;
    let _e318: f32 = b03_;
    let _e319: f32 = b08_;
    let _e322: f32 = b04_;
    let _e323: f32 = b07_;
    let _e326: f32 = b05_;
    let _e327: f32 = b06_;
    det_1 = ((((((_e307 * _e308) - (_e310 * _e311)) + (_e314 * _e315)) + (_e318 * _e319)) - (_e322 * _e323)) + (_e326 * _e327));
    let _e331: f32 = a11_1;
    let _e332: f32 = b11_1;
    let _e334: f32 = a12_1;
    let _e335: f32 = b10_;
    let _e338: f32 = a13_;
    let _e339: f32 = b09_;
    let _e342: f32 = a02_1;
    let _e343: f32 = b10_;
    let _e345: f32 = a01_1;
    let _e346: f32 = b11_1;
    let _e349: f32 = a03_;
    let _e350: f32 = b09_;
    let _e353: f32 = a31_;
    let _e354: f32 = b05_;
    let _e356: f32 = a32_;
    let _e357: f32 = b04_;
    let _e360: f32 = a33_;
    let _e361: f32 = b03_;
    let _e364: f32 = a22_1;
    let _e365: f32 = b04_;
    let _e367: f32 = a21_1;
    let _e368: f32 = b05_;
    let _e371: f32 = a23_;
    let _e372: f32 = b03_;
    let _e375: f32 = a12_1;
    let _e376: f32 = b08_;
    let _e378: f32 = a10_1;
    let _e379: f32 = b11_1;
    let _e382: f32 = a13_;
    let _e383: f32 = b07_;
    let _e386: f32 = a00_1;
    let _e387: f32 = b11_1;
    let _e389: f32 = a02_1;
    let _e390: f32 = b08_;
    let _e393: f32 = a03_;
    let _e394: f32 = b07_;
    let _e397: f32 = a32_;
    let _e398: f32 = b02_;
    let _e400: f32 = a30_;
    let _e401: f32 = b05_;
    let _e404: f32 = a33_;
    let _e405: f32 = b01_1;
    let _e408: f32 = a20_1;
    let _e409: f32 = b05_;
    let _e411: f32 = a22_1;
    let _e412: f32 = b02_;
    let _e415: f32 = a23_;
    let _e416: f32 = b01_1;
    let _e419: f32 = a10_1;
    let _e420: f32 = b10_;
    let _e422: f32 = a11_1;
    let _e423: f32 = b08_;
    let _e426: f32 = a13_;
    let _e427: f32 = b06_;
    let _e430: f32 = a01_1;
    let _e431: f32 = b08_;
    let _e433: f32 = a00_1;
    let _e434: f32 = b10_;
    let _e437: f32 = a03_;
    let _e438: f32 = b06_;
    let _e441: f32 = a30_;
    let _e442: f32 = b04_;
    let _e444: f32 = a31_;
    let _e445: f32 = b02_;
    let _e448: f32 = a33_;
    let _e449: f32 = b00_;
    let _e452: f32 = a21_1;
    let _e453: f32 = b02_;
    let _e455: f32 = a20_1;
    let _e456: f32 = b04_;
    let _e459: f32 = a23_;
    let _e460: f32 = b00_;
    let _e463: f32 = a11_1;
    let _e464: f32 = b07_;
    let _e466: f32 = a10_1;
    let _e467: f32 = b09_;
    let _e470: f32 = a12_1;
    let _e471: f32 = b06_;
    let _e474: f32 = a00_1;
    let _e475: f32 = b09_;
    let _e477: f32 = a01_1;
    let _e478: f32 = b07_;
    let _e481: f32 = a02_1;
    let _e482: f32 = b06_;
    let _e485: f32 = a31_;
    let _e486: f32 = b01_1;
    let _e488: f32 = a30_;
    let _e489: f32 = b03_;
    let _e492: f32 = a32_;
    let _e493: f32 = b00_;
    let _e496: f32 = a20_1;
    let _e497: f32 = b03_;
    let _e499: f32 = a21_1;
    let _e500: f32 = b01_1;
    let _e503: f32 = a22_1;
    let _e504: f32 = b00_;
    let _e511: mat4x4<f32> = mat4x4<f32>(vec4<f32>((((_e331 * _e332) - (_e334 * _e335)) + (_e338 * _e339)), (((_e342 * _e343) - (_e345 * _e346)) - (_e349 * _e350)), (((_e353 * _e354) - (_e356 * _e357)) + (_e360 * _e361)), (((_e364 * _e365) - (_e367 * _e368)) - (_e371 * _e372))), vec4<f32>((((_e375 * _e376) - (_e378 * _e379)) - (_e382 * _e383)), (((_e386 * _e387) - (_e389 * _e390)) + (_e393 * _e394)), (((_e397 * _e398) - (_e400 * _e401)) - (_e404 * _e405)), (((_e408 * _e409) - (_e411 * _e412)) + (_e415 * _e416))), vec4<f32>((((_e419 * _e420) - (_e422 * _e423)) + (_e426 * _e427)), (((_e430 * _e431) - (_e433 * _e434)) - (_e437 * _e438)), (((_e441 * _e442) - (_e444 * _e445)) + (_e448 * _e449)), (((_e452 * _e453) - (_e455 * _e456)) - (_e459 * _e460))), vec4<f32>((((_e463 * _e464) - (_e466 * _e467)) - (_e470 * _e471)), (((_e474 * _e475) - (_e477 * _e478)) + (_e481 * _e482)), (((_e485 * _e486) - (_e488 * _e489)) - (_e492 * _e493)), (((_e496 * _e497) - (_e499 * _e500)) + (_e503 * _e504))));
    let _e512: f32 = det_1;
    let _e513: vec4<f32> = vec4(_e512);
    return mat4x4<f32>((_e511[0] / _e513), (_e511[1] / _e513), (_e511[2] / _e513), (_e511[3] / _e513));
}

fn getAARoughnessFactor(normal: vec3<f32>) -> f32 {
    var normal_1: vec3<f32>;
    var dxy: vec3<f32>;

    normal_1 = normal;
    let _e119: vec3<f32> = normal_1;
    let _e120: vec3<f32> = dpdx(_e119);
    let _e122: vec3<f32> = normal_1;
    let _e123: vec3<f32> = dpdy(_e122);
    dxy = max(abs(_e120), abs(-(_e123)));
    let _e128: vec3<f32> = dxy;
    let _e130: vec3<f32> = dxy;
    let _e133: vec3<f32> = dxy;
    return max(max(_e128.x, _e130.y), _e133.z);
}

fn F_Schlick(f0_: f32, f90_: f32, dotLH: f32) -> f32 {
    var f0_1: f32;
    var f90_1: f32;
    var dotLH_1: f32;

    f0_1 = f0_;
    f90_1 = f90_;
    dotLH_1 = dotLH;
    let _e123: f32 = f0_1;
    let _e124: f32 = f90_1;
    let _e125: f32 = f0_1;
    let _e128: f32 = dotLH_1;
    return (_e123 + ((_e124 - _e125) * pow((1f - _e128), 5f)));
}

fn F_Schlick_1(f0_2: vec3<f32>, f90_2: f32, dotLH_2: f32) -> vec3<f32> {
    var f0_3: vec3<f32>;
    var f90_3: f32;
    var dotLH_3: f32;
    var fresnel: f32;

    f0_3 = f0_2;
    f90_3 = f90_2;
    dotLH_3 = dotLH_2;
    let _e125: f32 = dotLH_3;
    let _e129: f32 = dotLH_3;
    fresnel = exp2((((-5.55473f * _e125) - 6.98316f) * _e129));
    let _e133: f32 = f90_3;
    let _e134: vec3<f32> = f0_3;
    let _e137: f32 = fresnel;
    let _e139: vec3<f32> = f0_3;
    return (((vec3(_e133) - _e134) * _e137) + _e139);
}

fn G_GGX_SmithCorrelated(alpha: f32, dotNL: f32, dotNV: f32) -> f32 {
    var alpha_1: f32;
    var dotNL_1: f32;
    var dotNV_1: f32;
    var a2_: f32;
    var gv: f32;
    var gl: f32;

    alpha_1 = alpha;
    dotNL_1 = dotNL;
    dotNV_1 = dotNV;
    let _e123: f32 = alpha_1;
    let _e124: f32 = pow2_(_e123);
    a2_ = _e124;
    let _e126: f32 = dotNL_1;
    let _e127: f32 = a2_;
    let _e129: f32 = a2_;
    let _e131: f32 = dotNV_1;
    let _e132: f32 = pow2_(_e131);
    gv = (_e126 * sqrt((_e127 + ((1f - _e129) * _e132))));
    let _e138: f32 = dotNV_1;
    let _e139: f32 = a2_;
    let _e141: f32 = a2_;
    let _e143: f32 = dotNL_1;
    let _e144: f32 = pow2_(_e143);
    gl = (_e138 * sqrt((_e139 + ((1f - _e141) * _e144))));
    let _e151: f32 = gv;
    let _e152: f32 = gl;
    return (0.5f / max((_e151 + _e152), 0.000001f));
}

fn D_GGX(alpha_2: f32, dotNH: f32) -> f32 {
    var alpha_3: f32;
    var dotNH_1: f32;
    var a2_1: f32;
    var denom: f32;

    alpha_3 = alpha_2;
    dotNH_1 = dotNH;
    let _e121: f32 = alpha_3;
    let _e122: f32 = pow2_(_e121);
    a2_1 = _e122;
    let _e124: f32 = dotNH_1;
    let _e125: f32 = pow2_(_e124);
    let _e126: f32 = a2_1;
    denom = ((_e125 * (_e126 - 1f)) + 1f);
    let _e134: f32 = a2_1;
    let _e136: f32 = denom;
    let _e137: f32 = pow2_(_e136);
    return ((0.31830987f * _e134) / _e137);
}

fn DG_GGX(alpha_4: f32, dotNV_2: f32, dotNL_2: f32, dotNH_2: f32) -> f32 {
    var alpha_5: f32;
    var dotNV_3: f32;
    var dotNL_3: f32;
    var dotNH_3: f32;
    var D: f32;
    var G: f32;

    alpha_5 = alpha_4;
    dotNV_3 = dotNV_2;
    dotNL_3 = dotNL_2;
    dotNH_3 = dotNH_2;
    let _e125: f32 = alpha_5;
    let _e126: f32 = dotNH_3;
    let _e127: f32 = D_GGX(_e125, _e126);
    D = _e127;
    let _e129: f32 = alpha_5;
    let _e130: f32 = dotNL_3;
    let _e131: f32 = dotNV_3;
    let _e132: f32 = G_GGX_SmithCorrelated(_e129, _e130, _e131);
    G = _e132;
    let _e134: f32 = G;
    let _e135: f32 = D;
    return (_e134 * _e135);
}

fn BRDF_Specular_GGX(incidentDirection: vec3<f32>, surfaceData: SurfaceData, bsdfData: BSDFData, normal_2: vec3<f32>, specularColor: vec3<f32>, roughness: f32) -> vec3<f32> {
    var incidentDirection_1: vec3<f32>;
    var surfaceData_1: SurfaceData;
    var bsdfData_1: BSDFData;
    var normal_3: vec3<f32>;
    var specularColor_1: vec3<f32>;
    var roughness_1: f32;
    var alpha_6: f32;
    var halfDir: vec3<f32>;
    var dotNL_4: f32;
    var dotNV_4: f32;
    var dotNH_4: f32;
    var dotLH_4: f32;
    var F: vec3<f32>;
    var GD: f32;

    incidentDirection_1 = incidentDirection;
    surfaceData_1 = surfaceData;
    bsdfData_1 = bsdfData;
    normal_3 = normal_2;
    specularColor_1 = specularColor;
    roughness_1 = roughness;
    let _e129: f32 = roughness_1;
    let _e130: f32 = pow2_(_e129);
    alpha_6 = _e130;
    let _e132: vec3<f32> = incidentDirection_1;
    let _e133: SurfaceData = surfaceData_1;
    halfDir = normalize((_e132 + _e133.viewDir));
    let _e138: vec3<f32> = normal_3;
    let _e139: vec3<f32> = incidentDirection_1;
    dotNL_4 = clamp(dot(_e138, _e139), 0f, 1f);
    let _e145: vec3<f32> = normal_3;
    let _e146: SurfaceData = surfaceData_1;
    dotNV_4 = clamp(dot(_e145, _e146.viewDir), 0f, 1f);
    let _e153: vec3<f32> = normal_3;
    let _e154: vec3<f32> = halfDir;
    dotNH_4 = clamp(dot(_e153, _e154), 0f, 1f);
    let _e160: vec3<f32> = incidentDirection_1;
    let _e161: vec3<f32> = halfDir;
    dotLH_4 = clamp(dot(_e160, _e161), 0f, 1f);
    let _e167: vec3<f32> = specularColor_1;
    let _e168: BSDFData = bsdfData_1;
    let _e170: f32 = dotLH_4;
    let _e171: vec3<f32> = F_Schlick_1(_e167, _e168.specularF90_, _e170);
    F = _e171;
    let _e173: f32 = alpha_6;
    let _e174: f32 = dotNV_4;
    let _e175: f32 = dotNL_4;
    let _e176: f32 = dotNH_4;
    let _e177: f32 = DG_GGX(_e173, _e174, _e175, _e176);
    GD = _e177;
    let _e179: vec3<f32> = F;
    let _e180: f32 = GD;
    return (_e179 * _e180);
}

fn BRDF_Diffuse_Lambert(diffuseColor: vec3<f32>) -> vec3<f32> {
    var diffuseColor_1: vec3<f32>;

    diffuseColor_1 = diffuseColor;
    let _e120: vec3<f32> = diffuseColor_1;
    return (0.31830987f * _e120);
}

fn envDFGApprox(roughness_2: f32, dotNV_5: f32) -> vec2<f32> {
    var roughness_3: f32;
    var dotNV_6: f32;
    var c0_: vec4<f32> = vec4<f32>(-1f, -0.0275f, -0.572f, 0.022f);
    var c1_: vec4<f32> = vec4<f32>(1f, 0.0425f, 1.04f, -0.04f);
    var r: vec4<f32>;
    var a004_: f32;

    roughness_3 = roughness_2;
    dotNV_6 = dotNV_5;
    let _e139: f32 = roughness_3;
    let _e140: vec4<f32> = c0_;
    let _e142: vec4<f32> = c1_;
    r = ((_e139 * _e140) + _e142);
    let _e145: vec4<f32> = r;
    let _e147: vec4<f32> = r;
    let _e152: f32 = dotNV_6;
    let _e156: vec4<f32> = r;
    let _e159: vec4<f32> = r;
    a004_ = ((min((_e145.x * _e147.x), exp2((-9.28f * _e152))) * _e156.x) + _e159.y);
    let _e167: f32 = a004_;
    let _e169: vec4<f32> = r;
    return ((vec2<f32>(-1.04f, 1.04f) * _e167) + _e169.zw);
}

fn envBRDFApprox(f0_4: vec3<f32>, f90_4: f32, roughness_4: f32, dotNV_7: f32) -> vec3<f32> {
    var f0_5: vec3<f32>;
    var f90_5: f32;
    var roughness_5: f32;
    var dotNV_8: f32;
    var AB: vec2<f32>;

    f0_5 = f0_4;
    f90_5 = f90_4;
    roughness_5 = roughness_4;
    dotNV_8 = dotNV_7;
    let _e125: f32 = roughness_5;
    let _e126: f32 = dotNV_8;
    let _e127: vec2<f32> = envDFGApprox(_e125, _e126);
    AB = _e127;
    let _e129: vec3<f32> = f0_5;
    let _e130: vec2<f32> = AB;
    let _e133: f32 = f90_5;
    let _e134: vec2<f32> = AB;
    return ((_e129 * _e130.x) + vec3((_e133 * _e134.y)));
}

fn initBSDFData(surfaceData_2: SurfaceData, bsdfData_2: ptr<function, BSDFData>) {
    var surfaceData_3: SurfaceData;
    var albedoColor: vec3<f32>;
    var metallic: f32;
    var roughness_6: f32;
    var dielectricBaseF0_: vec3<f32>;
    var dielectricF0_: vec3<f32>;
    var dielectricF90_: f32;
    var dfg: vec2<f32>;

    surfaceData_3 = surfaceData_2;
    let _e120: SurfaceData = surfaceData_3;
    albedoColor = _e120.albedoColor;
    let _e123: SurfaceData = surfaceData_3;
    metallic = _e123.metallic;
    let _e126: SurfaceData = surfaceData_3;
    roughness_6 = _e126.roughness;
    let _e129: SurfaceData = surfaceData_3;
    let _e133: SurfaceData = surfaceData_3;
    let _e138: f32 = pow2_(((_e129.IOR - 1f) / (_e133.IOR + 1f)));
    dielectricBaseF0_ = vec3(_e138);
    let _e141: vec3<f32> = dielectricBaseF0_;
    let _e142: SurfaceData = surfaceData_3;
    let _e148: SurfaceData = surfaceData_3;
    dielectricF0_ = (min((_e141 * _e142.specularColor), vec3(1f)) * _e148.specularIntensity);
    let _e152: SurfaceData = surfaceData_3;
    dielectricF90_ = _e152.specularIntensity;
    let _e156: vec3<f32> = dielectricF0_;
    let _e157: vec3<f32> = albedoColor;
    let _e158: f32 = metallic;
    (*bsdfData_2).specularF0_ = mix(_e156, _e157, vec3(_e158));
    let _e162: f32 = dielectricF90_;
    let _e164: f32 = metallic;
    (*bsdfData_2).specularF90_ = mix(_e162, 1f, _e164);
    let _e167: vec3<f32> = albedoColor;
    let _e169: f32 = metallic;
    let _e173: vec3<f32> = dielectricF0_;
    let _e175: vec3<f32> = dielectricF0_;
    let _e178: vec3<f32> = dielectricF0_;
    (*bsdfData_2).diffuseColor = ((_e167 * (1f - _e169)) * (1f - max(max(_e173.x, _e175.y), _e178.z)));
    let _e185: f32 = roughness_6;
    let _e186: SurfaceData = surfaceData_3;
    let _e188: f32 = getAARoughnessFactor(_e186.normal);
    (*bsdfData_2).roughness = max(0.045f, min((_e185 + _e188), 1f));
    let _e194: BSDFData = (*bsdfData_2);
    (*bsdfData_2).resolvedSpecularF0_ = _e194.specularF0_;
    let _e196: BSDFData = (*bsdfData_2);
    let _e198: SurfaceData = surfaceData_3;
    let _e200: vec2<f32> = envDFGApprox(_e196.roughness, _e198.dotNV);
    dfg = _e200;
    let _e203: BSDFData = (*bsdfData_2);
    let _e205: vec2<f32> = dfg;
    let _e208: BSDFData = (*bsdfData_2);
    let _e210: vec2<f32> = dfg;
    (*bsdfData_2).envSpecularDFG = ((_e203.resolvedSpecularF0_ * _e205.x) + vec3((_e208.specularF90_ * _e210.y)));
    let _e217: BSDFData = (*bsdfData_2);
    let _e220: vec2<f32> = dfg;
    let _e222: vec2<f32> = dfg;
    (*bsdfData_2).energyCompensation = (vec3(1f) + (_e217.resolvedSpecularF0_ * ((1f / max((_e220.x + _e222.y), 0.000001f)) - 1f)));
    let _e234: SurfaceData = surfaceData_3;
    (*bsdfData_2).diffuseAO = _e234.ambientOcclusion;
    return;
}

fn getTBNByDerivatives(uv_3: vec2<f32>, normal_4: vec3<f32>, position: vec3<f32>, isFrontFacing: bool) -> mat3x3<f32> {
    var uv_4: vec2<f32>;
    var normal_5: vec3<f32>;
    var position_1: vec3<f32>;
    var isFrontFacing_1: bool;
    var local_1: vec2<f32>;
    var dp1_: vec3<f32>;
    var dp2_: vec3<f32>;
    var duv1_: vec2<f32>;
    var duv2_: vec2<f32>;
    var dp2perp: vec3<f32>;
    var dp1perp: vec3<f32>;
    var tangent: vec3<f32>;
    var bitangent: vec3<f32>;
    var denom_1: f32;
    var local_2: f32;
    var invmax: f32;

    uv_4 = uv_3;
    normal_5 = normal_4;
    position_1 = position;
    isFrontFacing_1 = isFrontFacing;
    let _e125: bool = isFrontFacing_1;
    if _e125 {
        let _e126: vec2<f32> = uv_4;
        local_1 = _e126;
    } else {
        let _e127: vec2<f32> = uv_4;
        local_1 = -(_e127);
    }
    let _e130: vec2<f32> = local_1;
    uv_4 = _e130;
    let _e131: vec3<f32> = position_1;
    let _e132: vec3<f32> = dpdx(_e131);
    dp1_ = _e132;
    let _e134: vec3<f32> = position_1;
    let _e135: vec3<f32> = dpdy(_e134);
    dp2_ = -(_e135);
    let _e138: vec2<f32> = uv_4;
    let _e139: vec2<f32> = dpdx(_e138);
    duv1_ = _e139;
    let _e141: vec2<f32> = uv_4;
    let _e142: vec2<f32> = dpdy(_e141);
    duv2_ = -(_e142);
    let _e145: vec3<f32> = dp2_;
    let _e146: vec3<f32> = normal_5;
    dp2perp = cross(_e145, _e146);
    let _e149: vec3<f32> = normal_5;
    let _e150: vec3<f32> = dp1_;
    dp1perp = cross(_e149, _e150);
    let _e153: vec3<f32> = dp2perp;
    let _e154: vec2<f32> = duv1_;
    let _e157: vec3<f32> = dp1perp;
    let _e158: vec2<f32> = duv2_;
    tangent = ((_e153 * _e154.x) + (_e157 * _e158.x));
    let _e163: vec3<f32> = dp2perp;
    let _e164: vec2<f32> = duv1_;
    let _e167: vec3<f32> = dp1perp;
    let _e168: vec2<f32> = duv2_;
    bitangent = ((_e163 * _e164.y) + (_e167 * _e168.y));
    let _e173: vec3<f32> = tangent;
    let _e174: vec3<f32> = tangent;
    let _e176: vec3<f32> = bitangent;
    let _e177: vec3<f32> = bitangent;
    denom_1 = max(dot(_e173, _e174), dot(_e176, _e177));
    let _e181: f32 = denom_1;
    if (_e181 == 0f) {
        local_2 = 0f;
    } else {
        let _e185: vec4<f32> = global.camera_ProjectionParams;
        let _e187: f32 = denom_1;
        local_2 = (_e185.x / sqrt(_e187));
    }
    let _e191: f32 = local_2;
    invmax = _e191;
    let _e193: vec3<f32> = tangent;
    let _e194: f32 = invmax;
    let _e195: vec3<f32> = (_e193 * _e194);
    let _e196: vec3<f32> = bitangent;
    let _e197: f32 = invmax;
    let _e198: vec3<f32> = (_e196 * _e197);
    let _e199: vec3<f32> = normal_5;
    return mat3x3<f32>(vec3<f32>(_e195.x, _e195.y, _e195.z), vec3<f32>(_e198.x, _e198.y, _e198.z), vec3<f32>(_e199.x, _e199.y, _e199.z));
}

fn sampleBillboardBaseTexture(materialUv: vec2<f32>) -> vec4<f32> {
    var materialUv_1: vec2<f32>;
    var baseTexture: vec4<f32> = vec4(1f);

    materialUv_1 = materialUv;
    let _e122: vec4<f32> = baseTexture;
    return _e122;
}

fn applyBillboardAlphaCutoff(alpha_7: f32) {
    var alpha_8: f32;

    alpha_8 = alpha_7;
    let _e119: f32 = alpha_8;
    let _e120: f32 = global_1.material_AlphaCutoff;
    if (_e119 < _e120) {
        {
            discard;
        }
    } else {
        return;
    }
}

fn terrainProjectApplySeasonColor(sourceColor: vec3<f32>, seasonColor: vec4<f32>) -> vec3<f32> {
    var sourceColor_1: vec3<f32>;
    var seasonColor_1: vec4<f32>;
    var sourceLuminance: f32;
    var seasonTone: vec3<f32>;

    sourceColor_1 = sourceColor;
    seasonColor_1 = seasonColor;
    let _e121: vec3<f32> = sourceColor_1;
    sourceLuminance = dot(_e121, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e128: vec4<f32> = seasonColor_1;
    let _e130: f32 = sourceLuminance;
    seasonTone = (_e128.xyz * _e130);
    let _e133: vec3<f32> = sourceColor_1;
    let _e134: vec3<f32> = seasonTone;
    let _e135: vec4<f32> = seasonColor_1;
    return mix(_e133, _e134, vec3(clamp(_e135.w, 0f, 1f)));
}

fn terrainProjectSurfaceClimateHash(cell: vec2<f32>) -> f32 {
    var cell_1: vec2<f32>;

    cell_1 = cell;
    let _e119: vec2<f32> = cell_1;
    return fract((sin(dot(_e119, vec2<f32>(127.1f, 311.7f))) * 43758.547f));
}

fn terrainProjectSurfaceClimateValueNoise(position_2: vec2<f32>) -> f32 {
    var position_3: vec2<f32>;
    var cell_2: vec2<f32>;
    var local_3: vec2<f32>;
    var blend: vec2<f32>;
    var lower: f32;
    var upper: f32;

    position_3 = position_2;
    let _e119: vec2<f32> = position_3;
    cell_2 = floor(_e119);
    let _e122: vec2<f32> = position_3;
    local_3 = fract(_e122);
    let _e125: vec2<f32> = local_3;
    let _e126: vec2<f32> = local_3;
    let _e130: vec2<f32> = local_3;
    blend = ((_e125 * _e126) * (vec2(3f) - (2f * _e130)));
    let _e136: vec2<f32> = cell_2;
    let _e137: f32 = terrainProjectSurfaceClimateHash(_e136);
    let _e138: vec2<f32> = cell_2;
    let _e143: f32 = terrainProjectSurfaceClimateHash((_e138 + vec2<f32>(1f, 0f)));
    let _e144: vec2<f32> = blend;
    lower = mix(_e137, _e143, _e144.x);
    let _e148: vec2<f32> = cell_2;
    let _e153: f32 = terrainProjectSurfaceClimateHash((_e148 + vec2<f32>(0f, 1f)));
    let _e154: vec2<f32> = cell_2;
    let _e159: f32 = terrainProjectSurfaceClimateHash((_e154 + vec2<f32>(1f, 1f)));
    let _e160: vec2<f32> = blend;
    upper = mix(_e153, _e159, _e160.x);
    let _e164: f32 = lower;
    let _e165: f32 = upper;
    let _e166: vec2<f32> = blend;
    return mix(_e164, _e165, _e166.y);
}

fn terrainProjectSurfaceClimateNoise(worldXZ: vec2<f32>) -> f32 {
    var worldXZ_1: vec2<f32>;
    var broad: f32;
    var detail: f32;

    worldXZ_1 = worldXZ;
    let _e119: vec2<f32> = worldXZ_1;
    let _e122: f32 = terrainProjectSurfaceClimateValueNoise((_e119 * 0.055f));
    broad = _e122;
    let _e124: vec2<f32> = worldXZ_1;
    let _e131: f32 = terrainProjectSurfaceClimateValueNoise(((_e124 * 0.17f) + vec2<f32>(19.7f, 43.1f)));
    detail = _e131;
    let _e133: f32 = broad;
    let _e134: f32 = detail;
    return mix(_e133, _e134, 0.28f);
}

fn terrainProjectSurfaceWetness(response: f32) -> f32 {
    var response_1: f32;

    response_1 = response;
    let _e119: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e121: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e126: f32 = response_1;
    return clamp((max(_e119.x, (_e121.w * 0.48f)) * _e126), 0f, 1f);
}

fn terrainProjectApplySurfaceMoisture(surfaceData_4: ptr<function, SurfaceData>, geometryNormal: vec3<f32>, response_2: vec2<f32>) {
    var geometryNormal_1: vec3<f32>;
    var response_3: vec2<f32>;
    var wetness: f32;
    var porousResponse: f32;
    var wetSubstrate: f32;
    var substrateLuminance: f32;
    var saturatedSubstrate: vec3<f32>;
    var wetAlbedo: vec3<f32>;
    var wetRoughness: f32;

    geometryNormal_1 = geometryNormal;
    response_3 = response_2;
    let _e122: vec2<f32> = response_3;
    let _e124: f32 = terrainProjectSurfaceWetness(_e122.x);
    wetness = _e124;
    let _e127: SurfaceData = (*surfaceData_4);
    let _e134: SurfaceData = (*surfaceData_4);
    porousResponse = ((1f - _e127.metallic) * mix(0.35f, 1f, smoothstep(0.18f, 0.82f, _e134.roughness)));
    let _e140: f32 = wetness;
    let _e141: f32 = porousResponse;
    wetSubstrate = (_e140 * _e141);
    let _e144: SurfaceData = (*surfaceData_4);
    substrateLuminance = dot(_e144.albedoColor, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e152: f32 = substrateLuminance;
    let _e154: SurfaceData = (*surfaceData_4);
    saturatedSubstrate = mix(vec3(_e152), _e154.albedoColor, vec3(1.08f));
    let _e160: vec3<f32> = saturatedSubstrate;
    wetAlbedo = max((_e160 * 0.78f), vec3(0f));
    let _e168: SurfaceData = (*surfaceData_4);
    let _e170: vec3<f32> = wetAlbedo;
    let _e171: f32 = wetSubstrate;
    (*surfaceData_4).albedoColor = mix(_e168.albedoColor, _e170, vec3(_e171));
    let _e175: SurfaceData = (*surfaceData_4);
    wetRoughness = max(0.14f, (_e175.roughness * 0.62f));
    let _e182: SurfaceData = (*surfaceData_4);
    let _e184: f32 = wetRoughness;
    let _e185: f32 = wetSubstrate;
    (*surfaceData_4).roughness = mix(_e182.roughness, _e184, (_e185 * 0.72f));
    let _e190: SurfaceData = (*surfaceData_4);
    let _e192: SurfaceData = (*surfaceData_4);
    (*surfaceData_4).dotNV = clamp(dot(_e190.normal, _e192.viewDir), 0f, 1f);
    return;
}

fn terrainProjectTopSnowMask(worldPosition: vec3<f32>, geometryNormal_2: vec3<f32>, response_4: f32) -> f32 {
    var worldPosition_1: vec3<f32>;
    var geometryNormal_3: vec3<f32>;
    var response_5: f32;
    var snowStorage: f32;
    var distribution: f32;
    var snowDistribution: f32;
    var upward: f32;

    worldPosition_1 = worldPosition;
    geometryNormal_3 = geometryNormal_2;
    response_5 = response_4;
    let _e123: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e125: f32 = response_5;
    snowStorage = clamp((_e123.z * _e125), 0f, 1f);
    let _e131: vec3<f32> = worldPosition_1;
    let _e133: f32 = terrainProjectSurfaceClimateNoise(_e131.xz);
    distribution = _e133;
    let _e137: f32 = snowStorage;
    let _e138: f32 = distribution;
    snowDistribution = smoothstep(0.06f, 0.64f, (_e137 + ((_e138 - 0.5f) * 0.22f)));
    let _e146: vec3<f32> = geometryNormal_3;
    upward = clamp(normalize(_e146).y, 0f, 1f);
    let _e153: f32 = snowDistribution;
    let _e156: f32 = upward;
    let _e159: f32 = snowStorage;
    return ((_e153 * smoothstep(0.34f, 0.82f, _e156)) * _e159);
}

fn terrainProjectApplyTopSnowLayer(surfaceData_5: ptr<function, SurfaceData>, geometryNormal_4: vec3<f32>, snow: f32, targetRoughness: f32, normalFlattening: f32) {
    var geometryNormal_5: vec3<f32>;
    var snow_1: f32;
    var targetRoughness_1: f32;
    var normalFlattening_1: f32;

    geometryNormal_5 = geometryNormal_4;
    snow_1 = snow;
    targetRoughness_1 = targetRoughness;
    normalFlattening_1 = normalFlattening;
    let _e127: SurfaceData = (*surfaceData_5);
    let _e129: vec4<f32> = global_1.scene_SurfaceSnowColor;
    let _e131: f32 = snow_1;
    (*surfaceData_5).albedoColor = mix(_e127.albedoColor, _e129.xyz, vec3(_e131));
    let _e135: SurfaceData = (*surfaceData_5);
    let _e138: f32 = snow_1;
    (*surfaceData_5).metallic = mix(_e135.metallic, 0f, _e138);
    let _e141: SurfaceData = (*surfaceData_5);
    let _e143: f32 = targetRoughness_1;
    let _e144: f32 = snow_1;
    (*surfaceData_5).roughness = mix(_e141.roughness, _e143, _e144);
    let _e147: SurfaceData = (*surfaceData_5);
    let _e150: f32 = snow_1;
    (*surfaceData_5).specularIntensity = mix(_e147.specularIntensity, 0.68f, _e150);
    let _e153: SurfaceData = (*surfaceData_5);
    let _e155: vec3<f32> = geometryNormal_5;
    let _e157: f32 = snow_1;
    let _e158: f32 = normalFlattening_1;
    (*surfaceData_5).normal = normalize(mix(_e153.normal, normalize(_e155), vec3((_e157 * _e158))));
    return;
}

fn terrainProjectApplySurfaceClimate(surfaceData_6: ptr<function, SurfaceData>, geometryNormal_6: vec3<f32>, response_6: vec3<f32>) {
    var geometryNormal_7: vec3<f32>;
    var response_7: vec3<f32>;
    var snow_2: f32;

    geometryNormal_7 = geometryNormal_6;
    response_7 = response_6;
    let _e123: vec3<f32> = geometryNormal_7;
    let _e124: vec3<f32> = response_7;
    terrainProjectApplySurfaceMoisture(surfaceData_6, _e123, _e124.xy);
    let _e127: SurfaceData = (*surfaceData_6);
    let _e129: vec3<f32> = geometryNormal_7;
    let _e130: vec3<f32> = response_7;
    let _e132: f32 = terrainProjectTopSnowMask(_e127.position, _e129, _e130.z);
    snow_2 = _e132;
    let _e135: vec3<f32> = geometryNormal_7;
    let _e136: f32 = snow_2;
    terrainProjectApplyTopSnowLayer(surfaceData_6, _e135, _e136, 0.82f, 0.28f);
    let _e141: SurfaceData = (*surfaceData_6);
    let _e143: SurfaceData = (*surfaceData_6);
    (*surfaceData_6).dotNV = clamp(dot(_e141.normal, _e143.viewDir), 0f, 1f);
    return;
}

fn evaluateBillboardMaterial() -> SurfaceData {
    var surfaceData_7: SurfaceData;
    var materialUv_2: vec2<f32>;
    var baseTexture_1: vec4<f32>;
    var geometryNormal_8: vec3<f32>;
    var shadingNormal: vec3<f32>;
    var smoothness: f32;
    var albedoColor_1: vec3<f32>;
    var seasonalFoliageMask: f32;
    var barkSeasonColor: vec3<f32>;
    var leafSeasonColor: vec3<f32>;

    let _e118: vec2<f32> = uv_5;
    let _e119: f32 = global_1.material_Tiling;
    materialUv_2 = (_e118 * _e119);
    let _e122: vec2<f32> = materialUv_2;
    let _e123: vec4<f32> = sampleBillboardBaseTexture(_e122);
    baseTexture_1 = _e123;
    let _e125: vec4<f32> = baseTexture_1;
    applyBillboardAlphaCutoff(_e125.w);
    let _e127: vec3<f32> = normalWS_3;
    geometryNormal_8 = normalize(_e127);
    let _e130: vec3<f32> = geometryNormal_8;
    shadingNormal = _e130;
    let _e132: f32 = global_1.material_Smoothness;
    smoothness = _e132;
    let _e134: vec4<f32> = global_1.material_BaseColor;
    let _e136: vec4<f32> = baseTexture_1;
    albedoColor_1 = (_e134.xyz * _e136.xyz);
    let _e142: vec4<f32> = baseTexture_1;
    let _e144: vec4<f32> = baseTexture_1;
    let _e146: vec4<f32> = baseTexture_1;
    seasonalFoliageMask = smoothstep(0.04f, 0.16f, (_e142.y - max(_e144.x, _e146.z)));
    let _e152: vec3<f32> = albedoColor_1;
    let _e153: vec4<f32> = global.scene_TreeBarkSeasonColor;
    let _e154: vec3<f32> = terrainProjectApplySeasonColor(_e152, _e153);
    barkSeasonColor = _e154;
    let _e156: vec3<f32> = albedoColor_1;
    let _e157: vec4<f32> = global.scene_TreeLeafSeasonColor;
    let _e158: vec3<f32> = terrainProjectApplySeasonColor(_e156, _e157);
    leafSeasonColor = _e158;
    let _e161: vec3<f32> = barkSeasonColor;
    let _e162: vec3<f32> = leafSeasonColor;
    let _e163: f32 = seasonalFoliageMask;
    surfaceData_7.albedoColor = mix(_e161, _e162, vec3(_e163));
    surfaceData_7.emissiveColor = vec3(0f);
    surfaceData_7.metallic = 0f;
    let _e173: f32 = smoothness;
    surfaceData_7.roughness = (1f - clamp(_e173, 0f, 1f));
    surfaceData_7.ambientOcclusion = 1f;
    surfaceData_7.opacity = 1f;
    surfaceData_7.IOR = 1.5f;
    let _e185: vec3<f32> = positionWS_3;
    surfaceData_7.position = _e185;
    let _e187: vec4<f32> = positionCS_1;
    surfaceData_7.positionCS = _e187;
    let _e189: vec3<f32> = shadingNormal;
    surfaceData_7.normal = _e189;
    let _e191: vec3<f32> = global.camera_Position;
    let _e192: vec3<f32> = positionWS_3;
    surfaceData_7.viewDir = normalize((_e191 - _e192));
    let _e196: SurfaceData = surfaceData_7;
    let _e198: SurfaceData = surfaceData_7;
    surfaceData_7.dotNV = clamp(dot(_e196.normal, _e198.viewDir), 0f, 1f);
    surfaceData_7.specularIntensity = 1f;
    surfaceData_7.specularColor = vec3(1f);
    let _e210: vec3<f32> = geometryNormal_8;
    terrainProjectApplySurfaceClimate((&surfaceData_7), _e210, vec3<f32>(0.52f, 0f, 0.38f));
    let _e216: SurfaceData = surfaceData_7;
    return _e216;
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn applyTerrainProjectInstanceLodDither(fragmentPosition: vec2<f32>, instanceLodFade: f32) {
    var fragmentPosition_1: vec2<f32>;
    var instanceLodFade_1: f32;

    fragmentPosition_1 = fragmentPosition;
    instanceLodFade_1 = instanceLodFade;
    return;
}

fn applyTerrainProjectLodDither(fragmentPosition_2: vec2<f32>) {
    var fragmentPosition_3: vec2<f32>;

    fragmentPosition_3 = fragmentPosition_2;
    return;
}

fn isBitSet(value_4: f32, mask: f32, bitIndex: f32) -> bool {
    var value_5: f32;
    var mask_1: f32;
    var bitIndex_1: f32;

    value_5 = value_4;
    mask_1 = mask;
    bitIndex_1 = bitIndex;
    let _e123: f32 = value_5;
    let _e125: f32 = bitIndex_1;
    let _e128: f32 = floor((_e123 / pow(2f, _e125)));
    let _e136: f32 = mask_1;
    let _e138: f32 = bitIndex_1;
    let _e141: f32 = floor((_e136 / pow(2f, _e138)));
    return (((_e128 - (floor((_e128 / 2f)) * 2f)) == 1f) && ((_e141 - (floor((_e141 / 2f)) * 2f)) == 1f));
}

fn isRendererCulledByLight(rendererLayer: vec2<i32>, lightCullingMask: vec2<i32>) -> bool {
    var rendererLayer_1: vec2<i32>;
    var lightCullingMask_1: vec2<i32>;
    var i: i32 = 0i;

    rendererLayer_1 = rendererLayer;
    lightCullingMask_1 = lightCullingMask;
    loop {
        let _e123: i32 = i;
        if !((_e123 < 16i)) {
            break;
        }
        {
            let _e130: vec2<i32> = rendererLayer_1;
            let _e133: vec2<i32> = lightCullingMask_1;
            let _e136: i32 = i;
            let _e138: bool = isBitSet(f32(_e130.x), f32(_e133.x), f32(_e136));
            let _e139: vec2<i32> = rendererLayer_1;
            let _e142: vec2<i32> = lightCullingMask_1;
            let _e145: i32 = i;
            let _e147: bool = isBitSet(f32(_e139.y), f32(_e142.y), f32(_e145));
            if (_e138 || _e147) {
                {
                    return false;
                }
            }
        }
        continuing {
            let _e127: i32 = i;
            i = (_e127 + 1i);
        }
    }
    return true;
}

fn diffuseLobe(surfaceData_8: SurfaceData, bsdfData_3: BSDFData, attenuationIrradiance: vec3<f32>, diffuseColor_2: ptr<function, vec3<f32>>) {
    var surfaceData_9: SurfaceData;
    var bsdfData_4: BSDFData;
    var attenuationIrradiance_1: vec3<f32>;

    surfaceData_9 = surfaceData_8;
    bsdfData_4 = bsdfData_3;
    attenuationIrradiance_1 = attenuationIrradiance;
    let _e128: vec3<f32> = (*diffuseColor_2);
    let _e129: vec3<f32> = attenuationIrradiance_1;
    let _e130: BSDFData = bsdfData_4;
    let _e132: vec3<f32> = BRDF_Diffuse_Lambert(_e130.diffuseColor);
    (*diffuseColor_2) = (_e128 + (_e129 * _e132));
    return;
}

fn specularLobe(surfaceData_10: SurfaceData, bsdfData_5: BSDFData, incidentDirection_2: vec3<f32>, attenuationIrradiance_2: vec3<f32>, specularColor_2: ptr<function, vec3<f32>>) {
    var surfaceData_11: SurfaceData;
    var bsdfData_6: BSDFData;
    var incidentDirection_3: vec3<f32>;
    var attenuationIrradiance_3: vec3<f32>;

    surfaceData_11 = surfaceData_10;
    bsdfData_6 = bsdfData_5;
    incidentDirection_3 = incidentDirection_2;
    attenuationIrradiance_3 = attenuationIrradiance_2;
    let _e130: vec3<f32> = (*specularColor_2);
    let _e131: vec3<f32> = attenuationIrradiance_3;
    let _e132: vec3<f32> = incidentDirection_3;
    let _e133: SurfaceData = surfaceData_11;
    let _e134: BSDFData = bsdfData_6;
    let _e135: SurfaceData = surfaceData_11;
    let _e137: BSDFData = bsdfData_6;
    let _e139: BSDFData = bsdfData_6;
    let _e141: vec3<f32> = BRDF_Specular_GGX(_e132, _e133, _e134, _e135.normal, _e137.specularF0_, _e139.roughness);
    let _e143: BSDFData = bsdfData_6;
    (*specularColor_2) = (_e130 + ((_e131 * _e141) * _e143.energyCompensation));
    return;
}

fn sheenLobe(surfaceData_12: SurfaceData, bsdfData_7: BSDFData, incidentDirection_4: vec3<f32>, attenuationIrradiance_4: vec3<f32>, diffuseColor_3: ptr<function, vec3<f32>>, specularColor_3: ptr<function, vec3<f32>>) {
    var surfaceData_13: SurfaceData;
    var bsdfData_8: BSDFData;
    var incidentDirection_5: vec3<f32>;
    var attenuationIrradiance_5: vec3<f32>;

    surfaceData_13 = surfaceData_12;
    bsdfData_8 = bsdfData_7;
    incidentDirection_5 = incidentDirection_4;
    attenuationIrradiance_5 = attenuationIrradiance_4;
    return;
}

fn clearCoatLobe(surfaceData_14: SurfaceData, bsdfData_9: BSDFData, incidentDirection_6: vec3<f32>, color_1: vec3<f32>, specularColor_4: ptr<function, vec3<f32>>) -> f32 {
    var surfaceData_15: SurfaceData;
    var bsdfData_10: BSDFData;
    var incidentDirection_7: vec3<f32>;
    var color_2: vec3<f32>;
    var attenuation: f32 = 1f;

    surfaceData_15 = surfaceData_14;
    bsdfData_10 = bsdfData_9;
    incidentDirection_7 = incidentDirection_6;
    color_2 = color_1;
    let _e132: f32 = attenuation;
    return _e132;
}

fn surfaceShading(surfaceData_16: SurfaceData, bsdfData_11: BSDFData, incidentDirection_8: vec3<f32>, lightColor: vec3<f32>, totalDiffuseColor: ptr<function, vec3<f32>>, totalSpecularColor: ptr<function, vec3<f32>>) {
    var surfaceData_17: SurfaceData;
    var bsdfData_12: BSDFData;
    var incidentDirection_9: vec3<f32>;
    var lightColor_1: vec3<f32>;
    var diffuseColor_4: vec3<f32> = vec3(0f);
    var specularColor_5: vec3<f32> = vec3(0f);
    var dotNL_5: f32;
    var irradiance: vec3<f32>;
    var attenuation_1: f32;
    var attenuationIrradiance_6: vec3<f32>;

    surfaceData_17 = surfaceData_16;
    bsdfData_12 = bsdfData_11;
    incidentDirection_9 = incidentDirection_8;
    lightColor_1 = lightColor;
    let _e139: SurfaceData = surfaceData_17;
    let _e141: vec3<f32> = incidentDirection_9;
    dotNL_5 = clamp(dot(_e139.normal, _e141), 0f, 1f);
    let _e147: f32 = dotNL_5;
    let _e148: vec3<f32> = lightColor_1;
    irradiance = ((_e147 * _e148) * 3.1415927f);
    let _e153: SurfaceData = surfaceData_17;
    let _e154: BSDFData = bsdfData_12;
    let _e155: vec3<f32> = incidentDirection_9;
    let _e156: vec3<f32> = lightColor_1;
    let _e159: f32 = clearCoatLobe(_e153, _e154, _e155, _e156, (&specularColor_5));
    attenuation_1 = _e159;
    let _e161: f32 = attenuation_1;
    let _e162: vec3<f32> = irradiance;
    attenuationIrradiance_6 = (_e161 * _e162);
    let _e165: SurfaceData = surfaceData_17;
    let _e166: BSDFData = bsdfData_12;
    let _e167: vec3<f32> = attenuationIrradiance_6;
    diffuseLobe(_e165, _e166, _e167, (&diffuseColor_4));
    let _e170: SurfaceData = surfaceData_17;
    let _e171: BSDFData = bsdfData_12;
    let _e172: vec3<f32> = incidentDirection_9;
    let _e173: vec3<f32> = attenuationIrradiance_6;
    specularLobe(_e170, _e171, _e172, _e173, (&specularColor_5));
    let _e176: SurfaceData = surfaceData_17;
    let _e177: BSDFData = bsdfData_12;
    let _e178: vec3<f32> = incidentDirection_9;
    let _e179: vec3<f32> = attenuationIrradiance_6;
    sheenLobe(_e176, _e177, _e178, _e179, (&diffuseColor_4), (&specularColor_5));
    let _e184: vec3<f32> = (*totalDiffuseColor);
    let _e185: vec3<f32> = diffuseColor_4;
    (*totalDiffuseColor) = (_e184 + _e185);
    let _e187: vec3<f32> = (*totalSpecularColor);
    let _e188: vec3<f32> = specularColor_5;
    (*totalSpecularColor) = (_e187 + _e188);
    return;
}

fn evaluateDirectRadiance(surfaceData_18: SurfaceData, bsdfData_13: BSDFData, shadowAttenuation: f32, totalDiffuseColor_1: ptr<function, vec3<f32>>, totalSpecularColor_1: ptr<function, vec3<f32>>) {
    var surfaceData_19: SurfaceData;
    var bsdfData_14: BSDFData;
    var shadowAttenuation_1: f32;

    surfaceData_19 = surfaceData_18;
    bsdfData_14 = bsdfData_13;
    shadowAttenuation_1 = shadowAttenuation;
    return;
}

fn getReflectedVector(surfaceData_20: SurfaceData, n: vec3<f32>) -> vec3<f32> {
    var surfaceData_21: SurfaceData;
    var n_1: vec3<f32>;
    var r_1: vec3<f32>;

    surfaceData_21 = surfaceData_20;
    n_1 = n;
    let _e125: SurfaceData = surfaceData_21;
    let _e128: vec3<f32> = n_1;
    r_1 = reflect(-(_e125.viewDir), _e128);
    let _e131: vec3<f32> = r_1;
    return _e131;
}

fn getSpecularMIPLevel(roughness_7: f32, maxMIPLevel: i32) -> f32 {
    var roughness_8: f32;
    var maxMIPLevel_1: i32;

    roughness_8 = roughness_7;
    maxMIPLevel_1 = maxMIPLevel;
    let _e125: f32 = roughness_8;
    let _e126: i32 = maxMIPLevel_1;
    return (_e125 * f32(_e126));
}

fn getLightProbeRadiance(surfaceData_22: SurfaceData, normal_6: vec3<f32>, roughness_9: f32) -> vec3<f32> {
    var surfaceData_23: SurfaceData;
    var normal_7: vec3<f32>;
    var roughness_10: f32;

    surfaceData_23 = surfaceData_22;
    normal_7 = normal_6;
    roughness_10 = roughness_9;
    return vec3(0f);
}

fn evaluateSpecularOcclusion(dotNV_9: f32, diffuseAO: f32, roughness_11: f32) -> f32 {
    var dotNV_10: f32;
    var diffuseAO_1: f32;
    var roughness_12: f32;
    var specularAOFactor: f32 = 1f;

    dotNV_10 = dotNV_9;
    diffuseAO_1 = diffuseAO;
    roughness_12 = roughness_11;
    let _e129: f32 = specularAOFactor;
    return _e129;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal_8: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_9: vec3<f32>;
    var result: vec3<f32>;

    sh_1 = sh;
    normal_9 = normal_8;
    let _e127: vec3<f32> = sh_1[0];
    let _e130: vec3<f32> = sh_1[1];
    let _e131: vec3<f32> = normal_9;
    let _e137: vec3<f32> = sh_1[2];
    let _e138: vec3<f32> = normal_9;
    let _e144: vec3<f32> = sh_1[3];
    let _e145: vec3<f32> = normal_9;
    let _e151: vec3<f32> = sh_1[4];
    let _e152: vec3<f32> = normal_9;
    let _e154: vec3<f32> = normal_9;
    let _e161: vec3<f32> = sh_1[5];
    let _e162: vec3<f32> = normal_9;
    let _e164: vec3<f32> = normal_9;
    let _e171: vec3<f32> = sh_1[6];
    let _e173: vec3<f32> = normal_9;
    let _e176: vec3<f32> = normal_9;
    let _e185: vec3<f32> = sh_1[7];
    let _e186: vec3<f32> = normal_9;
    let _e188: vec3<f32> = normal_9;
    let _e195: vec3<f32> = sh_1[8];
    let _e196: vec3<f32> = normal_9;
    let _e198: vec3<f32> = normal_9;
    let _e201: vec3<f32> = normal_9;
    let _e203: vec3<f32> = normal_9;
    result = ((((((((_e127 + (_e130 * _e131.y)) + (_e137 * _e138.z)) + (_e144 * _e145.x)) + (_e151 * (_e152.y * _e154.x))) + (_e161 * (_e162.y * _e164.z))) + (_e171 * (((3f * _e173.z) * _e176.z) - 1f))) + (_e185 * (_e186.z * _e188.x))) + (_e195 * ((_e196.x * _e198.x) - (_e201.y * _e203.y))));
    let _e210: vec3<f32> = result;
    return max(_e210, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS_1: vec3<f32>) -> vec3<f32> {
    var normalWS_2: vec3<f32>;

    normalWS_2 = normalWS_1;
    let _e123: EnvMapLight = scene_EnvMapLight;
    return (_e123.diffuse * 3.1415927f);
}

fn evaluateDiffuseIBL(surfaceData_24: SurfaceData, bsdfData_15: BSDFData, diffuseColor_5: ptr<function, vec3<f32>>) {
    var surfaceData_25: SurfaceData;
    var bsdfData_16: BSDFData;
    var irradiance_1: vec3<f32>;

    surfaceData_25 = surfaceData_24;
    bsdfData_16 = bsdfData_15;
    let _e126: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e126.diffuse * 3.1415927f);
    let _e131: vec3<f32> = irradiance_1;
    let _e132: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e131 * _e132.diffuseIntensity);
    let _e135: vec3<f32> = (*diffuseColor_5);
    let _e136: BSDFData = bsdfData_16;
    let _e138: vec3<f32> = irradiance_1;
    let _e140: BSDFData = bsdfData_16;
    let _e142: vec3<f32> = BRDF_Diffuse_Lambert(_e140.diffuseColor);
    (*diffuseColor_5) = (_e135 + ((_e136.diffuseAO * _e138) * _e142));
    return;
}

fn evaluateClearCoatIBL(surfaceData_26: SurfaceData, bsdfData_17: BSDFData, specularColor_6: ptr<function, vec3<f32>>) -> f32 {
    var surfaceData_27: SurfaceData;
    var bsdfData_18: BSDFData;
    var radianceAttenuation: f32 = 1f;

    surfaceData_27 = surfaceData_26;
    bsdfData_18 = bsdfData_17;
    let _e128: f32 = radianceAttenuation;
    return _e128;
}

fn evaluateSpecularIBL(surfaceData_28: SurfaceData, bsdfData_19: BSDFData, radianceAttenuation_1: f32, outSpecularColor: ptr<function, vec3<f32>>) {
    var surfaceData_29: SurfaceData;
    var bsdfData_20: BSDFData;
    var radianceAttenuation_2: f32;
    var radiance: vec3<f32>;
    var specularAO: f32;

    surfaceData_29 = surfaceData_28;
    bsdfData_20 = bsdfData_19;
    radianceAttenuation_2 = radianceAttenuation_1;
    let _e128: SurfaceData = surfaceData_29;
    let _e129: SurfaceData = surfaceData_29;
    let _e131: BSDFData = bsdfData_20;
    let _e133: vec3<f32> = getLightProbeRadiance(_e128, _e129.normal, _e131.roughness);
    radiance = _e133;
    let _e135: SurfaceData = surfaceData_29;
    let _e137: BSDFData = bsdfData_20;
    let _e139: BSDFData = bsdfData_20;
    let _e141: f32 = evaluateSpecularOcclusion(_e135.dotNV, _e137.diffuseAO, _e139.roughness);
    specularAO = _e141;
    let _e143: vec3<f32> = (*outSpecularColor);
    let _e144: f32 = specularAO;
    let _e145: f32 = radianceAttenuation_2;
    let _e147: vec3<f32> = radiance;
    let _e149: BSDFData = bsdfData_20;
    let _e151: BSDFData = bsdfData_20;
    let _e153: BSDFData = bsdfData_20;
    let _e155: SurfaceData = surfaceData_29;
    let _e157: vec3<f32> = envBRDFApprox(_e149.resolvedSpecularF0_, _e151.specularF90_, _e153.roughness, _e155.dotNV);
    let _e159: BSDFData = bsdfData_20;
    (*outSpecularColor) = (_e143 + ((((_e144 * _e145) * _e147) * _e157) * _e159.energyCompensation));
    return;
}

fn evaluateSheenIBL(surfaceData_30: SurfaceData, bsdfData_21: BSDFData, radianceAttenuation_3: f32, diffuseColor_6: ptr<function, vec3<f32>>, specularColor_7: ptr<function, vec3<f32>>) {
    var surfaceData_31: SurfaceData;
    var bsdfData_22: BSDFData;
    var radianceAttenuation_4: f32;

    surfaceData_31 = surfaceData_30;
    bsdfData_22 = bsdfData_21;
    radianceAttenuation_4 = radianceAttenuation_3;
    return;
}

fn evaluateIBL(surfaceData_32: SurfaceData, bsdfData_23: BSDFData, totalDiffuseColor_2: ptr<function, vec3<f32>>, totalSpecularColor_2: ptr<function, vec3<f32>>) {
    var surfaceData_33: SurfaceData;
    var bsdfData_24: BSDFData;
    var diffuseColor_7: vec3<f32> = vec3(0f);
    var specularColor_8: vec3<f32> = vec3(0f);
    var radianceAttenuation_5: f32;

    surfaceData_33 = surfaceData_32;
    bsdfData_24 = bsdfData_23;
    let _e135: SurfaceData = surfaceData_33;
    let _e136: BSDFData = bsdfData_24;
    evaluateDiffuseIBL(_e135, _e136, (&diffuseColor_7));
    let _e139: SurfaceData = surfaceData_33;
    let _e140: BSDFData = bsdfData_24;
    let _e143: f32 = evaluateClearCoatIBL(_e139, _e140, (&specularColor_8));
    radianceAttenuation_5 = _e143;
    let _e145: SurfaceData = surfaceData_33;
    let _e146: BSDFData = bsdfData_24;
    let _e147: f32 = radianceAttenuation_5;
    evaluateSpecularIBL(_e145, _e146, _e147, (&specularColor_8));
    let _e150: SurfaceData = surfaceData_33;
    let _e151: BSDFData = bsdfData_24;
    let _e152: f32 = radianceAttenuation_5;
    evaluateSheenIBL(_e150, _e151, _e152, (&diffuseColor_7), (&specularColor_8));
    let _e157: vec3<f32> = (*totalDiffuseColor_2);
    let _e158: vec3<f32> = diffuseColor_7;
    (*totalDiffuseColor_2) = (_e157 + _e158);
    let _e160: vec3<f32> = (*totalSpecularColor_2);
    let _e161: vec3<f32> = specularColor_8;
    (*totalSpecularColor_2) = (_e160 + _e161);
    return;
}

fn sampleVolumetricCloudShadow(positionWS_1: vec3<f32>) -> f32 {
    var positionWS_2: vec3<f32>;

    positionWS_2 = positionWS_1;
    return 1f;
}

fn sampleTerrainProjectShadow() -> f32 {
    var attenuation_2: f32 = 1f;

    let _e123: f32 = attenuation_2;
    let _e124: vec3<f32> = positionWS_3;
    let _e125: f32 = sampleVolumetricCloudShadow(_e124);
    return (_e123 * _e125);
}

fn evaluateTerrainProjectLightingWithShadow(surfaceData_34: SurfaceData, shadowAttenuation_2: f32) -> TerrainProjectLightingResult {
    var surfaceData_35: SurfaceData;
    var shadowAttenuation_3: f32;
    var result_1: TerrainProjectLightingResult;
    var bsdfData_25: BSDFData;
    var directShadowAttenuation: f32;

    surfaceData_35 = surfaceData_34;
    shadowAttenuation_3 = shadowAttenuation_2;
    result_1.directDiffuse = vec3(0f);
    result_1.directSpecular = vec3(0f);
    result_1.environmentDiffuse = vec3(0f);
    result_1.environmentSpecular = vec3(0f);
    let _e139: f32 = shadowAttenuation_3;
    result_1.shadowAttenuation = _e139;
    let _e141: SurfaceData = surfaceData_35;
    surfaceData_35.albedoColor = _e141.albedoColor;
    let _e144: SurfaceData = surfaceData_35;
    initBSDFData(_e144, (&bsdfData_25));
    let _e147: TerrainProjectLightingResult = result_1;
    directShadowAttenuation = _e147.shadowAttenuation;
    let _e150: SurfaceData = surfaceData_35;
    let _e151: BSDFData = bsdfData_25;
    let _e152: f32 = directShadowAttenuation;
    let _e153: TerrainProjectLightingResult = result_1;
    let _e155: TerrainProjectLightingResult = result_1;
    var gs_output_arg0 = result_1.directDiffuse;
    var gs_output_arg1 = result_1.directSpecular;
    evaluateDirectRadiance(_e150, _e151, _e152, (&gs_output_arg0), (&gs_output_arg1));
    result_1.directDiffuse = gs_output_arg0;
    result_1.directSpecular = gs_output_arg1;
    let _e161: SurfaceData = surfaceData_35;
    let _e162: BSDFData = bsdfData_25;
    let _e163: TerrainProjectLightingResult = result_1;
    let _e165: TerrainProjectLightingResult = result_1;
    var gs_output_arg2 = result_1.environmentDiffuse;
    var gs_output_arg3 = result_1.environmentSpecular;
    evaluateIBL(_e161, _e162, (&gs_output_arg2), (&gs_output_arg3));
    result_1.environmentDiffuse = gs_output_arg2;
    result_1.environmentSpecular = gs_output_arg3;
    let _e171: TerrainProjectLightingResult = result_1;
    return _e171;
}

fn evaluateTerrainProjectLighting(surfaceData_36: SurfaceData) -> TerrainProjectLightingResult {
    var surfaceData_37: SurfaceData;

    surfaceData_37 = surfaceData_36;
    let _e123: SurfaceData = surfaceData_37;
    let _e124: f32 = sampleTerrainProjectShadow();
    let _e125: TerrainProjectLightingResult = evaluateTerrainProjectLightingWithShadow(_e123, _e124);
    return _e125;
}

fn terrainProjectFinalLighting(result_2: TerrainProjectLightingResult) -> vec3<f32> {
    var result_3: TerrainProjectLightingResult;

    result_3 = result_2;
    let _e123: TerrainProjectLightingResult = result_3;
    let _e125: TerrainProjectLightingResult = result_3;
    let _e128: TerrainProjectLightingResult = result_3;
    let _e131: TerrainProjectLightingResult = result_3;
    return (((_e123.directDiffuse + _e125.directSpecular) + _e128.environmentDiffuse) + _e131.environmentSpecular);
}

fn gs_wgpu_main() {
    var surfaceData_38: SurfaceData;
    var lighting: TerrainProjectLightingResult;
    var color_3: vec4<f32>;

    let _e122: vec4<f32> = gl_FragCoord_1;
    applyTerrainProjectLodDither(_e122.xy);
    let _e124: SurfaceData = evaluateBillboardMaterial();
    surfaceData_38 = _e124;
    let _e126: SurfaceData = surfaceData_38;
    let _e127: TerrainProjectLightingResult = evaluateTerrainProjectLighting(_e126);
    lighting = _e127;
    let _e129: TerrainProjectLightingResult = lighting;
    let _e130: vec3<f32> = terrainProjectFinalLighting(_e129);
    color_3 = vec4<f32>(_e130.x, _e130.y, _e130.z, 1f);
    let _e137: vec4<f32> = color_3;
    output_color = _e137;
    return;
}

fn main_1() {
    let _e126: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e132: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e138: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e126.x), bitcast<f32>(_e132.y), bitcast<f32>(_e138.z));
    let _e146: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e146.w);
    let _e153: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e153.x);
    let _e160: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e160.y);
    let _e167: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e167.z);
    let _e174: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e174.w);
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) uv: vec2<f32>, @location(1) positionWS: vec3<f32>, @location(2) normalWS: vec3<f32>, @location(3) positionCS: vec4<f32>, @builtin(position) gl_FragCoord: vec4<f32>) -> FragmentOutput {
    uv_5 = uv;
    positionWS_3 = positionWS;
    normalWS_3 = normalWS;
    positionCS_1 = positionCS;
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    let _e138: vec4<f32> = output_color;
    return FragmentOutput(_e138);
}
