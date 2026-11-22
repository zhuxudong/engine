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

struct gs_Auto_1_ {
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    material_TerrainRegionHeightDecode: array<vec4<f32>, 32>,
    material_TerrainVertexSpacing: f32,
    material_TerrainGridOrigin: vec2<f32>,
    renderer_ClipmapMeshSize: f32,
}

struct Attributes {
    POSITION: vec3<f32>,
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

struct TerrainProjectClipmapVertex {
    positionWS: vec3<f32>,
    sourceXZ: vec2<f32>,
    valid: f32,
    morph: f32,
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
    @location(0) positionWS: vec3<f32>,
    @location(1) sourceXZ: vec2<f32>,
    @location(2) normalWS: vec3<f32>,
    @location(3) positionCS: vec4<f32>,
    @location(4) terrainValid: f32,
    @location(5) clipmapMorph: f32,
    @location(6) cloudShadow: f32,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> POSITION_1: vec3<f32>;
var<private> positionWS_2: vec3<f32>;
var<private> sourceXZ_4: vec2<f32>;
var<private> normalWS_2: vec3<f32>;
var<private> positionCS: vec4<f32>;
var<private> terrainValid: f32;
var<private> clipmapMorph: f32;
var<private> cloudShadow: f32;
@group(2) @binding(2) 
var gs_wgpu_tex_material_TerrainHeightAtlas: texture_2d<f32>;
@group(2) @binding(3) 
var gs_wgpu_samp_material_TerrainHeightAtlas: sampler;
@group(2) @binding(4) 
var gs_wgpu_tex_material_TerrainNormalAtlas: texture_2d<f32>;
@group(2) @binding(5) 
var gs_wgpu_samp_material_TerrainNormalAtlas: sampler;
@group(2) @binding(6) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e35: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e35;
    let _e36: Attributes = interface_value;
    return _e36;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e42: Varyings = interface_value_2;
    positionWS_2 = _e42.positionWS;
    let _e44: Varyings = interface_value_2;
    sourceXZ_4 = _e44.sourceXZ;
    let _e46: Varyings = interface_value_2;
    normalWS_2 = _e46.normalWS;
    let _e48: Varyings = interface_value_2;
    positionCS = _e48.positionCS;
    let _e50: Varyings = interface_value_2;
    terrainValid = _e50.terrainValid;
    let _e52: Varyings = interface_value_2;
    clipmapMorph = _e52.clipmapMorph;
    let _e54: Varyings = interface_value_2;
    cloudShadow = _e54.cloudShadow;
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
        let _e51: i32 = index;
        if !((_e51 < 32i)) {
            break;
        }
        {
            let _e58: i32 = index;
            let _e59: i32 = global.material_TerrainRegionCount;
            if (_e58 >= _e59) {
                {
                    break;
                }
            }
            let _e61: i32 = index;
            let _e63: vec4<f32> = global.material_TerrainRegionWorldBounds[_e61];
            bounds = _e63;
            let _e65: vec4<f32> = bounds;
            minimum = _e65.xy;
            let _e68: vec2<f32> = minimum;
            let _e69: vec4<f32> = bounds;
            maximum = (_e68 + _e69.zw);
            let _e73: vec2<f32> = worldXZ_1;
            let _e74: vec2<f32> = minimum;
            let _e77: vec2<f32> = worldXZ_1;
            let _e78: vec2<f32> = maximum;
            if (all((_e73 >= _e74)) && all((_e77 <= _e78))) {
                {
                    let _e82: vec2<f32> = worldXZ_1;
                    let _e83: vec2<f32> = maximum;
                    if all((_e82 < _e83)) {
                        {
                            let _e86: i32 = index;
                            return _e86;
                        }
                    }
                    let _e87: i32 = inclusiveBoundaryCandidate;
                    let _e90: vec2<f32> = minimum;
                    let _e92: vec2<f32> = candidateMinimum;
                    let _e96: vec2<f32> = minimum;
                    let _e98: vec2<f32> = candidateMinimum;
                    let _e101: vec2<f32> = minimum;
                    let _e103: vec2<f32> = candidateMinimum;
                    if (((_e87 < 0i) || (_e90.x > _e92.x)) || ((_e96.x == _e98.x) && (_e101.y > _e103.y))) {
                        {
                            let _e108: i32 = index;
                            inclusiveBoundaryCandidate = _e108;
                            let _e109: vec2<f32> = minimum;
                            candidateMinimum = _e109;
                        }
                    }
                }
            }
        }
        continuing {
            let _e55: i32 = index;
            index = (_e55 + 1i);
        }
    }
    let _e110: i32 = inclusiveBoundaryCandidate;
    return _e110;
}

