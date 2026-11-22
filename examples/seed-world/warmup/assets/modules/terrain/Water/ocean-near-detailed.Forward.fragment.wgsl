diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ViewMat: mat4x4<f32>,
    camera_ProjMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    scene_ElapsedTime: vec4<f32>,
    material_SurfaceTimeOverride: f32,
    material_OceanFarTransition: vec2<f32>,
    material_OceanWaveFadeAndTimeScale: vec3<f32>,
}

struct gs_Auto_2_ {
    camera_DepthBufferParams: vec4<f32>,
    camera_ProjectionParams: vec4<f32>,
    camera_ViewInvMat: mat4x4<f32>,
    scene_SunlightColor: vec4<f32>,
    scene_SunlightDirection: vec3<f32>,
    material_EnvironmentReflectionParameters: vec4<f32>,
    material_EnvironmentFallbackIntensity: f32,
    material_EnvironmentReflectionMaximumMip: f32,
    material_EnvironmentReflectionProbePosition: vec4<f32>,
    material_EnvironmentReflectionBoxMinimum: vec4<f32>,
    material_EnvironmentReflectionBoxMaximum: vec4<f32>,
    material_SecondaryEnvironmentReflectionParameters: vec4<f32>,
    material_SecondaryEnvironmentReflectionMaximumMip: f32,
    material_SecondaryEnvironmentReflectionProbePosition: vec4<f32>,
    material_SecondaryEnvironmentReflectionBoxMinimum: vec4<f32>,
    material_SecondaryEnvironmentReflectionBoxMaximum: vec4<f32>,
    material_EnvironmentReflectionAvailable: f32,
    material_EnvironmentReflectionBlend: f32,
    material_AbsorptionCoefficient: vec3<f32>,
    material_ScatteringColor: vec3<f32>,
    material_ScatteringCoefficient: f32,
    material_IndexOfRefraction: f32,
    material_MaximumSurfaceOpticalDistance: f32,
    material_ReflectionIntensity: f32,
    material_Roughness: f32,
    material_OceanFoamEnabled: f32,
    material_OceanFoamIntensity: f32,
    material_RefractionStrength: f32,
    material_RefractionEnabled: f32,
    material_AppearanceV2BoundaryMaterialEnabled: f32,
    material_AppearanceV2RefractionUvScale: f32,
    material_AppearanceV2MacroNormalStrength: f32,
    material_AppearanceV2DirectionalHighlightStrength: f32,
    material_AppearanceV2DirectionalHighlightExponent: f32,
    material_AppearanceV2DirectionalHighlightDistortion: f32,
    material_AppearanceV2DirectionalHighlightSharp: f32,
    material_AppearanceV2DepthCoefficient0_: f32,
    material_AppearanceV2DepthCoefficient1_: f32,
    material_AppearanceV2DepthShallowColor: vec4<f32>,
    material_AppearanceV2DepthDeepColor: vec4<f32>,
    material_AppearanceV2Boundary0Range: f32,
    material_AppearanceV2Boundary0RefractionSuppression: f32,
    material_OceanTextureEnabled: vec4<f32>,
    material_OceanIntersectionTextureEnabled: f32,
    material_NearshoreWorldToUv: vec4<f32>,
    material_NearshoreDecode: vec4<f32>,
    material_NearshoreOutsidePolicy: vec4<f32>,
    material_NearshoreCellSize: vec2<f32>,
    material_CameraFeaturesAvailable: f32,
    material_OceanNormalParameters: vec4<f32>,
    material_OceanNormalMapping: vec4<f32>,
    material_OceanNormalFadeEndDistance: f32,
    material_OceanDeepColor: vec4<f32>,
    material_OceanHorizonColor: vec4<f32>,
    material_OceanFarReflectionFilter: vec2<f32>,
    material_OceanReflectionNormalBlend: f32,
    material_OceanSurfaceFoamParameters: vec4<f32>,
    material_OceanSurfaceFoamMapping: vec4<f32>,
    material_OceanSurfaceFoamColor: vec4<f32>,
    material_OceanIntersectionParameters: vec4<f32>,
    material_OceanIntersectionMotion: vec4<f32>,
    material_OceanIntersectionColor: vec4<f32>,
    material_OceanIntersectionRippleStrength: f32,
    material_OceanCausticsParameters: vec4<f32>,
    material_OceanCausticsMotion: vec4<f32>,
    material_OceanTranslucencyParameters: vec4<f32>,
    material_OceanTranslucencyCurvatureMask: f32,
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
    macroNormalWS: vec3<f32>,
    tangentWS: vec3<f32>,
    positionVS: vec3<f32>,
    clipPosition: vec4<f32>,
    waveOffsetY: f32,
    lod: f32,
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

struct WaterSurfaceResolvedLightingV2_ {
    diffuseRadiance: vec3<f32>,
    directSpecularRadiance: vec3<f32>,
}

struct FragmentOutput {
    @location(0) output_color: vec4<f32>,
}

const WATER_SURFACE_AMBIENT_PI: f32 = 3.1415927f;
const WATER_SURFACE_BRDF_MIN_PERCEPTUAL_ROUGHNESS: f32 = 0.045f;
const WATER_SURFACE_BRDF_EPSILON: f32 = 0.000001f;
const WATER_SURFACE_BRDF_RECIPROCAL_PI: f32 = 0.31830987f;
const WATER_SURFACE_BRDF_PI: f32 = 3.1415927f;

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(2) 
var<uniform> global_1: gs_Auto_2_;
var<private> output_color: vec4<f32>;
@group(1) @binding(0) 
var gs_wgpu_tex_camera_DepthTexture: texture_2d<f32>;
@group(1) @binding(1) 
var gs_wgpu_samp_camera_DepthTexture: sampler;
@group(1) @binding(2) 
var gs_wgpu_tex_camera_OpaqueTexture: texture_2d<f32>;
@group(1) @binding(3) 
var gs_wgpu_samp_camera_OpaqueTexture: sampler;
@group(2) @binding(3) 
var gs_wgpu_tex_material_ReflectionCubeTexture: texture_cube<f32>;
@group(2) @binding(4) 
var gs_wgpu_samp_material_ReflectionCubeTexture: sampler;
@group(2) @binding(5) 
var gs_wgpu_tex_material_SecondaryReflectionCubeTexture: texture_cube<f32>;
@group(2) @binding(6) 
var gs_wgpu_samp_material_SecondaryReflectionCubeTexture: sampler;
@group(2) @binding(7) 
var<uniform> gs_wgpu_data_3_: gs_Auto_3_;
var<private> scene_EnvMapLight: WaterSurfaceEnvironmentLight;
@group(2) @binding(8) 
var gs_wgpu_tex_material_SmoothWavesTexture: texture_2d<f32>;
@group(2) @binding(9) 
var gs_wgpu_samp_material_SmoothWavesTexture: sampler;
@group(2) @binding(10) 
var gs_wgpu_tex_material_RoughWavesTexture: texture_2d<f32>;
@group(2) @binding(11) 
var gs_wgpu_samp_material_RoughWavesTexture: sampler;
@group(2) @binding(12) 
var gs_wgpu_tex_material_CausticsTexture: texture_2d<f32>;
@group(2) @binding(13) 
var gs_wgpu_samp_material_CausticsTexture: sampler;
@group(2) @binding(14) 
var gs_wgpu_tex_material_FoamTexture: texture_2d<f32>;
@group(2) @binding(15) 
var gs_wgpu_samp_material_FoamTexture: sampler;
@group(2) @binding(16) 
var gs_wgpu_tex_material_IntersectionNoiseTexture: texture_2d<f32>;
@group(2) @binding(17) 
var gs_wgpu_samp_material_IntersectionNoiseTexture: sampler;
@group(2) @binding(18) 
var gs_wgpu_tex_material_NearshoreTexture: texture_2d<f32>;
@group(2) @binding(19) 
var gs_wgpu_samp_material_NearshoreTexture: sampler;
var<private> worldPosition_5: vec3<f32>;
var<private> macroNormalWS_5: vec3<f32>;
var<private> tangentWS_1: vec3<f32>;
var<private> positionVS_4: vec3<f32>;
var<private> clipPosition_1: vec4<f32>;
var<private> waveOffsetY_1: f32;

fn remapDepthBufferEyeDepth(depth: f32) -> f32 {
    var depth_1: f32;

    depth_1 = depth;
    let _e152: vec4<f32> = global_1.camera_DepthBufferParams;
    let _e154: f32 = depth_1;
    let _e156: vec4<f32> = global_1.camera_DepthBufferParams;
    return (1f / ((_e152.z * _e154) + _e156.w));
}

fn waterSurfaceDerivedSceneRayDepth(verticalDepth: f32, macroNormalWS_1: vec3<f32>, viewDirectionWS: vec3<f32>) -> f32 {
    var verticalDepth_1: f32;
    var macroNormalWS_2: vec3<f32>;
    var viewDirectionWS_1: vec3<f32>;
    var projectionDenominator: f32;

    verticalDepth_1 = verticalDepth;
    macroNormalWS_2 = macroNormalWS_1;
    viewDirectionWS_1 = viewDirectionWS;
    let _e163: vec3<f32> = viewDirectionWS_1;
    let _e165: vec3<f32> = macroNormalWS_2;
    projectionDenominator = abs(dot(normalize(_e163), normalize(_e165)));
    let _e170: f32 = verticalDepth_1;
    let _e173: f32 = projectionDenominator;
    return min((max(_e170, 0f) / max(_e173, 0.001f)), 1000000f);
}

fn waterSurfaceCompositeExponentialDensity(firstScaledDepth: f32, secondScaledDepth: f32) -> f32 {
    var firstScaledDepth_1: f32;
    var secondScaledDepth_1: f32;

    firstScaledDepth_1 = firstScaledDepth;
    secondScaledDepth_1 = secondScaledDepth;
    let _e162: f32 = firstScaledDepth_1;
    let _e165: f32 = secondScaledDepth_1;
    return clamp((1f - exp(-(max(max(_e162, 0f), max(_e165, 0f))))), 0f, 1f);
}

fn waterOceanApplySceneFog(color: vec4<f32>, positionVS_1: vec3<f32>) -> vec4<f32> {
    var color_1: vec4<f32>;
    var positionVS_2: vec3<f32>;

    color_1 = color;
    positionVS_2 = positionVS_1;
    let _e177: vec4<f32> = color_1;
    return _e177;
}

fn sampleVolumetricCloudShadow(positionWS: vec3<f32>) -> f32 {
    var positionWS_1: vec3<f32>;

    positionWS_1 = positionWS;
    return 1f;
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e181: vec3<f32> = worldPosition_5;
    interface_value.worldPosition = _e181;
    let _e183: vec3<f32> = macroNormalWS_5;
    interface_value.macroNormalWS = _e183;
    let _e185: vec3<f32> = tangentWS_1;
    interface_value.tangentWS = _e185;
    let _e187: vec3<f32> = positionVS_4;
    interface_value.positionVS = _e187;
    let _e189: vec4<f32> = clipPosition_1;
    interface_value.clipPosition = _e189;
    let _e191: f32 = waveOffsetY_1;
    interface_value.waveOffsetY = _e191;
    let _e192: Varyings = interface_value;
    return _e192;
}

fn waterEnvironmentSrgbToLinear(color_2: vec3<f32>) -> vec3<f32> {
    var color_3: vec3<f32>;
    var low: vec3<f32>;
    var high: vec3<f32>;

    color_3 = color_2;
    let _e181: vec3<f32> = color_3;
    low = (_e181 / vec3(12.92f));
    let _e186: vec3<f32> = color_3;
    high = pow(max(((_e186 + vec3(0.055f)) / vec3(1.055f)), vec3(0f)), vec3(2.4f));
    let _e200: vec3<f32> = low;
    let _e201: vec3<f32> = high;
    let _e204: vec3<f32> = color_3;
    return mix(_e200, _e201, step(vec3(0.04045f), _e204));
}

fn waterEnvironmentReflectionDirection(directionWS: vec3<f32>, positionWS_2: vec3<f32>, probePosition: vec4<f32>, boxMinimum: vec3<f32>, boxMaximum: vec3<f32>) -> vec3<f32> {
    var directionWS_1: vec3<f32>;
    var positionWS_3: vec3<f32>;
    var probePosition_1: vec4<f32>;
    var boxMinimum_1: vec3<f32>;
    var boxMaximum_1: vec3<f32>;
    var directionSign: vec3<f32>;
    var safeDirection: vec3<f32>;
    var intersectingPlane: vec3<f32>;
    var intersectionDistances: vec3<f32>;
    var nearestIntersection: f32;
    var projectedDirection: vec3<f32>;
    var projectedValid: f32;

    directionWS_1 = directionWS;
    positionWS_3 = positionWS_2;
    probePosition_1 = probePosition;
    boxMinimum_1 = boxMinimum;
    boxMaximum_1 = boxMaximum;
    let _e189: vec4<f32> = probePosition_1;
    if (_e189.w < 0.5f) {
        {
            let _e193: vec3<f32> = directionWS_1;
            return _e193;
        }
    }
    let _e201: vec3<f32> = directionWS_1;
    directionSign = mix(vec3(-1f), vec3(1f), step(vec3(0f), _e201));
    let _e205: vec3<f32> = directionSign;
    let _e206: vec3<f32> = directionWS_1;
    safeDirection = (_e205 * max(abs(_e206), vec3(0.000001f)));
    let _e213: vec3<f32> = boxMinimum_1;
    let _e214: vec3<f32> = boxMaximum_1;
    let _e217: vec3<f32> = directionWS_1;
    intersectingPlane = mix(_e213, _e214, step(vec3(0f), _e217));
    let _e221: vec3<f32> = intersectingPlane;
    let _e222: vec3<f32> = positionWS_3;
    let _e224: vec3<f32> = safeDirection;
    intersectionDistances = ((_e221 - _e222) / _e224);
    let _e227: vec3<f32> = intersectionDistances;
    let _e229: vec3<f32> = intersectionDistances;
    let _e231: vec3<f32> = intersectionDistances;
    nearestIntersection = min(_e227.x, min(_e229.y, _e231.z));
    let _e236: vec3<f32> = positionWS_3;
    let _e237: vec3<f32> = directionWS_1;
    let _e238: f32 = nearestIntersection;
    let _e243: vec4<f32> = probePosition_1;
    projectedDirection = ((_e236 + (_e237 * max(_e238, 0f))) - _e243.xyz);
    let _e248: vec3<f32> = projectedDirection;
    let _e249: vec3<f32> = projectedDirection;
    projectedValid = step(0.00000001f, dot(_e248, _e249));
    let _e253: vec3<f32> = directionWS_1;
    let _e254: vec3<f32> = projectedDirection;
    let _e255: f32 = projectedValid;
    return mix(_e253, _e254, vec3(_e255));
}

fn sampleWaterDistantEnvironmentReflection(directionWS_2: vec3<f32>, positionWS_4: vec3<f32>, roughness: f32) -> vec3<f32> {
    var directionWS_3: vec3<f32>;
    var positionWS_5: vec3<f32>;
    var roughness_1: f32;
    var originalDirectionWS: vec3<f32>;
    var rotation: vec2<f32>;
    var sampleDirection: vec3<f32>;
    var mipLevel: f32;
    var reflectedRadiance: vec3<f32>;
    var secondaryWeight: f32;
    var secondaryDirection: vec3<f32>;
    var secondaryRotation: vec2<f32>;
    var secondaryMipLevel: f32;
    var secondaryRadiance: vec3<f32>;

    directionWS_3 = directionWS_2;
    positionWS_5 = positionWS_4;
    roughness_1 = roughness;
    let _e185: vec3<f32> = directionWS_3;
    originalDirectionWS = _e185;
    let _e187: vec3<f32> = directionWS_3;
    let _e188: vec3<f32> = positionWS_5;
    let _e189: vec4<f32> = global_1.material_EnvironmentReflectionProbePosition;
    let _e190: vec4<f32> = global_1.material_EnvironmentReflectionBoxMinimum;
    let _e192: vec4<f32> = global_1.material_EnvironmentReflectionBoxMaximum;
    let _e194: vec3<f32> = waterEnvironmentReflectionDirection(_e187, _e188, _e189, _e190.xyz, _e192.xyz);
    directionWS_3 = _e194;
    let _e195: vec4<f32> = global_1.material_EnvironmentReflectionParameters;
    rotation = _e195.xy;
    let _e198: vec2<f32> = rotation;
    let _e200: vec3<f32> = directionWS_3;
    let _e203: vec2<f32> = rotation;
    let _e205: vec3<f32> = directionWS_3;
    let _e209: vec3<f32> = directionWS_3;
    let _e211: vec2<f32> = rotation;
    let _e214: vec3<f32> = directionWS_3;
    let _e217: vec2<f32> = rotation;
    let _e219: vec3<f32> = directionWS_3;
    sampleDirection = vec3<f32>(((_e198.x * _e200.x) + (_e203.y * _e205.z)), _e209.y, ((-(_e211.y) * _e214.x) + (_e217.x * _e219.z)));
    let _e225: f32 = roughness_1;
    let _e229: f32 = global_1.material_EnvironmentReflectionMaximumMip;
    mipLevel = (clamp(_e225, 0f, 1f) * max(_e229, 0f));
    let _e234: vec3<f32> = sampleDirection;
    let _e235: f32 = mipLevel;
    let _e236: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_ReflectionCubeTexture, gs_wgpu_samp_material_ReflectionCubeTexture, _e234, _e235);
    reflectedRadiance = _e236.xyz;
    let _e239: vec3<f32> = reflectedRadiance;
    let _e240: vec4<f32> = global_1.material_EnvironmentReflectionParameters;
    reflectedRadiance = (_e239 * max(_e240.z, 0f));
    let _e245: f32 = global_1.material_EnvironmentReflectionBlend;
    secondaryWeight = clamp(_e245, 0f, 1f);
    let _e250: f32 = secondaryWeight;
    if (_e250 > 0f) {
        {
            let _e253: vec3<f32> = originalDirectionWS;
            let _e254: vec3<f32> = positionWS_5;
            let _e255: vec4<f32> = global_1.material_SecondaryEnvironmentReflectionProbePosition;
            let _e256: vec4<f32> = global_1.material_SecondaryEnvironmentReflectionBoxMinimum;
            let _e258: vec4<f32> = global_1.material_SecondaryEnvironmentReflectionBoxMaximum;
            let _e260: vec3<f32> = waterEnvironmentReflectionDirection(_e253, _e254, _e255, _e256.xyz, _e258.xyz);
            secondaryDirection = _e260;
            let _e262: vec4<f32> = global_1.material_SecondaryEnvironmentReflectionParameters;
            secondaryRotation = _e262.xy;
            let _e265: vec2<f32> = secondaryRotation;
            let _e267: vec3<f32> = secondaryDirection;
            let _e270: vec2<f32> = secondaryRotation;
            let _e272: vec3<f32> = secondaryDirection;
            let _e276: vec3<f32> = secondaryDirection;
            let _e278: vec2<f32> = secondaryRotation;
            let _e281: vec3<f32> = secondaryDirection;
            let _e284: vec2<f32> = secondaryRotation;
            let _e286: vec3<f32> = secondaryDirection;
            secondaryDirection = vec3<f32>(((_e265.x * _e267.x) + (_e270.y * _e272.z)), _e276.y, ((-(_e278.y) * _e281.x) + (_e284.x * _e286.z)));
            let _e291: f32 = roughness_1;
            let _e295: f32 = global_1.material_SecondaryEnvironmentReflectionMaximumMip;
            secondaryMipLevel = (clamp(_e291, 0f, 1f) * max(_e295, 0f));
            let _e300: vec3<f32> = secondaryDirection;
            let _e301: f32 = secondaryMipLevel;
            let _e302: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_SecondaryReflectionCubeTexture, gs_wgpu_samp_material_SecondaryReflectionCubeTexture, _e300, _e301);
            secondaryRadiance = _e302.xyz;
            let _e305: vec3<f32> = secondaryRadiance;
            let _e306: vec4<f32> = global_1.material_SecondaryEnvironmentReflectionParameters;
            secondaryRadiance = (_e305 * max(_e306.z, 0f));
            let _e311: vec3<f32> = reflectedRadiance;
            let _e312: vec3<f32> = secondaryRadiance;
            let _e313: f32 = secondaryWeight;
            reflectedRadiance = mix(_e311, _e312, vec3(_e313));
        }
    }
    let _e316: vec3<f32> = reflectedRadiance;
    let _e317: f32 = global_1.material_EnvironmentFallbackIntensity;
    return (_e316 * max(_e317, 0f));
}

