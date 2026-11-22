diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_VPMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    renderer_ModelMat: mat4x4<f32>,
    material_TerrainHeightAtlasInvSize: vec2<f32>,
    material_TerrainRegionAtlasRects: array<vec4<f32>, 32>,
    material_TerrainRegionHeightDecode: array<vec4<f32>, 32>,
    material_TerrainVertexSpacing: f32,
    material_TerrainGridOrigin: vec2<f32>,
    renderer_Lod: f32,
    renderer_ClipmapMeshSize: f32,
}

struct gs_Auto_1_ {
    material_TerrainRegionWorldBounds: array<vec4<f32>, 32>,
    material_TerrainRegionCount: i32,
}

struct Attributes {
    POSITION: vec3<f32>,
}

struct TerrainProjectClipmapVertex {
    positionWS: vec3<f32>,
    sourceXZ: vec2<f32>,
    valid: f32,
    morph: f32,
}

struct TerrainDepthShadowVaryings {
    sourceXZ: vec2<f32>,
    sourcePositionWS: vec3<f32>,
    terrainValid: f32,
}

struct VertexOutput {
    @location(0) sourceXZ: vec2<f32>,
    @location(1) sourcePositionWS: vec3<f32>,
    @location(2) terrainValid: f32,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> POSITION_1: vec3<f32>;
@group(2) @binding(2) 
var gs_wgpu_tex_material_TerrainHeightAtlas: texture_2d<f32>;
@group(2) @binding(3) 
var gs_wgpu_samp_material_TerrainHeightAtlas: sampler;
@group(2) @binding(4) 
var gs_wgpu_tex_material_TerrainNormalAtlas: texture_2d<f32>;
@group(2) @binding(5) 
var gs_wgpu_samp_material_TerrainNormalAtlas: sampler;
var<private> sourceXZ_4: vec2<f32>;
var<private> sourcePositionWS_1: vec3<f32>;
var<private> terrainValid: f32;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e27: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e27;
    let _e28: Attributes = interface_value;
    return _e28;
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
        let _e36: i32 = index;
        if !((_e36 < 32i)) {
            break;
        }
        {
            let _e43: i32 = index;
            let _e44: i32 = global_1.material_TerrainRegionCount;
            if (_e43 >= _e44) {
                {
                    break;
                }
            }
            let _e46: i32 = index;
            let _e48: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e46];
            bounds = _e48;
            let _e50: vec4<f32> = bounds;
            minimum = _e50.xy;
            let _e53: vec2<f32> = minimum;
            let _e54: vec4<f32> = bounds;
            maximum = (_e53 + _e54.zw);
            let _e58: vec2<f32> = worldXZ_1;
            let _e59: vec2<f32> = minimum;
            let _e62: vec2<f32> = worldXZ_1;
            let _e63: vec2<f32> = maximum;
            if (all((_e58 >= _e59)) && all((_e62 <= _e63))) {
                {
                    let _e67: vec2<f32> = worldXZ_1;
                    let _e68: vec2<f32> = maximum;
                    if all((_e67 < _e68)) {
                        {
                            let _e71: i32 = index;
                            return _e71;
                        }
                    }
                    let _e72: i32 = inclusiveBoundaryCandidate;
                    let _e75: vec2<f32> = minimum;
                    let _e77: vec2<f32> = candidateMinimum;
                    let _e81: vec2<f32> = minimum;
                    let _e83: vec2<f32> = candidateMinimum;
                    let _e86: vec2<f32> = minimum;
                    let _e88: vec2<f32> = candidateMinimum;
                    if (((_e72 < 0i) || (_e75.x > _e77.x)) || ((_e81.x == _e83.x) && (_e86.y > _e88.y))) {
                        {
                            let _e93: i32 = index;
                            inclusiveBoundaryCandidate = _e93;
                            let _e94: vec2<f32> = minimum;
                            candidateMinimum = _e94;
                        }
                    }
                }
            }
        }
        continuing {
            let _e40: i32 = index;
            index = (_e40 + 1i);
        }
    }
    let _e95: i32 = inclusiveBoundaryCandidate;
    return _e95;
}

