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
    scene_ShadowBias: vec2<f32>,
    scene_LightDirection: vec3<f32>,
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

    let _e31: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e31;
    let _e32: Attributes = interface_value;
    return _e32;
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
        let _e40: i32 = index;
        if !((_e40 < 32i)) {
            break;
        }
        {
            let _e47: i32 = index;
            let _e48: i32 = global_1.material_TerrainRegionCount;
            if (_e47 >= _e48) {
                {
                    break;
                }
            }
            let _e50: i32 = index;
            let _e52: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e50];
            bounds = _e52;
            let _e54: vec4<f32> = bounds;
            minimum = _e54.xy;
            let _e57: vec2<f32> = minimum;
            let _e58: vec4<f32> = bounds;
            maximum = (_e57 + _e58.zw);
            let _e62: vec2<f32> = worldXZ_1;
            let _e63: vec2<f32> = minimum;
            let _e66: vec2<f32> = worldXZ_1;
            let _e67: vec2<f32> = maximum;
            if (all((_e62 >= _e63)) && all((_e66 <= _e67))) {
                {
                    let _e71: vec2<f32> = worldXZ_1;
                    let _e72: vec2<f32> = maximum;
                    if all((_e71 < _e72)) {
                        {
                            let _e75: i32 = index;
                            return _e75;
                        }
                    }
                    let _e76: i32 = inclusiveBoundaryCandidate;
                    let _e79: vec2<f32> = minimum;
                    let _e81: vec2<f32> = candidateMinimum;
                    let _e85: vec2<f32> = minimum;
                    let _e87: vec2<f32> = candidateMinimum;
                    let _e90: vec2<f32> = minimum;
                    let _e92: vec2<f32> = candidateMinimum;
                    if (((_e76 < 0i) || (_e79.x > _e81.x)) || ((_e85.x == _e87.x) && (_e90.y > _e92.y))) {
                        {
                            let _e97: i32 = index;
                            inclusiveBoundaryCandidate = _e97;
                            let _e98: vec2<f32> = minimum;
                            candidateMinimum = _e98;
                        }
                    }
                }
            }
        }
        continuing {
            let _e44: i32 = index;
            index = (_e44 + 1i);
        }
    }
    let _e99: i32 = inclusiveBoundaryCandidate;
    return _e99;
}