fn waterSurfaceAmbientDiffuseRadiance(normalWS: vec3<f32>) -> vec3<f32> {
    var normalWS_1: vec3<f32>;
    var ambientIrradiance: vec3<f32>;

    normalWS_1 = normalWS;
    let _e182: WaterSurfaceEnvironmentLight = scene_EnvMapLight;
    ambientIrradiance = (_e182.diffuse * WATER_SURFACE_AMBIENT_PI);
    let _e186: vec3<f32> = ambientIrradiance;
    let _e187: WaterSurfaceEnvironmentLight = scene_EnvMapLight;
    return ((_e186 * max(_e187.diffuseIntensity, 0f)) / vec3(3.1415927f));
}

fn waterSpatialFieldDecodeDepth(encodedDepth: f32, maximumDepth: f32) -> f32 {
    var encodedDepth_1: f32;
    var maximumDepth_1: f32;

    encodedDepth_1 = encodedDepth;
    maximumDepth_1 = maximumDepth;
    let _e184: f32 = encodedDepth_1;
    let _e185: f32 = maximumDepth_1;
    return (_e184 * _e185);
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
    let _e188: f32 = encodedDistance_1;
    let _e189: f32 = decodeScale_1;
    let _e191: f32 = decodeBias_1;
    let _e193: f32 = signedDistanceRange_1;
    return (((_e188 * _e189) + _e191) * _e193);
}

fn waterSurfaceResolvePerceptualRoughness(perceptualRoughness: f32) -> f32 {
    var perceptualRoughness_1: f32;

    perceptualRoughness_1 = perceptualRoughness;
    let _e186: f32 = perceptualRoughness_1;
    return max(WATER_SURFACE_BRDF_MIN_PERCEPTUAL_ROUGHNESS, clamp(_e186, 0f, 1f));
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
    let _e190: f32 = f0_1;
    boundedF0_ = clamp(_e190, 0f, 1f);
    let _e195: f32 = f90_1;
    boundedF90_ = clamp(_e195, 0f, 1f);
    let _e200: f32 = boundedF0_;
    let _e201: f32 = boundedF90_;
    let _e202: f32 = boundedF0_;
    let _e205: f32 = dotLH_1;
    return (_e200 + ((_e201 - _e202) * pow((1f - clamp(_e205, 0f, 1f)), 5f)));
}

fn waterSurfaceGgxDistribution(alpha: f32, dotNH: f32) -> f32 {
    var alpha_1: f32;
    var dotNH_1: f32;
    var minimumAlpha: f32 = 0.002025f;
    var resolvedAlpha: f32;
    var alphaSquared: f32;
    var boundedDotNH: f32;
    var denominator: f32;

    alpha_1 = alpha;
    dotNH_1 = dotNH;
    let _e192: f32 = minimumAlpha;
    let _e193: f32 = alpha_1;
    resolvedAlpha = max(_e192, _e193);
    let _e196: f32 = resolvedAlpha;
    let _e197: f32 = resolvedAlpha;
    alphaSquared = (_e196 * _e197);
    let _e200: f32 = dotNH_1;
    boundedDotNH = clamp(_e200, 0f, 1f);
    let _e205: f32 = boundedDotNH;
    let _e206: f32 = boundedDotNH;
    let _e208: f32 = alphaSquared;
    denominator = (((_e205 * _e206) * (_e208 - 1f)) + 1f);
    let _e215: f32 = alphaSquared;
    let _e217: f32 = denominator;
    let _e218: f32 = denominator;
    return ((WATER_SURFACE_BRDF_RECIPROCAL_PI * _e215) / max((_e217 * _e218), WATER_SURFACE_BRDF_EPSILON));
}

fn waterSurfaceGgxSmithCorrelated(alpha_2: f32, dotNL: f32, dotNV: f32) -> f32 {
    var alpha_3: f32;
    var dotNL_1: f32;
    var dotNV_1: f32;
    var minimumAlpha_1: f32 = 0.002025f;
    var resolvedAlpha_1: f32;
    var alphaSquared_1: f32;
    var boundedDotNL: f32;
    var boundedDotNV: f32;
    var gv: f32;
    var gl: f32;

    alpha_3 = alpha_2;
    dotNL_1 = dotNL;
    dotNV_1 = dotNV;
    let _e194: f32 = minimumAlpha_1;
    let _e195: f32 = alpha_3;
    resolvedAlpha_1 = max(_e194, _e195);
    let _e198: f32 = resolvedAlpha_1;
    let _e199: f32 = resolvedAlpha_1;
    alphaSquared_1 = (_e198 * _e199);
    let _e202: f32 = dotNL_1;
    boundedDotNL = clamp(_e202, 0f, 1f);
    let _e207: f32 = dotNV_1;
    boundedDotNV = clamp(_e207, 0f, 1f);
    let _e212: f32 = boundedDotNL;
    let _e213: f32 = alphaSquared_1;
    let _e215: f32 = alphaSquared_1;
    let _e217: f32 = boundedDotNV;
    let _e219: f32 = boundedDotNV;
    gv = (_e212 * sqrt((_e213 + (((1f - _e215) * _e217) * _e219))));
    let _e225: f32 = boundedDotNV;
    let _e226: f32 = alphaSquared_1;
    let _e228: f32 = alphaSquared_1;
    let _e230: f32 = boundedDotNL;
    let _e232: f32 = boundedDotNL;
    gl = (_e225 * sqrt((_e226 + (((1f - _e228) * _e230) * _e232))));
    let _e239: f32 = gv;
    let _e240: f32 = gl;
    return (0.5f / max((_e239 + _e240), WATER_SURFACE_BRDF_EPSILON));
}

fn waterSurfaceDirectSpecular(f0_2: f32, perceptualRoughness_2: f32, dotNV_2: f32, dotNL_2: f32, dotNH_2: f32, dotLH_2: f32) -> f32 {
    var f0_3: f32;
    var perceptualRoughness_3: f32;
    var dotNV_3: f32;
    var dotNL_3: f32;
    var dotNH_3: f32;
    var dotLH_3: f32;
    var resolvedRoughness: f32;
    var alpha_4: f32;
    var boundedDotNV_1: f32;
    var boundedDotNL_1: f32;
    var boundedDotNH_1: f32;
    var boundedDotLH: f32;
    var fresnel: f32;
    var distribution: f32;
    var visibility: f32;

    f0_3 = f0_2;
    perceptualRoughness_3 = perceptualRoughness_2;
    dotNV_3 = dotNV_2;
    dotNL_3 = dotNL_2;
    dotNH_3 = dotNH_2;
    dotLH_3 = dotLH_2;
    let _e196: f32 = perceptualRoughness_3;
    let _e197: f32 = waterSurfaceResolvePerceptualRoughness(_e196);
    resolvedRoughness = _e197;
    let _e199: f32 = resolvedRoughness;
    let _e200: f32 = resolvedRoughness;
    alpha_4 = (_e199 * _e200);
    let _e203: f32 = dotNV_3;
    boundedDotNV_1 = clamp(_e203, 0f, 1f);
    let _e208: f32 = dotNL_3;
    boundedDotNL_1 = clamp(_e208, 0f, 1f);
    let _e213: f32 = dotNH_3;
    boundedDotNH_1 = clamp(_e213, 0f, 1f);
    let _e218: f32 = dotLH_3;
    boundedDotLH = clamp(_e218, 0f, 1f);
    let _e223: f32 = f0_3;
    let _e225: f32 = boundedDotLH;
    let _e226: f32 = waterSurfaceSchlick(_e223, 1f, _e225);
    fresnel = _e226;
    let _e228: f32 = alpha_4;
    let _e229: f32 = boundedDotNH_1;
    let _e230: f32 = waterSurfaceGgxDistribution(_e228, _e229);
    distribution = _e230;
    let _e232: f32 = alpha_4;
    let _e233: f32 = boundedDotNL_1;
    let _e234: f32 = boundedDotNV_1;
    let _e235: f32 = waterSurfaceGgxSmithCorrelated(_e232, _e233, _e234);
    visibility = _e235;
    let _e237: f32 = fresnel;
    let _e238: f32 = distribution;
    let _e240: f32 = visibility;
    let _e242: f32 = boundedDotNL_1;
    return ((((_e237 * _e238) * _e240) * _e242) * WATER_SURFACE_BRDF_PI);
}

fn waterSurfaceEnvironmentDfg(perceptualRoughness_4: f32, dotNV_4: f32) -> vec2<f32> {
    var perceptualRoughness_5: f32;
    var dotNV_5: f32;
    var c0_: vec4<f32> = vec4<f32>(-1f, -0.0275f, -0.572f, 0.022f);
    var c1_: vec4<f32> = vec4<f32>(1f, 0.0425f, 1.04f, -0.04f);
    var r: vec4<f32>;
    var a004_: f32;

    perceptualRoughness_5 = perceptualRoughness_4;
    dotNV_5 = dotNV_4;
    let _e204: f32 = perceptualRoughness_5;
    let _e208: vec4<f32> = c0_;
    let _e210: vec4<f32> = c1_;
    r = ((clamp(_e204, 0f, 1f) * _e208) + _e210);
    let _e213: vec4<f32> = r;
    let _e215: vec4<f32> = r;
    let _e220: f32 = dotNV_5;
    let _e227: vec4<f32> = r;
    let _e230: vec4<f32> = r;
    a004_ = ((min((_e213.x * _e215.x), exp2((-9.28f * clamp(_e220, 0f, 1f)))) * _e227.x) + _e230.y);
    let _e238: f32 = a004_;
    let _e240: vec4<f32> = r;
    return ((vec2<f32>(-1.04f, 1.04f) * _e238) + _e240.zw);
}

fn waterSurfaceEnvironmentSpecularWeight(f0_4: f32, perceptualRoughness_6: f32, dotNV_6: f32) -> vec3<f32> {
    var f0_5: f32;
    var perceptualRoughness_7: f32;
    var dotNV_7: f32;
    var dfg: vec2<f32>;

    f0_5 = f0_4;
    perceptualRoughness_7 = perceptualRoughness_6;
    dotNV_7 = dotNV_6;
    let _e190: f32 = perceptualRoughness_7;
    let _e191: f32 = dotNV_7;
    let _e192: vec2<f32> = waterSurfaceEnvironmentDfg(_e190, _e191);
    dfg = _e192;
    let _e194: f32 = f0_5;
    let _e195: vec2<f32> = dfg;
    let _e198: vec2<f32> = dfg;
    return vec3(((_e194 * _e195.x) + _e198.y));
}

fn waterSurfaceLitDirectSpecular(f0_6: f32, perceptualRoughness_8: f32, dotNL_4: f32, dotNH_4: f32, dotLH_4: f32) -> f32 {
    var f0_7: f32;
    var perceptualRoughness_9: f32;
    var dotNL_5: f32;
    var dotNH_5: f32;
    var dotLH_5: f32;
    var resolvedPerceptualRoughness: f32;
    var roughness_2: f32;
    var roughnessSquared: f32;
    var denominator_1: f32;
    var lightDotHalfSquared: f32;
    var normalization: f32;
    var specularTerm: f32;

    f0_7 = f0_6;
    perceptualRoughness_9 = perceptualRoughness_8;
    dotNL_5 = dotNL_4;
    dotNH_5 = dotNH_4;
    dotLH_5 = dotLH_4;
    let _e194: f32 = perceptualRoughness_9;
    let _e195: f32 = waterSurfaceResolvePerceptualRoughness(_e194);
    resolvedPerceptualRoughness = _e195;
    let _e197: f32 = resolvedPerceptualRoughness;
    let _e198: f32 = resolvedPerceptualRoughness;
    roughness_2 = max((_e197 * _e198), 0.0078125f);
    let _e203: f32 = roughness_2;
    let _e204: f32 = roughness_2;
    roughnessSquared = max((_e203 * _e204), 0.000061035156f);
    let _e209: f32 = dotNH_5;
    denominator_1 = clamp(_e209, 0f, 1f);
    let _e214: f32 = denominator_1;
    let _e215: f32 = denominator_1;
    let _e217: f32 = roughnessSquared;
    denominator_1 = (((_e214 * _e215) * (_e217 - 1f)) + 1.00001f);
    let _e223: f32 = dotLH_5;
    let _e227: f32 = dotLH_5;
    lightDotHalfSquared = max((clamp(_e223, 0f, 1f) * clamp(_e227, 0f, 1f)), 0.1f);
    let _e235: f32 = roughness_2;
    normalization = ((_e235 * 4f) + 2f);
    let _e241: f32 = roughnessSquared;
    let _e242: f32 = denominator_1;
    let _e243: f32 = denominator_1;
    let _e245: f32 = lightDotHalfSquared;
    let _e247: f32 = normalization;
    specularTerm = (_e241 / max((((_e242 * _e243) * _e245) * _e247), WATER_SURFACE_BRDF_EPSILON));
    let _e252: f32 = f0_7;
    let _e256: f32 = specularTerm;
    let _e258: f32 = dotNL_5;
    return ((clamp(_e252, 0f, 1f) * _e256) * clamp(_e258, 0f, 1f));
}

fn waterSurfaceSampleRawEnvironmentReflectionV2_(directionWS_4: vec3<f32>, positionWS_6: vec3<f32>, perceptualRoughness_10: f32, radiance: ptr<function, vec3<f32>>, validity: ptr<function, f32>) {
    var directionWS_5: vec3<f32>;
    var positionWS_7: vec3<f32>;
    var perceptualRoughness_11: f32;

    directionWS_5 = directionWS_4;
    positionWS_7 = positionWS_6;
    perceptualRoughness_11 = perceptualRoughness_10;
    (*radiance) = vec3(0f);
    (*validity) = 0f;
    let _e195: f32 = global_1.material_EnvironmentReflectionAvailable;
    if (_e195 > 0.5f) {
        {
            let _e198: vec3<f32> = directionWS_5;
            let _e199: vec3<f32> = positionWS_7;
            let _e200: f32 = perceptualRoughness_11;
            let _e201: vec3<f32> = sampleWaterDistantEnvironmentReflection(_e198, _e199, _e200);
            (*radiance) = _e201;
            (*validity) = 1f;
            return;
        }
    } else {
        return;
    }
}

fn waterSurfaceResolveAnalyticReflectionFallbackV2_(normalY: f32, perceptualRoughness_12: f32, environmentIntensity: f32) -> vec3<f32> {
    var normalY_1: f32;
    var perceptualRoughness_13: f32;
    var environmentIntensity_1: f32;

    normalY_1 = normalY;
    perceptualRoughness_13 = perceptualRoughness_12;
    environmentIntensity_1 = environmentIntensity;
    let _e198: f32 = normalY_1;
    let _e207: f32 = perceptualRoughness_13;
    let _e214: f32 = environmentIntensity_1;
    return (mix(vec3<f32>(0.075f, 0.16f, 0.21f), vec3<f32>(0.32f, 0.48f, 0.57f), vec3(mix(clamp(((_e198 * 0.5f) + 0.5f), 0f, 1f), 0.5f, clamp(_e207, 0f, 1f)))) * max(_e214, 0f));
}

fn waterSurfaceResolveRawFoamWeightV2_(foam: WaterSurfaceRawFoamFactsV2_, policy: WaterSurfaceRawContributionPolicyV2_) -> f32 {
    var foam_1: WaterSurfaceRawFoamFactsV2_;
    var policy_1: WaterSurfaceRawContributionPolicyV2_;
    var proceduralSignal: f32;
    var foamSignal: f32;

    foam_1 = foam;
    policy_1 = policy;
    let _e188: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e190: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e193: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e197: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e203: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e206: WaterSurfaceRawFoamFactsV2_ = foam_1;
    proceduralSignal = (max(max(max(_e188.surfaceSignal, _e190.shoreSignal), ((_e193.crestSignal * 0.68f) + (_e197.currentSignal * 0.32f))), _e203.wakeSignal) * max(_e206.motionScale, 0f));
    let _e212: f32 = proceduralSignal;
    let _e215: WaterSurfaceRawContributionPolicyV2_ = policy_1;
    let _e220: WaterSurfaceRawFoamFactsV2_ = foam_1;
    let _e226: WaterSurfaceRawFoamFactsV2_ = foam_1;
    foamSignal = clamp((max((max(_e212, 0f) * max(_e215.foamIntensity, 0f)), max(_e220.localSignal, 0f)) * step(0.5f, _e226.enabled)), 0f, 1f);
    let _e236: f32 = foamSignal;
    let _e238: WaterSurfaceRawFoamFactsV2_ = foam_1;
    return max(smoothstep(0.02f, 0.78f, _e236), clamp(_e238.contactSignal, 0f, 1f));
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
    let _e194: f32 = foamWeight_1;
    resolved.foamWeight = clamp(_e194, 0f, 1f);
    let _e198: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e201: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    displacedValidity = clamp((_e198.displacedSampleValidity * step(0.5f, _e201.refractionEnabled)), 0f, 1f);
    let _e210: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e212: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e214: f32 = displacedValidity;
    resolved.refractionSceneColor = mix(_e210.centeredSceneSample, _e212.displacedSceneSample, vec3(_e214));
    let _e220: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    let _e224: f32 = displacedValidity;
    let _e226: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e232: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e238: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e244: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    let _e251: WaterSurfaceResolvedRawContributionsV2_ = resolved;
    let _e258: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    resolved.refractionWeight = clamp(((((((((1f - step(1.5f, _e220.primaryColorClosureModel)) * _e224) * clamp(_e226.depthWeight, 0f, 1f)) * clamp(_e232.shoreValidity, 0f, 1f)) * clamp(_e238.coverage, 0f, 1f)) * clamp(_e244.clarity, 0f, 1f)) * (1f - (_e251.foamWeight * 0.94f))) * (1f - clamp(_e258.boundaryRefractionSuppression, 0f, 1f))), 0f, 1f);
    let _e268: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    let _e270: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    let _e272: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    environment = mix(_e268.analyticSample, _e270.environmentSample, vec3(clamp(_e272.environmentValidity, 0f, 1f)));
    let _e281: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    resolved.reflectionRadiance = _e281.analyticSample;
    let _e283: WaterSurfaceRawContributionPolicyV2_ = policy_3;
    if (_e283.reflectionSource > 2.5f) {
        {
            let _e287: WaterSurfaceRawContributionPolicyV2_ = policy_3;
            ssrScale = clamp(_e287.ssrCompositeIntensity, 0f, 1f);
            let _e293: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
            let _e295: f32 = ssrScale;
            ssrBlend = clamp((_e293.ssrValidity * _e295), 0f, 1f);
            let _e302: vec3<f32> = environment;
            let _e304: f32 = ssrBlend;
            let _e307: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
            let _e309: f32 = ssrScale;
            resolved.reflectionRadiance = ((_e302 * (1f - _e304)) + (_e307.ssrPremultipliedSample * _e309));
        }
    } else {
        let _e312: WaterSurfaceRawContributionPolicyV2_ = policy_3;
        if (_e312.reflectionSource > 0.5f) {
            {
                let _e317: vec3<f32> = environment;
                resolved.reflectionRadiance = _e317;
            }
        }
    }
    let _e318: WaterSurfaceResolvedRawContributionsV2_ = resolved;
    return _e318;
}

