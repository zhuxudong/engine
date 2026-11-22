diagnostic(off, derivative_uniformity);
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

struct gs_Auto_2_ {
    camera_DepthBufferParams: vec4<f32>,
    camera_ProjectionParams: vec4<f32>,
    camera_Forward: vec3<f32>,
    scene_SurfaceClimate: vec4<f32>,
    scene_TerrainWaterCoverageParams: vec4<f32>,
    scene_TerrainWaterSurfaceParams: vec4<f32>,
    scene_TerrainWaterOpticsParams: vec4<f32>,
    scene_TerrainRippleParams: vec4<f32>,
    scene_WeatherTime: f32,
    material_TerrainPuddleAtlasInvSize: vec2<f32>,
    material_TerrainRegionPuddleRects: array<vec4<f32>, 32>,
    material_ScreenSpaceReflectionIntensity: f32,
    camera_SSRParams: vec4<f32>,
}

struct Varyings {
    positionWS: vec3<f32>,
    sourceXZ: vec2<f32>,
    normalWS: vec3<f32>,
    positionCS: vec4<f32>,
    terrainValid: f32,
    clipmapMorph: f32,
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

struct TerrainProjectSSRReceiverOutput {
    normalRoughness: vec4<f32>,
    receiverDepth: vec4<f32>,
}

struct FragmentOutput {
    @location(0) converted_FragData0_: vec4<f32>,
    @location(1) converted_FragData1_: vec4<f32>,
}

const TERRAIN_PROJECT_MIN_ADDITIVE_GROUP_WEIGHT: f32 = 0.005f;

@group(2) @binding(1) 
var<uniform> global: gs_Auto_1_;
@group(2) @binding(6) 
var<uniform> global_1: gs_Auto_2_;
var<private> converted_FragData0_: vec4<f32>;
var<private> converted_FragData1_: vec4<f32>;
var<private> positionWS_1: vec3<f32>;
var<private> normalWS_1: vec3<f32>;
var<private> positionCS_1: vec4<f32>;
var<private> terrainValid_1: f32;
var<private> clipmapMorph_1: f32;
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
@group(2) @binding(7) 
var gs_wgpu_tex_material_TerrainPuddleAtlas: texture_2d<f32>;
@group(2) @binding(8) 
var gs_wgpu_samp_material_TerrainPuddleAtlas: sampler;
var<private> gl_FragCoord_1: vec4<f32>;

fn remapDepthBufferEyeDepth(depth: f32) -> f32 {
    var depth_1: f32;

    depth_1 = depth;
    let _e49: vec4<f32> = global_1.camera_DepthBufferParams;
    let _e51: f32 = depth_1;
    let _e53: vec4<f32> = global_1.camera_DepthBufferParams;
    return (1f / ((_e49.z * _e51) + _e53.w));
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e53: vec3<f32> = positionWS_1;
    interface_value.positionWS = _e53;
    let _e55: vec3<f32> = normalWS_1;
    interface_value.normalWS = _e55;
    let _e57: vec4<f32> = positionCS_1;
    interface_value.positionCS = _e57;
    let _e59: f32 = terrainValid_1;
    interface_value.terrainValid = _e59;
    let _e61: f32 = clipmapMorph_1;
    interface_value.clipmapMorph = _e61;
    let _e62: Varyings = interface_value;
    return _e62;
}

fn encodeSSROctNormal(normal: vec3<f32>) -> vec2<f32> {
    var normal_1: vec3<f32>;
    var encoded: vec2<f32>;
    var local: f32;
    var local_1: f32;

    normal_1 = normal;
    let _e53: vec3<f32> = normal_1;
    let _e54: vec3<f32> = normal_1;
    let _e57: vec3<f32> = normal_1;
    let _e61: vec3<f32> = normal_1;
    normal_1 = (_e53 / vec3(max(((abs(_e54.x) + abs(_e57.y)) + abs(_e61.z)), 0.000001f)));
    let _e69: vec3<f32> = normal_1;
    encoded = _e69.xy;
    let _e72: vec3<f32> = normal_1;
    if (_e72.z < 0f) {
        {
            let _e77: vec2<f32> = encoded;
            let _e82: vec2<f32> = encoded;
            if (_e82.x >= 0f) {
                local = 1f;
            } else {
                local = -1f;
            }
            let _e90: f32 = local;
            let _e91: vec2<f32> = encoded;
            if (_e91.y >= 0f) {
                local_1 = 1f;
            } else {
                local_1 = -1f;
            }
            let _e99: f32 = local_1;
            encoded = ((vec2(1f) - abs(_e77.yx)) * vec2<f32>(_e90, _e99));
        }
    }
    let _e102: vec2<f32> = encoded;
    return ((_e102 * 0.5f) + vec2(0.5f));
}

fn packSSRNormalRoughness(worldNormal: vec3<f32>, roughness: f32) -> vec4<f32> {
    var worldNormal_1: vec3<f32>;
    var roughness_1: f32;
    var n: vec3<f32>;
    var r: f32;

    worldNormal_1 = worldNormal;
    roughness_1 = roughness;
    let _e55: vec3<f32> = worldNormal_1;
    n = normalize(_e55);
    let _e58: f32 = roughness_1;
    r = clamp(_e58, 0f, 1f);
    let _e63: vec3<f32> = n;
    let _e64: f32 = r;
    return vec4<f32>(_e63.x, _e63.y, _e63.z, _e64);
}

fn encodeSSRDepth(eyeDepth: f32, farClip: f32) -> vec4<f32> {
    var eyeDepth_1: f32;
    var farClip_1: f32;

    eyeDepth_1 = eyeDepth;
    farClip_1 = farClip;
    let _e55: f32 = eyeDepth_1;
    return vec4<f32>(clamp(_e55, 0f, 65000f), 0f, 0f, 1f);
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
        let _e62: i32 = index;
        if !((_e62 < 32i)) {
            break;
        }
        {
            let _e69: i32 = index;
            let _e70: i32 = global.material_TerrainRegionCount;
            if (_e69 >= _e70) {
                {
                    break;
                }
            }
            let _e72: i32 = index;
            let _e74: vec4<f32> = global.material_TerrainRegionWorldBounds[_e72];
            bounds = _e74;
            let _e76: vec4<f32> = bounds;
            minimum = _e76.xy;
            let _e79: vec2<f32> = minimum;
            let _e80: vec4<f32> = bounds;
            maximum = (_e79 + _e80.zw);
            let _e84: vec2<f32> = worldXZ_1;
            let _e85: vec2<f32> = minimum;
            let _e88: vec2<f32> = worldXZ_1;
            let _e89: vec2<f32> = maximum;
            if (all((_e84 >= _e85)) && all((_e88 <= _e89))) {
                {
                    let _e93: vec2<f32> = worldXZ_1;
                    let _e94: vec2<f32> = maximum;
                    if all((_e93 < _e94)) {
                        {
                            let _e97: i32 = index;
                            return _e97;
                        }
                    }
                    let _e98: i32 = inclusiveBoundaryCandidate;
                    let _e101: vec2<f32> = minimum;
                    let _e103: vec2<f32> = candidateMinimum;
                    let _e107: vec2<f32> = minimum;
                    let _e109: vec2<f32> = candidateMinimum;
                    let _e112: vec2<f32> = minimum;
                    let _e114: vec2<f32> = candidateMinimum;
                    if (((_e98 < 0i) || (_e101.x > _e103.x)) || ((_e107.x == _e109.x) && (_e112.y > _e114.y))) {
                        {
                            let _e119: i32 = index;
                            inclusiveBoundaryCandidate = _e119;
                            let _e120: vec2<f32> = minimum;
                            candidateMinimum = _e120;
                        }
                    }
                }
            }
        }
        continuing {
            let _e66: i32 = index;
            index = (_e66 + 1i);
        }
    }
    let _e121: i32 = inclusiveBoundaryCandidate;
    return _e121;
}

