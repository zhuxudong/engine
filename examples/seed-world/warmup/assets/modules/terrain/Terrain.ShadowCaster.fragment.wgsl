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

struct FragmentOutput {
    @location(0) converted_FragColor: vec4<f32>,
}

@group(2) @binding(1) 
var<uniform> global: gs_Auto_1_;
var<private> converted_FragColor: vec4<f32>;
var<private> sourcePositionWS_1: vec3<f32>;
var<private> terrainValid_1: f32;

fn terrainProjectShadowColor() -> vec4<f32> {
    return vec4(0f);
}

fn read_TerrainDepthShadowVaryings() -> TerrainDepthShadowVaryings {
    var interface_value: TerrainDepthShadowVaryings;

    let _e9: vec3<f32> = sourcePositionWS_1;
    interface_value.sourcePositionWS = _e9;
    let _e11: f32 = terrainValid_1;
    interface_value.terrainValid = _e11;
    let _e12: TerrainDepthShadowVaryings = interface_value;
    return _e12;
}

fn terrainProjectDiscardInvalidDepthShadow(varyings: TerrainDepthShadowVaryings) {
    var varyings_1: TerrainDepthShadowVaryings;

    varyings_1 = varyings;
    let _e9: TerrainDepthShadowVaryings = varyings_1;
    if (_e9.terrainValid < 0.999f) {
        discard;
    } else {
        return;
    }
}

fn TerrainShadowFragment(varyings_2: TerrainDepthShadowVaryings) {
    var varyings_3: TerrainDepthShadowVaryings;

    varyings_3 = varyings_2;
    let _e9: TerrainDepthShadowVaryings = varyings_3;
    terrainProjectDiscardInvalidDepthShadow(_e9);
    let _e10: vec4<f32> = terrainProjectShadowColor();
    converted_FragColor = _e10;
    return;
}

fn gs_wgpu_main() {
    var input_varyings: TerrainDepthShadowVaryings;

    let _e7: TerrainDepthShadowVaryings = read_TerrainDepthShadowVaryings();
    input_varyings = _e7;
    let _e9: TerrainDepthShadowVaryings = input_varyings;
    TerrainShadowFragment(_e9);
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(1) sourcePositionWS: vec3<f32>, @location(2) terrainValid: f32) -> FragmentOutput {
    sourcePositionWS_1 = sourcePositionWS;
    terrainValid_1 = terrainValid;
    main_1();
    let _e15: vec4<f32> = converted_FragColor;
    return FragmentOutput(_e15);
}
