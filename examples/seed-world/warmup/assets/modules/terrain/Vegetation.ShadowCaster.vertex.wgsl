diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ProjectionParams: vec4<f32>,
    camera_ViewMat: mat4x4<f32>,
    camera_VPMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    renderer_ModelMat: mat4x4<f32>,
    renderer_NormalMat: mat4x4<f32>,
    material_Tiling: f32,
    material_LightingFlatness: f32,
    material_WindForce: f32,
    material_WindWavesScale: f32,
    material_WindFlowDensity: f32,
    material_WindGroundWaveParams: vec4<f32>,
    material_WindGroundShapeParams: vec4<f32>,
    material_WindHierarchyParams: vec4<f32>,
    material_WindSpeciesParams: vec4<f32>,
    material_WindTrunkModeParams: vec4<f32>,
    material_WindTreePrimaryParams: vec4<f32>,
    material_WindTreeComplianceGain: f32,
    material_WindInputWeights: vec4<f32>,
    material_WindStructureWeights: vec4<f32>,
    material_WindAerodynamicWeights: vec4<f32>,
    material_WindFlutterTuning: vec4<f32>,
    material_WindLockedDirectionWS: vec4<f32>,
    material_WindMechanicalBoundsMin: vec4<f32>,
    material_WindMechanicalBoundsExtent: vec4<f32>,
    material_WindMechanicalTextureSize: vec4<f32>,
    material_UVBaseLock: f32,
    material_GrassDistanceFadeEnable: f32,
    material_GrassFadeDistance: f32,
    material_GrassFalloff: f32,
    scene_WindVelocity: vec3<f32>,
    scene_WindAnimationEnabled: f32,
    scene_WindFieldParams: vec4<f32>,
    scene_WindSpectrumAdvectionOffset: vec3<f32>,
    scene_WindLayerMultipliers: vec3<f32>,
    scene_WindSpectrumParams: vec4<f32>,
    scene_WindLocalFieldTransform: vec4<f32>,
    scene_WindLocalFieldTemporalParams: vec4<f32>,
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

struct Attributes {
    POSITION: vec3<f32>,
}