fn terrainProjectGeometryNormalAt(worldXZ_2: vec2<f32>, valid: ptr<function, f32>) -> vec3<f32> {
    var worldXZ_3: vec2<f32>;
    var regionIndex: i32;
    var bounds_1: vec4<f32>;
    var atlasRect: vec4<f32>;
    var local_2: vec2<f32>;
    var grid: vec2<f32>;
    var encodedXZ: vec2<f32>;
    var normalY: f32;

    worldXZ_3 = worldXZ_2;
    let _e56: vec2<f32> = worldXZ_3;
    let _e57: i32 = terrainProjectRegionIndex(_e56);
    regionIndex = _e57;
    let _e59: i32 = regionIndex;
    if (_e59 < 0i) {
        {
            (*valid) = 0f;
            return vec3<f32>(0f, 1f, 0f);
        }
    }
    let _e67: i32 = regionIndex;
    let _e69: vec4<f32> = global.material_TerrainRegionWorldBounds[_e67];
    bounds_1 = _e69;
    let _e71: i32 = regionIndex;
    let _e73: vec4<f32> = global.material_TerrainRegionAtlasRects[_e71];
    atlasRect = _e73;
    let _e75: vec2<f32> = worldXZ_3;
    let _e76: vec4<f32> = bounds_1;
    let _e79: vec4<f32> = bounds_1;
    local_2 = clamp(((_e75 - _e76.xy) / _e79.zw), vec2(0f), vec2(1f));
    let _e88: vec2<f32> = local_2;
    let _e89: vec4<f32> = atlasRect;
    grid = (_e88 * (_e89.zw - vec2(1f)));
    let _e96: vec4<f32> = atlasRect;
    let _e98: vec2<f32> = grid;
    let _e103: vec2<f32> = global.material_TerrainHeightAtlasInvSize;
    let _e105: vec4<f32> = textureSample(gs_wgpu_tex_material_TerrainNormalAtlas, gs_wgpu_samp_material_TerrainNormalAtlas, (((_e96.xy + _e98) + vec2(0.5f)) * _e103));
    encodedXZ = ((_e105.xy * 2f) - vec2(1f));
    let _e114: vec2<f32> = encodedXZ;
    let _e115: vec2<f32> = encodedXZ;
    normalY = sqrt(max((1f - dot(_e114, _e115)), 0f));
    (*valid) = 1f;
    let _e123: vec2<f32> = encodedXZ;
    let _e125: f32 = normalY;
    let _e126: vec2<f32> = encodedXZ;
    return normalize(vec3<f32>(_e123.x, _e125, _e126.y));
}

fn terrainProjectShadingGeometryNormal(worldXZ_4: vec2<f32>, vertexNormal: vec3<f32>) -> vec3<f32> {
    var worldXZ_5: vec2<f32>;
    var vertexNormal_1: vec3<f32>;

    worldXZ_5 = worldXZ_4;
    vertexNormal_1 = vertexNormal;
    let _e57: vec3<f32> = vertexNormal_1;
    return normalize(_e57);
}

fn terrainProjectSurfaceClimateHash(cell: vec2<f32>) -> f32 {
    var cell_1: vec2<f32>;

    cell_1 = cell;
    let _e61: vec2<f32> = cell_1;
    return fract((sin(dot(_e61, vec2<f32>(127.1f, 311.7f))) * 43758.547f));
}

fn terrainProjectSurfaceClimateValueNoise(position: vec2<f32>) -> f32 {
    var position_1: vec2<f32>;
    var cell_2: vec2<f32>;
    var local_3: vec2<f32>;
    var blend: vec2<f32>;
    var lower: f32;
    var upper: f32;

    position_1 = position;
    let _e61: vec2<f32> = position_1;
    cell_2 = floor(_e61);
    let _e64: vec2<f32> = position_1;
    local_3 = fract(_e64);
    let _e67: vec2<f32> = local_3;
    let _e68: vec2<f32> = local_3;
    let _e72: vec2<f32> = local_3;
    blend = ((_e67 * _e68) * (vec2(3f) - (2f * _e72)));
    let _e78: vec2<f32> = cell_2;
    let _e79: f32 = terrainProjectSurfaceClimateHash(_e78);
    let _e80: vec2<f32> = cell_2;
    let _e85: f32 = terrainProjectSurfaceClimateHash((_e80 + vec2<f32>(1f, 0f)));
    let _e86: vec2<f32> = blend;
    lower = mix(_e79, _e85, _e86.x);
    let _e90: vec2<f32> = cell_2;
    let _e95: f32 = terrainProjectSurfaceClimateHash((_e90 + vec2<f32>(0f, 1f)));
    let _e96: vec2<f32> = cell_2;
    let _e101: f32 = terrainProjectSurfaceClimateHash((_e96 + vec2<f32>(1f, 1f)));
    let _e102: vec2<f32> = blend;
    upper = mix(_e95, _e101, _e102.x);
    let _e106: f32 = lower;
    let _e107: f32 = upper;
    let _e108: vec2<f32> = blend;
    return mix(_e106, _e107, _e108.y);
}

fn terrainProjectSurfaceClimateNoise(worldXZ_6: vec2<f32>) -> f32 {
    var worldXZ_7: vec2<f32>;
    var broad: f32;
    var detail: f32;

    worldXZ_7 = worldXZ_6;
    let _e61: vec2<f32> = worldXZ_7;
    let _e64: f32 = terrainProjectSurfaceClimateValueNoise((_e61 * 0.055f));
    broad = _e64;
    let _e66: vec2<f32> = worldXZ_7;
    let _e73: f32 = terrainProjectSurfaceClimateValueNoise(((_e66 * 0.17f) + vec2<f32>(19.7f, 43.1f)));
    detail = _e73;
    let _e75: f32 = broad;
    let _e76: f32 = detail;
    return mix(_e75, _e76, 0.28f);
}

fn terrainProjectDecodeSurfaceNormal(encodedNormal: vec3<f32>) -> vec3<f32> {
    var encodedNormal_1: vec3<f32>;
    var normal_2: vec3<f32>;

    encodedNormal_1 = encodedNormal;
    let _e61: vec3<f32> = encodedNormal_1;
    normal_2 = ((_e61 * 2f) - vec3(1f));
    let _e68: vec3<f32> = normal_2;
    let _e69: vec2<f32> = _e68.xy;
    let _e70: vec3<f32> = normal_2;
    return normalize(vec3<f32>(_e69.x, _e69.y, max(_e70.z, 0.08f)));
}

