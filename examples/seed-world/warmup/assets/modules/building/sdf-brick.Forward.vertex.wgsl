diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(2) @group(3) var gs_wgpu_tex_storage_0_2 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_2 : sampler;

@binding(4) @group(3) var gs_wgpu_tex_storage_0_1 : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_storage_0_1 : sampler;

@binding(10) @group(3) var gs_wgpu_tex_storage_9_0 : texture_2d<u32>;

@binding(11) @group(3) var gs_wgpu_samp_storage_9_0 : sampler;

@binding(12) @group(3) var gs_wgpu_tex_storage_8_1 : texture_2d<u32>;

@binding(13) @group(3) var gs_wgpu_samp_storage_8_1 : sampler;

@binding(14) @group(3) var gs_wgpu_tex_storage_7_0 : texture_2d<u32>;

@binding(15) @group(3) var gs_wgpu_samp_storage_7_0 : sampler;

@binding(16) @group(3) var gs_wgpu_tex_storage_10_0 : texture_2d<u32>;

@binding(17) @group(3) var gs_wgpu_samp_storage_10_0 : sampler;

@binding(0) @group(3) var gs_wgpu_tex_uniform_MaterialData_natural : texture_2d<u32>;

@binding(1) @group(3) var gs_wgpu_samp_uniform_MaterialData_natural : sampler;

@binding(6) @group(3) var gs_wgpu_tex_uniform_ViewConstants_natural : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_uniform_ViewConstants_natural : sampler;

@binding(8) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

var<private> gl_InstanceIndex : i32;

var<private> gl_VertexIndex : i32;

@binding(0) @group(2) var<uniform> x_2921 : gs_Auto_0;

var<private> v0 : u32;

var<private> v2 : vec3<f32>;

var<private> v3 : vec3<f32>;

var<private> v4 : vec3<f32>;

var<private> v5 : f32;

var<private> v7 : f32;

var<private> v8 : f32;

var<private> v9 : vec2<f32>;

var<private> v10 : i32;

var<private> v11 : vec2<f32>;

var<private> v12 : i32;

var<private> v13 : u32;

var<private> v14_col0 : vec3<f32>;

var<private> v14_col1 : vec3<f32>;

var<private> v14_col2 : vec3<f32>;

var<private> gl_Position : vec4<f32>;

const x_880 = vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f);

const x_2358 = vec2<f32>(0.5f, 0.5f);

const x_2451 = vec3<f32>(0.0f, 1.0f, 0.0f);

