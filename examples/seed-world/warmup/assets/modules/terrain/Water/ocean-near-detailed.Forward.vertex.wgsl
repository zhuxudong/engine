diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    camera_ViewMat: mat4x4<f32>,
    camera_ProjMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    scene_ElapsedTime: vec4<f32>,
    material_SurfaceTimeOverride: f32,
    material_OceanFarTransition: vec2<f32>,
    material_OceanWaveFadeAndTimeScale: vec3<f32>,
}

struct gs_Auto_1_ {
    camera_VPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    material_WaterLevel: f32,
    material_OceanBandlimitViewportHeight: f32,
    material_OceanWaveParameters: vec4<f32>,
    renderer_OceanLod: f32,
}

struct Attributes {
    POSITION: vec4<f32>,
    TEXCOORD_0_: vec2<f32>,
}

struct Varyings {
    worldPosition: vec3<f32>,
    macroNormalWS: vec3<f32>,
    tangentWS: vec3<f32>,
    positionVS: vec3<f32>,
    clipPosition: vec4<f32>,
    waveOffsetY: f32,
    lod: f32,
}

struct VertexOutput {
    @location(0) worldPosition: vec3<f32>,
    @location(1) macroNormalWS: vec3<f32>,
    @location(2) tangentWS: vec3<f32>,
    @location(3) positionVS: vec3<f32>,
    @location(4) clipPosition: vec4<f32>,
    @location(5) waveOffsetY: f32,
    @location(6) lod: f32,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
var<private> POSITION_1: vec4<f32>;
var<private> TEXCOORD_0_1: vec2<f32>;
var<private> worldPosition: vec3<f32>;
var<private> macroNormalWS: vec3<f32>;
var<private> tangentWS: vec3<f32>;
var<private> positionVS: vec3<f32>;
var<private> clipPosition: vec4<f32>;
var<private> waveOffsetY: f32;
var<private> lod: f32;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e30: vec4<f32> = POSITION_1;
    interface_value.POSITION = _e30;
    let _e32: vec2<f32> = TEXCOORD_0_1;
    interface_value.TEXCOORD_0_ = _e32;
    let _e33: Attributes = interface_value;
    return _e33;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e37: Varyings = interface_value_2;
    worldPosition = _e37.worldPosition;
    let _e39: Varyings = interface_value_2;
    macroNormalWS = _e39.macroNormalWS;
    let _e41: Varyings = interface_value_2;
    tangentWS = _e41.tangentWS;
    let _e43: Varyings = interface_value_2;
    positionVS = _e43.positionVS;
    let _e45: Varyings = interface_value_2;
    clipPosition = _e45.clipPosition;
    let _e47: Varyings = interface_value_2;
    waveOffsetY = _e47.waveOffsetY;
    let _e49: Varyings = interface_value_2;
    lod = _e49.lod;
    return;
}

fn safeNormalize3_(value: vec3<f32>, fallbackValue: vec3<f32>) -> vec3<f32> {
    var value_1: vec3<f32>;
    var fallbackValue_1: vec3<f32>;
    var lengthSquared: f32;
    var local: vec3<f32>;

    value_1 = value;
    fallbackValue_1 = fallbackValue;
    let _e39: vec3<f32> = value_1;
    let _e40: vec3<f32> = value_1;
    lengthSquared = dot(_e39, _e40);
    let _e43: f32 = lengthSquared;
    if (_e43 > 0.00000001f) {
        let _e46: vec3<f32> = value_1;
        let _e47: f32 = lengthSquared;
        local = (_e46 * inverseSqrt(_e47));
    } else {
        let _e50: vec3<f32> = fallbackValue_1;
        local = _e50;
    }
    let _e52: vec3<f32> = local;
    return _e52;
}

fn waterConnectionFacts(p: vec2<f32>) -> vec4<f32> {
    var p_1: vec2<f32>;
    var result: vec4<f32> = vec4<f32>(1f, 1f, -1f, 1f);

    p_1 = p;
    let _e44: vec4<f32> = result;
    return _e44;
}