struct Varyings {
    uv: vec2<f32>,
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

struct VertexOutput {
    @location(0) uv: vec2<f32>,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
var<private> POSITION_1: vec3<f32>;
var<private> uv: vec2<f32>;
@group(0) @binding(0) 
var gs_wgpu_tex_scene_WindSpectrumTexture: texture_2d<f32>;
@group(0) @binding(1) 
var gs_wgpu_samp_scene_WindSpectrumTexture: sampler;
@group(0) @binding(2) 
var gs_wgpu_tex_scene_WindTreeResponseSlowTexture: texture_2d<f32>;

@group(0) @binding(4) 
var gs_wgpu_tex_scene_WindTreeResponseFastTexture: texture_2d<f32>;

var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e123: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e123;
    let _e124: Attributes = interface_value;
    return _e124;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e124: Varyings = interface_value_2;
    uv = _e124.uv;
    return;
}

fn terrainProjectRotateDetailY(value: vec3<f32>, radians: f32) -> vec3<f32> {
    var value_1: vec3<f32>;
    var radians_1: f32;
    var sine: f32;
    var cosine: f32;

    value_1 = value;
    radians_1 = radians;
    let _e126: f32 = radians_1;
    sine = sin(_e126);
    let _e129: f32 = radians_1;
    cosine = cos(_e129);
    let _e132: f32 = cosine;
    let _e133: vec3<f32> = value_1;
    let _e136: f32 = sine;
    let _e137: vec3<f32> = value_1;
    let _e141: vec3<f32> = value_1;
    let _e143: f32 = sine;
    let _e145: vec3<f32> = value_1;
    let _e148: f32 = cosine;
    let _e149: vec3<f32> = value_1;
    return vec3<f32>(((_e132 * _e133.x) + (_e136 * _e137.z)), _e141.y, ((-(_e143) * _e145.x) + (_e148 * _e149.z)));
}

fn terrainProjectDetailPositionOS(sourcePositionOS: vec3<f32>, attributes: Attributes) -> vec3<f32> {
    var sourcePositionOS_1: vec3<f32>;
    var attributes_1: Attributes;

    sourcePositionOS_1 = sourcePositionOS;
    attributes_1 = attributes;
    let _e126: vec3<f32> = sourcePositionOS_1;
    return _e126;
}

fn terrainProjectDetailOriginOS(attributes_2: Attributes) -> vec3<f32> {
    var attributes_3: Attributes;

    attributes_3 = attributes_2;
    return vec3(0f);
}

fn terrainProjectDetailNormalOS(sourceNormalOS: vec3<f32>, attributes_4: Attributes) -> vec3<f32> {
    var sourceNormalOS_1: vec3<f32>;
    var attributes_5: Attributes;

    sourceNormalOS_1 = sourceNormalOS;
    attributes_5 = attributes_4;
    let _e126: vec3<f32> = sourceNormalOS_1;
    return _e126;
}

fn terrainProjectDetailTangentOS(sourceTangentOS: vec3<f32>, attributes_6: Attributes) -> vec3<f32> {
    var sourceTangentOS_1: vec3<f32>;
    var attributes_7: Attributes;

    sourceTangentOS_1 = sourceTangentOS;
    attributes_7 = attributes_6;
    let _e126: vec3<f32> = sourceTangentOS_1;
    return _e126;
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
    var cosine_1: f32;
    var sine_1: f32;

    fromDirection_1 = fromDirection;
    toDirection_1 = toDirection;
    weight_1 = weight;
    let _e134: vec2<f32> = fromDirection_1;
    fromLength = length(_e134);
    let _e137: vec2<f32> = toDirection_1;
    toLength = length(_e137);
    let _e140: f32 = fromLength;
    if (_e140 <= 0.0001f) {
        let _e143: f32 = toLength;
        if (_e143 > 0.0001f) {
            let _e146: vec2<f32> = toDirection_1;
            let _e147: f32 = toLength;
            local = (_e146 / vec2(_e147));
        } else {
            local = vec2<f32>(1f, 0f);
        }
        let _e154: vec2<f32> = local;
        return _e154;
    }
    let _e155: f32 = toLength;
    if (_e155 <= 0.0001f) {
        let _e158: vec2<f32> = fromDirection_1;
        let _e159: f32 = fromLength;
        return (_e158 / vec2(_e159));
    }
    let _e162: vec2<f32> = fromDirection_1;
    let _e163: f32 = fromLength;
    fromUnit = (_e162 / vec2(_e163));
    let _e167: vec2<f32> = toDirection_1;
    let _e168: f32 = toLength;
    toUnit = (_e167 / vec2(_e168));
    let _e172: vec2<f32> = fromUnit;
    let _e174: vec2<f32> = toUnit;
    let _e177: vec2<f32> = fromUnit;
    let _e179: vec2<f32> = toUnit;
    crossAngle = ((_e172.x * _e174.y) - (_e177.y * _e179.x));
    let _e184: vec2<f32> = fromUnit;
    let _e185: vec2<f32> = toUnit;
    dotAngle = clamp(dot(_e184, _e185), -1f, 1f);
    let _e192: f32 = crossAngle;
    let _e193: f32 = dotAngle;
    let _e195: f32 = weight_1;
    angle = (atan2(_e192, _e193) * clamp(_e195, 0f, 1f));
    let _e201: f32 = angle;
    cosine_1 = cos(_e201);
    let _e204: f32 = angle;
    sine_1 = sin(_e204);
    let _e207: vec2<f32> = fromUnit;
    let _e209: f32 = cosine_1;
    let _e211: vec2<f32> = fromUnit;
    let _e213: f32 = sine_1;
    let _e216: vec2<f32> = fromUnit;
    let _e218: f32 = sine_1;
    let _e220: vec2<f32> = fromUnit;
    let _e222: f32 = cosine_1;
    return vec2<f32>(((_e207.x * _e209) - (_e211.y * _e213)), ((_e216.x * _e218) + (_e220.y * _e222)));
}

fn terrainProjectWindReceiverProfile() -> TerrainProjectWindReceiverProfile {
    var profile: TerrainProjectWindReceiverProfile;
    var response0_: vec4<f32>;
    var response1_: vec4<f32>;
    var response2_: vec4<f32>;

    let _e129: vec4<f32> = global.scene_WindGrassProfile0_;
    response0_ = _e129;
    let _e131: vec4<f32> = global.scene_WindGrassProfile1_;
    response1_ = _e131;
    let _e133: vec4<f32> = global.scene_WindGrassProfile2_;
    response2_ = _e133;
    let _e136: vec4<f32> = response0_;
    profile.bendGain = _e136.x;
    let _e139: vec4<f32> = response0_;
    profile.dynamicGain = _e139.y;
    let _e142: vec4<f32> = response0_;
    profile.macroGain = _e142.z;
    let _e145: vec4<f32> = response0_;
    profile.mesoGain = _e145.w;
    let _e148: vec4<f32> = response1_;
    profile.microGain = _e148.x;
    let _e151: vec4<f32> = response1_;
    profile.responseLagSeconds = _e151.y;
    let _e154: vec4<f32> = response1_;
    profile.maximumBendRadians = _e154.z;
    let _e157: vec4<f32> = response1_;
    profile.flutterWeight = _e157.w;
    let _e160: vec4<f32> = response2_;
    profile.flutterFrequencyMinHz = _e160.x;
    let _e163: vec4<f32> = response2_;
    profile.flutterFrequencyMaxHz = _e163.y;
    let _e166: vec4<f32> = response2_;
    profile.highSpeedMicroScale = _e166.z;
    let _e169: vec4<f32> = response2_;
    profile.naturalFrequencyHz = _e169.w;
    let _e171: TerrainProjectWindReceiverProfile = profile;
    return _e171;
}

fn terrainProjectWindAnimationLod(distanceToCamera: f32) -> f32 {
    var distanceToCamera_1: f32;

    distanceToCamera_1 = distanceToCamera;
    let _e132: f32 = distanceToCamera_1;
    let _e136: f32 = distanceToCamera_1;
    return (smoothstep(36f, 72f, _e132) + smoothstep(120f, 220f, _e136));
}

fn terrainProjectVegetationVertexColorWeight(attributes_8: Attributes) -> f32 {
    var attributes_9: Attributes;

    attributes_9 = attributes_8;
    return 1f;
}

fn terrainProjectVegetationBaseLockWeight(attributes_10: Attributes) -> f32 {
    var attributes_11: Attributes;
    var baseHeight: f32 = 0f;

    attributes_11 = attributes_10;
    let _e130: f32 = global.material_UVBaseLock;
    if (_e130 <= 0f) {
        return 1f;
    }
    let _e137: f32 = baseHeight;
    let _e140: f32 = global.material_UVBaseLock;
    return mix(1f, pow(_e137, 1.5f), _e140);
}

fn terrainProjectVegetationStructuralWeight(positionWS: vec3<f32>, originWS: vec3<f32>, attributes_12: Attributes) -> f32 {
    var positionWS_1: vec3<f32>;
    var originWS_1: vec3<f32>;
    var attributes_13: Attributes;
    var authoredWeight: f32;

    positionWS_1 = positionWS;
    originWS_1 = originWS;
    attributes_13 = attributes_12;
    let _e134: Attributes = attributes_13;
    let _e135: f32 = terrainProjectVegetationVertexColorWeight(_e134);
    authoredWeight = _e135;
    let _e137: f32 = authoredWeight;
    let _e138: Attributes = attributes_13;
    let _e139: f32 = terrainProjectVegetationBaseLockWeight(_e138);
    return (_e137 * _e139);
}

fn terrainProjectTreePhase(originWS_2: vec3<f32>) -> f32 {
    var originWS_3: vec3<f32>;

    originWS_3 = originWS_2;
    let _e130: vec3<f32> = originWS_3;
    return fract((sin(dot(_e130.xz, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
}

fn terrainProjectWindReceiverPhase(originWS_4: vec3<f32>, attributes_14: Attributes) -> f32 {
    var originWS_5: vec3<f32>;
    var attributes_15: Attributes;
    var phase: f32;

    originWS_5 = originWS_4;
    attributes_15 = attributes_14;
    let _e132: vec3<f32> = originWS_5;
    let _e133: f32 = terrainProjectTreePhase(_e132);
    phase = _e133;
    let _e135: f32 = phase;
    return _e135;
}

fn terrainProjectVegetationFlutterWeight(attributes_16: Attributes, profile_1: TerrainProjectWindReceiverProfile) -> f32 {
    var attributes_17: Attributes;
    var profile_2: TerrainProjectWindReceiverProfile;

    attributes_17 = attributes_16;
    profile_2 = profile_1;
    let _e132: TerrainProjectWindReceiverProfile = profile_2;
    return _e132.flutterWeight;
}

fn terrainProjectShrubBranchCompliance(attributes_18: Attributes) -> f32 {
    var attributes_19: Attributes;

    attributes_19 = attributes_18;
    return 1f;
}

fn terrainProjectHeroLeafSpanWeight(attributes_20: Attributes) -> f32 {
    var attributes_21: Attributes;

    attributes_21 = attributes_20;
    return 1f;
}

fn terrainProjectWindFlutterFrequencyHz(decorrelation: f32, profile_3: TerrainProjectWindReceiverProfile) -> f32 {
    var decorrelation_1: f32;
    var profile_4: TerrainProjectWindReceiverProfile;
    var variation: f32;

    decorrelation_1 = decorrelation;
    profile_4 = profile_3;
    let _e132: f32 = decorrelation_1;
    variation = clamp(abs(_e132), 0f, 1f);
    let _e138: TerrainProjectWindReceiverProfile = profile_4;
    let _e140: TerrainProjectWindReceiverProfile = profile_4;
    let _e142: f32 = variation;
    return mix(_e138.flutterFrequencyMinHz, _e140.flutterFrequencyMaxHz, _e142);
}

fn terrainProjectWindMicroEnvelope(relativeHorizontalSpeed: f32, profile_5: TerrainProjectWindReceiverProfile) -> f32 {
    var relativeHorizontalSpeed_1: f32;
    var profile_6: TerrainProjectWindReceiverProfile;

    relativeHorizontalSpeed_1 = relativeHorizontalSpeed;
    profile_6 = profile_5;
    let _e133: TerrainProjectWindReceiverProfile = profile_6;
    let _e137: f32 = relativeHorizontalSpeed_1;
    return mix(1f, _e133.highSpeedMicroScale, smoothstep(3f, 8f, _e137));
}

fn terrainProjectRotateAroundAxisSinCos(value_2: vec3<f32>, axis: vec3<f32>, cosine_2: f32, sine_2: f32) -> vec3<f32> {
    var value_3: vec3<f32>;
    var axis_1: vec3<f32>;
    var cosine_3: f32;
    var sine_3: f32;

    value_3 = value_2;
    axis_1 = axis;
    cosine_3 = cosine_2;
    sine_3 = sine_2;
    let _e136: vec3<f32> = value_3;
    let _e137: f32 = cosine_3;
    let _e139: vec3<f32> = axis_1;
    let _e140: vec3<f32> = value_3;
    let _e142: f32 = sine_3;
    let _e145: vec3<f32> = axis_1;
    let _e146: vec3<f32> = axis_1;
    let _e147: vec3<f32> = value_3;
    let _e151: f32 = cosine_3;
    return (((_e136 * _e137) + (cross(_e139, _e140) * _e142)) + ((_e145 * dot(_e146, _e147)) * (1f - _e151)));
}

fn terrainProjectRotateAroundAxis(value_4: vec3<f32>, axis_2: vec3<f32>, angle_1: f32) -> vec3<f32> {
    var value_5: vec3<f32>;
    var axis_3: vec3<f32>;
    var angle_2: f32;

    value_5 = value_4;
    axis_3 = axis_2;
    angle_2 = angle_1;
    let _e134: vec3<f32> = value_5;
    let _e135: vec3<f32> = axis_3;
    let _e136: f32 = angle_2;
    let _e138: f32 = angle_2;
    let _e140: vec3<f32> = terrainProjectRotateAroundAxisSinCos(_e134, _e135, cos(_e136), sin(_e138));
    return _e140;
}

fn terrainProjectSmoothSignedLimit(value_6: f32, maximumMagnitude: f32) -> f32 {
    var value_7: f32;
    var maximumMagnitude_1: f32;
    var magnitude: f32;
    var safeMaximum: f32;
    var saturation: f32;
    var limitedMagnitude: f32;
    var local_1: f32;

    value_7 = value_6;
    maximumMagnitude_1 = maximumMagnitude;
    let _e132: f32 = value_7;
    magnitude = abs(_e132);
    let _e135: f32 = maximumMagnitude_1;
    safeMaximum = max(_e135, 0.0001f);
    let _e139: f32 = safeMaximum;
    let _e142: f32 = safeMaximum;
    let _e143: f32 = magnitude;
    saturation = smoothstep((_e139 * 0.6f), _e142, _e143);
    let _e146: f32 = magnitude;
    let _e147: f32 = safeMaximum;
    let _e148: f32 = saturation;
    let _e150: f32 = safeMaximum;
    limitedMagnitude = min(mix(_e146, _e147, _e148), _e150);
    let _e153: f32 = value_7;
    if (_e153 < 0f) {
        let _e156: f32 = limitedMagnitude;
        local_1 = -(_e156);
    } else {
        let _e158: f32 = limitedMagnitude;
        local_1 = _e158;
    }
    let _e160: f32 = local_1;
    return _e160;
}

fn terrainProjectCompliantSignedTravel(value_8: f32, maximumMagnitude_2: f32) -> f32 {
    var value_9: f32;
    var maximumMagnitude_3: f32;
    var safeMaximum_1: f32;

    value_9 = value_8;
    maximumMagnitude_3 = maximumMagnitude_2;
    let _e132: f32 = maximumMagnitude_3;
    safeMaximum_1 = max(_e132, 0f);
    let _e136: f32 = value_9;
    let _e137: f32 = safeMaximum_1;
    let _e139: f32 = safeMaximum_1;
    let _e140: f32 = safeMaximum_1;
    let _e142: f32 = value_9;
    let _e143: f32 = value_9;
    return ((_e136 * _e137) * inverseSqrt((((_e139 * _e140) + (_e142 * _e143)) + 0.00000001f)));
}

fn terrainProjectSampleWind(positionWS_2: vec3<f32>, originWS_6: vec3<f32>, attributes_22: Attributes, windLod: f32, loadProfile: TerrainProjectWindReceiverProfile, microProfile: TerrainProjectWindReceiverProfile) -> TerrainProjectWindSample {
    var positionWS_3: vec3<f32>;
    var originWS_7: vec3<f32>;
    var attributes_23: Attributes;
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
    var mesoWeight: f32;
    var flutterFrequencyDecorrelator: f32;
    var flutterFrequencyHz: f32;
    var groundVerticalPhase: f32 = 0f;
    var receiverClockSeconds: f32;
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
    attributes_23 = attributes_22;
    windLod_1 = windLod;
    loadProfile_1 = loadProfile;
    microProfile_1 = microProfile;
    let _e141: vec3<f32> = originWS_7;
    let _e142: Attributes = attributes_23;
    let _e143: f32 = terrainProjectWindReceiverPhase(_e141, _e142);
    phase_1 = _e143;
    let _e145: vec4<f32> = global.scene_WindSpectrumParams;
    macroInverseScale = _e145.x;
    let _e148: vec4<f32> = global.scene_WindFieldParams;
    if (_e148.x > 0.0001f) {
        let _e152: vec3<f32> = global.scene_WindVelocity;
        local_2 = normalize(_e152.xz);
    } else {
        local_2 = vec2<f32>(1f, 0f);
    }
    let _e159: vec2<f32> = local_2;
    horizontalDirection = _e159;
    let _e163: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e166: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e168: f32 = naturalFrequencyScale;
    boundedResponseLag = min(_e163.responseLagSeconds, (0.5f / max((_e166.naturalFrequencyHz * _e168), 0.001f)));
    let _e175: vec3<f32> = positionWS_3;
    spectrumPosition = _e175.xz;
    let _e178: vec2<f32> = spectrumPosition;
    let _e179: f32 = macroInverseScale;
    let _e181: vec3<f32> = global.scene_WindSpectrumAdvectionOffset;
    let _e183: f32 = macroInverseScale;
    currentSpectrumUv = ((_e178 * _e179) - ((_e181.xz * _e183) * 0.12f));
    let _e189: vec2<f32> = currentSpectrumUv;
    let _e191: vec4<f32> = textureSampleLevel(gs_wgpu_tex_scene_WindSpectrumTexture, gs_wgpu_samp_scene_WindSpectrumTexture, _e189, 0f);
    currentPackedSpectrum = _e191;
    let _e193: vec4<f32> = currentPackedSpectrum;
    packedSpectrum = _e193;
    result.elasticMemory = 0f;
    result.groundResponseVelocity = 0f;
    let _e199: vec4<f32> = packedSpectrum;
    spectrum = ((_e199 * 2f) - vec4(1f));
    let _e207: vec4<f32> = spectrum;
    result.macro_ = clamp(_e207.x, -1f, 1f);
    let _e214: TerrainProjectWindSample = result;
    result.groundWave = _e214.macro_;
    result.groundDetail = 0f;
    result.exposure = 1f;
    let _e235: vec4<f32> = global.scene_WindFieldParams;
    result.turbulence = _e235.z;
    result.localFieldWeight = 0f;
    let _e239: vec4<f32> = global.scene_WindFieldParams;
    presentedReferenceGust = _e239.y;
    let _e245: f32 = windLod_1;
    mesoWeight = (1f - smoothstep(1.45f, 2f, _e245));
    let _e252: f32 = windLod_1;
    microLodWeight = (1f - smoothstep(0.45f, 1f, _e252));
    let _e256: vec4<f32> = spectrum;
    let _e262: f32 = mesoWeight;
    result.meso = (clamp(_e256.y, -1f, 1f) * _e262);
    result.micro = 0f;
    let _e266: f32 = microLodWeight;
    if (_e266 > 0f) {
        {
            let _e269: f32 = phase_1;
            flutterFrequencyDecorrelator = ((_e269 * 2f) - 1f);
            let _e275: f32 = flutterFrequencyDecorrelator;
            let _e276: TerrainProjectWindReceiverProfile = microProfile_1;
            let _e277: f32 = terrainProjectWindFlutterFrequencyHz(_e275, _e276);
            flutterFrequencyHz = _e277;
            let _e281: vec4<f32> = global.scene_WindFieldParams;
            receiverClockSeconds = _e281.w;
            let _e284: f32 = receiverClockSeconds;
            let _e285: f32 = flutterFrequencyHz;
            let _e289: f32 = phase_1;
            let _e293: f32 = groundVerticalPhase;
            periodicFlutterSignal = sin(((((_e284 * _e285) * 6.2831855f) + (_e289 * 6.2831855f)) + _e293));
            let _e296: vec4<f32> = spectrum;
            microSpectrumSignal = _e296.z;
            let _e299: f32 = microSpectrumSignal;
            let _e302: f32 = periodicFlutterSignal;
            let _e310: f32 = microLodWeight;
            result.micro = (clamp(((_e299 * 0.65f) + (_e302 * 0.35f)), -1f, 1f) * _e310);
        }
    }
    let _e312: vec3<f32> = positionWS_3;
    let _e314: vec3<f32> = originWS_7;
    heightAboveRoot = max((_e312.y - _e314.y), 0f);
    let _e320: vec3<f32> = global.scene_WindLayerMultipliers;
    let _e322: vec3<f32> = global.scene_WindLayerMultipliers;
    let _e326: f32 = heightAboveRoot;
    layer = mix(_e320.x, _e322.y, smoothstep(0.8f, 4f, _e326));
    let _e330: vec3<f32> = global.scene_WindVelocity;
    let _e331: f32 = layer;
    baseVelocity = (_e330 * _e331);
    let _e334: vec3<f32> = baseVelocity;
    velocity = _e334;
    let _e336: vec3<f32> = baseVelocity;
    steadyVelocity = _e336;
    let _e339: TerrainProjectWindSample = result;
    referenceGustWeight = (1f - _e339.localFieldWeight);
    let _e345: vec3<f32> = velocity;
    let _e346: vec3<f32> = baseVelocity;
    let _e347: f32 = presentedReferenceGust;
    let _e348: f32 = referenceGustWeight;
    let _e350: f32 = gustWeight;
    let _e352: TerrainProjectWindSample = result;
    let _e355: TerrainProjectWindSample = result;
    velocity = (_e345 + (_e346 * (((_e347 * _e348) * _e350) + (_e352.macro_ * (0.08f + (_e355.turbulence * 0.12f))))));
    let _e364: vec3<f32> = velocity;
    horizontalSpeed = length(_e364.xz);
    let _e368: f32 = horizontalSpeed;
    if (_e368 > 0.0001f) {
        {
            let _e371: vec3<f32> = velocity;
            let _e373: f32 = horizontalSpeed;
            direction = (_e371.xz / vec2(_e373));
            let _e377: vec3<f32> = velocity;
            let _e379: vec3<f32> = velocity;
            let _e381: vec2<f32> = direction;
            let _e384: vec2<f32> = direction;
            let _e387: f32 = horizontalSpeed;
            let _e389: TerrainProjectWindSample = result;
            let _e392: TerrainProjectWindSample = result;
            let _e395: vec4<f32> = global.scene_WindSpectrumParams;
            let _e398: vec2<f32> = (_e379.xz + ((((vec2<f32>(-(_e381.y), _e384.x) * _e387) * _e389.meso) * _e392.turbulence) * _e395.w));
            velocity.x = _e398.x;
            velocity.z = _e398.y;
        }
    }
    let _e403: vec3<f32> = velocity;
    let _e404: TerrainProjectWindSample = result;
    velocity = (_e403 * _e404.exposure);
    let _e407: vec3<f32> = velocity;
    let _e409: vec3<f32> = velocity;
    let _e411: vec2<f32> = localVelocity;
    let _e412: vec2<f32> = (_e409.xz + _e411);
    velocity.x = _e412.x;
    velocity.z = _e412.y;
    let _e417: vec3<f32> = steadyVelocity;
    let _e418: TerrainProjectWindSample = result;
    steadyVelocity = (_e417 * _e418.exposure);
    let _e422: vec3<f32> = velocity;
    result.velocityWS = _e422;
    let _e424: vec3<f32> = steadyVelocity;
    result.steadyHorizontalSpeed = length(_e424.xz);
    let _e427: TerrainProjectWindSample = result;
    return _e427;
}

fn terrainProjectCompliantBend(requestedAngle: f32, maximumAngle: f32) -> f32 {
    var requestedAngle_1: f32;
    var maximumAngle_1: f32;
    var safeMaximum_2: f32;

    requestedAngle_1 = requestedAngle;
    maximumAngle_1 = maximumAngle;
    let _e132: f32 = maximumAngle_1;
    safeMaximum_2 = max(_e132, 0.0001f);
    let _e136: f32 = safeMaximum_2;
    let _e138: f32 = requestedAngle_1;
    let _e142: f32 = safeMaximum_2;
    return (_e136 * (1f - exp((-(max(_e138, 0f)) / _e142))));
}

fn terrainProjectWindReceiverSpeed(wind: TerrainProjectWindSample, profile_7: TerrainProjectWindReceiverProfile) -> f32 {
    var wind_1: TerrainProjectWindSample;
    var profile_8: TerrainProjectWindReceiverProfile;

    wind_1 = wind;
    profile_8 = profile_7;
    let _e133: TerrainProjectWindSample = wind_1;
    let _e135: TerrainProjectWindSample = wind_1;
    let _e139: TerrainProjectWindReceiverProfile = profile_8;
    let _e143: TerrainProjectWindReceiverProfile = profile_8;
    return (max(0f, mix(_e133.steadyHorizontalSpeed, length(_e135.velocityWS.xz), _e139.dynamicGain)) * _e143.bendGain);
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
    let _e137: TerrainProjectWindSample = wind_3;
    let _e139: TerrainProjectWindSample = wind_3;
    let _e143: TerrainProjectWindReceiverProfile = profile_10;
    physicalSpeed = max(0f, mix(_e137.steadyHorizontalSpeed, length(_e139.velocityWS.xz), _e143.dynamicGain));
    let _e148: TerrainProjectWindSample = wind_3;
    let _e149: TerrainProjectWindReceiverProfile = profile_10;
    let _e150: f32 = terrainProjectWindReceiverSpeed(_e148, _e149);
    receiverSpeed = _e150;
    let _e152: f32 = physicalSpeed;
    normalizedSpeed = (_e152 / 8f);
    let _e156: f32 = receiverSpeed;
    let _e157: f32 = normalizedSpeed;
    quadraticEquivalentSpeed = (_e156 * max(_e157, 0f));
    let _e171: f32 = normalizedSpeed;
    let _e176: f32 = reconfigurationCoefficient;
    let _e181: f32 = nonlinearBlend;
    reconfiguration = pow((1f + (max((_e171 - 0.65f), 0f) * _e176)), (-0.67f * _e181));
    let _e185: f32 = receiverSpeed;
    let _e186: f32 = quadraticEquivalentSpeed;
    let _e187: f32 = nonlinearBlend;
    let _e189: f32 = reconfiguration;
    let _e191: f32 = grassLodgingGain;
    aerodynamicSpeed = ((mix(_e185, _e186, _e187) * _e189) * _e191);
    let _e194: f32 = aerodynamicSpeed;
    let _e195: f32 = global.material_WindForce;
    let _e199: f32 = flow_1;
    let _e201: f32 = structuralWeight_1;
    let _e203: f32 = retainedEnergyAngle;
    let _e204: f32 = structuralWeight_1;
    let _e207: TerrainProjectWindReceiverProfile = profile_10;
    let _e209: f32 = terrainProjectCompliantBend((((((_e194 * _e195) * 0.045f) * _e199) * _e201) + (_e203 * _e204)), _e207.maximumBendRadians);
    return _e209;
}

fn terrainProjectApplyVegetationWind(positionWS_4: vec3<f32>, originWS_8: vec3<f32>, attributes_24: Attributes, normalWS: ptr<function, vec3<f32>>, tangentWS: ptr<function, vec3<f32>>, windShadingResponse: ptr<function, f32>, groundWindDiagnostics: ptr<function, vec3<f32>>, groundWindCarrierNormalWS: ptr<function, vec3<f32>>) -> vec3<f32> {
    var positionWS_5: vec3<f32>;
    var originWS_9: vec3<f32>;
    var attributes_25: Attributes;
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
    attributes_25 = attributes_24;
    (*groundWindDiagnostics) = vec3(0f);
    (*groundWindCarrierNormalWS) = vec3<f32>(0f, 1f, 0f);
    let _e145: vec3<f32> = global.camera_Position;
    let _e146: vec3<f32> = originWS_9;
    cameraOffsetFromOrigin = (_e145 - _e146);
    let _e149: vec3<f32> = cameraOffsetFromOrigin;
    let _e150: vec3<f32> = cameraOffsetFromOrigin;
    cameraDistanceSquared = dot(_e149, _e150);
    let _e153: f32 = cameraDistanceSquared;
    cameraDistanceToOrigin = sqrt(_e153);
    let _e156: vec3<f32> = positionWS_5;
    windPositionWS = _e156;
    let _e158: vec3<f32> = (*normalWS);
    windNormalWS = _e158;
    let _e164: mat4x4<f32> = global.camera_ViewMat;
    let _e165: vec3<f32> = positionWS_5;
    eyeDepth = -((_e164 * vec4<f32>(_e165.x, _e165.y, _e165.z, 1f)).z);
    let _e175: f32 = eyeDepth;
    let _e176: vec4<f32> = global.camera_ProjectionParams;
    let _e179: f32 = global.material_GrassFadeDistance;
    cameraDepthFade = (((_e175 - _e176.y) - _e179) / 5f);
    let _e185: f32 = cameraDepthFade;
    let _e187: f32 = cameraDepthFade;
    let _e188: f32 = global.material_GrassFalloff;
    grassFade = clamp(mix((1f - _e185), _e187, (_e188 * 0.5f)), 0f, 1f);
    let _e196: f32 = grassFade;
    let _e197: f32 = global.material_GrassDistanceFadeEnable;
    grassFadeMask = mix(1f, _e196, _e197);
    let _e200: vec3<f32> = (*normalWS);
    let _e201: vec3<f32> = windNormalWS;
    let _e202: f32 = grassFadeMask;
    (*normalWS) = normalize(mix(_e200, _e201, vec3(_e202)));
    let _e206: f32 = grassFadeMask;
    (*windShadingResponse) = _e206;
    let _e207: vec3<f32> = originWS_9;
    let _e208: vec3<f32> = windPositionWS;
    let _e209: f32 = grassFadeMask;
    return mix(_e207, _e208, vec3(_e209));
}

fn terrainProjectVegetationPositionWS(positionOS: vec4<f32>, attributes_26: Attributes, proceduralTreeWindOriginOS: vec3<f32>, normalWS_1: ptr<function, vec3<f32>>, tangentWS_1: ptr<function, vec3<f32>>, windShadingResponse_1: ptr<function, f32>, groundWindDiagnostics_1: ptr<function, vec3<f32>>, groundWindCarrierNormalWS_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var positionOS_1: vec4<f32>;
    var attributes_27: Attributes;
    var proceduralTreeWindOriginOS_1: vec3<f32>;
    var detailPositionOS: vec3<f32>;
    var detailOriginOS: vec3<f32>;
    var homogeneousPositionWS: vec4<f32>;
    var positionWS_6: vec3<f32>;
    var homogeneousOriginWS: vec4<f32>;
    var originWS_10: vec3<f32>;

    positionOS_1 = positionOS;
    attributes_27 = attributes_26;
    proceduralTreeWindOriginOS_1 = proceduralTreeWindOriginOS;
    let _e139: vec4<f32> = positionOS_1;
    let _e141: Attributes = attributes_27;
    let _e142: vec3<f32> = terrainProjectDetailPositionOS(_e139.xyz, _e141);
    detailPositionOS = _e142;
    let _e144: Attributes = attributes_27;
    let _e145: vec3<f32> = terrainProjectDetailOriginOS(_e144);
    detailOriginOS = _e145;
    let _e147: mat4x4<f32> = global.renderer_ModelMat;
    let _e148: vec3<f32> = detailPositionOS;
    homogeneousPositionWS = (_e147 * vec4<f32>(_e148.x, _e148.y, _e148.z, 1f));
    let _e156: vec4<f32> = homogeneousPositionWS;
    let _e158: vec4<f32> = homogeneousPositionWS;
    positionWS_6 = (_e156.xyz / vec3(_e158.w));
    let _e163: mat4x4<f32> = global.renderer_ModelMat;
    let _e164: vec3<f32> = detailOriginOS;
    homogeneousOriginWS = (_e163 * vec4<f32>(_e164.x, _e164.y, _e164.z, 1f));
    let _e172: vec4<f32> = homogeneousOriginWS;
    let _e174: vec4<f32> = homogeneousOriginWS;
    originWS_10 = (_e172.xyz / vec3(_e174.w));
    let _e179: vec3<f32> = positionWS_6;
    let _e180: vec3<f32> = originWS_10;
    let _e181: Attributes = attributes_27;
    let _e192: vec3<f32> = terrainProjectApplyVegetationWind(_e179, _e180, _e181, normalWS_1, tangentWS_1, windShadingResponse_1, groundWindDiagnostics_1, groundWindCarrierNormalWS_1);
    return _e192;
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn applyTerrainProjectShadowBias(positionWS_7: vec3<f32>, normalWS_2: vec3<f32>) -> vec3<f32> {
    var positionWS_8: vec3<f32>;
    var normalWS_3: vec3<f32>;
    var inverseNdotL: f32;

    positionWS_8 = positionWS_7;
    normalWS_3 = normalWS_2;
    let _e132: vec3<f32> = positionWS_8;
    let _e133: vec3<f32> = global.scene_LightDirection;
    let _e134: vec2<f32> = global.scene_ShadowBias;
    positionWS_8 = (_e132 - (_e133 * _e134.x));
    let _e139: vec3<f32> = global.scene_LightDirection;
    let _e141: vec3<f32> = normalWS_3;
    inverseNdotL = (1f - clamp(dot(-(_e139), _e141), 0f, 1f));
    let _e148: vec3<f32> = positionWS_8;
    let _e149: vec3<f32> = normalWS_3;
    let _e150: f32 = inverseNdotL;
    let _e151: vec2<f32> = global.scene_ShadowBias;
    return (_e148 + (_e149 * (_e150 * _e151.y)));
}

fn terrainProjectShadowClipPosition(positionWS_9: vec3<f32>) -> vec4<f32> {
    var positionWS_10: vec3<f32>;
    var positionCS: vec4<f32>;

    positionWS_10 = positionWS_9;
    let _e130: mat4x4<f32> = global.camera_VPMat;
    let _e131: vec3<f32> = positionWS_10;
    positionCS = (_e130 * vec4<f32>(_e131.x, _e131.y, _e131.z, 1f));
    let _e140: vec4<f32> = positionCS;
    positionCS.z = max(_e140.z, -1f);
    let _e145: vec4<f32> = positionCS;
    return _e145;
}

fn terrainProjectBuildVegetationDepthShadowVaryings(attributes_28: Attributes) -> Varyings {
    var attributes_29: Attributes;
    var varyings: Varyings;
    var positionOS_2: vec4<f32>;
    var normalOS: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var proceduralTreeWindOriginOS_2: vec3<f32> = vec3(0f);
    var normalWS_4: vec3<f32>;
    var tangentWS_2: vec3<f32> = vec3(0f);
    var windShadingResponse_2: f32;
    var groundWindDiagnostics_2: vec3<f32>;
    var groundWindCarrierNormalWS_2: vec3<f32>;
    var positionWS_11: vec3<f32>;

    attributes_29 = attributes_28;
    let _e131: Attributes = attributes_29;
    positionOS_2 = vec4<f32>(_e131.POSITION.x, _e131.POSITION.y, _e131.POSITION.z, 1f);
    let _e147: vec3<f32> = normalOS;
    let _e152: f32 = global.material_LightingFlatness;
    normalOS = normalize(mix(_e147, vec3<f32>(0f, 1f, 0f), vec3(_e152)));
    let _e156: vec3<f32> = normalOS;
    let _e157: Attributes = attributes_29;
    let _e158: vec3<f32> = terrainProjectDetailNormalOS(_e156, _e157);
    normalOS = _e158;
    varyings.uv = vec2(0f);
    let _e170: mat4x4<f32> = global.renderer_NormalMat;
    let _e180: vec3<f32> = normalOS;
    normalWS_4 = normalize((mat3x3<f32>(_e170[0].xyz, _e170[1].xyz, _e170[2].xyz) * _e180));
    let _e183: vec4<f32> = positionOS_2;
    let _e184: Attributes = attributes_29;
    let _e185: vec3<f32> = proceduralTreeWindOriginOS_2;
    let _e196: vec3<f32> = terrainProjectVegetationPositionWS(_e183, _e184, _e185, (&normalWS_4), (&tangentWS_2), (&windShadingResponse_2), (&groundWindDiagnostics_2), (&groundWindCarrierNormalWS_2));
    positionWS_11 = _e196;
    let _e198: vec3<f32> = positionWS_11;
    let _e199: vec3<f32> = normalWS_4;
    let _e200: vec3<f32> = applyTerrainProjectShadowBias(_e198, _e199);
    let _e201: vec4<f32> = terrainProjectShadowClipPosition(_e200);
    gl_Position = _e201;
    let _e202: Varyings = varyings;
    return _e202;
}

fn VegetationShadowVertex(attributes_30: Attributes) -> Varyings {
    var attributes_31: Attributes;

    attributes_31 = attributes_30;
    let _e131: Attributes = attributes_31;
    let _e132: Varyings = terrainProjectBuildVegetationDepthShadowVaryings(_e131);
    return _e132;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e129: Attributes = read_Attributes();
    input_attributes = _e129;
    let _e131: Attributes = input_attributes;
    let _e132: Varyings = VegetationShadowVertex(_e131);
    write_Varyings(_e132);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e131: vec4<f32> = gl_Position;
    let _e133: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e131.z + _e133.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e139: vec2<f32> = uv;
    let _e141: vec4<f32> = gl_Position;
    return VertexOutput(_e139, _e141);
}