fn terrainProjectSampleRippleFrame(localUv: vec2<f32>, frame: f32) -> vec3<f32> {
    var localUv_1: vec2<f32>;
    var frame_1: f32;
    var frameCell: vec2<f32>;
    var frameUv: vec2<f32>;

    localUv_1 = localUv;
    frame_1 = frame;
    let _e63: f32 = frame_1;
    let _e69: f32 = frame_1;
    frameCell = vec2<f32>((_e63 - (floor((_e63 / 8f)) * 8f)), floor((_e69 * 0.125f)));
    let _e75: vec2<f32> = frameCell;
    let _e80: vec2<f32> = localUv_1;
    frameUv = ((_e75 + mix(vec2(0.04f), vec2(0.96f), clamp(_e80, vec2(0f), vec2(1f)))) * 0.125f);
    let _e91: vec2<f32> = frameUv;
    let _e92: vec4<f32> = textureSample(gs_wgpu_tex_scene_SurfaceRippleNormalAtlas, gs_wgpu_samp_scene_SurfaceRippleNormalAtlas, _e91);
    let _e94: vec3<f32> = terrainProjectDecodeSurfaceNormal(_e92.xyz);
    return _e94;
}

fn terrainProjectScaleTangentNormal(tangentNormal: vec3<f32>, strength: f32) -> vec3<f32> {
    var tangentNormal_1: vec3<f32>;
    var strength_1: f32;
    var clampedStrength: f32;
    var scaledZ: f32;

    tangentNormal_1 = tangentNormal;
    strength_1 = strength;
    let _e63: f32 = strength_1;
    clampedStrength = clamp(_e63, 0f, 1f);
    let _e69: vec3<f32> = tangentNormal_1;
    let _e73: f32 = clampedStrength;
    scaledZ = mix(1f, max(_e69.z, 0.08f), _e73);
    let _e76: vec3<f32> = tangentNormal_1;
    let _e78: f32 = clampedStrength;
    let _e79: vec2<f32> = (_e76.xy * _e78);
    let _e80: f32 = scaledZ;
    return normalize(vec3<f32>(_e79.x, _e79.y, _e80));
}

