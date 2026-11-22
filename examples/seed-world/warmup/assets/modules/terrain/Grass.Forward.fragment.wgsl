diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ProjectionParams: vec4<f32>,
    camera_ViewMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    scene_GrassSeasonColor: vec4<f32>,
    scene_TreeLeafSeasonColor: vec4<f32>,
    scene_TreeBarkSeasonColor: vec4<f32>,
    renderer_GrassColorFieldTransform: vec4<f32>,
    renderer_GrassColorFieldOffset: vec4<f32>,
    renderer_GrassColorFieldParams: vec4<f32>,
    renderer_GrassColorA: vec4<f32>,
    renderer_GrassColorB: vec4<f32>,
    renderer_RoadColorFieldA: vec4<f32>,
    renderer_RoadColorFieldB: vec4<f32>,
    renderer_RoadColorFieldRemap: vec4<f32>,
    renderer_GrassColorFieldVistaBlend: vec2<f32>,
    renderer_GrassColorOverrideA: vec4<f32>,
    renderer_GrassColorOverrideB: vec4<f32>,
    scene_SurfaceClimate: vec4<f32>,
    material_GrassSurfaceSnowResponse: vec4<f32>,
    camera_SurfaceReliefBakedDomain: vec4<f32>,
    camera_SurfaceReliefDomain: vec4<f32>,
    camera_SurfaceReliefOptions: vec4<f32>,
    scene_GroundWindShape: vec4<f32>,
    scene_GroundWindAdvection: vec4<f32>,
}

struct gs_Auto_1_ {
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    renderer_NormalMat: mat4x4<f32>,
    material_GrassDistanceFadeEnable: f32,
    material_GrassFadeDistance: f32,
    material_GrassFalloff: f32,
    scene_GroundWindWave: vec4<f32>,
    scene_GroundWindMotion: vec4<f32>,
    camera_DepthBufferParams: vec4<f32>,
    camera_Forward: vec3<f32>,
    renderer_Layer: vec4<i32>,
    scene_SurfaceSnowColor: vec4<f32>,
    material_GrassGroundColor: vec4<f32>,
    renderer_GrassRoadColor: vec4<f32>,
    renderer_GrassLodDebugColor: vec4<f32>,
}

struct Varyings {
    rootPositionWS: vec3<f32>,
    terrainNormalWS: vec3<f32>,
    positionWS: vec3<f32>,
    grassColor: vec3<f32>,
    surfaceWeights: vec3<f32>,
    tipWeight: f32,
    windCarrierNormalWS: vec3<f32>,
    windBentNormalWS: vec3<f32>,
    positionCS: vec4<f32>,
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
    @location(0) converted_FragColor: vec4<f32>,
}

const TERRAIN_PROJECT_GRASS_ROOT_FUSION_HEIGHT: f32 = 0.75f;
const TERRAIN_PROJECT_GRASS_BLADE_APPEARANCE_HEIGHT: f32 = 1f;

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> converted_FragColor: vec4<f32>;
var<private> rootPositionWS_1: vec3<f32>;
var<private> terrainNormalWS_1: vec3<f32>;
var<private> positionWS_3: vec3<f32>;
var<private> grassColor_1: vec3<f32>;
var<private> surfaceWeights_2: vec3<f32>;
var<private> tipWeight_5: f32;
var<private> windCarrierNormalWS_1: vec3<f32>;
var<private> windBentNormalWS_1: vec3<f32>;
var<private> positionCS_1: vec4<f32>;
@group(2) @binding(2) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;
@group(3) @binding(0) 
var gs_wgpu_tex_renderer_GrassColorFieldTexture: texture_2d<f32>;
@group(3) @binding(1) 
var gs_wgpu_samp_renderer_GrassColorFieldTexture: sampler;
@group(1) @binding(0) 
var gs_wgpu_tex_camera_SurfaceReliefHeightTexture: texture_2d<f32>;
@group(1) @binding(1) 
var gs_wgpu_samp_camera_SurfaceReliefHeightTexture: sampler;
@group(1) @binding(2) 
var gs_wgpu_tex_camera_SurfaceReliefMaskTexture: texture_2d<f32>;
@group(1) @binding(3) 
var gs_wgpu_samp_camera_SurfaceReliefMaskTexture: sampler;
@group(1) @binding(4) 
var gs_wgpu_tex_camera_SurfaceReliefBakedNormal: texture_2d<f32>;
@group(1) @binding(5) 
var gs_wgpu_samp_camera_SurfaceReliefBakedNormal: sampler;

fn pow2_(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e81: f32 = x_1;
    let _e82: f32 = x_1;
    return (_e81 * _e82);
}

fn remapDepthBufferEyeDepth(depth: f32) -> f32 {
    var depth_1: f32;

    depth_1 = depth;
    let _e82: vec4<f32> = global_1.camera_DepthBufferParams;
    let _e84: f32 = depth_1;
    let _e86: vec4<f32> = global_1.camera_DepthBufferParams;
    return (1f / ((_e82.z * _e84) + _e86.w));
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e90: vec3<f32> = rootPositionWS_1;
    interface_value.rootPositionWS = _e90;
    let _e92: vec3<f32> = terrainNormalWS_1;
    interface_value.terrainNormalWS = _e92;
    let _e94: vec3<f32> = positionWS_3;
    interface_value.positionWS = _e94;
    let _e96: vec3<f32> = grassColor_1;
    interface_value.grassColor = _e96;
    let _e98: vec3<f32> = surfaceWeights_2;
    interface_value.surfaceWeights = _e98;
    let _e100: f32 = tipWeight_5;
    interface_value.tipWeight = _e100;
    let _e102: vec3<f32> = windCarrierNormalWS_1;
    interface_value.windCarrierNormalWS = _e102;
    let _e104: vec3<f32> = windBentNormalWS_1;
    interface_value.windBentNormalWS = _e104;
    let _e106: vec4<f32> = positionCS_1;
    interface_value.positionCS = _e106;
    let _e107: Varyings = interface_value;
    return _e107;
}

fn sampleVolumetricCloudShadow(positionWS_1: vec3<f32>) -> f32 {
    var positionWS_2: vec3<f32>;

    positionWS_2 = positionWS_1;
    return 1f;
}

fn sampleTerrainProjectShadow(varyings: Varyings) -> f32 {
    var varyings_1: Varyings;
    var attenuation: f32 = 1f;

    varyings_1 = varyings;
    let _e92: f32 = attenuation;
    let _e93: Varyings = varyings_1;
    let _e95: f32 = sampleVolumetricCloudShadow(_e93.positionWS);
    return (_e92 * _e95);
}

fn getAARoughnessFactor(normal: vec3<f32>) -> f32 {
    var normal_1: vec3<f32>;
    var dxy: vec3<f32>;

    normal_1 = normal;
    let _e90: vec3<f32> = normal_1;
    let _e91: vec3<f32> = dpdx(_e90);
    let _e93: vec3<f32> = normal_1;
    let _e94: vec3<f32> = dpdy(_e93);
    dxy = max(abs(_e91), abs(-(_e94)));
    let _e99: vec3<f32> = dxy;
    let _e101: vec3<f32> = dxy;
    let _e104: vec3<f32> = dxy;
    return max(max(_e99.x, _e101.y), _e104.z);
}

fn F_Schlick(f0_: f32, f90_: f32, dotLH: f32) -> f32 {
    var f0_1: f32;
    var f90_1: f32;
    var dotLH_1: f32;

    f0_1 = f0_;
    f90_1 = f90_;
    dotLH_1 = dotLH;
    let _e94: f32 = f0_1;
    let _e95: f32 = f90_1;
    let _e96: f32 = f0_1;
    let _e99: f32 = dotLH_1;
    return (_e94 + ((_e95 - _e96) * pow((1f - _e99), 5f)));
}

fn F_Schlick_1(f0_2: vec3<f32>, f90_2: f32, dotLH_2: f32) -> vec3<f32> {
    var f0_3: vec3<f32>;
    var f90_3: f32;
    var dotLH_3: f32;
    var fresnel: f32;

    f0_3 = f0_2;
    f90_3 = f90_2;
    dotLH_3 = dotLH_2;
    let _e96: f32 = dotLH_3;
    let _e100: f32 = dotLH_3;
    fresnel = exp2((((-5.55473f * _e96) - 6.98316f) * _e100));
    let _e104: f32 = f90_3;
    let _e105: vec3<f32> = f0_3;
    let _e108: f32 = fresnel;
    let _e110: vec3<f32> = f0_3;
    return (((vec3(_e104) - _e105) * _e108) + _e110);
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
    let _e94: f32 = alpha_1;
    let _e95: f32 = pow2_(_e94);
    a2_ = _e95;
    let _e97: f32 = dotNL_1;
    let _e98: f32 = a2_;
    let _e100: f32 = a2_;
    let _e102: f32 = dotNV_1;
    let _e103: f32 = pow2_(_e102);
    gv = (_e97 * sqrt((_e98 + ((1f - _e100) * _e103))));
    let _e109: f32 = dotNV_1;
    let _e110: f32 = a2_;
    let _e112: f32 = a2_;
    let _e114: f32 = dotNL_1;
    let _e115: f32 = pow2_(_e114);
    gl = (_e109 * sqrt((_e110 + ((1f - _e112) * _e115))));
    let _e122: f32 = gv;
    let _e123: f32 = gl;
    return (0.5f / max((_e122 + _e123), 0.000001f));
}

fn D_GGX(alpha_2: f32, dotNH: f32) -> f32 {
    var alpha_3: f32;
    var dotNH_1: f32;
    var a2_1: f32;
    var denom: f32;

    alpha_3 = alpha_2;
    dotNH_1 = dotNH;
    let _e92: f32 = alpha_3;
    let _e93: f32 = pow2_(_e92);
    a2_1 = _e93;
    let _e95: f32 = dotNH_1;
    let _e96: f32 = pow2_(_e95);
    let _e97: f32 = a2_1;
    denom = ((_e96 * (_e97 - 1f)) + 1f);
    let _e105: f32 = a2_1;
    let _e107: f32 = denom;
    let _e108: f32 = pow2_(_e107);
    return ((0.31830987f * _e105) / _e108);
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
    let _e96: f32 = alpha_5;
    let _e97: f32 = dotNH_3;
    let _e98: f32 = D_GGX(_e96, _e97);
    D = _e98;
    let _e100: f32 = alpha_5;
    let _e101: f32 = dotNL_3;
    let _e102: f32 = dotNV_3;
    let _e103: f32 = G_GGX_SmithCorrelated(_e100, _e101, _e102);
    G = _e103;
    let _e105: f32 = G;
    let _e106: f32 = D;
    return (_e105 * _e106);
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
    let _e100: f32 = roughness_1;
    let _e101: f32 = pow2_(_e100);
    alpha_6 = _e101;
    let _e103: vec3<f32> = incidentDirection_1;
    let _e104: SurfaceData = surfaceData_1;
    halfDir = normalize((_e103 + _e104.viewDir));
    let _e109: vec3<f32> = normal_3;
    let _e110: vec3<f32> = incidentDirection_1;
    dotNL_4 = clamp(dot(_e109, _e110), 0f, 1f);
    let _e116: vec3<f32> = normal_3;
    let _e117: SurfaceData = surfaceData_1;
    dotNV_4 = clamp(dot(_e116, _e117.viewDir), 0f, 1f);
    let _e124: vec3<f32> = normal_3;
    let _e125: vec3<f32> = halfDir;
    dotNH_4 = clamp(dot(_e124, _e125), 0f, 1f);
    let _e131: vec3<f32> = incidentDirection_1;
    let _e132: vec3<f32> = halfDir;
    dotLH_4 = clamp(dot(_e131, _e132), 0f, 1f);
    let _e138: vec3<f32> = specularColor_1;
    let _e139: BSDFData = bsdfData_1;
    let _e141: f32 = dotLH_4;
    let _e142: vec3<f32> = F_Schlick_1(_e138, _e139.specularF90_, _e141);
    F = _e142;
    let _e144: f32 = alpha_6;
    let _e145: f32 = dotNV_4;
    let _e146: f32 = dotNL_4;
    let _e147: f32 = dotNH_4;
    let _e148: f32 = DG_GGX(_e144, _e145, _e146, _e147);
    GD = _e148;
    let _e150: vec3<f32> = F;
    let _e151: f32 = GD;
    return (_e150 * _e151);
}

