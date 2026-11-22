diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ProjectionParams: vec4<f32>,
    camera_ViewMat: mat4x4<f32>,
    camera_VPMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    renderer_ModelMat: mat4x4<f32>,
    renderer_NormalMat: mat4x4<f32>,
    material_Tiling: f32,
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
    scene_ShadowBias: vec2<f32>,
    scene_LightDirection: vec3<f32>,
}

struct TerrainProjectWindSample {
    velocityWS: vec3<f32>,
    steadyHorizontalSpeed: f32,
    macro_: f32,
    meso: f32,
    micro: f32,
    groundWave: f32,
    groundDetail: f32,
    turbulence: f32,
    exposure: f32,
    localFieldWeight: f32,
    elasticMemory: f32,
    groundResponseVelocity: f32,
}

struct TerrainProjectWindReceiverProfile {
    bendGain: f32,
    dynamicGain: f32,
    macroGain: f32,
    mesoGain: f32,
    microGain: f32,
    responseLagSeconds: f32,
    maximumBendRadians: f32,
    flutterWeight: f32,
    flutterFrequencyMinHz: f32,
    flutterFrequencyMaxHz: f32,
    highSpeedMicroScale: f32,
    naturalFrequencyHz: f32,
}

struct TerrainProjectBillboardDeformation {
    sourcePositionWS: vec3<f32>,
    positionWS: vec3<f32>,
    normalWS: vec3<f32>,
    tangentWS: vec4<f32>,
    windWeight: f32,
}

