diagnostic(off, derivative_uniformity);
struct gs_Auto_1_ {
    material_AlphaCutoff: f32,
}

struct FragmentOutput {
    @location(0) output_color: vec4<f32>,
}

@group(2) @binding(1) 
var<uniform> global: gs_Auto_1_;
var<private> output_color: vec4<f32>;
var<private> uv_3: vec2<f32>;
var<private> sourcePositionWS_1: vec3<f32>;
var<private> gl_FragCoord_1: vec4<f32>;

fn sRGBToLinear(value: f32) -> f32 {
    var value_1: f32;
    var linearRGBLo: f32;
    var linearRGBHi: f32;
    var local: f32;
    var linearRGB: f32;

    value_1 = value;
    let _e5: f32 = value_1;
    linearRGBLo = (_e5 / 12.92f);
    let _e9: f32 = value_1;
    linearRGBHi = pow(((_e9 + 0.055f) / 1.055f), 2.4f);
    let _e17: f32 = value_1;
    if (_e17 <= 0.04045f) {
        let _e20: f32 = linearRGBLo;
        local = _e20;
    } else {
        let _e21: f32 = linearRGBHi;
        local = _e21;
    }
    let _e23: f32 = local;
    linearRGB = _e23;
    let _e25: f32 = linearRGB;
    return _e25;
}

fn sRGBToLinear_1(value_2: vec4<f32>) -> vec4<f32> {
    var value_3: vec4<f32>;

    value_3 = value_2;
    let _e5: vec4<f32> = value_3;
    let _e7: f32 = sRGBToLinear(_e5.x);
    let _e8: vec4<f32> = value_3;
    let _e10: f32 = sRGBToLinear(_e8.y);
    let _e11: vec4<f32> = value_3;
    let _e13: f32 = sRGBToLinear(_e11.z);
    let _e14: vec4<f32> = value_3;
    return vec4<f32>(_e7, _e10, _e13, _e14.w);
}

fn texture2DSRGB(gs_wgpu_tex_tex: texture_2d<f32>, gs_wgpu_samp_tex: sampler, uv_1: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;
    var color: vec4<f32>;

    uv_2 = uv_1;
    let _e7: vec2<f32> = uv_2;
    let _e8: vec4<f32> = textureSample(gs_wgpu_tex_tex, gs_wgpu_samp_tex, _e7);
    color = _e8;
    let _e10: vec4<f32> = color;
    return _e10;
}