fn BRDF_Diffuse_Lambert(diffuseColor: vec3<f32>) -> vec3<f32> {
    var diffuseColor_1: vec3<f32>;

    diffuseColor_1 = diffuseColor;
    let _e91: vec3<f32> = diffuseColor_1;
    return (0.31830987f * _e91);
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
    let _e110: f32 = roughness_3;
    let _e111: vec4<f32> = c0_;
    let _e113: vec4<f32> = c1_;
    r = ((_e110 * _e111) + _e113);
    let _e116: vec4<f32> = r;
    let _e118: vec4<f32> = r;
    let _e123: f32 = dotNV_6;
    let _e127: vec4<f32> = r;
    let _e130: vec4<f32> = r;
    a004_ = ((min((_e116.x * _e118.x), exp2((-9.28f * _e123))) * _e127.x) + _e130.y);
    let _e138: f32 = a004_;
    let _e140: vec4<f32> = r;
    return ((vec2<f32>(-1.04f, 1.04f) * _e138) + _e140.zw);
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
    let _e96: f32 = roughness_5;
    let _e97: f32 = dotNV_8;
    let _e98: vec2<f32> = envDFGApprox(_e96, _e97);
    AB = _e98;
    let _e100: vec3<f32> = f0_5;
    let _e101: vec2<f32> = AB;
    let _e104: f32 = f90_5;
    let _e105: vec2<f32> = AB;
    return ((_e100 * _e101.x) + vec3((_e104 * _e105.y)));
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
    let _e91: SurfaceData = surfaceData_3;
    albedoColor = _e91.albedoColor;
    let _e94: SurfaceData = surfaceData_3;
    metallic = _e94.metallic;
    let _e97: SurfaceData = surfaceData_3;
    roughness_6 = _e97.roughness;
    let _e100: SurfaceData = surfaceData_3;
    let _e104: SurfaceData = surfaceData_3;
    let _e109: f32 = pow2_(((_e100.IOR - 1f) / (_e104.IOR + 1f)));
    dielectricBaseF0_ = vec3(_e109);
    let _e112: vec3<f32> = dielectricBaseF0_;
    let _e113: SurfaceData = surfaceData_3;
    let _e119: SurfaceData = surfaceData_3;
    dielectricF0_ = (min((_e112 * _e113.specularColor), vec3(1f)) * _e119.specularIntensity);
    let _e123: SurfaceData = surfaceData_3;
    dielectricF90_ = _e123.specularIntensity;
    let _e127: vec3<f32> = dielectricF0_;
    let _e128: vec3<f32> = albedoColor;
    let _e129: f32 = metallic;
    (*bsdfData_2).specularF0_ = mix(_e127, _e128, vec3(_e129));
    let _e133: f32 = dielectricF90_;
    let _e135: f32 = metallic;
    (*bsdfData_2).specularF90_ = mix(_e133, 1f, _e135);
    let _e138: vec3<f32> = albedoColor;
    let _e140: f32 = metallic;
    let _e144: vec3<f32> = dielectricF0_;
    let _e146: vec3<f32> = dielectricF0_;
    let _e149: vec3<f32> = dielectricF0_;
    (*bsdfData_2).diffuseColor = ((_e138 * (1f - _e140)) * (1f - max(max(_e144.x, _e146.y), _e149.z)));
    let _e156: f32 = roughness_6;
    let _e157: SurfaceData = surfaceData_3;
    let _e159: f32 = getAARoughnessFactor(_e157.normal);
    (*bsdfData_2).roughness = max(0.045f, min((_e156 + _e159), 1f));
    let _e165: BSDFData = (*bsdfData_2);
    (*bsdfData_2).resolvedSpecularF0_ = _e165.specularF0_;
    let _e167: BSDFData = (*bsdfData_2);
    let _e169: SurfaceData = surfaceData_3;
    let _e171: vec2<f32> = envDFGApprox(_e167.roughness, _e169.dotNV);
    dfg = _e171;
    let _e174: BSDFData = (*bsdfData_2);
    let _e176: vec2<f32> = dfg;
    let _e179: BSDFData = (*bsdfData_2);
    let _e181: vec2<f32> = dfg;
    (*bsdfData_2).envSpecularDFG = ((_e174.resolvedSpecularF0_ * _e176.x) + vec3((_e179.specularF90_ * _e181.y)));
    let _e188: BSDFData = (*bsdfData_2);
    let _e191: vec2<f32> = dfg;
    let _e193: vec2<f32> = dfg;
    (*bsdfData_2).energyCompensation = (vec3(1f) + (_e188.resolvedSpecularF0_ * ((1f / max((_e191.x + _e193.y), 0.000001f)) - 1f)));
    let _e205: SurfaceData = surfaceData_3;
    (*bsdfData_2).diffuseAO = _e205.ambientOcclusion;
    return;
}

fn isRendererCulledByLight(rendererLayer: vec2<i32>, lightCullingMask: vec2<i32>) -> bool {
    var rendererLayer_1: vec2<i32>;
    var lightCullingMask_1: vec2<i32>;

    rendererLayer_1 = rendererLayer;
    lightCullingMask_1 = lightCullingMask;
    let _e92: vec2<i32> = rendererLayer_1;
    let _e94: vec2<i32> = lightCullingMask_1;
    let _e99: vec2<i32> = rendererLayer_1;
    let _e101: vec2<i32> = lightCullingMask_1;
    return !((((_e92.x & _e94.x) != 0i) || ((_e99.y & _e101.y) != 0i)));
}

fn diffuseLobe(varyings_2: Varyings, surfaceData_4: SurfaceData, bsdfData_3: BSDFData, attenuationIrradiance: vec3<f32>, diffuseColor_2: ptr<function, vec3<f32>>) {
    var varyings_3: Varyings;
    var surfaceData_5: SurfaceData;
    var bsdfData_4: BSDFData;
    var attenuationIrradiance_1: vec3<f32>;

    varyings_3 = varyings_2;
    surfaceData_5 = surfaceData_4;
    bsdfData_4 = bsdfData_3;
    attenuationIrradiance_1 = attenuationIrradiance;
    let _e101: vec3<f32> = (*diffuseColor_2);
    let _e102: vec3<f32> = attenuationIrradiance_1;
    let _e103: BSDFData = bsdfData_4;
    let _e105: vec3<f32> = BRDF_Diffuse_Lambert(_e103.diffuseColor);
    (*diffuseColor_2) = (_e101 + (_e102 * _e105));
    return;
}

fn specularLobe(varyings_4: Varyings, surfaceData_6: SurfaceData, bsdfData_5: BSDFData, incidentDirection_2: vec3<f32>, attenuationIrradiance_2: vec3<f32>, specularColor_2: ptr<function, vec3<f32>>) {
    var varyings_5: Varyings;
    var surfaceData_7: SurfaceData;
    var bsdfData_6: BSDFData;
    var incidentDirection_3: vec3<f32>;
    var attenuationIrradiance_3: vec3<f32>;

    varyings_5 = varyings_4;
    surfaceData_7 = surfaceData_6;
    bsdfData_6 = bsdfData_5;
    incidentDirection_3 = incidentDirection_2;
    attenuationIrradiance_3 = attenuationIrradiance_2;
    let _e103: vec3<f32> = (*specularColor_2);
    let _e104: vec3<f32> = attenuationIrradiance_3;
    let _e105: vec3<f32> = incidentDirection_3;
    let _e106: SurfaceData = surfaceData_7;
    let _e107: BSDFData = bsdfData_6;
    let _e108: SurfaceData = surfaceData_7;
    let _e110: BSDFData = bsdfData_6;
    let _e112: BSDFData = bsdfData_6;
    let _e114: vec3<f32> = BRDF_Specular_GGX(_e105, _e106, _e107, _e108.normal, _e110.specularF0_, _e112.roughness);
    let _e116: BSDFData = bsdfData_6;
    (*specularColor_2) = (_e103 + ((_e104 * _e114) * _e116.energyCompensation));
    return;
}

fn sheenLobe(varyings_6: Varyings, surfaceData_8: SurfaceData, bsdfData_7: BSDFData, incidentDirection_4: vec3<f32>, attenuationIrradiance_4: vec3<f32>, diffuseColor_3: ptr<function, vec3<f32>>, specularColor_3: ptr<function, vec3<f32>>) {
    var varyings_7: Varyings;
    var surfaceData_9: SurfaceData;
    var bsdfData_8: BSDFData;
    var incidentDirection_5: vec3<f32>;
    var attenuationIrradiance_5: vec3<f32>;

    varyings_7 = varyings_6;
    surfaceData_9 = surfaceData_8;
    bsdfData_8 = bsdfData_7;
    incidentDirection_5 = incidentDirection_4;
    attenuationIrradiance_5 = attenuationIrradiance_4;
    return;
}

fn clearCoatLobe(varyings_8: Varyings, surfaceData_10: SurfaceData, bsdfData_9: BSDFData, incidentDirection_6: vec3<f32>, color: vec3<f32>, specularColor_4: ptr<function, vec3<f32>>) -> f32 {
    var varyings_9: Varyings;
    var surfaceData_11: SurfaceData;
    var bsdfData_10: BSDFData;
    var incidentDirection_7: vec3<f32>;
    var color_1: vec3<f32>;
    var attenuation_1: f32 = 1f;

    varyings_9 = varyings_8;
    surfaceData_11 = surfaceData_10;
    bsdfData_10 = bsdfData_9;
    incidentDirection_7 = incidentDirection_6;
    color_1 = color;
    let _e105: f32 = attenuation_1;
    return _e105;
}

fn surfaceShading(varyings_10: Varyings, surfaceData_12: SurfaceData, bsdfData_11: BSDFData, incidentDirection_8: vec3<f32>, lightColor: vec3<f32>, totalDiffuseColor: ptr<function, vec3<f32>>, totalSpecularColor: ptr<function, vec3<f32>>) {
    var varyings_11: Varyings;
    var surfaceData_13: SurfaceData;
    var bsdfData_12: BSDFData;
    var incidentDirection_9: vec3<f32>;
    var lightColor_1: vec3<f32>;
    var diffuseColor_4: vec3<f32> = vec3(0f);
    var specularColor_5: vec3<f32> = vec3(0f);
    var dotNL_5: f32;
    var irradiance: vec3<f32>;
    var attenuation_2: f32;
    var attenuationIrradiance_6: vec3<f32>;

    varyings_11 = varyings_10;
    surfaceData_13 = surfaceData_12;
    bsdfData_12 = bsdfData_11;
    incidentDirection_9 = incidentDirection_8;
    lightColor_1 = lightColor;
    let _e112: SurfaceData = surfaceData_13;
    let _e114: vec3<f32> = incidentDirection_9;
    dotNL_5 = clamp(dot(_e112.normal, _e114), 0f, 1f);
    let _e120: f32 = dotNL_5;
    let _e121: vec3<f32> = lightColor_1;
    irradiance = ((_e120 * _e121) * 3.1415927f);
    let _e126: Varyings = varyings_11;
    let _e127: SurfaceData = surfaceData_13;
    let _e128: BSDFData = bsdfData_12;
    let _e129: vec3<f32> = incidentDirection_9;
    let _e130: vec3<f32> = lightColor_1;
    let _e133: f32 = clearCoatLobe(_e126, _e127, _e128, _e129, _e130, (&specularColor_5));
    attenuation_2 = _e133;
    let _e135: f32 = attenuation_2;
    let _e136: vec3<f32> = irradiance;
    attenuationIrradiance_6 = (_e135 * _e136);
    let _e139: Varyings = varyings_11;
    let _e140: SurfaceData = surfaceData_13;
    let _e141: BSDFData = bsdfData_12;
    let _e142: vec3<f32> = attenuationIrradiance_6;
    diffuseLobe(_e139, _e140, _e141, _e142, (&diffuseColor_4));
    let _e145: Varyings = varyings_11;
    let _e146: SurfaceData = surfaceData_13;
    let _e147: BSDFData = bsdfData_12;
    let _e148: vec3<f32> = incidentDirection_9;
    let _e149: vec3<f32> = attenuationIrradiance_6;
    specularLobe(_e145, _e146, _e147, _e148, _e149, (&specularColor_5));
    let _e152: Varyings = varyings_11;
    let _e153: SurfaceData = surfaceData_13;
    let _e154: BSDFData = bsdfData_12;
    let _e155: vec3<f32> = incidentDirection_9;
    let _e156: vec3<f32> = attenuationIrradiance_6;
    sheenLobe(_e152, _e153, _e154, _e155, _e156, (&diffuseColor_4), (&specularColor_5));
    let _e161: vec3<f32> = (*totalDiffuseColor);
    let _e162: vec3<f32> = diffuseColor_4;
    (*totalDiffuseColor) = (_e161 + _e162);
    let _e164: vec3<f32> = (*totalSpecularColor);
    let _e165: vec3<f32> = specularColor_5;
    (*totalSpecularColor) = (_e164 + _e165);
    return;
}

