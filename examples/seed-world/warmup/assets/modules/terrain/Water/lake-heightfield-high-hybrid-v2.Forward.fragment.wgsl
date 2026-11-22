diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    renderer_MVPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    camera_DepthBufferParams: vec4<f32>,
    camera_ProjectionParams: vec4<f32>,
    camera_ViewInvMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    scene_ElapsedTime: vec4<f32>,
    renderer_Layer: vec4<i32>,
    scene_WindVelocity: vec3<f32>,
    material_WindVelocity: vec3<f32>,
    material_WindVelocityOverride: f32,
    material_AppearanceV2Detail0Enabled: f32,
    material_AppearanceV2Detail1Enabled: f32,
    material_AppearanceV2DetailEnabled: f32,
    material_AppearanceV2DetailNormalStrength: f32,
    material_AppearanceV2DepthResponseEnabled: f32,
    material_AppearanceV2BoundaryAlphaEnabled: f32,
    material_AppearanceV2BoundaryMaterialEnabled: f32,
    material_AppearanceV2RefractionUvScale: f32,
    material_AppearanceV2Detail0Transform: vec4<f32>,
    material_AppearanceV2Detail0Rotation: vec2<f32>,
    material_AppearanceV2Detail0Strength: f32,
    material_AppearanceV2Detail1Transform: vec4<f32>,
    material_AppearanceV2Detail1Rotation: vec2<f32>,
    material_AppearanceV2Detail1Strength: f32,
    material_AppearanceV2DepthDistance: f32,
    material_AppearanceV2DepthExponent: f32,
    material_AppearanceV2DepthColor: vec4<f32>,
    material_AppearanceV2Boundary0Range: f32,
    material_AppearanceV2Boundary0Alpha: f32,
    material_AppearanceV2Boundary1Range: f32,
    material_AppearanceV2Boundary1Color: vec3<f32>,
    material_AppearanceV2Boundary1Roughness: f32,
    material_AppearanceV2Boundary1PatternWorldScale: f32,
    material_AppearanceV2Boundary1PatternTimeRate: f32,
    material_AppearanceV2Boundary1PatternOpacity: f32,
    material_AppearanceV2Boundary1PatternWeights: vec3<f32>,
    material_AppearanceV2Boundary1PatternLacunarity: f32,
    material_AppearanceV2Boundary1PatternExponent: f32,
    material_AppearanceDirectSpecularEnabled: f32,
    material_WaterWorldToLocalPlanar: vec4<f32>,
    material_ShallowColor: vec4<f32>,
    material_Alpha: f32,
    material_Clarity: f32,
    material_SurfaceTimeOverride: f32,
    material_RefractionEnabled: f32,
    material_CompositionMode: f32,
    material_MicroNormalsEnabled: f32,
    material_AbsorptionCoefficient: vec3<f32>,
    material_ScatteringColor: vec3<f32>,
    material_ScatteringCoefficient: f32,
    material_MaximumSurfaceOpticalDistance: f32,
    material_FresnelF0_: f32,
    material_Roughness: f32,
    material_ReflectionIntensity: f32,
    material_ReflectionSource: f32,
    material_WaterScreenSpaceReflectionCompositeIntensity: f32,
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
    scene_WeatherState: vec4<f32>,
    scene_WeatherTime: f32,
}

