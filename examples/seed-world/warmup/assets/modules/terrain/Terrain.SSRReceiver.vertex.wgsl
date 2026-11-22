diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    material_TerrainRegionHeightDecode: array<vec4<f32>, 32>,
    material_TerrainVertexSpacing: f32,
    material_TerrainGridOrigin: vec2<f32>,
    renderer_ClipmapMeshSize: f32,
}

struct gs_Auto_1_ {
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
}

struct TerrainProjectClipmapVertex {
    positionWS: vec3<f32>,
    sourceXZ: vec2<f32>,
    valid: f32,
    morph: f32,
}

struct VertexOutput {
    @location(0) positionWS: vec3<f32>,
    @location(1) sourceXZ: vec2<f32>,
    @location(2) normalWS: vec3<f32>,
    @location(3) positionCS: vec4<f32>,
    @location(4) terrainValid: f32,
    @location(5) clipmapMorph: f32,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> POSITION_1: vec3<f32>;
var<private> positionWS: vec3<f32>;
var<private> sourceXZ_4: vec2<f32>;
var<private> normalWS: vec3<f32>;
var<private> positionCS: vec4<f32>;
var<private> terrainValid: f32;
var<private> clipmapMorph: f32;
@group(2) @binding(2) 
var gs_wgpu_tex_material_TerrainHeightAtlas: texture_2d<f32>;
@group(2) @binding(3) 
var gs_wgpu_samp_material_TerrainHeightAtlas: sampler;
@group(2) @binding(4) 
var gs_wgpu_tex_material_TerrainNormalAtlas: texture_2d<f32>;
@group(2) @binding(5) 
var gs_wgpu_samp_material_TerrainNormalAtlas: sampler;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e33: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e33;
    let _e34: Attributes = interface_value;
    return _e34;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e39: Varyings = interface_value_2;
    positionWS = _e39.positionWS;
    let _e41: Varyings = interface_value_2;
    sourceXZ_4 = _e41.sourceXZ;
    let _e43: Varyings = interface_value_2;
    normalWS = _e43.normalWS;
    let _e45: Varyings = interface_value_2;
    positionCS = _e45.positionCS;
    let _e47: Varyings = interface_value_2;
    terrainValid = _e47.terrainValid;
    let _e49: Varyings = interface_value_2;
    clipmapMorph = _e49.clipmapMorph;
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
        let _e48: i32 = index;
        if !((_e48 < 32i)) {
            break;
        }
        {
            let _e55: i32 = index;
            let _e56: i32 = global_1.material_TerrainRegionCount;
            if (_e55 >= _e56) {
                {
                    break;
                }
            }
            let _e58: i32 = index;
            let _e60: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e58];
            bounds = _e60;
            let _e62: vec4<f32> = bounds;
            minimum = _e62.xy;
            let _e65: vec2<f32> = minimum;
            let _e66: vec4<f32> = bounds;
            maximum = (_e65 + _e66.zw);
            let _e70: vec2<f32> = worldXZ_1;
            let _e71: vec2<f32> = minimum;
            let _e74: vec2<f32> = worldXZ_1;
            let _e75: vec2<f32> = maximum;
            if (all((_e70 >= _e71)) && all((_e74 <= _e75))) {
                {
                    let _e79: vec2<f32> = worldXZ_1;
                    let _e80: vec2<f32> = maximum;
                    if all((_e79 < _e80)) {
                        {
                            let _e83: i32 = index;
                            return _e83;
                        }
                    }
                    let _e84: i32 = inclusiveBoundaryCandidate;
                    let _e87: vec2<f32> = minimum;
                    let _e89: vec2<f32> = candidateMinimum;
                    let _e93: vec2<f32> = minimum;
                    let _e95: vec2<f32> = candidateMinimum;
                    let _e98: vec2<f32> = minimum;
                    let _e100: vec2<f32> = candidateMinimum;
                    if (((_e84 < 0i) || (_e87.x > _e89.x)) || ((_e93.x == _e95.x) && (_e98.y > _e100.y))) {
                        {
                            let _e105: i32 = index;
                            inclusiveBoundaryCandidate = _e105;
                            let _e106: vec2<f32> = minimum;
                            candidateMinimum = _e106;
                        }
                    }
                }
            }
        }
        continuing {
            let _e52: i32 = index;
            index = (_e52 + 1i);
        }
    }
    let _e107: i32 = inclusiveBoundaryCandidate;
    return _e107;
}