fn terrainProjectDecodeR16_(atlasTexel: vec2<f32>) -> f32 {
    var atlasTexel_1: vec2<f32>;
    var bytes: vec2<f32>;

    atlasTexel_1 = atlasTexel;
    let _e46: vec2<f32> = atlasTexel_1;
    let _e50: vec2<f32> = global.material_TerrainHeightAtlasInvSize;
    let _e53: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_TerrainHeightAtlas, gs_wgpu_samp_material_TerrainHeightAtlas, ((_e46 + vec2(0.5f)) * _e50), 0f);
    bytes = (_e53.xy * 255f);
    let _e58: vec2<f32> = bytes;
    let _e60: vec2<f32> = bytes;
    return ((_e58.x + (_e60.y * 256f)) / 65535f);
}

fn terrainProjectHeightAt(worldXZ_2: vec2<f32>, valid: ptr<function, f32>) -> f32 {
    var worldXZ_3: vec2<f32>;
    var regionIndex: i32;
    var bounds_1: vec4<f32>;
    var atlasRect: vec4<f32>;
    var local: vec2<f32>;
    var grid: vec2<f32>;
    var gridMinimum: vec2<f32>;
    var gridMaximum: vec2<f32>;
    var blend: vec2<f32>;
    var atlasMinimum: vec2<f32>;
    var atlasMaximum: vec2<f32>;
    var height00_: f32;
    var height10_: f32;
    var height01_: f32;
    var height11_: f32;
    var normalizedHeight: f32;
    var decode: vec2<f32>;

    worldXZ_3 = worldXZ_2;
    let _e47: vec2<f32> = worldXZ_3;
    let _e48: i32 = terrainProjectRegionIndex(_e47);
    regionIndex = _e48;
    let _e50: i32 = regionIndex;
    if (_e50 < 0i) {
        {
            (*valid) = 0f;
            return 0f;
        }
    }
    let _e55: i32 = regionIndex;
    let _e57: vec4<f32> = global.material_TerrainRegionWorldBounds[_e55];
    bounds_1 = _e57;
    let _e59: i32 = regionIndex;
    let _e61: vec4<f32> = global.material_TerrainRegionAtlasRects[_e59];
    atlasRect = _e61;
    let _e63: vec2<f32> = worldXZ_3;
    let _e64: vec4<f32> = bounds_1;
    let _e67: vec4<f32> = bounds_1;
    local = clamp(((_e63 - _e64.xy) / _e67.zw), vec2(0f), vec2(1f));
    let _e76: vec2<f32> = local;
    let _e77: vec4<f32> = atlasRect;
    grid = (_e76 * (_e77.zw - vec2(1f)));
    let _e84: vec2<f32> = grid;
    gridMinimum = floor(_e84);
    let _e87: vec2<f32> = gridMinimum;
    let _e91: vec4<f32> = atlasRect;
    gridMaximum = min((_e87 + vec2(1f)), (_e91.zw - vec2(1f)));
    let _e98: vec2<f32> = grid;
    let _e99: vec2<f32> = gridMinimum;
    blend = (_e98 - _e99);
    let _e102: vec4<f32> = atlasRect;
    let _e104: vec2<f32> = gridMinimum;
    atlasMinimum = (_e102.xy + _e104);
    let _e107: vec4<f32> = atlasRect;
    let _e109: vec2<f32> = gridMaximum;
    atlasMaximum = (_e107.xy + _e109);
    let _e112: vec2<f32> = atlasMinimum;
    let _e113: f32 = terrainProjectDecodeR16_(_e112);
    height00_ = _e113;
    let _e115: vec2<f32> = atlasMaximum;
    let _e117: vec2<f32> = atlasMinimum;
    let _e120: f32 = terrainProjectDecodeR16_(vec2<f32>(_e115.x, _e117.y));
    height10_ = _e120;
    let _e122: vec2<f32> = atlasMinimum;
    let _e124: vec2<f32> = atlasMaximum;
    let _e127: f32 = terrainProjectDecodeR16_(vec2<f32>(_e122.x, _e124.y));
    height01_ = _e127;
    let _e129: vec2<f32> = atlasMaximum;
    let _e130: f32 = terrainProjectDecodeR16_(_e129);
    height11_ = _e130;
    let _e132: f32 = height00_;
    let _e133: f32 = height10_;
    let _e134: vec2<f32> = blend;
    let _e137: f32 = height01_;
    let _e138: f32 = height11_;
    let _e139: vec2<f32> = blend;
    let _e142: vec2<f32> = blend;
    normalizedHeight = mix(mix(_e132, _e133, _e134.x), mix(_e137, _e138, _e139.x), _e142.y);
    let _e146: i32 = regionIndex;
    let _e148: vec2<f32> = global_1.material_TerrainRegionHeightDecode[_e146].xy;
    decode = _e148;
    (*valid) = 1f;
    let _e151: vec2<f32> = decode;
    let _e153: f32 = normalizedHeight;
    let _e154: vec2<f32> = decode;
    return (_e151.x + (_e153 * _e154.y));
}