fn waterSurfaceBoundedTranslucency(tint: vec3<f32>, lightRadiance: vec3<f32>, lightDirection: vec3<f32>, viewDirection: vec3<f32>, normal: vec3<f32>, backStrength: f32, incidentStrength: f32, exponent: f32, curvatureWeight: f32, visibility_1: f32) -> vec3<f32> {
    var tint_1: vec3<f32>;
    var lightRadiance_1: vec3<f32>;
    var lightDirection_1: vec3<f32>;
    var viewDirection_1: vec3<f32>;
    var normal_1: vec3<f32>;
    var backStrength_1: f32;
    var incidentStrength_1: f32;
    var exponent_1: f32;
    var curvatureWeight_1: f32;
    var visibility_2: f32;
    var back: f32;
    var incident: f32;
    var curvature: f32;

    tint_1 = tint;
    lightRadiance_1 = lightRadiance;
    lightDirection_1 = lightDirection;
    viewDirection_1 = viewDirection;
    normal_1 = normal;
    backStrength_1 = backStrength;
    incidentStrength_1 = incidentStrength;
    exponent_1 = exponent;
    curvatureWeight_1 = curvatureWeight;
    visibility_2 = visibility_1;
    let _e204: vec3<f32> = viewDirection_1;
    let _e206: vec3<f32> = lightDirection_1;
    let _e210: f32 = exponent_1;
    let _e214: f32 = backStrength_1;
    back = (pow(max(dot(-(_e204), _e206), 0f), max(_e210, 1f)) * max(_e214, 0f));
    let _e219: vec3<f32> = lightDirection_1;
    let _e220: vec3<f32> = normal_1;
    let _e224: f32 = incidentStrength_1;
    incident = (max(dot(_e219, _e220), 0f) * max(_e224, 0f));
    let _e230: vec3<f32> = normal_1;
    let _e231: vec3<f32> = lightDirection_1;
    let _e234: f32 = curvatureWeight_1;
    curvature = clamp(mix(1f, dot(_e230, -(_e231)), _e234), 0f, 1f);
    let _e240: vec3<f32> = tint_1;
    let _e244: vec3<f32> = lightRadiance_1;
    let _e249: f32 = back;
    let _e250: f32 = incident;
    let _e253: f32 = curvature;
    let _e255: f32 = visibility_2;
    return ((((max(_e240, vec3(0f)) * max(_e244, vec3(0f))) * (_e249 + _e250)) * _e253) * clamp(_e255, 0f, 1f));
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
    let _e196: f32 = closureModel_1;
    if (_e196 > 3.5f) {
        {
            let _e199: vec3<f32> = sceneColor_1;
            let _e200: vec3<f32> = depthColor_1;
            let _e201: f32 = depthFactor_1;
            let _e207: vec3<f32> = diffuseLighting_1;
            return (mix(_e199, _e200, vec3(clamp(_e201, 0f, 1f))) * max(_e207, vec3(0f)));
        }
    }
    let _e212: vec3<f32> = surfaceColor_1;
    let _e213: vec3<f32> = depthColor_1;
    let _e214: vec3<f32> = diffuseLighting_1;
    let _e219: f32 = depthFactor_1;
    stylized = mix(_e212, (_e213 * max(_e214, vec3(0f))), vec3(clamp(_e219, 0f, 1f)));
    let _e226: vec3<f32> = sceneColor_1;
    let _e232: vec3<f32> = depthColor_1;
    let _e233: vec3<f32> = diffuseLighting_1;
    let _e238: f32 = depthFactor_1;
    litScene = mix(clamp(_e226, vec3(0f), vec3(1f)), (_e232 * max(_e233, vec3(0f))), vec3(clamp(_e238, 0f, 1f)));
    let _e245: vec3<f32> = surfaceColor_1;
    let _e246: vec3<f32> = depthColor_1;
    let _e247: f32 = depthFactor_1;
    let _e253: vec3<f32> = diffuseLighting_1;
    sceneCompositeWater = (mix(_e245, _e246, vec3(clamp(_e247, 0f, 1f))) * max(_e253, vec3(0f)));
    let _e259: f32 = closureModel_1;
    if (_e259 > 2.5f) {
        let _e262: vec3<f32> = sceneCompositeWater;
        local_2 = _e262;
    } else {
        let _e263: f32 = closureModel_1;
        if (_e263 > 1.5f) {
            let _e266: vec3<f32> = litScene;
            local_1 = _e266;
        } else {
            let _e267: f32 = closureModel_1;
            if (_e267 > 0.5f) {
                let _e270: vec3<f32> = stylized;
                local = _e270;
            } else {
                let _e271: vec3<f32> = surfaceColor_1;
                local = _e271;
            }
            let _e273: vec3<f32> = local;
            local_1 = _e273;
        }
        let _e275: vec3<f32> = local_1;
        local_2 = _e275;
    }
    let _e277: vec3<f32> = local_2;
    return _e277;
}

fn waterSurfaceOpticalTransmittance(absorptionCoefficient: vec3<f32>, opticalDepth: f32) -> vec3<f32> {
    var absorptionCoefficient_1: vec3<f32>;
    var opticalDepth_1: f32;

    absorptionCoefficient_1 = absorptionCoefficient;
    opticalDepth_1 = opticalDepth;
    let _e188: vec3<f32> = absorptionCoefficient_1;
    let _e193: f32 = opticalDepth_1;
    return exp((-(max(_e188, vec3(0f))) * max(_e193, 0f)));
}

fn waterSurfaceOpticalScattering(scatteringColor: vec3<f32>, scatteringCoefficient: f32, opticalDepth_2: f32) -> vec3<f32> {
    var scatteringColor_1: vec3<f32>;
    var scatteringCoefficient_1: f32;
    var opticalDepth_3: f32;
    var weight: f32;

    scatteringColor_1 = scatteringColor;
    scatteringCoefficient_1 = scatteringCoefficient;
    opticalDepth_3 = opticalDepth_2;
    let _e191: f32 = scatteringCoefficient_1;
    let _e195: f32 = opticalDepth_3;
    weight = (1f - exp((-(max(_e191, 0f)) * max(_e195, 0f))));
    let _e202: vec3<f32> = scatteringColor_1;
    let _e206: f32 = weight;
    return (max(_e202, vec3(0f)) * _e206);
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
    let _e194: vec3<f32> = surfaceColor_3;
    let _e195: vec3<f32> = absorptionCoefficient_3;
    let _e196: f32 = opticalDepth_5;
    let _e197: vec3<f32> = waterSurfaceOpticalTransmittance(_e195, _e196);
    let _e199: vec3<f32> = scatteringColor_3;
    let _e200: f32 = scatteringCoefficient_3;
    let _e201: f32 = opticalDepth_5;
    let _e202: vec3<f32> = waterSurfaceOpticalScattering(_e199, _e200, _e201);
    return ((_e194 * _e197) + _e202);
}

fn waterSurfaceComposeFinal(color_4: vec3<f32>, alpha_5: f32, precomposedReplace: f32) -> vec4<f32> {
    var color_5: vec3<f32>;
    var alpha_6: f32;
    var precomposedReplace_1: f32;

    color_5 = color_4;
    alpha_6 = alpha_5;
    precomposedReplace_1 = precomposedReplace;
    let _e190: vec3<f32> = color_5;
    let _e191: f32 = alpha_6;
    let _e197: f32 = precomposedReplace_1;
    return vec4<f32>(_e190.x, _e190.y, _e190.z, mix(clamp(_e191, 0f, 1f), 1f, step(0.5f, _e197)));
}

fn waterSurfaceResolveAlphaV2_(baseAlpha: f32, clarity: f32, opticalDepth_6: f32, fresnel_1: f32, foamWeight_2: f32, coastalAlpha: f32, coastalAlphaWeight: f32) -> f32 {
    var baseAlpha_1: f32;
    var clarity_1: f32;
    var opticalDepth_7: f32;
    var fresnel_2: f32;
    var foamWeight_3: f32;
    var coastalAlpha_1: f32;
    var coastalAlphaWeight_1: f32;
    var absorptionAlpha: f32;
    var alpha_7: f32;

    baseAlpha_1 = baseAlpha;
    clarity_1 = clarity;
    opticalDepth_7 = opticalDepth_6;
    fresnel_2 = fresnel_1;
    foamWeight_3 = foamWeight_2;
    coastalAlpha_1 = coastalAlpha;
    coastalAlphaWeight_1 = coastalAlphaWeight;
    let _e201: f32 = clarity_1;
    let _e207: f32 = opticalDepth_7;
    absorptionAlpha = (1f - exp((-(mix(0.48f, 0.13f, clamp(_e201, 0f, 1f))) * max(_e207, 0f))));
    let _e214: f32 = baseAlpha_1;
    let _e217: f32 = absorptionAlpha;
    alpha_7 = (_e214 * mix(0.18f, 0.94f, _e217));
    let _e221: f32 = alpha_7;
    let _e222: f32 = fresnel_2;
    let _e227: f32 = alpha_7;
    alpha_7 = (_e221 + ((clamp(_e222, 0f, 1f) * (1f - _e227)) * 0.48f));
    let _e233: f32 = alpha_7;
    let _e234: f32 = foamWeight_3;
    alpha_7 = (_e233 + (clamp(_e234, 0f, 1f) * 0.3f));
    let _e241: f32 = alpha_7;
    let _e242: f32 = coastalAlpha_1;
    let _e243: f32 = coastalAlphaWeight_1;
    alpha_7 = mix(_e241, _e242, clamp(_e243, 0f, 1f));
    let _e248: f32 = alpha_7;
    return clamp(_e248, 0f, 1f);
}

fn waterSurfaceAmplifyMacroNormalSlopes(macroNormalWS_3: vec3<f32>, strength: f32) -> vec3<f32> {
    var macroNormalWS_4: vec3<f32>;
    var strength_1: f32;
    var amplified: vec3<f32>;
    var lengthSquared: f32;
    var local_3: vec3<f32>;

    macroNormalWS_4 = macroNormalWS_3;
    strength_1 = strength;
    let _e188: vec3<f32> = macroNormalWS_4;
    let _e190: f32 = strength_1;
    let _e194: vec3<f32> = macroNormalWS_4;
    let _e196: vec3<f32> = macroNormalWS_4;
    let _e198: f32 = strength_1;
    amplified = vec3<f32>((_e188.x * max(_e190, 0f)), _e194.y, (_e196.z * max(_e198, 0f)));
    let _e204: vec3<f32> = amplified;
    let _e205: vec3<f32> = amplified;
    lengthSquared = dot(_e204, _e205);
    let _e208: f32 = lengthSquared;
    if (_e208 > 0.00000001f) {
        let _e211: vec3<f32> = amplified;
        let _e212: f32 = lengthSquared;
        local_3 = (_e211 * inverseSqrt(_e212));
    } else {
        local_3 = vec3<f32>(0f, 1f, 0f);
    }
    let _e220: vec3<f32> = local_3;
    return _e220;
}

fn waterSurfaceDirectionalHighlightV2_(lightRadiance_2: vec3<f32>, lightDirectionWS: vec3<f32>, viewDirectionWS_2: vec3<f32>, geometryNormalWS: vec3<f32>, detailNormalWS: vec3<f32>, distortion: f32, exponent_2: f32, strength_2: f32, sharp: f32) -> vec3<f32> {
    var lightRadiance_3: vec3<f32>;
    var lightDirectionWS_1: vec3<f32>;
    var viewDirectionWS_3: vec3<f32>;
    var geometryNormalWS_1: vec3<f32>;
    var detailNormalWS_1: vec3<f32>;
    var distortion_1: f32;
    var exponent_3: f32;
    var strength_3: f32;
    var sharp_1: f32;
    var safeDistortion: f32;
    var perturbedNormal: vec3<f32>;
    var halfVector: vec3<f32>;
    var specular: f32;
    var sharpWeight: f32;
    var viewFactor: f32;

    lightRadiance_3 = lightRadiance_2;
    lightDirectionWS_1 = lightDirectionWS;
    viewDirectionWS_3 = viewDirectionWS_2;
    geometryNormalWS_1 = geometryNormalWS;
    detailNormalWS_1 = detailNormalWS;
    distortion_1 = distortion;
    exponent_3 = exponent_2;
    strength_3 = strength_2;
    sharp_1 = sharp;
    let _e202: f32 = distortion_1;
    safeDistortion = clamp(_e202, 0f, 2f);
    let _e207: vec3<f32> = geometryNormalWS_1;
    let _e208: vec3<f32> = detailNormalWS_1;
    let _e209: f32 = safeDistortion;
    perturbedNormal = normalize(mix(_e207, _e208, vec3(_e209)));
    let _e214: vec3<f32> = lightDirectionWS_1;
    let _e215: vec3<f32> = viewDirectionWS_3;
    let _e217: vec3<f32> = perturbedNormal;
    let _e218: f32 = safeDistortion;
    halfVector = normalize(((_e214 + _e215) + (_e217 * _e218)));
    let _e223: vec3<f32> = geometryNormalWS_1;
    let _e224: vec3<f32> = halfVector;
    let _e229: f32 = exponent_3;
    specular = pow(clamp(dot(_e223, _e224), 0f, 1f), max(_e229, 1f));
    let _e235: f32 = sharp_1;
    sharpWeight = step(0.5f, _e235);
    let _e238: f32 = specular;
    let _e240: f32 = specular;
    let _e242: f32 = sharpWeight;
    specular = mix(_e238, step(0.2f, _e240), _e242);
    let _e246: vec3<f32> = geometryNormalWS_1;
    let _e247: vec3<f32> = lightDirectionWS_1;
    viewFactor = smoothstep(0f, 0.15f, clamp(dot(_e246, _e247), 0f, 1f));
    let _e254: vec3<f32> = lightRadiance_3;
    let _e258: f32 = specular;
    let _e260: f32 = strength_3;
    let _e266: f32 = sharpWeight;
    let _e269: f32 = viewFactor;
    return ((((max(_e254, vec3(0f)) * _e258) * max(_e260, 0f)) * mix(1f, 0.5f, _e266)) * _e269);
}

fn waterSurfaceCreateResolvedLightingV2_(ambientDiffuseRadiance: vec3<f32>) -> WaterSurfaceResolvedLightingV2_ {
    var ambientDiffuseRadiance_1: vec3<f32>;
    var lighting: WaterSurfaceResolvedLightingV2_;

    ambientDiffuseRadiance_1 = ambientDiffuseRadiance;
    let _e188: vec3<f32> = ambientDiffuseRadiance_1;
    lighting.diffuseRadiance = max(_e188, vec3(0f));
    lighting.directSpecularRadiance = vec3(0f);
    let _e195: WaterSurfaceResolvedLightingV2_ = lighting;
    return _e195;
}

fn waterSurfaceAccumulateDirectLightingV2_(lighting_1: WaterSurfaceResolvedLightingV2_, lightRadiance_4: vec3<f32>, normalDotView: f32, normalDotLight: f32, normalDotHalf: f32, lightDotHalf: f32, fresnelF0_: f32, perceptualRoughness_14: f32, primaryColorClosureModel: f32, directSpecularEnabled: f32) -> WaterSurfaceResolvedLightingV2_ {
    var lighting_2: WaterSurfaceResolvedLightingV2_;
    var lightRadiance_5: vec3<f32>;
    var normalDotView_1: f32;
    var normalDotLight_1: f32;
    var normalDotHalf_1: f32;
    var lightDotHalf_1: f32;
    var fresnelF0_1: f32;
    var perceptualRoughness_15: f32;
    var primaryColorClosureModel_1: f32;
    var directSpecularEnabled_1: f32;
    var safeLightRadiance: vec3<f32>;
    var safeNormalDotLight: f32;
    var resolvedDirectSpecular: f32 = 0f;
    var specGate: f32;

    lighting_2 = lighting_1;
    lightRadiance_5 = lightRadiance_4;
    normalDotView_1 = normalDotView;
    normalDotLight_1 = normalDotLight;
    normalDotHalf_1 = normalDotHalf;
    lightDotHalf_1 = lightDotHalf;
    fresnelF0_1 = fresnelF0_;
    perceptualRoughness_15 = perceptualRoughness_14;
    primaryColorClosureModel_1 = primaryColorClosureModel;
    directSpecularEnabled_1 = directSpecularEnabled;
    let _e204: vec3<f32> = lightRadiance_5;
    safeLightRadiance = max(_e204, vec3(0f));
    let _e209: f32 = normalDotLight_1;
    safeNormalDotLight = clamp(_e209, 0f, 1f);
    let _e216: f32 = directSpecularEnabled_1;
    specGate = clamp(_e216, 0f, 1f);
    let _e221: f32 = specGate;
    if (_e221 > 0f) {
        {
            let _e224: f32 = primaryColorClosureModel_1;
            let _e227: f32 = primaryColorClosureModel_1;
            if ((_e224 >= 1.5f) && (_e227 < 3.5f)) {
                {
                    let _e231: f32 = fresnelF0_1;
                    let _e232: f32 = perceptualRoughness_15;
                    let _e233: f32 = safeNormalDotLight;
                    let _e234: f32 = normalDotHalf_1;
                    let _e235: f32 = lightDotHalf_1;
                    let _e236: f32 = waterSurfaceLitDirectSpecular(_e231, _e232, _e233, _e234, _e235);
                    resolvedDirectSpecular = _e236;
                }
            } else {
                {
                    let _e237: f32 = fresnelF0_1;
                    let _e238: f32 = perceptualRoughness_15;
                    let _e239: f32 = normalDotView_1;
                    let _e240: f32 = safeNormalDotLight;
                    let _e241: f32 = normalDotHalf_1;
                    let _e242: f32 = lightDotHalf_1;
                    let _e243: f32 = waterSurfaceDirectSpecular(_e237, _e238, _e239, _e240, _e241, _e242);
                    resolvedDirectSpecular = _e243;
                }
            }
            let _e244: f32 = resolvedDirectSpecular;
            let _e245: f32 = specGate;
            resolvedDirectSpecular = (_e244 * _e245);
        }
    }
    let _e248: WaterSurfaceResolvedLightingV2_ = lighting_2;
    let _e250: vec3<f32> = safeLightRadiance;
    let _e251: f32 = safeNormalDotLight;
    lighting_2.diffuseRadiance = (_e248.diffuseRadiance + (_e250 * _e251));
    let _e255: WaterSurfaceResolvedLightingV2_ = lighting_2;
    let _e257: vec3<f32> = safeLightRadiance;
    let _e258: f32 = resolvedDirectSpecular;
    lighting_2.directSpecularRadiance = (_e255.directSpecularRadiance + (_e257 * _e258));
    let _e261: WaterSurfaceResolvedLightingV2_ = lighting_2;
    return _e261;
}

