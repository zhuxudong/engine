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

struct Attributes {
    POSITION: vec3<f32>,
    NORMAL: vec3<f32>,
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
    @location(0) rootPositionWS: vec3<f32>,
    @location(1) terrainNormalWS: vec3<f32>,
    @location(2) positionWS: vec3<f32>,
    @location(3) grassColor: vec3<f32>,
    @location(4) surfaceWeights: vec3<f32>,
    @location(5) tipWeight: f32,
    @location(6) windCarrierNormalWS: vec3<f32>,
    @location(7) windBentNormalWS: vec3<f32>,
    @location(8) positionCS: vec4<f32>,
    @builtin(position) gl_Position: vec4<f32>,
}

const TERRAIN_PROJECT_GRASS_ROOT_FUSION_HEIGHT: f32 = 0.75f;
const TERRAIN_PROJECT_GRASS_BLADE_APPEARANCE_HEIGHT: f32 = 1f;

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> POSITION_1: vec3<f32>;
var<private> NORMAL_1: vec3<f32>;
var<private> rootPositionWS_4: vec3<f32>;
var<private> terrainNormalWS: vec3<f32>;
var<private> positionWS_4: vec3<f32>;
var<private> grassColor: vec3<f32>;
var<private> surfaceWeights: vec3<f32>;
var<private> tipWeight_7: f32;
var<private> windCarrierNormalWS: vec3<f32>;
var<private> windBentNormalWS: vec3<f32>;
var<private> positionCS: vec4<f32>;
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
@group(0) @binding(0) 
var gs_wgpu_tex_scene_WindSpectrumTexture: texture_2d<f32>;
@group(0) @binding(1) 
var gs_wgpu_samp_scene_WindSpectrumTexture: sampler;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e82: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e82;
    let _e84: vec3<f32> = NORMAL_1;
    interface_value.NORMAL = _e84;
    let _e85: Attributes = interface_value;
    return _e85;
}

fn terrainProjectRotateDetailY(value: vec3<f32>, radians: f32) -> vec3<f32> {
    var value_1: vec3<f32>;
    var radians_1: f32;
    var sine: f32;
    var cosine: f32;

    value_1 = value;
    radians_1 = radians;
    let _e84: f32 = radians_1;
    sine = sin(_e84);
    let _e87: f32 = radians_1;
    cosine = cos(_e87);
    let _e90: f32 = cosine;
    let _e91: vec3<f32> = value_1;
    let _e94: f32 = sine;
    let _e95: vec3<f32> = value_1;
    let _e99: vec3<f32> = value_1;
    let _e101: f32 = sine;
    let _e103: vec3<f32> = value_1;
    let _e106: f32 = cosine;
    let _e107: vec3<f32> = value_1;
    return vec3<f32>(((_e90 * _e91.x) + (_e94 * _e95.z)), _e99.y, ((-(_e101) * _e103.x) + (_e106 * _e107.z)));
}

fn terrainProjectDetailPositionOS(sourcePositionOS: vec3<f32>, attributes: Attributes) -> vec3<f32> {
    var sourcePositionOS_1: vec3<f32>;
    var attributes_1: Attributes;

    sourcePositionOS_1 = sourcePositionOS;
    attributes_1 = attributes;
    let _e84: vec3<f32> = sourcePositionOS_1;
    return _e84;
}

