diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ViewMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
}

struct gs_Auto_1_ {
    camera_ProjMat: mat4x4<f32>,
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    material_WaterLevel: f32,
    material_OceanFarProjection: vec4<f32>,
    scene_SunlightColor: vec4<f32>,
    scene_SunlightDirection: vec3<f32>,
    material_EnvironmentReflectionParameters: vec4<f32>,
    material_EnvironmentFallbackIntensity: f32,
    material_EnvironmentReflectionMaximumMip: f32,
    material_EnvironmentReflectionAvailable: f32,
    material_AbsorptionCoefficient: vec3<f32>,
    material_ScatteringColor: vec3<f32>,
    material_ScatteringCoefficient: f32,
    material_IndexOfRefraction: f32,
    material_MaximumSurfaceOpticalDistance: f32,
    material_ReflectionIntensity: f32,
    material_Roughness: f32,
    material_NearshoreWorldToUv: vec4<f32>,
    material_NearshoreDecode: vec4<f32>,
    material_NearshoreOutsidePolicy: vec4<f32>,
    material_NearshoreCellSize: vec2<f32>,
    material_OceanDeepColor: vec4<f32>,
    material_OceanHorizonColor: vec4<f32>,
    material_OceanFarReflectionFilter: vec2<f32>,
}

struct Attributes {
    POSITION: vec4<f32>,
    TEXCOORD_0_: vec2<f32>,
}

struct Varyings {
    worldPosition: vec3<f32>,
    positionVS: vec3<f32>,
}

struct VertexOutput {
    @location(0) worldPosition: vec3<f32>,
    @location(1) positionVS: vec3<f32>,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> POSITION_1: vec4<f32>;
var<private> TEXCOORD_0_1: vec2<f32>;
var<private> worldPosition: vec3<f32>;
var<private> positionVS: vec3<f32>;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e58: vec4<f32> = POSITION_1;
    interface_value.POSITION = _e58;
    let _e60: vec2<f32> = TEXCOORD_0_1;
    interface_value.TEXCOORD_0_ = _e60;
    let _e61: Attributes = interface_value;
    return _e61;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e60: Varyings = interface_value_2;
    worldPosition = _e60.worldPosition;
    let _e62: Varyings = interface_value_2;
    positionVS = _e62.positionVS;
    return;
}

fn vert(attributes: Attributes) -> Varyings {
    var attributes_1: Attributes;
    var output: Varyings;
    var localWorldPosition: vec4<f32>;
    var outerVertex: f32;
    var viewportHeight: f32;
    var projectionScaleY: f32;
    var cameraHeight: f32;
    var projectionDistance: f32;
    var outerDirection: vec2<f32>;
    var projectedWorldXZ: vec2<f32>;
    var projectedWorldPosition: vec4<f32>;
    var surfaceWorldPosition: vec4<f32>;
    var clipPosition: vec4<f32>;

    attributes_1 = attributes;
    let _e61: mat4x4<f32> = global_1.renderer_ModelMat;
    let _e62: Attributes = attributes_1;
    localWorldPosition = (_e61 * _e62.POSITION);
    let _e67: vec4<f32> = localWorldPosition;
    let _e69: f32 = global_1.material_WaterLevel;
    localWorldPosition.y = (_e67.y + _e69);
    let _e72: Attributes = attributes_1;
    outerVertex = step(0.5f, _e72.TEXCOORD_0_.x);
    let _e77: vec4<f32> = global_1.material_OceanFarProjection;
    viewportHeight = max(_e77.x, 1f);
    let _e86: f32 = global_1.camera_ProjMat[1][1];
    projectionScaleY = max(abs(_e86), 0.0001f);
    let _e91: vec3<f32> = global.camera_Position;
    let _e93: vec4<f32> = localWorldPosition;
    cameraHeight = max((_e91.y - _e93.y), 0f);
    let _e99: f32 = cameraHeight;
    let _e100: f32 = viewportHeight;
    let _e102: f32 = projectionScaleY;
    projectionDistance = (((_e99 * _e100) * _e102) / 1f);
    let _e107: f32 = projectionDistance;
    let _e108: vec4<f32> = global_1.material_OceanFarProjection;
    projectionDistance = clamp(_e107, _e108.y, 10000000f);
    let _e112: Attributes = attributes_1;
    outerDirection = normalize(_e112.POSITION.xz);
    let _e117: vec3<f32> = global.camera_Position;
    let _e119: vec2<f32> = outerDirection;
    let _e120: f32 = projectionDistance;
    projectedWorldXZ = (_e117.xz + (_e119 * _e120));
    let _e124: vec2<f32> = projectedWorldXZ;
    let _e126: vec4<f32> = localWorldPosition;
    let _e128: vec2<f32> = projectedWorldXZ;
    projectedWorldPosition = vec4<f32>(_e124.x, _e126.y, _e128.y, 1f);
    let _e133: vec4<f32> = localWorldPosition;
    let _e134: vec4<f32> = projectedWorldPosition;
    let _e135: f32 = outerVertex;
    surfaceWorldPosition = mix(_e133, _e134, vec4(_e135));
    let _e139: mat4x4<f32> = global_1.camera_VPMat;
    let _e140: vec4<f32> = surfaceWorldPosition;
    clipPosition = (_e139 * _e140);
    let _e144: vec4<f32> = clipPosition;
    let _e146: vec4<f32> = clipPosition;
    let _e150: f32 = outerVertex;
    clipPosition.z = mix(_e144.z, (_e146.w * 0.99999f), _e150);
    let _e153: vec4<f32> = surfaceWorldPosition;
    output.worldPosition = _e153.xyz;
    let _e156: mat4x4<f32> = global.camera_ViewMat;
    let _e157: vec4<f32> = surfaceWorldPosition;
    output.positionVS = (_e156 * _e157).xyz;
    let _e161: vec4<f32> = clipPosition;
    gl_Position = _e161;
    let _e162: Varyings = output;
    return _e162;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e59: Attributes = read_Attributes();
    input_attributes = _e59;
    let _e61: Attributes = input_attributes;
    let _e62: Varyings = vert(_e61);
    write_Varyings(_e62);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e61: vec4<f32> = gl_Position;
    let _e63: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e61.z + _e63.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec4<f32>, @location(1) TEXCOORD_0_: vec2<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    TEXCOORD_0_1 = TEXCOORD_0_;
    main_1();
    let _e67: vec3<f32> = worldPosition;
    let _e69: vec3<f32> = positionVS;
    let _e71: vec4<f32> = gl_Position;
    return VertexOutput(_e67, _e69, _e71);
}
