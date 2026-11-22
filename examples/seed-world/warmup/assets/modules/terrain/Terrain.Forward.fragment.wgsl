diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ViewMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    material_TerrainRegionWorldBounds: array<vec4<f32>, 32>,
    material_TerrainRegionCount: i32,
    material_TerrainHeightAtlasInvSize: vec2<f32>,
    material_TerrainRegionAtlasRects: array<vec4<f32>, 32>,
    renderer_Lod: f32,
    scene_GrassSeasonColor: vec4<f32>,
    scene_TreeLeafSeasonColor: vec4<f32>,
    scene_TreeBarkSeasonColor: vec4<f32>,
}

struct gs_Auto_3_ {
    camera_DepthBufferParams: vec4<f32>,
    camera_ProjectionParams: vec4<f32>,
    camera_Forward: vec3<f32>,
    scene_SurfaceClimate: vec4<f32>,
    scene_SurfaceSnowColor: vec4<f32>,
    scene_TerrainWaterCoverageParams: vec4<f32>,
    scene_TerrainWaterSurfaceParams: vec4<f32>,
    scene_TerrainWaterOpticsParams: vec4<f32>,
    scene_TerrainRippleParams: vec4<f32>,
    scene_WeatherTime: f32,
    material_TerrainPuddleAtlasInvSize: vec2<f32>,
    material_TerrainRegionPuddleRects: array<vec4<f32>, 32>,
    material_BaseColor: vec4<f32>,
    material_Metallic: f32,
    material_Smoothness: f32,
    renderer_Layer: vec4<i32>,
}

