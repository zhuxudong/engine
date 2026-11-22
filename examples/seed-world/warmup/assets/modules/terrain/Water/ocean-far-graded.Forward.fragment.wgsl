diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ViewMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
}

struct gs_Auto_1_ {
    camera_ProjMat: mat4x4<f32>,
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    material_WaterLevel: f32,
    material_OceanFarProjection: vec4<f32>,
    scene_SunlightColor: vec4<f32>,
    scene_SunlightDirection: vec3<f32>,
    material_EnvironmentReflectionParameters: vec4<f32>,
    material_EnvironmentFallbackIntensity: f32,
    material_EnvironmentReflectionMaximumMip: f32,
    material_EnvironmentReflectionAvailable: f32,
    material_AbsorptionCoefficient: vec3<f32>,
    material_ScatteringColor: vec3<f32>,
    material_ScatteringCoefficient: f32,
    material_IndexOfRefraction: f32,
    material_MaximumSurfaceOpticalDistance: f32,
    material_ReflectionIntensity: f32,
    material_Roughness: f32,
    material_NearshoreWorldToUv: vec4<f32>,
    material_NearshoreDecode: vec4<f32>,
    material_NearshoreOutsidePolicy: vec4<f32>,
    material_NearshoreCellSize: vec2<f32>,
    material_OceanDeepColor: vec4<f32>,
    material_OceanHorizonColor: vec4<f32>,
    material_OceanFarReflectionFilter: vec2<f32>,
}

struct WaterSurfaceEnvironmentLight {
    diffuse: vec3<f32>,
    mipMapLevel: f32,
    diffuseIntensity: f32,
    specularIntensity: f32,
}

struct gs_Auto_3_ {
    words: array<vec4<u32>, 2>,
}

struct Varyings {
    worldPosition: vec3<f32>,
    positionVS: vec3<f32>,
}

struct WaterSurfaceRawRefractionFactsV2_ {
    centeredSceneSample: vec3<f32>,
    displacedSceneSample: vec3<f32>,
    displacedSampleValidity: f32,
    depthWeight: f32,
    shoreValidity: f32,
    coverage: f32,
}

struct WaterSurfaceRawReflectionFactsV2_ {
    analyticSample: vec3<f32>,
    environmentSample: vec3<f32>,
    environmentValidity: f32,
    ssrPremultipliedSample: vec3<f32>,
    ssrValidity: f32,
}

struct WaterSurfaceRawFoamFactsV2_ {
    surfaceSignal: f32,
    shoreSignal: f32,
    crestSignal: f32,
    currentSignal: f32,
    wakeSignal: f32,
    contactSignal: f32,
    localSignal: f32,
    motionScale: f32,
    enabled: f32,
}

struct WaterSurfaceRawContributionPolicyV2_ {
    primaryColorClosureModel: f32,
    refractionEnabled: f32,
    clarity: f32,
    boundaryRefractionSuppression: f32,
    reflectionSource: f32,
    ssrCompositeIntensity: f32,
    foamIntensity: f32,
}

struct WaterSurfaceResolvedRawContributionsV2_ {
    refractionSceneColor: vec3<f32>,
    refractionWeight: f32,
    reflectionRadiance: vec3<f32>,
    foamWeight: f32,
}

struct WaterSurfaceFinalClosureV2Input {
    additionalTransmissionRadiance: vec3<f32>,
    primarySceneColor: vec3<f32>,
    surfaceColor: vec3<f32>,
    depthColor: vec3<f32>,
    depthFactor: f32,
    diffuseLighting: vec3<f32>,
    primaryColorClosureModel: f32,
    absorptionCoefficient: vec3<f32>,
    scatteringColor: vec3<f32>,
    scatteringCoefficient: f32,
    opticalDepth: f32,
    refractionColor: vec3<f32>,
    refractionWeight: f32,
    reflectionRadiance: vec3<f32>,
    fresnelF0_: f32,
    perceptualRoughness: f32,
    normalDotView: f32,
    transmissionFresnelWeight: f32,
    reflectionIntensity: f32,
    directSpecularRadiance: vec3<f32>,
    boundaryColor: vec3<f32>,
    foamColor: vec3<f32>,
    foamWeight: f32,
    baseAlpha: f32,
    clarity: f32,
    coastalAlpha: f32,
    coastalAlphaWeight: f32,
    coverage: f32,
    compositionSceneColor: vec3<f32>,
    precomposedReplace: f32,
}

struct FragmentOutput {
    @location(0) output_color: vec4<f32>,
}

const WATER_SURFACE_AMBIENT_PI: f32 = 3.1415927f;

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> output_color: vec4<f32>;
@group(2) @binding(2) 
var gs_wgpu_tex_material_ReflectionCubeTexture: texture_cube<f32>;
@group(2) @binding(3) 
var gs_wgpu_samp_material_ReflectionCubeTexture: sampler;
@group(2) @binding(4) 
var<uniform> gs_wgpu_data_2_: gs_Auto_3_;
var<private> scene_EnvMapLight: WaterSurfaceEnvironmentLight;
@group(2) @binding(5) 
var gs_wgpu_tex_material_NearshoreTexture: texture_2d<f32>;
@group(2) @binding(6) 
var gs_wgpu_samp_material_NearshoreTexture: sampler;
var<private> worldPosition_3: vec3<f32>;
var<private> positionVS_3: vec3<f32>;

fn waterOceanApplySceneFog(color: vec4<f32>, positionVS_1: vec3<f32>) -> vec4<f32> {
    var color_1: vec4<f32>;
    var positionVS_2: vec3<f32>;

    color_1 = color;
    positionVS_2 = positionVS_1;
    let _e67: vec4<f32> = color_1;
    return _e67;
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e67: vec3<f32> = worldPosition_3;
    interface_value.worldPosition = _e67;
    let _e69: vec3<f32> = positionVS_3;
    interface_value.positionVS = _e69;
    let _e70: Varyings = interface_value;
    return _e70;
}

fn waterSurfaceAmbientDiffuseRadiance(normalWS: vec3<f32>) -> vec3<f32> {
    var normalWS_1: vec3<f32>;
    var ambientIrradiance: vec3<f32>;

    normalWS_1 = normalWS;
    let _e68: WaterSurfaceEnvironmentLight = scene_EnvMapLight;
    ambientIrradiance = (_e68.diffuse * WATER_SURFACE_AMBIENT_PI);
    let _e72: vec3<f32> = ambientIrradiance;
    let _e73: WaterSurfaceEnvironmentLight = scene_EnvMapLight;
    return ((_e72 * max(_e73.diffuseIntensity, 0f)) / vec3(3.1415927f));
}

fn waterSpatialFieldDecodeSignedDistance(encodedDistance: f32, decodeScale: f32, decodeBias: f32, signedDistanceRange: f32) -> f32 {
    var encodedDistance_1: f32;
    var decodeScale_1: f32;
    var decodeBias_1: f32;
    var signedDistanceRange_1: f32;

    encodedDistance_1 = encodedDistance;
    decodeScale_1 = decodeScale;
    decodeBias_1 = decodeBias;
    signedDistanceRange_1 = signedDistanceRange;
    let _e74: f32 = encodedDistance_1;
    let _e75: f32 = decodeScale_1;
    let _e77: f32 = decodeBias_1;
    let _e79: f32 = signedDistanceRange_1;
    return (((_e74 * _e75) + _e77) * _e79);
}