fn waterConnectionNormal(p_2: vec2<f32>, normal: vec3<f32>) -> vec3<f32> {
    var p_3: vec2<f32>;
    var normal_1: vec3<f32>;

    p_3 = p_2;
    normal_1 = normal;
    let _e43: vec3<f32> = normal_1;
    let _e44: vec2<f32> = p_3;
    let _e45: vec4<f32> = waterConnectionFacts(_e44);
    return normalize(mix(vec3<f32>(0f, 1f, 0f), _e43, vec3(_e45.x)));
}

fn oceanMaximum4_(value_2: vec4<f32>) -> f32 {
    var value_3: vec4<f32>;

    value_3 = value_2;
    let _e37: vec4<f32> = value_3;
    let _e39: vec4<f32> = value_3;
    let _e42: vec4<f32> = value_3;
    let _e44: vec4<f32> = value_3;
    return max(max(_e37.x, _e39.y), max(_e42.z, _e44.w));
}

fn oceanGeometryWaveWavelength(frequency: vec4<f32>) -> vec4<f32> {
    var frequency_1: vec4<f32>;
    var twoPi: f32 = 6.2831855f;

    frequency_1 = frequency;
    let _e39: f32 = twoPi;
    let _e41: vec4<f32> = frequency_1;
    return (vec4(_e39) / max(_e41, vec4(0.0001f)));
}

fn oceanGeometryEffectiveSamplingCellSize(meshCellSize: f32, distanceToCamera: f32) -> f32 {
    var meshCellSize_1: f32;
    var distanceToCamera_1: f32;
    var continuousCellSize: f32;

    meshCellSize_1 = meshCellSize;
    distanceToCamera_1 = distanceToCamera;
    let _e43: f32 = distanceToCamera_1;
    let _e50: f32 = distanceToCamera_1;
    continuousCellSize = ((2f + (2f * smoothstep(96f, 112f, _e43))) + (4f * smoothstep(160f, 176f, _e50)));
    let _e55: f32 = meshCellSize_1;
    let _e56: f32 = continuousCellSize;
    return max(_e55, _e56);
}

fn oceanGeometryWaveGridWeight(wavelength: vec4<f32>, samplingCellSize: f32) -> vec4<f32> {
    var wavelength_1: vec4<f32>;
    var samplingCellSize_1: f32;
    var samplesPerWavelength: vec4<f32>;

    wavelength_1 = wavelength;
    samplingCellSize_1 = samplingCellSize;
    let _e39: vec4<f32> = wavelength_1;
    let _e40: f32 = samplingCellSize_1;
    samplesPerWavelength = (_e39 / vec4(max(_e40, 0.0001f)));
    let _e50: vec4<f32> = samplesPerWavelength;
    return smoothstep(vec4(2f), vec4(4f), _e50);
}