fn waterSurfaceEvaluateFinalClosureV2_(closure: WaterSurfaceFinalClosureV2Input, foamColorWeight: f32, depthOpacity: f32) -> vec4<f32> {
    var closure_1: WaterSurfaceFinalClosureV2Input;
    var foamColorWeight_1: f32;
    var depthOpacity_1: f32;
    var fresnel_3: f32;
    var primaryColor: vec3<f32>;
    var baseColor: vec3<f32>;
    var refractionMix: f32 = 0f;
    var resolvedRefractionColor: vec3<f32>;
    var local_4: vec3<f32>;
    var color_6: vec3<f32>;
    var boundaryContribution: vec3<f32>;
    var litSceneColorClosure: f32;
    var transmissionFresnel: f32;
    var reflectionBrdfWeight: vec3<f32>;
    var litFoamColor: vec3<f32>;
    var sceneColorCompositeClosure: f32;
    var sceneCompositeWeight: f32;
    var alpha_8: f32;
    var replace: f32;

    closure_1 = closure;
    foamColorWeight_1 = foamColorWeight;
    depthOpacity_1 = depthOpacity;
    let _e190: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e193: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e195: f32 = waterSurfaceSchlick(_e190.fresnelF0_, 1f, _e193.normalDotView);
    fresnel_3 = _e195;
    let _e197: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e199: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e201: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e203: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e205: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e207: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e209: vec3<f32> = waterSurfaceResolvePrimaryColor(_e197.primarySceneColor, _e199.surfaceColor, _e201.depthColor, _e203.depthFactor, _e205.diffuseLighting, _e207.primaryColorClosureModel);
    primaryColor = _e209;
    let _e211: vec3<f32> = primaryColor;
    baseColor = _e211;
    let _e215: WaterSurfaceFinalClosureV2Input = closure_1;
    resolvedRefractionColor = _e215.refractionColor;
    let _e218: WaterSurfaceFinalClosureV2Input = closure_1;
    if (_e218.primaryColorClosureModel < 0.5f) {
        {
            let _e222: vec3<f32> = primaryColor;
            let _e223: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e225: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e227: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e229: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e231: vec3<f32> = waterSurfaceApplyOpticalVolume(_e222, _e223.absorptionCoefficient, _e225.scatteringColor, _e227.scatteringCoefficient, _e229.opticalDepth);
            baseColor = _e231;
            let _e232: WaterSurfaceFinalClosureV2Input = closure_1;
            refractionMix = clamp(_e232.refractionWeight, 0f, 1f);
            let _e237: f32 = refractionMix;
            if (_e237 > 0f) {
                {
                    let _e240: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e242: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e244: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e246: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e248: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e250: vec3<f32> = waterSurfaceApplyOpticalVolume(_e240.refractionColor, _e242.absorptionCoefficient, _e244.scatteringColor, _e246.scatteringCoefficient, _e248.opticalDepth);
                    resolvedRefractionColor = _e250;
                }
            }
        }
    } else {
        let _e251: WaterSurfaceFinalClosureV2Input = closure_1;
        if (_e251.primaryColorClosureModel < 1.5f) {
            {
                let _e255: WaterSurfaceFinalClosureV2Input = closure_1;
                refractionMix = clamp(_e255.refractionWeight, 0f, 1f);
            }
        }
    }
    let _e260: f32 = refractionMix;
    if (_e260 > 0f) {
        let _e263: vec3<f32> = baseColor;
        let _e264: vec3<f32> = resolvedRefractionColor;
        let _e265: f32 = refractionMix;
        local_4 = mix(_e263, _e264, vec3(_e265));
    } else {
        let _e268: vec3<f32> = baseColor;
        local_4 = _e268;
    }
    let _e270: vec3<f32> = local_4;
    color_6 = _e270;
    let _e272: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e274: WaterSurfaceFinalClosureV2Input = closure_1;
    boundaryContribution = (_e272.boundaryColor * max(_e274.diffuseLighting, vec3(0f)));
    let _e282: WaterSurfaceFinalClosureV2Input = closure_1;
    litSceneColorClosure = step(1.5f, _e282.primaryColorClosureModel);
    let _e286: vec3<f32> = color_6;
    let _e287: vec3<f32> = boundaryContribution;
    let _e288: f32 = litSceneColorClosure;
    color_6 = (_e286 + (_e287 * _e288));
    let _e291: vec3<f32> = color_6;
    let _e292: WaterSurfaceFinalClosureV2Input = closure_1;
    color_6 = (_e291 + _e292.additionalTransmissionRadiance);
    let _e295: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e297: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e299: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e301: vec3<f32> = waterSurfaceEnvironmentSpecularWeight(_e295.fresnelF0_, _e297.perceptualRoughness, _e299.normalDotView);
    transmissionFresnel = clamp(_e301.x, 0f, 1f);
    let _e307: vec3<f32> = color_6;
    let _e310: f32 = transmissionFresnel;
    let _e312: WaterSurfaceFinalClosureV2Input = closure_1;
    color_6 = (_e307 * mix(1f, (1f - _e310), clamp(_e312.transmissionFresnelWeight, 0f, 1f)));
    let _e319: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e321: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e323: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e325: vec3<f32> = waterSurfaceEnvironmentSpecularWeight(_e319.fresnelF0_, _e321.perceptualRoughness, _e323.normalDotView);
    reflectionBrdfWeight = _e325;
    let _e327: vec3<f32> = color_6;
    let _e328: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e330: vec3<f32> = reflectionBrdfWeight;
    let _e332: WaterSurfaceFinalClosureV2Input = closure_1;
    color_6 = (_e327 + ((_e328.reflectionRadiance * _e330) * max(_e332.reflectionIntensity, 0f)));
    let _e338: vec3<f32> = color_6;
    let _e339: WaterSurfaceFinalClosureV2Input = closure_1;
    color_6 = (_e338 + _e339.directSpecularRadiance);
    let _e342: vec3<f32> = color_6;
    let _e343: vec3<f32> = boundaryContribution;
    let _e345: f32 = litSceneColorClosure;
    color_6 = (_e342 + (_e343 * (1f - _e345)));
    let _e349: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e351: WaterSurfaceFinalClosureV2Input = closure_1;
    litFoamColor = (_e349.foamColor * max(_e351.diffuseLighting, vec3(0f)));
    let _e358: vec3<f32> = color_6;
    let _e359: vec3<f32> = litFoamColor;
    let _e360: f32 = foamColorWeight_1;
    color_6 = mix(_e358, _e359, vec3(clamp(_e360, 0f, 1f)));
    let _e367: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e372: WaterSurfaceFinalClosureV2Input = closure_1;
    sceneColorCompositeClosure = (step(2.5f, _e367.primaryColorClosureModel) * (1f - step(3.5f, _e372.primaryColorClosureModel)));
    let _e378: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e380: f32 = depthOpacity_1;
    let _e385: f32 = foamColorWeight_1;
    let _e390: WaterSurfaceFinalClosureV2Input = closure_1;
    sceneCompositeWeight = (clamp(((_e378.depthFactor * clamp(_e380, 0f, 1f)) + _e385), 0f, 1f) * clamp(_e390.coverage, 0f, 1f));
    let _e397: vec3<f32> = color_6;
    let _e398: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e400: vec3<f32> = color_6;
    let _e401: f32 = sceneCompositeWeight;
    let _e404: f32 = sceneColorCompositeClosure;
    color_6 = mix(_e397, mix(_e398.primarySceneColor, _e400, vec3(_e401)), vec3(_e404));
    let _e407: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e409: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e411: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e413: f32 = fresnel_3;
    let _e414: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e416: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e418: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e420: f32 = waterSurfaceResolveAlphaV2_(_e407.baseAlpha, _e409.clarity, _e411.opticalDepth, _e413, _e414.foamWeight, _e416.coastalAlpha, _e418.coastalAlphaWeight);
    let _e421: WaterSurfaceFinalClosureV2Input = closure_1;
    alpha_8 = (_e420 * clamp(_e421.coverage, 0f, 1f));
    let _e429: WaterSurfaceFinalClosureV2Input = closure_1;
    replace = step(0.5f, _e429.precomposedReplace);
    let _e433: vec3<f32> = color_6;
    let _e434: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e436: vec3<f32> = color_6;
    let _e437: f32 = alpha_8;
    let _e440: f32 = replace;
    let _e442: f32 = sceneColorCompositeClosure;
    color_6 = mix(_e433, mix(_e434.compositionSceneColor, _e436, vec3(_e437)), vec3((_e440 * (1f - _e442))));
    let _e447: vec3<f32> = color_6;
    let _e448: f32 = alpha_8;
    let _e449: f32 = replace;
    let _e450: vec4<f32> = waterSurfaceComposeFinal(_e447, _e448, _e449);
    return _e450;
}

fn waterSurfaceEvaluateFinalClosureV2_1(closure_2: WaterSurfaceFinalClosureV2Input, foamColorWeight_2: f32) -> vec4<f32> {
    var closure_3: WaterSurfaceFinalClosureV2Input;
    var foamColorWeight_3: f32;

    closure_3 = closure_2;
    foamColorWeight_3 = foamColorWeight_2;
    let _e188: WaterSurfaceFinalClosureV2Input = closure_3;
    let _e189: f32 = foamColorWeight_3;
    let _e191: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_(_e188, _e189, 1f);
    return _e191;
}

fn waterSurfaceEvaluateFinalClosureV2_2(closure_4: WaterSurfaceFinalClosureV2Input) -> vec4<f32> {
    var closure_5: WaterSurfaceFinalClosureV2Input;

    closure_5 = closure_4;
    let _e186: WaterSurfaceFinalClosureV2Input = closure_5;
    let _e187: WaterSurfaceFinalClosureV2Input = closure_5;
    let _e189: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_1(_e186, _e187.foamWeight);
    return _e189;
}

fn waterSurfaceOutputWithPick(color_7: vec4<f32>) -> vec4<f32> {
    var color_8: vec4<f32>;

    color_8 = color_7;
    let _e186: vec4<f32> = color_8;
    return _e186;
}

fn oceanFarFieldSafeNormalize(value: vec3<f32>, fallbackValue: vec3<f32>) -> vec3<f32> {
    var value_1: vec3<f32>;
    var fallbackValue_1: vec3<f32>;
    var lengthSquared_1: f32;
    var local_5: vec3<f32>;

    value_1 = value;
    fallbackValue_1 = fallbackValue;
    let _e188: vec3<f32> = value_1;
    let _e189: vec3<f32> = value_1;
    lengthSquared_1 = dot(_e188, _e189);
    let _e192: f32 = lengthSquared_1;
    if (_e192 > 0.00000001f) {
        let _e195: vec3<f32> = value_1;
        let _e196: f32 = lengthSquared_1;
        local_5 = (_e195 * inverseSqrt(_e196));
    } else {
        let _e199: vec3<f32> = fallbackValue_1;
        local_5 = _e199;
    }
    let _e201: vec3<f32> = local_5;
    return _e201;
}

fn oceanFarFieldSrgbToLinear(color_9: vec3<f32>) -> vec3<f32> {
    var color_10: vec3<f32>;
    var low_1: vec3<f32>;
    var high_1: vec3<f32>;

    color_10 = color_9;
    let _e186: vec3<f32> = color_10;
    low_1 = (_e186 / vec3(12.92f));
    let _e191: vec3<f32> = color_10;
    high_1 = pow(max(((_e191 + vec3(0.055f)) / vec3(1.055f)), vec3(0f)), vec3(2.4f));
    let _e205: vec3<f32> = low_1;
    let _e206: vec3<f32> = high_1;
    let _e209: vec3<f32> = color_10;
    return mix(_e205, _e206, step(vec3(0.04045f), _e209));
}

fn oceanFarReflectionDirection(viewDirection_2: vec3<f32>) -> vec3<f32> {
    var viewDirection_3: vec3<f32>;
    var direction: vec3<f32>;

    viewDirection_3 = viewDirection_2;
    let _e186: vec3<f32> = viewDirection_3;
    direction = reflect(-(_e186), vec3<f32>(0f, 1f, 0f));
    let _e195: vec3<f32> = direction;
    let _e197: vec3<f32> = direction;
    let _e201: vec2<f32> = global_1.material_OceanFarReflectionFilter;
    direction.y = sqrt(((_e195.y * _e197.y) + (4f * _e201.y)));
    let _e206: vec3<f32> = direction;
    return normalize(_e206);
}

fn oceanFarReflectionNormalDotView(viewDirection_4: vec3<f32>) -> f32 {
    var viewDirection_5: vec3<f32>;
    var normalDotView_2: f32;
    var positiveSlopeMeanSquared: f32;

    viewDirection_5 = viewDirection_4;
    let _e186: vec3<f32> = viewDirection_5;
    normalDotView_2 = clamp(_e186.y, 0f, 1f);
    let _e192: vec2<f32> = global_1.material_OceanFarReflectionFilter;
    positiveSlopeMeanSquared = (_e192.y * 0.15915494f);
    let _e197: f32 = normalDotView_2;
    let _e198: f32 = normalDotView_2;
    let _e200: f32 = positiveSlopeMeanSquared;
    return clamp(sqrt(((_e197 * _e198) + _e200)), 0f, 1f);
}

fn sampleOceanFarFieldReflection(analyticFallback: vec3<f32>, directionWS_6: vec3<f32>) -> vec3<f32> {
    var analyticFallback_1: vec3<f32>;
    var directionWS_7: vec3<f32>;
    var rotation_1: vec2<f32>;
    var sampleDirection_1: vec3<f32>;
    var mipLevel_1: f32;
    var reflectedRadiance_1: vec3<f32>;

    analyticFallback_1 = analyticFallback;
    directionWS_7 = directionWS_6;
    let _e188: f32 = global_1.material_EnvironmentReflectionAvailable;
    if (_e188 < 0.5f) {
        let _e191: vec3<f32> = analyticFallback_1;
        return _e191;
    }
    let _e192: vec4<f32> = global_1.material_EnvironmentReflectionParameters;
    rotation_1 = _e192.xy;
    let _e195: vec2<f32> = rotation_1;
    let _e197: vec3<f32> = directionWS_7;
    let _e200: vec2<f32> = rotation_1;
    let _e202: vec3<f32> = directionWS_7;
    let _e206: vec3<f32> = directionWS_7;
    let _e208: vec2<f32> = rotation_1;
    let _e211: vec3<f32> = directionWS_7;
    let _e214: vec2<f32> = rotation_1;
    let _e216: vec3<f32> = directionWS_7;
    sampleDirection_1 = vec3<f32>(((_e195.x * _e197.x) + (_e200.y * _e202.z)), _e206.y, ((-(_e208.y) * _e211.x) + (_e214.x * _e216.z)));
    let _e222: vec2<f32> = global_1.material_OceanFarReflectionFilter;
    let _e227: f32 = global_1.material_EnvironmentReflectionMaximumMip;
    mipLevel_1 = (clamp(_e222.x, 0f, 1f) * max(_e227, 0f));
    let _e232: vec3<f32> = sampleDirection_1;
    let _e233: f32 = mipLevel_1;
    let _e234: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_ReflectionCubeTexture, gs_wgpu_samp_material_ReflectionCubeTexture, _e232, _e233);
    reflectedRadiance_1 = _e234.xyz;
    let _e237: vec3<f32> = reflectedRadiance_1;
    let _e238: vec4<f32> = global_1.material_EnvironmentReflectionParameters;
    let _e243: f32 = global_1.material_EnvironmentFallbackIntensity;
    return ((_e237 * max(_e238.z, 0f)) * max(_e243, 0f));
}

fn oceanFarFieldRadiance(worldPosition_1: vec3<f32>) -> vec3<f32> {
    var worldPosition_2: vec3<f32>;
    var surfaceNormal: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var viewDirection_6: vec3<f32>;
    var horizonFactor: f32;
    var baseColor_1: vec3<f32>;
    var lightVector: vec3<f32>;
    var sunlightAvailable: f32;
    var lightDirection_2: vec3<f32>;
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
    let _e191: vec3<f32> = global.camera_Position;
    let _e192: vec3<f32> = worldPosition_2;
    let _e194: vec3<f32> = surfaceNormal;
    let _e195: vec3<f32> = oceanFarFieldSafeNormalize((_e191 - _e192), _e194);
    viewDirection_6 = _e195;
    let _e198: vec3<f32> = viewDirection_6;
    let _e199: vec3<f32> = surfaceNormal;
    let _e207: vec4<f32> = global_1.material_OceanHorizonColor;
    horizonFactor = (pow((1f - clamp(dot(_e198, _e199), 0f, 1f)), 8f) * _e207.w);
    let _e211: vec4<f32> = global_1.material_OceanDeepColor;
    let _e213: vec4<f32> = global_1.material_OceanHorizonColor;
    let _e215: f32 = horizonFactor;
    baseColor_1 = mix(_e211.xyz, _e213.xyz, vec3(_e215));
    let _e219: vec3<f32> = global_1.scene_SunlightDirection;
    lightVector = -(_e219);
    let _e223: vec3<f32> = lightVector;
    let _e224: vec3<f32> = lightVector;
    sunlightAvailable = step(0.00000001f, dot(_e223, _e224));
    let _e228: vec3<f32> = lightVector;
    let _e229: vec3<f32> = surfaceNormal;
    let _e230: vec3<f32> = oceanFarFieldSafeNormalize(_e228, _e229);
    lightDirection_2 = _e230;
    let _e232: vec4<f32> = global_1.scene_SunlightColor;
    let _e237: f32 = sunlightAvailable;
    sunlightColor = (max(_e232.xyz, vec3(0f)) * _e237);
    let _e240: vec3<f32> = surfaceNormal;
    let _e241: vec3<f32> = waterSurfaceAmbientDiffuseRadiance(_e240);
    let _e242: vec3<f32> = sunlightColor;
    let _e243: vec3<f32> = surfaceNormal;
    let _e244: vec3<f32> = lightDirection_2;
    diffuseLighting_2 = (_e241 + (_e242 * max(dot(_e243, _e244), 0f)));
    let _e251: vec3<f32> = worldPosition_2;
    waterSurface_positionWS = _e251;
    let _e268: vec3<f32> = worldPosition_2;
    waterSurface_meshUv = _e268.xz;
    let _e276: f32 = global_1.material_MaximumSurfaceOpticalDistance;
    waterSurface_verticalDepth = _e276;
    let _e278: vec4<f32> = global_1.material_NearshoreDecode;
    waterSurface_horizontalShoreDistance = _e278.y;
    rawRefractionFacts.centeredSceneSample = vec3(0f);
    rawRefractionFacts.displacedSceneSample = vec3(0f);
    rawRefractionFacts.displacedSampleValidity = 0f;
    rawRefractionFacts.depthWeight = 0f;
    rawRefractionFacts.shoreValidity = 1f;
    let _e299: f32 = waterSurface_coverage;
    rawRefractionFacts.coverage = _e299;
    let _e303: vec2<f32> = global_1.material_OceanFarReflectionFilter;
    let _e306: vec3<f32> = waterSurfaceResolveAnalyticReflectionFallbackV2_(1f, _e303.x, 1f);
    rawReflectionFacts.analyticSample = _e306;
    let _e308: WaterSurfaceRawReflectionFactsV2_ = rawReflectionFacts;
    let _e310: vec3<f32> = viewDirection_6;
    let _e311: vec3<f32> = oceanFarReflectionDirection(_e310);
    let _e312: vec3<f32> = sampleOceanFarFieldReflection(_e308.analyticSample, _e311);
    rawReflectionFacts.environmentSample = _e312;
    let _e314: f32 = global_1.material_EnvironmentReflectionAvailable;
    rawReflectionFacts.environmentValidity = _e314;
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
    let _e354: WaterSurfaceRawRefractionFactsV2_ = rawRefractionFacts;
    let _e355: WaterSurfaceRawReflectionFactsV2_ = rawReflectionFacts;
    let _e356: WaterSurfaceRawFoamFactsV2_ = rawFoamFacts;
    let _e357: WaterSurfaceRawContributionPolicyV2_ = rawContributionPolicy;
    let _e358: f32 = waterSurfaceResolveRawFoamWeightV2_(_e356, _e357);
    let _e359: WaterSurfaceRawContributionPolicyV2_ = rawContributionPolicy;
    let _e360: WaterSurfaceResolvedRawContributionsV2_ = waterSurfaceResolveRawContributionsV2_(_e354, _e355, _e358, _e359);
    contributions = _e360;
    closureInput.additionalTransmissionRadiance = vec3(0f);
    closureInput.primarySceneColor = vec3(0f);
    let _e370: vec3<f32> = baseColor_1;
    closureInput.surfaceColor = _e370;
    let _e372: vec3<f32> = baseColor_1;
    closureInput.depthColor = _e372;
    closureInput.depthFactor = 1f;
    let _e376: vec3<f32> = diffuseLighting_2;
    closureInput.diffuseLighting = _e376;
    closureInput.primaryColorClosureModel = 3f;
    let _e380: vec3<f32> = global_1.material_AbsorptionCoefficient;
    closureInput.absorptionCoefficient = _e380;
    let _e382: vec3<f32> = global_1.material_ScatteringColor;
    closureInput.scatteringColor = _e382;
    let _e384: f32 = global_1.material_ScatteringCoefficient;
    closureInput.scatteringCoefficient = _e384;
    let _e386: f32 = waterSurface_verticalDepth;
    closureInput.opticalDepth = _e386;
    let _e388: WaterSurfaceResolvedRawContributionsV2_ = contributions;
    closureInput.refractionColor = _e388.refractionSceneColor;
    closureInput.refractionWeight = 0f;
    let _e393: WaterSurfaceResolvedRawContributionsV2_ = contributions;
    closureInput.reflectionRadiance = _e393.reflectionRadiance;
    let _e396: f32 = global_1.material_IndexOfRefraction;
    let _e399: f32 = global_1.material_IndexOfRefraction;
    closureInput.fresnelF0_ = pow(((_e396 - 1f) / (_e399 + 1f)), 2f);
    let _e406: f32 = global_1.material_Roughness;
    closureInput.perceptualRoughness = _e406;
    let _e408: vec3<f32> = viewDirection_6;
    let _e409: f32 = oceanFarReflectionNormalDotView(_e408);
    closureInput.normalDotView = _e409;
    closureInput.transmissionFresnelWeight = 1f;
    let _e413: f32 = global_1.material_ReflectionIntensity;
    closureInput.reflectionIntensity = _e413;
    closureInput.directSpecularRadiance = vec3(0f);
    closureInput.boundaryColor = vec3(0f);
    closureInput.foamColor = vec3(1f);
    let _e424: WaterSurfaceResolvedRawContributionsV2_ = contributions;
    closureInput.foamWeight = _e424.foamWeight;
    closureInput.baseAlpha = 1f;
    closureInput.clarity = 1f;
    closureInput.coastalAlpha = 1f;
    closureInput.coastalAlphaWeight = 1f;
    let _e435: f32 = waterSurface_coverage;
    closureInput.coverage = _e435;
    closureInput.compositionSceneColor = vec3(0f);
    closureInput.precomposedReplace = 1f;
    let _e441: WaterSurfaceFinalClosureV2Input = closureInput;
    let _e442: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_2(_e441);
    return _e442.xyz;
}

