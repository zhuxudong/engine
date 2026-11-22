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

@binding(0) @group(2) var<uniform> x_1072 : gs_Auto_0;

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

@binding(1) @group(2) var<uniform> x_2174 : gs_Auto_1;

@binding(26) @group(3) var gs_wgpu_tex_domain_counts : texture_2d<u32>;

@binding(27) @group(3) var gs_wgpu_samp_domain_counts : sampler;

var<private> residentColor : vec4<f32>;

var<private> v14_col0 : vec3<f32>;

var<private> v14_col1 : vec3<f32>;

var<private> v14_col2 : vec3<f32>;

const x_880 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_7283 = vec4<f32>(128.0f, 128.0f, 128.0f, 128.0f);

const x_7290 = vec4<f32>(0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f);

const x_1289 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_1444 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_1604 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_7294 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_1755 = vec3<f32>(289.0f, 289.0f, 289.0f);

const x_2026 = vec3<f32>(0.0f, 1.0f, 0.0f);

fn main_1() {
  var x_3963 : bool;
  var x_3965 : bool;
  var x_4017 : vec2<f32>;
  var x_4019 : vec2<f32>;
  var x_4021 : vec2<f32>;
  var x_4029 : f32;
  var x_4035 : f32;
  var x_6622 : f32;
  var x_6620 : vec2<f32>;
  var x_6618 : f32;
  var x_6616 : vec2<f32>;
  var x_6614 : vec2<f32>;
  var x_6612 : f32;
  var x_6621 : f32;
  var x_6619 : vec2<f32>;
  var x_6617 : f32;
  var x_6615 : vec2<f32>;
  var x_6613 : vec2<f32>;
  var x_6611 : f32;
  var x_2967 : bool;
  var x_2969 : bool;
  var x_2974 : bool;
  var x_2976 : bool;
  var x_3030 : bool;
  var x_6654 : bool;
  var x_3038 : bool;
  var x_6655 : bool;
  var x_3417 : vec3<f32>;
  var x_6842 : vec3<f32>;
  var x_6869 : vec3<f32>;
  var x_7029 : vec3<f32>;
  var x_3479 : bool;
  var x_7161 : bool;
  var x_7070 : vec3<f32>;
  var x_3487 : vec3<f32>;
  var x_7114 : vec3<f32>;
  var x_3665 : vec3<f32>;
  var x_7156 : vec3<f32>;
  var x_7218 : bool;
  var x_7217 : bool;
  let x_2377 : vec3<f32> = v14_col0;
  let x_2379 : vec3<f32> = v14_col1;
  let x_2381 : vec3<f32> = v14_col2;
  let x_2443 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_2448 : i32 = x_2443.x;
  let x_2455 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((20i % x_2448), (20i / x_2448)), 0i);
  let x_2467 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((21i % x_2448), (21i / x_2448)), 0i);
  let x_2479 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((22i % x_2448), (22i / x_2448)), 0i);
  let x_2491 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((23i % x_2448), (23i / x_2448)), 0i);
  let x_2503 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_2448), (63i / x_2448)), 0i);
  let x_2556 : mat4x4<f32> = mat4x4<f32>(vec4<f32>(bitcast<f32>(x_2455.x), bitcast<f32>(x_2467.x), bitcast<f32>(x_2479.x), bitcast<f32>(x_2491.x)), vec4<f32>(bitcast<f32>(x_2455.y), bitcast<f32>(x_2467.y), bitcast<f32>(x_2479.y), bitcast<f32>(x_2491.y)), vec4<f32>(bitcast<f32>(x_2455.z), bitcast<f32>(x_2467.z), bitcast<f32>(x_2479.z), bitcast<f32>(x_2491.z)), vec4<f32>(bitcast<f32>(x_2455.w), bitcast<f32>(x_2467.w), bitcast<f32>(x_2479.w), bitcast<f32>(x_2491.w)));
  let x_2560 : f32 = bitcast<f32>(x_2503.w);
  let x_2571 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ColorLibraryData_natural, 0i));
  let x_2576 : i32 = x_2571.x;
  let x_2583 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((28i % x_2576), (28i / x_2576)), 0i);
  let x_2595 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((30i % x_2576), (30i / x_2576)), 0i);
  let x_2607 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((31i % x_2576), (31i / x_2576)), 0i);
  let x_2620 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2583.x), bitcast<f32>(x_2583.y), bitcast<f32>(x_2583.z), 0.0f);
  let x_2634 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2595.x), bitcast<f32>(x_2595.y), bitcast<f32>(x_2595.z), 0.0f);
  let x_2648 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2607.x), bitcast<f32>(x_2607.y), bitcast<f32>(x_2607.z), 0.0f);
  let x_2660 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_2665 : i32 = x_2660.x;
  let x_2672 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_2665), (8i / x_2665)), 0i);
  let x_2684 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_2665), (17i / x_2665)), 0i);
  let x_2696 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_2665), (18i / x_2665)), 0i);
  let x_2708 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_2665), (19i / x_2665)), 0i);
  let x_2710 : u32 = x_2672.w;
  let x_2721 : vec3<f32> = vec3<f32>(bitcast<f32>(x_2684.x), 0.0f, bitcast<f32>(x_2684.z));
  let x_2725 : f32 = bitcast<f32>(x_2684.w);
  let x_2728 : u32 = x_2696.w;
  let x_2731 : u32 = x_2708.x;
  let x_2849 : f32 = v2.y;
  let x_2850 : f32 = v8;
  if ((x_2849 < x_2850)) {
    discard;
  }
  let x_2854 : i32 = v12;
  let x_2856 : bool = ((x_2854 & 8i) != 0i);
  let x_2859 : bool = ((x_2854 & 16i) != 0i);
  let x_2862 : bool = ((x_2854 & 2048i) != 0i);
  let x_2865 : vec4<f32> = (x_2556 * vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f));
  let x_2866 : vec3<f32> = v3;
  let x_2868 : vec3<f32> = ((x_2866 * 0.875f) + x_880);
  let x_3754 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3758 : i32 = x_3754.z;
  let x_3765 : f32 = f32((x_3758 - 1i));
  let x_3766 : f32 = clamp(((x_2868.z * f32(x_3758)) - 0.5f), 0.0f, x_3765);
  let x_3768 : f32 = floor(x_3766);
  let x_3782 : f32 = x_2868.x;
  let x_3783 : f32 = x_2868.y;
  let x_3785 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3782, x_3783, x_3768).xy, i32(round(vec3<f32>(x_3782, x_3783, x_3768).z)), 0.0f);
  let x_3795 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3782, x_3783, min((x_3768 + 1.0f), x_3765)).xy, i32(round(vec3<f32>(x_3782, x_3783, min((x_3768 + 1.0f), x_3765)).z)), 0.0f);
  let x_3798 : f32 = (x_3766 - x_3768);
  let x_2871 : f32 = ((((mix(x_3785, x_3795, vec4<f32>(x_3798, x_3798, x_3798, x_3798)) * 255.0f) - x_7283) * x_7290)).x;
  let x_2873 : f32 = (x_2871 * 0.25624999403953552246f);
  let x_2876 : vec3<f32> = v4;
  let x_2879 : vec3<f32> = ((x_2866 + x_880) + (x_2876 * x_2873));
  let x_2883 : vec3<f32> = (((x_2879 - x_880) * 0.875f) + x_880);
  let x_3816 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3820 : i32 = x_3816.z;
  let x_3827 : f32 = f32((x_3820 - 1i));
  let x_3828 : f32 = clamp(((x_2883.z * f32(x_3820)) - 0.5f), 0.0f, x_3827);
  let x_3830 : f32 = floor(x_3828);
  let x_3844 : f32 = x_2883.x;
  let x_3845 : f32 = x_2883.y;
  let x_3847 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3844, x_3845, x_3830).xy, i32(round(vec3<f32>(x_3844, x_3845, x_3830).z)), 0.0f);
  let x_3857 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3844, x_3845, min((x_3830 + 1.0f), x_3827)).xy, i32(round(vec3<f32>(x_3844, x_3845, min((x_3830 + 1.0f), x_3827)).z)), 0.0f);
  let x_3860 : f32 = (x_3828 - x_3830);
  let x_2886 : f32 = ((((mix(x_3847, x_3857, vec4<f32>(x_3860, x_3860, x_3860, x_3860)) * 255.0f) - x_7283) * x_7290)).x;
  let x_2888 : f32 = (x_2886 * 0.19099999964237213135f);
  let x_2893 : vec3<f32> = (x_2879 + (x_2876 * x_2888));
  let x_2897 : vec3<f32> = (((x_2893 - x_880) * 0.875f) + x_880);
  let x_3878 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3882 : i32 = x_3878.z;
  let x_3889 : f32 = f32((x_3882 - 1i));
  let x_3890 : f32 = clamp(((x_2897.z * f32(x_3882)) - 0.5f), 0.0f, x_3889);
  let x_3892 : f32 = floor(x_3890);
  let x_3906 : f32 = x_2897.x;
  let x_3907 : f32 = x_2897.y;
  let x_3909 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3906, x_3907, x_3892).xy, i32(round(vec3<f32>(x_3906, x_3907, x_3892).z)), 0.0f);
  let x_3919 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3906, x_3907, min((x_3892 + 1.0f), x_3889)).xy, i32(round(vec3<f32>(x_3906, x_3907, min((x_3892 + 1.0f), x_3889)).z)), 0.0f);
  let x_3922 : f32 = (x_3890 - x_3892);
  let x_2900 : f32 = ((((mix(x_3909, x_3919, vec4<f32>(x_3922, x_3922, x_3922, x_3922)) * 255.0f) - x_7283) * x_7290)).x;
  let x_2902 : f32 = (x_2900 * 0.16312499344348907471f);
  let x_2908 : vec3<f32> = ((x_2893 + (x_2876 * x_2902)) - x_880);
  let x_2910 : vec3<f32> = abs(x_2908);
  let x_2912 : f32 = x_2910.x;
  let x_2914 : f32 = x_2910.y;
  let x_2916 : f32 = x_2910.z;
  let x_2919 : bool = (max(x_2912, max(x_2914, x_2916)) < 0.4930000007152557373f);
  let x_2922 : f32 = (-1.0f + x_2560);
  let x_3947 : vec3<f32> = dpdx(x_2908);
  let x_3950 : vec3<f32> = -(dpdy(x_2908));
  let x_3957 : bool = (x_2912 >= x_2914);
  x_3965 = x_3957;
  if (x_3957) {
    x_3963 = (x_2912 >= x_2916);
    x_3965 = x_3963;
  }
  var x_3995 : vec2<f32>;
  var x_3997 : vec2<f32>;
  var x_3999 : vec2<f32>;
  var x_4007 : f32;
  var x_4013 : f32;
  var x_3974 : vec2<f32>;
  var x_3976 : vec2<f32>;
  var x_3978 : vec2<f32>;
  var x_3986 : f32;
  var x_3992 : f32;
  if (x_3965) {
    x_4017 = vec2<f32>(x_2908.y, x_2908.z);
    x_4019 = vec2<f32>(x_3947.y, x_3947.z);
    x_4021 = vec2<f32>(x_3950.y, x_3950.z);
    let x_4026 : f32 = sign(x_2908.x);
    x_4029 = (x_4026 * x_3947.x);
    x_4035 = (x_4026 * x_3950.x);
    x_6621 = x_4035;
    x_6619 = x_4021;
    x_6617 = x_4029;
    x_6615 = x_4017;
    x_6613 = x_4019;
    x_6611 = x_2912;
  } else {
    if ((x_2914 >= x_2916)) {
      x_3995 = vec2<f32>(x_2908.x, x_2908.z);
      x_3997 = vec2<f32>(x_3947.x, x_3947.z);
      x_3999 = vec2<f32>(x_3950.x, x_3950.z);
      let x_4004 : f32 = sign(x_2908.y);
      x_4007 = (x_4004 * x_3947.y);
      x_4013 = (x_4004 * x_3950.y);
      x_6622 = x_4013;
      x_6620 = x_3999;
      x_6618 = x_4007;
      x_6616 = x_3995;
      x_6614 = x_3997;
      x_6612 = x_2914;
    } else {
      x_3974 = vec2<f32>(x_2908.x, x_2908.y);
      x_3976 = vec2<f32>(x_3947.x, x_3947.y);
      x_3978 = vec2<f32>(x_3950.x, x_3950.y);
      let x_3983 : f32 = sign(x_2908.z);
      x_3986 = (x_3983 * x_3947.z);
      x_3992 = (x_3983 * x_3950.z);
      x_6622 = x_3992;
      x_6620 = x_3978;
      x_6618 = x_3986;
      x_6616 = x_3974;
      x_6614 = x_3976;
      x_6612 = x_2916;
    }
    x_6621 = x_6622;
    x_6619 = x_6620;
    x_6617 = x_6618;
    x_6615 = x_6616;
    x_6613 = x_6614;
    x_6611 = x_6612;
  }
  let x_4038 : f32 = max(x_6611, 0.00000099999999747524f);
  let x_4047 : f32 = (0.5f / x_4038);
  let x_4048 : vec2<f32> = ((x_6613 - (x_6615 * (x_6617 / x_4038))) * x_4047);
  let x_4058 : vec2<f32> = ((x_6619 - (x_6615 * (x_6621 / x_4038))) * x_4047);
  let x_4063 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf_normal, 0i).xy);
  let x_4065 : f32 = f32(x_4063.x);
  let x_4089 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf_normal, gs_wgpu_samp_material_data_brick_sdf_normal, x_2908, clamp(((0.5f * log2(max(((max(dot(x_4048, x_4048), dot(x_4058, x_4058)) * x_4065) * x_4065), 0.00000000999999993923f))) + x_2922), 0.0f, 2.0f));
  let x_2931 : vec3<f32> = (((vec3<f32>(x_4089.x, x_4089.y, x_4089.z) * 255.0f) - vec3<f32>(128.0f, 128.0f, 128.0f)) * vec3<f32>(0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f));
  if ((dot(x_2931, x_2876) > 0.0f)) {
    discard;
  }
  let x_2938 : vec3<f32> = v2;
  let x_2943 : f32 = x_2865.w;
  let x_2954 : f32 = v5;
  let x_2956 : vec3<f32> = (x_2938 + ((normalize((x_2938 - (vec3<f32>(x_2865.x, x_2865.y, x_2865.z) / vec3<f32>(x_2943, x_2943, x_2943)))) * ((x_2873 + x_2888) + x_2902)) * x_2954));
  let x_2961 : bool = ((x_2871 * 0.125f) <= 0.01499999966472387314f);
  x_2969 = x_2961;
  if (!(x_2961)) {
    x_2967 = ((x_2886 * 0.125f) <= 0.01499999966472387314f);
    x_2969 = x_2967;
  }
  x_2976 = x_2969;
  if (!(x_2969)) {
    x_2974 = ((x_2900 * 0.125f) <= 0.01499999966472387314f);
    x_2976 = x_2974;
  }
  if (!(x_2976)) {
    discard;
  }
  let x_3015 : vec3<f32> = (x_2931 * mat3x3<f32>(vec3<f32>(x_2377.x, x_2379.x, x_2381.x), vec3<f32>(x_2377.y, x_2379.y, x_2381.y), vec3<f32>(x_2377.z, x_2379.z, x_2381.z)));
  let x_3018 : mat4x4<f32> = x_1072.renderer_MVPMat;
  let x_3024 : vec4<f32> = (x_3018 * vec4<f32>(x_2956.x, x_2956.y, x_2956.z, 1.0f));
  if (!(x_2856)) {
    let x_3029 : f32 = v7;
    x_3030 = (x_3029 > -2.5f);
    x_6654 = x_3030;
  } else {
    x_6654 = false;
  }
  if (x_6654) {
    let x_3037 : f32 = v7;
    x_3038 = (x_2849 < x_3037);
    x_6655 = x_3038;
  } else {
    x_6655 = false;
  }
  var x_3048 : bool;
  var x_6658 : bool;
  if (x_6655) {
    discard;
  } else {
    if (x_2856) {
      let x_3047 : f32 = v7;
      x_3048 = (x_2849 > x_3047);
      x_6658 = x_3048;
    } else {
      x_6658 = false;
    }
    if (x_6658) {
      discard;
    }
  }
  var x_3055 : i32;
  var x_3056 : u32;
  var x_3137 : vec2<f32>;
  var x_3065 : vec2<f32>;
  var x_6680 : vec2<f32>;
  var x_3144 : vec2<f32>;
  var x_6743 : vec2<f32>;
  var x_3150 : bool;
  var x_6686 : bool;
  var x_3164 : vec3<f32>;
  var x_3159 : vec3<f32>;
  var x_6781 : vec3<f32>;
  var x_3172 : bool;
  var x_6717 : bool;
  var x_3178 : bool;
  var x_6719 : bool;
  var x_3184 : bool;
  var x_6721 : bool;
  var x_3291 : vec3<f32>;
  var x_6747 : vec3<f32>;
  var x_6765 : vec3<f32>;
  var x_3298 : bool;
  var x_6761 : bool;
  var x_3304 : bool;
  var x_6782 : bool;
  var x_3348 : vec3<f32>;
  var x_6802 : vec3<f32>;
  var x_3395 : vec3<f32>;
  x_3055 = v10;
  x_3056 = bitcast<u32>(x_3055);
  if (((x_2854 & 2i) != 0i)) {
    let x_3402 : u32 = v0;
    let x_3409 : vec2<f32> = ((vec2<f32>(vec2<u32>(x_3402, x_3402)) * 0.20000000298023223877f) + (vec2<f32>(x_2938.x, x_2938.z) * 0.20000000298023223877f));
    let x_3415 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_3409.x, x_3409.y, f32(x_3056)).xy, i32(round(vec3<f32>(x_3409.x, x_3409.y, f32(x_3056)).z)));
    x_3417 = (vec3<f32>(x_3415.x, x_3415.y, x_3415.z) * 0.69999998807907104492f);
    x_6869 = x_3417;
  } else {
    var x_3090 : vec2<f32>;
    var x_6665 : vec2<f32>;
    var x_6676 : vec2<f32>;
    var x_3102 : vec2<f32>;
    var x_6677 : vec2<f32>;
    if (((x_2854 & 32i) != 0i)) {
      var x_3068 : vec3<f32>;
      var x_3084 : vec2<f32>;
      var x_3080 : vec2<f32>;
      x_3068 = normalize(x_3015);
      if ((x_3068.y > 0.89999997615814208984f)) {
        x_3090 = (vec2<f32>(x_2956.x, x_2956.z) * 0.69999998807907104492f);
        x_6676 = x_3090;
      } else {
        if ((abs(x_3068.x) > 0.89999997615814208984f)) {
          x_3084 = (vec2<f32>(x_2956.z, x_2956.y) * 0.69999998807907104492f);
          x_6665 = x_3084;
        } else {
          x_3080 = (vec2<f32>(x_2956.x, x_2956.y) * 0.69999998807907104492f);
          x_6665 = x_3080;
        }
        x_6676 = x_6665;
      }
      if (x_2919) {
        let x_3096 : u32 = v13;
        let x_4196 : i32 = ((bitcast<i32>(x_3096) * 16i) + 11i);
        let x_4528 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_4533 : i32 = (x_4196 / 4i);
        let x_4535 : i32 = x_4528.x;
        let x_4544 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4533 % x_4535), (x_4533 / x_4535)), 0i);
        let x_3101 : f32 = unpack2x16float(x_4544[(x_4196 % 4i)]).y;
        x_3102 = vec2<f32>(x_3101, x_3101);
        x_6677 = x_3102;
      } else {
        x_6677 = x_6676;
      }
      let x_3104 : u32 = v13;
      let x_4775 : i32 = ((bitcast<i32>(x_3104) * 16i) + 13i);
      let x_5147 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_5152 : i32 = (x_4775 / 4i);
      let x_5154 : i32 = x_5147.x;
      let x_5163 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5152 % x_5154), (x_5152 / x_5154)), 0i);
      let x_5165 : i32 = (x_4775 % 4i);
      let x_5712 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_5719 : i32 = x_5712.x;
      let x_5728 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5152 % x_5719), (x_5152 / x_5719)), 0i);
      let x_3113 : u32 = (x_5163[x_5165] + (x_5728[x_5165] << 10u));
      let x_3117 : u32 = (x_3113 ^ (x_3113 >> 6u));
      let x_3121 : u32 = (x_3117 + (x_3117 << 3u));
      let x_3125 : u32 = (x_3121 ^ (x_3121 >> 11u));
      let x_3135 : f32 = (bitcast<f32>((((x_3125 + (x_3125 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
      x_3137 = ((x_6677 * 0.30000001192092895508f) + vec2<f32>(x_3135, x_3135));
      x_6680 = x_3137;
    } else {
      x_3065 = v9;
      x_6680 = x_3065;
    }
    if (x_2919) {
      x_3144 = (x_6680 + vec2<f32>(0.20999999344348907471f, 0.20999999344348907471f));
      x_6743 = x_3144;
    } else {
      x_6743 = x_6680;
    }
    if ((x_3056 == 1u)) {
      x_6686 = true;
    } else {
      x_3150 = (x_3056 == 0u);
      x_6686 = x_3150;
    }
    if (x_6686) {
      x_3164 = pow(vec3<f32>(x_2648.x, x_2648.y, x_2648.z), vec3<f32>(1.29999995231628417969f, 1.29999995231628417969f, 1.29999995231628417969f));
      x_6781 = x_3164;
    } else {
      x_3159 = (pow(vec3<f32>(x_2634.x, x_2634.y, x_2634.z), x_1289) * 0.80000001192092895508f);
      x_6781 = x_3159;
    }
    if ((x_3055 == 0i)) {
      x_6717 = true;
    } else {
      x_3172 = (x_3055 == 4i);
      x_6717 = x_3172;
    }
    if (x_6717) {
      x_6719 = true;
    } else {
      x_3178 = (x_3055 == 10i);
      x_6719 = x_3178;
    }
    if (x_6719) {
      x_6721 = true;
    } else {
      x_3184 = (x_3055 == 12i);
      x_6721 = x_3184;
    }
    var x_3193 : bool;
    var x_6723 : bool;
    var x_3278 : vec3<f32>;
    var x_6746 : vec3<f32>;
    if (x_6721) {
      let x_3286 : vec2<f32> = (x_6743 + vec2<f32>(0.85000002384185791016f, 0.85000002384185791016f));
      let x_3290 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3286.x, x_3286.y, 0.0f).xy, i32(round(vec3<f32>(x_3286.x, x_3286.y, 0.0f).z)));
      x_3291 = vec3<f32>(x_3290.x, x_3290.y, x_3290.z);
      x_6765 = x_3291;
    } else {
      if ((x_3055 == 1i)) {
        x_6723 = true;
      } else {
        x_3193 = (x_3055 == 5i);
        x_6723 = x_3193;
      }
      var x_3202 : bool;
      var x_6725 : bool;
      var x_3264 : vec3<f32>;
      var x_6745 : vec3<f32>;
      if (x_6723) {
        let x_3272 : vec2<f32> = (x_6743 + vec2<f32>(0.44999998807907104492f, 0.44999998807907104492f));
        let x_3276 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3272.x, x_3272.y, 1.0f).xy, i32(round(vec3<f32>(x_3272.x, x_3272.y, 1.0f).z)));
        x_3278 = pow(vec3<f32>(x_3276.x, x_3276.y, x_3276.z), vec3<f32>(1.10000002384185791016f, 1.10000002384185791016f, 1.10000002384185791016f));
        x_6747 = x_3278;
      } else {
        if ((x_3055 == 2i)) {
          x_6725 = true;
        } else {
          x_3202 = (x_3055 == 7i);
          x_6725 = x_3202;
        }
        var x_3211 : bool;
        var x_6727 : bool;
        var x_3217 : bool;
        var x_6729 : bool;
        var x_3223 : bool;
        var x_6731 : bool;
        var x_3252 : vec3<f32>;
        var x_6744 : vec3<f32>;
        if (x_6725) {
          let x_3263 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_6743.x, x_6743.y, 2.0f).xy, i32(round(vec3<f32>(x_6743.x, x_6743.y, 2.0f).z)));
          x_3264 = vec3<f32>(x_3263.x, x_3263.y, x_3263.z);
          x_6746 = x_3264;
        } else {
          if ((x_3055 == 3i)) {
            x_6727 = true;
          } else {
            x_3211 = (x_3055 == 6i);
            x_6727 = x_3211;
          }
          if (x_6727) {
            x_6729 = true;
          } else {
            x_3217 = (x_3055 == 8i);
            x_6729 = x_3217;
          }
          if (x_6729) {
            x_6731 = true;
          } else {
            x_3223 = (x_3055 == 9i);
            x_6731 = x_3223;
          }
          var x_3240 : vec3<f32>;
          if (x_6731) {
            let x_3251 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_6743.x, x_6743.y, 3.0f).xy, i32(round(vec3<f32>(x_6743.x, x_6743.y, 3.0f).z)));
            x_3252 = vec3<f32>(x_3251.x, x_3251.y, x_3251.z);
            x_6745 = x_3252;
          } else {
            if ((x_3055 == 11i)) {
              let x_3239 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_6743.x, x_6743.y, 4.0f).xy, i32(round(vec3<f32>(x_6743.x, x_6743.y, 4.0f).z)));
              x_3240 = vec3<f32>(x_3239.x, x_3239.y, x_3239.z);
              x_6744 = x_3240;
            } else {
              x_6744 = x_1444;
            }
            x_6745 = x_6744;
          }
          x_6746 = x_6745;
        }
        x_6747 = x_6746;
      }
      x_6765 = x_6747;
    }
    let x_3294 : bool = (x_3056 == 7u);
    if (x_3294) {
      x_6761 = true;
    } else {
      x_3298 = (x_3056 == 2u);
      x_6761 = x_3298;
    }
    if (x_6761) {
      x_6782 = true;
    } else {
      x_3304 = (x_3056 == 11u);
      x_6782 = x_3304;
    }
    if (((x_2854 & 512i) != 0i)) {
      let x_3313 : u32 = v0;
      let x_3314 : u32 = (x_3313 ^ 8902390u);
      let x_3318 : u32 = (x_3314 + (x_3314 << 10u));
      let x_3322 : u32 = (x_3318 ^ (x_3318 >> 6u));
      let x_3326 : u32 = (x_3322 + (x_3322 << 3u));
      let x_3330 : u32 = (x_3326 ^ (x_3326 >> 11u));
      let x_3346 : f32 = mix(0.0f, 0.5f, smoothstep(0.20000000298023223877f, 0.80000001192092895508f, (bitcast<f32>((((x_3330 + (x_3330 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_3348 = mix(x_6765, select(x_6781, x_6765, vec3<bool>(x_6782, x_6782, x_6782)), vec3<f32>(x_3346, x_3346, x_3346));
      x_6802 = x_3348;
    } else {
      x_6802 = x_6765;
    }
    var x_3357 : bool;
    var x_6841 : bool;
    if (x_2919) {
      if (x_3294) {
        x_6841 = true;
      } else {
        x_3357 = (x_3056 == 2u);
        x_6841 = x_3357;
      }
      let x_3360 : u32 = v0;
      let x_3361 : u32 = (x_3360 ^ 239085u);
      let x_3365 : u32 = (x_3361 + (x_3361 << 10u));
      let x_3369 : u32 = (x_3365 ^ (x_3365 >> 6u));
      let x_3373 : u32 = (x_3369 + (x_3369 << 3u));
      let x_3377 : u32 = (x_3373 ^ (x_3373 >> 11u));
      let x_3393 : f32 = mix(0.0f, select(0.40000000596046447754f, 0.20000000298023223877f, x_6841), smoothstep(0.0f, 0.80000001192092895508f, (bitcast<f32>((((x_3377 + (x_3377 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_3395 = mix(x_6802, vec3<f32>(x_2620.x, x_2620.y, x_2620.z), vec3<f32>(x_3393, x_3393, x_3393));
      x_6842 = x_3395;
    } else {
      x_6842 = x_6802;
    }
    x_6869 = x_6842;
  }
  var x_3453 : vec3<f32>;
  var x_3440 : bool;
  var x_6907 : vec3<f32>;
  var x_7028 : bool;
  var x_7021 : vec3<f32>;
  var x_3468 : bool;
  var x_7019 : bool;
  var x_3475 : vec3<f32>;
  let x_3420 : vec3<f32> = normalize(x_3015);
  if (((x_2854 & 64i) == 0i)) {
    var x_7312 : u32;
    var x_3446 : vec3<f32>;
    x_7312 = select(0u, x_2728, ((x_2854 & 4096i) != 0i));
    if ((x_7312 == 1u)) {
      x_3453 = mix(x_6869, x_1604, x_880);
      x_7028 = true;
      x_7021 = x_3453;
    } else {
      x_3440 = (x_7312 == 2u);
      if (x_3440) {
        x_3446 = mix(x_6869, x_880, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_6907 = x_3446;
      } else {
        x_6907 = x_6869;
      }
      x_7028 = x_3440;
      x_7021 = x_6907;
    }
    if ((x_2731 == 1u)) {
      let x_3463 : vec2<f32> = v11;
      x_3468 = (distance(vec2<f32>(x_2721.x, x_2721.z), x_3463) < (1.88900005817413330078f * x_2725));
      x_7019 = x_3468;
    } else {
      x_7019 = false;
    }
    if (x_7019) {
      x_3475 = mix(x_6869, x_1604, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_7029 = x_3475;
    } else {
      x_7029 = x_7021;
    }
    x_3479 = select(x_7028, true, x_7019);
    x_7161 = x_3479;
    x_7070 = x_7029;
  } else {
    x_7161 = false;
    x_7070 = x_6869;
  }
  if (x_2862) {
    x_3487 = mix(x_6869, x_1604, x_880);
    x_7114 = x_3487;
  } else {
    x_7114 = x_7070;
  }
  if ((x_2710 == 4u)) {
    let x_3497 : vec2<f32> = (vec2<f32>(x_2938.x, x_2938.z) * 0.40000000596046447754f);
    let x_3500 : f32 = dot(x_3497, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
    let x_3503 : vec2<f32> = floor((x_3497 + vec2<f32>(x_3500, x_3500)));
    let x_3508 : f32 = dot(x_3503, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
    let x_3510 : vec2<f32> = ((x_3497 - x_3503) + vec2<f32>(x_3508, x_3508));
    let x_3512 : f32 = x_3510.x;
    let x_3514 : f32 = x_3510.y;
    let x_3517 : bool = (x_3512 > x_3514);
    let x_3519 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_3517, x_3517));
    let x_3522 : vec4<f32> = (vec4<f32>(x_3510.x, x_3510.y, x_3510.x, x_3510.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
    let x_3526 : vec2<f32> = (vec2<f32>(x_3522.x, x_3522.y) - x_3519);
    var x_7440_1 : vec4<f32> = x_3522;
    x_7440_1.x = x_3526.x;
    let x_7440 : vec4<f32> = x_7440_1;
    var x_7443_1 : vec4<f32> = x_7440;
    x_7443_1.y = x_3526.y;
    let x_7443 : vec4<f32> = x_7443_1;
    let x_3539 : vec2<f32> = (x_3503 - (vec2<f32>(289.0f, 289.0f) * trunc((x_3503 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
    let x_3541 : f32 = x_3539.y;
    let x_3546 : vec3<f32> = (vec3<f32>(x_3541, x_3541, x_3541) + vec3<f32>(0.0f, x_3519.y, 1.0f));
    let x_3551 : vec3<f32> = (((x_3546 * 34.0f) + x_1289) * x_3546);
    let x_3559 : f32 = x_3539.x;
    let x_3565 : vec3<f32> = (((x_3551 - (x_1755 * trunc((x_3551 * x_7294)))) + vec3<f32>(x_3559, x_3559, x_3559)) + vec3<f32>(0.0f, x_3519.x, 1.0f));
    let x_3570 : vec3<f32> = (((x_3565 * 34.0f) + x_1289) * x_3565);
    let x_3575 : vec2<f32> = vec2<f32>(x_7443.x, x_7443.y);
    let x_3580 : vec2<f32> = vec2<f32>(x_7443.z, x_7443.w);
    let x_3586 : vec3<f32> = max((x_880 - vec3<f32>(dot(x_3510, x_3510), dot(x_3575, x_3575), dot(x_3580, x_3580))), x_1444);
    let x_3589 : vec3<f32> = (x_3586 * x_3586);
    let x_3598 : vec3<f32> = (fract(((x_3570 - (x_1755 * trunc((x_3570 * x_7294)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
    let x_3600 : vec3<f32> = (x_3598 - x_1289);
    let x_3603 : vec3<f32> = (abs(x_3600) - x_880);
    let x_3608 : vec3<f32> = (x_3600 - floor((x_3598 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
    let x_3650 : vec2<f32> = ((vec2<f32>(x_3608.y, x_3608.z) * vec2<f32>(x_7443.x, x_7443.z)) + (vec2<f32>(x_3603.y, x_3603.z) * vec2<f32>(x_7443.y, x_7443.w)));
    let x_3663 : f32 = (smoothstep(0.0f, 1.0f, (smoothstep(-0.10000000149011611938f, 0.0f, x_2849) * clamp(x_3420.y, 0.0f, 1.0f))) * clamp(clamp(((130.0f * dot(((x_3589 * x_3589) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_3608 * x_3608) + (x_3603 * x_3603)) * 0.85373473167419433594f))), vec3<f32>(((x_3608.x * x_3512) + (x_3603.x * x_3514)), x_3650.x, x_3650.y))) + 0.75f), 0.0f, 1.0f), select(0.40000000596046447754f, 0.0f, x_2859), select(1.0f, 0.10000000149011611938f, x_2859)));
    x_3665 = mix(x_7114, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_3663, x_3663, x_3663));
    x_7156 = x_3665;
  } else {
    x_7156 = x_7114;
  }
  var x_2393 : u32;
  var x_7199 : u32;
  var x_7211 : bool;
  let x_3672 : vec3<f32> = sqrt(clamp(x_7156, x_1444, x_1289));
  let x_3729 : u32 = (((u32(((clamp(x_3672.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_3672.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_3672.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(2264924160u, 2399141888u, select(x_7161, true, x_2862)));
  let x_3740 : f32 = gl_FragCoord.z;
  gl_FragDepth = clamp(max((((x_3024.z / x_3024.w) * 0.5f) + 0.5f), x_3740), 0.0f, 1.0f);
  x_2393 = v13;
  switch(0u) {
    default: {
      let x_5818 : i32 = (bitcast<i32>(x_2393) * 16i);
      let x_5820 : i32 = (x_5818 + 15i);
      let x_5937 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_roof, 0i));
      let x_5942 : i32 = (x_5820 / 4i);
      let x_5944 : i32 = x_5937.x;
      let x_5953 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_roof, vec2<i32>((x_5942 % x_5944), (x_5942 / x_5944)), 0i);
      if ((x_5953[(x_5820 % 4i)] == 0u)) {
        x_7217 = false;
        break;
      }
      let x_5826 : i32 = (x_5818 + 10i);
      let x_5964 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_roof, 0i));
      let x_5969 : i32 = (x_5826 / 4i);
      let x_5971 : i32 = x_5964.x;
      let x_5980 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_roof, vec2<i32>((x_5969 % x_5971), (x_5969 / x_5971)), 0i);
      let x_5983 : u32 = x_5980[(x_5826 % 4i)];
      let x_5831 : vec4<f32> = x_2174.renderer_DormerGrid;
      let x_5839 : vec2<i32> = vec2<i32>(floor(((vec2<f32>(x_2956.x, x_2956.z) - vec2<f32>(x_5831.x, x_5831.y)) * vec2<f32>(x_5831.z, x_5831.w))));
      let x_5845 : i32 = (x_5839.x + (15i * x_5839.y));
      if (((x_5845 < 0i) | (x_5845 >= 225i))) {
        x_7217 = false;
        break;
      }
      let x_5991 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_counts, 0i));
      let x_5996 : i32 = (x_5845 / 4i);
      let x_5998 : i32 = x_5991.x;
      let x_6007 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_counts, vec2<i32>((x_5996 % x_5998), (x_5996 / x_5998)), 0i);
      let x_5855 : u32 = min(128u, x_6007[(x_5845 % 4i)]);
      x_7199 = 0u;
      loop {
        var x_7206 : bool;
        var x_5919 : bool;
        var x_5924 : u32;
        x_7218 = false;
        x_7211 = false;
        if ((x_7199 < x_5855)) {
        } else {
          break;
        }
        var x_5876 : vec3<f32>;
        var x_5890 : vec3<f32>;
        var x_6268 : f32;
        var x_6301 : f32;
        var x_6334 : f32;
        var x_6367 : f32;
        var x_7204 : bool;
        var x_7205 : bool;
        var x_6521 : bool;
        let x_5867 : i32 = (((x_5845 * 50i) + bitcast<i32>(x_7199)) * 12i);
        let x_6024 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6029 : i32 = (x_5867 / 4i);
        let x_6031 : i32 = x_6024.x;
        let x_6040 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6029 % x_6031), (x_6029 / x_6031)), 0i);
        let x_5871 : i32 = (x_5867 + 1i);
        let x_6057 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6062 : i32 = (x_5871 / 4i);
        let x_6064 : i32 = x_6057.x;
        let x_6073 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6062 % x_6064), (x_6062 / x_6064)), 0i);
        let x_5874 : i32 = (x_5867 + 2i);
        let x_6090 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6095 : i32 = (x_5874 / 4i);
        let x_6097 : i32 = x_6090.x;
        let x_6106 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6095 % x_6097), (x_6095 / x_6097)), 0i);
        x_5876 = vec3<f32>(bitcast<f32>(x_6040[(x_5867 % 4i)]), bitcast<f32>(x_6073[(x_5871 % 4i)]), bitcast<f32>(x_6106[(x_5874 % 4i)]));
        let x_5878 : i32 = (x_5867 + 3i);
        let x_6117 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6122 : i32 = (x_5878 / 4i);
        let x_6124 : i32 = x_6117.x;
        let x_6133 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6122 % x_6124), (x_6122 / x_6124)), 0i);
        let x_5882 : i32 = (x_5867 + 4i);
        let x_6150 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6155 : i32 = (x_5882 / 4i);
        let x_6157 : i32 = x_6150.x;
        let x_6166 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6155 % x_6157), (x_6155 / x_6157)), 0i);
        let x_5885 : i32 = (x_5867 + 5i);
        let x_6183 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6188 : i32 = (x_5885 / 4i);
        let x_6190 : i32 = x_6183.x;
        let x_6199 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6188 % x_6190), (x_6188 / x_6190)), 0i);
        let x_5888 : i32 = (x_5867 + 6i);
        let x_6216 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6221 : i32 = (x_5888 / 4i);
        let x_6223 : i32 = x_6216.x;
        let x_6232 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6221 % x_6223), (x_6221 / x_6223)), 0i);
        x_5890 = vec3<f32>(bitcast<f32>(x_6166[(x_5882 % 4i)]), bitcast<f32>(x_6199[(x_5885 % 4i)]), bitcast<f32>(x_6232[(x_5888 % 4i)]));
        let x_5896 : i32 = (x_5867 + 8i);
        let x_6276 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6281 : i32 = (x_5896 / 4i);
        let x_6283 : i32 = x_6276.x;
        let x_6292 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6281 % x_6283), (x_6281 / x_6283)), 0i);
        x_6268 = bitcast<f32>(x_6292[(x_5896 % 4i)]);
        let x_5899 : i32 = (x_5867 + 9i);
        let x_6309 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6314 : i32 = (x_5899 / 4i);
        let x_6316 : i32 = x_6309.x;
        let x_6325 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6314 % x_6316), (x_6314 / x_6316)), 0i);
        x_6301 = bitcast<f32>(x_6325[(x_5899 % 4i)]);
        let x_5903 : i32 = (x_5867 + 10i);
        let x_6342 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6347 : i32 = (x_5903 / 4i);
        let x_6349 : i32 = x_6342.x;
        let x_6358 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6347 % x_6349), (x_6347 / x_6349)), 0i);
        x_6334 = bitcast<f32>(x_6358[(x_5903 % 4i)]);
        let x_5906 : i32 = (x_5867 + 11i);
        let x_6375 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_6380 : i32 = (x_5906 / 4i);
        let x_6382 : i32 = x_6375.x;
        let x_6391 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_6380 % x_6382), (x_6380 / x_6382)), 0i);
        x_6367 = bitcast<f32>(x_6391[(x_5906 % 4i)]);
        let x_5913 : bool = (x_6133[(x_5878 % 4i)] == x_5983);
        x_5919 = x_5913;
        if (x_5913) {
          var x_6481 : f32;
          var x_6511 : bool;
          let x_6414 : vec3<f32> = vec3<f32>(x_6268, 0.0f, x_6301);
          let x_6431 : mat3x3<f32> = transpose(mat3x3<f32>(cross(x_6414, x_2026), x_2026, x_6414));
          let x_6433 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_6431);
          let x_6435 : vec3<f32> = (x_2026 * x_6431);
          let x_6437 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_6431);
          let x_6440 : vec3<f32> = cross(x_6433, x_6435);
          let x_6444 : f32 = (1.0f / dot(x_6437, x_6440));
          let x_6445 : vec3<f32> = vec3<f32>(x_6444, x_6444, x_6444);
          let x_6479 : vec3<f32> = ((mat3x3<f32>((cross(x_6435, x_6437) * x_6445), (cross(x_6437, x_6433) * x_6445), (x_6440 * x_6445)) * (x_2956 - x_5876)) / x_5890);
          x_6481 = x_6479.y;
          let x_6489 : f32 = clamp(((x_6481 * x_6334) + x_6367), 0.0f, 1.0f);
          if ((abs(x_6479.x) < mix(0.5f, 0.0f, ((x_6489 * x_6489) * x_6489)))) {
            if ((x_6481 < select(0.69999998807907104492f, 0.5f, (x_6334 == 1.0f)))) {
              x_6511 = (x_6481 > -0.5f);
              x_7204 = x_6511;
            } else {
              x_7204 = false;
            }
            x_7205 = x_7204;
          } else {
            x_7205 = false;
          }
          if (x_7205) {
            x_6521 = (abs(x_6479.z) < 0.5f);
            x_7206 = x_6521;
          } else {
            x_7206 = false;
          }
          x_5919 = x_7206;
        }
        if (x_5919) {
          x_7218 = true;
          x_7211 = true;
          break;
        }

        continuing {
          x_5924 = (x_7199 + bitcast<u32>(1i));
          x_7199 = x_5924;
        }
      }
      x_7217 = x_7218;
      if (x_7211) {
        break;
      }
      x_7217 = false;
    }
  }
  if (x_7217) {
    discard;
  }
  let x_2411 : vec3<f32> = vec3<f32>(f32((x_3729 & 255u)), f32(((x_3729 >> 8u) & 255u)), f32(((x_3729 >> 16u) & 255u)));
  let x_2416 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_2411 * x_2411));
  let x_2426 : vec3<f32> = select((x_2416 * 12.9200000762939453125f), ((pow(x_2416, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_2416 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_2426.x, x_2426.y, x_2426.z, 1.0f);
  return;
}

struct main_out {
  @builtin(frag_depth)
  gl_FragDepth_1 : f32,
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(1) v2_param : vec3<f32>, @location(6) @interpolate(flat) v8_param : f32, @location(10) @interpolate(flat) v12_param : i32, @location(2) v3_param : vec3<f32>, @location(3) v4_param : vec3<f32>, @location(4) v5_param : f32, @location(5) v7_param : f32, @location(8) @interpolate(flat) v10_param : i32, @location(0) @interpolate(flat) v0_param : u32, @location(11) @interpolate(flat) v13_param : u32, @location(7) v9_param : vec2<f32>, @location(9) @interpolate(flat) v11_param : vec2<f32>, @builtin(position) gl_FragCoord_param : vec4<f32>, @location(12) @interpolate(flat) v14_col0_param : vec3<f32>, @location(13) @interpolate(flat) v14_col1_param : vec3<f32>, @location(14) @interpolate(flat) v14_col2_param : vec3<f32>) -> main_out {
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
  v14_col0 = v14_col0_param;
  v14_col1 = v14_col1_param;
  v14_col2 = v14_col2_param;
  main_1();
  return main_out(gl_FragDepth, residentColor);
}