fn terrainProjectDecodeR16_(atlasTexel: vec2<f32>) -> f32 {
    var atlasTexel_1: vec2<f32>;
    var bytes: vec2<f32>;

    atlasTexel_1 = atlasTexel;
    let _e43: vec2<f32> = atlasTexel_1;
    let _e47: vec2<f32> = global_1.material_TerrainHeightAtlasInvSize;
    let _e50: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_TerrainHeightAtlas, gs_wgpu_samp_material_TerrainHeightAtlas, ((_e43 + vec2(0.5f)) * _e47), 0f);
    bytes = (_e50.xy * 255f);
    let _e55: vec2<f32> = bytes;
    let _e57: vec2<f32> = bytes;
    return ((_e55.x + (_e57.y * 256f)) / 65535f);
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
    let _e44: vec2<f32> = worldXZ_3;
    let _e45: i32 = terrainProjectRegionIndex(_e44);
    regionIndex = _e45;
    let _e47: i32 = regionIndex;
    if (_e47 < 0i) {
        {
            (*valid) = 0f;
            return 0f;
        }
    }
    let _e52: i32 = regionIndex;
    let _e54: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e52];
    bounds_1 = _e54;
    let _e56: i32 = regionIndex;
    let _e58: vec4<f32> = global_1.material_TerrainRegionAtlasRects[_e56];
    atlasRect = _e58;
    let _e60: vec2<f32> = worldXZ_3;
    let _e61: vec4<f32> = bounds_1;
    let _e64: vec4<f32> = bounds_1;
    local = clamp(((_e60 - _e61.xy) / _e64.zw), vec2(0f), vec2(1f));
    let _e73: vec2<f32> = local;
    let _e74: vec4<f32> = atlasRect;
    grid = (_e73 * (_e74.zw - vec2(1f)));
    let _e81: vec2<f32> = grid;
    gridMinimum = floor(_e81);
    let _e84: vec2<f32> = gridMinimum;
    let _e88: vec4<f32> = atlasRect;
    gridMaximum = min((_e84 + vec2(1f)), (_e88.zw - vec2(1f)));
    let _e95: vec2<f32> = grid;
    let _e96: vec2<f32> = gridMinimum;
    blend = (_e95 - _e96);
    let _e99: vec4<f32> = atlasRect;
    let _e101: vec2<f32> = gridMinimum;
    atlasMinimum = (_e99.xy + _e101);
    let _e104: vec4<f32> = atlasRect;
    let _e106: vec2<f32> = gridMaximum;
    atlasMaximum = (_e104.xy + _e106);
    let _e109: vec2<f32> = atlasMinimum;
    let _e110: f32 = terrainProjectDecodeR16_(_e109);
    height00_ = _e110;
    let _e112: vec2<f32> = atlasMaximum;
    let _e114: vec2<f32> = atlasMinimum;
    let _e117: f32 = terrainProjectDecodeR16_(vec2<f32>(_e112.x, _e114.y));
    height10_ = _e117;
    let _e119: vec2<f32> = atlasMinimum;
    let _e121: vec2<f32> = atlasMaximum;
    let _e124: f32 = terrainProjectDecodeR16_(vec2<f32>(_e119.x, _e121.y));
    height01_ = _e124;
    let _e126: vec2<f32> = atlasMaximum;
    let _e127: f32 = terrainProjectDecodeR16_(_e126);
    height11_ = _e127;
    let _e129: f32 = height00_;
    let _e130: f32 = height10_;
    let _e131: vec2<f32> = blend;
    let _e134: f32 = height01_;
    let _e135: f32 = height11_;
    let _e136: vec2<f32> = blend;
    let _e139: vec2<f32> = blend;
    normalizedHeight = mix(mix(_e129, _e130, _e131.x), mix(_e134, _e135, _e136.x), _e139.y);
    let _e143: i32 = regionIndex;
    let _e145: vec2<f32> = global.material_TerrainRegionHeightDecode[_e143].xy;
    decode = _e145;
    (*valid) = 1f;
    let _e148: vec2<f32> = decode;
    let _e150: f32 = normalizedHeight;
    let _e151: vec2<f32> = decode;
    return (_e148.x + (_e150 * _e151.y));
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
    let _e44: vec2<f32> = worldXZ_5;
    let _e45: i32 = terrainProjectRegionIndex(_e44);
    regionIndex_1 = _e45;
    let _e47: i32 = regionIndex_1;
    if (_e47 < 0i) {
        {
            (*valid_1) = 0f;
            return vec3<f32>(0f, 1f, 0f);
        }
    }
    let _e55: i32 = regionIndex_1;
    let _e57: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e55];
    bounds_2 = _e57;
    let _e59: i32 = regionIndex_1;
    let _e61: vec4<f32> = global_1.material_TerrainRegionAtlasRects[_e59];
    atlasRect_1 = _e61;
    let _e63: vec2<f32> = worldXZ_5;
    let _e64: vec4<f32> = bounds_2;
    let _e67: vec4<f32> = bounds_2;
    local_1 = clamp(((_e63 - _e64.xy) / _e67.zw), vec2(0f), vec2(1f));
    let _e76: vec2<f32> = local_1;
    let _e77: vec4<f32> = atlasRect_1;
    grid_1 = (_e76 * (_e77.zw - vec2(1f)));
    let _e84: vec4<f32> = atlasRect_1;
    let _e86: vec2<f32> = grid_1;
    let _e91: vec2<f32> = global_1.material_TerrainHeightAtlasInvSize;
    let _e94: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_TerrainNormalAtlas, gs_wgpu_samp_material_TerrainNormalAtlas, (((_e84.xy + _e86) + vec2(0.5f)) * _e91), 0f);
    encodedXZ = ((_e94.xy * 2f) - vec2(1f));
    let _e103: vec2<f32> = encodedXZ;
    let _e104: vec2<f32> = encodedXZ;
    normalY = sqrt(max((1f - dot(_e103, _e104)), 0f));
    (*valid_1) = 1f;
    let _e112: vec2<f32> = encodedXZ;
    let _e114: f32 = normalY;
    let _e115: vec2<f32> = encodedXZ;
    return normalize(vec3<f32>(_e112.x, _e114, _e115.y));
}

