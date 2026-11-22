diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    renderer_ModelMat: mat4x4<f32>,
    renderer_MVPMat: mat4x4<f32>,
    camera_DepthBufferParams: vec4<f32>,
    camera_ProjectionParams: vec4<f32>,
    camera_Position: vec3<f32>,
    scene_ElapsedTime: vec4<f32>,
    scene_WindVelocity: vec3<f32>,
    material_WindVelocity: vec3<f32>,
    material_WindVelocityOverride: f32,
    material_AppearanceV2Detail0Enabled: f32,
    material_AppearanceV2DetailEnabled: f32,
    material_AppearanceV2DetailNormalStrength: f32,
    material_AppearanceV2Detail0Transform: vec4<f32>,
    material_AppearanceV2Detail0Rotation: vec2<f32>,
    material_AppearanceV2Detail0Strength: f32,
    material_LocalMapDecode: vec4<f32>,
    material_SurfaceTimeOverride: f32,
    material_MicroNormalsEnabled: f32,
    material_Roughness: f32,
    material_ScreenSpaceReflectionIntensity: f32,
    camera_SSRParams: vec4<f32>,
    scene_WeatherState: vec4<f32>,
}

struct Varyings {
    worldPosition: vec3<f32>,
    objectPosition: vec3<f32>,
    meshUv: vec2<f32>,
    macroNormalWS: vec3<f32>,
    baseNormalWS: vec3<f32>,
    tangentWS: vec3<f32>,
    atlasUv: vec2<f32>,
    waveOffset: f32,
}

struct HeightfieldSSRReceiverOutput {
    normalRoughness: vec4<f32>,
    receiverDepth: vec4<f32>,
}

