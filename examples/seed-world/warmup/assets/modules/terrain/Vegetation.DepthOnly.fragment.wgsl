diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ProjectionParams: vec4<f32>,
    camera_ViewMat: mat4x4<f32>,
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    renderer_NormalMat: mat4x4<f32>,
    material_Tiling: f32,
    material_LightingFlatness: f32,
    material_WindForce: f32,
    material_WindWavesScale: f32,
    material_WindFlowDensity: f32,
    material_WindGroundWaveParams: vec4<f32>,
    material_WindGroundShapeParams: vec4<f32>,
    material_WindHierarchyParams: vec4<f32>,
    material_WindLeafMotionParams: vec4<f32>,
    material_WindSpeciesParams: vec4<f32>,
    material_WindTrunkModeParams: vec4<f32>,
    material_WindTreePrimaryParams: vec4<f32>,
    material_WindTreeComplianceGain: f32,
    material_WindInputWeights: vec4<f32>,
    material_WindStructureWeights: vec4<f32>,
    material_WindAerodynamicWeights: vec4<f32>,
    material_WindFoliageWeights: vec4<f32>,
    material_WindFlutterTuning: vec4<f32>,
    material_WindLeafBladeParams: vec4<f32>,
    material_WindLockedDirectionWS: vec4<f32>,
    material_WindMechanicalBoundsMin: vec4<f32>,
    material_WindMechanicalBoundsExtent: vec4<f32>,
    material_WindMechanicalTextureSize: vec4<f32>,
    material_UVBaseLock: f32,
    material_GrassDistanceFadeEnable: f32,
    material_GrassFadeDistance: f32,
    material_GrassFalloff: f32,
    scene_WindVelocity: vec3<f32>,
    scene_WindAnimationEnabled: f32,
    scene_WindFieldParams: vec4<f32>,
    scene_WindSpectrumAdvectionOffset: vec3<f32>,
    scene_WindLayerMultipliers: vec3<f32>,
    scene_WindSpectrumParams: vec4<f32>,
    scene_WindLocalFieldTransform: vec4<f32>,
    scene_WindLocalFieldTemporalParams: vec4<f32>,
    scene_WindTreeResponseParams: vec4<f32>,
    scene_WindGroundResponseRampDuration: f32,
    scene_WindGrassProfile0_: vec4<f32>,
    scene_WindGrassProfile1_: vec4<f32>,
    scene_WindGrassProfile2_: vec4<f32>,
    scene_WindFlowerProfile0_: vec4<f32>,
    scene_WindFlowerProfile1_: vec4<f32>,
    scene_WindFlowerProfile2_: vec4<f32>,
    scene_WindLeafProfile0_: vec4<f32>,
    scene_WindLeafProfile1_: vec4<f32>,
    scene_WindLeafProfile2_: vec4<f32>,
    scene_WindShrubProfile0_: vec4<f32>,
    scene_WindShrubProfile1_: vec4<f32>,
    scene_WindShrubProfile2_: vec4<f32>,
    scene_WindBranchProfile0_: vec4<f32>,
    scene_WindBranchProfile1_: vec4<f32>,
    scene_WindBranchProfile2_: vec4<f32>,
    scene_WindBillboardProfile0_: vec4<f32>,
    scene_WindBillboardProfile1_: vec4<f32>,
    scene_WindBillboardProfile2_: vec4<f32>,
    material_AlphaCutoff: f32,
    material_LeafGlancingAngleCut: f32,
}

struct gs_Auto_1_ {
    camera_Position: vec3<f32>,
}

struct Varyings {
    uv: vec2<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> uv_3: vec2<f32>;
var<private> gl_FragCoord_1: vec4<f32>;

fn texture2DSRGB(gs_wgpu_tex_tex: texture_2d<f32>, gs_wgpu_samp_tex: sampler, uv_1: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;

    uv_2 = uv_1;
    let _e130: vec2<f32> = uv_2;
    let _e131: vec4<f32> = textureSample(gs_wgpu_tex_tex, gs_wgpu_samp_tex, _e130);
    return _e131;
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e129: vec2<f32> = uv_3;
    interface_value.uv = _e129;
    let _e130: Varyings = interface_value;
    return _e130;
}

fn sampleVegetationBaseTexture(materialUv: vec2<f32>) -> vec4<f32> {
    var materialUv_1: vec2<f32>;
    var baseTexture: vec4<f32> = vec4(1f);

    materialUv_1 = materialUv;
    let _e132: vec4<f32> = baseTexture;
    return _e132;
}

fn sampleProceduralTreeLeafMask(materialUv_2: vec2<f32>, shapeIndex: f32) -> vec4<f32> {
    var materialUv_3: vec2<f32>;
    var shapeIndex_1: f32;

    materialUv_3 = materialUv_2;
    shapeIndex_1 = shapeIndex;
    let _e131: vec2<f32> = materialUv_3;
    let _e132: vec4<f32> = sampleVegetationBaseTexture(_e131);
    return _e132;
}

fn sampleVegetationAlpha(materialUv_4: vec2<f32>) -> f32 {
    var materialUv_5: vec2<f32>;

    materialUv_5 = materialUv_4;
    let _e129: vec2<f32> = materialUv_5;
    let _e130: vec4<f32> = sampleVegetationBaseTexture(_e129);
    return _e130.w;
}

fn applyVegetationAlphaCutoff(alpha: f32) {
    var alpha_1: f32;

    alpha_1 = alpha;
    let _e129: f32 = alpha_1;
    let _e130: f32 = global.material_AlphaCutoff;
    if (_e129 < _e130) {
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

fn terrainProjectDiscardInvalidVegetationDepthShadow(varyings: Varyings) {
    var varyings_1: Varyings;

    varyings_1 = varyings;
    let _e130: vec4<f32> = gl_FragCoord_1;
    applyTerrainProjectLodDither(_e130.xy);
    return;
}

fn VegetationDepthOnlyFragment(varyings_2: Varyings) {
    var varyings_3: Varyings;

    varyings_3 = varyings_2;
    let _e130: Varyings = varyings_3;
    terrainProjectDiscardInvalidVegetationDepthShadow(_e130);
    return;
}

fn gs_wgpu_main() {
    var input_varyings: Varyings;

    let _e128: Varyings = read_Varyings();
    input_varyings = _e128;
    let _e130: Varyings = input_varyings;
    VegetationDepthOnlyFragment(_e130);
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) uv: vec2<f32>, @builtin(position) gl_FragCoord: vec4<f32>) {
    uv_3 = uv;
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    return;
}