fn waterConnectionFacts(p: vec2<f32>) -> vec4<f32> {
    var p_1: vec2<f32>;
    var result: vec4<f32> = vec4<f32>(1f, 1f, -1f, 1f);

    p_1 = p;
    let _e75: vec4<f32> = result;
    return _e75;
}

fn waterConnectionShore(p_2: vec2<f32>, original: f32) -> f32 {
    var p_3: vec2<f32>;
    var original_1: f32;
    var result_1: f32;

    p_3 = p_2;
    original_1 = original;
    let _e70: f32 = original_1;
    result_1 = _e70;
    let _e72: f32 = result_1;
    return _e72;
}

fn waterSurfaceSchlick(f0_: f32, f90_: f32, dotLH: f32) -> f32 {
    var f0_1: f32;
    var f90_1: f32;
    var dotLH_1: f32;
    var boundedF0_: f32;
    var boundedF90_: f32;

    f0_1 = f0_;
    f90_1 = f90_;
    dotLH_1 = dotLH;
    let _e72: f32 = f0_1;
    boundedF0_ = clamp(_e72, 0f, 1f);
    let _e77: f32 = f90_1;
    boundedF90_ = clamp(_e77, 0f, 1f);
    let _e82: f32 = boundedF0_;
    let _e83: f32 = boundedF90_;
    let _e84: f32 = boundedF0_;
    let _e87: f32 = dotLH_1;
    return (_e82 + ((_e83 - _e84) * pow((1f - clamp(_e87, 0f, 1f)), 5f)));
}

fn waterSurfaceEnvironmentDfg(perceptualRoughness: f32, dotNV: f32) -> vec2<f32> {
    var perceptualRoughness_1: f32;
    var dotNV_1: f32;
    var c0_: vec4<f32> = vec4<f32>(-1f, -0.0275f, -0.572f, 0.022f);
    var c1_: vec4<f32> = vec4<f32>(1f, 0.0425f, 1.04f, -0.04f);
    var r: vec4<f32>;
    var a004_: f32;

    perceptualRoughness_1 = perceptualRoughness;
    dotNV_1 = dotNV;
    let _e86: f32 = perceptualRoughness_1;
    let _e90: vec4<f32> = c0_;
    let _e92: vec4<f32> = c1_;
    r = ((clamp(_e86, 0f, 1f) * _e90) + _e92);
    let _e95: vec4<f32> = r;
    let _e97: vec4<f32> = r;
    let _e102: f32 = dotNV_1;
    let _e109: vec4<f32> = r;
    let _e112: vec4<f32> = r;
    a004_ = ((min((_e95.x * _e97.x), exp2((-9.28f * clamp(_e102, 0f, 1f)))) * _e109.x) + _e112.y);
    let _e120: f32 = a004_;
    let _e122: vec4<f32> = r;
    return ((vec2<f32>(-1.04f, 1.04f) * _e120) + _e122.zw);
}

fn waterSurfaceEnvironmentSpecularWeight(f0_2: f32, perceptualRoughness_2: f32, dotNV_2: f32) -> vec3<f32> {
    var f0_3: f32;
    var perceptualRoughness_3: f32;
    var dotNV_3: f32;
    var dfg: vec2<f32>;

    f0_3 = f0_2;
    perceptualRoughness_3 = perceptualRoughness_2;
    dotNV_3 = dotNV_2;
    let _e72: f32 = perceptualRoughness_3;
    let _e73: f32 = dotNV_3;
    let _e74: vec2<f32> = waterSurfaceEnvironmentDfg(_e72, _e73);
    dfg = _e74;
    let _e76: f32 = f0_3;
    let _e77: vec2<f32> = dfg;
    let _e80: vec2<f32> = dfg;
    return vec3(((_e76 * _e77.x) + _e80.y));
}

fn waterSurfaceResolveAnalyticReflectionFallbackV2_(normalY: f32, perceptualRoughness_4: f32, environmentIntensity: f32) -> vec3<f32> {
    var normalY_1: f32;
    var perceptualRoughness_5: f32;
    var environmentIntensity_1: f32;

    normalY_1 = normalY;
    perceptualRoughness_5 = perceptualRoughness_4;
    environmentIntensity_1 = environmentIntensity;
    let _e80: f32 = normalY_1;
    let _e89: f32 = perceptualRoughness_5;
    let _e96: f32 = environmentIntensity_1;
    return (mix(vec3<f32>(0.075f, 0.16f, 0.21f), vec3<f32>(0.32f, 0.48f, 0.57f), vec3(mix(clamp(((_e80 * 0.5f) + 0.5f), 0f, 1f), 0.5f, clamp(_e89, 0f, 1f)))) * max(_e96, 0f));
}

fn waterSurfaceResolveRawFoamWeightV2_(foam: WaterSurfaceRawFoamFactsV2_, policy: WaterSurfaceRawContributionPolicyV2_) -> f32 {
    var foam_1: WaterSurfaceRawFoamFactsV2_;
    var policy_1: WaterSurfaceRawContributionPolicyV2_;
    var proceduralSignal: f32;
    var foamSignal: f32;

    foam_1 = foam;
    policy_1 = policy;
    let _e70: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e72: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e75: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e79: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e85: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e88: WaterSurfaceRawFoamFactsV2_ = foam_1;
    proceduralSignal = (max(max(max(_e70.surfaceSignal, _e72.shoreSignal), ((_e75.crestSignal * 0.68f) + (_e79.currentSignal * 0.32f))), _e85.wakeSignal) * max(_e88.motionScale, 0f));
    let _e94: f32 = proceduralSignal;
    let _e97: WaterSurfaceRawContributionPolicyV2_ = policy_1;
    let _e102: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e108: WaterSurfaceRawFoamFactsV2_ = foam_1;
    foamSignal = clamp((max((max(_e94, 0f) * max(_e97.foamIntensity, 0f)), max(_e102.localSignal, 0f)) * step(0.5f, _e108.enabled)), 0f, 1f);
    let _e118: f32 = foamSignal;
    let _e120: WaterSurfaceRawFoamFactsV2_ = foam_1;
    return max(smoothstep(0.02f, 0.78f, _e118), clamp(_e120.contactSignal, 0f, 1f));
}

