diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

struct gs_Auto_1 {
  /* @offset(0) */
  renderer_DormerGrid : vec4<f32>,
}

@binding(4) @group(3) var gs_wgpu_tex_storage_0_1 : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_storage_0_1 : sampler;

@binding(4) @group(2) var gs_wgpu_tex_material_data_brick_sdf_normal : texture_cube<f32>;

@binding(5) @group(2) var gs_wgpu_samp_material_data_brick_sdf_normal : sampler;

@binding(2) @group(2) var gs_wgpu_tex_material_data_brick_sdf : texture_2d_array<f32>;

@binding(3) @group(2) var gs_wgpu_samp_material_data_brick_sdf : sampler;

@binding(6) @group(3) var gs_wgpu_tex_uniform_ViewConstants_natural : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_uniform_ViewConstants_natural : sampler;

@binding(18) @group(3) var gs_wgpu_tex_uniform_ColorLibraryData_natural : texture_2d<u32>;

@binding(19) @group(3) var gs_wgpu_samp_uniform_ColorLibraryData_natural : sampler;

@binding(8) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

var<private> v2 : vec3<f32>;

var<private> v8 : f32;

var<private> v12 : i32;

var<private> v3 : vec3<f32>;

var<private> v4 : vec3<f32>;

var<private> v5 : f32;

@binding(0) @group(2) var<uniform> x_1080 : gs_Auto_0;

var<private> v7 : f32;

var<private> v10 : i32;

@binding(20) @group(3) var gs_wgpu_tex_roof_colors_tex : texture_2d_array<f32>;

@binding(21) @group(3) var gs_wgpu_samp_roof_colors_tex : sampler;

var<private> v0 : u32;

var<private> v13 : u32;

var<private> v9 : vec2<f32>;

@binding(22) @group(3) var gs_wgpu_tex_wall_color_data_brick_colors : texture_2d_array<f32>;

@binding(23) @group(3) var gs_wgpu_samp_wall_color_data_brick_colors : sampler;

var<private> v11 : vec2<f32>;

var<private> gl_FragDepth : f32;

var<private> gl_FragCoord : vec4<f32>;

@binding(28) @group(3) var gs_wgpu_tex_domain_holes : texture_2d<u32>;

@binding(29) @group(3) var gs_wgpu_samp_domain_holes : sampler;

@binding(24) @group(3) var gs_wgpu_tex_domain_roof : texture_2d<u32>;

@binding(25) @group(3) var gs_wgpu_samp_domain_roof : sampler;

@binding(1) @group(2) var<uniform> x_2182 : gs_Auto_1;

@binding(26) @group(3) var gs_wgpu_tex_domain_counts : texture_2d<u32>;

@binding(27) @group(3) var gs_wgpu_samp_domain_counts : sampler;

@binding(30) @group(3) var gs_wgpu_tex_cell_clip : texture_2d<u32>;

@binding(31) @group(3) var gs_wgpu_samp_cell_clip : sampler;

var<private> resident_cell_id : u32;

var<private> residentColor : vec4<f32>;

var<private> v14_col0 : vec3<f32>;

var<private> v14_col1 : vec3<f32>;

var<private> v14_col2 : vec3<f32>;

const x_888 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_7659 = vec4<f32>(128.0f, 128.0f, 128.0f, 128.0f);

const x_7666 = vec4<f32>(0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f);

const x_1297 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_1452 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_1612 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_7670 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_1763 = vec3<f32>(289.0f, 289.0f, 289.0f);

const x_2034 = vec3<f32>(0.0f, 1.0f, 0.0f);

