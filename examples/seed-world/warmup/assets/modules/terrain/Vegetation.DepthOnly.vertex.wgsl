diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ProjectionParams: vec4<f32>,
    camera_ViewMat: mat4x4<f32>,
    camera_VPMat: mat4x4<f32>,
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
    material_WindLeafMotionParams: vec4<f32>,
    material_WindSpeciesParams: vec4<f32>,
    material_WindTrunkModeParams: vec4<f32>,
    material_WindTreePrimaryParams: vec4<f32>,
    material_WindTreeComplianceGain: f32,
    material_WindInputWeights: vec4<f32>,
    material_WindStructureWeights: vec4<f32>,
    material_WindAerodynamicWeights: vec4<f32>,
    material_WindFoliageWeights: vec4<f32>,
    material_WindFlutterTuning: vec4<f32>,
    material_WindLeafBladeParams: vec4<f32>,
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
    material_AlphaCutoff: f32,
    material_LeafGlancingAngleCut: f32,
}

struct gs_Auto_1_ {
    camera_Position: vec3<f32>,
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
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
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

    let _e129: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e129;
    let _e130: Attributes = interface_value;
    return _e130;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e130: Varyings = interface_value_2;
    uv = _e130.uv;
    return;
}

fn terrainProjectRotateDetailY(value: vec3<f32>, radians: f32) -> vec3<f32> {
    var value_1: vec3<f32>;
    var radians_1: f32;
    var sine: f32;
    var cosine: f32;

    value_1 = value;
    radians_1 = radians;
    let _e132: f32 = radians_1;
    sine = sin(_e132);
    let _e135: f32 = radians_1;
    cosine = cos(_e135);
    let _e138: f32 = cosine;
    let _e139: vec3<f32> = value_1;
    let _e142: f32 = sine;
    let _e143: vec3<f32> = value_1;
    let _e147: vec3<f32> = value_1;
    let _e149: f32 = sine;
    let _e151: vec3<f32> = value_1;
    let _e154: f32 = cosine;
    let _e155: vec3<f32> = value_1;
    return vec3<f32>(((_e138 * _e139.x) + (_e142 * _e143.z)), _e147.y, ((-(_e149) * _e151.x) + (_e154 * _e155.z)));
}

fn terrainProjectDetailPositionOS(sourcePositionOS: vec3<f32>, attributes: Attributes) -> vec3<f32> {
    var sourcePositionOS_1: vec3<f32>;
    var attributes_1: Attributes;

    sourcePositionOS_1 = sourcePositionOS;
    attributes_1 = attributes;
    let _e132: vec3<f32> = sourcePositionOS_1;
    return _e132;
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
    let _e132: vec3<f32> = sourceNormalOS_1;
    return _e132;
}

