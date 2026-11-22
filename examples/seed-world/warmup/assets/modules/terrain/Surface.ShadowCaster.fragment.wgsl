diagnostic(off, derivative_uniformity);
struct SurfaceDepthShadowVaryings {
    _emptyVaryingPad: f32,
}

struct FragmentOutput {
    @location(0) converted_FragColor: vec4<f32>,
}

var<private> converted_FragColor: vec4<f32>;
var<private> gl_FragCoord_1: vec4<f32>;

fn terrainProjectLodFade() -> f32 {
    return 1f;
}

fn applyTerrainProjectInstanceLodDither(fragmentPosition: vec2<f32>, instanceLodFade: f32) {
    var fragmentPosition_1: vec2<f32>;
    var instanceLodFade_1: f32;

    fragmentPosition_1 = fragmentPosition;
    instanceLodFade_1 = instanceLodFade;
    return;
}

fn applyTerrainProjectLodDither(fragmentPosition_2: vec2<f32>) {
    var fragmentPosition_3: vec2<f32>;

    fragmentPosition_3 = fragmentPosition_2;
    return;
}

fn terrainProjectShadowColor() -> vec4<f32> {
    return vec4(0f);
}

fn read_SurfaceDepthShadowVaryings() -> SurfaceDepthShadowVaryings {
    var interface_value: SurfaceDepthShadowVaryings;

    let _e2: SurfaceDepthShadowVaryings = interface_value;
    return _e2;
}

fn terrainProjectDiscardInvalidSurfaceDepthShadow(varyings: SurfaceDepthShadowVaryings) {
    var varyings_1: SurfaceDepthShadowVaryings;

    varyings_1 = varyings;
    let _e4: vec4<f32> = gl_FragCoord_1;
    applyTerrainProjectLodDither(_e4.xy);
    return;
}

fn SurfaceShadowFragment(varyings_2: SurfaceDepthShadowVaryings) {
    var varyings_3: SurfaceDepthShadowVaryings;

    varyings_3 = varyings_2;
    let _e4: SurfaceDepthShadowVaryings = varyings_3;
    terrainProjectDiscardInvalidSurfaceDepthShadow(_e4);
    let _e5: vec4<f32> = terrainProjectShadowColor();
    converted_FragColor = _e5;
    return;
}

fn gs_wgpu_main() {
    var input_varyings: SurfaceDepthShadowVaryings;

    let _e2: SurfaceDepthShadowVaryings = read_SurfaceDepthShadowVaryings();
    input_varyings = _e2;
    let _e4: SurfaceDepthShadowVaryings = input_varyings;
    SurfaceShadowFragment(_e4);
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@builtin(position) gl_FragCoord: vec4<f32>) -> FragmentOutput {
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    let _e5: vec4<f32> = converted_FragColor;
    return FragmentOutput(_e5);
}