struct gs_Auto_1_ {
    camera_ViewMat: mat4x4<f32>,
    material_LocalMapDecode: vec4<f32>,
    material_ShoreDampingWidth: f32,
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
    objectPosition: vec3<f32>,
    meshUv: vec2<f32>,
    baseNormalWS: vec3<f32>,
    macroNormalWS: vec3<f32>,
    tangentWS: vec3<f32>,
    atlasUv: vec2<f32>,
    waveOffset: f32,
    surfaceEyeDepth: f32,
    shoreDamping: f32,
    clipPosition: vec4<f32>,
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

struct WaterSurfaceRawContributionPolicyV2_ {
    primaryColorClosureModel: f32,
    refractionEnabled: f32,
    clarity: f32,
    boundaryRefractionSuppression: f32,
    reflectionSource: f32,
    ssrCompositeIntensity: f32,
}

struct WaterSurfaceResolvedRawContributionsV2_ {
    refractionSceneColor: vec3<f32>,
    refractionWeight: f32,
    reflectionRadiance: vec3<f32>,
    foamWeight: f32,
}

struct WaterSurfaceFinalClosureV2Input {
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

const WATER_SURFACE_BRDF_MIN_PERCEPTUAL_ROUGHNESS: f32 = 0.045f;
const WATER_SURFACE_BRDF_EPSILON: f32 = 0.000001f;
const WATER_SURFACE_BRDF_RECIPROCAL_PI: f32 = 0.31830987f;
const WATER_SURFACE_BRDF_PI: f32 = 3.1415927f;
const WATER_SURFACE_PI: f32 = 3.1415927f;

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> output_color: vec4<f32>;
@group(2) @binding(4) 
var<uniform> gs_wgpu_data_2_: gs_Auto_3_;
var<private> scene_EnvMapLight: WaterSurfaceEnvironmentLight;
@group(1) @binding(0) 
var gs_wgpu_tex_camera_DepthTexture: texture_2d<f32>;
@group(1) @binding(1) 
var gs_wgpu_samp_camera_DepthTexture: sampler;
@group(1) @binding(2) 
var gs_wgpu_tex_camera_OpaqueTexture: texture_2d<f32>;
@group(1) @binding(3) 
var gs_wgpu_samp_camera_OpaqueTexture: sampler;
@group(2) @binding(2) 
var gs_wgpu_tex_material_LocalMapTexture: texture_2d<f32>;
@group(2) @binding(3) 
var gs_wgpu_samp_material_LocalMapTexture: sampler;
@group(2) @binding(5) 
var gs_wgpu_tex_material_AppearanceV2Detail0Texture: texture_2d<f32>;
@group(2) @binding(6) 
var gs_wgpu_samp_material_AppearanceV2Detail0Texture: sampler;
@group(2) @binding(7) 
var gs_wgpu_tex_material_AppearanceV2Detail1Texture: texture_2d<f32>;
@group(2) @binding(8) 
var gs_wgpu_samp_material_AppearanceV2Detail1Texture: sampler;
@group(2) @binding(9) 
var gs_wgpu_tex_material_ReflectionCubeTexture: texture_cube<f32>;
@group(2) @binding(10) 
var gs_wgpu_samp_material_ReflectionCubeTexture: sampler;
@group(2) @binding(11) 
var gs_wgpu_tex_material_SecondaryReflectionCubeTexture: texture_cube<f32>;
@group(2) @binding(12) 
var gs_wgpu_samp_material_SecondaryReflectionCubeTexture: sampler;
var<private> worldPosition_1: vec3<f32>;
var<private> baseNormalWS_1: vec3<f32>;
var<private> macroNormalWS_7: vec3<f32>;
var<private> tangentWS_1: vec3<f32>;
var<private> atlasUv_1: vec2<f32>;
var<private> waveOffset_1: f32;
var<private> surfaceEyeDepth_5: f32;
var<private> clipPosition_1: vec4<f32>;
@group(0) @binding(0) 
var gs_wgpu_tex_scene_SurfaceRippleNormalAtlas: texture_2d<f32>;
@group(0) @binding(1) 
var gs_wgpu_samp_scene_SurfaceRippleNormalAtlas: sampler;

fn remapDepthBufferEyeDepth(depth: f32) -> f32 {
    var depth_1: f32;

    depth_1 = depth;
    let _e154: vec4<f32> = global.camera_DepthBufferParams;
    let _e156: f32 = depth_1;
    let _e158: vec4<f32> = global.camera_DepthBufferParams;
    return (1f / ((_e154.z * _e156) + _e158.w));
}

fn waterSurfaceLightLayerBitSet(value: f32, mask: f32, bitIndex: f32) -> bool {
    var value_1: f32;
    var mask_1: f32;
    var bitIndex_1: f32;

    value_1 = value;
    mask_1 = mask;
    bitIndex_1 = bitIndex;
    let _e157: f32 = value_1;
    let _e159: f32 = bitIndex_1;
    let _e162: f32 = floor((_e157 / pow(2f, _e159)));
    let _e170: f32 = mask_1;
    let _e172: f32 = bitIndex_1;
    let _e175: f32 = floor((_e170 / pow(2f, _e172)));
    return (((_e162 - (floor((_e162 / 2f)) * 2f)) == 1f) && ((_e175 - (floor((_e175 / 2f)) * 2f)) == 1f));
}

fn waterSurfaceIsRendererCulledByLight(rendererLayer: vec2<i32>, lightCullingMask: vec2<i32>) -> bool {
    var rendererLayer_1: vec2<i32>;
    var lightCullingMask_1: vec2<i32>;
    var layerBit: i32 = 0i;

    rendererLayer_1 = rendererLayer;
    lightCullingMask_1 = lightCullingMask;
    loop {
        let _e157: i32 = layerBit;
        if !((_e157 < 16i)) {
            break;
        }
        {
            let _e164: vec2<i32> = rendererLayer_1;
            let _e167: vec2<i32> = lightCullingMask_1;
            let _e170: i32 = layerBit;
            let _e172: bool = waterSurfaceLightLayerBitSet(f32(_e164.x), f32(_e167.x), f32(_e170));
            let _e173: vec2<i32> = rendererLayer_1;
            let _e176: vec2<i32> = lightCullingMask_1;
            let _e179: i32 = layerBit;
            let _e181: bool = waterSurfaceLightLayerBitSet(f32(_e173.y), f32(_e176.y), f32(_e179));
            if (_e172 || _e181) {
                {
                    return false;
                }
            }
        }
        continuing {
            let _e161: i32 = layerBit;
            layerBit = (_e161 + 1i);
        }
    }
    return true;
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e179: vec3<f32> = worldPosition_1;
    interface_value.worldPosition = _e179;
    let _e181: vec3<f32> = baseNormalWS_1;
    interface_value.baseNormalWS = _e181;
    let _e183: vec3<f32> = macroNormalWS_7;
    interface_value.macroNormalWS = _e183;
    let _e185: vec3<f32> = tangentWS_1;
    interface_value.tangentWS = _e185;
    let _e187: vec2<f32> = atlasUv_1;
    interface_value.atlasUv = _e187;
    let _e189: f32 = waveOffset_1;
    interface_value.waveOffset = _e189;
    let _e191: f32 = surfaceEyeDepth_5;
    interface_value.surfaceEyeDepth = _e191;
    let _e193: vec4<f32> = clipPosition_1;
    interface_value.clipPosition = _e193;
    let _e194: Varyings = interface_value;
    return _e194;
}

fn waterLocalDirectionToWorldXZ(localDirection: vec2<f32>) -> vec2<f32> {
    var localDirection_1: vec2<f32>;

    localDirection_1 = localDirection;
    let _e179: vec2<f32> = localDirection_1;
    let _e181: vec4<f32> = global.material_WaterWorldToLocalPlanar;
    let _e184: vec2<f32> = localDirection_1;
    let _e186: vec4<f32> = global.material_WaterWorldToLocalPlanar;
    let _e190: vec2<f32> = localDirection_1;
    let _e193: vec4<f32> = global.material_WaterWorldToLocalPlanar;
    let _e196: vec2<f32> = localDirection_1;
    let _e198: vec4<f32> = global.material_WaterWorldToLocalPlanar;
    return vec2<f32>(((_e179.x * _e181.x) + (_e184.y * _e186.y)), ((-(_e190.x) * _e193.y) + (_e196.y * _e198.x)));
}

fn rainRippleSafeNormalize3_(value_2: vec3<f32>, fallbackValue: vec3<f32>) -> vec3<f32> {
    var value_3: vec3<f32>;
    var fallbackValue_1: vec3<f32>;
    var lengthSquared: f32;
    var local: vec3<f32>;

    value_3 = value_2;
    fallbackValue_1 = fallbackValue;
    let _e183: vec3<f32> = value_3;
    let _e184: vec3<f32> = value_3;
    lengthSquared = dot(_e183, _e184);
    let _e187: f32 = lengthSquared;
    if (_e187 > 0.000001f) {
        let _e190: vec3<f32> = value_3;
        let _e191: f32 = lengthSquared;
        local = (_e190 * inverseSqrt(_e191));
    } else {
        let _e194: vec3<f32> = fallbackValue_1;
        local = _e194;
    }
    let _e196: vec3<f32> = local;
    return _e196;
}

fn rainRippleDecodeNormal(encodedNormal: vec3<f32>) -> vec3<f32> {
    var encodedNormal_1: vec3<f32>;
    var normal: vec3<f32>;

    encodedNormal_1 = encodedNormal;
    let _e181: vec3<f32> = encodedNormal_1;
    normal = ((_e181 * 2f) - vec3(1f));
    let _e188: vec3<f32> = normal;
    let _e189: vec2<f32> = _e188.xy;
    let _e190: vec3<f32> = normal;
    let _e201: vec3<f32> = rainRippleSafeNormalize3_(vec3<f32>(_e189.x, _e189.y, max(_e190.z, 0.08f)), vec3<f32>(0f, 0f, 1f));
    return _e201;
}

fn rainRippleSampleFrame(localUv: vec2<f32>, frame: f32) -> vec3<f32> {
    var localUv_1: vec2<f32>;
    var frame_1: f32;
    var frameCell: vec2<f32>;
    var frameUv: vec2<f32>;

    localUv_1 = localUv;
    frame_1 = frame;
    let _e183: f32 = frame_1;
    let _e189: f32 = frame_1;
    frameCell = vec2<f32>((_e183 - (floor((_e183 / 8f)) * 8f)), floor((_e189 * 0.125f)));
    let _e195: vec2<f32> = frameCell;
    let _e200: vec2<f32> = localUv_1;
    frameUv = ((_e195 + mix(vec2(0.04f), vec2(0.96f), clamp(_e200, vec2(0f), vec2(1f)))) * 0.125f);
    let _e211: vec2<f32> = frameUv;
    let _e212: vec4<f32> = textureSample(gs_wgpu_tex_scene_SurfaceRippleNormalAtlas, gs_wgpu_samp_scene_SurfaceRippleNormalAtlas, _e211);
    let _e214: vec3<f32> = rainRippleDecodeNormal(_e212.xyz);
    return _e214;
}

fn rainRippleField(fieldUv: vec2<f32>, weatherTime: f32, frameOffset: f32, rainStrength: f32) -> vec2<f32> {
    var fieldUv_1: vec2<f32>;
    var weatherTime_1: f32;
    var frameOffset_1: f32;
    var rainStrength_1: f32;
    var frameRate: f32;
    var frame_2: f32;

    fieldUv_1 = fieldUv;
    weatherTime_1 = weatherTime;
    frameOffset_1 = frameOffset;
    rainStrength_1 = rainStrength;
    let _e189: f32 = rainStrength_1;
    frameRate = mix(8f, 24f, clamp(_e189, 0f, 1f));
    let _e195: f32 = weatherTime_1;
    let _e196: f32 = frameRate;
    let _e198: f32 = frameOffset_1;
    let _e199: f32 = ((_e195 * _e196) + _e198);
    frame_2 = floor((_e199 - (floor((_e199 / 64f)) * 64f)));
    let _e207: vec2<f32> = fieldUv_1;
    let _e209: f32 = frame_2;
    let _e210: vec3<f32> = rainRippleSampleFrame(fract(_e207), _e209);
    return _e210.xy;
}

fn rainRippleDensityWeight(rippleSlope: vec2<f32>, rainAmount: f32) -> f32 {
    var rippleSlope_1: vec2<f32>;
    var rainAmount_1: f32;
    var minimumSlope: f32;
    var feather: f32;

    rippleSlope_1 = rippleSlope;
    rainAmount_1 = rainAmount;
    let _e185: f32 = rainAmount_1;
    minimumSlope = mix(0.14f, 0.025f, _e185);
    let _e190: f32 = rainAmount_1;
    feather = mix(0.07f, 0.025f, _e190);
    let _e193: f32 = minimumSlope;
    let _e194: f32 = minimumSlope;
    let _e195: f32 = feather;
    let _e197: vec2<f32> = rippleSlope_1;
    return smoothstep(_e193, (_e194 + _e195), length(_e197));
}

fn rainRippleApplyNormal(surfaceNormalWS: vec3<f32>, macroNormalWS_1: vec3<f32>, rippleSlope_2: vec2<f32>) -> vec3<f32> {
    var surfaceNormalWS_1: vec3<f32>;
    var macroNormalWS_2: vec3<f32>;
    var rippleSlope_3: vec2<f32>;
    var worldRippleSlope: vec3<f32>;
    var tangentRippleSlope: vec3<f32>;

    surfaceNormalWS_1 = surfaceNormalWS;
    macroNormalWS_2 = macroNormalWS_1;
    rippleSlope_3 = rippleSlope_2;
    let _e185: vec2<f32> = rippleSlope_3;
    let _e188: vec2<f32> = rippleSlope_3;
    worldRippleSlope = vec3<f32>(_e185.x, 0f, _e188.y);
    let _e192: vec3<f32> = worldRippleSlope;
    let _e193: vec3<f32> = macroNormalWS_2;
    let _e194: vec3<f32> = worldRippleSlope;
    let _e195: vec3<f32> = macroNormalWS_2;
    tangentRippleSlope = (_e192 - (_e193 * dot(_e194, _e195)));
    let _e200: vec3<f32> = surfaceNormalWS_1;
    let _e201: vec3<f32> = tangentRippleSlope;
    let _e203: vec3<f32> = macroNormalWS_2;
    let _e204: vec3<f32> = rainRippleSafeNormalize3_((_e200 + _e201), _e203);
    return _e204;
}

fn waterEnvironmentSrgbToLinear(color: vec3<f32>) -> vec3<f32> {
    var color_1: vec3<f32>;
    var low: vec3<f32>;
    var high: vec3<f32>;

    color_1 = color;
    let _e181: vec3<f32> = color_1;
    low = (_e181 / vec3(12.92f));
    let _e186: vec3<f32> = color_1;
    high = pow(max(((_e186 + vec3(0.055f)) / vec3(1.055f)), vec3(0f)), vec3(2.4f));
    let _e200: vec3<f32> = low;
    let _e201: vec3<f32> = high;
    let _e204: vec3<f32> = color_1;
    return mix(_e200, _e201, step(vec3(0.04045f), _e204));
}

fn waterEnvironmentReflectionDirection(directionWS: vec3<f32>, positionWS: vec3<f32>, probePosition: vec4<f32>, boxMinimum: vec3<f32>, boxMaximum: vec3<f32>) -> vec3<f32> {
    var directionWS_1: vec3<f32>;
    var positionWS_1: vec3<f32>;
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
    positionWS_1 = positionWS;
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
    let _e222: vec3<f32> = positionWS_1;
    let _e224: vec3<f32> = safeDirection;
    intersectionDistances = ((_e221 - _e222) / _e224);
    let _e227: vec3<f32> = intersectionDistances;
    let _e229: vec3<f32> = intersectionDistances;
    let _e231: vec3<f32> = intersectionDistances;
    nearestIntersection = min(_e227.x, min(_e229.y, _e231.z));
    let _e236: vec3<f32> = positionWS_1;
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

fn sampleWaterDistantEnvironmentReflection(directionWS_2: vec3<f32>, positionWS_2: vec3<f32>, roughness: f32) -> vec3<f32> {
    var directionWS_3: vec3<f32>;
    var positionWS_3: vec3<f32>;
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
    positionWS_3 = positionWS_2;
    roughness_1 = roughness;
    let _e185: vec3<f32> = directionWS_3;
    originalDirectionWS = _e185;
    let _e187: vec3<f32> = directionWS_3;
    let _e188: vec3<f32> = positionWS_3;
    let _e189: vec4<f32> = global.material_EnvironmentReflectionProbePosition;
    let _e190: vec4<f32> = global.material_EnvironmentReflectionBoxMinimum;
    let _e192: vec4<f32> = global.material_EnvironmentReflectionBoxMaximum;
    let _e194: vec3<f32> = waterEnvironmentReflectionDirection(_e187, _e188, _e189, _e190.xyz, _e192.xyz);
    directionWS_3 = _e194;
    let _e195: vec4<f32> = global.material_EnvironmentReflectionParameters;
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
    let _e229: f32 = global.material_EnvironmentReflectionMaximumMip;
    mipLevel = (clamp(_e225, 0f, 1f) * max(_e229, 0f));
    let _e234: vec3<f32> = sampleDirection;
    let _e235: f32 = mipLevel;
    let _e236: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_ReflectionCubeTexture, gs_wgpu_samp_material_ReflectionCubeTexture, _e234, _e235);
    reflectedRadiance = _e236.xyz;
    let _e239: vec3<f32> = reflectedRadiance;
    let _e240: vec4<f32> = global.material_EnvironmentReflectionParameters;
    reflectedRadiance = (_e239 * max(_e240.z, 0f));
    let _e245: f32 = global.material_EnvironmentReflectionBlend;
    secondaryWeight = clamp(_e245, 0f, 1f);
    let _e250: f32 = secondaryWeight;
    if (_e250 > 0f) {
        {
            let _e253: vec3<f32> = originalDirectionWS;
            let _e254: vec3<f32> = positionWS_3;
            let _e255: vec4<f32> = global.material_SecondaryEnvironmentReflectionProbePosition;
            let _e256: vec4<f32> = global.material_SecondaryEnvironmentReflectionBoxMinimum;
            let _e258: vec4<f32> = global.material_SecondaryEnvironmentReflectionBoxMaximum;
            let _e260: vec3<f32> = waterEnvironmentReflectionDirection(_e253, _e254, _e255, _e256.xyz, _e258.xyz);
            secondaryDirection = _e260;
            let _e262: vec4<f32> = global.material_SecondaryEnvironmentReflectionParameters;
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
            let _e295: f32 = global.material_SecondaryEnvironmentReflectionMaximumMip;
            secondaryMipLevel = (clamp(_e291, 0f, 1f) * max(_e295, 0f));
            let _e300: vec3<f32> = secondaryDirection;
            let _e301: f32 = secondaryMipLevel;
            let _e302: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_SecondaryReflectionCubeTexture, gs_wgpu_samp_material_SecondaryReflectionCubeTexture, _e300, _e301);
            secondaryRadiance = _e302.xyz;
            let _e305: vec3<f32> = secondaryRadiance;
            let _e306: vec4<f32> = global.material_SecondaryEnvironmentReflectionParameters;
            secondaryRadiance = (_e305 * max(_e306.z, 0f));
            let _e311: vec3<f32> = reflectedRadiance;
            let _e312: vec3<f32> = secondaryRadiance;
            let _e313: f32 = secondaryWeight;
            reflectedRadiance = mix(_e311, _e312, vec3(_e313));
        }
    }
    let _e316: vec3<f32> = reflectedRadiance;
    let _e317: f32 = global.material_EnvironmentFallbackIntensity;
    return (_e316 * max(_e317, 0f));
}

fn waterSpatialFieldDecodeDepth(encodedDepth: f32, maximumDepth: f32) -> f32 {
    var encodedDepth_1: f32;
    var maximumDepth_1: f32;

    encodedDepth_1 = encodedDepth;
    maximumDepth_1 = maximumDepth;
    let _e183: f32 = encodedDepth_1;
    let _e184: f32 = maximumDepth_1;
    return (_e183 * _e184);
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
    let _e187: f32 = encodedDistance_1;
    let _e188: f32 = decodeScale_1;
    let _e190: f32 = decodeBias_1;
    let _e192: f32 = signedDistanceRange_1;
    return (((_e187 * _e188) + _e190) * _e192);
}

fn waterSurfaceAppearanceSafeNormalize3_(value_4: vec3<f32>, fallbackValue_2: vec3<f32>) -> vec3<f32> {
    var value_5: vec3<f32>;
    var fallbackValue_3: vec3<f32>;
    var lengthSquared_1: f32;
    var local_1: vec3<f32>;

    value_5 = value_4;
    fallbackValue_3 = fallbackValue_2;
    let _e183: vec3<f32> = value_5;
    let _e184: vec3<f32> = value_5;
    lengthSquared_1 = dot(_e183, _e184);
    let _e187: f32 = lengthSquared_1;
    if (_e187 > 0.000001f) {
        let _e190: vec3<f32> = value_5;
        let _e191: f32 = lengthSquared_1;
        local_1 = (_e190 * inverseSqrt(_e191));
    } else {
        let _e194: vec3<f32> = fallbackValue_3;
        local_1 = _e194;
    }
    let _e196: vec3<f32> = local_1;
    return _e196;
}

fn waterSurfaceAppearanceDecodeTangentNormalPreserveSourceZ(packedNormal: vec4<f32>, strength: f32, flipGreen: f32) -> vec3<f32> {
    var packedNormal_1: vec4<f32>;
    var strength_1: f32;
    var flipGreen_1: f32;
    var sourceSlope: vec2<f32>;
    var sourceNormalZ: f32;
    var normalZ: f32;

    packedNormal_1 = packedNormal;
    strength_1 = strength;
    flipGreen_1 = flipGreen;
    let _e185: vec4<f32> = packedNormal_1;
    sourceSlope = ((_e185.xy * 2f) - vec2(1f));
    let _e194: vec2<f32> = sourceSlope;
    let _e200: f32 = flipGreen_1;
    sourceSlope.y = (_e194.y * mix(1f, -1f, step(0.5f, _e200)));
    let _e205: vec2<f32> = sourceSlope;
    let _e206: vec2<f32> = sourceSlope;
    sourceNormalZ = sqrt(max((1f - clamp(dot(_e205, _e206), 0f, 1f)), 0.0001f));
    let _e217: f32 = sourceNormalZ;
    let _e218: f32 = strength_1;
    normalZ = mix(1f, _e217, clamp(_e218, 0f, 1f));
    let _e224: vec2<f32> = sourceSlope;
    let _e225: f32 = strength_1;
    let _e226: vec2<f32> = (_e224 * _e225);
    let _e227: f32 = normalZ;
    return vec3<f32>(_e226.x, _e226.y, _e227);
}

fn waterSurfaceAppearanceBlendTangentNormalsPartialDerivative(firstNormal: vec3<f32>, secondNormal: vec3<f32>) -> vec3<f32> {
    var firstNormal_1: vec3<f32>;
    var secondNormal_1: vec3<f32>;

    firstNormal_1 = firstNormal;
    secondNormal_1 = secondNormal;
    let _e183: vec3<f32> = firstNormal_1;
    let _e185: vec3<f32> = secondNormal_1;
    let _e188: vec3<f32> = secondNormal_1;
    let _e190: vec3<f32> = firstNormal_1;
    let _e193: vec2<f32> = ((_e183.xy * _e185.z) + (_e188.xy * _e190.z));
    let _e194: vec3<f32> = firstNormal_1;
    let _e196: vec3<f32> = secondNormal_1;
    let _e206: vec3<f32> = waterSurfaceAppearanceSafeNormalize3_(vec3<f32>(_e193.x, _e193.y, (_e194.z * _e196.z)), vec3<f32>(0f, 0f, 1f));
    return _e206;
}

fn waterSurfaceAppearanceDepthTintFactor(sceneDepthDelta: f32, distance: f32, exponent: f32) -> f32 {
    var sceneDepthDelta_1: f32;
    var distance_1: f32;
    var exponent_1: f32;

    sceneDepthDelta_1 = sceneDepthDelta;
    distance_1 = distance;
    exponent_1 = exponent;
    let _e185: f32 = sceneDepthDelta_1;
    let _e186: f32 = distance_1;
    let _e193: f32 = exponent_1;
    return pow(clamp((_e185 / max(_e186, 0.0001f)), 0f, 1f), max(_e193, 0.0001f));
}

fn waterSurfaceDepthSampleValidity(rawDepth: f32, sceneEyeDepth: f32, surfaceEyeDepth_1: f32) -> f32 {
    var rawDepth_1: f32;
    var sceneEyeDepth_1: f32;
    var surfaceEyeDepth_2: f32;

    rawDepth_1 = rawDepth;
    sceneEyeDepth_1 = sceneEyeDepth;
    surfaceEyeDepth_2 = surfaceEyeDepth_1;
    let _e186: f32 = sceneEyeDepth_1;
    let _e188: f32 = sceneEyeDepth_1;
    let _e192: f32 = surfaceEyeDepth_2;
    let _e195: f32 = sceneEyeDepth_1;
    let _e200: f32 = rawDepth_1;
    return (((step(0f, _e186) * step(_e188, 1000000f)) * step((_e192 + 0.000001f), _e195)) * (1f - step(0.999999f, _e200)));
}

fn waterSurfaceReconstructOpaquePositionWS(surfacePositionWS: vec3<f32>, cameraPositionWS: vec3<f32>, cameraViewInverse: mat4x4<f32>, surfaceEyeDepth_3: f32, sceneEyeDepth_2: f32, orthographicProjection: f32) -> vec3<f32> {
    var surfacePositionWS_1: vec3<f32>;
    var cameraPositionWS_1: vec3<f32>;
    var cameraViewInverse_1: mat4x4<f32>;
    var surfaceEyeDepth_4: f32;
    var sceneEyeDepth_3: f32;
    var orthographicProjection_1: f32;
    var safeSurfaceEyeDepth: f32;
    var perspectivePosition: vec3<f32>;
    var cameraForwardWS: vec3<f32>;
    var orthographicPosition: vec3<f32>;

    surfacePositionWS_1 = surfacePositionWS;
    cameraPositionWS_1 = cameraPositionWS;
    cameraViewInverse_1 = cameraViewInverse;
    surfaceEyeDepth_4 = surfaceEyeDepth_3;
    sceneEyeDepth_3 = sceneEyeDepth_2;
    orthographicProjection_1 = orthographicProjection;
    let _e191: f32 = surfaceEyeDepth_4;
    safeSurfaceEyeDepth = max(_e191, 0.000001f);
    let _e195: vec3<f32> = cameraPositionWS_1;
    let _e196: vec3<f32> = surfacePositionWS_1;
    let _e197: vec3<f32> = cameraPositionWS_1;
    let _e199: f32 = sceneEyeDepth_3;
    let _e200: f32 = safeSurfaceEyeDepth;
    perspectivePosition = (_e195 + ((_e196 - _e197) * (_e199 / _e200)));
    let _e205: mat4x4<f32> = cameraViewInverse_1;
    cameraForwardWS = normalize((_e205 * vec4<f32>(0f, 0f, -1f, 0f)).xyz);
    let _e216: vec3<f32> = surfacePositionWS_1;
    let _e217: vec3<f32> = cameraForwardWS;
    let _e218: f32 = sceneEyeDepth_3;
    let _e219: f32 = surfaceEyeDepth_4;
    orthographicPosition = (_e216 + (_e217 * max((_e218 - _e219), 0f)));
    let _e226: vec3<f32> = perspectivePosition;
    let _e227: vec3<f32> = orthographicPosition;
    let _e228: f32 = orthographicProjection_1;
    return mix(_e226, _e227, vec3(clamp(_e228, 0f, 1f)));
}

fn waterSurfaceNormalDepth(surfacePositionWS_2: vec3<f32>, opaquePositionWS: vec3<f32>, macroNormalWS_3: vec3<f32>) -> f32 {
    var surfacePositionWS_3: vec3<f32>;
    var opaquePositionWS_1: vec3<f32>;
    var macroNormalWS_4: vec3<f32>;

    surfacePositionWS_3 = surfacePositionWS_2;
    opaquePositionWS_1 = opaquePositionWS;
    macroNormalWS_4 = macroNormalWS_3;
    let _e185: vec3<f32> = surfacePositionWS_3;
    let _e186: vec3<f32> = opaquePositionWS_1;
    let _e188: vec3<f32> = macroNormalWS_4;
    return abs(dot((_e185 - _e186), normalize(_e188)));
}

fn waterSurfaceDerivedSceneRayDepth(verticalDepth: f32, macroNormalWS_5: vec3<f32>, viewDirectionWS: vec3<f32>) -> f32 {
    var verticalDepth_1: f32;
    var macroNormalWS_6: vec3<f32>;
    var viewDirectionWS_1: vec3<f32>;
    var projectionDenominator: f32;

    verticalDepth_1 = verticalDepth;
    macroNormalWS_6 = macroNormalWS_5;
    viewDirectionWS_1 = viewDirectionWS;
    let _e185: vec3<f32> = viewDirectionWS_1;
    let _e187: vec3<f32> = macroNormalWS_6;
    projectionDenominator = abs(dot(normalize(_e185), normalize(_e187)));
    let _e192: f32 = verticalDepth_1;
    let _e195: f32 = projectionDenominator;
    return min((max(_e192, 0f) / max(_e195, 0.001f)), 1000000f);
}

fn sampleVolumetricCloudShadow(positionWS_4: vec3<f32>) -> f32 {
    var positionWS_5: vec3<f32>;

    positionWS_5 = positionWS_4;
    return 1f;
}

fn waterAnimatedVoronoiF1Hash(cell: vec2<f32>) -> vec2<f32> {
    var cell_1: vec2<f32>;
    var projected: vec2<f32>;

    cell_1 = cell;
    let _e181: vec2<f32> = cell_1;
    let _e186: vec2<f32> = cell_1;
    projected = vec2<f32>(dot(_e181, vec2<f32>(127.1f, 311.7f)), dot(_e186, vec2<f32>(269.5f, 183.3f)));
    let _e193: vec2<f32> = projected;
    return fract((sin(_e193) * 43758.547f));
}

fn waterAnimatedVoronoiF1Candidate(cell_2: vec2<f32>, localPosition: vec2<f32>, cellOffset: vec2<f32>, time: f32) -> f32 {
    var cell_3: vec2<f32>;
    var localPosition_1: vec2<f32>;
    var cellOffset_1: vec2<f32>;
    var time_1: f32;
    var randomOffset: vec2<f32>;
    var animatedOffset: vec2<f32>;
    var delta: vec2<f32>;

    cell_3 = cell_2;
    localPosition_1 = localPosition;
    cellOffset_1 = cellOffset;
    time_1 = time;
    let _e187: vec2<f32> = cell_3;
    let _e188: vec2<f32> = cellOffset_1;
    let _e190: vec2<f32> = waterAnimatedVoronoiF1Hash((_e187 + _e188));
    randomOffset = _e190;
    let _e192: f32 = time_1;
    let _e193: vec2<f32> = randomOffset;
    animatedOffset = ((sin((vec2(_e192) + (_e193 * 6.2831f))) * 0.5f) + vec2(0.5f));
    let _e205: vec2<f32> = localPosition_1;
    let _e206: vec2<f32> = cellOffset_1;
    let _e208: vec2<f32> = animatedOffset;
    delta = ((_e205 - _e206) - _e208);
    let _e211: vec2<f32> = delta;
    let _e212: vec2<f32> = delta;
    return dot(_e211, _e212);
}

fn waterAnimatedVoronoiF1_(position: vec2<f32>, time_2: f32) -> f32 {
    var position_1: vec2<f32>;
    var time_3: f32;
    var cell_4: vec2<f32>;
    var localPosition_2: vec2<f32>;
    var f1_: f32;

    position_1 = position;
    time_3 = time_2;
    let _e183: vec2<f32> = position_1;
    cell_4 = floor(_e183);
    let _e186: vec2<f32> = position_1;
    localPosition_2 = fract(_e186);
    let _e189: vec2<f32> = cell_4;
    let _e190: vec2<f32> = localPosition_2;
    let _e194: f32 = time_3;
    let _e195: f32 = waterAnimatedVoronoiF1Candidate(_e189, _e190, vec2<f32>(0f, 0f), _e194);
    f1_ = _e195;
    let _e197: f32 = f1_;
    let _e198: vec2<f32> = cell_4;
    let _e199: vec2<f32> = localPosition_2;
    let _e204: f32 = time_3;
    let _e205: f32 = waterAnimatedVoronoiF1Candidate(_e198, _e199, vec2<f32>(-1f, 0f), _e204);
    f1_ = min(_e197, _e205);
    let _e207: f32 = f1_;
    let _e208: vec2<f32> = cell_4;
    let _e209: vec2<f32> = localPosition_2;
    let _e213: f32 = time_3;
    let _e214: f32 = waterAnimatedVoronoiF1Candidate(_e208, _e209, vec2<f32>(1f, 0f), _e213);
    f1_ = min(_e207, _e214);
    let _e216: f32 = f1_;
    let _e217: vec2<f32> = cell_4;
    let _e218: vec2<f32> = localPosition_2;
    let _e223: f32 = time_3;
    let _e224: f32 = waterAnimatedVoronoiF1Candidate(_e217, _e218, vec2<f32>(0f, -1f), _e223);
    f1_ = min(_e216, _e224);
    let _e226: f32 = f1_;
    let _e227: vec2<f32> = cell_4;
    let _e228: vec2<f32> = localPosition_2;
    let _e232: f32 = time_3;
    let _e233: f32 = waterAnimatedVoronoiF1Candidate(_e227, _e228, vec2<f32>(0f, 1f), _e232);
    f1_ = min(_e226, _e233);
    let _e235: f32 = f1_;
    let _e236: vec2<f32> = cell_4;
    let _e237: vec2<f32> = localPosition_2;
    let _e243: f32 = time_3;
    let _e244: f32 = waterAnimatedVoronoiF1Candidate(_e236, _e237, vec2<f32>(-1f, -1f), _e243);
    f1_ = min(_e235, _e244);
    let _e246: f32 = f1_;
    let _e247: vec2<f32> = cell_4;
    let _e248: vec2<f32> = localPosition_2;
    let _e253: f32 = time_3;
    let _e254: f32 = waterAnimatedVoronoiF1Candidate(_e247, _e248, vec2<f32>(1f, -1f), _e253);
    f1_ = min(_e246, _e254);
    let _e256: f32 = f1_;
    let _e257: vec2<f32> = cell_4;
    let _e258: vec2<f32> = localPosition_2;
    let _e263: f32 = time_3;
    let _e264: f32 = waterAnimatedVoronoiF1Candidate(_e257, _e258, vec2<f32>(-1f, 1f), _e263);
    f1_ = min(_e256, _e264);
    let _e266: f32 = f1_;
    let _e267: vec2<f32> = cell_4;
    let _e268: vec2<f32> = localPosition_2;
    let _e272: f32 = time_3;
    let _e273: f32 = waterAnimatedVoronoiF1Candidate(_e267, _e268, vec2<f32>(1f, 1f), _e272);
    f1_ = min(_e266, _e273);
    let _e276: f32 = f1_;
    return clamp((0.707f * sqrt(_e276)), 0f, 1f);
}

fn waterAnimatedVoronoiF1UpperBounded(position_2: vec2<f32>, time_4: f32, f1Max: f32) -> f32 {
    var position_3: vec2<f32>;
    var time_5: f32;
    var f1Max_1: f32;
    var cell_5: vec2<f32>;
    var localPosition_3: vec2<f32>;
    var f1_1: f32;

    position_3 = position_2;
    time_5 = time_4;
    f1Max_1 = f1Max;
    let _e185: vec2<f32> = position_3;
    cell_5 = floor(_e185);
    let _e188: vec2<f32> = position_3;
    localPosition_3 = fract(_e188);
    let _e191: vec2<f32> = cell_5;
    let _e192: vec2<f32> = localPosition_3;
    let _e196: f32 = time_5;
    let _e197: f32 = waterAnimatedVoronoiF1Candidate(_e191, _e192, vec2<f32>(0f, 0f), _e196);
    f1_1 = _e197;
    let _e199: f32 = f1_1;
    let _e200: f32 = f1Max_1;
    if (_e199 <= _e200) {
        return 0f;
    }
    let _e203: f32 = f1_1;
    let _e204: vec2<f32> = cell_5;
    let _e205: vec2<f32> = localPosition_3;
    let _e210: f32 = time_5;
    let _e211: f32 = waterAnimatedVoronoiF1Candidate(_e204, _e205, vec2<f32>(-1f, 0f), _e210);
    f1_1 = min(_e203, _e211);
    let _e213: f32 = f1_1;
    let _e214: vec2<f32> = cell_5;
    let _e215: vec2<f32> = localPosition_3;
    let _e219: f32 = time_5;
    let _e220: f32 = waterAnimatedVoronoiF1Candidate(_e214, _e215, vec2<f32>(1f, 0f), _e219);
    f1_1 = min(_e213, _e220);
    let _e222: f32 = f1_1;
    let _e223: vec2<f32> = cell_5;
    let _e224: vec2<f32> = localPosition_3;
    let _e229: f32 = time_5;
    let _e230: f32 = waterAnimatedVoronoiF1Candidate(_e223, _e224, vec2<f32>(0f, -1f), _e229);
    f1_1 = min(_e222, _e230);
    let _e232: f32 = f1_1;
    let _e233: vec2<f32> = cell_5;
    let _e234: vec2<f32> = localPosition_3;
    let _e238: f32 = time_5;
    let _e239: f32 = waterAnimatedVoronoiF1Candidate(_e233, _e234, vec2<f32>(0f, 1f), _e238);
    f1_1 = min(_e232, _e239);
    let _e241: f32 = f1_1;
    let _e242: f32 = f1Max_1;
    if (_e241 <= _e242) {
        return 0f;
    }
    let _e245: f32 = f1_1;
    let _e246: vec2<f32> = cell_5;
    let _e247: vec2<f32> = localPosition_3;
    let _e253: f32 = time_5;
    let _e254: f32 = waterAnimatedVoronoiF1Candidate(_e246, _e247, vec2<f32>(-1f, -1f), _e253);
    f1_1 = min(_e245, _e254);
    let _e256: f32 = f1_1;
    let _e257: vec2<f32> = cell_5;
    let _e258: vec2<f32> = localPosition_3;
    let _e263: f32 = time_5;
    let _e264: f32 = waterAnimatedVoronoiF1Candidate(_e257, _e258, vec2<f32>(1f, -1f), _e263);
    f1_1 = min(_e256, _e264);
    let _e266: f32 = f1_1;
    let _e267: vec2<f32> = cell_5;
    let _e268: vec2<f32> = localPosition_3;
    let _e273: f32 = time_5;
    let _e274: f32 = waterAnimatedVoronoiF1Candidate(_e267, _e268, vec2<f32>(-1f, 1f), _e273);
    f1_1 = min(_e266, _e274);
    let _e276: f32 = f1_1;
    let _e277: vec2<f32> = cell_5;
    let _e278: vec2<f32> = localPosition_3;
    let _e282: f32 = time_5;
    let _e283: f32 = waterAnimatedVoronoiF1Candidate(_e277, _e278, vec2<f32>(1f, 1f), _e282);
    f1_1 = min(_e276, _e283);
    let _e286: f32 = f1_1;
    return clamp((0.707f * sqrt(_e286)), 0f, 1f);
}

fn evaluateWaterAnimatedVoronoiF1_(worldPositionXz: vec2<f32>, surfaceTime: f32, worldScale: f32, timeRate: f32, octaveWeights: vec3<f32>, lacunarity: f32) -> f32 {
    var worldPositionXz_1: vec2<f32>;
    var surfaceTime_1: f32;
    var worldScale_1: f32;
    var timeRate_1: f32;
    var octaveWeights_1: vec3<f32>;
    var lacunarity_1: f32;
    var weightSum: f32;
    var validWeights: bool;
    var animatedTime: f32;
    var weightedPattern: f32 = 0f;

    worldPositionXz_1 = worldPositionXz;
    surfaceTime_1 = surfaceTime;
    worldScale_1 = worldScale;
    timeRate_1 = timeRate;
    octaveWeights_1 = octaveWeights;
    lacunarity_1 = lacunarity;
    let _e191: vec3<f32> = octaveWeights_1;
    let _e193: vec3<f32> = octaveWeights_1;
    let _e196: vec3<f32> = octaveWeights_1;
    weightSum = ((_e191.x + _e193.y) + _e196.z);
    let _e200: vec3<f32> = octaveWeights_1;
    let _e204: vec3<f32> = octaveWeights_1;
    let _e209: vec3<f32> = octaveWeights_1;
    validWeights = (((_e200.x >= 0f) && (_e204.y >= 0f)) && (_e209.z >= 0f));
    let _e215: f32 = worldScale_1;
    let _e219: f32 = timeRate_1;
    let _e224: f32 = lacunarity_1;
    let _e229: bool = validWeights;
    let _e232: f32 = weightSum;
    if ((((!((_e215 > 0f)) || !((_e219 > 0f))) || !((_e224 > 0f))) || !(_e229)) || !((_e232 > 0f))) {
        {
            return 0f;
        }
    }
    let _e238: f32 = surfaceTime_1;
    let _e239: f32 = timeRate_1;
    animatedTime = (_e238 * _e239);
    let _e244: vec3<f32> = octaveWeights_1;
    if (_e244.x > 0f) {
        {
            let _e248: f32 = weightedPattern;
            let _e249: vec2<f32> = worldPositionXz_1;
            let _e250: f32 = worldScale_1;
            let _e252: f32 = animatedTime;
            let _e253: f32 = waterAnimatedVoronoiF1_((_e249 * _e250), _e252);
            let _e254: vec3<f32> = octaveWeights_1;
            weightedPattern = (_e248 + (_e253 * _e254.x));
        }
    }
    let _e258: vec3<f32> = octaveWeights_1;
    if (_e258.y > 0f) {
        {
            let _e262: f32 = weightedPattern;
            let _e263: vec2<f32> = worldPositionXz_1;
            let _e264: f32 = worldScale_1;
            let _e266: f32 = lacunarity_1;
            let _e268: f32 = animatedTime;
            let _e269: f32 = waterAnimatedVoronoiF1_(((_e263 * _e264) * _e266), _e268);
            let _e270: vec3<f32> = octaveWeights_1;
            weightedPattern = (_e262 + (_e269 * _e270.y));
        }
    }
    let _e274: vec3<f32> = octaveWeights_1;
    if (_e274.z > 0f) {
        {
            let _e278: f32 = weightedPattern;
            let _e279: vec2<f32> = worldPositionXz_1;
            let _e280: f32 = worldScale_1;
            let _e282: f32 = lacunarity_1;
            let _e284: f32 = lacunarity_1;
            let _e286: f32 = animatedTime;
            let _e287: f32 = waterAnimatedVoronoiF1_((((_e279 * _e280) * _e282) * _e284), _e286);
            let _e288: vec3<f32> = octaveWeights_1;
            weightedPattern = (_e278 + (_e287 * _e288.z));
        }
    }
    let _e292: f32 = weightedPattern;
    let _e293: f32 = weightSum;
    return clamp((_e292 / _e293), 0f, 1f);
}

fn evaluateWaterAnimatedVoronoiF1UpperBounded(worldPositionXz_2: vec2<f32>, surfaceTime_2: f32, worldScale_2: f32, timeRate_2: f32, octaveWeights_2: vec3<f32>, lacunarity_2: f32, pMax: f32) -> f32 {
    var worldPositionXz_3: vec2<f32>;
    var surfaceTime_3: f32;
    var worldScale_3: f32;
    var timeRate_3: f32;
    var octaveWeights_3: vec3<f32>;
    var lacunarity_3: f32;
    var pMax_1: f32;
    var weightSum_1: f32;
    var validWeights_1: bool;
    var eps: f32 = 0.00001f;
    var animatedTime_1: f32;
    var targetSum: f32;
    var w0_: f32;
    var rest0_: f32;
    var local_2: f32;
    var v0Max: f32;
    var local_3: f32;
    var f1Max0_: f32;
    var local_4: f32;
    var v0_: f32;
    var weightedPattern_1: f32;
    var w1_: f32;
    var rest1_: f32;
    var local_5: f32;
    var v1Max: f32;
    var local_6: f32;
    var f1Max1_: f32;
    var local_7: f32;
    var v1_: f32;
    var w2_: f32;
    var local_8: f32;
    var v2Max: f32;
    var local_9: f32;
    var f1Max2_: f32;
    var local_10: f32;
    var v2_: f32;

    worldPositionXz_3 = worldPositionXz_2;
    surfaceTime_3 = surfaceTime_2;
    worldScale_3 = worldScale_2;
    timeRate_3 = timeRate_2;
    octaveWeights_3 = octaveWeights_2;
    lacunarity_3 = lacunarity_2;
    pMax_1 = pMax;
    let _e193: vec3<f32> = octaveWeights_3;
    let _e195: vec3<f32> = octaveWeights_3;
    let _e198: vec3<f32> = octaveWeights_3;
    weightSum_1 = ((_e193.x + _e195.y) + _e198.z);
    let _e202: vec3<f32> = octaveWeights_3;
    let _e206: vec3<f32> = octaveWeights_3;
    let _e211: vec3<f32> = octaveWeights_3;
    validWeights_1 = (((_e202.x >= 0f) && (_e206.y >= 0f)) && (_e211.z >= 0f));
    let _e217: f32 = worldScale_3;
    let _e221: f32 = timeRate_3;
    let _e226: f32 = lacunarity_3;
    let _e231: bool = validWeights_1;
    let _e234: f32 = weightSum_1;
    if ((((!((_e217 > 0f)) || !((_e221 > 0f))) || !((_e226 > 0f))) || !(_e231)) || !((_e234 > 0f))) {
        {
            return 0f;
        }
    }
    let _e240: f32 = pMax_1;
    if (_e240 >= 1f) {
        return 0f;
    }
    let _e246: f32 = surfaceTime_3;
    let _e247: f32 = timeRate_3;
    animatedTime_1 = (_e246 * _e247);
    let _e250: f32 = pMax_1;
    let _e251: f32 = weightSum_1;
    targetSum = (_e250 * _e251);
    let _e254: vec3<f32> = octaveWeights_3;
    w0_ = _e254.x;
    let _e257: vec3<f32> = octaveWeights_3;
    let _e259: vec3<f32> = octaveWeights_3;
    rest0_ = (_e257.y + _e259.z);
    let _e263: f32 = w0_;
    if (_e263 > 0f) {
        let _e266: f32 = targetSum;
        let _e267: f32 = rest0_;
        let _e269: f32 = w0_;
        let _e271: f32 = eps;
        local_2 = (((_e266 - _e267) / _e269) - _e271);
    } else {
        local_2 = -1f;
    }
    let _e276: f32 = local_2;
    v0Max = _e276;
    let _e278: f32 = v0Max;
    if (_e278 >= 1f) {
        return 0f;
    }
    let _e282: f32 = v0Max;
    if (_e282 > 0f) {
        let _e285: f32 = v0Max;
        let _e288: f32 = v0Max;
        local_3 = ((_e285 / 0.707f) * (_e288 / 0.707f));
    } else {
        local_3 = -1f;
    }
    let _e295: f32 = local_3;
    f1Max0_ = _e295;
    let _e297: f32 = w0_;
    if (_e297 > 0f) {
        let _e300: vec2<f32> = worldPositionXz_3;
        let _e301: f32 = worldScale_3;
        let _e303: f32 = animatedTime_1;
        let _e304: f32 = f1Max0_;
        let _e305: f32 = waterAnimatedVoronoiF1UpperBounded((_e300 * _e301), _e303, _e304);
        local_4 = _e305;
    } else {
        local_4 = 0f;
    }
    let _e308: f32 = local_4;
    v0_ = _e308;
    let _e310: f32 = v0Max;
    let _e313: f32 = v0_;
    let _e314: f32 = v0Max;
    if ((_e310 >= 0f) && (_e313 <= _e314)) {
        return 0f;
    }
    let _e318: f32 = w0_;
    let _e319: f32 = v0_;
    weightedPattern_1 = (_e318 * _e319);
    let _e322: vec3<f32> = octaveWeights_3;
    w1_ = _e322.y;
    let _e325: vec3<f32> = octaveWeights_3;
    rest1_ = _e325.z;
    let _e328: f32 = w1_;
    if (_e328 > 0f) {
        let _e331: f32 = targetSum;
        let _e332: f32 = weightedPattern_1;
        let _e334: f32 = rest1_;
        let _e336: f32 = w1_;
        let _e338: f32 = eps;
        local_5 = ((((_e331 - _e332) - _e334) / _e336) - _e338);
    } else {
        local_5 = -1f;
    }
    let _e343: f32 = local_5;
    v1Max = _e343;
    let _e345: f32 = v1Max;
    if (_e345 >= 1f) {
        return 0f;
    }
    let _e349: f32 = v1Max;
    if (_e349 > 0f) {
        let _e352: f32 = v1Max;
        let _e355: f32 = v1Max;
        local_6 = ((_e352 / 0.707f) * (_e355 / 0.707f));
    } else {
        local_6 = -1f;
    }
    let _e362: f32 = local_6;
    f1Max1_ = _e362;
    let _e364: f32 = w1_;
    if (_e364 > 0f) {
        let _e367: vec2<f32> = worldPositionXz_3;
        let _e368: f32 = worldScale_3;
        let _e370: f32 = lacunarity_3;
        let _e372: f32 = animatedTime_1;
        let _e373: f32 = f1Max1_;
        let _e374: f32 = waterAnimatedVoronoiF1UpperBounded(((_e367 * _e368) * _e370), _e372, _e373);
        local_7 = _e374;
    } else {
        local_7 = 0f;
    }
    let _e377: f32 = local_7;
    v1_ = _e377;
    let _e379: f32 = v1Max;
    let _e382: f32 = v1_;
    let _e383: f32 = v1Max;
    if ((_e379 >= 0f) && (_e382 <= _e383)) {
        return 0f;
    }
    let _e387: f32 = weightedPattern_1;
    let _e388: f32 = w1_;
    let _e389: f32 = v1_;
    weightedPattern_1 = (_e387 + (_e388 * _e389));
    let _e392: vec3<f32> = octaveWeights_3;
    w2_ = _e392.z;
    let _e395: f32 = w2_;
    if (_e395 > 0f) {
        let _e398: f32 = targetSum;
        let _e399: f32 = weightedPattern_1;
        let _e401: f32 = w2_;
        let _e403: f32 = eps;
        local_8 = (((_e398 - _e399) / _e401) - _e403);
    } else {
        local_8 = -1f;
    }
    let _e408: f32 = local_8;
    v2Max = _e408;
    let _e410: f32 = v2Max;
    if (_e410 >= 1f) {
        return 0f;
    }
    let _e414: f32 = v2Max;
    if (_e414 > 0f) {
        let _e417: f32 = v2Max;
        let _e420: f32 = v2Max;
        local_9 = ((_e417 / 0.707f) * (_e420 / 0.707f));
    } else {
        local_9 = -1f;
    }
    let _e427: f32 = local_9;
    f1Max2_ = _e427;
    let _e429: f32 = w2_;
    if (_e429 > 0f) {
        let _e432: vec2<f32> = worldPositionXz_3;
        let _e433: f32 = worldScale_3;
        let _e435: f32 = lacunarity_3;
        let _e437: f32 = lacunarity_3;
        let _e439: f32 = animatedTime_1;
        let _e440: f32 = f1Max2_;
        let _e441: f32 = waterAnimatedVoronoiF1UpperBounded((((_e432 * _e433) * _e435) * _e437), _e439, _e440);
        local_10 = _e441;
    } else {
        local_10 = 0f;
    }
    let _e444: f32 = local_10;
    v2_ = _e444;
    let _e446: f32 = v2Max;
    let _e449: f32 = v2_;
    let _e450: f32 = v2Max;
    if ((_e446 >= 0f) && (_e449 <= _e450)) {
        return 0f;
    }
    let _e454: f32 = weightedPattern_1;
    let _e455: f32 = w2_;
    let _e456: f32 = v2_;
    weightedPattern_1 = (_e454 + (_e455 * _e456));
    let _e459: f32 = weightedPattern_1;
    let _e460: f32 = weightSum_1;
    return clamp((_e459 / _e460), 0f, 1f);
}

fn waterSurfaceResolvePerceptualRoughness(perceptualRoughness: f32) -> f32 {
    var perceptualRoughness_1: f32;

    perceptualRoughness_1 = perceptualRoughness;
    let _e185: f32 = perceptualRoughness_1;
    return max(WATER_SURFACE_BRDF_MIN_PERCEPTUAL_ROUGHNESS, clamp(_e185, 0f, 1f));
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
    let _e189: f32 = f0_1;
    boundedF0_ = clamp(_e189, 0f, 1f);
    let _e194: f32 = f90_1;
    boundedF90_ = clamp(_e194, 0f, 1f);
    let _e199: f32 = boundedF0_;
    let _e200: f32 = boundedF90_;
    let _e201: f32 = boundedF0_;
    let _e204: f32 = dotLH_1;
    return (_e199 + ((_e200 - _e201) * pow((1f - clamp(_e204, 0f, 1f)), 5f)));
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
    let _e191: f32 = minimumAlpha;
    let _e192: f32 = alpha_1;
    resolvedAlpha = max(_e191, _e192);
    let _e195: f32 = resolvedAlpha;
    let _e196: f32 = resolvedAlpha;
    alphaSquared = (_e195 * _e196);
    let _e199: f32 = dotNH_1;
    boundedDotNH = clamp(_e199, 0f, 1f);
    let _e204: f32 = boundedDotNH;
    let _e205: f32 = boundedDotNH;
    let _e207: f32 = alphaSquared;
    denominator = (((_e204 * _e205) * (_e207 - 1f)) + 1f);
    let _e214: f32 = alphaSquared;
    let _e216: f32 = denominator;
    let _e217: f32 = denominator;
    return ((WATER_SURFACE_BRDF_RECIPROCAL_PI * _e214) / max((_e216 * _e217), WATER_SURFACE_BRDF_EPSILON));
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
    let _e193: f32 = minimumAlpha_1;
    let _e194: f32 = alpha_3;
    resolvedAlpha_1 = max(_e193, _e194);
    let _e197: f32 = resolvedAlpha_1;
    let _e198: f32 = resolvedAlpha_1;
    alphaSquared_1 = (_e197 * _e198);
    let _e201: f32 = dotNL_1;
    boundedDotNL = clamp(_e201, 0f, 1f);
    let _e206: f32 = dotNV_1;
    boundedDotNV = clamp(_e206, 0f, 1f);
    let _e211: f32 = boundedDotNL;
    let _e212: f32 = alphaSquared_1;
    let _e214: f32 = alphaSquared_1;
    let _e216: f32 = boundedDotNV;
    let _e218: f32 = boundedDotNV;
    gv = (_e211 * sqrt((_e212 + (((1f - _e214) * _e216) * _e218))));
    let _e224: f32 = boundedDotNV;
    let _e225: f32 = alphaSquared_1;
    let _e227: f32 = alphaSquared_1;
    let _e229: f32 = boundedDotNL;
    let _e231: f32 = boundedDotNL;
    gl = (_e224 * sqrt((_e225 + (((1f - _e227) * _e229) * _e231))));
    let _e238: f32 = gv;
    let _e239: f32 = gl;
    return (0.5f / max((_e238 + _e239), WATER_SURFACE_BRDF_EPSILON));
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
    let _e195: f32 = perceptualRoughness_3;
    let _e196: f32 = waterSurfaceResolvePerceptualRoughness(_e195);
    resolvedRoughness = _e196;
    let _e198: f32 = resolvedRoughness;
    let _e199: f32 = resolvedRoughness;
    alpha_4 = (_e198 * _e199);
    let _e202: f32 = dotNV_3;
    boundedDotNV_1 = clamp(_e202, 0f, 1f);
    let _e207: f32 = dotNL_3;
    boundedDotNL_1 = clamp(_e207, 0f, 1f);
    let _e212: f32 = dotNH_3;
    boundedDotNH_1 = clamp(_e212, 0f, 1f);
    let _e217: f32 = dotLH_3;
    boundedDotLH = clamp(_e217, 0f, 1f);
    let _e222: f32 = f0_3;
    let _e224: f32 = boundedDotLH;
    let _e225: f32 = waterSurfaceSchlick(_e222, 1f, _e224);
    fresnel = _e225;
    let _e227: f32 = alpha_4;
    let _e228: f32 = boundedDotNH_1;
    let _e229: f32 = waterSurfaceGgxDistribution(_e227, _e228);
    distribution = _e229;
    let _e231: f32 = alpha_4;
    let _e232: f32 = boundedDotNL_1;
    let _e233: f32 = boundedDotNV_1;
    let _e234: f32 = waterSurfaceGgxSmithCorrelated(_e231, _e232, _e233);
    visibility = _e234;
    let _e236: f32 = fresnel;
    let _e237: f32 = distribution;
    let _e239: f32 = visibility;
    let _e241: f32 = boundedDotNL_1;
    return ((((_e236 * _e237) * _e239) * _e241) * WATER_SURFACE_BRDF_PI);
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
    let _e203: f32 = perceptualRoughness_5;
    let _e207: vec4<f32> = c0_;
    let _e209: vec4<f32> = c1_;
    r = ((clamp(_e203, 0f, 1f) * _e207) + _e209);
    let _e212: vec4<f32> = r;
    let _e214: vec4<f32> = r;
    let _e219: f32 = dotNV_5;
    let _e226: vec4<f32> = r;
    let _e229: vec4<f32> = r;
    a004_ = ((min((_e212.x * _e214.x), exp2((-9.28f * clamp(_e219, 0f, 1f)))) * _e226.x) + _e229.y);
    let _e237: f32 = a004_;
    let _e239: vec4<f32> = r;
    return ((vec2<f32>(-1.04f, 1.04f) * _e237) + _e239.zw);
}

fn waterSurfaceEnvironmentSpecularWeight(f0_4: f32, perceptualRoughness_6: f32, dotNV_6: f32) -> vec3<f32> {
    var f0_5: f32;
    var perceptualRoughness_7: f32;
    var dotNV_7: f32;
    var dfg: vec2<f32>;

    f0_5 = f0_4;
    perceptualRoughness_7 = perceptualRoughness_6;
    dotNV_7 = dotNV_6;
    let _e189: f32 = perceptualRoughness_7;
    let _e190: f32 = dotNV_7;
    let _e191: vec2<f32> = waterSurfaceEnvironmentDfg(_e189, _e190);
    dfg = _e191;
    let _e193: f32 = f0_5;
    let _e194: vec2<f32> = dfg;
    let _e197: vec2<f32> = dfg;
    return vec3(((_e193 * _e194.x) + _e197.y));
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
    let _e193: f32 = perceptualRoughness_9;
    let _e194: f32 = waterSurfaceResolvePerceptualRoughness(_e193);
    resolvedPerceptualRoughness = _e194;
    let _e196: f32 = resolvedPerceptualRoughness;
    let _e197: f32 = resolvedPerceptualRoughness;
    roughness_2 = max((_e196 * _e197), 0.0078125f);
    let _e202: f32 = roughness_2;
    let _e203: f32 = roughness_2;
    roughnessSquared = max((_e202 * _e203), 0.000061035156f);
    let _e208: f32 = dotNH_5;
    denominator_1 = clamp(_e208, 0f, 1f);
    let _e213: f32 = denominator_1;
    let _e214: f32 = denominator_1;
    let _e216: f32 = roughnessSquared;
    denominator_1 = (((_e213 * _e214) * (_e216 - 1f)) + 1.00001f);
    let _e222: f32 = dotLH_5;
    let _e226: f32 = dotLH_5;
    lightDotHalfSquared = max((clamp(_e222, 0f, 1f) * clamp(_e226, 0f, 1f)), 0.1f);
    let _e234: f32 = roughness_2;
    normalization = ((_e234 * 4f) + 2f);
    let _e240: f32 = roughnessSquared;
    let _e241: f32 = denominator_1;
    let _e242: f32 = denominator_1;
    let _e244: f32 = lightDotHalfSquared;
    let _e246: f32 = normalization;
    specularTerm = (_e240 / max((((_e241 * _e242) * _e244) * _e246), WATER_SURFACE_BRDF_EPSILON));
    let _e251: f32 = f0_7;
    let _e255: f32 = specularTerm;
    let _e257: f32 = dotNL_5;
    return ((clamp(_e251, 0f, 1f) * _e255) * clamp(_e257, 0f, 1f));
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
    let _e194: f32 = global.material_EnvironmentReflectionAvailable;
    if (_e194 > 0.5f) {
        {
            let _e197: vec3<f32> = directionWS_5;
            let _e198: vec3<f32> = positionWS_7;
            let _e199: f32 = perceptualRoughness_11;
            let _e200: vec3<f32> = sampleWaterDistantEnvironmentReflection(_e197, _e198, _e199);
            (*radiance) = _e200;
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
    let _e197: f32 = normalY_1;
    let _e206: f32 = perceptualRoughness_13;
    let _e213: f32 = environmentIntensity_1;
    return (mix(vec3<f32>(0.075f, 0.16f, 0.21f), vec3<f32>(0.32f, 0.48f, 0.57f), vec3(mix(clamp(((_e197 * 0.5f) + 0.5f), 0f, 1f), 0.5f, clamp(_e206, 0f, 1f)))) * max(_e213, 0f));
}

fn waterSurfaceResolveRawContributionsV2_(refraction: WaterSurfaceRawRefractionFactsV2_, reflection: WaterSurfaceRawReflectionFactsV2_, foamWeight: f32, policy: WaterSurfaceRawContributionPolicyV2_) -> WaterSurfaceResolvedRawContributionsV2_ {
    var refraction_1: WaterSurfaceRawRefractionFactsV2_;
    var reflection_1: WaterSurfaceRawReflectionFactsV2_;
    var foamWeight_1: f32;
    var policy_1: WaterSurfaceRawContributionPolicyV2_;
    var resolved: WaterSurfaceResolvedRawContributionsV2_;
    var displacedValidity: f32;
    var environment: vec3<f32>;
    var ssrScale: f32;
    var ssrBlend: f32;

    refraction_1 = refraction;
    reflection_1 = reflection;
    foamWeight_1 = foamWeight;
    policy_1 = policy;
    let _e193: f32 = foamWeight_1;
    resolved.foamWeight = clamp(_e193, 0f, 1f);
    let _e197: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e200: WaterSurfaceRawContributionPolicyV2_ = policy_1;
    displacedValidity = clamp((_e197.displacedSampleValidity * step(0.5f, _e200.refractionEnabled)), 0f, 1f);
    let _e209: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e211: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e213: f32 = displacedValidity;
    resolved.refractionSceneColor = mix(_e209.centeredSceneSample, _e211.displacedSceneSample, vec3(_e213));
    let _e219: WaterSurfaceRawContributionPolicyV2_ = policy_1;
    let _e223: f32 = displacedValidity;
    let _e225: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e231: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e237: WaterSurfaceRawRefractionFactsV2_ = refraction_1;
    let _e243: WaterSurfaceRawContributionPolicyV2_ = policy_1;
    let _e250: WaterSurfaceResolvedRawContributionsV2_ = resolved;
    let _e257: WaterSurfaceRawContributionPolicyV2_ = policy_1;
    resolved.refractionWeight = clamp(((((((((1f - step(1.5f, _e219.primaryColorClosureModel)) * _e223) * clamp(_e225.depthWeight, 0f, 1f)) * clamp(_e231.shoreValidity, 0f, 1f)) * clamp(_e237.coverage, 0f, 1f)) * clamp(_e243.clarity, 0f, 1f)) * (1f - (_e250.foamWeight * 0.94f))) * (1f - clamp(_e257.boundaryRefractionSuppression, 0f, 1f))), 0f, 1f);
    let _e267: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    let _e269: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    let _e271: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    environment = mix(_e267.analyticSample, _e269.environmentSample, vec3(clamp(_e271.environmentValidity, 0f, 1f)));
    let _e280: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
    resolved.reflectionRadiance = _e280.analyticSample;
    let _e282: WaterSurfaceRawContributionPolicyV2_ = policy_1;
    if (_e282.reflectionSource > 2.5f) {
        {
            let _e286: WaterSurfaceRawContributionPolicyV2_ = policy_1;
            ssrScale = clamp(_e286.ssrCompositeIntensity, 0f, 1f);
            let _e292: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
            let _e294: f32 = ssrScale;
            ssrBlend = clamp((_e292.ssrValidity * _e294), 0f, 1f);
            let _e301: vec3<f32> = environment;
            let _e303: f32 = ssrBlend;
            let _e306: WaterSurfaceRawReflectionFactsV2_ = reflection_1;
            let _e308: f32 = ssrScale;
            resolved.reflectionRadiance = ((_e301 * (1f - _e303)) + (_e306.ssrPremultipliedSample * _e308));
        }
    } else {
        let _e311: WaterSurfaceRawContributionPolicyV2_ = policy_1;
        if (_e311.reflectionSource > 0.5f) {
            {
                let _e316: vec3<f32> = environment;
                resolved.reflectionRadiance = _e316;
            }
        }
    }
    let _e317: WaterSurfaceResolvedRawContributionsV2_ = resolved;
    return _e317;
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
    var local_11: vec3<f32>;
    var local_12: vec3<f32>;

    sceneColor_1 = sceneColor;
    surfaceColor_1 = surfaceColor;
    depthColor_1 = depthColor;
    depthFactor_1 = depthFactor;
    diffuseLighting_1 = diffuseLighting;
    closureModel_1 = closureModel;
    let _e195: f32 = closureModel_1;
    if (_e195 > 3.5f) {
        {
            let _e198: vec3<f32> = sceneColor_1;
            let _e199: vec3<f32> = depthColor_1;
            let _e200: f32 = depthFactor_1;
            let _e206: vec3<f32> = diffuseLighting_1;
            return (mix(_e198, _e199, vec3(clamp(_e200, 0f, 1f))) * max(_e206, vec3(0f)));
        }
    }
    let _e211: vec3<f32> = surfaceColor_1;
    let _e212: vec3<f32> = depthColor_1;
    let _e213: vec3<f32> = diffuseLighting_1;
    let _e218: f32 = depthFactor_1;
    stylized = mix(_e211, (_e212 * max(_e213, vec3(0f))), vec3(clamp(_e218, 0f, 1f)));
    let _e225: vec3<f32> = sceneColor_1;
    let _e231: vec3<f32> = depthColor_1;
    let _e232: vec3<f32> = diffuseLighting_1;
    let _e237: f32 = depthFactor_1;
    litScene = mix(clamp(_e225, vec3(0f), vec3(1f)), (_e231 * max(_e232, vec3(0f))), vec3(clamp(_e237, 0f, 1f)));
    let _e244: f32 = closureModel_1;
    if (_e244 > 1.5f) {
        let _e247: vec3<f32> = litScene;
        local_12 = _e247;
    } else {
        let _e248: f32 = closureModel_1;
        if (_e248 > 0.5f) {
            let _e251: vec3<f32> = stylized;
            local_11 = _e251;
        } else {
            let _e252: vec3<f32> = surfaceColor_1;
            local_11 = _e252;
        }
        let _e254: vec3<f32> = local_11;
        local_12 = _e254;
    }
    let _e256: vec3<f32> = local_12;
    return _e256;
}

fn waterSurfaceOpticalTransmittance(absorptionCoefficient: vec3<f32>, opticalDepth: f32) -> vec3<f32> {
    var absorptionCoefficient_1: vec3<f32>;
    var opticalDepth_1: f32;

    absorptionCoefficient_1 = absorptionCoefficient;
    opticalDepth_1 = opticalDepth;
    let _e187: vec3<f32> = absorptionCoefficient_1;
    let _e192: f32 = opticalDepth_1;
    return exp((-(max(_e187, vec3(0f))) * max(_e192, 0f)));
}

fn waterSurfaceOpticalScattering(scatteringColor: vec3<f32>, scatteringCoefficient: f32, opticalDepth_2: f32) -> vec3<f32> {
    var scatteringColor_1: vec3<f32>;
    var scatteringCoefficient_1: f32;
    var opticalDepth_3: f32;
    var weight: f32;

    scatteringColor_1 = scatteringColor;
    scatteringCoefficient_1 = scatteringCoefficient;
    opticalDepth_3 = opticalDepth_2;
    let _e190: f32 = scatteringCoefficient_1;
    let _e194: f32 = opticalDepth_3;
    weight = (1f - exp((-(max(_e190, 0f)) * max(_e194, 0f))));
    let _e201: vec3<f32> = scatteringColor_1;
    let _e205: f32 = weight;
    return (max(_e201, vec3(0f)) * _e205);
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
    let _e193: vec3<f32> = surfaceColor_3;
    let _e194: vec3<f32> = absorptionCoefficient_3;
    let _e195: f32 = opticalDepth_5;
    let _e196: vec3<f32> = waterSurfaceOpticalTransmittance(_e194, _e195);
    let _e198: vec3<f32> = scatteringColor_3;
    let _e199: f32 = scatteringCoefficient_3;
    let _e200: f32 = opticalDepth_5;
    let _e201: vec3<f32> = waterSurfaceOpticalScattering(_e198, _e199, _e200);
    return ((_e193 * _e196) + _e201);
}

fn waterSurfaceComposeFinal(color_2: vec3<f32>, alpha_5: f32, precomposedReplace: f32) -> vec4<f32> {
    var color_3: vec3<f32>;
    var alpha_6: f32;
    var precomposedReplace_1: f32;

    color_3 = color_2;
    alpha_6 = alpha_5;
    precomposedReplace_1 = precomposedReplace;
    let _e189: vec3<f32> = color_3;
    let _e190: f32 = alpha_6;
    let _e196: f32 = precomposedReplace_1;
    return vec4<f32>(_e189.x, _e189.y, _e189.z, mix(clamp(_e190, 0f, 1f), 1f, step(0.5f, _e196)));
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
    let _e200: f32 = clarity_1;
    let _e206: f32 = opticalDepth_7;
    absorptionAlpha = (1f - exp((-(mix(0.48f, 0.13f, clamp(_e200, 0f, 1f))) * max(_e206, 0f))));
    let _e213: f32 = baseAlpha_1;
    let _e216: f32 = absorptionAlpha;
    alpha_7 = (_e213 * mix(0.18f, 0.94f, _e216));
    let _e220: f32 = alpha_7;
    let _e221: f32 = fresnel_2;
    let _e226: f32 = alpha_7;
    alpha_7 = (_e220 + ((clamp(_e221, 0f, 1f) * (1f - _e226)) * 0.48f));
    let _e232: f32 = alpha_7;
    let _e233: f32 = foamWeight_3;
    alpha_7 = (_e232 + (clamp(_e233, 0f, 1f) * 0.3f));
    let _e240: f32 = alpha_7;
    let _e241: f32 = coastalAlpha_1;
    let _e242: f32 = coastalAlphaWeight_1;
    alpha_7 = mix(_e240, _e241, clamp(_e242, 0f, 1f));
    let _e247: f32 = alpha_7;
    return clamp(_e247, 0f, 1f);
}

fn waterSurfaceCreateResolvedLightingV2_(ambientDiffuseRadiance: vec3<f32>) -> WaterSurfaceResolvedLightingV2_ {
    var ambientDiffuseRadiance_1: vec3<f32>;
    var lighting: WaterSurfaceResolvedLightingV2_;

    ambientDiffuseRadiance_1 = ambientDiffuseRadiance;
    let _e187: vec3<f32> = ambientDiffuseRadiance_1;
    lighting.diffuseRadiance = max(_e187, vec3(0f));
    lighting.directSpecularRadiance = vec3(0f);
    let _e194: WaterSurfaceResolvedLightingV2_ = lighting;
    return _e194;
}

fn waterSurfaceAccumulateDirectLightingV2_(lighting_1: WaterSurfaceResolvedLightingV2_, lightRadiance: vec3<f32>, normalDotView: f32, normalDotLight: f32, normalDotHalf: f32, lightDotHalf: f32, fresnelF0_: f32, perceptualRoughness_14: f32, primaryColorClosureModel: f32, directSpecularEnabled: f32) -> WaterSurfaceResolvedLightingV2_ {
    var lighting_2: WaterSurfaceResolvedLightingV2_;
    var lightRadiance_1: vec3<f32>;
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
    lightRadiance_1 = lightRadiance;
    normalDotView_1 = normalDotView;
    normalDotLight_1 = normalDotLight;
    normalDotHalf_1 = normalDotHalf;
    lightDotHalf_1 = lightDotHalf;
    fresnelF0_1 = fresnelF0_;
    perceptualRoughness_15 = perceptualRoughness_14;
    primaryColorClosureModel_1 = primaryColorClosureModel;
    directSpecularEnabled_1 = directSpecularEnabled;
    let _e203: vec3<f32> = lightRadiance_1;
    safeLightRadiance = max(_e203, vec3(0f));
    let _e208: f32 = normalDotLight_1;
    safeNormalDotLight = clamp(_e208, 0f, 1f);
    let _e215: f32 = directSpecularEnabled_1;
    specGate = clamp(_e215, 0f, 1f);
    let _e220: f32 = specGate;
    if (_e220 > 0f) {
        {
            let _e223: f32 = primaryColorClosureModel_1;
            let _e226: f32 = primaryColorClosureModel_1;
            if ((_e223 >= 1.5f) && (_e226 < 3.5f)) {
                {
                    let _e230: f32 = fresnelF0_1;
                    let _e231: f32 = perceptualRoughness_15;
                    let _e232: f32 = safeNormalDotLight;
                    let _e233: f32 = normalDotHalf_1;
                    let _e234: f32 = lightDotHalf_1;
                    let _e235: f32 = waterSurfaceLitDirectSpecular(_e230, _e231, _e232, _e233, _e234);
                    resolvedDirectSpecular = _e235;
                }
            } else {
                {
                    let _e236: f32 = fresnelF0_1;
                    let _e237: f32 = perceptualRoughness_15;
                    let _e238: f32 = normalDotView_1;
                    let _e239: f32 = safeNormalDotLight;
                    let _e240: f32 = normalDotHalf_1;
                    let _e241: f32 = lightDotHalf_1;
                    let _e242: f32 = waterSurfaceDirectSpecular(_e236, _e237, _e238, _e239, _e240, _e241);
                    resolvedDirectSpecular = _e242;
                }
            }
            let _e243: f32 = resolvedDirectSpecular;
            let _e244: f32 = specGate;
            resolvedDirectSpecular = (_e243 * _e244);
        }
    }
    let _e247: WaterSurfaceResolvedLightingV2_ = lighting_2;
    let _e249: vec3<f32> = safeLightRadiance;
    let _e250: f32 = safeNormalDotLight;
    lighting_2.diffuseRadiance = (_e247.diffuseRadiance + (_e249 * _e250));
    let _e254: WaterSurfaceResolvedLightingV2_ = lighting_2;
    let _e256: vec3<f32> = safeLightRadiance;
    let _e257: f32 = resolvedDirectSpecular;
    lighting_2.directSpecularRadiance = (_e254.directSpecularRadiance + (_e256 * _e257));
    let _e260: WaterSurfaceResolvedLightingV2_ = lighting_2;
    return _e260;
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
    var local_13: vec3<f32>;
    var color_4: vec3<f32>;
    var boundaryContribution: vec3<f32>;
    var litSceneColorClosure: f32;
    var reflectionBrdfWeight: vec3<f32>;
    var litFoamColor: vec3<f32>;
    var alpha_8: f32;
    var replace: f32;

    closure_1 = closure;
    foamColorWeight_1 = foamColorWeight;
    depthOpacity_1 = depthOpacity;
    let _e189: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e192: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e194: f32 = waterSurfaceSchlick(_e189.fresnelF0_, 1f, _e192.normalDotView);
    fresnel_3 = _e194;
    let _e196: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e198: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e200: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e202: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e204: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e206: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e208: vec3<f32> = waterSurfaceResolvePrimaryColor(_e196.primarySceneColor, _e198.surfaceColor, _e200.depthColor, _e202.depthFactor, _e204.diffuseLighting, _e206.primaryColorClosureModel);
    primaryColor = _e208;
    let _e210: vec3<f32> = primaryColor;
    baseColor = _e210;
    let _e214: WaterSurfaceFinalClosureV2Input = closure_1;
    resolvedRefractionColor = _e214.refractionColor;
    let _e217: WaterSurfaceFinalClosureV2Input = closure_1;
    if (_e217.primaryColorClosureModel < 0.5f) {
        {
            let _e221: vec3<f32> = primaryColor;
            let _e222: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e224: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e226: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e228: WaterSurfaceFinalClosureV2Input = closure_1;
            let _e230: vec3<f32> = waterSurfaceApplyOpticalVolume(_e221, _e222.absorptionCoefficient, _e224.scatteringColor, _e226.scatteringCoefficient, _e228.opticalDepth);
            baseColor = _e230;
            let _e231: WaterSurfaceFinalClosureV2Input = closure_1;
            refractionMix = clamp(_e231.refractionWeight, 0f, 1f);
            let _e236: f32 = refractionMix;
            if (_e236 > 0f) {
                {
                    let _e239: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e241: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e243: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e245: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e247: WaterSurfaceFinalClosureV2Input = closure_1;
                    let _e249: vec3<f32> = waterSurfaceApplyOpticalVolume(_e239.refractionColor, _e241.absorptionCoefficient, _e243.scatteringColor, _e245.scatteringCoefficient, _e247.opticalDepth);
                    resolvedRefractionColor = _e249;
                }
            }
        }
    } else {
        let _e250: WaterSurfaceFinalClosureV2Input = closure_1;
        if (_e250.primaryColorClosureModel < 1.5f) {
            {
                let _e254: WaterSurfaceFinalClosureV2Input = closure_1;
                refractionMix = clamp(_e254.refractionWeight, 0f, 1f);
            }
        }
    }
    let _e259: f32 = refractionMix;
    if (_e259 > 0f) {
        let _e262: vec3<f32> = baseColor;
        let _e263: vec3<f32> = resolvedRefractionColor;
        let _e264: f32 = refractionMix;
        local_13 = mix(_e262, _e263, vec3(_e264));
    } else {
        let _e267: vec3<f32> = baseColor;
        local_13 = _e267;
    }
    let _e269: vec3<f32> = local_13;
    color_4 = _e269;
    let _e271: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e273: WaterSurfaceFinalClosureV2Input = closure_1;
    boundaryContribution = (_e271.boundaryColor * max(_e273.diffuseLighting, vec3(0f)));
    let _e281: WaterSurfaceFinalClosureV2Input = closure_1;
    litSceneColorClosure = step(1.5f, _e281.primaryColorClosureModel);
    let _e285: vec3<f32> = color_4;
    let _e286: vec3<f32> = boundaryContribution;
    let _e287: f32 = litSceneColorClosure;
    color_4 = (_e285 + (_e286 * _e287));
    let _e290: vec3<f32> = color_4;
    let _e293: f32 = fresnel_3;
    let _e295: WaterSurfaceFinalClosureV2Input = closure_1;
    color_4 = (_e290 * mix(1f, (1f - _e293), clamp(_e295.transmissionFresnelWeight, 0f, 1f)));
    let _e302: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e304: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e306: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e308: vec3<f32> = waterSurfaceEnvironmentSpecularWeight(_e302.fresnelF0_, _e304.perceptualRoughness, _e306.normalDotView);
    reflectionBrdfWeight = _e308;
    let _e310: vec3<f32> = color_4;
    let _e311: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e313: vec3<f32> = reflectionBrdfWeight;
    let _e315: WaterSurfaceFinalClosureV2Input = closure_1;
    color_4 = (_e310 + ((_e311.reflectionRadiance * _e313) * max(_e315.reflectionIntensity, 0f)));
    let _e321: vec3<f32> = color_4;
    let _e322: WaterSurfaceFinalClosureV2Input = closure_1;
    color_4 = (_e321 + _e322.directSpecularRadiance);
    let _e325: vec3<f32> = color_4;
    let _e326: vec3<f32> = boundaryContribution;
    let _e328: f32 = litSceneColorClosure;
    color_4 = (_e325 + (_e326 * (1f - _e328)));
    let _e332: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e334: WaterSurfaceFinalClosureV2Input = closure_1;
    litFoamColor = (_e332.foamColor * max(_e334.diffuseLighting, vec3(0f)));
    let _e341: vec3<f32> = color_4;
    let _e342: vec3<f32> = litFoamColor;
    let _e343: f32 = foamColorWeight_1;
    color_4 = mix(_e341, _e342, vec3(clamp(_e343, 0f, 1f)));
    let _e349: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e351: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e353: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e355: f32 = fresnel_3;
    let _e356: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e358: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e360: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e362: f32 = waterSurfaceResolveAlphaV2_(_e349.baseAlpha, _e351.clarity, _e353.opticalDepth, _e355, _e356.foamWeight, _e358.coastalAlpha, _e360.coastalAlphaWeight);
    let _e363: WaterSurfaceFinalClosureV2Input = closure_1;
    alpha_8 = (_e362 * clamp(_e363.coverage, 0f, 1f));
    let _e371: WaterSurfaceFinalClosureV2Input = closure_1;
    replace = step(0.5f, _e371.precomposedReplace);
    let _e375: vec3<f32> = color_4;
    let _e376: WaterSurfaceFinalClosureV2Input = closure_1;
    let _e378: vec3<f32> = color_4;
    let _e379: f32 = alpha_8;
    let _e382: f32 = replace;
    color_4 = mix(_e375, mix(_e376.compositionSceneColor, _e378, vec3(_e379)), vec3(_e382));
    let _e385: vec3<f32> = color_4;
    let _e386: f32 = alpha_8;
    let _e387: f32 = replace;
    let _e388: vec4<f32> = waterSurfaceComposeFinal(_e385, _e386, _e387);
    return _e388;
}

fn waterSurfaceEvaluateFinalClosureV2_1(closure_2: WaterSurfaceFinalClosureV2Input, foamColorWeight_2: f32) -> vec4<f32> {
    var closure_3: WaterSurfaceFinalClosureV2Input;
    var foamColorWeight_3: f32;

    closure_3 = closure_2;
    foamColorWeight_3 = foamColorWeight_2;
    let _e187: WaterSurfaceFinalClosureV2Input = closure_3;
    let _e188: f32 = foamColorWeight_3;
    let _e190: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_(_e187, _e188, 1f);
    return _e190;
}

fn waterSurfaceEvaluateFinalClosureV2_2(closure_4: WaterSurfaceFinalClosureV2Input) -> vec4<f32> {
    var closure_5: WaterSurfaceFinalClosureV2Input;

    closure_5 = closure_4;
    let _e185: WaterSurfaceFinalClosureV2Input = closure_5;
    let _e186: WaterSurfaceFinalClosureV2Input = closure_5;
    let _e188: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_1(_e185, _e186.foamWeight);
    return _e188;
}

fn waterSurfaceOutputWithPick(color_5: vec4<f32>) -> vec4<f32> {
    var color_6: vec4<f32>;

    color_6 = color_5;
    let _e185: vec4<f32> = color_6;
    return _e185;
}

fn waterSurfaceLightingSafeNormalize3_(value_6: vec3<f32>, fallbackValue_4: vec3<f32>) -> vec3<f32> {
    var value_7: vec3<f32>;
    var fallbackValue_5: vec3<f32>;
    var lengthSquared_2: f32;
    var local_14: vec3<f32>;

    value_7 = value_6;
    fallbackValue_5 = fallbackValue_4;
    let _e188: vec3<f32> = value_7;
    let _e189: vec3<f32> = value_7;
    lengthSquared_2 = dot(_e188, _e189);
    let _e192: f32 = lengthSquared_2;
    if (_e192 > 0.000001f) {
        let _e195: vec3<f32> = value_7;
        let _e196: f32 = lengthSquared_2;
        local_14 = (_e195 * inverseSqrt(_e196));
    } else {
        let _e199: vec3<f32> = fallbackValue_5;
        local_14 = _e199;
    }
    let _e201: vec3<f32> = local_14;
    return _e201;
}

fn waterSurfaceAppearanceAmbientIrradiance(normalWS: vec3<f32>) -> vec3<f32> {
    var normalWS_1: vec3<f32>;
    var ambientIrradiance: vec3<f32>;

    normalWS_1 = normalWS;
    let _e186: WaterSurfaceEnvironmentLight = scene_EnvMapLight;
    ambientIrradiance = (_e186.diffuse * WATER_SURFACE_PI);
    let _e190: vec3<f32> = ambientIrradiance;
    let _e191: WaterSurfaceEnvironmentLight = scene_EnvMapLight;
    return (_e190 * max(_e191.diffuseIntensity, 0f));
}

fn evaluateWaterSurfaceDirectionalLighting(positionWS_8: vec3<f32>, normalWS_2: vec3<f32>, viewDirection: vec3<f32>, normalDotView_2: f32, fresnelF0_2: f32, roughness_3: f32, litSceneColorSpecular: f32, directDiffuseRadiance: ptr<function, vec3<f32>>, directSpecularRadiance: ptr<function, vec3<f32>>) {
    var positionWS_9: vec3<f32>;
    var normalWS_3: vec3<f32>;
    var viewDirection_1: vec3<f32>;
    var normalDotView_3: f32;
    var fresnelF0_3: f32;
    var roughness_4: f32;
    var litSceneColorSpecular_1: f32;
    var resolvedLighting: WaterSurfaceResolvedLightingV2_;

    positionWS_9 = positionWS_8;
    normalWS_3 = normalWS_2;
    viewDirection_1 = viewDirection;
    normalDotView_3 = normalDotView_2;
    fresnelF0_3 = fresnelF0_2;
    roughness_4 = roughness_3;
    litSceneColorSpecular_1 = litSceneColorSpecular;
    let _e202: WaterSurfaceResolvedLightingV2_ = waterSurfaceCreateResolvedLightingV2_(vec3(0f));
    resolvedLighting = _e202;
    let _e204: WaterSurfaceResolvedLightingV2_ = resolvedLighting;
    (*directDiffuseRadiance) = _e204.diffuseRadiance;
    let _e206: WaterSurfaceResolvedLightingV2_ = resolvedLighting;
    (*directSpecularRadiance) = _e206.directSpecularRadiance;
    return;
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

fn waterConnectionNormal(p_4: vec2<f32>, normal_1: vec3<f32>) -> vec3<f32> {
    var p_5: vec2<f32>;
    var normal_2: vec3<f32>;

    p_5 = p_4;
    normal_2 = normal_1;
    let _e192: vec3<f32> = normal_2;
    let _e193: vec2<f32> = p_5;
    let _e194: vec4<f32> = waterConnectionFacts(_e193);
    return normalize(mix(vec3<f32>(0f, 1f, 0f), _e192, vec3(_e194.x)));
}

fn waterWindVelocity() -> vec3<f32> {
    let _e184: vec3<f32> = global.scene_WindVelocity;
    let _e185: vec3<f32> = global.material_WindVelocity;
    let _e186: f32 = global.material_WindVelocityOverride;
    return mix(_e184, _e185, vec3(clamp(_e186, 0f, 1f)));
}

fn surfaceTime_4() -> f32 {
    var local_15: f32;
    var selected: f32;

    let _e184: f32 = global.material_SurfaceTimeOverride;
    if (_e184 >= 0f) {
        let _e187: f32 = global.material_SurfaceTimeOverride;
        local_15 = _e187;
    } else {
        let _e188: vec4<f32> = global.scene_ElapsedTime;
        local_15 = _e188.x;
    }
    let _e191: f32 = local_15;
    selected = _e191;
    let _e193: f32 = selected;
    let _e195: f32 = max(_e193, 0f);
    return (_e195 - (floor((_e195 / 4096f)) * 4096f));
}

fn safeNormalize2_(value_8: vec2<f32>, fallbackValue_6: vec2<f32>) -> vec2<f32> {
    var value_9: vec2<f32>;
    var fallbackValue_7: vec2<f32>;
    var lengthSquared_3: f32;
    var local_16: vec2<f32>;

    value_9 = value_8;
    fallbackValue_7 = fallbackValue_6;
    let _e188: vec2<f32> = value_9;
    let _e189: vec2<f32> = value_9;
    lengthSquared_3 = dot(_e188, _e189);
    let _e192: f32 = lengthSquared_3;
    if (_e192 > 0.000001f) {
        let _e195: vec2<f32> = value_9;
        let _e196: f32 = lengthSquared_3;
        local_16 = (_e195 * inverseSqrt(_e196));
    } else {
        let _e199: vec2<f32> = fallbackValue_7;
        local_16 = _e199;
    }
    let _e201: vec2<f32> = local_16;
    return _e201;
}

fn safeNormalize3_(value_10: vec3<f32>, fallbackValue_8: vec3<f32>) -> vec3<f32> {
    var value_11: vec3<f32>;
    var fallbackValue_9: vec3<f32>;
    var lengthSquared_4: f32;
    var local_17: vec3<f32>;

    value_11 = value_10;
    fallbackValue_9 = fallbackValue_8;
    let _e188: vec3<f32> = value_11;
    let _e189: vec3<f32> = value_11;
    lengthSquared_4 = dot(_e188, _e189);
    let _e192: f32 = lengthSquared_4;
    if (_e192 > 0.000001f) {
        let _e195: vec3<f32> = value_11;
        let _e196: f32 = lengthSquared_4;
        local_17 = (_e195 * inverseSqrt(_e196));
    } else {
        let _e199: vec3<f32> = fallbackValue_9;
        local_17 = _e199;
    }
    let _e201: vec3<f32> = local_17;
    return _e201;
}

fn frag(input: Varyings) {
    var input_1: Varyings;
    var localMap: vec4<f32>;
    var flowXZ: vec2<f32>;
    var authoredDepth: f32;
    var signedDistance: f32;
    var coverageHalfWidth: f32;
    var coverage: f32;
    var precomposedReplace_2: bool;
    var elapsedTime: f32;
    var fieldViewDirection: vec3<f32>;
    var sceneRayEyeScale: f32;
    var orthographicProjection_2: f32 = 0f;
    var fallbackSceneRayDepth: f32;
    var screenUv: vec2<f32>;
    var sceneDepthBufferSample: f32;
    var sceneEyeDepthSample: f32;
    var centeredSceneDepthAvailable: f32;
    var sceneEyeDepth_4: f32;
    var sceneDepthDelta_2: f32;
    var sceneRayDepth: f32;
    var opaquePositionWS_2: vec3<f32>;
    var exactSurfaceNormalDepth: f32;
    var surfaceNormalDepth: f32;
    var sampledOpticalDepth: f32;
    var opticalDepth_8: f32;
    var centeredDepthBehind: f32;
    var flowSpeed: f32;
    var flowWeight: f32;
    var sceneWindSpeed: f32;
    var local_18: vec2<f32>;
    var stillWaterDirection: vec2<f32>;
    var flowDirection: vec2<f32>;
    var baseWorldPosition: vec3<f32>;
    var heightfieldObstacleContact: f32;
    var waterSurface_positionWS: vec3<f32>;
    var waterSurface_macroNormalWS: vec3<f32>;
    var waterSurface_tangentWS: vec3<f32>;
    var waterSurface_bitangentWS: vec3<f32>;
    var waterSurface_meshUv: vec2<f32>;
    var waterSurface_flowWS: vec2<f32>;
    var waterSurface_coverage: f32;
    var waterSurface_verticalDepth: f32;
    var waterSurface_horizontalShoreDistance: f32;
    var waterSurface_obstacleContact: f32;
    var waterSurface_waveCrest: f32;
    var surfaceNormalWS_2: vec3<f32>;
    var appearanceNormalTS: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var appearanceLayerCoordinate0_: vec2<f32>;
    var appearanceLayerScaled0_: vec2<f32>;
    var appearanceLayerUv0_: vec2<f32>;
    var appearanceLayerNormal0_: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var appearanceLayerCoordinate1_: vec2<f32>;
    var appearanceLayerScaled1_: vec2<f32>;
    var appearanceLayerUv1_: vec2<f32>;
    var appearanceLayerNormal1_: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var appearanceTangentWS: vec3<f32>;
    var appearanceBitangentWS: vec3<f32>;
    var appearanceSurfaceNormalWS: vec3<f32>;
    var rainRate: f32;
    var rainRippleMask: f32 = 0f;
    var rainRippleStormAmount: f32 = 0f;
    var rainRippleUpwardCosine: f32;
    var rainRippleUpwardFade: f32;
    var rainRippleCameraDelta: vec3<f32>;
    var rainRippleHorizontalDistance: f32;
    var rainRippleVerticalDistance: f32;
    var rainRippleDistance: f32;
    var rainRippleDistanceFade: f32;
    var rainRippleRingAmplitude: f32;
    var rainRippleContribution: f32;
    var rainRipplePlaybackStrength: f32;
    var rainRippleRainAmount: f32;
    var rainRipplePrimarySample: vec2<f32>;
    var rainRipplePrimaryDensity: f32;
    var rainRippleSlope: vec2<f32>;
    var rainRippleRawMask: f32;
    var rainRippleSecondaryAmount: f32;
    var rotatedRainRippleXZ: vec2<f32>;
    var rainRippleSecondarySample: vec2<f32>;
    var rainRippleSecondaryDensity: f32;
    var rainRippleSecondaryWeight: f32;
    var rainRippleRoughnessResponse: f32;
    var rainRippleRoughnessFloor: f32;
    var rainRippleSurfaceRoughness: f32;
    var viewDirection_2: vec3<f32>;
    var normalFacing: f32;
    var normalDotView_4: f32;
    var localBathymetryProjectionDenominator: f32 = 1f;
    var localSceneRayDepth: f32;
    var bodyBoundedSceneRayDepth: f32;
    var fresnelF0_4: f32;
    var contactFoamMask: f32 = 0f;
    var appearanceCoastalAlpha: f32 = 0f;
    var appearanceBoundaryColor: vec3<f32> = vec3(0f);
    var appearanceBoundaryAlbedo: vec3<f32> = vec3(0f);
    var appearanceBoundaryAlbedoWeight: f32 = 0f;
    var appearanceBoundaryRoughness: f32 = 0f;
    var appearanceBoundaryRefractionSuppression: f32 = 0f;
    var appearanceBoundaryField0_: f32;
    var appearanceBoundaryRawNormalized0_: f32;
    var appearanceBoundaryNormalized0_: f32;
    var appearanceBoundaryMask0_: f32;
    var appearanceBoundaryField1_: f32;
    var appearanceBoundaryRawNormalized1_: f32;
    var appearanceBoundaryMask1_: f32 = 0f;
    var appearanceBoundaryGate1_: bool;
    var appearanceBoundaryRawNorm1_: f32;
    var appearanceBoundaryPatternExp1_: f32;
    var appearanceBoundaryPMax1_: f32 = -1f;
    var appearanceBoundaryAlwaysZero1_: bool = false;
    var appearanceBoundaryBaseReq1_: f32;
    var local_19: f32;
    var appearanceBoundaryPattern1_: f32;
    var appearanceBoundaryPatternResponse1_: f32;
    var appearanceBoundaryPMax1_1: f32 = -1f;
    var appearanceBoundaryPattern1_1: f32;
    var appearanceBoundaryPatternResponse1_1: f32;
    var effectiveSurfaceRoughness: f32;
    var directDiffuseRadiance_1: vec3<f32> = vec3(0f);
    var directSpecularRadiance_1: vec3<f32> = vec3(0f);
    var ambientDiffuse: vec3<f32>;
    var waterDiffuseLighting: vec3<f32>;
    var clarity_2: f32;
    var waterColor: vec3<f32>;
    var centeredOpaqueColor: vec3<f32>;
    var centeredOpaqueSampled: bool = false;
    var displacedOpaqueColor: vec3<f32>;
    var refractionUvDelta: vec2<f32> = vec2(0f);
    var refractionDepthContinuity: f32 = 1f;
    var refractionSampleValidity: f32 = 0f;
    var refractionDepthWeight: f32 = 0f;
    var refractionShoreWeight: f32 = 0f;
    var refractionFeatureWeight: f32;
    var baseNormalVS: vec3<f32>;
    var surfaceNormalVS: vec3<f32>;
    var refractionNormalDelta: vec2<f32>;
    var fragmentShoreDamping: f32;
    var displacedScreenUv: vec2<f32>;
    var refractionScreenInterior: f32;
    var refractedScreenUv: vec2<f32>;
    var refractionDepthDeltaUv: vec2<f32>;
    var local_20: f32;
    var refractedSceneDepthBufferSample: f32;
    var refractedSceneEyeDepthSample: f32;
    var refractedSceneDepthFinite: bool;
    var local_21: f32;
    var refractedSceneDepthAvailable: f32;
    var local_22: f32;
    var refractedSceneEyeDepth: f32;
    var refractedOpticalDepth: f32;
    var refractedGeometryBehindSurface: f32;
    var localRefractedGeometryBehindSurface: f32;
    var local_23: vec3<f32>;
    var appearanceDepthTintFactor: f32;
    var appearanceDepthTintColor: vec3<f32>;
    var rawAnalyticReflectionSample: vec3<f32> = vec3(0f);
    var rawEnvironmentReflectionSample: vec3<f32> = vec3(0f);
    var rawEnvironmentReflectionValidity: f32 = 0f;
    var rawSsrReflectionPremultipliedSample: vec3<f32> = vec3(0f);
    var rawSsrReflectionValidity: f32 = 0f;
    var sampleEnvironmentReflection: bool = true;
    var probeDirection: vec3<f32>;
    var reflectionIntensity: f32;
    var rawRefractionFacts: WaterSurfaceRawRefractionFactsV2_;
    var rawReflectionFacts: WaterSurfaceRawReflectionFactsV2_;
    var rawContributionPolicy: WaterSurfaceRawContributionPolicyV2_;
    var resolvedContributions: WaterSurfaceResolvedRawContributionsV2_;
    var closureInput: WaterSurfaceFinalClosureV2Input;
    var resolvedWaterClosure: vec4<f32>;
    var shaderCompositedColor: vec3<f32>;
    var surfaceAlpha: f32;
    var fragmentColor: vec3<f32>;
    var fragmentAlpha: f32;

    input_1 = input;
    let _e186: Varyings = input_1;
    let _e189: vec4<f32> = waterConnectionFacts(_e186.worldPosition.xz);
    if (_e189.w < 0.5f) {
        discard;
    }
    let _e193: Varyings = input_1;
    let _e195: vec4<f32> = textureSample(gs_wgpu_tex_material_LocalMapTexture, gs_wgpu_samp_material_LocalMapTexture, _e193.atlasUv);
    localMap = _e195;
    let _e197: vec4<f32> = localMap;
    let _e204: vec4<f32> = global_1.material_LocalMapDecode;
    flowXZ = (((_e197.xy * 2f) - vec2(1f)) * _e204.x);
    let _e208: vec4<f32> = localMap;
    let _e210: vec4<f32> = global_1.material_LocalMapDecode;
    let _e212: f32 = waterSpatialFieldDecodeDepth(_e208.z, _e210.y);
    authoredDepth = max(_e212, 0f);
    let _e216: vec4<f32> = localMap;
    let _e221: vec4<f32> = global_1.material_LocalMapDecode;
    let _e223: f32 = waterSpatialFieldDecodeSignedDistance(_e216.w, 2f, -1f, _e221.z);
    signedDistance = _e223;
    let _e225: Varyings = input_1;
    let _e228: f32 = signedDistance;
    let _e229: f32 = waterConnectionShore(_e225.worldPosition.xz, _e228);
    signedDistance = _e229;
    let _e231: f32 = signedDistance;
    let _e232: f32 = fwidth(_e231);
    let _e235: vec4<f32> = global_1.material_LocalMapDecode;
    coverageHalfWidth = max(0.08f, max((_e232 * 1.25f), (_e235.z * 0.007843138f)));
    let _e244: f32 = coverageHalfWidth;
    let _e246: f32 = coverageHalfWidth;
    let _e247: f32 = signedDistance;
    coverage = smoothstep(-(_e244), _e246, _e247);
    let _e250: f32 = global.material_CompositionMode;
    precomposedReplace_2 = (_e250 > 0.5f);
    let _e254: bool = precomposedReplace_2;
    let _e255: f32 = coverage;
    if (_e254 && (_e255 <= 0.001f)) {
        discard;
    }
    let _e259: f32 = surfaceTime_4();
    elapsedTime = _e259;
    let _e261: vec3<f32> = global.camera_Position;
    let _e262: Varyings = input_1;
    let _e265: Varyings = input_1;
    let _e267: vec3<f32> = safeNormalize3_((_e261 - _e262.worldPosition), _e265.macroNormalWS);
    fieldViewDirection = _e267;
    let _e269: Varyings = input_1;
    let _e271: vec3<f32> = global.camera_Position;
    let _e272: Varyings = input_1;
    sceneRayEyeScale = (_e269.surfaceEyeDepth / max(length((_e271 - _e272.worldPosition)), 0.001f));
    let _e282: f32 = authoredDepth;
    let _e283: Varyings = input_1;
    let _e285: vec3<f32> = fieldViewDirection;
    let _e286: f32 = waterSurfaceDerivedSceneRayDepth(_e282, _e283.macroNormalWS, _e285);
    fallbackSceneRayDepth = _e286;
    let _e288: Varyings = input_1;
    let _e291: Varyings = input_1;
    screenUv = (((_e288.clipPosition.xy / vec2(_e291.clipPosition.w)) * 0.5f) + vec2(0.5f));
    let _e304: vec2<f32> = screenUv;
    screenUv.y = (1f - _e304.y);
    let _e307: vec2<f32> = screenUv;
    let _e308: vec4<f32> = textureSample(gs_wgpu_tex_camera_DepthTexture, gs_wgpu_samp_camera_DepthTexture, _e307);
    sceneDepthBufferSample = _e308.x;
    let _e311: f32 = sceneDepthBufferSample;
    let _e312: f32 = remapDepthBufferEyeDepth(_e311);
    sceneEyeDepthSample = _e312;
    let _e314: f32 = sceneDepthBufferSample;
    let _e315: f32 = sceneEyeDepthSample;
    let _e316: Varyings = input_1;
    let _e318: f32 = waterSurfaceDepthSampleValidity(_e314, _e315, _e316.surfaceEyeDepth);
    centeredSceneDepthAvailable = _e318;
    let _e320: Varyings = input_1;
    let _e322: f32 = fallbackSceneRayDepth;
    let _e323: f32 = sceneRayEyeScale;
    let _e326: f32 = sceneEyeDepthSample;
    let _e327: f32 = centeredSceneDepthAvailable;
    sceneEyeDepth_4 = mix((_e320.surfaceEyeDepth + (_e322 * _e323)), _e326, _e327);
    let _e330: f32 = sceneEyeDepth_4;
    let _e331: Varyings = input_1;
    sceneDepthDelta_2 = max((_e330 - _e331.surfaceEyeDepth), 0f);
    let _e337: f32 = sceneDepthDelta_2;
    let _e338: f32 = sceneRayEyeScale;
    sceneRayDepth = (_e337 / max(_e338, 0.001f));
    let _e343: Varyings = input_1;
    let _e345: vec3<f32> = global.camera_Position;
    let _e346: mat4x4<f32> = global.camera_ViewInvMat;
    let _e347: Varyings = input_1;
    let _e349: f32 = sceneEyeDepth_4;
    let _e350: f32 = orthographicProjection_2;
    let _e351: vec3<f32> = waterSurfaceReconstructOpaquePositionWS(_e343.worldPosition, _e345, _e346, _e347.surfaceEyeDepth, _e349, _e350);
    opaquePositionWS_2 = _e351;
    let _e353: Varyings = input_1;
    let _e355: vec3<f32> = opaquePositionWS_2;
    let _e356: Varyings = input_1;
    let _e358: f32 = waterSurfaceNormalDepth(_e353.worldPosition, _e355, _e356.macroNormalWS);
    exactSurfaceNormalDepth = _e358;
    let _e360: f32 = authoredDepth;
    let _e361: f32 = exactSurfaceNormalDepth;
    let _e362: f32 = centeredSceneDepthAvailable;
    surfaceNormalDepth = mix(_e360, _e361, _e362);
    let _e365: f32 = sceneRayDepth;
    sampledOpticalDepth = _e365;
    let _e367: f32 = sampledOpticalDepth;
    let _e368: f32 = authoredDepth;
    opticalDepth_8 = min(_e367, _e368);
    let _e371: f32 = centeredSceneDepthAvailable;
    let _e373: f32 = sceneDepthDelta_2;
    centeredDepthBehind = (_e371 * step(0.000001f, _e373));
    let _e377: f32 = opticalDepth_8;
    let _e378: f32 = global.material_MaximumSurfaceOpticalDistance;
    opticalDepth_8 = min(_e377, max(_e378, 0f));
    let _e382: vec2<f32> = flowXZ;
    flowSpeed = length(_e382);
    let _e387: f32 = flowSpeed;
    flowWeight = smoothstep(0.055f, 0.756f, _e387);
    let _e390: vec3<f32> = waterWindVelocity();
    sceneWindSpeed = length(_e390.xz);
    let _e394: f32 = sceneWindSpeed;
    if (_e394 > 0.0001f) {
        let _e397: vec3<f32> = waterWindVelocity();
        let _e399: f32 = sceneWindSpeed;
        local_18 = (_e397.xz / vec2(_e399));
    } else {
        local_18 = vec2<f32>(-0.36f, -0.9329523f);
    }
    let _e408: vec2<f32> = local_18;
    stillWaterDirection = _e408;
    let _e410: vec2<f32> = stillWaterDirection;
    let _e411: vec2<f32> = flowXZ;
    let _e412: vec2<f32> = stillWaterDirection;
    let _e413: vec2<f32> = safeNormalize2_(_e411, _e412);
    let _e414: f32 = flowWeight;
    let _e419: vec2<f32> = stillWaterDirection;
    let _e420: vec2<f32> = safeNormalize2_(mix(_e410, _e413, vec2((_e414 * 0.88f))), _e419);
    flowDirection = _e420;
    let _e422: Varyings = input_1;
    let _e424: Varyings = input_1;
    let _e426: Varyings = input_1;
    baseWorldPosition = (_e422.worldPosition - (_e424.baseNormalWS * _e426.waveOffset));
    let _e431: vec3<f32> = baseWorldPosition;
    let _e433: f32 = signedDistance;
    let _e434: f32 = waterConnectionShore(_e431.xz, _e433);
    signedDistance = _e434;
    let _e435: f32 = opticalDepth_8;
    heightfieldObstacleContact = _e435;
    let _e437: Varyings = input_1;
    waterSurface_positionWS = _e437.worldPosition;
    let _e440: Varyings = input_1;
    waterSurface_macroNormalWS = _e440.macroNormalWS;
    let _e443: Varyings = input_1;
    waterSurface_tangentWS = _e443.tangentWS;
    let _e446: Varyings = input_1;
    let _e448: Varyings = input_1;
    let _e455: vec3<f32> = safeNormalize3_(cross(_e446.macroNormalWS, _e448.tangentWS), vec3<f32>(0f, 0f, 1f));
    waterSurface_bitangentWS = _e455;
    let _e457: Varyings = input_1;
    waterSurface_meshUv = _e457.atlasUv;
    let _e460: vec2<f32> = flowXZ;
    let _e461: vec2<f32> = waterLocalDirectionToWorldXZ(_e460);
    waterSurface_flowWS = _e461;
    let _e463: f32 = coverage;
    waterSurface_coverage = _e463;
    let _e465: f32 = authoredDepth;
    waterSurface_verticalDepth = _e465;
    let _e467: f32 = signedDistance;
    waterSurface_horizontalShoreDistance = _e467;
    let _e469: f32 = heightfieldObstacleContact;
    waterSurface_obstacleContact = _e469;
    let _e471: Varyings = input_1;
    waterSurface_waveCrest = max(_e471.waveOffset, 0f);
    let _e476: Varyings = input_1;
    let _e478: Varyings = input_1;
    let _e480: vec3<f32> = safeNormalize3_(_e476.macroNormalWS, _e478.macroNormalWS);
    surfaceNormalWS_2 = _e480;
    let _e487: vec3<f32> = baseWorldPosition;
    appearanceLayerCoordinate0_ = _e487.xz;
    let _e490: vec2<f32> = appearanceLayerCoordinate0_;
    let _e491: vec4<f32> = global.material_AppearanceV2Detail0Transform;
    appearanceLayerScaled0_ = (_e490 * _e491.xy);
    let _e495: vec2<f32> = appearanceLayerScaled0_;
    let _e497: vec2<f32> = global.material_AppearanceV2Detail0Rotation;
    let _e500: vec2<f32> = appearanceLayerScaled0_;
    let _e502: vec2<f32> = global.material_AppearanceV2Detail0Rotation;
    let _e506: vec2<f32> = appearanceLayerScaled0_;
    let _e508: vec2<f32> = global.material_AppearanceV2Detail0Rotation;
    let _e511: vec2<f32> = appearanceLayerScaled0_;
    let _e513: vec2<f32> = global.material_AppearanceV2Detail0Rotation;
    let _e518: vec4<f32> = global.material_AppearanceV2Detail0Transform;
    appearanceLayerUv0_ = (vec2<f32>(((_e495.x * _e497.x) - (_e500.y * _e502.y)), ((_e506.x * _e508.y) + (_e511.y * _e513.x))) + _e518.zw);
    let _e527: f32 = global.material_AppearanceV2Detail0Enabled;
    if (_e527 > 0.5f) {
        {
            let _e530: vec2<f32> = appearanceLayerUv0_;
            let _e531: vec4<f32> = textureSample(gs_wgpu_tex_material_AppearanceV2Detail0Texture, gs_wgpu_samp_material_AppearanceV2Detail0Texture, _e530);
            let _e532: f32 = global.material_AppearanceV2Detail0Strength;
            let _e534: vec3<f32> = waterSurfaceAppearanceDecodeTangentNormalPreserveSourceZ(_e531, _e532, 0f);
            appearanceLayerNormal0_ = _e534;
        }
    }
    let _e535: vec3<f32> = appearanceNormalTS;
    let _e536: vec3<f32> = appearanceLayerNormal0_;
    let _e537: vec3<f32> = waterSurfaceAppearanceBlendTangentNormalsPartialDerivative(_e535, _e536);
    appearanceNormalTS = _e537;
    let _e538: vec3<f32> = baseWorldPosition;
    appearanceLayerCoordinate1_ = _e538.xz;
    let _e541: vec2<f32> = appearanceLayerCoordinate1_;
    let _e542: vec4<f32> = global.material_AppearanceV2Detail1Transform;
    appearanceLayerScaled1_ = (_e541 * _e542.xy);
    let _e546: vec2<f32> = appearanceLayerScaled1_;
    let _e548: vec2<f32> = global.material_AppearanceV2Detail1Rotation;
    let _e551: vec2<f32> = appearanceLayerScaled1_;
    let _e553: vec2<f32> = global.material_AppearanceV2Detail1Rotation;
    let _e557: vec2<f32> = appearanceLayerScaled1_;
    let _e559: vec2<f32> = global.material_AppearanceV2Detail1Rotation;
    let _e562: vec2<f32> = appearanceLayerScaled1_;
    let _e564: vec2<f32> = global.material_AppearanceV2Detail1Rotation;
    let _e569: vec4<f32> = global.material_AppearanceV2Detail1Transform;
    appearanceLayerUv1_ = (vec2<f32>(((_e546.x * _e548.x) - (_e551.y * _e553.y)), ((_e557.x * _e559.y) + (_e562.y * _e564.x))) + _e569.zw);
    let _e578: f32 = global.material_AppearanceV2Detail1Enabled;
    if (_e578 > 0.5f) {
        {
            let _e581: vec2<f32> = appearanceLayerUv1_;
            let _e582: vec4<f32> = textureSample(gs_wgpu_tex_material_AppearanceV2Detail1Texture, gs_wgpu_samp_material_AppearanceV2Detail1Texture, _e581);
            let _e583: f32 = global.material_AppearanceV2Detail1Strength;
            let _e585: vec3<f32> = waterSurfaceAppearanceDecodeTangentNormalPreserveSourceZ(_e582, _e583, 0f);
            appearanceLayerNormal1_ = _e585;
        }
    }
    let _e586: vec3<f32> = appearanceNormalTS;
    let _e587: vec3<f32> = appearanceLayerNormal1_;
    let _e588: vec3<f32> = waterSurfaceAppearanceBlendTangentNormalsPartialDerivative(_e586, _e587);
    appearanceNormalTS = _e588;
    let _e593: vec3<f32> = appearanceNormalTS;
    let _e594: f32 = global.material_AppearanceV2DetailNormalStrength;
    appearanceNormalTS = normalize(mix(vec3<f32>(0f, 0f, 1f), _e593, vec3(_e594)));
    let _e598: Varyings = input_1;
    let _e600: Varyings = input_1;
    let _e602: Varyings = input_1;
    let _e604: Varyings = input_1;
    let _e613: vec3<f32> = safeNormalize3_((_e598.tangentWS - (_e600.macroNormalWS * dot(_e602.tangentWS, _e604.macroNormalWS))), vec3<f32>(1f, 0f, 0f));
    appearanceTangentWS = _e613;
    let _e615: Varyings = input_1;
    let _e617: vec3<f32> = appearanceTangentWS;
    let _e623: vec3<f32> = safeNormalize3_(cross(_e615.macroNormalWS, _e617), vec3<f32>(0f, 0f, 1f));
    appearanceBitangentWS = _e623;
    let _e625: vec3<f32> = appearanceTangentWS;
    let _e626: vec3<f32> = appearanceNormalTS;
    let _e629: vec3<f32> = appearanceBitangentWS;
    let _e630: vec3<f32> = appearanceNormalTS;
    let _e634: Varyings = input_1;
    let _e636: vec3<f32> = appearanceNormalTS;
    let _e640: Varyings = input_1;
    let _e642: vec3<f32> = safeNormalize3_((((_e625 * _e626.x) + (_e629 * _e630.y)) + (_e634.macroNormalWS * _e636.z)), _e640.macroNormalWS);
    appearanceSurfaceNormalWS = _e642;
    let _e644: vec3<f32> = surfaceNormalWS_2;
    let _e645: vec3<f32> = appearanceSurfaceNormalWS;
    let _e646: f32 = global.material_AppearanceV2DetailEnabled;
    let _e647: f32 = global.material_MicroNormalsEnabled;
    let _e651: Varyings = input_1;
    let _e653: vec3<f32> = safeNormalize3_(mix(_e644, _e645, vec3((_e646 * _e647))), _e651.macroNormalWS);
    surfaceNormalWS_2 = _e653;
    let _e654: Varyings = input_1;
    let _e657: vec3<f32> = surfaceNormalWS_2;
    let _e658: vec3<f32> = waterConnectionNormal(_e654.worldPosition.xz, _e657);
    surfaceNormalWS_2 = _e658;
    let _e659: vec4<f32> = global.scene_WeatherState;
    let _e664: f32 = global.material_MicroNormalsEnabled;
    rainRate = (clamp(_e659.x, 0f, 1f) * _e664);
    let _e671: f32 = rainRate;
    if (_e671 > 0.0001f) {
        {
            let _e674: Varyings = input_1;
            rainRippleUpwardCosine = clamp(_e674.macroNormalWS.y, 0f, 1f);
            let _e681: f32 = rainRippleUpwardCosine;
            let _e684: f32 = rainRippleUpwardCosine;
            rainRippleUpwardFade = (_e681 * smoothstep(0.2f, 0.55f, _e684));
            let _e688: vec3<f32> = global.camera_Position;
            let _e689: Varyings = input_1;
            rainRippleCameraDelta = (_e688 - _e689.worldPosition);
            let _e693: vec3<f32> = rainRippleCameraDelta;
            rainRippleHorizontalDistance = length(_e693.xz);
            let _e697: vec3<f32> = rainRippleCameraDelta;
            rainRippleVerticalDistance = abs(_e697.y);
            let _e701: f32 = rainRippleHorizontalDistance;
            let _e702: f32 = rainRippleVerticalDistance;
            rainRippleDistance = (_e701 + (_e702 * 0.25f));
            let _e710: f32 = rainRippleDistance;
            rainRippleDistanceFade = (1f - smoothstep(42f, 150f, _e710));
            let _e716: f32 = rainRate;
            rainRippleStormAmount = smoothstep(0.68f, 1f, _e716);
            let _e720: f32 = rainRippleStormAmount;
            rainRippleRingAmplitude = mix(0.82f, 1f, _e720);
            let _e723: f32 = rainRippleUpwardFade;
            let _e724: f32 = rainRippleDistanceFade;
            let _e726: f32 = rainRippleRingAmplitude;
            rainRippleContribution = ((_e723 * _e724) * _e726);
            let _e729: f32 = rainRippleContribution;
            if (_e729 > 0.001f) {
                {
                    let _e734: f32 = rainRate;
                    rainRipplePlaybackStrength = smoothstep(0.04f, 0.72f, _e734);
                    let _e739: f32 = rainRate;
                    rainRippleRainAmount = smoothstep(0.02f, 1f, _e739);
                    let _e742: vec3<f32> = baseWorldPosition;
                    let _e746: f32 = global.scene_WeatherTime;
                    let _e748: f32 = rainRipplePlaybackStrength;
                    let _e749: vec2<f32> = rainRippleField((_e742.xz * 0.68f), _e746, 0f, _e748);
                    rainRipplePrimarySample = _e749;
                    let _e751: vec2<f32> = rainRipplePrimarySample;
                    let _e752: f32 = rainRippleRainAmount;
                    let _e753: f32 = rainRippleDensityWeight(_e751, _e752);
                    rainRipplePrimaryDensity = _e753;
                    let _e755: vec2<f32> = rainRipplePrimarySample;
                    let _e757: f32 = rainRipplePrimaryDensity;
                    rainRippleSlope = (_e755 * (0.28f * _e757));
                    let _e761: vec2<f32> = rainRipplePrimarySample;
                    let _e763: f32 = rainRipplePrimaryDensity;
                    rainRippleRawMask = (length(_e761) * _e763);
                    let _e768: f32 = rainRate;
                    rainRippleSecondaryAmount = smoothstep(0.35f, 1f, _e768);
                    let _e771: f32 = rainRippleSecondaryAmount;
                    if (_e771 > 0f) {
                        {
                            let _e774: vec3<f32> = baseWorldPosition;
                            let _e778: vec3<f32> = baseWorldPosition;
                            let _e783: vec3<f32> = baseWorldPosition;
                            let _e787: vec3<f32> = baseWorldPosition;
                            rotatedRainRippleXZ = vec2<f32>(((_e774.x * 0.8f) - (_e778.z * 0.6f)), ((_e783.x * 0.6f) + (_e787.z * 0.8f)));
                            let _e794: vec2<f32> = rotatedRainRippleXZ;
                            let _e801: f32 = global.scene_WeatherTime;
                            let _e803: f32 = rainRipplePlaybackStrength;
                            let _e804: vec2<f32> = rainRippleField(((_e794 * 1.07f) + vec2<f32>(0.37f, 0.19f)), _e801, 23f, _e803);
                            rainRippleSecondarySample = _e804;
                            let _e806: vec2<f32> = rainRippleSecondarySample;
                            let _e807: f32 = rainRippleRainAmount;
                            let _e808: f32 = rainRippleDensityWeight(_e806, _e807);
                            rainRippleSecondaryDensity = _e808;
                            let _e810: f32 = rainRippleSecondaryDensity;
                            let _e811: f32 = rainRippleSecondaryAmount;
                            rainRippleSecondaryWeight = (_e810 * _e811);
                            let _e814: vec2<f32> = rainRippleSlope;
                            let _e815: vec2<f32> = rainRippleSecondarySample;
                            let _e817: f32 = rainRippleSecondaryWeight;
                            rainRippleSlope = (_e814 + (_e815 * (0.18f * _e817)));
                            let _e821: f32 = rainRippleRawMask;
                            let _e822: vec2<f32> = rainRippleSecondarySample;
                            let _e824: f32 = rainRippleSecondaryWeight;
                            rainRippleRawMask = max(_e821, (length(_e822) * _e824));
                        }
                    }
                    let _e829: f32 = rainRippleRawMask;
                    let _e831: f32 = rainRippleContribution;
                    rainRippleMask = (smoothstep(0.035f, 0.24f, _e829) * clamp(_e831, 0f, 1f));
                    let _e836: vec3<f32> = surfaceNormalWS_2;
                    let _e837: Varyings = input_1;
                    let _e839: vec2<f32> = rainRippleSlope;
                    let _e840: f32 = rainRippleContribution;
                    let _e842: vec3<f32> = rainRippleApplyNormal(_e836, _e837.macroNormalWS, (_e839 * _e840));
                    surfaceNormalWS_2 = _e842;
                }
            }
        }
    }
    let _e846: f32 = rainRippleStormAmount;
    rainRippleRoughnessResponse = mix(-0.018f, 0.08f, _e846);
    let _e849: f32 = global.material_Roughness;
    let _e852: f32 = global.material_Roughness;
    rainRippleRoughnessFloor = max((_e849 * 0.88f), (_e852 - 0.02f));
    let _e857: f32 = global.material_Roughness;
    let _e858: f32 = rainRippleMask;
    let _e859: f32 = rainRippleRoughnessResponse;
    let _e862: f32 = rainRippleRoughnessFloor;
    rainRippleSurfaceRoughness = clamp((_e857 + (_e858 * _e859)), _e862, 1f);
    let _e866: vec3<f32> = global.camera_Position;
    let _e867: Varyings = input_1;
    let _e870: Varyings = input_1;
    let _e872: vec3<f32> = safeNormalize3_((_e866 - _e867.worldPosition), _e870.baseNormalWS);
    viewDirection_2 = _e872;
    let _e875: vec3<f32> = surfaceNormalWS_2;
    let _e876: vec3<f32> = viewDirection_2;
    normalFacing = ((step(0f, dot(_e875, _e876)) * 2f) - 1f);
    let _e884: vec3<f32> = surfaceNormalWS_2;
    let _e885: f32 = normalFacing;
    surfaceNormalWS_2 = (_e884 * _e885);
    let _e887: vec3<f32> = surfaceNormalWS_2;
    let _e888: vec3<f32> = viewDirection_2;
    normalDotView_4 = clamp(dot(_e887, _e888), 0f, 1f);
    let _e896: vec3<f32> = viewDirection_2;
    let _e897: Varyings = input_1;
    localBathymetryProjectionDenominator = abs(dot(_e896, _e897.baseNormalWS));
    let _e901: f32 = authoredDepth;
    let _e902: f32 = localBathymetryProjectionDenominator;
    localSceneRayDepth = min((_e901 / max(_e902, 0.001f)), 1000000f);
    let _e909: f32 = sceneRayDepth;
    let _e910: f32 = localSceneRayDepth;
    bodyBoundedSceneRayDepth = min(_e909, _e910);
    let _e913: f32 = localSceneRayDepth;
    let _e914: f32 = bodyBoundedSceneRayDepth;
    let _e915: f32 = centeredSceneDepthAvailable;
    sceneRayDepth = mix(_e913, _e914, _e915);
    let _e917: f32 = sceneRayDepth;
    let _e918: f32 = sceneRayEyeScale;
    sceneDepthDelta_2 = (_e917 * _e918);
    let _e920: f32 = centeredDepthBehind;
    let _e922: f32 = centeredSceneDepthAvailable;
    let _e925: f32 = authoredDepth;
    centeredDepthBehind = max(_e920, ((1f - _e922) * step(0.000001f, _e925)));
    let _e929: f32 = sceneRayDepth;
    let _e930: f32 = global.material_MaximumSurfaceOpticalDistance;
    opticalDepth_8 = min(_e929, max(_e930, 0f));
    let _e934: f32 = global.material_FresnelF0_;
    fresnelF0_4 = clamp(_e934, 0f, 1f);
    let _e955: f32 = sceneDepthDelta_2;
    appearanceBoundaryField0_ = _e955;
    let _e957: f32 = appearanceBoundaryField0_;
    let _e958: f32 = global.material_AppearanceV2Boundary0Range;
    appearanceBoundaryRawNormalized0_ = (_e957 / max(_e958, 0.0001f));
    let _e963: f32 = appearanceBoundaryRawNormalized0_;
    appearanceBoundaryNormalized0_ = clamp(_e963, 0f, 1f);
    let _e968: f32 = appearanceBoundaryNormalized0_;
    appearanceBoundaryMask0_ = _e968;
    let _e970: f32 = appearanceBoundaryMask0_;
    appearanceBoundaryMask0_ = _e970;
    let _e971: f32 = appearanceBoundaryMask0_;
    appearanceBoundaryMask0_ = (_e971 * 1f);
    let _e974: f32 = appearanceCoastalAlpha;
    let _e975: f32 = appearanceBoundaryMask0_;
    let _e976: f32 = global.material_AppearanceV2Boundary0Alpha;
    appearanceCoastalAlpha = max(_e974, (_e975 * _e976));
    let _e979: f32 = sceneDepthDelta_2;
    appearanceBoundaryField1_ = _e979;
    let _e981: f32 = appearanceBoundaryField1_;
    let _e982: f32 = global.material_AppearanceV2Boundary1Range;
    appearanceBoundaryRawNormalized1_ = (_e981 / max(_e982, 0.0001f));
    let _e989: f32 = global.material_AppearanceV2Boundary1PatternOpacity;
    appearanceBoundaryGate1_ = (_e989 > 0.0001f);
    let _e993: bool = appearanceBoundaryGate1_;
    let _e994: f32 = global.material_AppearanceV2BoundaryMaterialEnabled;
    appearanceBoundaryGate1_ = (_e993 && (_e994 > 0.0001f));
    let _e998: bool = appearanceBoundaryGate1_;
    let _e999: f32 = centeredDepthBehind;
    appearanceBoundaryGate1_ = (_e998 && (_e999 > 0.0001f));
    let _e1003: bool = appearanceBoundaryGate1_;
    if _e1003 {
        {
            let _e1004: f32 = appearanceBoundaryRawNormalized1_;
            appearanceBoundaryRawNorm1_ = _e1004;
            let _e1006: f32 = global.material_AppearanceV2Boundary1PatternExponent;
            appearanceBoundaryPatternExp1_ = _e1006;
            let _e1008: f32 = appearanceBoundaryPatternExp1_;
            if (_e1008 == 0f) {
                {
                    let _e1012: f32 = appearanceBoundaryRawNorm1_;
                    let _e1017: f32 = global.material_AppearanceV2Boundary1PatternOpacity;
                    appearanceBoundaryMask1_ = (clamp((2f - _e1012), 0f, 1f) * _e1017);
                }
            } else {
                let _e1019: f32 = appearanceBoundaryPatternExp1_;
                if (_e1019 < 0f) {
                    {
                        let _e1022: f32 = appearanceBoundaryRawNorm1_;
                        if (_e1022 <= 1f) {
                            {
                                let _e1025: f32 = global.material_AppearanceV2Boundary1PatternOpacity;
                                appearanceBoundaryMask1_ = _e1025;
                            }
                        } else {
                            {
                                let _e1031: f32 = appearanceBoundaryRawNorm1_;
                                if (_e1031 > 2f) {
                                    {
                                        let _e1034: f32 = appearanceBoundaryRawNorm1_;
                                        let _e1038: f32 = appearanceBoundaryPatternExp1_;
                                        appearanceBoundaryBaseReq1_ = pow((_e1034 - 1f), (1f / _e1038));
                                        let _e1042: f32 = appearanceBoundaryBaseReq1_;
                                        if (_e1042 <= 0.0001f) {
                                            {
                                                appearanceBoundaryAlwaysZero1_ = true;
                                            }
                                        } else {
                                            {
                                                let _e1047: f32 = appearanceBoundaryBaseReq1_;
                                                appearanceBoundaryPMax1_ = (1f - _e1047);
                                            }
                                        }
                                    }
                                }
                                let _e1049: bool = appearanceBoundaryAlwaysZero1_;
                                if _e1049 {
                                    {
                                        appearanceBoundaryMask1_ = 0f;
                                    }
                                } else {
                                    {
                                        let _e1051: f32 = appearanceBoundaryPMax1_;
                                        if (_e1051 >= 0f) {
                                            let _e1054: Varyings = input_1;
                                            let _e1057: f32 = global.material_AppearanceV2Boundary1PatternTimeRate;
                                            let _e1058: f32 = global.material_AppearanceV2Boundary1PatternWorldScale;
                                            let _e1060: vec3<f32> = global.material_AppearanceV2Boundary1PatternWeights;
                                            let _e1061: f32 = global.material_AppearanceV2Boundary1PatternLacunarity;
                                            let _e1062: f32 = appearanceBoundaryPMax1_;
                                            let _e1063: f32 = evaluateWaterAnimatedVoronoiF1UpperBounded(_e1054.worldPosition.xz, _e1057, _e1058, 1f, _e1060, _e1061, _e1062);
                                            local_19 = _e1063;
                                        } else {
                                            let _e1064: Varyings = input_1;
                                            let _e1067: f32 = global.material_AppearanceV2Boundary1PatternTimeRate;
                                            let _e1068: f32 = global.material_AppearanceV2Boundary1PatternWorldScale;
                                            let _e1070: vec3<f32> = global.material_AppearanceV2Boundary1PatternWeights;
                                            let _e1071: f32 = global.material_AppearanceV2Boundary1PatternLacunarity;
                                            let _e1072: f32 = evaluateWaterAnimatedVoronoiF1_(_e1064.worldPosition.xz, _e1067, _e1068, 1f, _e1070, _e1071);
                                            local_19 = _e1072;
                                        }
                                        let _e1074: f32 = local_19;
                                        appearanceBoundaryPattern1_ = _e1074;
                                        let _e1077: f32 = appearanceBoundaryPattern1_;
                                        let _e1082: f32 = appearanceBoundaryPatternExp1_;
                                        appearanceBoundaryPatternResponse1_ = pow(max(abs((1f - _e1077)), 0.0001f), _e1082);
                                        let _e1086: f32 = appearanceBoundaryRawNorm1_;
                                        let _e1088: f32 = appearanceBoundaryPatternResponse1_;
                                        let _e1093: f32 = global.material_AppearanceV2Boundary1PatternOpacity;
                                        appearanceBoundaryMask1_ = (clamp(((1f - _e1086) + _e1088), 0f, 1f) * _e1093);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    {
                        let _e1095: f32 = appearanceBoundaryRawNorm1_;
                        if (_e1095 >= 2f) {
                            {
                                appearanceBoundaryMask1_ = 0f;
                            }
                        } else {
                            let _e1099: f32 = appearanceBoundaryRawNorm1_;
                            if (_e1099 <= 0f) {
                                {
                                    let _e1102: f32 = global.material_AppearanceV2Boundary1PatternOpacity;
                                    appearanceBoundaryMask1_ = _e1102;
                                }
                            } else {
                                {
                                    let _e1106: Varyings = input_1;
                                    let _e1109: f32 = global.material_AppearanceV2Boundary1PatternTimeRate;
                                    let _e1110: f32 = global.material_AppearanceV2Boundary1PatternWorldScale;
                                    let _e1112: vec3<f32> = global.material_AppearanceV2Boundary1PatternWeights;
                                    let _e1113: f32 = global.material_AppearanceV2Boundary1PatternLacunarity;
                                    let _e1114: f32 = evaluateWaterAnimatedVoronoiF1_(_e1106.worldPosition.xz, _e1109, _e1110, 1f, _e1112, _e1113);
                                    appearanceBoundaryPattern1_1 = _e1114;
                                    let _e1117: f32 = appearanceBoundaryPattern1_1;
                                    let _e1122: f32 = appearanceBoundaryPatternExp1_;
                                    appearanceBoundaryPatternResponse1_1 = pow(max(abs((1f - _e1117)), 0.0001f), _e1122);
                                    let _e1126: f32 = appearanceBoundaryRawNorm1_;
                                    let _e1128: f32 = appearanceBoundaryPatternResponse1_1;
                                    let _e1133: f32 = global.material_AppearanceV2Boundary1PatternOpacity;
                                    appearanceBoundaryMask1_ = (clamp(((1f - _e1126) + _e1128), 0f, 1f) * _e1133);
                                }
                            }
                        }
                    }
                }
            }
        }
    } else {
        {
            appearanceBoundaryMask1_ = 0f;
        }
    }
    let _e1136: f32 = appearanceBoundaryMask1_;
    let _e1137: f32 = centeredDepthBehind;
    appearanceBoundaryMask1_ = (_e1136 * _e1137);
    let _e1139: f32 = contactFoamMask;
    let _e1140: f32 = appearanceBoundaryMask1_;
    let _e1141: f32 = global.material_AppearanceV2BoundaryMaterialEnabled;
    contactFoamMask = max(_e1139, (_e1140 * _e1141));
    let _e1144: vec3<f32> = appearanceBoundaryColor;
    let _e1145: f32 = appearanceBoundaryMask1_;
    let _e1146: vec3<f32> = global.material_AppearanceV2Boundary1Color;
    let _e1148: f32 = global.material_AppearanceV2BoundaryMaterialEnabled;
    appearanceBoundaryColor = (_e1144 + ((_e1145 * _e1146) * _e1148));
    let _e1151: f32 = appearanceBoundaryRoughness;
    let _e1152: f32 = appearanceBoundaryMask1_;
    let _e1153: f32 = global.material_AppearanceV2Boundary1Roughness;
    let _e1155: f32 = global.material_AppearanceV2BoundaryMaterialEnabled;
    appearanceBoundaryRoughness = (_e1151 + ((_e1152 * _e1153) * _e1155));
    let _e1158: f32 = global.material_Roughness;
    let _e1159: f32 = appearanceBoundaryRoughness;
    effectiveSurfaceRoughness = clamp((_e1158 + _e1159), 0.045f, 1f);
    let _e1171: Varyings = input_1;
    let _e1173: vec3<f32> = surfaceNormalWS_2;
    let _e1174: vec3<f32> = viewDirection_2;
    let _e1175: f32 = normalDotView_4;
    let _e1176: f32 = fresnelF0_4;
    let _e1177: f32 = effectiveSurfaceRoughness;
    evaluateWaterSurfaceDirectionalLighting(_e1171.worldPosition, _e1173, _e1174, _e1175, _e1176, _e1177, 1f, (&directDiffuseRadiance_1), (&directSpecularRadiance_1));
    let _e1183: vec3<f32> = directSpecularRadiance_1;
    let _e1184: f32 = global.material_AppearanceDirectSpecularEnabled;
    directSpecularRadiance_1 = (_e1183 * _e1184);
    let _e1186: vec3<f32> = surfaceNormalWS_2;
    let _e1187: vec3<f32> = waterSurfaceAppearanceAmbientIrradiance(_e1186);
    ambientDiffuse = (_e1187 / vec3(3.1415927f));
    let _e1192: vec3<f32> = ambientDiffuse;
    let _e1193: vec3<f32> = directDiffuseRadiance_1;
    waterDiffuseLighting = max((_e1192 + _e1193), vec3(0f));
    let _e1199: f32 = global.material_Clarity;
    clarity_2 = clamp(_e1199, 0f, 1f);
    let _e1204: vec4<f32> = global.material_ShallowColor;
    waterColor = _e1204.xyz;
    let _e1207: vec3<f32> = waterColor;
    centeredOpaqueColor = _e1207;
    let _e1211: vec3<f32> = waterColor;
    displacedOpaqueColor = _e1211;
    let _e1225: f32 = global.material_RefractionEnabled;
    refractionFeatureWeight = (step(0.5f, _e1225) * 1f);
    let _e1230: mat4x4<f32> = global_1.camera_ViewMat;
    let _e1240: Varyings = input_1;
    baseNormalVS = normalize((mat3x3<f32>(_e1230[0].xyz, _e1230[1].xyz, _e1230[2].xyz) * _e1240.baseNormalWS));
    let _e1245: mat4x4<f32> = global_1.camera_ViewMat;
    let _e1255: vec3<f32> = surfaceNormalWS_2;
    surfaceNormalVS = normalize((mat3x3<f32>(_e1245[0].xyz, _e1245[1].xyz, _e1245[2].xyz) * _e1255));
    let _e1259: vec3<f32> = appearanceNormalTS;
    refractionNormalDelta = _e1259.xy;
    let _e1263: vec2<f32> = refractionNormalDelta;
    refractionNormalDelta.y = -(_e1263.y);
    let _e1268: f32 = opticalDepth_8;
    refractionDepthWeight = smoothstep(0.04f, 1.15f, _e1268);
    let _e1271: f32 = global_1.material_ShoreDampingWidth;
    let _e1274: f32 = signedDistance;
    fragmentShoreDamping = smoothstep(0f, max(_e1271, 0.0001f), _e1274);
    refractionShoreWeight = 1f;
    let _e1278: vec2<f32> = screenUv;
    let _e1279: vec2<f32> = refractionNormalDelta;
    let _e1280: f32 = global.material_AppearanceV2RefractionUvScale;
    let _e1282: f32 = refractionFeatureWeight;
    displacedScreenUv = (_e1278 + ((_e1279 * _e1280) * _e1282));
    let _e1287: vec2<f32> = displacedScreenUv;
    let _e1290: vec2<f32> = displacedScreenUv;
    let _e1296: vec2<f32> = displacedScreenUv;
    let _e1300: vec2<f32> = displacedScreenUv;
    refractionScreenInterior = (((step(0.002f, _e1287.x) * step(_e1290.x, 0.998f)) * step(0.002f, _e1296.y)) * step(_e1300.y, 0.998f));
    let _e1306: vec2<f32> = displacedScreenUv;
    refractedScreenUv = clamp(_e1306, vec2(0.002f), vec2(0.998f));
    let _e1313: vec2<f32> = refractedScreenUv;
    let _e1314: vec2<f32> = screenUv;
    refractionDepthDeltaUv = (_e1313 - _e1314);
    let _e1317: f32 = refractionScreenInterior;
    let _e1320: vec2<f32> = refractionDepthDeltaUv;
    let _e1321: vec2<f32> = refractionDepthDeltaUv;
    if ((_e1317 > 0.5f) && (dot(_e1320, _e1321) > 0.0000000001f)) {
        let _e1326: vec2<f32> = refractedScreenUv;
        let _e1327: vec4<f32> = textureSample(gs_wgpu_tex_camera_DepthTexture, gs_wgpu_samp_camera_DepthTexture, _e1326);
        local_20 = _e1327.x;
    } else {
        let _e1329: f32 = sceneDepthBufferSample;
        local_20 = _e1329;
    }
    let _e1331: f32 = local_20;
    refractedSceneDepthBufferSample = _e1331;
    let _e1333: f32 = refractedSceneDepthBufferSample;
    let _e1334: f32 = remapDepthBufferEyeDepth(_e1333);
    refractedSceneEyeDepthSample = _e1334;
    let _e1336: f32 = refractedSceneEyeDepthSample;
    let _e1339: f32 = refractedSceneEyeDepthSample;
    refractedSceneDepthFinite = ((_e1336 >= 0f) && (_e1339 <= 1000000f));
    let _e1344: bool = refractedSceneDepthFinite;
    let _e1345: f32 = refractedSceneDepthBufferSample;
    if (_e1344 && (_e1345 < 1f)) {
        local_21 = 1f;
    } else {
        local_21 = 0f;
    }
    let _e1352: f32 = local_21;
    refractedSceneDepthAvailable = _e1352;
    let _e1354: f32 = refractedSceneDepthAvailable;
    if (_e1354 > 0.5f) {
        let _e1357: f32 = refractedSceneEyeDepthSample;
        local_22 = _e1357;
    } else {
        let _e1358: Varyings = input_1;
        local_22 = _e1358.surfaceEyeDepth;
    }
    let _e1361: f32 = local_22;
    refractedSceneEyeDepth = _e1361;
    let _e1363: f32 = refractedSceneEyeDepth;
    let _e1364: Varyings = input_1;
    refractedOpticalDepth = max((_e1363 - _e1364.surfaceEyeDepth), 0f);
    refractionDepthContinuity = 1f;
    let _e1372: f32 = refractedSceneEyeDepth;
    let _e1373: Varyings = input_1;
    let _e1377: f32 = refractedSceneDepthAvailable;
    refractedGeometryBehindSurface = (step(0.000001f, (_e1372 - _e1373.surfaceEyeDepth)) * _e1377);
    let _e1380: f32 = coverage;
    let _e1382: f32 = authoredDepth;
    localRefractedGeometryBehindSurface = (_e1380 * step(0.000001f, _e1382));
    let _e1386: f32 = refractionScreenInterior;
    let _e1387: f32 = refractedGeometryBehindSurface;
    let _e1389: f32 = refractedSceneDepthAvailable;
    let _e1391: f32 = localRefractedGeometryBehindSurface;
    refractionSampleValidity = (_e1386 * max(_e1387, ((1f - _e1389) * _e1391)));
    let _e1395: vec2<f32> = refractedScreenUv;
    let _e1396: vec2<f32> = screenUv;
    refractionUvDelta = (_e1395 - _e1396);
    let _e1398: f32 = refractionSampleValidity;
    let _e1401: f32 = refractionFeatureWeight;
    if ((_e1398 > 0.9999f) && (_e1401 > 0.5f)) {
        {
            let _e1405: vec2<f32> = refractedScreenUv;
            let _e1406: vec4<f32> = textureSample(gs_wgpu_tex_camera_OpaqueTexture, gs_wgpu_samp_camera_OpaqueTexture, _e1405);
            displacedOpaqueColor = _e1406.xyz;
            let _e1408: vec3<f32> = displacedOpaqueColor;
            centeredOpaqueColor = _e1408;
            let _e1409: vec2<f32> = refractionUvDelta;
            let _e1410: vec2<f32> = refractionUvDelta;
            if (dot(_e1409, _e1410) <= 0.0000000001f) {
                {
                    centeredOpaqueSampled = true;
                }
            }
        }
    } else {
        {
            let _e1415: vec2<f32> = screenUv;
            let _e1416: vec4<f32> = textureSample(gs_wgpu_tex_camera_OpaqueTexture, gs_wgpu_samp_camera_OpaqueTexture, _e1415);
            centeredOpaqueColor = _e1416.xyz;
            centeredOpaqueSampled = true;
            let _e1419: f32 = refractionSampleValidity;
            if (_e1419 > 0.001f) {
                let _e1422: vec2<f32> = refractedScreenUv;
                let _e1423: vec4<f32> = textureSample(gs_wgpu_tex_camera_OpaqueTexture, gs_wgpu_samp_camera_OpaqueTexture, _e1422);
                local_23 = _e1423.xyz;
            } else {
                let _e1425: vec3<f32> = centeredOpaqueColor;
                local_23 = _e1425;
            }
            let _e1427: vec3<f32> = local_23;
            displacedOpaqueColor = _e1427;
        }
    }
    let _e1428: f32 = authoredDepth;
    let _e1429: f32 = global.material_AppearanceV2DepthDistance;
    let _e1430: f32 = global.material_AppearanceV2DepthExponent;
    let _e1431: f32 = waterSurfaceAppearanceDepthTintFactor(_e1428, _e1429, _e1430);
    appearanceDepthTintFactor = _e1431;
    let _e1433: vec4<f32> = global.material_AppearanceV2DepthColor;
    appearanceDepthTintColor = _e1433.xyz;
    let _e1436: vec3<f32> = appearanceDepthTintColor;
    let _e1438: f32 = appearanceBoundaryAlbedoWeight;
    let _e1441: vec3<f32> = appearanceBoundaryAlbedo;
    appearanceDepthTintColor = ((_e1436 * (1f - _e1438)) + _e1441);
    let _e1443: f32 = appearanceDepthTintFactor;
    let _e1444: f32 = appearanceBoundaryAlbedoWeight;
    appearanceDepthTintFactor = clamp((_e1443 + _e1444), 0f, 1f);
    let _e1464: bool = sampleEnvironmentReflection;
    if _e1464 {
        {
            let _e1465: vec3<f32> = viewDirection_2;
            let _e1467: vec3<f32> = surfaceNormalWS_2;
            let _e1469: Varyings = input_1;
            let _e1471: vec3<f32> = safeNormalize3_(reflect(-(_e1465), _e1467), _e1469.baseNormalWS);
            probeDirection = _e1471;
            let _e1473: vec3<f32> = surfaceNormalWS_2;
            let _e1475: f32 = effectiveSurfaceRoughness;
            let _e1476: WaterSurfaceEnvironmentLight = scene_EnvMapLight;
            let _e1478: vec3<f32> = waterSurfaceResolveAnalyticReflectionFallbackV2_(_e1473.y, _e1475, _e1476.specularIntensity);
            rawAnalyticReflectionSample = _e1478;
            let _e1479: vec3<f32> = probeDirection;
            let _e1480: Varyings = input_1;
            let _e1482: f32 = effectiveSurfaceRoughness;
            waterSurfaceSampleRawEnvironmentReflectionV2_(_e1479, _e1480.worldPosition, _e1482, (&rawEnvironmentReflectionSample), (&rawEnvironmentReflectionValidity));
        }
    }
    let _e1487: f32 = global.material_ReflectionIntensity;
    reflectionIntensity = max(_e1487, 0f);
    let _e1493: vec3<f32> = centeredOpaqueColor;
    rawRefractionFacts.centeredSceneSample = _e1493;
    let _e1495: vec3<f32> = displacedOpaqueColor;
    rawRefractionFacts.displacedSceneSample = _e1495;
    let _e1497: f32 = refractionSampleValidity;
    rawRefractionFacts.displacedSampleValidity = _e1497;
    let _e1499: f32 = refractionDepthWeight;
    rawRefractionFacts.depthWeight = _e1499;
    let _e1501: f32 = refractionShoreWeight;
    rawRefractionFacts.shoreValidity = _e1501;
    let _e1503: f32 = coverage;
    rawRefractionFacts.coverage = _e1503;
    let _e1506: vec3<f32> = rawAnalyticReflectionSample;
    rawReflectionFacts.analyticSample = _e1506;
    let _e1508: vec3<f32> = rawEnvironmentReflectionSample;
    rawReflectionFacts.environmentSample = _e1508;
    let _e1510: f32 = rawEnvironmentReflectionValidity;
    rawReflectionFacts.environmentValidity = _e1510;
    let _e1512: vec3<f32> = rawSsrReflectionPremultipliedSample;
    rawReflectionFacts.ssrPremultipliedSample = _e1512;
    let _e1514: f32 = rawSsrReflectionValidity;
    rawReflectionFacts.ssrValidity = _e1514;
    rawContributionPolicy.primaryColorClosureModel = 2f;
    let _e1520: f32 = global.material_RefractionEnabled;
    rawContributionPolicy.refractionEnabled = (step(0.5f, _e1520) * 1f);
    let _e1525: f32 = clarity_2;
    rawContributionPolicy.clarity = _e1525;
    let _e1527: f32 = appearanceBoundaryRefractionSuppression;
    rawContributionPolicy.boundaryRefractionSuppression = _e1527;
    let _e1529: f32 = global.material_ReflectionSource;
    rawContributionPolicy.reflectionSource = _e1529;
    let _e1531: f32 = global.material_WaterScreenSpaceReflectionCompositeIntensity;
    rawContributionPolicy.ssrCompositeIntensity = _e1531;
    let _e1532: WaterSurfaceRawRefractionFactsV2_ = rawRefractionFacts;
    let _e1533: WaterSurfaceRawReflectionFactsV2_ = rawReflectionFacts;
    let _e1534: f32 = contactFoamMask;
    let _e1535: WaterSurfaceRawContributionPolicyV2_ = rawContributionPolicy;
    let _e1536: WaterSurfaceResolvedRawContributionsV2_ = waterSurfaceResolveRawContributionsV2_(_e1532, _e1533, _e1534, _e1535);
    resolvedContributions = _e1536;
    let _e1540: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
    closureInput.primarySceneColor = _e1540.refractionSceneColor;
    let _e1543: vec4<f32> = global.material_ShallowColor;
    closureInput.surfaceColor = _e1543.xyz;
    let _e1546: vec3<f32> = appearanceDepthTintColor;
    closureInput.depthColor = _e1546;
    let _e1548: f32 = appearanceDepthTintFactor;
    let _e1549: f32 = global.material_AppearanceV2DepthResponseEnabled;
    closureInput.depthFactor = (_e1548 * _e1549);
    let _e1552: vec3<f32> = waterDiffuseLighting;
    closureInput.diffuseLighting = _e1552;
    closureInput.primaryColorClosureModel = 2f;
    let _e1556: vec3<f32> = global.material_AbsorptionCoefficient;
    closureInput.absorptionCoefficient = _e1556;
    let _e1558: vec3<f32> = global.material_ScatteringColor;
    closureInput.scatteringColor = _e1558;
    let _e1560: f32 = global.material_ScatteringCoefficient;
    closureInput.scatteringCoefficient = _e1560;
    let _e1562: f32 = opticalDepth_8;
    closureInput.opticalDepth = _e1562;
    let _e1564: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
    closureInput.refractionColor = _e1564.refractionSceneColor;
    let _e1567: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
    closureInput.refractionWeight = _e1567.refractionWeight;
    let _e1570: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
    closureInput.reflectionRadiance = _e1570.reflectionRadiance;
    let _e1573: f32 = fresnelF0_4;
    closureInput.fresnelF0_ = _e1573;
    let _e1575: f32 = effectiveSurfaceRoughness;
    closureInput.perceptualRoughness = _e1575;
    let _e1577: f32 = normalDotView_4;
    closureInput.normalDotView = _e1577;
    closureInput.transmissionFresnelWeight = 1f;
    let _e1581: f32 = reflectionIntensity;
    closureInput.reflectionIntensity = _e1581;
    let _e1583: vec3<f32> = directSpecularRadiance_1;
    closureInput.directSpecularRadiance = _e1583;
    let _e1585: vec3<f32> = appearanceBoundaryColor;
    closureInput.boundaryColor = _e1585;
    let _e1587: vec3<f32> = appearanceBoundaryColor;
    let _e1588: f32 = contactFoamMask;
    closureInput.foamColor = (_e1587 / vec3(max(_e1588, 0.0001f)));
    let _e1594: WaterSurfaceResolvedRawContributionsV2_ = resolvedContributions;
    closureInput.foamWeight = _e1594.foamWeight;
    let _e1597: f32 = global.material_Alpha;
    closureInput.baseAlpha = _e1597;
    let _e1599: f32 = clarity_2;
    closureInput.clarity = _e1599;
    let _e1601: f32 = appearanceCoastalAlpha;
    closureInput.coastalAlpha = _e1601;
    let _e1603: f32 = global.material_AppearanceV2BoundaryAlphaEnabled;
    closureInput.coastalAlphaWeight = _e1603;
    let _e1605: f32 = coverage;
    closureInput.coverage = _e1605;
    closureInput.precomposedReplace = 1f;
    let _e1608: bool = centeredOpaqueSampled;
    let _e1610: WaterSurfaceFinalClosureV2Input = closureInput;
    let _e1615: WaterSurfaceFinalClosureV2Input = closureInput;
    let _e1619: WaterSurfaceFinalClosureV2Input = closureInput;
    let _e1624: WaterSurfaceFinalClosureV2Input = closureInput;
    if ((!(_e1608) && (_e1610.precomposedReplace > 0.5f)) && !((((_e1615.coastalAlphaWeight >= 0.9999f) && (_e1619.coastalAlpha >= 0.9999f)) && (_e1624.coverage >= 0.9999f)))) {
        {
            let _e1631: vec2<f32> = screenUv;
            let _e1632: vec4<f32> = textureSample(gs_wgpu_tex_camera_OpaqueTexture, gs_wgpu_samp_camera_OpaqueTexture, _e1631);
            centeredOpaqueColor = _e1632.xyz;
            centeredOpaqueSampled = true;
        }
    }
    let _e1636: vec3<f32> = centeredOpaqueColor;
    closureInput.compositionSceneColor = _e1636;
    let _e1637: WaterSurfaceFinalClosureV2Input = closureInput;
    let _e1639: vec4<f32> = waterSurfaceEvaluateFinalClosureV2_1(_e1637, 0f);
    resolvedWaterClosure = _e1639;
    let _e1641: vec4<f32> = resolvedWaterClosure;
    shaderCompositedColor = _e1641.xyz;
    let _e1644: vec4<f32> = resolvedWaterClosure;
    surfaceAlpha = _e1644.w;
    let _e1647: vec3<f32> = shaderCompositedColor;
    fragmentColor = _e1647;
    let _e1649: f32 = surfaceAlpha;
    fragmentAlpha = _e1649;
    let _e1651: bool = precomposedReplace_2;
    if _e1651 {
        {
            fragmentAlpha = 1f;
        }
    }
    let _e1653: vec3<f32> = fragmentColor;
    let _e1654: f32 = fragmentAlpha;
    let _e1659: vec4<f32> = waterSurfaceOutputWithPick(vec4<f32>(_e1653.x, _e1653.y, _e1653.z, _e1654));
    output_color = _e1659;
    return;
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
    let _e188: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e194: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e200: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e188.x), bitcast<f32>(_e194.y), bitcast<f32>(_e200.z));
    let _e208: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e208.w);
    let _e215: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e215.x);
    let _e222: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e222.y);
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) worldPosition: vec3<f32>, @location(3) baseNormalWS: vec3<f32>, @location(4) macroNormalWS: vec3<f32>, @location(5) tangentWS: vec3<f32>, @location(6) atlasUv: vec2<f32>, @location(7) waveOffset: f32, @location(8) surfaceEyeDepth: f32, @location(10) clipPosition: vec4<f32>) -> FragmentOutput {
    worldPosition_1 = worldPosition;
    baseNormalWS_1 = baseNormalWS;
    macroNormalWS_7 = macroNormalWS;
    tangentWS_1 = tangentWS;
    atlasUv_1 = atlasUv;
    waveOffset_1 = waveOffset;
    surfaceEyeDepth_5 = surfaceEyeDepth;
    clipPosition_1 = clipPosition;
    main_1();
    let _e232: vec4<f32> = output_color;
    return FragmentOutput(_e232);
}