fn terrainProjectDecodeR16_(atlasTexel: vec2<f32>) -> f32 {
    var atlasTexel_1: vec2<f32>;
    var bytes: vec2<f32>;

    atlasTexel_1 = atlasTexel;
    let _e31: vec2<f32> = atlasTexel_1;
    let _e35: vec2<f32> = global.material_TerrainHeightAtlasInvSize;
    let _e38: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_TerrainHeightAtlas, gs_wgpu_samp_material_TerrainHeightAtlas, ((_e31 + vec2(0.5f)) * _e35), 0f);
    bytes = (_e38.xy * 255f);
    let _e43: vec2<f32> = bytes;
    let _e45: vec2<f32> = bytes;
    return ((_e43.x + (_e45.y * 256f)) / 65535f);
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
    let _e32: vec2<f32> = worldXZ_3;
    let _e33: i32 = terrainProjectRegionIndex(_e32);
    regionIndex = _e33;
    let _e35: i32 = regionIndex;
    if (_e35 < 0i) {
        {
            (*valid) = 0f;
            return 0f;
        }
    }
    let _e40: i32 = regionIndex;
    let _e42: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e40];
    bounds_1 = _e42;
    let _e44: i32 = regionIndex;
    let _e46: vec4<f32> = global.material_TerrainRegionAtlasRects[_e44];
    atlasRect = _e46;
    let _e48: vec2<f32> = worldXZ_3;
    let _e49: vec4<f32> = bounds_1;
    let _e52: vec4<f32> = bounds_1;
    local = clamp(((_e48 - _e49.xy) / _e52.zw), vec2(0f), vec2(1f));
    let _e61: vec2<f32> = local;
    let _e62: vec4<f32> = atlasRect;
    grid = (_e61 * (_e62.zw - vec2(1f)));
    let _e69: vec2<f32> = grid;
    gridMinimum = floor(_e69);
    let _e72: vec2<f32> = gridMinimum;
    let _e76: vec4<f32> = atlasRect;
    gridMaximum = min((_e72 + vec2(1f)), (_e76.zw - vec2(1f)));
    let _e83: vec2<f32> = grid;
    let _e84: vec2<f32> = gridMinimum;
    blend = (_e83 - _e84);
    let _e87: vec4<f32> = atlasRect;
    let _e89: vec2<f32> = gridMinimum;
    atlasMinimum = (_e87.xy + _e89);
    let _e92: vec4<f32> = atlasRect;
    let _e94: vec2<f32> = gridMaximum;
    atlasMaximum = (_e92.xy + _e94);
    let _e97: vec2<f32> = atlasMinimum;
    let _e98: f32 = terrainProjectDecodeR16_(_e97);
    height00_ = _e98;
    let _e100: vec2<f32> = atlasMaximum;
    let _e102: vec2<f32> = atlasMinimum;
    let _e105: f32 = terrainProjectDecodeR16_(vec2<f32>(_e100.x, _e102.y));
    height10_ = _e105;
    let _e107: vec2<f32> = atlasMinimum;
    let _e109: vec2<f32> = atlasMaximum;
    let _e112: f32 = terrainProjectDecodeR16_(vec2<f32>(_e107.x, _e109.y));
    height01_ = _e112;
    let _e114: vec2<f32> = atlasMaximum;
    let _e115: f32 = terrainProjectDecodeR16_(_e114);
    height11_ = _e115;
    let _e117: f32 = height00_;
    let _e118: f32 = height10_;
    let _e119: vec2<f32> = blend;
    let _e122: f32 = height01_;
    let _e123: f32 = height11_;
    let _e124: vec2<f32> = blend;
    let _e127: vec2<f32> = blend;
    normalizedHeight = mix(mix(_e117, _e118, _e119.x), mix(_e122, _e123, _e124.x), _e127.y);
    let _e131: i32 = regionIndex;
    let _e133: vec2<f32> = global.material_TerrainRegionHeightDecode[_e131].xy;
    decode = _e133;
    (*valid) = 1f;
    let _e136: vec2<f32> = decode;
    let _e138: f32 = normalizedHeight;
    let _e139: vec2<f32> = decode;
    return (_e136.x + (_e138 * _e139.y));
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
    let _e32: vec2<f32> = worldXZ_5;
    let _e33: i32 = terrainProjectRegionIndex(_e32);
    regionIndex_1 = _e33;
    let _e35: i32 = regionIndex_1;
    if (_e35 < 0i) {
        {
            (*valid_1) = 0f;
            return vec3<f32>(0f, 1f, 0f);
        }
    }
    let _e43: i32 = regionIndex_1;
    let _e45: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e43];
    bounds_2 = _e45;
    let _e47: i32 = regionIndex_1;
    let _e49: vec4<f32> = global.material_TerrainRegionAtlasRects[_e47];
    atlasRect_1 = _e49;
    let _e51: vec2<f32> = worldXZ_5;
    let _e52: vec4<f32> = bounds_2;
    let _e55: vec4<f32> = bounds_2;
    local_1 = clamp(((_e51 - _e52.xy) / _e55.zw), vec2(0f), vec2(1f));
    let _e64: vec2<f32> = local_1;
    let _e65: vec4<f32> = atlasRect_1;
    grid_1 = (_e64 * (_e65.zw - vec2(1f)));
    let _e72: vec4<f32> = atlasRect_1;
    let _e74: vec2<f32> = grid_1;
    let _e79: vec2<f32> = global.material_TerrainHeightAtlasInvSize;
    let _e82: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_TerrainNormalAtlas, gs_wgpu_samp_material_TerrainNormalAtlas, (((_e72.xy + _e74) + vec2(0.5f)) * _e79), 0f);
    encodedXZ = ((_e82.xy * 2f) - vec2(1f));
    let _e91: vec2<f32> = encodedXZ;
    let _e92: vec2<f32> = encodedXZ;
    normalY = sqrt(max((1f - dot(_e91, _e92)), 0f));
    (*valid_1) = 1f;
    let _e100: vec2<f32> = encodedXZ;
    let _e102: f32 = normalY;
    let _e103: vec2<f32> = encodedXZ;
    return normalize(vec3<f32>(_e100.x, _e102, _e103.y));
}