struct Varyings {
    positionWS: vec3<f32>,
    sourceXZ: vec2<f32>,
    normalWS: vec3<f32>,
    positionCS: vec4<f32>,
    terrainValid: f32,
    clipmapMorph: f32,
    cloudShadow: f32,
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

struct TerrainProjectWaterFilm {
    normal: vec3<f32>,
    roughness: f32,
    coverage: f32,
    dotNV: f32,
    ambientOcclusion: f32,
}

struct TerrainProjectWaterFilmAccumulator {
    weightedNormal: vec3<f32>,
    weightedRoughness: f32,
    weightedCoverage: f32,
    weightedAmbientOcclusion: f32,
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

const TERRAIN_PROJECT_MIN_ADDITIVE_GROUP_WEIGHT: f32 = 0.005f;

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(7) 
var<uniform> global_1: gs_Auto_3_;
var<private> converted_FragColor: vec4<f32>;
var<private> positionWS_3: vec3<f32>;
var<private> normalWS_3: vec3<f32>;
var<private> positionCS_1: vec4<f32>;
var<private> clipmapMorph_1: f32;
var<private> cloudShadow_1: f32;
@group(2) @binding(4) 
var gs_wgpu_tex_material_TerrainNormalAtlas: texture_2d<f32>;
@group(2) @binding(5) 
var gs_wgpu_samp_material_TerrainNormalAtlas: sampler;
@group(0) @binding(0) 
var gs_wgpu_tex_scene_SurfaceRippleNormalAtlas: texture_2d<f32>;
@group(0) @binding(1) 
var gs_wgpu_samp_scene_SurfaceRippleNormalAtlas: sampler;
@group(0) @binding(2) 
var gs_wgpu_tex_scene_SurfaceWaterNormal: texture_2d<f32>;
@group(0) @binding(3) 
var gs_wgpu_samp_scene_SurfaceWaterNormal: sampler;
@group(2) @binding(8) 
var gs_wgpu_tex_material_TerrainPuddleAtlas: texture_2d<f32>;
@group(2) @binding(9) 
var gs_wgpu_samp_material_TerrainPuddleAtlas: sampler;
@group(2) @binding(6) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;

fn pow2_(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e55: f32 = x_1;
    let _e56: f32 = x_1;
    return (_e55 * _e56);
}

fn remapDepthBufferEyeDepth(depth: f32) -> f32 {
    var depth_1: f32;

    depth_1 = depth;
    let _e56: vec4<f32> = global_1.camera_DepthBufferParams;
    let _e58: f32 = depth_1;
    let _e60: vec4<f32> = global_1.camera_DepthBufferParams;
    return (1f / ((_e56.z * _e58) + _e60.w));
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e60: vec3<f32> = positionWS_3;
    interface_value.positionWS = _e60;
    let _e62: vec3<f32> = normalWS_3;
    interface_value.normalWS = _e62;
    let _e64: vec4<f32> = positionCS_1;
    interface_value.positionCS = _e64;
    let _e66: f32 = clipmapMorph_1;
    interface_value.clipmapMorph = _e66;
    let _e68: f32 = cloudShadow_1;
    interface_value.cloudShadow = _e68;
    let _e69: Varyings = interface_value;
    return _e69;
}

fn getAARoughnessFactor(normal: vec3<f32>) -> f32 {
    var normal_1: vec3<f32>;
    var dxy: vec3<f32>;

    normal_1 = normal;
    let _e60: vec3<f32> = normal_1;
    let _e61: vec3<f32> = dpdx(_e60);
    let _e63: vec3<f32> = normal_1;
    let _e64: vec3<f32> = dpdy(_e63);
    dxy = max(abs(_e61), abs(-(_e64)));
    let _e69: vec3<f32> = dxy;
    let _e71: vec3<f32> = dxy;
    let _e74: vec3<f32> = dxy;
    return max(max(_e69.x, _e71.y), _e74.z);
}

fn F_Schlick(f0_: f32, f90_: f32, dotLH: f32) -> f32 {
    var f0_1: f32;
    var f90_1: f32;
    var dotLH_1: f32;

    f0_1 = f0_;
    f90_1 = f90_;
    dotLH_1 = dotLH;
    let _e64: f32 = f0_1;
    let _e65: f32 = f90_1;
    let _e66: f32 = f0_1;
    let _e69: f32 = dotLH_1;
    return (_e64 + ((_e65 - _e66) * pow((1f - _e69), 5f)));
}

fn F_Schlick_1(f0_2: vec3<f32>, f90_2: f32, dotLH_2: f32) -> vec3<f32> {
    var f0_3: vec3<f32>;
    var f90_3: f32;
    var dotLH_3: f32;
    var fresnel: f32;

    f0_3 = f0_2;
    f90_3 = f90_2;
    dotLH_3 = dotLH_2;
    let _e66: f32 = dotLH_3;
    let _e70: f32 = dotLH_3;
    fresnel = exp2((((-5.55473f * _e66) - 6.98316f) * _e70));
    let _e74: f32 = f90_3;
    let _e75: vec3<f32> = f0_3;
    let _e78: f32 = fresnel;
    let _e80: vec3<f32> = f0_3;
    return (((vec3(_e74) - _e75) * _e78) + _e80);
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
    let _e64: f32 = alpha_1;
    let _e65: f32 = pow2_(_e64);
    a2_ = _e65;
    let _e67: f32 = dotNL_1;
    let _e68: f32 = a2_;
    let _e70: f32 = a2_;
    let _e72: f32 = dotNV_1;
    let _e73: f32 = pow2_(_e72);
    gv = (_e67 * sqrt((_e68 + ((1f - _e70) * _e73))));
    let _e79: f32 = dotNV_1;
    let _e80: f32 = a2_;
    let _e82: f32 = a2_;
    let _e84: f32 = dotNL_1;
    let _e85: f32 = pow2_(_e84);
    gl = (_e79 * sqrt((_e80 + ((1f - _e82) * _e85))));
    let _e92: f32 = gv;
    let _e93: f32 = gl;
    return (0.5f / max((_e92 + _e93), 0.000001f));
}

fn D_GGX(alpha_2: f32, dotNH: f32) -> f32 {
    var alpha_3: f32;
    var dotNH_1: f32;
    var a2_1: f32;
    var denom: f32;

    alpha_3 = alpha_2;
    dotNH_1 = dotNH;
    let _e62: f32 = alpha_3;
    let _e63: f32 = pow2_(_e62);
    a2_1 = _e63;
    let _e65: f32 = dotNH_1;
    let _e66: f32 = pow2_(_e65);
    let _e67: f32 = a2_1;
    denom = ((_e66 * (_e67 - 1f)) + 1f);
    let _e75: f32 = a2_1;
    let _e77: f32 = denom;
    let _e78: f32 = pow2_(_e77);
    return ((0.31830987f * _e75) / _e78);
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
    let _e66: f32 = alpha_5;
    let _e67: f32 = dotNH_3;
    let _e68: f32 = D_GGX(_e66, _e67);
    D = _e68;
    let _e70: f32 = alpha_5;
    let _e71: f32 = dotNL_3;
    let _e72: f32 = dotNV_3;
    let _e73: f32 = G_GGX_SmithCorrelated(_e70, _e71, _e72);
    G = _e73;
    let _e75: f32 = G;
    let _e76: f32 = D;
    return (_e75 * _e76);
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
    let _e70: f32 = roughness_1;
    let _e71: f32 = pow2_(_e70);
    alpha_6 = _e71;
    let _e73: vec3<f32> = incidentDirection_1;
    let _e74: SurfaceData = surfaceData_1;
    halfDir = normalize((_e73 + _e74.viewDir));
    let _e79: vec3<f32> = normal_3;
    let _e80: vec3<f32> = incidentDirection_1;
    dotNL_4 = clamp(dot(_e79, _e80), 0f, 1f);
    let _e86: vec3<f32> = normal_3;
    let _e87: SurfaceData = surfaceData_1;
    dotNV_4 = clamp(dot(_e86, _e87.viewDir), 0f, 1f);
    let _e94: vec3<f32> = normal_3;
    let _e95: vec3<f32> = halfDir;
    dotNH_4 = clamp(dot(_e94, _e95), 0f, 1f);
    let _e101: vec3<f32> = incidentDirection_1;
    let _e102: vec3<f32> = halfDir;
    dotLH_4 = clamp(dot(_e101, _e102), 0f, 1f);
    let _e108: vec3<f32> = specularColor_1;
    let _e109: BSDFData = bsdfData_1;
    let _e111: f32 = dotLH_4;
    let _e112: vec3<f32> = F_Schlick_1(_e108, _e109.specularF90_, _e111);
    F = _e112;
    let _e114: f32 = alpha_6;
    let _e115: f32 = dotNV_4;
    let _e116: f32 = dotNL_4;
    let _e117: f32 = dotNH_4;
    let _e118: f32 = DG_GGX(_e114, _e115, _e116, _e117);
    GD = _e118;
    let _e120: vec3<f32> = F;
    let _e121: f32 = GD;
    return (_e120 * _e121);
}

fn BRDF_Diffuse_Lambert(diffuseColor: vec3<f32>) -> vec3<f32> {
    var diffuseColor_1: vec3<f32>;

    diffuseColor_1 = diffuseColor;
    let _e61: vec3<f32> = diffuseColor_1;
    return (0.31830987f * _e61);
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
    let _e80: f32 = roughness_3;
    let _e81: vec4<f32> = c0_;
    let _e83: vec4<f32> = c1_;
    r = ((_e80 * _e81) + _e83);
    let _e86: vec4<f32> = r;
    let _e88: vec4<f32> = r;
    let _e93: f32 = dotNV_6;
    let _e97: vec4<f32> = r;
    let _e100: vec4<f32> = r;
    a004_ = ((min((_e86.x * _e88.x), exp2((-9.28f * _e93))) * _e97.x) + _e100.y);
    let _e108: f32 = a004_;
    let _e110: vec4<f32> = r;
    return ((vec2<f32>(-1.04f, 1.04f) * _e108) + _e110.zw);
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
    let _e66: f32 = roughness_5;
    let _e67: f32 = dotNV_8;
    let _e68: vec2<f32> = envDFGApprox(_e66, _e67);
    AB = _e68;
    let _e70: vec3<f32> = f0_5;
    let _e71: vec2<f32> = AB;
    let _e74: f32 = f90_5;
    let _e75: vec2<f32> = AB;
    return ((_e70 * _e71.x) + vec3((_e74 * _e75.y)));
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
    let _e61: SurfaceData = surfaceData_3;
    albedoColor = _e61.albedoColor;
    let _e64: SurfaceData = surfaceData_3;
    metallic = _e64.metallic;
    let _e67: SurfaceData = surfaceData_3;
    roughness_6 = _e67.roughness;
    let _e70: SurfaceData = surfaceData_3;
    let _e74: SurfaceData = surfaceData_3;
    let _e79: f32 = pow2_(((_e70.IOR - 1f) / (_e74.IOR + 1f)));
    dielectricBaseF0_ = vec3(_e79);
    let _e82: vec3<f32> = dielectricBaseF0_;
    let _e83: SurfaceData = surfaceData_3;
    let _e89: SurfaceData = surfaceData_3;
    dielectricF0_ = (min((_e82 * _e83.specularColor), vec3(1f)) * _e89.specularIntensity);
    let _e93: SurfaceData = surfaceData_3;
    dielectricF90_ = _e93.specularIntensity;
    let _e97: vec3<f32> = dielectricF0_;
    let _e98: vec3<f32> = albedoColor;
    let _e99: f32 = metallic;
    (*bsdfData_2).specularF0_ = mix(_e97, _e98, vec3(_e99));
    let _e103: f32 = dielectricF90_;
    let _e105: f32 = metallic;
    (*bsdfData_2).specularF90_ = mix(_e103, 1f, _e105);
    let _e108: vec3<f32> = albedoColor;
    let _e110: f32 = metallic;
    let _e114: vec3<f32> = dielectricF0_;
    let _e116: vec3<f32> = dielectricF0_;
    let _e119: vec3<f32> = dielectricF0_;
    (*bsdfData_2).diffuseColor = ((_e108 * (1f - _e110)) * (1f - max(max(_e114.x, _e116.y), _e119.z)));
    let _e126: f32 = roughness_6;
    let _e127: SurfaceData = surfaceData_3;
    let _e129: f32 = getAARoughnessFactor(_e127.normal);
    (*bsdfData_2).roughness = max(0.045f, min((_e126 + _e129), 1f));
    let _e135: BSDFData = (*bsdfData_2);
    (*bsdfData_2).resolvedSpecularF0_ = _e135.specularF0_;
    let _e137: BSDFData = (*bsdfData_2);
    let _e139: SurfaceData = surfaceData_3;
    let _e141: vec2<f32> = envDFGApprox(_e137.roughness, _e139.dotNV);
    dfg = _e141;
    let _e144: BSDFData = (*bsdfData_2);
    let _e146: vec2<f32> = dfg;
    let _e149: BSDFData = (*bsdfData_2);
    let _e151: vec2<f32> = dfg;
    (*bsdfData_2).envSpecularDFG = ((_e144.resolvedSpecularF0_ * _e146.x) + vec3((_e149.specularF90_ * _e151.y)));
    let _e158: BSDFData = (*bsdfData_2);
    let _e161: vec2<f32> = dfg;
    let _e163: vec2<f32> = dfg;
    (*bsdfData_2).energyCompensation = (vec3(1f) + (_e158.resolvedSpecularF0_ * ((1f / max((_e161.x + _e163.y), 0.000001f)) - 1f)));
    let _e175: SurfaceData = surfaceData_3;
    (*bsdfData_2).diffuseAO = _e175.ambientOcclusion;
    return;
}

fn terrainProjectRegionIndex(worldXZ: vec2<f32>) -> i32 {
    var worldXZ_1: vec2<f32>;
    var inclusiveBoundaryCandidate: i32 = -1i;
    var candidateMinimum: vec2<f32> = vec2(-0x1.fffffep+127f);
    var index: i32 = 0i;
    var bounds: vec4<f32>;
    var minimum: vec2<f32>;
    var maximum: vec2<f32>;

    worldXZ_1 = worldXZ;
    loop {
        let _e69: i32 = index;
        if !((_e69 < 32i)) {
            break;
        }
        {
            let _e76: i32 = index;
            let _e77: i32 = global.material_TerrainRegionCount;
            if (_e76 >= _e77) {
                {
                    break;
                }
            }
            let _e79: i32 = index;
            let _e81: vec4<f32> = global.material_TerrainRegionWorldBounds[_e79];
            bounds = _e81;
            let _e83: vec4<f32> = bounds;
            minimum = _e83.xy;
            let _e86: vec2<f32> = minimum;
            let _e87: vec4<f32> = bounds;
            maximum = (_e86 + _e87.zw);
            let _e91: vec2<f32> = worldXZ_1;
            let _e92: vec2<f32> = minimum;
            let _e95: vec2<f32> = worldXZ_1;
            let _e96: vec2<f32> = maximum;
            if (all((_e91 >= _e92)) && all((_e95 <= _e96))) {
                {
                    let _e100: vec2<f32> = worldXZ_1;
                    let _e101: vec2<f32> = maximum;
                    if all((_e100 < _e101)) {
                        {
                            let _e104: i32 = index;
                            return _e104;
                        }
                    }
                    let _e105: i32 = inclusiveBoundaryCandidate;
                    let _e108: vec2<f32> = minimum;
                    let _e110: vec2<f32> = candidateMinimum;
                    let _e114: vec2<f32> = minimum;
                    let _e116: vec2<f32> = candidateMinimum;
                    let _e119: vec2<f32> = minimum;
                    let _e121: vec2<f32> = candidateMinimum;
                    if (((_e105 < 0i) || (_e108.x > _e110.x)) || ((_e114.x == _e116.x) && (_e119.y > _e121.y))) {
                        {
                            let _e126: i32 = index;
                            inclusiveBoundaryCandidate = _e126;
                            let _e127: vec2<f32> = minimum;
                            candidateMinimum = _e127;
                        }
                    }
                }
            }
        }
        continuing {
            let _e73: i32 = index;
            index = (_e73 + 1i);
        }
    }
    let _e128: i32 = inclusiveBoundaryCandidate;
    return _e128;
}

fn terrainProjectGeometryNormalAt(worldXZ_2: vec2<f32>, valid: ptr<function, f32>) -> vec3<f32> {
    var worldXZ_3: vec2<f32>;
    var regionIndex: i32;
    var bounds_1: vec4<f32>;
    var atlasRect: vec4<f32>;
    var local: vec2<f32>;
    var grid: vec2<f32>;
    var encodedXZ: vec2<f32>;
    var normalY: f32;

    worldXZ_3 = worldXZ_2;
    let _e63: vec2<f32> = worldXZ_3;
    let _e64: i32 = terrainProjectRegionIndex(_e63);
    regionIndex = _e64;
    let _e66: i32 = regionIndex;
    if (_e66 < 0i) {
        {
            (*valid) = 0f;
            return vec3<f32>(0f, 1f, 0f);
        }
    }
    let _e74: i32 = regionIndex;
    let _e76: vec4<f32> = global.material_TerrainRegionWorldBounds[_e74];
    bounds_1 = _e76;
    let _e78: i32 = regionIndex;
    let _e80: vec4<f32> = global.material_TerrainRegionAtlasRects[_e78];
    atlasRect = _e80;
    let _e82: vec2<f32> = worldXZ_3;
    let _e83: vec4<f32> = bounds_1;
    let _e86: vec4<f32> = bounds_1;
    local = clamp(((_e82 - _e83.xy) / _e86.zw), vec2(0f), vec2(1f));
    let _e95: vec2<f32> = local;
    let _e96: vec4<f32> = atlasRect;
    grid = (_e95 * (_e96.zw - vec2(1f)));
    let _e103: vec4<f32> = atlasRect;
    let _e105: vec2<f32> = grid;
    let _e110: vec2<f32> = global.material_TerrainHeightAtlasInvSize;
    let _e112: vec4<f32> = textureSample(gs_wgpu_tex_material_TerrainNormalAtlas, gs_wgpu_samp_material_TerrainNormalAtlas, (((_e103.xy + _e105) + vec2(0.5f)) * _e110));
    encodedXZ = ((_e112.xy * 2f) - vec2(1f));
    let _e121: vec2<f32> = encodedXZ;
    let _e122: vec2<f32> = encodedXZ;
    normalY = sqrt(max((1f - dot(_e121, _e122)), 0f));
    (*valid) = 1f;
    let _e130: vec2<f32> = encodedXZ;
    let _e132: f32 = normalY;
    let _e133: vec2<f32> = encodedXZ;
    return normalize(vec3<f32>(_e130.x, _e132, _e133.y));
}

fn terrainProjectShadingGeometryNormal(worldXZ_4: vec2<f32>, vertexNormal: vec3<f32>) -> vec3<f32> {
    var worldXZ_5: vec2<f32>;
    var vertexNormal_1: vec3<f32>;

    worldXZ_5 = worldXZ_4;
    vertexNormal_1 = vertexNormal;
    let _e64: vec3<f32> = vertexNormal_1;
    return normalize(_e64);
}

fn terrainProjectWaterIOR() -> f32 {
    let _e60: vec4<f32> = global_1.scene_TerrainWaterOpticsParams;
    return clamp(_e60.y, 1.001f, 2f);
}

fn terrainProjectWaterF0_() -> f32 {
    var eta: f32;

    let _e60: f32 = terrainProjectWaterIOR();
    let _e63: f32 = terrainProjectWaterIOR();
    eta = ((_e60 - 1f) / (_e63 + 1f));
    let _e68: f32 = eta;
    let _e69: f32 = eta;
    return (_e68 * _e69);
}

fn terrainProjectSurfaceClimateHash(cell: vec2<f32>) -> f32 {
    var cell_1: vec2<f32>;

    cell_1 = cell;
    let _e68: vec2<f32> = cell_1;
    return fract((sin(dot(_e68, vec2<f32>(127.1f, 311.7f))) * 43758.547f));
}

fn terrainProjectSurfaceClimateValueNoise(position: vec2<f32>) -> f32 {
    var position_1: vec2<f32>;
    var cell_2: vec2<f32>;
    var local_1: vec2<f32>;
    var blend: vec2<f32>;
    var lower: f32;
    var upper: f32;

    position_1 = position;
    let _e68: vec2<f32> = position_1;
    cell_2 = floor(_e68);
    let _e71: vec2<f32> = position_1;
    local_1 = fract(_e71);
    let _e74: vec2<f32> = local_1;
    let _e75: vec2<f32> = local_1;
    let _e79: vec2<f32> = local_1;
    blend = ((_e74 * _e75) * (vec2(3f) - (2f * _e79)));
    let _e85: vec2<f32> = cell_2;
    let _e86: f32 = terrainProjectSurfaceClimateHash(_e85);
    let _e87: vec2<f32> = cell_2;
    let _e92: f32 = terrainProjectSurfaceClimateHash((_e87 + vec2<f32>(1f, 0f)));
    let _e93: vec2<f32> = blend;
    lower = mix(_e86, _e92, _e93.x);
    let _e97: vec2<f32> = cell_2;
    let _e102: f32 = terrainProjectSurfaceClimateHash((_e97 + vec2<f32>(0f, 1f)));
    let _e103: vec2<f32> = cell_2;
    let _e108: f32 = terrainProjectSurfaceClimateHash((_e103 + vec2<f32>(1f, 1f)));
    let _e109: vec2<f32> = blend;
    upper = mix(_e102, _e108, _e109.x);
    let _e113: f32 = lower;
    let _e114: f32 = upper;
    let _e115: vec2<f32> = blend;
    return mix(_e113, _e114, _e115.y);
}

fn terrainProjectSurfaceClimateNoise(worldXZ_6: vec2<f32>) -> f32 {
    var worldXZ_7: vec2<f32>;
    var broad: f32;
    var detail: f32;

    worldXZ_7 = worldXZ_6;
    let _e68: vec2<f32> = worldXZ_7;
    let _e71: f32 = terrainProjectSurfaceClimateValueNoise((_e68 * 0.055f));
    broad = _e71;
    let _e73: vec2<f32> = worldXZ_7;
    let _e80: f32 = terrainProjectSurfaceClimateValueNoise(((_e73 * 0.17f) + vec2<f32>(19.7f, 43.1f)));
    detail = _e80;
    let _e82: f32 = broad;
    let _e83: f32 = detail;
    return mix(_e82, _e83, 0.28f);
}

fn terrainProjectDecodeSurfaceNormal(encodedNormal: vec3<f32>) -> vec3<f32> {
    var encodedNormal_1: vec3<f32>;
    var normal_4: vec3<f32>;

    encodedNormal_1 = encodedNormal;
    let _e68: vec3<f32> = encodedNormal_1;
    normal_4 = ((_e68 * 2f) - vec3(1f));
    let _e75: vec3<f32> = normal_4;
    let _e76: vec2<f32> = _e75.xy;
    let _e77: vec3<f32> = normal_4;
    return normalize(vec3<f32>(_e76.x, _e76.y, max(_e77.z, 0.08f)));
}

fn terrainProjectSampleRippleFrame(localUv: vec2<f32>, frame: f32) -> vec3<f32> {
    var localUv_1: vec2<f32>;
    var frame_1: f32;
    var frameCell: vec2<f32>;
    var frameUv: vec2<f32>;

    localUv_1 = localUv;
    frame_1 = frame;
    let _e70: f32 = frame_1;
    let _e76: f32 = frame_1;
    frameCell = vec2<f32>((_e70 - (floor((_e70 / 8f)) * 8f)), floor((_e76 * 0.125f)));
    let _e82: vec2<f32> = frameCell;
    let _e87: vec2<f32> = localUv_1;
    frameUv = ((_e82 + mix(vec2(0.04f), vec2(0.96f), clamp(_e87, vec2(0f), vec2(1f)))) * 0.125f);
    let _e98: vec2<f32> = frameUv;
    let _e99: vec4<f32> = textureSample(gs_wgpu_tex_scene_SurfaceRippleNormalAtlas, gs_wgpu_samp_scene_SurfaceRippleNormalAtlas, _e98);
    let _e101: vec3<f32> = terrainProjectDecodeSurfaceNormal(_e99.xyz);
    return _e101;
}

fn terrainProjectScaleTangentNormal(tangentNormal: vec3<f32>, strength: f32) -> vec3<f32> {
    var tangentNormal_1: vec3<f32>;
    var strength_1: f32;
    var clampedStrength: f32;
    var scaledZ: f32;

    tangentNormal_1 = tangentNormal;
    strength_1 = strength;
    let _e70: f32 = strength_1;
    clampedStrength = clamp(_e70, 0f, 1f);
    let _e76: vec3<f32> = tangentNormal_1;
    let _e80: f32 = clampedStrength;
    scaledZ = mix(1f, max(_e76.z, 0.08f), _e80);
    let _e83: vec3<f32> = tangentNormal_1;
    let _e85: f32 = clampedStrength;
    let _e86: vec2<f32> = (_e83.xy * _e85);
    let _e87: f32 = scaledZ;
    return normalize(vec3<f32>(_e86.x, _e86.y, _e87));
}

fn terrainProjectBlendWhiteoutNormals(baseNormal: vec3<f32>, detailNormal: vec3<f32>) -> vec3<f32> {
    var baseNormal_1: vec3<f32>;
    var detailNormal_1: vec3<f32>;

    baseNormal_1 = baseNormal;
    detailNormal_1 = detailNormal;
    let _e70: vec3<f32> = baseNormal_1;
    let _e72: vec3<f32> = detailNormal_1;
    let _e74: vec2<f32> = (_e70.xy + _e72.xy);
    let _e75: vec3<f32> = baseNormal_1;
    let _e77: vec3<f32> = detailNormal_1;
    return normalize(vec3<f32>(_e74.x, _e74.y, (_e75.z * _e77.z)));
}

fn terrainProjectRippleField(fieldUv: vec2<f32>, frameOffset: f32, rainStrength: f32) -> vec3<f32> {
    var fieldUv_1: vec2<f32>;
    var frameOffset_1: f32;
    var rainStrength_1: f32;
    var frameRate: f32;
    var frame_2: f32;

    fieldUv_1 = fieldUv;
    frameOffset_1 = frameOffset;
    rainStrength_1 = rainStrength;
    let _e74: f32 = rainStrength_1;
    frameRate = mix(8f, 24f, clamp(_e74, 0f, 1f));
    let _e80: f32 = global_1.scene_WeatherTime;
    let _e81: f32 = frameRate;
    let _e83: f32 = frameOffset_1;
    let _e84: f32 = ((_e80 * _e81) + _e83);
    frame_2 = floor((_e84 - (floor((_e84 / 64f)) * 64f)));
    let _e92: vec2<f32> = fieldUv_1;
    let _e94: f32 = frame_2;
    let _e95: vec3<f32> = terrainProjectSampleRippleFrame(fract(_e92), _e94);
    return _e95;
}

fn terrainProjectPuddleNormal(waterSurfaceNormal: vec3<f32>, worldXZ_8: vec2<f32>, rainStrength_2: f32, puddleNormal: ptr<function, vec3<f32>>, ringResponse: ptr<function, f32>) {
    var waterSurfaceNormal_1: vec3<f32>;
    var worldXZ_9: vec2<f32>;
    var rainStrength_3: f32;
    var rippleVisibility: f32;
    var waterUv: vec2<f32>;
    var tangentNormal_2: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var sampleN: vec3<f32>;
    var weightedRingResponse: f32 = 0f;
    var rippleUvTiling: f32;
    var rippleCount: f32;
    var rippleUv: vec2<f32>;
    var rippleWeights: vec4<f32>;
    var uv: vec2<f32>;
    var uv_1: vec2<f32>;
    var uv_2: vec2<f32>;
    var basisNormal: vec3<f32>;
    var tangent: vec3<f32>;
    var bitangent: vec3<f32>;

    waterSurfaceNormal_1 = waterSurfaceNormal;
    worldXZ_9 = worldXZ_8;
    rainStrength_3 = rainStrength_2;
    let _e76: f32 = rainStrength_3;
    rippleVisibility = smoothstep(0.015f, 0.12f, _e76);
    let _e79: vec2<f32> = worldXZ_9;
    waterUv = (_e79 * 0.34f);
    let _e88: vec2<f32> = waterUv;
    let _e89: f32 = global_1.scene_WeatherTime;
    let _e96: vec4<f32> = textureSample(gs_wgpu_tex_scene_SurfaceWaterNormal, gs_wgpu_samp_scene_SurfaceWaterNormal, (_e88 + (_e89 * vec2<f32>(0.021f, -0.014f))));
    let _e98: vec3<f32> = terrainProjectDecodeSurfaceNormal(_e96.xyz);
    sampleN = _e98;
    let _e100: vec3<f32> = tangentNormal_2;
    let _e101: vec3<f32> = sampleN;
    let _e103: vec3<f32> = terrainProjectScaleTangentNormal(_e101, 0.025f);
    let _e104: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e100, _e103);
    tangentNormal_2 = _e104;
    let _e105: vec2<f32> = waterUv;
    let _e108: vec2<f32> = waterUv;
    let _e113: f32 = global_1.scene_WeatherTime;
    let _e120: vec4<f32> = textureSample(gs_wgpu_tex_scene_SurfaceWaterNormal, gs_wgpu_samp_scene_SurfaceWaterNormal, ((vec2<f32>(-(_e105.y), _e108.x) * 1.37f) + (_e113 * vec2<f32>(-0.017f, 0.012f))));
    let _e122: vec3<f32> = terrainProjectDecodeSurfaceNormal(_e120.xyz);
    sampleN = _e122;
    let _e123: vec3<f32> = tangentNormal_2;
    let _e124: vec3<f32> = sampleN;
    let _e126: vec3<f32> = terrainProjectScaleTangentNormal(_e124, 0.025f);
    let _e127: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e123, _e126);
    tangentNormal_2 = _e127;
    let _e130: f32 = rippleVisibility;
    if (_e130 > 0f) {
        {
            let _e133: vec4<f32> = global_1.scene_TerrainRippleParams;
            rippleUvTiling = clamp(_e133.x, 0.05f, 8f);
            let _e139: vec4<f32> = global_1.scene_TerrainRippleParams;
            rippleCount = clamp(_e139.y, 0f, 4f);
            let _e145: vec2<f32> = worldXZ_9;
            let _e147: f32 = rippleUvTiling;
            rippleUv = (_e145 * (0.68f * _e147));
            let _e151: f32 = rippleCount;
            rippleWeights = clamp((vec4(_e151) - vec4<f32>(0f, 1f, 2f, 3f)), vec4(0f), vec4(1f));
            let _e165: vec4<f32> = rippleWeights;
            if (_e165.x > 0f) {
                {
                    let _e169: vec2<f32> = rippleUv;
                    let _e171: f32 = rainStrength_3;
                    let _e172: vec3<f32> = terrainProjectRippleField(_e169, 0f, _e171);
                    sampleN = _e172;
                    let _e173: vec3<f32> = tangentNormal_2;
                    let _e174: vec3<f32> = sampleN;
                    let _e176: f32 = rippleVisibility;
                    let _e178: vec4<f32> = rippleWeights;
                    let _e181: vec3<f32> = terrainProjectScaleTangentNormal(_e174, ((0.42f * _e176) * _e178.x));
                    let _e182: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e173, _e181);
                    tangentNormal_2 = _e182;
                    let _e183: f32 = weightedRingResponse;
                    let _e184: vec3<f32> = sampleN;
                    let _e187: vec4<f32> = rippleWeights;
                    weightedRingResponse = max(_e183, (length(_e184.xy) * _e187.x));
                }
            }
            let _e191: vec4<f32> = rippleWeights;
            if (_e191.y > 0f) {
                {
                    let _e195: vec2<f32> = rippleUv;
                    let _e199: vec2<f32> = rippleUv;
                    let _e204: vec2<f32> = rippleUv;
                    let _e208: vec2<f32> = rippleUv;
                    uv = vec2<f32>(((_e195.x * 0.8f) - (_e199.y * 0.6f)), ((_e204.x * 0.6f) + (_e208.y * 0.8f)));
                    let _e215: vec2<f32> = uv;
                    let _e221: f32 = rainStrength_3;
                    let _e222: vec3<f32> = terrainProjectRippleField((_e215 + vec2<f32>(0.37f, 0.19f)), 23f, _e221);
                    sampleN = _e222;
                    let _e223: vec3<f32> = tangentNormal_2;
                    let _e224: vec3<f32> = sampleN;
                    let _e226: f32 = rippleVisibility;
                    let _e228: vec4<f32> = rippleWeights;
                    let _e231: vec3<f32> = terrainProjectScaleTangentNormal(_e224, ((0.32f * _e226) * _e228.y));
                    let _e232: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e223, _e231);
                    tangentNormal_2 = _e232;
                    let _e233: f32 = weightedRingResponse;
                    let _e234: vec3<f32> = sampleN;
                    let _e237: vec4<f32> = rippleWeights;
                    weightedRingResponse = max(_e233, (length(_e234.xy) * _e237.y));
                }
            }
            let _e241: vec4<f32> = rippleWeights;
            if (_e241.z > 0f) {
                {
                    let _e245: vec2<f32> = rippleUv;
                    let _e250: vec2<f32> = rippleUv;
                    let _e255: vec2<f32> = rippleUv;
                    let _e259: vec2<f32> = rippleUv;
                    uv_1 = vec2<f32>(((_e245.x * -0.28f) - (_e250.y * 0.96f)), ((_e255.x * 0.96f) - (_e259.y * 0.28f)));
                    let _e266: vec2<f32> = uv_1;
                    let _e272: f32 = rainStrength_3;
                    let _e273: vec3<f32> = terrainProjectRippleField((_e266 + vec2<f32>(0.71f, 0.43f)), 41f, _e272);
                    sampleN = _e273;
                    let _e274: vec3<f32> = tangentNormal_2;
                    let _e275: vec3<f32> = sampleN;
                    let _e277: f32 = rippleVisibility;
                    let _e279: vec4<f32> = rippleWeights;
                    let _e282: vec3<f32> = terrainProjectScaleTangentNormal(_e275, ((0.27f * _e277) * _e279.z));
                    let _e283: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e274, _e282);
                    tangentNormal_2 = _e283;
                    let _e284: f32 = weightedRingResponse;
                    let _e285: vec3<f32> = sampleN;
                    let _e288: vec4<f32> = rippleWeights;
                    weightedRingResponse = max(_e284, (length(_e285.xy) * _e288.z));
                }
            }
            let _e292: vec4<f32> = rippleWeights;
            if (_e292.w > 0f) {
                {
                    let _e296: vec2<f32> = rippleUv;
                    let _e300: vec2<f32> = rippleUv;
                    let _e305: vec2<f32> = rippleUv;
                    let _e309: vec2<f32> = rippleUv;
                    uv_2 = vec2<f32>(((_e296.x * 0.54f) - (_e300.y * 0.84f)), ((_e305.x * 0.84f) + (_e309.y * 0.54f)));
                    let _e316: vec2<f32> = uv_2;
                    let _e322: f32 = rainStrength_3;
                    let _e323: vec3<f32> = terrainProjectRippleField((_e316 + vec2<f32>(0.13f, 0.79f)), 57f, _e322);
                    sampleN = _e323;
                    let _e324: vec3<f32> = tangentNormal_2;
                    let _e325: vec3<f32> = sampleN;
                    let _e327: f32 = rippleVisibility;
                    let _e329: vec4<f32> = rippleWeights;
                    let _e332: vec3<f32> = terrainProjectScaleTangentNormal(_e325, ((0.23f * _e327) * _e329.w));
                    let _e333: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e324, _e332);
                    tangentNormal_2 = _e333;
                    let _e334: f32 = weightedRingResponse;
                    let _e335: vec3<f32> = sampleN;
                    let _e338: vec4<f32> = rippleWeights;
                    weightedRingResponse = max(_e334, (length(_e335.xy) * _e338.w));
                }
            }
        }
    }
    let _e342: f32 = weightedRingResponse;
    let _e348: f32 = rippleVisibility;
    (*ringResponse) = (clamp((_e342 * 2.4f), 0f, 1f) * _e348);
    let _e350: vec3<f32> = waterSurfaceNormal_1;
    basisNormal = normalize(_e350);
    let _e357: vec3<f32> = basisNormal;
    let _e358: vec3<f32> = basisNormal;
    tangent = (vec3<f32>(1f, 0f, 0f) - (_e357 * _e358.x));
    let _e363: vec3<f32> = tangent;
    let _e364: vec3<f32> = tangent;
    if (dot(_e363, _e364) < 0.00001f) {
        {
            let _e372: vec3<f32> = basisNormal;
            let _e373: vec3<f32> = basisNormal;
            tangent = (vec3<f32>(0f, 0f, 1f) - (_e372 * _e373.z));
        }
    }
    let _e377: vec3<f32> = tangent;
    tangent = normalize(_e377);
    let _e379: vec3<f32> = tangent;
    let _e380: vec3<f32> = basisNormal;
    bitangent = normalize(cross(_e379, _e380));
    let _e384: vec3<f32> = tangent;
    let _e385: vec3<f32> = tangentNormal_2;
    let _e388: vec3<f32> = bitangent;
    let _e389: vec3<f32> = tangentNormal_2;
    let _e393: vec3<f32> = basisNormal;
    let _e394: vec3<f32> = tangentNormal_2;
    (*puddleNormal) = normalize((((_e384 * _e385.x) + (_e388 * _e389.y)) + (_e393 * _e394.z)));
    return;
}