fn waterSurfaceResolveRawContributionsV2_(refraction: WaterSurfaceRawRefractionFactsV2_, reflection: WaterSurfaceRawReflectionFactsV2_, foamWeight: f32, policy_2: WaterSurfaceRawContributionPolicyV2_) -> WaterSurfaceResolvedRawContributionsV2_ {
    var refraction_1: WaterSurfaceRawRefractionFactsV2_;
    var reflection_1: WaterSurfaceRawReflectionFactsV2_;
    var foamWeight_1: f32;
    var policy_3: WaterSurfaceRawContributionPolicyV2_;
    var resolved: WaterSurfaceResolvedRawContributionsV2_;
    var displacedValidity: f32;
    var environment: vec3<f32>;
    var ssrScale: f32;
    var ssrBlend: f32;

    refraction_1 = refraction;
    reflection_1 = reflection;
    foamWeight_1 = foamWeight;
    policy_3 = policy_2;
    let _e76: f32 = foamWeight_1;
    resolved.foamWeight = clamp(_e76, 0f, 1f);
    let _e80: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e83: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    displacedValidity = clamp((_e80.displacedSampleValidity * step(0.5f, _e83.refractionEnabled)), 0f, 1f);
    let _e92: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e94: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e96: f32 = displacedValidity;
    resolved.refractionSceneColor = mix(_e92.centeredSceneSample, _e94.displacedSceneSample, vec3(_e96));
    let _e102: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    let _e106: f32 = displacedValidity;
    let _e108: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e114: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e120: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e126: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    let _e133: WaterSurfaceResolvedRawContributionsV2_ = resolved;
    let _e140: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    resolved.refractionWeight = clamp(((((((((1f - step(1.5f, _e102.primaryColorClosureModel)) * _e106) * clamp(_e108.depthWeight, 0f, 1f)) * clamp(_e114.shoreValidity, 0f, 1f)) * clamp(_e120.coverage, 0f, 1f)) * clamp(_e126.clarity, 0f, 1f)) * (1f - (_e133.foamWeight * 0.94f))) * (1f - clamp(_e140.boundaryRefractionSuppression, 0f, 1f))), 0f, 1f);
    let _e150: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    let _e152: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    let _e154: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    environment = mix(_e150.analyticSample, _e152.environmentSample, vec3(clamp(_e154.environmentValidity, 0f, 1f)));
    let _e163: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    resolved.reflectionRadiance = _e163.analyticSample;
    let _e165: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    if (_e165.reflectionSource > 2.5f) {
        {
            let _e169: WaterSurfaceRawContributionPolicyV2_ = policy_3;
            ssrScale = clamp(_e169.ssrCompositeIntensity, 0f, 1f);
            let _e175: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
            let _e177: f32 = ssrScale;
            ssrBlend = clamp((_e175.ssrValidity * _e177), 0f, 1f);
            let _e184: vec3<f32> = environment;
            let _e186: f32 = ssrBlend;
            let _e189: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
            let _e191: f32 = ssrScale;
            resolved.reflectionRadiance = ((_e184 * (1f - _e186)) + (_e189.ssrPremultipliedSample * _e191));
        }
    } else {
        let _e194: WaterSurfaceRawContributionPolicyV2_ = policy_3;
        if (_e194.reflectionSource > 0.5f) {
            {
                let _e199: vec3<f32> = environment;
                resolved.reflectionRadiance = _e199;
            }
        }
    }
    let _e200: WaterSurfaceResolvedRawContributionsV2_ = resolved;
    return _e200;
}

fn waterSurfaceResolvePrimaryColor(sceneColor: vec3<f32>, surfaceColor: vec3<f32>, depthColor: vec3<f32>, depthFactor: f32, diffuseLighting: vec3<f32>, closureModel: f32) -> vec3<f32> {
    var sceneColor_1: vec3<f32>;
    var surfaceColor_1: vec3<f32>;
    var depthColor_1: vec3<f32>;
    var depthFactor_1: f32;
    var diffuseLighting_1: vec3<f32>;
    var closureModel_1: f32;
    var stylized: vec3<f32>;
    var litScene: vec3<f32>;
    var sceneCompositeWater: vec3<f32>;
    var local: vec3<f32>;
    var local_1: vec3<f32>;
    var local_2: vec3<f32>;

    sceneColor_1 = sceneColor;
    surfaceColor_1 = surfaceColor;
    depthColor_1 = depthColor;
    depthFactor_1 = depthFactor;
    diffuseLighting_1 = diffuseLighting;
    closureModel_1 = closureModel;
    let _e78: f32 = closureModel_1;
    if (_e78 > 3.5f) {
        {
            let _e81: vec3<f32> = sceneColor_1;
            let _e82: vec3<f32> = depthColor_1;
            let _e83: f32 = depthFactor_1;
            let _e89: vec3<f32> = diffuseLighting_1;
            return (mix(_e81, _e82, vec3(clamp(_e83, 0f, 1f))) * max(_e89, vec3(0f)));
        }
    }
    let _e94: vec3<f32> = surfaceColor_1;
    let _e95: vec3<f32> = depthColor_1;
    let _e96: vec3<f32> = diffuseLighting_1;
    let _e101: f32 = depthFactor_1;
    stylized = mix(_e94, (_e95 * max(_e96, vec3(0f))), vec3(clamp(_e101, 0f, 1f)));
    let _e108: vec3<f32> = sceneColor_1;
    let _e114: vec3<f32> = depthColor_1;
    let _e115: vec3<f32> = diffuseLighting_1;
    let _e120: f32 = depthFactor_1;
    litScene = mix(clamp(_e108, vec3(0f), vec3(1f)), (_e114 * max(_e115, vec3(0f))), vec3(clamp(_e120, 0f, 1f)));
    let _e127: vec3<f32> = surfaceColor_1;
    let _e128: vec3<f32> = depthColor_1;
    let _e129: f32 = depthFactor_1;
    let _e135: vec3<f32> = diffuseLighting_1;
    sceneCompositeWater = (mix(_e127, _e128, vec3(clamp(_e129, 0f, 1f))) * max(_e135, vec3(0f)));
    let _e141: f32 = closureModel_1;
    if (_e141 > 2.5f) {
        let _e144: vec3<f32> = sceneCompositeWater;
        local_2 = _e144;
    } else {
        let _e145: f32 = closureModel_1;
        if (_e145 > 1.5f) {
            let _e148: vec3<f32> = litScene;
            local_1 = _e148;
        } else {
            let _e149: f32 = closureModel_1;
            if (_e149 > 0.5f) {
                let _e152: vec3<f32> = stylized;
                local = _e152;
            } else {
                let _e153: vec3<f32> = surfaceColor_1;
                local = _e153;
            }
            let _e155: vec3<f32> = local;
            local_1 = _e155;
        }
        let _e157: vec3<f32> = local_1;
        local_2 = _e157;
    }
    let _e159: vec3<f32> = local_2;
    return _e159;
}

fn waterSurfaceOpticalTransmittance(absorptionCoefficient: vec3<f32>, opticalDepth: f32) -> vec3<f32> {
    var absorptionCoefficient_1: vec3<f32>;
    var opticalDepth_1: f32;

    absorptionCoefficient_1 = absorptionCoefficient;
    opticalDepth_1 = opticalDepth;
    let _e70: vec3<f32> = absorptionCoefficient_1;
    let _e75: f32 = opticalDepth_1;
    return exp((-(max(_e70, vec3(0f))) * max(_e75, 0f)));
}

fn waterSurfaceOpticalScattering(scatteringColor: vec3<f32>, scatteringCoefficient: f32, opticalDepth_2: f32) -> vec3<f32> {
    var scatteringColor_1: vec3<f32>;
    var scatteringCoefficient_1: f32;
    var opticalDepth_3: f32;
    var weight: f32;

    scatteringColor_1 = scatteringColor;
    scatteringCoefficient_1 = scatteringCoefficient;
    opticalDepth_3 = opticalDepth_2;
    let _e73: f32 = scatteringCoefficient_1;
    let _e77: f32 = opticalDepth_3;
    weight = (1f - exp((-(max(_e73, 0f)) * max(_e77, 0f))));
    let _e84: vec3<f32> = scatteringColor_1;
    let _e88: f32 = weight;
    return (max(_e84, vec3(0f)) * _e88);
}

