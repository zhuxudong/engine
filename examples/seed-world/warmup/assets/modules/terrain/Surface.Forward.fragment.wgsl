diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ViewMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
}

struct gs_Auto_1_ {
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    renderer_MVMat: mat4x4<f32>,
    renderer_MVPMat: mat4x4<f32>,
    renderer_NormalMat: mat4x4<f32>,
    camera_DepthBufferParams: vec4<f32>,
    camera_ProjectionParams: vec4<f32>,
    camera_Forward: vec3<f32>,
    scene_SurfaceClimate: vec4<f32>,
    scene_SurfaceSnowColor: vec4<f32>,
    scene_TerrainWaterCoverageParams: vec4<f32>,
    material_BaseColor: vec4<f32>,
    material_Tiling: f32,
    material_Metallic: f32,
    material_Smoothness: f32,
    material_SmoothnessSource: f32,
    material_NormalScale: f32,
    material_OcclusionStrength: f32,
    renderer_Layer: vec4<i32>,
}

struct Varyings {
    uv: vec2<f32>,
    sourcePositionOSY: f32,
    positionWS: vec3<f32>,
    normalWS: vec3<f32>,
    cloudShadow: f32,
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
var<private> sourcePositionOSY_1: f32;
var<private> positionWS_3: vec3<f32>;
var<private> normalWS_3: vec3<f32>;
var<private> cloudShadow_1: f32;
var<private> positionCS_1: vec4<f32>;
@group(2) @binding(2) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;
var<private> gl_FragCoord_1: vec4<f32>;
var<private> gl_FrontFacing_1: bool;

fn pow2_(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e45: f32 = x_1;
    let _e46: f32 = x_1;
    return (_e45 * _e46);
}

fn sRGBToLinear(value: f32) -> f32 {
    var value_1: f32;
    var linearRGBLo: f32;
    var linearRGBHi: f32;
    var local: f32;
    var linearRGB: f32;

    value_1 = value;
    let _e45: f32 = value_1;
    linearRGBLo = (_e45 / 12.92f);
    let _e49: f32 = value_1;
    linearRGBHi = pow(((_e49 + 0.055f) / 1.055f), 2.4f);
    let _e57: f32 = value_1;
    if (_e57 <= 0.04045f) {
        let _e60: f32 = linearRGBLo;
        local = _e60;
    } else {
        let _e61: f32 = linearRGBHi;
        local = _e61;
    }
    let _e63: f32 = local;
    linearRGB = _e63;
    let _e65: f32 = linearRGB;
    return _e65;
}

fn sRGBToLinear_1(value_2: vec4<f32>) -> vec4<f32> {
    var value_3: vec4<f32>;

    value_3 = value_2;
    let _e45: vec4<f32> = value_3;
    let _e47: f32 = sRGBToLinear(_e45.x);
    let _e48: vec4<f32> = value_3;
    let _e50: f32 = sRGBToLinear(_e48.y);
    let _e51: vec4<f32> = value_3;
    let _e53: f32 = sRGBToLinear(_e51.z);
    let _e54: vec4<f32> = value_3;
    return vec4<f32>(_e47, _e50, _e53, _e54.w);
}

fn texture2DSRGB(gs_wgpu_tex_tex: texture_2d<f32>, gs_wgpu_samp_tex: sampler, uv_1: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;

    uv_2 = uv_1;
    let _e47: vec2<f32> = uv_2;
    let _e48: vec4<f32> = textureSample(gs_wgpu_tex_tex, gs_wgpu_samp_tex, _e47);
    return _e48;
}

fn remapDepthBufferEyeDepth(depth: f32) -> f32 {
    var depth_1: f32;

    depth_1 = depth;
    let _e46: vec4<f32> = global_1.camera_DepthBufferParams;
    let _e48: f32 = depth_1;
    let _e50: vec4<f32> = global_1.camera_DepthBufferParams;
    return (1f / ((_e46.z * _e48) + _e50.w));
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e51: vec2<f32> = uv_5;
    interface_value.uv = _e51;
    let _e53: f32 = sourcePositionOSY_1;
    interface_value.sourcePositionOSY = _e53;
    let _e55: vec3<f32> = positionWS_3;
    interface_value.positionWS = _e55;
    let _e57: vec3<f32> = normalWS_3;
    interface_value.normalWS = _e57;
    let _e59: f32 = cloudShadow_1;
    interface_value.cloudShadow = _e59;
    let _e61: vec4<f32> = positionCS_1;
    interface_value.positionCS = _e61;
    let _e62: Varyings = interface_value;
    return _e62;
}

fn getAARoughnessFactor(normal: vec3<f32>) -> f32 {
    var normal_1: vec3<f32>;
    var dxy: vec3<f32>;

    normal_1 = normal;
    let _e51: vec3<f32> = normal_1;
    let _e52: vec3<f32> = dpdx(_e51);
    let _e54: vec3<f32> = normal_1;
    let _e55: vec3<f32> = dpdy(_e54);
    dxy = max(abs(_e52), abs(-(_e55)));
    let _e60: vec3<f32> = dxy;
    let _e62: vec3<f32> = dxy;
    let _e65: vec3<f32> = dxy;
    return max(max(_e60.x, _e62.y), _e65.z);
}

fn F_Schlick(f0_: f32, f90_: f32, dotLH: f32) -> f32 {
    var f0_1: f32;
    var f90_1: f32;
    var dotLH_1: f32;

    f0_1 = f0_;
    f90_1 = f90_;
    dotLH_1 = dotLH;
    let _e55: f32 = f0_1;
    let _e56: f32 = f90_1;
    let _e57: f32 = f0_1;
    let _e60: f32 = dotLH_1;
    return (_e55 + ((_e56 - _e57) * pow((1f - _e60), 5f)));
}

fn F_Schlick_1(f0_2: vec3<f32>, f90_2: f32, dotLH_2: f32) -> vec3<f32> {
    var f0_3: vec3<f32>;
    var f90_3: f32;
    var dotLH_3: f32;
    var fresnel: f32;

    f0_3 = f0_2;
    f90_3 = f90_2;
    dotLH_3 = dotLH_2;
    let _e57: f32 = dotLH_3;
    let _e61: f32 = dotLH_3;
    fresnel = exp2((((-5.55473f * _e57) - 6.98316f) * _e61));
    let _e65: f32 = f90_3;
    let _e66: vec3<f32> = f0_3;
    let _e69: f32 = fresnel;
    let _e71: vec3<f32> = f0_3;
    return (((vec3(_e65) - _e66) * _e69) + _e71);
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
    let _e55: f32 = alpha_1;
    let _e56: f32 = pow2_(_e55);
    a2_ = _e56;
    let _e58: f32 = dotNL_1;
    let _e59: f32 = a2_;
    let _e61: f32 = a2_;
    let _e63: f32 = dotNV_1;
    let _e64: f32 = pow2_(_e63);
    gv = (_e58 * sqrt((_e59 + ((1f - _e61) * _e64))));
    let _e70: f32 = dotNV_1;
    let _e71: f32 = a2_;
    let _e73: f32 = a2_;
    let _e75: f32 = dotNL_1;
    let _e76: f32 = pow2_(_e75);
    gl = (_e70 * sqrt((_e71 + ((1f - _e73) * _e76))));
    let _e83: f32 = gv;
    let _e84: f32 = gl;
    return (0.5f / max((_e83 + _e84), 0.000001f));
}

fn D_GGX(alpha_2: f32, dotNH: f32) -> f32 {
    var alpha_3: f32;
    var dotNH_1: f32;
    var a2_1: f32;
    var denom: f32;

    alpha_3 = alpha_2;
    dotNH_1 = dotNH;
    let _e53: f32 = alpha_3;
    let _e54: f32 = pow2_(_e53);
    a2_1 = _e54;
    let _e56: f32 = dotNH_1;
    let _e57: f32 = pow2_(_e56);
    let _e58: f32 = a2_1;
    denom = ((_e57 * (_e58 - 1f)) + 1f);
    let _e66: f32 = a2_1;
    let _e68: f32 = denom;
    let _e69: f32 = pow2_(_e68);
    return ((0.31830987f * _e66) / _e69);
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
    let _e57: f32 = alpha_5;
    let _e58: f32 = dotNH_3;
    let _e59: f32 = D_GGX(_e57, _e58);
    D = _e59;
    let _e61: f32 = alpha_5;
    let _e62: f32 = dotNL_3;
    let _e63: f32 = dotNV_3;
    let _e64: f32 = G_GGX_SmithCorrelated(_e61, _e62, _e63);
    G = _e64;
    let _e66: f32 = G;
    let _e67: f32 = D;
    return (_e66 * _e67);
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
    let _e61: f32 = roughness_1;
    let _e62: f32 = pow2_(_e61);
    alpha_6 = _e62;
    let _e64: vec3<f32> = incidentDirection_1;
    let _e65: SurfaceData = surfaceData_1;
    halfDir = normalize((_e64 + _e65.viewDir));
    let _e70: vec3<f32> = normal_3;
    let _e71: vec3<f32> = incidentDirection_1;
    dotNL_4 = clamp(dot(_e70, _e71), 0f, 1f);
    let _e77: vec3<f32> = normal_3;
    let _e78: SurfaceData = surfaceData_1;
    dotNV_4 = clamp(dot(_e77, _e78.viewDir), 0f, 1f);
    let _e85: vec3<f32> = normal_3;
    let _e86: vec3<f32> = halfDir;
    dotNH_4 = clamp(dot(_e85, _e86), 0f, 1f);
    let _e92: vec3<f32> = incidentDirection_1;
    let _e93: vec3<f32> = halfDir;
    dotLH_4 = clamp(dot(_e92, _e93), 0f, 1f);
    let _e99: vec3<f32> = specularColor_1;
    let _e100: BSDFData = bsdfData_1;
    let _e102: f32 = dotLH_4;
    let _e103: vec3<f32> = F_Schlick_1(_e99, _e100.specularF90_, _e102);
    F = _e103;
    let _e105: f32 = alpha_6;
    let _e106: f32 = dotNV_4;
    let _e107: f32 = dotNL_4;
    let _e108: f32 = dotNH_4;
    let _e109: f32 = DG_GGX(_e105, _e106, _e107, _e108);
    GD = _e109;
    let _e111: vec3<f32> = F;
    let _e112: f32 = GD;
    return (_e111 * _e112);
}

fn BRDF_Diffuse_Lambert(diffuseColor: vec3<f32>) -> vec3<f32> {
    var diffuseColor_1: vec3<f32>;

    diffuseColor_1 = diffuseColor;
    let _e52: vec3<f32> = diffuseColor_1;
    return (0.31830987f * _e52);
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
    let _e71: f32 = roughness_3;
    let _e72: vec4<f32> = c0_;
    let _e74: vec4<f32> = c1_;
    r = ((_e71 * _e72) + _e74);
    let _e77: vec4<f32> = r;
    let _e79: vec4<f32> = r;
    let _e84: f32 = dotNV_6;
    let _e88: vec4<f32> = r;
    let _e91: vec4<f32> = r;
    a004_ = ((min((_e77.x * _e79.x), exp2((-9.28f * _e84))) * _e88.x) + _e91.y);
    let _e99: f32 = a004_;
    let _e101: vec4<f32> = r;
    return ((vec2<f32>(-1.04f, 1.04f) * _e99) + _e101.zw);
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
    let _e57: f32 = roughness_5;
    let _e58: f32 = dotNV_8;
    let _e59: vec2<f32> = envDFGApprox(_e57, _e58);
    AB = _e59;
    let _e61: vec3<f32> = f0_5;
    let _e62: vec2<f32> = AB;
    let _e65: f32 = f90_5;
    let _e66: vec2<f32> = AB;
    return ((_e61 * _e62.x) + vec3((_e65 * _e66.y)));
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
    let _e52: SurfaceData = surfaceData_3;
    albedoColor = _e52.albedoColor;
    let _e55: SurfaceData = surfaceData_3;
    metallic = _e55.metallic;
    let _e58: SurfaceData = surfaceData_3;
    roughness_6 = _e58.roughness;
    let _e61: SurfaceData = surfaceData_3;
    let _e65: SurfaceData = surfaceData_3;
    let _e70: f32 = pow2_(((_e61.IOR - 1f) / (_e65.IOR + 1f)));
    dielectricBaseF0_ = vec3(_e70);
    let _e73: vec3<f32> = dielectricBaseF0_;
    let _e74: SurfaceData = surfaceData_3;
    let _e80: SurfaceData = surfaceData_3;
    dielectricF0_ = (min((_e73 * _e74.specularColor), vec3(1f)) * _e80.specularIntensity);
    let _e84: SurfaceData = surfaceData_3;
    dielectricF90_ = _e84.specularIntensity;
    let _e88: vec3<f32> = dielectricF0_;
    let _e89: vec3<f32> = albedoColor;
    let _e90: f32 = metallic;
    (*bsdfData_2).specularF0_ = mix(_e88, _e89, vec3(_e90));
    let _e94: f32 = dielectricF90_;
    let _e96: f32 = metallic;
    (*bsdfData_2).specularF90_ = mix(_e94, 1f, _e96);
    let _e99: vec3<f32> = albedoColor;
    let _e101: f32 = metallic;
    let _e105: vec3<f32> = dielectricF0_;
    let _e107: vec3<f32> = dielectricF0_;
    let _e110: vec3<f32> = dielectricF0_;
    (*bsdfData_2).diffuseColor = ((_e99 * (1f - _e101)) * (1f - max(max(_e105.x, _e107.y), _e110.z)));
    let _e117: f32 = roughness_6;
    let _e118: SurfaceData = surfaceData_3;
    let _e120: f32 = getAARoughnessFactor(_e118.normal);
    (*bsdfData_2).roughness = max(0.045f, min((_e117 + _e120), 1f));
    let _e126: BSDFData = (*bsdfData_2);
    (*bsdfData_2).resolvedSpecularF0_ = _e126.specularF0_;
    let _e128: BSDFData = (*bsdfData_2);
    let _e130: SurfaceData = surfaceData_3;
    let _e132: vec2<f32> = envDFGApprox(_e128.roughness, _e130.dotNV);
    dfg = _e132;
    let _e135: BSDFData = (*bsdfData_2);
    let _e137: vec2<f32> = dfg;
    let _e140: BSDFData = (*bsdfData_2);
    let _e142: vec2<f32> = dfg;
    (*bsdfData_2).envSpecularDFG = ((_e135.resolvedSpecularF0_ * _e137.x) + vec3((_e140.specularF90_ * _e142.y)));
    let _e149: BSDFData = (*bsdfData_2);
    let _e152: vec2<f32> = dfg;
    let _e154: vec2<f32> = dfg;
    (*bsdfData_2).energyCompensation = (vec3(1f) + (_e149.resolvedSpecularF0_ * ((1f / max((_e152.x + _e154.y), 0.000001f)) - 1f)));
    let _e166: SurfaceData = surfaceData_3;
    (*bsdfData_2).diffuseAO = _e166.ambientOcclusion;
    return;
}

fn getTBNByDerivatives(uv_3: vec2<f32>, normal_4: vec3<f32>, position: vec3<f32>, isFrontFacing: bool) -> mat3x3<f32> {
    var uv_4: vec2<f32>;
    var normal_5: vec3<f32>;
    var position_1: vec3<f32>;
    var isFrontFacing_1: bool;
    var local_1: vec2<f32>;
    var dp1_: vec3<f32>;
    var dp2_: vec3<f32>;
    var duv1_: vec2<f32>;
    var duv2_: vec2<f32>;
    var dp2perp: vec3<f32>;
    var dp1perp: vec3<f32>;
    var tangent: vec3<f32>;
    var bitangent: vec3<f32>;
    var denom_1: f32;
    var local_2: f32;
    var invmax: f32;

    uv_4 = uv_3;
    normal_5 = normal_4;
    position_1 = position;
    isFrontFacing_1 = isFrontFacing;
    let _e57: bool = isFrontFacing_1;
    if _e57 {
        let _e58: vec2<f32> = uv_4;
        local_1 = _e58;
    } else {
        let _e59: vec2<f32> = uv_4;
        local_1 = -(_e59);
    }
    let _e62: vec2<f32> = local_1;
    uv_4 = _e62;
    let _e63: vec3<f32> = position_1;
    let _e64: vec3<f32> = dpdx(_e63);
    dp1_ = _e64;
    let _e66: vec3<f32> = position_1;
    let _e67: vec3<f32> = dpdy(_e66);
    dp2_ = -(_e67);
    let _e70: vec2<f32> = uv_4;
    let _e71: vec2<f32> = dpdx(_e70);
    duv1_ = _e71;
    let _e73: vec2<f32> = uv_4;
    let _e74: vec2<f32> = dpdy(_e73);
    duv2_ = -(_e74);
    let _e77: vec3<f32> = dp2_;
    let _e78: vec3<f32> = normal_5;
    dp2perp = cross(_e77, _e78);
    let _e81: vec3<f32> = normal_5;
    let _e82: vec3<f32> = dp1_;
    dp1perp = cross(_e81, _e82);
    let _e85: vec3<f32> = dp2perp;
    let _e86: vec2<f32> = duv1_;
    let _e89: vec3<f32> = dp1perp;
    let _e90: vec2<f32> = duv2_;
    tangent = ((_e85 * _e86.x) + (_e89 * _e90.x));
    let _e95: vec3<f32> = dp2perp;
    let _e96: vec2<f32> = duv1_;
    let _e99: vec3<f32> = dp1perp;
    let _e100: vec2<f32> = duv2_;
    bitangent = ((_e95 * _e96.y) + (_e99 * _e100.y));
    let _e105: vec3<f32> = tangent;
    let _e106: vec3<f32> = tangent;
    let _e108: vec3<f32> = bitangent;
    let _e109: vec3<f32> = bitangent;
    denom_1 = max(dot(_e105, _e106), dot(_e108, _e109));
    let _e113: f32 = denom_1;
    if (_e113 == 0f) {
        local_2 = 0f;
    } else {
        let _e117: vec4<f32> = global_1.camera_ProjectionParams;
        let _e119: f32 = denom_1;
        local_2 = (_e117.x / sqrt(_e119));
    }
    let _e123: f32 = local_2;
    invmax = _e123;
    let _e125: vec3<f32> = tangent;
    let _e126: f32 = invmax;
    let _e127: vec3<f32> = (_e125 * _e126);
    let _e128: vec3<f32> = bitangent;
    let _e129: f32 = invmax;
    let _e130: vec3<f32> = (_e128 * _e129);
    let _e131: vec3<f32> = normal_5;
    return mat3x3<f32>(vec3<f32>(_e127.x, _e127.y, _e127.z), vec3<f32>(_e130.x, _e130.y, _e130.z), vec3<f32>(_e131.x, _e131.y, _e131.z));
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn terrainProjectSurfaceClimateHash(cell: vec2<f32>) -> f32 {
    var cell_1: vec2<f32>;

    cell_1 = cell;
    let _e51: vec2<f32> = cell_1;
    return fract((sin(dot(_e51, vec2<f32>(127.1f, 311.7f))) * 43758.547f));
}

fn terrainProjectSurfaceClimateValueNoise(position_2: vec2<f32>) -> f32 {
    var position_3: vec2<f32>;
    var cell_2: vec2<f32>;
    var local_3: vec2<f32>;
    var blend: vec2<f32>;
    var lower: f32;
    var upper: f32;

    position_3 = position_2;
    let _e51: vec2<f32> = position_3;
    cell_2 = floor(_e51);
    let _e54: vec2<f32> = position_3;
    local_3 = fract(_e54);
    let _e57: vec2<f32> = local_3;
    let _e58: vec2<f32> = local_3;
    let _e62: vec2<f32> = local_3;
    blend = ((_e57 * _e58) * (vec2(3f) - (2f * _e62)));
    let _e68: vec2<f32> = cell_2;
    let _e69: f32 = terrainProjectSurfaceClimateHash(_e68);
    let _e70: vec2<f32> = cell_2;
    let _e75: f32 = terrainProjectSurfaceClimateHash((_e70 + vec2<f32>(1f, 0f)));
    let _e76: vec2<f32> = blend;
    lower = mix(_e69, _e75, _e76.x);
    let _e80: vec2<f32> = cell_2;
    let _e85: f32 = terrainProjectSurfaceClimateHash((_e80 + vec2<f32>(0f, 1f)));
    let _e86: vec2<f32> = cell_2;
    let _e91: f32 = terrainProjectSurfaceClimateHash((_e86 + vec2<f32>(1f, 1f)));
    let _e92: vec2<f32> = blend;
    upper = mix(_e85, _e91, _e92.x);
    let _e96: f32 = lower;
    let _e97: f32 = upper;
    let _e98: vec2<f32> = blend;
    return mix(_e96, _e97, _e98.y);
}

fn terrainProjectSurfaceClimateNoise(worldXZ: vec2<f32>) -> f32 {
    var worldXZ_1: vec2<f32>;
    var broad: f32;
    var detail: f32;

    worldXZ_1 = worldXZ;
    let _e51: vec2<f32> = worldXZ_1;
    let _e54: f32 = terrainProjectSurfaceClimateValueNoise((_e51 * 0.055f));
    broad = _e54;
    let _e56: vec2<f32> = worldXZ_1;
    let _e63: f32 = terrainProjectSurfaceClimateValueNoise(((_e56 * 0.17f) + vec2<f32>(19.7f, 43.1f)));
    detail = _e63;
    let _e65: f32 = broad;
    let _e66: f32 = detail;
    return mix(_e65, _e66, 0.28f);
}

fn terrainProjectSurfaceWetness(response: f32) -> f32 {
    var response_1: f32;

    response_1 = response;
    let _e51: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e53: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e58: f32 = response_1;
    return clamp((max(_e51.x, (_e53.w * 0.48f)) * _e58), 0f, 1f);
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
    let _e54: vec2<f32> = response_3;
    let _e56: f32 = terrainProjectSurfaceWetness(_e54.x);
    wetness = _e56;
    let _e58: f32 = wetness;
    if (_e58 <= 0f) {
        return;
    }
    let _e62: SurfaceData = (*surfaceData_4);
    let _e69: SurfaceData = (*surfaceData_4);
    porousResponse = ((1f - _e62.metallic) * mix(0.35f, 1f, smoothstep(0.18f, 0.82f, _e69.roughness)));
    let _e75: f32 = wetness;
    let _e76: f32 = porousResponse;
    wetSubstrate = (_e75 * _e76);
    let _e79: SurfaceData = (*surfaceData_4);
    substrateLuminance = dot(_e79.albedoColor, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e87: f32 = substrateLuminance;
    let _e89: SurfaceData = (*surfaceData_4);
    saturatedSubstrate = mix(vec3(_e87), _e89.albedoColor, vec3(1.08f));
    let _e95: vec3<f32> = saturatedSubstrate;
    wetAlbedo = max((_e95 * 0.78f), vec3(0f));
    let _e103: SurfaceData = (*surfaceData_4);
    let _e105: vec3<f32> = wetAlbedo;
    let _e106: f32 = wetSubstrate;
    (*surfaceData_4).albedoColor = mix(_e103.albedoColor, _e105, vec3(_e106));
    let _e110: SurfaceData = (*surfaceData_4);
    wetRoughness = max(0.14f, (_e110.roughness * 0.62f));
    let _e117: SurfaceData = (*surfaceData_4);
    let _e119: f32 = wetRoughness;
    let _e120: f32 = wetSubstrate;
    (*surfaceData_4).roughness = mix(_e117.roughness, _e119, (_e120 * 0.72f));
    let _e125: SurfaceData = (*surfaceData_4);
    let _e127: SurfaceData = (*surfaceData_4);
    (*surfaceData_4).dotNV = clamp(dot(_e125.normal, _e127.viewDir), 0f, 1f);
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
    let _e55: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e57: f32 = response_5;
    snowStorage = clamp((_e55.z * _e57), 0f, 1f);
    let _e63: f32 = snowStorage;
    if (_e63 <= 0f) {
        return 0f;
    }
    let _e67: vec3<f32> = worldPosition_1;
    let _e69: f32 = terrainProjectSurfaceClimateNoise(_e67.xz);
    distribution = _e69;
    let _e73: f32 = snowStorage;
    let _e74: f32 = distribution;
    snowDistribution = smoothstep(0.06f, 0.64f, (_e73 + ((_e74 - 0.5f) * 0.22f)));
    let _e82: vec3<f32> = geometryNormal_3;
    upward = clamp(normalize(_e82).y, 0f, 1f);
    let _e89: f32 = snowDistribution;
    let _e92: f32 = upward;
    let _e95: f32 = snowStorage;
    return ((_e89 * smoothstep(0.34f, 0.82f, _e92)) * _e95);
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
    let _e58: f32 = snow_1;
    if (_e58 <= 0f) {
        return;
    }
    let _e62: SurfaceData = (*surfaceData_5);
    let _e64: vec4<f32> = global_1.scene_SurfaceSnowColor;
    let _e66: f32 = snow_1;
    (*surfaceData_5).albedoColor = mix(_e62.albedoColor, _e64.xyz, vec3(_e66));
    let _e70: SurfaceData = (*surfaceData_5);
    let _e73: f32 = snow_1;
    (*surfaceData_5).metallic = mix(_e70.metallic, 0f, _e73);
    let _e76: SurfaceData = (*surfaceData_5);
    let _e78: f32 = targetRoughness_1;
    let _e79: f32 = snow_1;
    (*surfaceData_5).roughness = mix(_e76.roughness, _e78, _e79);
    let _e82: SurfaceData = (*surfaceData_5);
    let _e85: f32 = snow_1;
    (*surfaceData_5).specularIntensity = mix(_e82.specularIntensity, 0.68f, _e85);
    let _e88: SurfaceData = (*surfaceData_5);
    let _e90: vec3<f32> = geometryNormal_5;
    let _e92: f32 = snow_1;
    let _e93: f32 = normalFlattening_1;
    (*surfaceData_5).normal = normalize(mix(_e88.normal, normalize(_e90), vec3((_e92 * _e93))));
    return;
}

fn terrainProjectApplySurfaceClimate(surfaceData_6: ptr<function, SurfaceData>, geometryNormal_6: vec3<f32>, response_6: vec3<f32>) {
    var geometryNormal_7: vec3<f32>;
    var response_7: vec3<f32>;
    var snow_2: f32;

    geometryNormal_7 = geometryNormal_6;
    response_7 = response_6;
    let _e55: vec3<f32> = geometryNormal_7;
    let _e56: vec3<f32> = response_7;
    terrainProjectApplySurfaceMoisture(surfaceData_6, _e55, _e56.xy);
    let _e59: SurfaceData = (*surfaceData_6);
    let _e61: vec3<f32> = geometryNormal_7;
    let _e62: vec3<f32> = response_7;
    let _e64: f32 = terrainProjectTopSnowMask(_e59.position, _e61, _e62.z);
    snow_2 = _e64;
    let _e67: vec3<f32> = geometryNormal_7;
    let _e68: f32 = snow_2;
    terrainProjectApplyTopSnowLayer(surfaceData_6, _e67, _e68, 0.82f, 0.28f);
    let _e73: SurfaceData = (*surfaceData_6);
    let _e75: SurfaceData = (*surfaceData_6);
    (*surfaceData_6).dotNV = clamp(dot(_e73.normal, _e75.viewDir), 0f, 1f);
    return;
}

fn evaluateSurfaceMaterial(varyings: Varyings, isFrontFacing_2: bool) -> SurfaceData {
    var varyings_1: Varyings;
    var isFrontFacing_3: bool;
    var surfaceData_7: SurfaceData;
    var materialUv: vec2<f32>;
    var local_4: f32;
    var faceSign: f32;
    var geometryNormal_8: vec3<f32>;
    var baseTexture: vec4<f32> = vec4(1f);
    var albedoColor_1: vec3<f32>;
    var metallic_1: f32;
    var smoothness: f32;
    var ambientOcclusion: f32 = 1f;
    var shadingNormal: vec3<f32>;
    var baseTangentNormal: vec3<f32> = vec3<f32>(0f, 0f, 1f);

    varyings_1 = varyings;
    isFrontFacing_3 = isFrontFacing_2;
    let _e54: Varyings = varyings_1;
    let _e56: f32 = global_1.material_Tiling;
    materialUv = (_e54.uv * _e56);
    let _e59: bool = isFrontFacing_3;
    if _e59 {
        local_4 = 1f;
    } else {
        local_4 = -1f;
    }
    let _e64: f32 = local_4;
    faceSign = _e64;
    let _e66: Varyings = varyings_1;
    let _e68: vec3<f32> = dpdx(_e66.positionWS);
    let _e69: Varyings = varyings_1;
    let _e71: vec3<f32> = dpdy(_e69.positionWS);
    let _e75: f32 = faceSign;
    geometryNormal_8 = (normalize(cross(_e68, -(_e71))) * _e75);
    let _e81: vec4<f32> = global_1.material_BaseColor;
    let _e83: vec4<f32> = baseTexture;
    albedoColor_1 = (_e81.xyz * _e83.xyz);
    let _e87: f32 = global_1.material_Metallic;
    metallic_1 = _e87;
    let _e89: f32 = global_1.material_Smoothness;
    smoothness = _e89;
    let _e93: vec3<f32> = geometryNormal_8;
    shadingNormal = _e93;
    let _e101: vec3<f32> = albedoColor_1;
    surfaceData_7.albedoColor = _e101;
    surfaceData_7.emissiveColor = vec3(0f);
    let _e106: f32 = metallic_1;
    surfaceData_7.metallic = clamp(_e106, 0f, 1f);
    let _e112: f32 = smoothness;
    surfaceData_7.roughness = (1f - clamp(_e112, 0f, 1f));
    let _e118: f32 = ambientOcclusion;
    surfaceData_7.ambientOcclusion = clamp(_e118, 0f, 1f);
    surfaceData_7.opacity = 1f;
    surfaceData_7.IOR = 1.5f;
    let _e127: Varyings = varyings_1;
    surfaceData_7.position = _e127.positionWS;
    let _e130: Varyings = varyings_1;
    surfaceData_7.positionCS = _e130.positionCS;
    let _e133: vec3<f32> = shadingNormal;
    surfaceData_7.normal = _e133;
    let _e135: vec3<f32> = global.camera_Position;
    let _e136: Varyings = varyings_1;
    surfaceData_7.viewDir = normalize((_e135 - _e136.positionWS));
    let _e141: SurfaceData = surfaceData_7;
    let _e143: SurfaceData = surfaceData_7;
    surfaceData_7.dotNV = clamp(dot(_e141.normal, _e143.viewDir), 0f, 1f);
    surfaceData_7.specularIntensity = 1f;
    surfaceData_7.specularColor = vec3(1f);
    let _e154: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e155: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e159: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    if ((dot(_e154, _e155) > 0f) || (_e159.y > 0f)) {
        {
            let _e165: vec3<f32> = geometryNormal_8;
            terrainProjectApplySurfaceClimate((&surfaceData_7), _e165, vec3<f32>(1f, 0.35f, 0.9f));
        }
    }
    let _e171: SurfaceData = surfaceData_7;
    return _e171;
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
    let _e53: vec2<i32> = rendererLayer_1;
    let _e55: vec2<i32> = lightCullingMask_1;
    let _e60: vec2<i32> = rendererLayer_1;
    let _e62: vec2<i32> = lightCullingMask_1;
    return !((((_e53.x & _e55.x) != 0i) || ((_e60.y & _e62.y) != 0i)));
}

fn diffuseLobe(varyings_2: Varyings, surfaceData_8: SurfaceData, bsdfData_3: BSDFData, attenuationIrradiance: vec3<f32>, diffuseColor_2: ptr<function, vec3<f32>>) {
    var varyings_3: Varyings;
    var surfaceData_9: SurfaceData;
    var bsdfData_4: BSDFData;
    var attenuationIrradiance_1: vec3<f32>;

    varyings_3 = varyings_2;
    surfaceData_9 = surfaceData_8;
    bsdfData_4 = bsdfData_3;
    attenuationIrradiance_1 = attenuationIrradiance;
    let _e62: vec3<f32> = (*diffuseColor_2);
    let _e63: vec3<f32> = attenuationIrradiance_1;
    let _e64: BSDFData = bsdfData_4;
    let _e66: vec3<f32> = BRDF_Diffuse_Lambert(_e64.diffuseColor);
    (*diffuseColor_2) = (_e62 + (_e63 * _e66));
    return;
}

fn specularLobe(varyings_4: Varyings, surfaceData_10: SurfaceData, bsdfData_5: BSDFData, incidentDirection_2: vec3<f32>, attenuationIrradiance_2: vec3<f32>, specularColor_2: ptr<function, vec3<f32>>) {
    var varyings_5: Varyings;
    var surfaceData_11: SurfaceData;
    var bsdfData_6: BSDFData;
    var incidentDirection_3: vec3<f32>;
    var attenuationIrradiance_3: vec3<f32>;

    varyings_5 = varyings_4;
    surfaceData_11 = surfaceData_10;
    bsdfData_6 = bsdfData_5;
    incidentDirection_3 = incidentDirection_2;
    attenuationIrradiance_3 = attenuationIrradiance_2;
    let _e64: vec3<f32> = (*specularColor_2);
    let _e65: vec3<f32> = attenuationIrradiance_3;
    let _e66: vec3<f32> = incidentDirection_3;
    let _e67: SurfaceData = surfaceData_11;
    let _e68: BSDFData = bsdfData_6;
    let _e69: SurfaceData = surfaceData_11;
    let _e71: BSDFData = bsdfData_6;
    let _e73: BSDFData = bsdfData_6;
    let _e75: vec3<f32> = BRDF_Specular_GGX(_e66, _e67, _e68, _e69.normal, _e71.specularF0_, _e73.roughness);
    let _e77: BSDFData = bsdfData_6;
    (*specularColor_2) = (_e64 + ((_e65 * _e75) * _e77.energyCompensation));
    return;
}

fn sheenLobe(varyings_6: Varyings, surfaceData_12: SurfaceData, bsdfData_7: BSDFData, incidentDirection_4: vec3<f32>, attenuationIrradiance_4: vec3<f32>, diffuseColor_3: ptr<function, vec3<f32>>, specularColor_3: ptr<function, vec3<f32>>) {
    var varyings_7: Varyings;
    var surfaceData_13: SurfaceData;
    var bsdfData_8: BSDFData;
    var incidentDirection_5: vec3<f32>;
    var attenuationIrradiance_5: vec3<f32>;

    varyings_7 = varyings_6;
    surfaceData_13 = surfaceData_12;
    bsdfData_8 = bsdfData_7;
    incidentDirection_5 = incidentDirection_4;
    attenuationIrradiance_5 = attenuationIrradiance_4;
    return;
}

fn clearCoatLobe(varyings_8: Varyings, surfaceData_14: SurfaceData, bsdfData_9: BSDFData, incidentDirection_6: vec3<f32>, color: vec3<f32>, specularColor_4: ptr<function, vec3<f32>>) -> f32 {
    var varyings_9: Varyings;
    var surfaceData_15: SurfaceData;
    var bsdfData_10: BSDFData;
    var incidentDirection_7: vec3<f32>;
    var color_1: vec3<f32>;
    var attenuation: f32 = 1f;

    varyings_9 = varyings_8;
    surfaceData_15 = surfaceData_14;
    bsdfData_10 = bsdfData_9;
    incidentDirection_7 = incidentDirection_6;
    color_1 = color;
    let _e66: f32 = attenuation;
    return _e66;
}

fn surfaceShading(varyings_10: Varyings, surfaceData_16: SurfaceData, bsdfData_11: BSDFData, incidentDirection_8: vec3<f32>, lightColor: vec3<f32>, totalDiffuseColor: ptr<function, vec3<f32>>, totalSpecularColor: ptr<function, vec3<f32>>) {
    var varyings_11: Varyings;
    var surfaceData_17: SurfaceData;
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
    surfaceData_17 = surfaceData_16;
    bsdfData_12 = bsdfData_11;
    incidentDirection_9 = incidentDirection_8;
    lightColor_1 = lightColor;
    let _e73: SurfaceData = surfaceData_17;
    let _e75: vec3<f32> = incidentDirection_9;
    dotNL_5 = clamp(dot(_e73.normal, _e75), 0f, 1f);
    let _e81: f32 = dotNL_5;
    let _e82: vec3<f32> = lightColor_1;
    irradiance = ((_e81 * _e82) * 3.1415927f);
    let _e87: Varyings = varyings_11;
    let _e88: SurfaceData = surfaceData_17;
    let _e89: BSDFData = bsdfData_12;
    let _e90: vec3<f32> = incidentDirection_9;
    let _e91: vec3<f32> = lightColor_1;
    let _e94: f32 = clearCoatLobe(_e87, _e88, _e89, _e90, _e91, (&specularColor_5));
    attenuation_1 = _e94;
    let _e96: f32 = attenuation_1;
    let _e97: vec3<f32> = irradiance;
    attenuationIrradiance_6 = (_e96 * _e97);
    let _e100: Varyings = varyings_11;
    let _e101: SurfaceData = surfaceData_17;
    let _e102: BSDFData = bsdfData_12;
    let _e103: vec3<f32> = attenuationIrradiance_6;
    diffuseLobe(_e100, _e101, _e102, _e103, (&diffuseColor_4));
    let _e106: Varyings = varyings_11;
    let _e107: SurfaceData = surfaceData_17;
    let _e108: BSDFData = bsdfData_12;
    let _e109: vec3<f32> = incidentDirection_9;
    let _e110: vec3<f32> = attenuationIrradiance_6;
    specularLobe(_e106, _e107, _e108, _e109, _e110, (&specularColor_5));
    let _e113: Varyings = varyings_11;
    let _e114: SurfaceData = surfaceData_17;
    let _e115: BSDFData = bsdfData_12;
    let _e116: vec3<f32> = incidentDirection_9;
    let _e117: vec3<f32> = attenuationIrradiance_6;
    sheenLobe(_e113, _e114, _e115, _e116, _e117, (&diffuseColor_4), (&specularColor_5));
    let _e122: vec3<f32> = (*totalDiffuseColor);
    let _e123: vec3<f32> = diffuseColor_4;
    (*totalDiffuseColor) = (_e122 + _e123);
    let _e125: vec3<f32> = (*totalSpecularColor);
    let _e126: vec3<f32> = specularColor_5;
    (*totalSpecularColor) = (_e125 + _e126);
    return;
}

fn evaluateDirectRadiance(varyings_12: Varyings, surfaceData_18: SurfaceData, bsdfData_13: BSDFData, shadowAttenuation: f32, totalDiffuseColor_1: ptr<function, vec3<f32>>, totalSpecularColor_1: ptr<function, vec3<f32>>) {
    var varyings_13: Varyings;
    var surfaceData_19: SurfaceData;
    var bsdfData_14: BSDFData;
    var shadowAttenuation_1: f32;

    varyings_13 = varyings_12;
    surfaceData_19 = surfaceData_18;
    bsdfData_14 = bsdfData_13;
    shadowAttenuation_1 = shadowAttenuation;
    return;
}

fn getReflectedVector(surfaceData_20: SurfaceData, n: vec3<f32>) -> vec3<f32> {
    var surfaceData_21: SurfaceData;
    var n_1: vec3<f32>;
    var r_1: vec3<f32>;

    surfaceData_21 = surfaceData_20;
    n_1 = n;
    let _e57: SurfaceData = surfaceData_21;
    let _e60: vec3<f32> = n_1;
    r_1 = reflect(-(_e57.viewDir), _e60);
    let _e63: vec3<f32> = r_1;
    return _e63;
}

fn getSpecularMIPLevel(roughness_7: f32, maxMIPLevel: i32) -> f32 {
    var roughness_8: f32;
    var maxMIPLevel_1: i32;

    roughness_8 = roughness_7;
    maxMIPLevel_1 = maxMIPLevel;
    let _e57: f32 = roughness_8;
    let _e58: i32 = maxMIPLevel_1;
    return (_e57 * f32(_e58));
}

fn getLightProbeRadiance(surfaceData_22: SurfaceData, normal_6: vec3<f32>, roughness_9: f32) -> vec3<f32> {
    var surfaceData_23: SurfaceData;
    var normal_7: vec3<f32>;
    var roughness_10: f32;

    surfaceData_23 = surfaceData_22;
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
    let _e61: f32 = specularAOFactor;
    return _e61;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal_8: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_9: vec3<f32>;
    var result: vec3<f32>;

    sh_1 = sh;
    normal_9 = normal_8;
    let _e59: vec3<f32> = sh_1[0];
    let _e62: vec3<f32> = sh_1[1];
    let _e63: vec3<f32> = normal_9;
    let _e69: vec3<f32> = sh_1[2];
    let _e70: vec3<f32> = normal_9;
    let _e76: vec3<f32> = sh_1[3];
    let _e77: vec3<f32> = normal_9;
    let _e83: vec3<f32> = sh_1[4];
    let _e84: vec3<f32> = normal_9;
    let _e86: vec3<f32> = normal_9;
    let _e93: vec3<f32> = sh_1[5];
    let _e94: vec3<f32> = normal_9;
    let _e96: vec3<f32> = normal_9;
    let _e103: vec3<f32> = sh_1[6];
    let _e105: vec3<f32> = normal_9;
    let _e108: vec3<f32> = normal_9;
    let _e117: vec3<f32> = sh_1[7];
    let _e118: vec3<f32> = normal_9;
    let _e120: vec3<f32> = normal_9;
    let _e127: vec3<f32> = sh_1[8];
    let _e128: vec3<f32> = normal_9;
    let _e130: vec3<f32> = normal_9;
    let _e133: vec3<f32> = normal_9;
    let _e135: vec3<f32> = normal_9;
    result = ((((((((_e59 + (_e62 * _e63.y)) + (_e69 * _e70.z)) + (_e76 * _e77.x)) + (_e83 * (_e84.y * _e86.x))) + (_e93 * (_e94.y * _e96.z))) + (_e103 * (((3f * _e105.z) * _e108.z) - 1f))) + (_e117 * (_e118.z * _e120.x))) + (_e127 * ((_e128.x * _e130.x) - (_e133.y * _e135.y))));
    let _e142: vec3<f32> = result;
    return max(_e142, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS_1: vec3<f32>) -> vec3<f32> {
    var normalWS_2: vec3<f32>;

    normalWS_2 = normalWS_1;
    let _e55: EnvMapLight = scene_EnvMapLight;
    return (_e55.diffuse * 3.1415927f);
}

fn evaluateDiffuseIBL(varyings_14: Varyings, surfaceData_24: SurfaceData, bsdfData_15: BSDFData, diffuseColor_5: ptr<function, vec3<f32>>) {
    var varyings_15: Varyings;
    var surfaceData_25: SurfaceData;
    var bsdfData_16: BSDFData;
    var irradiance_1: vec3<f32>;

    varyings_15 = varyings_14;
    surfaceData_25 = surfaceData_24;
    bsdfData_16 = bsdfData_15;
    let _e60: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e60.diffuse * 3.1415927f);
    let _e65: vec3<f32> = irradiance_1;
    let _e66: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e65 * _e66.diffuseIntensity);
    let _e69: vec3<f32> = (*diffuseColor_5);
    let _e70: BSDFData = bsdfData_16;
    let _e72: vec3<f32> = irradiance_1;
    let _e74: BSDFData = bsdfData_16;
    let _e76: vec3<f32> = BRDF_Diffuse_Lambert(_e74.diffuseColor);
    (*diffuseColor_5) = (_e69 + ((_e70.diffuseAO * _e72) * _e76));
    return;
}

fn evaluateClearCoatIBL(varyings_16: Varyings, surfaceData_26: SurfaceData, bsdfData_17: BSDFData, specularColor_6: ptr<function, vec3<f32>>) -> f32 {
    var varyings_17: Varyings;
    var surfaceData_27: SurfaceData;
    var bsdfData_18: BSDFData;
    var radianceAttenuation: f32 = 1f;

    varyings_17 = varyings_16;
    surfaceData_27 = surfaceData_26;
    bsdfData_18 = bsdfData_17;
    let _e62: f32 = radianceAttenuation;
    return _e62;
}

fn evaluateSpecularIBL(varyings_18: Varyings, surfaceData_28: SurfaceData, bsdfData_19: BSDFData, radianceAttenuation_1: f32, outSpecularColor: ptr<function, vec3<f32>>) {
    var varyings_19: Varyings;
    var surfaceData_29: SurfaceData;
    var bsdfData_20: BSDFData;
    var radianceAttenuation_2: f32;
    var radiance: vec3<f32>;
    var specularAO: f32;

    varyings_19 = varyings_18;
    surfaceData_29 = surfaceData_28;
    bsdfData_20 = bsdfData_19;
    radianceAttenuation_2 = radianceAttenuation_1;
    let _e62: SurfaceData = surfaceData_29;
    let _e63: SurfaceData = surfaceData_29;
    let _e65: BSDFData = bsdfData_20;
    let _e67: vec3<f32> = getLightProbeRadiance(_e62, _e63.normal, _e65.roughness);
    radiance = _e67;
    let _e69: SurfaceData = surfaceData_29;
    let _e71: BSDFData = bsdfData_20;
    let _e73: BSDFData = bsdfData_20;
    let _e75: f32 = evaluateSpecularOcclusion(_e69.dotNV, _e71.diffuseAO, _e73.roughness);
    specularAO = _e75;
    let _e77: vec3<f32> = (*outSpecularColor);
    let _e78: f32 = specularAO;
    let _e79: f32 = radianceAttenuation_2;
    let _e81: vec3<f32> = radiance;
    let _e83: BSDFData = bsdfData_20;
    let _e85: BSDFData = bsdfData_20;
    let _e87: BSDFData = bsdfData_20;
    let _e89: SurfaceData = surfaceData_29;
    let _e91: vec3<f32> = envBRDFApprox(_e83.resolvedSpecularF0_, _e85.specularF90_, _e87.roughness, _e89.dotNV);
    let _e93: BSDFData = bsdfData_20;
    (*outSpecularColor) = (_e77 + ((((_e78 * _e79) * _e81) * _e91) * _e93.energyCompensation));
    return;
}

fn evaluateSheenIBL(varyings_20: Varyings, surfaceData_30: SurfaceData, bsdfData_21: BSDFData, radianceAttenuation_3: f32, diffuseColor_6: ptr<function, vec3<f32>>, specularColor_7: ptr<function, vec3<f32>>) {
    var varyings_21: Varyings;
    var surfaceData_31: SurfaceData;
    var bsdfData_22: BSDFData;
    var radianceAttenuation_4: f32;

    varyings_21 = varyings_20;
    surfaceData_31 = surfaceData_30;
    bsdfData_22 = bsdfData_21;
    radianceAttenuation_4 = radianceAttenuation_3;
    return;
}

fn evaluateIBL(varyings_22: Varyings, surfaceData_32: SurfaceData, bsdfData_23: BSDFData, totalDiffuseColor_2: ptr<function, vec3<f32>>, totalSpecularColor_2: ptr<function, vec3<f32>>) {
    var varyings_23: Varyings;
    var surfaceData_33: SurfaceData;
    var bsdfData_24: BSDFData;
    var diffuseColor_7: vec3<f32> = vec3(0f);
    var specularColor_8: vec3<f32> = vec3(0f);
    var radianceAttenuation_5: f32;

    varyings_23 = varyings_22;
    surfaceData_33 = surfaceData_32;
    bsdfData_24 = bsdfData_23;
    let _e69: Varyings = varyings_23;
    let _e70: SurfaceData = surfaceData_33;
    let _e71: BSDFData = bsdfData_24;
    evaluateDiffuseIBL(_e69, _e70, _e71, (&diffuseColor_7));
    let _e74: Varyings = varyings_23;
    let _e75: SurfaceData = surfaceData_33;
    let _e76: BSDFData = bsdfData_24;
    let _e79: f32 = evaluateClearCoatIBL(_e74, _e75, _e76, (&specularColor_8));
    radianceAttenuation_5 = _e79;
    let _e81: Varyings = varyings_23;
    let _e82: SurfaceData = surfaceData_33;
    let _e83: BSDFData = bsdfData_24;
    let _e84: f32 = radianceAttenuation_5;
    evaluateSpecularIBL(_e81, _e82, _e83, _e84, (&specularColor_8));
    let _e87: Varyings = varyings_23;
    let _e88: SurfaceData = surfaceData_33;
    let _e89: BSDFData = bsdfData_24;
    let _e90: f32 = radianceAttenuation_5;
    evaluateSheenIBL(_e87, _e88, _e89, _e90, (&diffuseColor_7), (&specularColor_8));
    let _e95: vec3<f32> = (*totalDiffuseColor_2);
    let _e96: vec3<f32> = diffuseColor_7;
    (*totalDiffuseColor_2) = (_e95 + _e96);
    let _e98: vec3<f32> = (*totalSpecularColor_2);
    let _e99: vec3<f32> = specularColor_8;
    (*totalSpecularColor_2) = (_e98 + _e99);
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
    let _e57: f32 = attenuation_2;
    return _e57;
}

fn terrainProjectEvaluateSpecularIBL(surfaceData_34: SurfaceData, bsdfData_25: BSDFData, radiance_1: vec3<f32>) -> vec3<f32> {
    var surfaceData_35: SurfaceData;
    var bsdfData_26: BSDFData;
    var radiance_2: vec3<f32>;
    var specularAO_1: f32;

    surfaceData_35 = surfaceData_34;
    bsdfData_26 = bsdfData_25;
    radiance_2 = radiance_1;
    let _e59: SurfaceData = surfaceData_35;
    let _e61: BSDFData = bsdfData_26;
    let _e63: BSDFData = bsdfData_26;
    let _e65: f32 = evaluateSpecularOcclusion(_e59.dotNV, _e61.diffuseAO, _e63.roughness);
    specularAO_1 = _e65;
    let _e67: f32 = specularAO_1;
    let _e68: vec3<f32> = radiance_2;
    let _e70: BSDFData = bsdfData_26;
    let _e72: BSDFData = bsdfData_26;
    let _e74: BSDFData = bsdfData_26;
    let _e76: SurfaceData = surfaceData_35;
    let _e78: vec3<f32> = envBRDFApprox(_e70.resolvedSpecularF0_, _e72.specularF90_, _e74.roughness, _e76.dotNV);
    let _e80: BSDFData = bsdfData_26;
    return (((_e67 * _e68) * _e78) * _e80.energyCompensation);
}

fn evaluateTerrainProjectLightingWithShadow(varyings_26: Varyings, surfaceData_36: SurfaceData, shadowAttenuation_2: f32) -> TerrainProjectLightingResult {
    var varyings_27: Varyings;
    var surfaceData_37: SurfaceData;
    var shadowAttenuation_3: f32;
    var result_1: TerrainProjectLightingResult;
    var bsdfData_27: BSDFData;
    var directShadowAttenuation: f32;

    varyings_27 = varyings_26;
    surfaceData_37 = surfaceData_36;
    shadowAttenuation_3 = shadowAttenuation_2;
    result_1.directDiffuse = vec3(0f);
    result_1.directSpecular = vec3(0f);
    result_1.environmentDiffuse = vec3(0f);
    result_1.environmentSpecular = vec3(0f);
    let _e73: f32 = shadowAttenuation_3;
    result_1.shadowAttenuation = _e73;
    let _e75: SurfaceData = surfaceData_37;
    surfaceData_37.albedoColor = _e75.albedoColor;
    let _e78: SurfaceData = surfaceData_37;
    initBSDFData(_e78, (&bsdfData_27));
    let _e81: TerrainProjectLightingResult = result_1;
    directShadowAttenuation = _e81.shadowAttenuation;
    let _e84: Varyings = varyings_27;
    let _e85: SurfaceData = surfaceData_37;
    let _e86: BSDFData = bsdfData_27;
    let _e87: f32 = directShadowAttenuation;
    let _e88: TerrainProjectLightingResult = result_1;
    let _e90: TerrainProjectLightingResult = result_1;
    var gs_output_arg0 = result_1.directDiffuse;
    var gs_output_arg1 = result_1.directSpecular;
    evaluateDirectRadiance(_e84, _e85, _e86, _e87, (&gs_output_arg0), (&gs_output_arg1));
    result_1.directDiffuse = gs_output_arg0;
    result_1.directSpecular = gs_output_arg1;
    let _e96: Varyings = varyings_27;
    let _e97: SurfaceData = surfaceData_37;
    let _e98: BSDFData = bsdfData_27;
    let _e99: TerrainProjectLightingResult = result_1;
    let _e101: TerrainProjectLightingResult = result_1;
    var gs_output_arg2 = result_1.environmentDiffuse;
    var gs_output_arg3 = result_1.environmentSpecular;
    evaluateIBL(_e96, _e97, _e98, (&gs_output_arg2), (&gs_output_arg3));
    result_1.environmentDiffuse = gs_output_arg2;
    result_1.environmentSpecular = gs_output_arg3;
    let _e107: TerrainProjectLightingResult = result_1;
    return _e107;
}

fn evaluateTerrainProjectLighting(varyings_28: Varyings, surfaceData_38: SurfaceData) -> TerrainProjectLightingResult {
    var varyings_29: Varyings;
    var surfaceData_39: SurfaceData;

    varyings_29 = varyings_28;
    surfaceData_39 = surfaceData_38;
    let _e57: Varyings = varyings_29;
    let _e58: SurfaceData = surfaceData_39;
    let _e59: Varyings = varyings_29;
    let _e60: f32 = sampleTerrainProjectShadow(_e59);
    let _e61: TerrainProjectLightingResult = evaluateTerrainProjectLightingWithShadow(_e57, _e58, _e60);
    return _e61;
}

fn terrainProjectFinalLighting(result_2: TerrainProjectLightingResult) -> vec3<f32> {
    var result_3: TerrainProjectLightingResult;

    result_3 = result_2;
    let _e55: TerrainProjectLightingResult = result_3;
    let _e57: TerrainProjectLightingResult = result_3;
    let _e60: TerrainProjectLightingResult = result_3;
    let _e63: TerrainProjectLightingResult = result_3;
    return (((_e55.directDiffuse + _e57.directSpecular) + _e60.environmentDiffuse) + _e63.environmentSpecular);
}

fn SurfaceFragment(varyings_30: Varyings) {
    var varyings_31: Varyings;
    var surfaceData_40: SurfaceData;
    var shadowAttenuation_4: f32;
    var lighting: TerrainProjectLightingResult;
    var color_2: vec4<f32>;

    varyings_31 = varyings_30;
    let _e56: vec4<f32> = gl_FragCoord_1;
    applyTerrainProjectLodDither(_e56.xy);
    let _e59: Varyings = varyings_31;
    let _e60: bool = gl_FrontFacing_1;
    let _e61: SurfaceData = evaluateSurfaceMaterial(_e59, _e60);
    surfaceData_40 = _e61;
    let _e63: Varyings = varyings_31;
    let _e64: f32 = sampleTerrainProjectShadow(_e63);
    let _e65: Varyings = varyings_31;
    shadowAttenuation_4 = (_e64 * _e65.cloudShadow);
    let _e69: Varyings = varyings_31;
    let _e70: SurfaceData = surfaceData_40;
    let _e71: f32 = shadowAttenuation_4;
    let _e72: TerrainProjectLightingResult = evaluateTerrainProjectLightingWithShadow(_e69, _e70, _e71);
    lighting = _e72;
    let _e74: TerrainProjectLightingResult = lighting;
    let _e75: vec3<f32> = terrainProjectFinalLighting(_e74);
    color_2 = vec4<f32>(_e75.x, _e75.y, _e75.z, 1f);
    let _e82: vec4<f32> = color_2;
    converted_FragColor = _e82;
    return;
}

fn gs_wgpu_main() {
    var input_varyings: Varyings;

    let _e55: Varyings = read_Varyings();
    input_varyings = _e55;
    let _e57: Varyings = input_varyings;
    SurfaceFragment(_e57);
    return;
}

fn main_1() {
    let _e59: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e65: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e71: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e59.x), bitcast<f32>(_e65.y), bitcast<f32>(_e71.z));
    let _e79: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e79.w);
    let _e86: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e86.x);
    let _e93: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e93.y);
    let _e100: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e100.z);
    let _e107: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e107.w);
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) uv: vec2<f32>, @location(1) sourcePositionOSY: f32, @location(2) positionWS: vec3<f32>, @location(3) normalWS: vec3<f32>, @location(4) cloudShadow: f32, @location(5) positionCS: vec4<f32>, @builtin(position) gl_FragCoord: vec4<f32>, @builtin(front_facing) gl_FrontFacing: bool) -> FragmentOutput {
    uv_5 = uv;
    sourcePositionOSY_1 = sourcePositionOSY;
    positionWS_3 = positionWS;
    normalWS_3 = normalWS;
    cloudShadow_1 = cloudShadow;
    positionCS_1 = positionCS;
    gl_FragCoord_1 = gl_FragCoord;
    gl_FrontFacing_1 = gl_FrontFacing;
    main_1();
    let _e78: vec4<f32> = converted_FragColor;
    return FragmentOutput(_e78);
}
