diagnostic(off, derivative_uniformity);
struct SurfaceDepthShadowVaryings {
    _emptyVaryingPad: f32,
}

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

fn read_SurfaceDepthShadowVaryings() -> SurfaceDepthShadowVaryings {
    var interface_value: SurfaceDepthShadowVaryings;

    let _e1: SurfaceDepthShadowVaryings = interface_value;
    return _e1;
}

fn terrainProjectDiscardInvalidSurfaceDepthShadow(varyings: SurfaceDepthShadowVaryings) {
    var varyings_1: SurfaceDepthShadowVaryings;

    varyings_1 = varyings;
    let _e3: vec4<f32> = gl_FragCoord_1;
    applyTerrainProjectLodDither(_e3.xy);
    return;
}

fn SurfaceDepthOnlyFragment(varyings_2: SurfaceDepthShadowVaryings) {
    var varyings_3: SurfaceDepthShadowVaryings;

    varyings_3 = varyings_2;
    let _e3: SurfaceDepthShadowVaryings = varyings_3;
    terrainProjectDiscardInvalidSurfaceDepthShadow(_e3);
    return;
}

fn gs_wgpu_main() {
    var input_varyings: SurfaceDepthShadowVaryings;

    let _e1: SurfaceDepthShadowVaryings = read_SurfaceDepthShadowVaryings();
    input_varyings = _e1;
    let _e3: SurfaceDepthShadowVaryings = input_varyings;
    SurfaceDepthOnlyFragment(_e3);
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@builtin(position) gl_FragCoord: vec4<f32>) {
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    return;
}
