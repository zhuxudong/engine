diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    renderer_ModelMat: mat4x4<f32>,
    renderer_MVPMat: mat4x4<f32>,
    camera_DepthBufferParams: vec4<f32>,
    camera_ProjectionParams: vec4<f32>,
    camera_Position: vec3<f32>,
    scene_ElapsedTime: vec4<f32>,
    scene_WindVelocity: vec3<f32>,
    material_WindVelocity: vec3<f32>,
    material_WindVelocityOverride: f32,
    material_AppearanceV2Detail0Enabled: f32,
    material_AppearanceV2DetailEnabled: f32,
    material_AppearanceV2DetailNormalStrength: f32,
    material_AppearanceV2Detail0Transform: vec4<f32>,
    material_AppearanceV2Detail0Rotation: vec2<f32>,
    material_AppearanceV2Detail0Strength: f32,
    material_LocalMapDecode: vec4<f32>,
    material_SurfaceTimeOverride: f32,
    material_MicroNormalsEnabled: f32,
    material_Roughness: f32,
    material_ScreenSpaceReflectionIntensity: f32,
    camera_SSRParams: vec4<f32>,
    scene_WeatherState: vec4<f32>,
}

struct Attributes {
    POSITION: vec4<f32>,
    NORMAL: vec3<f32>,
    TANGENT: vec4<f32>,
    TEXCOORD_0_: vec2<f32>,
}

struct Varyings {
    worldPosition: vec3<f32>,
    objectPosition: vec3<f32>,
    meshUv: vec2<f32>,
    macroNormalWS: vec3<f32>,
    baseNormalWS: vec3<f32>,
    tangentWS: vec3<f32>,
    atlasUv: vec2<f32>,
    waveOffset: f32,
}

struct VertexOutput {
    @location(0) worldPosition: vec3<f32>,
    @location(1) objectPosition: vec3<f32>,
    @location(2) meshUv: vec2<f32>,
    @location(3) macroNormalWS: vec3<f32>,
    @location(4) baseNormalWS: vec3<f32>,
    @location(5) tangentWS: vec3<f32>,
    @location(6) atlasUv: vec2<f32>,
    @location(7) waveOffset: f32,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
var<private> POSITION_1: vec4<f32>;
var<private> NORMAL_1: vec3<f32>;
var<private> TANGENT_1: vec4<f32>;
var<private> TEXCOORD_0_1: vec2<f32>;
var<private> worldPosition: vec3<f32>;
var<private> objectPosition: vec3<f32>;
var<private> meshUv: vec2<f32>;
var<private> macroNormalWS: vec3<f32>;
var<private> baseNormalWS: vec3<f32>;
var<private> tangentWS: vec3<f32>;
var<private> atlasUv: vec2<f32>;
var<private> waveOffset_1: f32;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e50: vec4<f32> = POSITION_1;
    interface_value.POSITION = _e50;
    let _e52: vec3<f32> = NORMAL_1;
    interface_value.NORMAL = _e52;
    let _e54: vec4<f32> = TANGENT_1;
    interface_value.TANGENT = _e54;
    let _e56: vec2<f32> = TEXCOORD_0_1;
    interface_value.TEXCOORD_0_ = _e56;
    let _e57: Attributes = interface_value;
    return _e57;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e58: Varyings = interface_value_2;
    worldPosition = _e58.worldPosition;
    let _e60: Varyings = interface_value_2;
    objectPosition = _e60.objectPosition;
    let _e62: Varyings = interface_value_2;
    meshUv = _e62.meshUv;
    let _e64: Varyings = interface_value_2;
    macroNormalWS = _e64.macroNormalWS;
    let _e66: Varyings = interface_value_2;
    baseNormalWS = _e66.baseNormalWS;
    let _e68: Varyings = interface_value_2;
    tangentWS = _e68.tangentWS;
    let _e70: Varyings = interface_value_2;
    atlasUv = _e70.atlasUv;
    let _e72: Varyings = interface_value_2;
    waveOffset_1 = _e72.waveOffset;
    return;
}