fn terrainProjectClipmapMorphFactor(sourceXZ: vec2<f32>) -> f32 {
    var sourceXZ_1: vec2<f32>;
    var levelSpacing: f32;
    var distanceInLevelVertices: vec2<f32>;
    var outerDistance: f32;
    var transition: f32;

    sourceXZ_1 = sourceXZ;
    let _e31: f32 = global.material_TerrainVertexSpacing;
    let _e32: f32 = global.renderer_Lod;
    levelSpacing = (_e31 * exp2(_e32));
    let _e36: vec2<f32> = sourceXZ_1;
    let _e37: vec3<f32> = global.camera_Position;
    let _e41: f32 = levelSpacing;
    distanceInLevelVertices = (abs((_e36 - _e37.xz)) / vec2(_e41));
    let _e45: vec2<f32> = distanceInLevelVertices;
    let _e47: vec2<f32> = distanceInLevelVertices;
    outerDistance = max(_e45.x, _e47.y);
    let _e51: f32 = outerDistance;
    let _e52: f32 = global.renderer_ClipmapMeshSize;
    let _e56: f32 = global.renderer_ClipmapMeshSize;
    transition = (((_e51 - _e52) - 4f) / (_e56 - 4f));
    let _e63: f32 = transition;
    return smoothstep(0f, 1f, _e63);
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
    let _e33: f32 = global.material_TerrainVertexSpacing;
    let _e34: f32 = global.renderer_Lod;
    levelSpacing_1 = (_e33 * exp2(_e34));
    let _e38: vec2<f32> = sourceXZ_3;
    let _e39: vec2<f32> = global.material_TerrainGridOrigin;
    let _e41: f32 = levelSpacing_1;
    levelGrid = ((_e38 - _e39) / vec2(_e41));
    let _e45: vec3<f32> = positionOS_1;
    vertexParity = (fract((_e45.xz * 0.5f)) * 2f);
    let _e53: f32 = global.renderer_Lod;
    if (_e53 < 0.5f) {
        {
            let _e56: vec2<f32> = levelGrid;
            let _e64: vec2<f32> = levelGrid;
            diagonalParity = round(fract(((round((_e56.y - (floor((_e56.y / 4f)) * 4f))) * round((_e64.x - (floor((_e64.x / 4f)) * 4f)))) * 0.25f)));
            let _e78: vec2<f32> = vertexParity;
            let _e79: vec2<f32> = vertexParity;
            let _e81: vec2<f32> = vertexParity;
            let _e85: f32 = diagonalParity;
            return mix(_e78, vec2<f32>(_e79.x, -(_e81.y)), vec2(_e85));
        }
    }
    let _e88: vec2<f32> = vertexParity;
    let _e89: vec2<f32> = levelGrid;
    return (_e88 * round(((fract((_e89 * 0.25f)) - vec2(0.5f)) * 4f)));
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
    let _e32: mat4x4<f32> = global.renderer_ModelMat;
    let _e33: vec3<f32> = positionOS_3;
    homogeneousPositionWS = (_e32 * vec4<f32>(_e33.x, _e33.y, _e33.z, 1f));
    let _e41: vec4<f32> = homogeneousPositionWS;
    let _e43: vec4<f32> = homogeneousPositionWS;
    sourcePositionWS = (_e41.xyz / vec3(_e43.w));
    let _e49: vec3<f32> = sourcePositionWS;
    result.sourceXZ = _e49.xz;
    let _e51: TerrainProjectClipmapVertex = result;
    let _e53: TerrainProjectClipmapVertex = result;
    var gs_output_arg0 = result.valid;
    let _e57: f32 = terrainProjectHeightAt(_e51.sourceXZ, (&gs_output_arg0));
    result.valid = gs_output_arg0;
    sourceHeight = _e57;
    let _e60: TerrainProjectClipmapVertex = result;
    if (_e60.valid < 0.5f) {
        local_2 = 0f;
    } else {
        let _e65: TerrainProjectClipmapVertex = result;
        let _e67: f32 = terrainProjectClipmapMorphFactor(_e65.sourceXZ);
        local_2 = _e67;
    }
    let _e69: f32 = local_2;
    result.morph = _e69;
    let _e70: f32 = global.material_TerrainVertexSpacing;
    let _e71: f32 = global.renderer_Lod;
    levelSpacing_2 = (_e70 * exp2(_e71));
    let _e75: TerrainProjectClipmapVertex = result;
    let _e77: vec3<f32> = positionOS_3;
    let _e78: TerrainProjectClipmapVertex = result;
    let _e80: vec2<f32> = terrainProjectClipmapVertexShift(_e77, _e78.sourceXZ);
    let _e81: f32 = levelSpacing_2;
    targetXZ = (_e75.sourceXZ - (_e80 * _e81));
    let _e86: vec2<f32> = targetXZ;
    let _e89: f32 = terrainProjectHeightAt(_e86, (&targetValid));
    targetHeight = _e89;
    let _e91: f32 = targetValid;
    if (_e91 < 0.5f) {
        {
            let _e94: TerrainProjectClipmapVertex = result;
            targetXZ = _e94.sourceXZ;
            let _e96: f32 = sourceHeight;
            targetHeight = _e96;
            result.morph = 0f;
        }
    }
    let _e99: TerrainProjectClipmapVertex = result;
    let _e101: vec2<f32> = targetXZ;
    let _e102: TerrainProjectClipmapVertex = result;
    renderedXZ = mix(_e99.sourceXZ, _e101, vec2(_e102.morph));
    let _e108: vec2<f32> = renderedXZ;
    let _e110: f32 = sourceHeight;
    let _e111: f32 = targetHeight;
    let _e112: TerrainProjectClipmapVertex = result;
    let _e115: vec2<f32> = renderedXZ;
    result.positionWS = vec3<f32>(_e108.x, mix(_e110, _e111, _e112.morph), _e115.y);
    let _e118: TerrainProjectClipmapVertex = result;
    return _e118;
}

