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

@binding(8) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

var<private> gl_InstanceIndex : i32;

var<private> Vertex_Position : vec3<f32>;

var<private> Vertex_Normal : vec3<f32>;

var<private> is_bevel : i32;

@binding(0) @group(2) var<uniform> x_2969 : gs_Auto_0;

var<private> v0 : u32;

var<private> v1 : vec3<f32>;

var<private> v2 : vec3<f32>;

var<private> v7 : f32;

var<private> v8 : f32;

var<private> v9 : vec2<f32>;

var<private> v10 : i32;

var<private> v11 : vec2<f32>;

var<private> v12 : i32;

var<private> gl_Position : vec4<f32>;

const x_707 = vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f);

const x_2297 = vec2<f32>(0.5f, 0.5f);

fn main_1() {
  var x_3332 : vec2<f32>;
  var x_3356 : vec2<f32>;
  var x_3380 : vec2<f32>;
  var x_3404 : vec2<f32>;
  var x_3428 : vec2<f32>;
  var x_3452 : vec2<f32>;
  var x_3476 : vec2<f32>;
  var x_3500 : vec2<f32>;
  var x_25093 : mat3x4<f32>;
  var x_24669 : mat3x4<f32>;
  var x_3857 : i32;
  var x_24663 : i32;
  var x_3907 : vec3<f32>;
  var x_25232 : vec3<f32>;
  var x_24674 : u32;
  var x_24673 : u32;
  var x_24677 : u32;
  var x_24676 : u32;
  var x_24680 : u32;
  var x_24679 : u32;
  var x_24683 : u32;
  var x_24682 : u32;
  var x_24686 : u32;
  var x_24685 : u32;
  var x_24689 : u32;
  var x_24688 : u32;
  var x_24692 : u32;
  var x_24691 : u32;
  var x_24695 : u32;
  var x_24694 : u32;
  var x_5093 : i32;
  var x_24750 : i32;
  var x_5106 : i32;
  var x_24809 : i32;
  var x_5165 : f32;
  var x_5174 : f32;
  var x_24970 : f32;
  var x_24832 : i32;
  var x_5222 : i32;
  var x_24811 : i32;
  var x_24981 : i32;
  var x_24882 : i32;
  var x_21801 : u32;
  var x_22461 : u32;
  var x_24841 : u32;
  var x_5395 : vec2<f32>;
  var x_5401 : vec2<f32>;
  var x_24883 : vec2<f32>;
  var x_5410 : vec2<f32>;
  var x_24886 : vec2<f32>;
  var x_5486 : vec2<f32>;
  var x_24974 : vec2<f32>;
  let x_3103 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_MaterialData_natural, vec2<i32>(0i, 0i), 0i);
  let x_3227 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_3232 : i32 = x_3227.x;
  let x_3239 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((15i % x_3232), (15i / x_3232)), 0i);
  let x_3241 : u32 = x_3239.y;
  let x_3617 : bool = (x_3103.x != 0u);
  let x_3621 : i32 = gl_InstanceIndex;
  let x_3625 : i32 = bitcast<i32>((select(0u, 4194304u, x_3617) + bitcast<u32>(x_3621)));
  let x_5567 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_5572 : i32 = (x_3625 / 4i);
  let x_5574 : i32 = x_5567.x;
  let x_5583 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_5574), (x_5572 / x_5574)), 0i);
  let x_5585 : i32 = (x_3625 % 4i);
  let x_5668 : i32 = ((bitcast<i32>(x_5583[x_5585]) * 16i) + 8i);
  let x_5944 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_5949 : i32 = (x_5668 / 4i);
  let x_5951 : i32 = x_5944.x;
  let x_5960 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5949 % x_5951), (x_5949 / x_5951)), 0i);
  let x_3630 : vec2<f32> = unpack2x16float(x_5960[(x_5668 % 4i)]);
  let x_6167 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_6174 : i32 = x_6167.x;
  let x_6183 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_6174), (x_5572 / x_6174)), 0i);
  let x_6276 : i32 = ((bitcast<i32>(x_6183[x_5585]) * 16i) + 9i);
  let x_6570 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_6575 : i32 = (x_6276 / 4i);
  let x_6577 : i32 = x_6570.x;
  let x_6586 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_6575 % x_6577), (x_6575 / x_6577)), 0i);
  let x_3637 : vec2<f32> = unpack2x16float(x_6586[(x_6276 % 4i)]);
  let x_6766 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_6773 : i32 = x_6766.x;
  let x_6782 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_6773), (x_5572 / x_6773)), 0i);
  let x_6905 : i32 = ((bitcast<i32>(x_6782[x_5585]) * 16i) + 13i);
  let x_7277 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_7282 : i32 = (x_6905 / 4i);
  let x_7284 : i32 = x_7277.x;
  let x_7293 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_7282 % x_7284), (x_7282 / x_7284)), 0i);
  let x_7296 : u32 = x_7293[(x_6905 % 4i)];
  let x_3651 : i32 = -(bitcast<i32>((x_7296 & 1u)));
  let x_3656 : i32 = (1i - bitcast<i32>((((x_7296 & 3u) >> 1u) << 1u)));
  let x_3661 : f32 = f32((~(x_3651) & x_3656));
  let x_3665 : f32 = f32((x_3651 & x_3656));
  let x_3695 : mat4x4<f32> = mat4x4<f32>(vec4<f32>(x_3661, 0.0f, -(x_3665), 0.0f), vec4<f32>(0.0f, 1.0f, 0.0f, 0.0f), vec4<f32>(x_3665, 0.0f, x_3661, 0.0f), x_707);
  let x_7365 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_7372 : i32 = x_7365.x;
  let x_7381 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_7372), (x_5572 / x_7372)), 0i);
  let x_7414 : i32 = ((bitcast<i32>(x_7381[x_5585]) * 16i) + 1i);
  let x_7552 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_7557 : i32 = (x_7414 / 4i);
  let x_7559 : i32 = x_7552.x;
  let x_7568 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_7557 % x_7559), (x_7557 / x_7559)), 0i);
  let x_3702 : vec2<f32> = unpack2x16float(x_7568[(x_7414 % 4i)]);
  let x_7964 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_7971 : i32 = x_7964.x;
  let x_7980 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_7971), (x_5572 / x_7971)), 0i);
  let x_8003 : i32 = (bitcast<i32>(x_7980[x_5585]) * 16i);
  let x_8124 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_8129 : i32 = (x_8003 / 4i);
  let x_8131 : i32 = x_8124.x;
  let x_8140 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_8129 % x_8131), (x_8129 / x_8131)), 0i);
  let x_3709 : vec2<f32> = unpack2x16float(x_8140[(x_8003 % 4i)]);
  let x_8563 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_8570 : i32 = x_8563.x;
  let x_8579 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_8570), (x_5572 / x_8570)), 0i);
  let x_8619 : i32 = ((bitcast<i32>(x_8579[x_5585]) * 16i) + 2i);
  let x_8777 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_8782 : i32 = (x_8619 / 4i);
  let x_8784 : i32 = x_8777.x;
  let x_8793 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_8782 % x_8784), (x_8782 / x_8784)), 0i);
  let x_3723 : vec2<f32> = unpack2x16float(x_8793[(x_8619 % 4i)]);
  let x_9162 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_9169 : i32 = x_9162.x;
  let x_9178 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_9169), (x_5572 / x_9169)), 0i);
  let x_9225 : i32 = ((bitcast<i32>(x_9178[x_5585]) * 16i) + 3i);
  let x_9403 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_9408 : i32 = (x_9225 / 4i);
  let x_9410 : i32 = x_9403.x;
  let x_9419 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_9408 % x_9410), (x_9408 / x_9410)), 0i);
  let x_3733 : vec2<f32> = unpack2x16float(x_9419[(x_9225 % 4i)]);
  let x_9761 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_9768 : i32 = x_9761.x;
  let x_9777 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_9768), (x_5572 / x_9768)), 0i);
  let x_9831 : i32 = ((bitcast<i32>(x_9777[x_5585]) * 16i) + 4i);
  let x_10029 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_10034 : i32 = (x_9831 / 4i);
  let x_10036 : i32 = x_10029.x;
  let x_10045 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_10034 % x_10036), (x_10034 / x_10036)), 0i);
  let x_10360 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_10367 : i32 = x_10360.x;
  let x_10376 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_10367), (x_5572 / x_10367)), 0i);
  let x_10437 : i32 = ((bitcast<i32>(x_10376[x_5585]) * 16i) + 5i);
  let x_10655 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_10660 : i32 = (x_10437 / 4i);
  let x_10662 : i32 = x_10655.x;
  let x_10671 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_10660 % x_10662), (x_10660 / x_10662)), 0i);
  let x_10959 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_10966 : i32 = x_10959.x;
  let x_10975 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_10966), (x_5572 / x_10966)), 0i);
  let x_11045 : i32 = ((bitcast<i32>(x_10975[x_5585]) * 16i) + 6i);
  let x_11281 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_11286 : i32 = (x_11045 / 4i);
  let x_11288 : i32 = x_11281.x;
  let x_11297 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_11286 % x_11288), (x_11286 / x_11288)), 0i);
  let x_11558 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_11565 : i32 = x_11558.x;
  let x_11574 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_11565), (x_5572 / x_11565)), 0i);
  let x_11651 : i32 = ((bitcast<i32>(x_11574[x_5585]) * 16i) + 7i);
  let x_11907 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_11912 : i32 = (x_11651 / 4i);
  let x_11914 : i32 = x_11907.x;
  let x_11923 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_11912 % x_11914), (x_11912 / x_11914)), 0i);
  let x_3784 : mat3x4<f32> = transpose(mat4x3<f32>(vec3<f32>(x_3709.x, x_3709.y, x_3702.x), vec3<f32>(x_3702.y, x_3723.x, x_3723.y), vec3<f32>(x_3733.x, x_3733.y, unpack2x16float(x_10045[(x_9831 % 4i)]).x), vec3<f32>(bitcast<f32>(x_10671[(x_10437 % 4i)]), bitcast<f32>(x_11297[(x_11045 % 4i)]), bitcast<f32>(x_11923[(x_11651 % 4i)]))));
  var x_25064_1 : mat3x4<f32> = x_3784;
  x_25064_1[0u].w = x_3784[0u].w;
  let x_25064 : mat3x4<f32> = x_25064_1;
  var x_25067_1 : mat3x4<f32> = x_25064;
  x_25067_1[1u].w = x_3784[1u].w;
  let x_25067 : mat3x4<f32> = x_25067_1;
  var x_25070_1 : mat3x4<f32> = x_25067;
  x_25070_1[2u].w = x_3784[2u].w;
  let x_25070 : mat3x4<f32> = x_25070_1;
  let x_3797 : vec3<f32> = Vertex_Position;
  let x_3803 : vec4<f32> = (vec4<f32>(x_3797.x, x_3797.y, x_3797.z, 1.0f) * x_3695);
  let x_12157 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_12164 : i32 = x_12157.x;
  let x_12173 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_12164), (x_5572 / x_12164)), 0i);
  let x_12306 : i32 = ((bitcast<i32>(x_12173[x_5585]) * 16i) + 15i);
  let x_12722 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_12727 : i32 = (x_12306 / 4i);
  let x_12729 : i32 = x_12722.x;
  let x_12738 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_12727 % x_12729), (x_12727 / x_12729)), 0i);
  let x_3812 : i32 = bitcast<i32>(x_12738[(x_12306 % 4i)]);
  if (((x_3812 & 32i) != 0i)) {
    let x_12756 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_12763 : i32 = x_12756.x;
    let x_12772 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_12763), (x_5572 / x_12763)), 0i);
    let x_12872 : i32 = ((bitcast<i32>(x_12772[x_5585]) * 16i) + 10i);
    let x_13186 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_13191 : i32 = (x_12872 / 4i);
    let x_13193 : i32 = x_13186.x;
    let x_13202 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_13191 % x_13193), (x_13191 / x_13193)), 0i);
    let x_3823 : vec2<f32> = unpack2x16float(x_13202[(x_12872 % 4i)]);
    let x_3839 : vec3<f32> = (vec3<f32>(x_3784[0u].z, x_3784[1u].z, x_3784[2u].z) * mix(x_3823.x, x_3823.y, (0.5f - x_3803.x)));
    var x_25087_1 : mat3x4<f32> = x_25070;
    x_25087_1[0u].z = x_3839.x;
    let x_25087 : mat3x4<f32> = x_25087_1;
    var x_25090_1 : mat3x4<f32> = x_25087;
    x_25090_1[1u].z = x_3839.y;
    let x_25090 : mat3x4<f32> = x_25090_1;
    x_25093 = x_25090;
    x_25093[2u].z = x_3839.z;
    x_24669 = x_25093;
  } else {
    x_24669 = x_25070;
  }
  if (x_3617) {
    x_3857 = (x_3812 | 4096i);
    x_24663 = x_3857;
  } else {
    x_24663 = x_3812;
  }
  if (((x_24663 & 4i) != 0i)) {
    let x_13355 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_13362 : i32 = x_13355.x;
    let x_13371 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_13362), (x_5572 / x_13362)), 0i);
    let x_13494 : i32 = ((bitcast<i32>(x_13371[x_5585]) * 16i) + 13i);
    let x_13866 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_13871 : i32 = (x_13494 / 4i);
    let x_13873 : i32 = x_13866.x;
    let x_13882 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_13871 % x_13873), (x_13871 / x_13873)), 0i);
    let x_13954 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_13961 : i32 = x_13954.x;
    let x_13970 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_13961), (x_5572 / x_13961)), 0i);
    let x_14093 : i32 = ((bitcast<i32>(x_13970[x_5585]) * 16i) + 13i);
    let x_14465 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_14470 : i32 = (x_14093 / 4i);
    let x_14472 : i32 = x_14465.x;
    let x_14481 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_14470 % x_14472), (x_14470 / x_14472)), 0i);
    let x_3878 : u32 = (x_13882[(x_13494 % 4i)] + (x_14481[(x_14093 % 4i)] << 10u));
    let x_3882 : u32 = (x_3878 ^ (x_3878 >> 6u));
    let x_3886 : u32 = (x_3882 + (x_3882 << 3u));
    let x_3890 : u32 = (x_3886 ^ (x_3886 >> 11u));
    let x_3900 : f32 = select(1.10000002384185791016f, 1.0f, ((bitcast<f32>((((x_3890 + (x_3890 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) > 0.89999997615814208984f));
    let x_3905 : bool = ((x_3812 & 1i) != 0i);
    x_3907 = select(vec3<f32>(x_3900, x_3900, 1.0f), vec3<f32>(1.04999995231628417969f, 1.04999995231628417969f, 1.04999995231628417969f), vec3<bool>(x_3905, x_3905, x_3905));
    x_25232 = x_3907;
  } else {
    x_25232 = vec3<f32>(1.0f, 1.0f, 1.0f);
  }
  let x_3941 : mat3x4<f32> = (mat4x4<f32>(vec4<f32>(x_25232.x, 0.0f, 0.0f, 0.0f), vec4<f32>(0.0f, x_25232.y, 0.0f, 0.0f), vec4<f32>(0.0f, 0.0f, x_25232.z, 0.0f), x_707) * x_24669);
  let x_3943 : f32 = x_3803.x;
  let x_3944 : f32 = x_3803.y;
  let x_3948 : vec3<f32> = (vec4<f32>(x_3943, x_3944, x_3803.z, 1.0f) * x_3941);
  let x_3952 : vec4<f32> = vec4<f32>(x_3948.x, x_3948.y, x_3948.z, 1.0f);
  let x_3954 : vec3<f32> = vec3<f32>(x_3952.x, x_3952.y, x_3952.z);
  let x_3956 : vec3<f32> = (x_3954 * 0.40000000596046447754f);
  let x_3959 : vec3<i32> = vec3<i32>(floor(x_3956));
  let x_3961 : vec3<f32> = fract(x_3956);
  let x_3963 : vec3<u32> = bitcast<vec3<u32>>(x_3959);
  let x_3965 : u32 = x_3963.z;
  let x_3969 : u32 = (x_3965 + (x_3965 << 10u));
  let x_3973 : u32 = (x_3969 ^ (x_3969 >> 6u));
  let x_3977 : u32 = (x_3973 + (x_3973 << 3u));
  let x_3981 : u32 = (x_3977 ^ (x_3977 >> 11u));
  let x_3991 : u32 = ((((x_3963.y * 1664525u) + (x_3981 + (x_3981 << 15u))) + 1013904223u) * 1664525u);
  let x_3995 : u32 = (x_3991 ^ (x_3991 >> 11u));
  let x_4000 : u32 = (x_3995 ^ ((x_3995 << 7u) & 2636928640u));
  let x_4005 : u32 = (x_4000 ^ ((x_4000 << 15u) & 4022730752u));
  let x_4015 : u32 = ((((x_3963.x * 1664525u) + (x_4005 ^ (x_4005 >> 18u))) + 1013904223u) * 1664525u);
  let x_4019 : u32 = (x_4015 ^ (x_4015 >> 11u));
  let x_4024 : u32 = (x_4019 ^ ((x_4019 << 7u) & 2636928640u));
  let x_4029 : u32 = (x_4024 ^ ((x_4024 << 15u) & 4022730752u));
  let x_4033 : u32 = (x_4029 ^ (x_4029 >> 18u));
  x_24674 = x_4033;
  x_24673 = 0u;
  loop {
    if ((x_24673 >= 2u)) {
      break;
    }
    let x_4045 : u32 = (x_24674 + (x_24674 << 10u));
    let x_4049 : u32 = (x_4045 ^ (x_4045 >> 6u));
    let x_4053 : u32 = (x_4049 + (x_4049 << 3u));
    let x_4057 : u32 = (x_4053 ^ (x_4053 >> 11u));
    x_3332[x_24673] = (bitcast<f32>(((x_24674 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24674 = (x_4057 + (x_4057 << 15u));
      x_24673 = (x_24673 + 1u);
    }
  }
  let x_4077 : vec3<u32> = bitcast<vec3<u32>>((x_3959 + vec3<i32>(1i, 0i, 0i)));
  let x_4079 : u32 = x_4077.z;
  let x_4083 : u32 = (x_4079 + (x_4079 << 10u));
  let x_4087 : u32 = (x_4083 ^ (x_4083 >> 6u));
  let x_4091 : u32 = (x_4087 + (x_4087 << 3u));
  let x_4095 : u32 = (x_4091 ^ (x_4091 >> 11u));
  let x_4105 : u32 = ((((x_4077.y * 1664525u) + (x_4095 + (x_4095 << 15u))) + 1013904223u) * 1664525u);
  let x_4109 : u32 = (x_4105 ^ (x_4105 >> 11u));
  let x_4114 : u32 = (x_4109 ^ ((x_4109 << 7u) & 2636928640u));
  let x_4119 : u32 = (x_4114 ^ ((x_4114 << 15u) & 4022730752u));
  let x_4129 : u32 = ((((x_4077.x * 1664525u) + (x_4119 ^ (x_4119 >> 18u))) + 1013904223u) * 1664525u);
  let x_4133 : u32 = (x_4129 ^ (x_4129 >> 11u));
  let x_4138 : u32 = (x_4133 ^ ((x_4133 << 7u) & 2636928640u));
  let x_4143 : u32 = (x_4138 ^ ((x_4138 << 15u) & 4022730752u));
  let x_4147 : u32 = (x_4143 ^ (x_4143 >> 18u));
  x_24677 = x_4147;
  x_24676 = 0u;
  loop {
    if ((x_24676 >= 2u)) {
      break;
    }
    let x_4159 : u32 = (x_24677 + (x_24677 << 10u));
    let x_4163 : u32 = (x_4159 ^ (x_4159 >> 6u));
    let x_4167 : u32 = (x_4163 + (x_4163 << 3u));
    let x_4171 : u32 = (x_4167 ^ (x_4167 >> 11u));
    x_3356[x_24676] = (bitcast<f32>(((x_24677 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24677 = (x_4171 + (x_4171 << 15u));
      x_24676 = (x_24676 + 1u);
    }
  }
  let x_4191 : vec3<u32> = bitcast<vec3<u32>>((x_3959 + vec3<i32>(0i, 1i, 0i)));
  let x_4193 : u32 = x_4191.z;
  let x_4197 : u32 = (x_4193 + (x_4193 << 10u));
  let x_4201 : u32 = (x_4197 ^ (x_4197 >> 6u));
  let x_4205 : u32 = (x_4201 + (x_4201 << 3u));
  let x_4209 : u32 = (x_4205 ^ (x_4205 >> 11u));
  let x_4219 : u32 = ((((x_4191.y * 1664525u) + (x_4209 + (x_4209 << 15u))) + 1013904223u) * 1664525u);
  let x_4223 : u32 = (x_4219 ^ (x_4219 >> 11u));
  let x_4228 : u32 = (x_4223 ^ ((x_4223 << 7u) & 2636928640u));
  let x_4233 : u32 = (x_4228 ^ ((x_4228 << 15u) & 4022730752u));
  let x_4243 : u32 = ((((x_4191.x * 1664525u) + (x_4233 ^ (x_4233 >> 18u))) + 1013904223u) * 1664525u);
  let x_4247 : u32 = (x_4243 ^ (x_4243 >> 11u));
  let x_4252 : u32 = (x_4247 ^ ((x_4247 << 7u) & 2636928640u));
  let x_4257 : u32 = (x_4252 ^ ((x_4252 << 15u) & 4022730752u));
  let x_4261 : u32 = (x_4257 ^ (x_4257 >> 18u));
  x_24680 = x_4261;
  x_24679 = 0u;
  loop {
    if ((x_24679 >= 2u)) {
      break;
    }
    let x_4273 : u32 = (x_24680 + (x_24680 << 10u));
    let x_4277 : u32 = (x_4273 ^ (x_4273 >> 6u));
    let x_4281 : u32 = (x_4277 + (x_4277 << 3u));
    let x_4285 : u32 = (x_4281 ^ (x_4281 >> 11u));
    x_3380[x_24679] = (bitcast<f32>(((x_24680 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24680 = (x_4285 + (x_4285 << 15u));
      x_24679 = (x_24679 + 1u);
    }
  }
  let x_4305 : vec3<u32> = bitcast<vec3<u32>>((x_3959 + vec3<i32>(1i, 1i, 0i)));
  let x_4307 : u32 = x_4305.z;
  let x_4311 : u32 = (x_4307 + (x_4307 << 10u));
  let x_4315 : u32 = (x_4311 ^ (x_4311 >> 6u));
  let x_4319 : u32 = (x_4315 + (x_4315 << 3u));
  let x_4323 : u32 = (x_4319 ^ (x_4319 >> 11u));
  let x_4333 : u32 = ((((x_4305.y * 1664525u) + (x_4323 + (x_4323 << 15u))) + 1013904223u) * 1664525u);
  let x_4337 : u32 = (x_4333 ^ (x_4333 >> 11u));
  let x_4342 : u32 = (x_4337 ^ ((x_4337 << 7u) & 2636928640u));
  let x_4347 : u32 = (x_4342 ^ ((x_4342 << 15u) & 4022730752u));
  let x_4357 : u32 = ((((x_4305.x * 1664525u) + (x_4347 ^ (x_4347 >> 18u))) + 1013904223u) * 1664525u);
  let x_4361 : u32 = (x_4357 ^ (x_4357 >> 11u));
  let x_4366 : u32 = (x_4361 ^ ((x_4361 << 7u) & 2636928640u));
  let x_4371 : u32 = (x_4366 ^ ((x_4366 << 15u) & 4022730752u));
  let x_4375 : u32 = (x_4371 ^ (x_4371 >> 18u));
  x_24683 = x_4375;
  x_24682 = 0u;
  loop {
    if ((x_24682 >= 2u)) {
      break;
    }
    let x_4387 : u32 = (x_24683 + (x_24683 << 10u));
    let x_4391 : u32 = (x_4387 ^ (x_4387 >> 6u));
    let x_4395 : u32 = (x_4391 + (x_4391 << 3u));
    let x_4399 : u32 = (x_4395 ^ (x_4395 >> 11u));
    x_3404[x_24682] = (bitcast<f32>(((x_24683 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24683 = (x_4399 + (x_4399 << 15u));
      x_24682 = (x_24682 + 1u);
    }
  }
  let x_4419 : vec3<u32> = bitcast<vec3<u32>>((x_3959 + vec3<i32>(0i, 0i, 1i)));
  let x_4421 : u32 = x_4419.z;
  let x_4425 : u32 = (x_4421 + (x_4421 << 10u));
  let x_4429 : u32 = (x_4425 ^ (x_4425 >> 6u));
  let x_4433 : u32 = (x_4429 + (x_4429 << 3u));
  let x_4437 : u32 = (x_4433 ^ (x_4433 >> 11u));
  let x_4447 : u32 = ((((x_4419.y * 1664525u) + (x_4437 + (x_4437 << 15u))) + 1013904223u) * 1664525u);
  let x_4451 : u32 = (x_4447 ^ (x_4447 >> 11u));
  let x_4456 : u32 = (x_4451 ^ ((x_4451 << 7u) & 2636928640u));
  let x_4461 : u32 = (x_4456 ^ ((x_4456 << 15u) & 4022730752u));
  let x_4471 : u32 = ((((x_4419.x * 1664525u) + (x_4461 ^ (x_4461 >> 18u))) + 1013904223u) * 1664525u);
  let x_4475 : u32 = (x_4471 ^ (x_4471 >> 11u));
  let x_4480 : u32 = (x_4475 ^ ((x_4475 << 7u) & 2636928640u));
  let x_4485 : u32 = (x_4480 ^ ((x_4480 << 15u) & 4022730752u));
  let x_4489 : u32 = (x_4485 ^ (x_4485 >> 18u));
  x_24686 = x_4489;
  x_24685 = 0u;
  loop {
    if ((x_24685 >= 2u)) {
      break;
    }
    let x_4501 : u32 = (x_24686 + (x_24686 << 10u));
    let x_4505 : u32 = (x_4501 ^ (x_4501 >> 6u));
    let x_4509 : u32 = (x_4505 + (x_4505 << 3u));
    let x_4513 : u32 = (x_4509 ^ (x_4509 >> 11u));
    x_3428[x_24685] = (bitcast<f32>(((x_24686 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24686 = (x_4513 + (x_4513 << 15u));
      x_24685 = (x_24685 + 1u);
    }
  }
  let x_4533 : vec3<u32> = bitcast<vec3<u32>>((x_3959 + vec3<i32>(1i, 0i, 1i)));
  let x_4535 : u32 = x_4533.z;
  let x_4539 : u32 = (x_4535 + (x_4535 << 10u));
  let x_4543 : u32 = (x_4539 ^ (x_4539 >> 6u));
  let x_4547 : u32 = (x_4543 + (x_4543 << 3u));
  let x_4551 : u32 = (x_4547 ^ (x_4547 >> 11u));
  let x_4561 : u32 = ((((x_4533.y * 1664525u) + (x_4551 + (x_4551 << 15u))) + 1013904223u) * 1664525u);
  let x_4565 : u32 = (x_4561 ^ (x_4561 >> 11u));
  let x_4570 : u32 = (x_4565 ^ ((x_4565 << 7u) & 2636928640u));
  let x_4575 : u32 = (x_4570 ^ ((x_4570 << 15u) & 4022730752u));
  let x_4585 : u32 = ((((x_4533.x * 1664525u) + (x_4575 ^ (x_4575 >> 18u))) + 1013904223u) * 1664525u);
  let x_4589 : u32 = (x_4585 ^ (x_4585 >> 11u));
  let x_4594 : u32 = (x_4589 ^ ((x_4589 << 7u) & 2636928640u));
  let x_4599 : u32 = (x_4594 ^ ((x_4594 << 15u) & 4022730752u));
  let x_4603 : u32 = (x_4599 ^ (x_4599 >> 18u));
  x_24689 = x_4603;
  x_24688 = 0u;
  loop {
    if ((x_24688 >= 2u)) {
      break;
    }
    let x_4615 : u32 = (x_24689 + (x_24689 << 10u));
    let x_4619 : u32 = (x_4615 ^ (x_4615 >> 6u));
    let x_4623 : u32 = (x_4619 + (x_4619 << 3u));
    let x_4627 : u32 = (x_4623 ^ (x_4623 >> 11u));
    x_3452[x_24688] = (bitcast<f32>(((x_24689 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24689 = (x_4627 + (x_4627 << 15u));
      x_24688 = (x_24688 + 1u);
    }
  }
  let x_4647 : vec3<u32> = bitcast<vec3<u32>>((x_3959 + vec3<i32>(0i, 1i, 1i)));
  let x_4649 : u32 = x_4647.z;
  let x_4653 : u32 = (x_4649 + (x_4649 << 10u));
  let x_4657 : u32 = (x_4653 ^ (x_4653 >> 6u));
  let x_4661 : u32 = (x_4657 + (x_4657 << 3u));
  let x_4665 : u32 = (x_4661 ^ (x_4661 >> 11u));
  let x_4675 : u32 = ((((x_4647.y * 1664525u) + (x_4665 + (x_4665 << 15u))) + 1013904223u) * 1664525u);
  let x_4679 : u32 = (x_4675 ^ (x_4675 >> 11u));
  let x_4684 : u32 = (x_4679 ^ ((x_4679 << 7u) & 2636928640u));
  let x_4689 : u32 = (x_4684 ^ ((x_4684 << 15u) & 4022730752u));
  let x_4699 : u32 = ((((x_4647.x * 1664525u) + (x_4689 ^ (x_4689 >> 18u))) + 1013904223u) * 1664525u);
  let x_4703 : u32 = (x_4699 ^ (x_4699 >> 11u));
  let x_4708 : u32 = (x_4703 ^ ((x_4703 << 7u) & 2636928640u));
  let x_4713 : u32 = (x_4708 ^ ((x_4708 << 15u) & 4022730752u));
  let x_4717 : u32 = (x_4713 ^ (x_4713 >> 18u));
  x_24692 = x_4717;
  x_24691 = 0u;
  loop {
    if ((x_24691 >= 2u)) {
      break;
    }
    let x_4729 : u32 = (x_24692 + (x_24692 << 10u));
    let x_4733 : u32 = (x_4729 ^ (x_4729 >> 6u));
    let x_4737 : u32 = (x_4733 + (x_4733 << 3u));
    let x_4741 : u32 = (x_4737 ^ (x_4737 >> 11u));
    x_3476[x_24691] = (bitcast<f32>(((x_24692 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24692 = (x_4741 + (x_4741 << 15u));
      x_24691 = (x_24691 + 1u);
    }
  }
  let x_4761 : vec3<u32> = bitcast<vec3<u32>>((x_3959 + vec3<i32>(1i, 1i, 1i)));
  let x_4763 : u32 = x_4761.z;
  let x_4767 : u32 = (x_4763 + (x_4763 << 10u));
  let x_4771 : u32 = (x_4767 ^ (x_4767 >> 6u));
  let x_4775 : u32 = (x_4771 + (x_4771 << 3u));
  let x_4779 : u32 = (x_4775 ^ (x_4775 >> 11u));
  let x_4789 : u32 = ((((x_4761.y * 1664525u) + (x_4779 + (x_4779 << 15u))) + 1013904223u) * 1664525u);
  let x_4793 : u32 = (x_4789 ^ (x_4789 >> 11u));
  let x_4798 : u32 = (x_4793 ^ ((x_4793 << 7u) & 2636928640u));
  let x_4803 : u32 = (x_4798 ^ ((x_4798 << 15u) & 4022730752u));
  let x_4813 : u32 = ((((x_4761.x * 1664525u) + (x_4803 ^ (x_4803 >> 18u))) + 1013904223u) * 1664525u);
  let x_4817 : u32 = (x_4813 ^ (x_4813 >> 11u));
  let x_4822 : u32 = (x_4817 ^ ((x_4817 << 7u) & 2636928640u));
  let x_4827 : u32 = (x_4822 ^ ((x_4822 << 15u) & 4022730752u));
  let x_4831 : u32 = (x_4827 ^ (x_4827 >> 18u));
  x_24695 = x_4831;
  x_24694 = 0u;
  loop {
    if ((x_24694 >= 2u)) {
      break;
    }
    let x_4843 : u32 = (x_24695 + (x_24695 << 10u));
    let x_4847 : u32 = (x_4843 ^ (x_4843 >> 6u));
    let x_4851 : u32 = (x_4847 + (x_4847 << 3u));
    let x_4855 : u32 = (x_4851 ^ (x_4851 >> 11u));
    x_3500[x_24694] = (bitcast<f32>(((x_24695 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24695 = (x_4855 + (x_4855 << 15u));
      x_24694 = (x_24694 + 1u);
    }
  }
  let x_4879 : vec3<f32> = ((x_3961 * x_3961) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_3961)));
  let x_4881 : f32 = x_4879.x;
  let x_4883 : f32 = (1.0f - x_4881);
  let x_4885 : f32 = x_4879.y;
  let x_4887 : f32 = (1.0f - x_4885);
  let x_4889 : f32 = x_4879.z;
  let x_4891 : f32 = (1.0f - x_4889);
  let x_4892 : vec2<f32> = x_3332;
  let x_4899 : vec2<f32> = x_3356;
  let x_4907 : vec2<f32> = x_3380;
  let x_4915 : vec2<f32> = x_3404;
  let x_4923 : vec2<f32> = x_3428;
  let x_4931 : vec2<f32> = x_3452;
  let x_4939 : vec2<f32> = x_3476;
  let x_4947 : vec2<f32> = x_3500;
  let x_4957 : vec2<f32> = clamp(((((((((((((x_4892 * x_4883) * x_4887) * x_4891) + (((x_4899 * x_4881) * x_4887) * x_4891)) + (((x_4907 * x_4883) * x_4885) * x_4891)) + (((x_4915 * x_4881) * x_4885) * x_4891)) + (((x_4923 * x_4883) * x_4887) * x_4889)) + (((x_4931 * x_4881) * x_4887) * x_4889)) + (((x_4939 * x_4883) * x_4885) * x_4889)) + (((x_4947 * x_4881) * x_4885) * x_4889)) - x_2297) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_2297);
  let x_4965 : vec3<f32> = (x_3954 + (vec3<f32>(x_4957.x, 0.0f, x_4957.y) * 0.05999999865889549255f));
  var x_25136_1 : vec4<f32> = x_3952;
  x_25136_1.x = x_4965.x;
  let x_25136 : vec4<f32> = x_25136_1;
  var x_25139_1 : vec4<f32> = x_25136;
  x_25139_1.z = x_4965.z;
  let x_25139 : vec4<f32> = x_25139_1;
  let x_4974 : vec3<f32> = (x_707 * x_3941);
  let x_4977 : f32 = (x_3943 - -0.5f);
  let x_4996 : f32 = (x_4965.y + mix(mix(x_3630.x, x_3630.y, x_4977), mix(x_3637.x, x_3637.y, x_4977), (x_3944 - -0.5f)));
  var x_25148_1 : vec4<f32> = x_25139;
  x_25148_1.y = x_4996;
  let x_25148 : vec4<f32> = x_25148_1;
  let x_14553 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_14560 : i32 = x_14553.x;
  let x_14569 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_14560), (x_5572 / x_14560)), 0i);
  let x_14678 : i32 = ((bitcast<i32>(x_14569[x_5585]) * 16i) + 11i);
  let x_15010 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_15015 : i32 = (x_14678 / 4i);
  let x_15017 : i32 = x_15010.x;
  let x_15026 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_15015 % x_15017), (x_15015 / x_15017)), 0i);
  let x_5005 : vec2<f32> = unpack2x16float(x_15026[(x_14678 % 4i)]);
  let x_5007 : f32 = x_5005.y;
  let x_5009 : vec4<f32> = x_3941[0u];
  let x_5012 : vec4<f32> = x_3941[1u];
  let x_5015 : vec4<f32> = x_3941[2u];
  let x_5029 : mat3x3<f32> = mat3x3<f32>(vec3<f32>(x_5009.x, x_5009.y, x_5009.z), vec3<f32>(x_5012.x, x_5012.y, x_5012.z), vec3<f32>(x_5015.x, x_5015.y, x_5015.z));
  let x_5031 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_5029);
  let x_5033 : vec3<f32> = (vec3<f32>(0.0f, 1.0f, 0.0f) * x_5029);
  let x_5035 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_5029);
  let x_5038 : vec3<f32> = cross(x_5031, x_5033);
  let x_5042 : f32 = (1.0f / dot(x_5035, x_5038));
  let x_5043 : vec3<f32> = vec3<f32>(x_5042, x_5042, x_5042);
  let x_15152 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_15159 : i32 = x_15152.x;
  let x_15168 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_15159), (x_5572 / x_15159)), 0i);
  let x_15291 : i32 = ((bitcast<i32>(x_15168[x_5585]) * 16i) + 13i);
  let x_15663 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_15668 : i32 = (x_15291 / 4i);
  let x_15670 : i32 = x_15663.x;
  let x_15679 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_15668 % x_15670), (x_15668 / x_15670)), 0i);
  let x_5077 : u32 = (x_15679[(x_15291 % 4i)] & 65535u);
  let x_5078 : vec3<f32> = Vertex_Normal;
  let x_5084 : vec4<f32> = (vec4<f32>(x_5078.x, x_5078.y, x_5078.z, 0.0f) * x_3695);
  let x_5087 : vec3<f32> = (vec3<f32>(x_5084.x, x_5084.y, x_5084.z) * transpose(mat3x3<f32>((cross(x_5033, x_5035) * x_5043), (cross(x_5035, x_5031) * x_5043), (x_5038 * x_5043))));
  let x_5088 : i32 = is_bevel;
  let x_5089 : bool = (x_5088 != 0i);
  if (x_5089) {
    x_5093 = (x_24663 | 256i);
    x_24750 = x_5093;
  } else {
    x_24750 = x_24663;
  }
  let x_15751 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_15758 : i32 = x_15751.x;
  let x_15767 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_15758), (x_5572 / x_15758)), 0i);
  let x_15890 : i32 = ((bitcast<i32>(x_15767[x_5585]) * 16i) + 13i);
  let x_16262 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_16267 : i32 = (x_15890 / 4i);
  let x_16269 : i32 = x_16262.x;
  let x_16278 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_16267 % x_16269), (x_16267 / x_16269)), 0i);
  if ((x_16278[(x_15890 % 4i)] < 10u)) {
    x_5106 = (x_24750 | 512i);
    x_24809 = x_5106;
  } else {
    x_24809 = x_24750;
  }
  let x_16350 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_16357 : i32 = x_16350.x;
  let x_16366 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_16357), (x_5572 / x_16357)), 0i);
  let x_16466 : i32 = ((bitcast<i32>(x_16366[x_5585]) * 16i) + 10i);
  let x_16780 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_16785 : i32 = (x_16466 / 4i);
  let x_16787 : i32 = x_16780.x;
  let x_16796 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_16785 % x_16787), (x_16785 / x_16787)), 0i);
  let x_5155 : vec2<f32> = unpack2x16float(x_16796[(x_16466 % 4i)]);
  if ((x_4977 < 0.5f)) {
    x_5165 = mix(x_5155.x, x_5155.y, (x_4977 * 2.0f));
    x_24970 = x_5165;
  } else {
    x_5174 = mix(x_5155.y, x_5005.x, ((x_4977 * 2.0f) - 1.0f));
    x_24970 = x_5174;
  }
  var x_5205 : bool;
  var x_24828 : bool;
  var x_5211 : i32;
  var x_5237 : i32;
  var x_5262 : i32;
  let x_16949 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_16956 : i32 = x_16949.x;
  let x_16965 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_16956), (x_5572 / x_16956)), 0i);
  let x_17093 : i32 = ((bitcast<i32>(x_16965[x_5585]) * 16i) + 14i);
  let x_17487 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_17492 : i32 = (x_17093 / 4i);
  let x_17494 : i32 = x_17487.x;
  let x_17503 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_17492 % x_17494), (x_17492 / x_17494)), 0i);
  let x_5183 : bool = ((x_17503[(x_17093 % 4i)] & 2147483648u) != 0u);
  if (x_5183) {
    let x_17548 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_17555 : i32 = x_17548.x;
    let x_17564 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_17555), (x_5572 / x_17555)), 0i);
    let x_17692 : i32 = ((bitcast<i32>(x_17564[x_5585]) * 16i) + 14i);
    let x_18086 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_18091 : i32 = (x_17692 / 4i);
    let x_18093 : i32 = x_18086.x;
    let x_18102 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_18091 % x_18093), (x_18091 / x_18093)), 0i);
    if (((x_18102[(x_17692 % 4i)] & 1073741824u) != 0u)) {
      let x_18147 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
      let x_18154 : i32 = x_18147.x;
      let x_18163 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_18154), (x_5572 / x_18154)), 0i);
      let x_18291 : i32 = ((bitcast<i32>(x_18163[x_5585]) * 16i) + 14i);
      let x_18685 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_18690 : i32 = (x_18291 / 4i);
      let x_18692 : i32 = x_18685.x;
      let x_18701 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_18690 % x_18692), (x_18690 / x_18692)), 0i);
      x_5205 = (((x_18701[(x_18291 % 4i)] >> 4u) & 65535u) == x_3241);
      x_24828 = x_5205;
    } else {
      x_24828 = false;
    }
    if (x_24828) {
      x_5211 = (x_24809 | 2048i);
      x_24832 = x_5211;
    } else {
      x_24832 = x_24809;
    }
    let x_18746 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_18753 : i32 = x_18746.x;
    let x_18762 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_18753), (x_5572 / x_18753)), 0i);
    let x_18890 : i32 = ((bitcast<i32>(x_18762[x_5585]) * 16i) + 14i);
    let x_19284 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_19289 : i32 = (x_18890 / 4i);
    let x_19291 : i32 = x_19284.x;
    let x_19300 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_19289 % x_19291), (x_19289 / x_19291)), 0i);
    x_5222 = bitcast<i32>((x_19300[(x_18890 % 4i)] & 15u));
    x_24981 = x_5222;
    x_24882 = x_24832;
  } else {
    var x_20596 : u32;
    var x_21229 : u32;
    var x_24810 : u32;
    if (((x_24809 & 8192i) != 0i)) {
      let x_19345 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
      let x_19352 : i32 = x_19345.x;
      let x_19361 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_19352), (x_5572 / x_19352)), 0i);
      let x_19489 : i32 = ((bitcast<i32>(x_19361[x_5585]) * 16i) + 14i);
      let x_19883 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_19888 : i32 = (x_19489 / 4i);
      let x_19890 : i32 = x_19883.x;
      let x_19899 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_19888 % x_19890), (x_19888 / x_19890)), 0i);
      let x_5235 : i32 = bitcast<i32>(x_19899[(x_19489 % 4i)]);
      let x_19944 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
      let x_19949 : i32 = (x_5235 / 4i);
      let x_19951 : i32 = x_19944.x;
      let x_19960 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_19949 % x_19951), (x_19949 / x_19951)), 0i);
      x_5237 = bitcast<i32>(x_19960[(x_5235 % 4i)]);
      x_24811 = x_5237;
    } else {
      if (((x_24809 & 2i) != 0i)) {
        let x_19978 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
        let x_19985 : i32 = x_19978.x;
        let x_19994 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_19985), (x_5572 / x_19985)), 0i);
        let x_20122 : i32 = ((bitcast<i32>(x_19994[x_5585]) * 16i) + 14i);
        let x_20516 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_20521 : i32 = (x_20122 / 4i);
        let x_20523 : i32 = x_20516.x;
        let x_20532 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_20521 % x_20523), (x_20521 / x_20523)), 0i);
        let x_5249 : i32 = bitcast<i32>(x_20532[(x_20122 % 4i)]);
        let x_20577 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
        let x_20582 : i32 = (x_5249 / 4i);
        let x_20584 : i32 = x_20577.x;
        let x_20593 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_20582 % x_20584), (x_20582 / x_20584)), 0i);
        x_20596 = x_20593[(x_5249 % 4i)];
        x_24810 = x_20596;
      } else {
        let x_20611 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
        let x_20618 : i32 = x_20611.x;
        let x_20627 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_20618), (x_5572 / x_20618)), 0i);
        let x_20755 : i32 = ((bitcast<i32>(x_20627[x_5585]) * 16i) + 14i);
        let x_21149 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_21154 : i32 = (x_20755 / 4i);
        let x_21156 : i32 = x_21149.x;
        let x_21165 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_21154 % x_21156), (x_21154 / x_21156)), 0i);
        let x_5258 : i32 = bitcast<i32>(x_21165[(x_20755 % 4i)]);
        let x_21210 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
        let x_21215 : i32 = (x_5258 / 4i);
        let x_21217 : i32 = x_21210.x;
        let x_21226 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_21215 % x_21217), (x_21215 / x_21217)), 0i);
        x_21229 = x_21226[(x_5258 % 4i)];
        x_24810 = x_21229;
      }
      x_5262 = bitcast<i32>(x_24810);
      x_24811 = x_5262;
    }
    x_24981 = x_24811;
    x_24882 = x_24809;
  }
  if (x_5183) {
    let x_21244 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_21251 : i32 = x_21244.x;
    let x_21260 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_21251), (x_5572 / x_21251)), 0i);
    let x_21388 : i32 = ((bitcast<i32>(x_21260[x_5585]) * 16i) + 14i);
    let x_21782 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_21787 : i32 = (x_21388 / 4i);
    let x_21789 : i32 = x_21782.x;
    let x_21798 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_21787 % x_21789), (x_21787 / x_21789)), 0i);
    x_21801 = x_21798[(x_21388 % 4i)];
    x_24841 = x_21801;
  } else {
    let x_21843 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_21850 : i32 = x_21843.x;
    let x_21859 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_21850), (x_5572 / x_21850)), 0i);
    let x_21987 : i32 = ((bitcast<i32>(x_21859[x_5585]) * 16i) + 14i);
    let x_22381 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_22386 : i32 = (x_21987 / 4i);
    let x_22388 : i32 = x_22381.x;
    let x_22397 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_22386 % x_22388), (x_22386 / x_22388)), 0i);
    let x_5282 : i32 = bitcast<i32>(x_22397[(x_21987 % 4i)]);
    let x_22442 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_10_0, 0i));
    let x_22447 : i32 = (x_5282 / 4i);
    let x_22449 : i32 = x_22442.x;
    let x_22458 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_10_0, vec2<i32>((x_22447 % x_22449), (x_22447 / x_22449)), 0i);
    x_22461 = x_22458[(x_5282 % 4i)];
    x_24841 = x_22461;
  }
  let x_5286 : u32 = (x_24841 & 65535u);
  let x_5288 : u32 = (x_5286 ^ 7993234u);
  let x_5292 : u32 = (x_5288 + (x_5288 << 10u));
  let x_5296 : u32 = (x_5292 ^ (x_5292 >> 6u));
  let x_5300 : u32 = (x_5296 + (x_5296 << 3u));
  let x_5304 : u32 = (x_5300 ^ (x_5300 >> 11u));
  let x_5306 : u32 = (x_5286 ^ 3450234u);
  let x_5310 : u32 = (x_5306 + (x_5306 << 10u));
  let x_5314 : u32 = (x_5310 ^ (x_5310 >> 6u));
  let x_5318 : u32 = (x_5314 + (x_5314 << 3u));
  let x_5322 : u32 = (x_5318 ^ (x_5318 >> 11u));
  let x_22476 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
  let x_22483 : i32 = x_22476.x;
  let x_22492 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_22483), (x_5572 / x_22483)), 0i);
  let x_22608 : i32 = ((bitcast<i32>(x_22492[x_5585]) * 16i) + 12i);
  let x_22960 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_22965 : i32 = (x_22608 / 4i);
  let x_22967 : i32 = x_22960.x;
  let x_22976 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_22965 % x_22967), (x_22965 / x_22967)), 0i);
  let x_5344 : f32 = (f32(x_5286) * 0.20000000298023223877f);
  let x_5364 : vec2<f32> = ((((vec2<f32>(mix(x_5007, unpack2x16float(x_22976[(x_22608 % 4i)]).x, x_4977), select(x_4996, 0.0f, ((x_24809 & 1024i) != 0i))) * 0.10000000149011611938f) * 0.69999998807907104492f) + vec2<f32>(x_5344, x_5344)) + vec2<f32>((bitcast<f32>((((x_5304 + (x_5304 << 15u)) & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_5322 + (x_5322 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
  let x_5366 : u32 = (x_5077 ^ 292478890u);
  let x_5370 : u32 = (x_5366 + (x_5366 << 10u));
  let x_5374 : u32 = (x_5370 ^ (x_5370 >> 6u));
  let x_5378 : u32 = (x_5374 + (x_5374 << 3u));
  let x_5382 : u32 = (x_5378 ^ (x_5378 >> 11u));
  let x_5390 : f32 = (bitcast<f32>((((x_5382 + (x_5382 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
  if ((x_5390 > 0.89999997615814208984f)) {
    x_5395 = (x_5364 * 3.0f);
    x_24883 = x_5395;
  } else {
    let x_5399 : f32 = (0.61000001430511474609f * x_5390);
    x_5401 = (x_5364 + vec2<f32>(x_5399, x_5399));
    x_24883 = x_5401;
  }
  if (((x_24882 & 512i) != 0i)) {
    x_5410 = (x_24883 * 2.20000004768371582031f);
    x_24886 = x_5410;
  } else {
    x_24886 = x_24883;
  }
  var x_5425 : vec2<f32>;
  var x_24887 : vec2<f32>;
  var x_24901 : vec2<f32>;
  var x_5445 : vec2<f32>;
  var x_24911 : vec2<f32>;
  let x_5416 : bool = ((x_24809 & 32i) != 0i);
  if (x_5416) {
    var x_5434 : vec2<f32>;
    var x_5438 : vec2<f32>;
    if ((x_5087.y > 0.89999997615814208984f)) {
      x_5425 = (vec2<f32>(x_25148.x, x_25148.z) * 0.69999998807907104492f);
      x_24901 = x_5425;
    } else {
      if ((abs(x_5087.x) > 0.89999997615814208984f)) {
        x_5434 = (vec2<f32>(x_25148.z, x_25148.y) * 0.69999998807907104492f);
        x_24887 = x_5434;
      } else {
        x_5438 = (vec2<f32>(x_25148.x, x_25148.y) * 0.69999998807907104492f);
        x_24887 = x_5438;
      }
      x_24901 = x_24887;
    }
    if (x_5089) {
      x_5445 = vec2<f32>(x_5007, x_5007);
      x_24911 = x_5445;
    } else {
      x_24911 = x_24901;
    }
    let x_23075 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_23082 : i32 = x_23075.x;
    let x_23091 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_23082), (x_5572 / x_23082)), 0i);
    let x_23214 : i32 = ((bitcast<i32>(x_23091[x_5585]) * 16i) + 13i);
    let x_23586 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_23591 : i32 = (x_23214 / 4i);
    let x_23593 : i32 = x_23586.x;
    let x_23602 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_23591 % x_23593), (x_23591 / x_23593)), 0i);
    let x_23674 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_2, 0i));
    let x_23681 : i32 = x_23674.x;
    let x_23690 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_2, vec2<i32>((x_5572 % x_23681), (x_5572 / x_23681)), 0i);
    let x_23813 : i32 = ((bitcast<i32>(x_23690[x_5585]) * 16i) + 13i);
    let x_24185 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_24190 : i32 = (x_23813 / 4i);
    let x_24192 : i32 = x_24185.x;
    let x_24201 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_24190 % x_24192), (x_24190 / x_24192)), 0i);
    let x_5462 : u32 = (x_23602[(x_23214 % 4i)] + (x_24201[(x_23813 % 4i)] << 10u));
    let x_5466 : u32 = (x_5462 ^ (x_5462 >> 6u));
    let x_5470 : u32 = (x_5466 + (x_5466 << 3u));
    let x_5474 : u32 = (x_5470 ^ (x_5470 >> 11u));
    let x_5484 : f32 = (bitcast<f32>((((x_5474 + (x_5474 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
    x_5486 = ((x_24911 * 0.30000001192092895508f) + vec2<f32>(x_5484, x_5484));
    x_24974 = x_5486;
  } else {
    x_24974 = x_24886;
  }
  let x_5491 : mat4x4<f32> = x_2969.renderer_MVPMat;
  gl_Position = (x_5491 * x_25148);
  v0 = x_5077;
  v1 = x_5087;
  v2 = vec3<f32>(x_25148.x, x_25148.y, x_25148.z);
  v7 = select(x_24970, -100.0f, x_5416);
  v8 = -100000.0f;
  v9 = x_24974;
  v10 = x_24981;
  let x_5518 : vec4<f32> = vec4<f32>(x_4974.x, 0.0f, x_4974.z, 1.0f);
  v11 = vec2<f32>(x_5518.x, x_5518.z);
  v12 = x_24882;
  let x_3073 : f32 = gl_Position.z;
  let x_3075 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_3073 + x_3075));
  return;
}

struct main_out {
  @builtin(position)
  gl_Position : vec4<f32>,
  @location(0) @interpolate(flat)
  v0_1 : u32,
  @location(1)
  v1_1 : vec3<f32>,
  @location(2)
  v2_1 : vec3<f32>,
  @location(3)
  v7_1 : f32,
  @location(4) @interpolate(flat)
  v8_1 : f32,
  @location(5)
  v9_1 : vec2<f32>,
  @location(6) @interpolate(flat)
  v10_1 : i32,
  @location(7) @interpolate(flat)
  v11_1 : vec2<f32>,
  @location(8) @interpolate(flat)
  v12_1 : i32,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @location(0) Vertex_Position_param : vec3<f32>, @location(1) Vertex_Normal_param : vec3<f32>, @location(2) @interpolate(flat) is_bevel_param : i32) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  Vertex_Position = Vertex_Position_param;
  Vertex_Normal = Vertex_Normal_param;
  is_bevel = is_bevel_param;
  main_1();
  return main_out(gl_Position, v0, v1, v2, v7, v8, v9, v10, v11, v12);
}