fn inverseMat(m: mat2x2<f32>) -> mat2x2<f32> {
    var m_1: mat2x2<f32>;

    m_1 = m;
    let _e9: f32 = m_1[1][1];
    let _e14: f32 = m_1[0][1];
    let _e20: f32 = m_1[1][0];
    let _e26: f32 = m_1[0][0];
    let _e29: mat2x2<f32> = mat2x2<f32>(vec2<f32>(_e9, -(_e14)), vec2<f32>(-(_e20), _e26));
    let _e34: f32 = m_1[0][0];
    let _e39: f32 = m_1[1][1];
    let _e45: f32 = m_1[0][1];
    let _e50: f32 = m_1[1][0];
    let _e53: vec2<f32> = vec2(((_e34 * _e39) - (_e45 * _e50)));
    return mat2x2<f32>((_e29[0] / _e53), (_e29[1] / _e53));
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
    let _e9: f32 = m_3[0][0];
    a00_ = _e9;
    let _e15: f32 = m_3[0][1];
    a01_ = _e15;
    let _e21: f32 = m_3[0][2];
    a02_ = _e21;
    let _e27: f32 = m_3[1][0];
    a10_ = _e27;
    let _e33: f32 = m_3[1][1];
    a11_ = _e33;
    let _e39: f32 = m_3[1][2];
    a12_ = _e39;
    let _e45: f32 = m_3[2][0];
    a20_ = _e45;
    let _e51: f32 = m_3[2][1];
    a21_ = _e51;
    let _e57: f32 = m_3[2][2];
    a22_ = _e57;
    let _e59: f32 = a22_;
    let _e60: f32 = a11_;
    let _e62: f32 = a12_;
    let _e63: f32 = a21_;
    b01_ = ((_e59 * _e60) - (_e62 * _e63));
    let _e67: f32 = a22_;
    let _e69: f32 = a10_;
    let _e71: f32 = a12_;
    let _e72: f32 = a20_;
    b11_ = ((-(_e67) * _e69) + (_e71 * _e72));
    let _e76: f32 = a21_;
    let _e77: f32 = a10_;
    let _e79: f32 = a11_;
    let _e80: f32 = a20_;
    b21_ = ((_e76 * _e77) - (_e79 * _e80));
    let _e84: f32 = a00_;
    let _e85: f32 = b01_;
    let _e87: f32 = a01_;
    let _e88: f32 = b11_;
    let _e91: f32 = a02_;
    let _e92: f32 = b21_;
    det = (((_e84 * _e85) + (_e87 * _e88)) + (_e91 * _e92));
    let _e96: f32 = b01_;
    let _e97: f32 = a22_;
    let _e99: f32 = a01_;
    let _e101: f32 = a02_;
    let _e102: f32 = a21_;
    let _e105: f32 = a12_;
    let _e106: f32 = a01_;
    let _e108: f32 = a02_;
    let _e109: f32 = a11_;
    let _e112: f32 = b11_;
    let _e113: f32 = a22_;
    let _e114: f32 = a00_;
    let _e116: f32 = a02_;
    let _e117: f32 = a20_;
    let _e120: f32 = a12_;
    let _e122: f32 = a00_;
    let _e124: f32 = a02_;
    let _e125: f32 = a10_;
    let _e128: f32 = b21_;
    let _e129: f32 = a21_;
    let _e131: f32 = a00_;
    let _e133: f32 = a01_;
    let _e134: f32 = a20_;
    let _e137: f32 = a11_;
    let _e138: f32 = a00_;
    let _e140: f32 = a01_;
    let _e141: f32 = a10_;
    let _e147: mat3x3<f32> = mat3x3<f32>(vec3<f32>(_e96, ((-(_e97) * _e99) + (_e101 * _e102)), ((_e105 * _e106) - (_e108 * _e109))), vec3<f32>(_e112, ((_e113 * _e114) - (_e116 * _e117)), ((-(_e120) * _e122) + (_e124 * _e125))), vec3<f32>(_e128, ((-(_e129) * _e131) + (_e133 * _e134)), ((_e137 * _e138) - (_e140 * _e141))));
    let _e148: f32 = det;
    let _e149: vec3<f32> = vec3(_e148);
    return mat3x3<f32>((_e147[0] / _e149), (_e147[1] / _e149), (_e147[2] / _e149));
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
    let _e9: f32 = m_5[0][0];
    a00_1 = _e9;
    let _e15: f32 = m_5[0][1];
    a01_1 = _e15;
    let _e21: f32 = m_5[0][2];
    a02_1 = _e21;
    let _e27: f32 = m_5[0][3];
    a03_ = _e27;
    let _e33: f32 = m_5[1][0];
    a10_1 = _e33;
    let _e39: f32 = m_5[1][1];
    a11_1 = _e39;
    let _e45: f32 = m_5[1][2];
    a12_1 = _e45;
    let _e51: f32 = m_5[1][3];
    a13_ = _e51;
    let _e57: f32 = m_5[2][0];
    a20_1 = _e57;
    let _e63: f32 = m_5[2][1];
    a21_1 = _e63;
    let _e69: f32 = m_5[2][2];
    a22_1 = _e69;
    let _e75: f32 = m_5[2][3];
    a23_ = _e75;
    let _e81: f32 = m_5[3][0];
    a30_ = _e81;
    let _e87: f32 = m_5[3][1];
    a31_ = _e87;
    let _e93: f32 = m_5[3][2];
    a32_ = _e93;
    let _e99: f32 = m_5[3][3];
    a33_ = _e99;
    let _e101: f32 = a00_1;
    let _e102: f32 = a11_1;
    let _e104: f32 = a01_1;
    let _e105: f32 = a10_1;
    b00_ = ((_e101 * _e102) - (_e104 * _e105));
    let _e109: f32 = a00_1;
    let _e110: f32 = a12_1;
    let _e112: f32 = a02_1;
    let _e113: f32 = a10_1;
    b01_1 = ((_e109 * _e110) - (_e112 * _e113));
    let _e117: f32 = a00_1;
    let _e118: f32 = a13_;
    let _e120: f32 = a03_;
    let _e121: f32 = a10_1;
    b02_ = ((_e117 * _e118) - (_e120 * _e121));
    let _e125: f32 = a01_1;
    let _e126: f32 = a12_1;
    let _e128: f32 = a02_1;
    let _e129: f32 = a11_1;
    b03_ = ((_e125 * _e126) - (_e128 * _e129));
    let _e133: f32 = a01_1;
    let _e134: f32 = a13_;
    let _e136: f32 = a03_;
    let _e137: f32 = a11_1;
    b04_ = ((_e133 * _e134) - (_e136 * _e137));
    let _e141: f32 = a02_1;
    let _e142: f32 = a13_;
    let _e144: f32 = a03_;
    let _e145: f32 = a12_1;
    b05_ = ((_e141 * _e142) - (_e144 * _e145));
    let _e149: f32 = a20_1;
    let _e150: f32 = a31_;
    let _e152: f32 = a21_1;
    let _e153: f32 = a30_;
    b06_ = ((_e149 * _e150) - (_e152 * _e153));
    let _e157: f32 = a20_1;
    let _e158: f32 = a32_;
    let _e160: f32 = a22_1;
    let _e161: f32 = a30_;
    b07_ = ((_e157 * _e158) - (_e160 * _e161));
    let _e165: f32 = a20_1;
    let _e166: f32 = a33_;
    let _e168: f32 = a23_;
    let _e169: f32 = a30_;
    b08_ = ((_e165 * _e166) - (_e168 * _e169));
    let _e173: f32 = a21_1;
    let _e174: f32 = a32_;
    let _e176: f32 = a22_1;
    let _e177: f32 = a31_;
    b09_ = ((_e173 * _e174) - (_e176 * _e177));
    let _e181: f32 = a21_1;
    let _e182: f32 = a33_;
    let _e184: f32 = a23_;
    let _e185: f32 = a31_;
    b10_ = ((_e181 * _e182) - (_e184 * _e185));
    let _e189: f32 = a22_1;
    let _e190: f32 = a33_;
    let _e192: f32 = a23_;
    let _e193: f32 = a32_;
    b11_1 = ((_e189 * _e190) - (_e192 * _e193));
    let _e197: f32 = b00_;
    let _e198: f32 = b11_1;
    let _e200: f32 = b01_1;
    let _e201: f32 = b10_;
    let _e204: f32 = b02_;
    let _e205: f32 = b09_;
    let _e208: f32 = b03_;
    let _e209: f32 = b08_;
    let _e212: f32 = b04_;
    let _e213: f32 = b07_;
    let _e216: f32 = b05_;
    let _e217: f32 = b06_;
    det_1 = ((((((_e197 * _e198) - (_e200 * _e201)) + (_e204 * _e205)) + (_e208 * _e209)) - (_e212 * _e213)) + (_e216 * _e217));
    let _e221: f32 = a11_1;
    let _e222: f32 = b11_1;
    let _e224: f32 = a12_1;
    let _e225: f32 = b10_;
    let _e228: f32 = a13_;
    let _e229: f32 = b09_;
    let _e232: f32 = a02_1;
    let _e233: f32 = b10_;
    let _e235: f32 = a01_1;
    let _e236: f32 = b11_1;
    let _e239: f32 = a03_;
    let _e240: f32 = b09_;
    let _e243: f32 = a31_;
    let _e244: f32 = b05_;
    let _e246: f32 = a32_;
    let _e247: f32 = b04_;
    let _e250: f32 = a33_;
    let _e251: f32 = b03_;
    let _e254: f32 = a22_1;
    let _e255: f32 = b04_;
    let _e257: f32 = a21_1;
    let _e258: f32 = b05_;
    let _e261: f32 = a23_;
    let _e262: f32 = b03_;
    let _e265: f32 = a12_1;
    let _e266: f32 = b08_;
    let _e268: f32 = a10_1;
    let _e269: f32 = b11_1;
    let _e272: f32 = a13_;
    let _e273: f32 = b07_;
    let _e276: f32 = a00_1;
    let _e277: f32 = b11_1;
    let _e279: f32 = a02_1;
    let _e280: f32 = b08_;
    let _e283: f32 = a03_;
    let _e284: f32 = b07_;
    let _e287: f32 = a32_;
    let _e288: f32 = b02_;
    let _e290: f32 = a30_;
    let _e291: f32 = b05_;
    let _e294: f32 = a33_;
    let _e295: f32 = b01_1;
    let _e298: f32 = a20_1;
    let _e299: f32 = b05_;
    let _e301: f32 = a22_1;
    let _e302: f32 = b02_;
    let _e305: f32 = a23_;
    let _e306: f32 = b01_1;
    let _e309: f32 = a10_1;
    let _e310: f32 = b10_;
    let _e312: f32 = a11_1;
    let _e313: f32 = b08_;
    let _e316: f32 = a13_;
    let _e317: f32 = b06_;
    let _e320: f32 = a01_1;
    let _e321: f32 = b08_;
    let _e323: f32 = a00_1;
    let _e324: f32 = b10_;
    let _e327: f32 = a03_;
    let _e328: f32 = b06_;
    let _e331: f32 = a30_;
    let _e332: f32 = b04_;
    let _e334: f32 = a31_;
    let _e335: f32 = b02_;
    let _e338: f32 = a33_;
    let _e339: f32 = b00_;
    let _e342: f32 = a21_1;
    let _e343: f32 = b02_;
    let _e345: f32 = a20_1;
    let _e346: f32 = b04_;
    let _e349: f32 = a23_;
    let _e350: f32 = b00_;
    let _e353: f32 = a11_1;
    let _e354: f32 = b07_;
    let _e356: f32 = a10_1;
    let _e357: f32 = b09_;
    let _e360: f32 = a12_1;
    let _e361: f32 = b06_;
    let _e364: f32 = a00_1;
    let _e365: f32 = b09_;
    let _e367: f32 = a01_1;
    let _e368: f32 = b07_;
    let _e371: f32 = a02_1;
    let _e372: f32 = b06_;
    let _e375: f32 = a31_;
    let _e376: f32 = b01_1;
    let _e378: f32 = a30_;
    let _e379: f32 = b03_;
    let _e382: f32 = a32_;
    let _e383: f32 = b00_;
    let _e386: f32 = a20_1;
    let _e387: f32 = b03_;
    let _e389: f32 = a21_1;
    let _e390: f32 = b01_1;
    let _e393: f32 = a22_1;
    let _e394: f32 = b00_;
    let _e401: mat4x4<f32> = mat4x4<f32>(vec4<f32>((((_e221 * _e222) - (_e224 * _e225)) + (_e228 * _e229)), (((_e232 * _e233) - (_e235 * _e236)) - (_e239 * _e240)), (((_e243 * _e244) - (_e246 * _e247)) + (_e250 * _e251)), (((_e254 * _e255) - (_e257 * _e258)) - (_e261 * _e262))), vec4<f32>((((_e265 * _e266) - (_e268 * _e269)) - (_e272 * _e273)), (((_e276 * _e277) - (_e279 * _e280)) + (_e283 * _e284)), (((_e287 * _e288) - (_e290 * _e291)) - (_e294 * _e295)), (((_e298 * _e299) - (_e301 * _e302)) + (_e305 * _e306))), vec4<f32>((((_e309 * _e310) - (_e312 * _e313)) + (_e316 * _e317)), (((_e320 * _e321) - (_e323 * _e324)) - (_e327 * _e328)), (((_e331 * _e332) - (_e334 * _e335)) + (_e338 * _e339)), (((_e342 * _e343) - (_e345 * _e346)) - (_e349 * _e350))), vec4<f32>((((_e353 * _e354) - (_e356 * _e357)) - (_e360 * _e361)), (((_e364 * _e365) - (_e367 * _e368)) + (_e371 * _e372)), (((_e375 * _e376) - (_e378 * _e379)) - (_e382 * _e383)), (((_e386 * _e387) - (_e389 * _e390)) + (_e393 * _e394))));
    let _e402: f32 = det_1;
    let _e403: vec4<f32> = vec4(_e402);
    return mat4x4<f32>((_e401[0] / _e403), (_e401[1] / _e403), (_e401[2] / _e403), (_e401[3] / _e403));
}

