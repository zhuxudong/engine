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

@binding(0) @group(2) var<uniform> x_2924 : gs_Auto_0;

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

var<private> resident_cell_id : u32;

var<private> v14_col0 : vec3<f32>;

var<private> v14_col1 : vec3<f32>;

var<private> v14_col2 : vec3<f32>;

var<private> gl_Position : vec4<f32>;

const x_883 = vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f);

const x_2361 = vec2<f32>(0.5f, 0.5f);

const x_2454 = vec3<f32>(0.0f, 1.0f, 0.0f);

fn main_1() {
  var x_3339 : vec2<f32>;
  var x_3363 : vec2<f32>;
  var x_3387 : vec2<f32>;
  var x_3411 : vec2<f32>;
  var x_3435 : vec2<f32>;
  var x_3459 : vec2<f32>;
  var x_3483 : vec2<f32>;
  var x_3507 : vec2<f32>;
  var x_12072 : u32;
  var x_23434 : u32;
  var x_12082 : u32;
  var x_23435 : u32;
  var x_12092 : u32;
  var x_23436 : u32;
  var x_23832 : mat3x4<f32>;
  var x_23451 : mat3x4<f32>;
  var x_3858 : i32;
  var x_23445 : i32;
  var x_3908 : vec3<f32>;
  var x_23977 : vec3<f32>;
  var x_23453 : u32;
  var x_23452 : u32;
  var x_23456 : u32;
  var x_23455 : u32;
  var x_23459 : u32;
  var x_23458 : u32;
  var x_23462 : u32;
  var x_23461 : u32;
  var x_23465 : u32;
  var x_23464 : u32;
  var x_23468 : u32;
  var x_23467 : u32;
  var x_23471 : u32;
  var x_23470 : u32;
  var x_23474 : u32;
  var x_23473 : u32;
  var x_5104 : i32;
  var x_23577 : i32;
  var x_5160 : f32;
  var x_5169 : f32;
  var x_23681 : f32;
  var x_23602 : i32;
  var x_5217 : i32;
  var x_23579 : i32;
  var x_23689 : i32;
  var x_23630 : i32;
  var x_22353 : u32;
  var x_23013 : u32;
  var x_23611 : u32;
  var x_5374 : vec2<f32>;
  var x_5380 : vec2<f32>;
  var x_23631 : vec2<f32>;
  var x_5389 : vec2<f32>;
  var x_23637 : vec2<f32>;
  var x_5399 : vec2<f32>;
  var x_23684 : vec2<f32>;
  let x_3107 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_MaterialData_natural, vec2<i32>(0i, 0i), 0i);
  let x_3121 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_3126 : i32 = x_3121.x;
  let x_3133 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((20i % x_3126), (20i / x_3126)), 0i);
  let x_3145 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((21i % x_3126), (21i / x_3126)), 0i);
  let x_3157 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((22i % x_3126), (22i / x_3126)), 0i);
  let x_3169 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((23i % x_3126), (23i / x_3126)), 0i);
  let x_3231 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_3236 : i32 = x_3231.x;
  let x_3243 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((15i % x_3236), (15i / x_3236)), 0i);
  let x_3245 : u32 = x_3243.y;
  let x_3606 : bool = (x_3107.x != 0u);
  let x_3607 : i32 = gl_InstanceIndex;
  let x_5484 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_5489 : i32 = (x_3607 / 4i);
  let x_5491 : i32 = x_5484.x;
  let x_5500 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_5491), (x_5489 / x_5491)), 0i);
  let x_5502 : i32 = (x_3607 % 4i);
  let x_5585 : i32 = ((bitcast<i32>(x_5500[x_5502]) * 16i) + 8i);
  let x_5861 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_5866 : i32 = (x_5585 / 4i);
  let x_5868 : i32 = x_5861.x;
  let x_5877 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5866 % x_5868), (x_5866 / x_5868)), 0i);
  let x_3615 : vec2<f32> = unpack2x16float(x_5877[(x_5585 % 4i)]);
  let x_6084 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_6091 : i32 = x_6084.x;
  let x_6100 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_6091), (x_5489 / x_6091)), 0i);
  let x_6193 : i32 = ((bitcast<i32>(x_6100[x_5502]) * 16i) + 9i);
  let x_6487 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_6492 : i32 = (x_6193 / 4i);
  let x_6494 : i32 = x_6487.x;
  let x_6503 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_6492 % x_6494), (x_6492 / x_6494)), 0i);
  let x_3622 : vec2<f32> = unpack2x16float(x_6503[(x_6193 % 4i)]);
  let x_6683 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_6690 : i32 = x_6683.x;
  let x_6699 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_6690), (x_5489 / x_6690)), 0i);
  let x_6822 : i32 = ((bitcast<i32>(x_6699[x_5502]) * 16i) + 13i);
  let x_7194 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_7199 : i32 = (x_6822 / 4i);
  let x_7201 : i32 = x_7194.x;
  let x_7210 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_7199 % x_7201), (x_7199 / x_7201)), 0i);
  let x_7213 : u32 = x_7210[(x_6822 % 4i)];
  let x_3636 : i32 = -(bitcast<i32>((x_7213 & 1u)));
  let x_3641 : i32 = (1i - bitcast<i32>((((x_7213 & 3u) >> 1u) << 1u)));
  let x_3646 : f32 = f32((~(x_3636) & x_3641));
  let x_3650 : f32 = f32((x_3636 & x_3641));
  let x_7282 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_7289 : i32 = x_7282.x;
  let x_7298 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_7289), (x_5489 / x_7289)), 0i);
  let x_7331 : i32 = ((bitcast<i32>(x_7298[x_5502]) * 16i) + 1i);
  let x_7469 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_7474 : i32 = (x_7331 / 4i);
  let x_7476 : i32 = x_7469.x;
  let x_7485 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_7474 % x_7476), (x_7474 / x_7476)), 0i);
  let x_3657 : vec2<f32> = unpack2x16float(x_7485[(x_7331 % 4i)]);
  let x_7881 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_7888 : i32 = x_7881.x;
  let x_7897 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_7888), (x_5489 / x_7888)), 0i);
  let x_7920 : i32 = (bitcast<i32>(x_7897[x_5502]) * 16i);
  let x_8041 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_8046 : i32 = (x_7920 / 4i);
  let x_8048 : i32 = x_8041.x;
  let x_8057 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_8046 % x_8048), (x_8046 / x_8048)), 0i);
  let x_3664 : vec2<f32> = unpack2x16float(x_8057[(x_7920 % 4i)]);
  let x_8480 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_8487 : i32 = x_8480.x;
  let x_8496 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_8487), (x_5489 / x_8487)), 0i);
  let x_8536 : i32 = ((bitcast<i32>(x_8496[x_5502]) * 16i) + 2i);
  let x_8694 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_8699 : i32 = (x_8536 / 4i);
  let x_8701 : i32 = x_8694.x;
  let x_8710 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_8699 % x_8701), (x_8699 / x_8701)), 0i);
  let x_3678 : vec2<f32> = unpack2x16float(x_8710[(x_8536 % 4i)]);
  let x_9079 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_9086 : i32 = x_9079.x;
  let x_9095 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_9086), (x_5489 / x_9086)), 0i);
  let x_9142 : i32 = ((bitcast<i32>(x_9095[x_5502]) * 16i) + 3i);
  let x_9320 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_9325 : i32 = (x_9142 / 4i);
  let x_9327 : i32 = x_9320.x;
  let x_9336 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_9325 % x_9327), (x_9325 / x_9327)), 0i);
  let x_3688 : vec2<f32> = unpack2x16float(x_9336[(x_9142 % 4i)]);
  let x_9678 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_9685 : i32 = x_9678.x;
  let x_9694 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_9685), (x_5489 / x_9685)), 0i);
  let x_9748 : i32 = ((bitcast<i32>(x_9694[x_5502]) * 16i) + 4i);
  let x_9946 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_9951 : i32 = (x_9748 / 4i);
  let x_9953 : i32 = x_9946.x;
  let x_9962 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_9951 % x_9953), (x_9951 / x_9953)), 0i);
  let x_10277 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_10284 : i32 = x_10277.x;
  let x_10293 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_10284), (x_5489 / x_10284)), 0i);
  let x_10354 : i32 = ((bitcast<i32>(x_10293[x_5502]) * 16i) + 5i);
  let x_10572 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_10577 : i32 = (x_10354 / 4i);
  let x_10579 : i32 = x_10572.x;
  let x_10588 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_10577 % x_10579), (x_10577 / x_10579)), 0i);
  let x_10876 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_10883 : i32 = x_10876.x;
  let x_10892 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_10883), (x_5489 / x_10883)), 0i);
  let x_10962 : i32 = ((bitcast<i32>(x_10892[x_5502]) * 16i) + 6i);
  let x_11198 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_11203 : i32 = (x_10962 / 4i);
  let x_11205 : i32 = x_11198.x;
  let x_11214 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_11203 % x_11205), (x_11203 / x_11205)), 0i);
  let x_11475 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_11482 : i32 = x_11475.x;
  let x_11491 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_11482), (x_5489 / x_11482)), 0i);
  let x_11568 : i32 = ((bitcast<i32>(x_11491[x_5502]) * 16i) + 7i);
  let x_11824 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_11829 : i32 = (x_11568 / 4i);
  let x_11831 : i32 = x_11824.x;
  let x_11840 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_11829 % x_11831), (x_11829 / x_11831)), 0i);
  let x_3739 : mat3x4<f32> = transpose(mat4x3<f32>(vec3<f32>(x_3664.x, x_3664.y, x_3657.x), vec3<f32>(x_3657.y, x_3678.x, x_3678.y), vec3<f32>(x_3688.x, x_3688.y, unpack2x16float(x_9962[(x_9748 % 4i)]).x), vec3<f32>(bitcast<f32>(x_10588[(x_10354 % 4i)]), bitcast<f32>(x_11214[(x_10962 % 4i)]), bitcast<f32>(x_11840[(x_11568 % 4i)]))));
  var x_23790_1 : mat3x4<f32> = x_3739;
  x_23790_1[0u].w = x_3739[0u].w;
  let x_23790 : mat3x4<f32> = x_23790_1;
  var x_23793_1 : mat3x4<f32> = x_23790;
  x_23793_1[1u].w = x_3739[1u].w;
  let x_23793 : mat3x4<f32> = x_23793_1;
  var x_23796_1 : mat3x4<f32> = x_23793;
  x_23796_1[2u].w = x_3739[2u].w;
  let x_23796 : mat3x4<f32> = x_23796_1;
  let x_3752 : i32 = gl_VertexIndex;
  let x_3754 : u32 = bitcast<u32>(x_3752);
  let x_3757 : u32 = ((x_3754 & 4u) >> 2u);
  let x_3760 : u32 = ((x_3754 & 2u) >> 1u);
  let x_3762 : u32 = (x_3754 & 1u);
  let x_3766 : vec4<f32> = (mat4x4<f32>(vec4<f32>(bitcast<f32>(x_3133.x), bitcast<f32>(x_3145.x), bitcast<f32>(x_3157.x), bitcast<f32>(x_3169.x)), vec4<f32>(bitcast<f32>(x_3133.y), bitcast<f32>(x_3145.y), bitcast<f32>(x_3157.y), bitcast<f32>(x_3169.y)), vec4<f32>(bitcast<f32>(x_3133.z), bitcast<f32>(x_3145.z), bitcast<f32>(x_3157.z), bitcast<f32>(x_3169.z)), vec4<f32>(bitcast<f32>(x_3133.w), bitcast<f32>(x_3145.w), bitcast<f32>(x_3157.w), bitcast<f32>(x_3169.w))) * x_883);
  let x_3770 : f32 = x_3766.w;
  let x_3772 : vec3<f32> = (vec3<f32>(x_3766.x, x_3766.y, x_3766.z) / vec3<f32>(x_3770, x_3770, x_3770));
  let x_3774 : vec3<u32> = (vec3<u32>(1u, 1u, 1u) - vec3<u32>(x_3757, x_3760, x_3762));
  let x_3776 : vec4<f32> = x_23790[0u];
  let x_3779 : vec4<f32> = x_23793[1u];
  let x_3782 : vec4<f32> = x_23796[2u];
  let x_3802 : vec3<bool> = ((mat3x3<f32>(vec3<f32>(x_3776.x, x_3776.y, x_3776.z), vec3<f32>(x_3779.x, x_3779.y, x_3779.z), vec3<f32>(x_3782.x, x_3782.y, x_3782.z)) * (x_3772 - (x_883 * x_23796))) > vec3<f32>(0.0f, 0.0f, 0.0f));
  if (x_3802.x) {
    x_23434 = x_3757;
  } else {
    x_12072 = x_3774.x;
    x_23434 = x_12072;
  }
  if (x_3802.y) {
    x_23435 = x_3760;
  } else {
    x_12082 = x_3774.y;
    x_23435 = x_12082;
  }
  if (x_3802.z) {
    x_23436 = x_3762;
  } else {
    x_12092 = x_3774.z;
    x_23436 = x_12092;
  }
  let x_3806 : vec3<f32> = (vec3<f32>(vec3<u32>(x_23434, x_23435, x_23436)) - vec3<f32>(0.5f, 0.5f, 0.5f));
  let x_12110 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_12117 : i32 = x_12110.x;
  let x_12126 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_12117), (x_5489 / x_12117)), 0i);
  let x_12259 : i32 = ((bitcast<i32>(x_12126[x_5502]) * 16i) + 15i);
  let x_12675 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_12680 : i32 = (x_12259 / 4i);
  let x_12682 : i32 = x_12675.x;
  let x_12691 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_12680 % x_12682), (x_12680 / x_12682)), 0i);
  let x_3813 : i32 = bitcast<i32>(x_12691[(x_12259 % 4i)]);
  if (((x_3813 & 32i) != 0i)) {
    let x_12709 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_12716 : i32 = x_12709.x;
    let x_12725 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_12716), (x_5489 / x_12716)), 0i);
    let x_12825 : i32 = ((bitcast<i32>(x_12725[x_5502]) * 16i) + 10i);
    let x_13139 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_13144 : i32 = (x_12825 / 4i);
    let x_13146 : i32 = x_13139.x;
    let x_13155 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_13144 % x_13146), (x_13144 / x_13146)), 0i);
    let x_3824 : vec2<f32> = unpack2x16float(x_13155[(x_12825 % 4i)]);
    let x_3840 : vec3<f32> = (vec3<f32>(x_3739[0u].z, x_3739[1u].z, x_3739[2u].z) * mix(x_3824.x, x_3824.y, (0.5f - x_3806.x)));
    var x_23826_1 : mat3x4<f32> = x_23796;
    x_23826_1[0u].z = x_3840.x;
    let x_23826 : mat3x4<f32> = x_23826_1;
    var x_23829_1 : mat3x4<f32> = x_23826;
    x_23829_1[1u].z = x_3840.y;
    let x_23829 : mat3x4<f32> = x_23829_1;
    x_23832 = x_23829;
    x_23832[2u].z = x_3840.z;
    x_23451 = x_23832;
  } else {
    x_23451 = x_23796;
  }
  if (x_3606) {
    x_3858 = (x_3813 | 4096i);
    x_23445 = x_3858;
  } else {
    x_23445 = x_3813;
  }
  if (((x_23445 & 4i) != 0i)) {
    let x_13308 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_13315 : i32 = x_13308.x;
    let x_13324 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_13315), (x_5489 / x_13315)), 0i);
    let x_13447 : i32 = ((bitcast<i32>(x_13324[x_5502]) * 16i) + 13i);
    let x_13819 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_13824 : i32 = (x_13447 / 4i);
    let x_13826 : i32 = x_13819.x;
    let x_13835 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_13824 % x_13826), (x_13824 / x_13826)), 0i);
    let x_13907 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_13914 : i32 = x_13907.x;
    let x_13923 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_13914), (x_5489 / x_13914)), 0i);
    let x_14046 : i32 = ((bitcast<i32>(x_13923[x_5502]) * 16i) + 13i);
    let x_14418 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_14423 : i32 = (x_14046 / 4i);
    let x_14425 : i32 = x_14418.x;
    let x_14434 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_14423 % x_14425), (x_14423 / x_14425)), 0i);
    let x_3879 : u32 = (x_13835[(x_13447 % 4i)] + (x_14434[(x_14046 % 4i)] << 10u));
    let x_3883 : u32 = (x_3879 ^ (x_3879 >> 6u));
    let x_3887 : u32 = (x_3883 + (x_3883 << 3u));
    let x_3891 : u32 = (x_3887 ^ (x_3887 >> 11u));
    let x_3901 : f32 = select(1.10000002384185791016f, 1.0f, ((bitcast<f32>((((x_3891 + (x_3891 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) > 0.89999997615814208984f));
    let x_3906 : bool = ((x_3813 & 1i) != 0i);
    x_3908 = select(vec3<f32>(x_3901, x_3901, 1.0f), vec3<f32>(1.04999995231628417969f, 1.04999995231628417969f, 1.04999995231628417969f), vec3<bool>(x_3906, x_3906, x_3906));
    x_23977 = x_3908;
  } else {
    x_23977 = vec3<f32>(1.0f, 1.0f, 1.0f);
  }
  let x_3942 : mat3x4<f32> = (mat4x4<f32>(vec4<f32>(x_23977.x, 0.0f, 0.0f, 0.0f), vec4<f32>(0.0f, x_23977.y, 0.0f, 0.0f), vec4<f32>(0.0f, 0.0f, x_23977.z, 0.0f), x_883) * x_23451);
  let x_3944 : f32 = x_3806.x;
  let x_3945 : f32 = x_3806.y;
  let x_3949 : vec3<f32> = (vec4<f32>(x_3944, x_3945, x_3806.z, 1.0f) * x_3942);
  let x_3953 : vec4<f32> = vec4<f32>(x_3949.x, x_3949.y, x_3949.z, 1.0f);
  let x_3955 : vec3<f32> = vec3<f32>(x_3953.x, x_3953.y, x_3953.z);
  let x_3957 : vec3<f32> = (x_3955 * 0.40000000596046447754f);
  let x_3960 : vec3<i32> = vec3<i32>(floor(x_3957));
  let x_3962 : vec3<f32> = fract(x_3957);
  let x_3964 : vec3<u32> = bitcast<vec3<u32>>(x_3960);
  let x_3966 : u32 = x_3964.z;
  let x_3970 : u32 = (x_3966 + (x_3966 << 10u));
  let x_3974 : u32 = (x_3970 ^ (x_3970 >> 6u));
  let x_3978 : u32 = (x_3974 + (x_3974 << 3u));
  let x_3982 : u32 = (x_3978 ^ (x_3978 >> 11u));
  let x_3992 : u32 = ((((x_3964.y * 1664525u) + (x_3982 + (x_3982 << 15u))) + 1013904223u) * 1664525u);
  let x_3996 : u32 = (x_3992 ^ (x_3992 >> 11u));
  let x_4001 : u32 = (x_3996 ^ ((x_3996 << 7u) & 2636928640u));
  let x_4006 : u32 = (x_4001 ^ ((x_4001 << 15u) & 4022730752u));
  let x_4016 : u32 = ((((x_3964.x * 1664525u) + (x_4006 ^ (x_4006 >> 18u))) + 1013904223u) * 1664525u);
  let x_4020 : u32 = (x_4016 ^ (x_4016 >> 11u));
  let x_4025 : u32 = (x_4020 ^ ((x_4020 << 7u) & 2636928640u));
  let x_4030 : u32 = (x_4025 ^ ((x_4025 << 15u) & 4022730752u));
  let x_4034 : u32 = (x_4030 ^ (x_4030 >> 18u));
  x_23453 = x_4034;
  x_23452 = 0u;
  loop {
    if ((x_23452 >= 2u)) {
      break;
    }
    let x_4046 : u32 = (x_23453 + (x_23453 << 10u));
    let x_4050 : u32 = (x_4046 ^ (x_4046 >> 6u));
    let x_4054 : u32 = (x_4050 + (x_4050 << 3u));
    let x_4058 : u32 = (x_4054 ^ (x_4054 >> 11u));
    x_3339[x_23452] = (bitcast<f32>(((x_23453 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23453 = (x_4058 + (x_4058 << 15u));
      x_23452 = (x_23452 + 1u);
    }
  }
  let x_4078 : vec3<u32> = bitcast<vec3<u32>>((x_3960 + vec3<i32>(1i, 0i, 0i)));
  let x_4080 : u32 = x_4078.z;
  let x_4084 : u32 = (x_4080 + (x_4080 << 10u));
  let x_4088 : u32 = (x_4084 ^ (x_4084 >> 6u));
  let x_4092 : u32 = (x_4088 + (x_4088 << 3u));
  let x_4096 : u32 = (x_4092 ^ (x_4092 >> 11u));
  let x_4106 : u32 = ((((x_4078.y * 1664525u) + (x_4096 + (x_4096 << 15u))) + 1013904223u) * 1664525u);
  let x_4110 : u32 = (x_4106 ^ (x_4106 >> 11u));
  let x_4115 : u32 = (x_4110 ^ ((x_4110 << 7u) & 2636928640u));
  let x_4120 : u32 = (x_4115 ^ ((x_4115 << 15u) & 4022730752u));
  let x_4130 : u32 = ((((x_4078.x * 1664525u) + (x_4120 ^ (x_4120 >> 18u))) + 1013904223u) * 1664525u);
  let x_4134 : u32 = (x_4130 ^ (x_4130 >> 11u));
  let x_4139 : u32 = (x_4134 ^ ((x_4134 << 7u) & 2636928640u));
  let x_4144 : u32 = (x_4139 ^ ((x_4139 << 15u) & 4022730752u));
  let x_4148 : u32 = (x_4144 ^ (x_4144 >> 18u));
  x_23456 = x_4148;
  x_23455 = 0u;
  loop {
    if ((x_23455 >= 2u)) {
      break;
    }
    let x_4160 : u32 = (x_23456 + (x_23456 << 10u));
    let x_4164 : u32 = (x_4160 ^ (x_4160 >> 6u));
    let x_4168 : u32 = (x_4164 + (x_4164 << 3u));
    let x_4172 : u32 = (x_4168 ^ (x_4168 >> 11u));
    x_3363[x_23455] = (bitcast<f32>(((x_23456 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23456 = (x_4172 + (x_4172 << 15u));
      x_23455 = (x_23455 + 1u);
    }
  }
  let x_4192 : vec3<u32> = bitcast<vec3<u32>>((x_3960 + vec3<i32>(0i, 1i, 0i)));
  let x_4194 : u32 = x_4192.z;
  let x_4198 : u32 = (x_4194 + (x_4194 << 10u));
  let x_4202 : u32 = (x_4198 ^ (x_4198 >> 6u));
  let x_4206 : u32 = (x_4202 + (x_4202 << 3u));
  let x_4210 : u32 = (x_4206 ^ (x_4206 >> 11u));
  let x_4220 : u32 = ((((x_4192.y * 1664525u) + (x_4210 + (x_4210 << 15u))) + 1013904223u) * 1664525u);
  let x_4224 : u32 = (x_4220 ^ (x_4220 >> 11u));
  let x_4229 : u32 = (x_4224 ^ ((x_4224 << 7u) & 2636928640u));
  let x_4234 : u32 = (x_4229 ^ ((x_4229 << 15u) & 4022730752u));
  let x_4244 : u32 = ((((x_4192.x * 1664525u) + (x_4234 ^ (x_4234 >> 18u))) + 1013904223u) * 1664525u);
  let x_4248 : u32 = (x_4244 ^ (x_4244 >> 11u));
  let x_4253 : u32 = (x_4248 ^ ((x_4248 << 7u) & 2636928640u));
  let x_4258 : u32 = (x_4253 ^ ((x_4253 << 15u) & 4022730752u));
  let x_4262 : u32 = (x_4258 ^ (x_4258 >> 18u));
  x_23459 = x_4262;
  x_23458 = 0u;
  loop {
    if ((x_23458 >= 2u)) {
      break;
    }
    let x_4274 : u32 = (x_23459 + (x_23459 << 10u));
    let x_4278 : u32 = (x_4274 ^ (x_4274 >> 6u));
    let x_4282 : u32 = (x_4278 + (x_4278 << 3u));
    let x_4286 : u32 = (x_4282 ^ (x_4282 >> 11u));
    x_3387[x_23458] = (bitcast<f32>(((x_23459 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23459 = (x_4286 + (x_4286 << 15u));
      x_23458 = (x_23458 + 1u);
    }
  }
  let x_4306 : vec3<u32> = bitcast<vec3<u32>>((x_3960 + vec3<i32>(1i, 1i, 0i)));
  let x_4308 : u32 = x_4306.z;
  let x_4312 : u32 = (x_4308 + (x_4308 << 10u));
  let x_4316 : u32 = (x_4312 ^ (x_4312 >> 6u));
  let x_4320 : u32 = (x_4316 + (x_4316 << 3u));
  let x_4324 : u32 = (x_4320 ^ (x_4320 >> 11u));
  let x_4334 : u32 = ((((x_4306.y * 1664525u) + (x_4324 + (x_4324 << 15u))) + 1013904223u) * 1664525u);
  let x_4338 : u32 = (x_4334 ^ (x_4334 >> 11u));
  let x_4343 : u32 = (x_4338 ^ ((x_4338 << 7u) & 2636928640u));
  let x_4348 : u32 = (x_4343 ^ ((x_4343 << 15u) & 4022730752u));
  let x_4358 : u32 = ((((x_4306.x * 1664525u) + (x_4348 ^ (x_4348 >> 18u))) + 1013904223u) * 1664525u);
  let x_4362 : u32 = (x_4358 ^ (x_4358 >> 11u));
  let x_4367 : u32 = (x_4362 ^ ((x_4362 << 7u) & 2636928640u));
  let x_4372 : u32 = (x_4367 ^ ((x_4367 << 15u) & 4022730752u));
  let x_4376 : u32 = (x_4372 ^ (x_4372 >> 18u));
  x_23462 = x_4376;
  x_23461 = 0u;
  loop {
    if ((x_23461 >= 2u)) {
      break;
    }
    let x_4388 : u32 = (x_23462 + (x_23462 << 10u));
    let x_4392 : u32 = (x_4388 ^ (x_4388 >> 6u));
    let x_4396 : u32 = (x_4392 + (x_4392 << 3u));
    let x_4400 : u32 = (x_4396 ^ (x_4396 >> 11u));
    x_3411[x_23461] = (bitcast<f32>(((x_23462 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23462 = (x_4400 + (x_4400 << 15u));
      x_23461 = (x_23461 + 1u);
    }
  }
  let x_4420 : vec3<u32> = bitcast<vec3<u32>>((x_3960 + vec3<i32>(0i, 0i, 1i)));
  let x_4422 : u32 = x_4420.z;
  let x_4426 : u32 = (x_4422 + (x_4422 << 10u));
  let x_4430 : u32 = (x_4426 ^ (x_4426 >> 6u));
  let x_4434 : u32 = (x_4430 + (x_4430 << 3u));
  let x_4438 : u32 = (x_4434 ^ (x_4434 >> 11u));
  let x_4448 : u32 = ((((x_4420.y * 1664525u) + (x_4438 + (x_4438 << 15u))) + 1013904223u) * 1664525u);
  let x_4452 : u32 = (x_4448 ^ (x_4448 >> 11u));
  let x_4457 : u32 = (x_4452 ^ ((x_4452 << 7u) & 2636928640u));
  let x_4462 : u32 = (x_4457 ^ ((x_4457 << 15u) & 4022730752u));
  let x_4472 : u32 = ((((x_4420.x * 1664525u) + (x_4462 ^ (x_4462 >> 18u))) + 1013904223u) * 1664525u);
  let x_4476 : u32 = (x_4472 ^ (x_4472 >> 11u));
  let x_4481 : u32 = (x_4476 ^ ((x_4476 << 7u) & 2636928640u));
  let x_4486 : u32 = (x_4481 ^ ((x_4481 << 15u) & 4022730752u));
  let x_4490 : u32 = (x_4486 ^ (x_4486 >> 18u));
  x_23465 = x_4490;
  x_23464 = 0u;
  loop {
    if ((x_23464 >= 2u)) {
      break;
    }
    let x_4502 : u32 = (x_23465 + (x_23465 << 10u));
    let x_4506 : u32 = (x_4502 ^ (x_4502 >> 6u));
    let x_4510 : u32 = (x_4506 + (x_4506 << 3u));
    let x_4514 : u32 = (x_4510 ^ (x_4510 >> 11u));
    x_3435[x_23464] = (bitcast<f32>(((x_23465 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23465 = (x_4514 + (x_4514 << 15u));
      x_23464 = (x_23464 + 1u);
    }
  }
  let x_4534 : vec3<u32> = bitcast<vec3<u32>>((x_3960 + vec3<i32>(1i, 0i, 1i)));
  let x_4536 : u32 = x_4534.z;
  let x_4540 : u32 = (x_4536 + (x_4536 << 10u));
  let x_4544 : u32 = (x_4540 ^ (x_4540 >> 6u));
  let x_4548 : u32 = (x_4544 + (x_4544 << 3u));
  let x_4552 : u32 = (x_4548 ^ (x_4548 >> 11u));
  let x_4562 : u32 = ((((x_4534.y * 1664525u) + (x_4552 + (x_4552 << 15u))) + 1013904223u) * 1664525u);
  let x_4566 : u32 = (x_4562 ^ (x_4562 >> 11u));
  let x_4571 : u32 = (x_4566 ^ ((x_4566 << 7u) & 2636928640u));
  let x_4576 : u32 = (x_4571 ^ ((x_4571 << 15u) & 4022730752u));
  let x_4586 : u32 = ((((x_4534.x * 1664525u) + (x_4576 ^ (x_4576 >> 18u))) + 1013904223u) * 1664525u);
  let x_4590 : u32 = (x_4586 ^ (x_4586 >> 11u));
  let x_4595 : u32 = (x_4590 ^ ((x_4590 << 7u) & 2636928640u));
  let x_4600 : u32 = (x_4595 ^ ((x_4595 << 15u) & 4022730752u));
  let x_4604 : u32 = (x_4600 ^ (x_4600 >> 18u));
  x_23468 = x_4604;
  x_23467 = 0u;
  loop {
    if ((x_23467 >= 2u)) {
      break;
    }
    let x_4616 : u32 = (x_23468 + (x_23468 << 10u));
    let x_4620 : u32 = (x_4616 ^ (x_4616 >> 6u));
    let x_4624 : u32 = (x_4620 + (x_4620 << 3u));
    let x_4628 : u32 = (x_4624 ^ (x_4624 >> 11u));
    x_3459[x_23467] = (bitcast<f32>(((x_23468 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23468 = (x_4628 + (x_4628 << 15u));
      x_23467 = (x_23467 + 1u);
    }
  }
  let x_4648 : vec3<u32> = bitcast<vec3<u32>>((x_3960 + vec3<i32>(0i, 1i, 1i)));
  let x_4650 : u32 = x_4648.z;
  let x_4654 : u32 = (x_4650 + (x_4650 << 10u));
  let x_4658 : u32 = (x_4654 ^ (x_4654 >> 6u));
  let x_4662 : u32 = (x_4658 + (x_4658 << 3u));
  let x_4666 : u32 = (x_4662 ^ (x_4662 >> 11u));
  let x_4676 : u32 = ((((x_4648.y * 1664525u) + (x_4666 + (x_4666 << 15u))) + 1013904223u) * 1664525u);
  let x_4680 : u32 = (x_4676 ^ (x_4676 >> 11u));
  let x_4685 : u32 = (x_4680 ^ ((x_4680 << 7u) & 2636928640u));
  let x_4690 : u32 = (x_4685 ^ ((x_4685 << 15u) & 4022730752u));
  let x_4700 : u32 = ((((x_4648.x * 1664525u) + (x_4690 ^ (x_4690 >> 18u))) + 1013904223u) * 1664525u);
  let x_4704 : u32 = (x_4700 ^ (x_4700 >> 11u));
  let x_4709 : u32 = (x_4704 ^ ((x_4704 << 7u) & 2636928640u));
  let x_4714 : u32 = (x_4709 ^ ((x_4709 << 15u) & 4022730752u));
  let x_4718 : u32 = (x_4714 ^ (x_4714 >> 18u));
  x_23471 = x_4718;
  x_23470 = 0u;
  loop {
    if ((x_23470 >= 2u)) {
      break;
    }
    let x_4730 : u32 = (x_23471 + (x_23471 << 10u));
    let x_4734 : u32 = (x_4730 ^ (x_4730 >> 6u));
    let x_4738 : u32 = (x_4734 + (x_4734 << 3u));
    let x_4742 : u32 = (x_4738 ^ (x_4738 >> 11u));
    x_3483[x_23470] = (bitcast<f32>(((x_23471 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23471 = (x_4742 + (x_4742 << 15u));
      x_23470 = (x_23470 + 1u);
    }
  }
  let x_4762 : vec3<u32> = bitcast<vec3<u32>>((x_3960 + vec3<i32>(1i, 1i, 1i)));
  let x_4764 : u32 = x_4762.z;
  let x_4768 : u32 = (x_4764 + (x_4764 << 10u));
  let x_4772 : u32 = (x_4768 ^ (x_4768 >> 6u));
  let x_4776 : u32 = (x_4772 + (x_4772 << 3u));
  let x_4780 : u32 = (x_4776 ^ (x_4776 >> 11u));
  let x_4790 : u32 = ((((x_4762.y * 1664525u) + (x_4780 + (x_4780 << 15u))) + 1013904223u) * 1664525u);
  let x_4794 : u32 = (x_4790 ^ (x_4790 >> 11u));
  let x_4799 : u32 = (x_4794 ^ ((x_4794 << 7u) & 2636928640u));
  let x_4804 : u32 = (x_4799 ^ ((x_4799 << 15u) & 4022730752u));
  let x_4814 : u32 = ((((x_4762.x * 1664525u) + (x_4804 ^ (x_4804 >> 18u))) + 1013904223u) * 1664525u);
  let x_4818 : u32 = (x_4814 ^ (x_4814 >> 11u));
  let x_4823 : u32 = (x_4818 ^ ((x_4818 << 7u) & 2636928640u));
  let x_4828 : u32 = (x_4823 ^ ((x_4823 << 15u) & 4022730752u));
  let x_4832 : u32 = (x_4828 ^ (x_4828 >> 18u));
  x_23474 = x_4832;
  x_23473 = 0u;
  loop {
    if ((x_23473 >= 2u)) {
      break;
    }
    let x_4844 : u32 = (x_23474 + (x_23474 << 10u));
    let x_4848 : u32 = (x_4844 ^ (x_4844 >> 6u));
    let x_4852 : u32 = (x_4848 + (x_4848 << 3u));
    let x_4856 : u32 = (x_4852 ^ (x_4852 >> 11u));
    x_3507[x_23473] = (bitcast<f32>(((x_23474 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23474 = (x_4856 + (x_4856 << 15u));
      x_23473 = (x_23473 + 1u);
    }
  }
  let x_4880 : vec3<f32> = ((x_3962 * x_3962) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_3962)));
  let x_4882 : f32 = x_4880.x;
  let x_4884 : f32 = (1.0f - x_4882);
  let x_4886 : f32 = x_4880.y;
  let x_4888 : f32 = (1.0f - x_4886);
  let x_4890 : f32 = x_4880.z;
  let x_4892 : f32 = (1.0f - x_4890);
  let x_4893 : vec2<f32> = x_3339;
  let x_4900 : vec2<f32> = x_3363;
  let x_4908 : vec2<f32> = x_3387;
  let x_4916 : vec2<f32> = x_3411;
  let x_4924 : vec2<f32> = x_3435;
  let x_4932 : vec2<f32> = x_3459;
  let x_4940 : vec2<f32> = x_3483;
  let x_4948 : vec2<f32> = x_3507;
  let x_4958 : vec2<f32> = clamp(((((((((((((x_4893 * x_4884) * x_4888) * x_4892) + (((x_4900 * x_4882) * x_4888) * x_4892)) + (((x_4908 * x_4884) * x_4886) * x_4892)) + (((x_4916 * x_4882) * x_4886) * x_4892)) + (((x_4924 * x_4884) * x_4888) * x_4890)) + (((x_4932 * x_4882) * x_4888) * x_4890)) + (((x_4940 * x_4884) * x_4886) * x_4890)) + (((x_4948 * x_4882) * x_4886) * x_4890)) - x_2361) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_2361);
  let x_4966 : vec3<f32> = (x_3955 + (vec3<f32>(x_4958.x, 0.0f, x_4958.y) * 0.05999999865889549255f));
  var x_23875_1 : vec4<f32> = x_3953;
  x_23875_1.x = x_4966.x;
  let x_23875 : vec4<f32> = x_23875_1;
  var x_23878_1 : vec4<f32> = x_23875;
  x_23878_1.z = x_4966.z;
  let x_23878 : vec4<f32> = x_23878_1;
  let x_4975 : vec3<f32> = (x_883 * x_3942);
  let x_4978 : f32 = (x_3944 - -0.5f);
  let x_4997 : f32 = (x_4966.y + mix(mix(x_3615.x, x_3615.y, x_4978), mix(x_3622.x, x_3622.y, x_4978), (x_3945 - -0.5f)));
  var x_23887_1 : vec4<f32> = x_23878;
  x_23887_1.y = x_4997;
  let x_23887 : vec4<f32> = x_23887_1;
  let x_14506 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_14513 : i32 = x_14506.x;
  let x_14522 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_14513), (x_5489 / x_14513)), 0i);
  let x_14631 : i32 = ((bitcast<i32>(x_14522[x_5502]) * 16i) + 11i);
  let x_14963 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_14968 : i32 = (x_14631 / 4i);
  let x_14970 : i32 = x_14963.x;
  let x_14979 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_14968 % x_14970), (x_14968 / x_14970)), 0i);
  let x_5006 : vec2<f32> = unpack2x16float(x_14979[(x_14631 % 4i)]);
  let x_5008 : vec4<f32> = x_3942[0u];
  let x_5011 : vec4<f32> = x_3942[1u];
  let x_5014 : vec4<f32> = x_3942[2u];
  let x_5028 : mat3x3<f32> = mat3x3<f32>(vec3<f32>(x_5008.x, x_5008.y, x_5008.z), vec3<f32>(x_5011.x, x_5011.y, x_5011.z), vec3<f32>(x_5014.x, x_5014.y, x_5014.z));
  let x_5030 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_5028);
  let x_5032 : vec3<f32> = (x_2454 * x_5028);
  let x_5034 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_5028);
  let x_5037 : vec3<f32> = cross(x_5030, x_5032);
  let x_5041 : f32 = (1.0f / dot(x_5034, x_5037));
  let x_5042 : vec3<f32> = vec3<f32>(x_5041, x_5041, x_5041);
  let x_5069 : mat3x3<f32> = transpose(mat3x3<f32>((cross(x_5032, x_5034) * x_5042), (cross(x_5034, x_5030) * x_5042), (x_5037 * x_5042)));
  let x_15105 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_15112 : i32 = x_15105.x;
  let x_15121 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_15112), (x_5489 / x_15112)), 0i);
  let x_15237 : i32 = ((bitcast<i32>(x_15121[x_5502]) * 16i) + 12i);
  let x_15589 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_15594 : i32 = (x_15237 / 4i);
  let x_15596 : i32 = x_15589.x;
  let x_15605 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_15594 % x_15596), (x_15594 / x_15596)), 0i);
  let x_5087 : vec2<f32> = vec2<f32>(mix(x_5006.y, unpack2x16float(x_15605[(x_15237 % 4i)]).x, x_4978), select(x_4997, 0.0f, ((x_3813 & 1024i) != 0i)));
  let x_15704 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_15711 : i32 = x_15704.x;
  let x_15720 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_15711), (x_5489 / x_15711)), 0i);
  let x_15843 : i32 = ((bitcast<i32>(x_15720[x_5502]) * 16i) + 13i);
  let x_16215 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_16220 : i32 = (x_15843 / 4i);
  let x_16222 : i32 = x_16215.x;
  let x_16231 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_16220 % x_16222), (x_16220 / x_16222)), 0i);
  let x_5094 : u32 = (x_16231[(x_15843 % 4i)] & 65535u);
  let x_16303 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_16310 : i32 = x_16303.x;
  let x_16319 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_16310), (x_5489 / x_16310)), 0i);
  let x_16442 : i32 = ((bitcast<i32>(x_16319[x_5502]) * 16i) + 13i);
  let x_16814 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_16819 : i32 = (x_16442 / 4i);
  let x_16821 : i32 = x_16814.x;
  let x_16830 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_16819 % x_16821), (x_16819 / x_16821)), 0i);
  if ((x_16830[(x_16442 % 4i)] < 10u)) {
    x_5104 = (x_23445 | 512i);
    x_23577 = x_5104;
  } else {
    x_23577 = x_23445;
  }
  let x_5129 : mat3x3<f32> = mat3x3<f32>(vec3<f32>(x_3646, 0.0f, -(x_3650)), x_2454, vec3<f32>(x_3650, 0.0f, x_3646));
  let x_5132 : vec3<f32> = (x_5129 * x_3806);
  let x_5135 : vec3<f32> = (x_3772 - x_4975);
  let x_5140 : vec3<f32> = (x_5129 * (x_5069 * x_5135));
  let x_5143 : mat3x3<f32> = (x_5129 * x_5069);
  let x_16902 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_16909 : i32 = x_16902.x;
  let x_16918 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_16909), (x_5489 / x_16909)), 0i);
  let x_17018 : i32 = ((bitcast<i32>(x_16918[x_5502]) * 16i) + 10i);
  let x_17332 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_17337 : i32 = (x_17018 / 4i);
  let x_17339 : i32 = x_17332.x;
  let x_17348 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_17337 % x_17339), (x_17337 / x_17339)), 0i);
  let x_5150 : vec2<f32> = unpack2x16float(x_17348[(x_17018 % 4i)]);
  if ((x_4978 < 0.5f)) {
    x_5160 = mix(x_5150.x, x_5150.y, (x_4978 * 2.0f));
    x_23681 = x_5160;
  } else {
    x_5169 = mix(x_5150.y, x_5006.x, ((x_4978 * 2.0f) - 1.0f));
    x_23681 = x_5169;
  }
  var x_5200 : bool;
  var x_23598 : bool;
  var x_5206 : i32;
  var x_5232 : i32;
  var x_5257 : i32;
  let x_17501 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_17508 : i32 = x_17501.x;
  let x_17517 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_17508), (x_5489 / x_17508)), 0i);
  let x_17645 : i32 = ((bitcast<i32>(x_17517[x_5502]) * 16i) + 14i);
  let x_18039 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_18044 : i32 = (x_17645 / 4i);
  let x_18046 : i32 = x_18039.x;
  let x_18055 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_18044 % x_18046), (x_18044 / x_18046)), 0i);
  let x_5178 : bool = ((x_18055[(x_17645 % 4i)] & 2147483648u) != 0u);
  if (x_5178) {
    let x_18100 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_18107 : i32 = x_18100.x;
    let x_18116 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_18107), (x_5489 / x_18107)), 0i);
    let x_18244 : i32 = ((bitcast<i32>(x_18116[x_5502]) * 16i) + 14i);
    let x_18638 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_18643 : i32 = (x_18244 / 4i);
    let x_18645 : i32 = x_18638.x;
    let x_18654 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_18643 % x_18645), (x_18643 / x_18645)), 0i);
    if (((x_18654[(x_18244 % 4i)] & 1073741824u) != 0u)) {
      let x_18699 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
      let x_18706 : i32 = x_18699.x;
      let x_18715 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_18706), (x_5489 / x_18706)), 0i);
      let x_18843 : i32 = ((bitcast<i32>(x_18715[x_5502]) * 16i) + 14i);
      let x_19237 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_19242 : i32 = (x_18843 / 4i);
      let x_19244 : i32 = x_19237.x;
      let x_19253 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_19242 % x_19244), (x_19242 / x_19244)), 0i);
      x_5200 = (((x_19253[(x_18843 % 4i)] >> 4u) & 65535u) == x_3245);
      x_23598 = x_5200;
    } else {
      x_23598 = false;
    }
    if (x_23598) {
      x_5206 = (x_23577 | 2048i);
      x_23602 = x_5206;
    } else {
      x_23602 = x_23577;
    }
    let x_19298 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_19305 : i32 = x_19298.x;
    let x_19314 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_19305), (x_5489 / x_19305)), 0i);
    let x_19442 : i32 = ((bitcast<i32>(x_19314[x_5502]) * 16i) + 14i);
    let x_19836 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_19841 : i32 = (x_19442 / 4i);
    let x_19843 : i32 = x_19836.x;
    let x_19852 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_19841 % x_19843), (x_19841 / x_19843)), 0i);
    x_5217 = bitcast<i32>((x_19852[(x_19442 % 4i)] & 15u));
    x_23689 = x_5217;
    x_23630 = x_23602;
  } else {
    var x_21148 : u32;
    var x_21781 : u32;
    var x_23578 : u32;
    if (((x_23577 & 8192i) != 0i)) {
      let x_19897 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
      let x_19904 : i32 = x_19897.x;
      let x_19913 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_19904), (x_5489 / x_19904)), 0i);
      let x_20041 : i32 = ((bitcast<i32>(x_19913[x_5502]) * 16i) + 14i);
      let x_20435 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_20440 : i32 = (x_20041 / 4i);
      let x_20442 : i32 = x_20435.x;
      let x_20451 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_20440 % x_20442), (x_20440 / x_20442)), 0i);
      let x_5230 : i32 = bitcast<i32>(x_20451[(x_20041 % 4i)]);
      let x_20496 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
      let x_20501 : i32 = (x_5230 / 4i);
      let x_20503 : i32 = x_20496.x;
      let x_20512 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_20501 % x_20503), (x_20501 / x_20503)), 0i);
      x_5232 = bitcast<i32>(x_20512[(x_5230 % 4i)]);
      x_23579 = x_5232;
    } else {
      if (((x_23577 & 2i) != 0i)) {
        let x_20530 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
        let x_20537 : i32 = x_20530.x;
        let x_20546 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_20537), (x_5489 / x_20537)), 0i);
        let x_20674 : i32 = ((bitcast<i32>(x_20546[x_5502]) * 16i) + 14i);
        let x_21068 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_21073 : i32 = (x_20674 / 4i);
        let x_21075 : i32 = x_21068.x;
        let x_21084 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_21073 % x_21075), (x_21073 / x_21075)), 0i);
        let x_5244 : i32 = bitcast<i32>(x_21084[(x_20674 % 4i)]);
        let x_21129 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
        let x_21134 : i32 = (x_5244 / 4i);
        let x_21136 : i32 = x_21129.x;
        let x_21145 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_21134 % x_21136), (x_21134 / x_21136)), 0i);
        x_21148 = x_21145[(x_5244 % 4i)];
        x_23578 = x_21148;
      } else {
        let x_21163 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
        let x_21170 : i32 = x_21163.x;
        let x_21179 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_21170), (x_5489 / x_21170)), 0i);
        let x_21307 : i32 = ((bitcast<i32>(x_21179[x_5502]) * 16i) + 14i);
        let x_21701 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_21706 : i32 = (x_21307 / 4i);
        let x_21708 : i32 = x_21701.x;
        let x_21717 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_21706 % x_21708), (x_21706 / x_21708)), 0i);
        let x_5253 : i32 = bitcast<i32>(x_21717[(x_21307 % 4i)]);
        let x_21762 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
        let x_21767 : i32 = (x_5253 / 4i);
        let x_21769 : i32 = x_21762.x;
        let x_21778 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_21767 % x_21769), (x_21767 / x_21769)), 0i);
        x_21781 = x_21778[(x_5253 % 4i)];
        x_23578 = x_21781;
      }
      x_5257 = bitcast<i32>(x_23578);
      x_23579 = x_5257;
    }
    x_23689 = x_23579;
    x_23630 = x_23577;
  }
  if (x_5178) {
    let x_21796 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_21803 : i32 = x_21796.x;
    let x_21812 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_21803), (x_5489 / x_21803)), 0i);
    let x_21940 : i32 = ((bitcast<i32>(x_21812[x_5502]) * 16i) + 14i);
    let x_22334 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_22339 : i32 = (x_21940 / 4i);
    let x_22341 : i32 = x_22334.x;
    let x_22350 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_22339 % x_22341), (x_22339 / x_22341)), 0i);
    x_22353 = x_22350[(x_21940 % 4i)];
    x_23611 = x_22353;
  } else {
    let x_22395 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_22402 : i32 = x_22395.x;
    let x_22411 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_22402), (x_5489 / x_22402)), 0i);
    let x_22539 : i32 = ((bitcast<i32>(x_22411[x_5502]) * 16i) + 14i);
    let x_22933 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_22938 : i32 = (x_22539 / 4i);
    let x_22940 : i32 = x_22933.x;
    let x_22949 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_22938 % x_22940), (x_22938 / x_22940)), 0i);
    let x_5277 : i32 = bitcast<i32>(x_22949[(x_22539 % 4i)]);
    let x_22994 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_10_0, 0i));
    let x_22999 : i32 = (x_5277 / 4i);
    let x_23001 : i32 = x_22994.x;
    let x_23010 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_10_0, vec2<i32>((x_22999 % x_23001), (x_22999 / x_23001)), 0i);
    x_23013 = x_23010[(x_5277 % 4i)];
    x_23611 = x_23013;
  }
  let x_5281 : u32 = (x_23611 & 65535u);
  let x_5283 : u32 = (x_5281 ^ 7993234u);
  let x_5287 : u32 = (x_5283 + (x_5283 << 10u));
  let x_5291 : u32 = (x_5287 ^ (x_5287 >> 6u));
  let x_5295 : u32 = (x_5291 + (x_5291 << 3u));
  let x_5299 : u32 = (x_5295 ^ (x_5295 >> 11u));
  let x_5301 : u32 = (x_5281 ^ 3450234u);
  let x_5305 : u32 = (x_5301 + (x_5301 << 10u));
  let x_5309 : u32 = (x_5305 ^ (x_5305 >> 6u));
  let x_5313 : u32 = (x_5309 + (x_5309 << 3u));
  let x_5317 : u32 = (x_5313 ^ (x_5313 >> 11u));
  let x_5323 : f32 = (f32(x_5281) * 0.20000000298023223877f);
  let x_5343 : vec2<f32> = ((((x_5087 * 0.10000000149011611938f) * 0.69999998807907104492f) + vec2<f32>(x_5323, x_5323)) + vec2<f32>((bitcast<f32>((((x_5299 + (x_5299 << 15u)) & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_5317 + (x_5317 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
  let x_5345 : u32 = (x_5094 ^ 292478890u);
  let x_5349 : u32 = (x_5345 + (x_5345 << 10u));
  let x_5353 : u32 = (x_5349 ^ (x_5349 >> 6u));
  let x_5357 : u32 = (x_5353 + (x_5353 << 3u));
  let x_5361 : u32 = (x_5357 ^ (x_5357 >> 11u));
  let x_5369 : f32 = (bitcast<f32>((((x_5361 + (x_5361 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
  if ((x_5369 > 0.89999997615814208984f)) {
    x_5374 = (x_5343 * 3.0f);
    x_23631 = x_5374;
  } else {
    let x_5378 : f32 = (0.61000001430511474609f * x_5369);
    x_5380 = (x_5343 + vec2<f32>(x_5378, x_5378));
    x_23631 = x_5380;
  }
  if (((x_23630 & 512i) != 0i)) {
    x_5389 = (x_23631 * 2.20000004768371582031f);
    x_23637 = x_5389;
  } else {
    x_23637 = x_23631;
  }
  let x_5395 : bool = ((x_23577 & 32i) != 0i);
  if (x_5395) {
    x_5399 = (x_5087 * 0.69999998807907104492f);
    x_23684 = x_5399;
  } else {
    x_23684 = x_23637;
  }
  let x_5404 : mat4x4<f32> = x_2924.renderer_MVPMat;
  gl_Position = (x_5404 * x_23887);
  v0 = x_5094;
  v2 = vec3<f32>(x_23887.x, x_23887.y, x_23887.z);
  v3 = x_5132;
  v4 = normalize((x_5132 - x_5140));
  v5 = (length(x_5135) / length(x_5140));
  v7 = select(x_23681, -100.0f, x_5395);
  v8 = -100000.0f;
  v9 = x_23684;
  v10 = x_23689;
  let x_5430 : vec4<f32> = vec4<f32>(x_4975.x, 0.0f, x_4975.z, 1.0f);
  v11 = vec2<f32>(x_5430.x, x_5430.z);
  v12 = x_23630;
  let x_23028 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_23035 : i32 = x_23028.x;
  let x_23044 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_23035), (x_5489 / x_23035)), 0i);
  v13 = x_23044[x_5502];
  let x_23055 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_23062 : i32 = x_23055.x;
  let x_23071 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5489 % x_23062), (x_5489 / x_23062)), 0i);
  resident_cell_id = x_23071[x_5502];
  v14_col0 = vec3<f32>(x_5143[0u].x, x_5143[1u].x, x_5143[2u].x);
  v14_col1 = vec3<f32>(x_5143[0u].y, x_5143[1u].y, x_5143[2u].y);
  v14_col2 = vec3<f32>(x_5143[0u].z, x_5143[1u].z, x_5143[2u].z);
  let x_3066 : f32 = gl_Position.z;
  let x_3068 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_3066 + x_3068));
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
  @location(15) @interpolate(flat)
  resident_cell_id_1 : u32,
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
  return main_out(gl_Position, v0, v2, v3, v4, v5, v7, v8, v9, v10, v11, v12, v13, resident_cell_id, v14_col0, v14_col1, v14_col2);
}