fn terrainProjectGeometryNormalAt(worldXZ_4: vec2<f32>, valid_1: ptr<function, f32>) -> vec3<f32> {
    var worldXZ_5: vec2<f32>;
    var regionIndex_1: i32;
    var bounds_2: vec4<f32>;
    var atlasRect_1: vec4<f32>;
    var local_1: vec2<f32>;
    var grid_1: vec2<f32>;
    var encodedXZ: vec2<f32>;
    var normalY: f32;

    worldXZ_5 = worldXZ_4;
    let _e47: vec2<f32> = worldXZ_5;
    let _e48: i32 = terrainProjectRegionIndex(_e47);
    regionIndex_1 = _e48;
    let _e50: i32 = regionIndex_1;
    if (_e50 < 0i) {
        {
            (*valid_1) = 0f;
            return vec3<f32>(0f, 1f, 0f);
        }
    }
    let _e58: i32 = regionIndex_1;
    let _e60: vec4<f32> = global.material_TerrainRegionWorldBounds[_e58];
    bounds_2 = _e60;
    let _e62: i32 = regionIndex_1;
    let _e64: vec4<f32> = global.material_TerrainRegionAtlasRects[_e62];
    atlasRect_1 = _e64;
    let _e66: vec2<f32> = worldXZ_5;
    let _e67: vec4<f32> = bounds_2;
    let _e70: vec4<f32> = bounds_2;
    local_1 = clamp(((_e66 - _e67.xy) / _e70.zw), vec2(0f), vec2(1f));
    let _e79: vec2<f32> = local_1;
    let _e80: vec4<f32> = atlasRect_1;
    grid_1 = (_e79 * (_e80.zw - vec2(1f)));
    let _e87: vec4<f32> = atlasRect_1;
    let _e89: vec2<f32> = grid_1;
    let _e94: vec2<f32> = global.material_TerrainHeightAtlasInvSize;
    let _e97: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_TerrainNormalAtlas, gs_wgpu_samp_material_TerrainNormalAtlas, (((_e87.xy + _e89) + vec2(0.5f)) * _e94), 0f);
    encodedXZ = ((_e97.xy * 2f) - vec2(1f));
    let _e106: vec2<f32> = encodedXZ;
    let _e107: vec2<f32> = encodedXZ;
    normalY = sqrt(max((1f - dot(_e106, _e107)), 0f));
    (*valid_1) = 1f;
    let _e115: vec2<f32> = encodedXZ;
    let _e117: f32 = normalY;
    let _e118: vec2<f32> = encodedXZ;
    return normalize(vec3<f32>(_e115.x, _e117, _e118.y));
}

