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
    camera_DepthBufferParams: vec4<f32>,
    camera_Forward: vec3<f32>,
    material_BaseColor: vec4<f32>,
    material_Tiling: f32,
    material_AlphaCutoff: f32,
    material_Smoothness: f32,
    material_NormalScale: f32,
    material_SecondColor: vec4<f32>,
    material_SecondColorOffset: f32,
    material_SecondColorFade: f32,
    material_SecondColorLevel: f32,
    material_SecondColorGradient: f32,
    material_SecondColorWorldNoiseScale: f32,
    material_LeafAlbedoBrightness: f32,
    material_LeafAlbedoDesaturation: f32,
    material_LeafAlbedoTextureBlend: f32,
    material_LeafBaseAOInfluence: f32,
    material_LeafGlancingAngleCut: f32,
    material_LeafFlipBackfaceNormals: f32,
    material_TranslucencyColor: vec4<f32>,
    material_TranslucencyIntensity: f32,
    material_TranslucencyBacklightThreshold: f32,
    material_TranslucencyNormalWrap: f32,
    material_TranslucencyEnergyScale: f32,
    material_TranslucencyAOInfluence: f32,
    material_TranslucencyNormalDistortion: f32,
    material_TranslucencyScattering: f32,
    material_TranslucencyDirect: f32,
    material_TranslucencyAmbient: f32,
    material_TranslucencyShadowStrength: f32,
    material_ProceduralTreeCanopyOcclusionDensity: f32,
    material_ProceduralTreeCanopyOcclusionColor: vec4<f32>,
    scene_SurfaceClimate: vec4<f32>,
    scene_SurfaceSnowColor: vec4<f32>,
    material_SnowResponse: vec4<f32>,
    renderer_Layer: vec4<i32>,
}

struct Attributes {
    POSITION: vec3<f32>,
}

struct Varyings {
    uv: vec2<f32>,
    positionWS: vec3<f32>,
    normalWS: vec3<f32>,
    positionCS: vec4<f32>,
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
var<private> normalWS_4: vec3<f32>;
var<private> positionCS: vec4<f32>;
@group(0) @binding(0) 
var gs_wgpu_tex_scene_WindSpectrumTexture: texture_2d<f32>;
@group(0) @binding(1) 
var gs_wgpu_samp_scene_WindSpectrumTexture: sampler;
@group(0) @binding(2) 
var gs_wgpu_tex_scene_WindTreeResponseSlowTexture: texture_2d<f32>;

@group(0) @binding(4) 
var gs_wgpu_tex_scene_WindTreeResponseFastTexture: texture_2d<f32>;

@group(2) @binding(2) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e201: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e201;
    let _e202: Attributes = interface_value;
    return _e202;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e205: Varyings = interface_value_2;
    uv = _e205.uv;
    let _e207: Varyings = interface_value_2;
    positionWS_7 = _e207.positionWS;
    let _e209: Varyings = interface_value_2;
    normalWS_4 = _e209.normalWS;
    let _e211: Varyings = interface_value_2;
    positionCS = _e211.positionCS;
    return;
}

fn terrainProjectRotateDetailY(value: vec3<f32>, radians: f32) -> vec3<f32> {
    var value_1: vec3<f32>;
    var radians_1: f32;
    var sine: f32;
    var cosine: f32;

    value_1 = value;
    radians_1 = radians;
    let _e207: f32 = radians_1;
    sine = sin(_e207);
    let _e210: f32 = radians_1;
    cosine = cos(_e210);
    let _e213: f32 = cosine;
    let _e214: vec3<f32> = value_1;
    let _e217: f32 = sine;
    let _e218: vec3<f32> = value_1;
    let _e222: vec3<f32> = value_1;
    let _e224: f32 = sine;
    let _e226: vec3<f32> = value_1;
    let _e229: f32 = cosine;
    let _e230: vec3<f32> = value_1;
    return vec3<f32>(((_e213 * _e214.x) + (_e217 * _e218.z)), _e222.y, ((-(_e224) * _e226.x) + (_e229 * _e230.z)));
}

fn terrainProjectDetailPositionOS(sourcePositionOS: vec3<f32>, attributes: Attributes) -> vec3<f32> {
    var sourcePositionOS_1: vec3<f32>;
    var attributes_1: Attributes;

    sourcePositionOS_1 = sourcePositionOS;
    attributes_1 = attributes;
    let _e207: vec3<f32> = sourcePositionOS_1;
    return _e207;
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
    let _e207: vec3<f32> = sourceNormalOS_1;
    return _e207;
}