fn evaluateDirectRadiance(varyings_12: Varyings, surfaceData_14: SurfaceData, bsdfData_13: BSDFData, shadowAttenuation: f32, totalDiffuseColor_1: ptr<function, vec3<f32>>, totalSpecularColor_1: ptr<function, vec3<f32>>) {
    var varyings_13: Varyings;
    var surfaceData_15: SurfaceData;
    var bsdfData_14: BSDFData;
    var shadowAttenuation_1: f32;

    varyings_13 = varyings_12;
    surfaceData_15 = surfaceData_14;
    bsdfData_14 = bsdfData_13;
    shadowAttenuation_1 = shadowAttenuation;
    return;
}

fn getReflectedVector(surfaceData_16: SurfaceData, n: vec3<f32>) -> vec3<f32> {
    var surfaceData_17: SurfaceData;
    var n_1: vec3<f32>;
    var r_1: vec3<f32>;

    surfaceData_17 = surfaceData_16;
    n_1 = n;
    let _e96: SurfaceData = surfaceData_17;
    let _e99: vec3<f32> = n_1;
    r_1 = reflect(-(_e96.viewDir), _e99);
    let _e102: vec3<f32> = r_1;
    return _e102;
}

fn getSpecularMIPLevel(roughness_7: f32, maxMIPLevel: i32) -> f32 {
    var roughness_8: f32;
    var maxMIPLevel_1: i32;

    roughness_8 = roughness_7;
    maxMIPLevel_1 = maxMIPLevel;
    let _e96: f32 = roughness_8;
    let _e97: i32 = maxMIPLevel_1;
    return (_e96 * f32(_e97));
}

fn getLightProbeRadiance(surfaceData_18: SurfaceData, normal_4: vec3<f32>, roughness_9: f32) -> vec3<f32> {
    var surfaceData_19: SurfaceData;
    var normal_5: vec3<f32>;
    var roughness_10: f32;

    surfaceData_19 = surfaceData_18;
    normal_5 = normal_4;
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
    let _e100: f32 = specularAOFactor;
    return _e100;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal_6: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_7: vec3<f32>;
    var result: vec3<f32>;

    sh_1 = sh;
    normal_7 = normal_6;
    let _e98: vec3<f32> = sh_1[0];
    let _e101: vec3<f32> = sh_1[1];
    let _e102: vec3<f32> = normal_7;
    let _e108: vec3<f32> = sh_1[2];
    let _e109: vec3<f32> = normal_7;
    let _e115: vec3<f32> = sh_1[3];
    let _e116: vec3<f32> = normal_7;
    let _e122: vec3<f32> = sh_1[4];
    let _e123: vec3<f32> = normal_7;
    let _e125: vec3<f32> = normal_7;
    let _e132: vec3<f32> = sh_1[5];
    let _e133: vec3<f32> = normal_7;
    let _e135: vec3<f32> = normal_7;
    let _e142: vec3<f32> = sh_1[6];
    let _e144: vec3<f32> = normal_7;
    let _e147: vec3<f32> = normal_7;
    let _e156: vec3<f32> = sh_1[7];
    let _e157: vec3<f32> = normal_7;
    let _e159: vec3<f32> = normal_7;
    let _e166: vec3<f32> = sh_1[8];
    let _e167: vec3<f32> = normal_7;
    let _e169: vec3<f32> = normal_7;
    let _e172: vec3<f32> = normal_7;
    let _e174: vec3<f32> = normal_7;
    result = ((((((((_e98 + (_e101 * _e102.y)) + (_e108 * _e109.z)) + (_e115 * _e116.x)) + (_e122 * (_e123.y * _e125.x))) + (_e132 * (_e133.y * _e135.z))) + (_e142 * (((3f * _e144.z) * _e147.z) - 1f))) + (_e156 * (_e157.z * _e159.x))) + (_e166 * ((_e167.x * _e169.x) - (_e172.y * _e174.y))));
    let _e181: vec3<f32> = result;
    return max(_e181, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS: vec3<f32>) -> vec3<f32> {
    var normalWS_1: vec3<f32>;

    normalWS_1 = normalWS;
    let _e94: EnvMapLight = scene_EnvMapLight;
    return (_e94.diffuse * 3.1415927f);
}

fn evaluateDiffuseIBL(varyings_14: Varyings, surfaceData_20: SurfaceData, bsdfData_15: BSDFData, diffuseColor_5: ptr<function, vec3<f32>>) {
    var varyings_15: Varyings;
    var surfaceData_21: SurfaceData;
    var bsdfData_16: BSDFData;
    var irradiance_1: vec3<f32>;

    varyings_15 = varyings_14;
    surfaceData_21 = surfaceData_20;
    bsdfData_16 = bsdfData_15;
    let _e99: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e99.diffuse * 3.1415927f);
    let _e104: vec3<f32> = irradiance_1;
    let _e105: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e104 * _e105.diffuseIntensity);
    let _e108: vec3<f32> = (*diffuseColor_5);
    let _e109: BSDFData = bsdfData_16;
    let _e111: vec3<f32> = irradiance_1;
    let _e113: BSDFData = bsdfData_16;
    let _e115: vec3<f32> = BRDF_Diffuse_Lambert(_e113.diffuseColor);
    (*diffuseColor_5) = (_e108 + ((_e109.diffuseAO * _e111) * _e115));
    return;
}

fn evaluateClearCoatIBL(varyings_16: Varyings, surfaceData_22: SurfaceData, bsdfData_17: BSDFData, specularColor_6: ptr<function, vec3<f32>>) -> f32 {
    var varyings_17: Varyings;
    var surfaceData_23: SurfaceData;
    var bsdfData_18: BSDFData;
    var radianceAttenuation: f32 = 1f;

    varyings_17 = varyings_16;
    surfaceData_23 = surfaceData_22;
    bsdfData_18 = bsdfData_17;
    let _e101: f32 = radianceAttenuation;
    return _e101;
}

fn evaluateSpecularIBL(varyings_18: Varyings, surfaceData_24: SurfaceData, bsdfData_19: BSDFData, radianceAttenuation_1: f32, outSpecularColor: ptr<function, vec3<f32>>) {
    var varyings_19: Varyings;
    var surfaceData_25: SurfaceData;
    var bsdfData_20: BSDFData;
    var radianceAttenuation_2: f32;
    var radiance: vec3<f32>;
    var specularAO: f32;

    varyings_19 = varyings_18;
    surfaceData_25 = surfaceData_24;
    bsdfData_20 = bsdfData_19;
    radianceAttenuation_2 = radianceAttenuation_1;
    let _e101: SurfaceData = surfaceData_25;
    let _e102: SurfaceData = surfaceData_25;
    let _e104: BSDFData = bsdfData_20;
    let _e106: vec3<f32> = getLightProbeRadiance(_e101, _e102.normal, _e104.roughness);
    radiance = _e106;
    let _e108: SurfaceData = surfaceData_25;
    let _e110: BSDFData = bsdfData_20;
    let _e112: BSDFData = bsdfData_20;
    let _e114: f32 = evaluateSpecularOcclusion(_e108.dotNV, _e110.diffuseAO, _e112.roughness);
    specularAO = _e114;
    let _e116: vec3<f32> = (*outSpecularColor);
    let _e117: f32 = specularAO;
    let _e118: f32 = radianceAttenuation_2;
    let _e120: vec3<f32> = radiance;
    let _e122: BSDFData = bsdfData_20;
    let _e124: BSDFData = bsdfData_20;
    let _e126: BSDFData = bsdfData_20;
    let _e128: SurfaceData = surfaceData_25;
    let _e130: vec3<f32> = envBRDFApprox(_e122.resolvedSpecularF0_, _e124.specularF90_, _e126.roughness, _e128.dotNV);
    let _e132: BSDFData = bsdfData_20;
    (*outSpecularColor) = (_e116 + ((((_e117 * _e118) * _e120) * _e130) * _e132.energyCompensation));
    return;
}

fn evaluateSheenIBL(varyings_20: Varyings, surfaceData_26: SurfaceData, bsdfData_21: BSDFData, radianceAttenuation_3: f32, diffuseColor_6: ptr<function, vec3<f32>>, specularColor_7: ptr<function, vec3<f32>>) {
    var varyings_21: Varyings;
    var surfaceData_27: SurfaceData;
    var bsdfData_22: BSDFData;
    var radianceAttenuation_4: f32;

    varyings_21 = varyings_20;
    surfaceData_27 = surfaceData_26;
    bsdfData_22 = bsdfData_21;
    radianceAttenuation_4 = radianceAttenuation_3;
    return;
}

fn evaluateIBL(varyings_22: Varyings, surfaceData_28: SurfaceData, bsdfData_23: BSDFData, totalDiffuseColor_2: ptr<function, vec3<f32>>, totalSpecularColor_2: ptr<function, vec3<f32>>) {
    var varyings_23: Varyings;
    var surfaceData_29: SurfaceData;
    var bsdfData_24: BSDFData;
    var diffuseColor_7: vec3<f32> = vec3(0f);
    var specularColor_8: vec3<f32> = vec3(0f);
    var radianceAttenuation_5: f32;

    varyings_23 = varyings_22;
    surfaceData_29 = surfaceData_28;
    bsdfData_24 = bsdfData_23;
    let _e108: Varyings = varyings_23;
    let _e109: SurfaceData = surfaceData_29;
    let _e110: BSDFData = bsdfData_24;
    evaluateDiffuseIBL(_e108, _e109, _e110, (&diffuseColor_7));
    let _e113: Varyings = varyings_23;
    let _e114: SurfaceData = surfaceData_29;
    let _e115: BSDFData = bsdfData_24;
    let _e118: f32 = evaluateClearCoatIBL(_e113, _e114, _e115, (&specularColor_8));
    radianceAttenuation_5 = _e118;
    let _e120: Varyings = varyings_23;
    let _e121: SurfaceData = surfaceData_29;
    let _e122: BSDFData = bsdfData_24;
    let _e123: f32 = radianceAttenuation_5;
    evaluateSpecularIBL(_e120, _e121, _e122, _e123, (&specularColor_8));
    let _e126: Varyings = varyings_23;
    let _e127: SurfaceData = surfaceData_29;
    let _e128: BSDFData = bsdfData_24;
    let _e129: f32 = radianceAttenuation_5;
    evaluateSheenIBL(_e126, _e127, _e128, _e129, (&diffuseColor_7), (&specularColor_8));
    let _e134: vec3<f32> = (*totalDiffuseColor_2);
    let _e135: vec3<f32> = diffuseColor_7;
    (*totalDiffuseColor_2) = (_e134 + _e135);
    let _e137: vec3<f32> = (*totalSpecularColor_2);
    let _e138: vec3<f32> = specularColor_8;
    (*totalSpecularColor_2) = (_e137 + _e138);
    return;
}

