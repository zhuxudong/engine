diagnostic(off, derivative_uniformity);
struct gs_Auto_0_ {
    renderer_MVPMat: mat4x4<f32>,
    renderer_ModelMat: mat4x4<f32>,
    camera_DepthBufferParams: vec4<f32>,
    camera_ProjectionParams: vec4<f32>,
    camera_ViewInvMat: mat4x4<f32>,
    camera_Position: vec3<f32>,
    scene_ElapsedTime: vec4<f32>,
    renderer_Layer: vec4<i32>,
    scene_WindVelocity: vec3<f32>,
    material_WindVelocity: vec3<f32>,
    material_WindVelocityOverride: f32,
    material_AppearanceV2Detail0Enabled: f32,
    material_AppearanceV2Detail1Enabled: f32,
    material_AppearanceV2DetailEnabled: f32,
    material_AppearanceV2DetailNormalStrength: f32,
    material_AppearanceV2DepthResponseEnabled: f32,
    material_AppearanceV2BoundaryAlphaEnabled: f32,
    material_AppearanceV2BoundaryMaterialEnabled: f32,
    material_AppearanceV2RefractionUvScale: f32,
    material_AppearanceV2Detail0Transform: vec4<f32>,
    material_AppearanceV2Detail0Rotation: vec2<f32>,
    material_AppearanceV2Detail0Strength: f32,
    material_AppearanceV2Detail1Transform: vec4<f32>,
    material_AppearanceV2Detail1Rotation: vec2<f32>,
    material_AppearanceV2Detail1Strength: f32,
    material_AppearanceV2DepthDistance: f32,
    material_AppearanceV2DepthExponent: f32,
    material_AppearanceV2DepthColor: vec4<f32>,
    material_AppearanceV2Boundary0Range: f32,
    material_AppearanceV2Boundary0Alpha: f32,
    material_AppearanceV2Boundary1Range: f32,
    material_AppearanceV2Boundary1Color: vec3<f32>,
    material_AppearanceV2Boundary1Roughness: f32,
    material_AppearanceV2Boundary1PatternWorldScale: f32,
    material_AppearanceV2Boundary1PatternTimeRate: f32,
    material_AppearanceV2Boundary1PatternOpacity: f32,
    material_AppearanceV2Boundary1PatternWeights: vec3<f32>,
    material_AppearanceV2Boundary1PatternLacunarity: f32,
    material_AppearanceV2Boundary1PatternExponent: f32,
    material_AppearanceDirectSpecularEnabled: f32,
    material_WaterWorldToLocalPlanar: vec4<f32>,
    material_ShallowColor: vec4<f32>,
    material_Alpha: f32,
    material_Clarity: f32,
    material_SurfaceTimeOverride: f32,
    material_RefractionEnabled: f32,
    material_CompositionMode: f32,
    material_MicroNormalsEnabled: f32,
    material_AbsorptionCoefficient: vec3<f32>,
    material_ScatteringColor: vec3<f32>,
    material_ScatteringCoefficient: f32,
    material_MaximumSurfaceOpticalDistance: f32,
    material_FresnelF0_: f32,
    material_Roughness: f32,
    material_ReflectionIntensity: f32,
    material_ReflectionSource: f32,
    material_WaterScreenSpaceReflectionCompositeIntensity: f32,
    material_EnvironmentReflectionParameters: vec4<f32>,
    material_EnvironmentFallbackIntensity: f32,
    material_EnvironmentReflectionMaximumMip: f32,
    material_EnvironmentReflectionProbePosition: vec4<f32>,
    material_EnvironmentReflectionBoxMinimum: vec4<f32>,
    material_EnvironmentReflectionBoxMaximum: vec4<f32>,
    material_SecondaryEnvironmentReflectionParameters: vec4<f32>,
    material_SecondaryEnvironmentReflectionMaximumMip: f32,
    material_SecondaryEnvironmentReflectionProbePosition: vec4<f32>,
    material_SecondaryEnvironmentReflectionBoxMinimum: vec4<f32>,
    material_SecondaryEnvironmentReflectionBoxMaximum: vec4<f32>,
    material_EnvironmentReflectionAvailable: f32,
    material_EnvironmentReflectionBlend: f32,
    scene_WeatherState: vec4<f32>,
    scene_WeatherTime: f32,
}

