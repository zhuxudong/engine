diagnostic(off, derivative_uniformity);
@binding(4) @group(3) var gs_wgpu_tex_storage_0_0 : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_storage_0_0 : sampler;

@binding(0) @group(3) var gs_wgpu_tex_uniform_ViewConstants_natural : texture_2d<u32>;

@binding(1) @group(3) var gs_wgpu_samp_uniform_ViewConstants_natural : sampler;

@binding(8) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

var<private> v0 : vec3<f32>;

var<private> v5 : f32;

var<private> v1 : vec3<f32>;

var<private> v6 : vec2<f32>;

@binding(1) @group(2) var gs_wgpu_tex_material_data_wood_edge_damage : texture_2d<f32>;

@binding(2) @group(2) var gs_wgpu_samp_material_data_wood_edge_damage : sampler;

var<private> v7 : vec2<f32>;

@binding(10) @group(3) var gs_wgpu_tex_halftimber_colors_tex : texture_2d_array<f32>;

@binding(11) @group(3) var gs_wgpu_samp_halftimber_colors_tex : sampler;

var<private> v4 : u32;

@binding(3) @group(2) var gs_wgpu_tex_material_data_wood_roughness : texture_2d<f32>;

@binding(4) @group(2) var gs_wgpu_samp_material_data_wood_roughness : sampler;

@binding(5) @group(2) var gs_wgpu_tex_material_data_wood_normal : texture_2d<f32>;

@binding(6) @group(2) var gs_wgpu_samp_material_data_wood_normal : sampler;

var<private> v2 : vec3<f32>;

var<private> v3 : vec3<f32>;

@binding(7) @group(2) var gs_wgpu_tex_material_data_dirtpath_heightmap : texture_2d<f32>;

@binding(8) @group(2) var gs_wgpu_samp_material_data_dirtpath_heightmap : sampler;

var<private> residentColor : vec4<f32>;

const x_384 = vec3<f32>(1.0f, 1.0f, 1.0f);