fn terrainProjectEvaluateSpecularIBL(surfaceData_30: SurfaceData, bsdfData_25: BSDFData, radiance_1: vec3<f32>) -> vec3<f32> {
    var surfaceData_31: SurfaceData;
    var bsdfData_26: BSDFData;
    var radiance_2: vec3<f32>;
    var specularAO_1: f32;

    surfaceData_31 = surfaceData_30;
    bsdfData_26 = bsdfData_25;
    radiance_2 = radiance_1;
    let _e98: SurfaceData = surfaceData_31;
    let _e100: BSDFData = bsdfData_26;
    let _e102: BSDFData = bsdfData_26;
    let _e104: f32 = evaluateSpecularOcclusion(_e98.dotNV, _e100.diffuseAO, _e102.roughness);
    specularAO_1 = _e104;
    let _e106: f32 = specularAO_1;
    let _e107: vec3<f32> = radiance_2;
    let _e109: BSDFData = bsdfData_26;
    let _e111: BSDFData = bsdfData_26;
    let _e113: BSDFData = bsdfData_26;
    let _e115: SurfaceData = surfaceData_31;
    let _e117: vec3<f32> = envBRDFApprox(_e109.resolvedSpecularF0_, _e111.specularF90_, _e113.roughness, _e115.dotNV);
    let _e119: BSDFData = bsdfData_26;
    return (((_e106 * _e107) * _e117) * _e119.energyCompensation);
}

fn evaluateTerrainProjectLightingWithShadow(varyings_24: Varyings, surfaceData_32: SurfaceData, shadowAttenuation_2: f32) -> TerrainProjectLightingResult {
    var varyings_25: Varyings;
    var surfaceData_33: SurfaceData;
    var shadowAttenuation_3: f32;
    var result_1: TerrainProjectLightingResult;
    var bsdfData_27: BSDFData;
    var directShadowAttenuation: f32;

    varyings_25 = varyings_24;
    surfaceData_33 = surfaceData_32;
    shadowAttenuation_3 = shadowAttenuation_2;
    result_1.directDiffuse = vec3(0f);
    result_1.directSpecular = vec3(0f);
    result_1.environmentDiffuse = vec3(0f);
    result_1.environmentSpecular = vec3(0f);
    let _e112: f32 = shadowAttenuation_3;
    result_1.shadowAttenuation = _e112;
    let _e114: SurfaceData = surfaceData_33;
    surfaceData_33.albedoColor = _e114.albedoColor;
    let _e117: SurfaceData = surfaceData_33;
    initBSDFData(_e117, (&bsdfData_27));
    let _e120: TerrainProjectLightingResult = result_1;
    directShadowAttenuation = _e120.shadowAttenuation;
    let _e123: Varyings = varyings_25;
    let _e124: SurfaceData = surfaceData_33;
    let _e125: BSDFData = bsdfData_27;
    let _e126: f32 = directShadowAttenuation;
    let _e127: TerrainProjectLightingResult = result_1;
    let _e129: TerrainProjectLightingResult = result_1;
    var gs_output_arg0 = result_1.directDiffuse;
    var gs_output_arg1 = result_1.directSpecular;
    evaluateDirectRadiance(_e123, _e124, _e125, _e126, (&gs_output_arg0), (&gs_output_arg1));
    result_1.directDiffuse = gs_output_arg0;
    result_1.directSpecular = gs_output_arg1;
    let _e135: Varyings = varyings_25;
    let _e136: SurfaceData = surfaceData_33;
    let _e137: BSDFData = bsdfData_27;
    let _e138: TerrainProjectLightingResult = result_1;
    let _e140: TerrainProjectLightingResult = result_1;
    var gs_output_arg2 = result_1.environmentDiffuse;
    var gs_output_arg3 = result_1.environmentSpecular;
    evaluateIBL(_e135, _e136, _e137, (&gs_output_arg2), (&gs_output_arg3));
    result_1.environmentDiffuse = gs_output_arg2;
    result_1.environmentSpecular = gs_output_arg3;
    let _e146: TerrainProjectLightingResult = result_1;
    return _e146;
}

fn terrainProjectFinalLighting(result_2: TerrainProjectLightingResult) -> vec3<f32> {
    var result_3: TerrainProjectLightingResult;

    result_3 = result_2;
    let _e94: TerrainProjectLightingResult = result_3;
    let _e96: TerrainProjectLightingResult = result_3;
    let _e99: TerrainProjectLightingResult = result_3;
    let _e102: TerrainProjectLightingResult = result_3;
    return (((_e94.directDiffuse + _e96.directSpecular) + _e99.environmentDiffuse) + _e102.environmentSpecular);
}

fn terrainProjectBuildSurfaceData(varyings_26: Varyings, albedo: vec3<f32>, surfaceNormal: vec3<f32>, metallic_1: f32, smoothness: f32, ambientOcclusion: f32) -> SurfaceData {
    var varyings_27: Varyings;
    var albedo_1: vec3<f32>;
    var surfaceNormal_1: vec3<f32>;
    var metallic_2: f32;
    var smoothness_1: f32;
    var ambientOcclusion_1: f32;
    var surfaceData_34: SurfaceData;

    varyings_27 = varyings_26;
    albedo_1 = albedo;
    surfaceNormal_1 = surfaceNormal;
    metallic_2 = metallic_1;
    smoothness_1 = smoothness;
    ambientOcclusion_1 = ambientOcclusion;
    let _e106: vec3<f32> = albedo_1;
    surfaceData_34.albedoColor = _e106;
    surfaceData_34.emissiveColor = vec3(0f);
    let _e111: f32 = metallic_2;
    surfaceData_34.metallic = clamp(_e111, 0f, 1f);
    let _e117: f32 = smoothness_1;
    surfaceData_34.roughness = (1f - clamp(_e117, 0f, 1f));
    let _e123: f32 = ambientOcclusion_1;
    surfaceData_34.ambientOcclusion = clamp(_e123, 0f, 1f);
    surfaceData_34.opacity = 1f;
    surfaceData_34.IOR = 1.5f;
    let _e132: Varyings = varyings_27;
    surfaceData_34.position = _e132.positionWS;
    let _e135: Varyings = varyings_27;
    surfaceData_34.positionCS = _e135.positionCS;
    let _e138: vec3<f32> = surfaceNormal_1;
    surfaceData_34.normal = _e138;
    let _e140: vec3<f32> = global.camera_Position;
    let _e141: Varyings = varyings_27;
    surfaceData_34.viewDir = normalize((_e140 - _e141.positionWS));
    let _e146: SurfaceData = surfaceData_34;
    let _e148: SurfaceData = surfaceData_34;
    surfaceData_34.dotNV = clamp(dot(_e146.normal, _e148.viewDir), 0f, 1f);
    surfaceData_34.specularIntensity = 1f;
    surfaceData_34.specularColor = vec3(1f);
    let _e159: SurfaceData = surfaceData_34;
    return _e159;
}

