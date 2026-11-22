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

struct VertexOutput {
    @location(0) uv: vec2<f32>,
    @location(1) positionWS: vec3<f32>,
    @location(2) normalWS: vec3<f32>,
    @location(3) positionCS: vec4<f32>,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> POSITION_1: vec3<f32>;
var<private> uv: vec2<f32>;
var<private> positionWS_7: vec3<f32>;
var<private> normalWS_3: vec3<f32>;
var<private> positionCS: vec4<f32>;
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

@group(2) @binding(2) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;
var<private> gl_Position: vec4<f32>;

fn inverseMat(m: mat2x2<f32>) -> mat2x2<f32> {
    var m_1: mat2x2<f32>;

    m_1 = m;
    let _e118: f32 = m_1[1][1];
    let _e123: f32 = m_1[0][1];
    let _e129: f32 = m_1[1][0];
    let _e135: f32 = m_1[0][0];
    let _e138: mat2x2<f32> = mat2x2<f32>(vec2<f32>(_e118, -(_e123)), vec2<f32>(-(_e129), _e135));
    let _e143: f32 = m_1[0][0];
    let _e148: f32 = m_1[1][1];
    let _e154: f32 = m_1[0][1];
    let _e159: f32 = m_1[1][0];
    let _e162: vec2<f32> = vec2(((_e143 * _e148) - (_e154 * _e159)));
    return mat2x2<f32>((_e138[0] / _e162), (_e138[1] / _e162));
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
    let _e118: f32 = m_3[0][0];
    a00_ = _e118;
    let _e124: f32 = m_3[0][1];
    a01_ = _e124;
    let _e130: f32 = m_3[0][2];
    a02_ = _e130;
    let _e136: f32 = m_3[1][0];
    a10_ = _e136;
    let _e142: f32 = m_3[1][1];
    a11_ = _e142;
    let _e148: f32 = m_3[1][2];
    a12_ = _e148;
    let _e154: f32 = m_3[2][0];
    a20_ = _e154;
    let _e160: f32 = m_3[2][1];
    a21_ = _e160;
    let _e166: f32 = m_3[2][2];
    a22_ = _e166;
    let _e168: f32 = a22_;
    let _e169: f32 = a11_;
    let _e171: f32 = a12_;
    let _e172: f32 = a21_;
    b01_ = ((_e168 * _e169) - (_e171 * _e172));
    let _e176: f32 = a22_;
    let _e178: f32 = a10_;
    let _e180: f32 = a12_;
    let _e181: f32 = a20_;
    b11_ = ((-(_e176) * _e178) + (_e180 * _e181));
    let _e185: f32 = a21_;
    let _e186: f32 = a10_;
    let _e188: f32 = a11_;
    let _e189: f32 = a20_;
    b21_ = ((_e185 * _e186) - (_e188 * _e189));
    let _e193: f32 = a00_;
    let _e194: f32 = b01_;
    let _e196: f32 = a01_;
    let _e197: f32 = b11_;
    let _e200: f32 = a02_;
    let _e201: f32 = b21_;
    det = (((_e193 * _e194) + (_e196 * _e197)) + (_e200 * _e201));
    let _e205: f32 = b01_;
    let _e206: f32 = a22_;
    let _e208: f32 = a01_;
    let _e210: f32 = a02_;
    let _e211: f32 = a21_;
    let _e214: f32 = a12_;
    let _e215: f32 = a01_;
    let _e217: f32 = a02_;
    let _e218: f32 = a11_;
    let _e221: f32 = b11_;
    let _e222: f32 = a22_;
    let _e223: f32 = a00_;
    let _e225: f32 = a02_;
    let _e226: f32 = a20_;
    let _e229: f32 = a12_;
    let _e231: f32 = a00_;
    let _e233: f32 = a02_;
    let _e234: f32 = a10_;
    let _e237: f32 = b21_;
    let _e238: f32 = a21_;
    let _e240: f32 = a00_;
    let _e242: f32 = a01_;
    let _e243: f32 = a20_;
    let _e246: f32 = a11_;
    let _e247: f32 = a00_;
    let _e249: f32 = a01_;
    let _e250: f32 = a10_;
    let _e256: mat3x3<f32> = mat3x3<f32>(vec3<f32>(_e205, ((-(_e206) * _e208) + (_e210 * _e211)), ((_e214 * _e215) - (_e217 * _e218))), vec3<f32>(_e221, ((_e222 * _e223) - (_e225 * _e226)), ((-(_e229) * _e231) + (_e233 * _e234))), vec3<f32>(_e237, ((-(_e238) * _e240) + (_e242 * _e243)), ((_e246 * _e247) - (_e249 * _e250))));
    let _e257: f32 = det;
    let _e258: vec3<f32> = vec3(_e257);
    return mat3x3<f32>((_e256[0] / _e258), (_e256[1] / _e258), (_e256[2] / _e258));
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
    let _e118: f32 = m_5[0][0];
    a00_1 = _e118;
    let _e124: f32 = m_5[0][1];
    a01_1 = _e124;
    let _e130: f32 = m_5[0][2];
    a02_1 = _e130;
    let _e136: f32 = m_5[0][3];
    a03_ = _e136;
    let _e142: f32 = m_5[1][0];
    a10_1 = _e142;
    let _e148: f32 = m_5[1][1];
    a11_1 = _e148;
    let _e154: f32 = m_5[1][2];
    a12_1 = _e154;
    let _e160: f32 = m_5[1][3];
    a13_ = _e160;
    let _e166: f32 = m_5[2][0];
    a20_1 = _e166;
    let _e172: f32 = m_5[2][1];
    a21_1 = _e172;
    let _e178: f32 = m_5[2][2];
    a22_1 = _e178;
    let _e184: f32 = m_5[2][3];
    a23_ = _e184;
    let _e190: f32 = m_5[3][0];
    a30_ = _e190;
    let _e196: f32 = m_5[3][1];
    a31_ = _e196;
    let _e202: f32 = m_5[3][2];
    a32_ = _e202;
    let _e208: f32 = m_5[3][3];
    a33_ = _e208;
    let _e210: f32 = a00_1;
    let _e211: f32 = a11_1;
    let _e213: f32 = a01_1;
    let _e214: f32 = a10_1;
    b00_ = ((_e210 * _e211) - (_e213 * _e214));
    let _e218: f32 = a00_1;
    let _e219: f32 = a12_1;
    let _e221: f32 = a02_1;
    let _e222: f32 = a10_1;
    b01_1 = ((_e218 * _e219) - (_e221 * _e222));
    let _e226: f32 = a00_1;
    let _e227: f32 = a13_;
    let _e229: f32 = a03_;
    let _e230: f32 = a10_1;
    b02_ = ((_e226 * _e227) - (_e229 * _e230));
    let _e234: f32 = a01_1;
    let _e235: f32 = a12_1;
    let _e237: f32 = a02_1;
    let _e238: f32 = a11_1;
    b03_ = ((_e234 * _e235) - (_e237 * _e238));
    let _e242: f32 = a01_1;
    let _e243: f32 = a13_;
    let _e245: f32 = a03_;
    let _e246: f32 = a11_1;
    b04_ = ((_e242 * _e243) - (_e245 * _e246));
    let _e250: f32 = a02_1;
    let _e251: f32 = a13_;
    let _e253: f32 = a03_;
    let _e254: f32 = a12_1;
    b05_ = ((_e250 * _e251) - (_e253 * _e254));
    let _e258: f32 = a20_1;
    let _e259: f32 = a31_;
    let _e261: f32 = a21_1;
    let _e262: f32 = a30_;
    b06_ = ((_e258 * _e259) - (_e261 * _e262));
    let _e266: f32 = a20_1;
    let _e267: f32 = a32_;
    let _e269: f32 = a22_1;
    let _e270: f32 = a30_;
    b07_ = ((_e266 * _e267) - (_e269 * _e270));
    let _e274: f32 = a20_1;
    let _e275: f32 = a33_;
    let _e277: f32 = a23_;
    let _e278: f32 = a30_;
    b08_ = ((_e274 * _e275) - (_e277 * _e278));
    let _e282: f32 = a21_1;
    let _e283: f32 = a32_;
    let _e285: f32 = a22_1;
    let _e286: f32 = a31_;
    b09_ = ((_e282 * _e283) - (_e285 * _e286));
    let _e290: f32 = a21_1;
    let _e291: f32 = a33_;
    let _e293: f32 = a23_;
    let _e294: f32 = a31_;
    b10_ = ((_e290 * _e291) - (_e293 * _e294));
    let _e298: f32 = a22_1;
    let _e299: f32 = a33_;
    let _e301: f32 = a23_;
    let _e302: f32 = a32_;
    b11_1 = ((_e298 * _e299) - (_e301 * _e302));
    let _e306: f32 = b00_;
    let _e307: f32 = b11_1;
    let _e309: f32 = b01_1;
    let _e310: f32 = b10_;
    let _e313: f32 = b02_;
    let _e314: f32 = b09_;
    let _e317: f32 = b03_;
    let _e318: f32 = b08_;
    let _e321: f32 = b04_;
    let _e322: f32 = b07_;
    let _e325: f32 = b05_;
    let _e326: f32 = b06_;
    det_1 = ((((((_e306 * _e307) - (_e309 * _e310)) + (_e313 * _e314)) + (_e317 * _e318)) - (_e321 * _e322)) + (_e325 * _e326));
    let _e330: f32 = a11_1;
    let _e331: f32 = b11_1;
    let _e333: f32 = a12_1;
    let _e334: f32 = b10_;
    let _e337: f32 = a13_;
    let _e338: f32 = b09_;
    let _e341: f32 = a02_1;
    let _e342: f32 = b10_;
    let _e344: f32 = a01_1;
    let _e345: f32 = b11_1;
    let _e348: f32 = a03_;
    let _e349: f32 = b09_;
    let _e352: f32 = a31_;
    let _e353: f32 = b05_;
    let _e355: f32 = a32_;
    let _e356: f32 = b04_;
    let _e359: f32 = a33_;
    let _e360: f32 = b03_;
    let _e363: f32 = a22_1;
    let _e364: f32 = b04_;
    let _e366: f32 = a21_1;
    let _e367: f32 = b05_;
    let _e370: f32 = a23_;
    let _e371: f32 = b03_;
    let _e374: f32 = a12_1;
    let _e375: f32 = b08_;
    let _e377: f32 = a10_1;
    let _e378: f32 = b11_1;
    let _e381: f32 = a13_;
    let _e382: f32 = b07_;
    let _e385: f32 = a00_1;
    let _e386: f32 = b11_1;
    let _e388: f32 = a02_1;
    let _e389: f32 = b08_;
    let _e392: f32 = a03_;
    let _e393: f32 = b07_;
    let _e396: f32 = a32_;
    let _e397: f32 = b02_;
    let _e399: f32 = a30_;
    let _e400: f32 = b05_;
    let _e403: f32 = a33_;
    let _e404: f32 = b01_1;
    let _e407: f32 = a20_1;
    let _e408: f32 = b05_;
    let _e410: f32 = a22_1;
    let _e411: f32 = b02_;
    let _e414: f32 = a23_;
    let _e415: f32 = b01_1;
    let _e418: f32 = a10_1;
    let _e419: f32 = b10_;
    let _e421: f32 = a11_1;
    let _e422: f32 = b08_;
    let _e425: f32 = a13_;
    let _e426: f32 = b06_;
    let _e429: f32 = a01_1;
    let _e430: f32 = b08_;
    let _e432: f32 = a00_1;
    let _e433: f32 = b10_;
    let _e436: f32 = a03_;
    let _e437: f32 = b06_;
    let _e440: f32 = a30_;
    let _e441: f32 = b04_;
    let _e443: f32 = a31_;
    let _e444: f32 = b02_;
    let _e447: f32 = a33_;
    let _e448: f32 = b00_;
    let _e451: f32 = a21_1;
    let _e452: f32 = b02_;
    let _e454: f32 = a20_1;
    let _e455: f32 = b04_;
    let _e458: f32 = a23_;
    let _e459: f32 = b00_;
    let _e462: f32 = a11_1;
    let _e463: f32 = b07_;
    let _e465: f32 = a10_1;
    let _e466: f32 = b09_;
    let _e469: f32 = a12_1;
    let _e470: f32 = b06_;
    let _e473: f32 = a00_1;
    let _e474: f32 = b09_;
    let _e476: f32 = a01_1;
    let _e477: f32 = b07_;
    let _e480: f32 = a02_1;
    let _e481: f32 = b06_;
    let _e484: f32 = a31_;
    let _e485: f32 = b01_1;
    let _e487: f32 = a30_;
    let _e488: f32 = b03_;
    let _e491: f32 = a32_;
    let _e492: f32 = b00_;
    let _e495: f32 = a20_1;
    let _e496: f32 = b03_;
    let _e498: f32 = a21_1;
    let _e499: f32 = b01_1;
    let _e502: f32 = a22_1;
    let _e503: f32 = b00_;
    let _e510: mat4x4<f32> = mat4x4<f32>(vec4<f32>((((_e330 * _e331) - (_e333 * _e334)) + (_e337 * _e338)), (((_e341 * _e342) - (_e344 * _e345)) - (_e348 * _e349)), (((_e352 * _e353) - (_e355 * _e356)) + (_e359 * _e360)), (((_e363 * _e364) - (_e366 * _e367)) - (_e370 * _e371))), vec4<f32>((((_e374 * _e375) - (_e377 * _e378)) - (_e381 * _e382)), (((_e385 * _e386) - (_e388 * _e389)) + (_e392 * _e393)), (((_e396 * _e397) - (_e399 * _e400)) - (_e403 * _e404)), (((_e407 * _e408) - (_e410 * _e411)) + (_e414 * _e415))), vec4<f32>((((_e418 * _e419) - (_e421 * _e422)) + (_e425 * _e426)), (((_e429 * _e430) - (_e432 * _e433)) - (_e436 * _e437)), (((_e440 * _e441) - (_e443 * _e444)) + (_e447 * _e448)), (((_e451 * _e452) - (_e454 * _e455)) - (_e458 * _e459))), vec4<f32>((((_e462 * _e463) - (_e465 * _e466)) - (_e469 * _e470)), (((_e473 * _e474) - (_e476 * _e477)) + (_e480 * _e481)), (((_e484 * _e485) - (_e487 * _e488)) - (_e491 * _e492)), (((_e495 * _e496) - (_e498 * _e499)) + (_e502 * _e503))));
    let _e511: f32 = det_1;
    let _e512: vec4<f32> = vec4(_e511);
    return mat4x4<f32>((_e510[0] / _e512), (_e510[1] / _e512), (_e510[2] / _e512), (_e510[3] / _e512));
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
    let _e141: vec2<f32> = fromDirection_1;
    fromLength = length(_e141);
    let _e144: vec2<f32> = toDirection_1;
    toLength = length(_e144);
    let _e147: f32 = fromLength;
    if (_e147 <= 0.0001f) {
        let _e150: f32 = toLength;
        if (_e150 > 0.0001f) {
            let _e153: vec2<f32> = toDirection_1;
            let _e154: f32 = toLength;
            local = (_e153 / vec2(_e154));
        } else {
            local = vec2<f32>(1f, 0f);
        }
        let _e161: vec2<f32> = local;
        return _e161;
    }
    let _e162: f32 = toLength;
    if (_e162 <= 0.0001f) {
        let _e165: vec2<f32> = fromDirection_1;
        let _e166: f32 = fromLength;
        return (_e165 / vec2(_e166));
    }
    let _e169: vec2<f32> = fromDirection_1;
    let _e170: f32 = fromLength;
    fromUnit = (_e169 / vec2(_e170));
    let _e174: vec2<f32> = toDirection_1;
    let _e175: f32 = toLength;
    toUnit = (_e174 / vec2(_e175));
    let _e179: vec2<f32> = fromUnit;
    let _e181: vec2<f32> = toUnit;
    let _e184: vec2<f32> = fromUnit;
    let _e186: vec2<f32> = toUnit;
    crossAngle = ((_e179.x * _e181.y) - (_e184.y * _e186.x));
    let _e191: vec2<f32> = fromUnit;
    let _e192: vec2<f32> = toUnit;
    dotAngle = clamp(dot(_e191, _e192), -1f, 1f);
    let _e199: f32 = crossAngle;
    let _e200: f32 = dotAngle;
    let _e202: f32 = weight_1;
    angle = (atan2(_e199, _e200) * clamp(_e202, 0f, 1f));
    let _e208: f32 = angle;
    cosine = cos(_e208);
    let _e211: f32 = angle;
    sine = sin(_e211);
    let _e214: vec2<f32> = fromUnit;
    let _e216: f32 = cosine;
    let _e218: vec2<f32> = fromUnit;
    let _e220: f32 = sine;
    let _e223: vec2<f32> = fromUnit;
    let _e225: f32 = sine;
    let _e227: vec2<f32> = fromUnit;
    let _e229: f32 = cosine;
    return vec2<f32>(((_e214.x * _e216) - (_e218.y * _e220)), ((_e223.x * _e225) + (_e227.y * _e229)));
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
    let _e145: f32 = elapsedSeconds_1;
    deltaTime = clamp(_e145, 0f, 8f);
    let _e150: f32 = frequencyHz_1;
    omega = (max(_e150, 0.001f) * 6.2831855f);
    let _e156: vec2<f32> = state_1;
    let _e158: f32 = target_1;
    error = (_e156.x - _e158);
    let _e161: f32 = dampingRatio_1;
    if (_e161 >= 0.9999f) {
        {
            let _e164: vec2<f32> = state_1;
            let _e166: f32 = omega;
            let _e167: f32 = error;
            coefficient = (_e164.y + (_e166 * _e167));
            let _e171: f32 = omega;
            let _e173: f32 = deltaTime;
            decay = exp((-(_e171) * _e173));
            let _e177: f32 = target_1;
            let _e178: f32 = error;
            let _e179: f32 = coefficient;
            let _e180: f32 = deltaTime;
            let _e183: f32 = decay;
            let _e186: vec2<f32> = state_1;
            let _e188: f32 = omega;
            let _e189: f32 = coefficient;
            let _e191: f32 = deltaTime;
            let _e194: f32 = decay;
            return vec2<f32>((_e177 + ((_e178 + (_e179 * _e180)) * _e183)), ((_e186.y - ((_e188 * _e189) * _e191)) * _e194));
        }
    }
    let _e197: f32 = dampingRatio_1;
    boundedDamping = clamp(_e197, 0.001f, 0.9999f);
    let _e202: f32 = omega;
    let _e204: f32 = boundedDamping;
    let _e205: f32 = boundedDamping;
    dampedOmega = (_e202 * sqrt(max((1f - (_e204 * _e205)), 0.000001f)));
    let _e213: f32 = boundedDamping;
    let _e215: f32 = omega;
    let _e217: f32 = deltaTime;
    decay_1 = exp(((-(_e213) * _e215) * _e217));
    let _e221: f32 = dampedOmega;
    let _e222: f32 = deltaTime;
    cosine_1 = cos((_e221 * _e222));
    let _e226: f32 = dampedOmega;
    let _e227: f32 = deltaTime;
    sine_1 = sin((_e226 * _e227));
    let _e231: vec2<f32> = state_1;
    let _e233: f32 = boundedDamping;
    let _e234: f32 = omega;
    let _e236: f32 = error;
    let _e239: f32 = dampedOmega;
    sineCoefficient = ((_e231.y + ((_e233 * _e234) * _e236)) / _e239);
    let _e242: f32 = error;
    let _e243: f32 = cosine_1;
    let _e245: f32 = sineCoefficient;
    let _e246: f32 = sine_1;
    oscillation = ((_e242 * _e243) + (_e245 * _e246));
    let _e250: f32 = target_1;
    let _e251: f32 = decay_1;
    let _e252: f32 = oscillation;
    let _e255: f32 = decay_1;
    let _e256: f32 = boundedDamping;
    let _e258: f32 = omega;
    let _e260: f32 = oscillation;
    let _e262: f32 = error;
    let _e263: f32 = dampedOmega;
    let _e265: f32 = sine_1;
    let _e268: f32 = sineCoefficient;
    let _e269: f32 = dampedOmega;
    let _e271: f32 = cosine_1;
    return vec2<f32>((_e250 + (_e251 * _e252)), (_e255 * ((((-(_e256) * _e258) * _e260) - ((_e262 * _e263) * _e265)) + ((_e268 * _e269) * _e271))));
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
    let _e149: f32 = elapsedSeconds_3;
    deltaTime_1 = clamp(_e149, 0f, 8f);
    let _e154: f32 = deltaTime_1;
    if (_e154 <= 0f) {
        let _e157: vec2<f32> = state_3;
        return _e157;
    }
    let _e158: f32 = rampDurationSeconds_1;
    rampDuration = max(_e158, 0.0001f);
    let _e162: f32 = deltaTime_1;
    let _e163: f32 = rampDuration;
    rampTime = min(_e162, _e163);
    let _e166: f32 = frequencyHz_3;
    omega_1 = (max(_e166, 0.001f) * 6.2831855f);
    let _e172: f32 = dampingRatio_3;
    boundedDamping_1 = clamp(_e172, 0.001f, 1f);
    let _e177: f32 = endTarget_1;
    let _e178: f32 = startTarget_1;
    let _e180: f32 = rampDuration;
    slope = ((_e177 - _e178) / _e180);
    let _e184: f32 = boundedDamping_1;
    let _e186: f32 = slope;
    let _e188: f32 = omega_1;
    steadyVelocityOffset = (((2f * _e184) * _e186) / _e188);
    let _e191: vec2<f32> = state_3;
    let _e193: f32 = startTarget_1;
    let _e195: f32 = steadyVelocityOffset;
    let _e197: vec2<f32> = state_3;
    let _e199: f32 = slope;
    homogeneousState = vec2<f32>(((_e191.x - _e193) + _e195), (_e197.y - _e199));
    let _e203: vec2<f32> = homogeneousState;
    let _e205: f32 = frequencyHz_3;
    let _e206: f32 = boundedDamping_1;
    let _e207: f32 = rampTime;
    let _e208: vec2<f32> = terrainProjectAdvanceDampedResponse(_e203, 0f, _e205, _e206, _e207);
    homogeneous = _e208;
    let _e210: f32 = startTarget_1;
    let _e211: f32 = slope;
    let _e212: f32 = rampTime;
    let _e215: f32 = steadyVelocityOffset;
    let _e217: vec2<f32> = homogeneous;
    let _e220: f32 = slope;
    let _e221: vec2<f32> = homogeneous;
    response = vec2<f32>((((_e210 + (_e211 * _e212)) - _e215) + _e217.x), (_e220 + _e221.y));
    let _e226: f32 = deltaTime_1;
    let _e227: f32 = rampDuration;
    if (_e226 > _e227) {
        {
            let _e229: vec2<f32> = response;
            let _e230: f32 = endTarget_1;
            let _e231: f32 = frequencyHz_3;
            let _e232: f32 = boundedDamping_1;
            let _e233: f32 = deltaTime_1;
            let _e234: f32 = rampDuration;
            let _e236: vec2<f32> = terrainProjectAdvanceDampedResponse(_e229, _e230, _e231, _e232, (_e233 - _e234));
            response = _e236;
        }
    }
    let _e237: vec2<f32> = response;
    return _e237;
}

fn terrainProjectWindReceiverProfile() -> TerrainProjectWindReceiverProfile {
    var profile: TerrainProjectWindReceiverProfile;
    var response0_: vec4<f32>;
    var response1_: vec4<f32>;
    var response2_: vec4<f32>;

    let _e136: vec4<f32> = global_1.scene_WindBillboardProfile0_;
    response0_ = _e136;
    let _e138: vec4<f32> = global_1.scene_WindBillboardProfile1_;
    response1_ = _e138;
    let _e140: vec4<f32> = global_1.scene_WindBillboardProfile2_;
    response2_ = _e140;
    let _e143: vec4<f32> = response0_;
    profile.bendGain = _e143.x;
    let _e146: vec4<f32> = response0_;
    profile.dynamicGain = _e146.y;
    let _e149: vec4<f32> = response0_;
    profile.macroGain = _e149.z;
    let _e152: vec4<f32> = response0_;
    profile.mesoGain = _e152.w;
    let _e155: vec4<f32> = response1_;
    profile.microGain = _e155.x;
    let _e158: vec4<f32> = response1_;
    profile.responseLagSeconds = _e158.y;
    let _e161: vec4<f32> = response1_;
    profile.maximumBendRadians = _e161.z;
    let _e164: vec4<f32> = response1_;
    profile.flutterWeight = _e164.w;
    let _e167: vec4<f32> = response2_;
    profile.flutterFrequencyMinHz = _e167.x;
    let _e170: vec4<f32> = response2_;
    profile.flutterFrequencyMaxHz = _e170.y;
    let _e173: vec4<f32> = response2_;
    profile.highSpeedMicroScale = _e173.z;
    let _e176: vec4<f32> = response2_;
    profile.naturalFrequencyHz = _e176.w;
    let _e178: TerrainProjectWindReceiverProfile = profile;
    return _e178;
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

    let _e135: f32 = global_1.material_UVBaseLock;
    if (_e135 <= 0f) {
        return 1f;
    }
    let _e142: f32 = baseHeight;
    let _e145: f32 = global_1.material_UVBaseLock;
    return mix(1f, pow(_e142, 1.5f), _e145);
}

fn terrainProjectVegetationStructuralWeight(positionWS: vec3<f32>, originWS: vec3<f32>) -> f32 {
    var positionWS_1: vec3<f32>;
    var originWS_1: vec3<f32>;
    var authoredWeight: f32;

    positionWS_1 = positionWS;
    originWS_1 = originWS;
    let _e139: f32 = terrainProjectVegetationVertexColorWeight();
    authoredWeight = _e139;
    let _e141: f32 = authoredWeight;
    let _e142: f32 = terrainProjectVegetationBaseLockWeight();
    return (_e141 * _e142);
}

fn terrainProjectTreePhase(originWS_2: vec3<f32>) -> f32 {
    var originWS_3: vec3<f32>;

    originWS_3 = originWS_2;
    let _e137: vec3<f32> = originWS_3;
    return fract((sin(dot(_e137.xz, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
}

fn terrainProjectWindReceiverPhase(originWS_4: vec3<f32>) -> f32 {
    var originWS_5: vec3<f32>;
    var phase: f32;

    originWS_5 = originWS_4;
    let _e137: vec3<f32> = originWS_5;
    let _e138: f32 = terrainProjectTreePhase(_e137);
    phase = _e138;
    let _e140: f32 = phase;
    return _e140;
}

fn terrainProjectVegetationFlutterWeight(profile_1: TerrainProjectWindReceiverProfile) -> f32 {
    var profile_2: TerrainProjectWindReceiverProfile;

    profile_2 = profile_1;
    let _e137: TerrainProjectWindReceiverProfile = profile_2;
    return _e137.flutterWeight;
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
    let _e139: f32 = decorrelation_1;
    variation = clamp(abs(_e139), 0f, 1f);
    let _e145: TerrainProjectWindReceiverProfile = profile_4;
    let _e147: TerrainProjectWindReceiverProfile = profile_4;
    let _e149: f32 = variation;
    return mix(_e145.flutterFrequencyMinHz, _e147.flutterFrequencyMaxHz, _e149);
}

fn terrainProjectWindMicroEnvelope(relativeHorizontalSpeed: f32, profile_5: TerrainProjectWindReceiverProfile) -> f32 {
    var relativeHorizontalSpeed_1: f32;
    var profile_6: TerrainProjectWindReceiverProfile;

    relativeHorizontalSpeed_1 = relativeHorizontalSpeed;
    profile_6 = profile_5;
    let _e140: TerrainProjectWindReceiverProfile = profile_6;
    let _e144: f32 = relativeHorizontalSpeed_1;
    return mix(1f, _e140.highSpeedMicroScale, smoothstep(3f, 8f, _e144));
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
    let _e143: vec3<f32> = value_1;
    let _e144: f32 = cosine_3;
    let _e146: vec3<f32> = axis_1;
    let _e147: vec3<f32> = value_1;
    let _e149: f32 = sine_3;
    let _e152: vec3<f32> = axis_1;
    let _e153: vec3<f32> = axis_1;
    let _e154: vec3<f32> = value_1;
    let _e158: f32 = cosine_3;
    return (((_e143 * _e144) + (cross(_e146, _e147) * _e149)) + ((_e152 * dot(_e153, _e154)) * (1f - _e158)));
}

fn terrainProjectRotateAroundAxis(value_2: vec3<f32>, axis_2: vec3<f32>, angle_1: f32) -> vec3<f32> {
    var value_3: vec3<f32>;
    var axis_3: vec3<f32>;
    var angle_2: f32;

    value_3 = value_2;
    axis_3 = axis_2;
    angle_2 = angle_1;
    let _e141: vec3<f32> = value_3;
    let _e142: vec3<f32> = axis_3;
    let _e143: f32 = angle_2;
    let _e145: f32 = angle_2;
    let _e147: vec3<f32> = terrainProjectRotateAroundAxisSinCos(_e141, _e142, cos(_e143), sin(_e145));
    return _e147;
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
    let _e139: f32 = value_5;
    magnitude = abs(_e139);
    let _e142: f32 = maximumMagnitude_1;
    safeMaximum = max(_e142, 0.0001f);
    let _e146: f32 = safeMaximum;
    let _e149: f32 = safeMaximum;
    let _e150: f32 = magnitude;
    saturation = smoothstep((_e146 * 0.6f), _e149, _e150);
    let _e153: f32 = magnitude;
    let _e154: f32 = safeMaximum;
    let _e155: f32 = saturation;
    let _e157: f32 = safeMaximum;
    limitedMagnitude = min(mix(_e153, _e154, _e155), _e157);
    let _e160: f32 = value_5;
    if (_e160 < 0f) {
        let _e163: f32 = limitedMagnitude;
        local_1 = -(_e163);
    } else {
        let _e165: f32 = limitedMagnitude;
        local_1 = _e165;
    }
    let _e167: f32 = local_1;
    return _e167;
}

fn terrainProjectCompliantSignedTravel(value_6: f32, maximumMagnitude_2: f32) -> f32 {
    var value_7: f32;
    var maximumMagnitude_3: f32;
    var safeMaximum_1: f32;

    value_7 = value_6;
    maximumMagnitude_3 = maximumMagnitude_2;
    let _e139: f32 = maximumMagnitude_3;
    safeMaximum_1 = max(_e139, 0f);
    let _e143: f32 = value_7;
    let _e144: f32 = safeMaximum_1;
    let _e146: f32 = safeMaximum_1;
    let _e147: f32 = safeMaximum_1;
    let _e149: f32 = value_7;
    let _e150: f32 = value_7;
    return ((_e143 * _e144) * inverseSqrt((((_e146 * _e147) + (_e149 * _e150)) + 0.00000001f)));
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
    let _e146: vec3<f32> = originWS_7;
    let _e147: f32 = terrainProjectWindReceiverPhase(_e146);
    phase_1 = _e147;
    let _e149: vec4<f32> = global_1.scene_WindSpectrumParams;
    macroInverseScale = _e149.x;
    let _e152: vec4<f32> = global_1.scene_WindFieldParams;
    if (_e152.x > 0.0001f) {
        let _e156: vec3<f32> = global_1.scene_WindVelocity;
        local_2 = normalize(_e156.xz);
    } else {
        local_2 = vec2<f32>(1f, 0f);
    }
    let _e163: vec2<f32> = local_2;
    horizontalDirection = _e163;
    let _e167: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e170: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e172: f32 = naturalFrequencyScale;
    boundedResponseLag = min(_e167.responseLagSeconds, (0.5f / max((_e170.naturalFrequencyHz * _e172), 0.001f)));
    let _e179: vec3<f32> = positionWS_3;
    spectrumPosition = _e179.xz;
    let _e182: vec2<f32> = spectrumPosition;
    let _e183: f32 = macroInverseScale;
    let _e185: vec3<f32> = global_1.scene_WindSpectrumAdvectionOffset;
    let _e187: f32 = macroInverseScale;
    currentSpectrumUv = ((_e182 * _e183) - ((_e185.xz * _e187) * 0.12f));
    let _e193: vec2<f32> = currentSpectrumUv;
    let _e195: vec4<f32> = textureSampleLevel(gs_wgpu_tex_scene_WindSpectrumTexture, gs_wgpu_samp_scene_WindSpectrumTexture, _e193, 0f);
    currentPackedSpectrum = _e195;
    let _e197: vec4<f32> = currentPackedSpectrum;
    packedSpectrum = _e197;
    result.elasticMemory = 0f;
    result.groundResponseVelocity = 0f;
    let _e203: vec4<f32> = packedSpectrum;
    spectrum = ((_e203 * 2f) - vec4(1f));
    let _e211: vec4<f32> = spectrum;
    result.macro_ = clamp(_e211.x, -1f, 1f);
    let _e218: TerrainProjectWindSample = result;
    result.groundWave = _e218.macro_;
    result.groundDetail = 0f;
    result.exposure = 1f;
    let _e239: vec4<f32> = global_1.scene_WindFieldParams;
    result.turbulence = _e239.z;
    result.localFieldWeight = 0f;
    let _e243: vec4<f32> = global_1.scene_WindFieldParams;
    presentedReferenceGust = _e243.y;
    result.meso = 0f;
    result.micro = 0f;
    let _e250: vec3<f32> = positionWS_3;
    let _e252: vec3<f32> = originWS_7;
    heightAboveRoot = max((_e250.y - _e252.y), 0f);
    let _e258: vec3<f32> = global_1.scene_WindLayerMultipliers;
    let _e260: vec3<f32> = global_1.scene_WindLayerMultipliers;
    let _e264: f32 = heightAboveRoot;
    layer = mix(_e258.x, _e260.y, smoothstep(0.8f, 4f, _e264));
    let _e268: vec3<f32> = global_1.scene_WindVelocity;
    let _e269: f32 = layer;
    baseVelocity = (_e268 * _e269);
    let _e272: vec3<f32> = baseVelocity;
    velocity = _e272;
    let _e274: vec3<f32> = baseVelocity;
    steadyVelocity = _e274;
    let _e277: TerrainProjectWindSample = result;
    referenceGustWeight = (1f - _e277.localFieldWeight);
    let _e283: vec3<f32> = velocity;
    let _e284: vec3<f32> = baseVelocity;
    let _e285: f32 = presentedReferenceGust;
    let _e286: f32 = referenceGustWeight;
    let _e288: f32 = gustWeight;
    let _e290: TerrainProjectWindSample = result;
    let _e293: TerrainProjectWindSample = result;
    velocity = (_e283 + (_e284 * (((_e285 * _e286) * _e288) + (_e290.macro_ * (0.08f + (_e293.turbulence * 0.12f))))));
    let _e302: vec3<f32> = velocity;
    horizontalSpeed = length(_e302.xz);
    let _e306: f32 = horizontalSpeed;
    if (_e306 > 0.0001f) {
        {
            let _e309: vec3<f32> = velocity;
            let _e311: f32 = horizontalSpeed;
            direction = (_e309.xz / vec2(_e311));
            let _e315: vec3<f32> = velocity;
            let _e317: vec3<f32> = velocity;
            let _e319: vec2<f32> = direction;
            let _e322: vec2<f32> = direction;
            let _e325: f32 = horizontalSpeed;
            let _e327: TerrainProjectWindSample = result;
            let _e330: TerrainProjectWindSample = result;
            let _e333: vec4<f32> = global_1.scene_WindSpectrumParams;
            let _e336: vec2<f32> = (_e317.xz + ((((vec2<f32>(-(_e319.y), _e322.x) * _e325) * _e327.meso) * _e330.turbulence) * _e333.w));
            velocity.x = _e336.x;
            velocity.z = _e336.y;
        }
    }
    let _e341: vec3<f32> = velocity;
    let _e342: TerrainProjectWindSample = result;
    velocity = (_e341 * _e342.exposure);
    let _e345: vec3<f32> = velocity;
    let _e347: vec3<f32> = velocity;
    let _e349: vec2<f32> = localVelocity;
    let _e350: vec2<f32> = (_e347.xz + _e349);
    velocity.x = _e350.x;
    velocity.z = _e350.y;
    let _e355: vec3<f32> = steadyVelocity;
    let _e356: TerrainProjectWindSample = result;
    steadyVelocity = (_e355 * _e356.exposure);
    let _e360: vec3<f32> = velocity;
    result.velocityWS = _e360;
    let _e362: vec3<f32> = steadyVelocity;
    result.steadyHorizontalSpeed = length(_e362.xz);
    let _e365: TerrainProjectWindSample = result;
    return _e365;
}

fn terrainProjectCompliantBend(requestedAngle: f32, maximumAngle: f32) -> f32 {
    var requestedAngle_1: f32;
    var maximumAngle_1: f32;
    var safeMaximum_2: f32;

    requestedAngle_1 = requestedAngle;
    maximumAngle_1 = maximumAngle;
    let _e139: f32 = maximumAngle_1;
    safeMaximum_2 = max(_e139, 0.0001f);
    let _e143: f32 = safeMaximum_2;
    let _e145: f32 = requestedAngle_1;
    let _e149: f32 = safeMaximum_2;
    return (_e143 * (1f - exp((-(max(_e145, 0f)) / _e149))));
}

fn terrainProjectWindReceiverSpeed(wind: TerrainProjectWindSample, profile_7: TerrainProjectWindReceiverProfile) -> f32 {
    var wind_1: TerrainProjectWindSample;
    var profile_8: TerrainProjectWindReceiverProfile;

    wind_1 = wind;
    profile_8 = profile_7;
    let _e140: TerrainProjectWindSample = wind_1;
    let _e142: TerrainProjectWindSample = wind_1;
    let _e146: TerrainProjectWindReceiverProfile = profile_8;
    let _e150: TerrainProjectWindReceiverProfile = profile_8;
    return (max(0f, mix(_e140.steadyHorizontalSpeed, length(_e142.velocityWS.xz), _e146.dynamicGain)) * _e150.bendGain);
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
    let _e144: TerrainProjectWindSample = wind_3;
    let _e146: TerrainProjectWindSample = wind_3;
    let _e150: TerrainProjectWindReceiverProfile = profile_10;
    physicalSpeed = max(0f, mix(_e144.steadyHorizontalSpeed, length(_e146.velocityWS.xz), _e150.dynamicGain));
    let _e155: TerrainProjectWindSample = wind_3;
    let _e156: TerrainProjectWindReceiverProfile = profile_10;
    let _e157: f32 = terrainProjectWindReceiverSpeed(_e155, _e156);
    receiverSpeed = _e157;
    let _e159: f32 = physicalSpeed;
    normalizedSpeed = (_e159 / 8f);
    let _e163: f32 = receiverSpeed;
    let _e164: f32 = normalizedSpeed;
    quadraticEquivalentSpeed = (_e163 * max(_e164, 0f));
    let _e178: f32 = normalizedSpeed;
    let _e183: f32 = reconfigurationCoefficient;
    let _e188: f32 = nonlinearBlend;
    reconfiguration = pow((1f + (max((_e178 - 0.65f), 0f) * _e183)), (-0.67f * _e188));
    let _e192: f32 = receiverSpeed;
    let _e193: f32 = quadraticEquivalentSpeed;
    let _e194: f32 = nonlinearBlend;
    let _e196: f32 = reconfiguration;
    let _e198: f32 = grassLodgingGain;
    aerodynamicSpeed = ((mix(_e192, _e193, _e194) * _e196) * _e198);
    let _e201: f32 = aerodynamicSpeed;
    let _e202: f32 = global_1.material_WindForce;
    let _e206: f32 = flow_1;
    let _e208: f32 = structuralWeight_1;
    let _e210: f32 = retainedEnergyAngle;
    let _e211: f32 = structuralWeight_1;
    let _e214: TerrainProjectWindReceiverProfile = profile_10;
    let _e216: f32 = terrainProjectCompliantBend((((((_e201 * _e202) * 0.045f) * _e206) * _e208) + (_e210 * _e211)), _e214.maximumBendRadians);
    return _e216;
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
    let _e150: vec3<f32> = global.camera_Position;
    let _e151: vec3<f32> = originWS_9;
    cameraOffsetFromOrigin = (_e150 - _e151);
    let _e154: vec3<f32> = cameraOffsetFromOrigin;
    let _e155: vec3<f32> = cameraOffsetFromOrigin;
    cameraDistanceSquared = dot(_e154, _e155);
    let _e158: f32 = cameraDistanceSquared;
    cameraDistanceToOrigin = sqrt(_e158);
    let _e161: vec3<f32> = positionWS_5;
    windPositionWS = _e161;
    let _e163: vec3<f32> = (*normalWS);
    windNormalWS = _e163;
    let _e169: mat4x4<f32> = global.camera_ViewMat;
    let _e170: vec3<f32> = positionWS_5;
    eyeDepth = -((_e169 * vec4<f32>(_e170.x, _e170.y, _e170.z, 1f)).z);
    let _e180: f32 = eyeDepth;
    let _e181: vec4<f32> = global.camera_ProjectionParams;
    let _e184: f32 = global_1.material_GrassFadeDistance;
    cameraDepthFade = (((_e180 - _e181.y) - _e184) / 5f);
    let _e190: f32 = cameraDepthFade;
    let _e192: f32 = cameraDepthFade;
    let _e193: f32 = global_1.material_GrassFalloff;
    grassFade = clamp(mix((1f - _e190), _e192, (_e193 * 0.5f)), 0f, 1f);
    let _e201: f32 = grassFade;
    let _e202: f32 = global_1.material_GrassDistanceFadeEnable;
    grassFadeMask = mix(1f, _e201, _e202);
    let _e205: vec3<f32> = (*normalWS);
    let _e206: vec3<f32> = windNormalWS;
    let _e207: f32 = grassFadeMask;
    (*normalWS) = normalize(mix(_e205, _e206, vec3(_e207)));
    let _e211: f32 = grassFadeMask;
    (*windShadingResponse) = _e211;
    let _e212: vec3<f32> = originWS_9;
    let _e213: vec3<f32> = windPositionWS;
    let _e214: f32 = grassFadeMask;
    return mix(_e212, _e213, vec3(_e214));
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
    let _e145: f32 = global.camera_ViewMat[0][0];
    let _e150: f32 = global.camera_ViewMat[1][0];
    let _e155: f32 = global.camera_ViewMat[2][0];
    cameraRightWS = normalize(vec3<f32>(_e145, _e150, _e155));
    let _e163: f32 = global.camera_ViewMat[0][2];
    let _e168: f32 = global.camera_ViewMat[1][2];
    let _e173: f32 = global.camera_ViewMat[2][2];
    cameraFacingWS = normalize(vec3<f32>(_e163, _e168, _e173));
    let _e182: vec3<f32> = cameraRightWS;
    let _e183: vec3<f32> = cameraUpWS;
    let _e184: vec3<f32> = cameraFacingWS;
    cameraFacingBasis = mat3x3<f32>(vec3<f32>(_e182.x, _e182.y, _e182.z), vec3<f32>(_e183.x, _e183.y, _e183.z), vec3<f32>(_e184.x, _e184.y, _e184.z));
    let _e201: vec4<f32> = global_1.renderer_ModelMat[0];
    let _e206: vec4<f32> = global_1.renderer_ModelMat[1];
    let _e211: vec4<f32> = global_1.renderer_ModelMat[2];
    modelScale = vec3<f32>(length(_e201.xyz), length(_e206.xyz), length(_e211.xyz));
    let _e216: mat4x4<f32> = global_1.renderer_ModelMat;
    homogeneousOriginWS = (_e216 * vec4<f32>(0f, 0f, 0f, 1f));
    let _e224: vec4<f32> = homogeneousOriginWS;
    let _e226: vec4<f32> = homogeneousOriginWS;
    originWS_10 = (_e224.xyz / vec3(_e226.w));
    let _e231: vec3<f32> = originWS_10;
    let _e232: mat3x3<f32> = cameraFacingBasis;
    let _e233: vec4<f32> = positionOS_1;
    let _e235: vec3<f32> = modelScale;
    positionWS_6 = (_e231 + (_e232 * (_e233.xyz * _e235)));
    let _e242: vec3<f32> = positionWS_6;
    deformation.sourcePositionWS = _e242;
    let _e244: mat3x3<f32> = cameraFacingBasis;
    let _e245: vec3<f32> = normalOS_1;
    deformation.normalWS = normalize((_e244 * _e245));
    let _e249: mat3x3<f32> = cameraFacingBasis;
    let _e250: vec4<f32> = tangentOS_1;
    let _e253: vec3<f32> = normalize((_e249 * _e250.xyz));
    let _e254: vec4<f32> = tangentOS_1;
    deformation.tangentWS = vec4<f32>(_e253.x, _e253.y, _e253.z, _e254.w);
    let _e264: vec3<f32> = positionWS_6;
    let _e265: vec3<f32> = originWS_10;
    let _e266: TerrainProjectBillboardDeformation = deformation;
    let _e268: TerrainProjectBillboardDeformation = deformation;
    let _e277: vec4<f32> = deformation.tangentWS;
    local_3 = _e277.xyz;
    var gs_output_arg0 = deformation.normalWS;
    let _e289: vec3<f32> = terrainProjectApplyVegetationWind(_e264, _e265, (&gs_output_arg0), (&local_3), (&windShadingResponse_1), (&groundWindDiagnostics_1), (&groundWindCarrierNormalWS_1));
    deformation.normalWS = gs_output_arg0;
    let _e290: f32 = local_3.x;
    deformation.tangentWS.x = _e290;
    let _e291: f32 = local_3.y;
    deformation.tangentWS.y = _e291;
    let _e292: f32 = local_3.z;
    deformation.tangentWS.z = _e292;
    deformation.positionWS = _e289;
    let _e294: f32 = terrainProjectVegetationVertexColorWeight();
    let _e295: f32 = terrainProjectVegetationBaseLockWeight();
    deformation.windWeight = (_e294 * _e295);
    let _e297: TerrainProjectBillboardDeformation = deformation;
    return _e297;
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_1: vec3<f32>;
    var result_1: vec3<f32>;

    sh_1 = sh;
    normal_1 = normal;
    let _e145: vec3<f32> = sh_1[0];
    let _e148: vec3<f32> = sh_1[1];
    let _e149: vec3<f32> = normal_1;
    let _e155: vec3<f32> = sh_1[2];
    let _e156: vec3<f32> = normal_1;
    let _e162: vec3<f32> = sh_1[3];
    let _e163: vec3<f32> = normal_1;
    let _e169: vec3<f32> = sh_1[4];
    let _e170: vec3<f32> = normal_1;
    let _e172: vec3<f32> = normal_1;
    let _e179: vec3<f32> = sh_1[5];
    let _e180: vec3<f32> = normal_1;
    let _e182: vec3<f32> = normal_1;
    let _e189: vec3<f32> = sh_1[6];
    let _e191: vec3<f32> = normal_1;
    let _e194: vec3<f32> = normal_1;
    let _e203: vec3<f32> = sh_1[7];
    let _e204: vec3<f32> = normal_1;
    let _e206: vec3<f32> = normal_1;
    let _e213: vec3<f32> = sh_1[8];
    let _e214: vec3<f32> = normal_1;
    let _e216: vec3<f32> = normal_1;
    let _e219: vec3<f32> = normal_1;
    let _e221: vec3<f32> = normal_1;
    result_1 = ((((((((_e145 + (_e148 * _e149.y)) + (_e155 * _e156.z)) + (_e162 * _e163.x)) + (_e169 * (_e170.y * _e172.x))) + (_e179 * (_e180.y * _e182.z))) + (_e189 * (((3f * _e191.z) * _e194.z) - 1f))) + (_e203 * (_e204.z * _e206.x))) + (_e213 * ((_e214.x * _e216.x) - (_e219.y * _e221.y))));
    let _e228: vec3<f32> = result_1;
    return max(_e228, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS_1: vec3<f32>) -> vec3<f32> {
    var normalWS_2: vec3<f32>;

    normalWS_2 = normalWS_1;
    let _e141: EnvMapLight = scene_EnvMapLight;
    return (_e141.diffuse * 3.1415927f);
}

fn gs_wgpu_main() {
    var positionOS_2: vec4<f32>;
    var normalOS_2: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var tangentOS_2: vec4<f32> = vec4<f32>(1f, 0f, 0f, 1f);
    var deformation_1: TerrainProjectBillboardDeformation;

    let _e139: vec3<f32> = POSITION_1;
    positionOS_2 = vec4<f32>(_e139.x, _e139.y, _e139.z, 1f);
    uv = vec2(0f);
    let _e159: vec4<f32> = positionOS_2;
    let _e160: vec3<f32> = normalOS_2;
    let _e161: vec4<f32> = tangentOS_2;
    let _e162: TerrainProjectBillboardDeformation = terrainProjectBillboardDeformation(_e159, _e160, _e161);
    deformation_1 = _e162;
    let _e164: TerrainProjectBillboardDeformation = deformation_1;
    positionWS_7 = _e164.positionWS;
    let _e166: TerrainProjectBillboardDeformation = deformation_1;
    normalWS_3 = _e166.normalWS;
    let _e168: mat4x4<f32> = global_1.camera_VPMat;
    let _e169: vec3<f32> = positionWS_7;
    positionCS = (_e168 * vec4<f32>(_e169.x, _e169.y, _e169.z, 1f));
    let _e177: vec4<f32> = positionCS;
    gl_Position = _e177;
    return;
}

fn main_1() {
    let _e144: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e150: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e156: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e144.x), bitcast<f32>(_e150.y), bitcast<f32>(_e156.z));
    let _e164: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e164.w);
    let _e171: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e171.x);
    let _e178: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e178.y);
    let _e185: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e185.z);
    let _e192: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e192.w);
    gs_wgpu_main();
    let _e197: vec4<f32> = gl_Position;
    let _e199: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e197.z + _e199.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e166: vec2<f32> = uv;
    let _e168: vec3<f32> = positionWS_7;
    let _e170: vec3<f32> = normalWS_3;
    let _e172: vec4<f32> = positionCS;
    let _e174: vec4<f32> = gl_Position;
    return VertexOutput(_e166, _e168, _e170, _e172, _e174);
}