struct VertexOutput {
    @location(0) uv: vec2<f32>,
    @location(1) sourcePositionWS: vec3<f32>,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
var<private> POSITION_1: vec3<f32>;
var<private> uv: vec2<f32>;
var<private> sourcePositionWS: vec3<f32>;
@group(0) @binding(0) 
var gs_wgpu_tex_scene_WindSpectrumTexture: texture_2d<f32>;
@group(0) @binding(1) 
var gs_wgpu_samp_scene_WindSpectrumTexture: sampler;
@group(0) @binding(2) 
var gs_wgpu_tex_scene_WindLocalFieldTexture: texture_2d<f32>;

@group(0) @binding(4) 
var gs_wgpu_tex_scene_WindLocalFieldPreviousTexture: texture_2d<f32>;

@group(0) @binding(6) 
var gs_wgpu_tex_scene_WindLocalFieldExposureTexture: texture_2d<f32>;

@group(0) @binding(8) 
var gs_wgpu_tex_scene_WindLocalFieldPreviousExposureTexture: texture_2d<f32>;

@group(0) @binding(10) 
var gs_wgpu_tex_scene_WindGroundResponseTexture: texture_2d<f32>;

@group(0) @binding(12) 
var gs_wgpu_tex_scene_WindFlowerResponseTexture: texture_2d<f32>;

@group(0) @binding(14) 
var gs_wgpu_tex_scene_WindTreeResponseSlowTexture: texture_2d<f32>;

@group(0) @binding(16) 
var gs_wgpu_tex_scene_WindTreeResponseFastTexture: texture_2d<f32>;

var<private> gl_Position: vec4<f32>;

fn inverseMat(m: mat2x2<f32>) -> mat2x2<f32> {
    var m_1: mat2x2<f32>;

    m_1 = m;
    let _e100: f32 = m_1[1][1];
    let _e105: f32 = m_1[0][1];
    let _e111: f32 = m_1[1][0];
    let _e117: f32 = m_1[0][0];
    let _e120: mat2x2<f32> = mat2x2<f32>(vec2<f32>(_e100, -(_e105)), vec2<f32>(-(_e111), _e117));
    let _e125: f32 = m_1[0][0];
    let _e130: f32 = m_1[1][1];
    let _e136: f32 = m_1[0][1];
    let _e141: f32 = m_1[1][0];
    let _e144: vec2<f32> = vec2(((_e125 * _e130) - (_e136 * _e141)));
    return mat2x2<f32>((_e120[0] / _e144), (_e120[1] / _e144));
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
    let _e100: f32 = m_3[0][0];
    a00_ = _e100;
    let _e106: f32 = m_3[0][1];
    a01_ = _e106;
    let _e112: f32 = m_3[0][2];
    a02_ = _e112;
    let _e118: f32 = m_3[1][0];
    a10_ = _e118;
    let _e124: f32 = m_3[1][1];
    a11_ = _e124;
    let _e130: f32 = m_3[1][2];
    a12_ = _e130;
    let _e136: f32 = m_3[2][0];
    a20_ = _e136;
    let _e142: f32 = m_3[2][1];
    a21_ = _e142;
    let _e148: f32 = m_3[2][2];
    a22_ = _e148;
    let _e150: f32 = a22_;
    let _e151: f32 = a11_;
    let _e153: f32 = a12_;
    let _e154: f32 = a21_;
    b01_ = ((_e150 * _e151) - (_e153 * _e154));
    let _e158: f32 = a22_;
    let _e160: f32 = a10_;
    let _e162: f32 = a12_;
    let _e163: f32 = a20_;
    b11_ = ((-(_e158) * _e160) + (_e162 * _e163));
    let _e167: f32 = a21_;
    let _e168: f32 = a10_;
    let _e170: f32 = a11_;
    let _e171: f32 = a20_;
    b21_ = ((_e167 * _e168) - (_e170 * _e171));
    let _e175: f32 = a00_;
    let _e176: f32 = b01_;
    let _e178: f32 = a01_;
    let _e179: f32 = b11_;
    let _e182: f32 = a02_;
    let _e183: f32 = b21_;
    det = (((_e175 * _e176) + (_e178 * _e179)) + (_e182 * _e183));
    let _e187: f32 = b01_;
    let _e188: f32 = a22_;
    let _e190: f32 = a01_;
    let _e192: f32 = a02_;
    let _e193: f32 = a21_;
    let _e196: f32 = a12_;
    let _e197: f32 = a01_;
    let _e199: f32 = a02_;
    let _e200: f32 = a11_;
    let _e203: f32 = b11_;
    let _e204: f32 = a22_;
    let _e205: f32 = a00_;
    let _e207: f32 = a02_;
    let _e208: f32 = a20_;
    let _e211: f32 = a12_;
    let _e213: f32 = a00_;
    let _e215: f32 = a02_;
    let _e216: f32 = a10_;
    let _e219: f32 = b21_;
    let _e220: f32 = a21_;
    let _e222: f32 = a00_;
    let _e224: f32 = a01_;
    let _e225: f32 = a20_;
    let _e228: f32 = a11_;
    let _e229: f32 = a00_;
    let _e231: f32 = a01_;
    let _e232: f32 = a10_;
    let _e238: mat3x3<f32> = mat3x3<f32>(vec3<f32>(_e187, ((-(_e188) * _e190) + (_e192 * _e193)), ((_e196 * _e197) - (_e199 * _e200))), vec3<f32>(_e203, ((_e204 * _e205) - (_e207 * _e208)), ((-(_e211) * _e213) + (_e215 * _e216))), vec3<f32>(_e219, ((-(_e220) * _e222) + (_e224 * _e225)), ((_e228 * _e229) - (_e231 * _e232))));
    let _e239: f32 = det;
    let _e240: vec3<f32> = vec3(_e239);
    return mat3x3<f32>((_e238[0] / _e240), (_e238[1] / _e240), (_e238[2] / _e240));
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
    let _e100: f32 = m_5[0][0];
    a00_1 = _e100;
    let _e106: f32 = m_5[0][1];
    a01_1 = _e106;
    let _e112: f32 = m_5[0][2];
    a02_1 = _e112;
    let _e118: f32 = m_5[0][3];
    a03_ = _e118;
    let _e124: f32 = m_5[1][0];
    a10_1 = _e124;
    let _e130: f32 = m_5[1][1];
    a11_1 = _e130;
    let _e136: f32 = m_5[1][2];
    a12_1 = _e136;
    let _e142: f32 = m_5[1][3];
    a13_ = _e142;
    let _e148: f32 = m_5[2][0];
    a20_1 = _e148;
    let _e154: f32 = m_5[2][1];
    a21_1 = _e154;
    let _e160: f32 = m_5[2][2];
    a22_1 = _e160;
    let _e166: f32 = m_5[2][3];
    a23_ = _e166;
    let _e172: f32 = m_5[3][0];
    a30_ = _e172;
    let _e178: f32 = m_5[3][1];
    a31_ = _e178;
    let _e184: f32 = m_5[3][2];
    a32_ = _e184;
    let _e190: f32 = m_5[3][3];
    a33_ = _e190;
    let _e192: f32 = a00_1;
    let _e193: f32 = a11_1;
    let _e195: f32 = a01_1;
    let _e196: f32 = a10_1;
    b00_ = ((_e192 * _e193) - (_e195 * _e196));
    let _e200: f32 = a00_1;
    let _e201: f32 = a12_1;
    let _e203: f32 = a02_1;
    let _e204: f32 = a10_1;
    b01_1 = ((_e200 * _e201) - (_e203 * _e204));
    let _e208: f32 = a00_1;
    let _e209: f32 = a13_;
    let _e211: f32 = a03_;
    let _e212: f32 = a10_1;
    b02_ = ((_e208 * _e209) - (_e211 * _e212));
    let _e216: f32 = a01_1;
    let _e217: f32 = a12_1;
    let _e219: f32 = a02_1;
    let _e220: f32 = a11_1;
    b03_ = ((_e216 * _e217) - (_e219 * _e220));
    let _e224: f32 = a01_1;
    let _e225: f32 = a13_;
    let _e227: f32 = a03_;
    let _e228: f32 = a11_1;
    b04_ = ((_e224 * _e225) - (_e227 * _e228));
    let _e232: f32 = a02_1;
    let _e233: f32 = a13_;
    let _e235: f32 = a03_;
    let _e236: f32 = a12_1;
    b05_ = ((_e232 * _e233) - (_e235 * _e236));
    let _e240: f32 = a20_1;
    let _e241: f32 = a31_;
    let _e243: f32 = a21_1;
    let _e244: f32 = a30_;
    b06_ = ((_e240 * _e241) - (_e243 * _e244));
    let _e248: f32 = a20_1;
    let _e249: f32 = a32_;
    let _e251: f32 = a22_1;
    let _e252: f32 = a30_;
    b07_ = ((_e248 * _e249) - (_e251 * _e252));
    let _e256: f32 = a20_1;
    let _e257: f32 = a33_;
    let _e259: f32 = a23_;
    let _e260: f32 = a30_;
    b08_ = ((_e256 * _e257) - (_e259 * _e260));
    let _e264: f32 = a21_1;
    let _e265: f32 = a32_;
    let _e267: f32 = a22_1;
    let _e268: f32 = a31_;
    b09_ = ((_e264 * _e265) - (_e267 * _e268));
    let _e272: f32 = a21_1;
    let _e273: f32 = a33_;
    let _e275: f32 = a23_;
    let _e276: f32 = a31_;
    b10_ = ((_e272 * _e273) - (_e275 * _e276));
    let _e280: f32 = a22_1;
    let _e281: f32 = a33_;
    let _e283: f32 = a23_;
    let _e284: f32 = a32_;
    b11_1 = ((_e280 * _e281) - (_e283 * _e284));
    let _e288: f32 = b00_;
    let _e289: f32 = b11_1;
    let _e291: f32 = b01_1;
    let _e292: f32 = b10_;
    let _e295: f32 = b02_;
    let _e296: f32 = b09_;
    let _e299: f32 = b03_;
    let _e300: f32 = b08_;
    let _e303: f32 = b04_;
    let _e304: f32 = b07_;
    let _e307: f32 = b05_;
    let _e308: f32 = b06_;
    det_1 = ((((((_e288 * _e289) - (_e291 * _e292)) + (_e295 * _e296)) + (_e299 * _e300)) - (_e303 * _e304)) + (_e307 * _e308));
    let _e312: f32 = a11_1;
    let _e313: f32 = b11_1;
    let _e315: f32 = a12_1;
    let _e316: f32 = b10_;
    let _e319: f32 = a13_;
    let _e320: f32 = b09_;
    let _e323: f32 = a02_1;
    let _e324: f32 = b10_;
    let _e326: f32 = a01_1;
    let _e327: f32 = b11_1;
    let _e330: f32 = a03_;
    let _e331: f32 = b09_;
    let _e334: f32 = a31_;
    let _e335: f32 = b05_;
    let _e337: f32 = a32_;
    let _e338: f32 = b04_;
    let _e341: f32 = a33_;
    let _e342: f32 = b03_;
    let _e345: f32 = a22_1;
    let _e346: f32 = b04_;
    let _e348: f32 = a21_1;
    let _e349: f32 = b05_;
    let _e352: f32 = a23_;
    let _e353: f32 = b03_;
    let _e356: f32 = a12_1;
    let _e357: f32 = b08_;
    let _e359: f32 = a10_1;
    let _e360: f32 = b11_1;
    let _e363: f32 = a13_;
    let _e364: f32 = b07_;
    let _e367: f32 = a00_1;
    let _e368: f32 = b11_1;
    let _e370: f32 = a02_1;
    let _e371: f32 = b08_;
    let _e374: f32 = a03_;
    let _e375: f32 = b07_;
    let _e378: f32 = a32_;
    let _e379: f32 = b02_;
    let _e381: f32 = a30_;
    let _e382: f32 = b05_;
    let _e385: f32 = a33_;
    let _e386: f32 = b01_1;
    let _e389: f32 = a20_1;
    let _e390: f32 = b05_;
    let _e392: f32 = a22_1;
    let _e393: f32 = b02_;
    let _e396: f32 = a23_;
    let _e397: f32 = b01_1;
    let _e400: f32 = a10_1;
    let _e401: f32 = b10_;
    let _e403: f32 = a11_1;
    let _e404: f32 = b08_;
    let _e407: f32 = a13_;
    let _e408: f32 = b06_;
    let _e411: f32 = a01_1;
    let _e412: f32 = b08_;
    let _e414: f32 = a00_1;
    let _e415: f32 = b10_;
    let _e418: f32 = a03_;
    let _e419: f32 = b06_;
    let _e422: f32 = a30_;
    let _e423: f32 = b04_;
    let _e425: f32 = a31_;
    let _e426: f32 = b02_;
    let _e429: f32 = a33_;
    let _e430: f32 = b00_;
    let _e433: f32 = a21_1;
    let _e434: f32 = b02_;
    let _e436: f32 = a20_1;
    let _e437: f32 = b04_;
    let _e440: f32 = a23_;
    let _e441: f32 = b00_;
    let _e444: f32 = a11_1;
    let _e445: f32 = b07_;
    let _e447: f32 = a10_1;
    let _e448: f32 = b09_;
    let _e451: f32 = a12_1;
    let _e452: f32 = b06_;
    let _e455: f32 = a00_1;
    let _e456: f32 = b09_;
    let _e458: f32 = a01_1;
    let _e459: f32 = b07_;
    let _e462: f32 = a02_1;
    let _e463: f32 = b06_;
    let _e466: f32 = a31_;
    let _e467: f32 = b01_1;
    let _e469: f32 = a30_;
    let _e470: f32 = b03_;
    let _e473: f32 = a32_;
    let _e474: f32 = b00_;
    let _e477: f32 = a20_1;
    let _e478: f32 = b03_;
    let _e480: f32 = a21_1;
    let _e481: f32 = b01_1;
    let _e484: f32 = a22_1;
    let _e485: f32 = b00_;
    let _e492: mat4x4<f32> = mat4x4<f32>(vec4<f32>((((_e312 * _e313) - (_e315 * _e316)) + (_e319 * _e320)), (((_e323 * _e324) - (_e326 * _e327)) - (_e330 * _e331)), (((_e334 * _e335) - (_e337 * _e338)) + (_e341 * _e342)), (((_e345 * _e346) - (_e348 * _e349)) - (_e352 * _e353))), vec4<f32>((((_e356 * _e357) - (_e359 * _e360)) - (_e363 * _e364)), (((_e367 * _e368) - (_e370 * _e371)) + (_e374 * _e375)), (((_e378 * _e379) - (_e381 * _e382)) - (_e385 * _e386)), (((_e389 * _e390) - (_e392 * _e393)) + (_e396 * _e397))), vec4<f32>((((_e400 * _e401) - (_e403 * _e404)) + (_e407 * _e408)), (((_e411 * _e412) - (_e414 * _e415)) - (_e418 * _e419)), (((_e422 * _e423) - (_e425 * _e426)) + (_e429 * _e430)), (((_e433 * _e434) - (_e436 * _e437)) - (_e440 * _e441))), vec4<f32>((((_e444 * _e445) - (_e447 * _e448)) - (_e451 * _e452)), (((_e455 * _e456) - (_e458 * _e459)) + (_e462 * _e463)), (((_e466 * _e467) - (_e469 * _e470)) - (_e473 * _e474)), (((_e477 * _e478) - (_e480 * _e481)) + (_e484 * _e485))));
    let _e493: f32 = det_1;
    let _e494: vec4<f32> = vec4(_e493);
    return mat4x4<f32>((_e492[0] / _e494), (_e492[1] / _e494), (_e492[2] / _e494), (_e492[3] / _e494));
}

fn terrainProjectMixHorizontalDirection(fromDirection: vec2<f32>, toDirection: vec2<f32>, weight: f32) -> vec2<f32> {
    var fromDirection_1: vec2<f32>;
    var toDirection_1: vec2<f32>;
    var weight_1: f32;
    var fromLength: f32;
    var toLength: f32;
    var local: vec2<f32>;
    var fromUnit: vec2<f32>;
    var toUnit: vec2<f32>;
    var crossAngle: f32;
    var dotAngle: f32;
    var angle: f32;
    var cosine: f32;
    var sine: f32;

    fromDirection_1 = fromDirection;
    toDirection_1 = toDirection;
    weight_1 = weight;
    let _e121: vec2<f32> = fromDirection_1;
    fromLength = length(_e121);
    let _e124: vec2<f32> = toDirection_1;
    toLength = length(_e124);
    let _e127: f32 = fromLength;
    if (_e127 <= 0.0001f) {
        let _e130: f32 = toLength;
        if (_e130 > 0.0001f) {
            let _e133: vec2<f32> = toDirection_1;
            let _e134: f32 = toLength;
            local = (_e133 / vec2(_e134));
        } else {
            local = vec2<f32>(1f, 0f);
        }
        let _e141: vec2<f32> = local;
        return _e141;
    }
    let _e142: f32 = toLength;
    if (_e142 <= 0.0001f) {
        let _e145: vec2<f32> = fromDirection_1;
        let _e146: f32 = fromLength;
        return (_e145 / vec2(_e146));
    }
    let _e149: vec2<f32> = fromDirection_1;
    let _e150: f32 = fromLength;
    fromUnit = (_e149 / vec2(_e150));
    let _e154: vec2<f32> = toDirection_1;
    let _e155: f32 = toLength;
    toUnit = (_e154 / vec2(_e155));
    let _e159: vec2<f32> = fromUnit;
    let _e161: vec2<f32> = toUnit;
    let _e164: vec2<f32> = fromUnit;
    let _e166: vec2<f32> = toUnit;
    crossAngle = ((_e159.x * _e161.y) - (_e164.y * _e166.x));
    let _e171: vec2<f32> = fromUnit;
    let _e172: vec2<f32> = toUnit;
    dotAngle = clamp(dot(_e171, _e172), -1f, 1f);
    let _e179: f32 = crossAngle;
    let _e180: f32 = dotAngle;
    let _e182: f32 = weight_1;
    angle = (atan2(_e179, _e180) * clamp(_e182, 0f, 1f));
    let _e188: f32 = angle;
    cosine = cos(_e188);
    let _e191: f32 = angle;
    sine = sin(_e191);
    let _e194: vec2<f32> = fromUnit;
    let _e196: f32 = cosine;
    let _e198: vec2<f32> = fromUnit;
    let _e200: f32 = sine;
    let _e203: vec2<f32> = fromUnit;
    let _e205: f32 = sine;
    let _e207: vec2<f32> = fromUnit;
    let _e209: f32 = cosine;
    return vec2<f32>(((_e194.x * _e196) - (_e198.y * _e200)), ((_e203.x * _e205) + (_e207.y * _e209)));
}

fn terrainProjectAdvanceDampedResponse(state: vec2<f32>, target_: f32, frequencyHz: f32, dampingRatio: f32, elapsedSeconds: f32) -> vec2<f32> {
    var state_1: vec2<f32>;
    var target_1: f32;
    var frequencyHz_1: f32;
    var dampingRatio_1: f32;
    var elapsedSeconds_1: f32;
    var deltaTime: f32;
    var omega: f32;
    var error: f32;
    var coefficient: f32;
    var decay: f32;
    var boundedDamping: f32;
    var dampedOmega: f32;
    var decay_1: f32;
    var cosine_1: f32;
    var sine_1: f32;
    var sineCoefficient: f32;
    var oscillation: f32;

    state_1 = state;
    target_1 = target_;
    frequencyHz_1 = frequencyHz;
    dampingRatio_1 = dampingRatio;
    elapsedSeconds_1 = elapsedSeconds;
    let _e125: f32 = elapsedSeconds_1;
    deltaTime = clamp(_e125, 0f, 8f);
    let _e130: f32 = frequencyHz_1;
    omega = (max(_e130, 0.001f) * 6.2831855f);
    let _e136: vec2<f32> = state_1;
    let _e138: f32 = target_1;
    error = (_e136.x - _e138);
    let _e141: f32 = dampingRatio_1;
    if (_e141 >= 0.9999f) {
        {
            let _e144: vec2<f32> = state_1;
            let _e146: f32 = omega;
            let _e147: f32 = error;
            coefficient = (_e144.y + (_e146 * _e147));
            let _e151: f32 = omega;
            let _e153: f32 = deltaTime;
            decay = exp((-(_e151) * _e153));
            let _e157: f32 = target_1;
            let _e158: f32 = error;
            let _e159: f32 = coefficient;
            let _e160: f32 = deltaTime;
            let _e163: f32 = decay;
            let _e166: vec2<f32> = state_1;
            let _e168: f32 = omega;
            let _e169: f32 = coefficient;
            let _e171: f32 = deltaTime;
            let _e174: f32 = decay;
            return vec2<f32>((_e157 + ((_e158 + (_e159 * _e160)) * _e163)), ((_e166.y - ((_e168 * _e169) * _e171)) * _e174));
        }
    }
    let _e177: f32 = dampingRatio_1;
    boundedDamping = clamp(_e177, 0.001f, 0.9999f);
    let _e182: f32 = omega;
    let _e184: f32 = boundedDamping;
    let _e185: f32 = boundedDamping;
    dampedOmega = (_e182 * sqrt(max((1f - (_e184 * _e185)), 0.000001f)));
    let _e193: f32 = boundedDamping;
    let _e195: f32 = omega;
    let _e197: f32 = deltaTime;
    decay_1 = exp(((-(_e193) * _e195) * _e197));
    let _e201: f32 = dampedOmega;
    let _e202: f32 = deltaTime;
    cosine_1 = cos((_e201 * _e202));
    let _e206: f32 = dampedOmega;
    let _e207: f32 = deltaTime;
    sine_1 = sin((_e206 * _e207));
    let _e211: vec2<f32> = state_1;
    let _e213: f32 = boundedDamping;
    let _e214: f32 = omega;
    let _e216: f32 = error;
    let _e219: f32 = dampedOmega;
    sineCoefficient = ((_e211.y + ((_e213 * _e214) * _e216)) / _e219);
    let _e222: f32 = error;
    let _e223: f32 = cosine_1;
    let _e225: f32 = sineCoefficient;
    let _e226: f32 = sine_1;
    oscillation = ((_e222 * _e223) + (_e225 * _e226));
    let _e230: f32 = target_1;
    let _e231: f32 = decay_1;
    let _e232: f32 = oscillation;
    let _e235: f32 = decay_1;
    let _e236: f32 = boundedDamping;
    let _e238: f32 = omega;
    let _e240: f32 = oscillation;
    let _e242: f32 = error;
    let _e243: f32 = dampedOmega;
    let _e245: f32 = sine_1;
    let _e248: f32 = sineCoefficient;
    let _e249: f32 = dampedOmega;
    let _e251: f32 = cosine_1;
    return vec2<f32>((_e230 + (_e231 * _e232)), (_e235 * ((((-(_e236) * _e238) * _e240) - ((_e242 * _e243) * _e245)) + ((_e248 * _e249) * _e251))));
}

fn terrainProjectAdvanceDampedRampResponse(state_2: vec2<f32>, startTarget: f32, endTarget: f32, frequencyHz_2: f32, dampingRatio_2: f32, rampDurationSeconds: f32, elapsedSeconds_2: f32) -> vec2<f32> {
    var state_3: vec2<f32>;
    var startTarget_1: f32;
    var endTarget_1: f32;
    var frequencyHz_3: f32;
    var dampingRatio_3: f32;
    var rampDurationSeconds_1: f32;
    var elapsedSeconds_3: f32;
    var deltaTime_1: f32;
    var rampDuration: f32;
    var rampTime: f32;
    var omega_1: f32;
    var boundedDamping_1: f32;
    var slope: f32;
    var steadyVelocityOffset: f32;
    var homogeneousState: vec2<f32>;
    var homogeneous: vec2<f32>;
    var response: vec2<f32>;

    state_3 = state_2;
    startTarget_1 = startTarget;
    endTarget_1 = endTarget;
    frequencyHz_3 = frequencyHz_2;
    dampingRatio_3 = dampingRatio_2;
    rampDurationSeconds_1 = rampDurationSeconds;
    elapsedSeconds_3 = elapsedSeconds_2;
    let _e129: f32 = elapsedSeconds_3;
    deltaTime_1 = clamp(_e129, 0f, 8f);
    let _e134: f32 = deltaTime_1;
    if (_e134 <= 0f) {
        let _e137: vec2<f32> = state_3;
        return _e137;
    }
    let _e138: f32 = rampDurationSeconds_1;
    rampDuration = max(_e138, 0.0001f);
    let _e142: f32 = deltaTime_1;
    let _e143: f32 = rampDuration;
    rampTime = min(_e142, _e143);
    let _e146: f32 = frequencyHz_3;
    omega_1 = (max(_e146, 0.001f) * 6.2831855f);
    let _e152: f32 = dampingRatio_3;
    boundedDamping_1 = clamp(_e152, 0.001f, 1f);
    let _e157: f32 = endTarget_1;
    let _e158: f32 = startTarget_1;
    let _e160: f32 = rampDuration;
    slope = ((_e157 - _e158) / _e160);
    let _e164: f32 = boundedDamping_1;
    let _e166: f32 = slope;
    let _e168: f32 = omega_1;
    steadyVelocityOffset = (((2f * _e164) * _e166) / _e168);
    let _e171: vec2<f32> = state_3;
    let _e173: f32 = startTarget_1;
    let _e175: f32 = steadyVelocityOffset;
    let _e177: vec2<f32> = state_3;
    let _e179: f32 = slope;
    homogeneousState = vec2<f32>(((_e171.x - _e173) + _e175), (_e177.y - _e179));
    let _e183: vec2<f32> = homogeneousState;
    let _e185: f32 = frequencyHz_3;
    let _e186: f32 = boundedDamping_1;
    let _e187: f32 = rampTime;
    let _e188: vec2<f32> = terrainProjectAdvanceDampedResponse(_e183, 0f, _e185, _e186, _e187);
    homogeneous = _e188;
    let _e190: f32 = startTarget_1;
    let _e191: f32 = slope;
    let _e192: f32 = rampTime;
    let _e195: f32 = steadyVelocityOffset;
    let _e197: vec2<f32> = homogeneous;
    let _e200: f32 = slope;
    let _e201: vec2<f32> = homogeneous;
    response = vec2<f32>((((_e190 + (_e191 * _e192)) - _e195) + _e197.x), (_e200 + _e201.y));
    let _e206: f32 = deltaTime_1;
    let _e207: f32 = rampDuration;
    if (_e206 > _e207) {
        {
            let _e209: vec2<f32> = response;
            let _e210: f32 = endTarget_1;
            let _e211: f32 = frequencyHz_3;
            let _e212: f32 = boundedDamping_1;
            let _e213: f32 = deltaTime_1;
            let _e214: f32 = rampDuration;
            let _e216: vec2<f32> = terrainProjectAdvanceDampedResponse(_e209, _e210, _e211, _e212, (_e213 - _e214));
            response = _e216;
        }
    }
    let _e217: vec2<f32> = response;
    return _e217;
}

fn terrainProjectWindReceiverProfile() -> TerrainProjectWindReceiverProfile {
    var profile: TerrainProjectWindReceiverProfile;
    var response0_: vec4<f32>;
    var response1_: vec4<f32>;
    var response2_: vec4<f32>;

    let _e116: vec4<f32> = global.scene_WindBillboardProfile0_;
    response0_ = _e116;
    let _e118: vec4<f32> = global.scene_WindBillboardProfile1_;
    response1_ = _e118;
    let _e120: vec4<f32> = global.scene_WindBillboardProfile2_;
    response2_ = _e120;
    let _e123: vec4<f32> = response0_;
    profile.bendGain = _e123.x;
    let _e126: vec4<f32> = response0_;
    profile.dynamicGain = _e126.y;
    let _e129: vec4<f32> = response0_;
    profile.macroGain = _e129.z;
    let _e132: vec4<f32> = response0_;
    profile.mesoGain = _e132.w;
    let _e135: vec4<f32> = response1_;
    profile.microGain = _e135.x;
    let _e138: vec4<f32> = response1_;
    profile.responseLagSeconds = _e138.y;
    let _e141: vec4<f32> = response1_;
    profile.maximumBendRadians = _e141.z;
    let _e144: vec4<f32> = response1_;
    profile.flutterWeight = _e144.w;
    let _e147: vec4<f32> = response2_;
    profile.flutterFrequencyMinHz = _e147.x;
    let _e150: vec4<f32> = response2_;
    profile.flutterFrequencyMaxHz = _e150.y;
    let _e153: vec4<f32> = response2_;
    profile.highSpeedMicroScale = _e153.z;
    let _e156: vec4<f32> = response2_;
    profile.naturalFrequencyHz = _e156.w;
    let _e158: TerrainProjectWindReceiverProfile = profile;
    return _e158;
}

fn terrainProjectWindAnimationLod(distanceToCamera: f32) -> f32 {
    var distanceToCamera_1: f32;

    distanceToCamera_1 = distanceToCamera;
    return 3f;
}

fn terrainProjectVegetationVertexColorWeight() -> f32 {
    return 1f;
}

fn terrainProjectVegetationBaseLockWeight() -> f32 {
    var baseHeight: f32 = 0f;

    let _e115: f32 = global.material_UVBaseLock;
    if (_e115 <= 0f) {
        return 1f;
    }
    let _e122: f32 = baseHeight;
    let _e125: f32 = global.material_UVBaseLock;
    return mix(1f, pow(_e122, 1.5f), _e125);
}

fn terrainProjectVegetationStructuralWeight(positionWS: vec3<f32>, originWS: vec3<f32>) -> f32 {
    var positionWS_1: vec3<f32>;
    var originWS_1: vec3<f32>;
    var authoredWeight: f32;

    positionWS_1 = positionWS;
    originWS_1 = originWS;
    let _e119: f32 = terrainProjectVegetationVertexColorWeight();
    authoredWeight = _e119;
    let _e121: f32 = authoredWeight;
    let _e122: f32 = terrainProjectVegetationBaseLockWeight();
    return (_e121 * _e122);
}

fn terrainProjectTreePhase(originWS_2: vec3<f32>) -> f32 {
    var originWS_3: vec3<f32>;

    originWS_3 = originWS_2;
    let _e117: vec3<f32> = originWS_3;
    return fract((sin(dot(_e117.xz, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
}

fn terrainProjectWindReceiverPhase(originWS_4: vec3<f32>) -> f32 {
    var originWS_5: vec3<f32>;
    var phase: f32;

    originWS_5 = originWS_4;
    let _e117: vec3<f32> = originWS_5;
    let _e118: f32 = terrainProjectTreePhase(_e117);
    phase = _e118;
    let _e120: f32 = phase;
    return _e120;
}

fn terrainProjectVegetationFlutterWeight(profile_1: TerrainProjectWindReceiverProfile) -> f32 {
    var profile_2: TerrainProjectWindReceiverProfile;

    profile_2 = profile_1;
    let _e117: TerrainProjectWindReceiverProfile = profile_2;
    return _e117.flutterWeight;
}

fn terrainProjectShrubBranchCompliance() -> f32 {
    return 1f;
}

fn terrainProjectHeroLeafSpanWeight() -> f32 {
    return 1f;
}

fn terrainProjectWindFlutterFrequencyHz(decorrelation: f32, profile_3: TerrainProjectWindReceiverProfile) -> f32 {
    var decorrelation_1: f32;
    var profile_4: TerrainProjectWindReceiverProfile;
    var variation: f32;

    decorrelation_1 = decorrelation;
    profile_4 = profile_3;
    let _e119: f32 = decorrelation_1;
    variation = clamp(abs(_e119), 0f, 1f);
    let _e125: TerrainProjectWindReceiverProfile = profile_4;
    let _e127: TerrainProjectWindReceiverProfile = profile_4;
    let _e129: f32 = variation;
    return mix(_e125.flutterFrequencyMinHz, _e127.flutterFrequencyMaxHz, _e129);
}

fn terrainProjectWindMicroEnvelope(relativeHorizontalSpeed: f32, profile_5: TerrainProjectWindReceiverProfile) -> f32 {
    var relativeHorizontalSpeed_1: f32;
    var profile_6: TerrainProjectWindReceiverProfile;

    relativeHorizontalSpeed_1 = relativeHorizontalSpeed;
    profile_6 = profile_5;
    let _e120: TerrainProjectWindReceiverProfile = profile_6;
    let _e124: f32 = relativeHorizontalSpeed_1;
    return mix(1f, _e120.highSpeedMicroScale, smoothstep(3f, 8f, _e124));
}

fn terrainProjectRotateAroundAxisSinCos(value: vec3<f32>, axis: vec3<f32>, cosine_2: f32, sine_2: f32) -> vec3<f32> {
    var value_1: vec3<f32>;
    var axis_1: vec3<f32>;
    var cosine_3: f32;
    var sine_3: f32;

    value_1 = value;
    axis_1 = axis;
    cosine_3 = cosine_2;
    sine_3 = sine_2;
    let _e123: vec3<f32> = value_1;
    let _e124: f32 = cosine_3;
    let _e126: vec3<f32> = axis_1;
    let _e127: vec3<f32> = value_1;
    let _e129: f32 = sine_3;
    let _e132: vec3<f32> = axis_1;
    let _e133: vec3<f32> = axis_1;
    let _e134: vec3<f32> = value_1;
    let _e138: f32 = cosine_3;
    return (((_e123 * _e124) + (cross(_e126, _e127) * _e129)) + ((_e132 * dot(_e133, _e134)) * (1f - _e138)));
}

fn terrainProjectRotateAroundAxis(value_2: vec3<f32>, axis_2: vec3<f32>, angle_1: f32) -> vec3<f32> {
    var value_3: vec3<f32>;
    var axis_3: vec3<f32>;
    var angle_2: f32;

    value_3 = value_2;
    axis_3 = axis_2;
    angle_2 = angle_1;
    let _e121: vec3<f32> = value_3;
    let _e122: vec3<f32> = axis_3;
    let _e123: f32 = angle_2;
    let _e125: f32 = angle_2;
    let _e127: vec3<f32> = terrainProjectRotateAroundAxisSinCos(_e121, _e122, cos(_e123), sin(_e125));
    return _e127;
}

fn terrainProjectSmoothSignedLimit(value_4: f32, maximumMagnitude: f32) -> f32 {
    var value_5: f32;
    var maximumMagnitude_1: f32;
    var magnitude: f32;
    var safeMaximum: f32;
    var saturation: f32;
    var limitedMagnitude: f32;
    var local_1: f32;

    value_5 = value_4;
    maximumMagnitude_1 = maximumMagnitude;
    let _e119: f32 = value_5;
    magnitude = abs(_e119);
    let _e122: f32 = maximumMagnitude_1;
    safeMaximum = max(_e122, 0.0001f);
    let _e126: f32 = safeMaximum;
    let _e129: f32 = safeMaximum;
    let _e130: f32 = magnitude;
    saturation = smoothstep((_e126 * 0.6f), _e129, _e130);
    let _e133: f32 = magnitude;
    let _e134: f32 = safeMaximum;
    let _e135: f32 = saturation;
    let _e137: f32 = safeMaximum;
    limitedMagnitude = min(mix(_e133, _e134, _e135), _e137);
    let _e140: f32 = value_5;
    if (_e140 < 0f) {
        let _e143: f32 = limitedMagnitude;
        local_1 = -(_e143);
    } else {
        let _e145: f32 = limitedMagnitude;
        local_1 = _e145;
    }
    let _e147: f32 = local_1;
    return _e147;
}

fn terrainProjectCompliantSignedTravel(value_6: f32, maximumMagnitude_2: f32) -> f32 {
    var value_7: f32;
    var maximumMagnitude_3: f32;
    var safeMaximum_1: f32;

    value_7 = value_6;
    maximumMagnitude_3 = maximumMagnitude_2;
    let _e119: f32 = maximumMagnitude_3;
    safeMaximum_1 = max(_e119, 0f);
    let _e123: f32 = value_7;
    let _e124: f32 = safeMaximum_1;
    let _e126: f32 = safeMaximum_1;
    let _e127: f32 = safeMaximum_1;
    let _e129: f32 = value_7;
    let _e130: f32 = value_7;
    return ((_e123 * _e124) * inverseSqrt((((_e126 * _e127) + (_e129 * _e130)) + 0.00000001f)));
}

fn terrainProjectSampleWind(positionWS_2: vec3<f32>, originWS_6: vec3<f32>, windLod: f32, loadProfile: TerrainProjectWindReceiverProfile, microProfile: TerrainProjectWindReceiverProfile) -> TerrainProjectWindSample {
    var positionWS_3: vec3<f32>;
    var originWS_7: vec3<f32>;
    var windLod_1: f32;
    var loadProfile_1: TerrainProjectWindReceiverProfile;
    var microProfile_1: TerrainProjectWindReceiverProfile;
    var result: TerrainProjectWindSample;
    var phase_1: f32;
    var macroInverseScale: f32;
    var local_2: vec2<f32>;
    var horizontalDirection: vec2<f32>;
    var naturalFrequencyScale: f32 = 1f;
    var boundedResponseLag: f32;
    var spectrumPosition: vec2<f32>;
    var currentSpectrumUv: vec2<f32>;
    var currentPackedSpectrum: vec4<f32>;
    var packedSpectrum: vec4<f32>;
    var spectrum: vec4<f32>;
    var localVelocity: vec2<f32> = vec2(0f);
    var spatialGustVelocity: vec2<f32> = vec2(0f);
    var localTurbulence: f32 = 0f;
    var microSpectrumSignal: f32 = 0f;
    var periodicFlutterSignal: f32 = 0f;
    var microLodWeight: f32 = 0f;
    var presentedReferenceGust: f32;
    var heightAboveRoot: f32;
    var layer: f32;
    var baseVelocity: vec3<f32>;
    var velocity: vec3<f32>;
    var steadyVelocity: vec3<f32>;
    var referenceGustWeight: f32;
    var gustWeight: f32 = 1f;
    var horizontalSpeed: f32;
    var direction: vec2<f32>;

    positionWS_3 = positionWS_2;
    originWS_7 = originWS_6;
    windLod_1 = windLod;
    loadProfile_1 = loadProfile;
    microProfile_1 = microProfile;
    let _e126: vec3<f32> = originWS_7;
    let _e127: f32 = terrainProjectWindReceiverPhase(_e126);
    phase_1 = _e127;
    let _e129: vec4<f32> = global.scene_WindSpectrumParams;
    macroInverseScale = _e129.x;
    let _e132: vec4<f32> = global.scene_WindFieldParams;
    if (_e132.x > 0.0001f) {
        let _e136: vec3<f32> = global.scene_WindVelocity;
        local_2 = normalize(_e136.xz);
    } else {
        local_2 = vec2<f32>(1f, 0f);
    }
    let _e143: vec2<f32> = local_2;
    horizontalDirection = _e143;
    let _e147: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e150: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e152: f32 = naturalFrequencyScale;
    boundedResponseLag = min(_e147.responseLagSeconds, (0.5f / max((_e150.naturalFrequencyHz * _e152), 0.001f)));
    let _e159: vec3<f32> = positionWS_3;
    spectrumPosition = _e159.xz;
    let _e162: vec2<f32> = spectrumPosition;
    let _e163: f32 = macroInverseScale;
    let _e165: vec3<f32> = global.scene_WindSpectrumAdvectionOffset;
    let _e167: f32 = macroInverseScale;
    currentSpectrumUv = ((_e162 * _e163) - ((_e165.xz * _e167) * 0.12f));
    let _e173: vec2<f32> = currentSpectrumUv;
    let _e175: vec4<f32> = textureSampleLevel(gs_wgpu_tex_scene_WindSpectrumTexture, gs_wgpu_samp_scene_WindSpectrumTexture, _e173, 0f);
    currentPackedSpectrum = _e175;
    let _e177: vec4<f32> = currentPackedSpectrum;
    packedSpectrum = _e177;
    result.elasticMemory = 0f;
    result.groundResponseVelocity = 0f;
    let _e183: vec4<f32> = packedSpectrum;
    spectrum = ((_e183 * 2f) - vec4(1f));
    let _e191: vec4<f32> = spectrum;
    result.macro_ = clamp(_e191.x, -1f, 1f);
    let _e198: TerrainProjectWindSample = result;
    result.groundWave = _e198.macro_;
    result.groundDetail = 0f;
    result.exposure = 1f;
    let _e219: vec4<f32> = global.scene_WindFieldParams;
    result.turbulence = _e219.z;
    result.localFieldWeight = 0f;
    let _e223: vec4<f32> = global.scene_WindFieldParams;
    presentedReferenceGust = _e223.y;
    result.meso = 0f;
    result.micro = 0f;
    let _e230: vec3<f32> = positionWS_3;
    let _e232: vec3<f32> = originWS_7;
    heightAboveRoot = max((_e230.y - _e232.y), 0f);
    let _e238: vec3<f32> = global.scene_WindLayerMultipliers;
    let _e240: vec3<f32> = global.scene_WindLayerMultipliers;
    let _e244: f32 = heightAboveRoot;
    layer = mix(_e238.x, _e240.y, smoothstep(0.8f, 4f, _e244));
    let _e248: vec3<f32> = global.scene_WindVelocity;
    let _e249: f32 = layer;
    baseVelocity = (_e248 * _e249);
    let _e252: vec3<f32> = baseVelocity;
    velocity = _e252;
    let _e254: vec3<f32> = baseVelocity;
    steadyVelocity = _e254;
    let _e257: TerrainProjectWindSample = result;
    referenceGustWeight = (1f - _e257.localFieldWeight);
    let _e263: vec3<f32> = velocity;
    let _e264: vec3<f32> = baseVelocity;
    let _e265: f32 = presentedReferenceGust;
    let _e266: f32 = referenceGustWeight;
    let _e268: f32 = gustWeight;
    let _e270: TerrainProjectWindSample = result;
    let _e273: TerrainProjectWindSample = result;
    velocity = (_e263 + (_e264 * (((_e265 * _e266) * _e268) + (_e270.macro_ * (0.08f + (_e273.turbulence * 0.12f))))));
    let _e282: vec3<f32> = velocity;
    horizontalSpeed = length(_e282.xz);
    let _e286: f32 = horizontalSpeed;
    if (_e286 > 0.0001f) {
        {
            let _e289: vec3<f32> = velocity;
            let _e291: f32 = horizontalSpeed;
            direction = (_e289.xz / vec2(_e291));
            let _e295: vec3<f32> = velocity;
            let _e297: vec3<f32> = velocity;
            let _e299: vec2<f32> = direction;
            let _e302: vec2<f32> = direction;
            let _e305: f32 = horizontalSpeed;
            let _e307: TerrainProjectWindSample = result;
            let _e310: TerrainProjectWindSample = result;
            let _e313: vec4<f32> = global.scene_WindSpectrumParams;
            let _e316: vec2<f32> = (_e297.xz + ((((vec2<f32>(-(_e299.y), _e302.x) * _e305) * _e307.meso) * _e310.turbulence) * _e313.w));
            velocity.x = _e316.x;
            velocity.z = _e316.y;
        }
    }
    let _e321: vec3<f32> = velocity;
    let _e322: TerrainProjectWindSample = result;
    velocity = (_e321 * _e322.exposure);
    let _e325: vec3<f32> = velocity;
    let _e327: vec3<f32> = velocity;
    let _e329: vec2<f32> = localVelocity;
    let _e330: vec2<f32> = (_e327.xz + _e329);
    velocity.x = _e330.x;
    velocity.z = _e330.y;
    let _e335: vec3<f32> = steadyVelocity;
    let _e336: TerrainProjectWindSample = result;
    steadyVelocity = (_e335 * _e336.exposure);
    let _e340: vec3<f32> = velocity;
    result.velocityWS = _e340;
    let _e342: vec3<f32> = steadyVelocity;
    result.steadyHorizontalSpeed = length(_e342.xz);
    let _e345: TerrainProjectWindSample = result;
    return _e345;
}

fn terrainProjectCompliantBend(requestedAngle: f32, maximumAngle: f32) -> f32 {
    var requestedAngle_1: f32;
    var maximumAngle_1: f32;
    var safeMaximum_2: f32;

    requestedAngle_1 = requestedAngle;
    maximumAngle_1 = maximumAngle;
    let _e119: f32 = maximumAngle_1;
    safeMaximum_2 = max(_e119, 0.0001f);
    let _e123: f32 = safeMaximum_2;
    let _e125: f32 = requestedAngle_1;
    let _e129: f32 = safeMaximum_2;
    return (_e123 * (1f - exp((-(max(_e125, 0f)) / _e129))));
}

fn terrainProjectWindReceiverSpeed(wind: TerrainProjectWindSample, profile_7: TerrainProjectWindReceiverProfile) -> f32 {
    var wind_1: TerrainProjectWindSample;
    var profile_8: TerrainProjectWindReceiverProfile;

    wind_1 = wind;
    profile_8 = profile_7;
    let _e120: TerrainProjectWindSample = wind_1;
    let _e122: TerrainProjectWindSample = wind_1;
    let _e126: TerrainProjectWindReceiverProfile = profile_8;
    let _e130: TerrainProjectWindReceiverProfile = profile_8;
    return (max(0f, mix(_e120.steadyHorizontalSpeed, length(_e122.velocityWS.xz), _e126.dynamicGain)) * _e130.bendGain);
}

fn terrainProjectWindBendAngle(wind_2: TerrainProjectWindSample, profile_9: TerrainProjectWindReceiverProfile, flow: f32, structuralWeight: f32) -> f32 {
    var wind_3: TerrainProjectWindSample;
    var profile_10: TerrainProjectWindReceiverProfile;
    var flow_1: f32;
    var structuralWeight_1: f32;
    var physicalSpeed: f32;
    var receiverSpeed: f32;
    var normalizedSpeed: f32;
    var quadraticEquivalentSpeed: f32;
    var nonlinearBlend: f32 = 0f;
    var reconfigurationCoefficient: f32 = 1f;
    var grassLodgingGain: f32 = 1f;
    var retainedEnergyAngle: f32 = 0f;
    var reconfiguration: f32;
    var aerodynamicSpeed: f32;

    wind_3 = wind_2;
    profile_10 = profile_9;
    flow_1 = flow;
    structuralWeight_1 = structuralWeight;
    let _e124: TerrainProjectWindSample = wind_3;
    let _e126: TerrainProjectWindSample = wind_3;
    let _e130: TerrainProjectWindReceiverProfile = profile_10;
    physicalSpeed = max(0f, mix(_e124.steadyHorizontalSpeed, length(_e126.velocityWS.xz), _e130.dynamicGain));
    let _e135: TerrainProjectWindSample = wind_3;
    let _e136: TerrainProjectWindReceiverProfile = profile_10;
    let _e137: f32 = terrainProjectWindReceiverSpeed(_e135, _e136);
    receiverSpeed = _e137;
    let _e139: f32 = physicalSpeed;
    normalizedSpeed = (_e139 / 8f);
    let _e143: f32 = receiverSpeed;
    let _e144: f32 = normalizedSpeed;
    quadraticEquivalentSpeed = (_e143 * max(_e144, 0f));
    let _e158: f32 = normalizedSpeed;
    let _e163: f32 = reconfigurationCoefficient;
    let _e168: f32 = nonlinearBlend;
    reconfiguration = pow((1f + (max((_e158 - 0.65f), 0f) * _e163)), (-0.67f * _e168));
    let _e172: f32 = receiverSpeed;
    let _e173: f32 = quadraticEquivalentSpeed;
    let _e174: f32 = nonlinearBlend;
    let _e176: f32 = reconfiguration;
    let _e178: f32 = grassLodgingGain;
    aerodynamicSpeed = ((mix(_e172, _e173, _e174) * _e176) * _e178);
    let _e181: f32 = aerodynamicSpeed;
    let _e182: f32 = global.material_WindForce;
    let _e186: f32 = flow_1;
    let _e188: f32 = structuralWeight_1;
    let _e190: f32 = retainedEnergyAngle;
    let _e191: f32 = structuralWeight_1;
    let _e194: TerrainProjectWindReceiverProfile = profile_10;
    let _e196: f32 = terrainProjectCompliantBend((((((_e181 * _e182) * 0.045f) * _e186) * _e188) + (_e190 * _e191)), _e194.maximumBendRadians);
    return _e196;
}

fn terrainProjectApplyVegetationWind(positionWS_4: vec3<f32>, originWS_8: vec3<f32>, normalWS: ptr<function, vec3<f32>>, tangentWS: ptr<function, vec3<f32>>, windShadingResponse: ptr<function, f32>, groundWindDiagnostics: ptr<function, vec3<f32>>, groundWindCarrierNormalWS: ptr<function, vec3<f32>>) -> vec3<f32> {
    var positionWS_5: vec3<f32>;
    var originWS_9: vec3<f32>;
    var cameraOffsetFromOrigin: vec3<f32>;
    var cameraDistanceSquared: f32;
    var cameraDistanceToOrigin: f32;
    var windPositionWS: vec3<f32>;
    var windNormalWS: vec3<f32>;
    var windTangentWS: vec3<f32> = vec3(0f);
    var grassFade: f32;
    var eyeDepth: f32;
    var cameraDepthFade: f32;
    var grassFadeMask: f32;

    positionWS_5 = positionWS_4;
    originWS_9 = originWS_8;
    (*groundWindDiagnostics) = vec3(0f);
    (*groundWindCarrierNormalWS) = vec3<f32>(0f, 1f, 0f);
    let _e130: vec3<f32> = global.camera_Position;
    let _e131: vec3<f32> = originWS_9;
    cameraOffsetFromOrigin = (_e130 - _e131);
    let _e134: vec3<f32> = cameraOffsetFromOrigin;
    let _e135: vec3<f32> = cameraOffsetFromOrigin;
    cameraDistanceSquared = dot(_e134, _e135);
    let _e138: f32 = cameraDistanceSquared;
    cameraDistanceToOrigin = sqrt(_e138);
    let _e141: vec3<f32> = positionWS_5;
    windPositionWS = _e141;
    let _e143: vec3<f32> = (*normalWS);
    windNormalWS = _e143;
    let _e149: mat4x4<f32> = global.camera_ViewMat;
    let _e150: vec3<f32> = positionWS_5;
    eyeDepth = -((_e149 * vec4<f32>(_e150.x, _e150.y, _e150.z, 1f)).z);
    let _e160: f32 = eyeDepth;
    let _e161: vec4<f32> = global.camera_ProjectionParams;
    let _e164: f32 = global.material_GrassFadeDistance;
    cameraDepthFade = (((_e160 - _e161.y) - _e164) / 5f);
    let _e170: f32 = cameraDepthFade;
    let _e172: f32 = cameraDepthFade;
    let _e173: f32 = global.material_GrassFalloff;
    grassFade = clamp(mix((1f - _e170), _e172, (_e173 * 0.5f)), 0f, 1f);
    let _e181: f32 = grassFade;
    let _e182: f32 = global.material_GrassDistanceFadeEnable;
    grassFadeMask = mix(1f, _e181, _e182);
    let _e185: vec3<f32> = (*normalWS);
    let _e186: vec3<f32> = windNormalWS;
    let _e187: f32 = grassFadeMask;
    (*normalWS) = normalize(mix(_e185, _e186, vec3(_e187)));
    let _e191: f32 = grassFadeMask;
    (*windShadingResponse) = _e191;
    let _e192: vec3<f32> = originWS_9;
    let _e193: vec3<f32> = windPositionWS;
    let _e194: f32 = grassFadeMask;
    return mix(_e192, _e193, vec3(_e194));
}

fn terrainProjectBillboardDeformation(positionOS: vec4<f32>, normalOS: vec3<f32>, tangentOS: vec4<f32>) -> TerrainProjectBillboardDeformation {
    var positionOS_1: vec4<f32>;
    var normalOS_1: vec3<f32>;
    var tangentOS_1: vec4<f32>;
    var cameraRightWS: vec3<f32>;
    var cameraFacingWS: vec3<f32>;
    var cameraUpWS: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var cameraFacingBasis: mat3x3<f32>;
    var modelScale: vec3<f32>;
    var homogeneousOriginWS: vec4<f32>;
    var originWS_10: vec3<f32>;
    var positionWS_6: vec3<f32>;
    var deformation: TerrainProjectBillboardDeformation;
    var windShadingResponse_1: f32;
    var groundWindDiagnostics_1: vec3<f32>;
    var groundWindCarrierNormalWS_1: vec3<f32>;
    var local_3: vec3<f32>;

    positionOS_1 = positionOS;
    normalOS_1 = normalOS;
    tangentOS_1 = tangentOS;
    let _e125: f32 = global.camera_ViewMat[0][0];
    let _e130: f32 = global.camera_ViewMat[1][0];
    let _e135: f32 = global.camera_ViewMat[2][0];
    cameraRightWS = normalize(vec3<f32>(_e125, _e130, _e135));
    let _e143: f32 = global.camera_ViewMat[0][2];
    let _e148: f32 = global.camera_ViewMat[1][2];
    let _e153: f32 = global.camera_ViewMat[2][2];
    cameraFacingWS = normalize(vec3<f32>(_e143, _e148, _e153));
    let _e162: vec3<f32> = cameraRightWS;
    let _e163: vec3<f32> = cameraUpWS;
    let _e164: vec3<f32> = cameraFacingWS;
    cameraFacingBasis = mat3x3<f32>(vec3<f32>(_e162.x, _e162.y, _e162.z), vec3<f32>(_e163.x, _e163.y, _e163.z), vec3<f32>(_e164.x, _e164.y, _e164.z));
    let _e181: vec4<f32> = global.renderer_ModelMat[0];
    let _e186: vec4<f32> = global.renderer_ModelMat[1];
    let _e191: vec4<f32> = global.renderer_ModelMat[2];
    modelScale = vec3<f32>(length(_e181.xyz), length(_e186.xyz), length(_e191.xyz));
    let _e196: mat4x4<f32> = global.renderer_ModelMat;
    homogeneousOriginWS = (_e196 * vec4<f32>(0f, 0f, 0f, 1f));
    let _e204: vec4<f32> = homogeneousOriginWS;
    let _e206: vec4<f32> = homogeneousOriginWS;
    originWS_10 = (_e204.xyz / vec3(_e206.w));
    let _e211: vec3<f32> = originWS_10;
    let _e212: mat3x3<f32> = cameraFacingBasis;
    let _e213: vec4<f32> = positionOS_1;
    let _e215: vec3<f32> = modelScale;
    positionWS_6 = (_e211 + (_e212 * (_e213.xyz * _e215)));
    let _e222: vec3<f32> = positionWS_6;
    deformation.sourcePositionWS = _e222;
    let _e224: mat3x3<f32> = cameraFacingBasis;
    let _e225: vec3<f32> = normalOS_1;
    deformation.normalWS = normalize((_e224 * _e225));
    let _e229: mat3x3<f32> = cameraFacingBasis;
    let _e230: vec4<f32> = tangentOS_1;
    let _e233: vec3<f32> = normalize((_e229 * _e230.xyz));
    let _e234: vec4<f32> = tangentOS_1;
    deformation.tangentWS = vec4<f32>(_e233.x, _e233.y, _e233.z, _e234.w);
    let _e244: vec3<f32> = positionWS_6;
    let _e245: vec3<f32> = originWS_10;
    let _e246: TerrainProjectBillboardDeformation = deformation;
    let _e248: TerrainProjectBillboardDeformation = deformation;
    let _e257: vec4<f32> = deformation.tangentWS;
    local_3 = _e257.xyz;
    var gs_output_arg0 = deformation.normalWS;
    let _e269: vec3<f32> = terrainProjectApplyVegetationWind(_e244, _e245, (&gs_output_arg0), (&local_3), (&windShadingResponse_1), (&groundWindDiagnostics_1), (&groundWindCarrierNormalWS_1));
    deformation.normalWS = gs_output_arg0;
    let _e270: f32 = local_3.x;
    deformation.tangentWS.x = _e270;
    let _e271: f32 = local_3.y;
    deformation.tangentWS.y = _e271;
    let _e272: f32 = local_3.z;
    deformation.tangentWS.z = _e272;
    deformation.positionWS = _e269;
    let _e274: f32 = terrainProjectVegetationVertexColorWeight();
    let _e275: f32 = terrainProjectVegetationBaseLockWeight();
    deformation.windWeight = (_e274 * _e275);
    let _e277: TerrainProjectBillboardDeformation = deformation;
    return _e277;
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn applyTerrainProjectShadowBias(positionWS_7: vec3<f32>, normalWS_1: vec3<f32>) -> vec3<f32> {
    var positionWS_8: vec3<f32>;
    var normalWS_2: vec3<f32>;
    var inverseNdotL: f32;

    positionWS_8 = positionWS_7;
    normalWS_2 = normalWS_1;
    let _e119: vec3<f32> = positionWS_8;
    let _e120: vec3<f32> = global.scene_LightDirection;
    let _e121: vec2<f32> = global.scene_ShadowBias;
    positionWS_8 = (_e119 - (_e120 * _e121.x));
    let _e126: vec3<f32> = global.scene_LightDirection;
    let _e128: vec3<f32> = normalWS_2;
    inverseNdotL = (1f - clamp(dot(-(_e126), _e128), 0f, 1f));
    let _e135: vec3<f32> = positionWS_8;
    let _e136: vec3<f32> = normalWS_2;
    let _e137: f32 = inverseNdotL;
    let _e138: vec2<f32> = global.scene_ShadowBias;
    return (_e135 + (_e136 * (_e137 * _e138.y)));
}

fn terrainProjectShadowClipPosition(positionWS_9: vec3<f32>) -> vec4<f32> {
    var positionWS_10: vec3<f32>;
    var positionCS: vec4<f32>;

    positionWS_10 = positionWS_9;
    let _e117: mat4x4<f32> = global.camera_VPMat;
    let _e118: vec3<f32> = positionWS_10;
    positionCS = (_e117 * vec4<f32>(_e118.x, _e118.y, _e118.z, 1f));
    let _e127: vec4<f32> = positionCS;
    positionCS.z = max(_e127.z, -1f);
    let _e132: vec4<f32> = positionCS;
    return _e132;
}

fn gs_wgpu_main() {
    var positionOS_2: vec4<f32>;
    var normalOS_2: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var tangentOS_2: vec4<f32> = vec4<f32>(1f, 0f, 0f, 1f);
    var deformation_1: TerrainProjectBillboardDeformation;
    var positionWS_11: vec3<f32>;

    let _e115: vec3<f32> = POSITION_1;
    positionOS_2 = vec4<f32>(_e115.x, _e115.y, _e115.z, 1f);
    uv = vec2(0f);
    let _e135: vec4<f32> = positionOS_2;
    let _e136: vec3<f32> = normalOS_2;
    let _e137: vec4<f32> = tangentOS_2;
    let _e138: TerrainProjectBillboardDeformation = terrainProjectBillboardDeformation(_e135, _e136, _e137);
    deformation_1 = _e138;
    let _e140: TerrainProjectBillboardDeformation = deformation_1;
    sourcePositionWS = _e140.positionWS;
    let _e142: TerrainProjectBillboardDeformation = deformation_1;
    positionWS_11 = _e142.positionWS;
    let _e146: vec3<f32> = positionWS_11;
    let _e147: TerrainProjectBillboardDeformation = deformation_1;
    let _e149: vec3<f32> = applyTerrainProjectShadowBias(_e146, _e147.normalWS);
    let _e150: vec4<f32> = terrainProjectShadowClipPosition(_e149);
    gl_Position = _e150;
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e118: vec4<f32> = gl_Position;
    let _e120: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e118.z + _e120.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e139: vec2<f32> = uv;
    let _e141: vec3<f32> = sourcePositionWS;
    let _e143: vec4<f32> = gl_Position;
    return VertexOutput(_e139, _e141, _e143);
}