fn terrainProjectClipmapMorphFactor(sourceXZ: vec2<f32>) -> f32 {
    var sourceXZ_1: vec2<f32>;
    var levelSpacing: f32;
    var distanceInLevelVertices: vec2<f32>;
    var outerDistance: f32;
    var transition: f32;

    sourceXZ_1 = sourceXZ;
    let _e46: f32 = global_1.material_TerrainVertexSpacing;
    let _e47: f32 = global.renderer_Lod;
    levelSpacing = (_e46 * exp2(_e47));
    let _e51: vec2<f32> = sourceXZ_1;
    let _e52: vec3<f32> = global.camera_Position;
    let _e56: f32 = levelSpacing;
    distanceInLevelVertices = (abs((_e51 - _e52.xz)) / vec2(_e56));
    let _e60: vec2<f32> = distanceInLevelVertices;
    let _e62: vec2<f32> = distanceInLevelVertices;
    outerDistance = max(_e60.x, _e62.y);
    let _e66: f32 = outerDistance;
    let _e67: f32 = global_1.renderer_ClipmapMeshSize;
    let _e71: f32 = global_1.renderer_ClipmapMeshSize;
    transition = (((_e66 - _e67) - 4f) / (_e71 - 4f));
    let _e78: f32 = transition;
    return smoothstep(0f, 1f, _e78);
}

fn terrainProjectClipmapVertexShift(positionOS: vec3<f32>, sourceXZ_2: vec2<f32>) -> vec2<f32> {
    var positionOS_1: vec3<f32>;
    var sourceXZ_3: vec2<f32>;
    var levelSpacing_1: f32;
    var levelGrid: vec2<f32>;
    var vertexParity: vec2<f32>;
    var diagonalParity: f32;

    positionOS_1 = positionOS;
    sourceXZ_3 = sourceXZ_2;
    let _e48: f32 = global_1.material_TerrainVertexSpacing;
    let _e49: f32 = global.renderer_Lod;
    levelSpacing_1 = (_e48 * exp2(_e49));
    let _e53: vec2<f32> = sourceXZ_3;
    let _e54: vec2<f32> = global_1.material_TerrainGridOrigin;
    let _e56: f32 = levelSpacing_1;
    levelGrid = ((_e53 - _e54) / vec2(_e56));
    let _e60: vec3<f32> = positionOS_1;
    vertexParity = (fract((_e60.xz * 0.5f)) * 2f);
    let _e68: f32 = global.renderer_Lod;
    if (_e68 < 0.5f) {
        {
            let _e71: vec2<f32> = levelGrid;
            let _e79: vec2<f32> = levelGrid;
            diagonalParity = round(fract(((round((_e71.y - (floor((_e71.y / 4f)) * 4f))) * round((_e79.x - (floor((_e79.x / 4f)) * 4f)))) * 0.25f)));
            let _e93: vec2<f32> = vertexParity;
            let _e94: vec2<f32> = vertexParity;
            let _e96: vec2<f32> = vertexParity;
            let _e100: f32 = diagonalParity;
            return mix(_e93, vec2<f32>(_e94.x, -(_e96.y)), vec2(_e100));
        }
    }
    let _e103: vec2<f32> = vertexParity;
    let _e104: vec2<f32> = levelGrid;
    return (_e103 * round(((fract((_e104 * 0.25f)) - vec2(0.5f)) * 4f)));
}

