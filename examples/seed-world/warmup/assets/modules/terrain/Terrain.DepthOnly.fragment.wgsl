diagnostic(off, derivative_uniformity);
struct gs_Auto_1_ {
    material_TerrainRegionWorldBounds: array<vec4<f32>, 32>,
    material_TerrainRegionCount: i32,
}

struct TerrainDepthShadowVaryings {
    sourceXZ: vec2<f32>,
    sourcePositionWS: vec3<f32>,
    terrainValid: f32,
}

@group(2) @binding(1) 
var<uniform> global: gs_Auto_1_;
var<private> sourcePositionWS_1: vec3<f32>;
var<private> terrainValid_1: f32;

fn read_TerrainDepthShadowVaryings() -> TerrainDepthShadowVaryings {
    var interface_value: TerrainDepthShadowVaryings;

    let _e8: vec3<f32> = sourcePositionWS_1;
    interface_value.sourcePositionWS = _e8;
    let _e10: f32 = terrainValid_1;
    interface_value.terrainValid = _e10;
    let _e11: TerrainDepthShadowVaryings = interface_value;
    return _e11;
}

fn terrainProjectDiscardInvalidDepthShadow(varyings: TerrainDepthShadowVaryings) {
    var varyings_1: TerrainDepthShadowVaryings;

    varyings_1 = varyings;
    let _e8: TerrainDepthShadowVaryings = varyings_1;
    if (_e8.terrainValid < 0.999f) {
        discard;
    } else {
        return;
    }
}

fn TerrainDepthOnlyFragment(varyings_2: TerrainDepthShadowVaryings) {
    var varyings_3: TerrainDepthShadowVaryings;

    varyings_3 = varyings_2;
    let _e8: TerrainDepthShadowVaryings = varyings_3;
    terrainProjectDiscardInvalidDepthShadow(_e8);
    return;
}

fn gs_wgpu_main() {
    var input_varyings: TerrainDepthShadowVaryings;

    let _e6: TerrainDepthShadowVaryings = read_TerrainDepthShadowVaryings();
    input_varyings = _e6;
    let _e8: TerrainDepthShadowVaryings = input_varyings;
    TerrainDepthOnlyFragment(_e8);
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(1) sourcePositionWS: vec3<f32>, @location(2) terrainValid: f32) {
    sourcePositionWS_1 = sourcePositionWS;
    terrainValid_1 = terrainValid;
    main_1();
    return;
}