fn sampleBillboardBaseTexture(materialUv: vec2<f32>) -> vec4<f32> {
    var materialUv_1: vec2<f32>;
    var baseTexture: vec4<f32> = vec4(1f);

    materialUv_1 = materialUv;
    let _e10: vec4<f32> = baseTexture;
    return _e10;
}

fn applyBillboardAlphaCutoff(alpha: f32) {
    var alpha_1: f32;

    alpha_1 = alpha;
    let _e7: f32 = alpha_1;
    let _e8: f32 = global.material_AlphaCutoff;
    if (_e7 < _e8) {
        {
            discard;
        }
    } else {
        return;
    }
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

fn terrainProjectShadowColor() -> vec4<f32> {
    return vec4(0f);
}

fn gs_wgpu_main() {
    let _e6: vec4<f32> = gl_FragCoord_1;
    applyTerrainProjectLodDither(_e6.xy);
    let _e8: vec2<f32> = uv_3;
    let _e9: vec4<f32> = sampleBillboardBaseTexture(_e8);
    applyBillboardAlphaCutoff(_e9.w);
    let _e11: vec4<f32> = terrainProjectShadowColor();
    output_color = _e11;
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) uv: vec2<f32>, @location(1) sourcePositionWS: vec3<f32>, @builtin(position) gl_FragCoord: vec4<f32>) -> FragmentOutput {
    uv_3 = uv;
    sourcePositionWS_1 = sourcePositionWS;
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    let _e15: vec4<f32> = output_color;
    return FragmentOutput(_e15);
}