fn waterSurfaceApplyOpticalVolume(surfaceColor_2: vec3<f32>, absorptionCoefficient_2: vec3<f32>, scatteringColor_2: vec3<f32>, scatteringCoefficient_2: f32, opticalDepth_4: f32) -> vec3<f32> {
    var surfaceColor_3: vec3<f32>;
    var absorptionCoefficient_3: vec3<f32>;
    var scatteringColor_3: vec3<f32>;
    var scatteringCoefficient_3: f32;
    var opticalDepth_5: f32;

    surfaceColor_3 = surfaceColor_2;
    absorptionCoefficient_3 = absorptionCoefficient_2;
    scatteringColor_3 = scatteringColor_2;
    scatteringCoefficient_3 = scatteringCoefficient_2;
    opticalDepth_5 = opticalDepth_4;
    let _e76: vec3<f32> = surfaceColor_3;
    let _e77: vec3<f32> = absorptionCoefficient_3;
    let _e78: f32 = opticalDepth_5;
    let _e79: vec3<f32> = waterSurfaceOpticalTransmittance(_e77, _e78);
    let _e81: vec3<f32> = scatteringColor_3;
    let _e82: f32 = scatteringCoefficient_3;
    let _e83: f32 = opticalDepth_5;
    let _e84: vec3<f32> = waterSurfaceOpticalScattering(_e81, _e82, _e83);
    return ((_e76 * _e79) + _e84);
}

fn waterSurfaceComposeFinal(color_2: vec3<f32>, alpha: f32, precomposedReplace: f32) -> vec4<f32> {
    var color_3: vec3<f32>;
    var alpha_1: f32;
    var precomposedReplace_1: f32;

    color_3 = color_2;
    alpha_1 = alpha;
    precomposedReplace_1 = precomposedReplace;
    let _e72: vec3<f32> = color_3;
    let _e73: f32 = alpha_1;
    let _e79: f32 = precomposedReplace_1;
    return vec4<f32>(_e72.x, _e72.y, _e72.z, mix(clamp(_e73, 0f, 1f), 1f, step(0.5f, _e79)));
}

fn waterSurfaceResolveAlphaV2_(baseAlpha: f32, clarity: f32, opticalDepth_6: f32, fresnel: f32, foamWeight_2: f32, coastalAlpha: f32, coastalAlphaWeight: f32) -> f32 {
    var baseAlpha_1: f32;
    var clarity_1: f32;
    var opticalDepth_7: f32;
    var fresnel_1: f32;
    var foamWeight_3: f32;
    var coastalAlpha_1: f32;
    var coastalAlphaWeight_1: f32;
    var absorptionAlpha: f32;
    var alpha_2: f32;

    baseAlpha_1 = baseAlpha;
    clarity_1 = clarity;
    opticalDepth_7 = opticalDepth_6;
    fresnel_1 = fresnel;
    foamWeight_3 = foamWeight_2;
    coastalAlpha_1 = coastalAlpha;
    coastalAlphaWeight_1 = coastalAlphaWeight;
    let _e83: f32 = clarity_1;
    let _e89: f32 = opticalDepth_7;
    absorptionAlpha = (1f - exp((-(mix(0.48f, 0.13f, clamp(_e83, 0f, 1f))) * max(_e89, 0f))));
    let _e96: f32 = baseAlpha_1;
    let _e99: f32 = absorptionAlpha;
    alpha_2 = (_e96 * mix(0.18f, 0.94f, _e99));
    let _e103: f32 = alpha_2;
    let _e104: f32 = fresnel_1;
    let _e109: f32 = alpha_2;
    alpha_2 = (_e103 + ((clamp(_e104, 0f, 1f) * (1f - _e109)) * 0.48f));
    let _e115: f32 = alpha_2;
    let _e116: f32 = foamWeight_3;
    alpha_2 = (_e115 + (clamp(_e116, 0f, 1f) * 0.3f));
    let _e123: f32 = alpha_2;
    let _e124: f32 = coastalAlpha_1;
    let _e125: f32 = coastalAlphaWeight_1;
    alpha_2 = mix(_e123, _e124, clamp(_e125, 0f, 1f));
    let _e130: f32 = alpha_2;
    return clamp(_e130, 0f, 1f);
}

