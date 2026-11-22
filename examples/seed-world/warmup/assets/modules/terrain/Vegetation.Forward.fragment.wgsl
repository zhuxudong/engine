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

struct Varyings {
    uv: vec2<f32>,
    positionWS: vec3<f32>,
    normalWS: vec3<f32>,
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

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> converted_FragColor: vec4<f32>;
var<private> uv_5: vec2<f32>;
var<private> positionWS_3: vec3<f32>;
var<private> normalWS_3: vec3<f32>;
var<private> positionCS_1: vec4<f32>;
@group(2) @binding(2) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;
var<private> gl_FragCoord_1: vec4<f32>;
var<private> gl_FrontFacing_1: bool;

fn pow2_(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e201: f32 = x_1;
    let _e202: f32 = x_1;
    return (_e201 * _e202);
}

fn texture2DSRGB(gs_wgpu_tex_tex: texture_2d<f32>, gs_wgpu_samp_tex: sampler, uv_1: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;

    uv_2 = uv_1;
    let _e203: vec2<f32> = uv_2;
    let _e204: vec4<f32> = textureSample(gs_wgpu_tex_tex, gs_wgpu_samp_tex, _e203);
    return _e204;
}

fn remapDepthBufferEyeDepth(depth: f32) -> f32 {
    var depth_1: f32;

    depth_1 = depth;
    let _e202: vec4<f32> = global_1.camera_DepthBufferParams;
    let _e204: f32 = depth_1;
    let _e206: vec4<f32> = global_1.camera_DepthBufferParams;
    return (1f / ((_e202.z * _e204) + _e206.w));
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e205: vec2<f32> = uv_5;
    interface_value.uv = _e205;
    let _e207: vec3<f32> = positionWS_3;
    interface_value.positionWS = _e207;
    let _e209: vec3<f32> = normalWS_3;
    interface_value.normalWS = _e209;
    let _e211: vec4<f32> = positionCS_1;
    interface_value.positionCS = _e211;
    let _e212: Varyings = interface_value;
    return _e212;
}

fn getAARoughnessFactor(normal: vec3<f32>) -> f32 {
    var normal_1: vec3<f32>;
    var dxy: vec3<f32>;

    normal_1 = normal;
    let _e205: vec3<f32> = normal_1;
    let _e206: vec3<f32> = dpdx(_e205);
    let _e208: vec3<f32> = normal_1;
    let _e209: vec3<f32> = dpdy(_e208);
    dxy = max(abs(_e206), abs(-(_e209)));
    let _e214: vec3<f32> = dxy;
    let _e216: vec3<f32> = dxy;
    let _e219: vec3<f32> = dxy;
    return max(max(_e214.x, _e216.y), _e219.z);
}

fn F_Schlick(f0_: f32, f90_: f32, dotLH: f32) -> f32 {
    var f0_1: f32;
    var f90_1: f32;
    var dotLH_1: f32;

    f0_1 = f0_;
    f90_1 = f90_;
    dotLH_1 = dotLH;
    let _e209: f32 = f0_1;
    let _e210: f32 = f90_1;
    let _e211: f32 = f0_1;
    let _e214: f32 = dotLH_1;
    return (_e209 + ((_e210 - _e211) * pow((1f - _e214), 5f)));
}

fn F_Schlick_1(f0_2: vec3<f32>, f90_2: f32, dotLH_2: f32) -> vec3<f32> {
    var f0_3: vec3<f32>;
    var f90_3: f32;
    var dotLH_3: f32;
    var fresnel: f32;

    f0_3 = f0_2;
    f90_3 = f90_2;
    dotLH_3 = dotLH_2;
    let _e211: f32 = dotLH_3;
    let _e215: f32 = dotLH_3;
    fresnel = exp2((((-5.55473f * _e211) - 6.98316f) * _e215));
    let _e219: f32 = f90_3;
    let _e220: vec3<f32> = f0_3;
    let _e223: f32 = fresnel;
    let _e225: vec3<f32> = f0_3;
    return (((vec3(_e219) - _e220) * _e223) + _e225);
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
    let _e209: f32 = alpha_1;
    let _e210: f32 = pow2_(_e209);
    a2_ = _e210;
    let _e212: f32 = dotNL_1;
    let _e213: f32 = a2_;
    let _e215: f32 = a2_;
    let _e217: f32 = dotNV_1;
    let _e218: f32 = pow2_(_e217);
    gv = (_e212 * sqrt((_e213 + ((1f - _e215) * _e218))));
    let _e224: f32 = dotNV_1;
    let _e225: f32 = a2_;
    let _e227: f32 = a2_;
    let _e229: f32 = dotNL_1;
    let _e230: f32 = pow2_(_e229);
    gl = (_e224 * sqrt((_e225 + ((1f - _e227) * _e230))));
    let _e237: f32 = gv;
    let _e238: f32 = gl;
    return (0.5f / max((_e237 + _e238), 0.000001f));
}

fn D_GGX(alpha_2: f32, dotNH: f32) -> f32 {
    var alpha_3: f32;
    var dotNH_1: f32;
    var a2_1: f32;
    var denom: f32;

    alpha_3 = alpha_2;
    dotNH_1 = dotNH;
    let _e207: f32 = alpha_3;
    let _e208: f32 = pow2_(_e207);
    a2_1 = _e208;
    let _e210: f32 = dotNH_1;
    let _e211: f32 = pow2_(_e210);
    let _e212: f32 = a2_1;
    denom = ((_e211 * (_e212 - 1f)) + 1f);
    let _e220: f32 = a2_1;
    let _e222: f32 = denom;
    let _e223: f32 = pow2_(_e222);
    return ((0.31830987f * _e220) / _e223);
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
    let _e211: f32 = alpha_5;
    let _e212: f32 = dotNH_3;
    let _e213: f32 = D_GGX(_e211, _e212);
    D = _e213;
    let _e215: f32 = alpha_5;
    let _e216: f32 = dotNL_3;
    let _e217: f32 = dotNV_3;
    let _e218: f32 = G_GGX_SmithCorrelated(_e215, _e216, _e217);
    G = _e218;
    let _e220: f32 = G;
    let _e221: f32 = D;
    return (_e220 * _e221);
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
    let _e215: f32 = roughness_1;
    let _e216: f32 = pow2_(_e215);
    alpha_6 = _e216;
    let _e218: vec3<f32> = incidentDirection_1;
    let _e219: SurfaceData = surfaceData_1;
    halfDir = normalize((_e218 + _e219.viewDir));
    let _e224: vec3<f32> = normal_3;
    let _e225: vec3<f32> = incidentDirection_1;
    dotNL_4 = clamp(dot(_e224, _e225), 0f, 1f);
    let _e231: vec3<f32> = normal_3;
    let _e232: SurfaceData = surfaceData_1;
    dotNV_4 = clamp(dot(_e231, _e232.viewDir), 0f, 1f);
    let _e239: vec3<f32> = normal_3;
    let _e240: vec3<f32> = halfDir;
    dotNH_4 = clamp(dot(_e239, _e240), 0f, 1f);
    let _e246: vec3<f32> = incidentDirection_1;
    let _e247: vec3<f32> = halfDir;
    dotLH_4 = clamp(dot(_e246, _e247), 0f, 1f);
    let _e253: vec3<f32> = specularColor_1;
    let _e254: BSDFData = bsdfData_1;
    let _e256: f32 = dotLH_4;
    let _e257: vec3<f32> = F_Schlick_1(_e253, _e254.specularF90_, _e256);
    F = _e257;
    let _e259: f32 = alpha_6;
    let _e260: f32 = dotNV_4;
    let _e261: f32 = dotNL_4;
    let _e262: f32 = dotNH_4;
    let _e263: f32 = DG_GGX(_e259, _e260, _e261, _e262);
    GD = _e263;
    let _e265: vec3<f32> = F;
    let _e266: f32 = GD;
    return (_e265 * _e266);
}

fn BRDF_Diffuse_Lambert(diffuseColor: vec3<f32>) -> vec3<f32> {
    var diffuseColor_1: vec3<f32>;

    diffuseColor_1 = diffuseColor;
    let _e206: vec3<f32> = diffuseColor_1;
    return (0.31830987f * _e206);
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
    let _e225: f32 = roughness_3;
    let _e226: vec4<f32> = c0_;
    let _e228: vec4<f32> = c1_;
    r = ((_e225 * _e226) + _e228);
    let _e231: vec4<f32> = r;
    let _e233: vec4<f32> = r;
    let _e238: f32 = dotNV_6;
    let _e242: vec4<f32> = r;
    let _e245: vec4<f32> = r;
    a004_ = ((min((_e231.x * _e233.x), exp2((-9.28f * _e238))) * _e242.x) + _e245.y);
    let _e253: f32 = a004_;
    let _e255: vec4<f32> = r;
    return ((vec2<f32>(-1.04f, 1.04f) * _e253) + _e255.zw);
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
    let _e211: f32 = roughness_5;
    let _e212: f32 = dotNV_8;
    let _e213: vec2<f32> = envDFGApprox(_e211, _e212);
    AB = _e213;
    let _e215: vec3<f32> = f0_5;
    let _e216: vec2<f32> = AB;
    let _e219: f32 = f90_5;
    let _e220: vec2<f32> = AB;
    return ((_e215 * _e216.x) + vec3((_e219 * _e220.y)));
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
    let _e206: SurfaceData = surfaceData_3;
    albedoColor = _e206.albedoColor;
    let _e209: SurfaceData = surfaceData_3;
    metallic = _e209.metallic;
    let _e212: SurfaceData = surfaceData_3;
    roughness_6 = _e212.roughness;
    let _e215: SurfaceData = surfaceData_3;
    let _e219: SurfaceData = surfaceData_3;
    let _e224: f32 = pow2_(((_e215.IOR - 1f) / (_e219.IOR + 1f)));
    dielectricBaseF0_ = vec3(_e224);
    let _e227: vec3<f32> = dielectricBaseF0_;
    let _e228: SurfaceData = surfaceData_3;
    let _e234: SurfaceData = surfaceData_3;
    dielectricF0_ = (min((_e227 * _e228.specularColor), vec3(1f)) * _e234.specularIntensity);
    let _e238: SurfaceData = surfaceData_3;
    dielectricF90_ = _e238.specularIntensity;
    let _e242: vec3<f32> = dielectricF0_;
    let _e243: vec3<f32> = albedoColor;
    let _e244: f32 = metallic;
    (*bsdfData_2).specularF0_ = mix(_e242, _e243, vec3(_e244));
    let _e248: f32 = dielectricF90_;
    let _e250: f32 = metallic;
    (*bsdfData_2).specularF90_ = mix(_e248, 1f, _e250);
    let _e253: vec3<f32> = albedoColor;
    let _e255: f32 = metallic;
    let _e259: vec3<f32> = dielectricF0_;
    let _e261: vec3<f32> = dielectricF0_;
    let _e264: vec3<f32> = dielectricF0_;
    (*bsdfData_2).diffuseColor = ((_e253 * (1f - _e255)) * (1f - max(max(_e259.x, _e261.y), _e264.z)));
    let _e271: f32 = roughness_6;
    let _e272: SurfaceData = surfaceData_3;
    let _e274: f32 = getAARoughnessFactor(_e272.normal);
    (*bsdfData_2).roughness = max(0.045f, min((_e271 + _e274), 1f));
    let _e280: BSDFData = (*bsdfData_2);
    (*bsdfData_2).resolvedSpecularF0_ = _e280.specularF0_;
    let _e282: BSDFData = (*bsdfData_2);
    let _e284: SurfaceData = surfaceData_3;
    let _e286: vec2<f32> = envDFGApprox(_e282.roughness, _e284.dotNV);
    dfg = _e286;
    let _e289: BSDFData = (*bsdfData_2);
    let _e291: vec2<f32> = dfg;
    let _e294: BSDFData = (*bsdfData_2);
    let _e296: vec2<f32> = dfg;
    (*bsdfData_2).envSpecularDFG = ((_e289.resolvedSpecularF0_ * _e291.x) + vec3((_e294.specularF90_ * _e296.y)));
    let _e303: BSDFData = (*bsdfData_2);
    let _e306: vec2<f32> = dfg;
    let _e308: vec2<f32> = dfg;
    (*bsdfData_2).energyCompensation = (vec3(1f) + (_e303.resolvedSpecularF0_ * ((1f / max((_e306.x + _e308.y), 0.000001f)) - 1f)));
    let _e320: SurfaceData = surfaceData_3;
    (*bsdfData_2).diffuseAO = _e320.ambientOcclusion;
    return;
}

fn getTBNByDerivatives(uv_3: vec2<f32>, normal_4: vec3<f32>, position: vec3<f32>, isFrontFacing: bool) -> mat3x3<f32> {
    var uv_4: vec2<f32>;
    var normal_5: vec3<f32>;
    var position_1: vec3<f32>;
    var isFrontFacing_1: bool;
    var local: vec2<f32>;
    var dp1_: vec3<f32>;
    var dp2_: vec3<f32>;
    var duv1_: vec2<f32>;
    var duv2_: vec2<f32>;
    var dp2perp: vec3<f32>;
    var dp1perp: vec3<f32>;
    var tangent: vec3<f32>;
    var bitangent: vec3<f32>;
    var denom_1: f32;
    var local_1: f32;
    var invmax: f32;

    uv_4 = uv_3;
    normal_5 = normal_4;
    position_1 = position;
    isFrontFacing_1 = isFrontFacing;
    let _e211: bool = isFrontFacing_1;
    if _e211 {
        let _e212: vec2<f32> = uv_4;
        local = _e212;
    } else {
        let _e213: vec2<f32> = uv_4;
        local = -(_e213);
    }
    let _e216: vec2<f32> = local;
    uv_4 = _e216;
    let _e217: vec3<f32> = position_1;
    let _e218: vec3<f32> = dpdx(_e217);
    dp1_ = _e218;
    let _e220: vec3<f32> = position_1;
    let _e221: vec3<f32> = dpdy(_e220);
    dp2_ = -(_e221);
    let _e224: vec2<f32> = uv_4;
    let _e225: vec2<f32> = dpdx(_e224);
    duv1_ = _e225;
    let _e227: vec2<f32> = uv_4;
    let _e228: vec2<f32> = dpdy(_e227);
    duv2_ = -(_e228);
    let _e231: vec3<f32> = dp2_;
    let _e232: vec3<f32> = normal_5;
    dp2perp = cross(_e231, _e232);
    let _e235: vec3<f32> = normal_5;
    let _e236: vec3<f32> = dp1_;
    dp1perp = cross(_e235, _e236);
    let _e239: vec3<f32> = dp2perp;
    let _e240: vec2<f32> = duv1_;
    let _e243: vec3<f32> = dp1perp;
    let _e244: vec2<f32> = duv2_;
    tangent = ((_e239 * _e240.x) + (_e243 * _e244.x));
    let _e249: vec3<f32> = dp2perp;
    let _e250: vec2<f32> = duv1_;
    let _e253: vec3<f32> = dp1perp;
    let _e254: vec2<f32> = duv2_;
    bitangent = ((_e249 * _e250.y) + (_e253 * _e254.y));
    let _e259: vec3<f32> = tangent;
    let _e260: vec3<f32> = tangent;
    let _e262: vec3<f32> = bitangent;
    let _e263: vec3<f32> = bitangent;
    denom_1 = max(dot(_e259, _e260), dot(_e262, _e263));
    let _e267: f32 = denom_1;
    if (_e267 == 0f) {
        local_1 = 0f;
    } else {
        let _e271: vec4<f32> = global.camera_ProjectionParams;
        let _e273: f32 = denom_1;
        local_1 = (_e271.x / sqrt(_e273));
    }
    let _e277: f32 = local_1;
    invmax = _e277;
    let _e279: vec3<f32> = tangent;
    let _e280: f32 = invmax;
    let _e281: vec3<f32> = (_e279 * _e280);
    let _e282: vec3<f32> = bitangent;
    let _e283: f32 = invmax;
    let _e284: vec3<f32> = (_e282 * _e283);
    let _e285: vec3<f32> = normal_5;
    return mat3x3<f32>(vec3<f32>(_e281.x, _e281.y, _e281.z), vec3<f32>(_e284.x, _e284.y, _e284.z), vec3<f32>(_e285.x, _e285.y, _e285.z));
}

fn sampleVegetationBaseTexture(materialUv: vec2<f32>) -> vec4<f32> {
    var materialUv_1: vec2<f32>;
    var baseTexture: vec4<f32> = vec4(1f);

    materialUv_1 = materialUv;
    let _e208: vec4<f32> = baseTexture;
    return _e208;
}

fn sampleProceduralTreeLeafMask(materialUv_2: vec2<f32>, shapeIndex: f32) -> vec4<f32> {
    var materialUv_3: vec2<f32>;
    var shapeIndex_1: f32;

    materialUv_3 = materialUv_2;
    shapeIndex_1 = shapeIndex;
    let _e207: vec2<f32> = materialUv_3;
    let _e208: vec4<f32> = sampleVegetationBaseTexture(_e207);
    return _e208;
}

fn applyVegetationAlphaCutoff(alpha_7: f32) {
    var alpha_8: f32;

    alpha_8 = alpha_7;
    let _e205: f32 = alpha_8;
    let _e206: f32 = global_1.material_AlphaCutoff;
    if (_e205 < _e206) {
        {
            discard;
        }
    } else {
        return;
    }
}

fn terrainProjectApplySeasonColor(sourceColor: vec3<f32>, seasonColor: vec4<f32>) -> vec3<f32> {
    var sourceColor_1: vec3<f32>;
    var seasonColor_1: vec4<f32>;
    var sourceLuminance: f32;
    var seasonTone: vec3<f32>;

    sourceColor_1 = sourceColor;
    seasonColor_1 = seasonColor;
    let _e207: vec3<f32> = sourceColor_1;
    sourceLuminance = dot(_e207, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e214: vec4<f32> = seasonColor_1;
    let _e216: f32 = sourceLuminance;
    seasonTone = (_e214.xyz * _e216);
    let _e219: vec3<f32> = sourceColor_1;
    let _e220: vec3<f32> = seasonTone;
    let _e221: vec4<f32> = seasonColor_1;
    return mix(_e219, _e220, vec3(clamp(_e221.w, 0f, 1f)));
}

fn terrainProjectApplyAuthoredSeasonColor(sourceColor_2: vec3<f32>, seasonColor_2: vec4<f32>, authoredChannels: vec3<f32>) -> vec3<f32> {
    var sourceColor_3: vec3<f32>;
    var seasonColor_3: vec4<f32>;
    var authoredChannels_1: vec3<f32>;

    sourceColor_3 = sourceColor_2;
    seasonColor_3 = seasonColor_2;
    authoredChannels_1 = authoredChannels;
    let _e209: vec3<f32> = sourceColor_3;
    let _e210: vec4<f32> = seasonColor_3;
    let _e211: vec3<f32> = terrainProjectApplySeasonColor(_e209, _e210);
    let _e212: vec3<f32> = sourceColor_3;
    let _e213: vec3<f32> = authoredChannels_1;
    return mix(_e211, _e212, _e213);
}

fn terrainProjectPlantAuthoredChannels() -> vec3<f32> {
    var mask: vec3<f32> = vec3(0f);

    let _e206: vec3<f32> = mask;
    return _e206;
}

fn terrainProjectSurfaceClimateHash(cell: vec2<f32>) -> f32 {
    var cell_1: vec2<f32>;

    cell_1 = cell;
    let _e205: vec2<f32> = cell_1;
    return fract((sin(dot(_e205, vec2<f32>(127.1f, 311.7f))) * 43758.547f));
}

fn terrainProjectSurfaceClimateValueNoise(position_2: vec2<f32>) -> f32 {
    var position_3: vec2<f32>;
    var cell_2: vec2<f32>;
    var local_2: vec2<f32>;
    var blend: vec2<f32>;
    var lower: f32;
    var upper: f32;

    position_3 = position_2;
    let _e205: vec2<f32> = position_3;
    cell_2 = floor(_e205);
    let _e208: vec2<f32> = position_3;
    local_2 = fract(_e208);
    let _e211: vec2<f32> = local_2;
    let _e212: vec2<f32> = local_2;
    let _e216: vec2<f32> = local_2;
    blend = ((_e211 * _e212) * (vec2(3f) - (2f * _e216)));
    let _e222: vec2<f32> = cell_2;
    let _e223: f32 = terrainProjectSurfaceClimateHash(_e222);
    let _e224: vec2<f32> = cell_2;
    let _e229: f32 = terrainProjectSurfaceClimateHash((_e224 + vec2<f32>(1f, 0f)));
    let _e230: vec2<f32> = blend;
    lower = mix(_e223, _e229, _e230.x);
    let _e234: vec2<f32> = cell_2;
    let _e239: f32 = terrainProjectSurfaceClimateHash((_e234 + vec2<f32>(0f, 1f)));
    let _e240: vec2<f32> = cell_2;
    let _e245: f32 = terrainProjectSurfaceClimateHash((_e240 + vec2<f32>(1f, 1f)));
    let _e246: vec2<f32> = blend;
    upper = mix(_e239, _e245, _e246.x);
    let _e250: f32 = lower;
    let _e251: f32 = upper;
    let _e252: vec2<f32> = blend;
    return mix(_e250, _e251, _e252.y);
}

fn terrainProjectSurfaceClimateNoise(worldXZ: vec2<f32>) -> f32 {
    var worldXZ_1: vec2<f32>;
    var broad: f32;
    var detail: f32;

    worldXZ_1 = worldXZ;
    let _e205: vec2<f32> = worldXZ_1;
    let _e208: f32 = terrainProjectSurfaceClimateValueNoise((_e205 * 0.055f));
    broad = _e208;
    let _e210: vec2<f32> = worldXZ_1;
    let _e217: f32 = terrainProjectSurfaceClimateValueNoise(((_e210 * 0.17f) + vec2<f32>(19.7f, 43.1f)));
    detail = _e217;
    let _e219: f32 = broad;
    let _e220: f32 = detail;
    return mix(_e219, _e220, 0.28f);
}

fn terrainProjectSurfaceWetness(response: f32) -> f32 {
    var response_1: f32;

    response_1 = response;
    let _e205: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e207: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e212: f32 = response_1;
    return clamp((max(_e205.x, (_e207.w * 0.48f)) * _e212), 0f, 1f);
}

fn terrainProjectApplySurfaceMoisture(surfaceData_4: ptr<function, SurfaceData>, geometryNormal: vec3<f32>, response_2: vec2<f32>) {
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
    let _e208: vec2<f32> = response_3;
    let _e210: f32 = terrainProjectSurfaceWetness(_e208.x);
    wetness = _e210;
    let _e212: f32 = wetness;
    if (_e212 <= 0f) {
        return;
    }
    let _e216: SurfaceData = (*surfaceData_4);
    let _e223: SurfaceData = (*surfaceData_4);
    porousResponse = ((1f - _e216.metallic) * mix(0.35f, 1f, smoothstep(0.18f, 0.82f, _e223.roughness)));
    let _e229: f32 = wetness;
    let _e230: f32 = porousResponse;
    wetSubstrate = (_e229 * _e230);
    let _e233: SurfaceData = (*surfaceData_4);
    substrateLuminance = dot(_e233.albedoColor, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e241: f32 = substrateLuminance;
    let _e243: SurfaceData = (*surfaceData_4);
    saturatedSubstrate = mix(vec3(_e241), _e243.albedoColor, vec3(1.08f));
    let _e249: vec3<f32> = saturatedSubstrate;
    wetAlbedo = max((_e249 * 0.78f), vec3(0f));
    let _e257: SurfaceData = (*surfaceData_4);
    let _e259: vec3<f32> = wetAlbedo;
    let _e260: f32 = wetSubstrate;
    (*surfaceData_4).albedoColor = mix(_e257.albedoColor, _e259, vec3(_e260));
    let _e264: SurfaceData = (*surfaceData_4);
    wetRoughness = max(0.14f, (_e264.roughness * 0.62f));
    let _e271: SurfaceData = (*surfaceData_4);
    let _e273: f32 = wetRoughness;
    let _e274: f32 = wetSubstrate;
    (*surfaceData_4).roughness = mix(_e271.roughness, _e273, (_e274 * 0.72f));
    let _e279: SurfaceData = (*surfaceData_4);
    let _e281: SurfaceData = (*surfaceData_4);
    (*surfaceData_4).dotNV = clamp(dot(_e279.normal, _e281.viewDir), 0f, 1f);
    return;
}

fn terrainProjectTopSnowMask(worldPosition: vec3<f32>, geometryNormal_2: vec3<f32>, response_4: f32) -> f32 {
    var worldPosition_1: vec3<f32>;
    var geometryNormal_3: vec3<f32>;
    var response_5: f32;
    var snowStorage: f32;
    var distribution: f32;
    var snowDistribution: f32;
    var upward: f32;

    worldPosition_1 = worldPosition;
    geometryNormal_3 = geometryNormal_2;
    response_5 = response_4;
    let _e209: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e211: f32 = response_5;
    snowStorage = clamp((_e209.z * _e211), 0f, 1f);
    let _e217: f32 = snowStorage;
    if (_e217 <= 0f) {
        return 0f;
    }
    let _e221: vec3<f32> = worldPosition_1;
    let _e223: f32 = terrainProjectSurfaceClimateNoise(_e221.xz);
    distribution = _e223;
    let _e227: f32 = snowStorage;
    let _e228: f32 = distribution;
    snowDistribution = smoothstep(0.06f, 0.64f, (_e227 + ((_e228 - 0.5f) * 0.22f)));
    let _e236: vec3<f32> = geometryNormal_3;
    upward = clamp(normalize(_e236).y, 0f, 1f);
    let _e243: f32 = snowDistribution;
    let _e246: f32 = upward;
    let _e249: f32 = snowStorage;
    return ((_e243 * smoothstep(0.34f, 0.82f, _e246)) * _e249);
}

fn terrainProjectApplyTopSnowLayer(surfaceData_5: ptr<function, SurfaceData>, geometryNormal_4: vec3<f32>, snow: f32, targetRoughness: f32, normalFlattening: f32) {
    var geometryNormal_5: vec3<f32>;
    var snow_1: f32;
    var targetRoughness_1: f32;
    var normalFlattening_1: f32;

    geometryNormal_5 = geometryNormal_4;
    snow_1 = snow;
    targetRoughness_1 = targetRoughness;
    normalFlattening_1 = normalFlattening;
    let _e212: f32 = snow_1;
    if (_e212 <= 0f) {
        return;
    }
    let _e216: SurfaceData = (*surfaceData_5);
    let _e218: vec4<f32> = global_1.scene_SurfaceSnowColor;
    let _e220: f32 = snow_1;
    (*surfaceData_5).albedoColor = mix(_e216.albedoColor, _e218.xyz, vec3(_e220));
    let _e224: SurfaceData = (*surfaceData_5);
    let _e227: f32 = snow_1;
    (*surfaceData_5).metallic = mix(_e224.metallic, 0f, _e227);
    let _e230: SurfaceData = (*surfaceData_5);
    let _e232: f32 = targetRoughness_1;
    let _e233: f32 = snow_1;
    (*surfaceData_5).roughness = mix(_e230.roughness, _e232, _e233);
    let _e236: SurfaceData = (*surfaceData_5);
    let _e239: f32 = snow_1;
    (*surfaceData_5).specularIntensity = mix(_e236.specularIntensity, 0.68f, _e239);
    let _e242: SurfaceData = (*surfaceData_5);
    let _e244: vec3<f32> = geometryNormal_5;
    let _e246: f32 = snow_1;
    let _e247: f32 = normalFlattening_1;
    (*surfaceData_5).normal = normalize(mix(_e242.normal, normalize(_e244), vec3((_e246 * _e247))));
    return;
}

fn terrainProjectApplySurfaceClimate(surfaceData_6: ptr<function, SurfaceData>, geometryNormal_6: vec3<f32>, response_6: vec3<f32>) {
    var geometryNormal_7: vec3<f32>;
    var response_7: vec3<f32>;
    var snow_2: f32;

    geometryNormal_7 = geometryNormal_6;
    response_7 = response_6;
    let _e209: vec3<f32> = geometryNormal_7;
    let _e210: vec3<f32> = response_7;
    terrainProjectApplySurfaceMoisture(surfaceData_6, _e209, _e210.xy);
    let _e213: SurfaceData = (*surfaceData_6);
    let _e215: vec3<f32> = geometryNormal_7;
    let _e216: vec3<f32> = response_7;
    let _e218: f32 = terrainProjectTopSnowMask(_e213.position, _e215, _e216.z);
    snow_2 = _e218;
    let _e221: vec3<f32> = geometryNormal_7;
    let _e222: f32 = snow_2;
    terrainProjectApplyTopSnowLayer(surfaceData_6, _e221, _e222, 0.82f, 0.28f);
    let _e227: SurfaceData = (*surfaceData_6);
    let _e229: SurfaceData = (*surfaceData_6);
    (*surfaceData_6).dotNV = clamp(dot(_e227.normal, _e229.viewDir), 0f, 1f);
    return;
}

fn terrainProjectVegetationLeafSnowMask(sourcePositionY: f32) -> f32 {
    var sourcePositionY_1: f32;
    var verticalSnow: f32;

    sourcePositionY_1 = sourcePositionY;
    let _e205: vec4<f32> = global_1.material_SnowResponse;
    let _e207: vec4<f32> = global_1.material_SnowResponse;
    let _e209: f32 = sourcePositionY_1;
    verticalSnow = smoothstep(_e205.y, _e207.z, _e209);
    let _e212: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e214: vec4<f32> = global_1.material_SnowResponse;
    let _e217: f32 = verticalSnow;
    return clamp(((_e212.z * _e214.w) * _e217), 0f, 1f);
}

fn terrainProjectVegetationShrubSnowMask(worldPosition_2: vec3<f32>, geometryNormal_8: vec3<f32>) -> f32 {
    var worldPosition_3: vec3<f32>;
    var geometryNormal_9: vec3<f32>;
    var snowStorage_1: f32;
    var distribution_1: f32;
    var snowDistribution_1: f32;
    var upward_1: f32;
    var slope: f32;

    worldPosition_3 = worldPosition_2;
    geometryNormal_9 = geometryNormal_8;
    let _e207: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e209: vec4<f32> = global_1.material_SnowResponse;
    snowStorage_1 = clamp((_e207.z * _e209.x), 0f, 1f);
    let _e216: f32 = snowStorage_1;
    if (_e216 <= 0f) {
        return 0f;
    }
    let _e220: vec3<f32> = worldPosition_3;
    let _e222: f32 = terrainProjectSurfaceClimateNoise(_e220.xz);
    distribution_1 = _e222;
    let _e226: f32 = snowStorage_1;
    let _e227: f32 = distribution_1;
    snowDistribution_1 = smoothstep(0.34f, 0.76f, (_e226 + ((_e227 - 0.5f) * 0.42f)));
    let _e235: vec3<f32> = geometryNormal_9;
    upward_1 = clamp(normalize(_e235).y, 0f, 1f);
    let _e242: f32 = upward_1;
    let _e243: vec4<f32> = global_1.material_SnowResponse;
    let _e249: vec4<f32> = global_1.material_SnowResponse;
    slope = pow(clamp((_e242 + _e243.y), 0f, 1f), max(_e249.z, 0.01f));
    let _e255: f32 = snowDistribution_1;
    let _e256: f32 = slope;
    let _e258: vec4<f32> = global_1.material_SnowResponse;
    return clamp(((_e255 * _e256) * _e258.w), 0f, 1f);
}

fn terrainProjectVegetationGrassSnowMask(worldPosition_4: vec3<f32>) -> f32 {
    var worldPosition_5: vec3<f32>;
    var snowStorage_2: f32;
    var broadPatch: f32;
    var localPatch: f32;
    var distribution_2: f32;
    var patchSnow: f32;
    var accumulationGate: f32;

    worldPosition_5 = worldPosition_4;
    let _e205: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e207: vec4<f32> = global_1.material_SnowResponse;
    snowStorage_2 = clamp((_e205.z * _e207.x), 0f, 1f);
    let _e214: f32 = snowStorage_2;
    if (_e214 <= 0f) {
        return 0f;
    }
    let _e218: vec3<f32> = worldPosition_5;
    let _e226: f32 = terrainProjectSurfaceClimateValueNoise(((_e218.xz * 0.018f) + vec2<f32>(7.3f, 31.9f)));
    broadPatch = _e226;
    let _e228: vec3<f32> = worldPosition_5;
    let _e236: f32 = terrainProjectSurfaceClimateValueNoise(((_e228.xz * 0.075f) + vec2<f32>(53.1f, 11.7f)));
    localPatch = _e236;
    let _e238: f32 = broadPatch;
    let _e239: f32 = localPatch;
    distribution_2 = mix(_e238, _e239, 0.32f);
    let _e245: f32 = snowStorage_2;
    let _e246: f32 = distribution_2;
    patchSnow = smoothstep(0.28f, 0.64f, (_e245 + ((_e246 - 0.5f) * 0.72f)));
    let _e256: f32 = snowStorage_2;
    accumulationGate = smoothstep(0.04f, 0.22f, _e256);
    let _e259: f32 = patchSnow;
    let _e260: f32 = accumulationGate;
    let _e262: vec4<f32> = global_1.material_SnowResponse;
    return clamp(((_e259 * _e260) * _e262.w), 0f, 1f);
}

fn terrainProjectApplyVegetationGrassClimate(surfaceData_7: ptr<function, SurfaceData>, geometryNormal_10: vec3<f32>) {
    var geometryNormal_11: vec3<f32>;
    var snow_3: f32;
    var grassSnowColor: vec3<f32>;

    geometryNormal_11 = geometryNormal_10;
    let _e206: SurfaceData = (*surfaceData_7);
    let _e208: f32 = terrainProjectVegetationGrassSnowMask(_e206.position);
    snow_3 = _e208;
    let _e210: f32 = snow_3;
    if (_e210 <= 0f) {
        return;
    }
    let _e213: vec4<f32> = global_1.scene_SurfaceSnowColor;
    grassSnowColor = (_e213.xyz * vec3<f32>(0.86f, 0.93f, 1f));
    let _e222: SurfaceData = (*surfaceData_7);
    let _e224: vec3<f32> = grassSnowColor;
    let _e225: f32 = snow_3;
    (*surfaceData_7).albedoColor = mix(_e222.albedoColor, _e224, vec3(_e225));
    let _e229: SurfaceData = (*surfaceData_7);
    let _e232: f32 = snow_3;
    (*surfaceData_7).roughness = mix(_e229.roughness, 0.78f, _e232);
    let _e235: SurfaceData = (*surfaceData_7);
    let _e238: f32 = snow_3;
    (*surfaceData_7).specularIntensity = mix(_e235.specularIntensity, 0.7f, _e238);
    let _e241: SurfaceData = (*surfaceData_7);
    let _e243: vec3<f32> = geometryNormal_11;
    let _e245: f32 = snow_3;
    (*surfaceData_7).normal = normalize(mix(_e241.normal, normalize(_e243), vec3((_e245 * 0.08f))));
    let _e252: SurfaceData = (*surfaceData_7);
    let _e254: SurfaceData = (*surfaceData_7);
    (*surfaceData_7).dotNV = clamp(dot(_e252.normal, _e254.viewDir), 0f, 1f);
    return;
}

fn terrainProjectApplyVegetationLeafClimate(surfaceData_8: ptr<function, SurfaceData>, geometryNormal_12: vec3<f32>, sourcePositionY_2: f32) {
    var geometryNormal_13: vec3<f32>;
    var sourcePositionY_3: f32;
    var snow_4: f32;
    var leafSnowColor: vec3<f32>;

    geometryNormal_13 = geometryNormal_12;
    sourcePositionY_3 = sourcePositionY_2;
    let _e208: f32 = sourcePositionY_3;
    let _e209: f32 = terrainProjectVegetationLeafSnowMask(_e208);
    snow_4 = _e209;
    let _e211: f32 = snow_4;
    if (_e211 <= 0f) {
        return;
    }
    let _e214: vec4<f32> = global_1.scene_SurfaceSnowColor;
    leafSnowColor = _e214.xyz;
    let _e218: SurfaceData = (*surfaceData_8);
    let _e220: vec3<f32> = leafSnowColor;
    let _e221: f32 = snow_4;
    (*surfaceData_8).albedoColor = mix(_e218.albedoColor, _e220, vec3(_e221));
    let _e225: SurfaceData = (*surfaceData_8);
    let _e228: f32 = snow_4;
    (*surfaceData_8).roughness = mix(_e225.roughness, 0.74f, _e228);
    let _e231: SurfaceData = (*surfaceData_8);
    let _e234: f32 = snow_4;
    (*surfaceData_8).specularIntensity = mix(_e231.specularIntensity, 0.72f, _e234);
    let _e237: SurfaceData = (*surfaceData_8);
    let _e239: vec3<f32> = geometryNormal_13;
    let _e241: f32 = snow_4;
    (*surfaceData_8).normal = normalize(mix(_e237.normal, normalize(_e239), vec3((_e241 * 0.16f))));
    let _e248: SurfaceData = (*surfaceData_8);
    let _e250: SurfaceData = (*surfaceData_8);
    (*surfaceData_8).dotNV = clamp(dot(_e248.normal, _e250.viewDir), 0f, 1f);
    return;
}

fn terrainProjectApplyVegetationShrubClimate(surfaceData_9: ptr<function, SurfaceData>, geometryNormal_14: vec3<f32>) {
    var geometryNormal_15: vec3<f32>;
    var snow_5: f32;
    var leafSnowColor_1: vec3<f32>;

    geometryNormal_15 = geometryNormal_14;
    let _e206: SurfaceData = (*surfaceData_9);
    let _e208: vec3<f32> = geometryNormal_15;
    let _e209: f32 = terrainProjectVegetationShrubSnowMask(_e206.position, _e208);
    snow_5 = _e209;
    let _e211: f32 = snow_5;
    if (_e211 <= 0f) {
        return;
    }
    let _e214: vec4<f32> = global_1.scene_SurfaceSnowColor;
    leafSnowColor_1 = (_e214.xyz * vec3<f32>(0.78f, 0.88f, 1f));
    let _e223: SurfaceData = (*surfaceData_9);
    let _e225: vec3<f32> = leafSnowColor_1;
    let _e226: f32 = snow_5;
    (*surfaceData_9).albedoColor = mix(_e223.albedoColor, _e225, vec3(_e226));
    let _e230: SurfaceData = (*surfaceData_9);
    let _e233: f32 = snow_5;
    (*surfaceData_9).roughness = mix(_e230.roughness, 0.74f, _e233);
    let _e236: SurfaceData = (*surfaceData_9);
    let _e239: f32 = snow_5;
    (*surfaceData_9).specularIntensity = mix(_e236.specularIntensity, 0.72f, _e239);
    let _e242: SurfaceData = (*surfaceData_9);
    let _e244: vec3<f32> = geometryNormal_15;
    let _e246: f32 = snow_5;
    (*surfaceData_9).normal = normalize(mix(_e242.normal, normalize(_e244), vec3((_e246 * 0.16f))));
    let _e253: SurfaceData = (*surfaceData_9);
    let _e255: SurfaceData = (*surfaceData_9);
    (*surfaceData_9).dotNV = clamp(dot(_e253.normal, _e255.viewDir), 0f, 1f);
    return;
}

fn terrainProjectApplyVegetationBranchClimate(surfaceData_10: ptr<function, SurfaceData>, geometryNormal_16: vec3<f32>) {
    var geometryNormal_17: vec3<f32>;

    geometryNormal_17 = geometryNormal_16;
    let _e207: SurfaceData = (*surfaceData_10);
    let _e209: SurfaceData = (*surfaceData_10);
    (*surfaceData_10).dotNV = clamp(dot(_e207.normal, _e209.viewDir), 0f, 1f);
    return;
}

fn terrainProjectApplyVegetationWetness(surfaceData_11: ptr<function, SurfaceData>, geometryNormal_18: vec3<f32>) {
    var geometryNormal_19: vec3<f32>;

    geometryNormal_19 = geometryNormal_18;
    let _e206: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e210: vec4<f32> = global_1.scene_SurfaceClimate;
    if ((_e206.x <= 0f) && (_e210.w <= 0f)) {
        return;
    }
    let _e216: vec3<f32> = geometryNormal_19;
    terrainProjectApplySurfaceMoisture(surfaceData_11, _e216, vec2<f32>(0.72f, 0f));
    let _e222: SurfaceData = (*surfaceData_11);
    let _e224: SurfaceData = (*surfaceData_11);
    (*surfaceData_11).dotNV = clamp(dot(_e222.normal, _e224.viewDir), 0f, 1f);
    return;
}

fn terrainProjectEvaluateLeafAlbedo(textureColor: vec3<f32>, tint: vec3<f32>) -> vec3<f32> {
    var textureColor_1: vec3<f32>;
    var tint_1: vec3<f32>;
    var sampledLuminance: f32;
    var sampledAlbedo: vec3<f32>;
    var overlayLow: vec3<f32>;
    var overlayHigh: vec3<f32>;
    var overlayAlbedo: vec3<f32>;

    textureColor_1 = textureColor;
    tint_1 = tint;
    let _e207: vec3<f32> = textureColor_1;
    sampledLuminance = dot(_e207, vec3<f32>(0.299f, 0.587f, 0.114f));
    let _e214: vec3<f32> = textureColor_1;
    let _e215: f32 = sampledLuminance;
    let _e217: f32 = global_1.material_LeafAlbedoDesaturation;
    let _e223: f32 = global_1.material_LeafAlbedoBrightness;
    sampledAlbedo = (mix(_e214, vec3(_e215), vec3(clamp(_e217, 0f, 1f))) * max(_e223, 0f));
    let _e229: vec3<f32> = tint_1;
    let _e231: vec3<f32> = sampledAlbedo;
    overlayLow = ((2f * _e229) * _e231);
    let _e237: vec3<f32> = tint_1;
    let _e242: vec3<f32> = sampledAlbedo;
    overlayHigh = (vec3(1f) - ((2f * (vec3(1f) - _e237)) * (vec3(1f) - _e242)));
    let _e249: vec3<f32> = overlayLow;
    let _e250: vec3<f32> = overlayHigh;
    let _e253: vec3<f32> = tint_1;
    overlayAlbedo = clamp(mix(_e249, _e250, step(vec3(0.5f), _e253)), vec3(0f), vec3(1f));
    let _e262: vec3<f32> = tint_1;
    let _e263: vec3<f32> = overlayAlbedo;
    let _e264: f32 = global_1.material_LeafAlbedoTextureBlend;
    return mix(_e262, _e263, vec3(clamp(_e264, 0f, 1f)));
}

fn evaluateVegetationMaterial(varyings: Varyings, isFrontFacing_2: bool, alphaCoverage: f32) -> SurfaceData {
    var varyings_1: Varyings;
    var isFrontFacing_3: bool;
    var alphaCoverage_1: f32;
    var surfaceData_12: SurfaceData;
    var materialUv_4: vec2<f32>;
    var baseTexture_1: vec4<f32>;
    var baseTint: vec3<f32>;
    var albedoColor_1: vec3<f32>;
    var ambientOcclusion: f32 = 1f;
    var smoothness: f32;
    var geometryNormal_20: vec3<f32>;
    var shadingNormal: vec3<f32>;

    varyings_1 = varyings;
    isFrontFacing_3 = isFrontFacing_2;
    alphaCoverage_1 = alphaCoverage;
    let _e210: Varyings = varyings_1;
    let _e212: f32 = global_1.material_Tiling;
    materialUv_4 = (_e210.uv * _e212);
    let _e215: vec2<f32> = materialUv_4;
    let _e216: vec4<f32> = sampleVegetationBaseTexture(_e215);
    baseTexture_1 = _e216;
    let _e218: vec4<f32> = global_1.material_BaseColor;
    baseTint = _e218.xyz;
    let _e221: vec3<f32> = baseTint;
    let _e222: vec4<f32> = baseTexture_1;
    albedoColor_1 = (_e221 * _e222.xyz);
    let _e228: f32 = global_1.material_Smoothness;
    smoothness = _e228;
    let _e230: Varyings = varyings_1;
    geometryNormal_20 = normalize(_e230.normalWS);
    let _e234: vec3<f32> = geometryNormal_20;
    shadingNormal = _e234;
    let _e237: vec3<f32> = albedoColor_1;
    surfaceData_12.albedoColor = _e237;
    surfaceData_12.emissiveColor = vec3(0f);
    surfaceData_12.metallic = 0f;
    let _e245: f32 = smoothness;
    surfaceData_12.roughness = (1f - clamp(_e245, 0f, 1f));
    let _e251: f32 = ambientOcclusion;
    surfaceData_12.ambientOcclusion = _e251;
    surfaceData_12.opacity = 1f;
    surfaceData_12.IOR = 1.5f;
    let _e257: Varyings = varyings_1;
    surfaceData_12.position = _e257.positionWS;
    let _e260: Varyings = varyings_1;
    surfaceData_12.positionCS = _e260.positionCS;
    let _e263: vec3<f32> = shadingNormal;
    surfaceData_12.normal = _e263;
    let _e265: vec3<f32> = global.camera_Position;
    let _e266: Varyings = varyings_1;
    surfaceData_12.viewDir = normalize((_e265 - _e266.positionWS));
    let _e271: SurfaceData = surfaceData_12;
    let _e273: SurfaceData = surfaceData_12;
    surfaceData_12.dotNV = clamp(dot(_e271.normal, _e273.viewDir), 0f, 1f);
    surfaceData_12.specularIntensity = 1f;
    surfaceData_12.specularColor = vec3(1f);
    let _e285: vec3<f32> = geometryNormal_20;
    terrainProjectApplyVegetationWetness((&surfaceData_12), _e285);
    let _e287: SurfaceData = surfaceData_12;
    return _e287;
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

fn isRendererCulledByLight(rendererLayer: vec2<i32>, lightCullingMask: vec2<i32>) -> bool {
    var rendererLayer_1: vec2<i32>;
    var lightCullingMask_1: vec2<i32>;

    rendererLayer_1 = rendererLayer;
    lightCullingMask_1 = lightCullingMask;
    let _e207: vec2<i32> = rendererLayer_1;
    let _e209: vec2<i32> = lightCullingMask_1;
    let _e214: vec2<i32> = rendererLayer_1;
    let _e216: vec2<i32> = lightCullingMask_1;
    return !((((_e207.x & _e209.x) != 0i) || ((_e214.y & _e216.y) != 0i)));
}

fn diffuseLobe(varyings_2: Varyings, surfaceData_13: SurfaceData, bsdfData_3: BSDFData, attenuationIrradiance: vec3<f32>, diffuseColor_2: ptr<function, vec3<f32>>) {
    var varyings_3: Varyings;
    var surfaceData_14: SurfaceData;
    var bsdfData_4: BSDFData;
    var attenuationIrradiance_1: vec3<f32>;

    varyings_3 = varyings_2;
    surfaceData_14 = surfaceData_13;
    bsdfData_4 = bsdfData_3;
    attenuationIrradiance_1 = attenuationIrradiance;
    let _e216: vec3<f32> = (*diffuseColor_2);
    let _e217: vec3<f32> = attenuationIrradiance_1;
    let _e218: BSDFData = bsdfData_4;
    let _e220: vec3<f32> = BRDF_Diffuse_Lambert(_e218.diffuseColor);
    (*diffuseColor_2) = (_e216 + (_e217 * _e220));
    return;
}

fn specularLobe(varyings_4: Varyings, surfaceData_15: SurfaceData, bsdfData_5: BSDFData, incidentDirection_2: vec3<f32>, attenuationIrradiance_2: vec3<f32>, specularColor_2: ptr<function, vec3<f32>>) {
    var varyings_5: Varyings;
    var surfaceData_16: SurfaceData;
    var bsdfData_6: BSDFData;
    var incidentDirection_3: vec3<f32>;
    var attenuationIrradiance_3: vec3<f32>;

    varyings_5 = varyings_4;
    surfaceData_16 = surfaceData_15;
    bsdfData_6 = bsdfData_5;
    incidentDirection_3 = incidentDirection_2;
    attenuationIrradiance_3 = attenuationIrradiance_2;
    let _e218: vec3<f32> = (*specularColor_2);
    let _e219: vec3<f32> = attenuationIrradiance_3;
    let _e220: vec3<f32> = incidentDirection_3;
    let _e221: SurfaceData = surfaceData_16;
    let _e222: BSDFData = bsdfData_6;
    let _e223: SurfaceData = surfaceData_16;
    let _e225: BSDFData = bsdfData_6;
    let _e227: BSDFData = bsdfData_6;
    let _e229: vec3<f32> = BRDF_Specular_GGX(_e220, _e221, _e222, _e223.normal, _e225.specularF0_, _e227.roughness);
    let _e231: BSDFData = bsdfData_6;
    (*specularColor_2) = (_e218 + ((_e219 * _e229) * _e231.energyCompensation));
    return;
}

fn sheenLobe(varyings_6: Varyings, surfaceData_17: SurfaceData, bsdfData_7: BSDFData, incidentDirection_4: vec3<f32>, attenuationIrradiance_4: vec3<f32>, diffuseColor_3: ptr<function, vec3<f32>>, specularColor_3: ptr<function, vec3<f32>>) {
    var varyings_7: Varyings;
    var surfaceData_18: SurfaceData;
    var bsdfData_8: BSDFData;
    var incidentDirection_5: vec3<f32>;
    var attenuationIrradiance_5: vec3<f32>;

    varyings_7 = varyings_6;
    surfaceData_18 = surfaceData_17;
    bsdfData_8 = bsdfData_7;
    incidentDirection_5 = incidentDirection_4;
    attenuationIrradiance_5 = attenuationIrradiance_4;
    return;
}

fn clearCoatLobe(varyings_8: Varyings, surfaceData_19: SurfaceData, bsdfData_9: BSDFData, incidentDirection_6: vec3<f32>, color: vec3<f32>, specularColor_4: ptr<function, vec3<f32>>) -> f32 {
    var varyings_9: Varyings;
    var surfaceData_20: SurfaceData;
    var bsdfData_10: BSDFData;
    var incidentDirection_7: vec3<f32>;
    var color_1: vec3<f32>;
    var attenuation: f32 = 1f;

    varyings_9 = varyings_8;
    surfaceData_20 = surfaceData_19;
    bsdfData_10 = bsdfData_9;
    incidentDirection_7 = incidentDirection_6;
    color_1 = color;
    let _e220: f32 = attenuation;
    return _e220;
}

fn surfaceShading(varyings_10: Varyings, surfaceData_21: SurfaceData, bsdfData_11: BSDFData, incidentDirection_8: vec3<f32>, lightColor: vec3<f32>, totalDiffuseColor: ptr<function, vec3<f32>>, totalSpecularColor: ptr<function, vec3<f32>>) {
    var varyings_11: Varyings;
    var surfaceData_22: SurfaceData;
    var bsdfData_12: BSDFData;
    var incidentDirection_9: vec3<f32>;
    var lightColor_1: vec3<f32>;
    var diffuseColor_4: vec3<f32> = vec3(0f);
    var specularColor_5: vec3<f32> = vec3(0f);
    var dotNL_5: f32;
    var irradiance: vec3<f32>;
    var attenuation_1: f32;
    var attenuationIrradiance_6: vec3<f32>;

    varyings_11 = varyings_10;
    surfaceData_22 = surfaceData_21;
    bsdfData_12 = bsdfData_11;
    incidentDirection_9 = incidentDirection_8;
    lightColor_1 = lightColor;
    let _e227: SurfaceData = surfaceData_22;
    let _e229: vec3<f32> = incidentDirection_9;
    dotNL_5 = clamp(dot(_e227.normal, _e229), 0f, 1f);
    let _e235: f32 = dotNL_5;
    let _e236: vec3<f32> = lightColor_1;
    irradiance = ((_e235 * _e236) * 3.1415927f);
    let _e241: Varyings = varyings_11;
    let _e242: SurfaceData = surfaceData_22;
    let _e243: BSDFData = bsdfData_12;
    let _e244: vec3<f32> = incidentDirection_9;
    let _e245: vec3<f32> = lightColor_1;
    let _e248: f32 = clearCoatLobe(_e241, _e242, _e243, _e244, _e245, (&specularColor_5));
    attenuation_1 = _e248;
    let _e250: f32 = attenuation_1;
    let _e251: vec3<f32> = irradiance;
    attenuationIrradiance_6 = (_e250 * _e251);
    let _e254: Varyings = varyings_11;
    let _e255: SurfaceData = surfaceData_22;
    let _e256: BSDFData = bsdfData_12;
    let _e257: vec3<f32> = attenuationIrradiance_6;
    diffuseLobe(_e254, _e255, _e256, _e257, (&diffuseColor_4));
    let _e260: Varyings = varyings_11;
    let _e261: SurfaceData = surfaceData_22;
    let _e262: BSDFData = bsdfData_12;
    let _e263: vec3<f32> = incidentDirection_9;
    let _e264: vec3<f32> = attenuationIrradiance_6;
    specularLobe(_e260, _e261, _e262, _e263, _e264, (&specularColor_5));
    let _e267: Varyings = varyings_11;
    let _e268: SurfaceData = surfaceData_22;
    let _e269: BSDFData = bsdfData_12;
    let _e270: vec3<f32> = incidentDirection_9;
    let _e271: vec3<f32> = attenuationIrradiance_6;
    sheenLobe(_e267, _e268, _e269, _e270, _e271, (&diffuseColor_4), (&specularColor_5));
    let _e276: vec3<f32> = (*totalDiffuseColor);
    let _e277: vec3<f32> = diffuseColor_4;
    (*totalDiffuseColor) = (_e276 + _e277);
    let _e279: vec3<f32> = (*totalSpecularColor);
    let _e280: vec3<f32> = specularColor_5;
    (*totalSpecularColor) = (_e279 + _e280);
    return;
}

fn evaluateDirectRadiance(varyings_12: Varyings, surfaceData_23: SurfaceData, bsdfData_13: BSDFData, shadowAttenuation: f32, totalDiffuseColor_1: ptr<function, vec3<f32>>, totalSpecularColor_1: ptr<function, vec3<f32>>) {
    var varyings_13: Varyings;
    var surfaceData_24: SurfaceData;
    var bsdfData_14: BSDFData;
    var shadowAttenuation_1: f32;

    varyings_13 = varyings_12;
    surfaceData_24 = surfaceData_23;
    bsdfData_14 = bsdfData_13;
    shadowAttenuation_1 = shadowAttenuation;
    return;
}

fn getReflectedVector(surfaceData_25: SurfaceData, n: vec3<f32>) -> vec3<f32> {
    var surfaceData_26: SurfaceData;
    var n_1: vec3<f32>;
    var r_1: vec3<f32>;

    surfaceData_26 = surfaceData_25;
    n_1 = n;
    let _e211: SurfaceData = surfaceData_26;
    let _e214: vec3<f32> = n_1;
    r_1 = reflect(-(_e211.viewDir), _e214);
    let _e217: vec3<f32> = r_1;
    return _e217;
}

fn getSpecularMIPLevel(roughness_7: f32, maxMIPLevel: i32) -> f32 {
    var roughness_8: f32;
    var maxMIPLevel_1: i32;

    roughness_8 = roughness_7;
    maxMIPLevel_1 = maxMIPLevel;
    let _e211: f32 = roughness_8;
    let _e212: i32 = maxMIPLevel_1;
    return (_e211 * f32(_e212));
}

fn getLightProbeRadiance(surfaceData_27: SurfaceData, normal_6: vec3<f32>, roughness_9: f32) -> vec3<f32> {
    var surfaceData_28: SurfaceData;
    var normal_7: vec3<f32>;
    var roughness_10: f32;

    surfaceData_28 = surfaceData_27;
    normal_7 = normal_6;
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
    let _e215: f32 = specularAOFactor;
    return _e215;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal_8: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_9: vec3<f32>;
    var result: vec3<f32>;

    sh_1 = sh;
    normal_9 = normal_8;
    let _e213: vec3<f32> = sh_1[0];
    let _e216: vec3<f32> = sh_1[1];
    let _e217: vec3<f32> = normal_9;
    let _e223: vec3<f32> = sh_1[2];
    let _e224: vec3<f32> = normal_9;
    let _e230: vec3<f32> = sh_1[3];
    let _e231: vec3<f32> = normal_9;
    let _e237: vec3<f32> = sh_1[4];
    let _e238: vec3<f32> = normal_9;
    let _e240: vec3<f32> = normal_9;
    let _e247: vec3<f32> = sh_1[5];
    let _e248: vec3<f32> = normal_9;
    let _e250: vec3<f32> = normal_9;
    let _e257: vec3<f32> = sh_1[6];
    let _e259: vec3<f32> = normal_9;
    let _e262: vec3<f32> = normal_9;
    let _e271: vec3<f32> = sh_1[7];
    let _e272: vec3<f32> = normal_9;
    let _e274: vec3<f32> = normal_9;
    let _e281: vec3<f32> = sh_1[8];
    let _e282: vec3<f32> = normal_9;
    let _e284: vec3<f32> = normal_9;
    let _e287: vec3<f32> = normal_9;
    let _e289: vec3<f32> = normal_9;
    result = ((((((((_e213 + (_e216 * _e217.y)) + (_e223 * _e224.z)) + (_e230 * _e231.x)) + (_e237 * (_e238.y * _e240.x))) + (_e247 * (_e248.y * _e250.z))) + (_e257 * (((3f * _e259.z) * _e262.z) - 1f))) + (_e271 * (_e272.z * _e274.x))) + (_e281 * ((_e282.x * _e284.x) - (_e287.y * _e289.y))));
    let _e296: vec3<f32> = result;
    return max(_e296, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS_1: vec3<f32>) -> vec3<f32> {
    var normalWS_2: vec3<f32>;

    normalWS_2 = normalWS_1;
    let _e209: EnvMapLight = scene_EnvMapLight;
    return (_e209.diffuse * 3.1415927f);
}

fn evaluateDiffuseIBL(varyings_14: Varyings, surfaceData_29: SurfaceData, bsdfData_15: BSDFData, diffuseColor_5: ptr<function, vec3<f32>>) {
    var varyings_15: Varyings;
    var surfaceData_30: SurfaceData;
    var bsdfData_16: BSDFData;
    var irradiance_1: vec3<f32>;

    varyings_15 = varyings_14;
    surfaceData_30 = surfaceData_29;
    bsdfData_16 = bsdfData_15;
    let _e214: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e214.diffuse * 3.1415927f);
    let _e219: vec3<f32> = irradiance_1;
    let _e220: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e219 * _e220.diffuseIntensity);
    let _e223: vec3<f32> = (*diffuseColor_5);
    let _e224: BSDFData = bsdfData_16;
    let _e226: vec3<f32> = irradiance_1;
    let _e228: BSDFData = bsdfData_16;
    let _e230: vec3<f32> = BRDF_Diffuse_Lambert(_e228.diffuseColor);
    (*diffuseColor_5) = (_e223 + ((_e224.diffuseAO * _e226) * _e230));
    return;
}

fn evaluateClearCoatIBL(varyings_16: Varyings, surfaceData_31: SurfaceData, bsdfData_17: BSDFData, specularColor_6: ptr<function, vec3<f32>>) -> f32 {
    var varyings_17: Varyings;
    var surfaceData_32: SurfaceData;
    var bsdfData_18: BSDFData;
    var radianceAttenuation: f32 = 1f;

    varyings_17 = varyings_16;
    surfaceData_32 = surfaceData_31;
    bsdfData_18 = bsdfData_17;
    let _e216: f32 = radianceAttenuation;
    return _e216;
}

fn evaluateSpecularIBL(varyings_18: Varyings, surfaceData_33: SurfaceData, bsdfData_19: BSDFData, radianceAttenuation_1: f32, outSpecularColor: ptr<function, vec3<f32>>) {
    var varyings_19: Varyings;
    var surfaceData_34: SurfaceData;
    var bsdfData_20: BSDFData;
    var radianceAttenuation_2: f32;
    var radiance: vec3<f32>;
    var specularAO: f32;

    varyings_19 = varyings_18;
    surfaceData_34 = surfaceData_33;
    bsdfData_20 = bsdfData_19;
    radianceAttenuation_2 = radianceAttenuation_1;
    let _e216: SurfaceData = surfaceData_34;
    let _e217: SurfaceData = surfaceData_34;
    let _e219: BSDFData = bsdfData_20;
    let _e221: vec3<f32> = getLightProbeRadiance(_e216, _e217.normal, _e219.roughness);
    radiance = _e221;
    let _e223: SurfaceData = surfaceData_34;
    let _e225: BSDFData = bsdfData_20;
    let _e227: BSDFData = bsdfData_20;
    let _e229: f32 = evaluateSpecularOcclusion(_e223.dotNV, _e225.diffuseAO, _e227.roughness);
    specularAO = _e229;
    let _e231: vec3<f32> = (*outSpecularColor);
    let _e232: f32 = specularAO;
    let _e233: f32 = radianceAttenuation_2;
    let _e235: vec3<f32> = radiance;
    let _e237: BSDFData = bsdfData_20;
    let _e239: BSDFData = bsdfData_20;
    let _e241: BSDFData = bsdfData_20;
    let _e243: SurfaceData = surfaceData_34;
    let _e245: vec3<f32> = envBRDFApprox(_e237.resolvedSpecularF0_, _e239.specularF90_, _e241.roughness, _e243.dotNV);
    let _e247: BSDFData = bsdfData_20;
    (*outSpecularColor) = (_e231 + ((((_e232 * _e233) * _e235) * _e245) * _e247.energyCompensation));
    return;
}

fn evaluateSheenIBL(varyings_20: Varyings, surfaceData_35: SurfaceData, bsdfData_21: BSDFData, radianceAttenuation_3: f32, diffuseColor_6: ptr<function, vec3<f32>>, specularColor_7: ptr<function, vec3<f32>>) {
    var varyings_21: Varyings;
    var surfaceData_36: SurfaceData;
    var bsdfData_22: BSDFData;
    var radianceAttenuation_4: f32;

    varyings_21 = varyings_20;
    surfaceData_36 = surfaceData_35;
    bsdfData_22 = bsdfData_21;
    radianceAttenuation_4 = radianceAttenuation_3;
    return;
}

fn evaluateIBL(varyings_22: Varyings, surfaceData_37: SurfaceData, bsdfData_23: BSDFData, totalDiffuseColor_2: ptr<function, vec3<f32>>, totalSpecularColor_2: ptr<function, vec3<f32>>) {
    var varyings_23: Varyings;
    var surfaceData_38: SurfaceData;
    var bsdfData_24: BSDFData;
    var diffuseColor_7: vec3<f32> = vec3(0f);
    var specularColor_8: vec3<f32> = vec3(0f);
    var radianceAttenuation_5: f32;

    varyings_23 = varyings_22;
    surfaceData_38 = surfaceData_37;
    bsdfData_24 = bsdfData_23;
    let _e223: Varyings = varyings_23;
    let _e224: SurfaceData = surfaceData_38;
    let _e225: BSDFData = bsdfData_24;
    evaluateDiffuseIBL(_e223, _e224, _e225, (&diffuseColor_7));
    let _e228: Varyings = varyings_23;
    let _e229: SurfaceData = surfaceData_38;
    let _e230: BSDFData = bsdfData_24;
    let _e233: f32 = evaluateClearCoatIBL(_e228, _e229, _e230, (&specularColor_8));
    radianceAttenuation_5 = _e233;
    let _e235: Varyings = varyings_23;
    let _e236: SurfaceData = surfaceData_38;
    let _e237: BSDFData = bsdfData_24;
    let _e238: f32 = radianceAttenuation_5;
    evaluateSpecularIBL(_e235, _e236, _e237, _e238, (&specularColor_8));
    let _e241: Varyings = varyings_23;
    let _e242: SurfaceData = surfaceData_38;
    let _e243: BSDFData = bsdfData_24;
    let _e244: f32 = radianceAttenuation_5;
    evaluateSheenIBL(_e241, _e242, _e243, _e244, (&diffuseColor_7), (&specularColor_8));
    let _e249: vec3<f32> = (*totalDiffuseColor_2);
    let _e250: vec3<f32> = diffuseColor_7;
    (*totalDiffuseColor_2) = (_e249 + _e250);
    let _e252: vec3<f32> = (*totalSpecularColor_2);
    let _e253: vec3<f32> = specularColor_8;
    (*totalSpecularColor_2) = (_e252 + _e253);
    return;
}

fn sampleVolumetricCloudShadow(positionWS_1: vec3<f32>) -> f32 {
    var positionWS_2: vec3<f32>;

    positionWS_2 = positionWS_1;
    return 1f;
}

fn sampleTerrainProjectShadow(varyings_24: Varyings) -> f32 {
    var varyings_25: Varyings;
    var attenuation_2: f32 = 1f;

    varyings_25 = varyings_24;
    let _e211: f32 = attenuation_2;
    let _e212: Varyings = varyings_25;
    let _e214: f32 = sampleVolumetricCloudShadow(_e212.positionWS);
    return (_e211 * _e214);
}

fn terrainProjectEvaluateSpecularIBL(surfaceData_39: SurfaceData, bsdfData_25: BSDFData, radiance_1: vec3<f32>) -> vec3<f32> {
    var surfaceData_40: SurfaceData;
    var bsdfData_26: BSDFData;
    var radiance_2: vec3<f32>;
    var specularAO_1: f32;

    surfaceData_40 = surfaceData_39;
    bsdfData_26 = bsdfData_25;
    radiance_2 = radiance_1;
    let _e213: SurfaceData = surfaceData_40;
    let _e215: BSDFData = bsdfData_26;
    let _e217: BSDFData = bsdfData_26;
    let _e219: f32 = evaluateSpecularOcclusion(_e213.dotNV, _e215.diffuseAO, _e217.roughness);
    specularAO_1 = _e219;
    let _e221: f32 = specularAO_1;
    let _e222: vec3<f32> = radiance_2;
    let _e224: BSDFData = bsdfData_26;
    let _e226: BSDFData = bsdfData_26;
    let _e228: BSDFData = bsdfData_26;
    let _e230: SurfaceData = surfaceData_40;
    let _e232: vec3<f32> = envBRDFApprox(_e224.resolvedSpecularF0_, _e226.specularF90_, _e228.roughness, _e230.dotNV);
    let _e234: BSDFData = bsdfData_26;
    return (((_e221 * _e222) * _e232) * _e234.energyCompensation);
}

fn evaluateTerrainProjectLightingWithShadow(varyings_26: Varyings, surfaceData_41: SurfaceData, shadowAttenuation_2: f32) -> TerrainProjectLightingResult {
    var varyings_27: Varyings;
    var surfaceData_42: SurfaceData;
    var shadowAttenuation_3: f32;
    var result_1: TerrainProjectLightingResult;
    var bsdfData_27: BSDFData;
    var directShadowAttenuation: f32;

    varyings_27 = varyings_26;
    surfaceData_42 = surfaceData_41;
    shadowAttenuation_3 = shadowAttenuation_2;
    result_1.directDiffuse = vec3(0f);
    result_1.directSpecular = vec3(0f);
    result_1.environmentDiffuse = vec3(0f);
    result_1.environmentSpecular = vec3(0f);
    let _e227: f32 = shadowAttenuation_3;
    result_1.shadowAttenuation = _e227;
    let _e229: SurfaceData = surfaceData_42;
    surfaceData_42.albedoColor = _e229.albedoColor;
    let _e232: SurfaceData = surfaceData_42;
    initBSDFData(_e232, (&bsdfData_27));
    let _e235: TerrainProjectLightingResult = result_1;
    directShadowAttenuation = _e235.shadowAttenuation;
    let _e238: Varyings = varyings_27;
    let _e239: SurfaceData = surfaceData_42;
    let _e240: BSDFData = bsdfData_27;
    let _e241: f32 = directShadowAttenuation;
    let _e242: TerrainProjectLightingResult = result_1;
    let _e244: TerrainProjectLightingResult = result_1;
    var gs_output_arg0 = result_1.directDiffuse;
    var gs_output_arg1 = result_1.directSpecular;
    evaluateDirectRadiance(_e238, _e239, _e240, _e241, (&gs_output_arg0), (&gs_output_arg1));
    result_1.directDiffuse = gs_output_arg0;
    result_1.directSpecular = gs_output_arg1;
    let _e250: Varyings = varyings_27;
    let _e251: SurfaceData = surfaceData_42;
    let _e252: BSDFData = bsdfData_27;
    let _e253: TerrainProjectLightingResult = result_1;
    let _e255: TerrainProjectLightingResult = result_1;
    var gs_output_arg2 = result_1.environmentDiffuse;
    var gs_output_arg3 = result_1.environmentSpecular;
    evaluateIBL(_e250, _e251, _e252, (&gs_output_arg2), (&gs_output_arg3));
    result_1.environmentDiffuse = gs_output_arg2;
    result_1.environmentSpecular = gs_output_arg3;
    let _e261: TerrainProjectLightingResult = result_1;
    return _e261;
}

fn evaluateTerrainProjectLighting(varyings_28: Varyings, surfaceData_43: SurfaceData) -> TerrainProjectLightingResult {
    var varyings_29: Varyings;
    var surfaceData_44: SurfaceData;

    varyings_29 = varyings_28;
    surfaceData_44 = surfaceData_43;
    let _e211: Varyings = varyings_29;
    let _e212: SurfaceData = surfaceData_44;
    let _e213: Varyings = varyings_29;
    let _e214: f32 = sampleTerrainProjectShadow(_e213);
    let _e215: TerrainProjectLightingResult = evaluateTerrainProjectLightingWithShadow(_e211, _e212, _e214);
    return _e215;
}

fn terrainProjectFinalLighting(result_2: TerrainProjectLightingResult) -> vec3<f32> {
    var result_3: TerrainProjectLightingResult;

    result_3 = result_2;
    let _e209: TerrainProjectLightingResult = result_3;
    let _e211: TerrainProjectLightingResult = result_3;
    let _e214: TerrainProjectLightingResult = result_3;
    let _e217: TerrainProjectLightingResult = result_3;
    return (((_e209.directDiffuse + _e211.directSpecular) + _e214.environmentDiffuse) + _e217.environmentSpecular);
}

fn VegetationFragment(varyings_30: Varyings) {
    var varyings_31: Varyings;
    var alphaCoverage_2: f32 = 1f;
    var surfaceData_45: SurfaceData;
    var lighting: TerrainProjectLightingResult;
    var transmission: vec3<f32> = vec3(0f);
    var color_2: vec4<f32>;

    varyings_31 = varyings_30;
    let _e210: vec4<f32> = gl_FragCoord_1;
    applyTerrainProjectLodDither(_e210.xy);
    let _e215: Varyings = varyings_31;
    let _e216: bool = gl_FrontFacing_1;
    let _e217: f32 = alphaCoverage_2;
    let _e218: SurfaceData = evaluateVegetationMaterial(_e215, _e216, _e217);
    surfaceData_45 = _e218;
    let _e220: Varyings = varyings_31;
    let _e221: SurfaceData = surfaceData_45;
    let _e222: TerrainProjectLightingResult = evaluateTerrainProjectLighting(_e220, _e221);
    lighting = _e222;
    let _e227: TerrainProjectLightingResult = lighting;
    let _e228: vec3<f32> = terrainProjectFinalLighting(_e227);
    let _e229: vec3<f32> = transmission;
    let _e231: SurfaceData = surfaceData_45;
    let _e233: vec3<f32> = ((_e228 + _e229) + _e231.emissiveColor);
    color_2 = vec4<f32>(_e233.x, _e233.y, _e233.z, 1f);
    let _e240: vec4<f32> = color_2;
    converted_FragColor = _e240;
    return;
}

fn gs_wgpu_main() {
    var input_varyings: Varyings;

    let _e209: Varyings = read_Varyings();
    input_varyings = _e209;
    let _e211: Varyings = input_varyings;
    VegetationFragment(_e211);
    return;
}

fn main_1() {
    let _e213: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e219: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e225: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e213.x), bitcast<f32>(_e219.y), bitcast<f32>(_e225.z));
    let _e233: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e233.w);
    let _e240: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e240.x);
    let _e247: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e247.y);
    let _e254: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e254.z);
    let _e261: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e261.w);
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) uv: vec2<f32>, @location(1) positionWS: vec3<f32>, @location(2) normalWS: vec3<f32>, @location(3) positionCS: vec4<f32>, @builtin(position) gl_FragCoord: vec4<f32>, @builtin(front_facing) gl_FrontFacing: bool) -> FragmentOutput {
    uv_5 = uv;
    positionWS_3 = positionWS;
    normalWS_3 = normalWS;
    positionCS_1 = positionCS;
    gl_FragCoord_1 = gl_FragCoord;
    gl_FrontFacing_1 = gl_FrontFacing;
    main_1();
    let _e226: vec4<f32> = converted_FragColor;
    return FragmentOutput(_e226);
}