struct gs_Auto_1_ {
    camera_ViewMat: mat4x4<f32>,
    material_LocalMapDecode: vec4<f32>,
    material_ShoreDampingWidth: f32,
}

struct Attributes {
    POSITION: vec4<f32>,
    NORMAL: vec3<f32>,
    TANGENT: vec4<f32>,
    TEXCOORD_0_: vec2<f32>,
}

struct Varyings {
    worldPosition: vec3<f32>,
    objectPosition: vec3<f32>,
    meshUv: vec2<f32>,
    baseNormalWS: vec3<f32>,
    macroNormalWS: vec3<f32>,
    tangentWS: vec3<f32>,
    atlasUv: vec2<f32>,
    waveOffset: f32,
    surfaceEyeDepth: f32,
    shoreDamping: f32,
    clipPosition: vec4<f32>,
}

struct VertexOutput {
    @location(0) worldPosition: vec3<f32>,
    @location(1) objectPosition: vec3<f32>,
    @location(2) meshUv: vec2<f32>,
    @location(3) baseNormalWS: vec3<f32>,
    @location(4) macroNormalWS: vec3<f32>,
    @location(5) tangentWS: vec3<f32>,
    @location(6) atlasUv: vec2<f32>,
    @location(7) waveOffset: f32,
    @location(8) surfaceEyeDepth: f32,
    @location(9) shoreDamping: f32,
    @location(10) clipPosition: vec4<f32>,
    @builtin(position) gl_Position: vec4<f32>,
}

@group(2) @binding(0) 
var<uniform> global: gs_Auto_0_;
@group(2) @binding(1) 
var<uniform> global_1: gs_Auto_1_;
@group(2) @binding(2) 
var gs_wgpu_tex_material_LocalMapTexture: texture_2d<f32>;
@group(2) @binding(3) 
var gs_wgpu_samp_material_LocalMapTexture: sampler;
var<private> POSITION_1: vec4<f32>;
var<private> NORMAL_1: vec3<f32>;
var<private> TANGENT_1: vec4<f32>;
var<private> TEXCOORD_0_1: vec2<f32>;
var<private> worldPosition: vec3<f32>;
var<private> objectPosition: vec3<f32>;
var<private> meshUv: vec2<f32>;
var<private> baseNormalWS: vec3<f32>;
var<private> macroNormalWS: vec3<f32>;
var<private> tangentWS: vec3<f32>;
var<private> atlasUv: vec2<f32>;
var<private> waveOffset_1: f32;
var<private> surfaceEyeDepth: f32;
var<private> shoreDamping_1: f32;
var<private> clipPosition: vec4<f32>;
var<private> gl_Position: vec4<f32>;

fn read_Attributes() -> Attributes {
    var interface_value: Attributes;

    let _e158: vec4<f32> = POSITION_1;
    interface_value.POSITION = _e158;
    let _e160: vec3<f32> = NORMAL_1;
    interface_value.NORMAL = _e160;
    let _e162: vec4<f32> = TANGENT_1;
    interface_value.TANGENT = _e162;
    let _e164: vec2<f32> = TEXCOORD_0_1;
    interface_value.TEXCOORD_0_ = _e164;
    let _e165: Attributes = interface_value;
    return _e165;
}