fn terrainProjectClipmapVertexAt(positionOS_2: vec3<f32>) -> TerrainProjectClipmapVertex {
    var positionOS_3: vec3<f32>;
    var result: TerrainProjectClipmapVertex;
    var homogeneousPositionWS: vec4<f32>;
    var sourcePositionWS: vec3<f32>;
    var sourceHeight: f32;
    var local_2: f32;
    var levelSpacing_2: f32;
    var targetXZ: vec2<f32>;
    var targetValid: f32;
    var targetHeight: f32;
    var renderedXZ: vec2<f32>;

    positionOS_3 = positionOS_2;
    let _e47: mat4x4<f32> = global_1.renderer_ModelMat;
    let _e48: vec3<f32> = positionOS_3;
    homogeneousPositionWS = (_e47 * vec4<f32>(_e48.x, _e48.y, _e48.z, 1f));
    let _e56: vec4<f32> = homogeneousPositionWS;
    let _e58: vec4<f32> = homogeneousPositionWS;
    sourcePositionWS = (_e56.xyz / vec3(_e58.w));
    let _e64: vec3<f32> = sourcePositionWS;
    result.sourceXZ = _e64.xz;
    let _e66: TerrainProjectClipmapVertex = result;
    let _e68: TerrainProjectClipmapVertex = result;
    var gs_output_arg0 = result.valid;
    let _e72: f32 = terrainProjectHeightAt(_e66.sourceXZ, (&gs_output_arg0));
    result.valid = gs_output_arg0;
    sourceHeight = _e72;
    let _e75: TerrainProjectClipmapVertex = result;
    if (_e75.valid < 0.5f) {
        local_2 = 0f;
    } else {
        let _e80: TerrainProjectClipmapVertex = result;
        let _e82: f32 = terrainProjectClipmapMorphFactor(_e80.sourceXZ);
        local_2 = _e82;
    }
    let _e84: f32 = local_2;
    result.morph = _e84;
    let _e85: f32 = global_1.material_TerrainVertexSpacing;
    let _e86: f32 = global.renderer_Lod;
    levelSpacing_2 = (_e85 * exp2(_e86));
    let _e90: TerrainProjectClipmapVertex = result;
    let _e92: vec3<f32> = positionOS_3;
    let _e93: TerrainProjectClipmapVertex = result;
    let _e95: vec2<f32> = terrainProjectClipmapVertexShift(_e92, _e93.sourceXZ);
    let _e96: f32 = levelSpacing_2;
    targetXZ = (_e90.sourceXZ - (_e95 * _e96));
    let _e101: vec2<f32> = targetXZ;
    let _e104: f32 = terrainProjectHeightAt(_e101, (&targetValid));
    targetHeight = _e104;
    let _e106: f32 = targetValid;
    if (_e106 < 0.5f) {
        {
            let _e109: TerrainProjectClipmapVertex = result;
            targetXZ = _e109.sourceXZ;
            let _e111: f32 = sourceHeight;
            targetHeight = _e111;
            result.morph = 0f;
        }
    }
    let _e114: TerrainProjectClipmapVertex = result;
    let _e116: vec2<f32> = targetXZ;
    let _e117: TerrainProjectClipmapVertex = result;
    renderedXZ = mix(_e114.sourceXZ, _e116, vec2(_e117.morph));
    let _e123: vec2<f32> = renderedXZ;
    let _e125: f32 = sourceHeight;
    let _e126: f32 = targetHeight;
    let _e127: TerrainProjectClipmapVertex = result;
    let _e130: vec2<f32> = renderedXZ;
    result.positionWS = vec3<f32>(_e123.x, mix(_e125, _e126, _e127.morph), _e130.y);
    let _e133: TerrainProjectClipmapVertex = result;
    return _e133;
}