fn terrainProjectApplySeasonColor(sourceColor: vec3<f32>, seasonColor: vec4<f32>) -> vec3<f32> {
    var sourceColor_1: vec3<f32>;
    var seasonColor_1: vec4<f32>;
    var sourceLuminance: f32;
    var seasonTone: vec3<f32>;

    sourceColor_1 = sourceColor;
    seasonColor_1 = seasonColor;
    let _e96: vec3<f32> = sourceColor_1;
    sourceLuminance = dot(_e96, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e103: vec4<f32> = seasonColor_1;
    let _e105: f32 = sourceLuminance;
    seasonTone = (_e103.xyz * _e105);
    let _e108: vec3<f32> = sourceColor_1;
    let _e109: vec3<f32> = seasonTone;
    let _e110: vec4<f32> = seasonColor_1;
    return mix(_e108, _e109, vec3(clamp(_e110.w, 0f, 1f)));
}

fn terrainProjectApplyAuthoredSeasonColor(sourceColor_2: vec3<f32>, seasonColor_2: vec4<f32>, authoredChannels: vec3<f32>) -> vec3<f32> {
    var sourceColor_3: vec3<f32>;
    var seasonColor_3: vec4<f32>;
    var authoredChannels_1: vec3<f32>;

    sourceColor_3 = sourceColor_2;
    seasonColor_3 = seasonColor_2;
    authoredChannels_1 = authoredChannels;
    let _e98: vec3<f32> = sourceColor_3;
    let _e99: vec4<f32> = seasonColor_3;
    let _e100: vec3<f32> = terrainProjectApplySeasonColor(_e98, _e99);
    let _e101: vec3<f32> = sourceColor_3;
    let _e102: vec3<f32> = authoredChannels_1;
    return mix(_e100, _e101, _e102);
}

fn grassColorFieldRotateUv(value: vec2<f32>, cosineSine: vec2<f32>) -> vec2<f32> {
    var value_1: vec2<f32>;
    var cosineSine_1: vec2<f32>;

    value_1 = value;
    cosineSine_1 = cosineSine;
    let _e98: vec2<f32> = cosineSine_1;
    let _e100: vec2<f32> = value_1;
    let _e103: vec2<f32> = cosineSine_1;
    let _e105: vec2<f32> = value_1;
    let _e109: vec2<f32> = cosineSine_1;
    let _e111: vec2<f32> = value_1;
    let _e114: vec2<f32> = cosineSine_1;
    let _e116: vec2<f32> = value_1;
    return vec2<f32>(((_e98.x * _e100.x) + (_e103.y * _e105.y)), ((_e109.x * _e111.y) - (_e114.y * _e116.x)));
}

fn grassColorFieldMaximumLod() -> f32 {
    var baseSize: vec2<i32>;

    let _e95: vec2<u32> = textureDimensions(gs_wgpu_tex_renderer_GrassColorFieldTexture, 0i);
    baseSize = vec2<i32>(_e95);
    let _e98: vec2<i32> = baseSize;
    let _e100: vec2<i32> = baseSize;
    return floor(log2(f32(max(_e98.x, _e100.y))));
}

fn grassColorFieldSoftnessLod() -> f32 {
    var textureResolution: f32;
    var softnessMetres: f32;
    var softnessLod: f32;

    let _e95: vec2<u32> = textureDimensions(gs_wgpu_tex_renderer_GrassColorFieldTexture, 0i);
    textureResolution = f32(vec2<i32>(_e95).x);
    let _e100: vec4<f32> = global.renderer_GrassColorFieldParams;
    softnessMetres = max(_e100.x, 0f);
    let _e105: f32 = softnessMetres;
    let _e106: vec4<f32> = global.renderer_GrassColorFieldTransform;
    let _e109: f32 = textureResolution;
    softnessLod = max(log2(max(((_e105 * _e106.y) * _e109), 1f)), 0f);
    let _e117: f32 = softnessLod;
    let _e118: f32 = grassColorFieldMaximumLod();
    return min(_e117, _e118);
}

fn grassColorFieldMirrorUv(uv: vec2<f32>) -> vec2<f32> {
    var uv_1: vec2<f32>;

    uv_1 = uv;
    let _e98: vec2<f32> = uv_1;
    let _e100: vec2<f32> = vec2(2f);
    return (vec2(1f) - abs(((_e98 - (floor((_e98 / _e100)) * _e100)) - vec2(1f))));
}

fn grassColorFieldDetailUv(worldXZ: vec2<f32>) -> vec2<f32> {
    var worldXZ_1: vec2<f32>;
    var cosineSine_2: vec2<f32>;

    worldXZ_1 = worldXZ;
    let _e96: vec4<f32> = global.renderer_GrassColorFieldTransform;
    let _e99: vec4<f32> = global.renderer_GrassColorFieldTransform;
    cosineSine_2 = vec2<f32>(cos(_e96.z), sin(_e99.z));
    let _e104: vec2<f32> = worldXZ_1;
    let _e105: vec4<f32> = global.renderer_GrassColorFieldTransform;
    let _e108: vec4<f32> = global.renderer_GrassColorFieldOffset;
    let _e111: vec2<f32> = cosineSine_2;
    let _e112: vec2<f32> = grassColorFieldRotateUv(((_e104 * _e105.y) + _e108.xy), _e111);
    let _e113: vec2<f32> = grassColorFieldMirrorUv(_e112);
    return _e113;
}

fn grassColorFieldVistaUv(worldXZ_2: vec2<f32>) -> vec2<f32> {
    var worldXZ_3: vec2<f32>;

    worldXZ_3 = worldXZ_2;
    let _e96: vec2<f32> = worldXZ_3;
    let _e97: vec4<f32> = global.renderer_GrassColorFieldTransform;
    let _e100: vec4<f32> = global.renderer_GrassColorFieldOffset;
    return clamp(((_e96 * _e97.w) + _e100.zw), vec2(0f), vec2(1f));
}

fn decodeGrassColorField(field: f32) -> f32 {
    var field_1: f32;
    var remapRange: f32;

    field_1 = field;
    let _e96: vec4<f32> = global.renderer_GrassColorFieldParams;
    let _e98: vec4<f32> = global.renderer_GrassColorFieldParams;
    remapRange = max((_e96.z - _e98.y), 0.00001f);
    let _e104: f32 = field_1;
    let _e105: vec4<f32> = global.renderer_GrassColorFieldParams;
    let _e108: f32 = remapRange;
    return clamp(((_e104 - _e105.y) / _e108), 0f, 1f);
}

fn sampleGrassColorFieldAtLod(worldXZ_4: vec2<f32>, lod: f32) -> f32 {
    var worldXZ_5: vec2<f32>;
    var lod_1: f32;
    var field_2: f32;

    worldXZ_5 = worldXZ_4;
    lod_1 = lod;
    let _e98: vec4<f32> = global.renderer_GrassColorFieldTransform;
    if (_e98.x < 0.5f) {
        return 0.5f;
    }
    let _e103: vec2<f32> = worldXZ_5;
    let _e104: vec2<f32> = grassColorFieldDetailUv(_e103);
    let _e105: f32 = lod_1;
    let _e106: vec4<f32> = textureSampleLevel(gs_wgpu_tex_renderer_GrassColorFieldTexture, gs_wgpu_samp_renderer_GrassColorFieldTexture, _e104, _e105);
    field_2 = _e106.x;
    let _e109: f32 = field_2;
    let _e110: f32 = decodeGrassColorField(_e109);
    return _e110;
}

fn sampleGrassColorField(worldXZ_6: vec2<f32>) -> f32 {
    var worldXZ_7: vec2<f32>;

    worldXZ_7 = worldXZ_6;
    let _e96: vec4<f32> = global.renderer_GrassColorFieldTransform;
    if (_e96.x < 0.5f) {
        return 0.5f;
    }
    let _e101: vec4<f32> = global.renderer_GrassColorFieldParams;
    if (_e101.x <= 0f) {
        {
            let _e105: vec2<f32> = worldXZ_7;
            let _e106: vec2<f32> = grassColorFieldDetailUv(_e105);
            let _e107: vec4<f32> = textureSample(gs_wgpu_tex_renderer_GrassColorFieldTexture, gs_wgpu_samp_renderer_GrassColorFieldTexture, _e106);
            let _e109: f32 = decodeGrassColorField(_e107.x);
            return _e109;
        }
    }
    let _e110: vec2<f32> = worldXZ_7;
    let _e111: f32 = grassColorFieldSoftnessLod();
    let _e112: f32 = sampleGrassColorFieldAtLod(_e110, _e111);
    return _e112;
}

fn sampleGrassVistaColorField(worldXZ_8: vec2<f32>) -> f32 {
    var worldXZ_9: vec2<f32>;
    var field_3: f32;

    worldXZ_9 = worldXZ_8;
    let _e96: vec4<f32> = global.renderer_GrassColorFieldTransform;
    if (_e96.x < 0.5f) {
        return 0.5f;
    }
    let _e101: vec2<f32> = worldXZ_9;
    let _e102: vec2<f32> = grassColorFieldVistaUv(_e101);
    let _e103: vec4<f32> = textureSample(gs_wgpu_tex_renderer_GrassColorFieldTexture, gs_wgpu_samp_renderer_GrassColorFieldTexture, _e102);
    field_3 = _e103.y;
    let _e106: f32 = field_3;
    let _e107: f32 = decodeGrassColorField(_e106);
    return _e107;
}

fn grassColorFieldVistaBlendWeight(worldPosition: vec3<f32>) -> f32 {
    var worldPosition_1: vec3<f32>;

    worldPosition_1 = worldPosition;
    let _e96: vec2<f32> = global.renderer_GrassColorFieldVistaBlend;
    let _e98: vec2<f32> = global.renderer_GrassColorFieldVistaBlend;
    let _e100: vec3<f32> = global.camera_Position;
    let _e101: vec3<f32> = worldPosition_1;
    return smoothstep(_e96.x, _e98.y, distance(_e100, _e101));
}

fn grassRgbToHsv(color_2: vec3<f32>) -> vec3<f32> {
    var color_3: vec3<f32>;
    var k: vec4<f32> = vec4<f32>(0f, -0.33333334f, 0.6666667f, -1f);
    var p: vec4<f32>;
    var q: vec4<f32>;
    var delta: f32;
    var epsilon: f32 = 0.0000000001f;

    color_3 = color_2;
    let _e104: vec3<f32> = color_3;
    let _e105: vec2<f32> = _e104.zy;
    let _e106: vec4<f32> = k;
    let _e107: vec2<f32> = _e106.wz;
    let _e113: vec3<f32> = color_3;
    let _e114: vec2<f32> = _e113.yz;
    let _e115: vec4<f32> = k;
    let _e116: vec2<f32> = _e115.xy;
    let _e122: vec3<f32> = color_3;
    let _e124: vec3<f32> = color_3;
    p = mix(vec4<f32>(_e105.x, _e105.y, _e107.x, _e107.y), vec4<f32>(_e114.x, _e114.y, _e116.x, _e116.y), vec4(step(_e122.z, _e124.y)));
    let _e130: vec4<f32> = p;
    let _e131: vec3<f32> = _e130.xyw;
    let _e132: vec3<f32> = color_3;
    let _e138: vec3<f32> = color_3;
    let _e140: vec4<f32> = p;
    let _e141: vec3<f32> = _e140.yzx;
    let _e146: vec4<f32> = p;
    let _e148: vec3<f32> = color_3;
    q = mix(vec4<f32>(_e131.x, _e131.y, _e131.z, _e132.x), vec4<f32>(_e138.x, _e141.x, _e141.y, _e141.z), vec4(step(_e146.x, _e148.x)));
    let _e154: vec4<f32> = q;
    let _e156: vec4<f32> = q;
    let _e158: vec4<f32> = q;
    delta = (_e154.x - min(_e156.w, _e158.y));
    let _e165: vec4<f32> = q;
    let _e167: vec4<f32> = q;
    let _e169: vec4<f32> = q;
    let _e173: f32 = delta;
    let _e175: f32 = epsilon;
    let _e180: f32 = delta;
    let _e181: vec4<f32> = q;
    let _e183: f32 = epsilon;
    let _e186: vec4<f32> = q;
    return vec3<f32>(abs((_e165.z + ((_e167.w - _e169.y) / ((6f * _e173) + _e175)))), (_e180 / (_e181.x + _e183)), _e186.x);
}

fn grassHsvToRgb(color_4: vec3<f32>) -> vec3<f32> {
    var color_5: vec3<f32>;
    var p_1: vec3<f32>;

    color_5 = color_4;
    let _e96: vec3<f32> = color_5;
    p_1 = abs(((fract((_e96.xxx + vec3<f32>(0f, 0.6666667f, 0.33333334f))) * 6f) - vec3(3f)));
    let _e111: vec3<f32> = color_5;
    let _e115: vec3<f32> = p_1;
    let _e124: vec3<f32> = color_5;
    return (_e111.z * mix(vec3(1f), clamp((_e115 - vec3(1f)), vec3(0f), vec3(1f)), vec3(_e124.y)));
}

fn grassSaturatePaletteEndpoint(color_6: vec3<f32>) -> vec3<f32> {
    var color_7: vec3<f32>;
    var hsv: vec3<f32>;

    color_7 = color_6;
    let _e96: vec3<f32> = color_7;
    let _e97: vec3<f32> = grassRgbToHsv(_e96);
    hsv = _e97;
    let _e100: vec3<f32> = hsv;
    let _e102: vec4<f32> = global.renderer_GrassColorFieldParams;
    hsv.y = clamp((_e100.y * _e102.w), 0f, 1f);
    let _e108: vec3<f32> = hsv;
    let _e109: vec3<f32> = grassHsvToRgb(_e108);
    return _e109;
}

fn grassColorFromField(field_4: f32) -> vec3<f32> {
    var field_5: f32;
    var colorA: vec3<f32>;
    var colorB: vec3<f32>;

    field_5 = field_4;
    let _e96: vec4<f32> = global.renderer_GrassColorA;
    let _e98: vec3<f32> = grassSaturatePaletteEndpoint(_e96.xyz);
    colorA = _e98;
    let _e100: vec4<f32> = global.renderer_GrassColorB;
    let _e102: vec3<f32> = grassSaturatePaletteEndpoint(_e100.xyz);
    colorB = _e102;
    let _e104: vec3<f32> = colorA;
    let _e105: vec4<f32> = global.scene_GrassSeasonColor;
    let _e106: vec4<f32> = global.renderer_GrassColorOverrideA;
    let _e108: vec3<f32> = terrainProjectApplyAuthoredSeasonColor(_e104, _e105, _e106.xyz);
    colorA = _e108;
    let _e109: vec3<f32> = colorB;
    let _e110: vec4<f32> = global.scene_GrassSeasonColor;
    let _e111: vec4<f32> = global.renderer_GrassColorOverrideB;
    let _e113: vec3<f32> = terrainProjectApplyAuthoredSeasonColor(_e109, _e110, _e111.xyz);
    colorB = _e113;
    let _e114: vec3<f32> = colorA;
    let _e115: vec3<f32> = colorB;
    let _e116: f32 = field_5;
    return mix(_e114, _e115, vec3(_e116));
}

fn evaluateGrassBaseColor(worldXZ_10: vec2<f32>) -> vec3<f32> {
    var worldXZ_11: vec2<f32>;

    worldXZ_11 = worldXZ_10;
    let _e96: vec2<f32> = worldXZ_11;
    let _e97: f32 = sampleGrassColorField(_e96);
    let _e98: vec3<f32> = grassColorFromField(_e97);
    return _e98;
}

fn roadColorFromField(field_6: f32, nativeColor: vec3<f32>) -> vec3<f32> {
    var field_7: f32;
    var nativeColor_1: vec3<f32>;

    field_7 = field_6;
    nativeColor_1 = nativeColor;
    let _e98: vec3<f32> = nativeColor_1;
    let _e99: vec4<f32> = global.renderer_RoadColorFieldA;
    let _e101: vec4<f32> = global.renderer_RoadColorFieldB;
    let _e103: f32 = field_7;
    let _e106: vec4<f32> = global.renderer_RoadColorFieldA;
    return mix(_e98, mix(_e99.xyz, _e101.xyz, vec3(_e103)), vec3(_e106.w));
}

fn roadDetailColorFromField(field_8: f32, nativeColor_2: vec3<f32>, vistaWeight: f32) -> vec3<f32> {
    var field_9: f32;
    var nativeColor_3: vec3<f32>;
    var vistaWeight_1: f32;
    var contrast: f32;
    var local: f32;
    var midpoint: f32;
    var detail: f32;

    field_9 = field_8;
    nativeColor_3 = nativeColor_2;
    vistaWeight_1 = vistaWeight;
    let _e100: vec4<f32> = global.renderer_RoadColorFieldRemap;
    contrast = max(_e100.x, 1f);
    let _e105: vec4<f32> = global.renderer_RoadColorFieldRemap;
    if (_e105.x > 0f) {
        let _e109: vec4<f32> = global.renderer_RoadColorFieldRemap;
        local = _e109.y;
    } else {
        local = 0.5f;
    }
    let _e113: f32 = local;
    midpoint = _e113;
    let _e115: f32 = field_9;
    let _e116: f32 = midpoint;
    let _e118: f32 = contrast;
    detail = clamp((((_e115 - _e116) * _e118) + 0.5f), 0f, 1f);
    let _e126: f32 = detail;
    let _e127: f32 = field_9;
    let _e128: f32 = vistaWeight_1;
    let _e130: vec3<f32> = nativeColor_3;
    let _e131: vec3<f32> = roadColorFromField(mix(_e126, _e127, _e128), _e130);
    return _e131;
}

fn terrainProjectSurfaceClimateHash(cell: vec2<f32>) -> f32 {
    var cell_1: vec2<f32>;

    cell_1 = cell;
    let _e96: vec2<f32> = cell_1;
    return fract((sin(dot(_e96, vec2<f32>(127.1f, 311.7f))) * 43758.547f));
}

fn terrainProjectSurfaceClimateValueNoise(position: vec2<f32>) -> f32 {
    var position_1: vec2<f32>;
    var cell_2: vec2<f32>;
    var local_1: vec2<f32>;
    var blend: vec2<f32>;
    var lower: f32;
    var upper: f32;

    position_1 = position;
    let _e96: vec2<f32> = position_1;
    cell_2 = floor(_e96);
    let _e99: vec2<f32> = position_1;
    local_1 = fract(_e99);
    let _e102: vec2<f32> = local_1;
    let _e103: vec2<f32> = local_1;
    let _e107: vec2<f32> = local_1;
    blend = ((_e102 * _e103) * (vec2(3f) - (2f * _e107)));
    let _e113: vec2<f32> = cell_2;
    let _e114: f32 = terrainProjectSurfaceClimateHash(_e113);
    let _e115: vec2<f32> = cell_2;
    let _e120: f32 = terrainProjectSurfaceClimateHash((_e115 + vec2<f32>(1f, 0f)));
    let _e121: vec2<f32> = blend;
    lower = mix(_e114, _e120, _e121.x);
    let _e125: vec2<f32> = cell_2;
    let _e130: f32 = terrainProjectSurfaceClimateHash((_e125 + vec2<f32>(0f, 1f)));
    let _e131: vec2<f32> = cell_2;
    let _e136: f32 = terrainProjectSurfaceClimateHash((_e131 + vec2<f32>(1f, 1f)));
    let _e137: vec2<f32> = blend;
    upper = mix(_e130, _e136, _e137.x);
    let _e141: f32 = lower;
    let _e142: f32 = upper;
    let _e143: vec2<f32> = blend;
    return mix(_e141, _e142, _e143.y);
}

fn terrainProjectSurfaceClimateNoise(worldXZ_12: vec2<f32>) -> f32 {
    var worldXZ_13: vec2<f32>;
    var broad: f32;
    var detail_1: f32;

    worldXZ_13 = worldXZ_12;
    let _e96: vec2<f32> = worldXZ_13;
    let _e99: f32 = terrainProjectSurfaceClimateValueNoise((_e96 * 0.055f));
    broad = _e99;
    let _e101: vec2<f32> = worldXZ_13;
    let _e108: f32 = terrainProjectSurfaceClimateValueNoise(((_e101 * 0.17f) + vec2<f32>(19.7f, 43.1f)));
    detail_1 = _e108;
    let _e110: f32 = broad;
    let _e111: f32 = detail_1;
    return mix(_e110, _e111, 0.28f);
}

fn terrainProjectSurfaceWetness(response: f32) -> f32 {
    var response_1: f32;

    response_1 = response;
    let _e96: vec4<f32> = global.scene_SurfaceClimate;
    let _e98: vec4<f32> = global.scene_SurfaceClimate;
    let _e103: f32 = response_1;
    return clamp((max(_e96.x, (_e98.w * 0.48f)) * _e103), 0f, 1f);
}

fn terrainProjectApplySurfaceMoisture(surfaceData_35: ptr<function, SurfaceData>, geometryNormal: vec3<f32>, response_2: vec2<f32>) {
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
    let _e99: vec2<f32> = response_3;
    let _e101: f32 = terrainProjectSurfaceWetness(_e99.x);
    wetness = _e101;
    let _e103: f32 = wetness;
    if (_e103 <= 0f) {
        return;
    }
    let _e107: SurfaceData = (*surfaceData_35);
    let _e114: SurfaceData = (*surfaceData_35);
    porousResponse = ((1f - _e107.metallic) * mix(0.35f, 1f, smoothstep(0.18f, 0.82f, _e114.roughness)));
    let _e120: f32 = wetness;
    let _e121: f32 = porousResponse;
    wetSubstrate = (_e120 * _e121);
    let _e124: SurfaceData = (*surfaceData_35);
    substrateLuminance = dot(_e124.albedoColor, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e132: f32 = substrateLuminance;
    let _e134: SurfaceData = (*surfaceData_35);
    saturatedSubstrate = mix(vec3(_e132), _e134.albedoColor, vec3(1.08f));
    let _e140: vec3<f32> = saturatedSubstrate;
    wetAlbedo = max((_e140 * 0.78f), vec3(0f));
    let _e148: SurfaceData = (*surfaceData_35);
    let _e150: vec3<f32> = wetAlbedo;
    let _e151: f32 = wetSubstrate;
    (*surfaceData_35).albedoColor = mix(_e148.albedoColor, _e150, vec3(_e151));
    let _e155: SurfaceData = (*surfaceData_35);
    wetRoughness = max(0.14f, (_e155.roughness * 0.62f));
    let _e162: SurfaceData = (*surfaceData_35);
    let _e164: f32 = wetRoughness;
    let _e165: f32 = wetSubstrate;
    (*surfaceData_35).roughness = mix(_e162.roughness, _e164, (_e165 * 0.72f));
    let _e170: SurfaceData = (*surfaceData_35);
    let _e172: SurfaceData = (*surfaceData_35);
    (*surfaceData_35).dotNV = clamp(dot(_e170.normal, _e172.viewDir), 0f, 1f);
    return;
}

fn terrainProjectTopSnowMask(worldPosition_2: vec3<f32>, geometryNormal_2: vec3<f32>, response_4: f32) -> f32 {
    var worldPosition_3: vec3<f32>;
    var geometryNormal_3: vec3<f32>;
    var response_5: f32;
    var snowStorage: f32;
    var distribution: f32;
    var snowDistribution: f32;
    var upward: f32;

    worldPosition_3 = worldPosition_2;
    geometryNormal_3 = geometryNormal_2;
    response_5 = response_4;
    let _e100: vec4<f32> = global.scene_SurfaceClimate;
    let _e102: f32 = response_5;
    snowStorage = clamp((_e100.z * _e102), 0f, 1f);
    let _e108: f32 = snowStorage;
    if (_e108 <= 0f) {
        return 0f;
    }
    let _e112: vec3<f32> = worldPosition_3;
    let _e114: f32 = terrainProjectSurfaceClimateNoise(_e112.xz);
    distribution = _e114;
    let _e118: f32 = snowStorage;
    let _e119: f32 = distribution;
    snowDistribution = smoothstep(0.06f, 0.64f, (_e118 + ((_e119 - 0.5f) * 0.22f)));
    let _e127: vec3<f32> = geometryNormal_3;
    upward = clamp(normalize(_e127).y, 0f, 1f);
    let _e134: f32 = snowDistribution;
    let _e137: f32 = upward;
    let _e140: f32 = snowStorage;
    return ((_e134 * smoothstep(0.34f, 0.82f, _e137)) * _e140);
}

fn terrainProjectApplyTopSnowLayer(surfaceData_36: ptr<function, SurfaceData>, geometryNormal_4: vec3<f32>, snow: f32, targetRoughness: f32, normalFlattening: f32) {
    var geometryNormal_5: vec3<f32>;
    var snow_1: f32;
    var targetRoughness_1: f32;
    var normalFlattening_1: f32;

    geometryNormal_5 = geometryNormal_4;
    snow_1 = snow;
    targetRoughness_1 = targetRoughness;
    normalFlattening_1 = normalFlattening;
    let _e103: f32 = snow_1;
    if (_e103 <= 0f) {
        return;
    }
    let _e107: SurfaceData = (*surfaceData_36);
    let _e109: vec4<f32> = global_1.scene_SurfaceSnowColor;
    let _e111: f32 = snow_1;
    (*surfaceData_36).albedoColor = mix(_e107.albedoColor, _e109.xyz, vec3(_e111));
    let _e115: SurfaceData = (*surfaceData_36);
    let _e118: f32 = snow_1;
    (*surfaceData_36).metallic = mix(_e115.metallic, 0f, _e118);
    let _e121: SurfaceData = (*surfaceData_36);
    let _e123: f32 = targetRoughness_1;
    let _e124: f32 = snow_1;
    (*surfaceData_36).roughness = mix(_e121.roughness, _e123, _e124);
    let _e127: SurfaceData = (*surfaceData_36);
    let _e130: f32 = snow_1;
    (*surfaceData_36).specularIntensity = mix(_e127.specularIntensity, 0.68f, _e130);
    let _e133: SurfaceData = (*surfaceData_36);
    let _e135: vec3<f32> = geometryNormal_5;
    let _e137: f32 = snow_1;
    let _e138: f32 = normalFlattening_1;
    (*surfaceData_36).normal = normalize(mix(_e133.normal, normalize(_e135), vec3((_e137 * _e138))));
    return;
}

fn terrainProjectApplySurfaceClimate(surfaceData_37: ptr<function, SurfaceData>, geometryNormal_6: vec3<f32>, response_6: vec3<f32>) {
    var geometryNormal_7: vec3<f32>;
    var response_7: vec3<f32>;
    var snow_2: f32;

    geometryNormal_7 = geometryNormal_6;
    response_7 = response_6;
    let _e100: vec3<f32> = geometryNormal_7;
    let _e101: vec3<f32> = response_7;
    terrainProjectApplySurfaceMoisture(surfaceData_37, _e100, _e101.xy);
    let _e104: SurfaceData = (*surfaceData_37);
    let _e106: vec3<f32> = geometryNormal_7;
    let _e107: vec3<f32> = response_7;
    let _e109: f32 = terrainProjectTopSnowMask(_e104.position, _e106, _e107.z);
    snow_2 = _e109;
    let _e112: vec3<f32> = geometryNormal_7;
    let _e113: f32 = snow_2;
    terrainProjectApplyTopSnowLayer(surfaceData_37, _e112, _e113, 0.82f, 0.28f);
    let _e118: SurfaceData = (*surfaceData_37);
    let _e120: SurfaceData = (*surfaceData_37);
    (*surfaceData_37).dotNV = clamp(dot(_e118.normal, _e120.viewDir), 0f, 1f);
    return;
}

fn terrainProjectGrassBladeAppearanceWeight(tipWeight_1: f32) -> f32 {
    var tipWeight_2: f32;

    tipWeight_2 = tipWeight_1;
    let _e98: f32 = tipWeight_2;
    return smoothstep(TERRAIN_PROJECT_GRASS_ROOT_FUSION_HEIGHT, TERRAIN_PROJECT_GRASS_BLADE_APPEARANCE_HEIGHT, clamp(_e98, 0f, 1f));
}

fn terrainProjectGrassBladeShadeWeight(tipWeight_3: f32) -> f32 {
    var tipWeight_4: f32;

    tipWeight_4 = tipWeight_3;
    let _e98: f32 = tipWeight_4;
    let _e99: f32 = terrainProjectGrassBladeAppearanceWeight(_e98);
    let _e102: f32 = tipWeight_4;
    return (_e99 * smoothstep(0.25f, 0.95f, _e102));
}

fn terrainProjectGrassWindFieldNormal(groundNormal: vec3<f32>, carrierNormal: vec3<f32>, bentNormal: vec3<f32>) -> vec3<f32> {
    var groundNormal_1: vec3<f32>;
    var carrierNormal_1: vec3<f32>;
    var bentNormal_1: vec3<f32>;

    groundNormal_1 = groundNormal;
    carrierNormal_1 = carrierNormal;
    bentNormal_1 = bentNormal;
    let _e102: vec3<f32> = groundNormal_1;
    let _e103: vec3<f32> = carrierNormal_1;
    let _e112: vec3<f32> = bentNormal_1;
    return normalize(((_e102 + ((_e103 - vec3<f32>(0f, 1f, 0f)) * 0.45f)) + (_e112 - vec3<f32>(0f, 1f, 0f))));
}

fn terrainProjectSurfaceReliefEnabled() -> bool {
    let _e102: vec4<f32> = global.camera_SurfaceReliefOptions;
    return (_e102.x > 0.5f);
}

fn terrainProjectSurfaceReliefWeight(worldPosition_4: vec3<f32>) -> f32 {
    var worldPosition_5: vec3<f32>;

    worldPosition_5 = worldPosition_4;
    let _e104: bool = terrainProjectSurfaceReliefEnabled();
    if !(_e104) {
        return 0f;
    }
    let _e110: vec3<f32> = global.camera_Position;
    let _e111: vec3<f32> = worldPosition_5;
    return (1f - smoothstep(50f, 60f, distance(_e110, _e111)));
}

fn terrainProjectSurfaceReliefPattern(worldXZ_14: vec2<f32>) -> f32 {
    var worldXZ_15: vec2<f32>;
    var patternUV: vec2<f32>;
    var colorField: f32;

    worldXZ_15 = worldXZ_14;
    let _e104: vec2<f32> = worldXZ_15;
    patternUV = ((_e104 * vec2<f32>(1f, -1f)) * 0.05f);
    let _e115: vec2<f32> = patternUV;
    let _e117: vec2<f32> = vec2(2f);
    patternUV = (vec2(1f) - abs(((_e115 - (floor((_e115 / _e117)) * _e117)) - vec2(1f))));
    let _e129: vec2<f32> = patternUV;
    patternUV.y = (1f - _e129.y);
    let _e132: vec2<f32> = patternUV;
    let _e134: vec4<f32> = textureSampleLevel(gs_wgpu_tex_camera_SurfaceReliefHeightTexture, gs_wgpu_samp_camera_SurfaceReliefHeightTexture, _e132, 0f);
    colorField = _e134.x;
    let _e137: f32 = colorField;
    return clamp(((_e137 - 0.17524087f) / 0.79473084f), 0f, 1f);
}

fn terrainProjectSurfaceReliefMask(worldXZ_16: vec2<f32>) -> vec3<f32> {
    var worldXZ_17: vec2<f32>;
    var resolution: f32;
    var maskUV: vec2<f32>;

    worldXZ_17 = worldXZ_16;
    let _e104: vec4<f32> = global.camera_SurfaceReliefDomain;
    resolution = _e104.w;
    let _e107: vec2<f32> = worldXZ_17;
    let _e108: vec4<f32> = global.camera_SurfaceReliefDomain;
    let _e111: vec4<f32> = global.camera_SurfaceReliefDomain;
    let _e120: f32 = resolution;
    let _e127: f32 = resolution;
    maskUV = (((clamp(((_e107 - _e108.xy) / vec2(_e111.z)), vec2(0f), vec2(1f)) * (_e120 - 1f)) + vec2(0.5f)) / vec2(_e127));
    let _e131: vec2<f32> = maskUV;
    let _e132: vec4<f32> = textureSample(gs_wgpu_tex_camera_SurfaceReliefMaskTexture, gs_wgpu_samp_camera_SurfaceReliefMaskTexture, _e131);
    return _e132.xyz;
}

fn terrainProjectSurfaceReliefPatternGradient(worldXZ_18: vec2<f32>) -> vec2<f32> {
    var worldXZ_19: vec2<f32>;
    var normal_8: vec3<f32>;

    worldXZ_19 = worldXZ_18;
    let _e104: vec2<f32> = worldXZ_19;
    let _e105: vec4<f32> = global.camera_SurfaceReliefBakedDomain;
    let _e109: vec4<f32> = textureSample(gs_wgpu_tex_camera_SurfaceReliefBakedNormal, gs_wgpu_samp_camera_SurfaceReliefBakedNormal, (_e104 / vec2(_e105.z)));
    normal_8 = ((_e109.xyz * 2f) - vec3(1f));
    let _e117: vec3<f32> = normal_8;
    let _e120: vec3<f32> = normal_8;
    return (-(_e117.xz) / vec2(max(_e120.y, 0.00001f)));
}

fn terrainProjectSurfaceReliefGradient(worldXZ_20: vec2<f32>) -> vec2<f32> {
    var worldXZ_21: vec2<f32>;
    var gradient: vec2<f32>;
    var maskData: vec3<f32>;
    var mask: f32;
    var maskGradient: vec2<f32>;
    var heightOffset: f32;

    worldXZ_21 = worldXZ_20;
    let _e104: vec2<f32> = worldXZ_21;
    let _e105: vec2<f32> = terrainProjectSurfaceReliefPatternGradient(_e104);
    gradient = _e105;
    {
        let _e107: vec2<f32> = worldXZ_21;
        let _e108: vec3<f32> = terrainProjectSurfaceReliefMask(_e107);
        maskData = _e108;
        let _e110: vec3<f32> = maskData;
        mask = _e110.x;
        let _e113: vec3<f32> = maskData;
        maskGradient = (((_e113.yz * 255f) - vec2(128f)) / vec2(91.94594f));
        let _e128: vec2<f32> = worldXZ_21;
        let _e129: f32 = terrainProjectSurfaceReliefPattern(_e128);
        heightOffset = (-1.8f * (_e129 - 0.79318225f));
        let _e134: f32 = mask;
        let _e135: vec2<f32> = gradient;
        let _e137: f32 = heightOffset;
        let _e138: vec2<f32> = maskGradient;
        gradient = ((_e134 * _e135) + (_e137 * _e138));
    }
    let _e141: vec2<f32> = gradient;
    return _e141;
}

fn terrainProjectApplyReliefGradient(terrainNormal: vec3<f32>, gradient_1: vec2<f32>, influence: f32) -> vec3<f32> {
    var terrainNormal_1: vec3<f32>;
    var gradient_2: vec2<f32>;
    var influence_1: f32;
    var normal_9: vec3<f32>;

    terrainNormal_1 = terrainNormal;
    gradient_2 = gradient_1;
    influence_1 = influence;
    let _e108: vec3<f32> = terrainNormal_1;
    let _e109: vec2<f32> = gradient_2;
    let _e112: vec2<f32> = gradient_2;
    let _e115: vec3<f32> = terrainNormal_1;
    normal_9 = normalize((_e108 - (vec3<f32>(_e109.x, 0f, _e112.y) * _e115.y)));
    let _e121: vec3<f32> = terrainNormal_1;
    let _e122: vec3<f32> = normal_9;
    let _e123: f32 = influence_1;
    return normalize(mix(_e121, _e122, vec3(_e123)));
}

fn terrainProjectSurfaceReliefNormal(worldPosition_6: vec3<f32>, terrainNormal_2: vec3<f32>, grassCoverage: f32) -> vec3<f32> {
    var worldPosition_7: vec3<f32>;
    var terrainNormal_3: vec3<f32>;
    var grassCoverage_1: f32;
    var local_2: f32;
    var influence_2: f32;

    worldPosition_7 = worldPosition_6;
    terrainNormal_3 = terrainNormal_2;
    grassCoverage_1 = grassCoverage;
    let _e108: vec4<f32> = global.camera_SurfaceReliefOptions;
    if (_e108.y > 0.5f) {
        local_2 = 1f;
    } else {
        let _e113: f32 = grassCoverage_1;
        local_2 = clamp(_e113, 0f, 1f);
    }
    let _e118: f32 = local_2;
    influence_2 = _e118;
    let _e120: vec3<f32> = terrainNormal_3;
    let _e121: vec3<f32> = worldPosition_7;
    let _e123: vec2<f32> = terrainProjectSurfaceReliefGradient(_e121.xz);
    let _e124: f32 = influence_2;
    let _e125: vec3<f32> = terrainProjectApplyReliefGradient(_e120, _e123, _e124);
    return _e125;
}

fn terrainProjectGroundWindColorNormal(baseNormalWS: vec3<f32>, windFieldNormalWS: vec3<f32>, heightWeight: f32, colorContrast: f32) -> vec3<f32> {
    var baseNormalWS_1: vec3<f32>;
    var windFieldNormalWS_1: vec3<f32>;
    var heightWeight_1: f32;
    var colorContrast_1: f32;
    var baseNormal: vec3<f32>;
    var windFieldNormal: vec3<f32>;
    var contrastAmount: f32;
    var normalGain: f32;

    baseNormalWS_1 = baseNormalWS;
    windFieldNormalWS_1 = windFieldNormalWS;
    heightWeight_1 = heightWeight;
    colorContrast_1 = colorContrast;
    let _e110: vec3<f32> = baseNormalWS_1;
    baseNormal = normalize(_e110);
    let _e113: vec3<f32> = windFieldNormalWS_1;
    windFieldNormal = normalize(_e113);
    let _e116: f32 = colorContrast_1;
    contrastAmount = clamp(((_e116 - 0.5f) / 3.5f), 0f, 1f);
    let _e127: f32 = contrastAmount;
    normalGain = mix(0.9f, 1.1f, _e127);
    let _e130: vec3<f32> = baseNormal;
    let _e131: vec3<f32> = windFieldNormal;
    let _e137: f32 = normalGain;
    let _e138: f32 = heightWeight_1;
    return normalize((_e130 + ((_e131 - vec3<f32>(0f, 1f, 0f)) * (_e137 * clamp(_e138, 0f, 1f)))));
}

fn terrainProjectGroundWindLightingBand(rawLightingSweep: f32, baseLightingSweep: f32, colorContrast_2: f32) -> f32 {
    var rawLightingSweep_1: f32;
    var baseLightingSweep_1: f32;
    var colorContrast_3: f32;
    var contrastAmount_1: f32;
    var rampCenter: f32;
    var rampHalfWidth: f32;

    rawLightingSweep_1 = rawLightingSweep;
    baseLightingSweep_1 = baseLightingSweep;
    colorContrast_3 = colorContrast_2;
    let _e108: f32 = colorContrast_3;
    contrastAmount_1 = clamp(((_e108 - 0.5f) / 3.5f), 0f, 1f);
    let _e118: f32 = baseLightingSweep_1;
    rampCenter = clamp(mix(0.5f, _e118, 0.12f), 0.42f, 0.58f);
    let _e127: f32 = contrastAmount_1;
    rampHalfWidth = mix(0.32f, 0.06f, _e127);
    let _e130: f32 = rampCenter;
    let _e131: f32 = rampHalfWidth;
    let _e133: f32 = rampCenter;
    let _e134: f32 = rampHalfWidth;
    let _e136: f32 = rawLightingSweep_1;
    return smoothstep((_e130 - _e131), (_e133 + _e134), clamp(_e136, 0f, 1f));
}

fn terrainProjectGroundWindDarkMix(lightingSweep: f32, colorContrast_4: f32) -> f32 {
    var lightingSweep_1: f32;
    var colorContrast_5: f32;
    var shadowResponse: f32;
    var shapedShadowResponse: f32;

    lightingSweep_1 = lightingSweep;
    colorContrast_5 = colorContrast_4;
    let _e107: f32 = lightingSweep_1;
    shadowResponse = (1f - clamp(_e107, 0f, 1f));
    let _e113: f32 = shadowResponse;
    let _e115: f32 = colorContrast_5;
    shapedShadowResponse = pow(_e113, (1f / max(_e115, 0.001f)));
    let _e122: f32 = shapedShadowResponse;
    return (0.811136f * _e122);
}

fn terrainProjectApplyGroundWindLightingColor(litColor: vec3<f32>, inheritedShadowColor: vec3<f32>, lightingSweep_2: f32, colorStrength: f32, colorContrast_6: f32) -> vec3<f32> {
    var litColor_1: vec3<f32>;
    var inheritedShadowColor_1: vec3<f32>;
    var lightingSweep_3: f32;
    var colorStrength_1: f32;
    var colorContrast_7: f32;
    var strength: f32;
    var darkMix: f32;
    var colorized: vec3<f32>;
    var multiplyMask: f32;

    litColor_1 = litColor;
    inheritedShadowColor_1 = inheritedShadowColor;
    lightingSweep_3 = lightingSweep_2;
    colorStrength_1 = colorStrength;
    colorContrast_7 = colorContrast_6;
    let _e112: f32 = colorStrength_1;
    strength = clamp(_e112, 0f, 1f);
    let _e117: f32 = lightingSweep_3;
    let _e118: f32 = colorContrast_7;
    let _e119: f32 = terrainProjectGroundWindDarkMix(_e117, _e118);
    darkMix = _e119;
    let _e121: vec3<f32> = litColor_1;
    let _e122: vec3<f32> = inheritedShadowColor_1;
    let _e123: f32 = darkMix;
    let _e124: f32 = strength;
    colorized = mix(_e121, _e122, vec3((_e123 * _e124)));
    let _e130: f32 = darkMix;
    multiplyMask = (1f - _e130);
    let _e133: vec3<f32> = colorized;
    let _e134: vec3<f32> = colorized;
    let _e135: f32 = multiplyMask;
    let _e138: f32 = strength;
    return mix(_e133, (_e134 * _e135), vec3((0.275f * _e138)));
}

fn terrainProjectApplyGrassGroundWindColor(litColor_2: vec3<f32>, lightingSweep_4: f32, colorStrength_2: f32, colorContrast_8: f32) -> vec3<f32> {
    var litColor_3: vec3<f32>;
    var lightingSweep_5: f32;
    var colorStrength_3: f32;
    var colorContrast_9: f32;
    var inheritedShadowColor_2: vec3<f32>;

    litColor_3 = litColor_2;
    lightingSweep_5 = lightingSweep_4;
    colorStrength_3 = colorStrength_2;
    colorContrast_9 = colorContrast_8;
    let _e110: vec3<f32> = litColor_3;
    inheritedShadowColor_2 = (max(_e110, vec3(0f)) * 0.24f);
    let _e117: vec3<f32> = litColor_3;
    let _e118: vec3<f32> = inheritedShadowColor_2;
    let _e119: f32 = lightingSweep_5;
    let _e120: f32 = colorStrength_3;
    let _e121: f32 = colorContrast_9;
    let _e122: vec3<f32> = terrainProjectApplyGroundWindLightingColor(_e117, _e118, _e119, _e120, _e121);
    return _e122;
}

fn terrainProjectGroundWindLightingSweep(normalWS_2: vec3<f32>) -> f32 {
    var normalWS_3: vec3<f32>;
    var normalizedNormal: vec3<f32>;
    var weightedDiffuse: f32 = 0f;
    var totalLightWeight: f32 = 0f;
    var local_3: f32;

    normalWS_3 = normalWS_2;
    let _e104: vec3<f32> = normalWS_3;
    normalizedNormal = normalize(_e104);
    let _e111: f32 = totalLightWeight;
    if (_e111 > 0.0001f) {
        let _e114: f32 = weightedDiffuse;
        let _e115: f32 = totalLightWeight;
        local_3 = clamp((_e114 / _e115), 0f, 1f);
    } else {
        let _e120: vec3<f32> = normalizedNormal;
        local_3 = clamp(_e120.y, 0f, 1f);
    }
    let _e126: f32 = local_3;
    return _e126;
}

fn GrassFragment(input: Varyings) {
    var input_1: Varyings;
    var surfaceWeights_1: vec3<f32>;
    var surfaceWeight: f32;
    var local_4: vec3<f32>;
    var bladeAppearanceWeight: f32;
    var grassSurfaceColor: vec3<f32>;
    var surfaceColor: vec3<f32>;
    var bladeShadeWeight: f32;
    var detailGroundNormal: vec3<f32>;
    var windFieldNormal_1: vec3<f32>;
    var shadingNormal: vec3<f32>;
    var groundWindColorWeight: f32;
    var surfaceData_38: SurfaceData;
    var groundSnowResponse: f32;
    var snowResponse: f32;
    var climateNormal: vec3<f32>;
    var shadowAttenuation_4: f32;
    var color_8: vec3<f32>;
    var groundWindColorContrast: f32;
    var groundWindColorNormal: vec3<f32>;
    var groundWindRawLightingSweep: f32;
    var groundWindBaseLightingSweep: f32;
    var groundWindLightingSweep: f32;

    input_1 = input;
    let _e104: Varyings = input_1;
    surfaceWeights_1 = max(_e104.surfaceWeights, vec3(0f));
    let _e110: vec3<f32> = surfaceWeights_1;
    surfaceWeight = dot(_e110, vec3(1f));
    let _e115: f32 = surfaceWeight;
    if (_e115 > 0.00001f) {
        let _e118: vec3<f32> = surfaceWeights_1;
        let _e119: f32 = surfaceWeight;
        local_4 = (_e118 / vec3(_e119));
    } else {
        local_4 = vec3<f32>(1f, 0f, 0f);
    }
    let _e127: vec3<f32> = local_4;
    surfaceWeights_1 = _e127;
    let _e128: Varyings = input_1;
    let _e130: f32 = terrainProjectGrassBladeAppearanceWeight(_e128.tipWeight);
    bladeAppearanceWeight = _e130;
    let _e132: Varyings = input_1;
    grassSurfaceColor = _e132.grassColor;
    let _e135: vec3<f32> = grassSurfaceColor;
    let _e136: vec3<f32> = surfaceWeights_1;
    let _e139: vec4<f32> = global_1.renderer_GrassRoadColor;
    let _e141: vec3<f32> = surfaceWeights_1;
    let _e145: vec4<f32> = global_1.material_GrassGroundColor;
    let _e147: vec3<f32> = surfaceWeights_1;
    surfaceColor = (((_e135 * _e136.x) + (_e139.xyz * _e141.y)) + (_e145.xyz * _e147.z));
    let _e152: Varyings = input_1;
    let _e154: f32 = terrainProjectGrassBladeShadeWeight(_e152.tipWeight);
    bladeShadeWeight = _e154;
    let _e156: Varyings = input_1;
    detailGroundNormal = _e156.terrainNormalWS;
    let _e159: vec3<f32> = detailGroundNormal;
    let _e160: Varyings = input_1;
    let _e162: Varyings = input_1;
    let _e164: vec3<f32> = terrainProjectGrassWindFieldNormal(_e159, _e160.windCarrierNormalWS, _e162.windBentNormalWS);
    windFieldNormal_1 = _e164;
    let _e166: Varyings = input_1;
    let _e168: vec3<f32> = windFieldNormal_1;
    let _e169: f32 = bladeShadeWeight;
    shadingNormal = normalize(mix(_e166.terrainNormalWS, _e168, vec3(_e169)));
    let _e174: vec4<f32> = global.scene_GroundWindShape;
    let _e179: f32 = bladeShadeWeight;
    groundWindColorWeight = (clamp(_e174.z, 0f, 1f) * _e179);
    let _e182: Varyings = input_1;
    let _e183: vec3<f32> = surfaceColor;
    let _e184: vec3<f32> = shadingNormal;
    let _e188: SurfaceData = terrainProjectBuildSurfaceData(_e182, _e183, _e184, 0f, 0f, 1f);
    surfaceData_38 = _e188;
    let _e190: vec3<f32> = surfaceWeights_1;
    let _e191: vec4<f32> = global.material_GrassSurfaceSnowResponse;
    groundSnowResponse = dot(_e190, _e191.xyz);
    let _e195: vec4<f32> = global.scene_SurfaceClimate;
    let _e196: vec4<f32> = global.scene_SurfaceClimate;
    if (dot(_e195, _e196) > 0f) {
        {
            let _e200: f32 = groundSnowResponse;
            let _e201: vec4<f32> = global.material_GrassSurfaceSnowResponse;
            let _e203: f32 = bladeAppearanceWeight;
            snowResponse = mix(_e200, _e201.w, _e203);
            let _e206: Varyings = input_1;
            let _e208: vec3<f32> = windFieldNormal_1;
            let _e209: f32 = bladeAppearanceWeight;
            climateNormal = normalize(mix(_e206.terrainNormalWS, _e208, vec3(_e209)));
            let _e215: vec3<f32> = climateNormal;
            let _e218: f32 = snowResponse;
            terrainProjectApplySurfaceClimate((&surfaceData_38), _e215, vec3<f32>(1f, 0f, _e218));
        }
    }
    let _e221: Varyings = input_1;
    let _e222: f32 = sampleTerrainProjectShadow(_e221);
    shadowAttenuation_4 = _e222;
    let _e224: Varyings = input_1;
    let _e225: SurfaceData = surfaceData_38;
    let _e226: f32 = shadowAttenuation_4;
    let _e227: TerrainProjectLightingResult = evaluateTerrainProjectLightingWithShadow(_e224, _e225, _e226);
    let _e228: vec3<f32> = terrainProjectFinalLighting(_e227);
    color_8 = max(_e228, vec3(0f));
    let _e233: f32 = groundWindColorWeight;
    if (_e233 > 0f) {
        {
            let _e236: vec4<f32> = global.scene_GroundWindAdvection;
            groundWindColorContrast = max(_e236.z, 0.001f);
            let _e241: Varyings = input_1;
            let _e243: Varyings = input_1;
            let _e245: f32 = bladeShadeWeight;
            let _e246: f32 = groundWindColorContrast;
            let _e247: vec3<f32> = terrainProjectGroundWindColorNormal(_e241.terrainNormalWS, _e243.windCarrierNormalWS, _e245, _e246);
            groundWindColorNormal = _e247;
            let _e249: vec3<f32> = groundWindColorNormal;
            let _e250: f32 = terrainProjectGroundWindLightingSweep(_e249);
            groundWindRawLightingSweep = _e250;
            let _e252: Varyings = input_1;
            let _e254: f32 = terrainProjectGroundWindLightingSweep(_e252.terrainNormalWS);
            groundWindBaseLightingSweep = _e254;
            let _e256: f32 = groundWindRawLightingSweep;
            let _e257: f32 = groundWindBaseLightingSweep;
            let _e258: f32 = groundWindColorContrast;
            let _e259: f32 = terrainProjectGroundWindLightingBand(_e256, _e257, _e258);
            groundWindLightingSweep = _e259;
            let _e261: vec3<f32> = color_8;
            let _e262: f32 = groundWindLightingSweep;
            let _e263: f32 = groundWindColorWeight;
            let _e264: f32 = groundWindColorContrast;
            let _e265: vec3<f32> = terrainProjectApplyGrassGroundWindColor(_e261, _e262, _e263, _e264);
            color_8 = _e265;
        }
    }
    let _e266: vec4<f32> = global_1.renderer_GrassLodDebugColor;
    if (_e266.w > 0f) {
        {
            let _e270: vec3<f32> = color_8;
            let _e271: vec4<f32> = global_1.renderer_GrassLodDebugColor;
            let _e273: vec4<f32> = global_1.renderer_GrassLodDebugColor;
            color_8 = mix(_e270, _e271.xyz, vec3(_e273.w));
        }
    }
    let _e277: vec3<f32> = color_8;
    converted_FragColor = vec4<f32>(_e277.x, _e277.y, _e277.z, 1f);
    return;
}

fn gs_wgpu_main() {
    var input_input: Varyings;

    let _e102: Varyings = read_Varyings();
    input_input = _e102;
    let _e104: Varyings = input_input;
    GrassFragment(_e104);
    return;
}

fn main_1() {
    let _e106: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e112: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e118: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e106.x), bitcast<f32>(_e112.y), bitcast<f32>(_e118.z));
    let _e126: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e126.w);
    let _e133: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e133.x);
    let _e140: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e140.y);
    let _e147: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e147.z);
    let _e154: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e154.w);
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) rootPositionWS: vec3<f32>, @location(1) terrainNormalWS: vec3<f32>, @location(2) positionWS: vec3<f32>, @location(3) grassColor: vec3<f32>, @location(4) surfaceWeights: vec3<f32>, @location(5) tipWeight: f32, @location(6) windCarrierNormalWS: vec3<f32>, @location(7) windBentNormalWS: vec3<f32>, @location(8) positionCS: vec4<f32>) -> FragmentOutput {
    rootPositionWS_1 = rootPositionWS;
    terrainNormalWS_1 = terrainNormalWS;
    positionWS_3 = positionWS;
    grassColor_1 = grassColor;
    surfaceWeights_2 = surfaceWeights;
    tipWeight_5 = tipWeight;
    windCarrierNormalWS_1 = windCarrierNormalWS;
    windBentNormalWS_1 = windBentNormalWS;
    positionCS_1 = positionCS;
    main_1();
    let _e142: vec4<f32> = converted_FragColor;
    return FragmentOutput(_e142);
}