fn waterSurfaceEvaluateFinalClosureV2_(closure: WaterSurfaceFinalClosureV2Input, foamColorWeight: f32, depthOpacity: f32) -> vec4<f32> {
    var closure_1: WaterSurfaceFinalClosureV2Input;
    var foamColorWeight_1: f32;
    var depthOpacity_1: f32;
    var fresnel_2: f32;
    var primaryColor: vec3<f32>;
    var baseColor: vec3<f32>;
    var refractionMix: f32 = 0f;
    var resolvedRefractionColor: vec3<f32>;
    var local_3: vec3<f32>;
    var color_4: vec3<f32>;
    var boundaryContribution: vec3<f32>;
    var litSceneColorClosure: f32;
    var transmissionFresnel: f32;
    var reflectionBrdfWeight: vec3<f32>;
    var litFoamColor: vec3<f32>;
    var sceneColorCompositeClosure: f32;
    var sceneCompositeWeight: f32;
    var alpha_3: f32;
    var replace: f32;

    closure_1 = closure;
    foamColorWeight_1 = foamColorWeight;
    depthOpacity_1 = depthOpacity;
    let _e72: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e75: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e77: f32 = waterSurfaceSchlick(_e72.fresnelF0_, 1f, _e75.normalDotView);
    fresnel_2 = _e77;
    let _e79: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e81: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e83: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e85: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e87: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e89: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e91: vec3<f32> = waterSurfaceResolvePrimaryColor(_e79.primarySceneColor, _e81.surfaceColor, _e83.depthColor, _e85.depthFactor, _e87.diffuseLighting, _e89.primaryColorClosureModel);
    primaryColor = _e91;
    let _e93: vec3<f32> = primaryColor;
    baseColor = _e93;
    let _e97: WaterSurfaceFinalClosureV2Input = closure_1;
    resolvedRefractionColor = _e97.refractionColor;
    let _e100: WaterSurfaceFinalClosureV2Input = closure_1;
    if (_e100.primaryColorClosureModel < 0.5f) {
        {
            let _e104: vec3<f32> = primaryColor;
            let _e105: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e107: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e109: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e111: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e113: vec3<f32> = waterSurfaceApplyOpticalVolume(_e104, _e105.absorptionCoefficient, _e107.scatteringColor, _e109.scatteringCoefficient, _e111.opticalDepth);
            baseColor = _e113;
            let _e114: WaterSurfaceFinalClosureV2Input = closure_1;
            refractionMix = clamp(_e114.refractionWeight, 0f, 1f);
            let _e119: f32 = refractionMix;
            if (_e119 > 0f) {
                {
                    let _e122: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e124: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e126: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e128: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e130: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e132: vec3<f32> = waterSurfaceApplyOpticalVolume(_e122.refractionColor, _e124.absorptionCoefficient, _e126.scatteringColor, _e128.scatteringCoefficient, _e130.opticalDepth);
                    resolvedRefractionColor = _e132;
                }
            }
        }
    } else {
        let _e133: WaterSurfaceFinalClosureV2Input = closure_1;
        if (_e133.primaryColorClosureModel < 1.5f) {
            {
                let _e137: WaterSurfaceFinalClosureV2Input = closure_1;
                refractionMix = clamp(_e137.refractionWeight, 0f, 1f);
            }
        }
    }
    let _e142: f32 = refractionMix;
    if (_e142 > 0f) {
        let _e145: vec3<f32> = baseColor;
        let _e146: vec3<f32> = resolvedRefractionColor;
        let _e147: f32 = refractionMix;
        local_3 = mix(_e145, _e146, vec3(_e147));
    } else {
        let _e150: vec3<f32> = baseColor;
        local_3 = _e150;
    }
    let _e152: vec3<f32> = local_3;
    color_4 = _e152;
    let _e154: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e156: WaterSurfaceFinalClosureV2Input = closure_1;
    boundaryContribution = (_e154.boundaryColor * max(_e156.diffuseLighting, vec3(0f)));
    let _e164: WaterSurfaceFinalClosureV2Input = closure_1;
    litSceneColorClosure = step(1.5f, _e164.primaryColorClosureModel);
    let _e168: vec3<f32> = color_4;
    let _e169: vec3<f32> = boundaryContribution;
    let _e170: f32 = litSceneColorClosure;
    color_4 = (_e168 + (_e169 * _e170));
    let _e173: vec3<f32> = color_4;
    let _e174: WaterSurfaceFinalClosureV2Input = closure_1;
    color_4 = (_e173 + _e174.additionalTransmissionRadiance);
    let _e177: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e179: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e181: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e183: vec3<f32> = waterSurfaceEnvironmentSpecularWeight(_e177.fresnelF0_, _e179.perceptualRoughness, _e181.normalDotView);
    transmissionFresnel = clamp(_e183.x, 0f, 1f);
    let _e189: vec3<f32> = color_4;
    let _e192: f32 = transmissionFresnel;
    let _e194: WaterSurfaceFinalClosureV2Input = closure_1;
    color_4 = (_e189 * mix(1f, (1f - _e192), clamp(_e194.transmissionFresnelWeight, 0f, 1f)));
    let _e201: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e203: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e205: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e207: vec3<f32> = waterSurfaceEnvironmentSpecularWeight(_e201.fresnelF0_, _e203.perceptualRoughness, _e205.normalDotView);
    reflectionBrdfWeight = _e207;
    let _e209: vec3<f32> = color_4;
    let _e210: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e212: vec3<f32> = reflectionBrdfWeight;
    let _e214: WaterSurfaceFinalClosureV2Input = closure_1;
    color_4 = (_e209 + ((_e210.reflectionRadiance * _e212) * max(_e214.reflectionIntensity, 0f)));
    let _e220: vec3<f32> = color_4;
    let _e221: WaterSurfaceFinalClosureV2Input = closure_1;
    color_4 = (_e220 + _e221.directSpecularRadiance);
    let _e224: vec3<f32> = color_4;
    let _e225: vec3<f32> = boundaryContribution;
    let _e227: f32 = litSceneColorClosure;
    color_4 = (_e224 + (_e225 * (1f - _e227)));
    let _e231: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e233: WaterSurfaceFinalClosureV2Input = closure_1;
    litFoamColor = (_e231.foamColor * max(_e233.diffuseLighting, vec3(0f)));
    let _e240: vec3<f32> = color_4;
    let _e241: vec3<f32> = litFoamColor;
    let _e242: f32 = foamColorWeight_1;
    color_4 = mix(_e240, _e241, vec3(clamp(_e242, 0f, 1f)));
    let _e249: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e254: WaterSurfaceFinalClosureV2Input = closure_1;
    sceneColorCompositeClosure = (step(2.5f, _e249.primaryColorClosureModel) * (1f - step(3.5f, _e254.primaryColorClosureModel)));
    let _e260: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e262: f32 = depthOpacity_1;
    let _e267: f32 = foamColorWeight_1;
    let _e272: WaterSurfaceFinalClosureV2Input = closure_1;
    sceneCompositeWeight = (clamp(((_e260.depthFactor * clamp(_e262, 0f, 1f)) + _e267), 0f, 1f) * clamp(_e272.coverage, 0f, 1f));
    let _e279: vec3<f32> = color_4;
    let _e280: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e282: vec3<f32> = color_4;
    let _e283: f32 = sceneCompositeWeight;
    let _e286: f32 = sceneColorCompositeClosure;
    color_4 = mix(_e279, mix(_e280.primarySceneColor, _e282, vec3(_e283)), vec3(_e286));
    let _e289: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e291: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e293: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e295: f32 = fresnel_2;
    let _e296: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e298: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e300: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e302: f32 = waterSurfaceResolveAlphaV2_(_e289.baseAlpha, _e291.clarity, _e293.opticalDepth, _e295, _e296.foamWeight, _e298.coastalAlpha, _e300.coastalAlphaWeight);
    let _e303: WaterSurfaceFinalClosureV2Input = closure_1;
    alpha_3 = (_e302 * clamp(_e303.coverage, 0f, 1f));
    let _e311: WaterSurfaceFinalClosureV2Input = closure_1;
    replace = step(0.5f, _e311.precomposedReplace);
    let _e315: vec3<f32> = color_4;
    let _e316: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e318: vec3<f32> = color_4;
    let _e319: f32 = alpha_3;
    let _e322: f32 = replace;
    let _e324: f32 = sceneColorCompositeClosure;
    color_4 = mix(_e315, mix(_e316.compositionSceneColor, _e318, vec3(_e319)), vec3((_e322 * (1f - _e324))));
    let _e329: vec3<f32> = color_4;
    let _e330: f32 = alpha_3;
    let _e331: f32 = replace;
    let _e332: vec4<f32> = waterSurfaceComposeFinal(_e329, _e330, _e331);
    return _e332;
}

fn waterSurfaceEvaluateFinalClosureV2_1(closure_2: WaterSurfaceFinalClosureV2Input, foamColorWeight_2: f32) -> vec4<f32> {
    var closure_3: WaterSurfaceFinalClosureV2Input;
    var foamColorWeight_3: f32;

    closure_3 = closure_2;
    foamColorWeight_3 = foamColorWeight_2;
    let _e70: WaterSurfaceFinalClosureV2Input = closure_3;
    let _e71: f32 = foamColorWeight_3;
    let _e73: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_(_e70, _e71, 1f);
    return _e73;
}

fn waterSurfaceEvaluateFinalClosureV2_2(closure_4: WaterSurfaceFinalClosureV2Input) -> vec4<f32> {
    var closure_5: WaterSurfaceFinalClosureV2Input;

    closure_5 = closure_4;
    let _e68: WaterSurfaceFinalClosureV2Input = closure_5;
    let _e69: WaterSurfaceFinalClosureV2Input = closure_5;
    let _e71: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_1(_e68, _e69.foamWeight);
    return _e71;
}

fn waterSurfaceOutputWithPick(color_5: vec4<f32>) -> vec4<f32> {
    var color_6: vec4<f32>;

    color_6 = color_5;
    let _e68: vec4<f32> = color_6;
    return _e68;
}