fn terrainProjectSurfacePuddleStorage(response: f32) -> f32 {
    var response_1: f32;

    response_1 = response;
    let _e68: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e70: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    let _e73: f32 = response_1;
    return clamp(((_e68.y + _e70.y) * _e73), 0f, 1f);
}

fn terrainProjectSurfaceWetness(response_2: f32) -> f32 {
    var response_3: f32;

    response_3 = response_2;
    let _e68: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e70: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e75: f32 = response_3;
    return clamp((max(_e68.x, (_e70.w * 0.48f)) * _e75), 0f, 1f);
}

fn terrainProjectSurfaceHydrologyMasks(worldPosition: vec3<f32>, response_4: f32) -> vec2<f32> {
    var worldPosition_1: vec3<f32>;
    var response_5: f32;
    var storage: f32;
    var regionIndex_1: i32;
    var bounds_2: vec4<f32>;
    var rect: vec4<f32>;
    var local_2: vec2<f32>;
    var atlasTexel: vec2<f32>;
    var hydrology: vec2<f32>;
    var fillDistance: f32;
    var shorelineWidth: f32 = 0.003921569f;
    var classWidth: f32 = 0.02f;
    var retainedSurface: f32;
    var resolvedBasin: f32;
    var filled: f32;
    var hydrologyCoverage: f32;

    worldPosition_1 = worldPosition;
    response_5 = response_4;
    let _e70: f32 = response_5;
    let _e71: f32 = terrainProjectSurfacePuddleStorage(_e70);
    storage = _e71;
    let _e73: f32 = storage;
    if (_e73 <= 0.06f) {
        return vec2(0f);
    }
    let _e78: vec3<f32> = worldPosition_1;
    let _e80: i32 = terrainProjectRegionIndex(_e78.xz);
    regionIndex_1 = _e80;
    let _e82: i32 = regionIndex_1;
    if (_e82 < 0i) {
        return vec2(0f);
    }
    let _e87: i32 = regionIndex_1;
    let _e89: vec4<f32> = global.material_TerrainRegionWorldBounds[_e87];
    bounds_2 = _e89;
    let _e91: i32 = regionIndex_1;
    let _e93: vec4<f32> = global_1.material_TerrainRegionPuddleRects[_e91];
    rect = _e93;
    let _e95: vec3<f32> = worldPosition_1;
    let _e97: vec4<f32> = bounds_2;
    let _e100: vec4<f32> = bounds_2;
    local_2 = clamp(((_e95.xz - _e97.xy) / _e100.zw), vec2(0f), vec2(1f));
    let _e109: vec4<f32> = rect;
    let _e111: vec2<f32> = local_2;
    let _e112: vec4<f32> = rect;
    atlasTexel = (_e109.xy + (_e111 * (_e112.zw - vec2(1f))));
    let _e120: vec2<f32> = atlasTexel;
    let _e124: vec2<f32> = global_1.material_TerrainPuddleAtlasInvSize;
    let _e126: vec4<f32> = textureSample(gs_wgpu_tex_material_TerrainPuddleAtlas, gs_wgpu_samp_material_TerrainPuddleAtlas, ((_e120 + vec2(0.5f)) * _e124));
    hydrology = _e126.xy;
    let _e129: f32 = storage;
    let _e130: vec2<f32> = hydrology;
    fillDistance = (_e129 - _e130.x);
    let _e140: f32 = fillDistance;
    let _e141: f32 = fwidth(_e140);
    let _e144: f32 = shorelineWidth;
    shorelineWidth = max((_e141 * 1.25f), _e144);
    let _e146: vec2<f32> = hydrology;
    let _e148: f32 = fwidth(_e146.y);
    let _e151: f32 = classWidth;
    classWidth = max((_e148 * 1.25f), _e151);
    let _e154: f32 = classWidth;
    let _e157: f32 = classWidth;
    let _e159: vec2<f32> = hydrology;
    retainedSurface = smoothstep((0.25f - _e154), (0.45f + _e157), _e159.y);
    let _e164: f32 = classWidth;
    let _e167: f32 = classWidth;
    let _e169: vec2<f32> = hydrology;
    resolvedBasin = smoothstep((0.75f - _e164), (0.95f + _e167), _e169.y);
    let _e173: f32 = shorelineWidth;
    let _e175: f32 = shorelineWidth;
    let _e176: f32 = fillDistance;
    filled = smoothstep(-(_e173), _e175, _e176);
    let _e179: f32 = filled;
    let _e182: f32 = storage;
    hydrologyCoverage = (_e179 * smoothstep(0.06f, 0.3f, _e182));
    let _e186: f32 = retainedSurface;
    let _e188: f32 = resolvedBasin;
    let _e191: f32 = hydrologyCoverage;
    let _e193: f32 = resolvedBasin;
    let _e194: f32 = hydrologyCoverage;
    return vec2<f32>(((_e186 * (1f - _e188)) * _e191), (_e193 * _e194));
}