fn terrainProjectDetailTangentOS(sourceTangentOS: vec3<f32>, attributes_6: Attributes) -> vec3<f32> {
    var sourceTangentOS_1: vec3<f32>;
    var attributes_7: Attributes;

    sourceTangentOS_1 = sourceTangentOS;
    attributes_7 = attributes_6;
    let _e132: vec3<f32> = sourceTangentOS_1;
    return _e132;
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
    let _e140: vec2<f32> = fromDirection_1;
    fromLength = length(_e140);
    let _e143: vec2<f32> = toDirection_1;
    toLength = length(_e143);
    let _e146: f32 = fromLength;
    if (_e146 <= 0.0001f) {
        let _e149: f32 = toLength;
        if (_e149 > 0.0001f) {
            let _e152: vec2<f32> = toDirection_1;
            let _e153: f32 = toLength;
            local = (_e152 / vec2(_e153));
        } else {
            local = vec2<f32>(1f, 0f);
        }
        let _e160: vec2<f32> = local;
        return _e160;
    }
    let _e161: f32 = toLength;
    if (_e161 <= 0.0001f) {
        let _e164: vec2<f32> = fromDirection_1;
        let _e165: f32 = fromLength;
        return (_e164 / vec2(_e165));
    }
    let _e168: vec2<f32> = fromDirection_1;
    let _e169: f32 = fromLength;
    fromUnit = (_e168 / vec2(_e169));
    let _e173: vec2<f32> = toDirection_1;
    let _e174: f32 = toLength;
    toUnit = (_e173 / vec2(_e174));
    let _e178: vec2<f32> = fromUnit;
    let _e180: vec2<f32> = toUnit;
    let _e183: vec2<f32> = fromUnit;
    let _e185: vec2<f32> = toUnit;
    crossAngle = ((_e178.x * _e180.y) - (_e183.y * _e185.x));
    let _e190: vec2<f32> = fromUnit;
    let _e191: vec2<f32> = toUnit;
    dotAngle = clamp(dot(_e190, _e191), -1f, 1f);
    let _e198: f32 = crossAngle;
    let _e199: f32 = dotAngle;
    let _e201: f32 = weight_1;
    angle = (atan2(_e198, _e199) * clamp(_e201, 0f, 1f));
    let _e207: f32 = angle;
    cosine_1 = cos(_e207);
    let _e210: f32 = angle;
    sine_1 = sin(_e210);
    let _e213: vec2<f32> = fromUnit;
    let _e215: f32 = cosine_1;
    let _e217: vec2<f32> = fromUnit;
    let _e219: f32 = sine_1;
    let _e222: vec2<f32> = fromUnit;
    let _e224: f32 = sine_1;
    let _e226: vec2<f32> = fromUnit;
    let _e228: f32 = cosine_1;
    return vec2<f32>(((_e213.x * _e215) - (_e217.y * _e219)), ((_e222.x * _e224) + (_e226.y * _e228)));
}

fn terrainProjectWindReceiverProfile() -> TerrainProjectWindReceiverProfile {
    var profile: TerrainProjectWindReceiverProfile;
    var response0_: vec4<f32>;
    var response1_: vec4<f32>;
    var response2_: vec4<f32>;

    let _e135: vec4<f32> = global.scene_WindGrassProfile0_;
    response0_ = _e135;
    let _e137: vec4<f32> = global.scene_WindGrassProfile1_;
    response1_ = _e137;
    let _e139: vec4<f32> = global.scene_WindGrassProfile2_;
    response2_ = _e139;
    let _e142: vec4<f32> = response0_;
    profile.bendGain = _e142.x;
    let _e145: vec4<f32> = response0_;
    profile.dynamicGain = _e145.y;
    let _e148: vec4<f32> = response0_;
    profile.macroGain = _e148.z;
    let _e151: vec4<f32> = response0_;
    profile.mesoGain = _e151.w;
    let _e154: vec4<f32> = response1_;
    profile.microGain = _e154.x;
    let _e157: vec4<f32> = response1_;
    profile.responseLagSeconds = _e157.y;
    let _e160: vec4<f32> = response1_;
    profile.maximumBendRadians = _e160.z;
    let _e163: vec4<f32> = response1_;
    profile.flutterWeight = _e163.w;
    let _e166: vec4<f32> = response2_;
    profile.flutterFrequencyMinHz = _e166.x;
    let _e169: vec4<f32> = response2_;
    profile.flutterFrequencyMaxHz = _e169.y;
    let _e172: vec4<f32> = response2_;
    profile.highSpeedMicroScale = _e172.z;
    let _e175: vec4<f32> = response2_;
    profile.naturalFrequencyHz = _e175.w;
    let _e177: TerrainProjectWindReceiverProfile = profile;
    return _e177;
}

fn terrainProjectWindAnimationLod(distanceToCamera: f32) -> f32 {
    var distanceToCamera_1: f32;

    distanceToCamera_1 = distanceToCamera;
    let _e138: f32 = distanceToCamera_1;
    let _e142: f32 = distanceToCamera_1;
    return (smoothstep(36f, 72f, _e138) + smoothstep(120f, 220f, _e142));
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
    let _e136: f32 = global.material_UVBaseLock;
    if (_e136 <= 0f) {
        return 1f;
    }
    let _e143: f32 = baseHeight;
    let _e146: f32 = global.material_UVBaseLock;
    return mix(1f, pow(_e143, 1.5f), _e146);
}