fn main_1() {
  var x_745 : vec3<f32>;
  var x_1941 : vec3<f32>;
  var x_764 : f32;
  var x_1948 : f32;
  var x_828 : vec3<f32>;
  var x_1999 : vec3<f32>;
  var x_859 : bool;
  var x_1952 : bool;
  var x_891 : vec3<f32>;
  var x_1958 : vec3<f32>;
  let x_669 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_674 : i32 = x_669.x;
  let x_681 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_674), (63i / x_674)), 0i);
  let x_684 : f32 = bitcast<f32>(x_681.w);
  let x_693 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_698 : i32 = x_693.x;
  let x_705 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_698), (8i / x_698)), 0i);
  let x_707 : u32 = x_705.w;
  let x_734 : vec3<f32> = v0;
  let x_735 : vec3<f32> = normalize(x_734);
  let x_736 : f32 = v5;
  if ((x_736 > 0.00999999977648258209f)) {
    let x_739 : vec3<f32> = v1;
    x_745 = normalize(cross(dpdx(x_739), (dpdy(x_739) * -1.0f)));
    x_1941 = x_745;
  } else {
    x_1941 = x_735;
  }
  let x_749 : vec2<f32> = v6;
  let x_750 : vec2<f32> = (x_749 * vec2<f32>(0.44999998807907104492f, 0.05999999865889549255f));
  let x_752 : bool = (x_736 <= 0.00999999977648258209f);
  if (x_752) {
    let x_758 : vec2<f32> = v7;
    let x_762 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_wood_edge_damage, gs_wgpu_samp_material_data_wood_edge_damage, (x_758 * vec2<f32>(1.0f, 0.05000000074505805969f)), x_684);
    x_764 = (1.0f - x_762.x);
    x_1948 = x_764;
  } else {
    x_1948 = 0.0f;
  }
  let x_771 : u32 = v4;
  let x_1024 : i32 = (bitcast<i32>(x_771) * 14i);
  let x_1025 : i32 = (x_1024 + 7i);
  let x_1260 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_1265 : i32 = (x_1025 / 4i);
  let x_1267 : i32 = x_1260.x;
  let x_1276 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_1265 % x_1267), (x_1265 / x_1267)), 0i);
  let x_777 : f32 = x_750.x;
  let x_778 : f32 = x_750.y;
  let x_782 : vec4<f32> = textureSampleBias(gs_wgpu_tex_halftimber_colors_tex, gs_wgpu_samp_halftimber_colors_tex, vec3<f32>(x_777, x_778, f32(bitcast<i32>(x_1276[(x_1025 % 4i)]))).xy, i32(round(vec3<f32>(x_777, x_778, f32(bitcast<i32>(x_1276[(x_1025 % 4i)]))).z)), x_684);
  let x_784 : vec2<f32> = (x_749 * vec2<f32>(0.22499999403953552246f, 0.1799999922513961792f));
  let x_791 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_wood_roughness, gs_wgpu_samp_material_data_wood_roughness, x_784, x_684);
  let x_795 : f32 = mix(0.69999998807907104492f, 0.89999997615814208984f, (1.0f - x_791.x));
  if (x_752) {
    let x_804 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_wood_normal, gs_wgpu_samp_material_data_wood_normal, x_784, x_684);
    let x_807 : vec3<f32> = ((vec3<f32>(x_804.x, x_804.y, x_804.z) * 2.0f) - x_384);
    let x_812 : vec3<f32> = v2;
    let x_817 : vec3<f32> = v3;
    x_828 = normalize((((normalize(x_812) * x_807.x) + (normalize(x_817) * x_807.y)) + (x_735 * (x_807.z * 18.1818180084228515625f))));
    x_1999 = x_828;
  } else {
    x_1999 = x_1941;
  }
  let x_841 : vec4<f32> = textureSampleBias(gs_wgpu_tex_halftimber_colors_tex, gs_wgpu_samp_halftimber_colors_tex, vec3<f32>(x_777, x_778, 0.0f).xy, i32(round(vec3<f32>(x_777, x_778, 0.0f).z)), x_684);
  let x_847 : f32 = (x_1948 * 0.40000000596046447754f);
  let x_849 : vec3<f32> = mix(vec3<f32>(x_782.x, x_782.y, x_782.z), vec3<f32>(x_841.x, x_841.y, x_841.z), vec3<f32>(x_847, x_847, x_847));
  if ((x_707 == 4u)) {
    let x_1511 : i32 = (x_1024 + 9i);
    let x_1789 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_1794 : i32 = (x_1511 / 4i);
    let x_1796 : i32 = x_1789.x;
    let x_1805 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_1794 % x_1796), (x_1794 / x_1796)), 0i);
    x_859 = ((x_1805[(x_1511 % 4i)] & 16u) == 0u);
    x_1952 = x_859;
  } else {
    x_1952 = false;
  }
  if (x_1952) {
    let x_867 : vec3<f32> = v1;
    let x_872 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_dirtpath_heightmap, gs_wgpu_samp_material_data_dirtpath_heightmap, (vec2<f32>(x_867.x, x_867.z) * 0.05000000074505805969f), x_684);
    let x_874 : f32 = x_872.x;
    let x_889 : f32 = (((smoothstep(0.0f, 0.20000000298023223877f, (smoothstep(0.5f, 1.0f, x_795) * mix(0.0f, 0.5f, x_874))) * 0.60000002384185791016f) + (x_874 * 0.20000000298023223877f)) * clamp(x_1999.y, 0.0f, 1.0f));
    x_891 = mix(x_849, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_889, x_889, x_889));
    x_1958 = x_891;
  } else {
    x_1958 = x_849;
  }
  let x_930 : vec3<f32> = sqrt(clamp(x_1958, vec3<f32>(0.0f, 0.0f, 0.0f), x_384));
  let x_952 : u32 = ((u32(((clamp(x_930.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_930.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_930.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u));
  let x_956 : u32 = (x_952 | 117440512u);
  let x_642 : vec3<f32> = vec3<f32>(f32((x_952 & 255u)), f32(((x_956 >> 8u) & 255u)), f32(((x_956 >> 16u) & 255u)));
  let x_647 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_642 * x_642));
  let x_657 : vec3<f32> = select((x_647 * 12.9200000762939453125f), ((pow(x_647, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_647 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_657.x, x_657.y, x_657.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(0) v0_param : vec3<f32>, @location(5) v5_param : f32, @location(1) v1_param : vec3<f32>, @location(6) v6_param : vec2<f32>, @location(7) v7_param : vec2<f32>, @location(4) @interpolate(flat) v4_param : u32, @location(2) v2_param : vec3<f32>, @location(3) v3_param : vec3<f32>) -> main_out {
  v0 = v0_param;
  v5 = v5_param;
  v1 = v1_param;
  v6 = v6_param;
  v7 = v7_param;
  v4 = v4_param;
  v2 = v2_param;
  v3 = v3_param;
  main_1();
  return main_out(residentColor);
}