fn terrainProjectDetailTangentOS(sourceTangentOS: vec3<f32>, attributes_6: Attributes) -> vec3<f32> {
    var sourceTangentOS_1: vec3<f32>;
    var attributes_7: Attributes;

    sourceTangentOS_1 = sourceTangentOS;
    attributes_7 = attributes_6;
    let _e207: vec3<f32> = sourceTangentOS_1;
    return _e207;
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
    let _e215: vec2<f32> = fromDirection_1;
    fromLength = length(_e215);
    let _e218: vec2<f32> = toDirection_1;
    toLength = length(_e218);
    let _e221: f32 = fromLength;
    if (_e221 <= 0.0001f) {
        let _e224: f32 = toLength;
        if (_e224 > 0.0001f) {
            let _e227: vec2<f32> = toDirection_1;
            let _e228: f32 = toLength;
            local = (_e227 / vec2(_e228));
        } else {
            local = vec2<f32>(1f, 0f);
        }
        let _e235: vec2<f32> = local;
        return _e235;
    }
    let _e236: f32 = toLength;
    if (_e236 <= 0.0001f) {
        let _e239: vec2<f32> = fromDirection_1;
        let _e240: f32 = fromLength;
        return (_e239 / vec2(_e240));
    }
    let _e243: vec2<f32> = fromDirection_1;
    let _e244: f32 = fromLength;
    fromUnit = (_e243 / vec2(_e244));
    let _e248: vec2<f32> = toDirection_1;
    let _e249: f32 = toLength;
    toUnit = (_e248 / vec2(_e249));
    let _e253: vec2<f32> = fromUnit;
    let _e255: vec2<f32> = toUnit;
    let _e258: vec2<f32> = fromUnit;
    let _e260: vec2<f32> = toUnit;
    crossAngle = ((_e253.x * _e255.y) - (_e258.y * _e260.x));
    let _e265: vec2<f32> = fromUnit;
    let _e266: vec2<f32> = toUnit;
    dotAngle = clamp(dot(_e265, _e266), -1f, 1f);
    let _e273: f32 = crossAngle;
    let _e274: f32 = dotAngle;
    let _e276: f32 = weight_1;
    angle = (atan2(_e273, _e274) * clamp(_e276, 0f, 1f));
    let _e282: f32 = angle;
    cosine_1 = cos(_e282);
    let _e285: f32 = angle;
    sine_1 = sin(_e285);
    let _e288: vec2<f32> = fromUnit;
    let _e290: f32 = cosine_1;
    let _e292: vec2<f32> = fromUnit;
    let _e294: f32 = sine_1;
    let _e297: vec2<f32> = fromUnit;
    let _e299: f32 = sine_1;
    let _e301: vec2<f32> = fromUnit;
    let _e303: f32 = cosine_1;
    return vec2<f32>(((_e288.x * _e290) - (_e292.y * _e294)), ((_e297.x * _e299) + (_e301.y * _e303)));
}

fn terrainProjectWindReceiverProfile() -> TerrainProjectWindReceiverProfile {
    var profile: TerrainProjectWindReceiverProfile;
    var response0_: vec4<f32>;
    var response1_: vec4<f32>;
    var response2_: vec4<f32>;

    let _e210: vec4<f32> = global_1.scene_WindGrassProfile0_;
    response0_ = _e210;
    let _e212: vec4<f32> = global_1.scene_WindGrassProfile1_;
    response1_ = _e212;
    let _e214: vec4<f32> = global_1.scene_WindGrassProfile2_;
    response2_ = _e214;
    let _e217: vec4<f32> = response0_;
    profile.bendGain = _e217.x;
    let _e220: vec4<f32> = response0_;
    profile.dynamicGain = _e220.y;
    let _e223: vec4<f32> = response0_;
    profile.macroGain = _e223.z;
    let _e226: vec4<f32> = response0_;
    profile.mesoGain = _e226.w;
    let _e229: vec4<f32> = response1_;
    profile.microGain = _e229.x;
    let _e232: vec4<f32> = response1_;
    profile.responseLagSeconds = _e232.y;
    let _e235: vec4<f32> = response1_;
    profile.maximumBendRadians = _e235.z;
    let _e238: vec4<f32> = response1_;
    profile.flutterWeight = _e238.w;
    let _e241: vec4<f32> = response2_;
    profile.flutterFrequencyMinHz = _e241.x;
    let _e244: vec4<f32> = response2_;
    profile.flutterFrequencyMaxHz = _e244.y;
    let _e247: vec4<f32> = response2_;
    profile.highSpeedMicroScale = _e247.z;
    let _e250: vec4<f32> = response2_;
    profile.naturalFrequencyHz = _e250.w;
    let _e252: TerrainProjectWindReceiverProfile = profile;
    return _e252;
}