fn terrainProjectBlendWhiteoutNormals(baseNormal: vec3<f32>, detailNormal: vec3<f32>) -> vec3<f32> {
    var baseNormal_1: vec3<f32>;
    var detailNormal_1: vec3<f32>;

    baseNormal_1 = baseNormal;
    detailNormal_1 = detailNormal;
    let _e63: vec3<f32> = baseNormal_1;
    let _e65: vec3<f32> = detailNormal_1;
    let _e67: vec2<f32> = (_e63.xy + _e65.xy);
    let _e68: vec3<f32> = baseNormal_1;
    let _e70: vec3<f32> = detailNormal_1;
    return normalize(vec3<f32>(_e67.x, _e67.y, (_e68.z * _e70.z)));
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
    let _e67: f32 = rainStrength_1;
    frameRate = mix(8f, 24f, clamp(_e67, 0f, 1f));
    let _e73: f32 = global_1.scene_WeatherTime;
    let _e74: f32 = frameRate;
    let _e76: f32 = frameOffset_1;
    let _e77: f32 = ((_e73 * _e74) + _e76);
    frame_2 = floor((_e77 - (floor((_e77 / 64f)) * 64f)));
    let _e85: vec2<f32> = fieldUv_1;
    let _e87: f32 = frame_2;
    let _e88: vec3<f32> = terrainProjectSampleRippleFrame(fract(_e85), _e87);
    return _e88;
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
    let _e69: f32 = rainStrength_3;
    rippleVisibility = smoothstep(0.015f, 0.12f, _e69);
    let _e72: vec2<f32> = worldXZ_9;
    waterUv = (_e72 * 0.34f);
    let _e81: vec2<f32> = waterUv;
    let _e82: f32 = global_1.scene_WeatherTime;
    let _e89: vec4<f32> = textureSample(gs_wgpu_tex_scene_SurfaceWaterNormal, gs_wgpu_samp_scene_SurfaceWaterNormal, (_e81 + (_e82 * vec2<f32>(0.021f, -0.014f))));
    let _e91: vec3<f32> = terrainProjectDecodeSurfaceNormal(_e89.xyz);
    sampleN = _e91;
    let _e93: vec3<f32> = tangentNormal_2;
    let _e94: vec3<f32> = sampleN;
    let _e96: vec3<f32> = terrainProjectScaleTangentNormal(_e94, 0.025f);
    let _e97: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e93, _e96);
    tangentNormal_2 = _e97;
    let _e98: vec2<f32> = waterUv;
    let _e101: vec2<f32> = waterUv;
    let _e106: f32 = global_1.scene_WeatherTime;
    let _e113: vec4<f32> = textureSample(gs_wgpu_tex_scene_SurfaceWaterNormal, gs_wgpu_samp_scene_SurfaceWaterNormal, ((vec2<f32>(-(_e98.y), _e101.x) * 1.37f) + (_e106 * vec2<f32>(-0.017f, 0.012f))));
    let _e115: vec3<f32> = terrainProjectDecodeSurfaceNormal(_e113.xyz);
    sampleN = _e115;
    let _e116: vec3<f32> = tangentNormal_2;
    let _e117: vec3<f32> = sampleN;
    let _e119: vec3<f32> = terrainProjectScaleTangentNormal(_e117, 0.025f);
    let _e120: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e116, _e119);
    tangentNormal_2 = _e120;
    let _e123: f32 = rippleVisibility;
    if (_e123 > 0f) {
        {
            let _e126: vec4<f32> = global_1.scene_TerrainRippleParams;
            rippleUvTiling = clamp(_e126.x, 0.05f, 8f);
            let _e132: vec4<f32> = global_1.scene_TerrainRippleParams;
            rippleCount = clamp(_e132.y, 0f, 4f);
            let _e138: vec2<f32> = worldXZ_9;
            let _e140: f32 = rippleUvTiling;
            rippleUv = (_e138 * (0.68f * _e140));
            let _e144: f32 = rippleCount;
            rippleWeights = clamp((vec4(_e144) - vec4<f32>(0f, 1f, 2f, 3f)), vec4(0f), vec4(1f));
            let _e158: vec4<f32> = rippleWeights;
            if (_e158.x > 0f) {
                {
                    let _e162: vec2<f32> = rippleUv;
                    let _e164: f32 = rainStrength_3;
                    let _e165: vec3<f32> = terrainProjectRippleField(_e162, 0f, _e164);
                    sampleN = _e165;
                    let _e166: vec3<f32> = tangentNormal_2;
                    let _e167: vec3<f32> = sampleN;
                    let _e169: f32 = rippleVisibility;
                    let _e171: vec4<f32> = rippleWeights;
                    let _e174: vec3<f32> = terrainProjectScaleTangentNormal(_e167, ((0.42f * _e169) * _e171.x));
                    let _e175: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e166, _e174);
                    tangentNormal_2 = _e175;
                    let _e176: f32 = weightedRingResponse;
                    let _e177: vec3<f32> = sampleN;
                    let _e180: vec4<f32> = rippleWeights;
                    weightedRingResponse = max(_e176, (length(_e177.xy) * _e180.x));
                }
            }
            let _e184: vec4<f32> = rippleWeights;
            if (_e184.y > 0f) {
                {
                    let _e188: vec2<f32> = rippleUv;
                    let _e192: vec2<f32> = rippleUv;
                    let _e197: vec2<f32> = rippleUv;
                    let _e201: vec2<f32> = rippleUv;
                    uv = vec2<f32>(((_e188.x * 0.8f) - (_e192.y * 0.6f)), ((_e197.x * 0.6f) + (_e201.y * 0.8f)));
                    let _e208: vec2<f32> = uv;
                    let _e214: f32 = rainStrength_3;
                    let _e215: vec3<f32> = terrainProjectRippleField((_e208 + vec2<f32>(0.37f, 0.19f)), 23f, _e214);
                    sampleN = _e215;
                    let _e216: vec3<f32> = tangentNormal_2;
                    let _e217: vec3<f32> = sampleN;
                    let _e219: f32 = rippleVisibility;
                    let _e221: vec4<f32> = rippleWeights;
                    let _e224: vec3<f32> = terrainProjectScaleTangentNormal(_e217, ((0.32f * _e219) * _e221.y));
                    let _e225: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e216, _e224);
                    tangentNormal_2 = _e225;
                    let _e226: f32 = weightedRingResponse;
                    let _e227: vec3<f32> = sampleN;
                    let _e230: vec4<f32> = rippleWeights;
                    weightedRingResponse = max(_e226, (length(_e227.xy) * _e230.y));
                }
            }
            let _e234: vec4<f32> = rippleWeights;
            if (_e234.z > 0f) {
                {
                    let _e238: vec2<f32> = rippleUv;
                    let _e243: vec2<f32> = rippleUv;
                    let _e248: vec2<f32> = rippleUv;
                    let _e252: vec2<f32> = rippleUv;
                    uv_1 = vec2<f32>(((_e238.x * -0.28f) - (_e243.y * 0.96f)), ((_e248.x * 0.96f) - (_e252.y * 0.28f)));
                    let _e259: vec2<f32> = uv_1;
                    let _e265: f32 = rainStrength_3;
                    let _e266: vec3<f32> = terrainProjectRippleField((_e259 + vec2<f32>(0.71f, 0.43f)), 41f, _e265);
                    sampleN = _e266;
                    let _e267: vec3<f32> = tangentNormal_2;
                    let _e268: vec3<f32> = sampleN;
                    let _e270: f32 = rippleVisibility;
                    let _e272: vec4<f32> = rippleWeights;
                    let _e275: vec3<f32> = terrainProjectScaleTangentNormal(_e268, ((0.27f * _e270) * _e272.z));
                    let _e276: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e267, _e275);
                    tangentNormal_2 = _e276;
                    let _e277: f32 = weightedRingResponse;
                    let _e278: vec3<f32> = sampleN;
                    let _e281: vec4<f32> = rippleWeights;
                    weightedRingResponse = max(_e277, (length(_e278.xy) * _e281.z));
                }
            }
            let _e285: vec4<f32> = rippleWeights;
            if (_e285.w > 0f) {
                {
                    let _e289: vec2<f32> = rippleUv;
                    let _e293: vec2<f32> = rippleUv;
                    let _e298: vec2<f32> = rippleUv;
                    let _e302: vec2<f32> = rippleUv;
                    uv_2 = vec2<f32>(((_e289.x * 0.54f) - (_e293.y * 0.84f)), ((_e298.x * 0.84f) + (_e302.y * 0.54f)));
                    let _e309: vec2<f32> = uv_2;
                    let _e315: f32 = rainStrength_3;
                    let _e316: vec3<f32> = terrainProjectRippleField((_e309 + vec2<f32>(0.13f, 0.79f)), 57f, _e315);
                    sampleN = _e316;
                    let _e317: vec3<f32> = tangentNormal_2;
                    let _e318: vec3<f32> = sampleN;
                    let _e320: f32 = rippleVisibility;
                    let _e322: vec4<f32> = rippleWeights;
                    let _e325: vec3<f32> = terrainProjectScaleTangentNormal(_e318, ((0.23f * _e320) * _e322.w));
                    let _e326: vec3<f32> = terrainProjectBlendWhiteoutNormals(_e317, _e325);
                    tangentNormal_2 = _e326;
                    let _e327: f32 = weightedRingResponse;
                    let _e328: vec3<f32> = sampleN;
                    let _e331: vec4<f32> = rippleWeights;
                    weightedRingResponse = max(_e327, (length(_e328.xy) * _e331.w));
                }
            }
        }
    }
    let _e335: f32 = weightedRingResponse;
    let _e341: f32 = rippleVisibility;
    (*ringResponse) = (clamp((_e335 * 2.4f), 0f, 1f) * _e341);
    let _e343: vec3<f32> = waterSurfaceNormal_1;
    basisNormal = normalize(_e343);
    let _e350: vec3<f32> = basisNormal;
    let _e351: vec3<f32> = basisNormal;
    tangent = (vec3<f32>(1f, 0f, 0f) - (_e350 * _e351.x));
    let _e356: vec3<f32> = tangent;
    let _e357: vec3<f32> = tangent;
    if (dot(_e356, _e357) < 0.00001f) {
        {
            let _e365: vec3<f32> = basisNormal;
            let _e366: vec3<f32> = basisNormal;
            tangent = (vec3<f32>(0f, 0f, 1f) - (_e365 * _e366.z));
        }
    }
    let _e370: vec3<f32> = tangent;
    tangent = normalize(_e370);
    let _e372: vec3<f32> = tangent;
    let _e373: vec3<f32> = basisNormal;
    bitangent = normalize(cross(_e372, _e373));
    let _e377: vec3<f32> = tangent;
    let _e378: vec3<f32> = tangentNormal_2;
    let _e381: vec3<f32> = bitangent;
    let _e382: vec3<f32> = tangentNormal_2;
    let _e386: vec3<f32> = basisNormal;
    let _e387: vec3<f32> = tangentNormal_2;
    (*puddleNormal) = normalize((((_e377 * _e378.x) + (_e381 * _e382.y)) + (_e386 * _e387.z)));
    return;
}

fn terrainProjectSurfacePuddleStorage(response: f32) -> f32 {
    var response_1: f32;

    response_1 = response;
    let _e61: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e63: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    let _e66: f32 = response_1;
    return clamp(((_e61.y + _e63.y) * _e66), 0f, 1f);
}