fn terrainProjectVegetationStructuralWeight(positionWS: vec3<f32>, originWS: vec3<f32>, attributes_12: Attributes) -> f32 {
    var positionWS_1: vec3<f32>;
    var originWS_1: vec3<f32>;
    var attributes_13: Attributes;
    var authoredWeight: f32;

    positionWS_1 = positionWS;
    originWS_1 = originWS;
    attributes_13 = attributes_12;
    let _e140: Attributes = attributes_13;
    let _e141: f32 = terrainProjectVegetationVertexColorWeight(_e140);
    authoredWeight = _e141;
    let _e143: f32 = authoredWeight;
    let _e144: Attributes = attributes_13;
    let _e145: f32 = terrainProjectVegetationBaseLockWeight(_e144);
    return (_e143 * _e145);
}

fn terrainProjectTreePhase(originWS_2: vec3<f32>) -> f32 {
    var originWS_3: vec3<f32>;

    originWS_3 = originWS_2;
    let _e136: vec3<f32> = originWS_3;
    return fract((sin(dot(_e136.xz, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
}

fn terrainProjectWindReceiverPhase(originWS_4: vec3<f32>, attributes_14: Attributes) -> f32 {
    var originWS_5: vec3<f32>;
    var attributes_15: Attributes;
    var phase: f32;

    originWS_5 = originWS_4;
    attributes_15 = attributes_14;
    let _e138: vec3<f32> = originWS_5;
    let _e139: f32 = terrainProjectTreePhase(_e138);
    phase = _e139;
    let _e141: f32 = phase;
    return _e141;
}

fn terrainProjectVegetationFlutterWeight(attributes_16: Attributes, profile_1: TerrainProjectWindReceiverProfile) -> f32 {
    var attributes_17: Attributes;
    var profile_2: TerrainProjectWindReceiverProfile;

    attributes_17 = attributes_16;
    profile_2 = profile_1;
    let _e138: TerrainProjectWindReceiverProfile = profile_2;
    return _e138.flutterWeight;
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
    let _e138: f32 = decorrelation_1;
    variation = clamp(abs(_e138), 0f, 1f);
    let _e144: TerrainProjectWindReceiverProfile = profile_4;
    let _e146: TerrainProjectWindReceiverProfile = profile_4;
    let _e148: f32 = variation;
    return mix(_e144.flutterFrequencyMinHz, _e146.flutterFrequencyMaxHz, _e148);
}

fn terrainProjectWindMicroEnvelope(relativeHorizontalSpeed: f32, profile_5: TerrainProjectWindReceiverProfile) -> f32 {
    var relativeHorizontalSpeed_1: f32;
    var profile_6: TerrainProjectWindReceiverProfile;

    relativeHorizontalSpeed_1 = relativeHorizontalSpeed;
    profile_6 = profile_5;
    let _e139: TerrainProjectWindReceiverProfile = profile_6;
    let _e143: f32 = relativeHorizontalSpeed_1;
    return mix(1f, _e139.highSpeedMicroScale, smoothstep(3f, 8f, _e143));
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
    let _e142: vec3<f32> = value_3;
    let _e143: f32 = cosine_3;
    let _e145: vec3<f32> = axis_1;
    let _e146: vec3<f32> = value_3;
    let _e148: f32 = sine_3;
    let _e151: vec3<f32> = axis_1;
    let _e152: vec3<f32> = axis_1;
    let _e153: vec3<f32> = value_3;
    let _e157: f32 = cosine_3;
    return (((_e142 * _e143) + (cross(_e145, _e146) * _e148)) + ((_e151 * dot(_e152, _e153)) * (1f - _e157)));
}

fn terrainProjectRotateAroundAxis(value_4: vec3<f32>, axis_2: vec3<f32>, angle_1: f32) -> vec3<f32> {
    var value_5: vec3<f32>;
    var axis_3: vec3<f32>;
    var angle_2: f32;

    value_5 = value_4;
    axis_3 = axis_2;
    angle_2 = angle_1;
    let _e140: vec3<f32> = value_5;
    let _e141: vec3<f32> = axis_3;
    let _e142: f32 = angle_2;
    let _e144: f32 = angle_2;
    let _e146: vec3<f32> = terrainProjectRotateAroundAxisSinCos(_e140, _e141, cos(_e142), sin(_e144));
    return _e146;
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
    let _e138: f32 = value_7;
    magnitude = abs(_e138);
    let _e141: f32 = maximumMagnitude_1;
    safeMaximum = max(_e141, 0.0001f);
    let _e145: f32 = safeMaximum;
    let _e148: f32 = safeMaximum;
    let _e149: f32 = magnitude;
    saturation = smoothstep((_e145 * 0.6f), _e148, _e149);
    let _e152: f32 = magnitude;
    let _e153: f32 = safeMaximum;
    let _e154: f32 = saturation;
    let _e156: f32 = safeMaximum;
    limitedMagnitude = min(mix(_e152, _e153, _e154), _e156);
    let _e159: f32 = value_7;
    if (_e159 < 0f) {
        let _e162: f32 = limitedMagnitude;
        local_1 = -(_e162);
    } else {
        let _e164: f32 = limitedMagnitude;
        local_1 = _e164;
    }
    let _e166: f32 = local_1;
    return _e166;
}

fn terrainProjectCompliantSignedTravel(value_8: f32, maximumMagnitude_2: f32) -> f32 {
    var value_9: f32;
    var maximumMagnitude_3: f32;
    var safeMaximum_1: f32;

    value_9 = value_8;
    maximumMagnitude_3 = maximumMagnitude_2;
    let _e138: f32 = maximumMagnitude_3;
    safeMaximum_1 = max(_e138, 0f);
    let _e142: f32 = value_9;
    let _e143: f32 = safeMaximum_1;
    let _e145: f32 = safeMaximum_1;
    let _e146: f32 = safeMaximum_1;
    let _e148: f32 = value_9;
    let _e149: f32 = value_9;
    return ((_e142 * _e143) * inverseSqrt((((_e145 * _e146) + (_e148 * _e149)) + 0.00000001f)));
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
    let _e147: vec3<f32> = originWS_7;
    let _e148: Attributes = attributes_23;
    let _e149: f32 = terrainProjectWindReceiverPhase(_e147, _e148);
    phase_1 = _e149;
    let _e151: vec4<f32> = global.scene_WindSpectrumParams;
    macroInverseScale = _e151.x;
    let _e154: vec4<f32> = global.scene_WindFieldParams;
    if (_e154.x > 0.0001f) {
        let _e158: vec3<f32> = global.scene_WindVelocity;
        local_2 = normalize(_e158.xz);
    } else {
        local_2 = vec2<f32>(1f, 0f);
    }
    let _e165: vec2<f32> = local_2;
    horizontalDirection = _e165;
    let _e169: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e172: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e174: f32 = naturalFrequencyScale;
    boundedResponseLag = min(_e169.responseLagSeconds, (0.5f / max((_e172.naturalFrequencyHz * _e174), 0.001f)));
    let _e181: vec3<f32> = positionWS_3;
    spectrumPosition = _e181.xz;
    let _e184: vec2<f32> = spectrumPosition;
    let _e185: f32 = macroInverseScale;
    let _e187: vec3<f32> = global.scene_WindSpectrumAdvectionOffset;
    let _e189: f32 = macroInverseScale;
    currentSpectrumUv = ((_e184 * _e185) - ((_e187.xz * _e189) * 0.12f));
    let _e195: vec2<f32> = currentSpectrumUv;
    let _e197: vec4<f32> = textureSampleLevel(gs_wgpu_tex_scene_WindSpectrumTexture, gs_wgpu_samp_scene_WindSpectrumTexture, _e195, 0f);
    currentPackedSpectrum = _e197;
    let _e199: vec4<f32> = currentPackedSpectrum;
    packedSpectrum = _e199;
    result.elasticMemory = 0f;
    result.groundResponseVelocity = 0f;
    let _e205: vec4<f32> = packedSpectrum;
    spectrum = ((_e205 * 2f) - vec4(1f));
    let _e213: vec4<f32> = spectrum;
    result.macro_ = clamp(_e213.x, -1f, 1f);
    let _e220: TerrainProjectWindSample = result;
    result.groundWave = _e220.macro_;
    result.groundDetail = 0f;
    result.exposure = 1f;
    let _e241: vec4<f32> = global.scene_WindFieldParams;
    result.turbulence = _e241.z;
    result.localFieldWeight = 0f;
    let _e245: vec4<f32> = global.scene_WindFieldParams;
    presentedReferenceGust = _e245.y;
    let _e251: f32 = windLod_1;
    mesoWeight = (1f - smoothstep(1.45f, 2f, _e251));
    let _e258: f32 = windLod_1;
    microLodWeight = (1f - smoothstep(0.45f, 1f, _e258));
    let _e262: vec4<f32> = spectrum;
    let _e268: f32 = mesoWeight;
    result.meso = (clamp(_e262.y, -1f, 1f) * _e268);
    result.micro = 0f;
    let _e272: f32 = microLodWeight;
    if (_e272 > 0f) {
        {
            let _e275: f32 = phase_1;
            flutterFrequencyDecorrelator = ((_e275 * 2f) - 1f);
            let _e281: f32 = flutterFrequencyDecorrelator;
            let _e282: TerrainProjectWindReceiverProfile = microProfile_1;
            let _e283: f32 = terrainProjectWindFlutterFrequencyHz(_e281, _e282);
            flutterFrequencyHz = _e283;
            let _e287: vec4<f32> = global.scene_WindFieldParams;
            receiverClockSeconds = _e287.w;
            let _e290: f32 = receiverClockSeconds;
            let _e291: f32 = flutterFrequencyHz;
            let _e295: f32 = phase_1;
            let _e299: f32 = groundVerticalPhase;
            periodicFlutterSignal = sin(((((_e290 * _e291) * 6.2831855f) + (_e295 * 6.2831855f)) + _e299));
            let _e302: vec4<f32> = spectrum;
            microSpectrumSignal = _e302.z;
            let _e305: f32 = microSpectrumSignal;
            let _e308: f32 = periodicFlutterSignal;
            let _e316: f32 = microLodWeight;
            result.micro = (clamp(((_e305 * 0.65f) + (_e308 * 0.35f)), -1f, 1f) * _e316);
        }
    }
    let _e318: vec3<f32> = positionWS_3;
    let _e320: vec3<f32> = originWS_7;
    heightAboveRoot = max((_e318.y - _e320.y), 0f);
    let _e326: vec3<f32> = global.scene_WindLayerMultipliers;
    let _e328: vec3<f32> = global.scene_WindLayerMultipliers;
    let _e332: f32 = heightAboveRoot;
    layer = mix(_e326.x, _e328.y, smoothstep(0.8f, 4f, _e332));
    let _e336: vec3<f32> = global.scene_WindVelocity;
    let _e337: f32 = layer;
    baseVelocity = (_e336 * _e337);
    let _e340: vec3<f32> = baseVelocity;
    velocity = _e340;
    let _e342: vec3<f32> = baseVelocity;
    steadyVelocity = _e342;
    let _e345: TerrainProjectWindSample = result;
    referenceGustWeight = (1f - _e345.localFieldWeight);
    let _e351: vec3<f32> = velocity;
    let _e352: vec3<f32> = baseVelocity;
    let _e353: f32 = presentedReferenceGust;
    let _e354: f32 = referenceGustWeight;
    let _e356: f32 = gustWeight;
    let _e358: TerrainProjectWindSample = result;
    let _e361: TerrainProjectWindSample = result;
    velocity = (_e351 + (_e352 * (((_e353 * _e354) * _e356) + (_e358.macro_ * (0.08f + (_e361.turbulence * 0.12f))))));
    let _e370: vec3<f32> = velocity;
    horizontalSpeed = length(_e370.xz);
    let _e374: f32 = horizontalSpeed;
    if (_e374 > 0.0001f) {
        {
            let _e377: vec3<f32> = velocity;
            let _e379: f32 = horizontalSpeed;
            direction = (_e377.xz / vec2(_e379));
            let _e383: vec3<f32> = velocity;
            let _e385: vec3<f32> = velocity;
            let _e387: vec2<f32> = direction;
            let _e390: vec2<f32> = direction;
            let _e393: f32 = horizontalSpeed;
            let _e395: TerrainProjectWindSample = result;
            let _e398: TerrainProjectWindSample = result;
            let _e401: vec4<f32> = global.scene_WindSpectrumParams;
            let _e404: vec2<f32> = (_e385.xz + ((((vec2<f32>(-(_e387.y), _e390.x) * _e393) * _e395.meso) * _e398.turbulence) * _e401.w));
            velocity.x = _e404.x;
            velocity.z = _e404.y;
        }
    }
    let _e409: vec3<f32> = velocity;
    let _e410: TerrainProjectWindSample = result;
    velocity = (_e409 * _e410.exposure);
    let _e413: vec3<f32> = velocity;
    let _e415: vec3<f32> = velocity;
    let _e417: vec2<f32> = localVelocity;
    let _e418: vec2<f32> = (_e415.xz + _e417);
    velocity.x = _e418.x;
    velocity.z = _e418.y;
    let _e423: vec3<f32> = steadyVelocity;
    let _e424: TerrainProjectWindSample = result;
    steadyVelocity = (_e423 * _e424.exposure);
    let _e428: vec3<f32> = velocity;
    result.velocityWS = _e428;
    let _e430: vec3<f32> = steadyVelocity;
    result.steadyHorizontalSpeed = length(_e430.xz);
    let _e433: TerrainProjectWindSample = result;
    return _e433;
}

fn terrainProjectCompliantBend(requestedAngle: f32, maximumAngle: f32) -> f32 {
    var requestedAngle_1: f32;
    var maximumAngle_1: f32;
    var safeMaximum_2: f32;

    requestedAngle_1 = requestedAngle;
    maximumAngle_1 = maximumAngle;
    let _e138: f32 = maximumAngle_1;
    safeMaximum_2 = max(_e138, 0.0001f);
    let _e142: f32 = safeMaximum_2;
    let _e144: f32 = requestedAngle_1;
    let _e148: f32 = safeMaximum_2;
    return (_e142 * (1f - exp((-(max(_e144, 0f)) / _e148))));
}

fn terrainProjectWindReceiverSpeed(wind: TerrainProjectWindSample, profile_7: TerrainProjectWindReceiverProfile) -> f32 {
    var wind_1: TerrainProjectWindSample;
    var profile_8: TerrainProjectWindReceiverProfile;

    wind_1 = wind;
    profile_8 = profile_7;
    let _e139: TerrainProjectWindSample = wind_1;
    let _e141: TerrainProjectWindSample = wind_1;
    let _e145: TerrainProjectWindReceiverProfile = profile_8;
    let _e149: TerrainProjectWindReceiverProfile = profile_8;
    return (max(0f, mix(_e139.steadyHorizontalSpeed, length(_e141.velocityWS.xz), _e145.dynamicGain)) * _e149.bendGain);
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
    let _e143: TerrainProjectWindSample = wind_3;
    let _e145: TerrainProjectWindSample = wind_3;
    let _e149: TerrainProjectWindReceiverProfile = profile_10;
    physicalSpeed = max(0f, mix(_e143.steadyHorizontalSpeed, length(_e145.velocityWS.xz), _e149.dynamicGain));
    let _e154: TerrainProjectWindSample = wind_3;
    let _e155: TerrainProjectWindReceiverProfile = profile_10;
    let _e156: f32 = terrainProjectWindReceiverSpeed(_e154, _e155);
    receiverSpeed = _e156;
    let _e158: f32 = physicalSpeed;
    normalizedSpeed = (_e158 / 8f);
    let _e162: f32 = receiverSpeed;
    let _e163: f32 = normalizedSpeed;
    quadraticEquivalentSpeed = (_e162 * max(_e163, 0f));
    let _e177: f32 = normalizedSpeed;
    let _e182: f32 = reconfigurationCoefficient;
    let _e187: f32 = nonlinearBlend;
    reconfiguration = pow((1f + (max((_e177 - 0.65f), 0f) * _e182)), (-0.67f * _e187));
    let _e191: f32 = receiverSpeed;
    let _e192: f32 = quadraticEquivalentSpeed;
    let _e193: f32 = nonlinearBlend;
    let _e195: f32 = reconfiguration;
    let _e197: f32 = grassLodgingGain;
    aerodynamicSpeed = ((mix(_e191, _e192, _e193) * _e195) * _e197);
    let _e200: f32 = aerodynamicSpeed;
    let _e201: f32 = global.material_WindForce;
    let _e205: f32 = flow_1;
    let _e207: f32 = structuralWeight_1;
    let _e209: f32 = retainedEnergyAngle;
    let _e210: f32 = structuralWeight_1;
    let _e213: TerrainProjectWindReceiverProfile = profile_10;
    let _e215: f32 = terrainProjectCompliantBend((((((_e200 * _e201) * 0.045f) * _e205) * _e207) + (_e209 * _e210)), _e213.maximumBendRadians);
    return _e215;
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
    let _e151: vec3<f32> = global_1.camera_Position;
    let _e152: vec3<f32> = originWS_9;
    cameraOffsetFromOrigin = (_e151 - _e152);
    let _e155: vec3<f32> = cameraOffsetFromOrigin;
    let _e156: vec3<f32> = cameraOffsetFromOrigin;
    cameraDistanceSquared = dot(_e155, _e156);
    let _e159: f32 = cameraDistanceSquared;
    cameraDistanceToOrigin = sqrt(_e159);
    let _e162: vec3<f32> = positionWS_5;
    windPositionWS = _e162;
    let _e164: vec3<f32> = (*normalWS);
    windNormalWS = _e164;
    let _e170: mat4x4<f32> = global.camera_ViewMat;
    let _e171: vec3<f32> = positionWS_5;
    eyeDepth = -((_e170 * vec4<f32>(_e171.x, _e171.y, _e171.z, 1f)).z);
    let _e181: f32 = eyeDepth;
    let _e182: vec4<f32> = global.camera_ProjectionParams;
    let _e185: f32 = global.material_GrassFadeDistance;
    cameraDepthFade = (((_e181 - _e182.y) - _e185) / 5f);
    let _e191: f32 = cameraDepthFade;
    let _e193: f32 = cameraDepthFade;
    let _e194: f32 = global.material_GrassFalloff;
    grassFade = clamp(mix((1f - _e191), _e193, (_e194 * 0.5f)), 0f, 1f);
    let _e202: f32 = grassFade;
    let _e203: f32 = global.material_GrassDistanceFadeEnable;
    grassFadeMask = mix(1f, _e202, _e203);
    let _e206: vec3<f32> = (*normalWS);
    let _e207: vec3<f32> = windNormalWS;
    let _e208: f32 = grassFadeMask;
    (*normalWS) = normalize(mix(_e206, _e207, vec3(_e208)));
    let _e212: f32 = grassFadeMask;
    (*windShadingResponse) = _e212;
    let _e213: vec3<f32> = originWS_9;
    let _e214: vec3<f32> = windPositionWS;
    let _e215: f32 = grassFadeMask;
    return mix(_e213, _e214, vec3(_e215));
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
    let _e145: vec4<f32> = positionOS_1;
    let _e147: Attributes = attributes_27;
    let _e148: vec3<f32> = terrainProjectDetailPositionOS(_e145.xyz, _e147);
    detailPositionOS = _e148;
    let _e150: Attributes = attributes_27;
    let _e151: vec3<f32> = terrainProjectDetailOriginOS(_e150);
    detailOriginOS = _e151;
    let _e153: mat4x4<f32> = global.renderer_ModelMat;
    let _e154: vec3<f32> = detailPositionOS;
    homogeneousPositionWS = (_e153 * vec4<f32>(_e154.x, _e154.y, _e154.z, 1f));
    let _e162: vec4<f32> = homogeneousPositionWS;
    let _e164: vec4<f32> = homogeneousPositionWS;
    positionWS_6 = (_e162.xyz / vec3(_e164.w));
    let _e169: mat4x4<f32> = global.renderer_ModelMat;
    let _e170: vec3<f32> = detailOriginOS;
    homogeneousOriginWS = (_e169 * vec4<f32>(_e170.x, _e170.y, _e170.z, 1f));
    let _e178: vec4<f32> = homogeneousOriginWS;
    let _e180: vec4<f32> = homogeneousOriginWS;
    originWS_10 = (_e178.xyz / vec3(_e180.w));
    let _e185: vec3<f32> = positionWS_6;
    let _e186: vec3<f32> = originWS_10;
    let _e187: Attributes = attributes_27;
    let _e198: vec3<f32> = terrainProjectApplyVegetationWind(_e185, _e186, _e187, normalWS_1, tangentWS_1, windShadingResponse_1, groundWindDiagnostics_1, groundWindCarrierNormalWS_1);
    return _e198;
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn terrainProjectBuildVegetationDepthShadowVaryings(attributes_28: Attributes) -> Varyings {
    var attributes_29: Attributes;
    var varyings: Varyings;
    var positionOS_2: vec4<f32>;
    var normalOS: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var proceduralTreeWindOriginOS_2: vec3<f32> = vec3(0f);
    var normalWS_2: vec3<f32>;
    var tangentWS_2: vec3<f32> = vec3(0f);
    var windShadingResponse_2: f32;
    var groundWindDiagnostics_2: vec3<f32>;
    var groundWindCarrierNormalWS_2: vec3<f32>;
    var positionWS_7: vec3<f32>;

    attributes_29 = attributes_28;
    let _e137: Attributes = attributes_29;
    positionOS_2 = vec4<f32>(_e137.POSITION.x, _e137.POSITION.y, _e137.POSITION.z, 1f);
    let _e153: vec3<f32> = normalOS;
    let _e158: f32 = global.material_LightingFlatness;
    normalOS = normalize(mix(_e153, vec3<f32>(0f, 1f, 0f), vec3(_e158)));
    let _e162: vec3<f32> = normalOS;
    let _e163: Attributes = attributes_29;
    let _e164: vec3<f32> = terrainProjectDetailNormalOS(_e162, _e163);
    normalOS = _e164;
    varyings.uv = vec2(0f);
    let _e176: mat4x4<f32> = global.renderer_NormalMat;
    let _e186: vec3<f32> = normalOS;
    normalWS_2 = normalize((mat3x3<f32>(_e176[0].xyz, _e176[1].xyz, _e176[2].xyz) * _e186));
    let _e189: vec4<f32> = positionOS_2;
    let _e190: Attributes = attributes_29;
    let _e191: vec3<f32> = proceduralTreeWindOriginOS_2;
    let _e202: vec3<f32> = terrainProjectVegetationPositionWS(_e189, _e190, _e191, (&normalWS_2), (&tangentWS_2), (&windShadingResponse_2), (&groundWindDiagnostics_2), (&groundWindCarrierNormalWS_2));
    positionWS_7 = _e202;
    let _e204: mat4x4<f32> = global.camera_VPMat;
    let _e205: vec3<f32> = positionWS_7;
    gl_Position = (_e204 * vec4<f32>(_e205.x, _e205.y, _e205.z, 1f));
    let _e212: Varyings = varyings;
    return _e212;
}

fn VegetationDepthOnlyVertex(attributes_30: Attributes) -> Varyings {
    var attributes_31: Attributes;

    attributes_31 = attributes_30;
    let _e137: Attributes = attributes_31;
    let _e138: Varyings = terrainProjectBuildVegetationDepthShadowVaryings(_e137);
    return _e138;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e135: Attributes = read_Attributes();
    input_attributes = _e135;
    let _e137: Attributes = input_attributes;
    let _e138: Varyings = VegetationDepthOnlyVertex(_e137);
    write_Varyings(_e138);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e137: vec4<f32> = gl_Position;
    let _e139: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e137.z + _e139.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e145: vec2<f32> = uv;
    let _e147: vec4<f32> = gl_Position;
    return VertexOutput(_e145, _e147);
}