fn terrainProjectWindAnimationLod(distanceToCamera: f32) -> f32 {
    var distanceToCamera_1: f32;

    distanceToCamera_1 = distanceToCamera;
    let _e213: f32 = distanceToCamera_1;
    let _e217: f32 = distanceToCamera_1;
    return (smoothstep(36f, 72f, _e213) + smoothstep(120f, 220f, _e217));
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
    let _e211: f32 = global_1.material_UVBaseLock;
    if (_e211 <= 0f) {
        return 1f;
    }
    let _e218: f32 = baseHeight;
    let _e221: f32 = global_1.material_UVBaseLock;
    return mix(1f, pow(_e218, 1.5f), _e221);
}

fn terrainProjectVegetationStructuralWeight(positionWS: vec3<f32>, originWS: vec3<f32>, attributes_12: Attributes) -> f32 {
    var positionWS_1: vec3<f32>;
    var originWS_1: vec3<f32>;
    var attributes_13: Attributes;
    var authoredWeight: f32;

    positionWS_1 = positionWS;
    originWS_1 = originWS;
    attributes_13 = attributes_12;
    let _e215: Attributes = attributes_13;
    let _e216: f32 = terrainProjectVegetationVertexColorWeight(_e215);
    authoredWeight = _e216;
    let _e218: f32 = authoredWeight;
    let _e219: Attributes = attributes_13;
    let _e220: f32 = terrainProjectVegetationBaseLockWeight(_e219);
    return (_e218 * _e220);
}