fn safeNormalize3_(value_2: vec3<f32>, fallbackValue_2: vec3<f32>) -> vec3<f32> {
    var value_3: vec3<f32>;
    var fallbackValue_3: vec3<f32>;
    var lengthSquared_2: f32;
    var local_6: vec3<f32>;

    value_3 = value_2;
    fallbackValue_3 = fallbackValue_2;
    let _e188: vec3<f32> = value_3;
    let _e189: vec3<f32> = value_3;
    lengthSquared_2 = dot(_e188, _e189);
    let _e192: f32 = lengthSquared_2;
    if (_e192 > 0.00000001f) {
        let _e195: vec3<f32> = value_3;
        let _e196: f32 = lengthSquared_2;
        local_6 = (_e195 * inverseSqrt(_e196));
    } else {
        let _e199: vec3<f32> = fallbackValue_3;
        local_6 = _e199;
    }
    let _e201: vec3<f32> = local_6;
    return _e201;
}

fn reconstructOpaquePositionWS(uv: vec2<f32>, eyeDepth: f32) -> vec3<f32> {
    var uv_1: vec2<f32>;
    var eyeDepth_1: f32;
    var ndc: vec2<f32>;
    var positionVS_3: vec3<f32>;

    uv_1 = uv;
    eyeDepth_1 = eyeDepth;
    let _e188: vec2<f32> = uv_1;
    ndc = ((_e188 * 2f) - vec2(1f));
    let _e196: vec2<f32> = ndc;
    ndc.y = -(_e196.y);
    let _e200: vec2<f32> = ndc;
    let _e202: f32 = eyeDepth_1;
    let _e208: f32 = global.camera_ProjMat[0][0];
    let _e210: vec2<f32> = ndc;
    let _e212: f32 = eyeDepth_1;
    let _e218: f32 = global.camera_ProjMat[1][1];
    let _e220: f32 = eyeDepth_1;
    positionVS_3 = vec3<f32>(((_e200.x * _e202) / _e208), ((_e210.y * _e212) / _e218), -(_e220));
    let _e223: mat4x4<f32> = global_1.camera_ViewInvMat;
    let _e224: vec3<f32> = positionVS_3;
    return (_e223 * vec4<f32>(_e224.x, _e224.y, _e224.z, 1f)).xyz;
}

fn decodeNormalMap(encoded: vec3<f32>) -> vec3<f32> {
    var encoded_1: vec3<f32>;

    encoded_1 = encoded;
    let _e186: vec3<f32> = encoded_1;
    let _e196: vec3<f32> = safeNormalize3_(((_e186 * 2f) - vec3(1f)), vec3<f32>(0f, 0f, 1f));
    return _e196;
}

fn blendNormalRnm(first: vec3<f32>, second: vec3<f32>) -> vec3<f32> {
    var first_1: vec3<f32>;
    var second_1: vec3<f32>;

    first_1 = first;
    second_1 = second;
    let _e188: vec3<f32> = first_1;
    let _e190: vec3<f32> = second_1;
    let _e192: vec2<f32> = (_e188.xy + _e190.xy);
    let _e193: vec3<f32> = first_1;
    let _e195: vec3<f32> = second_1;
    let _e198: vec3<f32> = first_1;
    let _e200: vec3<f32> = second_1;
    let _e211: vec3<f32> = safeNormalize3_(vec3<f32>(_e192.x, _e192.y, ((_e193.z * _e195.z) - dot(_e198.xy, _e200.xy))), vec3<f32>(0f, 0f, 1f));
    return _e211;
}

fn smoothstep01_(value_4: f32) -> f32 {
    var value_5: f32;
    var bounded: f32;

    value_5 = value_4;
    let _e186: f32 = value_5;
    bounded = clamp(_e186, 0f, 1f);
    let _e191: f32 = bounded;
    let _e192: f32 = bounded;
    let _e196: f32 = bounded;
    return ((_e191 * _e192) * (3f - (2f * _e196)));
}

fn screenEdgeMask(screenUv: vec2<f32>, refractionLength: f32) -> f32 {
    var screenUv_1: vec2<f32>;
    var refractionLength_1: f32;
    var reciprocalLength: f32;
    var remapped: vec2<f32>;

    screenUv_1 = screenUv;
    refractionLength_1 = refractionLength;
    let _e189: f32 = refractionLength_1;
    reciprocalLength = (1f / max(_e189, 0.000001f));
    let _e194: f32 = reciprocalLength;
    let _e196: vec2<f32> = screenUv_1;
    let _e203: f32 = reciprocalLength;
    remapped = clamp((vec2(_e194) - (abs(((_e196 * 2f) - vec2(1f))) * _e203)), vec2(0f), vec2(1f));
    let _e212: vec2<f32> = remapped;
    let _e214: f32 = smoothstep01_(_e212.x);
    let _e215: vec2<f32> = remapped;
    let _e217: f32 = smoothstep01_(_e215.y);
    return (_e214 * _e217);
}

fn physicalRefractionOffset(screenUv_2: vec2<f32>, cameraForwardWS: vec3<f32>, tangentWorldNormal: vec3<f32>, strength_4: f32) -> vec2<f32> {
    var screenUv_3: vec2<f32>;
    var cameraForwardWS_1: vec3<f32>;
    var tangentWorldNormal_1: vec3<f32>;
    var strength_5: f32;
    var physicalRefractionRayWS: vec3<f32>;
    var physicalRefractionRayVS: vec3<f32>;
    var edgeMask: f32;
    var normalFallback: vec2<f32>;

    screenUv_3 = screenUv_2;
    cameraForwardWS_1 = cameraForwardWS;
    tangentWorldNormal_1 = tangentWorldNormal;
    strength_5 = strength_4;
    let _e192: f32 = global_1.material_IndexOfRefraction;
    if (_e192 == 1f) {
        return vec2(0f);
    }
    let _e197: vec3<f32> = cameraForwardWS_1;
    let _e199: vec3<f32> = tangentWorldNormal_1;
    let _e201: f32 = global_1.material_IndexOfRefraction;
    physicalRefractionRayWS = refract(-(_e197), _e199, (1f / _e201));
    let _e205: mat4x4<f32> = global.camera_ViewMat;
    let _e215: vec3<f32> = physicalRefractionRayWS;
    physicalRefractionRayVS = (mat3x3<f32>(_e205[0].xyz, _e205[1].xyz, _e205[2].xyz) * _e215);
    let _e218: vec2<f32> = screenUv_3;
    let _e219: vec3<f32> = physicalRefractionRayVS;
    let _e222: f32 = screenEdgeMask(_e218, length(_e219.xy));
    edgeMask = _e222;
    let _e224: vec3<f32> = tangentWorldNormal_1;
    normalFallback = (_e224.xz * 0.5f);
    let _e229: vec2<f32> = normalFallback;
    let _e230: vec3<f32> = physicalRefractionRayVS;
    let _e232: f32 = edgeMask;
    let _e235: f32 = strength_5;
    return (mix(_e229, _e230.xy, vec2(_e232)) * _e235);
}

fn screenInterior(uv_2: vec2<f32>) -> f32 {
    var uv_3: vec2<f32>;

    uv_3 = uv_2;
    let _e187: vec2<f32> = uv_3;
    let _e190: vec2<f32> = uv_3;
    let _e196: vec2<f32> = uv_3;
    let _e200: vec2<f32> = uv_3;
    return (((step(0.001f, _e187.x) * step(_e190.x, 0.999f)) * step(0.001f, _e196.y)) * step(_e200.y, 0.999f));
}

fn packedUv(sourceUv: vec2<f32>, tiling: vec2<f32>, timeValue: vec2<f32>, speed: f32, subTiling: f32, subSpeed: f32) -> vec4<f32> {
    var sourceUv_1: vec2<f32>;
    var tiling_1: vec2<f32>;
    var timeValue_1: vec2<f32>;
    var speed_1: f32;
    var subTiling_1: f32;
    var subSpeed_1: f32;
    var baseSpeed: vec2<f32>;
    var uv1_: vec2<f32>;
    var tiling2_: vec2<f32>;
    var uv2_: vec2<f32>;

    sourceUv_1 = sourceUv;
    tiling_1 = tiling;
    timeValue_1 = timeValue;
    speed_1 = speed;
    subTiling_1 = subTiling;
    subSpeed_1 = subSpeed;
    let _e196: f32 = speed_1;
    let _e198: vec2<f32> = tiling_1;
    baseSpeed = (vec2(_e196) * _e198);
    let _e201: vec2<f32> = sourceUv_1;
    let _e202: vec2<f32> = tiling_1;
    let _e204: vec2<f32> = timeValue_1;
    let _e205: vec2<f32> = baseSpeed;
    uv1_ = ((_e201 * _e202) + (_e204 * _e205));
    let _e209: vec2<f32> = tiling_1;
    let _e210: f32 = subTiling_1;
    tiling2_ = (_e209 * _e210);
    let _e213: vec2<f32> = sourceUv_1;
    let _e214: vec2<f32> = tiling2_;
    let _e216: vec2<f32> = timeValue_1;
    let _e217: f32 = speed_1;
    let _e218: f32 = subSpeed_1;
    let _e220: vec2<f32> = tiling2_;
    uv2_ = ((_e213 * _e214) + (_e216 * ((_e217 * _e218) * _e220)));
    let _e225: vec2<f32> = uv1_;
    let _e226: vec2<f32> = uv2_;
    return vec4<f32>(_e225.x, _e225.y, _e226.x, _e226.y);
}

fn waterConnectionFacts(p: vec2<f32>) -> vec4<f32> {
    var p_1: vec2<f32>;
    var result: vec4<f32> = vec4<f32>(1f, 1f, -1f, 1f);

    p_1 = p;
    let _e193: vec4<f32> = result;
    return _e193;
}

fn waterConnectionShore(p_2: vec2<f32>, original: f32) -> f32 {
    var p_3: vec2<f32>;
    var original_1: f32;
    var result_1: f32;

    p_3 = p_2;
    original_1 = original;
    let _e188: f32 = original_1;
    result_1 = _e188;
    let _e190: f32 = result_1;
    return _e190;
}

fn waterConnectionNormal(p_4: vec2<f32>, normal_2: vec3<f32>) -> vec3<f32> {
    var p_5: vec2<f32>;
    var normal_3: vec3<f32>;

    p_5 = p_4;
    normal_3 = normal_2;
    let _e192: vec3<f32> = normal_3;
    let _e193: vec2<f32> = p_5;
    let _e194: vec4<f32> = waterConnectionFacts(_e193);
    return normalize(mix(vec3<f32>(0f, 1f, 0f), _e192, vec3(_e194.x)));
}

fn sampleDetailNormal(worldXZ: vec2<f32>, worldPosition_3: vec3<f32>, elapsedTime: f32) -> vec3<f32> {
    var worldXZ_1: vec2<f32>;
    var worldPosition_4: vec3<f32>;
    var elapsedTime_1: f32;
    var timeValue_2: vec2<f32>;
    var farUv: vec4<f32>;
    var farNormal: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var farA: vec3<f32>;
    var farB: vec3<f32>;
    var pixelDistance: f32;
    var fadeFactor: f32;
    var nearUv: vec4<f32>;
    var nearNormal: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var nearA: vec3<f32>;
    var nearB: vec3<f32>;

    worldXZ_1 = worldXZ;
    worldPosition_4 = worldPosition_3;
    elapsedTime_1 = elapsedTime;
    let _e190: f32 = elapsedTime_1;
    let _e193: vec3<f32> = global.material_OceanWaveFadeAndTimeScale;
    timeValue_2 = (vec2(-(_e190)) * _e193.z);
    let _e197: vec2<f32> = worldXZ_1;
    let _e198: vec4<f32> = global_1.material_OceanNormalMapping;
    let _e201: vec2<f32> = timeValue_2;
    let _e202: vec4<f32> = global_1.material_OceanNormalParameters;
    let _e208: vec4<f32> = packedUv(_e197, vec2(_e198.z), _e201, (_e202.z * 0.5f), 0.5f, 0.15f);
    farUv = _e208;
    let _e215: vec4<f32> = global_1.material_OceanTextureEnabled;
    if (_e215.y > 0.5f) {
        {
            let _e219: vec4<f32> = farUv;
            let _e221: vec4<f32> = textureSample(gs_wgpu_tex_material_RoughWavesTexture, gs_wgpu_samp_material_RoughWavesTexture, _e219.xy);
            let _e223: vec3<f32> = decodeNormalMap(_e221.xyz);
            farA = _e223;
            let _e225: vec4<f32> = farUv;
            let _e227: vec4<f32> = textureSample(gs_wgpu_tex_material_RoughWavesTexture, gs_wgpu_samp_material_RoughWavesTexture, _e225.zw);
            let _e229: vec3<f32> = decodeNormalMap(_e227.xyz);
            farB = _e229;
            let _e231: vec3<f32> = farA;
            let _e232: vec3<f32> = farB;
            let _e233: vec3<f32> = blendNormalRnm(_e231, _e232);
            farNormal = _e233;
        }
    }
    let _e234: vec3<f32> = global.camera_Position;
    let _e235: vec3<f32> = worldPosition_4;
    pixelDistance = distance(_e234, _e235);
    let _e238: f32 = global_1.material_OceanNormalFadeEndDistance;
    let _e239: f32 = pixelDistance;
    let _e241: f32 = global_1.material_OceanNormalFadeEndDistance;
    let _e242: vec4<f32> = global_1.material_OceanNormalMapping;
    fadeFactor = clamp(((_e238 - _e239) / max((_e241 - _e242.w), 0.0001f)), 0f, 1f);
    let _e252: f32 = fadeFactor;
    if (_e252 <= 0f) {
        {
            let _e255: vec3<f32> = farNormal;
            let _e260: vec3<f32> = safeNormalize3_(_e255, vec3<f32>(0f, 0f, 1f));
            return _e260;
        }
    }
    let _e261: vec2<f32> = worldXZ_1;
    let _e262: vec4<f32> = global_1.material_OceanNormalMapping;
    let _e264: vec2<f32> = timeValue_2;
    let _e265: vec4<f32> = global_1.material_OceanNormalParameters;
    let _e267: vec4<f32> = global_1.material_OceanNormalParameters;
    let _e269: vec4<f32> = global_1.material_OceanNormalParameters;
    let _e271: vec4<f32> = packedUv(_e261, _e262.xy, _e264, _e265.z, _e267.y, _e269.w);
    nearUv = _e271;
    let _e278: vec4<f32> = global_1.material_OceanTextureEnabled;
    if (_e278.x > 0.5f) {
        {
            let _e282: vec4<f32> = nearUv;
            let _e284: vec4<f32> = textureSample(gs_wgpu_tex_material_SmoothWavesTexture, gs_wgpu_samp_material_SmoothWavesTexture, _e282.xy);
            let _e286: vec3<f32> = decodeNormalMap(_e284.xyz);
            nearA = _e286;
            let _e288: vec4<f32> = nearUv;
            let _e290: vec4<f32> = textureSample(gs_wgpu_tex_material_SmoothWavesTexture, gs_wgpu_samp_material_SmoothWavesTexture, _e288.zw);
            let _e292: vec3<f32> = decodeNormalMap(_e290.xyz);
            nearB = _e292;
            let _e294: vec3<f32> = nearA;
            let _e295: vec3<f32> = nearB;
            let _e296: vec3<f32> = blendNormalRnm(_e294, _e295);
            nearNormal = _e296;
        }
    }
    let _e297: vec3<f32> = farNormal;
    let _e298: vec3<f32> = nearNormal;
    let _e299: f32 = fadeFactor;
    let _e306: vec3<f32> = safeNormalize3_(mix(_e297, _e298, vec3(_e299)), vec3<f32>(0f, 0f, 1f));
    return _e306;
}

