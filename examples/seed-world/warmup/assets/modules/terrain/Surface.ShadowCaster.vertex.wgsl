diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    renderer_NormalMat: mat4x4<f32>,
    scene_ShadowBias: vec2<f32>,
    scene_LightDirection: vec3<f32>,
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

    let _e13: vec3<f32> = POSITION_1;
    interface_value.POSITION = _e13;
    let _e14: Attributes = interface_value;
    return _e14;
}

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn applyTerrainProjectShadowBias(positionWS: vec3<f32>, normalWS: vec3<f32>) -> vec3<f32> {
    var positionWS_1: vec3<f32>;
    var normalWS_1: vec3<f32>;
    var inverseNdotL: f32;

    positionWS_1 = positionWS;
    normalWS_1 = normalWS;
    let _e15: vec3<f32> = positionWS_1;
    let _e16: vec3<f32> = global.scene_LightDirection;
    let _e17: vec2<f32> = global.scene_ShadowBias;
    positionWS_1 = (_e15 - (_e16 * _e17.x));
    let _e22: vec3<f32> = global.scene_LightDirection;
    let _e24: vec3<f32> = normalWS_1;
    inverseNdotL = (1f - clamp(dot(-(_e22), _e24), 0f, 1f));
    let _e31: vec3<f32> = positionWS_1;
    let _e32: vec3<f32> = normalWS_1;
    let _e33: f32 = inverseNdotL;
    let _e34: vec2<f32> = global.scene_ShadowBias;
    return (_e31 + (_e32 * (_e33 * _e34.y)));
}

fn terrainProjectShadowClipPosition(positionWS_2: vec3<f32>) -> vec4<f32> {
    var positionWS_3: vec3<f32>;
    var positionCS: vec4<f32>;

    positionWS_3 = positionWS_2;
    let _e13: mat4x4<f32> = global.camera_VPMat;
    let _e14: vec3<f32> = positionWS_3;
    positionCS = (_e13 * vec4<f32>(_e14.x, _e14.y, _e14.z, 1f));
    let _e23: vec4<f32> = positionCS;
    positionCS.z = max(_e23.z, -1f);
    let _e28: vec4<f32> = positionCS;
    return _e28;
}

fn write_SurfaceDepthShadowVaryings(interface_value_1: SurfaceDepthShadowVaryings) {
    var interface_value_2: SurfaceDepthShadowVaryings;

    interface_value_2 = interface_value_1;
    let _e14: SurfaceDepthShadowVaryings = interface_value_2;
    _emptyVaryingPad = _e14._emptyVaryingPad;
    return;
}

fn terrainProjectBuildSurfaceDepthShadowVaryings(attributes: Attributes) -> SurfaceDepthShadowVaryings {
    var attributes_1: Attributes;
    var varyings: SurfaceDepthShadowVaryings;
    var positionOS: vec4<f32>;
    var normalOS: vec3<f32> = vec3<f32>(0f, 1f, 0f);
    var positionWS_4: vec3<f32>;
    var normalWS_2: vec3<f32>;

    attributes_1 = attributes;
    let _e15: Attributes = attributes_1;
    positionOS = vec4<f32>(_e15.POSITION.x, _e15.POSITION.y, _e15.POSITION.z, 1f);
    let _e28: mat4x4<f32> = global.renderer_ModelMat;
    let _e29: vec4<f32> = positionOS;
    positionWS_4 = (_e28 * _e29).xyz;
    let _e33: mat4x4<f32> = global.renderer_NormalMat;
    let _e43: vec3<f32> = normalOS;
    normalWS_2 = normalize((mat3x3<f32>(_e33[0].xyz, _e33[1].xyz, _e33[2].xyz) * _e43));
    varyings._emptyVaryingPad = 0f;
    let _e50: vec3<f32> = positionWS_4;
    let _e51: vec3<f32> = normalWS_2;
    let _e52: vec3<f32> = applyTerrainProjectShadowBias(_e50, _e51);
    let _e53: vec4<f32> = terrainProjectShadowClipPosition(_e52);
    gl_Position = _e53;
    let _e54: SurfaceDepthShadowVaryings = varyings;
    return _e54;
}

fn SurfaceShadowVertex(attributes_2: Attributes) -> SurfaceDepthShadowVaryings {
    var attributes_3: Attributes;

    attributes_3 = attributes_2;
    let _e15: Attributes = attributes_3;
    let _e16: SurfaceDepthShadowVaryings = terrainProjectBuildSurfaceDepthShadowVaryings(_e15);
    return _e16;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e13: Attributes = read_Attributes();
    input_attributes = _e13;
    let _e15: Attributes = input_attributes;
    let _e16: SurfaceDepthShadowVaryings = SurfaceShadowVertex(_e15);
    write_SurfaceDepthShadowVaryings(_e16);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e15: vec4<f32> = gl_Position;
    let _e17: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e15.z + _e17.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec3<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    main_1();
    let _e17: f32 = _emptyVaryingPad;
    let _e19: vec4<f32> = gl_Position;
    return VertexOutput(_e17, _e19);
}
