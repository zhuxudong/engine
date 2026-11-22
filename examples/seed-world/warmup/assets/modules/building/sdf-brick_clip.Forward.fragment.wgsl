diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(4) @group(3) var gs_wgpu_tex_storage_0_1 : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_storage_0_1 : sampler;

@binding(3) @group(2) var gs_wgpu_tex_material_data_brick_sdf_normal : texture_cube<f32>;

@binding(4) @group(2) var gs_wgpu_samp_material_data_brick_sdf_normal : sampler;

@binding(1) @group(2) var gs_wgpu_tex_material_data_brick_sdf : texture_2d_array<f32>;

@binding(2) @group(2) var gs_wgpu_samp_material_data_brick_sdf : sampler;

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

@binding(0) @group(2) var<uniform> x_1059 : gs_Auto_0;

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

@binding(24) @group(3) var gs_wgpu_tex_cell_clip : texture_2d<u32>;

@binding(25) @group(3) var gs_wgpu_samp_cell_clip : sampler;

var<private> resident_cell_id : u32;

var<private> residentColor : vec4<f32>;

var<private> v14_col0 : vec3<f32>;

var<private> v14_col1 : vec3<f32>;

var<private> v14_col2 : vec3<f32>;

const x_867 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_6429 = vec4<f32>(128.0f, 128.0f, 128.0f, 128.0f);

const x_6436 = vec4<f32>(0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f);

const x_1276 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_1431 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_1591 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_6440 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_1742 = vec3<f32>(289.0f, 289.0f, 289.0f);