fn terrainProjectClipmapGeometryNormal(center: TerrainProjectClipmapVertex) -> vec3<f32> {
    var center_1: TerrainProjectClipmapVertex;
    var valid_2: f32;

    center_1 = center;
    let _e47: TerrainProjectClipmapVertex = center_1;
    let _e52: vec3<f32> = terrainProjectGeometryNormalAt(_e47.positionWS.xz, (&valid_2));
    return _e52;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_1: vec3<f32>;
    var result_1: vec3<f32>;

    sh_1 = sh;
    normal_1 = normal;
    let _e54: vec3<f32> = sh_1[0];
    let _e57: vec3<f32> = sh_1[1];
    let _e58: vec3<f32> = normal_1;
    let _e64: vec3<f32> = sh_1[2];
    let _e65: vec3<f32> = normal_1;
    let _e71: vec3<f32> = sh_1[3];
    let _e72: vec3<f32> = normal_1;
    let _e78: vec3<f32> = sh_1[4];
    let _e79: vec3<f32> = normal_1;
    let _e81: vec3<f32> = normal_1;
    let _e88: vec3<f32> = sh_1[5];
    let _e89: vec3<f32> = normal_1;
    let _e91: vec3<f32> = normal_1;
    let _e98: vec3<f32> = sh_1[6];
    let _e100: vec3<f32> = normal_1;
    let _e103: vec3<f32> = normal_1;
    let _e112: vec3<f32> = sh_1[7];
    let _e113: vec3<f32> = normal_1;
    let _e115: vec3<f32> = normal_1;
    let _e122: vec3<f32> = sh_1[8];
    let _e123: vec3<f32> = normal_1;
    let _e125: vec3<f32> = normal_1;
    let _e128: vec3<f32> = normal_1;
    let _e130: vec3<f32> = normal_1;
    result_1 = ((((((((_e54 + (_e57 * _e58.y)) + (_e64 * _e65.z)) + (_e71 * _e72.x)) + (_e78 * (_e79.y * _e81.x))) + (_e88 * (_e89.y * _e91.z))) + (_e98 * (((3f * _e100.z) * _e103.z) - 1f))) + (_e112 * (_e113.z * _e115.x))) + (_e122 * ((_e123.x * _e125.x) - (_e128.y * _e130.y))));
    let _e137: vec3<f32> = result_1;
    return max(_e137, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS: vec3<f32>) -> vec3<f32> {
    var normalWS_1: vec3<f32>;

    normalWS_1 = normalWS;
    let _e50: EnvMapLight = scene_EnvMapLight;
    return (_e50.diffuse * 3.1415927f);
}

fn sampleVolumetricCloudShadow(positionWS: vec3<f32>) -> f32 {
    var positionWS_1: vec3<f32>;

    positionWS_1 = positionWS;
    return 1f;
}

fn TerrainVertex(attributes: Attributes) -> Varyings {
    var attributes_1: Attributes;
    var varyings: Varyings;
    var clipmapVertex: TerrainProjectClipmapVertex;
    var local_3: f32;
    var zeroVal: f32;

    attributes_1 = attributes;
    let _e51: Attributes = attributes_1;
    let _e53: TerrainProjectClipmapVertex = terrainProjectClipmapVertexAt(_e51.POSITION);
    clipmapVertex = _e53;
    let _e56: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.positionWS = _e56.positionWS;
    let _e59: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.sourceXZ = _e59.sourceXZ;
    let _e62: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.terrainValid = _e62.valid;
    let _e65: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.clipmapMorph = _e65.morph;
    let _e68: TerrainProjectClipmapVertex = clipmapVertex;
    let _e69: vec3<f32> = terrainProjectClipmapGeometryNormal(_e68);
    varyings.normalWS = _e69;
    let _e71: mat4x4<f32> = global_1.camera_VPMat;
    let _e72: Varyings = varyings;
    varyings.positionCS = (_e71 * vec4<f32>(_e72.positionWS.x, _e72.positionWS.y, _e72.positionWS.z, 1f));
    let _e81: TerrainProjectClipmapVertex = clipmapVertex;
    if (_e81.valid < 0.999f) {
        local_3 = 1f;
    } else {
        let _e86: Varyings = varyings;
        let _e88: f32 = sampleVolumetricCloudShadow(_e86.positionWS);
        local_3 = _e88;
    }
    let _e90: f32 = local_3;
    varyings.cloudShadow = _e90;
    let _e91: TerrainProjectClipmapVertex = clipmapVertex;
    if (_e91.valid < 0.999f) {
        {
            let _e95: TerrainProjectClipmapVertex = clipmapVertex;
            zeroVal = (_e95.valid * 0f);
            let _e101: f32 = zeroVal;
            let _e102: f32 = zeroVal;
            gl_Position = vec4((_e101 / _e102));
        }
    } else {
        {
            let _e105: Varyings = varyings;
            gl_Position = _e105.positionCS;
        }
    }
    let _e107: Varyings = varyings;
    return _e107;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e49: Attributes = read_Attributes();
    input_attributes = _e49;
    let _e51: Attributes = input_attributes;
    let _e52: Varyings = TerrainVertex(_e51);
    write_Varyings(_e52);
    return;
}

fn main_1() {
    let _e53: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e59: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e65: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e53.x), bitcast<f32>(_e59.y), bitcast<f32>(_e65.z));
    let _e73: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e73.w);
    let _e80: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e80.x);
    let _e87: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e87.y);
    let _e94: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e94.z);
    let _e101: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e101.w);
    gs_wgpu_main();
    let _e106: vec4<f32> = gl_Position;
    let _e108: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e106.z + _e108.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e64: vec3<f32> = positionWS_2;
    let _e66: vec2<f32> = sourceXZ_4;
    let _e68: vec3<f32> = normalWS_2;
    let _e70: vec4<f32> = positionCS;
    let _e72: f32 = terrainValid;
    let _e74: f32 = clipmapMorph;
    let _e76: f32 = cloudShadow;
    let _e78: vec4<f32> = gl_Position;
    return VertexOutput(_e64, _e66, _e68, _e70, _e72, _e74, _e76, _e78);
}