fn terrainProjectSurfaceHydrologyMasks(worldPosition: vec3<f32>, response_2: f32) -> vec2<f32> {
    var worldPosition_1: vec3<f32>;
    var response_3: f32;
    var storage: f32;
    var regionIndex_1: i32;
    var bounds_2: vec4<f32>;
    var rect: vec4<f32>;
    var local_4: vec2<f32>;
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
    response_3 = response_2;
    let _e63: f32 = response_3;
    let _e64: f32 = terrainProjectSurfacePuddleStorage(_e63);
    storage = _e64;
    let _e66: f32 = storage;
    if (_e66 <= 0.06f) {
        return vec2(0f);
    }
    let _e71: vec3<f32> = worldPosition_1;
    let _e73: i32 = terrainProjectRegionIndex(_e71.xz);
    regionIndex_1 = _e73;
    let _e75: i32 = regionIndex_1;
    if (_e75 < 0i) {
        return vec2(0f);
    }
    let _e80: i32 = regionIndex_1;
    let _e82: vec4<f32> = global.material_TerrainRegionWorldBounds[_e80];
    bounds_2 = _e82;
    let _e84: i32 = regionIndex_1;
    let _e86: vec4<f32> = global_1.material_TerrainRegionPuddleRects[_e84];
    rect = _e86;
    let _e88: vec3<f32> = worldPosition_1;
    let _e90: vec4<f32> = bounds_2;
    let _e93: vec4<f32> = bounds_2;
    local_4 = clamp(((_e88.xz - _e90.xy) / _e93.zw), vec2(0f), vec2(1f));
    let _e102: vec4<f32> = rect;
    let _e104: vec2<f32> = local_4;
    let _e105: vec4<f32> = rect;
    atlasTexel = (_e102.xy + (_e104 * (_e105.zw - vec2(1f))));
    let _e113: vec2<f32> = atlasTexel;
    let _e117: vec2<f32> = global_1.material_TerrainPuddleAtlasInvSize;
    let _e119: vec4<f32> = textureSample(gs_wgpu_tex_material_TerrainPuddleAtlas, gs_wgpu_samp_material_TerrainPuddleAtlas, ((_e113 + vec2(0.5f)) * _e117));
    hydrology = _e119.xy;
    let _e122: f32 = storage;
    let _e123: vec2<f32> = hydrology;
    fillDistance = (_e122 - _e123.x);
    let _e133: f32 = fillDistance;
    let _e134: f32 = fwidth(_e133);
    let _e137: f32 = shorelineWidth;
    shorelineWidth = max((_e134 * 1.25f), _e137);
    let _e139: vec2<f32> = hydrology;
    let _e141: f32 = fwidth(_e139.y);
    let _e144: f32 = classWidth;
    classWidth = max((_e141 * 1.25f), _e144);
    let _e147: f32 = classWidth;
    let _e150: f32 = classWidth;
    let _e152: vec2<f32> = hydrology;
    retainedSurface = smoothstep((0.25f - _e147), (0.45f + _e150), _e152.y);
    let _e157: f32 = classWidth;
    let _e160: f32 = classWidth;
    let _e162: vec2<f32> = hydrology;
    resolvedBasin = smoothstep((0.75f - _e157), (0.95f + _e160), _e162.y);
    let _e166: f32 = shorelineWidth;
    let _e168: f32 = shorelineWidth;
    let _e169: f32 = fillDistance;
    filled = smoothstep(-(_e166), _e168, _e169);
    let _e172: f32 = filled;
    let _e175: f32 = storage;
    hydrologyCoverage = (_e172 * smoothstep(0.06f, 0.3f, _e175));
    let _e179: f32 = retainedSurface;
    let _e181: f32 = resolvedBasin;
    let _e184: f32 = hydrologyCoverage;
    let _e186: f32 = resolvedBasin;
    let _e187: f32 = hydrologyCoverage;
    return vec2<f32>(((_e179 * (1f - _e181)) * _e184), (_e186 * _e187));
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
    let _e65: vec3<f32> = geometryNormal_1;
    upward = clamp(normalize(_e65).y, 0f, 1f);
    let _e74: f32 = upward;
    filmSlopeAcceptance = smoothstep(0.42f, 0.94f, _e74);
    let _e79: vec4<f32> = global_1.scene_SurfaceClimate;
    activeRain = smoothstep(0.03f, 0.68f, _e79.w);
    let _e85: f32 = activeRain;
    filmCapacity = mix(0.22f, 0.38f, _e85);
    let _e90: f32 = rainWetness_1;
    let _e92: f32 = filmSlopeAcceptance;
    let _e94: f32 = filmCapacity;
    baseFilmCoverage = ((smoothstep(0.08f, 0.82f, _e90) * _e92) * _e94);
    let _e97: f32 = microRetention_1;
    let _e98: f32 = filmSlopeAcceptance;
    retainedFilmCoverage = (_e97 * _e98);
    let _e101: f32 = baseFilmCoverage;
    let _e103: f32 = baseFilmCoverage;
    let _e105: f32 = retainedFilmCoverage;
    return (_e101 + ((1f - _e103) * _e105));
}

fn terrainProjectSurfaceWaterCoverage(standingWaterCoverage: f32, thinFilmCoverage: f32) -> f32 {
    var standingWaterCoverage_1: f32;
    var thinFilmCoverage_1: f32;

    standingWaterCoverage_1 = standingWaterCoverage;
    thinFilmCoverage_1 = thinFilmCoverage;
    let _e63: f32 = standingWaterCoverage_1;
    let _e65: f32 = standingWaterCoverage_1;
    let _e67: f32 = thinFilmCoverage_1;
    return clamp((_e63 + ((1f - _e65) * _e67)), 0f, 1f);
}

fn terrainProjectSurfaceStandingWaterLobe(standingWaterCoverage_2: f32, waterCoverage: f32) -> f32 {
    var standingWaterCoverage_3: f32;
    var waterCoverage_1: f32;
    var standingWaterShare: f32;

    standingWaterCoverage_3 = standingWaterCoverage_2;
    waterCoverage_1 = waterCoverage;
    let _e63: f32 = standingWaterCoverage_3;
    let _e64: f32 = waterCoverage_1;
    standingWaterShare = (_e63 / max(_e64, 0.0001f));
    let _e70: f32 = standingWaterShare;
    return step(0.5f, _e70);
}

fn terrainProjectTopSnowMask(worldPosition_2: vec3<f32>, geometryNormal_2: vec3<f32>, response_4: f32) -> f32 {
    var worldPosition_3: vec3<f32>;
    var geometryNormal_3: vec3<f32>;
    var response_5: f32;
    var snowStorage: f32;
    var distribution: f32;
    var snowDistribution: f32;
    var upward_1: f32;

    worldPosition_3 = worldPosition_2;
    geometryNormal_3 = geometryNormal_2;
    response_5 = response_4;
    let _e65: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e67: f32 = response_5;
    snowStorage = clamp((_e65.z * _e67), 0f, 1f);
    let _e73: f32 = snowStorage;
    if (_e73 <= 0f) {
        return 0f;
    }
    let _e77: vec3<f32> = worldPosition_3;
    let _e79: f32 = terrainProjectSurfaceClimateNoise(_e77.xz);
    distribution = _e79;
    let _e83: f32 = snowStorage;
    let _e84: f32 = distribution;
    snowDistribution = smoothstep(0.06f, 0.64f, (_e83 + ((_e84 - 0.5f) * 0.22f)));
    let _e92: vec3<f32> = geometryNormal_3;
    upward_1 = clamp(normalize(_e92).y, 0f, 1f);
    let _e99: f32 = snowDistribution;
    let _e102: f32 = upward_1;
    let _e105: f32 = snowStorage;
    return ((_e99 * smoothstep(0.34f, 0.82f, _e102)) * _e105);
}