fn main_1() {
  var x_4103 : bool;
  var x_4105 : bool;
  var x_4157 : vec2<f32>;
  var x_4159 : vec2<f32>;
  var x_4161 : vec2<f32>;
  var x_4169 : f32;
  var x_4175 : f32;
  var x_6919 : f32;
  var x_6917 : vec2<f32>;
  var x_6915 : f32;
  var x_6913 : vec2<f32>;
  var x_6911 : vec2<f32>;
  var x_6909 : f32;
  var x_6918 : f32;
  var x_6916 : vec2<f32>;
  var x_6914 : f32;
  var x_6912 : vec2<f32>;
  var x_6910 : vec2<f32>;
  var x_6908 : f32;
  var x_3107 : bool;
  var x_3109 : bool;
  var x_3114 : bool;
  var x_3116 : bool;
  var x_3170 : bool;
  var x_6951 : bool;
  var x_3178 : bool;
  var x_6952 : bool;
  var x_3557 : vec3<f32>;
  var x_7139 : vec3<f32>;
  var x_7166 : vec3<f32>;
  var x_7326 : vec3<f32>;
  var x_3619 : bool;
  var x_7458 : bool;
  var x_7367 : vec3<f32>;
  var x_3627 : vec3<f32>;
  var x_7411 : vec3<f32>;
  var x_3805 : vec3<f32>;
  var x_7453 : vec3<f32>;
  var x_7515 : bool;
  var x_7514 : bool;
  var x_7587 : bool;
  var x_7586 : bool;
  let x_2509 : vec3<f32> = v14_col0;
  let x_2511 : vec3<f32> = v14_col1;
  let x_2513 : vec3<f32> = v14_col2;
  let x_2583 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_2588 : i32 = x_2583.x;
  let x_2595 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((20i % x_2588), (20i / x_2588)), 0i);
  let x_2607 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((21i % x_2588), (21i / x_2588)), 0i);
  let x_2619 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((22i % x_2588), (22i / x_2588)), 0i);
  let x_2631 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((23i % x_2588), (23i / x_2588)), 0i);
  let x_2643 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_2588), (63i / x_2588)), 0i);
  let x_2696 : mat4x4<f32> = mat4x4<f32>(vec4<f32>(bitcast<f32>(x_2595.x), bitcast<f32>(x_2607.x), bitcast<f32>(x_2619.x), bitcast<f32>(x_2631.x)), vec4<f32>(bitcast<f32>(x_2595.y), bitcast<f32>(x_2607.y), bitcast<f32>(x_2619.y), bitcast<f32>(x_2631.y)), vec4<f32>(bitcast<f32>(x_2595.z), bitcast<f32>(x_2607.z), bitcast<f32>(x_2619.z), bitcast<f32>(x_2631.z)), vec4<f32>(bitcast<f32>(x_2595.w), bitcast<f32>(x_2607.w), bitcast<f32>(x_2619.w), bitcast<f32>(x_2631.w)));
  let x_2700 : f32 = bitcast<f32>(x_2643.w);
  let x_2711 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ColorLibraryData_natural, 0i));
  let x_2716 : i32 = x_2711.x;
  let x_2723 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((28i % x_2716), (28i / x_2716)), 0i);
  let x_2735 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((30i % x_2716), (30i / x_2716)), 0i);
  let x_2747 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((31i % x_2716), (31i / x_2716)), 0i);
  let x_2760 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2723.x), bitcast<f32>(x_2723.y), bitcast<f32>(x_2723.z), 0.0f);
  let x_2774 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2735.x), bitcast<f32>(x_2735.y), bitcast<f32>(x_2735.z), 0.0f);
  let x_2788 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2747.x), bitcast<f32>(x_2747.y), bitcast<f32>(x_2747.z), 0.0f);
  let x_2800 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_2805 : i32 = x_2800.x;
  let x_2812 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_2805), (8i / x_2805)), 0i);
  let x_2824 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_2805), (17i / x_2805)), 0i);
  let x_2836 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_2805), (18i / x_2805)), 0i);
  let x_2848 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_2805), (19i / x_2805)), 0i);
  let x_2850 : u32 = x_2812.w;
  let x_2861 : vec3<f32> = vec3<f32>(bitcast<f32>(x_2824.x), 0.0f, bitcast<f32>(x_2824.z));
  let x_2865 : f32 = bitcast<f32>(x_2824.w);
  let x_2868 : u32 = x_2836.w;
  let x_2871 : u32 = x_2848.x;
  let x_2989 : f32 = v2.y;
  let x_2990 : f32 = v8;
  if ((x_2989 < x_2990)) {
    discard;
  }
  let x_2994 : i32 = v12;
  let x_2996 : bool = ((x_2994 & 8i) != 0i);
  let x_2999 : bool = ((x_2994 & 16i) != 0i);
  let x_3002 : bool = ((x_2994 & 2048i) != 0i);
  let x_3005 : vec4<f32> = (x_2696 * vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f));
  let x_3006 : vec3<f32> = v3;
  let x_3008 : vec3<f32> = ((x_3006 * 0.875f) + x_888);
  let x_3894 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3898 : i32 = x_3894.z;
  let x_3905 : f32 = f32((x_3898 - 1i));
  let x_3906 : f32 = clamp(((x_3008.z * f32(x_3898)) - 0.5f), 0.0f, x_3905);
  let x_3908 : f32 = floor(x_3906);
  let x_3922 : f32 = x_3008.x;
  let x_3923 : f32 = x_3008.y;
  let x_3925 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3922, x_3923, x_3908).xy, i32(round(vec3<f32>(x_3922, x_3923, x_3908).z)), 0.0f);
  let x_3935 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3922, x_3923, min((x_3908 + 1.0f), x_3905)).xy, i32(round(vec3<f32>(x_3922, x_3923, min((x_3908 + 1.0f), x_3905)).z)), 0.0f);
  let x_3938 : f32 = (x_3906 - x_3908);
  let x_3011 : f32 = ((((mix(x_3925, x_3935, vec4<f32>(x_3938, x_3938, x_3938, x_3938)) * 255.0f) - x_7659) * x_7666)).x;
  let x_3013 : f32 = (x_3011 * 0.25624999403953552246f);
  let x_3016 : vec3<f32> = v4;
  let x_3019 : vec3<f32> = ((x_3006 + x_888) + (x_3016 * x_3013));
  let x_3023 : vec3<f32> = (((x_3019 - x_888) * 0.875f) + x_888);
  let x_3956 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3960 : i32 = x_3956.z;
  let x_3967 : f32 = f32((x_3960 - 1i));
  let x_3968 : f32 = clamp(((x_3023.z * f32(x_3960)) - 0.5f), 0.0f, x_3967);
  let x_3970 : f32 = floor(x_3968);
  let x_3984 : f32 = x_3023.x;
  let x_3985 : f32 = x_3023.y;
  let x_3987 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3984, x_3985, x_3970).xy, i32(round(vec3<f32>(x_3984, x_3985, x_3970).z)), 0.0f);
  let x_3997 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3984, x_3985, min((x_3970 + 1.0f), x_3967)).xy, i32(round(vec3<f32>(x_3984, x_3985, min((x_3970 + 1.0f), x_3967)).z)), 0.0f);
  let x_4000 : f32 = (x_3968 - x_3970);
  let x_3026 : f32 = ((((mix(x_3987, x_3997, vec4<f32>(x_4000, x_4000, x_4000, x_4000)) * 255.0f) - x_7659) * x_7666)).x;
  let x_3028 : f32 = (x_3026 * 0.19099999964237213135f);
  let x_3033 : vec3<f32> = (x_3019 + (x_3016 * x_3028));
  let x_3037 : vec3<f32> = (((x_3033 - x_888) * 0.875f) + x_888);
  let x_4018 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_4022 : i32 = x_4018.z;
  let x_4029 : f32 = f32((x_4022 - 1i));
  let x_4030 : f32 = clamp(((x_3037.z * f32(x_4022)) - 0.5f), 0.0f, x_4029);
  let x_4032 : f32 = floor(x_4030);
  let x_4046 : f32 = x_3037.x;
  let x_4047 : f32 = x_3037.y;
  let x_4049 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_4046, x_4047, x_4032).xy, i32(round(vec3<f32>(x_4046, x_4047, x_4032).z)), 0.0f);
  let x_4059 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_4046, x_4047, min((x_4032 + 1.0f), x_4029)).xy, i32(round(vec3<f32>(x_4046, x_4047, min((x_4032 + 1.0f), x_4029)).z)), 0.0f);
  let x_4062 : f32 = (x_4030 - x_4032);
  let x_3040 : f32 = ((((mix(x_4049, x_4059, vec4<f32>(x_4062, x_4062, x_4062, x_4062)) * 255.0f) - x_7659) * x_7666)).x;
  let x_3042 : f32 = (x_3040 * 0.16312499344348907471f);
  let x_3048 : vec3<f32> = ((x_3033 + (x_3016 * x_3042)) - x_888);
  let x_3050 : vec3<f32> = abs(x_3048);
  let x_3052 : f32 = x_3050.x;
  let x_3054 : f32 = x_3050.y;
  let x_3056 : f32 = x_3050.z;
  let x_3059 : bool = (max(x_3052, max(x_3054, x_3056)) < 0.4930000007152557373f);
  let x_3062 : f32 = (-1.0f + x_2700);
  let x_4087 : vec3<f32> = dpdx(x_3048);
  let x_4090 : vec3<f32> = -(dpdy(x_3048));
  let x_4097 : bool = (x_3052 >= x_3054);
  x_4105 = x_4097;
  if (x_4097) {
    x_4103 = (x_3052 >= x_3056);
    x_4105 = x_4103;
  }
  var x_4135 : vec2<f32>;
  var x_4137 : vec2<f32>;
  var x_4139 : vec2<f32>;
  var x_4147 : f32;
  var x_4153 : f32;
  var x_4114 : vec2<f32>;
  var x_4116 : vec2<f32>;
  var x_4118 : vec2<f32>;
  var x_4126 : f32;
  var x_4132 : f32;
  if (x_4105) {
    x_4157 = vec2<f32>(x_3048.y, x_3048.z);
    x_4159 = vec2<f32>(x_4087.y, x_4087.z);
    x_4161 = vec2<f32>(x_4090.y, x_4090.z);
    let x_4166 : f32 = sign(x_3048.x);
    x_4169 = (x_4166 * x_4087.x);
    x_4175 = (x_4166 * x_4090.x);
    x_6918 = x_4175;
    x_6916 = x_4161;
    x_6914 = x_4169;
    x_6912 = x_4157;
    x_6910 = x_4159;
    x_6908 = x_3052;
  } else {
    if ((x_3054 >= x_3056)) {
      x_4135 = vec2<f32>(x_3048.x, x_3048.z);
      x_4137 = vec2<f32>(x_4087.x, x_4087.z);
      x_4139 = vec2<f32>(x_4090.x, x_4090.z);
      let x_4144 : f32 = sign(x_3048.y);
      x_4147 = (x_4144 * x_4087.y);
      x_4153 = (x_4144 * x_4090.y);
      x_6919 = x_4153;
      x_6917 = x_4139;
      x_6915 = x_4147;
      x_6913 = x_4135;
      x_6911 = x_4137;
      x_6909 = x_3054;
    } else {
      x_4114 = vec2<f32>(x_3048.x, x_3048.y);
      x_4116 = vec2<f32>(x_4087.x, x_4087.y);
      x_4118 = vec2<f32>(x_4090.x, x_4090.y);
      let x_4123 : f32 = sign(x_3048.z);
      x_4126 = (x_4123 * x_4087.z);
      x_4132 = (x_4123 * x_4090.z);
      x_6919 = x_4132;
      x_6917 = x_4118;
      x_6915 = x_4126;
      x_6913 = x_4114;
      x_6911 = x_4116;
      x_6909 = x_3056;
    }
    x_6918 = x_6919;
    x_6916 = x_6917;
    x_6914 = x_6915;
    x_6912 = x_6913;
    x_6910 = x_6911;
    x_6908 = x_6909;
  }
  let x_4178 : f32 = max(x_6908, 0.00000099999999747524f);
  let x_4187 : f32 = (0.5f / x_4178);
  let x_4188 : vec2<f32> = ((x_6910 - (x_6912 * (x_6914 / x_4178))) * x_4187);
  let x_4198 : vec2<f32> = ((x_6916 - (x_6912 * (x_6918 / x_4178))) * x_4187);
  let x_4203 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf_normal, 0i).xy);
  let x_4205 : f32 = f32(x_4203.x);
  let x_4229 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf_normal, gs_wgpu_samp_material_data_brick_sdf_normal, x_3048, clamp(((0.5f * log2(max(((max(dot(x_4188, x_4188), dot(x_4198, x_4198)) * x_4205) * x_4205), 0.00000000999999993923f))) + x_3062), 0.0f, 2.0f));
  let x_3071 : vec3<f32> = (((vec3<f32>(x_4229.x, x_4229.y, x_4229.z) * 255.0f) - vec3<f32>(128.0f, 128.0f, 128.0f)) * vec3<f32>(0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f));
  if ((dot(x_3071, x_3016) > 0.0f)) {
    discard;
  }
  let x_3078 : vec3<f32> = v2;
  let x_3083 : f32 = x_3005.w;
  let x_3094 : f32 = v5;
  let x_3096 : vec3<f32> = (x_3078 + ((normalize((x_3078 - (vec3<f32>(x_3005.x, x_3005.y, x_3005.z) / vec3<f32>(x_3083, x_3083, x_3083)))) * ((x_3013 + x_3028) + x_3042)) * x_3094));
  let x_3101 : bool = ((x_3011 * 0.125f) <= 0.01499999966472387314f);
  x_3109 = x_3101;
  if (!(x_3101)) {
    x_3107 = ((x_3026 * 0.125f) <= 0.01499999966472387314f);
    x_3109 = x_3107;
  }
  x_3116 = x_3109;
  if (!(x_3109)) {
    x_3114 = ((x_3040 * 0.125f) <= 0.01499999966472387314f);
    x_3116 = x_3114;
  }
  if (!(x_3116)) {
    discard;
  }
  let x_3155 : vec3<f32> = (x_3071 * mat3x3<f32>(vec3<f32>(x_2509.x, x_2511.x, x_2513.x), vec3<f32>(x_2509.y, x_2511.y, x_2513.y), vec3<f32>(x_2509.z, x_2511.z, x_2513.z)));
  let x_3158 : mat4x4<f32> = x_1080.renderer_MVPMat;
  let x_3163 : vec4<f32> = vec4<f32>(x_3096.x, x_3096.y, x_3096.z, 1.0f);
  let x_3164 : vec4<f32> = (x_3158 * x_3163);
  if (!(x_2996)) {
    let x_3169 : f32 = v7;
    x_3170 = (x_3169 > -2.5f);
    x_6951 = x_3170;
  } else {
    x_6951 = false;
  }
  if (x_6951) {
    let x_3177 : f32 = v7;
    x_3178 = (x_2989 < x_3177);
    x_6952 = x_3178;
  } else {
    x_6952 = false;
  }
  var x_3188 : bool;
  var x_6955 : bool;
  if (x_6952) {
    discard;
  } else {
    if (x_2996) {
      let x_3187 : f32 = v7;
      x_3188 = (x_2989 > x_3187);
      x_6955 = x_3188;
    } else {
      x_6955 = false;
    }
    if (x_6955) {
      discard;
    }
  }
  var x_3195 : i32;
  var x_3196 : u32;
  var x_3277 : vec2<f32>;
  var x_3205 : vec2<f32>;
  var x_6977 : vec2<f32>;
  var x_3284 : vec2<f32>;
  var x_7040 : vec2<f32>;
  var x_3290 : bool;
  var x_6983 : bool;
  var x_3304 : vec3<f32>;
  var x_3299 : vec3<f32>;
  var x_7078 : vec3<f32>;
  var x_3312 : bool;
  var x_7014 : bool;
  var x_3318 : bool;
  var x_7016 : bool;
  var x_3324 : bool;
  var x_7018 : bool;
  var x_3431 : vec3<f32>;
  var x_7044 : vec3<f32>;
  var x_7062 : vec3<f32>;
  var x_3438 : bool;
  var x_7058 : bool;
  var x_3444 : bool;
  var x_7079 : bool;
  var x_3488 : vec3<f32>;
  var x_7099 : vec3<f32>;
  var x_3535 : vec3<f32>;
  x_3195 = v10;
  x_3196 = bitcast<u32>(x_3195);
  if (((x_2994 & 2i) != 0i)) {
    let x_3542 : u32 = v0;
    let x_3549 : vec2<f32> = ((vec2<f32>(vec2<u32>(x_3542, x_3542)) * 0.20000000298023223877f) + (vec2<f32>(x_3078.x, x_3078.z) * 0.20000000298023223877f));
    let x_3555 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_3549.x, x_3549.y, f32(x_3196)).xy, i32(round(vec3<f32>(x_3549.x, x_3549.y, f32(x_3196)).z)));
    x_3557 = (vec3<f32>(x_3555.x, x_3555.y, x_3555.z) * 0.69999998807907104492f);
    x_7166 = x_3557;
  } else {
    var x_3230 : vec2<f32>;
    var x_6962 : vec2<f32>;
    var x_6973 : vec2<f32>;
    var x_3242 : vec2<f32>;
    var x_6974 : vec2<f32>;
    if (((x_2994 & 32i) != 0i)) {
      var x_3208 : vec3<f32>;
      var x_3224 : vec2<f32>;
      var x_3220 : vec2<f32>;
      x_3208 = normalize(x_3155);
      if ((x_3208.y > 0.89999997615814208984f)) {
        x_3230 = (vec2<f32>(x_3096.x, x_3096.z) * 0.69999998807907104492f);
        x_6973 = x_3230;
      } else {
        if ((abs(x_3208.x) > 0.89999997615814208984f)) {
          x_3224 = (vec2<f32>(x_3096.z, x_3096.y) * 0.69999998807907104492f);
          x_6962 = x_3224;
        } else {
          x_3220 = (vec2<f32>(x_3096.x, x_3096.y) * 0.69999998807907104492f);
          x_6962 = x_3220;
        }
        x_6973 = x_6962;
      }
      if (x_3059) {
        let x_3236 : u32 = v13;
        let x_4336 : i32 = ((bitcast<i32>(x_3236) * 16i) + 11i);
        let x_4668 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_4673 : i32 = (x_4336 / 4i);
        let x_4675 : i32 = x_4668.x;
        let x_4684 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4673 % x_4675), (x_4673 / x_4675)), 0i);
        let x_3241 : f32 = unpack2x16float(x_4684[(x_4336 % 4i)]).y;
        x_3242 = vec2<f32>(x_3241, x_3241);
        x_6974 = x_3242;
      } else {
        x_6974 = x_6973;
      }
      let x_3244 : u32 = v13;
      let x_4915 : i32 = ((bitcast<i32>(x_3244) * 16i) + 13i);
      let x_5287 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_5292 : i32 = (x_4915 / 4i);
      let x_5294 : i32 = x_5287.x;
      let x_5303 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5292 % x_5294), (x_5292 / x_5294)), 0i);
      let x_5305 : i32 = (x_4915 % 4i);
      let x_5852 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_5859 : i32 = x_5852.x;
      let x_5868 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5292 % x_5859), (x_5292 / x_5859)), 0i);
      let x_3253 : u32 = (x_5303[x_5305] + (x_5868[x_5305] << 10u));
      let x_3257 : u32 = (x_3253 ^ (x_3253 >> 6u));
      let x_3261 : u32 = (x_3257 + (x_3257 << 3u));
      let x_3265 : u32 = (x_3261 ^ (x_3261 >> 11u));
      let x_3275 : f32 = (bitcast<f32>((((x_3265 + (x_3265 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
      x_3277 = ((x_6974 * 0.30000001192092895508f) + vec2<f32>(x_3275, x_3275));
      x_6977 = x_3277;
    } else {
      x_3205 = v9;
      x_6977 = x_3205;
    }
    if (x_3059) {
      x_3284 = (x_6977 + vec2<f32>(0.20999999344348907471f, 0.20999999344348907471f));
      x_7040 = x_3284;
    } else {
      x_7040 = x_6977;
    }
    if ((x_3196 == 1u)) {
      x_6983 = true;
    } else {
      x_3290 = (x_3196 == 0u);
      x_6983 = x_3290;
    }
    if (x_6983) {
      x_3304 = pow(vec3<f32>(x_2788.x, x_2788.y, x_2788.z), vec3<f32>(1.29999995231628417969f, 1.29999995231628417969f, 1.29999995231628417969f));
      x_7078 = x_3304;
    } else {
      x_3299 = (pow(vec3<f32>(x_2774.x, x_2774.y, x_2774.z), x_1297) * 0.80000001192092895508f);
      x_7078 = x_3299;
    }
    if ((x_3195 == 0i)) {
      x_7014 = true;
    } else {
      x_3312 = (x_3195 == 4i);
      x_7014 = x_3312;
    }
    if (x_7014) {
      x_7016 = true;
    } else {
      x_3318 = (x_3195 == 10i);
      x_7016 = x_3318;
    }
    if (x_7016) {
      x_7018 = true;
    } else {
      x_3324 = (x_3195 == 12i);
      x_7018 = x_3324;
    }
    var x_3333 : bool;
    var x_7020 : bool;
    var x_3418 : vec3<f32>;
    var x_7043 : vec3<f32>;
    if (x_7018) {
      let x_3426 : vec2<f32> = (x_7040 + vec2<f32>(0.85000002384185791016f, 0.85000002384185791016f));
      let x_3430 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3426.x, x_3426.y, 0.0f).xy, i32(round(vec3<f32>(x_3426.x, x_3426.y, 0.0f).z)));
      x_3431 = vec3<f32>(x_3430.x, x_3430.y, x_3430.z);
      x_7062 = x_3431;
    } else {
      if ((x_3195 == 1i)) {
        x_7020 = true;
      } else {
        x_3333 = (x_3195 == 5i);
        x_7020 = x_3333;
      }
      var x_3342 : bool;
      var x_7022 : bool;
      var x_3404 : vec3<f32>;
      var x_7042 : vec3<f32>;
      if (x_7020) {
        let x_3412 : vec2<f32> = (x_7040 + vec2<f32>(0.44999998807907104492f, 0.44999998807907104492f));
        let x_3416 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3412.x, x_3412.y, 1.0f).xy, i32(round(vec3<f32>(x_3412.x, x_3412.y, 1.0f).z)));
        x_3418 = pow(vec3<f32>(x_3416.x, x_3416.y, x_3416.z), vec3<f32>(1.10000002384185791016f, 1.10000002384185791016f, 1.10000002384185791016f));
        x_7044 = x_3418;
      } else {
        if ((x_3195 == 2i)) {
          x_7022 = true;
        } else {
          x_3342 = (x_3195 == 7i);
          x_7022 = x_3342;
        }
        var x_3351 : bool;
        var x_7024 : bool;
        var x_3357 : bool;
        var x_7026 : bool;
        var x_3363 : bool;
        var x_7028 : bool;
        var x_3392 : vec3<f32>;
        var x_7041 : vec3<f32>;
        if (x_7022) {
          let x_3403 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_7040.x, x_7040.y, 2.0f).xy, i32(round(vec3<f32>(x_7040.x, x_7040.y, 2.0f).z)));
          x_3404 = vec3<f32>(x_3403.x, x_3403.y, x_3403.z);
          x_7043 = x_3404;
        } else {
          if ((x_3195 == 3i)) {
            x_7024 = true;
          } else {
            x_3351 = (x_3195 == 6i);
            x_7024 = x_3351;
          }
          if (x_7024) {
            x_7026 = true;
          } else {
            x_3357 = (x_3195 == 8i);
            x_7026 = x_3357;
          }
          if (x_7026) {
            x_7028 = true;
          } else {
            x_3363 = (x_3195 == 9i);
            x_7028 = x_3363;
          }
          var x_3380 : vec3<f32>;
          if (x_7028) {
            let x_3391 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_7040.x, x_7040.y, 3.0f).xy, i32(round(vec3<f32>(x_7040.x, x_7040.y, 3.0f).z)));
            x_3392 = vec3<f32>(x_3391.x, x_3391.y, x_3391.z);
            x_7042 = x_3392;
          } else {
            if ((x_3195 == 11i)) {
              let x_3379 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_7040.x, x_7040.y, 4.0f).xy, i32(round(vec3<f32>(x_7040.x, x_7040.y, 4.0f).z)));
              x_3380 = vec3<f32>(x_3379.x, x_3379.y, x_3379.z);
              x_7041 = x_3380;
            } else {
              x_7041 = x_1452;
            }
            x_7042 = x_7041;
          }
          x_7043 = x_7042;
        }
        x_7044 = x_7043;
      }
      x_7062 = x_7044;
    }
    let x_3434 : bool = (x_3196 == 7u);
    if (x_3434) {
      x_7058 = true;
    } else {
      x_3438 = (x_3196 == 2u);
      x_7058 = x_3438;
    }
    if (x_7058) {
      x_7079 = true;
    } else {
      x_3444 = (x_3196 == 11u);
      x_7079 = x_3444;
    }
    if (((x_2994 & 512i) != 0i)) {
      let x_3453 : u32 = v0;
      let x_3454 : u32 = (x_3453 ^ 8902390u);
      let x_3458 : u32 = (x_3454 + (x_3454 << 10u));
      let x_3462 : u32 = (x_3458 ^ (x_3458 >> 6u));
      let x_3466 : u32 = (x_3462 + (x_3462 << 3u));
      let x_3470 : u32 = (x_3466 ^ (x_3466 >> 11u));
      let x_3486 : f32 = mix(0.0f, 0.5f, smoothstep(0.20000000298023223877f, 0.80000001192092895508f, (bitcast<f32>((((x_3470 + (x_3470 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_3488 = mix(x_7062, select(x_7078, x_7062, vec3<bool>(x_7079, x_7079, x_7079)), vec3<f32>(x_3486, x_3486, x_3486));
      x_7099 = x_3488;
    } else {
      x_7099 = x_7062;
    }
    var x_3497 : bool;
    var x_7138 : bool;
    if (x_3059) {
      if (x_3434) {
        x_7138 = true;
      } else {
        x_3497 = (x_3196 == 2u);
        x_7138 = x_3497;
      }
      let x_3500 : u32 = v0;
      let x_3501 : u32 = (x_3500 ^ 239085u);
      let x_3505 : u32 = (x_3501 + (x_3501 << 10u));
      let x_3509 : u32 = (x_3505 ^ (x_3505 >> 6u));
      let x_3513 : u32 = (x_3509 + (x_3509 << 3u));
      let x_3517 : u32 = (x_3513 ^ (x_3513 >> 11u));
      let x_3533 : f32 = mix(0.0f, select(0.40000000596046447754f, 0.20000000298023223877f, x_7138), smoothstep(0.0f, 0.80000001192092895508f, (bitcast<f32>((((x_3517 + (x_3517 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_3535 = mix(x_7099, vec3<f32>(x_2760.x, x_2760.y, x_2760.z), vec3<f32>(x_3533, x_3533, x_3533));
      x_7139 = x_3535;
    } else {
      x_7139 = x_7099;
    }
    x_7166 = x_7139;
  }
  var x_3593 : vec3<f32>;
  var x_3580 : bool;
  var x_7204 : vec3<f32>;
  var x_7325 : bool;
  var x_7318 : vec3<f32>;
  var x_3608 : bool;
  var x_7316 : bool;
  var x_3615 : vec3<f32>;
  let x_3560 : vec3<f32> = normalize(x_3155);
  if (((x_2994 & 64i) == 0i)) {
    var x_7688 : u32;
    var x_3586 : vec3<f32>;
    x_7688 = select(0u, x_2868, ((x_2994 & 4096i) != 0i));
    if ((x_7688 == 1u)) {
      x_3593 = mix(x_7166, x_1612, x_888);
      x_7325 = true;
      x_7318 = x_3593;
    } else {
      x_3580 = (x_7688 == 2u);
      if (x_3580) {
        x_3586 = mix(x_7166, x_888, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_7204 = x_3586;
      } else {
        x_7204 = x_7166;
      }
      x_7325 = x_3580;
      x_7318 = x_7204;
    }
    if ((x_2871 == 1u)) {
      let x_3603 : vec2<f32> = v11;
      x_3608 = (distance(vec2<f32>(x_2861.x, x_2861.z), x_3603) < (1.88900005817413330078f * x_2865));
      x_7316 = x_3608;
    } else {
      x_7316 = false;
    }
    if (x_7316) {
      x_3615 = mix(x_7166, x_1612, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_7326 = x_3615;
    } else {
      x_7326 = x_7318;
    }
    x_3619 = select(x_7325, true, x_7316);
    x_7458 = x_3619;
    x_7367 = x_7326;
  } else {
    x_7458 = false;
    x_7367 = x_7166;
  }
  if (x_3002) {
    x_3627 = mix(x_7166, x_1612, x_888);
    x_7411 = x_3627;
  } else {
    x_7411 = x_7367;
  }
  if ((x_2850 == 4u)) {
    let x_3637 : vec2<f32> = (vec2<f32>(x_3078.x, x_3078.z) * 0.40000000596046447754f);
    let x_3640 : f32 = dot(x_3637, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
    let x_3643 : vec2<f32> = floor((x_3637 + vec2<f32>(x_3640, x_3640)));
    let x_3648 : f32 = dot(x_3643, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
    let x_3650 : vec2<f32> = ((x_3637 - x_3643) + vec2<f32>(x_3648, x_3648));
    let x_3652 : f32 = x_3650.x;
    let x_3654 : f32 = x_3650.y;
    let x_3657 : bool = (x_3652 > x_3654);
    let x_3659 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_3657, x_3657));
    let x_3662 : vec4<f32> = (vec4<f32>(x_3650.x, x_3650.y, x_3650.x, x_3650.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
    let x_3666 : vec2<f32> = (vec2<f32>(x_3662.x, x_3662.y) - x_3659);
    var x_7816_1 : vec4<f32> = x_3662;
    x_7816_1.x = x_3666.x;
    let x_7816 : vec4<f32> = x_7816_1;
    var x_7819_1 : vec4<f32> = x_7816;
    x_7819_1.y = x_3666.y;
    let x_7819 : vec4<f32> = x_7819_1;
    let x_3679 : vec2<f32> = (x_3643 - (vec2<f32>(289.0f, 289.0f) * trunc((x_3643 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
    let x_3681 : f32 = x_3679.y;
    let x_3686 : vec3<f32> = (vec3<f32>(x_3681, x_3681, x_3681) + vec3<f32>(0.0f, x_3659.y, 1.0f));
    let x_3691 : vec3<f32> = (((x_3686 * 34.0f) + x_1297) * x_3686);
    let x_3699 : f32 = x_3679.x;
    let x_3705 : vec3<f32> = (((x_3691 - (x_1763 * trunc((x_3691 * x_7670)))) + vec3<f32>(x_3699, x_3699, x_3699)) + vec3<f32>(0.0f, x_3659.x, 1.0f));
    let x_3710 : vec3<f32> = (((x_3705 * 34.0f) + x_1297) * x_3705);
    let x_3715 : vec2<f32> = vec2<f32>(x_7819.x, x_7819.y);
    let x_3720 : vec2<f32> = vec2<f32>(x_7819.z, x_7819.w);
    let x_3726 : vec3<f32> = max((x_888 - vec3<f32>(dot(x_3650, x_3650), dot(x_3715, x_3715), dot(x_3720, x_3720))), x_1452);
    let x_3729 : vec3<f32> = (x_3726 * x_3726);
    let x_3738 : vec3<f32> = (fract(((x_3710 - (x_1763 * trunc((x_3710 * x_7670)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
    let x_3740 : vec3<f32> = (x_3738 - x_1297);
    let x_3743 : vec3<f32> = (abs(x_3740) - x_888);
    let x_3748 : vec3<f32> = (x_3740 - floor((x_3738 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
    let x_3790 : vec2<f32> = ((vec2<f32>(x_3748.y, x_3748.z) * vec2<f32>(x_7819.x, x_7819.z)) + (vec2<f32>(x_3743.y, x_3743.z) * vec2<f32>(x_7819.y, x_7819.w)));
    let x_3803 : f32 = (smoothstep(0.0f, 1.0f, (smoothstep(-0.10000000149011611938f, 0.0f, x_2989) * clamp(x_3560.y, 0.0f, 1.0f))) * clamp(clamp(((130.0f * dot(((x_3729 * x_3729) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_3748 * x_3748) + (x_3743 * x_3743)) * 0.85373473167419433594f))), vec3<f32>(((x_3748.x * x_3652) + (x_3743.x * x_3654)), x_3790.x, x_3790.y))) + 0.75f), 0.0f, 1.0f), select(0.40000000596046447754f, 0.0f, x_2999), select(1.0f, 0.10000000149011611938f, x_2999)));
    x_3805 = mix(x_7411, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_3803, x_3803, x_3803));
    x_7453 = x_3805;
  } else {
    x_7453 = x_7411;
  }
  var x_2527 : u32;
  var x_7496 : u32;
  var x_7508 : bool;
  let x_3812 : vec3<f32> = sqrt(clamp(x_7453, x_1452, x_1297));
  let x_3869 : u32 = (((u32(((clamp(x_3812.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_3812.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_3812.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(2264924160u, 2399141888u, select(x_7458, true, x_3002)));
  let x_3880 : f32 = gl_FragCoord.z;
  gl_FragDepth = clamp(max((((x_3164.z / x_3164.w) * 0.5f) + 0.5f), x_3880), 0.0f, 1.0f);
  x_2527 = v13;
  switch(0u) {
    default: {
      let x_5958 : i32 = (bitcast<i32>(x_2527) * 16i);
      let x_5960 : i32 = (x_5958 + 15i);
      let x_6077 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_roof, 0i));
      let x_6082 : i32 = (x_5960 / 4i);
      let x_6084 : i32 = x_6077.x;
      let x_6093 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_roof, vec2<i32>((x_6082 % x_6084), (x_6082 / x_6084)), 0i);
      if ((x_6093[(x_5960 % 4i)] == 0u)) {
        x_7514 = false;
        break;
      }
      let x_5966 : i32 = (x_5958 + 10i);
      let x_6104 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_roof, 0i));
      let x_6109 : i32 = (x_5966 / 4i);
      let x_6111 : i32 = x_6104.x;
      let x_6120 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_roof, vec2<i32>((x_6109 % x_6111), (x_6109 / x_6111)), 0i);
      let x_6123 : u32 = x_6120[(x_5966 % 4i)];
      let x_5971 : vec4<f32> = x_2182.renderer_DormerGrid;
      let x_5979 : vec2<i32> = vec2<i32>(floor(((vec2<f32>(x_3096.x, x_3096.z) - vec2<f32>(x_5971.x, x_5971.y)) * vec2<f32>(x_5971.z, x_5971.w))));
      let x_5985 : i32 = (x_5979.x + (15i * x_5979.y));
      if (((x_5985 < 0i) | (x_5985 >= 225i))) {
        x_7514 = false;
        break;
      }
      let x_6131 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_counts, 0i));
      let x_6136 : i32 = (x_5985 / 4i);
      let x_6138 : i32 = x_6131.x;
      let x_6147 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_counts, vec2<i32>((x_6136 % x_6138), (x_6136 / x_6138)), 0i);
      let x_5995 : u32 = min(128u, x_6147[(x_5985 % 4i)]);
      x_7496 = 0u;
      loop {
        var x_7503 : bool;
        var x_6059 : bool;
        var x_6064 : u32;
        x_7515 = false;
        x_7508 = false;
        if ((x_7496 < x_5995)) {
        } else {
          break;
        }
        var x_6016 : vec3<f32>;
        var x_6030 : vec3<f32>;
        var x_6408 : f32;
        var x_6441 : f32;
        var x_6474 : f32;
        var x_6507 : f32;
        var x_7501 : bool;
        var x_7502 : bool;
        var x_6661 : bool;
        let x_6007 : i32 = (((x_5985 * 50i) + bitcast<i32>(x_7496)) * 12i);
        let x_6164 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6169 : i32 = (x_6007 / 4i);
        let x_6171 : i32 = x_6164.x;
        let x_6180 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6169 % x_6171), (x_6169 / x_6171)), 0i);
        let x_6011 : i32 = (x_6007 + 1i);
        let x_6197 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6202 : i32 = (x_6011 / 4i);
        let x_6204 : i32 = x_6197.x;
        let x_6213 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6202 % x_6204), (x_6202 / x_6204)), 0i);
        let x_6014 : i32 = (x_6007 + 2i);
        let x_6230 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6235 : i32 = (x_6014 / 4i);
        let x_6237 : i32 = x_6230.x;
        let x_6246 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6235 % x_6237), (x_6235 / x_6237)), 0i);
        x_6016 = vec3<f32>(bitcast<f32>(x_6180[(x_6007 % 4i)]), bitcast<f32>(x_6213[(x_6011 % 4i)]), bitcast<f32>(x_6246[(x_6014 % 4i)]));
        let x_6018 : i32 = (x_6007 + 3i);
        let x_6257 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6262 : i32 = (x_6018 / 4i);
        let x_6264 : i32 = x_6257.x;
        let x_6273 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6262 % x_6264), (x_6262 / x_6264)), 0i);
        let x_6022 : i32 = (x_6007 + 4i);
        let x_6290 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6295 : i32 = (x_6022 / 4i);
        let x_6297 : i32 = x_6290.x;
        let x_6306 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6295 % x_6297), (x_6295 / x_6297)), 0i);
        let x_6025 : i32 = (x_6007 + 5i);
        let x_6323 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6328 : i32 = (x_6025 / 4i);
        let x_6330 : i32 = x_6323.x;
        let x_6339 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6328 % x_6330), (x_6328 / x_6330)), 0i);
        let x_6028 : i32 = (x_6007 + 6i);
        let x_6356 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6361 : i32 = (x_6028 / 4i);
        let x_6363 : i32 = x_6356.x;
        let x_6372 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6361 % x_6363), (x_6361 / x_6363)), 0i);
        x_6030 = vec3<f32>(bitcast<f32>(x_6306[(x_6022 % 4i)]), bitcast<f32>(x_6339[(x_6025 % 4i)]), bitcast<f32>(x_6372[(x_6028 % 4i)]));
        let x_6036 : i32 = (x_6007 + 8i);
        let x_6416 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6421 : i32 = (x_6036 / 4i);
        let x_6423 : i32 = x_6416.x;
        let x_6432 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6421 % x_6423), (x_6421 / x_6423)), 0i);
        x_6408 = bitcast<f32>(x_6432[(x_6036 % 4i)]);
        let x_6039 : i32 = (x_6007 + 9i);
        let x_6449 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6454 : i32 = (x_6039 / 4i);
        let x_6456 : i32 = x_6449.x;
        let x_6465 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6454 % x_6456), (x_6454 / x_6456)), 0i);
        x_6441 = bitcast<f32>(x_6465[(x_6039 % 4i)]);
        let x_6043 : i32 = (x_6007 + 10i);
        let x_6482 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6487 : i32 = (x_6043 / 4i);
        let x_6489 : i32 = x_6482.x;
        let x_6498 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6487 % x_6489), (x_6487 / x_6489)), 0i);
        x_6474 = bitcast<f32>(x_6498[(x_6043 % 4i)]);
        let x_6046 : i32 = (x_6007 + 11i);
        let x_6515 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6520 : i32 = (x_6046 / 4i);
        let x_6522 : i32 = x_6515.x;
        let x_6531 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6520 % x_6522), (x_6520 / x_6522)), 0i);
        x_6507 = bitcast<f32>(x_6531[(x_6046 % 4i)]);
        let x_6053 : bool = (x_6273[(x_6018 % 4i)] == x_6123);
        x_6059 = x_6053;
        if (x_6053) {
          var x_6621 : f32;
          var x_6651 : bool;
          let x_6554 : vec3<f32> = vec3<f32>(x_6408, 0.0f, x_6441);
          let x_6571 : mat3x3<f32> = transpose(mat3x3<f32>(cross(x_6554, x_2034), x_2034, x_6554));
          let x_6573 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_6571);
          let x_6575 : vec3<f32> = (x_2034 * x_6571);
          let x_6577 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_6571);
          let x_6580 : vec3<f32> = cross(x_6573, x_6575);
          let x_6584 : f32 = (1.0f / dot(x_6577, x_6580));
          let x_6585 : vec3<f32> = vec3<f32>(x_6584, x_6584, x_6584);
          let x_6619 : vec3<f32> = ((mat3x3<f32>((cross(x_6575, x_6577) * x_6585), (cross(x_6577, x_6573) * x_6585), (x_6580 * x_6585)) * (x_3096 - x_6016)) / x_6030);
          x_6621 = x_6619.y;
          let x_6629 : f32 = clamp(((x_6621 * x_6474) + x_6507), 0.0f, 1.0f);
          if ((abs(x_6619.x) < mix(0.5f, 0.0f, ((x_6629 * x_6629) * x_6629)))) {
            if ((x_6621 < select(0.69999998807907104492f, 0.5f, (x_6474 == 1.0f)))) {
              x_6651 = (x_6621 > -0.5f);
              x_7501 = x_6651;
            } else {
              x_7501 = false;
            }
            x_7502 = x_7501;
          } else {
            x_7502 = false;
          }
          if (x_7502) {
            x_6661 = (abs(x_6619.z) < 0.5f);
            x_7503 = x_6661;
          } else {
            x_7503 = false;
          }
          x_6059 = x_7503;
        }
        if (x_6059) {
          x_7515 = true;
          x_7508 = true;
          break;
        }

        continuing {
          x_6064 = (x_7496 + bitcast<u32>(1i));
          x_7496 = x_6064;
        }
      }
      x_7514 = x_7515;
      if (x_7508) {
        break;
      }
      x_7514 = false;
    }
  }
  if (x_7514) {
    discard;
  }
  var x_2532 : u32;
  var x_7572 : u32;
  var x_7571 : u32;
  var x_7582 : bool;
  x_2532 = resident_cell_id;
  switch(0u) {
    default: {
      let x_6753 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_cell_clip, 0i));
      let x_6758 : i32 = bitcast<i32>(x_2532);
      let x_6760 : i32 = x_6753.x;
      let x_6769 : vec4<u32> = textureLoad(gs_wgpu_tex_cell_clip, vec2<i32>((x_6758 % x_6760), (x_6758 / x_6760)), 0i);
      let x_6770 : vec4<f32> = bitcast<vec4<f32>>(x_6769);
      let x_6682 : f32 = x_6770.y;
      if ((x_6682 < 0.0f)) {
        x_7586 = false;
        break;
      }
      if ((x_6682 == 0.0f)) {
        x_7586 = true;
        break;
      }
      let x_6693 : u32 = u32(x_6770.x);
      x_7572 = x_6693;
      x_7571 = 0u;
      loop {
        var x_7573 : u32;
        var x_7578 : bool;
        var x_6740 : u32;
        x_7587 = false;
        x_7582 = false;
        if ((x_7571 < u32(x_6682))) {
        } else {
          break;
        }
        let x_6778 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_cell_clip, 0i));
        let x_6783 : i32 = bitcast<i32>(x_7572);
        let x_6785 : i32 = x_6778.x;
        let x_6794 : vec4<u32> = textureLoad(gs_wgpu_tex_cell_clip, vec2<i32>((x_6783 % x_6785), (x_6783 / x_6785)), 0i);
        let x_6705 : u32 = u32((bitcast<vec4<f32>>(x_6794)).x);
        let x_6707 : u32 = (x_7572 + 1u);
        x_7573 = 0u;
        loop {
          var x_6733 : u32;
          x_7578 = true;
          if ((x_7573 < x_6705)) {
          } else {
            break;
          }
          let x_6803 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_cell_clip, 0i));
          let x_6808 : i32 = bitcast<i32>((x_6707 + x_7573));
          let x_6810 : i32 = x_6803.x;
          let x_6819 : vec4<u32> = textureLoad(gs_wgpu_tex_cell_clip, vec2<i32>((x_6808 % x_6810), (x_6808 / x_6810)), 0i);
          if (!((dot(bitcast<vec4<f32>>(x_6819), x_3163) >= -0.00000999999974737875f))) {
            x_7578 = false;
            break;
          }

          continuing {
            x_6733 = (x_7573 + bitcast<u32>(1i));
            x_7573 = x_6733;
          }
        }
        if (x_7578) {
          x_7587 = true;
          x_7582 = true;
          break;
        }

        continuing {
          x_6740 = (x_7571 + bitcast<u32>(1i));
          x_7572 = (x_6707 + x_6705);
          x_7571 = x_6740;
        }
      }
      x_7586 = x_7587;
      if (x_7582) {
        break;
      }
      x_7586 = false;
    }
  }
  if (!(x_7586)) {
    discard;
  }
  let x_2551 : vec3<f32> = vec3<f32>(f32((x_3869 & 255u)), f32(((x_3869 >> 8u) & 255u)), f32(((x_3869 >> 16u) & 255u)));
  let x_2556 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_2551 * x_2551));
  let x_2566 : vec3<f32> = select((x_2556 * 12.9200000762939453125f), ((pow(x_2556, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_2556 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_2566.x, x_2566.y, x_2566.z, 1.0f);
  return;
}

struct main_out {
  @builtin(frag_depth)
  gl_FragDepth_1 : f32,
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(1) v2_param : vec3<f32>, @location(6) @interpolate(flat) v8_param : f32, @location(10) @interpolate(flat) v12_param : i32, @location(2) v3_param : vec3<f32>, @location(3) v4_param : vec3<f32>, @location(4) v5_param : f32, @location(5) v7_param : f32, @location(8) @interpolate(flat) v10_param : i32, @location(0) @interpolate(flat) v0_param : u32, @location(11) @interpolate(flat) v13_param : u32, @location(7) v9_param : vec2<f32>, @location(9) @interpolate(flat) v11_param : vec2<f32>, @builtin(position) gl_FragCoord_param : vec4<f32>, @location(15) @interpolate(flat) resident_cell_id_param : u32, @location(12) @interpolate(flat) v14_col0_param : vec3<f32>, @location(13) @interpolate(flat) v14_col1_param : vec3<f32>, @location(14) @interpolate(flat) v14_col2_param : vec3<f32>) -> main_out {
  v2 = v2_param;
  v8 = v8_param;
  v12 = v12_param;
  v3 = v3_param;
  v4 = v4_param;
  v5 = v5_param;
  v7 = v7_param;
  v10 = v10_param;
  v0 = v0_param;
  v13 = v13_param;
  v9 = v9_param;
  v11 = v11_param;
  gl_FragCoord = gl_FragCoord_param;
  resident_cell_id = resident_cell_id_param;
  v14_col0 = v14_col0_param;
  v14_col1 = v14_col1_param;
  v14_col2 = v14_col2_param;
  main_1();
  return main_out(gl_FragDepth, residentColor);
}