fn oceanFarFieldSafeNormalize(value: vec3<f32>, fallbackValue: vec3<f32>) -> vec3<f32> {
    var value_1: vec3<f32>;
    var fallbackValue_1: vec3<f32>;
    var lengthSquared: f32;
    var local_4: vec3<f32>;

    value_1 = value;
    fallbackValue_1 = fallbackValue;
    let _e70: vec3<f32> = value_1;
    let _e71: vec3<f32> = value_1;
    lengthSquared = dot(_e70, _e71);
    let _e74: f32 = lengthSquared;
    if (_e74 > 0.00000001f) {
        let _e77: vec3<f32> = value_1;
        let _e78: f32 = lengthSquared;
        local_4 = (_e77 * inverseSqrt(_e78));
    } else {
        let _e81: vec3<f32> = fallbackValue_1;
        local_4 = _e81;
    }
    let _e83: vec3<f32> = local_4;
    return _e83;
}

fn oceanFarFieldSrgbToLinear(color_7: vec3<f32>) -> vec3<f32> {
    var color_8: vec3<f32>;
    var low: vec3<f32>;
    var high: vec3<f32>;

    color_8 = color_7;
    let _e68: vec3<f32> = color_8;
    low = (_e68 / vec3(12.92f));
    let _e73: vec3<f32> = color_8;
    high = pow(max(((_e73 + vec3(0.055f)) / vec3(1.055f)), vec3(0f)), vec3(2.4f));
    let _e87: vec3<f32> = low;
    let _e88: vec3<f32> = high;
    let _e91: vec3<f32> = color_8;
    return mix(_e87, _e88, step(vec3(0.04045f), _e91));
}

fn oceanFarReflectionDirection(viewDirection: vec3<f32>) -> vec3<f32> {
    var viewDirection_1: vec3<f32>;
    var direction: vec3<f32>;

    viewDirection_1 = viewDirection;
    let _e68: vec3<f32> = viewDirection_1;
    direction = reflect(-(_e68), vec3<f32>(0f, 1f, 0f));
    let _e77: vec3<f32> = direction;
    let _e79: vec3<f32> = direction;
    let _e83: vec2<f32> = global_1.material_OceanFarReflectionFilter;
    direction.y = sqrt(((_e77.y * _e79.y) + (4f * _e83.y)));
    let _e88: vec3<f32> = direction;
    return normalize(_e88);
}

fn oceanFarReflectionNormalDotView(viewDirection_2: vec3<f32>) -> f32 {
    var viewDirection_3: vec3<f32>;
    var normalDotView: f32;
    var positiveSlopeMeanSquared: f32;

    viewDirection_3 = viewDirection_2;
    let _e68: vec3<f32> = viewDirection_3;
    normalDotView = clamp(_e68.y, 0f, 1f);
    let _e74: vec2<f32> = global_1.material_OceanFarReflectionFilter;
    positiveSlopeMeanSquared = (_e74.y * 0.15915494f);
    let _e79: f32 = normalDotView;
    let _e80: f32 = normalDotView;
    let _e82: f32 = positiveSlopeMeanSquared;
    return clamp(sqrt(((_e79 * _e80) + _e82)), 0f, 1f);
}

fn sampleOceanFarFieldReflection(analyticFallback: vec3<f32>, directionWS: vec3<f32>) -> vec3<f32> {
    var analyticFallback_1: vec3<f32>;
    var directionWS_1: vec3<f32>;
    var rotation: vec2<f32>;
    var sampleDirection: vec3<f32>;
    var mipLevel: f32;
    var reflectedRadiance: vec3<f32>;

    analyticFallback_1 = analyticFallback;
    directionWS_1 = directionWS;
    let _e70: f32 = global_1.material_EnvironmentReflectionAvailable;
    if (_e70 < 0.5f) {
        let _e73: vec3<f32> = analyticFallback_1;
        return _e73;
    }
    let _e74: vec4<f32> = global_1.material_EnvironmentReflectionParameters;
    rotation = _e74.xy;
    let _e77: vec2<f32> = rotation;
    let _e79: vec3<f32> = directionWS_1;
    let _e82: vec2<f32> = rotation;
    let _e84: vec3<f32> = directionWS_1;
    let _e88: vec3<f32> = directionWS_1;
    let _e90: vec2<f32> = rotation;
    let _e93: vec3<f32> = directionWS_1;
    let _e96: vec2<f32> = rotation;
    let _e98: vec3<f32> = directionWS_1;
    sampleDirection = vec3<f32>(((_e77.x * _e79.x) + (_e82.y * _e84.z)), _e88.y, ((-(_e90.y) * _e93.x) + (_e96.x * _e98.z)));
    let _e104: vec2<f32> = global_1.material_OceanFarReflectionFilter;
    let _e109: f32 = global_1.material_EnvironmentReflectionMaximumMip;
    mipLevel = (clamp(_e104.x, 0f, 1f) * max(_e109, 0f));
    let _e114: vec3<f32> = sampleDirection;
    let _e115: f32 = mipLevel;
    let _e116: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_ReflectionCubeTexture, gs_wgpu_samp_material_ReflectionCubeTexture, _e114, _e115);
    reflectedRadiance = _e116.xyz;
    let _e119: vec3<f32> = reflectedRadiance;
    let _e120: vec4<f32> = global_1.material_EnvironmentReflectionParameters;
    let _e125: f32 = global_1.material_EnvironmentFallbackIntensity;
    return ((_e119 * max(_e120.z, 0f)) * max(_e125, 0f));
}