fn terrainProjectTreePhase(originWS_2: vec3<f32>) -> f32 {
    var originWS_3: vec3<f32>;

    originWS_3 = originWS_2;
    let _e211: vec3<f32> = originWS_3;
    return fract((sin(dot(_e211.xz, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
}

fn terrainProjectWindReceiverPhase(originWS_4: vec3<f32>, attributes_14: Attributes) -> f32 {
    var originWS_5: vec3<f32>;
    var attributes_15: Attributes;
    var phase: f32;

    originWS_5 = originWS_4;
    attributes_15 = attributes_14;
    let _e213: vec3<f32> = originWS_5;
    let _e214: f32 = terrainProjectTreePhase(_e213);
    phase = _e214;
    let _e216: f32 = phase;
    return _e216;
}

fn terrainProjectVegetationFlutterWeight(attributes_16: Attributes, profile_1: TerrainProjectWindReceiverProfile) -> f32 {
    var attributes_17: Attributes;
    var profile_2: TerrainProjectWindReceiverProfile;

    attributes_17 = attributes_16;
    profile_2 = profile_1;
    let _e213: TerrainProjectWindReceiverProfile = profile_2;
    return _e213.flutterWeight;
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
    let _e213: f32 = decorrelation_1;
    variation = clamp(abs(_e213), 0f, 1f);
    let _e219: TerrainProjectWindReceiverProfile = profile_4;
    let _e221: TerrainProjectWindReceiverProfile = profile_4;
    let _e223: f32 = variation;
    return mix(_e219.flutterFrequencyMinHz, _e221.flutterFrequencyMaxHz, _e223);
}

fn terrainProjectWindMicroEnvelope(relativeHorizontalSpeed: f32, profile_5: TerrainProjectWindReceiverProfile) -> f32 {
    var relativeHorizontalSpeed_1: f32;
    var profile_6: TerrainProjectWindReceiverProfile;

    relativeHorizontalSpeed_1 = relativeHorizontalSpeed;
    profile_6 = profile_5;
    let _e214: TerrainProjectWindReceiverProfile = profile_6;
    let _e218: f32 = relativeHorizontalSpeed_1;
    return mix(1f, _e214.highSpeedMicroScale, smoothstep(3f, 8f, _e218));
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
    let _e217: vec3<f32> = value_3;
    let _e218: f32 = cosine_3;
    let _e220: vec3<f32> = axis_1;
    let _e221: vec3<f32> = value_3;
    let _e223: f32 = sine_3;
    let _e226: vec3<f32> = axis_1;
    let _e227: vec3<f32> = axis_1;
    let _e228: vec3<f32> = value_3;
    let _e232: f32 = cosine_3;
    return (((_e217 * _e218) + (cross(_e220, _e221) * _e223)) + ((_e226 * dot(_e227, _e228)) * (1f - _e232)));
}

fn terrainProjectRotateAroundAxis(value_4: vec3<f32>, axis_2: vec3<f32>, angle_1: f32) -> vec3<f32> {
    var value_5: vec3<f32>;
    var axis_3: vec3<f32>;
    var angle_2: f32;

    value_5 = value_4;
    axis_3 = axis_2;
    angle_2 = angle_1;
    let _e215: vec3<f32> = value_5;
    let _e216: vec3<f32> = axis_3;
    let _e217: f32 = angle_2;
    let _e219: f32 = angle_2;
    let _e221: vec3<f32> = terrainProjectRotateAroundAxisSinCos(_e215, _e216, cos(_e217), sin(_e219));
    return _e221;
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
    let _e213: f32 = value_7;
    magnitude = abs(_e213);
    let _e216: f32 = maximumMagnitude_1;
    safeMaximum = max(_e216, 0.0001f);
    let _e220: f32 = safeMaximum;
    let _e223: f32 = safeMaximum;
    let _e224: f32 = magnitude;
    saturation = smoothstep((_e220 * 0.6f), _e223, _e224);
    let _e227: f32 = magnitude;
    let _e228: f32 = safeMaximum;
    let _e229: f32 = saturation;
    let _e231: f32 = safeMaximum;
    limitedMagnitude = min(mix(_e227, _e228, _e229), _e231);
    let _e234: f32 = value_7;
    if (_e234 < 0f) {
        let _e237: f32 = limitedMagnitude;
        local_1 = -(_e237);
    } else {
        let _e239: f32 = limitedMagnitude;
        local_1 = _e239;
    }
    let _e241: f32 = local_1;
    return _e241;
}

fn terrainProjectCompliantSignedTravel(value_8: f32, maximumMagnitude_2: f32) -> f32 {
    var value_9: f32;
    var maximumMagnitude_3: f32;
    var safeMaximum_1: f32;

    value_9 = value_8;
    maximumMagnitude_3 = maximumMagnitude_2;
    let _e213: f32 = maximumMagnitude_3;
    safeMaximum_1 = max(_e213, 0f);
    let _e217: f32 = value_9;
    let _e218: f32 = safeMaximum_1;
    let _e220: f32 = safeMaximum_1;
    let _e221: f32 = safeMaximum_1;
    let _e223: f32 = value_9;
    let _e224: f32 = value_9;
    return ((_e217 * _e218) * inverseSqrt((((_e220 * _e221) + (_e223 * _e224)) + 0.00000001f)));
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
    let _e222: vec3<f32> = originWS_7;
    let _e223: Attributes = attributes_23;
    let _e224: f32 = terrainProjectWindReceiverPhase(_e222, _e223);
    phase_1 = _e224;
    let _e226: vec4<f32> = global_1.scene_WindSpectrumParams;
    macroInverseScale = _e226.x;
    let _e229: vec4<f32> = global_1.scene_WindFieldParams;
    if (_e229.x > 0.0001f) {
        let _e233: vec3<f32> = global_1.scene_WindVelocity;
        local_2 = normalize(_e233.xz);
    } else {
        local_2 = vec2<f32>(1f, 0f);
    }
    let _e240: vec2<f32> = local_2;
    horizontalDirection = _e240;
    let _e244: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e247: TerrainProjectWindReceiverProfile = loadProfile_1;
    let _e249: f32 = naturalFrequencyScale;
    boundedResponseLag = min(_e244.responseLagSeconds, (0.5f / max((_e247.naturalFrequencyHz * _e249), 0.001f)));
    let _e256: vec3<f32> = positionWS_3;
    spectrumPosition = _e256.xz;
    let _e259: vec2<f32> = spectrumPosition;
    let _e260: f32 = macroInverseScale;
    let _e262: vec3<f32> = global_1.scene_WindSpectrumAdvectionOffset;
    let _e264: f32 = macroInverseScale;
    currentSpectrumUv = ((_e259 * _e260) - ((_e262.xz * _e264) * 0.12f));
    let _e270: vec2<f32> = currentSpectrumUv;
    let _e272: vec4<f32> = textureSampleLevel(gs_wgpu_tex_scene_WindSpectrumTexture, gs_wgpu_samp_scene_WindSpectrumTexture, _e270, 0f);
    currentPackedSpectrum = _e272;
    let _e274: vec4<f32> = currentPackedSpectrum;
    packedSpectrum = _e274;
    result.elasticMemory = 0f;
    result.groundResponseVelocity = 0f;
    let _e280: vec4<f32> = packedSpectrum;
    spectrum = ((_e280 * 2f) - vec4(1f));
    let _e288: vec4<f32> = spectrum;
    result.macro_ = clamp(_e288.x, -1f, 1f);
    let _e295: TerrainProjectWindSample = result;
    result.groundWave = _e295.macro_;
    result.groundDetail = 0f;
    result.exposure = 1f;
    let _e316: vec4<f32> = global_1.scene_WindFieldParams;
    result.turbulence = _e316.z;
    result.localFieldWeight = 0f;
    let _e320: vec4<f32> = global_1.scene_WindFieldParams;
    presentedReferenceGust = _e320.y;
    let _e326: f32 = windLod_1;
    mesoWeight = (1f - smoothstep(1.45f, 2f, _e326));
    let _e333: f32 = windLod_1;
    microLodWeight = (1f - smoothstep(0.45f, 1f, _e333));
    let _e337: vec4<f32> = spectrum;
    let _e343: f32 = mesoWeight;
    result.meso = (clamp(_e337.y, -1f, 1f) * _e343);
    result.micro = 0f;
    let _e347: f32 = microLodWeight;
    if (_e347 > 0f) {
        {
            let _e350: f32 = phase_1;
            flutterFrequencyDecorrelator = ((_e350 * 2f) - 1f);
            let _e356: f32 = flutterFrequencyDecorrelator;
            let _e357: TerrainProjectWindReceiverProfile = microProfile_1;
            let _e358: f32 = terrainProjectWindFlutterFrequencyHz(_e356, _e357);
            flutterFrequencyHz = _e358;
            let _e362: vec4<f32> = global_1.scene_WindFieldParams;
            receiverClockSeconds = _e362.w;
            let _e365: f32 = receiverClockSeconds;
            let _e366: f32 = flutterFrequencyHz;
            let _e370: f32 = phase_1;
            let _e374: f32 = groundVerticalPhase;
            periodicFlutterSignal = sin(((((_e365 * _e366) * 6.2831855f) + (_e370 * 6.2831855f)) + _e374));
            let _e377: vec4<f32> = spectrum;
            microSpectrumSignal = _e377.z;
            let _e380: f32 = microSpectrumSignal;
            let _e383: f32 = periodicFlutterSignal;
            let _e391: f32 = microLodWeight;
            result.micro = (clamp(((_e380 * 0.65f) + (_e383 * 0.35f)), -1f, 1f) * _e391);
        }
    }
    let _e393: vec3<f32> = positionWS_3;
    let _e395: vec3<f32> = originWS_7;
    heightAboveRoot = max((_e393.y - _e395.y), 0f);
    let _e401: vec3<f32> = global_1.scene_WindLayerMultipliers;
    let _e403: vec3<f32> = global_1.scene_WindLayerMultipliers;
    let _e407: f32 = heightAboveRoot;
    layer = mix(_e401.x, _e403.y, smoothstep(0.8f, 4f, _e407));
    let _e411: vec3<f32> = global_1.scene_WindVelocity;
    let _e412: f32 = layer;
    baseVelocity = (_e411 * _e412);
    let _e415: vec3<f32> = baseVelocity;
    velocity = _e415;
    let _e417: vec3<f32> = baseVelocity;
    steadyVelocity = _e417;
    let _e420: TerrainProjectWindSample = result;
    referenceGustWeight = (1f - _e420.localFieldWeight);
    let _e426: vec3<f32> = velocity;
    let _e427: vec3<f32> = baseVelocity;
    let _e428: f32 = presentedReferenceGust;
    let _e429: f32 = referenceGustWeight;
    let _e431: f32 = gustWeight;
    let _e433: TerrainProjectWindSample = result;
    let _e436: TerrainProjectWindSample = result;
    velocity = (_e426 + (_e427 * (((_e428 * _e429) * _e431) + (_e433.macro_ * (0.08f + (_e436.turbulence * 0.12f))))));
    let _e445: vec3<f32> = velocity;
    horizontalSpeed = length(_e445.xz);
    let _e449: f32 = horizontalSpeed;
    if (_e449 > 0.0001f) {
        {
            let _e452: vec3<f32> = velocity;
            let _e454: f32 = horizontalSpeed;
            direction = (_e452.xz / vec2(_e454));
            let _e458: vec3<f32> = velocity;
            let _e460: vec3<f32> = velocity;
            let _e462: vec2<f32> = direction;
            let _e465: vec2<f32> = direction;
            let _e468: f32 = horizontalSpeed;
            let _e470: TerrainProjectWindSample = result;
            let _e473: TerrainProjectWindSample = result;
            let _e476: vec4<f32> = global_1.scene_WindSpectrumParams;
            let _e479: vec2<f32> = (_e460.xz + ((((vec2<f32>(-(_e462.y), _e465.x) * _e468) * _e470.meso) * _e473.turbulence) * _e476.w));
            velocity.x = _e479.x;
            velocity.z = _e479.y;
        }
    }
    let _e484: vec3<f32> = velocity;
    let _e485: TerrainProjectWindSample = result;
    velocity = (_e484 * _e485.exposure);
    let _e488: vec3<f32> = velocity;
    let _e490: vec3<f32> = velocity;
    let _e492: vec2<f32> = localVelocity;
    let _e493: vec2<f32> = (_e490.xz + _e492);
    velocity.x = _e493.x;
    velocity.z = _e493.y;
    let _e498: vec3<f32> = steadyVelocity;
    let _e499: TerrainProjectWindSample = result;
    steadyVelocity = (_e498 * _e499.exposure);
    let _e503: vec3<f32> = velocity;
    result.velocityWS = _e503;
    let _e505: vec3<f32> = steadyVelocity;
    result.steadyHorizontalSpeed = length(_e505.xz);
    let _e508: TerrainProjectWindSample = result;
    return _e508;
}

fn terrainProjectCompliantBend(requestedAngle: f32, maximumAngle: f32) -> f32 {
    var requestedAngle_1: f32;
    var maximumAngle_1: f32;
    var safeMaximum_2: f32;

    requestedAngle_1 = requestedAngle;
    maximumAngle_1 = maximumAngle;
    let _e213: f32 = maximumAngle_1;
    safeMaximum_2 = max(_e213, 0.0001f);
    let _e217: f32 = safeMaximum_2;
    let _e219: f32 = requestedAngle_1;
    let _e223: f32 = safeMaximum_2;
    return (_e217 * (1f - exp((-(max(_e219, 0f)) / _e223))));
}

fn terrainProjectWindReceiverSpeed(wind: TerrainProjectWindSample, profile_7: TerrainProjectWindReceiverProfile) -> f32 {
    var wind_1: TerrainProjectWindSample;
    var profile_8: TerrainProjectWindReceiverProfile;

    wind_1 = wind;
    profile_8 = profile_7;
    let _e214: TerrainProjectWindSample = wind_1;
    let _e216: TerrainProjectWindSample = wind_1;
    let _e220: TerrainProjectWindReceiverProfile = profile_8;
    let _e224: TerrainProjectWindReceiverProfile = profile_8;
    return (max(0f, mix(_e214.steadyHorizontalSpeed, length(_e216.velocityWS.xz), _e220.dynamicGain)) * _e224.bendGain);
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
    let _e218: TerrainProjectWindSample = wind_3;
    let _e220: TerrainProjectWindSample = wind_3;
    let _e224: TerrainProjectWindReceiverProfile = profile_10;
    physicalSpeed = max(0f, mix(_e218.steadyHorizontalSpeed, length(_e220.velocityWS.xz), _e224.dynamicGain));
    let _e229: TerrainProjectWindSample = wind_3;
    let _e230: TerrainProjectWindReceiverProfile = profile_10;
    let _e231: f32 = terrainProjectWindReceiverSpeed(_e229, _e230);
    receiverSpeed = _e231;
    let _e233: f32 = physicalSpeed;
    normalizedSpeed = (_e233 / 8f);
    let _e237: f32 = receiverSpeed;
    let _e238: f32 = normalizedSpeed;
    quadraticEquivalentSpeed = (_e237 * max(_e238, 0f));
    let _e252: f32 = normalizedSpeed;
    let _e257: f32 = reconfigurationCoefficient;
    let _e262: f32 = nonlinearBlend;
    reconfiguration = pow((1f + (max((_e252 - 0.65f), 0f) * _e257)), (-0.67f * _e262));
    let _e266: f32 = receiverSpeed;
    let _e267: f32 = quadraticEquivalentSpeed;
    let _e268: f32 = nonlinearBlend;
    let _e270: f32 = reconfiguration;
    let _e272: f32 = grassLodgingGain;
    aerodynamicSpeed = ((mix(_e266, _e267, _e268) * _e270) * _e272);
    let _e275: f32 = aerodynamicSpeed;
    let _e276: f32 = global_1.material_WindForce;
    let _e280: f32 = flow_1;
    let _e282: f32 = structuralWeight_1;
    let _e284: f32 = retainedEnergyAngle;
    let _e285: f32 = structuralWeight_1;
    let _e288: TerrainProjectWindReceiverProfile = profile_10;
    let _e290: f32 = terrainProjectCompliantBend((((((_e275 * _e276) * 0.045f) * _e280) * _e282) + (_e284 * _e285)), _e288.maximumBendRadians);
    return _e290;
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
    let _e226: vec3<f32> = global.camera_Position;
    let _e227: vec3<f32> = originWS_9;
    cameraOffsetFromOrigin = (_e226 - _e227);
    let _e230: vec3<f32> = cameraOffsetFromOrigin;
    let _e231: vec3<f32> = cameraOffsetFromOrigin;
    cameraDistanceSquared = dot(_e230, _e231);
    let _e234: f32 = cameraDistanceSquared;
    cameraDistanceToOrigin = sqrt(_e234);
    let _e237: vec3<f32> = positionWS_5;
    windPositionWS = _e237;
    let _e239: vec3<f32> = (*normalWS);
    windNormalWS = _e239;
    let _e245: mat4x4<f32> = global.camera_ViewMat;
    let _e246: vec3<f32> = positionWS_5;
    eyeDepth = -((_e245 * vec4<f32>(_e246.x, _e246.y, _e246.z, 1f)).z);
    let _e256: f32 = eyeDepth;
    let _e257: vec4<f32> = global.camera_ProjectionParams;
    let _e260: f32 = global_1.material_GrassFadeDistance;
    cameraDepthFade = (((_e256 - _e257.y) - _e260) / 5f);
    let _e266: f32 = cameraDepthFade;
    let _e268: f32 = cameraDepthFade;
    let _e269: f32 = global_1.material_GrassFalloff;
    grassFade = clamp(mix((1f - _e266), _e268, (_e269 * 0.5f)), 0f, 1f);
    let _e277: f32 = grassFade;
    let _e278: f32 = global_1.material_GrassDistanceFadeEnable;
    grassFadeMask = mix(1f, _e277, _e278);
    let _e281: vec3<f32> = (*normalWS);
    let _e282: vec3<f32> = windNormalWS;
    let _e283: f32 = grassFadeMask;
    (*normalWS) = normalize(mix(_e281, _e282, vec3(_e283)));
    let _e287: f32 = grassFadeMask;
    (*windShadingResponse) = _e287;
    let _e288: vec3<f32> = originWS_9;
    let _e289: vec3<f32> = windPositionWS;
    let _e290: f32 = grassFadeMask;
    return mix(_e288, _e289, vec3(_e290));
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
    let _e220: vec4<f32> = positionOS_1;
    let _e222: Attributes = attributes_27;
    let _e223: vec3<f32> = terrainProjectDetailPositionOS(_e220.xyz, _e222);
    detailPositionOS = _e223;
    let _e225: Attributes = attributes_27;
    let _e226: vec3<f32> = terrainProjectDetailOriginOS(_e225);
    detailOriginOS = _e226;
    let _e228: mat4x4<f32> = global_1.renderer_ModelMat;
    let _e229: vec3<f32> = detailPositionOS;
    homogeneousPositionWS = (_e228 * vec4<f32>(_e229.x, _e229.y, _e229.z, 1f));
    let _e237: vec4<f32> = homogeneousPositionWS;
    let _e239: vec4<f32> = homogeneousPositionWS;
    positionWS_6 = (_e237.xyz / vec3(_e239.w));
    let _e244: mat4x4<f32> = global_1.renderer_ModelMat;
    let _e245: vec3<f32> = detailOriginOS;
    homogeneousOriginWS = (_e244 * vec4<f32>(_e245.x, _e245.y, _e245.z, 1f));
    let _e253: vec4<f32> = homogeneousOriginWS;
    let _e255: vec4<f32> = homogeneousOriginWS;
    originWS_10 = (_e253.xyz / vec3(_e255.w));
    let _e260: vec3<f32> = positionWS_6;
    let _e261: vec3<f32> = originWS_10;
    let _e262: Attributes = attributes_27;
    let _e273: vec3<f32> = terrainProjectApplyVegetationWind(_e260, _e261, _e262, normalWS_1, tangentWS_1, windShadingResponse_1, groundWindDiagnostics_1, groundWindCarrierNormalWS_1);
    return _e273;
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
    let _e219: vec3<f32> = sh_1[0];
    let _e222: vec3<f32> = sh_1[1];
    let _e223: vec3<f32> = normal_1;
    let _e229: vec3<f32> = sh_1[2];
    let _e230: vec3<f32> = normal_1;
    let _e236: vec3<f32> = sh_1[3];
    let _e237: vec3<f32> = normal_1;
    let _e243: vec3<f32> = sh_1[4];
    let _e244: vec3<f32> = normal_1;
    let _e246: vec3<f32> = normal_1;
    let _e253: vec3<f32> = sh_1[5];
    let _e254: vec3<f32> = normal_1;
    let _e256: vec3<f32> = normal_1;
    let _e263: vec3<f32> = sh_1[6];
    let _e265: vec3<f32> = normal_1;
    let _e268: vec3<f32> = normal_1;
    let _e277: vec3<f32> = sh_1[7];
    let _e278: vec3<f32> = normal_1;
    let _e280: vec3<f32> = normal_1;
    let _e287: vec3<f32> = sh_1[8];
    let _e288: vec3<f32> = normal_1;
    let _e290: vec3<f32> = normal_1;
    let _e293: vec3<f32> = normal_1;
    let _e295: vec3<f32> = normal_1;
    result_1 = ((((((((_e219 + (_e222 * _e223.y)) + (_e229 * _e230.z)) + (_e236 * _e237.x)) + (_e243 * (_e244.y * _e246.x))) + (_e253 * (_e254.y * _e256.z))) + (_e263 * (((3f * _e265.z) * _e268.z) - 1f))) + (_e277 * (_e278.z * _e280.x))) + (_e287 * ((_e288.x * _e290.x) - (_e293.y * _e295.y))));
    let _e302: vec3<f32> = result_1;
    return max(_e302, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS_2: vec3<f32>) -> vec3<f32> {
    var normalWS_3: vec3<f32>;

    normalWS_3 = normalWS_2;
    let _e215: EnvMapLight = scene_EnvMapLight;
    return (_e215.diffuse * 3.1415927f);
}

fn VegetationVertex(attributes_28: Attributes) -> Varyings {
    var attributes_29: Attributes;
    var varyings: Varyings;
    var positionOS_2: vec4<f32>;
    var normalOS: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var proceduralTreeWindOriginOS_2: vec3<f32> = vec3(0f);
    var tangentWS_2: vec3<f32> = vec3(0f);
    var windShadingResponse_2: f32;
    var groundWindDiagnostics_2: vec3<f32>;
    var groundWindCarrierNormalWS_2: vec3<f32>;

    attributes_29 = attributes_28;
    let _e216: Attributes = attributes_29;
    positionOS_2 = vec4<f32>(_e216.POSITION.x, _e216.POSITION.y, _e216.POSITION.z, 1f);
    let _e232: vec3<f32> = normalOS;
    let _e237: f32 = global_1.material_LightingFlatness;
    normalOS = normalize(mix(_e232, vec3<f32>(0f, 1f, 0f), vec3(_e237)));
    let _e241: vec3<f32> = normalOS;
    let _e242: Attributes = attributes_29;
    let _e243: vec3<f32> = terrainProjectDetailNormalOS(_e241, _e242);
    normalOS = _e243;
    varyings.uv = vec2(0f);
    let _e254: mat4x4<f32> = global_1.renderer_NormalMat;
    let _e264: vec3<f32> = normalOS;
    varyings.normalWS = normalize((mat3x3<f32>(_e254[0].xyz, _e254[1].xyz, _e254[2].xyz) * _e264));
    let _e268: vec4<f32> = positionOS_2;
    let _e269: Attributes = attributes_29;
    let _e270: vec3<f32> = proceduralTreeWindOriginOS_2;
    let _e271: Varyings = varyings;
    var gs_output_arg0 = varyings.normalWS;
    let _e283: vec3<f32> = terrainProjectVegetationPositionWS(_e268, _e269, _e270, (&gs_output_arg0), (&tangentWS_2), (&windShadingResponse_2), (&groundWindDiagnostics_2), (&groundWindCarrierNormalWS_2));
    varyings.normalWS = gs_output_arg0;
    varyings.positionWS = _e283;
    let _e285: mat4x4<f32> = global_1.camera_VPMat;
    let _e286: Varyings = varyings;
    varyings.positionCS = (_e285 * vec4<f32>(_e286.positionWS.x, _e286.positionWS.y, _e286.positionWS.z, 1f));
    let _e295: Varyings = varyings;
    gl_Position = _e295.positionCS;
    let _e297: Varyings = varyings;
    return _e297;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e214: Attributes = read_Attributes();
    input_attributes = _e214;
    let _e216: Attributes = input_attributes;
    let _e217: Varyings = VegetationVertex(_e216);
    write_Varyings(_e217);
    return;
}

fn main_1() {
    let _e218: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e224: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e230: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e218.x), bitcast<f32>(_e224.y), bitcast<f32>(_e230.z));
    let _e238: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e238.w);
    let _e245: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e245.x);
    let _e252: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e252.y);
    let _e259: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e259.z);
    let _e266: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e266.w);
    gs_wgpu_main();
    let _e271: vec4<f32> = gl_Position;
    let _e273: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e271.z + _e273.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e228: vec2<f32> = uv;
    let _e230: vec3<f32> = positionWS_7;
    let _e232: vec3<f32> = normalWS_4;
    let _e234: vec4<f32> = positionCS;
    let _e236: vec4<f32> = gl_Position;
    return VertexOutput(_e228, _e230, _e232, _e234, _e236);
}
