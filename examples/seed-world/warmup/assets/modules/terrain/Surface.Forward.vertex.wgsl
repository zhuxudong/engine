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

struct Attributes {
    POSITION: vec3<f32>,
}

struct Varyings {
    uv: vec2<f32>,
    sourcePositionOSY: f32,
    positionWS: vec3<f32>,
    normalWS: vec3<f32>,
    cloudShadow: f32,
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
    @location(0) uv: vec2<f32>,
    @location(1) sourcePositionOSY: f32,
    @location(2) positionWS: vec3<f32>,
    @location(3) normalWS: vec3<f32>,
    @location(4) cloudShadow: f32,
    @location(5) positionCS: vec4<f32>,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> POSITION_1: vec3<f32>;
var<private> uv: vec2<f32>;
var<private> sourcePositionOSY: f32;
var<private> positionWS_2: vec3<f32>;
var<private> normalWS_2: vec3<f32>;
var<private> cloudShadow: f32;
var<private> positionCS: vec4<f32>;
@group(2) @binding(2) 
var<uniform> gs_wgpu_data_2_: gs_Auto_2_;
var<private> scene_EnvMapLight: EnvMapLight;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e45: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e45;
    let _e46: Attributes = interface_value;
    return _e46;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e51: Varyings = interface_value_2;
    uv = _e51.uv;
    let _e53: Varyings = interface_value_2;
    sourcePositionOSY = _e53.sourcePositionOSY;
    let _e55: Varyings = interface_value_2;
    positionWS_2 = _e55.positionWS;
    let _e57: Varyings = interface_value_2;
    normalWS_2 = _e57.normalWS;
    let _e59: Varyings = interface_value_2;
    cloudShadow = _e59.cloudShadow;
    let _e61: Varyings = interface_value_2;
    positionCS = _e61.positionCS;
    return;
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn getLightProbeIrradiance(sh: array<vec3<f32>, 9>, normal: vec3<f32>) -> vec3<f32> {
    var sh_1: array<vec3<f32>, 9>;
    var normal_1: vec3<f32>;
    var result: vec3<f32>;

    sh_1 = sh;
    normal_1 = normal;
    let _e59: vec3<f32> = sh_1[0];
    let _e62: vec3<f32> = sh_1[1];
    let _e63: vec3<f32> = normal_1;
    let _e69: vec3<f32> = sh_1[2];
    let _e70: vec3<f32> = normal_1;
    let _e76: vec3<f32> = sh_1[3];
    let _e77: vec3<f32> = normal_1;
    let _e83: vec3<f32> = sh_1[4];
    let _e84: vec3<f32> = normal_1;
    let _e86: vec3<f32> = normal_1;
    let _e93: vec3<f32> = sh_1[5];
    let _e94: vec3<f32> = normal_1;
    let _e96: vec3<f32> = normal_1;
    let _e103: vec3<f32> = sh_1[6];
    let _e105: vec3<f32> = normal_1;
    let _e108: vec3<f32> = normal_1;
    let _e117: vec3<f32> = sh_1[7];
    let _e118: vec3<f32> = normal_1;
    let _e120: vec3<f32> = normal_1;
    let _e127: vec3<f32> = sh_1[8];
    let _e128: vec3<f32> = normal_1;
    let _e130: vec3<f32> = normal_1;
    let _e133: vec3<f32> = normal_1;
    let _e135: vec3<f32> = normal_1;
    result = ((((((((_e59 + (_e62 * _e63.y)) + (_e69 * _e70.z)) + (_e76 * _e77.x)) + (_e83 * (_e84.y * _e86.x))) + (_e93 * (_e94.y * _e96.z))) + (_e103 * (((3f * _e105.z) * _e108.z) - 1f))) + (_e117 * (_e118.z * _e120.x))) + (_e127 * ((_e128.x * _e130.x) - (_e133.y * _e135.y))));
    let _e142: vec3<f32> = result;
    return max(_e142, vec3(0f));
}

fn getGlobalDiffuseIrradiance(normalWS: vec3<f32>) -> vec3<f32> {
    var normalWS_1: vec3<f32>;

    normalWS_1 = normalWS;
    let _e55: EnvMapLight = scene_EnvMapLight;
    return (_e55.diffuse * 3.1415927f);
}

fn sampleVolumetricCloudShadow(positionWS: vec3<f32>) -> f32 {
    var positionWS_1: vec3<f32>;

    positionWS_1 = positionWS;
    return 1f;
}

fn SurfaceVertex(attributes: Attributes) -> Varyings {
    var attributes_1: Attributes;
    var varyings: Varyings;
    var positionOS: vec4<f32>;
    var normalOS: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var homogeneousPositionWS: vec4<f32>;
    var proceduralTreeTangentWS: vec3<f32> = vec3(0f);

    attributes_1 = attributes;
    let _e56: Attributes = attributes_1;
    positionOS = vec4<f32>(_e56.POSITION.x, _e56.POSITION.y, _e56.POSITION.z, 1f);
    let _e70: vec4<f32> = positionOS;
    varyings.sourcePositionOSY = _e70.y;
    varyings.uv = vec2(0f);
    let _e75: mat4x4<f32> = global_1.renderer_ModelMat;
    let _e76: vec4<f32> = positionOS;
    homogeneousPositionWS = (_e75 * _e76);
    let _e80: vec4<f32> = homogeneousPositionWS;
    let _e82: vec4<f32> = homogeneousPositionWS;
    varyings.positionWS = (_e80.xyz / vec3(_e82.w));
    let _e87: mat4x4<f32> = global_1.renderer_NormalMat;
    let _e97: vec3<f32> = normalOS;
    varyings.normalWS = normalize((mat3x3<f32>(_e87[0].xyz, _e87[1].xyz, _e87[2].xyz) * _e97));
    let _e104: Varyings = varyings;
    let _e106: f32 = sampleVolumetricCloudShadow(_e104.positionWS);
    varyings.cloudShadow = _e106;
    let _e108: mat4x4<f32> = global_1.renderer_MVPMat;
    let _e109: vec4<f32> = positionOS;
    varyings.positionCS = (_e108 * _e109);
    let _e112: Varyings = varyings;
    gl_Position = _e112.positionCS;
    let _e114: Varyings = varyings;
    return _e114;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e54: Attributes = read_Attributes();
    input_attributes = _e54;
    let _e56: Attributes = input_attributes;
    let _e57: Varyings = SurfaceVertex(_e56);
    write_Varyings(_e57);
    return;
}

fn main_1() {
    let _e58: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e64: vec4<u32> = gs_wgpu_data_2_.words[0];
    let _e70: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.diffuse = vec3<f32>(bitcast<f32>(_e58.x), bitcast<f32>(_e64.y), bitcast<f32>(_e70.z));
    let _e78: vec4<u32> = gs_wgpu_data_2_.words[0];
    scene_EnvMapLight.mipMapLevel = bitcast<f32>(_e78.w);
    let _e85: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.diffuseIntensity = bitcast<f32>(_e85.x);
    let _e92: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularIntensity = bitcast<f32>(_e92.y);
    let _e99: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.mipMapLevel2_ = bitcast<f32>(_e99.z);
    let _e106: vec4<u32> = gs_wgpu_data_2_.words[1];
    scene_EnvMapLight.specularTextureBlend = bitcast<f32>(_e106.w);
    gs_wgpu_main();
    let _e111: vec4<f32> = gl_Position;
    let _e113: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e111.z + _e113.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e64: vec2<f32> = uv;
    let _e66: f32 = sourcePositionOSY;
    let _e68: vec3<f32> = positionWS_2;
    let _e70: vec3<f32> = normalWS_2;
    let _e72: f32 = cloudShadow;
    let _e74: vec4<f32> = positionCS;
    let _e76: vec4<f32> = gl_Position;
    return VertexOutput(_e64, _e66, _e68, _e70, _e72, _e74, _e76);
}