fn terrainProjectDetailOriginOS(attributes_2: Attributes) -> vec3<f32> {
    var attributes_3: Attributes;

    attributes_3 = attributes_2;
    return vec3(0f);
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e91: Varyings = interface_value_2;
    rootPositionWS_4 = _e91.rootPositionWS;
    let _e93: Varyings = interface_value_2;
    terrainNormalWS = _e93.terrainNormalWS;
    let _e95: Varyings = interface_value_2;
    positionWS_4 = _e95.positionWS;
    let _e97: Varyings = interface_value_2;
    grassColor = _e97.grassColor;
    let _e99: Varyings = interface_value_2;
    surfaceWeights = _e99.surfaceWeights;
    let _e101: Varyings = interface_value_2;
    tipWeight_7 = _e101.tipWeight;
    let _e103: Varyings = interface_value_2;
    windCarrierNormalWS = _e103.windCarrierNormalWS;
    let _e105: Varyings = interface_value_2;
    windBentNormalWS = _e105.windBentNormalWS;
    let _e107: Varyings = interface_value_2;
    positionCS = _e107.positionCS;
    return;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_1: vec3<f32>;
    var result: vec3<f32>;

    sh_1 = sh;
    normal_1 = normal;
    let _e99: vec3<f32> = sh_1[0];
    let _e102: vec3<f32> = sh_1[1];
    let _e103: vec3<f32> = normal_1;
    let _e109: vec3<f32> = sh_1[2];
    let _e110: vec3<f32> = normal_1;
    let _e116: vec3<f32> = sh_1[3];
    let _e117: vec3<f32> = normal_1;
    let _e123: vec3<f32> = sh_1[4];
    let _e124: vec3<f32> = normal_1;
    let _e126: vec3<f32> = normal_1;
    let _e133: vec3<f32> = sh_1[5];
    let _e134: vec3<f32> = normal_1;
    let _e136: vec3<f32> = normal_1;
    let _e143: vec3<f32> = sh_1[6];
    let _e145: vec3<f32> = normal_1;
    let _e148: vec3<f32> = normal_1;
    let _e157: vec3<f32> = sh_1[7];
    let _e158: vec3<f32> = normal_1;
    let _e160: vec3<f32> = normal_1;
    let _e167: vec3<f32> = sh_1[8];
    let _e168: vec3<f32> = normal_1;
    let _e170: vec3<f32> = normal_1;
    let _e173: vec3<f32> = normal_1;
    let _e175: vec3<f32> = normal_1;
    result = ((((((((_e99 + (_e102 * _e103.y)) + (_e109 * _e110.z)) + (_e116 * _e117.x)) + (_e123 * (_e124.y * _e126.x))) + (_e133 * (_e134.y * _e136.z))) + (_e143 * (((3f * _e145.z) * _e148.z) - 1f))) + (_e157 * (_e158.z * _e160.x))) + (_e167 * ((_e168.x * _e170.x) - (_e173.y * _e175.y))));
    let _e182: vec3<f32> = result;
    return max(_e182, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS: vec3<f32>) -> vec3<f32> {
    var normalWS_1: vec3<f32>;

    normalWS_1 = normalWS;
    let _e95: EnvMapLight = scene_EnvMapLight;
    return (_e95.diffuse * 3.1415927f);
}

fn terrainProjectApplySeasonColor(sourceColor: vec3<f32>, seasonColor: vec4<f32>) -> vec3<f32> {
    var sourceColor_1: vec3<f32>;
    var seasonColor_1: vec4<f32>;
    var sourceLuminance: f32;
    var seasonTone: vec3<f32>;

    sourceColor_1 = sourceColor;
    seasonColor_1 = seasonColor;
    let _e97: vec3<f32> = sourceColor_1;
    sourceLuminance = dot(_e97, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e104: vec4<f32> = seasonColor_1;
    let _e106: f32 = sourceLuminance;
    seasonTone = (_e104.xyz * _e106);
    let _e109: vec3<f32> = sourceColor_1;
    let _e110: vec3<f32> = seasonTone;
    let _e111: vec4<f32> = seasonColor_1;
    return mix(_e109, _e110, vec3(clamp(_e111.w, 0f, 1f)));
}

fn terrainProjectApplyAuthoredSeasonColor(sourceColor_2: vec3<f32>, seasonColor_2: vec4<f32>, authoredChannels: vec3<f32>) -> vec3<f32> {
    var sourceColor_3: vec3<f32>;
    var seasonColor_3: vec4<f32>;
    var authoredChannels_1: vec3<f32>;

    sourceColor_3 = sourceColor_2;
    seasonColor_3 = seasonColor_2;
    authoredChannels_1 = authoredChannels;
    let _e99: vec3<f32> = sourceColor_3;
    let _e100: vec4<f32> = seasonColor_3;
    let _e101: vec3<f32> = terrainProjectApplySeasonColor(_e99, _e100);
    let _e102: vec3<f32> = sourceColor_3;
    let _e103: vec3<f32> = authoredChannels_1;
    return mix(_e101, _e102, _e103);
}

fn grassColorFieldRotateUv(value_2: vec2<f32>, cosineSine: vec2<f32>) -> vec2<f32> {
    var value_3: vec2<f32>;
    var cosineSine_1: vec2<f32>;

    value_3 = value_2;
    cosineSine_1 = cosineSine;
    let _e99: vec2<f32> = cosineSine_1;
    let _e101: vec2<f32> = value_3;
    let _e104: vec2<f32> = cosineSine_1;
    let _e106: vec2<f32> = value_3;
    let _e110: vec2<f32> = cosineSine_1;
    let _e112: vec2<f32> = value_3;
    let _e115: vec2<f32> = cosineSine_1;
    let _e117: vec2<f32> = value_3;
    return vec2<f32>(((_e99.x * _e101.x) + (_e104.y * _e106.y)), ((_e110.x * _e112.y) - (_e115.y * _e117.x)));
}

fn grassColorFieldMaximumLod() -> f32 {
    var baseSize: vec2<i32>;

    let _e96: vec2<u32> = textureDimensions(gs_wgpu_tex_renderer_GrassColorFieldTexture, 0i);
    baseSize = vec2<i32>(_e96);
    let _e99: vec2<i32> = baseSize;
    let _e101: vec2<i32> = baseSize;
    return floor(log2(f32(max(_e99.x, _e101.y))));
}

fn grassColorFieldSoftnessLod() -> f32 {
    var textureResolution: f32;
    var softnessMetres: f32;
    var softnessLod: f32;

    let _e96: vec2<u32> = textureDimensions(gs_wgpu_tex_renderer_GrassColorFieldTexture, 0i);
    textureResolution = f32(vec2<i32>(_e96).x);
    let _e101: vec4<f32> = global.renderer_GrassColorFieldParams;
    softnessMetres = max(_e101.x, 0f);
    let _e106: f32 = softnessMetres;
    let _e107: vec4<f32> = global.renderer_GrassColorFieldTransform;
    let _e110: f32 = textureResolution;
    softnessLod = max(log2(max(((_e106 * _e107.y) * _e110), 1f)), 0f);
    let _e118: f32 = softnessLod;
    let _e119: f32 = grassColorFieldMaximumLod();
    return min(_e118, _e119);
}

fn grassColorFieldMirrorUv(uv: vec2<f32>) -> vec2<f32> {
    var uv_1: vec2<f32>;

    uv_1 = uv;
    let _e99: vec2<f32> = uv_1;
    let _e101: vec2<f32> = vec2(2f);
    return (vec2(1f) - abs(((_e99 - (floor((_e99 / _e101)) * _e101)) - vec2(1f))));
}

fn grassColorFieldDetailUv(worldXZ: vec2<f32>) -> vec2<f32> {
    var worldXZ_1: vec2<f32>;
    var cosineSine_2: vec2<f32>;

    worldXZ_1 = worldXZ;
    let _e97: vec4<f32> = global.renderer_GrassColorFieldTransform;
    let _e100: vec4<f32> = global.renderer_GrassColorFieldTransform;
    cosineSine_2 = vec2<f32>(cos(_e97.z), sin(_e100.z));
    let _e105: vec2<f32> = worldXZ_1;
    let _e106: vec4<f32> = global.renderer_GrassColorFieldTransform;
    let _e109: vec4<f32> = global.renderer_GrassColorFieldOffset;
    let _e112: vec2<f32> = cosineSine_2;
    let _e113: vec2<f32> = grassColorFieldRotateUv(((_e105 * _e106.y) + _e109.xy), _e112);
    let _e114: vec2<f32> = grassColorFieldMirrorUv(_e113);
    return _e114;
}

fn grassColorFieldVistaUv(worldXZ_2: vec2<f32>) -> vec2<f32> {
    var worldXZ_3: vec2<f32>;

    worldXZ_3 = worldXZ_2;
    let _e97: vec2<f32> = worldXZ_3;
    let _e98: vec4<f32> = global.renderer_GrassColorFieldTransform;
    let _e101: vec4<f32> = global.renderer_GrassColorFieldOffset;
    return clamp(((_e97 * _e98.w) + _e101.zw), vec2(0f), vec2(1f));
}

fn decodeGrassColorField(field: f32) -> f32 {
    var field_1: f32;
    var remapRange: f32;

    field_1 = field;
    let _e97: vec4<f32> = global.renderer_GrassColorFieldParams;
    let _e99: vec4<f32> = global.renderer_GrassColorFieldParams;
    remapRange = max((_e97.z - _e99.y), 0.00001f);
    let _e105: f32 = field_1;
    let _e106: vec4<f32> = global.renderer_GrassColorFieldParams;
    let _e109: f32 = remapRange;
    return clamp(((_e105 - _e106.y) / _e109), 0f, 1f);
}

fn sampleGrassColorFieldAtLod(worldXZ_4: vec2<f32>, lod: f32) -> f32 {
    var worldXZ_5: vec2<f32>;
    var lod_1: f32;
    var field_2: f32;

    worldXZ_5 = worldXZ_4;
    lod_1 = lod;
    let _e99: vec4<f32> = global.renderer_GrassColorFieldTransform;
    if (_e99.x < 0.5f) {
        return 0.5f;
    }
    let _e104: vec2<f32> = worldXZ_5;
    let _e105: vec2<f32> = grassColorFieldDetailUv(_e104);
    let _e106: f32 = lod_1;
    let _e107: vec4<f32> = textureSampleLevel(gs_wgpu_tex_renderer_GrassColorFieldTexture, gs_wgpu_samp_renderer_GrassColorFieldTexture, _e105, _e106);
    field_2 = _e107.x;
    let _e110: f32 = field_2;
    let _e111: f32 = decodeGrassColorField(_e110);
    return _e111;
}

fn sampleGrassColorField(worldXZ_6: vec2<f32>) -> f32 {
    var worldXZ_7: vec2<f32>;

    worldXZ_7 = worldXZ_6;
    let _e97: vec4<f32> = global.renderer_GrassColorFieldTransform;
    if (_e97.x < 0.5f) {
        return 0.5f;
    }
    let _e102: vec4<f32> = global.renderer_GrassColorFieldParams;
    if (_e102.x <= 0f) {
        {
            let _e106: vec2<f32> = worldXZ_7;
            let _e107: vec2<f32> = grassColorFieldDetailUv(_e106);
            let _e109: vec4<f32> = textureSampleLevel(gs_wgpu_tex_renderer_GrassColorFieldTexture, gs_wgpu_samp_renderer_GrassColorFieldTexture, _e107, 0f);
            let _e111: f32 = decodeGrassColorField(_e109.x);
            return _e111;
        }
    }
    let _e112: vec2<f32> = worldXZ_7;
    let _e113: f32 = grassColorFieldSoftnessLod();
    let _e114: f32 = sampleGrassColorFieldAtLod(_e112, _e113);
    return _e114;
}

fn sampleGrassVistaColorField(worldXZ_8: vec2<f32>) -> f32 {
    var worldXZ_9: vec2<f32>;
    var field_3: f32;

    worldXZ_9 = worldXZ_8;
    let _e97: vec4<f32> = global.renderer_GrassColorFieldTransform;
    if (_e97.x < 0.5f) {
        return 0.5f;
    }
    let _e102: vec2<f32> = worldXZ_9;
    let _e103: vec2<f32> = grassColorFieldVistaUv(_e102);
    let _e105: vec4<f32> = textureSampleLevel(gs_wgpu_tex_renderer_GrassColorFieldTexture, gs_wgpu_samp_renderer_GrassColorFieldTexture, _e103, 0f);
    field_3 = _e105.y;
    let _e108: f32 = field_3;
    let _e109: f32 = decodeGrassColorField(_e108);
    return _e109;
}

fn grassColorFieldVistaBlendWeight(worldPosition: vec3<f32>) -> f32 {
    var worldPosition_1: vec3<f32>;

    worldPosition_1 = worldPosition;
    let _e97: vec2<f32> = global.renderer_GrassColorFieldVistaBlend;
    let _e99: vec2<f32> = global.renderer_GrassColorFieldVistaBlend;
    let _e101: vec3<f32> = global.camera_Position;
    let _e102: vec3<f32> = worldPosition_1;
    return smoothstep(_e97.x, _e99.y, distance(_e101, _e102));
}

fn grassRgbToHsv(color: vec3<f32>) -> vec3<f32> {
    var color_1: vec3<f32>;
    var k: vec4<f32> = vec4<f32>(0f, -0.33333334f, 0.6666667f, -1f);
    var p: vec4<f32>;
    var q: vec4<f32>;
    var delta: f32;
    var epsilon: f32 = 0.0000000001f;

    color_1 = color;
    let _e105: vec3<f32> = color_1;
    let _e106: vec2<f32> = _e105.zy;
    let _e107: vec4<f32> = k;
    let _e108: vec2<f32> = _e107.wz;
    let _e114: vec3<f32> = color_1;
    let _e115: vec2<f32> = _e114.yz;
    let _e116: vec4<f32> = k;
    let _e117: vec2<f32> = _e116.xy;
    let _e123: vec3<f32> = color_1;
    let _e125: vec3<f32> = color_1;
    p = mix(vec4<f32>(_e106.x, _e106.y, _e108.x, _e108.y), vec4<f32>(_e115.x, _e115.y, _e117.x, _e117.y), vec4(step(_e123.z, _e125.y)));
    let _e131: vec4<f32> = p;
    let _e132: vec3<f32> = _e131.xyw;
    let _e133: vec3<f32> = color_1;
    let _e139: vec3<f32> = color_1;
    let _e141: vec4<f32> = p;
    let _e142: vec3<f32> = _e141.yzx;
    let _e147: vec4<f32> = p;
    let _e149: vec3<f32> = color_1;
    q = mix(vec4<f32>(_e132.x, _e132.y, _e132.z, _e133.x), vec4<f32>(_e139.x, _e142.x, _e142.y, _e142.z), vec4(step(_e147.x, _e149.x)));
    let _e155: vec4<f32> = q;
    let _e157: vec4<f32> = q;
    let _e159: vec4<f32> = q;
    delta = (_e155.x - min(_e157.w, _e159.y));
    let _e166: vec4<f32> = q;
    let _e168: vec4<f32> = q;
    let _e170: vec4<f32> = q;
    let _e174: f32 = delta;
    let _e176: f32 = epsilon;
    let _e181: f32 = delta;
    let _e182: vec4<f32> = q;
    let _e184: f32 = epsilon;
    let _e187: vec4<f32> = q;
    return vec3<f32>(abs((_e166.z + ((_e168.w - _e170.y) / ((6f * _e174) + _e176)))), (_e181 / (_e182.x + _e184)), _e187.x);
}

fn grassHsvToRgb(color_2: vec3<f32>) -> vec3<f32> {
    var color_3: vec3<f32>;
    var p_1: vec3<f32>;

    color_3 = color_2;
    let _e97: vec3<f32> = color_3;
    p_1 = abs(((fract((_e97.xxx + vec3<f32>(0f, 0.6666667f, 0.33333334f))) * 6f) - vec3(3f)));
    let _e112: vec3<f32> = color_3;
    let _e116: vec3<f32> = p_1;
    let _e125: vec3<f32> = color_3;
    return (_e112.z * mix(vec3(1f), clamp((_e116 - vec3(1f)), vec3(0f), vec3(1f)), vec3(_e125.y)));
}

fn grassSaturatePaletteEndpoint(color_4: vec3<f32>) -> vec3<f32> {
    var color_5: vec3<f32>;
    var hsv: vec3<f32>;

    color_5 = color_4;
    let _e97: vec3<f32> = color_5;
    let _e98: vec3<f32> = grassRgbToHsv(_e97);
    hsv = _e98;
    let _e101: vec3<f32> = hsv;
    let _e103: vec4<f32> = global.renderer_GrassColorFieldParams;
    hsv.y = clamp((_e101.y * _e103.w), 0f, 1f);
    let _e109: vec3<f32> = hsv;
    let _e110: vec3<f32> = grassHsvToRgb(_e109);
    return _e110;
}

fn grassColorFromField(field_4: f32) -> vec3<f32> {
    var field_5: f32;
    var colorA: vec3<f32>;
    var colorB: vec3<f32>;

    field_5 = field_4;
    let _e97: vec4<f32> = global.renderer_GrassColorA;
    let _e99: vec3<f32> = grassSaturatePaletteEndpoint(_e97.xyz);
    colorA = _e99;
    let _e101: vec4<f32> = global.renderer_GrassColorB;
    let _e103: vec3<f32> = grassSaturatePaletteEndpoint(_e101.xyz);
    colorB = _e103;
    let _e105: vec3<f32> = colorA;
    let _e106: vec4<f32> = global.scene_GrassSeasonColor;
    let _e107: vec4<f32> = global.renderer_GrassColorOverrideA;
    let _e109: vec3<f32> = terrainProjectApplyAuthoredSeasonColor(_e105, _e106, _e107.xyz);
    colorA = _e109;
    let _e110: vec3<f32> = colorB;
    let _e111: vec4<f32> = global.scene_GrassSeasonColor;
    let _e112: vec4<f32> = global.renderer_GrassColorOverrideB;
    let _e114: vec3<f32> = terrainProjectApplyAuthoredSeasonColor(_e110, _e111, _e112.xyz);
    colorB = _e114;
    let _e115: vec3<f32> = colorA;
    let _e116: vec3<f32> = colorB;
    let _e117: f32 = field_5;
    return mix(_e115, _e116, vec3(_e117));
}

fn evaluateGrassBaseColor(worldXZ_10: vec2<f32>) -> vec3<f32> {
    var worldXZ_11: vec2<f32>;

    worldXZ_11 = worldXZ_10;
    let _e97: vec2<f32> = worldXZ_11;
    let _e98: f32 = sampleGrassColorField(_e97);
    let _e99: vec3<f32> = grassColorFromField(_e98);
    return _e99;
}

fn roadColorFromField(field_6: f32, nativeColor: vec3<f32>) -> vec3<f32> {
    var field_7: f32;
    var nativeColor_1: vec3<f32>;

    field_7 = field_6;
    nativeColor_1 = nativeColor;
    let _e99: vec3<f32> = nativeColor_1;
    let _e100: vec4<f32> = global.renderer_RoadColorFieldA;
    let _e102: vec4<f32> = global.renderer_RoadColorFieldB;
    let _e104: f32 = field_7;
    let _e107: vec4<f32> = global.renderer_RoadColorFieldA;
    return mix(_e99, mix(_e100.xyz, _e102.xyz, vec3(_e104)), vec3(_e107.w));
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
    let _e101: vec4<f32> = global.renderer_RoadColorFieldRemap;
    contrast = max(_e101.x, 1f);
    let _e106: vec4<f32> = global.renderer_RoadColorFieldRemap;
    if (_e106.x > 0f) {
        let _e110: vec4<f32> = global.renderer_RoadColorFieldRemap;
        local = _e110.y;
    } else {
        local = 0.5f;
    }
    let _e114: f32 = local;
    midpoint = _e114;
    let _e116: f32 = field_9;
    let _e117: f32 = midpoint;
    let _e119: f32 = contrast;
    detail = clamp((((_e116 - _e117) * _e119) + 0.5f), 0f, 1f);
    let _e127: f32 = detail;
    let _e128: f32 = field_9;
    let _e129: f32 = vistaWeight_1;
    let _e131: vec3<f32> = nativeColor_3;
    let _e132: vec3<f32> = roadColorFromField(mix(_e127, _e128, _e129), _e131);
    return _e132;
}

fn terrainProjectGrassDistanceVisibility(rootPositionWS: vec3<f32>) -> f32 {
    var rootPositionWS_1: vec3<f32>;
    var distanceVisibility: f32;
    var eyeDepth: f32;
    var cameraDepthFade: f32;

    rootPositionWS_1 = rootPositionWS;
    let _e98: mat4x4<f32> = global.camera_ViewMat;
    let _e99: vec3<f32> = rootPositionWS_1;
    eyeDepth = -((_e98 * vec4<f32>(_e99.x, _e99.y, _e99.z, 1f)).z);
    let _e109: f32 = eyeDepth;
    let _e110: vec4<f32> = global.camera_ProjectionParams;
    let _e113: f32 = global_1.material_GrassFadeDistance;
    cameraDepthFade = (((_e109 - _e110.y) - _e113) / 5f);
    let _e119: f32 = cameraDepthFade;
    let _e121: f32 = cameraDepthFade;
    let _e122: f32 = global_1.material_GrassFalloff;
    distanceVisibility = clamp(mix((1f - _e119), _e121, (_e122 * 0.5f)), 0f, 1f);
    let _e130: f32 = distanceVisibility;
    let _e131: f32 = global_1.material_GrassDistanceFadeEnable;
    return mix(1f, _e130, _e131);
}

fn terrainProjectGrassBladeAppearanceWeight(tipWeight: f32) -> f32 {
    var tipWeight_1: f32;

    tipWeight_1 = tipWeight;
    let _e99: f32 = tipWeight_1;
    return smoothstep(TERRAIN_PROJECT_GRASS_ROOT_FUSION_HEIGHT, TERRAIN_PROJECT_GRASS_BLADE_APPEARANCE_HEIGHT, clamp(_e99, 0f, 1f));
}

fn terrainProjectGrassBladeShadeWeight(tipWeight_2: f32) -> f32 {
    var tipWeight_3: f32;

    tipWeight_3 = tipWeight_2;
    let _e99: f32 = tipWeight_3;
    let _e100: f32 = terrainProjectGrassBladeAppearanceWeight(_e99);
    let _e103: f32 = tipWeight_3;
    return (_e100 * smoothstep(0.25f, 0.95f, _e103));
}

fn terrainProjectGrassWindFieldNormal(groundNormal: vec3<f32>, carrierNormal: vec3<f32>, bentNormal: vec3<f32>) -> vec3<f32> {
    var groundNormal_1: vec3<f32>;
    var carrierNormal_1: vec3<f32>;
    var bentNormal_1: vec3<f32>;

    groundNormal_1 = groundNormal;
    carrierNormal_1 = carrierNormal;
    bentNormal_1 = bentNormal;
    let _e103: vec3<f32> = groundNormal_1;
    let _e104: vec3<f32> = carrierNormal_1;
    let _e113: vec3<f32> = bentNormal_1;
    return normalize(((_e103 + ((_e104 - vec3<f32>(0f, 1f, 0f)) * 0.45f)) + (_e113 - vec3<f32>(0f, 1f, 0f))));
}

fn terrainProjectSurfaceReliefEnabled() -> bool {
    let _e103: vec4<f32> = global.camera_SurfaceReliefOptions;
    return (_e103.x > 0.5f);
}

fn terrainProjectSurfaceReliefWeight(worldPosition_2: vec3<f32>) -> f32 {
    var worldPosition_3: vec3<f32>;

    worldPosition_3 = worldPosition_2;
    let _e105: bool = terrainProjectSurfaceReliefEnabled();
    if !(_e105) {
        return 0f;
    }
    let _e111: vec3<f32> = global.camera_Position;
    let _e112: vec3<f32> = worldPosition_3;
    return (1f - smoothstep(50f, 60f, distance(_e111, _e112)));
}

fn terrainProjectSurfaceReliefPattern(worldXZ_12: vec2<f32>) -> f32 {
    var worldXZ_13: vec2<f32>;
    var patternUV: vec2<f32>;
    var colorField: f32;

    worldXZ_13 = worldXZ_12;
    let _e105: vec2<f32> = worldXZ_13;
    patternUV = ((_e105 * vec2<f32>(1f, -1f)) * 0.05f);
    let _e116: vec2<f32> = patternUV;
    let _e118: vec2<f32> = vec2(2f);
    patternUV = (vec2(1f) - abs(((_e116 - (floor((_e116 / _e118)) * _e118)) - vec2(1f))));
    let _e130: vec2<f32> = patternUV;
    patternUV.y = (1f - _e130.y);
    let _e133: vec2<f32> = patternUV;
    let _e135: vec4<f32> = textureSampleLevel(gs_wgpu_tex_camera_SurfaceReliefHeightTexture, gs_wgpu_samp_camera_SurfaceReliefHeightTexture, _e133, 0f);
    colorField = _e135.x;
    let _e138: f32 = colorField;
    return clamp(((_e138 - 0.17524087f) / 0.79473084f), 0f, 1f);
}

fn terrainProjectSurfaceReliefMask(worldXZ_14: vec2<f32>) -> vec3<f32> {
    var worldXZ_15: vec2<f32>;
    var resolution: f32;
    var maskUV: vec2<f32>;

    worldXZ_15 = worldXZ_14;
    let _e105: vec4<f32> = global.camera_SurfaceReliefDomain;
    resolution = _e105.w;
    let _e108: vec2<f32> = worldXZ_15;
    let _e109: vec4<f32> = global.camera_SurfaceReliefDomain;
    let _e112: vec4<f32> = global.camera_SurfaceReliefDomain;
    let _e121: f32 = resolution;
    let _e128: f32 = resolution;
    maskUV = (((clamp(((_e108 - _e109.xy) / vec2(_e112.z)), vec2(0f), vec2(1f)) * (_e121 - 1f)) + vec2(0.5f)) / vec2(_e128));
    let _e132: vec2<f32> = maskUV;
    let _e134: vec4<f32> = textureSampleLevel(gs_wgpu_tex_camera_SurfaceReliefMaskTexture, gs_wgpu_samp_camera_SurfaceReliefMaskTexture, _e132, 0f);
    return _e134.xyz;
}

fn terrainProjectSurfaceReliefPatternGradient(worldXZ_16: vec2<f32>) -> vec2<f32> {
    var worldXZ_17: vec2<f32>;
    var normal_2: vec3<f32>;

    worldXZ_17 = worldXZ_16;
    let _e105: vec2<f32> = worldXZ_17;
    let _e106: vec4<f32> = global.camera_SurfaceReliefBakedDomain;
    let _e111: vec4<f32> = textureSampleLevel(gs_wgpu_tex_camera_SurfaceReliefBakedNormal, gs_wgpu_samp_camera_SurfaceReliefBakedNormal, (_e105 / vec2(_e106.z)), 0f);
    normal_2 = ((_e111.xyz * 2f) - vec3(1f));
    let _e119: vec3<f32> = normal_2;
    let _e122: vec3<f32> = normal_2;
    return (-(_e119.xz) / vec2(max(_e122.y, 0.00001f)));
}

fn terrainProjectSurfaceReliefGradient(worldXZ_18: vec2<f32>) -> vec2<f32> {
    var worldXZ_19: vec2<f32>;
    var gradient: vec2<f32>;
    var maskData: vec3<f32>;
    var mask: f32;
    var maskGradient: vec2<f32>;
    var heightOffset: f32;

    worldXZ_19 = worldXZ_18;
    let _e105: vec2<f32> = worldXZ_19;
    let _e106: vec2<f32> = terrainProjectSurfaceReliefPatternGradient(_e105);
    gradient = _e106;
    {
        let _e108: vec2<f32> = worldXZ_19;
        let _e109: vec3<f32> = terrainProjectSurfaceReliefMask(_e108);
        maskData = _e109;
        let _e111: vec3<f32> = maskData;
        mask = _e111.x;
        let _e114: vec3<f32> = maskData;
        maskGradient = (((_e114.yz * 255f) - vec2(128f)) / vec2(91.94594f));
        let _e129: vec2<f32> = worldXZ_19;
        let _e130: f32 = terrainProjectSurfaceReliefPattern(_e129);
        heightOffset = (-1.8f * (_e130 - 0.79318225f));
        let _e135: f32 = mask;
        let _e136: vec2<f32> = gradient;
        let _e138: f32 = heightOffset;
        let _e139: vec2<f32> = maskGradient;
        gradient = ((_e135 * _e136) + (_e138 * _e139));
    }
    let _e142: vec2<f32> = gradient;
    return _e142;
}

fn terrainProjectApplyReliefGradient(terrainNormal: vec3<f32>, gradient_1: vec2<f32>, influence: f32) -> vec3<f32> {
    var terrainNormal_1: vec3<f32>;
    var gradient_2: vec2<f32>;
    var influence_1: f32;
    var normal_3: vec3<f32>;

    terrainNormal_1 = terrainNormal;
    gradient_2 = gradient_1;
    influence_1 = influence;
    let _e109: vec3<f32> = terrainNormal_1;
    let _e110: vec2<f32> = gradient_2;
    let _e113: vec2<f32> = gradient_2;
    let _e116: vec3<f32> = terrainNormal_1;
    normal_3 = normalize((_e109 - (vec3<f32>(_e110.x, 0f, _e113.y) * _e116.y)));
    let _e122: vec3<f32> = terrainNormal_1;
    let _e123: vec3<f32> = normal_3;
    let _e124: f32 = influence_1;
    return normalize(mix(_e122, _e123, vec3(_e124)));
}

fn terrainProjectSurfaceReliefNormal(worldPosition_4: vec3<f32>, terrainNormal_2: vec3<f32>, grassCoverage: f32) -> vec3<f32> {
    var worldPosition_5: vec3<f32>;
    var terrainNormal_3: vec3<f32>;
    var grassCoverage_1: f32;
    var local_1: f32;
    var influence_2: f32;

    worldPosition_5 = worldPosition_4;
    terrainNormal_3 = terrainNormal_2;
    grassCoverage_1 = grassCoverage;
    let _e109: vec4<f32> = global.camera_SurfaceReliefOptions;
    if (_e109.y > 0.5f) {
        local_1 = 1f;
    } else {
        let _e114: f32 = grassCoverage_1;
        local_1 = clamp(_e114, 0f, 1f);
    }
    let _e119: f32 = local_1;
    influence_2 = _e119;
    let _e121: vec3<f32> = terrainNormal_3;
    let _e122: vec3<f32> = worldPosition_5;
    let _e124: vec2<f32> = terrainProjectSurfaceReliefGradient(_e122.xz);
    let _e125: f32 = influence_2;
    let _e126: vec3<f32> = terrainProjectApplyReliefGradient(_e121, _e124, _e125);
    return _e126;
}

fn terrainProjectAttachedReliefNormal(positionWS: vec3<f32>, normal_4: vec3<f32>, coverage: f32) -> vec3<f32> {
    var positionWS_1: vec3<f32>;
    var normal_5: vec3<f32>;
    var coverage_1: f32;
    var weight: f32;

    positionWS_1 = positionWS;
    normal_5 = normal_4;
    coverage_1 = coverage;
    let _e109: vec3<f32> = positionWS_1;
    let _e110: f32 = terrainProjectSurfaceReliefWeight(_e109);
    weight = _e110;
    let _e112: f32 = weight;
    if (_e112 <= 0f) {
        let _e115: vec3<f32> = normal_5;
        return _e115;
    }
    let _e116: vec3<f32> = normal_5;
    let _e117: vec3<f32> = normal_5;
    let _e118: vec3<f32> = positionWS_1;
    let _e120: vec2<f32> = terrainProjectSurfaceReliefPatternGradient(_e118.xz);
    let _e121: f32 = coverage_1;
    let _e125: vec3<f32> = terrainProjectApplyReliefGradient(_e117, _e120, clamp(_e121, 0f, 1f));
    let _e126: f32 = weight;
    return normalize(mix(_e116, _e125, vec3(_e126)));
}

fn terrainProjectGroundWindCoordinates(worldXZ_20: vec2<f32>) -> vec2<f32> {
    var worldXZ_21: vec2<f32>;
    var direction: vec2<f32>;
    var perpendicular: vec2<f32>;

    worldXZ_21 = worldXZ_20;
    let _e107: vec4<f32> = global_1.scene_GroundWindMotion;
    direction = _e107.xy;
    let _e110: vec2<f32> = direction;
    let _e113: vec2<f32> = direction;
    perpendicular = vec2<f32>(-(_e110.y), _e113.x);
    let _e117: vec2<f32> = worldXZ_21;
    let _e118: vec2<f32> = perpendicular;
    let _e120: vec2<f32> = worldXZ_21;
    let _e121: vec2<f32> = direction;
    return vec2<f32>(dot(_e117, _e118), dot(_e120, _e121));
}

fn terrainProjectGroundWindBroadUv(worldXZ_22: vec2<f32>) -> vec2<f32> {
    var worldXZ_23: vec2<f32>;
    var coordinates: vec2<f32>;
    var advectionAlongWind: f32;
    var tiling: vec2<f32>;

    worldXZ_23 = worldXZ_22;
    let _e107: vec2<f32> = worldXZ_23;
    let _e108: vec2<f32> = terrainProjectGroundWindCoordinates(_e107);
    coordinates = _e108;
    let _e110: vec4<f32> = global.scene_GroundWindAdvection;
    let _e112: vec4<f32> = global_1.scene_GroundWindMotion;
    advectionAlongWind = dot(_e110.xy, _e112.xy);
    let _e119: vec4<f32> = global_1.scene_GroundWindWave;
    tiling = (vec2<f32>(0.35f, 1f) / vec2(max(_e119.y, 0.001f)));
    let _e126: vec2<f32> = coordinates;
    let _e128: f32 = advectionAlongWind;
    let _e131: vec2<f32> = tiling;
    return ((_e126 + vec2<f32>(0f, _e128)) * _e131);
}

fn terrainProjectGroundWindDetailUv(worldXZ_24: vec2<f32>) -> vec2<f32> {
    var worldXZ_25: vec2<f32>;
    var coordinates_1: vec2<f32>;
    var advectionAlongWind_1: f32;
    var tiling_1: vec2<f32>;

    worldXZ_25 = worldXZ_24;
    let _e107: vec2<f32> = worldXZ_25;
    let _e108: vec2<f32> = terrainProjectGroundWindCoordinates(_e107);
    coordinates_1 = _e108;
    let _e110: vec4<f32> = global.scene_GroundWindAdvection;
    let _e112: vec4<f32> = global_1.scene_GroundWindMotion;
    advectionAlongWind_1 = dot(_e110.xy, _e112.xy);
    let _e119: vec4<f32> = global_1.scene_GroundWindWave;
    tiling_1 = (vec2<f32>(0.35f, 1f) / vec2(max(_e119.y, 0.001f)));
    let _e126: vec2<f32> = coordinates_1;
    let _e128: f32 = advectionAlongWind_1;
    let _e129: vec4<f32> = global.scene_GroundWindShape;
    let _e134: vec2<f32> = tiling_1;
    return (((_e126 + vec2<f32>(0f, (_e128 * _e129.y))) * _e134) * 10f);
}

fn terrainProjectGroundWindAngle(broadNoise: f32, detailNoise: f32) -> f32 {
    var broadNoise_1: f32;
    var detailNoise_1: f32;

    broadNoise_1 = broadNoise;
    detailNoise_1 = detailNoise;
    let _e109: vec4<f32> = global_1.scene_GroundWindWave;
    let _e111: vec4<f32> = global_1.scene_GroundWindWave;
    let _e115: f32 = broadNoise_1;
    let _e118: vec4<f32> = global_1.scene_GroundWindWave;
    let _e122: f32 = detailNoise_1;
    return ((_e109.w - (max(_e111.x, 0f) * _e115)) + (max(_e118.z, 0f) * _e122));
}

fn terrainProjectGroundWindNormalized(angle: f32) -> f32 {
    var angle_1: f32;
    var minimumAngle: f32;
    var angleRange: f32;

    angle_1 = angle;
    let _e107: vec4<f32> = global_1.scene_GroundWindWave;
    let _e109: vec4<f32> = global_1.scene_GroundWindWave;
    minimumAngle = (_e107.w - max(_e109.x, 0f));
    let _e115: vec4<f32> = global_1.scene_GroundWindWave;
    let _e117: vec4<f32> = global_1.scene_GroundWindWave;
    angleRange = max((_e115.x + _e117.z), 0.001f);
    let _e123: f32 = angle_1;
    let _e124: f32 = minimumAngle;
    let _e126: f32 = angleRange;
    return clamp(((_e123 - _e124) / _e126), 0f, 1f);
}

fn terrainProjectGroundWindBodyWeight(rootWeight: f32) -> f32 {
    var rootWeight_1: f32;
    var weight_1: f32;
    var rootAnchor: f32;

    rootWeight_1 = rootWeight;
    let _e107: f32 = rootWeight_1;
    weight_1 = clamp(_e107, 0f, 1f);
    let _e114: f32 = weight_1;
    rootAnchor = smoothstep(0f, 0.18f, _e114);
    let _e117: f32 = rootAnchor;
    let _e120: f32 = weight_1;
    return (_e117 * mix(0.62f, 1f, _e120));
}

fn terrainProjectGroundWindAngleAt(worldXZ_26: vec2<f32>) -> f32 {
    var worldXZ_27: vec2<f32>;
    var broadNoise_2: f32;
    var detailNoise_2: f32;

    worldXZ_27 = worldXZ_26;
    let _e107: vec2<f32> = worldXZ_27;
    let _e108: vec2<f32> = terrainProjectGroundWindBroadUv(_e107);
    let _e110: vec4<f32> = textureSampleLevel(gs_wgpu_tex_scene_WindSpectrumTexture, gs_wgpu_samp_scene_WindSpectrumTexture, _e108, 0f);
    broadNoise_2 = _e110.x;
    let _e113: vec2<f32> = worldXZ_27;
    let _e114: vec2<f32> = terrainProjectGroundWindDetailUv(_e113);
    let _e116: vec4<f32> = textureSampleLevel(gs_wgpu_tex_scene_WindSpectrumTexture, gs_wgpu_samp_scene_WindSpectrumTexture, _e114, 0f);
    detailNoise_2 = _e116.x;
    let _e119: f32 = broadNoise_2;
    let _e120: f32 = detailNoise_2;
    let _e121: f32 = terrainProjectGroundWindAngle(_e119, _e120);
    return _e121;
}

fn terrainProjectGroundWindCarrierNormal(worldXZ_28: vec2<f32>, centerAngle: f32) -> vec3<f32> {
    var worldXZ_29: vec2<f32>;
    var centerAngle_1: f32;
    var sampleStep: f32;
    var heightScale: f32;
    var slopeX: f32;
    var slopeZ: f32;

    worldXZ_29 = worldXZ_28;
    centerAngle_1 = centerAngle;
    let _e109: vec4<f32> = global_1.scene_GroundWindWave;
    sampleStep = max((_e109.y / 32f), 0.2f);
    let _e116: vec4<f32> = global_1.scene_GroundWindWave;
    heightScale = (_e116.y * 0.55f);
    let _e121: vec2<f32> = worldXZ_29;
    let _e122: f32 = sampleStep;
    let _e126: f32 = terrainProjectGroundWindAngleAt((_e121 + vec2<f32>(_e122, 0f)));
    let _e127: f32 = centerAngle_1;
    let _e129: f32 = heightScale;
    let _e131: f32 = sampleStep;
    slopeX = (((_e126 - _e127) * _e129) / _e131);
    let _e134: vec2<f32> = worldXZ_29;
    let _e136: f32 = sampleStep;
    let _e139: f32 = terrainProjectGroundWindAngleAt((_e134 + vec2<f32>(0f, _e136)));
    let _e140: f32 = centerAngle_1;
    let _e142: f32 = heightScale;
    let _e144: f32 = sampleStep;
    slopeZ = (((_e139 - _e140) * _e142) / _e144);
    let _e147: f32 = slopeX;
    let _e150: f32 = slopeZ;
    return normalize(vec3<f32>(-(_e147), 1f, -(_e150)));
}

fn terrainProjectGroundWindDirectionalNormal(angle_2: f32) -> vec3<f32> {
    var angle_3: f32;
    var signedField: f32;
    var slope: f32;
    var direction_1: vec2<f32>;

    angle_3 = angle_2;
    let _e107: f32 = angle_3;
    let _e108: f32 = terrainProjectGroundWindNormalized(_e107);
    signedField = ((_e108 * 2f) - 1f);
    let _e114: f32 = signedField;
    let _e115: vec4<f32> = global_1.scene_GroundWindWave;
    let _e117: vec4<f32> = global_1.scene_GroundWindWave;
    slope = (_e114 * max((_e115.x + _e117.z), 0.001f));
    let _e124: vec4<f32> = global_1.scene_GroundWindMotion;
    direction_1 = _e124.xy;
    let _e127: vec2<f32> = direction_1;
    let _e130: f32 = slope;
    let _e133: vec2<f32> = direction_1;
    let _e136: f32 = slope;
    return normalize(vec3<f32>((-(_e127.x) * _e130), 1f, (-(_e133.y) * _e136)));
}

fn grassRotateAroundAxis(value_4: vec3<f32>, axis: vec3<f32>, angle_4: f32) -> vec3<f32> {
    var value_5: vec3<f32>;
    var axis_1: vec3<f32>;
    var angle_5: f32;
    var cosine_1: f32;
    var sine_1: f32;

    value_5 = value_4;
    axis_1 = axis;
    angle_5 = angle_4;
    let _e111: f32 = angle_5;
    cosine_1 = cos(_e111);
    let _e114: f32 = angle_5;
    sine_1 = sin(_e114);
    let _e117: vec3<f32> = value_5;
    let _e118: f32 = cosine_1;
    let _e120: vec3<f32> = axis_1;
    let _e121: vec3<f32> = value_5;
    let _e123: f32 = sine_1;
    let _e126: vec3<f32> = axis_1;
    let _e127: vec3<f32> = axis_1;
    let _e128: vec3<f32> = value_5;
    let _e132: f32 = cosine_1;
    return (((_e117 * _e118) + (cross(_e120, _e121) * _e123)) + ((_e126 * dot(_e127, _e128)) * (1f - _e132)));
}

fn grassWindPosition(rootPositionWS_2: vec3<f32>, positionWS_2: vec3<f32>, tipWeight_4: f32, carrierNormalMode: i32, carrierNormalWS: ptr<function, vec3<f32>>, bentNormalWS: ptr<function, vec3<f32>>) -> vec3<f32> {
    var rootPositionWS_3: vec3<f32>;
    var positionWS_3: vec3<f32>;
    var tipWeight_5: f32;
    var carrierNormalMode_1: i32;
    var rootWeight_2: f32;
    var direction_2: vec2<f32>;
    var unweightedAngle: f32;
    var bendAxis: vec3<f32>;
    var bodyWeight: f32;
    var bendAngle: f32;
    var local_2: vec3<f32>;
    var stem: vec3<f32>;

    rootPositionWS_3 = rootPositionWS_2;
    positionWS_3 = positionWS_2;
    tipWeight_5 = tipWeight_4;
    carrierNormalMode_1 = carrierNormalMode;
    let _e115: f32 = tipWeight_5;
    let _e119: vec4<f32> = global.scene_GroundWindShape;
    rootWeight_2 = pow(clamp(_e115, 0f, 1f), max(_e119.x, 0.05f));
    let _e125: vec4<f32> = global_1.scene_GroundWindMotion;
    direction_2 = _e125.xy;
    let _e128: vec3<f32> = rootPositionWS_3;
    let _e130: f32 = terrainProjectGroundWindAngleAt(_e128.xz);
    unweightedAngle = _e130;
    let _e132: i32 = carrierNormalMode_1;
    if (_e132 == 2i) {
        {
            let _e135: vec3<f32> = rootPositionWS_3;
            let _e137: f32 = unweightedAngle;
            let _e138: vec3<f32> = terrainProjectGroundWindCarrierNormal(_e135.xz, _e137);
            (*carrierNormalWS) = _e138;
        }
    } else {
        let _e139: i32 = carrierNormalMode_1;
        if (_e139 == 1i) {
            {
                let _e142: f32 = unweightedAngle;
                let _e143: vec3<f32> = terrainProjectGroundWindDirectionalNormal(_e142);
                (*carrierNormalWS) = _e143;
            }
        } else {
            {
                (*carrierNormalWS) = vec3<f32>(0f, 1f, 0f);
            }
        }
    }
    let _e148: vec2<f32> = direction_2;
    let _e151: vec2<f32> = direction_2;
    bendAxis = normalize(vec3<f32>(_e148.y, 0f, -(_e151.x)));
    let _e157: f32 = rootWeight_2;
    let _e158: f32 = terrainProjectGroundWindBodyWeight(_e157);
    bodyWeight = _e158;
    let _e160: f32 = unweightedAngle;
    let _e161: f32 = bodyWeight;
    bendAngle = (_e160 * _e161);
    let _e164: i32 = carrierNormalMode_1;
    if (_e164 != 0i) {
        let _e171: vec3<f32> = bendAxis;
        let _e172: f32 = bendAngle;
        let _e173: vec3<f32> = grassRotateAroundAxis(vec3<f32>(0f, 1f, 0f), _e171, _e172);
        local_2 = _e173;
    } else {
        local_2 = vec3<f32>(0f, 1f, 0f);
    }
    let _e179: vec3<f32> = local_2;
    (*bentNormalWS) = _e179;
    let _e180: vec3<f32> = positionWS_3;
    let _e181: vec3<f32> = rootPositionWS_3;
    stem = (_e180 - _e181);
    let _e184: vec3<f32> = rootPositionWS_3;
    let _e185: vec3<f32> = stem;
    let _e186: vec3<f32> = bendAxis;
    let _e187: f32 = bendAngle;
    let _e188: vec3<f32> = grassRotateAroundAxis(_e185, _e186, _e187);
    return (_e184 + _e188);
}

fn grassCulledVaryings() -> Varyings {
    var output: Varyings;

    output.rootPositionWS = vec3(0f);
    output.terrainNormalWS = vec3<f32>(0f, 1f, 0f);
    output.positionWS = vec3(0f);
    output.grassColor = vec3(0f);
    output.surfaceWeights = vec3(0f);
    output.tipWeight = 0f;
    output.windCarrierNormalWS = vec3<f32>(0f, 1f, 0f);
    output.windBentNormalWS = vec3<f32>(0f, 1f, 0f);
    output.positionCS = vec4<f32>(2f, 2f, 2f, 1f);
    let _e142: Varyings = output;
    gl_Position = _e142.positionCS;
    let _e144: Varyings = output;
    return _e144;
}

fn GrassVertex(attributes_4: Attributes) -> Varyings {
    var attributes_5: Attributes;
    var output_1: Varyings;
    var positionOS: vec3<f32>;
    var rootOS: vec3<f32>;
    var rootPosition: vec4<f32>;
    var bladeScale: f32;
    var authoredHeight: f32 = 0.16685753f;
    var tipWeight_6: f32;
    var carrierNormalMode_2: i32 = 2i;
    var worldPosition_6: vec4<f32>;

    attributes_5 = attributes_4;
    let _e109: Attributes = attributes_5;
    let _e111: Attributes = attributes_5;
    let _e112: vec3<f32> = terrainProjectDetailPositionOS(_e109.POSITION, _e111);
    positionOS = _e112;
    let _e114: Attributes = attributes_5;
    let _e115: vec3<f32> = terrainProjectDetailOriginOS(_e114);
    rootOS = _e115;
    let _e117: mat4x4<f32> = global_1.renderer_ModelMat;
    let _e118: vec3<f32> = rootOS;
    rootPosition = (_e117 * vec4<f32>(_e118.x, _e118.y, _e118.z, 1f));
    let _e127: vec4<f32> = rootPosition;
    let _e129: vec4<f32> = rootPosition;
    output_1.rootPositionWS = (_e127.xyz / vec3(_e129.w));
    output_1.terrainNormalWS = vec3<f32>(0f, 1f, 0f);
    output_1.surfaceWeights = vec3<f32>(1f, 0f, 0f);
    let _e143: Varyings = output_1;
    let _e145: f32 = terrainProjectGrassDistanceVisibility(_e143.rootPositionWS);
    bladeScale = _e145;
    let _e147: f32 = bladeScale;
    if (_e147 <= 0.0001f) {
        {
            let _e150: Varyings = grassCulledVaryings();
            return _e150;
        }
    }
    let _e151: vec3<f32> = rootOS;
    let _e152: vec3<f32> = positionOS;
    let _e153: f32 = bladeScale;
    positionOS = mix(_e151, _e152, vec3(_e153));
    let _e157: Varyings = output_1;
    let _e160: vec3<f32> = evaluateGrassBaseColor(_e157.rootPositionWS.xz);
    output_1.grassColor = _e160;
    let _e163: Attributes = attributes_5;
    let _e166: f32 = authoredHeight;
    tipWeight_6 = clamp((_e163.POSITION.y / _e166), 0f, 1f);
    let _e173: f32 = tipWeight_6;
    output_1.tipWeight = _e173;
    let _e176: mat4x4<f32> = global_1.renderer_ModelMat;
    let _e177: vec3<f32> = positionOS;
    worldPosition_6 = (_e176 * vec4<f32>(_e177.x, _e177.y, _e177.z, 1f));
    let _e185: vec4<f32> = worldPosition_6;
    let _e187: Varyings = output_1;
    let _e189: vec4<f32> = worldPosition_6;
    let _e191: f32 = tipWeight_6;
    let _e192: i32 = carrierNormalMode_2;
    let _e193: Varyings = output_1;
    let _e195: Varyings = output_1;
    var gs_output_arg0 = output_1.windCarrierNormalWS;
    var gs_output_arg1 = output_1.windBentNormalWS;
    let _e201: vec3<f32> = grassWindPosition(_e187.rootPositionWS, _e189.xyz, _e191, _e192, (&gs_output_arg0), (&gs_output_arg1));
    output_1.windCarrierNormalWS = gs_output_arg0;
    output_1.windBentNormalWS = gs_output_arg1;
    worldPosition_6.x = _e201.x;
    worldPosition_6.y = _e201.y;
    worldPosition_6.z = _e201.z;
    let _e209: vec4<f32> = worldPosition_6;
    let _e211: vec4<f32> = worldPosition_6;
    output_1.positionWS = (_e209.xyz / vec3(_e211.w));
    let _e216: mat4x4<f32> = global_1.camera_VPMat;
    let _e217: vec4<f32> = worldPosition_6;
    output_1.positionCS = (_e216 * _e217);
    let _e219: Varyings = output_1;
    gl_Position = _e219.positionCS;
    let _e221: Varyings = output_1;
    return _e221;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e106: Attributes = read_Attributes();
    input_attributes = _e106;
    let _e108: Attributes = input_attributes;
    let _e109: Varyings = GrassVertex(_e108);
    write_Varyings(_e109);
    return;
}

fn main_1() {
    let _e110: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e116: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e122: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e110.x), bitcast<f32>(_e116.y), bitcast<f32>(_e122.z));
    let _e130: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e130.w);
    let _e137: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e137.x);
    let _e144: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e144.y);
    let _e151: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e151.z);
    let _e158: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e158.w);
    gs_wgpu_main();
    let _e163: vec4<f32> = gl_Position;
    let _e165: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e163.z + _e165.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>, @location(1) NORMAL: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    NORMAL_1 = NORMAL;
    main_1();
    let _e134: vec3<f32> = rootPositionWS_4;
    let _e136: vec3<f32> = terrainNormalWS;
    let _e138: vec3<f32> = positionWS_4;
    let _e140: vec3<f32> = grassColor;
    let _e142: vec3<f32> = surfaceWeights;
    let _e144: f32 = tipWeight_7;
    let _e146: vec3<f32> = windCarrierNormalWS;
    let _e148: vec3<f32> = windBentNormalWS;
    let _e150: vec4<f32> = positionCS;
    let _e152: vec4<f32> = gl_Position;
    return VertexOutput(_e134, _e136, _e138, _e140, _e142, _e144, _e146, _e148, _e150, _e152);
}
