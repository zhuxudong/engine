diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    renderer_NormalMat: mat4x4<f32>,
}

struct Attributes {
    POSITION: vec3<f32>,
}

struct SurfaceDepthShadowVaryings {
    _emptyVaryingPad: f32,
}

struct VertexOutput {
    @location(0) _emptyVaryingPad: f32,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
var<private> POSITION_1: vec3<f32>;
var<private> _emptyVaryingPad: f32;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e9: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e9;
    let _e10: Attributes = interface_value;
    return _e10;
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn write_SurfaceDepthShadowVaryings(interface_value_1: SurfaceDepthShadowVaryings) {
    var interface_value_2: SurfaceDepthShadowVaryings;

    interface_value_2 = interface_value_1;
    let _e10: SurfaceDepthShadowVaryings = interface_value_2;
    _emptyVaryingPad = _e10._emptyVaryingPad;
    return;
}

fn terrainProjectBuildSurfaceDepthShadowVaryings(attributes: Attributes) -> SurfaceDepthShadowVaryings {
    var attributes_1: Attributes;
    var varyings: SurfaceDepthShadowVaryings;
    var positionOS: vec4<f32>;
    var normalOS: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var positionWS: vec3<f32>;
    var normalWS: vec3<f32>;

    attributes_1 = attributes;
    let _e11: Attributes = attributes_1;
    positionOS = vec4<f32>(_e11.POSITION.x, _e11.POSITION.y, _e11.POSITION.z, 1f);
    let _e24: mat4x4<f32> = global.renderer_ModelMat;
    let _e25: vec4<f32> = positionOS;
    positionWS = (_e24 * _e25).xyz;
    let _e29: mat4x4<f32> = global.renderer_NormalMat;
    let _e39: vec3<f32> = normalOS;
    normalWS = normalize((mat3x3<f32>(_e29[0].xyz, _e29[1].xyz, _e29[2].xyz) * _e39));
    varyings._emptyVaryingPad = 0f;
    let _e46: mat4x4<f32> = global.camera_VPMat;
    let _e47: vec3<f32> = positionWS;
    gl_Position = (_e46 * vec4<f32>(_e47.x, _e47.y, _e47.z, 1f));
    let _e54: SurfaceDepthShadowVaryings = varyings;
    return _e54;
}

fn SurfaceDepthOnlyVertex(attributes_2: Attributes) -> SurfaceDepthShadowVaryings {
    var attributes_3: Attributes;

    attributes_3 = attributes_2;
    let _e11: Attributes = attributes_3;
    let _e12: SurfaceDepthShadowVaryings = terrainProjectBuildSurfaceDepthShadowVaryings(_e11);
    return _e12;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e9: Attributes = read_Attributes();
    input_attributes = _e9;
    let _e11: Attributes = input_attributes;
    let _e12: SurfaceDepthShadowVaryings = SurfaceDepthOnlyVertex(_e11);
    write_SurfaceDepthShadowVaryings(_e12);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e11: vec4<f32> = gl_Position;
    let _e13: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e11.z + _e13.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e13: f32 = _emptyVaryingPad;
    let _e15: vec4<f32> = gl_Position;
    return VertexOutput(_e13, _e15);
}