fn frag(input: Varyings) {
    var input_1: Varyings;
    var nearshoreUv: vec2<f32>;
    var outsideEdges: vec4<f32>;
    var outsideAtlas: f32;
    var outsideWet: f32;
    var verticalDepth_2: f32;
    var shoreDistance: f32;
    var clampedNearshoreUv: vec2<f32>;
    var nearshoreSample: vec4<f32>;
    var shoreAntialias: f32;
    var atlasCoverage: f32;
    var coverage: f32;
    var waterSurface_positionWS_1: vec3<f32>;
    var waterSurface_macroNormalWS_1: vec3<f32>;
    var waterSurface_tangentWS_1: vec3<f32>;
    var waterSurface_bitangentWS_1: vec3<f32>;
    var waterSurface_meshUv_1: vec2<f32>;
    var waterSurface_flowWS_1: vec2<f32> = vec2(0f);
    var waterSurface_coverage_1: f32;
    var waterSurface_verticalDepth_1: f32;
    var waterSurface_horizontalShoreDistance_1: f32;
    var waterSurface_obstacleContact_1: f32 = 0f;
    var waterSurface_waveCrest_1: f32;
    var farFieldWeight: f32;
    var farFieldColor: vec3<f32>;
    var farWaterClosure: vec4<f32>;
    var local_7: f32;
    var elapsedTime_2: f32;
    var macroNormal: vec3<f32>;
    var tangent: vec3<f32>;
    var bitangent: vec3<f32>;
    var tangentNormal: vec3<f32>;
    var detailNormal: vec3<f32>;
    var viewDirection_7: vec3<f32>;
    var screenUv_4: vec2<f32>;
    var surfaceEyeDepth: f32;
    var centeredDepthRaw: f32;
    var centeredEyeDepth: f32;
    var centeredDepthAvailable: f32;
    var centeredViewDepth: f32;
    var cameraForwardWS_2: vec3<f32>;
    var refractionOffset: vec2<f32>;
    var requestedDisplacedUv: vec2<f32>;
    var refractionScreenInterior: f32;
    var local_8: f32;
    var requestedDisplacedDepthRaw: f32;
    var requestedDisplacedEyeDepth: f32;
    var refractionValidity: f32;
    var displacedUv: vec2<f32>;
    var displacedDepthRaw: f32;
    var displacedEyeDepth: f32;
    var displacedDepthAvailable: f32;
    var centeredSceneColor: vec3<f32>;
    var refractedSceneColor: vec3<f32>;
    var local_9: vec3<f32>;
    var fallbackViewDepth: f32;
    var viewDepth: f32;
    var sceneRayEyeScale: f32;
    var fieldViewDirection: vec3<f32>;
    var fallbackRayDistance: f32;
    var sceneRayDepth: f32;
    var local_10: vec3<f32>;
    var local_11: vec3<f32>;
    var opaquePosition: vec3<f32>;
    var exactSurfaceNormalDepth: f32;
    var sampledSurfaceNormalDepth: f32;
    var grazingCorrection: f32;
    var surfaceNormalDepth: f32;
    var centeredDepthBehind: f32;
    var contactFoamMask: f32 = 0f;
    var appearanceCoastalAlpha: f32 = 1f;
    var appearanceBoundaryColor: vec3<f32> = vec3(0f);
    var appearanceBoundaryAlbedo: vec3<f32> = vec3(0f);
    var appearanceBoundaryAlbedoWeight: f32 = 0f;
    var appearanceBoundaryRoughness: f32 = 0f;
    var appearanceBoundaryRefractionSuppression: f32 = 0f;
    var appearanceBoundaryField0_: f32;
    var appearanceBoundaryRawNormalized0_: f32;
    var appearanceBoundaryNormalized0_: f32;
    var appearanceBoundaryMask0_: f32;
    var effectiveSurfaceRoughness: f32;
    var appearanceDepthTerm0_: f32;
    var appearanceDepthTerm1_: f32;
    var appearanceDepthTintFactor: f32;
    var appearanceDepthShallowColor: vec3<f32>;
    var appearanceDepthTintColor: vec3<f32>;
    var waterDensity: f32;
    var baseColor_2: vec4<f32>;
    var waterFog: f32;
    var offsetVector: vec2<f32>;
    var verticalIntersectionGradient: f32;
    var shoreIntersectionGradient: f32;
    var intersectionGradient: f32;
    var intersectionDistance: f32;
    var intersection: f32 = 0f;
    var intersectionTime: vec2<f32>;
    var intersectionUv: vec2<f32>;
    var intersectionNoise: f32;
    var intersectionSine: f32;
    var baseFoam: f32;
    var foamMask: f32;
    var foamUv: vec4<f32>;
    var foamTexture: f32 = 0f;
    var surfaceFoam: f32;
    var flattening: f32;
    var horizonFactor_1: f32;
    var lightDirectionVector: vec3<f32>;
    var sunlightAvailable_1: f32;
    var lightDirection_3: vec3<f32>;
    var unshadowedSunlightColor: vec3<f32>;
    var cloudShadowAttenuation: f32;
    var sunlightColor_1: vec3<f32>;
    var diffuseNormal: vec3<f32>;
    var ambientDiffuse: vec3<f32>;
    var lighting_3: WaterSurfaceResolvedLightingV2_;
    var diffuseLighting_3: vec3<f32>;
    var reflectionNormal: vec3<f32>;
    var analyticReflection: vec3<f32>;
    var reflectionDirection: vec3<f32>;
    var reflectionNormalDotView: f32;
    var reflectionSamplingRoughness: f32;
    var environmentReflection: vec3<f32>;
    var environmentValidity: f32;
    var sunReflection: vec3<f32>;
    var edgeFade: f32;
    var causticsMask: f32;
    var mainLightIntensity: f32;
    var causticsWeight: f32;
    var caustics: vec3<f32> = vec3(0f);
    var causticsTime: vec2<f32>;
    var causticsBase: vec2<f32>;
    var causticsA: vec3<f32>;
    var causticsB: vec3<f32>;
    var translucencyRadiance: vec3<f32>;
    var rawRefractionFacts_1: WaterSurfaceRawRefractionFactsV2_;
    var rawReflectionFacts_1: WaterSurfaceRawReflectionFactsV2_;
    var rawFoamFacts_1: WaterSurfaceRawFoamFactsV2_;
    var rawContributionPolicy_1: WaterSurfaceRawContributionPolicyV2_;
    var resolvedContributions: WaterSurfaceResolvedRawContributionsV2_;
    var closureInput_1: WaterSurfaceFinalClosureV2Input;
    var resolvedWaterClosure: vec4<f32>;
    var finalColor: vec3<f32>;
    var finalAlpha: f32;

    input_1 = input;
    let _e186: Varyings = input_1;
    let _e189: vec4<f32> = waterConnectionFacts(_e186.worldPosition.xz);
    if (_e189.w < 0.5f) {
        discard;
    }
    let _e193: Varyings = input_1;
    let _e196: vec4<f32> = global_1.material_NearshoreWorldToUv;
    let _e199: vec4<f32> = global_1.material_NearshoreWorldToUv;
    nearshoreUv = ((_e193.worldPosition.xz * _e196.xy) + _e199.zw);
    let _e205: vec2<f32> = nearshoreUv;
    let _e210: vec2<f32> = nearshoreUv;
    let _e215: vec2<f32> = nearshoreUv;
    let _e220: vec2<f32> = nearshoreUv;
    outsideEdges = vec4<f32>((1f - step(0f, _e205.x)), step(1.000001f, _e210.x), (1f - step(0f, _e215.y)), step(1.000001f, _e220.y));
    let _e225: vec4<f32> = outsideEdges;
    let _e227: vec4<f32> = outsideEdges;
    let _e230: vec4<f32> = outsideEdges;
    let _e232: vec4<f32> = outsideEdges;
    outsideAtlas = max(max(_e225.x, _e227.y), max(_e230.z, _e232.w));
    let _e238: vec4<f32> = global_1.material_NearshoreOutsidePolicy;
    let _e240: vec4<f32> = outsideEdges;
    let _e244: vec4<f32> = global_1.material_NearshoreOutsidePolicy;
    let _e246: vec4<f32> = outsideEdges;
    let _e251: vec4<f32> = global_1.material_NearshoreOutsidePolicy;
    let _e253: vec4<f32> = outsideEdges;
    let _e258: vec4<f32> = global_1.material_NearshoreOutsidePolicy;
    let _e260: vec4<f32> = outsideEdges;
    outsideWet = (((mix(1f, _e238.x, _e240.x) * mix(1f, _e244.y, _e246.y)) * mix(1f, _e251.z, _e253.z)) * mix(1f, _e258.w, _e260.w));
    let _e265: vec4<f32> = global_1.material_NearshoreDecode;
    let _e269: f32 = outsideWet;
    verticalDepth_2 = (max(_e265.x, 0.0001f) * _e269);
    let _e272: vec4<f32> = global_1.material_NearshoreDecode;
    let _e275: vec4<f32> = global_1.material_NearshoreDecode;
    let _e277: f32 = outsideWet;
    shoreDistance = mix(-(_e272.y), _e275.y, _e277);
    let _e280: f32 = outsideAtlas;
    if (_e280 < 0.5f) {
        {
            let _e283: vec2<f32> = nearshoreUv;
            clampedNearshoreUv = clamp(_e283, vec2(0f), vec2(1f));
            let _e290: vec2<f32> = clampedNearshoreUv;
            let _e292: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_NearshoreTexture, gs_wgpu_samp_material_NearshoreTexture, _e290, 0f);
            nearshoreSample = _e292;
            let _e294: vec4<f32> = nearshoreSample;
            let _e296: vec4<f32> = global_1.material_NearshoreDecode;
            let _e300: f32 = waterSpatialFieldDecodeDepth(_e294.z, max(_e296.x, 0.0001f));
            verticalDepth_2 = _e300;
            let _e301: vec4<f32> = nearshoreSample;
            let _e306: vec4<f32> = global_1.material_NearshoreDecode;
            let _e308: f32 = waterSpatialFieldDecodeSignedDistance(_e301.w, 2.007874f, -1.007874f, _e306.y);
            shoreDistance = _e308;
        }
    }
    let _e309: vec2<f32> = global_1.material_NearshoreCellSize;
    let _e311: vec2<f32> = global_1.material_NearshoreCellSize;
    let _e316: f32 = shoreDistance;
    let _e317: f32 = fwidth(_e316);
    let _e320: vec4<f32> = global_1.material_NearshoreDecode;
    shoreAntialias = max((max(_e309.x, _e311.y) * 0.42f), max((_e317 * 1.25f), (_e320.y * 0.007843138f)));
    let _e329: Varyings = input_1;
    let _e332: f32 = shoreDistance;
    let _e333: f32 = waterConnectionShore(_e329.worldPosition.xz, _e332);
    shoreDistance = _e333;
    let _e334: f32 = shoreAntialias;
    let _e336: f32 = shoreAntialias;
    let _e337: f32 = shoreDistance;
    atlasCoverage = smoothstep(-(_e334), _e336, _e337);
    let _e340: f32 = atlasCoverage;
    let _e341: f32 = outsideWet;
    let _e342: f32 = outsideAtlas;
    coverage = mix(_e340, _e341, _e342);
    let _e345: f32 = coverage;
    if (_e345 <= 0.001f) {
        discard;
    }
    let _e348: Varyings = input_1;
    waterSurface_positionWS_1 = _e348.worldPosition;
    let _e351: Varyings = input_1;
    waterSurface_macroNormalWS_1 = _e351.macroNormalWS;
    let _e354: Varyings = input_1;
    waterSurface_tangentWS_1 = _e354.tangentWS;
    let _e357: Varyings = input_1;
    let _e359: Varyings = input_1;
    waterSurface_bitangentWS_1 = normalize(cross(_e357.macroNormalWS, _e359.tangentWS));
    let _e364: vec2<f32> = nearshoreUv;
    waterSurface_meshUv_1 = _e364;
    let _e369: f32 = coverage;
    waterSurface_coverage_1 = _e369;
    let _e371: f32 = verticalDepth_2;
    waterSurface_verticalDepth_1 = _e371;
    let _e373: f32 = shoreDistance;
    waterSurface_horizontalShoreDistance_1 = _e373;
    let _e377: Varyings = input_1;
    waterSurface_waveCrest_1 = max(_e377.waveOffsetY, 0f);
    let _e382: vec2<f32> = global.material_OceanFarTransition;
    let _e384: vec2<f32> = global.material_OceanFarTransition;
    let _e386: vec3<f32> = global.camera_Position;
    let _e387: Varyings = input_1;
    farFieldWeight = smoothstep(_e382.x, _e384.y, distance(_e386, _e387.worldPosition));
    let _e392: f32 = farFieldWeight;
    if (_e392 >= 0.999f) {
        {
            let _e395: Varyings = input_1;
            let _e397: vec3<f32> = oceanFarFieldRadiance(_e395.worldPosition);
            farFieldColor = _e397;
            let _e399: vec3<f32> = farFieldColor;
            let _e400: f32 = coverage;
            farWaterClosure = vec4<f32>(_e399.x, _e399.y, _e399.z, _e400);
            let _e406: vec4<f32> = farWaterClosure;
            let _e407: vec4<f32> = waterSurfaceOutputWithPick(_e406);
            output_color = _e407;
            return;
        }
    } else {
        {
            let _e408: f32 = global.material_SurfaceTimeOverride;
            if (_e408 >= 0f) {
                let _e411: f32 = global.material_SurfaceTimeOverride;
                local_7 = _e411;
            } else {
                let _e412: vec4<f32> = global.scene_ElapsedTime;
                local_7 = _e412.x;
            }
            let _e415: f32 = local_7;
            elapsedTime_2 = _e415;
            let _e417: vec3<f32> = waterSurface_macroNormalWS_1;
            let _e418: f32 = global_1.material_AppearanceV2MacroNormalStrength;
            let _e419: vec3<f32> = waterSurfaceAmplifyMacroNormalSlopes(_e417, _e418);
            macroNormal = _e419;
            let _e421: Varyings = input_1;
            let _e423: vec3<f32> = macroNormal;
            let _e424: Varyings = input_1;
            let _e426: vec3<f32> = macroNormal;
            let _e434: vec3<f32> = safeNormalize3_((_e421.tangentWS - (_e423 * dot(_e424.tangentWS, _e426))), vec3<f32>(1f, 0f, 0f));
            tangent = _e434;
            let _e436: vec3<f32> = macroNormal;
            let _e437: vec3<f32> = tangent;
            let _e443: vec3<f32> = safeNormalize3_(cross(_e436, _e437), vec3<f32>(0f, 0f, 1f));
            bitangent = _e443;
            let _e445: Varyings = input_1;
            let _e448: Varyings = input_1;
            let _e450: f32 = elapsedTime_2;
            let _e451: vec3<f32> = sampleDetailNormal(_e445.worldPosition.xz, _e448.worldPosition, _e450);
            tangentNormal = _e451;
            let _e453: vec3<f32> = tangent;
            let _e454: vec3<f32> = tangentNormal;
            let _e457: vec3<f32> = bitangent;
            let _e458: vec3<f32> = tangentNormal;
            let _e462: vec3<f32> = macroNormal;
            let _e463: vec3<f32> = tangentNormal;
            let _e467: vec3<f32> = macroNormal;
            let _e468: vec3<f32> = safeNormalize3_((((_e453 * _e454.x) + (_e457 * _e458.y)) + (_e462 * _e463.z)), _e467);
            detailNormal = _e468;
            let _e470: vec3<f32> = global.camera_Position;
            let _e471: Varyings = input_1;
            let _e478: vec3<f32> = safeNormalize3_((_e470 - _e471.worldPosition), vec3<f32>(0f, 1f, 0f));
            viewDirection_7 = _e478;
            let _e480: Varyings = input_1;
            let _e483: Varyings = input_1;
            screenUv_4 = (((_e480.clipPosition.xy / vec2(_e483.clipPosition.w)) * 0.5f) + vec2(0.5f));
            let _e496: vec2<f32> = screenUv_4;
            screenUv_4.y = (1f - _e496.y);
            let _e499: Varyings = input_1;
            surfaceEyeDepth = -(_e499.positionVS.z);
            let _e504: vec2<f32> = screenUv_4;
            let _e505: vec4<f32> = textureSample(gs_wgpu_tex_camera_DepthTexture, gs_wgpu_samp_camera_DepthTexture, _e504);
            centeredDepthRaw = _e505.x;
            let _e508: f32 = centeredDepthRaw;
            let _e509: f32 = remapDepthBufferEyeDepth(_e508);
            centeredEyeDepth = _e509;
            let _e511: f32 = global_1.material_CameraFeaturesAvailable;
            let _e512: f32 = surfaceEyeDepth;
            let _e515: f32 = centeredEyeDepth;
            let _e518: f32 = centeredDepthRaw;
            centeredDepthAvailable = ((_e511 * step((_e512 + 0.0001f), _e515)) * step(_e518, 0.999999f));
            let _e523: f32 = centeredEyeDepth;
            let _e524: f32 = surfaceEyeDepth;
            let _e528: f32 = centeredDepthAvailable;
            centeredViewDepth = (max((_e523 - _e524), 0f) * _e528);
            let _e531: Varyings = input_1;
            let _e534: vec3<f32> = detailNormal;
            let _e535: vec3<f32> = waterConnectionNormal(_e531.worldPosition.xz, _e534);
            detailNormal = _e535;
            let _e538: vec4<f32> = global_1.camera_ViewInvMat[2];
            let _e541: Varyings = input_1;
            let _e543: vec3<f32> = global.camera_Position;
            let _e550: vec3<f32> = safeNormalize3_((_e541.worldPosition - _e543), vec3<f32>(0f, 0f, -1f));
            let _e551: vec3<f32> = safeNormalize3_(-(_e538.xyz), _e550);
            cameraForwardWS_2 = _e551;
            let _e553: vec2<f32> = screenUv_4;
            let _e554: vec3<f32> = cameraForwardWS_2;
            let _e555: vec3<f32> = detailNormal;
            let _e556: f32 = global_1.material_RefractionEnabled;
            let _e557: f32 = global_1.material_RefractionStrength;
            let _e559: f32 = global_1.material_AppearanceV2RefractionUvScale;
            let _e561: vec2<f32> = physicalRefractionOffset(_e553, _e554, _e555, ((_e556 * _e557) * _e559));
            let _e562: Varyings = input_1;
            refractionOffset = (_e561 / vec2(max(abs(_e562.clipPosition.w), 1f)));
            let _e572: vec2<f32> = refractionOffset;
            refractionOffset.y = -(_e572.y);
            let _e575: vec2<f32> = screenUv_4;
            let _e576: vec2<f32> = refractionOffset;
            requestedDisplacedUv = (_e575 + _e576);
            let _e579: vec2<f32> = requestedDisplacedUv;
            let _e580: f32 = screenInterior(_e579);
            refractionScreenInterior = _e580;
            let _e582: f32 = refractionScreenInterior;
            let _e585: vec2<f32> = refractionOffset;
            let _e586: vec2<f32> = refractionOffset;
            if ((_e582 > 0.5f) && (dot(_e585, _e586) > 0.0000000001f)) {
                let _e591: vec2<f32> = requestedDisplacedUv;
                let _e592: vec4<f32> = textureSample(gs_wgpu_tex_camera_DepthTexture, gs_wgpu_samp_camera_DepthTexture, _e591);
                local_8 = _e592.x;
            } else {
                let _e594: f32 = centeredDepthRaw;
                local_8 = _e594;
            }
            let _e596: f32 = local_8;
            requestedDisplacedDepthRaw = _e596;
            let _e598: f32 = requestedDisplacedDepthRaw;
            let _e599: f32 = remapDepthBufferEyeDepth(_e598);
            requestedDisplacedEyeDepth = _e599;
            let _e601: f32 = global_1.material_CameraFeaturesAvailable;
            let _e602: f32 = refractionScreenInterior;
            let _e604: f32 = surfaceEyeDepth;
            let _e607: f32 = requestedDisplacedEyeDepth;
            let _e610: f32 = requestedDisplacedDepthRaw;
            refractionValidity = (((_e601 * _e602) * step((_e604 + 0.0001f), _e607)) * step(_e610, 0.999999f));
            let _e615: vec2<f32> = refractionOffset;
            let _e616: f32 = refractionValidity;
            refractionOffset = (_e615 * _e616);
            let _e618: vec2<f32> = screenUv_4;
            let _e619: vec2<f32> = refractionOffset;
            displacedUv = (_e618 + _e619);
            let _e622: f32 = centeredDepthRaw;
            let _e623: f32 = requestedDisplacedDepthRaw;
            let _e624: f32 = refractionValidity;
            displacedDepthRaw = mix(_e622, _e623, _e624);
            let _e627: f32 = displacedDepthRaw;
            let _e628: f32 = remapDepthBufferEyeDepth(_e627);
            displacedEyeDepth = _e628;
            let _e630: f32 = global_1.material_CameraFeaturesAvailable;
            let _e631: f32 = surfaceEyeDepth;
            let _e634: f32 = displacedEyeDepth;
            let _e637: f32 = displacedDepthRaw;
            displacedDepthAvailable = ((_e630 * step((_e631 + 0.0001f), _e634)) * step(_e637, 0.999999f));
            let _e644: f32 = refractionValidity;
            let _e647: f32 = global_1.material_RefractionEnabled;
            if ((_e644 > 0.9999f) && (_e647 > 0.5f)) {
                {
                    let _e651: vec2<f32> = displacedUv;
                    let _e652: vec4<f32> = textureSample(gs_wgpu_tex_camera_OpaqueTexture, gs_wgpu_samp_camera_OpaqueTexture, _e651);
                    refractedSceneColor = _e652.xyz;
                    let _e654: vec3<f32> = refractedSceneColor;
                    centeredSceneColor = _e654;
                }
            } else {
                {
                    let _e655: vec2<f32> = screenUv_4;
                    let _e656: vec4<f32> = textureSample(gs_wgpu_tex_camera_OpaqueTexture, gs_wgpu_samp_camera_OpaqueTexture, _e655);
                    centeredSceneColor = _e656.xyz;
                    let _e658: f32 = refractionValidity;
                    if (_e658 > 0.001f) {
                        let _e661: vec2<f32> = displacedUv;
                        let _e662: vec4<f32> = textureSample(gs_wgpu_tex_camera_OpaqueTexture, gs_wgpu_samp_camera_OpaqueTexture, _e661);
                        local_9 = _e662.xyz;
                    } else {
                        let _e664: vec3<f32> = centeredSceneColor;
                        local_9 = _e664;
                    }
                    let _e666: vec3<f32> = local_9;
                    refractedSceneColor = _e666;
                }
            }
            let _e667: f32 = verticalDepth_2;
            let _e668: f32 = centeredViewDepth;
            let _e669: f32 = centeredDepthAvailable;
            fallbackViewDepth = mix(_e667, _e668, _e669);
            let _e672: f32 = fallbackViewDepth;
            let _e673: f32 = displacedEyeDepth;
            let _e674: f32 = surfaceEyeDepth;
            let _e678: f32 = displacedDepthAvailable;
            viewDepth = mix(_e672, max((_e673 - _e674), 0f), _e678);
            let _e681: f32 = surfaceEyeDepth;
            let _e682: vec3<f32> = global.camera_Position;
            let _e683: Varyings = input_1;
            sceneRayEyeScale = (_e681 / max(length((_e682 - _e683.worldPosition)), 0.001f));
            let _e691: vec3<f32> = viewDirection_7;
            fieldViewDirection = _e691;
            let _e693: f32 = verticalDepth_2;
            let _e694: vec3<f32> = waterSurface_macroNormalWS_1;
            let _e695: vec3<f32> = fieldViewDirection;
            let _e696: f32 = waterSurfaceDerivedSceneRayDepth(_e693, _e694, _e695);
            fallbackRayDistance = _e696;
            let _e698: f32 = fallbackRayDistance;
            let _e699: f32 = viewDepth;
            let _e700: f32 = sceneRayEyeScale;
            let _e704: f32 = centeredDepthAvailable;
            let _e705: f32 = displacedDepthAvailable;
            sceneRayDepth = mix(_e698, (_e699 / max(_e700, 0.001f)), max(_e704, _e705));
            let _e709: f32 = displacedDepthAvailable;
            if (_e709 > 0.5f) {
                let _e712: vec2<f32> = displacedUv;
                let _e713: f32 = displacedEyeDepth;
                let _e714: vec3<f32> = reconstructOpaquePositionWS(_e712, _e713);
                local_11 = _e714;
            } else {
                let _e715: f32 = centeredDepthAvailable;
                if (_e715 > 0.5f) {
                    let _e718: vec2<f32> = screenUv_4;
                    let _e719: f32 = centeredEyeDepth;
                    let _e720: vec3<f32> = reconstructOpaquePositionWS(_e718, _e719);
                    local_10 = _e720;
                } else {
                    let _e721: Varyings = input_1;
                    let _e724: f32 = verticalDepth_2;
                    local_10 = (_e721.worldPosition - vec3<f32>(0f, _e724, 0f));
                }
                let _e729: vec3<f32> = local_10;
                local_11 = _e729;
            }
            let _e731: vec3<f32> = local_11;
            opaquePosition = _e731;
            let _e733: Varyings = input_1;
            let _e735: vec3<f32> = opaquePosition;
            let _e737: vec3<f32> = waterSurface_macroNormalWS_1;
            exactSurfaceNormalDepth = abs(dot((_e733.worldPosition - _e735), normalize(_e737)));
            let _e742: f32 = verticalDepth_2;
            let _e743: f32 = exactSurfaceNormalDepth;
            let _e744: f32 = centeredDepthAvailable;
            let _e745: f32 = displacedDepthAvailable;
            sampledSurfaceNormalDepth = mix(_e742, _e743, max(_e744, _e745));
            let _e750: vec3<f32> = viewDirection_7;
            let _e751: vec3<f32> = waterSurface_macroNormalWS_1;
            grazingCorrection = pow((1f - clamp(dot(_e750, _e751), 0f, 1f)), 64f);
            let _e760: f32 = sampledSurfaceNormalDepth;
            let _e761: f32 = viewDepth;
            let _e762: f32 = grazingCorrection;
            surfaceNormalDepth = mix(_e760, _e761, _e762);
            let _e767: f32 = centeredViewDepth;
            centeredDepthBehind = smoothstep(0.03f, 0.22f, _e767);
            let _e786: f32 = waterSurface_horizontalShoreDistance_1;
            appearanceBoundaryField0_ = _e786;
            let _e788: f32 = appearanceBoundaryField0_;
            let _e789: f32 = global_1.material_AppearanceV2Boundary0Range;
            appearanceBoundaryRawNormalized0_ = (_e788 / max(_e789, 0.0001f));
            let _e794: f32 = appearanceBoundaryRawNormalized0_;
            appearanceBoundaryNormalized0_ = clamp(_e794, 0f, 1f);
            let _e801: f32 = appearanceBoundaryNormalized0_;
            appearanceBoundaryMask0_ = smoothstep(0f, 1f, _e801);
            let _e805: f32 = appearanceBoundaryMask0_;
            appearanceBoundaryMask0_ = (1f - _e805);
            let _e807: f32 = appearanceBoundaryMask0_;
            appearanceBoundaryMask0_ = (_e807 * 1f);
            let _e810: f32 = appearanceBoundaryRefractionSuppression;
            let _e811: f32 = appearanceBoundaryMask0_;
            let _e812: f32 = global_1.material_AppearanceV2Boundary0RefractionSuppression;
            let _e814: f32 = global_1.material_AppearanceV2BoundaryMaterialEnabled;
            appearanceBoundaryRefractionSuppression = max(_e810, ((_e811 * _e812) * _e814));
            let _e817: f32 = global_1.material_Roughness;
            let _e818: f32 = appearanceBoundaryRoughness;
            effectiveSurfaceRoughness = clamp((_e817 + _e818), 0.045f, 1f);
            let _e824: f32 = viewDepth;
            let _e827: f32 = global_1.material_AppearanceV2DepthCoefficient0_;
            appearanceDepthTerm0_ = (max(_e824, 0f) * _e827);
            let _e830: f32 = surfaceNormalDepth;
            let _e833: f32 = global_1.material_AppearanceV2DepthCoefficient1_;
            appearanceDepthTerm1_ = (max(_e830, 0f) * _e833);
            let _e836: f32 = appearanceDepthTerm0_;
            let _e837: f32 = appearanceDepthTerm1_;
            let _e838: f32 = waterSurfaceCompositeExponentialDensity(_e836, _e837);
            appearanceDepthTintFactor = _e838;
            let _e840: vec4<f32> = global_1.material_AppearanceV2DepthShallowColor;
            appearanceDepthShallowColor = _e840.xyz;
            let _e843: vec4<f32> = global_1.material_AppearanceV2DepthDeepColor;
            appearanceDepthTintColor = _e843.xyz;
            let _e846: vec3<f32> = appearanceDepthTintColor;
            let _e848: f32 = appearanceBoundaryAlbedoWeight;
            let _e851: vec3<f32> = appearanceBoundaryAlbedo;
            appearanceDepthTintColor = ((_e846 * (1f - _e848)) + _e851);
            let _e853: f32 = appearanceDepthTintFactor;
            let _e854: f32 = appearanceBoundaryAlbedoWeight;
            appearanceDepthTintFactor = clamp((_e853 + _e854), 0f, 1f);
            let _e859: f32 = appearanceDepthTintFactor;
            waterDensity = _e859;
            let _e861: vec4<f32> = global_1.material_AppearanceV2DepthShallowColor;
            let _e862: vec4<f32> = global_1.material_AppearanceV2DepthDeepColor;
            let _e863: f32 = waterDensity;
            baseColor_2 = mix(_e861, _e862, vec4(_e863));
            let _e867: f32 = waterDensity;
            let _e868: vec4<f32> = baseColor_2;
            waterFog = (_e867 * _e868.w);
            let _e872: Varyings = input_1;
            let _e875: vec3<f32> = detailNormal;
            offsetVector = clamp((vec2(_e872.waveOffsetY) + _e875.xz), vec2(0f), vec2(1f));
            let _e885: f32 = surfaceNormalDepth;
            let _e887: vec4<f32> = global_1.material_OceanIntersectionParameters;
            verticalIntersectionGradient = (1f - clamp((exp(_e885) / _e887.y), 0f, 1f));
            let _e895: f32 = appearanceBoundaryMask0_;
            shoreIntersectionGradient = _e895;
            let _e897: f32 = verticalIntersectionGradient;
            let _e898: f32 = shoreIntersectionGradient;
            let _e900: f32 = coverage;
            intersectionGradient = (max(_e897, _e898) * _e900);
            let _e903: f32 = intersectionGradient;
            let _e904: vec4<f32> = global_1.material_OceanIntersectionParameters;
            intersectionDistance = clamp((_e903 / _e904.z), 0f, 1f);
            let _e913: vec4<f32> = global_1.material_OceanIntersectionParameters;
            let _e917: f32 = global_1.material_OceanIntersectionTextureEnabled;
            if ((_e913.x > 0f) && (_e917 > 0.5f)) {
                {
                    let _e921: f32 = intersectionDistance;
                    if (_e921 > 0f) {
                        {
                            let _e924: f32 = elapsedTime_2;
                            let _e927: vec4<f32> = global_1.material_OceanIntersectionMotion;
                            intersectionTime = (vec2(-(_e924)) * _e927.x);
                            let _e931: Varyings = input_1;
                            let _e934: vec2<f32> = offsetVector;
                            let _e935: vec4<f32> = global_1.material_OceanIntersectionMotion;
                            let _e939: vec4<f32> = global_1.material_OceanIntersectionParameters;
                            let _e942: vec2<f32> = intersectionTime;
                            intersectionUv = (((_e931.worldPosition.xz + (_e934 * _e935.z)) * _e939.w) + _e942);
                            let _e945: vec2<f32> = intersectionUv;
                            let _e946: vec4<f32> = textureSample(gs_wgpu_tex_material_IntersectionNoiseTexture, gs_wgpu_samp_material_IntersectionNoiseTexture, _e945);
                            intersectionNoise = _e946.x;
                            let _e949: vec2<f32> = intersectionTime;
                            let _e953: f32 = intersectionGradient;
                            let _e954: vec4<f32> = global_1.material_OceanIntersectionMotion;
                            let _e959: f32 = global_1.material_OceanIntersectionRippleStrength;
                            intersectionSine = (sin(((_e949.y * 10f) - (_e953 * _e954.w))) * _e959);
                            let _e962: f32 = intersectionNoise;
                            let _e963: f32 = intersectionSine;
                            let _e965: f32 = intersectionDistance;
                            let _e967: f32 = intersectionDistance;
                            intersectionNoise = clamp((((_e962 + _e963) * _e965) + _e967), 0f, 1f);
                            let _e972: vec4<f32> = global_1.material_OceanIntersectionMotion;
                            let _e974: f32 = intersectionNoise;
                            let _e976: f32 = coverage;
                            let _e978: vec4<f32> = global_1.material_OceanIntersectionParameters;
                            intersection = ((step(_e972.y, _e974) * _e976) * _e978.x);
                        }
                    } else {
                        let _e981: vec4<f32> = global_1.material_OceanIntersectionMotion;
                        if (_e981.y <= 0f) {
                            {
                                let _e985: f32 = coverage;
                                let _e986: vec4<f32> = global_1.material_OceanIntersectionParameters;
                                intersection = (_e985 * _e986.x);
                            }
                        }
                    }
                }
            }
            let _e989: vec4<f32> = global_1.material_OceanSurfaceFoamParameters;
            baseFoam = clamp(_e989.y, 0f, 1f);
            let _e996: f32 = baseFoam;
            foamMask = clamp((1f - _e996), 0f, 1f);
            let _e1002: Varyings = input_1;
            let _e1005: vec2<f32> = offsetVector;
            let _e1006: vec4<f32> = global_1.material_OceanSurfaceFoamMapping;
            let _e1010: vec4<f32> = global_1.material_OceanSurfaceFoamMapping;
            let _e1012: f32 = elapsedTime_2;
            let _e1015: vec4<f32> = global_1.material_OceanSurfaceFoamParameters;
            let _e1017: vec4<f32> = global_1.material_OceanSurfaceFoamParameters;
            let _e1019: vec4<f32> = global_1.material_OceanSurfaceFoamMapping;
            let _e1021: vec4<f32> = packedUv((_e1002.worldPosition.xz + (_e1005 * _e1006.y)), _e1010.zw, vec2(-(_e1012)), _e1015.w, _e1017.z, _e1019.x);
            foamUv = _e1021;
            let _e1025: vec4<f32> = global_1.material_OceanTextureEnabled;
            if (_e1025.w > 0.5f) {
                let _e1029: vec4<f32> = foamUv;
                let _e1031: vec4<f32> = textureSample(gs_wgpu_tex_material_FoamTexture, gs_wgpu_samp_material_FoamTexture, _e1029.xy);
                let _e1033: vec4<f32> = foamUv;
                let _e1035: vec4<f32> = textureSample(gs_wgpu_tex_material_FoamTexture, gs_wgpu_samp_material_FoamTexture, _e1033.zw);
                foamTexture = clamp((_e1031.x + _e1035.x), 0f, 1f);
            }
            let _e1041: f32 = foamMask;
            let _e1042: f32 = foamMask;
            let _e1045: f32 = foamTexture;
            let _e1047: vec4<f32> = global_1.material_OceanSurfaceFoamColor;
            let _e1050: vec4<f32> = global_1.material_OceanSurfaceFoamParameters;
            let _e1053: vec4<f32> = global_1.material_OceanTextureEnabled;
            surfaceFoam = (((smoothstep(_e1041, (_e1042 + 1f), _e1045) * _e1047.w) * _e1050.x) * _e1053.w);
            let _e1057: f32 = intersection;
            let _e1058: f32 = surfaceFoam;
            flattening = clamp(max(_e1057, _e1058), 0f, 1f);
            let _e1064: vec3<f32> = detailNormal;
            let _e1065: vec3<f32> = macroNormal;
            let _e1066: f32 = flattening;
            let _e1069: vec3<f32> = macroNormal;
            let _e1070: vec3<f32> = safeNormalize3_(mix(_e1064, _e1065, vec3(_e1066)), _e1069);
            detailNormal = _e1070;
            let _e1072: vec3<f32> = viewDirection_7;
            let _e1084: vec4<f32> = global_1.material_OceanHorizonColor;
            horizonFactor_1 = (pow((1f - clamp(dot(_e1072, vec3<f32>(0f, 1f, 0f)), 0f, 1f)), 8f) * _e1084.w);
            let _e1088: vec3<f32> = global_1.scene_SunlightDirection;
            lightDirectionVector = -(_e1088);
            let _e1092: vec3<f32> = lightDirectionVector;
            let _e1093: vec3<f32> = lightDirectionVector;
            sunlightAvailable_1 = step(0.00000001f, dot(_e1092, _e1093));
            let _e1097: vec3<f32> = lightDirectionVector;
            let _e1102: vec3<f32> = safeNormalize3_(_e1097, vec3<f32>(0f, 1f, 0f));
            lightDirection_3 = _e1102;
            let _e1104: vec4<f32> = global_1.scene_SunlightColor;
            let _e1109: f32 = sunlightAvailable_1;
            unshadowedSunlightColor = (max(_e1104.xyz, vec3(0f)) * _e1109);
            let _e1112: Varyings = input_1;
            let _e1114: f32 = sampleVolumetricCloudShadow(_e1112.worldPosition);
            cloudShadowAttenuation = _e1114;
            let _e1116: vec3<f32> = unshadowedSunlightColor;
            let _e1117: f32 = cloudShadowAttenuation;
            sunlightColor_1 = (_e1116 * _e1117);
            let _e1120: vec3<f32> = macroNormal;
            let _e1121: vec3<f32> = detailNormal;
            let _e1122: vec4<f32> = global_1.material_OceanNormalParameters;
            let _e1126: vec3<f32> = macroNormal;
            let _e1127: vec3<f32> = safeNormalize3_(mix(_e1120, _e1121, vec3(_e1122.x)), _e1126);
            diffuseNormal = _e1127;
            let _e1129: vec3<f32> = diffuseNormal;
            let _e1130: vec3<f32> = waterSurfaceAmbientDiffuseRadiance(_e1129);
            ambientDiffuse = _e1130;
            let _e1132: vec3<f32> = ambientDiffuse;
            let _e1133: WaterSurfaceResolvedLightingV2_ = waterSurfaceCreateResolvedLightingV2_(_e1132);
            lighting_3 = _e1133;
            let _e1135: WaterSurfaceResolvedLightingV2_ = lighting_3;
            let _e1136: vec3<f32> = sunlightColor_1;
            let _e1137: vec3<f32> = diffuseNormal;
            let _e1138: vec3<f32> = viewDirection_7;
            let _e1143: vec3<f32> = diffuseNormal;
            let _e1144: vec3<f32> = lightDirection_3;
            let _e1151: f32 = global_1.material_Roughness;
            let _e1154: WaterSurfaceResolvedLightingV2_ = waterSurfaceAccumulateDirectLightingV2_(_e1135, _e1136, clamp(dot(_e1137, _e1138), 0f, 1f), max(dot(_e1143, _e1144), 0f), 0f, 0f, 0.02f, _e1151, 3f, 0f);
            lighting_3 = _e1154;
            let _e1155: WaterSurfaceResolvedLightingV2_ = lighting_3;
            diffuseLighting_3 = _e1155.diffuseRadiance;
            let _e1158: vec3<f32> = macroNormal;
            let _e1159: vec3<f32> = detailNormal;
            let _e1160: f32 = global_1.material_OceanReflectionNormalBlend;
            let _e1163: vec3<f32> = macroNormal;
            let _e1164: vec3<f32> = safeNormalize3_(mix(_e1158, _e1159, vec3(_e1160)), _e1163);
            reflectionNormal = _e1164;
            let _e1166: vec3<f32> = reflectionNormal;
            let _e1168: f32 = global_1.material_Roughness;
            let _e1170: vec3<f32> = waterSurfaceResolveAnalyticReflectionFallbackV2_(_e1166.y, _e1168, 1f);
            analyticReflection = _e1170;
            let _e1172: vec3<f32> = viewDirection_7;
            let _e1174: vec3<f32> = reflectionNormal;
            reflectionDirection = reflect(-(_e1172), _e1174);
            let _e1177: vec3<f32> = reflectionNormal;
            let _e1178: vec3<f32> = viewDirection_7;
            reflectionNormalDotView = clamp(dot(_e1177, _e1178), 0f, 1f);
            let _e1184: f32 = global_1.material_Roughness;
            reflectionSamplingRoughness = _e1184;
            let _e1186: f32 = farFieldWeight;
            if (_e1186 > 0f) {
                {
                    let _e1189: vec3<f32> = reflectionDirection;
                    let _e1190: vec3<f32> = viewDirection_7;
                    let _e1191: vec3<f32> = oceanFarReflectionDirection(_e1190);
                    let _e1192: f32 = farFieldWeight;
                    let _e1199: vec3<f32> = safeNormalize3_(mix(_e1189, _e1191, vec3(_e1192)), vec3<f32>(0f, 1f, 0f));
                    reflectionDirection = _e1199;
                    let _e1200: f32 = reflectionNormalDotView;
                    let _e1201: vec3<f32> = viewDirection_7;
                    let _e1202: f32 = oceanFarReflectionNormalDotView(_e1201);
                    let _e1203: f32 = farFieldWeight;
                    reflectionNormalDotView = mix(_e1200, _e1202, _e1203);
                    let _e1205: f32 = global_1.material_Roughness;
                    let _e1206: vec2<f32> = global_1.material_OceanFarReflectionFilter;
                    let _e1208: f32 = farFieldWeight;
                    reflectionSamplingRoughness = mix(_e1205, _e1206.x, _e1208);
                }
            }
            let _e1212: vec3<f32> = reflectionDirection;
            let _e1213: vec3<f32> = waterSurface_positionWS_1;
            let _e1214: f32 = reflectionSamplingRoughness;
            waterSurfaceSampleRawEnvironmentReflectionV2_(_e1212, _e1213, _e1214, (&environmentReflection), (&environmentValidity));
            let _e1219: vec3<f32> = sunlightColor_1;
            let _e1220: vec3<f32> = lightDirection_3;
            let _e1221: vec3<f32> = viewDirection_7;
            let _e1222: vec3<f32> = macroNormal;
            let _e1223: vec3<f32> = detailNormal;
            let _e1224: f32 = global_1.material_AppearanceV2DirectionalHighlightDistortion;
            let _e1225: f32 = global_1.material_AppearanceV2DirectionalHighlightExponent;
            let _e1226: f32 = global_1.material_AppearanceV2DirectionalHighlightStrength;
            let _e1227: f32 = global_1.material_AppearanceV2DirectionalHighlightSharp;
            let _e1228: vec3<f32> = waterSurfaceDirectionalHighlightV2_(_e1219, _e1220, _e1221, _e1222, _e1223, _e1224, _e1225, _e1226, _e1227);
            sunReflection = _e1228;
            let _e1230: f32 = surfaceNormalDepth;
            edgeFade = clamp((_e1230 / 0.187f), 0f, 1f);
            let _e1238: f32 = waterFog;
            let _e1240: f32 = intersection;
            let _e1242: f32 = surfaceFoam;
            let _e1247: f32 = coverage;
            causticsMask = (clamp((((1f - _e1238) - _e1240) - _e1242), 0f, 1f) * _e1247);
            let _e1250: vec3<f32> = unshadowedSunlightColor;
            mainLightIntensity = dot(_e1250, vec3<f32>(0.3f, 0.59f, 0.11f));
            let _e1257: f32 = causticsMask;
            let _e1258: vec4<f32> = global_1.material_OceanCausticsParameters;
            let _e1261: f32 = mainLightIntensity;
            let _e1263: f32 = cloudShadowAttenuation;
            let _e1265: vec4<f32> = global_1.material_OceanCausticsParameters;
            let _e1268: vec4<f32> = global_1.material_OceanTextureEnabled;
            causticsWeight = (((((_e1257 * _e1258.y) * _e1261) * _e1263) * _e1265.x) * _e1268.z);
            let _e1275: f32 = causticsWeight;
            if (_e1275 > 0f) {
                {
                    let _e1278: f32 = elapsedTime_2;
                    let _e1281: vec4<f32> = global_1.material_OceanCausticsMotion;
                    causticsTime = (vec2(-(_e1278)) * _e1281.x);
                    let _e1285: vec3<f32> = opaquePosition;
                    let _e1287: vec3<f32> = macroNormal;
                    let _e1288: vec3<f32> = detailNormal;
                    let _e1289: vec4<f32> = global_1.material_OceanCausticsParameters;
                    causticsBase = (_e1285.xz + mix(_e1287, _e1288, vec3(_e1289.w)).xz);
                    let _e1296: vec2<f32> = causticsBase;
                    let _e1297: vec4<f32> = global_1.material_OceanCausticsMotion;
                    let _e1300: vec2<f32> = causticsTime;
                    let _e1302: vec4<f32> = textureSample(gs_wgpu_tex_material_CausticsTexture, gs_wgpu_samp_material_CausticsTexture, ((_e1296 * _e1297.y) + _e1300));
                    causticsA = _e1302.xyz;
                    let _e1305: vec2<f32> = causticsBase;
                    let _e1306: vec4<f32> = global_1.material_OceanCausticsMotion;
                    let _e1311: vec2<f32> = causticsTime;
                    let _e1313: vec4<f32> = textureSample(gs_wgpu_tex_material_CausticsTexture, gs_wgpu_samp_material_CausticsTexture, (((_e1305 * _e1306.y) * 0.8f) - _e1311));
                    causticsB = _e1313.xyz;
                    let _e1316: vec3<f32> = causticsA;
                    let _e1317: vec3<f32> = causticsB;
                    caustics = (min(_e1316, _e1317) * 2f);
                    let _e1321: vec3<f32> = caustics;
                    let _e1323: vec3<f32> = caustics;
                    let _e1324: vec4<f32> = global_1.material_OceanCausticsParameters;
                    let _e1328: f32 = causticsWeight;
                    caustics = (mix(_e1321.xxx, _e1323, vec3(_e1324.z)) * _e1328);
                }
            }
            let _e1330: vec4<f32> = global_1.material_AppearanceV2DepthShallowColor;
            let _e1332: vec3<f32> = sunlightColor_1;
            let _e1333: vec3<f32> = lightDirection_3;
            let _e1334: vec3<f32> = viewDirection_7;
            let _e1335: vec3<f32> = macroNormal;
            let _e1336: vec3<f32> = detailNormal;
            let _e1340: vec3<f32> = macroNormal;
            let _e1341: vec3<f32> = safeNormalize3_((_e1335 + (_e1336 * 0.1f)), _e1340);
            let _e1342: vec4<f32> = global_1.material_OceanTranslucencyParameters;
            let _e1344: vec4<f32> = global_1.material_OceanTranslucencyParameters;
            let _e1346: vec4<f32> = global_1.material_OceanTranslucencyParameters;
            let _e1348: f32 = global_1.material_OceanTranslucencyCurvatureMask;
            let _e1349: f32 = waterFog;
            let _e1350: f32 = edgeFade;
            let _e1355: vec4<f32> = global_1.material_OceanTranslucencyParameters;
            let _e1358: vec3<f32> = waterSurfaceBoundedTranslucency(_e1330.xyz, _e1332, _e1333, _e1334, _e1341, _e1342.y, _e1344.z, _e1346.w, _e1348, (clamp((_e1349 + _e1350), 0f, 1f) * _e1355.x));
            translucencyRadiance = _e1358;
            let _e1362: vec3<f32> = centeredSceneColor;
            rawRefractionFacts_1.centeredSceneSample = _e1362;
            let _e1364: vec3<f32> = refractedSceneColor;
            rawRefractionFacts_1.displacedSceneSample = _e1364;
            let _e1366: f32 = refractionValidity;
            rawRefractionFacts_1.displacedSampleValidity = _e1366;
            let _e1369: f32 = waterFog;
            rawRefractionFacts_1.depthWeight = (1f - _e1369);
            let _e1372: f32 = edgeFade;
            rawRefractionFacts_1.shoreValidity = _e1372;
            let _e1374: f32 = waterSurface_coverage_1;
            rawRefractionFacts_1.coverage = _e1374;
            let _e1377: vec3<f32> = analyticReflection;
            rawReflectionFacts_1.analyticSample = _e1377;
            let _e1379: vec3<f32> = environmentReflection;
            rawReflectionFacts_1.environmentSample = _e1379;
            let _e1381: f32 = environmentValidity;
            rawReflectionFacts_1.environmentValidity = _e1381;
            rawReflectionFacts_1.ssrPremultipliedSample = vec3(0f);
            rawReflectionFacts_1.ssrValidity = 0f;
            let _e1389: f32 = surfaceFoam;
            rawFoamFacts_1.surfaceSignal = _e1389;
            let _e1391: f32 = intersection;
            rawFoamFacts_1.shoreSignal = _e1391;
            rawFoamFacts_1.crestSignal = 0f;
            rawFoamFacts_1.currentSignal = 0f;
            rawFoamFacts_1.wakeSignal = 0f;
            rawFoamFacts_1.contactSignal = 0f;
            rawFoamFacts_1.localSignal = 0f;
            rawFoamFacts_1.motionScale = 1f;
            let _e1405: f32 = global_1.material_OceanFoamEnabled;
            rawFoamFacts_1.enabled = _e1405;
            rawContributionPolicy_1.primaryColorClosureModel = 3f;
            let _e1410: f32 = global_1.material_RefractionEnabled;
            rawContributionPolicy_1.refractionEnabled = _e1410;
            rawContributionPolicy_1.clarity = 1f;
            let _e1414: f32 = appearanceBoundaryRefractionSuppression;
            rawContributionPolicy_1.boundaryRefractionSuppression = _e1414;
            rawContributionPolicy_1.reflectionSource = 1f;
            rawContributionPolicy_1.ssrCompositeIntensity = 0f;
            let _e1420: f32 = global_1.material_OceanFoamIntensity;
            rawContributionPolicy_1.foamIntensity = _e1420;
            let _e1421: WaterSurfaceRawRefractionFactsV2_ = rawRefractionFacts_1;
            let _e1422: WaterSurfaceRawReflectionFactsV2_ = rawReflectionFacts_1;
            let _e1423: WaterSurfaceRawFoamFactsV2_ = rawFoamFacts_1;
            let _e1424: WaterSurfaceRawContributionPolicyV2_ = rawContributionPolicy_1;
            let _e1425: f32 = waterSurfaceResolveRawFoamWeightV2_(_e1423, _e1424);
            let _e1426: WaterSurfaceRawContributionPolicyV2_ = rawContributionPolicy_1;
            let _e1427: WaterSurfaceResolvedRawContributionsV2_ = waterSurfaceResolveRawContributionsV2_(_e1421, _e1422, _e1425, _e1426);
            resolvedContributions = _e1427;
            let _e1431: vec3<f32> = caustics;
            let _e1432: vec3<f32> = translucencyRadiance;
            let _e1434: Varyings = input_1;
            let _e1437: vec4<f32> = waterConnectionFacts(_e1434.worldPosition.xz);
            closureInput_1.additionalTransmissionRadiance = ((_e1431 + _e1432) * _e1437.x);
            let _e1441: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
            closureInput_1.primarySceneColor = _e1441.refractionSceneColor;
            let _e1444: vec4<f32> = global_1.material_AppearanceV2DepthShallowColor;
            let _e1446: vec4<f32> = global_1.material_OceanHorizonColor;
            let _e1448: f32 = horizonFactor_1;
            closureInput_1.surfaceColor = mix(_e1444.xyz, _e1446.xyz, vec3(_e1448));
            let _e1452: vec3<f32> = appearanceDepthTintColor;
            let _e1453: vec4<f32> = global_1.material_OceanHorizonColor;
            let _e1455: f32 = horizonFactor_1;
            closureInput_1.depthColor = mix(_e1452, _e1453.xyz, vec3(_e1455));
            let _e1459: f32 = appearanceDepthTintFactor;
            closureInput_1.depthFactor = _e1459;
            let _e1461: vec3<f32> = diffuseLighting_3;
            closureInput_1.diffuseLighting = _e1461;
            closureInput_1.primaryColorClosureModel = 3f;
            let _e1465: vec3<f32> = global_1.material_AbsorptionCoefficient;
            closureInput_1.absorptionCoefficient = _e1465;
            let _e1467: vec3<f32> = global_1.material_ScatteringColor;
            closureInput_1.scatteringColor = _e1467;
            let _e1469: f32 = global_1.material_ScatteringCoefficient;
            closureInput_1.scatteringCoefficient = _e1469;
            let _e1471: f32 = viewDepth;
            let _e1472: f32 = global_1.material_MaximumSurfaceOpticalDistance;
            closureInput_1.opticalDepth = min(_e1471, _e1472);
            let _e1475: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
            closureInput_1.refractionColor = _e1475.refractionSceneColor;
            let _e1478: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
            closureInput_1.refractionWeight = _e1478.refractionWeight;
            let _e1481: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
            closureInput_1.reflectionRadiance = _e1481.reflectionRadiance;
            let _e1484: f32 = global_1.material_IndexOfRefraction;
            let _e1487: f32 = global_1.material_IndexOfRefraction;
            closureInput_1.fresnelF0_ = pow(((_e1484 - 1f) / (_e1487 + 1f)), 2f);
            let _e1494: f32 = effectiveSurfaceRoughness;
            closureInput_1.perceptualRoughness = _e1494;
            let _e1496: f32 = reflectionNormalDotView;
            closureInput_1.normalDotView = _e1496;
            closureInput_1.transmissionFresnelWeight = 1f;
            let _e1500: f32 = global_1.material_ReflectionIntensity;
            closureInput_1.reflectionIntensity = _e1500;
            let _e1502: vec3<f32> = sunReflection;
            closureInput_1.directSpecularRadiance = _e1502;
            let _e1504: vec3<f32> = appearanceBoundaryColor;
            closureInput_1.boundaryColor = _e1504;
            let _e1506: vec4<f32> = global_1.material_OceanSurfaceFoamColor;
            let _e1508: vec4<f32> = global_1.material_OceanIntersectionColor;
            let _e1510: f32 = intersection;
            closureInput_1.foamColor = mix(_e1506.xyz, _e1508.xyz, vec3(_e1510));
            let _e1514: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
            closureInput_1.foamWeight = _e1514.foamWeight;
            closureInput_1.baseAlpha = 1f;
            closureInput_1.clarity = 1f;
            let _e1521: f32 = edgeFade;
            let _e1522: f32 = appearanceCoastalAlpha;
            closureInput_1.coastalAlpha = (_e1521 * _e1522);
            closureInput_1.coastalAlphaWeight = 1f;
            let _e1527: f32 = waterSurface_coverage_1;
            closureInput_1.coverage = _e1527;
            let _e1529: vec3<f32> = centeredSceneColor;
            closureInput_1.compositionSceneColor = _e1529;
            closureInput_1.precomposedReplace = 1f;
            let _e1532: WaterSurfaceFinalClosureV2Input = closureInput_1;
            let _e1533: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
            let _e1535: vec4<f32> = baseColor_2;
            let _e1537: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_(_e1532, _e1533.foamWeight, _e1535.w);
            resolvedWaterClosure = _e1537;
            let _e1539: vec4<f32> = resolvedWaterClosure;
            finalColor = _e1539.xyz;
            let _e1542: vec4<f32> = resolvedWaterClosure;
            finalAlpha = _e1542.w;
            let _e1545: f32 = farFieldWeight;
            if (_e1545 > 0f) {
                {
                    let _e1548: vec3<f32> = finalColor;
                    let _e1549: Varyings = input_1;
                    let _e1551: vec3<f32> = oceanFarFieldRadiance(_e1549.worldPosition);
                    let _e1552: f32 = farFieldWeight;
                    finalColor = mix(_e1548, _e1551, vec3(_e1552));
                    let _e1555: f32 = finalAlpha;
                    let _e1556: f32 = coverage;
                    let _e1557: f32 = farFieldWeight;
                    finalAlpha = mix(_e1555, _e1556, _e1557);
                }
            }
            let _e1559: vec3<f32> = finalColor;
            let _e1560: f32 = finalAlpha;
            resolvedWaterClosure = vec4<f32>(_e1559.x, _e1559.y, _e1559.z, _e1560);
            let _e1565: vec4<f32> = resolvedWaterClosure;
            let _e1566: vec4<f32> = waterSurfaceOutputWithPick(_e1565);
            output_color = _e1566;
            return;
        }
    }
}