fn vert(attr: Attributes) -> Varyings {
    var attr_1: Attributes;
    var varyings: Varyings;
    var baseWorldPosition: vec4<f32>;
    var computedBaseNormalWS: vec3<f32>;
    var computedBaseTangentWS: vec3<f32>;
    var computedBaseBitangentWS: vec3<f32>;
    var waveOffset: f32 = 0f;
    var tangentSlope: f32 = 0f;
    var bitangentSlope: f32 = 0f;
    var computedMacroNormalWS: vec3<f32>;
    var localPosition: vec4<f32>;

    attr_1 = attr;
    let _e59: mat4x4<f32> = global.renderer_ModelMat;
    let _e60: Attributes = attr_1;
    baseWorldPosition = (_e59 * _e60.POSITION);
    let _e64: mat4x4<f32> = global.renderer_ModelMat;
    let _e74: Attributes = attr_1;
    computedBaseNormalWS = normalize((mat3x3<f32>(_e64[0].xyz, _e64[1].xyz, _e64[2].xyz) * _e74.NORMAL));
    let _e79: mat4x4<f32> = global.renderer_ModelMat;
    let _e89: Attributes = attr_1;
    computedBaseTangentWS = normalize((mat3x3<f32>(_e79[0].xyz, _e79[1].xyz, _e79[2].xyz) * _e89.TANGENT.xyz));
    let _e95: vec3<f32> = computedBaseNormalWS;
    let _e96: vec3<f32> = computedBaseTangentWS;
    let _e98: Attributes = attr_1;
    computedBaseBitangentWS = normalize((cross(_e95, _e96) * _e98.TANGENT.w));
    let _e110: vec3<f32> = computedBaseNormalWS;
    let _e111: vec3<f32> = computedBaseTangentWS;
    let _e112: f32 = tangentSlope;
    let _e115: vec3<f32> = computedBaseBitangentWS;
    let _e116: f32 = bitangentSlope;
    computedMacroNormalWS = normalize(((_e110 - (_e111 * _e112)) - (_e115 * _e116)));
    let _e121: Attributes = attr_1;
    let _e123: Attributes = attr_1;
    let _e125: f32 = waveOffset;
    let _e126: vec3<f32> = (_e123.NORMAL * _e125);
    localPosition = (_e121.POSITION + vec4<f32>(_e126.x, _e126.y, _e126.z, 0f));
    let _e135: mat4x4<f32> = global.renderer_MVPMat;
    let _e136: vec4<f32> = localPosition;
    gl_Position = (_e135 * _e136);
    let _e139: vec4<f32> = baseWorldPosition;
    let _e141: vec3<f32> = computedBaseNormalWS;
    let _e142: f32 = waveOffset;
    varyings.worldPosition = (_e139.xyz + (_e141 * _e142));
    let _e146: Attributes = attr_1;
    varyings.objectPosition = _e146.POSITION.xyz;
    let _e150: Attributes = attr_1;
    varyings.meshUv = _e150.TEXCOORD_0_;
    let _e153: vec3<f32> = computedMacroNormalWS;
    varyings.macroNormalWS = _e153;
    let _e155: vec3<f32> = computedBaseNormalWS;
    varyings.baseNormalWS = _e155;
    let _e157: vec3<f32> = computedBaseTangentWS;
    varyings.tangentWS = _e157;
    let _e159: Attributes = attr_1;
    varyings.atlasUv = _e159.TEXCOORD_0_;
    let _e162: f32 = waveOffset;
    varyings.waveOffset = _e162;
    let _e163: Varyings = varyings;
    return _e163;
}

fn gs_wgpu_main() {
    var input_attr: Attributes;

    let _e57: Attributes = read_Attributes();
    input_attr = _e57;
    let _e59: Attributes = input_attr;
    let _e60: Varyings = vert(_e59);
    write_Varyings(_e60);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e59: vec4<f32> = gl_Position;
    let _e61: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e59.z + _e61.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec4<f32>, @location(1) NORMAL: vec3<f32>, @location(2) TANGENT: vec4<f32>, @location(3) TEXCOORD_0_: vec2<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    NORMAL_1 = NORMAL;
    TANGENT_1 = TANGENT;
    TEXCOORD_0_1 = TEXCOORD_0_;
    main_1();
    let _e77: vec3<f32> = worldPosition;
    let _e79: vec3<f32> = objectPosition;
    let _e81: vec2<f32> = meshUv;
    let _e83: vec3<f32> = macroNormalWS;
    let _e85: vec3<f32> = baseNormalWS;
    let _e87: vec3<f32> = tangentWS;
    let _e89: vec2<f32> = atlasUv;
    let _e91: f32 = waveOffset_1;
    let _e93: vec4<f32> = gl_Position;
    return VertexOutput(_e77, _e79, _e81, _e83, _e85, _e87, _e89, _e91, _e93);
}