fn write_Varyings(interface_value_1: Varyings) {
    var interface_value_2: Varyings;

    interface_value_2 = interface_value_1;
    let _e169: Varyings = interface_value_2;
    worldPosition = _e169.worldPosition;
    let _e171: Varyings = interface_value_2;
    objectPosition = _e171.objectPosition;
    let _e173: Varyings = interface_value_2;
    meshUv = _e173.meshUv;
    let _e175: Varyings = interface_value_2;
    baseNormalWS = _e175.baseNormalWS;
    let _e177: Varyings = interface_value_2;
    macroNormalWS = _e177.macroNormalWS;
    let _e179: Varyings = interface_value_2;
    tangentWS = _e179.tangentWS;
    let _e181: Varyings = interface_value_2;
    atlasUv = _e181.atlasUv;
    let _e183: Varyings = interface_value_2;
    waveOffset_1 = _e183.waveOffset;
    let _e185: Varyings = interface_value_2;
    surfaceEyeDepth = _e185.surfaceEyeDepth;
    let _e187: Varyings = interface_value_2;
    shoreDamping_1 = _e187.shoreDamping;
    let _e189: Varyings = interface_value_2;
    clipPosition = _e189.clipPosition;
    return;
}

fn waterSpatialFieldDecodeDepth(encodedDepth: f32, maximumDepth: f32) -> f32 {
    var encodedDepth_1: f32;
    var maximumDepth_1: f32;

    encodedDepth_1 = encodedDepth;
    maximumDepth_1 = maximumDepth;
    let _e171: f32 = encodedDepth_1;
    let _e172: f32 = maximumDepth_1;
    return (_e171 * _e172);
}

fn waterSpatialFieldDecodeSignedDistance(encodedDistance: f32, decodeScale: f32, decodeBias: f32, signedDistanceRange: f32) -> f32 {
    var encodedDistance_1: f32;
    var decodeScale_1: f32;
    var decodeBias_1: f32;
    var signedDistanceRange_1: f32;

    encodedDistance_1 = encodedDistance;
    decodeScale_1 = decodeScale;
    decodeBias_1 = decodeBias;
    signedDistanceRange_1 = signedDistanceRange;
    let _e175: f32 = encodedDistance_1;
    let _e176: f32 = decodeScale_1;
    let _e178: f32 = decodeBias_1;
    let _e180: f32 = signedDistanceRange_1;
    return (((_e175 * _e176) + _e178) * _e180);
}

fn waterConnectionFacts(p: vec2<f32>) -> vec4<f32> {
    var p_1: vec2<f32>;
    var result: vec4<f32> = vec4<f32>(1f, 1f, -1f, 1f);

    p_1 = p;
    let _e176: vec4<f32> = result;
    return _e176;
}

fn waterConnectionShore(p_2: vec2<f32>, original: f32) -> f32 {
    var p_3: vec2<f32>;
    var original_1: f32;
    var result_1: f32;

    p_3 = p_2;
    original_1 = original;
    let _e171: f32 = original_1;
    result_1 = _e171;
    let _e173: f32 = result_1;
    return _e173;
}

fn safeNormalize2_(value: vec2<f32>, fallbackValue: vec2<f32>) -> vec2<f32> {
    var value_1: vec2<f32>;
    var fallbackValue_1: vec2<f32>;
    var lengthSquared: f32;
    var local: vec2<f32>;

    value_1 = value;
    fallbackValue_1 = fallbackValue;
    let _e171: vec2<f32> = value_1;
    let _e172: vec2<f32> = value_1;
    lengthSquared = dot(_e171, _e172);
    let _e175: f32 = lengthSquared;
    if (_e175 > 0.000001f) {
        let _e178: vec2<f32> = value_1;
        let _e179: f32 = lengthSquared;
        local = (_e178 * inverseSqrt(_e179));
    } else {
        let _e182: vec2<f32> = fallbackValue_1;
        local = _e182;
    }
    let _e184: vec2<f32> = local;
    return _e184;
}