fn oceanGeometryWaveViewWeight(wavelength_2: vec4<f32>, directionAB: vec4<f32>, directionCD: vec4<f32>, viewDistance: f32, viewDirection: vec3<f32>, projectedPixelsPerMetre: f32, grazingWeight: f32) -> vec4<f32> {
    var wavelength_3: vec4<f32>;
    var directionAB_1: vec4<f32>;
    var directionCD_1: vec4<f32>;
    var viewDistance_1: f32;
    var viewDirection_1: vec3<f32>;
    var projectedPixelsPerMetre_1: f32;
    var grazingWeight_1: f32;
    var waveViewAlignment: vec4<f32>;
    var projectedDirectionScale: vec4<f32>;
    var projectedPixelsPerWavelength: vec4<f32>;
    var projectedPixelWeight: vec4<f32>;
    var viewDistanceWavelengths: vec4<f32>;
    var distanceWeight: vec4<f32>;

    wavelength_3 = wavelength_2;
    directionAB_1 = directionAB;
    directionCD_1 = directionCD;
    viewDistance_1 = viewDistance;
    viewDirection_1 = viewDirection;
    projectedPixelsPerMetre_1 = projectedPixelsPerMetre;
    grazingWeight_1 = grazingWeight;
    let _e49: vec4<f32> = directionAB_1;
    let _e51: vec3<f32> = viewDirection_1;
    let _e54: vec4<f32> = directionAB_1;
    let _e56: vec3<f32> = viewDirection_1;
    let _e59: vec4<f32> = directionCD_1;
    let _e61: vec3<f32> = viewDirection_1;
    let _e64: vec4<f32> = directionCD_1;
    let _e66: vec3<f32> = viewDirection_1;
    waveViewAlignment = abs(vec4<f32>(dot(_e49.xy, _e51.xz), dot(_e54.zw, _e56.xz), dot(_e59.xy, _e61.xz), dot(_e64.zw, _e66.xz)));
    let _e74: vec4<f32> = waveViewAlignment;
    let _e75: vec4<f32> = waveViewAlignment;
    projectedDirectionScale = sqrt(max((vec4(1f) - (_e74 * _e75)), vec4(0f)));
    let _e83: vec4<f32> = wavelength_3;
    let _e84: f32 = projectedPixelsPerMetre_1;
    let _e86: vec4<f32> = projectedDirectionScale;
    projectedPixelsPerWavelength = ((_e83 * _e84) * _e86);
    let _e93: vec4<f32> = projectedPixelsPerWavelength;
    projectedPixelWeight = smoothstep(vec4(2f), vec4(6f), _e93);
    let _e96: f32 = viewDistance_1;
    let _e98: vec4<f32> = wavelength_3;
    viewDistanceWavelengths = (vec4(_e96) / _e98);
    let _e107: vec4<f32> = viewDistanceWavelengths;
    distanceWeight = (vec4(1f) - smoothstep(vec4(12f), vec4(48f), _e107));
    let _e111: vec4<f32> = projectedPixelWeight;
    let _e112: vec4<f32> = distanceWeight;
    let _e114: f32 = grazingWeight_1;
    return ((_e111 * _e112) * _e114);
}