fn terrainProjectDecodeR16_(atlasTexel: vec2<f32>) -> f32 {
    var atlasTexel_1: vec2<f32>;
    var bytes: vec2<f32>;

    atlasTexel_1 = atlasTexel;
    let _e35: vec2<f32> = atlasTexel_1;
    let _e39: vec2<f32> = global.material_TerrainHeightAtlasInvSize;
    let _e42: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_TerrainHeightAtlas, gs_wgpu_samp_material_TerrainHeightAtlas, ((_e35 + vec2(0.5f)) * _e39), 0f);
    bytes = (_e42.xy * 255f);
    let _e47: vec2<f32> = bytes;
    let _e49: vec2<f32> = bytes;
    return ((_e47.x + (_e49.y * 256f)) / 65535f);
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
    let _e36: vec2<f32> = worldXZ_3;
    let _e37: i32 = terrainProjectRegionIndex(_e36);
    regionIndex = _e37;
    let _e39: i32 = regionIndex;
    if (_e39 < 0i) {
        {
            (*valid) = 0f;
            return 0f;
        }
    }
    let _e44: i32 = regionIndex;
    let _e46: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e44];
    bounds_1 = _e46;
    let _e48: i32 = regionIndex;
    let _e50: vec4<f32> = global.material_TerrainRegionAtlasRects[_e48];
    atlasRect = _e50;
    let _e52: vec2<f32> = worldXZ_3;
    let _e53: vec4<f32> = bounds_1;
    let _e56: vec4<f32> = bounds_1;
    local = clamp(((_e52 - _e53.xy) / _e56.zw), vec2(0f), vec2(1f));
    let _e65: vec2<f32> = local;
    let _e66: vec4<f32> = atlasRect;
    grid = (_e65 * (_e66.zw - vec2(1f)));
    let _e73: vec2<f32> = grid;
    gridMinimum = floor(_e73);
    let _e76: vec2<f32> = gridMinimum;
    let _e80: vec4<f32> = atlasRect;
    gridMaximum = min((_e76 + vec2(1f)), (_e80.zw - vec2(1f)));
    let _e87: vec2<f32> = grid;
    let _e88: vec2<f32> = gridMinimum;
    blend = (_e87 - _e88);
    let _e91: vec4<f32> = atlasRect;
    let _e93: vec2<f32> = gridMinimum;
    atlasMinimum = (_e91.xy + _e93);
    let _e96: vec4<f32> = atlasRect;
    let _e98: vec2<f32> = gridMaximum;
    atlasMaximum = (_e96.xy + _e98);
    let _e101: vec2<f32> = atlasMinimum;
    let _e102: f32 = terrainProjectDecodeR16_(_e101);
    height00_ = _e102;
    let _e104: vec2<f32> = atlasMaximum;
    let _e106: vec2<f32> = atlasMinimum;
    let _e109: f32 = terrainProjectDecodeR16_(vec2<f32>(_e104.x, _e106.y));
    height10_ = _e109;
    let _e111: vec2<f32> = atlasMinimum;
    let _e113: vec2<f32> = atlasMaximum;
    let _e116: f32 = terrainProjectDecodeR16_(vec2<f32>(_e111.x, _e113.y));
    height01_ = _e116;
    let _e118: vec2<f32> = atlasMaximum;
    let _e119: f32 = terrainProjectDecodeR16_(_e118);
    height11_ = _e119;
    let _e121: f32 = height00_;
    let _e122: f32 = height10_;
    let _e123: vec2<f32> = blend;
    let _e126: f32 = height01_;
    let _e127: f32 = height11_;
    let _e128: vec2<f32> = blend;
    let _e131: vec2<f32> = blend;
    normalizedHeight = mix(mix(_e121, _e122, _e123.x), mix(_e126, _e127, _e128.x), _e131.y);
    let _e135: i32 = regionIndex;
    let _e137: vec2<f32> = global.material_TerrainRegionHeightDecode[_e135].xy;
    decode = _e137;
    (*valid) = 1f;
    let _e140: vec2<f32> = decode;
    let _e142: f32 = normalizedHeight;
    let _e143: vec2<f32> = decode;
    return (_e140.x + (_e142 * _e143.y));
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
    let _e36: vec2<f32> = worldXZ_5;
    let _e37: i32 = terrainProjectRegionIndex(_e36);
    regionIndex_1 = _e37;
    let _e39: i32 = regionIndex_1;
    if (_e39 < 0i) {
        {
            (*valid_1) = 0f;
            return vec3<f32>(0f, 1f, 0f);
        }
    }
    let _e47: i32 = regionIndex_1;
    let _e49: vec4<f32> = global_1.material_TerrainRegionWorldBounds[_e47];
    bounds_2 = _e49;
    let _e51: i32 = regionIndex_1;
    let _e53: vec4<f32> = global.material_TerrainRegionAtlasRects[_e51];
    atlasRect_1 = _e53;
    let _e55: vec2<f32> = worldXZ_5;
    let _e56: vec4<f32> = bounds_2;
    let _e59: vec4<f32> = bounds_2;
    local_1 = clamp(((_e55 - _e56.xy) / _e59.zw), vec2(0f), vec2(1f));
    let _e68: vec2<f32> = local_1;
    let _e69: vec4<f32> = atlasRect_1;
    grid_1 = (_e68 * (_e69.zw - vec2(1f)));
    let _e76: vec4<f32> = atlasRect_1;
    let _e78: vec2<f32> = grid_1;
    let _e83: vec2<f32> = global.material_TerrainHeightAtlasInvSize;
    let _e86: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_TerrainNormalAtlas, gs_wgpu_samp_material_TerrainNormalAtlas, (((_e76.xy + _e78) + vec2(0.5f)) * _e83), 0f);
    encodedXZ = ((_e86.xy * 2f) - vec2(1f));
    let _e95: vec2<f32> = encodedXZ;
    let _e96: vec2<f32> = encodedXZ;
    normalY = sqrt(max((1f - dot(_e95, _e96)), 0f));
    (*valid_1) = 1f;
    let _e104: vec2<f32> = encodedXZ;
    let _e106: f32 = normalY;
    let _e107: vec2<f32> = encodedXZ;
    return normalize(vec3<f32>(_e104.x, _e106, _e107.y));
}

