diagnostic(off, derivative_uniformity);
@binding(6) @group(3) var gs_wgpu_tex_uniform_FrameCounter_natural : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_uniform_FrameCounter_natural : sampler;

var<private> v4 : u32;

var<private> gl_FragCoord : vec4<f32>;

var<private> v5 : u32;

@binding(8) @group(3) var gs_wgpu_tex_window_colors_window_colors : texture_2d_array<f32>;

@binding(9) @group(3) var gs_wgpu_samp_window_colors_window_colors : sampler;

var<private> v3 : vec2<f32>;

var<private> residentColor : vec4<f32>;

const x_73 = vec2<u32>(1u, 1u);

fn main_1() {
  var x_360 : array<vec2<u32>, 4u>;
  var x_358 : u32;
  var x_437 : vec3<f32>;
  var x_502 : vec3<f32>;
  let x_356 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameCounter_natural, vec2<i32>(0i, 0i), 0i);
  x_358 = x_356.x;
  let x_374 : u32 = v4;
  if (((x_374 & 1u) != 0u)) {
    let x_378 : vec4<f32> = gl_FragCoord;
    x_360 = array<vec2<u32>, 4u>(vec2<u32>(0u, 0u), vec2<u32>(0u, 1u), x_73, vec2<u32>(1u, 0u));
    let x_386 : vec2<u32> = x_360[(x_358 & 3u)];
    if (all(((vec2<u32>(vec2<f32>(x_378.x, x_378.y)) & x_73) != x_386))) {
      discard;
    }
  }
  let x_392 : u32 = v5;
  let x_395 : u32 = (x_392 + (x_392 << 10u));
  let x_399 : u32 = (x_395 ^ (x_395 >> 6u));
  let x_403 : u32 = (x_399 + (x_399 << 3u));
  let x_407 : u32 = (x_403 ^ (x_403 >> 11u));
  let x_409 : i32 = bitcast<i32>(x_392);
  let x_413 : vec2<f32> = v3;
  let x_422 : f32 = (bitcast<f32>((((x_407 + (x_407 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
  let x_424 : vec2<f32> = ((x_413 * 0.5f) + vec2<f32>(x_422, x_422));
  let x_430 : vec4<f32> = textureSample(gs_wgpu_tex_window_colors_window_colors, gs_wgpu_samp_window_colors_window_colors, vec3<f32>(x_424.x, x_424.y, f32(x_409)).xy, i32(round(vec3<f32>(x_424.x, x_424.y, f32(x_409)).z)));
  let x_432 : vec3<f32> = vec3<f32>(x_430.x, x_430.y, x_430.z);
  if ((x_409 == 0i)) {
    x_437 = (x_432 * 0.69999998807907104492f);
    x_502 = x_437;
  } else {
    x_502 = x_432;
  }
  let x_447 : vec3<f32> = sqrt(clamp(x_502, vec3<f32>(0.0f, 0.0f, 0.0f), vec3<f32>(1.0f, 1.0f, 1.0f)));
  let x_469 : u32 = ((u32(((clamp(x_447.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_447.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_447.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u));
  let x_496 : u32 = (x_469 | 117440512u);
  let x_317 : vec3<f32> = vec3<f32>(f32((x_469 & 255u)), f32(((x_496 >> 8u) & 255u)), f32(((x_496 >> 16u) & 255u)));
  let x_322 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_317 * x_317));
  let x_332 : vec3<f32> = select((x_322 * 12.9200000762939453125f), ((pow(x_322, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_322 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_332.x, x_332.y, x_332.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(2) @interpolate(flat) v4_param : u32, @builtin(position) gl_FragCoord_param : vec4<f32>, @location(3) @interpolate(flat) v5_param : u32, @location(1) v3_param : vec2<f32>) -> main_out {
  v4 = v4_param;
  gl_FragCoord = gl_FragCoord_param;
  v5 = v5_param;
  v3 = v3_param;
  main_1();
  return main_out(residentColor);
}