fn applyWaveGroup(restXZ: vec2<f32>, amplitude: vec4<f32>, frequency_2: vec4<f32>, phase: vec4<f32>, steepness: vec4<f32>, directionAB_2: vec4<f32>, directionCD_2: vec4<f32>, waveBandlimitWeight: vec4<f32>, offset: ptr<function, vec3<f32>>, normalSum: ptr<function, vec3<f32>>) {
    var restXZ_1: vec2<f32>;
    var amplitude_1: vec4<f32>;
    var frequency_3: vec4<f32>;
    var phase_1: vec4<f32>;
    var steepness_1: vec4<f32>;
    var directionAB_3: vec4<f32>;
    var directionCD_3: vec4<f32>;
    var waveBandlimitWeight_1: vec4<f32>;
    var weightedAmplitude: vec4<f32>;
    var maximumAmplitude: f32;
    var angles: vec4<f32>;
    var cosine: vec4<f32>;
    var sine: vec4<f32>;
    var horizontalAB: vec4<f32>;
    var horizontalCD: vec4<f32>;
    var normalAB: vec4<f32>;
    var normalCD: vec4<f32>;
    var groupNormal: vec3<f32> = vec3<f32>(0f, 2f, 0f);

    restXZ_1 = restXZ;
    amplitude_1 = amplitude;
    frequency_3 = frequency_2;
    phase_1 = phase;
    steepness_1 = steepness;
    directionAB_3 = directionAB_2;
    directionCD_3 = directionCD_2;
    waveBandlimitWeight_1 = waveBandlimitWeight;
    let _e53: vec4<f32> = amplitude_1;
    let _e54: vec4<f32> = waveBandlimitWeight_1;
    weightedAmplitude = (_e53 * _e54);
    let _e57: vec4<f32> = weightedAmplitude;
    let _e60: vec4<f32> = weightedAmplitude;
    let _e64: vec4<f32> = weightedAmplitude;
    let _e67: vec4<f32> = weightedAmplitude;
    maximumAmplitude = max(max(abs(_e57.x), abs(_e60.y)), max(abs(_e64.z), abs(_e67.w)));
    let _e73: f32 = maximumAmplitude;
    if (_e73 > 0.0001f) {
        {
            let _e76: vec4<f32> = frequency_3;
            let _e77: vec4<f32> = directionAB_3;
            let _e79: vec2<f32> = restXZ_1;
            let _e81: vec4<f32> = directionAB_3;
            let _e83: vec2<f32> = restXZ_1;
            let _e85: vec4<f32> = directionCD_3;
            let _e87: vec2<f32> = restXZ_1;
            let _e89: vec4<f32> = directionCD_3;
            let _e91: vec2<f32> = restXZ_1;
            let _e95: vec4<f32> = phase_1;
            angles = ((_e76 * vec4<f32>(dot(_e77.xy, _e79), dot(_e81.zw, _e83), dot(_e85.xy, _e87), dot(_e89.zw, _e91))) + _e95);
            let _e98: vec4<f32> = angles;
            cosine = cos(_e98);
            let _e101: vec4<f32> = angles;
            sine = sin(_e101);
            let _e104: vec4<f32> = steepness_1;
            let _e106: vec4<f32> = directionAB_3;
            let _e108: vec4<f32> = weightedAmplitude;
            horizontalAB = ((_e104.xxyy * _e106) * _e108.xxyy);
            let _e112: vec4<f32> = steepness_1;
            let _e114: vec4<f32> = directionCD_3;
            let _e116: vec4<f32> = weightedAmplitude;
            horizontalCD = ((_e112.zzww * _e114) * _e116.zzww);
            let _e120: vec3<f32> = (*offset);
            let _e121: vec4<f32> = cosine;
            let _e122: vec4<f32> = horizontalAB;
            let _e123: vec2<f32> = _e122.xz;
            let _e124: vec4<f32> = horizontalCD;
            let _e125: vec2<f32> = _e124.xz;
            let _e132: vec4<f32> = sine;
            let _e133: vec4<f32> = weightedAmplitude;
            let _e135: vec4<f32> = cosine;
            let _e136: vec4<f32> = horizontalAB;
            let _e137: vec2<f32> = _e136.yw;
            let _e138: vec4<f32> = horizontalCD;
            let _e139: vec2<f32> = _e138.yw;
            (*offset) = (_e120 + vec3<f32>(dot(_e121, vec4<f32>(_e123.x, _e123.y, _e125.x, _e125.y)), dot(_e132, _e133), dot(_e135, vec4<f32>(_e137.x, _e137.y, _e139.x, _e139.y))));
            let _e148: vec4<f32> = frequency_3;
            let _e150: vec4<f32> = weightedAmplitude;
            let _e153: vec4<f32> = directionAB_3;
            normalAB = ((_e148.xxyy * _e150.xxyy) * _e153);
            let _e156: vec4<f32> = frequency_3;
            let _e158: vec4<f32> = weightedAmplitude;
            let _e161: vec4<f32> = directionCD_3;
            normalCD = ((_e156.zzww * _e158.zzww) * _e161);
            let _e170: vec3<f32> = groupNormal;
            let _e172: vec4<f32> = cosine;
            let _e173: vec4<f32> = normalAB;
            let _e174: vec2<f32> = _e173.xz;
            let _e175: vec4<f32> = normalCD;
            let _e176: vec2<f32> = _e175.xz;
            groupNormal.x = (_e170.x - dot(_e172, vec4<f32>(_e174.x, _e174.y, _e176.x, _e176.y)));
            let _e185: vec3<f32> = groupNormal;
            let _e187: vec4<f32> = cosine;
            let _e188: vec4<f32> = normalAB;
            let _e189: vec2<f32> = _e188.yw;
            let _e190: vec4<f32> = normalCD;
            let _e191: vec2<f32> = _e190.yw;
            groupNormal.z = (_e185.z - dot(_e187, vec4<f32>(_e189.x, _e189.y, _e191.x, _e191.y)));
            let _e199: vec3<f32> = (*normalSum);
            let _e200: vec3<f32> = groupNormal;
            (*normalSum) = (_e199 + normalize(_e200));
            return;
        }
    } else {
        return;
    }
}