fn terrainProjectClipmapMorphFactor(sourceXZ: vec2<f32>) -> f32 {
    var sourceXZ_1: vec2<f32>;
    var levelSpacing: f32;
    var distanceInLevelVertices: vec2<f32>;
    var outerDistance: f32;
    var transition: f32;

    sourceXZ_1 = sourceXZ;
    let _e35: f32 = global.material_TerrainVertexSpacing;
    let _e36: f32 = global.renderer_Lod;
    levelSpacing = (_e35 * exp2(_e36));
    let _e40: vec2<f32> = sourceXZ_1;
    let _e41: vec3<f32> = global.camera_Position;
    let _e45: f32 = levelSpacing;
    distanceInLevelVertices = (abs((_e40 - _e41.xz)) / vec2(_e45));
    let _e49: vec2<f32> = distanceInLevelVertices;
    let _e51: vec2<f32> = distanceInLevelVertices;
    outerDistance = max(_e49.x, _e51.y);
    let _e55: f32 = outerDistance;
    let _e56: f32 = global.renderer_ClipmapMeshSize;
    let _e60: f32 = global.renderer_ClipmapMeshSize;
    transition = (((_e55 - _e56) - 4f) / (_e60 - 4f));
    let _e67: f32 = transition;
    return smoothstep(0f, 1f, _e67);
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
    let _e37: f32 = global.material_TerrainVertexSpacing;
    let _e38: f32 = global.renderer_Lod;
    levelSpacing_1 = (_e37 * exp2(_e38));
    let _e42: vec2<f32> = sourceXZ_3;
    let _e43: vec2<f32> = global.material_TerrainGridOrigin;
    let _e45: f32 = levelSpacing_1;
    levelGrid = ((_e42 - _e43) / vec2(_e45));
    let _e49: vec3<f32> = positionOS_1;
    vertexParity = (fract((_e49.xz * 0.5f)) * 2f);
    let _e57: f32 = global.renderer_Lod;
    if (_e57 < 0.5f) {
        {
            let _e60: vec2<f32> = levelGrid;
            let _e68: vec2<f32> = levelGrid;
            diagonalParity = round(fract(((round((_e60.y - (floor((_e60.y / 4f)) * 4f))) * round((_e68.x - (floor((_e68.x / 4f)) * 4f)))) * 0.25f)));
            let _e82: vec2<f32> = vertexParity;
            let _e83: vec2<f32> = vertexParity;
            let _e85: vec2<f32> = vertexParity;
            let _e89: f32 = diagonalParity;
            return mix(_e82, vec2<f32>(_e83.x, -(_e85.y)), vec2(_e89));
        }
    }
    let _e92: vec2<f32> = vertexParity;
    let _e93: vec2<f32> = levelGrid;
    return (_e92 * round(((fract((_e93 * 0.25f)) - vec2(0.5f)) * 4f)));
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
    let _e36: mat4x4<f32> = global.renderer_ModelMat;
    let _e37: vec3<f32> = positionOS_3;
    homogeneousPositionWS = (_e36 * vec4<f32>(_e37.x, _e37.y, _e37.z, 1f));
    let _e45: vec4<f32> = homogeneousPositionWS;
    let _e47: vec4<f32> = homogeneousPositionWS;
    sourcePositionWS = (_e45.xyz / vec3(_e47.w));
    let _e53: vec3<f32> = sourcePositionWS;
    result.sourceXZ = _e53.xz;
    let _e55: TerrainProjectClipmapVertex = result;
    let _e57: TerrainProjectClipmapVertex = result;
    var gs_output_arg0 = result.valid;
    let _e61: f32 = terrainProjectHeightAt(_e55.sourceXZ, (&gs_output_arg0));
    result.valid = gs_output_arg0;
    sourceHeight = _e61;
    let _e64: TerrainProjectClipmapVertex = result;
    if (_e64.valid < 0.5f) {
        local_2 = 0f;
    } else {
        let _e69: TerrainProjectClipmapVertex = result;
        let _e71: f32 = terrainProjectClipmapMorphFactor(_e69.sourceXZ);
        local_2 = _e71;
    }
    let _e73: f32 = local_2;
    result.morph = _e73;
    let _e74: f32 = global.material_TerrainVertexSpacing;
    let _e75: f32 = global.renderer_Lod;
    levelSpacing_2 = (_e74 * exp2(_e75));
    let _e79: TerrainProjectClipmapVertex = result;
    let _e81: vec3<f32> = positionOS_3;
    let _e82: TerrainProjectClipmapVertex = result;
    let _e84: vec2<f32> = terrainProjectClipmapVertexShift(_e81, _e82.sourceXZ);
    let _e85: f32 = levelSpacing_2;
    targetXZ = (_e79.sourceXZ - (_e84 * _e85));
    let _e90: vec2<f32> = targetXZ;
    let _e93: f32 = terrainProjectHeightAt(_e90, (&targetValid));
    targetHeight = _e93;
    let _e95: f32 = targetValid;
    if (_e95 < 0.5f) {
        {
            let _e98: TerrainProjectClipmapVertex = result;
            targetXZ = _e98.sourceXZ;
            let _e100: f32 = sourceHeight;
            targetHeight = _e100;
            result.morph = 0f;
        }
    }
    let _e103: TerrainProjectClipmapVertex = result;
    let _e105: vec2<f32> = targetXZ;
    let _e106: TerrainProjectClipmapVertex = result;
    renderedXZ = mix(_e103.sourceXZ, _e105, vec2(_e106.morph));
    let _e112: vec2<f32> = renderedXZ;
    let _e114: f32 = sourceHeight;
    let _e115: f32 = targetHeight;
    let _e116: TerrainProjectClipmapVertex = result;
    let _e119: vec2<f32> = renderedXZ;
    result.positionWS = vec3<f32>(_e112.x, mix(_e114, _e115, _e116.morph), _e119.y);
    let _e122: TerrainProjectClipmapVertex = result;
    return _e122;
}