fn vert(attr: Attributes) -> Varyings {
    var attr_1: Attributes;
    var output: Varyings;
    var baseWorldPosition: vec4<f32>;
    var computedBaseNormalWS: vec3<f32>;
    var computedBaseTangentWS: vec3<f32>;
    var computedBaseBitangentWS: vec3<f32>;
    var computedAtlasUv: vec2<f32>;
    var localMap: vec4<f32>;
    var flowXZ: vec2<f32>;
    var authoredDepth: f32;
    var signedDistance: f32;
    var shoreDamping: f32;
    var flowSpeed: f32;
    var flowWeight: f32;
    var flowDirection: vec2<f32>;
    var macroFlowAlignment: f32;
    var macroAmplitudeScale: f32;
    var waveOffset: f32 = 0f;
    var tangentSlope: f32 = 0f;
    var bitangentSlope: f32 = 0f;
    var computedMacroNormalWS: vec3<f32>;
    var displacedWorldPosition: vec3<f32>;
    var localPosition: vec4<f32>;
    var computedClipPosition: vec4<f32>;

    attr_1 = attr;
    let _e170: mat4x4<f32> = global.renderer_ModelMat;
    let _e171: Attributes = attr_1;
    baseWorldPosition = (_e170 * _e171.POSITION);
    let _e175: mat4x4<f32> = global.renderer_ModelMat;
    let _e185: Attributes = attr_1;
    computedBaseNormalWS = normalize((mat3x3<f32>(_e175[0].xyz, _e175[1].xyz, _e175[2].xyz) * _e185.NORMAL));
    let _e190: mat4x4<f32> = global.renderer_ModelMat;
    let _e200: Attributes = attr_1;
    computedBaseTangentWS = normalize((mat3x3<f32>(_e190[0].xyz, _e190[1].xyz, _e190[2].xyz) * _e200.TANGENT.xyz));
    let _e206: vec3<f32> = computedBaseNormalWS;
    let _e207: vec3<f32> = computedBaseTangentWS;
    let _e209: Attributes = attr_1;
    computedBaseBitangentWS = normalize((cross(_e206, _e207) * _e209.TANGENT.w));
    let _e215: Attributes = attr_1;
    computedAtlasUv = _e215.TEXCOORD_0_;
    let _e218: vec2<f32> = computedAtlasUv;
    let _e220: vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_LocalMapTexture, gs_wgpu_samp_material_LocalMapTexture, _e218, 0f);
    localMap = _e220;
    let _e222: vec4<f32> = localMap;
    let _e229: vec4<f32> = global_1.material_LocalMapDecode;
    flowXZ = (((_e222.xy * 2f) - vec2(1f)) * _e229.x);
    let _e233: vec4<f32> = localMap;
    let _e235: vec4<f32> = global_1.material_LocalMapDecode;
    let _e237: f32 = waterSpatialFieldDecodeDepth(_e233.z, _e235.y);
    authoredDepth = _e237;
    let _e239: vec4<f32> = localMap;
    let _e244: vec4<f32> = global_1.material_LocalMapDecode;
    let _e246: f32 = waterSpatialFieldDecodeSignedDistance(_e239.w, 2f, -1f, _e244.z);
    signedDistance = _e246;
    let _e248: vec4<f32> = baseWorldPosition;
    let _e250: f32 = signedDistance;
    let _e251: f32 = waterConnectionShore(_e248.xz, _e250);
    signedDistance = _e251;
    let _e253: f32 = global_1.material_ShoreDampingWidth;
    let _e256: f32 = signedDistance;
    shoreDamping = smoothstep(0f, max(_e253, 0.0001f), _e256);
    let _e259: vec2<f32> = flowXZ;
    flowSpeed = length(_e259);
    let _e264: f32 = flowSpeed;
    flowWeight = smoothstep(0.055f, 0.756f, _e264);
    let _e267: vec2<f32> = flowXZ;
    let _e273: vec2<f32> = safeNormalize2_(_e267, vec2<f32>(-0.36f, -0.9329523f));
    flowDirection = _e273;
    let _e275: f32 = flowWeight;
    macroFlowAlignment = (_e275 * 0.72f);
    let _e281: f32 = flowWeight;
    macroAmplitudeScale = mix(0.3f, 1f, _e281);
    let _e290: vec3<f32> = computedBaseNormalWS;
    let _e291: vec3<f32> = computedBaseTangentWS;
    let _e292: f32 = tangentSlope;
    let _e295: vec3<f32> = computedBaseBitangentWS;
    let _e296: f32 = bitangentSlope;
    computedMacroNormalWS = normalize(((_e290 - (_e291 * _e292)) - (_e295 * _e296)));
    let _e301: f32 = waveOffset;
    let _e302: vec4<f32> = baseWorldPosition;
    let _e304: vec4<f32> = waterConnectionFacts(_e302.xz);
    waveOffset = (_e301 * _e304.x);
    let _e307: vec4<f32> = baseWorldPosition;
    let _e309: vec3<f32> = computedBaseNormalWS;
    let _e310: f32 = waveOffset;
    displacedWorldPosition = (_e307.xyz + (_e309 * _e310));
    let _e314: Attributes = attr_1;
    let _e316: Attributes = attr_1;
    let _e318: f32 = waveOffset;
    let _e319: vec3<f32> = (_e316.NORMAL * _e318);
    localPosition = (_e314.POSITION + vec4<f32>(_e319.x, _e319.y, _e319.z, 0f));
    let _e327: mat4x4<f32> = global.renderer_MVPMat;
    let _e328: vec4<f32> = localPosition;
    computedClipPosition = (_e327 * _e328);
    let _e332: vec4<f32> = computedClipPosition;
    gl_Position = _e332;
    let _e334: vec3<f32> = displacedWorldPosition;
    output.worldPosition = _e334;
    let _e336: Attributes = attr_1;
    output.objectPosition = _e336.POSITION.xyz;
    let _e340: Attributes = attr_1;
    output.meshUv = _e340.TEXCOORD_0_;
    let _e343: vec3<f32> = computedBaseNormalWS;
    output.baseNormalWS = _e343;
    let _e345: vec3<f32> = computedMacroNormalWS;
    output.macroNormalWS = _e345;
    let _e347: vec3<f32> = computedBaseTangentWS;
    output.tangentWS = _e347;
    let _e349: vec2<f32> = computedAtlasUv;
    output.atlasUv = _e349;
    let _e351: f32 = waveOffset;
    output.waveOffset = _e351;
    let _e353: mat4x4<f32> = global_1.camera_ViewMat;
    let _e354: vec3<f32> = displacedWorldPosition;
    output.surfaceEyeDepth = -((_e353 * vec4<f32>(_e354.x, _e354.y, _e354.z, 1f)).z);
    let _e364: f32 = shoreDamping;
    output.shoreDamping = _e364;
    let _e366: vec4<f32> = computedClipPosition;
    output.clipPosition = _e366;
    let _e367: Varyings = output;
    return _e367;
}