fn terrainProjectSurfaceThinFilmCoverage(geometryNormal: vec3<f32>, rainWetness: f32, microRetention: f32) -> f32 {
    var geometryNormal_1: vec3<f32>;
    var rainWetness_1: f32;
    var microRetention_1: f32;
    var upward: f32;
    var filmSlopeAcceptance: f32;
    var activeRain: f32;
    var filmCapacity: f32;
    var baseFilmCoverage: f32;
    var retainedFilmCoverage: f32;

    geometryNormal_1 = geometryNormal;
    rainWetness_1 = rainWetness;
    microRetention_1 = microRetention;
    let _e72: vec3<f32> = geometryNormal_1;
    upward = clamp(normalize(_e72).y, 0f, 1f);
    let _e81: f32 = upward;
    filmSlopeAcceptance = smoothstep(0.42f, 0.94f, _e81);
    let _e86: vec4<f32> = global_1.scene_SurfaceClimate;
    activeRain = smoothstep(0.03f, 0.68f, _e86.w);
    let _e92: f32 = activeRain;
    filmCapacity = mix(0.22f, 0.38f, _e92);
    let _e97: f32 = rainWetness_1;
    let _e99: f32 = filmSlopeAcceptance;
    let _e101: f32 = filmCapacity;
    baseFilmCoverage = ((smoothstep(0.08f, 0.82f, _e97) * _e99) * _e101);
    let _e104: f32 = microRetention_1;
    let _e105: f32 = filmSlopeAcceptance;
    retainedFilmCoverage = (_e104 * _e105);
    let _e108: f32 = baseFilmCoverage;
    let _e110: f32 = baseFilmCoverage;
    let _e112: f32 = retainedFilmCoverage;
    return (_e108 + ((1f - _e110) * _e112));
}

fn terrainProjectSurfaceWaterCoverage(standingWaterCoverage: f32, thinFilmCoverage: f32) -> f32 {
    var standingWaterCoverage_1: f32;
    var thinFilmCoverage_1: f32;

    standingWaterCoverage_1 = standingWaterCoverage;
    thinFilmCoverage_1 = thinFilmCoverage;
    let _e70: f32 = standingWaterCoverage_1;
    let _e72: f32 = standingWaterCoverage_1;
    let _e74: f32 = thinFilmCoverage_1;
    return clamp((_e70 + ((1f - _e72) * _e74)), 0f, 1f);
}

fn terrainProjectSurfaceStandingWaterLobe(standingWaterCoverage_2: f32, waterCoverage: f32) -> f32 {
    var standingWaterCoverage_3: f32;
    var waterCoverage_1: f32;
    var standingWaterShare: f32;

    standingWaterCoverage_3 = standingWaterCoverage_2;
    waterCoverage_1 = waterCoverage;
    let _e70: f32 = standingWaterCoverage_3;
    let _e71: f32 = waterCoverage_1;
    standingWaterShare = (_e70 / max(_e71, 0.0001f));
    let _e77: f32 = standingWaterShare;
    return step(0.5f, _e77);
}