fn terrainProjectEvaluateSurfaceWaterFilm(surfaceData: SurfaceData, geometryNormal_4: vec3<f32>, waterResponse: f32, snow: f32) -> TerrainProjectWaterFilm {
    var surfaceData_1: SurfaceData;
    var geometryNormal_5: vec3<f32>;
    var waterResponse_1: f32;
    var snow_1: f32;
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

    surfaceData_1 = surfaceData;
    geometryNormal_5 = geometryNormal_4;
    waterResponse_1 = waterResponse;
    snow_1 = snow;
    let _e67: vec4<f32> = global_1.scene_TerrainRippleParams;
    let _e69: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    waterVisibility = (_e67.z * _e69.x);
    let _e73: vec4<f32> = global_1.scene_SurfaceClimate;
    let _e77: f32 = waterResponse_1;
    rainWetness_2 = clamp(((_e73.w * 0.48f) * _e77), 0f, 1f);
    let _e83: f32 = waterVisibility;
    let _e86: f32 = rainWetness_2;
    let _e89: f32 = waterResponse_1;
    let _e90: f32 = terrainProjectSurfacePuddleStorage(_e89);
    if ((_e83 <= 0f) || ((_e86 <= 0f) && (_e90 <= 0.06f))) {
        {
            let _e97: SurfaceData = surfaceData_1;
            dryFilm.normal = _e97.normal;
            dryFilm.roughness = 0.1f;
            dryFilm.coverage = 0f;
            let _e104: SurfaceData = surfaceData_1;
            dryFilm.dotNV = _e104.dotNV;
            let _e107: SurfaceData = surfaceData_1;
            dryFilm.ambientOcclusion = _e107.ambientOcclusion;
            let _e109: TerrainProjectWaterFilm = dryFilm;
            return _e109;
        }
    }
    let _e110: SurfaceData = surfaceData_1;
    let _e112: f32 = waterResponse_1;
    let _e113: vec2<f32> = terrainProjectSurfaceHydrologyMasks(_e110.position, _e112);
    hydrologyMasks = _e113;
    let _e115: vec2<f32> = hydrologyMasks;
    microRetention_2 = _e115.x;
    let _e118: vec2<f32> = hydrologyMasks;
    standingWaterCoverage_4 = _e118.y;
    let _e121: vec3<f32> = geometryNormal_5;
    let _e122: f32 = rainWetness_2;
    let _e123: f32 = microRetention_2;
    let _e124: f32 = terrainProjectSurfaceThinFilmCoverage(_e121, _e122, _e123);
    thinFilmCoverage_2 = _e124;
    let _e126: f32 = standingWaterCoverage_4;
    let _e127: f32 = thinFilmCoverage_2;
    let _e128: f32 = terrainProjectSurfaceWaterCoverage(_e126, _e127);
    physicalWaterCoverage = _e128;
    let _e130: f32 = standingWaterCoverage_4;
    let _e131: f32 = physicalWaterCoverage;
    let _e132: f32 = terrainProjectSurfaceStandingWaterLobe(_e130, _e131);
    standingWaterLobe = _e132;
    let _e134: f32 = physicalWaterCoverage;
    let _e135: vec4<f32> = global_1.scene_TerrainRippleParams;
    let _e138: vec4<f32> = global_1.scene_TerrainWaterCoverageParams;
    waterCoverage_2 = clamp(((_e134 * _e135.z) * _e138.x), 0f, 1f);
    let _e145: SurfaceData = surfaceData_1;
    let _e147: vec3<f32> = geometryNormal_5;
    let _e149: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
    thinFilmNormal = normalize(mix(_e145.normal, normalize(_e147), vec3(_e149.z)));
    let _e155: vec3<f32> = thinFilmNormal;
    let _e160: f32 = standingWaterLobe;
    waterNormal = mix(_e155, vec3<f32>(0f, 1f, 0f), vec3(_e160));
    let _e166: vec4<f32> = global_1.scene_SurfaceClimate;
    rainStrength_4 = smoothstep(0.04f, 0.72f, _e166.w);
    let _e170: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
    let _e172: f32 = rainStrength_4;
    thinFilmRoughness = clamp((_e170.x + (_e172 * 0.02f)), 0.005f, 1f);
    let _e180: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
    let _e182: f32 = rainStrength_4;
    standingWaterRoughness = clamp((_e180.y + (_e182 * 0.02f)), 0.005f, 1f);
    let _e190: f32 = thinFilmRoughness;
    let _e191: f32 = standingWaterRoughness;
    let _e192: f32 = standingWaterLobe;
    waterRoughness = mix(_e190, _e191, _e192);
    let _e195: f32 = waterCoverage_2;
    if (_e195 > 0.001f) {
        {
            let _e200: vec3<f32> = waterNormal;
            let _e201: SurfaceData = surfaceData_1;
            let _e204: f32 = rainStrength_4;
            terrainProjectPuddleNormal(_e200, _e201.position.xz, _e204, (&animatedNormal), (&ringResponse_1));
            let _e211: f32 = rainStrength_4;
            rippleVisibility_1 = smoothstep(0.015f, 0.12f, _e211);
            let _e214: vec3<f32> = waterNormal;
            let _e215: vec3<f32> = animatedNormal;
            animatedAlignment = max(dot(_e214, _e215), 0.1f);
            let _e220: vec3<f32> = animatedNormal;
            let _e221: f32 = animatedAlignment;
            let _e224: vec3<f32> = waterNormal;
            animatedSlope = ((_e220 / vec3(_e221)) - _e224);
            let _e227: vec3<f32> = waterNormal;
            let _e228: vec3<f32> = animatedSlope;
            let _e229: vec4<f32> = global_1.scene_TerrainWaterSurfaceParams;
            scaledAnimatedNormal = normalize((_e227 + (_e228 * _e229.w)));
            let _e235: f32 = waterCoverage_2;
            let _e236: f32 = rippleVisibility_1;
            let _e240: f32 = standingWaterLobe;
            rippleWeight = ((_e235 * _e236) * mix(0.58f, 0.9f, _e240));
            let _e244: vec3<f32> = waterNormal;
            let _e245: vec3<f32> = scaledAnimatedNormal;
            let _e246: f32 = rippleWeight;
            waterNormal = normalize(mix(_e244, _e245, vec3(_e246)));
            let _e250: f32 = ringResponse_1;
            let _e251: f32 = waterCoverage_2;
            ringPolish = (_e250 * _e251);
            let _e254: f32 = waterRoughness;
            let _e256: f32 = waterRoughness;
            let _e257: vec4<f32> = global_1.scene_TerrainWaterOpticsParams;
            let _e261: f32 = ringPolish;
            waterRoughness = mix(_e254, max(0.018f, (_e256 * _e257.x)), _e261);
        }
    }
    let _e265: vec3<f32> = waterNormal;
    waterFilm.normal = _e265;
    let _e267: f32 = waterRoughness;
    waterFilm.roughness = _e267;
    let _e269: f32 = waterCoverage_2;
    let _e271: f32 = snow_1;
    waterFilm.coverage = (_e269 * (1f - _e271));
    let _e275: vec3<f32> = waterNormal;
    let _e276: SurfaceData = surfaceData_1;
    waterFilm.dotNV = clamp(dot(_e275, _e276.viewDir), 0f, 1f);
    let _e283: SurfaceData = surfaceData_1;
    waterFilm.ambientOcclusion = _e283.ambientOcclusion;
    let _e285: TerrainProjectWaterFilm = waterFilm;
    return _e285;
}