fn oceanFarFieldRadiance(worldPosition_1: vec3<f32>) -> vec3<f32> {
    var worldPosition_2: vec3<f32>;
    var surfaceNormal: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var viewDirection_4: vec3<f32>;
    var horizonFactor: f32;
    var baseColor_1: vec3<f32>;
    var lightVector: vec3<f32>;
    var sunlightAvailable: f32;
    var lightDirection: vec3<f32>;
    var sunlightColor: vec3<f32>;
    var diffuseLighting_2: vec3<f32>;
    var waterSurface_positionWS: vec3<f32>;
    var waterSurface_macroNormalWS: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var waterSurface_tangentWS: vec3<f32> = vec3<f32>(1f, 0f, 0f);
    var waterSurface_bitangentWS: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var waterSurface_meshUv: vec2<f32>;
    var waterSurface_flowWS: vec2<f32> = vec2(0f);
    var waterSurface_coverage: f32 = 1f;
    var waterSurface_verticalDepth: f32;
    var waterSurface_horizontalShoreDistance: f32;
    var waterSurface_obstacleContact: f32 = 0f;
    var waterSurface_waveCrest: f32 = 0f;
    var rawRefractionFacts: WaterSurfaceRawRefractionFactsV2_;
    var rawReflectionFacts: WaterSurfaceRawReflectionFactsV2_;
    var rawFoamFacts: WaterSurfaceRawFoamFactsV2_;
    var rawContributionPolicy: WaterSurfaceRawContributionPolicyV2_;
    var contributions: WaterSurfaceResolvedRawContributionsV2_;
    var closureInput: WaterSurfaceFinalClosureV2Input;

    worldPosition_2 = worldPosition_1;
    let _e73: vec3<f32> = global.camera_Position;
    let _e74: vec3<f32> = worldPosition_2;
    let _e76: vec3<f32> = surfaceNormal;
    let _e77: vec3<f32> = oceanFarFieldSafeNormalize((_e73 - _e74), _e76);
    viewDirection_4 = _e77;
    let _e80: vec3<f32> = viewDirection_4;
    let _e81: vec3<f32> = surfaceNormal;
    let _e89: vec4<f32> = global_1.material_OceanHorizonColor;
    horizonFactor = (pow((1f - clamp(dot(_e80, _e81), 0f, 1f)), 8f) * _e89.w);
    let _e93: vec4<f32> = global_1.material_OceanDeepColor;
    let _e95: vec4<f32> = global_1.material_OceanHorizonColor;
    let _e97: f32 = horizonFactor;
    baseColor_1 = mix(_e93.xyz, _e95.xyz, vec3(_e97));
    let _e101: vec3<f32> = global_1.scene_SunlightDirection;
    lightVector = -(_e101);
    let _e105: vec3<f32> = lightVector;
    let _e106: vec3<f32> = lightVector;
    sunlightAvailable = step(0.00000001f, dot(_e105, _e106));
    let _e110: vec3<f32> = lightVector;
    let _e111: vec3<f32> = surfaceNormal;
    let _e112: vec3<f32> = oceanFarFieldSafeNormalize(_e110, _e111);
    lightDirection = _e112;
    let _e114: vec4<f32> = global_1.scene_SunlightColor;
    let _e119: f32 = sunlightAvailable;
    sunlightColor = (max(_e114.xyz, vec3(0f)) * _e119);
    let _e122: vec3<f32> = surfaceNormal;
    let _e123: vec3<f32> = waterSurfaceAmbientDiffuseRadiance(_e122);
    let _e124: vec3<f32> = sunlightColor;
    let _e125: vec3<f32> = surfaceNormal;
    let _e126: vec3<f32> = lightDirection;
    diffuseLighting_2 = (_e123 + (_e124 * max(dot(_e125, _e126), 0f)));
    let _e133: vec3<f32> = worldPosition_2;
    waterSurface_positionWS = _e133;
    let _e150: vec3<f32> = worldPosition_2;
    waterSurface_meshUv = _e150.xz;
    let _e158: f32 = global_1.material_MaximumSurfaceOpticalDistance;
    waterSurface_verticalDepth = _e158;
    let _e160: vec4<f32> = global_1.material_NearshoreDecode;
    waterSurface_horizontalShoreDistance = _e160.y;
    rawRefractionFacts.centeredSceneSample = vec3(0f);
    rawRefractionFacts.displacedSceneSample = vec3(0f);
    rawRefractionFacts.displacedSampleValidity = 0f;
    rawRefractionFacts.depthWeight = 0f;
    rawRefractionFacts.shoreValidity = 1f;
    let _e181: f32 = waterSurface_coverage;
    rawRefractionFacts.coverage = _e181;
    let _e185: vec2<f32> = global_1.material_OceanFarReflectionFilter;
    let _e188: vec3<f32> = waterSurfaceResolveAnalyticReflectionFallbackV2_(1f, _e185.x, 1f);
    rawReflectionFacts.analyticSample = _e188;
    let _e190: WaterSurfaceRawReflectionFactsV2_ = rawReflectionFacts;
    let _e192: vec3<f32> = viewDirection_4;
    let _e193: vec3<f32> = oceanFarReflectionDirection(_e192);
    let _e194: vec3<f32> = sampleOceanFarFieldReflection(_e190.analyticSample, _e193);
    rawReflectionFacts.environmentSample = _e194;
    let _e196: f32 = global_1.material_EnvironmentReflectionAvailable;
    rawReflectionFacts.environmentValidity = _e196;
    rawReflectionFacts.ssrPremultipliedSample = vec3(0f);
    rawReflectionFacts.ssrValidity = 0f;
    rawFoamFacts.surfaceSignal = 0f;
    rawFoamFacts.shoreSignal = 0f;
    rawFoamFacts.crestSignal = 0f;
    rawFoamFacts.currentSignal = 0f;
    rawFoamFacts.wakeSignal = 0f;
    rawFoamFacts.contactSignal = 0f;
    rawFoamFacts.localSignal = 0f;
    rawFoamFacts.motionScale = 0f;
    rawFoamFacts.enabled = 0f;
    rawContributionPolicy.primaryColorClosureModel = 3f;
    rawContributionPolicy.refractionEnabled = 0f;
    rawContributionPolicy.clarity = 1f;
    rawContributionPolicy.boundaryRefractionSuppression = 0f;
    rawContributionPolicy.reflectionSource = 1f;
    rawContributionPolicy.ssrCompositeIntensity = 0f;
    rawContributionPolicy.foamIntensity = 0f;
    let _e236: WaterSurfaceRawRefractionFactsV2_ = rawRefractionFacts;
    let _e237: WaterSurfaceRawReflectionFactsV2_ = rawReflectionFacts;
    let _e238: WaterSurfaceRawFoamFactsV2_ = rawFoamFacts;
    let _e239: WaterSurfaceRawContributionPolicyV2_ = rawContributionPolicy;
    let _e240: f32 = waterSurfaceResolveRawFoamWeightV2_(_e238, _e239);
    let _e241: WaterSurfaceRawContributionPolicyV2_ = rawContributionPolicy;
    let _e242: WaterSurfaceResolvedRawContributionsV2_ = waterSurfaceResolveRawContributionsV2_(_e236, _e237, _e240, _e241);
    contributions = _e242;
    closureInput.additionalTransmissionRadiance = vec3(0f);
    closureInput.primarySceneColor = vec3(0f);
    let _e252: vec3<f32> = baseColor_1;
    closureInput.surfaceColor = _e252;
    let _e254: vec3<f32> = baseColor_1;
    closureInput.depthColor = _e254;
    closureInput.depthFactor = 1f;
    let _e258: vec3<f32> = diffuseLighting_2;
    closureInput.diffuseLighting = _e258;
    closureInput.primaryColorClosureModel = 3f;
    let _e262: vec3<f32> = global_1.material_AbsorptionCoefficient;
    closureInput.absorptionCoefficient = _e262;
    let _e264: vec3<f32> = global_1.material_ScatteringColor;
    closureInput.scatteringColor = _e264;
    let _e266: f32 = global_1.material_ScatteringCoefficient;
    closureInput.scatteringCoefficient = _e266;
    let _e268: f32 = waterSurface_verticalDepth;
    closureInput.opticalDepth = _e268;
    let _e270: WaterSurfaceResolvedRawContributionsV2_ = contributions;
    closureInput.refractionColor = _e270.refractionSceneColor;
    closureInput.refractionWeight = 0f;
    let _e275: WaterSurfaceResolvedRawContributionsV2_ = contributions;
    closureInput.reflectionRadiance = _e275.reflectionRadiance;
    let _e278: f32 = global_1.material_IndexOfRefraction;
    let _e281: f32 = global_1.material_IndexOfRefraction;
    closureInput.fresnelF0_ = pow(((_e278 - 1f) / (_e281 + 1f)), 2f);
    let _e288: f32 = global_1.material_Roughness;
    closureInput.perceptualRoughness = _e288;
    let _e290: vec3<f32> = viewDirection_4;
    let _e291: f32 = oceanFarReflectionNormalDotView(_e290);
    closureInput.normalDotView = _e291;
    closureInput.transmissionFresnelWeight = 1f;
    let _e295: f32 = global_1.material_ReflectionIntensity;
    closureInput.reflectionIntensity = _e295;
    closureInput.directSpecularRadiance = vec3(0f);
    closureInput.boundaryColor = vec3(0f);
    closureInput.foamColor = vec3(1f);
    let _e306: WaterSurfaceResolvedRawContributionsV2_ = contributions;
    closureInput.foamWeight = _e306.foamWeight;
    closureInput.baseAlpha = 1f;
    closureInput.clarity = 1f;
    closureInput.coastalAlpha = 1f;
    closureInput.coastalAlphaWeight = 1f;
    let _e317: f32 = waterSurface_coverage;
    closureInput.coverage = _e317;
    closureInput.compositionSceneColor = vec3(0f);
    closureInput.precomposedReplace = 1f;
    let _e323: WaterSurfaceFinalClosureV2Input = closureInput;
    let _e324: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_2(_e323);
    return _e324.xyz;
}