struct FragmentOutput {
    @location(0) output_color: vec4<f32>,
    @location(1) output_color_1_: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
var<private> output_color: vec4<f32>;
var<private> output_color_1_: vec4<f32>;
@group(2) @binding(1) 
var gs_wgpu_tex_material_LocalMapTexture: texture_2d<f32>;
@group(2) @binding(2) 
var gs_wgpu_samp_material_LocalMapTexture: sampler;
@group(2) @binding(3) 
var gs_wgpu_tex_material_AppearanceV2Detail0Texture: texture_2d<f32>;
@group(2) @binding(4) 
var gs_wgpu_samp_material_AppearanceV2Detail0Texture: sampler;
var<private> worldPosition_1: vec3<f32>;
var<private> macroNormalWS_1: vec3<f32>;
var<private> baseNormalWS_1: vec3<f32>;
var<private> tangentWS_1: vec3<f32>;
var<private> atlasUv_1: vec2<f32>;
var<private> waveOffset_1: f32;
var<private> gl_FragCoord_1: vec4<f32>;

fn remapDepthBufferEyeDepth(depth: f32) -> f32 {
    var depth_1: f32;

    depth_1 = depth;
    let _e49: vec4<f32> = global.camera_DepthBufferParams;
    let _e51: f32 = depth_1;
    let _e53: vec4<f32> = global.camera_DepthBufferParams;
    return (1f / ((_e49.z * _e51) + _e53.w));
}

fn encodeSSROctNormal(normal: vec3<f32>) -> vec2<f32> {
    var normal_1: vec3<f32>;
    var encoded: vec2<f32>;
    var local: f32;
    var local_1: f32;

    normal_1 = normal;
    let _e48: vec3<f32> = normal_1;
    let _e49: vec3<f32> = normal_1;
    let _e52: vec3<f32> = normal_1;
    let _e56: vec3<f32> = normal_1;
    normal_1 = (_e48 / vec3(max(((abs(_e49.x) + abs(_e52.y)) + abs(_e56.z)), 0.000001f)));
    let _e64: vec3<f32> = normal_1;
    encoded = _e64.xy;
    let _e67: vec3<f32> = normal_1;
    if (_e67.z < 0f) {
        {
            let _e72: vec2<f32> = encoded;
            let _e77: vec2<f32> = encoded;
            if (_e77.x >= 0f) {
                local = 1f;
            } else {
                local = -1f;
            }
            let _e85: f32 = local;
            let _e86: vec2<f32> = encoded;
            if (_e86.y >= 0f) {
                local_1 = 1f;
            } else {
                local_1 = -1f;
            }
            let _e94: f32 = local_1;
            encoded = ((vec2(1f) - abs(_e72.yx)) * vec2<f32>(_e85, _e94));
        }
    }
    let _e97: vec2<f32> = encoded;
    return ((_e97 * 0.5f) + vec2(0.5f));
}

fn packSSRNormalRoughness(worldNormal: vec3<f32>, roughness: f32) -> vec4<f32> {
    var worldNormal_1: vec3<f32>;
    var roughness_1: f32;
    var n: vec3<f32>;
    var r: f32;

    worldNormal_1 = worldNormal;
    roughness_1 = roughness;
    let _e50: vec3<f32> = worldNormal_1;
    n = normalize(_e50);
    let _e53: f32 = roughness_1;
    r = clamp(_e53, 0f, 1f);
    let _e58: vec3<f32> = n;
    let _e59: f32 = r;
    return vec4<f32>(_e58.x, _e58.y, _e58.z, _e59);
}

fn encodeSSRDepth(eyeDepth: f32, farClip: f32) -> vec4<f32> {
    var eyeDepth_1: f32;
    var farClip_1: f32;

    eyeDepth_1 = eyeDepth;
    farClip_1 = farClip;
    let _e50: f32 = eyeDepth_1;
    return vec4<f32>(clamp(_e50, 0f, 65000f), 0f, 0f, 1f);
}

fn read_Varyings() -> Varyings {
    var interface_value: Varyings;

    let _e58: vec3<f32> = worldPosition_1;
    interface_value.worldPosition = _e58;
    let _e60: vec3<f32> = macroNormalWS_1;
    interface_value.macroNormalWS = _e60;
    let _e62: vec3<f32> = baseNormalWS_1;
    interface_value.baseNormalWS = _e62;
    let _e64: vec3<f32> = tangentWS_1;
    interface_value.tangentWS = _e64;
    let _e66: vec2<f32> = atlasUv_1;
    interface_value.atlasUv = _e66;
    let _e68: f32 = waveOffset_1;
    interface_value.waveOffset = _e68;
    let _e69: Varyings = interface_value;
    return _e69;
}

fn write_HeightfieldSSRReceiverOutput(interface_value_1: HeightfieldSSRReceiverOutput) {
    var interface_value_2: HeightfieldSSRReceiverOutput;

    interface_value_2 = interface_value_1;
    let _e58: HeightfieldSSRReceiverOutput = interface_value_2;
    output_color = _e58.normalRoughness;
    let _e60: HeightfieldSSRReceiverOutput = interface_value_2;
    output_color_1_ = _e60.receiverDepth;
    return;
}

fn waterSurfaceAppearanceSafeNormalize3_(value: vec3<f32>, fallbackValue: vec3<f32>) -> vec3<f32> {
    var value_1: vec3<f32>;
    var fallbackValue_1: vec3<f32>;
    var lengthSquared: f32;
    var local_2: vec3<f32>;

    value_1 = value;
    fallbackValue_1 = fallbackValue;
    let _e60: vec3<f32> = value_1;
    let _e61: vec3<f32> = value_1;
    lengthSquared = dot(_e60, _e61);
    let _e64: f32 = lengthSquared;
    if (_e64 > 0.000001f) {
        let _e67: vec3<f32> = value_1;
        let _e68: f32 = lengthSquared;
        local_2 = (_e67 * inverseSqrt(_e68));
    } else {
        let _e71: vec3<f32> = fallbackValue_1;
        local_2 = _e71;
    }
    let _e73: vec3<f32> = local_2;
    return _e73;
}

fn waterSurfaceAppearanceDecodeTangentNormalPreserveSourceZ(packedNormal: vec4<f32>, strength: f32, flipGreen: f32) -> vec3<f32> {
    var packedNormal_1: vec4<f32>;
    var strength_1: f32;
    var flipGreen_1: f32;
    var sourceSlope: vec2<f32>;
    var sourceNormalZ: f32;
    var normalZ: f32;

    packedNormal_1 = packedNormal;
    strength_1 = strength;
    flipGreen_1 = flipGreen;
    let _e62: vec4<f32> = packedNormal_1;
    sourceSlope = ((_e62.xy * 2f) - vec2(1f));
    let _e71: vec2<f32> = sourceSlope;
    let _e77: f32 = flipGreen_1;
    sourceSlope.y = (_e71.y * mix(1f, -1f, step(0.5f, _e77)));
    let _e82: vec2<f32> = sourceSlope;
    let _e83: vec2<f32> = sourceSlope;
    sourceNormalZ = sqrt(max((1f - clamp(dot(_e82, _e83), 0f, 1f)), 0.0001f));
    let _e94: f32 = sourceNormalZ;
    let _e95: f32 = strength_1;
    normalZ = mix(1f, _e94, clamp(_e95, 0f, 1f));
    let _e101: vec2<f32> = sourceSlope;
    let _e102: f32 = strength_1;
    let _e103: vec2<f32> = (_e101 * _e102);
    let _e104: f32 = normalZ;
    return vec3<f32>(_e103.x, _e103.y, _e104);
}

fn waterSurfaceAppearanceBlendTangentNormalsPartialDerivative(firstNormal: vec3<f32>, secondNormal: vec3<f32>) -> vec3<f32> {
    var firstNormal_1: vec3<f32>;
    var secondNormal_1: vec3<f32>;

    firstNormal_1 = firstNormal;
    secondNormal_1 = secondNormal;
    let _e60: vec3<f32> = firstNormal_1;
    let _e62: vec3<f32> = secondNormal_1;
    let _e65: vec3<f32> = secondNormal_1;
    let _e67: vec3<f32> = firstNormal_1;
    let _e70: vec2<f32> = ((_e60.xy * _e62.z) + (_e65.xy * _e67.z));
    let _e71: vec3<f32> = firstNormal_1;
    let _e73: vec3<f32> = secondNormal_1;
    let _e83: vec3<f32> = waterSurfaceAppearanceSafeNormalize3_(vec3<f32>(_e70.x, _e70.y, (_e71.z * _e73.z)), vec3<f32>(0f, 0f, 1f));
    return _e83;
}

fn waterConnectionFacts(p: vec2<f32>) -> vec4<f32> {
    var p_1: vec2<f32>;
    var result: vec4<f32> = vec4<f32>(1f, 1f, -1f, 1f);

    p_1 = p;
    let _e65: vec4<f32> = result;
    return _e65;
}

fn waterConnectionShore(p_2: vec2<f32>, original: f32) -> f32 {
    var p_3: vec2<f32>;
    var original_1: f32;
    var result_1: f32;

    p_3 = p_2;
    original_1 = original;
    let _e60: f32 = original_1;
    result_1 = _e60;
    let _e62: f32 = result_1;
    return _e62;
}

fn waterConnectionNormal(p_4: vec2<f32>, normal_2: vec3<f32>) -> vec3<f32> {
    var p_5: vec2<f32>;
    var normal_3: vec3<f32>;

    p_5 = p_4;
    normal_3 = normal_2;
    let _e64: vec3<f32> = normal_3;
    let _e65: vec2<f32> = p_5;
    let _e66: vec4<f32> = waterConnectionFacts(_e65);
    return normalize(mix(vec3<f32>(0f, 1f, 0f), _e64, vec3(_e66.x)));
}

fn waterWindVelocity() -> vec3<f32> {
    let _e56: vec3<f32> = global.scene_WindVelocity;
    let _e57: vec3<f32> = global.material_WindVelocity;
    let _e58: f32 = global.material_WindVelocityOverride;
    return mix(_e56, _e57, vec3(clamp(_e58, 0f, 1f)));
}

fn surfaceTime() -> f32 {
    var local_3: f32;
    var selected: f32;

    let _e56: f32 = global.material_SurfaceTimeOverride;
    if (_e56 >= 0f) {
        let _e59: f32 = global.material_SurfaceTimeOverride;
        local_3 = _e59;
    } else {
        let _e60: vec4<f32> = global.scene_ElapsedTime;
        local_3 = _e60.x;
    }
    let _e63: f32 = local_3;
    selected = _e63;
    let _e65: f32 = selected;
    let _e67: f32 = max(_e65, 0f);
    return (_e67 - (floor((_e67 / 4096f)) * 4096f));
}

fn safeNormalize2_(value_2: vec2<f32>, fallbackValue_2: vec2<f32>) -> vec2<f32> {
    var value_3: vec2<f32>;
    var fallbackValue_3: vec2<f32>;
    var lengthSquared_1: f32;
    var local_4: vec2<f32>;

    value_3 = value_2;
    fallbackValue_3 = fallbackValue_2;
    let _e60: vec2<f32> = value_3;
    let _e61: vec2<f32> = value_3;
    lengthSquared_1 = dot(_e60, _e61);
    let _e64: f32 = lengthSquared_1;
    if (_e64 > 0.000001f) {
        let _e67: vec2<f32> = value_3;
        let _e68: f32 = lengthSquared_1;
        local_4 = (_e67 * inverseSqrt(_e68));
    } else {
        let _e71: vec2<f32> = fallbackValue_3;
        local_4 = _e71;
    }
    let _e73: vec2<f32> = local_4;
    return _e73;
}

fn safeNormalize3_(value_4: vec3<f32>, fallbackValue_4: vec3<f32>) -> vec3<f32> {
    var value_5: vec3<f32>;
    var fallbackValue_5: vec3<f32>;
    var lengthSquared_2: f32;
    var local_5: vec3<f32>;

    value_5 = value_4;
    fallbackValue_5 = fallbackValue_4;
    let _e60: vec3<f32> = value_5;
    let _e61: vec3<f32> = value_5;
    lengthSquared_2 = dot(_e60, _e61);
    let _e64: f32 = lengthSquared_2;
    if (_e64 > 0.000001f) {
        let _e67: vec3<f32> = value_5;
        let _e68: f32 = lengthSquared_2;
        local_5 = (_e67 * inverseSqrt(_e68));
    } else {
        let _e71: vec3<f32> = fallbackValue_5;
        local_5 = _e71;
    }
    let _e73: vec3<f32> = local_5;
    return _e73;
}

fn frag(input: Varyings) -> HeightfieldSSRReceiverOutput {
    var input_1: Varyings;
    var localMap: vec4<f32>;
    var signedDistance: f32;
    var coverageHalfWidth: f32;
    var elapsedTime: f32;
    var flowXZ: vec2<f32>;
    var flowSpeed: f32;
    var flowWeight: f32;
    var sceneWindSpeed: f32;
    var local_6: vec2<f32>;
    var stillWaterDirection: vec2<f32>;
    var flowDirection: vec2<f32>;
    var baseWorldPosition: vec3<f32>;
    var surfaceNormalWS: vec3<f32>;
    var appearanceNormalTS: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var appearanceLayerCoordinate0_: vec2<f32>;
    var appearanceLayerScaled0_: vec2<f32>;
    var appearanceLayerUv0_: vec2<f32>;
    var appearanceLayerNormal0_: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var appearanceTangentWS: vec3<f32>;
    var appearanceBitangentWS: vec3<f32>;
    var appearanceSurfaceNormalWS: vec3<f32>;
    var rainRate: f32;
    var rainRippleStormAmount: f32;
    var rainRippleSurfaceRoughness: f32;
    var viewDirection: vec3<f32>;
    var ssrOutput: HeightfieldSSRReceiverOutput;

    input_1 = input;
    let _e58: f32 = global.material_ScreenSpaceReflectionIntensity;
    if (_e58 <= 0f) {
        discard;
    }
    let _e61: Varyings = input_1;
    let _e63: vec4<f32> = textureSample(gs_wgpu_tex_material_LocalMapTexture, gs_wgpu_samp_material_LocalMapTexture, _e61.atlasUv);
    localMap = _e63;
    let _e65: vec4<f32> = localMap;
    let _e71: vec4<f32> = global.material_LocalMapDecode;
    signedDistance = (((_e65.w * 2f) - 1f) * _e71.z);
    let _e75: Varyings = input_1;
    let _e78: f32 = signedDistance;
    let _e79: f32 = waterConnectionShore(_e75.worldPosition.xz, _e78);
    signedDistance = _e79;
    let _e81: f32 = signedDistance;
    let _e82: f32 = fwidth(_e81);
    let _e85: vec4<f32> = global.material_LocalMapDecode;
    coverageHalfWidth = max(0.08f, max((_e82 * 1.25f), (_e85.z * 0.007843138f)));
    let _e94: Varyings = input_1;
    let _e97: vec4<f32> = waterConnectionFacts(_e94.worldPosition.xz);
    if (_e97.w < 0.5f) {
        discard;
    }
    let _e101: f32 = coverageHalfWidth;
    let _e103: f32 = coverageHalfWidth;
    let _e104: f32 = signedDistance;
    if (smoothstep(-(_e101), _e103, _e104) <= 0.001f) {
        discard;
    }
    let _e108: f32 = surfaceTime();
    elapsedTime = _e108;
    let _e110: vec4<f32> = localMap;
    let _e117: vec4<f32> = global.material_LocalMapDecode;
    flowXZ = (((_e110.xy * 2f) - vec2(1f)) * _e117.x);
    let _e121: vec2<f32> = flowXZ;
    flowSpeed = length(_e121);
    let _e126: f32 = flowSpeed;
    flowWeight = smoothstep(0.055f, 0.756f, _e126);
    let _e129: vec3<f32> = waterWindVelocity();
    sceneWindSpeed = length(_e129.xz);
    let _e133: f32 = sceneWindSpeed;
    if (_e133 > 0.0001f) {
        let _e136: vec3<f32> = waterWindVelocity();
        let _e138: f32 = sceneWindSpeed;
        local_6 = (_e136.xz / vec2(_e138));
    } else {
        local_6 = vec2<f32>(-0.36f, -0.9329523f);
    }
    let _e147: vec2<f32> = local_6;
    stillWaterDirection = _e147;
    let _e149: vec2<f32> = stillWaterDirection;
    let _e150: vec2<f32> = flowXZ;
    let _e151: vec2<f32> = stillWaterDirection;
    let _e152: vec2<f32> = safeNormalize2_(_e150, _e151);
    let _e153: f32 = flowWeight;
    let _e158: vec2<f32> = stillWaterDirection;
    let _e159: vec2<f32> = safeNormalize2_(mix(_e149, _e152, vec2((_e153 * 0.88f))), _e158);
    flowDirection = _e159;
    let _e161: Varyings = input_1;
    let _e163: Varyings = input_1;
    let _e165: Varyings = input_1;
    baseWorldPosition = (_e161.worldPosition - (_e163.baseNormalWS * _e165.waveOffset));
    let _e170: Varyings = input_1;
    let _e172: Varyings = input_1;
    let _e174: vec3<f32> = safeNormalize3_(_e170.macroNormalWS, _e172.macroNormalWS);
    surfaceNormalWS = _e174;
    let _e181: vec3<f32> = baseWorldPosition;
    appearanceLayerCoordinate0_ = _e181.xz;
    let _e184: vec2<f32> = appearanceLayerCoordinate0_;
    let _e185: vec4<f32> = global.material_AppearanceV2Detail0Transform;
    appearanceLayerScaled0_ = (_e184 * _e185.xy);
    let _e189: vec2<f32> = appearanceLayerScaled0_;
    let _e191: vec2<f32> = global.material_AppearanceV2Detail0Rotation;
    let _e194: vec2<f32> = appearanceLayerScaled0_;
    let _e196: vec2<f32> = global.material_AppearanceV2Detail0Rotation;
    let _e200: vec2<f32> = appearanceLayerScaled0_;
    let _e202: vec2<f32> = global.material_AppearanceV2Detail0Rotation;
    let _e205: vec2<f32> = appearanceLayerScaled0_;
    let _e207: vec2<f32> = global.material_AppearanceV2Detail0Rotation;
    let _e212: vec4<f32> = global.material_AppearanceV2Detail0Transform;
    appearanceLayerUv0_ = (vec2<f32>(((_e189.x * _e191.x) - (_e194.y * _e196.y)), ((_e200.x * _e202.y) + (_e205.y * _e207.x))) + _e212.zw);
    let _e221: f32 = global.material_AppearanceV2Detail0Enabled;
    if (_e221 > 0.5f) {
        {
            let _e224: vec2<f32> = appearanceLayerUv0_;
            let _e225: vec4<f32> = textureSample(gs_wgpu_tex_material_AppearanceV2Detail0Texture, gs_wgpu_samp_material_AppearanceV2Detail0Texture, _e224);
            let _e226: f32 = global.material_AppearanceV2Detail0Strength;
            let _e228: vec3<f32> = waterSurfaceAppearanceDecodeTangentNormalPreserveSourceZ(_e225, _e226, 0f);
            appearanceLayerNormal0_ = _e228;
        }
    }
    let _e229: vec3<f32> = appearanceNormalTS;
    let _e230: vec3<f32> = appearanceLayerNormal0_;
    let _e231: vec3<f32> = waterSurfaceAppearanceBlendTangentNormalsPartialDerivative(_e229, _e230);
    appearanceNormalTS = _e231;
    let _e236: vec3<f32> = appearanceNormalTS;
    let _e237: f32 = global.material_AppearanceV2DetailNormalStrength;
    appearanceNormalTS = normalize(mix(vec3<f32>(0f, 0f, 1f), _e236, vec3(_e237)));
    let _e241: Varyings = input_1;
    let _e243: Varyings = input_1;
    let _e245: Varyings = input_1;
    let _e247: Varyings = input_1;
    let _e256: vec3<f32> = safeNormalize3_((_e241.tangentWS - (_e243.macroNormalWS * dot(_e245.tangentWS, _e247.macroNormalWS))), vec3<f32>(1f, 0f, 0f));
    appearanceTangentWS = _e256;
    let _e258: Varyings = input_1;
    let _e260: vec3<f32> = appearanceTangentWS;
    let _e266: vec3<f32> = safeNormalize3_(cross(_e258.macroNormalWS, _e260), vec3<f32>(0f, 0f, 1f));
    appearanceBitangentWS = _e266;
    let _e268: vec3<f32> = appearanceTangentWS;
    let _e269: vec3<f32> = appearanceNormalTS;
    let _e272: vec3<f32> = appearanceBitangentWS;
    let _e273: vec3<f32> = appearanceNormalTS;
    let _e277: Varyings = input_1;
    let _e279: vec3<f32> = appearanceNormalTS;
    let _e283: Varyings = input_1;
    let _e285: vec3<f32> = safeNormalize3_((((_e268 * _e269.x) + (_e272 * _e273.y)) + (_e277.macroNormalWS * _e279.z)), _e283.macroNormalWS);
    appearanceSurfaceNormalWS = _e285;
    let _e287: vec3<f32> = surfaceNormalWS;
    let _e288: vec3<f32> = appearanceSurfaceNormalWS;
    let _e289: f32 = global.material_AppearanceV2DetailEnabled;
    let _e290: f32 = global.material_MicroNormalsEnabled;
    let _e294: Varyings = input_1;
    let _e296: vec3<f32> = safeNormalize3_(mix(_e287, _e288, vec3((_e289 * _e290))), _e294.macroNormalWS);
    surfaceNormalWS = _e296;
    let _e297: Varyings = input_1;
    let _e300: vec3<f32> = surfaceNormalWS;
    let _e301: vec3<f32> = waterConnectionNormal(_e297.worldPosition.xz, _e300);
    surfaceNormalWS = _e301;
    let _e302: vec4<f32> = global.scene_WeatherState;
    let _e307: f32 = global.material_MicroNormalsEnabled;
    rainRate = (clamp(_e302.x, 0f, 1f) * _e307);
    let _e312: f32 = rainRate;
    rainRippleStormAmount = smoothstep(0.68f, 1f, _e312);
    let _e315: f32 = global.material_Roughness;
    let _e316: f32 = rainRippleStormAmount;
    let _e320: f32 = global.material_Roughness;
    rainRippleSurfaceRoughness = clamp((_e315 + (_e316 * 0.02f)), _e320, 1f);
    let _e324: f32 = rainRippleSurfaceRoughness;
    let _e325: vec4<f32> = global.camera_SSRParams;
    if (_e324 >= _e325.y) {
        discard;
    }
    let _e328: vec3<f32> = global.camera_Position;
    let _e329: Varyings = input_1;
    let _e336: vec3<f32> = safeNormalize3_((_e328 - _e329.worldPosition), vec3<f32>(0f, 1f, 0f));
    viewDirection = _e336;
    let _e338: vec3<f32> = surfaceNormalWS;
    let _e340: vec3<f32> = surfaceNormalWS;
    let _e341: vec3<f32> = viewDirection;
    surfaceNormalWS = (_e338 * ((step(0f, dot(_e340, _e341)) * 2f) - 1f));
    let _e351: vec3<f32> = surfaceNormalWS;
    let _e352: f32 = rainRippleSurfaceRoughness;
    let _e353: vec4<f32> = packSSRNormalRoughness(_e351, _e352);
    ssrOutput.normalRoughness = _e353;
    let _e356: vec4<f32> = gl_FragCoord_1;
    let _e358: f32 = remapDepthBufferEyeDepth(_e356.z);
    let _e359: vec4<f32> = global.camera_ProjectionParams;
    let _e361: vec4<f32> = encodeSSRDepth(_e358, _e359.z);
    ssrOutput.receiverDepth = _e361;
    let _e362: HeightfieldSSRReceiverOutput = ssrOutput;
    return _e362;
}

fn gs_wgpu_main() {
    var input_input: Varyings;

    let _e57: Varyings = read_Varyings();
    input_input = _e57;
    let _e59: Varyings = input_input;
    let _e60: HeightfieldSSRReceiverOutput = frag(_e59);
    write_HeightfieldSSRReceiverOutput(_e60);
    return;
}

fn main_1() {
    gs_wgpu_main();
    return;
}

@fragment 
fn main(@location(0) worldPosition: vec3<f32>, @location(3) macroNormalWS: vec3<f32>, @location(4) baseNormalWS: vec3<f32>, @location(5) tangentWS: vec3<f32>, @location(6) atlasUv: vec2<f32>, @location(7) waveOffset: f32, @builtin(position) gl_FragCoord: vec4<f32>) -> FragmentOutput {
    worldPosition_1 = worldPosition;
    macroNormalWS_1 = macroNormalWS;
    baseNormalWS_1 = baseNormalWS;
    tangentWS_1 = tangentWS;
    atlasUv_1 = atlasUv;
    waveOffset_1 = waveOffset;
    gl_FragCoord_1 = gl_FragCoord;
    main_1();
    let _e83: vec4<f32> = output_color;
    let _e85: vec4<f32> = output_color_1_;
    return FragmentOutput(_e83, _e85);
}