fn gs_wgpu_main() {
    var input_attr: Attributes;

    let _e168: Attributes = read_Attributes();
    input_attr = _e168;
    let _e170: Attributes = input_attr;
    let _e171: Varyings = vert(_e170);
    write_Varyings(_e171);
    return;
}

fn main_1() {
    gs_wgpu_main();
    let _e170: vec4<f32> = gl_Position;
    let _e172: vec4<f32> = gl_Position;
    gl_Position.z = (0.5f * (_e170.z + _e172.w));
    return;
}

@vertex 
fn main(@location(0) POSITION: vec4<f32>, @location(1) NORMAL: vec3<f32>, @location(2) TANGENT: vec4<f32>, @location(3) TEXCOORD_0_: vec2<f32>) -> VertexOutput {
    POSITION_1 = POSITION;
    NORMAL_1 = NORMAL;
    TANGENT_1 = TANGENT;
    TEXCOORD_0_1 = TEXCOORD_0_;
    main_1();
    let _e193: vec3<f32> = worldPosition;
    let _e195: vec3<f32> = objectPosition;
    let _e197: vec2<f32> = meshUv;
    let _e199: vec3<f32> = baseNormalWS;
    let _e201: vec3<f32> = macroNormalWS;
    let _e203: vec3<f32> = tangentWS;
    let _e205: vec2<f32> = atlasUv;
    let _e207: f32 = waveOffset_1;
    let _e209: f32 = surfaceEyeDepth;
    let _e211: f32 = shoreDamping_1;
    let _e213: vec4<f32> = clipPosition;
    let _e215: vec4<f32> = gl_Position;
    return VertexOutput(_e193, _e195, _e197, _e199, _e201, _e203, _e205, _e207, _e209, _e211, _e213, _e215);
}