fn terrainProjectCreateWaterFilmAccumulator() -> TerrainProjectWaterFilmAccumulator {
    var accumulator: TerrainProjectWaterFilmAccumulator;

    accumulator.weightedNormal = vec3(0f);
    accumulator.weightedRoughness = 0f;
    accumulator.weightedCoverage = 0f;
    accumulator.weightedAmbientOcclusion = 0f;
    let _e69: TerrainProjectWaterFilmAccumulator = accumulator;
    return _e69;
}

fn terrainProjectAccumulateWaterFilm(accumulator_1: ptr<function, TerrainProjectWaterFilmAccumulator>, waterFilm_1: TerrainProjectWaterFilm, weight: f32) {
    var waterFilm_2: TerrainProjectWaterFilm;
    var weight_1: f32;
    var weightedCoverage: f32;

    waterFilm_2 = waterFilm_1;
    weight_1 = weight;
    let _e64: TerrainProjectWaterFilm = waterFilm_2;
    let _e66: f32 = weight_1;
    weightedCoverage = (_e64.coverage * max(_e66, 0f));
    let _e72: TerrainProjectWaterFilmAccumulator = (*accumulator_1);
    let _e74: TerrainProjectWaterFilm = waterFilm_2;
    let _e76: f32 = weightedCoverage;
    (*accumulator_1).weightedNormal = (_e72.weightedNormal + (_e74.normal * _e76));
    let _e80: TerrainProjectWaterFilmAccumulator = (*accumulator_1);
    let _e82: TerrainProjectWaterFilm = waterFilm_2;
    let _e84: f32 = weightedCoverage;
    (*accumulator_1).weightedRoughness = (_e80.weightedRoughness + (_e82.roughness * _e84));
    let _e88: TerrainProjectWaterFilmAccumulator = (*accumulator_1);
    let _e90: f32 = weightedCoverage;
    (*accumulator_1).weightedCoverage = (_e88.weightedCoverage + _e90);
    let _e93: TerrainProjectWaterFilmAccumulator = (*accumulator_1);
    let _e95: TerrainProjectWaterFilm = waterFilm_2;
    let _e97: f32 = weightedCoverage;
    (*accumulator_1).weightedAmbientOcclusion = (_e93.weightedAmbientOcclusion + (_e95.ambientOcclusion * _e97));
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
    let _e68: TerrainProjectWaterFilmAccumulator = accumulator_3;
    weightedCoverage_1 = _e68.weightedCoverage;
    let _e71: f32 = weightedCoverage_1;
    if (_e71 > 0.00001f) {
        {
            let _e75: TerrainProjectWaterFilmAccumulator = accumulator_3;
            waterFilm_3.normal = normalize(_e75.weightedNormal);
            let _e79: TerrainProjectWaterFilmAccumulator = accumulator_3;
            let _e81: f32 = weightedCoverage_1;
            waterFilm_3.roughness = (_e79.weightedRoughness / _e81);
            let _e84: TerrainProjectWaterFilmAccumulator = accumulator_3;
            let _e86: f32 = weightedCoverage_1;
            waterFilm_3.ambientOcclusion = (_e84.weightedAmbientOcclusion / _e86);
        }
    } else {
        {
            let _e89: vec3<f32> = fallbackNormal_1;
            waterFilm_3.normal = normalize(_e89);
            waterFilm_3.roughness = 0.1f;
            let _e94: f32 = fallbackAmbientOcclusion_1;
            waterFilm_3.ambientOcclusion = _e94;
        }
    }
    let _e96: f32 = weightedCoverage_1;
    waterFilm_3.coverage = clamp(_e96, 0f, 1f);
    let _e101: TerrainProjectWaterFilm = waterFilm_3;
    let _e103: vec3<f32> = viewDirection_1;
    waterFilm_3.dotNV = clamp(dot(_e101.normal, _e103), 0f, 1f);
    let _e108: TerrainProjectWaterFilm = waterFilm_3;
    return _e108;
}

fn terrainProjectBuildSurfaceData(varyings: Varyings, albedo: vec3<f32>, surfaceNormal: vec3<f32>, metallic: f32, smoothness: f32, ambientOcclusion: f32) -> SurfaceData {
    var varyings_1: Varyings;
    var albedo_1: vec3<f32>;
    var surfaceNormal_1: vec3<f32>;
    var metallic_1: f32;
    var smoothness_1: f32;
    var ambientOcclusion_1: f32;
    var surfaceData_2: SurfaceData;

    varyings_1 = varyings;
    albedo_1 = albedo;
    surfaceNormal_1 = surfaceNormal;
    metallic_1 = metallic;
    smoothness_1 = smoothness;
    ambientOcclusion_1 = ambientOcclusion;
    let _e73: vec3<f32> = albedo_1;
    surfaceData_2.albedoColor = _e73;
    surfaceData_2.emissiveColor = vec3(0f);
    let _e78: f32 = metallic_1;
    surfaceData_2.metallic = clamp(_e78, 0f, 1f);
    let _e84: f32 = smoothness_1;
    surfaceData_2.roughness = (1f - clamp(_e84, 0f, 1f));
    let _e90: f32 = ambientOcclusion_1;
    surfaceData_2.ambientOcclusion = clamp(_e90, 0f, 1f);
    surfaceData_2.opacity = 1f;
    surfaceData_2.IOR = 1.5f;
    let _e99: Varyings = varyings_1;
    surfaceData_2.position = _e99.positionWS;
    let _e102: Varyings = varyings_1;
    surfaceData_2.positionCS = _e102.positionCS;
    let _e105: vec3<f32> = surfaceNormal_1;
    surfaceData_2.normal = _e105;
    let _e107: vec3<f32> = global.camera_Position;
    let _e108: Varyings = varyings_1;
    surfaceData_2.viewDir = normalize((_e107 - _e108.positionWS));
    let _e113: SurfaceData = surfaceData_2;
    let _e115: SurfaceData = surfaceData_2;
    surfaceData_2.dotNV = clamp(dot(_e113.normal, _e115.viewDir), 0f, 1f);
    surfaceData_2.specularIntensity = 1f;
    surfaceData_2.specularColor = vec3(1f);
    let _e126: SurfaceData = surfaceData_2;
    return _e126;
}