fn gs_wgpu_main() {
    var input_input: Varyings;

    let _e184: Varyings = read_Varyings();
    input_input = _e184;
    let _e186: Varyings = input_input;
    frag(_e186);
    return;
}

fn main_1() {
    let _e188: vec4<u32> = gs_wgpu_data_3_.words[0];
    let _e194: vec4<u32> = gs_wgpu_data_3_.words[0];
    let _e200: vec4<u32> = gs_wgpu_data_3_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e188.x), bitcast<f32>(_e194.y), bitcast<f32>(_e200.z));
    let _e208: vec4<u32> = gs_wgpu_data_3_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e208.w);
    let _e215: vec4<u32> = gs_wgpu_data_3_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e215.x);
    let _e222: vec4<u32> = gs_wgpu_data_3_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e222.y);
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) worldPosition: vec3<f32>, @location(1) macroNormalWS: vec3<f32>, @location(2) tangentWS: vec3<f32>, @location(3) positionVS: vec3<f32>, @location(4) clipPosition: vec4<f32>, @location(5) waveOffsetY: f32) -> FragmentOutput {
    worldPosition_5 = worldPosition;
    macroNormalWS_5 = macroNormalWS;
    tangentWS_1 = tangentWS;
    positionVS_4 = positionVS;
    clipPosition_1 = clipPosition;
    waveOffsetY_1 = waveOffsetY;
    main_1();
    let _e230: vec4<f32> = output_color;
    return FragmentOutput(_e230);
}