fn terrainProjectClipmapGeometryNormal(center: TerrainProjectClipmapVertex) -> vec3<f32> {
    var center_1: TerrainProjectClipmapVertex;
    var valid_2: f32;

    center_1 = center;
    let _e36: TerrainProjectClipmapVertex = center_1;
    let _e41: vec3<f32> = terrainProjectGeometryNormalAt(_e36.positionWS.xz, (&valid_2));
    return _e41;
}

fn applyTerrainProjectShadowBias(positionWS: vec3<f32>, normalWS: vec3<f32>) -> vec3<f32> {
    var positionWS_1: vec3<f32>;
    var normalWS_1: vec3<f32>;
    var inverseNdotL: f32;

    positionWS_1 = positionWS;
    normalWS_1 = normalWS;
    let _e37: vec3<f32> = positionWS_1;
    let _e38: vec3<f32> = global.scene_LightDirection;
    let _e39: vec2<f32> = global.scene_ShadowBias;
    positionWS_1 = (_e37 - (_e38 * _e39.x));
    let _e44: vec3<f32> = global.scene_LightDirection;
    let _e46: vec3<f32> = normalWS_1;
    inverseNdotL = (1f - clamp(dot(-(_e44), _e46), 0f, 1f));
    let _e53: vec3<f32> = positionWS_1;
    let _e54: vec3<f32> = normalWS_1;
    let _e55: f32 = inverseNdotL;
    let _e56: vec2<f32> = global.scene_ShadowBias;
    return (_e53 + (_e54 * (_e55 * _e56.y)));
}