fn terrainProjectClipmapMorphFactor(sourceXZ: vec2<f32>) -> f32 {
    var sourceXZ_1: vec2<f32>;
    var levelSpacing: f32;
    var distanceInLevelVertices: vec2<f32>;
    var outerDistance: f32;
    var transition: f32;

    sourceXZ_1 = sourceXZ;
    let _e43: f32 = global.material_TerrainVertexSpacing;
    let _e44: f32 = global_1.renderer_Lod;
    levelSpacing = (_e43 * exp2(_e44));
    let _e48: vec2<f32> = sourceXZ_1;
    let _e49: vec3<f32> = global_1.camera_Position;
    let _e53: f32 = levelSpacing;
    distanceInLevelVertices = (abs((_e48 - _e49.xz)) / vec2(_e53));
    let _e57: vec2<f32> = distanceInLevelVertices;
    let _e59: vec2<f32> = distanceInLevelVertices;
    outerDistance = max(_e57.x, _e59.y);
    let _e63: f32 = outerDistance;
    let _e64: f32 = global.renderer_ClipmapMeshSize;
    let _e68: f32 = global.renderer_ClipmapMeshSize;
    transition = (((_e63 - _e64) - 4f) / (_e68 - 4f));
    let _e75: f32 = transition;
    return smoothstep(0f, 1f, _e75);
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
    let _e45: f32 = global.material_TerrainVertexSpacing;
    let _e46: f32 = global_1.renderer_Lod;
    levelSpacing_1 = (_e45 * exp2(_e46));
    let _e50: vec2<f32> = sourceXZ_3;
    let _e51: vec2<f32> = global.material_TerrainGridOrigin;
    let _e53: f32 = levelSpacing_1;
    levelGrid = ((_e50 - _e51) / vec2(_e53));
    let _e57: vec3<f32> = positionOS_1;
    vertexParity = (fract((_e57.xz * 0.5f)) * 2f);
    let _e65: f32 = global_1.renderer_Lod;
    if (_e65 < 0.5f) {
        {
            let _e68: vec2<f32> = levelGrid;
            let _e76: vec2<f32> = levelGrid;
            diagonalParity = round(fract(((round((_e68.y - (floor((_e68.y / 4f)) * 4f))) * round((_e76.x - (floor((_e76.x / 4f)) * 4f)))) * 0.25f)));
            let _e90: vec2<f32> = vertexParity;
            let _e91: vec2<f32> = vertexParity;
            let _e93: vec2<f32> = vertexParity;
            let _e97: f32 = diagonalParity;
            return mix(_e90, vec2<f32>(_e91.x, -(_e93.y)), vec2(_e97));
        }
    }
    let _e100: vec2<f32> = vertexParity;
    let _e101: vec2<f32> = levelGrid;
    return (_e100 * round(((fract((_e101 * 0.25f)) - vec2(0.5f)) * 4f)));
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
    let _e44: mat4x4<f32> = global.renderer_ModelMat;
    let _e45: vec3<f32> = positionOS_3;
    homogeneousPositionWS = (_e44 * vec4<f32>(_e45.x, _e45.y, _e45.z, 1f));
    let _e53: vec4<f32> = homogeneousPositionWS;
    let _e55: vec4<f32> = homogeneousPositionWS;
    sourcePositionWS = (_e53.xyz / vec3(_e55.w));
    let _e61: vec3<f32> = sourcePositionWS;
    result.sourceXZ = _e61.xz;
    let _e63: TerrainProjectClipmapVertex = result;
    let _e65: TerrainProjectClipmapVertex = result;
    var gs_output_arg0 = result.valid;
    let _e69: f32 = terrainProjectHeightAt(_e63.sourceXZ, (&gs_output_arg0));
    result.valid = gs_output_arg0;
    sourceHeight = _e69;
    let _e72: TerrainProjectClipmapVertex = result;
    if (_e72.valid < 0.5f) {
        local_2 = 0f;
    } else {
        let _e77: TerrainProjectClipmapVertex = result;
        let _e79: f32 = terrainProjectClipmapMorphFactor(_e77.sourceXZ);
        local_2 = _e79;
    }
    let _e81: f32 = local_2;
    result.morph = _e81;
    let _e82: f32 = global.material_TerrainVertexSpacing;
    let _e83: f32 = global_1.renderer_Lod;
    levelSpacing_2 = (_e82 * exp2(_e83));
    let _e87: TerrainProjectClipmapVertex = result;
    let _e89: vec3<f32> = positionOS_3;
    let _e90: TerrainProjectClipmapVertex = result;
    let _e92: vec2<f32> = terrainProjectClipmapVertexShift(_e89, _e90.sourceXZ);
    let _e93: f32 = levelSpacing_2;
    targetXZ = (_e87.sourceXZ - (_e92 * _e93));
    let _e98: vec2<f32> = targetXZ;
    let _e101: f32 = terrainProjectHeightAt(_e98, (&targetValid));
    targetHeight = _e101;
    let _e103: f32 = targetValid;
    if (_e103 < 0.5f) {
        {
            let _e106: TerrainProjectClipmapVertex = result;
            targetXZ = _e106.sourceXZ;
            let _e108: f32 = sourceHeight;
            targetHeight = _e108;
            result.morph = 0f;
        }
    }
    let _e111: TerrainProjectClipmapVertex = result;
    let _e113: vec2<f32> = targetXZ;
    let _e114: TerrainProjectClipmapVertex = result;
    renderedXZ = mix(_e111.sourceXZ, _e113, vec2(_e114.morph));
    let _e120: vec2<f32> = renderedXZ;
    let _e122: f32 = sourceHeight;
    let _e123: f32 = targetHeight;
    let _e124: TerrainProjectClipmapVertex = result;
    let _e127: vec2<f32> = renderedXZ;
    result.positionWS = vec3<f32>(_e120.x, mix(_e122, _e123, _e124.morph), _e127.y);
    let _e130: TerrainProjectClipmapVertex = result;
    return _e130;
}