fn terrainProjectClipmapGeometryNormal(center: TerrainProjectClipmapVertex) -> vec3<f32> {
    var center_1: TerrainProjectClipmapVertex;
    var valid_2: f32;

    center_1 = center;
    let _e32: TerrainProjectClipmapVertex = center_1;
    let _e37: vec3<f32> = terrainProjectGeometryNormalAt(_e32.positionWS.xz, (&valid_2));
    return _e37;
}

fn write_TerrainDepthShadowVaryings(interface_value_1: TerrainDepthShadowVaryings) {
    var interface_value_2: TerrainDepthShadowVaryings;

    interface_value_2 = interface_value_1;
    let _e34: TerrainDepthShadowVaryings = interface_value_2;
    sourceXZ_4 = _e34.sourceXZ;
    let _e36: TerrainDepthShadowVaryings = interface_value_2;
    sourcePositionWS_1 = _e36.sourcePositionWS;
    let _e38: TerrainDepthShadowVaryings = interface_value_2;
    terrainValid = _e38.terrainValid;
    return;
}

fn terrainProjectBuildDepthShadowVaryings(attributes: Attributes) -> TerrainDepthShadowVaryings {
    var attributes_1: Attributes;
    var varyings: TerrainDepthShadowVaryings;
    var clipmapVertex: TerrainProjectClipmapVertex;
    var positionWS: vec3<f32>;

    attributes_1 = attributes;
    let _e35: Attributes = attributes_1;
    let _e37: TerrainProjectClipmapVertex = terrainProjectClipmapVertexAt(_e35.POSITION);
    clipmapVertex = _e37;
    let _e40: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.sourceXZ = _e40.sourceXZ;
    let _e43: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.sourcePositionWS = _e43.positionWS;
    let _e46: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.terrainValid = _e46.valid;
    let _e48: TerrainProjectClipmapVertex = clipmapVertex;
    positionWS = _e48.positionWS;
    let _e52: mat4x4<f32> = global.camera_VPMat;
    let _e53: vec3<f32> = positionWS;
    gl_Position = (_e52 * vec4<f32>(_e53.x, _e53.y, _e53.z, 1f));
    let _e60: TerrainDepthShadowVaryings = varyings;
    return _e60;
}

fn TerrainDepthOnlyVertex(attributes_2: Attributes) -> TerrainDepthShadowVaryings {
    var attributes_3: Attributes;

    attributes_3 = attributes_2;
    let _e35: Attributes = attributes_3;
    let _e36: TerrainDepthShadowVaryings = terrainProjectBuildDepthShadowVaryings(_e35);
    return _e36;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e33: Attributes = read_Attributes();
    input_attributes = _e33;
    let _e35: Attributes = input_attributes;
    let _e36: TerrainDepthShadowVaryings = TerrainDepthOnlyVertex(_e35);
    write_TerrainDepthShadowVaryings(_e36);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e35: vec4<f32> = gl_Position;
    let _e37: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e35.z + _e37.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e43: vec2<f32> = sourceXZ_4;
    let _e45: vec3<f32> = sourcePositionWS_1;
    let _e47: f32 = terrainValid;
    let _e49: vec4<f32> = gl_Position;
    return VertexOutput(_e43, _e45, _e47, _e49);
}