fn terrainProjectShadowClipPosition(positionWS_2: vec3<f32>) -> vec4<f32> {
    var positionWS_3: vec3<f32>;
    var positionCS: vec4<f32>;

    positionWS_3 = positionWS_2;
    let _e35: mat4x4<f32> = global.camera_VPMat;
    let _e36: vec3<f32> = positionWS_3;
    positionCS = (_e35 * vec4<f32>(_e36.x, _e36.y, _e36.z, 1f));
    let _e45: vec4<f32> = positionCS;
    positionCS.z = max(_e45.z, -1f);
    let _e50: vec4<f32> = positionCS;
    return _e50;
}

fn write_TerrainDepthShadowVaryings(interface_value_1: TerrainDepthShadowVaryings) {
    var interface_value_2: TerrainDepthShadowVaryings;

    interface_value_2 = interface_value_1;
    let _e38: TerrainDepthShadowVaryings = interface_value_2;
    sourceXZ_4 = _e38.sourceXZ;
    let _e40: TerrainDepthShadowVaryings = interface_value_2;
    sourcePositionWS_1 = _e40.sourcePositionWS;
    let _e42: TerrainDepthShadowVaryings = interface_value_2;
    terrainValid = _e42.terrainValid;
    return;
}

fn terrainProjectBuildDepthShadowVaryings(attributes: Attributes) -> TerrainDepthShadowVaryings {
    var attributes_1: Attributes;
    var varyings: TerrainDepthShadowVaryings;
    var clipmapVertex: TerrainProjectClipmapVertex;
    var positionWS_4: vec3<f32>;
    var normalWS_2: vec3<f32>;

    attributes_1 = attributes;
    let _e39: Attributes = attributes_1;
    let _e41: TerrainProjectClipmapVertex = terrainProjectClipmapVertexAt(_e39.POSITION);
    clipmapVertex = _e41;
    let _e44: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.sourceXZ = _e44.sourceXZ;
    let _e47: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.sourcePositionWS = _e47.positionWS;
    let _e50: TerrainProjectClipmapVertex = clipmapVertex;
    varyings.terrainValid = _e50.valid;
    let _e52: TerrainProjectClipmapVertex = clipmapVertex;
    positionWS_4 = _e52.positionWS;
    let _e55: TerrainProjectClipmapVertex = clipmapVertex;
    let _e56: vec3<f32> = terrainProjectClipmapGeometryNormal(_e55);
    normalWS_2 = _e56;
    let _e59: vec3<f32> = positionWS_4;
    let _e60: vec3<f32> = normalWS_2;
    let _e61: vec3<f32> = applyTerrainProjectShadowBias(_e59, _e60);
    let _e62: vec4<f32> = terrainProjectShadowClipPosition(_e61);
    gl_Position = _e62;
    let _e63: TerrainDepthShadowVaryings = varyings;
    return _e63;
}

fn TerrainShadowVertex(attributes_2: Attributes) -> TerrainDepthShadowVaryings {
    var attributes_3: Attributes;

    attributes_3 = attributes_2;
    let _e39: Attributes = attributes_3;
    let _e40: TerrainDepthShadowVaryings = terrainProjectBuildDepthShadowVaryings(_e39);
    return _e40;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e37: Attributes = read_Attributes();
    input_attributes = _e37;
    let _e39: Attributes = input_attributes;
    let _e40: TerrainDepthShadowVaryings = TerrainShadowVertex(_e39);
    write_TerrainDepthShadowVaryings(_e40);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e39: vec4<f32> = gl_Position;
    let _e41: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e39.z + _e41.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e47: vec2<f32> = sourceXZ_4;
    let _e49: vec3<f32> = sourcePositionWS_1;
    let _e51: f32 = terrainValid;
    let _e53: vec4<f32> = gl_Position;
    return VertexOutput(_e47, _e49, _e51, _e53);
}