fn main_1() {
  var x_3742 : bool;
  var x_3744 : bool;
  var x_3796 : vec2<f32>;
  var x_3798 : vec2<f32>;
  var x_3800 : vec2<f32>;
  var x_3808 : f32;
  var x_3814 : f32;
  var x_5786 : f32;
  var x_5784 : vec2<f32>;
  var x_5782 : f32;
  var x_5780 : vec2<f32>;
  var x_5778 : vec2<f32>;
  var x_5776 : f32;
  var x_5785 : f32;
  var x_5783 : vec2<f32>;
  var x_5781 : f32;
  var x_5779 : vec2<f32>;
  var x_5777 : vec2<f32>;
  var x_5775 : f32;
  var x_2746 : bool;
  var x_2748 : bool;
  var x_2753 : bool;
  var x_2755 : bool;
  var x_2809 : bool;
  var x_5818 : bool;
  var x_2817 : bool;
  var x_5819 : bool;
  var x_3196 : vec3<f32>;
  var x_6006 : vec3<f32>;
  var x_6033 : vec3<f32>;
  var x_6193 : vec3<f32>;
  var x_3258 : bool;
  var x_6325 : bool;
  var x_6234 : vec3<f32>;
  var x_3266 : vec3<f32>;
  var x_6278 : vec3<f32>;
  var x_3444 : vec3<f32>;
  var x_6320 : vec3<f32>;
  var x_6379 : bool;
  var x_6378 : bool;
  let x_2155 : vec3<f32> = v14_col0;
  let x_2157 : vec3<f32> = v14_col1;
  let x_2159 : vec3<f32> = v14_col2;
  let x_2222 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_2227 : i32 = x_2222.x;
  let x_2234 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((20i % x_2227), (20i / x_2227)), 0i);
  let x_2246 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((21i % x_2227), (21i / x_2227)), 0i);
  let x_2258 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((22i % x_2227), (22i / x_2227)), 0i);
  let x_2270 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((23i % x_2227), (23i / x_2227)), 0i);
  let x_2282 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_2227), (63i / x_2227)), 0i);
  let x_2335 : mat4x4<f32> = mat4x4<f32>(vec4<f32>(bitcast<f32>(x_2234.x), bitcast<f32>(x_2246.x), bitcast<f32>(x_2258.x), bitcast<f32>(x_2270.x)), vec4<f32>(bitcast<f32>(x_2234.y), bitcast<f32>(x_2246.y), bitcast<f32>(x_2258.y), bitcast<f32>(x_2270.y)), vec4<f32>(bitcast<f32>(x_2234.z), bitcast<f32>(x_2246.z), bitcast<f32>(x_2258.z), bitcast<f32>(x_2270.z)), vec4<f32>(bitcast<f32>(x_2234.w), bitcast<f32>(x_2246.w), bitcast<f32>(x_2258.w), bitcast<f32>(x_2270.w)));
  let x_2339 : f32 = bitcast<f32>(x_2282.w);
  let x_2350 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ColorLibraryData_natural, 0i));
  let x_2355 : i32 = x_2350.x;
  let x_2362 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((28i % x_2355), (28i / x_2355)), 0i);
  let x_2374 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((30i % x_2355), (30i / x_2355)), 0i);
  let x_2386 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((31i % x_2355), (31i / x_2355)), 0i);
  let x_2399 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2362.x), bitcast<f32>(x_2362.y), bitcast<f32>(x_2362.z), 0.0f);
  let x_2413 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2374.x), bitcast<f32>(x_2374.y), bitcast<f32>(x_2374.z), 0.0f);
  let x_2427 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2386.x), bitcast<f32>(x_2386.y), bitcast<f32>(x_2386.z), 0.0f);
  let x_2439 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_2444 : i32 = x_2439.x;
  let x_2451 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_2444), (8i / x_2444)), 0i);
  let x_2463 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_2444), (17i / x_2444)), 0i);
  let x_2475 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_2444), (18i / x_2444)), 0i);
  let x_2487 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_2444), (19i / x_2444)), 0i);
  let x_2489 : u32 = x_2451.w;
  let x_2500 : vec3<f32> = vec3<f32>(bitcast<f32>(x_2463.x), 0.0f, bitcast<f32>(x_2463.z));
  let x_2504 : f32 = bitcast<f32>(x_2463.w);
  let x_2507 : u32 = x_2475.w;
  let x_2510 : u32 = x_2487.x;
  let x_2628 : f32 = v2.y;
  let x_2629 : f32 = v8;
  if ((x_2628 < x_2629)) {
    discard;
  }
  let x_2633 : i32 = v12;
  let x_2635 : bool = ((x_2633 & 8i) != 0i);
  let x_2638 : bool = ((x_2633 & 16i) != 0i);
  let x_2641 : bool = ((x_2633 & 2048i) != 0i);
  let x_2644 : vec4<f32> = (x_2335 * vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f));
  let x_2645 : vec3<f32> = v3;
  let x_2647 : vec3<f32> = ((x_2645 * 0.875f) + x_867);
  let x_3533 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3537 : i32 = x_3533.z;
  let x_3544 : f32 = f32((x_3537 - 1i));
  let x_3545 : f32 = clamp(((x_2647.z * f32(x_3537)) - 0.5f), 0.0f, x_3544);
  let x_3547 : f32 = floor(x_3545);
  let x_3561 : f32 = x_2647.x;
  let x_3562 : f32 = x_2647.y;
  let x_3564 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3561, x_3562, x_3547).xy, i32(round(vec3<f32>(x_3561, x_3562, x_3547).z)), 0.0f);
  let x_3574 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3561, x_3562, min((x_3547 + 1.0f), x_3544)).xy, i32(round(vec3<f32>(x_3561, x_3562, min((x_3547 + 1.0f), x_3544)).z)), 0.0f);
  let x_3577 : f32 = (x_3545 - x_3547);
  let x_2650 : f32 = ((((mix(x_3564, x_3574, vec4<f32>(x_3577, x_3577, x_3577, x_3577)) * 255.0f) - x_6429) * x_6436)).x;
  let x_2652 : f32 = (x_2650 * 0.25624999403953552246f);
  let x_2655 : vec3<f32> = v4;
  let x_2658 : vec3<f32> = ((x_2645 + x_867) + (x_2655 * x_2652));
  let x_2662 : vec3<f32> = (((x_2658 - x_867) * 0.875f) + x_867);
  let x_3595 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3599 : i32 = x_3595.z;
  let x_3606 : f32 = f32((x_3599 - 1i));
  let x_3607 : f32 = clamp(((x_2662.z * f32(x_3599)) - 0.5f), 0.0f, x_3606);
  let x_3609 : f32 = floor(x_3607);
  let x_3623 : f32 = x_2662.x;
  let x_3624 : f32 = x_2662.y;
  let x_3626 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3623, x_3624, x_3609).xy, i32(round(vec3<f32>(x_3623, x_3624, x_3609).z)), 0.0f);
  let x_3636 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3623, x_3624, min((x_3609 + 1.0f), x_3606)).xy, i32(round(vec3<f32>(x_3623, x_3624, min((x_3609 + 1.0f), x_3606)).z)), 0.0f);
  let x_3639 : f32 = (x_3607 - x_3609);
  let x_2665 : f32 = ((((mix(x_3626, x_3636, vec4<f32>(x_3639, x_3639, x_3639, x_3639)) * 255.0f) - x_6429) * x_6436)).x;
  let x_2667 : f32 = (x_2665 * 0.19099999964237213135f);
  let x_2672 : vec3<f32> = (x_2658 + (x_2655 * x_2667));
  let x_2676 : vec3<f32> = (((x_2672 - x_867) * 0.875f) + x_867);
  let x_3657 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3661 : i32 = x_3657.z;
  let x_3668 : f32 = f32((x_3661 - 1i));
  let x_3669 : f32 = clamp(((x_2676.z * f32(x_3661)) - 0.5f), 0.0f, x_3668);
  let x_3671 : f32 = floor(x_3669);
  let x_3685 : f32 = x_2676.x;
  let x_3686 : f32 = x_2676.y;
  let x_3688 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3685, x_3686, x_3671).xy, i32(round(vec3<f32>(x_3685, x_3686, x_3671).z)), 0.0f);
  let x_3698 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3685, x_3686, min((x_3671 + 1.0f), x_3668)).xy, i32(round(vec3<f32>(x_3685, x_3686, min((x_3671 + 1.0f), x_3668)).z)), 0.0f);
  let x_3701 : f32 = (x_3669 - x_3671);
  let x_2679 : f32 = ((((mix(x_3688, x_3698, vec4<f32>(x_3701, x_3701, x_3701, x_3701)) * 255.0f) - x_6429) * x_6436)).x;
  let x_2681 : f32 = (x_2679 * 0.16312499344348907471f);
  let x_2687 : vec3<f32> = ((x_2672 + (x_2655 * x_2681)) - x_867);
  let x_2689 : vec3<f32> = abs(x_2687);
  let x_2691 : f32 = x_2689.x;
  let x_2693 : f32 = x_2689.y;
  let x_2695 : f32 = x_2689.z;
  let x_2698 : bool = (max(x_2691, max(x_2693, x_2695)) < 0.4930000007152557373f);
  let x_2701 : f32 = (-1.0f + x_2339);
  let x_3726 : vec3<f32> = dpdx(x_2687);
  let x_3729 : vec3<f32> = -(dpdy(x_2687));
  let x_3736 : bool = (x_2691 >= x_2693);
  x_3744 = x_3736;
  if (x_3736) {
    x_3742 = (x_2691 >= x_2695);
    x_3744 = x_3742;
  }
  var x_3774 : vec2<f32>;
  var x_3776 : vec2<f32>;
  var x_3778 : vec2<f32>;
  var x_3786 : f32;
  var x_3792 : f32;
  var x_3753 : vec2<f32>;
  var x_3755 : vec2<f32>;
  var x_3757 : vec2<f32>;
  var x_3765 : f32;
  var x_3771 : f32;
  if (x_3744) {
    x_3796 = vec2<f32>(x_2687.y, x_2687.z);
    x_3798 = vec2<f32>(x_3726.y, x_3726.z);
    x_3800 = vec2<f32>(x_3729.y, x_3729.z);
    let x_3805 : f32 = sign(x_2687.x);
    x_3808 = (x_3805 * x_3726.x);
    x_3814 = (x_3805 * x_3729.x);
    x_5785 = x_3814;
    x_5783 = x_3800;
    x_5781 = x_3808;
    x_5779 = x_3796;
    x_5777 = x_3798;
    x_5775 = x_2691;
  } else {
    if ((x_2693 >= x_2695)) {
      x_3774 = vec2<f32>(x_2687.x, x_2687.z);
      x_3776 = vec2<f32>(x_3726.x, x_3726.z);
      x_3778 = vec2<f32>(x_3729.x, x_3729.z);
      let x_3783 : f32 = sign(x_2687.y);
      x_3786 = (x_3783 * x_3726.y);
      x_3792 = (x_3783 * x_3729.y);
      x_5786 = x_3792;
      x_5784 = x_3778;
      x_5782 = x_3786;
      x_5780 = x_3774;
      x_5778 = x_3776;
      x_5776 = x_2693;
    } else {
      x_3753 = vec2<f32>(x_2687.x, x_2687.y);
      x_3755 = vec2<f32>(x_3726.x, x_3726.y);
      x_3757 = vec2<f32>(x_3729.x, x_3729.y);
      let x_3762 : f32 = sign(x_2687.z);
      x_3765 = (x_3762 * x_3726.z);
      x_3771 = (x_3762 * x_3729.z);
      x_5786 = x_3771;
      x_5784 = x_3757;
      x_5782 = x_3765;
      x_5780 = x_3753;
      x_5778 = x_3755;
      x_5776 = x_2695;
    }
    x_5785 = x_5786;
    x_5783 = x_5784;
    x_5781 = x_5782;
    x_5779 = x_5780;
    x_5777 = x_5778;
    x_5775 = x_5776;
  }
  let x_3817 : f32 = max(x_5775, 0.00000099999999747524f);
  let x_3826 : f32 = (0.5f / x_3817);
  let x_3827 : vec2<f32> = ((x_5777 - (x_5779 * (x_5781 / x_3817))) * x_3826);
  let x_3837 : vec2<f32> = ((x_5783 - (x_5779 * (x_5785 / x_3817))) * x_3826);
  let x_3842 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf_normal, 0i).xy);
  let x_3844 : f32 = f32(x_3842.x);
  let x_3868 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf_normal, gs_wgpu_samp_material_data_brick_sdf_normal, x_2687, clamp(((0.5f * log2(max(((max(dot(x_3827, x_3827), dot(x_3837, x_3837)) * x_3844) * x_3844), 0.00000000999999993923f))) + x_2701), 0.0f, 2.0f));
  let x_2710 : vec3<f32> = (((vec3<f32>(x_3868.x, x_3868.y, x_3868.z) * 255.0f) - vec3<f32>(128.0f, 128.0f, 128.0f)) * vec3<f32>(0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f));
  if ((dot(x_2710, x_2655) > 0.0f)) {
    discard;
  }
  let x_2717 : vec3<f32> = v2;
  let x_2722 : f32 = x_2644.w;
  let x_2733 : f32 = v5;
  let x_2735 : vec3<f32> = (x_2717 + ((normalize((x_2717 - (vec3<f32>(x_2644.x, x_2644.y, x_2644.z) / vec3<f32>(x_2722, x_2722, x_2722)))) * ((x_2652 + x_2667) + x_2681)) * x_2733));
  let x_2740 : bool = ((x_2650 * 0.125f) <= 0.01499999966472387314f);
  x_2748 = x_2740;
  if (!(x_2740)) {
    x_2746 = ((x_2665 * 0.125f) <= 0.01499999966472387314f);
    x_2748 = x_2746;
  }
  x_2755 = x_2748;
  if (!(x_2748)) {
    x_2753 = ((x_2679 * 0.125f) <= 0.01499999966472387314f);
    x_2755 = x_2753;
  }
  if (!(x_2755)) {
    discard;
  }
  let x_2794 : vec3<f32> = (x_2710 * mat3x3<f32>(vec3<f32>(x_2155.x, x_2157.x, x_2159.x), vec3<f32>(x_2155.y, x_2157.y, x_2159.y), vec3<f32>(x_2155.z, x_2157.z, x_2159.z)));
  let x_2797 : mat4x4<f32> = x_1059.renderer_MVPMat;
  let x_2802 : vec4<f32> = vec4<f32>(x_2735.x, x_2735.y, x_2735.z, 1.0f);
  let x_2803 : vec4<f32> = (x_2797 * x_2802);
  if (!(x_2635)) {
    let x_2808 : f32 = v7;
    x_2809 = (x_2808 > -2.5f);
    x_5818 = x_2809;
  } else {
    x_5818 = false;
  }
  if (x_5818) {
    let x_2816 : f32 = v7;
    x_2817 = (x_2628 < x_2816);
    x_5819 = x_2817;
  } else {
    x_5819 = false;
  }
  var x_2827 : bool;
  var x_5822 : bool;
  if (x_5819) {
    discard;
  } else {
    if (x_2635) {
      let x_2826 : f32 = v7;
      x_2827 = (x_2628 > x_2826);
      x_5822 = x_2827;
    } else {
      x_5822 = false;
    }
    if (x_5822) {
      discard;
    }
  }
  var x_2834 : i32;
  var x_2835 : u32;
  var x_2916 : vec2<f32>;
  var x_2844 : vec2<f32>;
  var x_5844 : vec2<f32>;
  var x_2923 : vec2<f32>;
  var x_5907 : vec2<f32>;
  var x_2929 : bool;
  var x_5850 : bool;
  var x_2943 : vec3<f32>;
  var x_2938 : vec3<f32>;
  var x_5945 : vec3<f32>;
  var x_2951 : bool;
  var x_5881 : bool;
  var x_2957 : bool;
  var x_5883 : bool;
  var x_2963 : bool;
  var x_5885 : bool;
  var x_3070 : vec3<f32>;
  var x_5911 : vec3<f32>;
  var x_5929 : vec3<f32>;
  var x_3077 : bool;
  var x_5925 : bool;
  var x_3083 : bool;
  var x_5946 : bool;
  var x_3127 : vec3<f32>;
  var x_5966 : vec3<f32>;
  var x_3174 : vec3<f32>;
  x_2834 = v10;
  x_2835 = bitcast<u32>(x_2834);
  if (((x_2633 & 2i) != 0i)) {
    let x_3181 : u32 = v0;
    let x_3188 : vec2<f32> = ((vec2<f32>(vec2<u32>(x_3181, x_3181)) * 0.20000000298023223877f) + (vec2<f32>(x_2717.x, x_2717.z) * 0.20000000298023223877f));
    let x_3194 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_3188.x, x_3188.y, f32(x_2835)).xy, i32(round(vec3<f32>(x_3188.x, x_3188.y, f32(x_2835)).z)));
    x_3196 = (vec3<f32>(x_3194.x, x_3194.y, x_3194.z) * 0.69999998807907104492f);
    x_6033 = x_3196;
  } else {
    var x_2869 : vec2<f32>;
    var x_5829 : vec2<f32>;
    var x_5840 : vec2<f32>;
    var x_2881 : vec2<f32>;
    var x_5841 : vec2<f32>;
    if (((x_2633 & 32i) != 0i)) {
      var x_2847 : vec3<f32>;
      var x_2863 : vec2<f32>;
      var x_2859 : vec2<f32>;
      x_2847 = normalize(x_2794);
      if ((x_2847.y > 0.89999997615814208984f)) {
        x_2869 = (vec2<f32>(x_2735.x, x_2735.z) * 0.69999998807907104492f);
        x_5840 = x_2869;
      } else {
        if ((abs(x_2847.x) > 0.89999997615814208984f)) {
          x_2863 = (vec2<f32>(x_2735.z, x_2735.y) * 0.69999998807907104492f);
          x_5829 = x_2863;
        } else {
          x_2859 = (vec2<f32>(x_2735.x, x_2735.y) * 0.69999998807907104492f);
          x_5829 = x_2859;
        }
        x_5840 = x_5829;
      }
      if (x_2698) {
        let x_2875 : u32 = v13;
        let x_3975 : i32 = ((bitcast<i32>(x_2875) * 16i) + 11i);
        let x_4307 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_4312 : i32 = (x_3975 / 4i);
        let x_4314 : i32 = x_4307.x;
        let x_4323 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4312 % x_4314), (x_4312 / x_4314)), 0i);
        let x_2880 : f32 = unpack2x16float(x_4323[(x_3975 % 4i)]).y;
        x_2881 = vec2<f32>(x_2880, x_2880);
        x_5841 = x_2881;
      } else {
        x_5841 = x_5840;
      }
      let x_2883 : u32 = v13;
      let x_4554 : i32 = ((bitcast<i32>(x_2883) * 16i) + 13i);
      let x_4926 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_4931 : i32 = (x_4554 / 4i);
      let x_4933 : i32 = x_4926.x;
      let x_4942 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4931 % x_4933), (x_4931 / x_4933)), 0i);
      let x_4944 : i32 = (x_4554 % 4i);
      let x_5491 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_5498 : i32 = x_5491.x;
      let x_5507 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4931 % x_5498), (x_4931 / x_5498)), 0i);
      let x_2892 : u32 = (x_4942[x_4944] + (x_5507[x_4944] << 10u));
      let x_2896 : u32 = (x_2892 ^ (x_2892 >> 6u));
      let x_2900 : u32 = (x_2896 + (x_2896 << 3u));
      let x_2904 : u32 = (x_2900 ^ (x_2900 >> 11u));
      let x_2914 : f32 = (bitcast<f32>((((x_2904 + (x_2904 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
      x_2916 = ((x_5841 * 0.30000001192092895508f) + vec2<f32>(x_2914, x_2914));
      x_5844 = x_2916;
    } else {
      x_2844 = v9;
      x_5844 = x_2844;
    }
    if (x_2698) {
      x_2923 = (x_5844 + vec2<f32>(0.20999999344348907471f, 0.20999999344348907471f));
      x_5907 = x_2923;
    } else {
      x_5907 = x_5844;
    }
    if ((x_2835 == 1u)) {
      x_5850 = true;
    } else {
      x_2929 = (x_2835 == 0u);
      x_5850 = x_2929;
    }
    if (x_5850) {
      x_2943 = pow(vec3<f32>(x_2427.x, x_2427.y, x_2427.z), vec3<f32>(1.29999995231628417969f, 1.29999995231628417969f, 1.29999995231628417969f));
      x_5945 = x_2943;
    } else {
      x_2938 = (pow(vec3<f32>(x_2413.x, x_2413.y, x_2413.z), x_1276) * 0.80000001192092895508f);
      x_5945 = x_2938;
    }
    if ((x_2834 == 0i)) {
      x_5881 = true;
    } else {
      x_2951 = (x_2834 == 4i);
      x_5881 = x_2951;
    }
    if (x_5881) {
      x_5883 = true;
    } else {
      x_2957 = (x_2834 == 10i);
      x_5883 = x_2957;
    }
    if (x_5883) {
      x_5885 = true;
    } else {
      x_2963 = (x_2834 == 12i);
      x_5885 = x_2963;
    }
    var x_2972 : bool;
    var x_5887 : bool;
    var x_3057 : vec3<f32>;
    var x_5910 : vec3<f32>;
    if (x_5885) {
      let x_3065 : vec2<f32> = (x_5907 + vec2<f32>(0.85000002384185791016f, 0.85000002384185791016f));
      let x_3069 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3065.x, x_3065.y, 0.0f).xy, i32(round(vec3<f32>(x_3065.x, x_3065.y, 0.0f).z)));
      x_3070 = vec3<f32>(x_3069.x, x_3069.y, x_3069.z);
      x_5929 = x_3070;
    } else {
      if ((x_2834 == 1i)) {
        x_5887 = true;
      } else {
        x_2972 = (x_2834 == 5i);
        x_5887 = x_2972;
      }
      var x_2981 : bool;
      var x_5889 : bool;
      var x_3043 : vec3<f32>;
      var x_5909 : vec3<f32>;
      if (x_5887) {
        let x_3051 : vec2<f32> = (x_5907 + vec2<f32>(0.44999998807907104492f, 0.44999998807907104492f));
        let x_3055 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3051.x, x_3051.y, 1.0f).xy, i32(round(vec3<f32>(x_3051.x, x_3051.y, 1.0f).z)));
        x_3057 = pow(vec3<f32>(x_3055.x, x_3055.y, x_3055.z), vec3<f32>(1.10000002384185791016f, 1.10000002384185791016f, 1.10000002384185791016f));
        x_5911 = x_3057;
      } else {
        if ((x_2834 == 2i)) {
          x_5889 = true;
        } else {
          x_2981 = (x_2834 == 7i);
          x_5889 = x_2981;
        }
        var x_2990 : bool;
        var x_5891 : bool;
        var x_2996 : bool;
        var x_5893 : bool;
        var x_3002 : bool;
        var x_5895 : bool;
        var x_3031 : vec3<f32>;
        var x_5908 : vec3<f32>;
        if (x_5889) {
          let x_3042 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_5907.x, x_5907.y, 2.0f).xy, i32(round(vec3<f32>(x_5907.x, x_5907.y, 2.0f).z)));
          x_3043 = vec3<f32>(x_3042.x, x_3042.y, x_3042.z);
          x_5910 = x_3043;
        } else {
          if ((x_2834 == 3i)) {
            x_5891 = true;
          } else {
            x_2990 = (x_2834 == 6i);
            x_5891 = x_2990;
          }
          if (x_5891) {
            x_5893 = true;
          } else {
            x_2996 = (x_2834 == 8i);
            x_5893 = x_2996;
          }
          if (x_5893) {
            x_5895 = true;
          } else {
            x_3002 = (x_2834 == 9i);
            x_5895 = x_3002;
          }
          var x_3019 : vec3<f32>;
          if (x_5895) {
            let x_3030 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_5907.x, x_5907.y, 3.0f).xy, i32(round(vec3<f32>(x_5907.x, x_5907.y, 3.0f).z)));
            x_3031 = vec3<f32>(x_3030.x, x_3030.y, x_3030.z);
            x_5909 = x_3031;
          } else {
            if ((x_2834 == 11i)) {
              let x_3018 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_5907.x, x_5907.y, 4.0f).xy, i32(round(vec3<f32>(x_5907.x, x_5907.y, 4.0f).z)));
              x_3019 = vec3<f32>(x_3018.x, x_3018.y, x_3018.z);
              x_5908 = x_3019;
            } else {
              x_5908 = x_1431;
            }
            x_5909 = x_5908;
          }
          x_5910 = x_5909;
        }
        x_5911 = x_5910;
      }
      x_5929 = x_5911;
    }
    let x_3073 : bool = (x_2835 == 7u);
    if (x_3073) {
      x_5925 = true;
    } else {
      x_3077 = (x_2835 == 2u);
      x_5925 = x_3077;
    }
    if (x_5925) {
      x_5946 = true;
    } else {
      x_3083 = (x_2835 == 11u);
      x_5946 = x_3083;
    }
    if (((x_2633 & 512i) != 0i)) {
      let x_3092 : u32 = v0;
      let x_3093 : u32 = (x_3092 ^ 8902390u);
      let x_3097 : u32 = (x_3093 + (x_3093 << 10u));
      let x_3101 : u32 = (x_3097 ^ (x_3097 >> 6u));
      let x_3105 : u32 = (x_3101 + (x_3101 << 3u));
      let x_3109 : u32 = (x_3105 ^ (x_3105 >> 11u));
      let x_3125 : f32 = mix(0.0f, 0.5f, smoothstep(0.20000000298023223877f, 0.80000001192092895508f, (bitcast<f32>((((x_3109 + (x_3109 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_3127 = mix(x_5929, select(x_5945, x_5929, vec3<bool>(x_5946, x_5946, x_5946)), vec3<f32>(x_3125, x_3125, x_3125));
      x_5966 = x_3127;
    } else {
      x_5966 = x_5929;
    }
    var x_3136 : bool;
    var x_6005 : bool;
    if (x_2698) {
      if (x_3073) {
        x_6005 = true;
      } else {
        x_3136 = (x_2835 == 2u);
        x_6005 = x_3136;
      }
      let x_3139 : u32 = v0;
      let x_3140 : u32 = (x_3139 ^ 239085u);
      let x_3144 : u32 = (x_3140 + (x_3140 << 10u));
      let x_3148 : u32 = (x_3144 ^ (x_3144 >> 6u));
      let x_3152 : u32 = (x_3148 + (x_3148 << 3u));
      let x_3156 : u32 = (x_3152 ^ (x_3152 >> 11u));
      let x_3172 : f32 = mix(0.0f, select(0.40000000596046447754f, 0.20000000298023223877f, x_6005), smoothstep(0.0f, 0.80000001192092895508f, (bitcast<f32>((((x_3156 + (x_3156 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_3174 = mix(x_5966, vec3<f32>(x_2399.x, x_2399.y, x_2399.z), vec3<f32>(x_3172, x_3172, x_3172));
      x_6006 = x_3174;
    } else {
      x_6006 = x_5966;
    }
    x_6033 = x_6006;
  }
  var x_3232 : vec3<f32>;
  var x_3219 : bool;
  var x_6071 : vec3<f32>;
  var x_6192 : bool;
  var x_6185 : vec3<f32>;
  var x_3247 : bool;
  var x_6183 : bool;
  var x_3254 : vec3<f32>;
  let x_3199 : vec3<f32> = normalize(x_2794);
  if (((x_2633 & 64i) == 0i)) {
    var x_6458 : u32;
    var x_3225 : vec3<f32>;
    x_6458 = select(0u, x_2507, ((x_2633 & 4096i) != 0i));
    if ((x_6458 == 1u)) {
      x_3232 = mix(x_6033, x_1591, x_867);
      x_6192 = true;
      x_6185 = x_3232;
    } else {
      x_3219 = (x_6458 == 2u);
      if (x_3219) {
        x_3225 = mix(x_6033, x_867, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_6071 = x_3225;
      } else {
        x_6071 = x_6033;
      }
      x_6192 = x_3219;
      x_6185 = x_6071;
    }
    if ((x_2510 == 1u)) {
      let x_3242 : vec2<f32> = v11;
      x_3247 = (distance(vec2<f32>(x_2500.x, x_2500.z), x_3242) < (1.88900005817413330078f * x_2504));
      x_6183 = x_3247;
    } else {
      x_6183 = false;
    }
    if (x_6183) {
      x_3254 = mix(x_6033, x_1591, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_6193 = x_3254;
    } else {
      x_6193 = x_6185;
    }
    x_3258 = select(x_6192, true, x_6183);
    x_6325 = x_3258;
    x_6234 = x_6193;
  } else {
    x_6325 = false;
    x_6234 = x_6033;
  }
  if (x_2641) {
    x_3266 = mix(x_6033, x_1591, x_867);
    x_6278 = x_3266;
  } else {
    x_6278 = x_6234;
  }
  if ((x_2489 == 4u)) {
    let x_3276 : vec2<f32> = (vec2<f32>(x_2717.x, x_2717.z) * 0.40000000596046447754f);
    let x_3279 : f32 = dot(x_3276, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
    let x_3282 : vec2<f32> = floor((x_3276 + vec2<f32>(x_3279, x_3279)));
    let x_3287 : f32 = dot(x_3282, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
    let x_3289 : vec2<f32> = ((x_3276 - x_3282) + vec2<f32>(x_3287, x_3287));
    let x_3291 : f32 = x_3289.x;
    let x_3293 : f32 = x_3289.y;
    let x_3296 : bool = (x_3291 > x_3293);
    let x_3298 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_3296, x_3296));
    let x_3301 : vec4<f32> = (vec4<f32>(x_3289.x, x_3289.y, x_3289.x, x_3289.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
    let x_3305 : vec2<f32> = (vec2<f32>(x_3301.x, x_3301.y) - x_3298);
    var x_6586_1 : vec4<f32> = x_3301;
    x_6586_1.x = x_3305.x;
    let x_6586 : vec4<f32> = x_6586_1;
    var x_6589_1 : vec4<f32> = x_6586;
    x_6589_1.y = x_3305.y;
    let x_6589 : vec4<f32> = x_6589_1;
    let x_3318 : vec2<f32> = (x_3282 - (vec2<f32>(289.0f, 289.0f) * trunc((x_3282 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
    let x_3320 : f32 = x_3318.y;
    let x_3325 : vec3<f32> = (vec3<f32>(x_3320, x_3320, x_3320) + vec3<f32>(0.0f, x_3298.y, 1.0f));
    let x_3330 : vec3<f32> = (((x_3325 * 34.0f) + x_1276) * x_3325);
    let x_3338 : f32 = x_3318.x;
    let x_3344 : vec3<f32> = (((x_3330 - (x_1742 * trunc((x_3330 * x_6440)))) + vec3<f32>(x_3338, x_3338, x_3338)) + vec3<f32>(0.0f, x_3298.x, 1.0f));
    let x_3349 : vec3<f32> = (((x_3344 * 34.0f) + x_1276) * x_3344);
    let x_3354 : vec2<f32> = vec2<f32>(x_6589.x, x_6589.y);
    let x_3359 : vec2<f32> = vec2<f32>(x_6589.z, x_6589.w);
    let x_3365 : vec3<f32> = max((x_867 - vec3<f32>(dot(x_3289, x_3289), dot(x_3354, x_3354), dot(x_3359, x_3359))), x_1431);
    let x_3368 : vec3<f32> = (x_3365 * x_3365);
    let x_3377 : vec3<f32> = (fract(((x_3349 - (x_1742 * trunc((x_3349 * x_6440)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
    let x_3379 : vec3<f32> = (x_3377 - x_1276);
    let x_3382 : vec3<f32> = (abs(x_3379) - x_867);
    let x_3387 : vec3<f32> = (x_3379 - floor((x_3377 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
    let x_3429 : vec2<f32> = ((vec2<f32>(x_3387.y, x_3387.z) * vec2<f32>(x_6589.x, x_6589.z)) + (vec2<f32>(x_3382.y, x_3382.z) * vec2<f32>(x_6589.y, x_6589.w)));
    let x_3442 : f32 = (smoothstep(0.0f, 1.0f, (smoothstep(-0.10000000149011611938f, 0.0f, x_2628) * clamp(x_3199.y, 0.0f, 1.0f))) * clamp(clamp(((130.0f * dot(((x_3368 * x_3368) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_3387 * x_3387) + (x_3382 * x_3382)) * 0.85373473167419433594f))), vec3<f32>(((x_3387.x * x_3291) + (x_3382.x * x_3293)), x_3429.x, x_3429.y))) + 0.75f), 0.0f, 1.0f), select(0.40000000596046447754f, 0.0f, x_2638), select(1.0f, 0.10000000149011611938f, x_2638)));
    x_3444 = mix(x_6278, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_3442, x_3442, x_3442));
    x_6320 = x_3444;
  } else {
    x_6320 = x_6278;
  }
  var x_2171 : u32;
  var x_6364 : u32;
  var x_6363 : u32;
  var x_6374 : bool;
  let x_3451 : vec3<f32> = sqrt(clamp(x_6320, x_1431, x_1276));
  let x_3508 : u32 = (((u32(((clamp(x_3451.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_3451.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_3451.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(2264924160u, 2399141888u, select(x_6325, true, x_2641)));
  let x_3519 : f32 = gl_FragCoord.z;
  gl_FragDepth = clamp(max((((x_2803.z / x_2803.w) * 0.5f) + 0.5f), x_3519), 0.0f, 1.0f);
  x_2171 = resident_cell_id;
  switch(0u) {
    default: {
      let x_5654 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_cell_clip, 0i));
      let x_5659 : i32 = bitcast<i32>(x_2171);
      let x_5661 : i32 = x_5654.x;
      let x_5670 : vec4<u32> = textureLoad(gs_wgpu_tex_cell_clip, vec2<i32>((x_5659 % x_5661), (x_5659 / x_5661)), 0i);
      let x_5671 : vec4<f32> = bitcast<vec4<f32>>(x_5670);
      let x_5583 : f32 = x_5671.y;
      if ((x_5583 < 0.0f)) {
        x_6378 = false;
        break;
      }
      if ((x_5583 == 0.0f)) {
        x_6378 = true;
        break;
      }
      let x_5594 : u32 = u32(x_5671.x);
      x_6364 = x_5594;
      x_6363 = 0u;
      loop {
        var x_6365 : u32;
        var x_6370 : bool;
        var x_5641 : u32;
        x_6379 = false;
        x_6374 = false;
        if ((x_6363 < u32(x_5583))) {
        } else {
          break;
        }
        let x_5679 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_cell_clip, 0i));
        let x_5684 : i32 = bitcast<i32>(x_6364);
        let x_5686 : i32 = x_5679.x;
        let x_5695 : vec4<u32> = textureLoad(gs_wgpu_tex_cell_clip, vec2<i32>((x_5684 % x_5686), (x_5684 / x_5686)), 0i);
        let x_5606 : u32 = u32((bitcast<vec4<f32>>(x_5695)).x);
        let x_5608 : u32 = (x_6364 + 1u);
        x_6365 = 0u;
        loop {
          var x_5634 : u32;
          x_6370 = true;
          if ((x_6365 < x_5606)) {
          } else {
            break;
          }
          let x_5704 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_cell_clip, 0i));
          let x_5709 : i32 = bitcast<i32>((x_5608 + x_6365));
          let x_5711 : i32 = x_5704.x;
          let x_5720 : vec4<u32> = textureLoad(gs_wgpu_tex_cell_clip, vec2<i32>((x_5709 % x_5711), (x_5709 / x_5711)), 0i);
          if (!((dot(bitcast<vec4<f32>>(x_5720), x_2802) >= -0.00000999999974737875f))) {
            x_6370 = false;
            break;
          }

          continuing {
            x_5634 = (x_6365 + bitcast<u32>(1i));
            x_6365 = x_5634;
          }
        }
        if (x_6370) {
          x_6379 = true;
          x_6374 = true;
          break;
        }

        continuing {
          x_5641 = (x_6363 + bitcast<u32>(1i));
          x_6364 = (x_5608 + x_5606);
          x_6363 = x_5641;
        }
      }
      x_6378 = x_6379;
      if (x_6374) {
        break;
      }
      x_6378 = false;
    }
  }
  if (!(x_6378)) {
    discard;
  }
  let x_2190 : vec3<f32> = vec3<f32>(f32((x_3508 & 255u)), f32(((x_3508 >> 8u) & 255u)), f32(((x_3508 >> 16u) & 255u)));
  let x_2195 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_2190 * x_2190));
  let x_2205 : vec3<f32> = select((x_2195 * 12.9200000762939453125f), ((pow(x_2195, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_2195 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_2205.x, x_2205.y, x_2205.z, 1.0f);
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