fn main_1() {
  var x_3302 : vec2<f32>;
  var x_3326 : vec2<f32>;
  var x_3350 : vec2<f32>;
  var x_3374 : vec2<f32>;
  var x_3398 : vec2<f32>;
  var x_3422 : vec2<f32>;
  var x_3446 : vec2<f32>;
  var x_3470 : vec2<f32>;
  var x_12035 : u32;
  var x_23370 : u32;
  var x_12045 : u32;
  var x_23371 : u32;
  var x_12055 : u32;
  var x_23372 : u32;
  var x_23768 : mat3x4<f32>;
  var x_23387 : mat3x4<f32>;
  var x_3821 : i32;
  var x_23381 : i32;
  var x_3871 : vec3<f32>;
  var x_23911 : vec3<f32>;
  var x_23389 : u32;
  var x_23388 : u32;
  var x_23392 : u32;
  var x_23391 : u32;
  var x_23395 : u32;
  var x_23394 : u32;
  var x_23398 : u32;
  var x_23397 : u32;
  var x_23401 : u32;
  var x_23400 : u32;
  var x_23404 : u32;
  var x_23403 : u32;
  var x_23407 : u32;
  var x_23406 : u32;
  var x_23410 : u32;
  var x_23409 : u32;
  var x_5067 : i32;
  var x_23513 : i32;
  var x_5123 : f32;
  var x_5132 : f32;
  var x_23617 : f32;
  var x_23538 : i32;
  var x_5180 : i32;
  var x_23515 : i32;
  var x_23625 : i32;
  var x_23566 : i32;
  var x_22316 : u32;
  var x_22976 : u32;
  var x_23547 : u32;
  var x_5337 : vec2<f32>;
  var x_5343 : vec2<f32>;
  var x_23567 : vec2<f32>;
  var x_5352 : vec2<f32>;
  var x_23573 : vec2<f32>;
  var x_5362 : vec2<f32>;
  var x_23620 : vec2<f32>;
  let x_3070 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_MaterialData_natural, vec2<i32>(0i, 0i), 0i);
  let x_3084 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_3089 : i32 = x_3084.x;
  let x_3096 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((20i % x_3089), (20i / x_3089)), 0i);
  let x_3108 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((21i % x_3089), (21i / x_3089)), 0i);
  let x_3120 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((22i % x_3089), (22i / x_3089)), 0i);
  let x_3132 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((23i % x_3089), (23i / x_3089)), 0i);
  let x_3194 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_3199 : i32 = x_3194.x;
  let x_3206 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((15i % x_3199), (15i / x_3199)), 0i);
  let x_3208 : u32 = x_3206.y;
  let x_3569 : bool = (x_3070.x != 0u);
  let x_3570 : i32 = gl_InstanceIndex;
  let x_5447 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_5452 : i32 = (x_3570 / 4i);
  let x_5454 : i32 = x_5447.x;
  let x_5463 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_5454), (x_5452 / x_5454)), 0i);
  let x_5465 : i32 = (x_3570 % 4i);
  let x_5548 : i32 = ((bitcast<i32>(x_5463[x_5465]) * 16i) + 8i);
  let x_5824 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_5829 : i32 = (x_5548 / 4i);
  let x_5831 : i32 = x_5824.x;
  let x_5840 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5829 % x_5831), (x_5829 / x_5831)), 0i);
  let x_3578 : vec2<f32> = unpack2x16float(x_5840[(x_5548 % 4i)]);
  let x_6047 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_6054 : i32 = x_6047.x;
  let x_6063 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_6054), (x_5452 / x_6054)), 0i);
  let x_6156 : i32 = ((bitcast<i32>(x_6063[x_5465]) * 16i) + 9i);
  let x_6450 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_6455 : i32 = (x_6156 / 4i);
  let x_6457 : i32 = x_6450.x;
  let x_6466 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_6455 % x_6457), (x_6455 / x_6457)), 0i);
  let x_3585 : vec2<f32> = unpack2x16float(x_6466[(x_6156 % 4i)]);
  let x_6646 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_6653 : i32 = x_6646.x;
  let x_6662 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_6653), (x_5452 / x_6653)), 0i);
  let x_6785 : i32 = ((bitcast<i32>(x_6662[x_5465]) * 16i) + 13i);
  let x_7157 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_7162 : i32 = (x_6785 / 4i);
  let x_7164 : i32 = x_7157.x;
  let x_7173 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_7162 % x_7164), (x_7162 / x_7164)), 0i);
  let x_7176 : u32 = x_7173[(x_6785 % 4i)];
  let x_3599 : i32 = -(bitcast<i32>((x_7176 & 1u)));
  let x_3604 : i32 = (1i - bitcast<i32>((((x_7176 & 3u) >> 1u) << 1u)));
  let x_3609 : f32 = f32((~(x_3599) & x_3604));
  let x_3613 : f32 = f32((x_3599 & x_3604));
  let x_7245 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_7252 : i32 = x_7245.x;
  let x_7261 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_7252), (x_5452 / x_7252)), 0i);
  let x_7294 : i32 = ((bitcast<i32>(x_7261[x_5465]) * 16i) + 1i);
  let x_7432 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_7437 : i32 = (x_7294 / 4i);
  let x_7439 : i32 = x_7432.x;
  let x_7448 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_7437 % x_7439), (x_7437 / x_7439)), 0i);
  let x_3620 : vec2<f32> = unpack2x16float(x_7448[(x_7294 % 4i)]);
  let x_7844 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_7851 : i32 = x_7844.x;
  let x_7860 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_7851), (x_5452 / x_7851)), 0i);
  let x_7883 : i32 = (bitcast<i32>(x_7860[x_5465]) * 16i);
  let x_8004 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_8009 : i32 = (x_7883 / 4i);
  let x_8011 : i32 = x_8004.x;
  let x_8020 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_8009 % x_8011), (x_8009 / x_8011)), 0i);
  let x_3627 : vec2<f32> = unpack2x16float(x_8020[(x_7883 % 4i)]);
  let x_8443 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_8450 : i32 = x_8443.x;
  let x_8459 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_8450), (x_5452 / x_8450)), 0i);
  let x_8499 : i32 = ((bitcast<i32>(x_8459[x_5465]) * 16i) + 2i);
  let x_8657 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_8662 : i32 = (x_8499 / 4i);
  let x_8664 : i32 = x_8657.x;
  let x_8673 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_8662 % x_8664), (x_8662 / x_8664)), 0i);
  let x_3641 : vec2<f32> = unpack2x16float(x_8673[(x_8499 % 4i)]);
  let x_9042 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_9049 : i32 = x_9042.x;
  let x_9058 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_9049), (x_5452 / x_9049)), 0i);
  let x_9105 : i32 = ((bitcast<i32>(x_9058[x_5465]) * 16i) + 3i);
  let x_9283 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_9288 : i32 = (x_9105 / 4i);
  let x_9290 : i32 = x_9283.x;
  let x_9299 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_9288 % x_9290), (x_9288 / x_9290)), 0i);
  let x_3651 : vec2<f32> = unpack2x16float(x_9299[(x_9105 % 4i)]);
  let x_9641 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_9648 : i32 = x_9641.x;
  let x_9657 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_9648), (x_5452 / x_9648)), 0i);
  let x_9711 : i32 = ((bitcast<i32>(x_9657[x_5465]) * 16i) + 4i);
  let x_9909 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_9914 : i32 = (x_9711 / 4i);
  let x_9916 : i32 = x_9909.x;
  let x_9925 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_9914 % x_9916), (x_9914 / x_9916)), 0i);
  let x_10240 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_10247 : i32 = x_10240.x;
  let x_10256 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_10247), (x_5452 / x_10247)), 0i);
  let x_10317 : i32 = ((bitcast<i32>(x_10256[x_5465]) * 16i) + 5i);
  let x_10535 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_10540 : i32 = (x_10317 / 4i);
  let x_10542 : i32 = x_10535.x;
  let x_10551 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_10540 % x_10542), (x_10540 / x_10542)), 0i);
  let x_10839 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_10846 : i32 = x_10839.x;
  let x_10855 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_10846), (x_5452 / x_10846)), 0i);
  let x_10925 : i32 = ((bitcast<i32>(x_10855[x_5465]) * 16i) + 6i);
  let x_11161 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_11166 : i32 = (x_10925 / 4i);
  let x_11168 : i32 = x_11161.x;
  let x_11177 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_11166 % x_11168), (x_11166 / x_11168)), 0i);
  let x_11438 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_11445 : i32 = x_11438.x;
  let x_11454 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_11445), (x_5452 / x_11445)), 0i);
  let x_11531 : i32 = ((bitcast<i32>(x_11454[x_5465]) * 16i) + 7i);
  let x_11787 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_11792 : i32 = (x_11531 / 4i);
  let x_11794 : i32 = x_11787.x;
  let x_11803 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_11792 % x_11794), (x_11792 / x_11794)), 0i);
  let x_3702 : mat3x4<f32> = transpose(mat4x3<f32>(vec3<f32>(x_3627.x, x_3627.y, x_3620.x), vec3<f32>(x_3620.y, x_3641.x, x_3641.y), vec3<f32>(x_3651.x, x_3651.y, unpack2x16float(x_9925[(x_9711 % 4i)]).x), vec3<f32>(bitcast<f32>(x_10551[(x_10317 % 4i)]), bitcast<f32>(x_11177[(x_10925 % 4i)]), bitcast<f32>(x_11803[(x_11531 % 4i)]))));
  var x_23726_1 : mat3x4<f32> = x_3702;
  x_23726_1[0u].w = x_3702[0u].w;
  let x_23726 : mat3x4<f32> = x_23726_1;
  var x_23729_1 : mat3x4<f32> = x_23726;
  x_23729_1[1u].w = x_3702[1u].w;
  let x_23729 : mat3x4<f32> = x_23729_1;
  var x_23732_1 : mat3x4<f32> = x_23729;
  x_23732_1[2u].w = x_3702[2u].w;
  let x_23732 : mat3x4<f32> = x_23732_1;
  let x_3715 : i32 = gl_VertexIndex;
  let x_3717 : u32 = bitcast<u32>(x_3715);
  let x_3720 : u32 = ((x_3717 & 4u) >> 2u);
  let x_3723 : u32 = ((x_3717 & 2u) >> 1u);
  let x_3725 : u32 = (x_3717 & 1u);
  let x_3729 : vec4<f32> = (mat4x4<f32>(vec4<f32>(bitcast<f32>(x_3096.x), bitcast<f32>(x_3108.x), bitcast<f32>(x_3120.x), bitcast<f32>(x_3132.x)), vec4<f32>(bitcast<f32>(x_3096.y), bitcast<f32>(x_3108.y), bitcast<f32>(x_3120.y), bitcast<f32>(x_3132.y)), vec4<f32>(bitcast<f32>(x_3096.z), bitcast<f32>(x_3108.z), bitcast<f32>(x_3120.z), bitcast<f32>(x_3132.z)), vec4<f32>(bitcast<f32>(x_3096.w), bitcast<f32>(x_3108.w), bitcast<f32>(x_3120.w), bitcast<f32>(x_3132.w))) * x_880);
  let x_3733 : f32 = x_3729.w;
  let x_3735 : vec3<f32> = (vec3<f32>(x_3729.x, x_3729.y, x_3729.z) / vec3<f32>(x_3733, x_3733, x_3733));
  let x_3737 : vec3<u32> = (vec3<u32>(1u, 1u, 1u) - vec3<u32>(x_3720, x_3723, x_3725));
  let x_3739 : vec4<f32> = x_23726[0u];
  let x_3742 : vec4<f32> = x_23729[1u];
  let x_3745 : vec4<f32> = x_23732[2u];
  let x_3765 : vec3<bool> = ((mat3x3<f32>(vec3<f32>(x_3739.x, x_3739.y, x_3739.z), vec3<f32>(x_3742.x, x_3742.y, x_3742.z), vec3<f32>(x_3745.x, x_3745.y, x_3745.z)) * (x_3735 - (x_880 * x_23732))) > vec3<f32>(0.0f, 0.0f, 0.0f));
  if (x_3765.x) {
    x_23370 = x_3720;
  } else {
    x_12035 = x_3737.x;
    x_23370 = x_12035;
  }
  if (x_3765.y) {
    x_23371 = x_3723;
  } else {
    x_12045 = x_3737.y;
    x_23371 = x_12045;
  }
  if (x_3765.z) {
    x_23372 = x_3725;
  } else {
    x_12055 = x_3737.z;
    x_23372 = x_12055;
  }
  let x_3769 : vec3<f32> = (vec3<f32>(vec3<u32>(x_23370, x_23371, x_23372)) - vec3<f32>(0.5f, 0.5f, 0.5f));
  let x_12073 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_12080 : i32 = x_12073.x;
  let x_12089 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_12080), (x_5452 / x_12080)), 0i);
  let x_12222 : i32 = ((bitcast<i32>(x_12089[x_5465]) * 16i) + 15i);
  let x_12638 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_12643 : i32 = (x_12222 / 4i);
  let x_12645 : i32 = x_12638.x;
  let x_12654 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_12643 % x_12645), (x_12643 / x_12645)), 0i);
  let x_3776 : i32 = bitcast<i32>(x_12654[(x_12222 % 4i)]);
  if (((x_3776 & 32i) != 0i)) {
    let x_12672 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_12679 : i32 = x_12672.x;
    let x_12688 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_12679), (x_5452 / x_12679)), 0i);
    let x_12788 : i32 = ((bitcast<i32>(x_12688[x_5465]) * 16i) + 10i);
    let x_13102 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_13107 : i32 = (x_12788 / 4i);
    let x_13109 : i32 = x_13102.x;
    let x_13118 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_13107 % x_13109), (x_13107 / x_13109)), 0i);
    let x_3787 : vec2<f32> = unpack2x16float(x_13118[(x_12788 % 4i)]);
    let x_3803 : vec3<f32> = (vec3<f32>(x_3702[0u].z, x_3702[1u].z, x_3702[2u].z) * mix(x_3787.x, x_3787.y, (0.5f - x_3769.x)));
    var x_23762_1 : mat3x4<f32> = x_23732;
    x_23762_1[0u].z = x_3803.x;
    let x_23762 : mat3x4<f32> = x_23762_1;
    var x_23765_1 : mat3x4<f32> = x_23762;
    x_23765_1[1u].z = x_3803.y;
    let x_23765 : mat3x4<f32> = x_23765_1;
    x_23768 = x_23765;
    x_23768[2u].z = x_3803.z;
    x_23387 = x_23768;
  } else {
    x_23387 = x_23732;
  }
  if (x_3569) {
    x_3821 = (x_3776 | 4096i);
    x_23381 = x_3821;
  } else {
    x_23381 = x_3776;
  }
  if (((x_23381 & 4i) != 0i)) {
    let x_13271 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_13278 : i32 = x_13271.x;
    let x_13287 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_13278), (x_5452 / x_13278)), 0i);
    let x_13410 : i32 = ((bitcast<i32>(x_13287[x_5465]) * 16i) + 13i);
    let x_13782 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_13787 : i32 = (x_13410 / 4i);
    let x_13789 : i32 = x_13782.x;
    let x_13798 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_13787 % x_13789), (x_13787 / x_13789)), 0i);
    let x_13870 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_13877 : i32 = x_13870.x;
    let x_13886 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_13877), (x_5452 / x_13877)), 0i);
    let x_14009 : i32 = ((bitcast<i32>(x_13886[x_5465]) * 16i) + 13i);
    let x_14381 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_14386 : i32 = (x_14009 / 4i);
    let x_14388 : i32 = x_14381.x;
    let x_14397 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_14386 % x_14388), (x_14386 / x_14388)), 0i);
    let x_3842 : u32 = (x_13798[(x_13410 % 4i)] + (x_14397[(x_14009 % 4i)] << 10u));
    let x_3846 : u32 = (x_3842 ^ (x_3842 >> 6u));
    let x_3850 : u32 = (x_3846 + (x_3846 << 3u));
    let x_3854 : u32 = (x_3850 ^ (x_3850 >> 11u));
    let x_3864 : f32 = select(1.10000002384185791016f, 1.0f, ((bitcast<f32>((((x_3854 + (x_3854 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) > 0.89999997615814208984f));
    let x_3869 : bool = ((x_3776 & 1i) != 0i);
    x_3871 = select(vec3<f32>(x_3864, x_3864, 1.0f), vec3<f32>(1.04999995231628417969f, 1.04999995231628417969f, 1.04999995231628417969f), vec3<bool>(x_3869, x_3869, x_3869));
    x_23911 = x_3871;
  } else {
    x_23911 = vec3<f32>(1.0f, 1.0f, 1.0f);
  }
  let x_3905 : mat3x4<f32> = (mat4x4<f32>(vec4<f32>(x_23911.x, 0.0f, 0.0f, 0.0f), vec4<f32>(0.0f, x_23911.y, 0.0f, 0.0f), vec4<f32>(0.0f, 0.0f, x_23911.z, 0.0f), x_880) * x_23387);
  let x_3907 : f32 = x_3769.x;
  let x_3908 : f32 = x_3769.y;
  let x_3912 : vec3<f32> = (vec4<f32>(x_3907, x_3908, x_3769.z, 1.0f) * x_3905);
  let x_3916 : vec4<f32> = vec4<f32>(x_3912.x, x_3912.y, x_3912.z, 1.0f);
  let x_3918 : vec3<f32> = vec3<f32>(x_3916.x, x_3916.y, x_3916.z);
  let x_3920 : vec3<f32> = (x_3918 * 0.40000000596046447754f);
  let x_3923 : vec3<i32> = vec3<i32>(floor(x_3920));
  let x_3925 : vec3<f32> = fract(x_3920);
  let x_3927 : vec3<u32> = bitcast<vec3<u32>>(x_3923);
  let x_3929 : u32 = x_3927.z;
  let x_3933 : u32 = (x_3929 + (x_3929 << 10u));
  let x_3937 : u32 = (x_3933 ^ (x_3933 >> 6u));
  let x_3941 : u32 = (x_3937 + (x_3937 << 3u));
  let x_3945 : u32 = (x_3941 ^ (x_3941 >> 11u));
  let x_3955 : u32 = ((((x_3927.y * 1664525u) + (x_3945 + (x_3945 << 15u))) + 1013904223u) * 1664525u);
  let x_3959 : u32 = (x_3955 ^ (x_3955 >> 11u));
  let x_3964 : u32 = (x_3959 ^ ((x_3959 << 7u) & 2636928640u));
  let x_3969 : u32 = (x_3964 ^ ((x_3964 << 15u) & 4022730752u));
  let x_3979 : u32 = ((((x_3927.x * 1664525u) + (x_3969 ^ (x_3969 >> 18u))) + 1013904223u) * 1664525u);
  let x_3983 : u32 = (x_3979 ^ (x_3979 >> 11u));
  let x_3988 : u32 = (x_3983 ^ ((x_3983 << 7u) & 2636928640u));
  let x_3993 : u32 = (x_3988 ^ ((x_3988 << 15u) & 4022730752u));
  let x_3997 : u32 = (x_3993 ^ (x_3993 >> 18u));
  x_23389 = x_3997;
  x_23388 = 0u;
  loop {
    if ((x_23388 >= 2u)) {
      break;
    }
    let x_4009 : u32 = (x_23389 + (x_23389 << 10u));
    let x_4013 : u32 = (x_4009 ^ (x_4009 >> 6u));
    let x_4017 : u32 = (x_4013 + (x_4013 << 3u));
    let x_4021 : u32 = (x_4017 ^ (x_4017 >> 11u));
    x_3302[x_23388] = (bitcast<f32>(((x_23389 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23389 = (x_4021 + (x_4021 << 15u));
      x_23388 = (x_23388 + 1u);
    }
  }
  let x_4041 : vec3<u32> = bitcast<vec3<u32>>((x_3923 + vec3<i32>(1i, 0i, 0i)));
  let x_4043 : u32 = x_4041.z;
  let x_4047 : u32 = (x_4043 + (x_4043 << 10u));
  let x_4051 : u32 = (x_4047 ^ (x_4047 >> 6u));
  let x_4055 : u32 = (x_4051 + (x_4051 << 3u));
  let x_4059 : u32 = (x_4055 ^ (x_4055 >> 11u));
  let x_4069 : u32 = ((((x_4041.y * 1664525u) + (x_4059 + (x_4059 << 15u))) + 1013904223u) * 1664525u);
  let x_4073 : u32 = (x_4069 ^ (x_4069 >> 11u));
  let x_4078 : u32 = (x_4073 ^ ((x_4073 << 7u) & 2636928640u));
  let x_4083 : u32 = (x_4078 ^ ((x_4078 << 15u) & 4022730752u));
  let x_4093 : u32 = ((((x_4041.x * 1664525u) + (x_4083 ^ (x_4083 >> 18u))) + 1013904223u) * 1664525u);
  let x_4097 : u32 = (x_4093 ^ (x_4093 >> 11u));
  let x_4102 : u32 = (x_4097 ^ ((x_4097 << 7u) & 2636928640u));
  let x_4107 : u32 = (x_4102 ^ ((x_4102 << 15u) & 4022730752u));
  let x_4111 : u32 = (x_4107 ^ (x_4107 >> 18u));
  x_23392 = x_4111;
  x_23391 = 0u;
  loop {
    if ((x_23391 >= 2u)) {
      break;
    }
    let x_4123 : u32 = (x_23392 + (x_23392 << 10u));
    let x_4127 : u32 = (x_4123 ^ (x_4123 >> 6u));
    let x_4131 : u32 = (x_4127 + (x_4127 << 3u));
    let x_4135 : u32 = (x_4131 ^ (x_4131 >> 11u));
    x_3326[x_23391] = (bitcast<f32>(((x_23392 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23392 = (x_4135 + (x_4135 << 15u));
      x_23391 = (x_23391 + 1u);
    }
  }
  let x_4155 : vec3<u32> = bitcast<vec3<u32>>((x_3923 + vec3<i32>(0i, 1i, 0i)));
  let x_4157 : u32 = x_4155.z;
  let x_4161 : u32 = (x_4157 + (x_4157 << 10u));
  let x_4165 : u32 = (x_4161 ^ (x_4161 >> 6u));
  let x_4169 : u32 = (x_4165 + (x_4165 << 3u));
  let x_4173 : u32 = (x_4169 ^ (x_4169 >> 11u));
  let x_4183 : u32 = ((((x_4155.y * 1664525u) + (x_4173 + (x_4173 << 15u))) + 1013904223u) * 1664525u);
  let x_4187 : u32 = (x_4183 ^ (x_4183 >> 11u));
  let x_4192 : u32 = (x_4187 ^ ((x_4187 << 7u) & 2636928640u));
  let x_4197 : u32 = (x_4192 ^ ((x_4192 << 15u) & 4022730752u));
  let x_4207 : u32 = ((((x_4155.x * 1664525u) + (x_4197 ^ (x_4197 >> 18u))) + 1013904223u) * 1664525u);
  let x_4211 : u32 = (x_4207 ^ (x_4207 >> 11u));
  let x_4216 : u32 = (x_4211 ^ ((x_4211 << 7u) & 2636928640u));
  let x_4221 : u32 = (x_4216 ^ ((x_4216 << 15u) & 4022730752u));
  let x_4225 : u32 = (x_4221 ^ (x_4221 >> 18u));
  x_23395 = x_4225;
  x_23394 = 0u;
  loop {
    if ((x_23394 >= 2u)) {
      break;
    }
    let x_4237 : u32 = (x_23395 + (x_23395 << 10u));
    let x_4241 : u32 = (x_4237 ^ (x_4237 >> 6u));
    let x_4245 : u32 = (x_4241 + (x_4241 << 3u));
    let x_4249 : u32 = (x_4245 ^ (x_4245 >> 11u));
    x_3350[x_23394] = (bitcast<f32>(((x_23395 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23395 = (x_4249 + (x_4249 << 15u));
      x_23394 = (x_23394 + 1u);
    }
  }
  let x_4269 : vec3<u32> = bitcast<vec3<u32>>((x_3923 + vec3<i32>(1i, 1i, 0i)));
  let x_4271 : u32 = x_4269.z;
  let x_4275 : u32 = (x_4271 + (x_4271 << 10u));
  let x_4279 : u32 = (x_4275 ^ (x_4275 >> 6u));
  let x_4283 : u32 = (x_4279 + (x_4279 << 3u));
  let x_4287 : u32 = (x_4283 ^ (x_4283 >> 11u));
  let x_4297 : u32 = ((((x_4269.y * 1664525u) + (x_4287 + (x_4287 << 15u))) + 1013904223u) * 1664525u);
  let x_4301 : u32 = (x_4297 ^ (x_4297 >> 11u));
  let x_4306 : u32 = (x_4301 ^ ((x_4301 << 7u) & 2636928640u));
  let x_4311 : u32 = (x_4306 ^ ((x_4306 << 15u) & 4022730752u));
  let x_4321 : u32 = ((((x_4269.x * 1664525u) + (x_4311 ^ (x_4311 >> 18u))) + 1013904223u) * 1664525u);
  let x_4325 : u32 = (x_4321 ^ (x_4321 >> 11u));
  let x_4330 : u32 = (x_4325 ^ ((x_4325 << 7u) & 2636928640u));
  let x_4335 : u32 = (x_4330 ^ ((x_4330 << 15u) & 4022730752u));
  let x_4339 : u32 = (x_4335 ^ (x_4335 >> 18u));
  x_23398 = x_4339;
  x_23397 = 0u;
  loop {
    if ((x_23397 >= 2u)) {
      break;
    }
    let x_4351 : u32 = (x_23398 + (x_23398 << 10u));
    let x_4355 : u32 = (x_4351 ^ (x_4351 >> 6u));
    let x_4359 : u32 = (x_4355 + (x_4355 << 3u));
    let x_4363 : u32 = (x_4359 ^ (x_4359 >> 11u));
    x_3374[x_23397] = (bitcast<f32>(((x_23398 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23398 = (x_4363 + (x_4363 << 15u));
      x_23397 = (x_23397 + 1u);
    }
  }
  let x_4383 : vec3<u32> = bitcast<vec3<u32>>((x_3923 + vec3<i32>(0i, 0i, 1i)));
  let x_4385 : u32 = x_4383.z;
  let x_4389 : u32 = (x_4385 + (x_4385 << 10u));
  let x_4393 : u32 = (x_4389 ^ (x_4389 >> 6u));
  let x_4397 : u32 = (x_4393 + (x_4393 << 3u));
  let x_4401 : u32 = (x_4397 ^ (x_4397 >> 11u));
  let x_4411 : u32 = ((((x_4383.y * 1664525u) + (x_4401 + (x_4401 << 15u))) + 1013904223u) * 1664525u);
  let x_4415 : u32 = (x_4411 ^ (x_4411 >> 11u));
  let x_4420 : u32 = (x_4415 ^ ((x_4415 << 7u) & 2636928640u));
  let x_4425 : u32 = (x_4420 ^ ((x_4420 << 15u) & 4022730752u));
  let x_4435 : u32 = ((((x_4383.x * 1664525u) + (x_4425 ^ (x_4425 >> 18u))) + 1013904223u) * 1664525u);
  let x_4439 : u32 = (x_4435 ^ (x_4435 >> 11u));
  let x_4444 : u32 = (x_4439 ^ ((x_4439 << 7u) & 2636928640u));
  let x_4449 : u32 = (x_4444 ^ ((x_4444 << 15u) & 4022730752u));
  let x_4453 : u32 = (x_4449 ^ (x_4449 >> 18u));
  x_23401 = x_4453;
  x_23400 = 0u;
  loop {
    if ((x_23400 >= 2u)) {
      break;
    }
    let x_4465 : u32 = (x_23401 + (x_23401 << 10u));
    let x_4469 : u32 = (x_4465 ^ (x_4465 >> 6u));
    let x_4473 : u32 = (x_4469 + (x_4469 << 3u));
    let x_4477 : u32 = (x_4473 ^ (x_4473 >> 11u));
    x_3398[x_23400] = (bitcast<f32>(((x_23401 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23401 = (x_4477 + (x_4477 << 15u));
      x_23400 = (x_23400 + 1u);
    }
  }
  let x_4497 : vec3<u32> = bitcast<vec3<u32>>((x_3923 + vec3<i32>(1i, 0i, 1i)));
  let x_4499 : u32 = x_4497.z;
  let x_4503 : u32 = (x_4499 + (x_4499 << 10u));
  let x_4507 : u32 = (x_4503 ^ (x_4503 >> 6u));
  let x_4511 : u32 = (x_4507 + (x_4507 << 3u));
  let x_4515 : u32 = (x_4511 ^ (x_4511 >> 11u));
  let x_4525 : u32 = ((((x_4497.y * 1664525u) + (x_4515 + (x_4515 << 15u))) + 1013904223u) * 1664525u);
  let x_4529 : u32 = (x_4525 ^ (x_4525 >> 11u));
  let x_4534 : u32 = (x_4529 ^ ((x_4529 << 7u) & 2636928640u));
  let x_4539 : u32 = (x_4534 ^ ((x_4534 << 15u) & 4022730752u));
  let x_4549 : u32 = ((((x_4497.x * 1664525u) + (x_4539 ^ (x_4539 >> 18u))) + 1013904223u) * 1664525u);
  let x_4553 : u32 = (x_4549 ^ (x_4549 >> 11u));
  let x_4558 : u32 = (x_4553 ^ ((x_4553 << 7u) & 2636928640u));
  let x_4563 : u32 = (x_4558 ^ ((x_4558 << 15u) & 4022730752u));
  let x_4567 : u32 = (x_4563 ^ (x_4563 >> 18u));
  x_23404 = x_4567;
  x_23403 = 0u;
  loop {
    if ((x_23403 >= 2u)) {
      break;
    }
    let x_4579 : u32 = (x_23404 + (x_23404 << 10u));
    let x_4583 : u32 = (x_4579 ^ (x_4579 >> 6u));
    let x_4587 : u32 = (x_4583 + (x_4583 << 3u));
    let x_4591 : u32 = (x_4587 ^ (x_4587 >> 11u));
    x_3422[x_23403] = (bitcast<f32>(((x_23404 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23404 = (x_4591 + (x_4591 << 15u));
      x_23403 = (x_23403 + 1u);
    }
  }
  let x_4611 : vec3<u32> = bitcast<vec3<u32>>((x_3923 + vec3<i32>(0i, 1i, 1i)));
  let x_4613 : u32 = x_4611.z;
  let x_4617 : u32 = (x_4613 + (x_4613 << 10u));
  let x_4621 : u32 = (x_4617 ^ (x_4617 >> 6u));
  let x_4625 : u32 = (x_4621 + (x_4621 << 3u));
  let x_4629 : u32 = (x_4625 ^ (x_4625 >> 11u));
  let x_4639 : u32 = ((((x_4611.y * 1664525u) + (x_4629 + (x_4629 << 15u))) + 1013904223u) * 1664525u);
  let x_4643 : u32 = (x_4639 ^ (x_4639 >> 11u));
  let x_4648 : u32 = (x_4643 ^ ((x_4643 << 7u) & 2636928640u));
  let x_4653 : u32 = (x_4648 ^ ((x_4648 << 15u) & 4022730752u));
  let x_4663 : u32 = ((((x_4611.x * 1664525u) + (x_4653 ^ (x_4653 >> 18u))) + 1013904223u) * 1664525u);
  let x_4667 : u32 = (x_4663 ^ (x_4663 >> 11u));
  let x_4672 : u32 = (x_4667 ^ ((x_4667 << 7u) & 2636928640u));
  let x_4677 : u32 = (x_4672 ^ ((x_4672 << 15u) & 4022730752u));
  let x_4681 : u32 = (x_4677 ^ (x_4677 >> 18u));
  x_23407 = x_4681;
  x_23406 = 0u;
  loop {
    if ((x_23406 >= 2u)) {
      break;
    }
    let x_4693 : u32 = (x_23407 + (x_23407 << 10u));
    let x_4697 : u32 = (x_4693 ^ (x_4693 >> 6u));
    let x_4701 : u32 = (x_4697 + (x_4697 << 3u));
    let x_4705 : u32 = (x_4701 ^ (x_4701 >> 11u));
    x_3446[x_23406] = (bitcast<f32>(((x_23407 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23407 = (x_4705 + (x_4705 << 15u));
      x_23406 = (x_23406 + 1u);
    }
  }
  let x_4725 : vec3<u32> = bitcast<vec3<u32>>((x_3923 + vec3<i32>(1i, 1i, 1i)));
  let x_4727 : u32 = x_4725.z;
  let x_4731 : u32 = (x_4727 + (x_4727 << 10u));
  let x_4735 : u32 = (x_4731 ^ (x_4731 >> 6u));
  let x_4739 : u32 = (x_4735 + (x_4735 << 3u));
  let x_4743 : u32 = (x_4739 ^ (x_4739 >> 11u));
  let x_4753 : u32 = ((((x_4725.y * 1664525u) + (x_4743 + (x_4743 << 15u))) + 1013904223u) * 1664525u);
  let x_4757 : u32 = (x_4753 ^ (x_4753 >> 11u));
  let x_4762 : u32 = (x_4757 ^ ((x_4757 << 7u) & 2636928640u));
  let x_4767 : u32 = (x_4762 ^ ((x_4762 << 15u) & 4022730752u));
  let x_4777 : u32 = ((((x_4725.x * 1664525u) + (x_4767 ^ (x_4767 >> 18u))) + 1013904223u) * 1664525u);
  let x_4781 : u32 = (x_4777 ^ (x_4777 >> 11u));
  let x_4786 : u32 = (x_4781 ^ ((x_4781 << 7u) & 2636928640u));
  let x_4791 : u32 = (x_4786 ^ ((x_4786 << 15u) & 4022730752u));
  let x_4795 : u32 = (x_4791 ^ (x_4791 >> 18u));
  x_23410 = x_4795;
  x_23409 = 0u;
  loop {
    if ((x_23409 >= 2u)) {
      break;
    }
    let x_4807 : u32 = (x_23410 + (x_23410 << 10u));
    let x_4811 : u32 = (x_4807 ^ (x_4807 >> 6u));
    let x_4815 : u32 = (x_4811 + (x_4811 << 3u));
    let x_4819 : u32 = (x_4815 ^ (x_4815 >> 11u));
    x_3470[x_23409] = (bitcast<f32>(((x_23410 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23410 = (x_4819 + (x_4819 << 15u));
      x_23409 = (x_23409 + 1u);
    }
  }
  let x_4843 : vec3<f32> = ((x_3925 * x_3925) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_3925)));
  let x_4845 : f32 = x_4843.x;
  let x_4847 : f32 = (1.0f - x_4845);
  let x_4849 : f32 = x_4843.y;
  let x_4851 : f32 = (1.0f - x_4849);
  let x_4853 : f32 = x_4843.z;
  let x_4855 : f32 = (1.0f - x_4853);
  let x_4856 : vec2<f32> = x_3302;
  let x_4863 : vec2<f32> = x_3326;
  let x_4871 : vec2<f32> = x_3350;
  let x_4879 : vec2<f32> = x_3374;
  let x_4887 : vec2<f32> = x_3398;
  let x_4895 : vec2<f32> = x_3422;
  let x_4903 : vec2<f32> = x_3446;
  let x_4911 : vec2<f32> = x_3470;
  let x_4921 : vec2<f32> = clamp(((((((((((((x_4856 * x_4847) * x_4851) * x_4855) + (((x_4863 * x_4845) * x_4851) * x_4855)) + (((x_4871 * x_4847) * x_4849) * x_4855)) + (((x_4879 * x_4845) * x_4849) * x_4855)) + (((x_4887 * x_4847) * x_4851) * x_4853)) + (((x_4895 * x_4845) * x_4851) * x_4853)) + (((x_4903 * x_4847) * x_4849) * x_4853)) + (((x_4911 * x_4845) * x_4849) * x_4853)) - x_2358) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_2358);
  let x_4929 : vec3<f32> = (x_3918 + (vec3<f32>(x_4921.x, 0.0f, x_4921.y) * 0.05999999865889549255f));
  var x_23811_1 : vec4<f32> = x_3916;
  x_23811_1.x = x_4929.x;
  let x_23811 : vec4<f32> = x_23811_1;
  var x_23814_1 : vec4<f32> = x_23811;
  x_23814_1.z = x_4929.z;
  let x_23814 : vec4<f32> = x_23814_1;
  let x_4938 : vec3<f32> = (x_880 * x_3905);
  let x_4941 : f32 = (x_3907 - -0.5f);
  let x_4960 : f32 = (x_4929.y + mix(mix(x_3578.x, x_3578.y, x_4941), mix(x_3585.x, x_3585.y, x_4941), (x_3908 - -0.5f)));
  var x_23823_1 : vec4<f32> = x_23814;
  x_23823_1.y = x_4960;
  let x_23823 : vec4<f32> = x_23823_1;
  let x_14469 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_14476 : i32 = x_14469.x;
  let x_14485 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_14476), (x_5452 / x_14476)), 0i);
  let x_14594 : i32 = ((bitcast<i32>(x_14485[x_5465]) * 16i) + 11i);
  let x_14926 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_14931 : i32 = (x_14594 / 4i);
  let x_14933 : i32 = x_14926.x;
  let x_14942 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_14931 % x_14933), (x_14931 / x_14933)), 0i);
  let x_4969 : vec2<f32> = unpack2x16float(x_14942[(x_14594 % 4i)]);
  let x_4971 : vec4<f32> = x_3905[0u];
  let x_4974 : vec4<f32> = x_3905[1u];
  let x_4977 : vec4<f32> = x_3905[2u];
  let x_4991 : mat3x3<f32> = mat3x3<f32>(vec3<f32>(x_4971.x, x_4971.y, x_4971.z), vec3<f32>(x_4974.x, x_4974.y, x_4974.z), vec3<f32>(x_4977.x, x_4977.y, x_4977.z));
  let x_4993 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_4991);
  let x_4995 : vec3<f32> = (x_2451 * x_4991);
  let x_4997 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_4991);
  let x_5000 : vec3<f32> = cross(x_4993, x_4995);
  let x_5004 : f32 = (1.0f / dot(x_4997, x_5000));
  let x_5005 : vec3<f32> = vec3<f32>(x_5004, x_5004, x_5004);
  let x_5032 : mat3x3<f32> = transpose(mat3x3<f32>((cross(x_4995, x_4997) * x_5005), (cross(x_4997, x_4993) * x_5005), (x_5000 * x_5005)));
  let x_15068 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_15075 : i32 = x_15068.x;
  let x_15084 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_15075), (x_5452 / x_15075)), 0i);
  let x_15200 : i32 = ((bitcast<i32>(x_15084[x_5465]) * 16i) + 12i);
  let x_15552 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_15557 : i32 = (x_15200 / 4i);
  let x_15559 : i32 = x_15552.x;
  let x_15568 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_15557 % x_15559), (x_15557 / x_15559)), 0i);
  let x_5050 : vec2<f32> = vec2<f32>(mix(x_4969.y, unpack2x16float(x_15568[(x_15200 % 4i)]).x, x_4941), select(x_4960, 0.0f, ((x_3776 & 1024i) != 0i)));
  let x_15667 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_15674 : i32 = x_15667.x;
  let x_15683 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_15674), (x_5452 / x_15674)), 0i);
  let x_15806 : i32 = ((bitcast<i32>(x_15683[x_5465]) * 16i) + 13i);
  let x_16178 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_16183 : i32 = (x_15806 / 4i);
  let x_16185 : i32 = x_16178.x;
  let x_16194 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_16183 % x_16185), (x_16183 / x_16185)), 0i);
  let x_5057 : u32 = (x_16194[(x_15806 % 4i)] & 65535u);
  let x_16266 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_16273 : i32 = x_16266.x;
  let x_16282 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_16273), (x_5452 / x_16273)), 0i);
  let x_16405 : i32 = ((bitcast<i32>(x_16282[x_5465]) * 16i) + 13i);
  let x_16777 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_16782 : i32 = (x_16405 / 4i);
  let x_16784 : i32 = x_16777.x;
  let x_16793 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_16782 % x_16784), (x_16782 / x_16784)), 0i);
  if ((x_16793[(x_16405 % 4i)] < 10u)) {
    x_5067 = (x_23381 | 512i);
    x_23513 = x_5067;
  } else {
    x_23513 = x_23381;
  }
  let x_5092 : mat3x3<f32> = mat3x3<f32>(vec3<f32>(x_3609, 0.0f, -(x_3613)), x_2451, vec3<f32>(x_3613, 0.0f, x_3609));
  let x_5095 : vec3<f32> = (x_5092 * x_3769);
  let x_5098 : vec3<f32> = (x_3735 - x_4938);
  let x_5103 : vec3<f32> = (x_5092 * (x_5032 * x_5098));
  let x_5106 : mat3x3<f32> = (x_5092 * x_5032);
  let x_16865 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_16872 : i32 = x_16865.x;
  let x_16881 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_16872), (x_5452 / x_16872)), 0i);
  let x_16981 : i32 = ((bitcast<i32>(x_16881[x_5465]) * 16i) + 10i);
  let x_17295 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_17300 : i32 = (x_16981 / 4i);
  let x_17302 : i32 = x_17295.x;
  let x_17311 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_17300 % x_17302), (x_17300 / x_17302)), 0i);
  let x_5113 : vec2<f32> = unpack2x16float(x_17311[(x_16981 % 4i)]);
  if ((x_4941 < 0.5f)) {
    x_5123 = mix(x_5113.x, x_5113.y, (x_4941 * 2.0f));
    x_23617 = x_5123;
  } else {
    x_5132 = mix(x_5113.y, x_4969.x, ((x_4941 * 2.0f) - 1.0f));
    x_23617 = x_5132;
  }
  var x_5163 : bool;
  var x_23534 : bool;
  var x_5169 : i32;
  var x_5195 : i32;
  var x_5220 : i32;
  let x_17464 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_17471 : i32 = x_17464.x;
  let x_17480 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_17471), (x_5452 / x_17471)), 0i);
  let x_17608 : i32 = ((bitcast<i32>(x_17480[x_5465]) * 16i) + 14i);
  let x_18002 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_18007 : i32 = (x_17608 / 4i);
  let x_18009 : i32 = x_18002.x;
  let x_18018 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_18007 % x_18009), (x_18007 / x_18009)), 0i);
  let x_5141 : bool = ((x_18018[(x_17608 % 4i)] & 2147483648u) != 0u);
  if (x_5141) {
    let x_18063 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_18070 : i32 = x_18063.x;
    let x_18079 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_18070), (x_5452 / x_18070)), 0i);
    let x_18207 : i32 = ((bitcast<i32>(x_18079[x_5465]) * 16i) + 14i);
    let x_18601 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_18606 : i32 = (x_18207 / 4i);
    let x_18608 : i32 = x_18601.x;
    let x_18617 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_18606 % x_18608), (x_18606 / x_18608)), 0i);
    if (((x_18617[(x_18207 % 4i)] & 1073741824u) != 0u)) {
      let x_18662 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
      let x_18669 : i32 = x_18662.x;
      let x_18678 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_18669), (x_5452 / x_18669)), 0i);
      let x_18806 : i32 = ((bitcast<i32>(x_18678[x_5465]) * 16i) + 14i);
      let x_19200 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_19205 : i32 = (x_18806 / 4i);
      let x_19207 : i32 = x_19200.x;
      let x_19216 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_19205 % x_19207), (x_19205 / x_19207)), 0i);
      x_5163 = (((x_19216[(x_18806 % 4i)] >> 4u) & 65535u) == x_3208);
      x_23534 = x_5163;
    } else {
      x_23534 = false;
    }
    if (x_23534) {
      x_5169 = (x_23513 | 2048i);
      x_23538 = x_5169;
    } else {
      x_23538 = x_23513;
    }
    let x_19261 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_19268 : i32 = x_19261.x;
    let x_19277 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_19268), (x_5452 / x_19268)), 0i);
    let x_19405 : i32 = ((bitcast<i32>(x_19277[x_5465]) * 16i) + 14i);
    let x_19799 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_19804 : i32 = (x_19405 / 4i);
    let x_19806 : i32 = x_19799.x;
    let x_19815 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_19804 % x_19806), (x_19804 / x_19806)), 0i);
    x_5180 = bitcast<i32>((x_19815[(x_19405 % 4i)] & 15u));
    x_23625 = x_5180;
    x_23566 = x_23538;
  } else {
    var x_21111 : u32;
    var x_21744 : u32;
    var x_23514 : u32;
    if (((x_23513 & 8192i) != 0i)) {
      let x_19860 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
      let x_19867 : i32 = x_19860.x;
      let x_19876 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_19867), (x_5452 / x_19867)), 0i);
      let x_20004 : i32 = ((bitcast<i32>(x_19876[x_5465]) * 16i) + 14i);
      let x_20398 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_20403 : i32 = (x_20004 / 4i);
      let x_20405 : i32 = x_20398.x;
      let x_20414 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_20403 % x_20405), (x_20403 / x_20405)), 0i);
      let x_5193 : i32 = bitcast<i32>(x_20414[(x_20004 % 4i)]);
      let x_20459 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
      let x_20464 : i32 = (x_5193 / 4i);
      let x_20466 : i32 = x_20459.x;
      let x_20475 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_20464 % x_20466), (x_20464 / x_20466)), 0i);
      x_5195 = bitcast<i32>(x_20475[(x_5193 % 4i)]);
      x_23515 = x_5195;
    } else {
      if (((x_23513 & 2i) != 0i)) {
        let x_20493 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
        let x_20500 : i32 = x_20493.x;
        let x_20509 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_20500), (x_5452 / x_20500)), 0i);
        let x_20637 : i32 = ((bitcast<i32>(x_20509[x_5465]) * 16i) + 14i);
        let x_21031 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_21036 : i32 = (x_20637 / 4i);
        let x_21038 : i32 = x_21031.x;
        let x_21047 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_21036 % x_21038), (x_21036 / x_21038)), 0i);
        let x_5207 : i32 = bitcast<i32>(x_21047[(x_20637 % 4i)]);
        let x_21092 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
        let x_21097 : i32 = (x_5207 / 4i);
        let x_21099 : i32 = x_21092.x;
        let x_21108 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_21097 % x_21099), (x_21097 / x_21099)), 0i);
        x_21111 = x_21108[(x_5207 % 4i)];
        x_23514 = x_21111;
      } else {
        let x_21126 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
        let x_21133 : i32 = x_21126.x;
        let x_21142 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_21133), (x_5452 / x_21133)), 0i);
        let x_21270 : i32 = ((bitcast<i32>(x_21142[x_5465]) * 16i) + 14i);
        let x_21664 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_21669 : i32 = (x_21270 / 4i);
        let x_21671 : i32 = x_21664.x;
        let x_21680 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_21669 % x_21671), (x_21669 / x_21671)), 0i);
        let x_5216 : i32 = bitcast<i32>(x_21680[(x_21270 % 4i)]);
        let x_21725 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
        let x_21730 : i32 = (x_5216 / 4i);
        let x_21732 : i32 = x_21725.x;
        let x_21741 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_21730 % x_21732), (x_21730 / x_21732)), 0i);
        x_21744 = x_21741[(x_5216 % 4i)];
        x_23514 = x_21744;
      }
      x_5220 = bitcast<i32>(x_23514);
      x_23515 = x_5220;
    }
    x_23625 = x_23515;
    x_23566 = x_23513;
  }
  if (x_5141) {
    let x_21759 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_21766 : i32 = x_21759.x;
    let x_21775 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_21766), (x_5452 / x_21766)), 0i);
    let x_21903 : i32 = ((bitcast<i32>(x_21775[x_5465]) * 16i) + 14i);
    let x_22297 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_22302 : i32 = (x_21903 / 4i);
    let x_22304 : i32 = x_22297.x;
    let x_22313 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_22302 % x_22304), (x_22302 / x_22304)), 0i);
    x_22316 = x_22313[(x_21903 % 4i)];
    x_23547 = x_22316;
  } else {
    let x_22358 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_22365 : i32 = x_22358.x;
    let x_22374 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_22365), (x_5452 / x_22365)), 0i);
    let x_22502 : i32 = ((bitcast<i32>(x_22374[x_5465]) * 16i) + 14i);
    let x_22896 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_22901 : i32 = (x_22502 / 4i);
    let x_22903 : i32 = x_22896.x;
    let x_22912 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_22901 % x_22903), (x_22901 / x_22903)), 0i);
    let x_5240 : i32 = bitcast<i32>(x_22912[(x_22502 % 4i)]);
    let x_22957 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_10_0, 0i));
    let x_22962 : i32 = (x_5240 / 4i);
    let x_22964 : i32 = x_22957.x;
    let x_22973 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_10_0, vec2<i32>((x_22962 % x_22964), (x_22962 / x_22964)), 0i);
    x_22976 = x_22973[(x_5240 % 4i)];
    x_23547 = x_22976;
  }
  let x_5244 : u32 = (x_23547 & 65535u);
  let x_5246 : u32 = (x_5244 ^ 7993234u);
  let x_5250 : u32 = (x_5246 + (x_5246 << 10u));
  let x_5254 : u32 = (x_5250 ^ (x_5250 >> 6u));
  let x_5258 : u32 = (x_5254 + (x_5254 << 3u));
  let x_5262 : u32 = (x_5258 ^ (x_5258 >> 11u));
  let x_5264 : u32 = (x_5244 ^ 3450234u);
  let x_5268 : u32 = (x_5264 + (x_5264 << 10u));
  let x_5272 : u32 = (x_5268 ^ (x_5268 >> 6u));
  let x_5276 : u32 = (x_5272 + (x_5272 << 3u));
  let x_5280 : u32 = (x_5276 ^ (x_5276 >> 11u));
  let x_5286 : f32 = (f32(x_5244) * 0.20000000298023223877f);
  let x_5306 : vec2<f32> = ((((x_5050 * 0.10000000149011611938f) * 0.69999998807907104492f) + vec2<f32>(x_5286, x_5286)) + vec2<f32>((bitcast<f32>((((x_5262 + (x_5262 << 15u)) & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_5280 + (x_5280 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
  let x_5308 : u32 = (x_5057 ^ 292478890u);
  let x_5312 : u32 = (x_5308 + (x_5308 << 10u));
  let x_5316 : u32 = (x_5312 ^ (x_5312 >> 6u));
  let x_5320 : u32 = (x_5316 + (x_5316 << 3u));
  let x_5324 : u32 = (x_5320 ^ (x_5320 >> 11u));
  let x_5332 : f32 = (bitcast<f32>((((x_5324 + (x_5324 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
  if ((x_5332 > 0.89999997615814208984f)) {
    x_5337 = (x_5306 * 3.0f);
    x_23567 = x_5337;
  } else {
    let x_5341 : f32 = (0.61000001430511474609f * x_5332);
    x_5343 = (x_5306 + vec2<f32>(x_5341, x_5341));
    x_23567 = x_5343;
  }
  if (((x_23566 & 512i) != 0i)) {
    x_5352 = (x_23567 * 2.20000004768371582031f);
    x_23573 = x_5352;
  } else {
    x_23573 = x_23567;
  }
  let x_5358 : bool = ((x_23513 & 32i) != 0i);
  if (x_5358) {
    x_5362 = (x_5050 * 0.69999998807907104492f);
    x_23620 = x_5362;
  } else {
    x_23620 = x_23573;
  }
  let x_5367 : mat4x4<f32> = x_2921.renderer_MVPMat;
  gl_Position = (x_5367 * x_23823);
  v0 = x_5057;
  v2 = vec3<f32>(x_23823.x, x_23823.y, x_23823.z);
  v3 = x_5095;
  v4 = normalize((x_5095 - x_5103));
  v5 = (length(x_5098) / length(x_5103));
  v7 = select(x_23617, -100.0f, x_5358);
  v8 = -100000.0f;
  v9 = x_23620;
  v10 = x_23625;
  let x_5393 : vec4<f32> = vec4<f32>(x_4938.x, 0.0f, x_4938.z, 1.0f);
  v11 = vec2<f32>(x_5393.x, x_5393.z);
  v12 = x_23566;
  let x_22991 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_22998 : i32 = x_22991.x;
  let x_23007 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5452 % x_22998), (x_5452 / x_22998)), 0i);
  v13 = x_23007[x_5465];
  v14_col0 = vec3<f32>(x_5106[0u].x, x_5106[1u].x, x_5106[2u].x);
  v14_col1 = vec3<f32>(x_5106[0u].y, x_5106[1u].y, x_5106[2u].y);
  v14_col2 = vec3<f32>(x_5106[0u].z, x_5106[1u].z, x_5106[2u].z);
  let x_3032 : f32 = gl_Position.z;
  let x_3034 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_3032 + x_3034));
  return;
}

struct main_out {
  @builtin(position)
  gl_Position : vec4<f32>,
  @location(0) @interpolate(flat)
  v0_1 : u32,
  @location(1)
  v2_1 : vec3<f32>,
  @location(2)
  v3_1 : vec3<f32>,
  @location(3)
  v4_1 : vec3<f32>,
  @location(4)
  v5_1 : f32,
  @location(5)
  v7_1 : f32,
  @location(6) @interpolate(flat)
  v8_1 : f32,
  @location(7)
  v9_1 : vec2<f32>,
  @location(8) @interpolate(flat)
  v10_1 : i32,
  @location(9) @interpolate(flat)
  v11_1 : vec2<f32>,
  @location(10) @interpolate(flat)
  v12_1 : i32,
  @location(11) @interpolate(flat)
  v13_1 : u32,
  @location(12) @interpolate(flat)
  v14_col0_1 : vec3<f32>,
  @location(13) @interpolate(flat)
  v14_col1_1 : vec3<f32>,
  @location(14) @interpolate(flat)
  v14_col2_1 : vec3<f32>,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @builtin(vertex_index) gl_VertexIndex_param : u32) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  gl_VertexIndex = bitcast<i32>(gl_VertexIndex_param);
  main_1();
  return main_out(gl_Position, v0, v2, v3, v4, v5, v7, v8, v9, v10, v11, v12, v13, v14_col0, v14_col1, v14_col2);
}