fn terrainProjectClipmapGeometryNormal(center: TerrainProjectClipmapVertex) -> vec3<f32> {
    var center_1: TerrainProjectClipmapVertex;
    var valid_2: f32;

    center_1 = center;
    let _e44: TerrainProjectClipmapVertex = center_1;
    let _e49: vec3<f32> = terrainProjectGeometryNormalAt(_e44.positionWS.xz, (&valid_2));
    return _e49;
}

fn TerrainSSRReceiverVertex(attributes: Attributes) -> Varyings {
    var attributes_1: Attributes;
    var varyings: Varyings;
    var clipmapVertex: TerrainProjectClipmapVertex;

    attributes_1 = attributes;
    let _e44: Attributes = attributes_1;
    let _e46: TerrainProjectClipmapVertex = terrainProjectClipmapVertexAt(_e44.POSITION);
    clipmapVertex = _e46;
    let _e49: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.positionWS = _e49.positionWS;
    let _e52: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.sourceXZ = _e52.sourceXZ;
    let _e55: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.terrainValid = _e55.valid;
    let _e58: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.clipmapMorph = _e58.morph;
    let _e61: TerrainProjectClipmapVertex = clipmapVertex;
    let _e62: vec3<f32> = terrainProjectClipmapGeometryNormal(_e61);
    varyings.normalWS = _e62;
    let _e64: mat4x4<f32> = global.camera_VPMat;
    let _e65: Varyings = varyings;
    varyings.positionCS = (_e64 * vec4<f32>(_e65.positionWS.x, _e65.positionWS.y, _e65.positionWS.z, 1f));
    let _e74: Varyings = varyings;
    gl_Position = _e74.positionCS;
    let _e76: Varyings = varyings;
    return _e76;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e42: Attributes = read_Attributes();
    input_attributes = _e42;
    let _e44: Attributes = input_attributes;
    let _e45: Varyings = TerrainSSRReceiverVertex(_e44);
    write_Varyings(_e45);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e44: vec4<f32> = gl_Position;
    let _e46: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e44.z + _e46.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e55: vec3<f32> = positionWS;
    let _e57: vec2<f32> = sourceXZ_4;
    let _e59: vec3<f32> = normalWS;
    let _e61: vec4<f32> = positionCS;
    let _e63: f32 = terrainValid;
    let _e65: f32 = clipmapMorph;
    let _e67: vec4<f32> = gl_Position;
    return VertexOutput(_e55, _e57, _e59, _e61, _e63, _e65, _e67);
}
