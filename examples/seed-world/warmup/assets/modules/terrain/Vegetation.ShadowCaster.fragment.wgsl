diagnostic(off, derivative_uniformity);
struct gs_Auto_1_ {
    material_AlphaCutoff: f32,
}

struct Varyings {
    uv: vec2<f32>,
}

struct FragmentOutput {
    @location(0) converted_FragColor: vec4<f32>,
}

@group(2) @binding(1) 
var<uniform> global: gs_Auto_1_;
var<private> converted_FragColor: vec4<f32>;
var<private> uv_3: vec2<f32>;
var<private> gl_FragCoord_1: vec4<f32>;

fn texture2DSRGB(gs_wgpu_tex_tex: texture_2d<f32>, gs_wgpu_samp_tex: sampler, uv_1: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;

    uv_2 = uv_1;
    let _e7: vec2<f32> = uv_2;
    let _e8: vec4<f32> = textureSample(gs_wgpu_tex_tex, gs_wgpu_samp_tex, _e7);
    return _e8;
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e6: vec2<f32> = uv_3;
    interface_value.uv = _e6;
    let _e7: Varyings = interface_value;
    return _e7;
}

fn sampleVegetationBaseTexture(materialUv: vec2<f32>) -> vec4<f32> {
    var materialUv_1: vec2<f32>;
    var baseTexture: vec4<f32> = vec4(1f);

    materialUv_1 = materialUv;
    let _e9: vec4<f32> = baseTexture;
    return _e9;
}

fn sampleProceduralTreeLeafMask(materialUv_2: vec2<f32>, shapeIndex: f32) -> vec4<f32> {
    var materialUv_3: vec2<f32>;
    var shapeIndex_1: f32;

    materialUv_3 = materialUv_2;
    shapeIndex_1 = shapeIndex;
    let _e8: vec2<f32> = materialUv_3;
    let _e9: vec4<f32> = sampleVegetationBaseTexture(_e8);
    return _e9;
}

fn sampleVegetationAlpha(materialUv_4: vec2<f32>) -> f32 {
    var materialUv_5: vec2<f32>;

    materialUv_5 = materialUv_4;
    let _e6: vec2<f32> = materialUv_5;
    let _e7: vec4<f32> = sampleVegetationBaseTexture(_e6);
    return _e7.w;
}

fn applyVegetationAlphaCutoff(alpha: f32) {
    var alpha_1: f32;

    alpha_1 = alpha;
    let _e6: f32 = alpha_1;
    let _e7: f32 = global.material_AlphaCutoff;
    if (_e6 < _e7) {
        {
            discard;
        }
    } else {
        return;
    }
}

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

fn terrainProjectDiscardInvalidVegetationDepthShadow(varyings: Varyings) {
    var varyings_1: Varyings;

    varyings_1 = varyings;
    let _e7: vec4<f32> = gl_FragCoord_1;
    applyTerrainProjectLodDither(_e7.xy);
    return;
}

fn VegetationShadowFragment(varyings_2: Varyings) {
    var varyings_3: Varyings;

    varyings_3 = varyings_2;
    let _e7: Varyings = varyings_3;
    terrainProjectDiscardInvalidVegetationDepthShadow(_e7);
    let _e8: vec4<f32> = terrainProjectShadowColor();
    converted_FragColor = _e8;
    return;
}

fn gs_wgpu_main() {
    var input_varyings: Varyings;

    let _e5: Varyings = read_Varyings();
    input_varyings = _e5;
    let _e7: Varyings = input_varyings;
    VegetationShadowFragment(_e7);
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) uv: vec2<f32>, @builtin(position) gl_FragCoord: vec4<f32>) -> FragmentOutput {
    uv_3 = uv;
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    let _e11: vec4<f32> = converted_FragColor;
    return FragmentOutput(_e11);
}