fn terrainProjectApplySurfaceMoisture(surfaceData_4: ptr<function, SurfaceData>, geometryNormal_2: vec3<f32>, response_6: vec2<f32>) {
    var geometryNormal_3: vec3<f32>;
    var response_7: vec2<f32>;
    var wetness: f32;
    var porousResponse: f32;
    var wetSubstrate: f32;
    var substrateLuminance: f32;
    var saturatedSubstrate: vec3<f32>;
    var wetAlbedo: vec3<f32>;
    var wetRoughness: f32;

    geometryNormal_3 = geometryNormal_2;
    response_7 = response_6;
    let _e71: vec2<f32> = response_7;
    let _e73: f32 = terrainProjectSurfaceWetness(_e71.x);
    wetness = _e73;
    let _e75: f32 = wetness;
    if (_e75 <= 0f) {
        return;
    }
    let _e79: SurfaceData = (*surfaceData_4);
    let _e86: SurfaceData = (*surfaceData_4);
    porousResponse = ((1f - _e79.metallic) * mix(0.35f, 1f, smoothstep(0.18f, 0.82f, _e86.roughness)));
    let _e92: f32 = wetness;
    let _e93: f32 = porousResponse;
    wetSubstrate = (_e92 * _e93);
    let _e96: SurfaceData = (*surfaceData_4);
    substrateLuminance = dot(_e96.albedoColor, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e104: f32 = substrateLuminance;
    let _e106: SurfaceData = (*surfaceData_4);
    saturatedSubstrate = mix(vec3(_e104), _e106.albedoColor, vec3(1.08f));
    let _e112: vec3<f32> = saturatedSubstrate;
    wetAlbedo = max((_e112 * 0.78f), vec3(0f));
    let _e120: SurfaceData = (*surfaceData_4);
    let _e122: vec3<f32> = wetAlbedo;
    let _e123: f32 = wetSubstrate;
    (*surfaceData_4).albedoColor = mix(_e120.albedoColor, _e122, vec3(_e123));
    let _e127: SurfaceData = (*surfaceData_4);
    wetRoughness = max(0.14f, (_e127.roughness * 0.62f));
    let _e134: SurfaceData = (*surfaceData_4);
    let _e136: f32 = wetRoughness;
    let _e137: f32 = wetSubstrate;
    (*surfaceData_4).roughness = mix(_e134.roughness, _e136, (_e137 * 0.72f));
    let _e142: SurfaceData = (*surfaceData_4);
    let _e144: SurfaceData = (*surfaceData_4);
    (*surfaceData_4).dotNV = clamp(dot(_e142.normal, _e144.viewDir), 0f, 1f);
    return;
}

fn terrainProjectTopSnowMask(worldPosition_2: vec3<f32>, geometryNormal_4: vec3<f32>, response_8: f32) -> f32 {
    var worldPosition_3: vec3<f32>;
    var geometryNormal_5: vec3<f32>;
    var response_9: f32;
    var snowStorage: f32;
    var distribution: f32;
    var snowDistribution: f32;
    var upward_1: f32;

    worldPosition_3 = worldPosition_2;
    geometryNormal_5 = geometryNormal_4;
    response_9 = response_8;
    let _e72: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e74: f32 = response_9;
    snowStorage = clamp((_e72.z * _e74), 0f, 1f);
    let _e80: f32 = snowStorage;
    if (_e80 <= 0f) {
        return 0f;
    }
    let _e84: vec3<f32> = worldPosition_3;
    let _e86: f32 = terrainProjectSurfaceClimateNoise(_e84.xz);
    distribution = _e86;
    let _e90: f32 = snowStorage;
    let _e91: f32 = distribution;
    snowDistribution = smoothstep(0.06f, 0.64f, (_e90 + ((_e91 - 0.5f) * 0.22f)));
    let _e99: vec3<f32> = geometryNormal_5;
    upward_1 = clamp(normalize(_e99).y, 0f, 1f);
    let _e106: f32 = snowDistribution;
    let _e109: f32 = upward_1;
    let _e112: f32 = snowStorage;
    return ((_e106 * smoothstep(0.34f, 0.82f, _e109)) * _e112);
}

fn terrainProjectApplyTopSnowLayer(surfaceData_5: ptr<function, SurfaceData>, geometryNormal_6: vec3<f32>, snow: f32, targetRoughness: f32, normalFlattening: f32) {
    var geometryNormal_7: vec3<f32>;
    var snow_1: f32;
    var targetRoughness_1: f32;
    var normalFlattening_1: f32;

    geometryNormal_7 = geometryNormal_6;
    snow_1 = snow;
    targetRoughness_1 = targetRoughness;
    normalFlattening_1 = normalFlattening;
    let _e75: f32 = snow_1;
    if (_e75 <= 0f) {
        return;
    }
    let _e79: SurfaceData = (*surfaceData_5);
    let _e81: vec4<f32> = global_1.scene_SurfaceSnowColor;
    let _e83: f32 = snow_1;
    (*surfaceData_5).albedoColor = mix(_e79.albedoColor, _e81.xyz, vec3(_e83));
    let _e87: SurfaceData = (*surfaceData_5);
    let _e90: f32 = snow_1;
    (*surfaceData_5).metallic = mix(_e87.metallic, 0f, _e90);
    let _e93: SurfaceData = (*surfaceData_5);
    let _e95: f32 = targetRoughness_1;
    let _e96: f32 = snow_1;
    (*surfaceData_5).roughness = mix(_e93.roughness, _e95, _e96);
    let _e99: SurfaceData = (*surfaceData_5);
    let _e102: f32 = snow_1;
    (*surfaceData_5).specularIntensity = mix(_e99.specularIntensity, 0.68f, _e102);
    let _e105: SurfaceData = (*surfaceData_5);
    let _e107: vec3<f32> = geometryNormal_7;
    let _e109: f32 = snow_1;
    let _e110: f32 = normalFlattening_1;
    (*surfaceData_5).normal = normalize(mix(_e105.normal, normalize(_e107), vec3((_e109 * _e110))));
    return;
}

fn terrainProjectEvaluateSurfaceWaterFilm(surfaceData_6: SurfaceData, geometryNormal_8: vec3<f32>, waterResponse: f32, snow_2: f32) -> TerrainProjectWaterFilm {
    var surfaceData_7: SurfaceData;
    var geometryNormal_9: vec3<f32>;
    var waterResponse_1: f32;
    var snow_3: f32;
    var waterVisibility: f32;
    var rainWetness_2: f32;
    var dryFilm: TerrainProjectWaterFilm;
    var hydrologyMasks: vec2<f32>;
    var microRetention_2: f32;
    var standingWaterCoverage_4: f32;
    var thinFilmCoverage_2: f32;
    var physicalWaterCoverage: f32;
    var standingWaterLobe: f32;
    var waterCoverage_2: f32;
    var thinFilmNormal: vec3<f32>;
    var waterNormal: vec3<f32>;
    var rainStrength_4: f32;
    var thinFilmRoughness: f32;
    var standingWaterRoughness: f32;
    var waterRoughness: f32;
    var animatedNormal: vec3<f32>;
    var ringResponse_1: f32;
    var rippleVisibility_1: f32;
    var animatedAlignment: f32;
    var animatedSlope: vec3<f32>;
    var scaledAnimatedNormal: vec3<f32>;
    var rippleWeight: f32;
    var ringPolish: f32;
    var waterFilm: TerrainProjectWaterFilm;

    surfaceData_7 = surfaceData_6;
    geometryNormal_9 = geometryNormal_8;
    waterResponse_1 = waterResponse;
    snow_3 = snow_2;
    let _e74: vec4<f32> = global_1.scene_TerrainRippleParams;
    let _e76: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    waterVisibility = (_e74.z * _e76.x);
    let _e80: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e84: f32 = waterResponse_1;
    rainWetness_2 = clamp(((_e80.w * 0.48f) * _e84), 0f, 1f);
    let _e90: f32 = waterVisibility;
    let _e93: f32 = rainWetness_2;
    let _e96: f32 = waterResponse_1;
    let _e97: f32 = terrainProjectSurfacePuddleStorage(_e96);
    if ((_e90 <= 0f) || ((_e93 <= 0f) && (_e97 <= 0.06f))) {
        {
            let _e104: SurfaceData = surfaceData_7;
            dryFilm.normal = _e104.normal;
            dryFilm.roughness = 0.1f;
            dryFilm.coverage = 0f;
            let _e111: SurfaceData = surfaceData_7;
            dryFilm.dotNV = _e111.dotNV;
            let _e114: SurfaceData = surfaceData_7;
            dryFilm.ambientOcclusion = _e114.ambientOcclusion;
            let _e116: TerrainProjectWaterFilm = dryFilm;
            return _e116;
        }
    }
    let _e117: SurfaceData = surfaceData_7;
    let _e119: f32 = waterResponse_1;
    let _e120: vec2<f32> = terrainProjectSurfaceHydrologyMasks(_e117.position, _e119);
    hydrologyMasks = _e120;
    let _e122: vec2<f32> = hydrologyMasks;
    microRetention_2 = _e122.x;
    let _e125: vec2<f32> = hydrologyMasks;
    standingWaterCoverage_4 = _e125.y;
    let _e128: vec3<f32> = geometryNormal_9;
    let _e129: f32 = rainWetness_2;
    let _e130: f32 = microRetention_2;
    let _e131: f32 = terrainProjectSurfaceThinFilmCoverage(_e128, _e129, _e130);
    thinFilmCoverage_2 = _e131;
    let _e133: f32 = standingWaterCoverage_4;
    let _e134: f32 = thinFilmCoverage_2;
    let _e135: f32 = terrainProjectSurfaceWaterCoverage(_e133, _e134);
    physicalWaterCoverage = _e135;
    let _e137: f32 = standingWaterCoverage_4;
    let _e138: f32 = physicalWaterCoverage;
    let _e139: f32 = terrainProjectSurfaceStandingWaterLobe(_e137, _e138);
    standingWaterLobe = _e139;
    let _e141: f32 = physicalWaterCoverage;
    let _e142: vec4<f32> = global_1.scene_TerrainRippleParams;
    let _e145: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    waterCoverage_2 = clamp(((_e141 * _e142.z) * _e145.x), 0f, 1f);
    let _e152: SurfaceData = surfaceData_7;
    let _e154: vec3<f32> = geometryNormal_9;
    let _e156: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
    thinFilmNormal = normalize(mix(_e152.normal, normalize(_e154), vec3(_e156.z)));
    let _e162: vec3<f32> = thinFilmNormal;
    let _e167: f32 = standingWaterLobe;
    waterNormal = mix(_e162, vec3<f32>(0f, 1f, 0f), vec3(_e167));
    let _e173: vec4<f32> = global_1.scene_SurfaceClimate;
    rainStrength_4 = smoothstep(0.04f, 0.72f, _e173.w);
    let _e177: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
    let _e179: f32 = rainStrength_4;
    thinFilmRoughness = clamp((_e177.x + (_e179 * 0.02f)), 0.005f, 1f);
    let _e187: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
    let _e189: f32 = rainStrength_4;
    standingWaterRoughness = clamp((_e187.y + (_e189 * 0.02f)), 0.005f, 1f);
    let _e197: f32 = thinFilmRoughness;
    let _e198: f32 = standingWaterRoughness;
    let _e199: f32 = standingWaterLobe;
    waterRoughness = mix(_e197, _e198, _e199);
    let _e202: f32 = waterCoverage_2;
    if (_e202 > 0.001f) {
        {
            let _e207: vec3<f32> = waterNormal;
            let _e208: SurfaceData = surfaceData_7;
            let _e211: f32 = rainStrength_4;
            terrainProjectPuddleNormal(_e207, _e208.position.xz, _e211, (&animatedNormal), (&ringResponse_1));
            let _e218: f32 = rainStrength_4;
            rippleVisibility_1 = smoothstep(0.015f, 0.12f, _e218);
            let _e221: vec3<f32> = waterNormal;
            let _e222: vec3<f32> = animatedNormal;
            animatedAlignment = max(dot(_e221, _e222), 0.1f);
            let _e227: vec3<f32> = animatedNormal;
            let _e228: f32 = animatedAlignment;
            let _e231: vec3<f32> = waterNormal;
            animatedSlope = ((_e227 / vec3(_e228)) - _e231);
            let _e234: vec3<f32> = waterNormal;
            let _e235: vec3<f32> = animatedSlope;
            let _e236: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
            scaledAnimatedNormal = normalize((_e234 + (_e235 * _e236.w)));
            let _e242: f32 = waterCoverage_2;
            let _e243: f32 = rippleVisibility_1;
            let _e247: f32 = standingWaterLobe;
            rippleWeight = ((_e242 * _e243) * mix(0.58f, 0.9f, _e247));
            let _e251: vec3<f32> = waterNormal;
            let _e252: vec3<f32> = scaledAnimatedNormal;
            let _e253: f32 = rippleWeight;
            waterNormal = normalize(mix(_e251, _e252, vec3(_e253)));
            let _e257: f32 = ringResponse_1;
            let _e258: f32 = waterCoverage_2;
            ringPolish = (_e257 * _e258);
            let _e261: f32 = waterRoughness;
            let _e263: f32 = waterRoughness;
            let _e264: vec4<f32> = global_1.scene_TerrainWaterOpticsParams;
            let _e268: f32 = ringPolish;
            waterRoughness = mix(_e261, max(0.018f, (_e263 * _e264.x)), _e268);
        }
    }
    let _e272: vec3<f32> = waterNormal;
    waterFilm.normal = _e272;
    let _e274: f32 = waterRoughness;
    waterFilm.roughness = _e274;
    let _e276: f32 = waterCoverage_2;
    let _e278: f32 = snow_3;
    waterFilm.coverage = (_e276 * (1f - _e278));
    let _e282: vec3<f32> = waterNormal;
    let _e283: SurfaceData = surfaceData_7;
    waterFilm.dotNV = clamp(dot(_e282, _e283.viewDir), 0f, 1f);
    let _e290: SurfaceData = surfaceData_7;
    waterFilm.ambientOcclusion = _e290.ambientOcclusion;
    let _e292: TerrainProjectWaterFilm = waterFilm;
    return _e292;
}

fn terrainProjectCreateWaterFilmAccumulator() -> TerrainProjectWaterFilmAccumulator {
    var accumulator: TerrainProjectWaterFilmAccumulator;

    accumulator.weightedNormal = vec3(0f);
    accumulator.weightedRoughness = 0f;
    accumulator.weightedCoverage = 0f;
    accumulator.weightedAmbientOcclusion = 0f;
    let _e76: TerrainProjectWaterFilmAccumulator = accumulator;
    return _e76;
}

fn terrainProjectAccumulateWaterFilm(accumulator_1: ptr<function, TerrainProjectWaterFilmAccumulator>, waterFilm_1: TerrainProjectWaterFilm, weight: f32) {
    var waterFilm_2: TerrainProjectWaterFilm;
    var weight_1: f32;
    var weightedCoverage: f32;

    waterFilm_2 = waterFilm_1;
    weight_1 = weight;
    let _e71: TerrainProjectWaterFilm = waterFilm_2;
    let _e73: f32 = weight_1;
    weightedCoverage = (_e71.coverage * max(_e73, 0f));
    let _e79: TerrainProjectWaterFilmAccumulator = (*accumulator_1);
    let _e81: TerrainProjectWaterFilm = waterFilm_2;
    let _e83: f32 = weightedCoverage;
    (*accumulator_1).weightedNormal = (_e79.weightedNormal + (_e81.normal * _e83));
    let _e87: TerrainProjectWaterFilmAccumulator = (*accumulator_1);
    let _e89: TerrainProjectWaterFilm = waterFilm_2;
    let _e91: f32 = weightedCoverage;
    (*accumulator_1).weightedRoughness = (_e87.weightedRoughness + (_e89.roughness * _e91));
    let _e95: TerrainProjectWaterFilmAccumulator = (*accumulator_1);
    let _e97: f32 = weightedCoverage;
    (*accumulator_1).weightedCoverage = (_e95.weightedCoverage + _e97);
    let _e100: TerrainProjectWaterFilmAccumulator = (*accumulator_1);
    let _e102: TerrainProjectWaterFilm = waterFilm_2;
    let _e104: f32 = weightedCoverage;
    (*accumulator_1).weightedAmbientOcclusion = (_e100.weightedAmbientOcclusion + (_e102.ambientOcclusion * _e104));
    return;
}

fn terrainProjectResolveWaterFilm(accumulator_2: TerrainProjectWaterFilmAccumulator, fallbackNormal: vec3<f32>, viewDirection: vec3<f32>, fallbackAmbientOcclusion: f32) -> TerrainProjectWaterFilm {
    var accumulator_3: TerrainProjectWaterFilmAccumulator;
    var fallbackNormal_1: vec3<f32>;
    var viewDirection_1: vec3<f32>;
    var fallbackAmbientOcclusion_1: f32;
    var waterFilm_3: TerrainProjectWaterFilm;
    var weightedCoverage_1: f32;

    accumulator_3 = accumulator_2;
    fallbackNormal_1 = fallbackNormal;
    viewDirection_1 = viewDirection;
    fallbackAmbientOcclusion_1 = fallbackAmbientOcclusion;
    let _e75: TerrainProjectWaterFilmAccumulator = accumulator_3;
    weightedCoverage_1 = _e75.weightedCoverage;
    let _e78: f32 = weightedCoverage_1;
    if (_e78 > 0.00001f) {
        {
            let _e82: TerrainProjectWaterFilmAccumulator = accumulator_3;
            waterFilm_3.normal = normalize(_e82.weightedNormal);
            let _e86: TerrainProjectWaterFilmAccumulator = accumulator_3;
            let _e88: f32 = weightedCoverage_1;
            waterFilm_3.roughness = (_e86.weightedRoughness / _e88);
            let _e91: TerrainProjectWaterFilmAccumulator = accumulator_3;
            let _e93: f32 = weightedCoverage_1;
            waterFilm_3.ambientOcclusion = (_e91.weightedAmbientOcclusion / _e93);
        }
    } else {
        {
            let _e96: vec3<f32> = fallbackNormal_1;
            waterFilm_3.normal = normalize(_e96);
            waterFilm_3.roughness = 0.1f;
            let _e101: f32 = fallbackAmbientOcclusion_1;
            waterFilm_3.ambientOcclusion = _e101;
        }
    }
    let _e103: f32 = weightedCoverage_1;
    waterFilm_3.coverage = clamp(_e103, 0f, 1f);
    let _e108: TerrainProjectWaterFilm = waterFilm_3;
    let _e110: vec3<f32> = viewDirection_1;
    waterFilm_3.dotNV = clamp(dot(_e108.normal, _e110), 0f, 1f);
    let _e115: TerrainProjectWaterFilm = waterFilm_3;
    return _e115;
}

fn terrainProjectBuildWaterFilmSurface(substrate: SurfaceData, waterFilm_4: TerrainProjectWaterFilm) -> SurfaceData {
    var substrate_1: SurfaceData;
    var waterFilm_5: TerrainProjectWaterFilm;
    var waterSurface: SurfaceData;

    substrate_1 = substrate;
    waterFilm_5 = waterFilm_4;
    let _e70: SurfaceData = substrate_1;
    waterSurface = _e70;
    waterSurface.albedoColor = vec3(0f);
    waterSurface.emissiveColor = vec3(0f);
    waterSurface.metallic = 0f;
    let _e81: TerrainProjectWaterFilm = waterFilm_5;
    waterSurface.roughness = _e81.roughness;
    let _e84: TerrainProjectWaterFilm = waterFilm_5;
    waterSurface.ambientOcclusion = _e84.ambientOcclusion;
    waterSurface.opacity = 1f;
    let _e89: f32 = terrainProjectWaterIOR();
    waterSurface.IOR = _e89;
    let _e91: TerrainProjectWaterFilm = waterFilm_5;
    waterSurface.normal = _e91.normal;
    let _e94: TerrainProjectWaterFilm = waterFilm_5;
    waterSurface.dotNV = _e94.dotNV;
    waterSurface.specularIntensity = 1f;
    waterSurface.specularColor = vec3(1f);
    let _e101: SurfaceData = waterSurface;
    return _e101;
}

fn terrainProjectBuildSurfaceData(varyings: Varyings, albedo: vec3<f32>, surfaceNormal: vec3<f32>, metallic_1: f32, smoothness: f32, ambientOcclusion: f32) -> SurfaceData {
    var varyings_1: Varyings;
    var albedo_1: vec3<f32>;
    var surfaceNormal_1: vec3<f32>;
    var metallic_2: f32;
    var smoothness_1: f32;
    var ambientOcclusion_1: f32;
    var surfaceData_8: SurfaceData;

    varyings_1 = varyings;
    albedo_1 = albedo;
    surfaceNormal_1 = surfaceNormal;
    metallic_2 = metallic_1;
    smoothness_1 = smoothness;
    ambientOcclusion_1 = ambientOcclusion;
    let _e80: vec3<f32> = albedo_1;
    surfaceData_8.albedoColor = _e80;
    surfaceData_8.emissiveColor = vec3(0f);
    let _e85: f32 = metallic_2;
    surfaceData_8.metallic = clamp(_e85, 0f, 1f);
    let _e91: f32 = smoothness_1;
    surfaceData_8.roughness = (1f - clamp(_e91, 0f, 1f));
    let _e97: f32 = ambientOcclusion_1;
    surfaceData_8.ambientOcclusion = clamp(_e97, 0f, 1f);
    surfaceData_8.opacity = 1f;
    surfaceData_8.IOR = 1.5f;
    let _e106: Varyings = varyings_1;
    surfaceData_8.position = _e106.positionWS;
    let _e109: Varyings = varyings_1;
    surfaceData_8.positionCS = _e109.positionCS;
    let _e112: vec3<f32> = surfaceNormal_1;
    surfaceData_8.normal = _e112;
    let _e114: vec3<f32> = global.camera_Position;
    let _e115: Varyings = varyings_1;
    surfaceData_8.viewDir = normalize((_e114 - _e115.positionWS));
    let _e120: SurfaceData = surfaceData_8;
    let _e122: SurfaceData = surfaceData_8;
    surfaceData_8.dotNV = clamp(dot(_e120.normal, _e122.viewDir), 0f, 1f);
    surfaceData_8.specularIntensity = 1f;
    surfaceData_8.specularColor = vec3(1f);
    let _e133: SurfaceData = surfaceData_8;
    return _e133;
}

fn terrainProjectApplySeasonColor(sourceColor: vec3<f32>, seasonColor: vec4<f32>) -> vec3<f32> {
    var sourceColor_1: vec3<f32>;
    var seasonColor_1: vec4<f32>;
    var sourceLuminance: f32;
    var seasonTone: vec3<f32>;

    sourceColor_1 = sourceColor;
    seasonColor_1 = seasonColor;
    let _e70: vec3<f32> = sourceColor_1;
    sourceLuminance = dot(_e70, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e77: vec4<f32> = seasonColor_1;
    let _e79: f32 = sourceLuminance;
    seasonTone = (_e77.xyz * _e79);
    let _e82: vec3<f32> = sourceColor_1;
    let _e83: vec3<f32> = seasonTone;
    let _e84: vec4<f32> = seasonColor_1;
    return mix(_e82, _e83, vec3(clamp(_e84.w, 0f, 1f)));
}

fn terrainProjectApplyAuthoredSeasonColor(sourceColor_2: vec3<f32>, seasonColor_2: vec4<f32>, authoredChannels: vec3<f32>) -> vec3<f32> {
    var sourceColor_3: vec3<f32>;
    var seasonColor_3: vec4<f32>;
    var authoredChannels_1: vec3<f32>;

    sourceColor_3 = sourceColor_2;
    seasonColor_3 = seasonColor_2;
    authoredChannels_1 = authoredChannels;
    let _e72: vec3<f32> = sourceColor_3;
    let _e73: vec4<f32> = seasonColor_3;
    let _e74: vec3<f32> = terrainProjectApplySeasonColor(_e72, _e73);
    let _e75: vec3<f32> = sourceColor_3;
    let _e76: vec3<f32> = authoredChannels_1;
    return mix(_e74, _e75, _e76);
}

fn terrainProjectApplyFarWetSheen(surfaceData_9: ptr<function, SurfaceData>, geometryNormal_10: vec3<f32>, visibility: f32) {
    var geometryNormal_11: vec3<f32>;
    var visibility_1: f32;
    var coverage: f32;
    var roughness_7: f32;

    geometryNormal_11 = geometryNormal_10;
    visibility_1 = visibility;
    let _e73: f32 = terrainProjectSurfaceWetness(1f);
    let _e74: vec4<f32> = global_1.scene_TerrainRippleParams;
    let _e76: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    let _e85: vec3<f32> = geometryNormal_11;
    let _e89: f32 = visibility_1;
    coverage = (((_e73 * clamp((_e74.z * _e76.x), 0f, 1f)) * smoothstep(0.2f, 0.75f, _e85.y)) * _e89);
    let _e92: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
    roughness_7 = clamp(_e92.x, 0.24f, 1f);
    let _e99: SurfaceData = (*surfaceData_9);
    let _e101: SurfaceData = (*surfaceData_9);
    let _e103: f32 = roughness_7;
    let _e105: f32 = coverage;
    (*surfaceData_9).roughness = mix(_e99.roughness, min(_e101.roughness, _e103), _e105);
    let _e108: SurfaceData = (*surfaceData_9);
    let _e111: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    let _e115: f32 = coverage;
    (*surfaceData_9).specularIntensity = (_e108.specularIntensity * mix(1f, max(_e111.z, 0f), _e115));
    return;
}

fn terrainProjectApplyTerrainClimate(surfaceData_10: ptr<function, SurfaceData>, varyings_2: Varyings, geometryNormal_12: vec3<f32>, snowResponse: f32, waterFilm_6: ptr<function, TerrainProjectWaterFilm>) {
    var varyings_3: Varyings;
    var geometryNormal_13: vec3<f32>;
    var snowResponse_1: f32;
    var snow_4: f32;

    varyings_3 = varyings_2;
    geometryNormal_13 = geometryNormal_12;
    snowResponse_1 = snowResponse;
    let _e75: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e76: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e80: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    if ((dot(_e75, _e76) <= 0f) && (_e80.y <= 0f)) {
        {
            let _e86: SurfaceData = (*surfaceData_10);
            (*waterFilm_6).normal = _e86.normal;
            (*waterFilm_6).roughness = 0.1f;
            (*waterFilm_6).coverage = 0f;
            let _e93: SurfaceData = (*surfaceData_10);
            (*waterFilm_6).dotNV = _e93.dotNV;
            let _e96: SurfaceData = (*surfaceData_10);
            (*waterFilm_6).ambientOcclusion = _e96.ambientOcclusion;
            return;
        }
    }
    let _e99: vec3<f32> = geometryNormal_13;
    terrainProjectApplySurfaceMoisture(surfaceData_10, _e99, vec2(1f));
    let _e103: SurfaceData = (*surfaceData_10);
    let _e105: vec3<f32> = geometryNormal_13;
    let _e106: f32 = snowResponse_1;
    let _e107: f32 = terrainProjectTopSnowMask(_e103.position, _e105, _e106);
    snow_4 = _e107;
    let _e109: SurfaceData = (*surfaceData_10);
    let _e110: vec3<f32> = geometryNormal_13;
    let _e112: f32 = snow_4;
    let _e113: TerrainProjectWaterFilm = terrainProjectEvaluateSurfaceWaterFilm(_e109, _e110, 1f, _e112);
    (*waterFilm_6) = _e113;
    let _e115: vec3<f32> = geometryNormal_13;
    let _e116: f32 = snow_4;
    terrainProjectApplyTopSnowLayer(surfaceData_10, _e115, _e116, 0.82f, 0.28f);
    let _e121: SurfaceData = (*surfaceData_10);
    let _e123: SurfaceData = (*surfaceData_10);
    (*surfaceData_10).dotNV = clamp(dot(_e121.normal, _e123.viewDir), 0f, 1f);
    return;
}

fn evaluateTerrainFallbackSurface(varyings_4: Varyings, geometryNormal_14: vec3<f32>, waterFilm_7: ptr<function, TerrainProjectWaterFilm>) -> SurfaceData {
    var varyings_5: Varyings;
    var geometryNormal_15: vec3<f32>;
    var surfaceData_11: SurfaceData;

    varyings_5 = varyings_4;
    geometryNormal_15 = geometryNormal_14;
    let _e72: Varyings = varyings_5;
    let _e73: vec4<f32> = global_1.material_BaseColor;
    let _e75: vec3<f32> = geometryNormal_15;
    let _e76: f32 = global_1.material_Metallic;
    let _e77: f32 = global_1.material_Smoothness;
    let _e79: SurfaceData = terrainProjectBuildSurfaceData(_e72, _e73.xyz, _e75, _e76, _e77, 1f);
    surfaceData_11 = _e79;
    let _e82: Varyings = varyings_5;
    let _e83: vec3<f32> = geometryNormal_15;
    terrainProjectApplyTerrainClimate((&surfaceData_11), _e82, _e83, 1f, waterFilm_7);
    let _e88: SurfaceData = surfaceData_11;
    return _e88;
}

fn isRendererCulledByLight(rendererLayer: vec2<i32>, lightCullingMask: vec2<i32>) -> bool {
    var rendererLayer_1: vec2<i32>;
    var lightCullingMask_1: vec2<i32>;

    rendererLayer_1 = rendererLayer;
    lightCullingMask_1 = lightCullingMask;
    let _e71: vec2<i32> = rendererLayer_1;
    let _e73: vec2<i32> = lightCullingMask_1;
    let _e78: vec2<i32> = rendererLayer_1;
    let _e80: vec2<i32> = lightCullingMask_1;
    return !((((_e71.x & _e73.x) != 0i) || ((_e78.y & _e80.y) != 0i)));
}

fn diffuseLobe(varyings_6: Varyings, surfaceData_12: SurfaceData, bsdfData_3: BSDFData, attenuationIrradiance: vec3<f32>, diffuseColor_2: ptr<function, vec3<f32>>) {
    var varyings_7: Varyings;
    var surfaceData_13: SurfaceData;
    var bsdfData_4: BSDFData;
    var attenuationIrradiance_1: vec3<f32>;

    varyings_7 = varyings_6;
    surfaceData_13 = surfaceData_12;
    bsdfData_4 = bsdfData_3;
    attenuationIrradiance_1 = attenuationIrradiance;
    let _e80: vec3<f32> = (*diffuseColor_2);
    let _e81: vec3<f32> = attenuationIrradiance_1;
    let _e82: BSDFData = bsdfData_4;
    let _e84: vec3<f32> = BRDF_Diffuse_Lambert(_e82.diffuseColor);
    (*diffuseColor_2) = (_e80 + (_e81 * _e84));
    return;
}

fn specularLobe(varyings_8: Varyings, surfaceData_14: SurfaceData, bsdfData_5: BSDFData, incidentDirection_2: vec3<f32>, attenuationIrradiance_2: vec3<f32>, specularColor_2: ptr<function, vec3<f32>>) {
    var varyings_9: Varyings;
    var surfaceData_15: SurfaceData;
    var bsdfData_6: BSDFData;
    var incidentDirection_3: vec3<f32>;
    var attenuationIrradiance_3: vec3<f32>;

    varyings_9 = varyings_8;
    surfaceData_15 = surfaceData_14;
    bsdfData_6 = bsdfData_5;
    incidentDirection_3 = incidentDirection_2;
    attenuationIrradiance_3 = attenuationIrradiance_2;
    let _e82: vec3<f32> = (*specularColor_2);
    let _e83: vec3<f32> = attenuationIrradiance_3;
    let _e84: vec3<f32> = incidentDirection_3;
    let _e85: SurfaceData = surfaceData_15;
    let _e86: BSDFData = bsdfData_6;
    let _e87: SurfaceData = surfaceData_15;
    let _e89: BSDFData = bsdfData_6;
    let _e91: BSDFData = bsdfData_6;
    let _e93: vec3<f32> = BRDF_Specular_GGX(_e84, _e85, _e86, _e87.normal, _e89.specularF0_, _e91.roughness);
    let _e95: BSDFData = bsdfData_6;
    (*specularColor_2) = (_e82 + ((_e83 * _e93) * _e95.energyCompensation));
    return;
}

fn sheenLobe(varyings_10: Varyings, surfaceData_16: SurfaceData, bsdfData_7: BSDFData, incidentDirection_4: vec3<f32>, attenuationIrradiance_4: vec3<f32>, diffuseColor_3: ptr<function, vec3<f32>>, specularColor_3: ptr<function, vec3<f32>>) {
    var varyings_11: Varyings;
    var surfaceData_17: SurfaceData;
    var bsdfData_8: BSDFData;
    var incidentDirection_5: vec3<f32>;
    var attenuationIrradiance_5: vec3<f32>;

    varyings_11 = varyings_10;
    surfaceData_17 = surfaceData_16;
    bsdfData_8 = bsdfData_7;
    incidentDirection_5 = incidentDirection_4;
    attenuationIrradiance_5 = attenuationIrradiance_4;
    return;
}

fn clearCoatLobe(varyings_12: Varyings, surfaceData_18: SurfaceData, bsdfData_9: BSDFData, incidentDirection_6: vec3<f32>, color: vec3<f32>, specularColor_4: ptr<function, vec3<f32>>) -> f32 {
    var varyings_13: Varyings;
    var surfaceData_19: SurfaceData;
    var bsdfData_10: BSDFData;
    var incidentDirection_7: vec3<f32>;
    var color_1: vec3<f32>;
    var attenuation: f32 = 1f;

    varyings_13 = varyings_12;
    surfaceData_19 = surfaceData_18;
    bsdfData_10 = bsdfData_9;
    incidentDirection_7 = incidentDirection_6;
    color_1 = color;
    let _e84: f32 = attenuation;
    return _e84;
}

fn surfaceShading(varyings_14: Varyings, surfaceData_20: SurfaceData, bsdfData_11: BSDFData, incidentDirection_8: vec3<f32>, lightColor: vec3<f32>, totalDiffuseColor: ptr<function, vec3<f32>>, totalSpecularColor: ptr<function, vec3<f32>>) {
    var varyings_15: Varyings;
    var surfaceData_21: SurfaceData;
    var bsdfData_12: BSDFData;
    var incidentDirection_9: vec3<f32>;
    var lightColor_1: vec3<f32>;
    var diffuseColor_4: vec3<f32> = vec3(0f);
    var specularColor_5: vec3<f32> = vec3(0f);
    var dotNL_5: f32;
    var irradiance: vec3<f32>;
    var attenuation_1: f32;
    var attenuationIrradiance_6: vec3<f32>;

    varyings_15 = varyings_14;
    surfaceData_21 = surfaceData_20;
    bsdfData_12 = bsdfData_11;
    incidentDirection_9 = incidentDirection_8;
    lightColor_1 = lightColor;
    let _e91: SurfaceData = surfaceData_21;
    let _e93: vec3<f32> = incidentDirection_9;
    dotNL_5 = clamp(dot(_e91.normal, _e93), 0f, 1f);
    let _e99: f32 = dotNL_5;
    let _e100: vec3<f32> = lightColor_1;
    irradiance = ((_e99 * _e100) * 3.1415927f);
    let _e105: Varyings = varyings_15;
    let _e106: SurfaceData = surfaceData_21;
    let _e107: BSDFData = bsdfData_12;
    let _e108: vec3<f32> = incidentDirection_9;
    let _e109: vec3<f32> = lightColor_1;
    let _e112: f32 = clearCoatLobe(_e105, _e106, _e107, _e108, _e109, (&specularColor_5));
    attenuation_1 = _e112;
    let _e114: f32 = attenuation_1;
    let _e115: vec3<f32> = irradiance;
    attenuationIrradiance_6 = (_e114 * _e115);
    let _e118: Varyings = varyings_15;
    let _e119: SurfaceData = surfaceData_21;
    let _e120: BSDFData = bsdfData_12;
    let _e121: vec3<f32> = attenuationIrradiance_6;
    diffuseLobe(_e118, _e119, _e120, _e121, (&diffuseColor_4));
    let _e124: Varyings = varyings_15;
    let _e125: SurfaceData = surfaceData_21;
    let _e126: BSDFData = bsdfData_12;
    let _e127: vec3<f32> = incidentDirection_9;
    let _e128: vec3<f32> = attenuationIrradiance_6;
    specularLobe(_e124, _e125, _e126, _e127, _e128, (&specularColor_5));
    let _e131: Varyings = varyings_15;
    let _e132: SurfaceData = surfaceData_21;
    let _e133: BSDFData = bsdfData_12;
    let _e134: vec3<f32> = incidentDirection_9;
    let _e135: vec3<f32> = attenuationIrradiance_6;
    sheenLobe(_e131, _e132, _e133, _e134, _e135, (&diffuseColor_4), (&specularColor_5));
    let _e140: vec3<f32> = (*totalDiffuseColor);
    let _e141: vec3<f32> = diffuseColor_4;
    (*totalDiffuseColor) = (_e140 + _e141);
    let _e143: vec3<f32> = (*totalSpecularColor);
    let _e144: vec3<f32> = specularColor_5;
    (*totalSpecularColor) = (_e143 + _e144);
    return;
}

fn evaluateDirectRadiance(varyings_16: Varyings, surfaceData_22: SurfaceData, bsdfData_13: BSDFData, shadowAttenuation: f32, totalDiffuseColor_1: ptr<function, vec3<f32>>, totalSpecularColor_1: ptr<function, vec3<f32>>) {
    var varyings_17: Varyings;
    var surfaceData_23: SurfaceData;
    var bsdfData_14: BSDFData;
    var shadowAttenuation_1: f32;

    varyings_17 = varyings_16;
    surfaceData_23 = surfaceData_22;
    bsdfData_14 = bsdfData_13;
    shadowAttenuation_1 = shadowAttenuation;
    return;
}

fn getReflectedVector(surfaceData_24: SurfaceData, n: vec3<f32>) -> vec3<f32> {
    var surfaceData_25: SurfaceData;
    var n_1: vec3<f32>;
    var r_1: vec3<f32>;

    surfaceData_25 = surfaceData_24;
    n_1 = n;
    let _e75: SurfaceData = surfaceData_25;
    let _e78: vec3<f32> = n_1;
    r_1 = reflect(-(_e75.viewDir), _e78);
    let _e81: vec3<f32> = r_1;
    return _e81;
}

fn getSpecularMIPLevel(roughness_8: f32, maxMIPLevel: i32) -> f32 {
    var roughness_9: f32;
    var maxMIPLevel_1: i32;

    roughness_9 = roughness_8;
    maxMIPLevel_1 = maxMIPLevel;
    let _e75: f32 = roughness_9;
    let _e76: i32 = maxMIPLevel_1;
    return (_e75 * f32(_e76));
}

fn getLightProbeRadiance(surfaceData_26: SurfaceData, normal_5: vec3<f32>, roughness_10: f32) -> vec3<f32> {
    var surfaceData_27: SurfaceData;
    var normal_6: vec3<f32>;
    var roughness_11: f32;

    surfaceData_27 = surfaceData_26;
    normal_6 = normal_5;
    roughness_11 = roughness_10;
    return vec3(0f);
}

fn evaluateSpecularOcclusion(dotNV_9: f32, diffuseAO: f32, roughness_12: f32) -> f32 {
    var dotNV_10: f32;
    var diffuseAO_1: f32;
    var roughness_13: f32;
    var specularAOFactor: f32 = 1f;

    dotNV_10 = dotNV_9;
    diffuseAO_1 = diffuseAO;
    roughness_13 = roughness_12;
    let _e79: f32 = specularAOFactor;
    return _e79;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal_7: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_8: vec3<f32>;
    var result: vec3<f32>;

    sh_1 = sh;
    normal_8 = normal_7;
    let _e77: vec3<f32> = sh_1[0];
    let _e80: vec3<f32> = sh_1[1];
    let _e81: vec3<f32> = normal_8;
    let _e87: vec3<f32> = sh_1[2];
    let _e88: vec3<f32> = normal_8;
    let _e94: vec3<f32> = sh_1[3];
    let _e95: vec3<f32> = normal_8;
    let _e101: vec3<f32> = sh_1[4];
    let _e102: vec3<f32> = normal_8;
    let _e104: vec3<f32> = normal_8;
    let _e111: vec3<f32> = sh_1[5];
    let _e112: vec3<f32> = normal_8;
    let _e114: vec3<f32> = normal_8;
    let _e121: vec3<f32> = sh_1[6];
    let _e123: vec3<f32> = normal_8;
    let _e126: vec3<f32> = normal_8;
    let _e135: vec3<f32> = sh_1[7];
    let _e136: vec3<f32> = normal_8;
    let _e138: vec3<f32> = normal_8;
    let _e145: vec3<f32> = sh_1[8];
    let _e146: vec3<f32> = normal_8;
    let _e148: vec3<f32> = normal_8;
    let _e151: vec3<f32> = normal_8;
    let _e153: vec3<f32> = normal_8;
    result = ((((((((_e77 + (_e80 * _e81.y)) + (_e87 * _e88.z)) + (_e94 * _e95.x)) + (_e101 * (_e102.y * _e104.x))) + (_e111 * (_e112.y * _e114.z))) + (_e121 * (((3f * _e123.z) * _e126.z) - 1f))) + (_e135 * (_e136.z * _e138.x))) + (_e145 * ((_e146.x * _e148.x) - (_e151.y * _e153.y))));
    let _e160: vec3<f32> = result;
    return max(_e160, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS_1: vec3<f32>) -> vec3<f32> {
    var normalWS_2: vec3<f32>;

    normalWS_2 = normalWS_1;
    let _e73: EnvMapLight = scene_EnvMapLight;
    return (_e73.diffuse * 3.1415927f);
}

fn evaluateDiffuseIBL(varyings_18: Varyings, surfaceData_28: SurfaceData, bsdfData_15: BSDFData, diffuseColor_5: ptr<function, vec3<f32>>) {
    var varyings_19: Varyings;
    var surfaceData_29: SurfaceData;
    var bsdfData_16: BSDFData;
    var irradiance_1: vec3<f32>;

    varyings_19 = varyings_18;
    surfaceData_29 = surfaceData_28;
    bsdfData_16 = bsdfData_15;
    let _e78: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e78.diffuse * 3.1415927f);
    let _e83: vec3<f32> = irradiance_1;
    let _e84: EnvMapLight = scene_EnvMapLight;
    irradiance_1 = (_e83 * _e84.diffuseIntensity);
    let _e87: vec3<f32> = (*diffuseColor_5);
    let _e88: BSDFData = bsdfData_16;
    let _e90: vec3<f32> = irradiance_1;
    let _e92: BSDFData = bsdfData_16;
    let _e94: vec3<f32> = BRDF_Diffuse_Lambert(_e92.diffuseColor);
    (*diffuseColor_5) = (_e87 + ((_e88.diffuseAO * _e90) * _e94));
    return;
}

fn evaluateClearCoatIBL(varyings_20: Varyings, surfaceData_30: SurfaceData, bsdfData_17: BSDFData, specularColor_6: ptr<function, vec3<f32>>) -> f32 {
    var varyings_21: Varyings;
    var surfaceData_31: SurfaceData;
    var bsdfData_18: BSDFData;
    var radianceAttenuation: f32 = 1f;

    varyings_21 = varyings_20;
    surfaceData_31 = surfaceData_30;
    bsdfData_18 = bsdfData_17;
    let _e80: f32 = radianceAttenuation;
    return _e80;
}

fn evaluateSpecularIBL(varyings_22: Varyings, surfaceData_32: SurfaceData, bsdfData_19: BSDFData, radianceAttenuation_1: f32, outSpecularColor: ptr<function, vec3<f32>>) {
    var varyings_23: Varyings;
    var surfaceData_33: SurfaceData;
    var bsdfData_20: BSDFData;
    var radianceAttenuation_2: f32;
    var radiance: vec3<f32>;
    var specularAO: f32;

    varyings_23 = varyings_22;
    surfaceData_33 = surfaceData_32;
    bsdfData_20 = bsdfData_19;
    radianceAttenuation_2 = radianceAttenuation_1;
    let _e80: SurfaceData = surfaceData_33;
    let _e81: SurfaceData = surfaceData_33;
    let _e83: BSDFData = bsdfData_20;
    let _e85: vec3<f32> = getLightProbeRadiance(_e80, _e81.normal, _e83.roughness);
    radiance = _e85;
    let _e87: SurfaceData = surfaceData_33;
    let _e89: BSDFData = bsdfData_20;
    let _e91: BSDFData = bsdfData_20;
    let _e93: f32 = evaluateSpecularOcclusion(_e87.dotNV, _e89.diffuseAO, _e91.roughness);
    specularAO = _e93;
    let _e95: vec3<f32> = (*outSpecularColor);
    let _e96: f32 = specularAO;
    let _e97: f32 = radianceAttenuation_2;
    let _e99: vec3<f32> = radiance;
    let _e101: BSDFData = bsdfData_20;
    let _e103: BSDFData = bsdfData_20;
    let _e105: BSDFData = bsdfData_20;
    let _e107: SurfaceData = surfaceData_33;
    let _e109: vec3<f32> = envBRDFApprox(_e101.resolvedSpecularF0_, _e103.specularF90_, _e105.roughness, _e107.dotNV);
    let _e111: BSDFData = bsdfData_20;
    (*outSpecularColor) = (_e95 + ((((_e96 * _e97) * _e99) * _e109) * _e111.energyCompensation));
    return;
}

fn evaluateSheenIBL(varyings_24: Varyings, surfaceData_34: SurfaceData, bsdfData_21: BSDFData, radianceAttenuation_3: f32, diffuseColor_6: ptr<function, vec3<f32>>, specularColor_7: ptr<function, vec3<f32>>) {
    var varyings_25: Varyings;
    var surfaceData_35: SurfaceData;
    var bsdfData_22: BSDFData;
    var radianceAttenuation_4: f32;

    varyings_25 = varyings_24;
    surfaceData_35 = surfaceData_34;
    bsdfData_22 = bsdfData_21;
    radianceAttenuation_4 = radianceAttenuation_3;
    return;
}

fn evaluateIBL(varyings_26: Varyings, surfaceData_36: SurfaceData, bsdfData_23: BSDFData, totalDiffuseColor_2: ptr<function, vec3<f32>>, totalSpecularColor_2: ptr<function, vec3<f32>>) {
    var varyings_27: Varyings;
    var surfaceData_37: SurfaceData;
    var bsdfData_24: BSDFData;
    var diffuseColor_7: vec3<f32> = vec3(0f);
    var specularColor_8: vec3<f32> = vec3(0f);
    var radianceAttenuation_5: f32;

    varyings_27 = varyings_26;
    surfaceData_37 = surfaceData_36;
    bsdfData_24 = bsdfData_23;
    let _e87: Varyings = varyings_27;
    let _e88: SurfaceData = surfaceData_37;
    let _e89: BSDFData = bsdfData_24;
    evaluateDiffuseIBL(_e87, _e88, _e89, (&diffuseColor_7));
    let _e92: Varyings = varyings_27;
    let _e93: SurfaceData = surfaceData_37;
    let _e94: BSDFData = bsdfData_24;
    let _e97: f32 = evaluateClearCoatIBL(_e92, _e93, _e94, (&specularColor_8));
    radianceAttenuation_5 = _e97;
    let _e99: Varyings = varyings_27;
    let _e100: SurfaceData = surfaceData_37;
    let _e101: BSDFData = bsdfData_24;
    let _e102: f32 = radianceAttenuation_5;
    evaluateSpecularIBL(_e99, _e100, _e101, _e102, (&specularColor_8));
    let _e105: Varyings = varyings_27;
    let _e106: SurfaceData = surfaceData_37;
    let _e107: BSDFData = bsdfData_24;
    let _e108: f32 = radianceAttenuation_5;
    evaluateSheenIBL(_e105, _e106, _e107, _e108, (&diffuseColor_7), (&specularColor_8));
    let _e113: vec3<f32> = (*totalDiffuseColor_2);
    let _e114: vec3<f32> = diffuseColor_7;
    (*totalDiffuseColor_2) = (_e113 + _e114);
    let _e116: vec3<f32> = (*totalSpecularColor_2);
    let _e117: vec3<f32> = specularColor_8;
    (*totalSpecularColor_2) = (_e116 + _e117);
    return;
}

fn sampleVolumetricCloudShadow(positionWS_1: vec3<f32>) -> f32 {
    var positionWS_2: vec3<f32>;

    positionWS_2 = positionWS_1;
    return 1f;
}

fn sampleTerrainProjectShadow(varyings_28: Varyings) -> f32 {
    var varyings_29: Varyings;
    var attenuation_2: f32 = 1f;

    varyings_29 = varyings_28;
    let _e75: f32 = attenuation_2;
    return _e75;
}

fn terrainProjectEvaluateSpecularIBL(surfaceData_38: SurfaceData, bsdfData_25: BSDFData, radiance_1: vec3<f32>) -> vec3<f32> {
    var surfaceData_39: SurfaceData;
    var bsdfData_26: BSDFData;
    var radiance_2: vec3<f32>;
    var specularAO_1: f32;

    surfaceData_39 = surfaceData_38;
    bsdfData_26 = bsdfData_25;
    radiance_2 = radiance_1;
    let _e77: SurfaceData = surfaceData_39;
    let _e79: BSDFData = bsdfData_26;
    let _e81: BSDFData = bsdfData_26;
    let _e83: f32 = evaluateSpecularOcclusion(_e77.dotNV, _e79.diffuseAO, _e81.roughness);
    specularAO_1 = _e83;
    let _e85: f32 = specularAO_1;
    let _e86: vec3<f32> = radiance_2;
    let _e88: BSDFData = bsdfData_26;
    let _e90: BSDFData = bsdfData_26;
    let _e92: BSDFData = bsdfData_26;
    let _e94: SurfaceData = surfaceData_39;
    let _e96: vec3<f32> = envBRDFApprox(_e88.resolvedSpecularF0_, _e90.specularF90_, _e92.roughness, _e94.dotNV);
    let _e98: BSDFData = bsdfData_26;
    return (((_e85 * _e86) * _e96) * _e98.energyCompensation);
}

fn evaluateTerrainProjectLightingWithShadow(varyings_30: Varyings, surfaceData_40: SurfaceData, shadowAttenuation_2: f32) -> TerrainProjectLightingResult {
    var varyings_31: Varyings;
    var surfaceData_41: SurfaceData;
    var shadowAttenuation_3: f32;
    var result_1: TerrainProjectLightingResult;
    var bsdfData_27: BSDFData;
    var directShadowAttenuation: f32;
    var substrateRadiance: vec3<f32>;

    varyings_31 = varyings_30;
    surfaceData_41 = surfaceData_40;
    shadowAttenuation_3 = shadowAttenuation_2;
    result_1.directDiffuse = vec3(0f);
    result_1.directSpecular = vec3(0f);
    result_1.environmentDiffuse = vec3(0f);
    result_1.environmentSpecular = vec3(0f);
    let _e91: f32 = shadowAttenuation_3;
    result_1.shadowAttenuation = _e91;
    let _e93: SurfaceData = surfaceData_41;
    surfaceData_41.albedoColor = _e93.albedoColor;
    let _e96: SurfaceData = surfaceData_41;
    initBSDFData(_e96, (&bsdfData_27));
    let _e99: TerrainProjectLightingResult = result_1;
    directShadowAttenuation = _e99.shadowAttenuation;
    let _e102: Varyings = varyings_31;
    let _e103: SurfaceData = surfaceData_41;
    let _e104: BSDFData = bsdfData_27;
    let _e105: f32 = directShadowAttenuation;
    let _e106: TerrainProjectLightingResult = result_1;
    let _e108: TerrainProjectLightingResult = result_1;
    var gs_output_arg0 = result_1.directDiffuse;
    var gs_output_arg1 = result_1.directSpecular;
    evaluateDirectRadiance(_e102, _e103, _e104, _e105, (&gs_output_arg0), (&gs_output_arg1));
    result_1.directDiffuse = gs_output_arg0;
    result_1.directSpecular = gs_output_arg1;
    let _e114: Varyings = varyings_31;
    let _e115: SurfaceData = surfaceData_41;
    let _e116: BSDFData = bsdfData_27;
    let _e117: TerrainProjectLightingResult = result_1;
    var gs_output_arg2 = result_1.environmentDiffuse;
    evaluateDiffuseIBL(_e114, _e115, _e116, (&gs_output_arg2));
    result_1.environmentDiffuse = gs_output_arg2;
    let _e121: SurfaceData = surfaceData_41;
    let _e122: SurfaceData = surfaceData_41;
    let _e124: BSDFData = bsdfData_27;
    let _e126: vec3<f32> = getLightProbeRadiance(_e121, _e122.normal, _e124.roughness);
    substrateRadiance = _e126;
    let _e129: TerrainProjectLightingResult = result_1;
    let _e131: SurfaceData = surfaceData_41;
    let _e132: BSDFData = bsdfData_27;
    let _e133: vec3<f32> = substrateRadiance;
    let _e134: vec3<f32> = terrainProjectEvaluateSpecularIBL(_e131, _e132, _e133);
    result_1.environmentSpecular = (_e129.environmentSpecular + _e134);
    let _e136: TerrainProjectLightingResult = result_1;
    return _e136;
}

fn terrainProjectCreateLightingResult() -> TerrainProjectLightingResult {
    var result_2: TerrainProjectLightingResult;

    result_2.directDiffuse = vec3(0f);
    result_2.directSpecular = vec3(0f);
    result_2.environmentDiffuse = vec3(0f);
    result_2.environmentSpecular = vec3(0f);
    result_2.shadowAttenuation = 1f;
    let _e86: TerrainProjectLightingResult = result_2;
    return _e86;
}

fn terrainProjectAccumulateLighting(total: ptr<function, TerrainProjectLightingResult>, contribution: TerrainProjectLightingResult, weight_2: f32) {
    var contribution_1: TerrainProjectLightingResult;
    var weight_3: f32;

    contribution_1 = contribution;
    weight_3 = weight_2;
    let _e77: TerrainProjectLightingResult = (*total);
    let _e79: TerrainProjectLightingResult = contribution_1;
    let _e81: f32 = weight_3;
    (*total).directDiffuse = (_e77.directDiffuse + (_e79.directDiffuse * _e81));
    let _e85: TerrainProjectLightingResult = (*total);
    let _e87: TerrainProjectLightingResult = contribution_1;
    let _e89: f32 = weight_3;
    (*total).directSpecular = (_e85.directSpecular + (_e87.directSpecular * _e89));
    let _e93: TerrainProjectLightingResult = (*total);
    let _e95: TerrainProjectLightingResult = contribution_1;
    let _e97: f32 = weight_3;
    (*total).environmentDiffuse = (_e93.environmentDiffuse + (_e95.environmentDiffuse * _e97));
    let _e101: TerrainProjectLightingResult = (*total);
    let _e103: TerrainProjectLightingResult = contribution_1;
    let _e105: f32 = weight_3;
    (*total).environmentSpecular = (_e101.environmentSpecular + (_e103.environmentSpecular * _e105));
    let _e109: TerrainProjectLightingResult = contribution_1;
    (*total).shadowAttenuation = _e109.shadowAttenuation;
    return;
}

fn terrainProjectApplyWaterFilmLighting(varyings_32: Varyings, substrate_2: SurfaceData, waterFilm_8: TerrainProjectWaterFilm, ssrDepthSlope: f32, result_3: ptr<function, TerrainProjectLightingResult>) {
    var varyings_33: Varyings;
    var substrate_3: SurfaceData;
    var waterFilm_9: TerrainProjectWaterFilm;
    var ssrDepthSlope_1: f32;
    var waterFresnel: f32;
    var substrateTransmission: f32;
    var waterSurface_1: SurfaceData;
    var waterBsdfData: BSDFData;
    var unusedDiffuse: vec3<f32> = vec3(0f);
    var directSpecular: vec3<f32> = vec3(0f);
    var shadowAttenuation_4: f32;
    var radiance_3: vec3<f32>;
    var environmentSpecular: vec3<f32>;
    var reflectionIntensity: f32;

    varyings_33 = varyings_32;
    substrate_3 = substrate_2;
    waterFilm_9 = waterFilm_8;
    ssrDepthSlope_1 = ssrDepthSlope;
    let _e80: TerrainProjectWaterFilm = waterFilm_9;
    if (_e80.coverage > 0f) {
        {
            let _e84: f32 = terrainProjectWaterF0_();
            let _e86: TerrainProjectWaterFilm = waterFilm_9;
            let _e88: f32 = F_Schlick(_e84, 1f, _e86.dotNV);
            waterFresnel = _e88;
            let _e91: TerrainProjectWaterFilm = waterFilm_9;
            let _e93: f32 = waterFresnel;
            substrateTransmission = (1f - (_e91.coverage * _e93));
            let _e98: TerrainProjectLightingResult = (*result_3);
            let _e100: f32 = substrateTransmission;
            (*result_3).directDiffuse = (_e98.directDiffuse * _e100);
            let _e103: TerrainProjectLightingResult = (*result_3);
            let _e105: f32 = substrateTransmission;
            (*result_3).directSpecular = (_e103.directSpecular * _e105);
            let _e108: TerrainProjectLightingResult = (*result_3);
            let _e110: f32 = substrateTransmission;
            (*result_3).environmentDiffuse = (_e108.environmentDiffuse * _e110);
            let _e113: TerrainProjectLightingResult = (*result_3);
            let _e115: f32 = substrateTransmission;
            (*result_3).environmentSpecular = (_e113.environmentSpecular * _e115);
            let _e117: SurfaceData = substrate_3;
            let _e118: TerrainProjectWaterFilm = waterFilm_9;
            let _e119: SurfaceData = terrainProjectBuildWaterFilmSurface(_e117, _e118);
            waterSurface_1 = _e119;
            let _e122: SurfaceData = waterSurface_1;
            initBSDFData(_e122, (&waterBsdfData));
            let _e131: TerrainProjectLightingResult = (*result_3);
            shadowAttenuation_4 = _e131.shadowAttenuation;
            let _e134: Varyings = varyings_33;
            let _e135: SurfaceData = waterSurface_1;
            let _e136: BSDFData = waterBsdfData;
            let _e137: f32 = shadowAttenuation_4;
            evaluateDirectRadiance(_e134, _e135, _e136, _e137, (&unusedDiffuse), (&directSpecular));
            let _e142: SurfaceData = waterSurface_1;
            let _e143: SurfaceData = waterSurface_1;
            let _e145: BSDFData = waterBsdfData;
            let _e147: vec3<f32> = getLightProbeRadiance(_e142, _e143.normal, _e145.roughness);
            radiance_3 = _e147;
            let _e149: SurfaceData = waterSurface_1;
            let _e150: BSDFData = waterBsdfData;
            let _e151: vec3<f32> = radiance_3;
            let _e152: vec3<f32> = terrainProjectEvaluateSpecularIBL(_e149, _e150, _e151);
            environmentSpecular = _e152;
            let _e154: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
            reflectionIntensity = _e154.z;
            let _e158: TerrainProjectLightingResult = (*result_3);
            let _e160: vec3<f32> = directSpecular;
            let _e161: TerrainProjectWaterFilm = waterFilm_9;
            let _e164: f32 = reflectionIntensity;
            (*result_3).directSpecular = (_e158.directSpecular + ((_e160 * _e161.coverage) * _e164));
            let _e168: TerrainProjectLightingResult = (*result_3);
            let _e170: vec3<f32> = environmentSpecular;
            let _e171: TerrainProjectWaterFilm = waterFilm_9;
            let _e174: f32 = reflectionIntensity;
            (*result_3).environmentSpecular = (_e168.environmentSpecular + ((_e170 * _e171.coverage) * _e174));
            return;
        }
    } else {
        return;
    }
}

fn terrainProjectFinalLighting(result_4: TerrainProjectLightingResult) -> vec3<f32> {
    var result_5: TerrainProjectLightingResult;

    result_5 = result_4;
    let _e73: TerrainProjectLightingResult = result_5;
    let _e75: TerrainProjectLightingResult = result_5;
    let _e78: TerrainProjectLightingResult = result_5;
    let _e81: TerrainProjectLightingResult = result_5;
    return (((_e73.directDiffuse + _e75.directSpecular) + _e78.environmentDiffuse) + _e81.environmentSpecular);
}

fn TerrainFragment(varyings_34: Varyings) {
    var varyings_35: Varyings;
    var ssrDepthSlope_2: f32 = 0f;
    var shadowAttenuation_5: f32;
    var geometryNormal_16: vec3<f32>;
    var color_2: vec3<f32> = vec3(0f);
    var waterFilm_10: TerrainProjectWaterFilm;
    var surfaceData_42: SurfaceData;
    var lighting: TerrainProjectLightingResult;

    varyings_35 = varyings_34;
    let _e75: Varyings = varyings_35;
    let _e76: f32 = sampleTerrainProjectShadow(_e75);
    shadowAttenuation_5 = _e76;
    let _e78: f32 = shadowAttenuation_5;
    let _e79: Varyings = varyings_35;
    shadowAttenuation_5 = (_e78 * _e79.cloudShadow);
    let _e82: Varyings = varyings_35;
    let _e85: Varyings = varyings_35;
    let _e87: vec3<f32> = terrainProjectShadingGeometryNormal(_e82.positionWS.xz, _e85.normalWS);
    geometryNormal_16 = _e87;
    let _e93: Varyings = varyings_35;
    let _e94: vec3<f32> = geometryNormal_16;
    let _e97: SurfaceData = evaluateTerrainFallbackSurface(_e93, _e94, (&waterFilm_10));
    surfaceData_42 = _e97;
    let _e99: Varyings = varyings_35;
    let _e100: SurfaceData = surfaceData_42;
    let _e101: f32 = shadowAttenuation_5;
    let _e102: TerrainProjectLightingResult = evaluateTerrainProjectLightingWithShadow(_e99, _e100, _e101);
    lighting = _e102;
    let _e104: Varyings = varyings_35;
    let _e105: SurfaceData = surfaceData_42;
    let _e106: TerrainProjectWaterFilm = waterFilm_10;
    let _e107: f32 = ssrDepthSlope_2;
    terrainProjectApplyWaterFilmLighting(_e104, _e105, _e106, _e107, (&lighting));
    let _e110: TerrainProjectLightingResult = lighting;
    let _e111: vec3<f32> = terrainProjectFinalLighting(_e110);
    color_2 = _e111;
    let _e112: vec3<f32> = color_2;
    converted_FragColor = vec4<f32>(_e112.x, _e112.y, _e112.z, 1f);
    return;
}

fn gs_wgpu_main() {
    var input_varyings: Varyings;

    let _e71: Varyings = read_Varyings();
    input_varyings = _e71;
    let _e73: Varyings = input_varyings;
    TerrainFragment(_e73);
    return;
}

fn main_1() {
    let _e75: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e81: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e87: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e75.x), bitcast<f32>(_e81.y), bitcast<f32>(_e87.z));
    let _e95: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e95.w);
    let _e102: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e102.x);
    let _e109: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e109.y);
    let _e116: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e116.z);
    let _e123: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e123.w);
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) positionWS: vec3<f32>, @location(2) normalWS: vec3<f32>, @location(3) positionCS: vec4<f32>, @location(5) clipmapMorph: f32, @location(6) cloudShadow: f32) -> FragmentOutput {
    positionWS_3 = positionWS;
    normalWS_3 = normalWS;
    positionCS_1 = positionCS;
    clipmapMorph_1 = clipmapMorph;
    cloudShadow_1 = cloudShadow;
    main_1();
    let _e98: vec4<f32> = converted_FragColor;
    return FragmentOutput(_e98);
}