fn frag(input: Varyings) {
    var input_1: Varyings;
    var nearshoreUv: vec2<f32>;
    var outsideEdges: vec4<f32>;
    var outsideAtlas: f32;
    var outsideWet: f32;
    var shoreDistance: f32;
    var clampedNearshoreUv: vec2<f32>;
    var nearshoreSample: vec4<f32>;
    var shoreAntialias: f32;
    var atlasCoverage: f32;
    var coverage: f32;
    var finalColor: vec3<f32>;
    var resolvedWaterClosure: vec4<f32>;

    input_1 = input;
    let _e68: Varyings = input_1;
    let _e71: vec4<f32> = waterConnectionFacts(_e68.worldPosition.xz);
    if (_e71.w < 0.5f) {
        discard;
    }
    let _e75: Varyings = input_1;
    let _e78: vec4<f32> = global_1.material_NearshoreWorldToUv;
    let _e81: vec4<f32> = global_1.material_NearshoreWorldToUv;
    nearshoreUv = ((_e75.worldPosition.xz * _e78.xy) + _e81.zw);
    let _e87: vec2<f32> = nearshoreUv;
    let _e92: vec2<f32> = nearshoreUv;
    let _e97: vec2<f32> = nearshoreUv;
    let _e102: vec2<f32> = nearshoreUv;
    outsideEdges = vec4<f32>((1f - step(0f, _e87.x)), step(1.000001f, _e92.x), (1f - step(0f, _e97.y)), step(1.000001f, _e102.y));
    let _e107: vec4<f32> = outsideEdges;
    let _e109: vec4<f32> = outsideEdges;
    let _e112: vec4<f32> = outsideEdges;
    let _e114: vec4<f32> = outsideEdges;
    outsideAtlas = max(max(_e107.x, _e109.y), max(_e112.z, _e114.w));
    let _e120: vec4<f32> = global_1.material_NearshoreOutsidePolicy;
    let _e122: vec4<f32> = outsideEdges;
    let _e126: vec4<f32> = global_1.material_NearshoreOutsidePolicy;
    let _e128: vec4<f32> = outsideEdges;
    let _e133: vec4<f32> = global_1.material_NearshoreOutsidePolicy;
    let _e135: vec4<f32> = outsideEdges;
    let _e140: vec4<f32> = global_1.material_NearshoreOutsidePolicy;
    let _e142: vec4<f32> = outsideEdges;
    outsideWet = (((mix(1f, _e120.x, _e122.x) * mix(1f, _e126.y, _e128.y)) * mix(1f, _e133.z, _e135.z)) * mix(1f, _e140.w, _e142.w));
    let _e147: vec4<f32> = global_1.material_NearshoreDecode;
    let _e150: vec4<f32> = global_1.material_NearshoreDecode;
    let _e152: f32 = outsideWet;
    shoreDistance = mix(-(_e147.y), _e150.y, _e152);
    let _e155: f32 = outsideAtlas;
    if (_e155 < 0.5f) {
        {
            let _e158: vec2<f32> = nearshoreUv;
            clampedNearshoreUv = clamp(_e158, vec2(0f), vec2(1f));
            let _e165: vec2<f32> = clampedNearshoreUv;
            let _e167: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_NearshoreTexture, gs_wgpu_samp_material_NearshoreTexture, _e165, 0f);
            nearshoreSample = _e167;
            let _e169: vec4<f32> = nearshoreSample;
            let _e174: vec4<f32> = global_1.material_NearshoreDecode;
            let _e176: f32 = waterSpatialFieldDecodeSignedDistance(_e169.w, 2.007874f, -1.007874f, _e174.y);
            shoreDistance = _e176;
        }
    }
    let _e177: vec2<f32> = global_1.material_NearshoreCellSize;
    let _e179: vec2<f32> = global_1.material_NearshoreCellSize;
    let _e184: f32 = shoreDistance;
    let _e185: f32 = fwidth(_e184);
    let _e188: vec4<f32> = global_1.material_NearshoreDecode;
    shoreAntialias = max((max(_e177.x, _e179.y) * 0.42f), max((_e185 * 1.25f), (_e188.y * 0.007843138f)));
    let _e197: Varyings = input_1;
    let _e200: f32 = shoreDistance;
    let _e201: f32 = waterConnectionShore(_e197.worldPosition.xz, _e200);
    shoreDistance = _e201;
    let _e202: f32 = shoreAntialias;
    let _e204: f32 = shoreAntialias;
    let _e205: f32 = shoreDistance;
    atlasCoverage = smoothstep(-(_e202), _e204, _e205);
    let _e208: f32 = atlasCoverage;
    let _e209: f32 = outsideWet;
    let _e210: f32 = outsideAtlas;
    coverage = mix(_e208, _e209, _e210);
    let _e213: f32 = coverage;
    if (_e213 <= 0.001f) {
        discard;
    }
    let _e217: Varyings = input_1;
    let _e219: vec3<f32> = oceanFarFieldRadiance(_e217.worldPosition);
    finalColor = _e219;
    let _e220: vec3<f32> = finalColor;
    let _e221: f32 = coverage;
    resolvedWaterClosure = vec4<f32>(_e220.x, _e220.y, _e220.z, _e221);
    let _e227: vec4<f32> = resolvedWaterClosure;
    let _e228: vec4<f32> = waterSurfaceOutputWithPick(_e227);
    output_color = _e228;
    return;
}

fn gs_wgpu_main() {
    var input_input: Varyings;

    let _e66: Varyings = read_Varyings();
    input_input = _e66;
    let _e68: Varyings = input_input;
    frag(_e68);
    return;
}

fn main_1() {
    let _e70: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e76: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e82: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e70.x), bitcast<f32>(_e76.y), bitcast<f32>(_e82.z));
    let _e90: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e90.w);
    let _e97: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e97.x);
    let _e104: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e104.y);
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) worldPosition: vec3<f32>, @location(1) positionVS: vec3<f32>) -> FragmentOutput {
    worldPosition_3 = worldPosition;
    positionVS_3 = positionVS;
    main_1();
    let _e80: vec4<f32> = output_color;
    return FragmentOutput(_e80);
}