fn vert(attributes: Attributes) -> Varyings {
    var attributes_1: Attributes;
    var output: Varyings;
    var worldPosition4_: vec4<f32>;
    var restXZ_2: vec2<f32>;
    var restWorldPosition: vec3<f32>;
    var cameraVector: vec3<f32>;
    var viewDistance_2: f32;
    var distanceToCamera_2: f32;
    var fadeFactor: f32;
    var local_1: f32;
    var elapsedTime: f32;
    var sourceTime: vec2<f32>;
    var phase_2: vec4<f32>;
    var amplitude_2: vec4<f32> = vec4<f32>(0.3f, 0.35f, 0.25f, 0.25f);
    var frequency_4: vec4<f32>;
    var steepness_2: vec4<f32>;
    var directionAB_4: vec4<f32> = vec4<f32>(-0.3f, -0.85f, -0.85f, -0.25f);
    var directionCD_4: vec4<f32> = vec4<f32>(-0.1f, -0.9f, 0.5f, 0.5f);
    var offset_1: vec3<f32> = vec3(0f);
    var normalSum_1: vec3<f32> = vec3(0f);
    var waveBandlimitWeight_2: vec4<f32> = vec4(0f);
    var waveWavelength: vec4<f32>;
    var samplingCellSize_2: f32;
    var waveGridWeight: vec4<f32>;
    var viewDirection_2: vec3<f32>;
    var projectedPixelsPerMetre_2: f32;
    var grazingWeight_2: f32;
    var macroNormal: vec3<f32>;
    var tangent: vec3<f32>;

    attributes_1 = attributes;
    let _e38: mat4x4<f32> = global_1.renderer_ModelMat;
    let _e39: Attributes = attributes_1;
    worldPosition4_ = (_e38 * _e39.POSITION);
    let _e43: vec4<f32> = worldPosition4_;
    restXZ_2 = _e43.xz;
    let _e46: vec2<f32> = restXZ_2;
    let _e48: f32 = global_1.material_WaterLevel;
    let _e49: vec2<f32> = restXZ_2;
    restWorldPosition = vec3<f32>(_e46.x, _e48, _e49.y);
    let _e53: vec3<f32> = global.camera_Position;
    let _e54: vec3<f32> = restWorldPosition;
    cameraVector = (_e53 - _e54);
    let _e57: vec3<f32> = cameraVector;
    viewDistance_2 = max(length(_e57), 0.001f);
    let _e62: vec3<f32> = global.camera_Position;
    let _e64: vec2<f32> = restXZ_2;
    distanceToCamera_2 = distance(_e62.xz, _e64);
    let _e67: vec3<f32> = global.material_OceanWaveFadeAndTimeScale;
    let _e69: f32 = distanceToCamera_2;
    let _e71: vec3<f32> = global.material_OceanWaveFadeAndTimeScale;
    let _e73: vec3<f32> = global.material_OceanWaveFadeAndTimeScale;
    fadeFactor = clamp(((_e67.y - _e69) / max((_e71.y - _e73.x), 0.0001f)), 0f, 1f);
    let _e83: f32 = fadeFactor;
    let _e85: vec2<f32> = global.material_OceanFarTransition;
    let _e87: vec2<f32> = global.material_OceanFarTransition;
    let _e89: f32 = viewDistance_2;
    fadeFactor = (_e83 * (1f - smoothstep(_e85.x, _e87.y, _e89)));
    let _e93: f32 = global.material_SurfaceTimeOverride;
    if (_e93 >= 0f) {
        let _e96: f32 = global.material_SurfaceTimeOverride;
        local_1 = _e96;
    } else {
        let _e97: vec4<f32> = global.scene_ElapsedTime;
        local_1 = _e97.x;
    }
    let _e100: f32 = local_1;
    elapsedTime = _e100;
    let _e102: f32 = elapsedTime;
    let _e105: vec3<f32> = global.material_OceanWaveFadeAndTimeScale;
    sourceTime = (vec2(-(_e102)) * _e105.z);
    let _e110: vec2<f32> = sourceTime;
    let _e114: vec2<f32> = sourceTime;
    let _e118: vec2<f32> = sourceTime;
    let _e122: vec2<f32> = sourceTime;
    let _e126: vec4<f32> = global_1.material_OceanWaveParameters;
    phase_2 = (vec4<f32>((1.2f * _e110.x), (1.375f * _e114.y), (1.1f * _e118.x), (1f * _e122.y)) * _e126.z);
    let _e142: vec4<f32> = global_1.material_OceanWaveParameters;
    frequency_4 = (vec4<f32>(3.9f, 4.05f, 3.75f, 3.75f) * max((1f - _e142.y), 0.001f));
    let _e151: vec4<f32> = global_1.material_OceanWaveParameters;
    steepness_2 = (vec4(36f) * _e151.w);
    let _e182: vec4<f32> = frequency_4;
    let _e183: vec4<f32> = oceanGeometryWaveWavelength(_e182);
    waveWavelength = _e183;
    let _e185: Attributes = attributes_1;
    let _e188: f32 = distanceToCamera_2;
    let _e189: f32 = oceanGeometryEffectiveSamplingCellSize(_e185.TEXCOORD_0_.x, _e188);
    samplingCellSize_2 = _e189;
    let _e191: vec4<f32> = waveWavelength;
    let _e192: f32 = samplingCellSize_2;
    let _e193: vec4<f32> = oceanGeometryWaveGridWeight(_e191, _e192);
    waveGridWeight = _e193;
    let _e195: vec4<f32> = waveGridWeight;
    let _e196: f32 = oceanMaximum4_(_e195);
    if (_e196 > 0f) {
        {
            let _e199: vec3<f32> = cameraVector;
            let _e200: f32 = viewDistance_2;
            viewDirection_2 = (_e199 / vec3(_e200));
            let _e205: f32 = global_1.material_OceanBandlimitViewportHeight;
            let _e213: f32 = global.camera_ProjMat[1][1];
            projectedPixelsPerMetre_2 = ((0.5f * max(_e205, 1f)) * abs(_e213));
            let _e217: f32 = projectedPixelsPerMetre_2;
            let _e218: f32 = viewDistance_2;
            projectedPixelsPerMetre_2 = (_e217 / _e218);
            let _e222: vec3<f32> = viewDirection_2;
            grazingWeight_2 = smoothstep(0.035f, 0.14f, abs(_e222.y));
            let _e227: vec4<f32> = amplitude_2;
            let _e228: f32 = fadeFactor;
            amplitude_2 = (_e227 * _e228);
            let _e230: vec4<f32> = waveGridWeight;
            let _e231: f32 = oceanMaximum4_(_e230);
            if (_e231 > 0f) {
                {
                    let _e234: vec4<f32> = waveGridWeight;
                    let _e235: vec4<f32> = waveWavelength;
                    let _e236: vec4<f32> = directionAB_4;
                    let _e237: vec4<f32> = directionCD_4;
                    let _e238: f32 = viewDistance_2;
                    let _e239: vec3<f32> = viewDirection_2;
                    let _e240: f32 = projectedPixelsPerMetre_2;
                    let _e241: f32 = grazingWeight_2;
                    let _e242: vec4<f32> = oceanGeometryWaveViewWeight(_e235, _e236, _e237, _e238, _e239, _e240, _e241);
                    waveBandlimitWeight_2 = (_e234 * _e242);
                    let _e244: vec2<f32> = restXZ_2;
                    let _e245: vec4<f32> = amplitude_2;
                    let _e246: vec4<f32> = frequency_4;
                    let _e247: vec4<f32> = phase_2;
                    let _e248: vec4<f32> = steepness_2;
                    let _e249: vec4<f32> = directionAB_4;
                    let _e250: vec4<f32> = directionCD_4;
                    let _e251: vec4<f32> = waveBandlimitWeight_2;
                    applyWaveGroup(_e244, _e245, _e246, _e247, _e248, _e249, _e250, _e251, (&offset_1), (&normalSum_1));
                }
            }
            let _e256: vec4<f32> = frequency_4;
            frequency_4 = (_e256 * 1.5f);
            let _e259: vec4<f32> = frequency_4;
            let _e260: vec4<f32> = oceanGeometryWaveWavelength(_e259);
            waveWavelength = _e260;
            let _e261: vec4<f32> = waveWavelength;
            let _e262: f32 = samplingCellSize_2;
            let _e263: vec4<f32> = oceanGeometryWaveGridWeight(_e261, _e262);
            waveGridWeight = _e263;
            let _e264: vec4<f32> = amplitude_2;
            let _e265: f32 = fadeFactor;
            amplitude_2 = (_e264 * _e265);
            let _e267: vec4<f32> = waveGridWeight;
            let _e268: f32 = oceanMaximum4_(_e267);
            if (_e268 > 0f) {
                {
                    let _e271: vec4<f32> = waveGridWeight;
                    let _e272: vec4<f32> = waveWavelength;
                    let _e273: vec4<f32> = directionAB_4;
                    let _e274: vec4<f32> = directionCD_4;
                    let _e275: f32 = viewDistance_2;
                    let _e276: vec3<f32> = viewDirection_2;
                    let _e277: f32 = projectedPixelsPerMetre_2;
                    let _e278: f32 = grazingWeight_2;
                    let _e279: vec4<f32> = oceanGeometryWaveViewWeight(_e272, _e273, _e274, _e275, _e276, _e277, _e278);
                    waveBandlimitWeight_2 = (_e271 * _e279);
                    let _e281: vec2<f32> = restXZ_2;
                    let _e282: vec4<f32> = amplitude_2;
                    let _e283: vec4<f32> = frequency_4;
                    let _e284: vec4<f32> = phase_2;
                    let _e285: vec4<f32> = steepness_2;
                    let _e286: vec4<f32> = directionAB_4;
                    let _e287: vec4<f32> = directionCD_4;
                    let _e288: vec4<f32> = waveBandlimitWeight_2;
                    applyWaveGroup(_e281, _e282, _e283, _e284, _e285, _e286, _e287, _e288, (&offset_1), (&normalSum_1));
                }
            }
            let _e293: vec4<f32> = frequency_4;
            frequency_4 = (_e293 * 2f);
            let _e296: vec4<f32> = frequency_4;
            let _e297: vec4<f32> = oceanGeometryWaveWavelength(_e296);
            waveWavelength = _e297;
            let _e298: vec4<f32> = waveWavelength;
            let _e299: f32 = samplingCellSize_2;
            let _e300: vec4<f32> = oceanGeometryWaveGridWeight(_e298, _e299);
            waveGridWeight = _e300;
            let _e301: vec4<f32> = amplitude_2;
            let _e302: f32 = fadeFactor;
            amplitude_2 = (_e301 * _e302);
            let _e304: vec4<f32> = waveGridWeight;
            let _e305: f32 = oceanMaximum4_(_e304);
            if (_e305 > 0f) {
                {
                    let _e308: vec4<f32> = waveGridWeight;
                    let _e309: vec4<f32> = waveWavelength;
                    let _e310: vec4<f32> = directionAB_4;
                    let _e311: vec4<f32> = directionCD_4;
                    let _e312: f32 = viewDistance_2;
                    let _e313: vec3<f32> = viewDirection_2;
                    let _e314: f32 = projectedPixelsPerMetre_2;
                    let _e315: f32 = grazingWeight_2;
                    let _e316: vec4<f32> = oceanGeometryWaveViewWeight(_e309, _e310, _e311, _e312, _e313, _e314, _e315);
                    waveBandlimitWeight_2 = (_e308 * _e316);
                    let _e318: vec2<f32> = restXZ_2;
                    let _e319: vec4<f32> = amplitude_2;
                    let _e320: vec4<f32> = frequency_4;
                    let _e321: vec4<f32> = phase_2;
                    let _e322: vec4<f32> = steepness_2;
                    let _e323: vec4<f32> = directionAB_4;
                    let _e324: vec4<f32> = directionCD_4;
                    let _e325: vec4<f32> = waveBandlimitWeight_2;
                    applyWaveGroup(_e318, _e319, _e320, _e321, _e322, _e323, _e324, _e325, (&offset_1), (&normalSum_1));
                }
            }
        }
    }
    let _e331: vec3<f32> = offset_1;
    offset_1.y = (_e331.y / 2f);
    let _e335: vec3<f32> = offset_1;
    let _e337: vec3<f32> = offset_1;
    let _e340: vec4<f32> = global_1.material_OceanWaveParameters;
    let _e343: vec2<f32> = (_e337.xz * (0.01f * _e340.x));
    offset_1.x = _e343.x;
    offset_1.z = _e343.y;
    let _e349: vec3<f32> = offset_1;
    let _e351: vec4<f32> = global_1.material_OceanWaveParameters;
    offset_1.y = (_e349.y * _e351.x);
    let _e354: vec3<f32> = offset_1;
    let _e355: vec4<f32> = worldPosition4_;
    let _e357: vec4<f32> = waterConnectionFacts(_e355.xz);
    offset_1 = (_e354 * _e357.x);
    let _e360: vec4<f32> = worldPosition4_;
    let _e362: vec4<f32> = worldPosition4_;
    let _e364: vec3<f32> = offset_1;
    let _e365: vec3<f32> = (_e362.xyz + _e364);
    worldPosition4_.x = _e365.x;
    worldPosition4_.y = _e365.y;
    worldPosition4_.z = _e365.z;
    let _e373: vec4<f32> = worldPosition4_;
    let _e375: f32 = global_1.material_WaterLevel;
    worldPosition4_.y = (_e373.y + _e375);
    let _e377: vec4<f32> = worldPosition4_;
    let _e379: vec3<f32> = normalSum_1;
    let _e384: vec3<f32> = safeNormalize3_(_e379, vec3<f32>(0f, 1f, 0f));
    let _e385: vec3<f32> = waterConnectionNormal(_e377.xz, _e384);
    macroNormal = _e385;
    let _e388: vec3<f32> = macroNormal;
    let _e391: vec3<f32> = macroNormal;
    let _e402: vec3<f32> = safeNormalize3_(vec3<f32>(1f, (-(_e388.x) / max(_e391.y, 0.05f)), 0f), vec3<f32>(1f, 0f, 0f));
    tangent = _e402;
    let _e405: vec4<f32> = worldPosition4_;
    output.worldPosition = _e405.xyz;
    let _e408: vec3<f32> = macroNormal;
    output.macroNormalWS = _e408;
    let _e410: vec3<f32> = tangent;
    output.tangentWS = _e410;
    let _e412: mat4x4<f32> = global.camera_ViewMat;
    let _e413: vec4<f32> = worldPosition4_;
    output.positionVS = (_e412 * _e413).xyz;
    let _e417: mat4x4<f32> = global_1.camera_VPMat;
    let _e418: vec4<f32> = worldPosition4_;
    output.clipPosition = (_e417 * _e418);
    let _e421: vec3<f32> = offset_1;
    output.waveOffsetY = _e421.y;
    let _e424: f32 = global_1.renderer_OceanLod;
    output.lod = _e424;
    let _e426: Varyings = output;
    gl_Position = _e426.clipPosition;
    let _e428: Varyings = output;
    return _e428;
}

fn gs_wgpu_main() {
    var input_attributes: Attributes;

    let _e36: Attributes = read_Attributes();
    input_attributes = _e36;
    let _e38: Attributes = input_attributes;
    let _e39: Varyings = vert(_e38);
    write_Varyings(_e39);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e38: vec4<f32> = gl_Position;
    let _e40: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e38.z + _e40.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec4<f32>, @location(1) TEXCOORD_0_: vec2<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    TEXCOORD_0_1 = TEXCOORD_0_;
    main_1();
    let _e49: vec3<f32> = worldPosition;
    let _e51: vec3<f32> = macroNormalWS;
    let _e53: vec3<f32> = tangentWS;
    let _e55: vec3<f32> = positionVS;
    let _e57: vec4<f32> = clipPosition;
    let _e59: f32 = waveOffsetY;
    let _e61: f32 = lod;
    let _e63: vec4<f32> = gl_Position;
    return VertexOutput(_e49, _e51, _e53, _e55, _e57, _e59, _e61, _e63);
}