fn evaluateTerrainFallbackWaterFilm(varyings_2: Varyings, geometryNormal_6: vec3<f32>, waterFilm_4: ptr<function, TerrainProjectWaterFilm>) -> SurfaceData {
    var varyings_3: Varyings;
    var geometryNormal_7: vec3<f32>;
    var surfaceData_3: SurfaceData;
    var snow_2: f32;

    varyings_3 = varyings_2;
    geometryNormal_7 = geometryNormal_6;
    let _e65: Varyings = varyings_3;
    let _e68: vec3<f32> = geometryNormal_7;
    let _e72: SurfaceData = terrainProjectBuildSurfaceData(_e65, vec3(0f), _e68, 0f, 0f, 1f);
    surfaceData_3 = _e72;
    let _e74: SurfaceData = surfaceData_3;
    let _e76: vec3<f32> = geometryNormal_7;
    let _e78: f32 = terrainProjectTopSnowMask(_e74.position, _e76, 1f);
    snow_2 = _e78;
    let _e80: SurfaceData = surfaceData_3;
    let _e81: vec3<f32> = geometryNormal_7;
    let _e83: f32 = snow_2;
    let _e84: TerrainProjectWaterFilm = terrainProjectEvaluateSurfaceWaterFilm(_e80, _e81, 1f, _e83);
    (*waterFilm_4) = _e84;
    let _e85: SurfaceData = surfaceData_3;
    return _e85;
}

fn write_TerrainProjectSSRReceiverOutput(interface_value_1: TerrainProjectSSRReceiverOutput) {
    var interface_value_2: TerrainProjectSSRReceiverOutput;

    interface_value_2 = interface_value_1;
    let _e62: TerrainProjectSSRReceiverOutput = interface_value_2;
    converted_FragData0_ = _e62.normalRoughness;
    let _e64: TerrainProjectSSRReceiverOutput = interface_value_2;
    converted_FragData1_ = _e64.receiverDepth;
    return;
}

fn terrainProjectResolveSSRReceiverWaterFilm(varyings_4: Varyings, geometryNormal_8: vec3<f32>, sandMicroSlope: vec2<f32>) -> TerrainProjectWaterFilm {
    var varyings_5: Varyings;
    var geometryNormal_9: vec3<f32>;
    var sandMicroSlope_1: vec2<f32>;
    var waterFilm_5: TerrainProjectWaterFilm;
    var hasResolvedLayers: bool = false;

    varyings_5 = varyings_4;
    geometryNormal_9 = geometryNormal_8;
    sandMicroSlope_1 = sandMicroSlope;
    let _e69: bool = hasResolvedLayers;
    if !(_e69) {
        {
            let _e71: Varyings = varyings_5;
            let _e72: vec3<f32> = geometryNormal_9;
            let _e75: SurfaceData = evaluateTerrainFallbackWaterFilm(_e71, _e72, (&waterFilm_5));
        }
    }
    let _e76: TerrainProjectWaterFilm = waterFilm_5;
    return _e76;
}

fn TerrainSSRReceiverFragment(varyings_6: Varyings) -> TerrainProjectSSRReceiverOutput {
    var varyings_7: Varyings;
    var output: TerrainProjectSSRReceiverOutput;
    var sandMicroSlope_2: vec2<f32> = vec2(0f);
    var geometryNormal_10: vec3<f32>;
    var waterFilm_6: TerrainProjectWaterFilm;
    var waterRoughness_1: f32;
    var eyeDepth_2: f32;

    varyings_7 = varyings_6;
    output.normalRoughness = vec4(0f);
    output.receiverDepth = vec4(0f);
    let _e69: f32 = global_1.material_ScreenSpaceReflectionIntensity;
    if (_e69 <= 0f) {
        {
            discard;
        }
    }
    let _e75: Varyings = varyings_7;
    if (_e75.terrainValid < 0.999f) {
        {
            discard;
        }
    }
    let _e79: Varyings = varyings_7;
    let _e82: Varyings = varyings_7;
    let _e84: vec3<f32> = terrainProjectShadingGeometryNormal(_e79.positionWS.xz, _e82.normalWS);
    geometryNormal_10 = _e84;
    let _e86: Varyings = varyings_7;
    let _e87: vec3<f32> = geometryNormal_10;
    let _e88: vec2<f32> = sandMicroSlope_2;
    let _e89: TerrainProjectWaterFilm = terrainProjectResolveSSRReceiverWaterFilm(_e86, _e87, _e88);
    waterFilm_6 = _e89;
    let _e91: TerrainProjectWaterFilm = waterFilm_6;
    if (_e91.coverage <= 0.005f) {
        {
            discard;
        }
    }
    let _e95: TerrainProjectWaterFilm = waterFilm_6;
    waterRoughness_1 = clamp(_e95.roughness, 0.045f, 1f);
    let _e101: f32 = waterRoughness_1;
    let _e102: vec4<f32> = global_1.camera_SSRParams;
    if (_e101 >= _e102.y) {
        {
            discard;
        }
    }
    let _e106: vec4<f32> = gl_FragCoord_1;
    let _e108: f32 = remapDepthBufferEyeDepth(_e106.z);
    eyeDepth_2 = _e108;
    let _e111: TerrainProjectWaterFilm = waterFilm_6;
    let _e113: f32 = waterRoughness_1;
    let _e114: vec4<f32> = packSSRNormalRoughness(_e111.normal, _e113);
    output.normalRoughness = _e114;
    let _e116: f32 = eyeDepth_2;
    let _e117: vec4<f32> = global_1.camera_ProjectionParams;
    let _e119: vec4<f32> = encodeSSRDepth(_e116, _e117.z);
    output.receiverDepth = _e119;
    let _e120: TerrainProjectSSRReceiverOutput = output;
    return _e120;
}

fn gs_wgpu_main() {
    var input_varyings: Varyings;

    let _e61: Varyings = read_Varyings();
    input_varyings = _e61;
    let _e63: Varyings = input_varyings;
    let _e64: TerrainProjectSSRReceiverOutput = TerrainSSRReceiverFragment(_e63);
    write_TerrainProjectSSRReceiverOutput(_e64);
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) positionWS: vec3<f32>, @location(2) normalWS: vec3<f32>, @location(3) positionCS: vec4<f32>, @location(4) terrainValid: f32, @location(5) clipmapMorph: f32, @builtin(position) gl_FragCoord: vec4<f32>) -> FragmentOutput {
    positionWS_1 = positionWS;
    normalWS_1 = normalWS;
    positionCS_1 = positionCS;
    terrainValid_1 = terrainValid;
    clipmapMorph_1 = clipmapMorph;
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    let _e89: vec4<f32> = converted_FragData0_;
    let _e91: vec4<f32> = converted_FragData1_;
    return FragmentOutput(_e89, _e91);
}
