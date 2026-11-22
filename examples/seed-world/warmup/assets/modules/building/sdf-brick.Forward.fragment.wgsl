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

@binding(0) @group(2) var<uniform> x_1050 : gs_Auto_0;

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

var<private> residentColor : vec4<f32>;

var<private> v14_col0 : vec3<f32>;

var<private> v14_col1 : vec3<f32>;

var<private> v14_col2 : vec3<f32>;

const x_858 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_6027 = vec4<f32>(128.0f, 128.0f, 128.0f, 128.0f);

const x_6034 = vec4<f32>(0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f);

const x_1267 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_1422 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_1582 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_6038 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_1733 = vec3<f32>(289.0f, 289.0f, 289.0f);

fn main_1() {
  var x_3600 : bool;
  var x_3602 : bool;
  var x_3654 : vec2<f32>;
  var x_3656 : vec2<f32>;
  var x_3658 : vec2<f32>;
  var x_3666 : f32;
  var x_3672 : f32;
  var x_5487 : f32;
  var x_5485 : vec2<f32>;
  var x_5483 : f32;
  var x_5481 : vec2<f32>;
  var x_5479 : vec2<f32>;
  var x_5477 : f32;
  var x_5486 : f32;
  var x_5484 : vec2<f32>;
  var x_5482 : f32;
  var x_5480 : vec2<f32>;
  var x_5478 : vec2<f32>;
  var x_5476 : f32;
  var x_2604 : bool;
  var x_2606 : bool;
  var x_2611 : bool;
  var x_2613 : bool;
  var x_2667 : bool;
  var x_5519 : bool;
  var x_2675 : bool;
  var x_5520 : bool;
  var x_3054 : vec3<f32>;
  var x_5707 : vec3<f32>;
  var x_5734 : vec3<f32>;
  var x_5894 : vec3<f32>;
  var x_3116 : bool;
  var x_6026 : bool;
  var x_5935 : vec3<f32>;
  var x_3124 : vec3<f32>;
  var x_5979 : vec3<f32>;
  var x_3302 : vec3<f32>;
  var x_6021 : vec3<f32>;
  let x_2022 : vec3<f32> = v14_col0;
  let x_2024 : vec3<f32> = v14_col1;
  let x_2026 : vec3<f32> = v14_col2;
  let x_2080 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_2085 : i32 = x_2080.x;
  let x_2092 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((20i % x_2085), (20i / x_2085)), 0i);
  let x_2104 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((21i % x_2085), (21i / x_2085)), 0i);
  let x_2116 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((22i % x_2085), (22i / x_2085)), 0i);
  let x_2128 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((23i % x_2085), (23i / x_2085)), 0i);
  let x_2140 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_2085), (63i / x_2085)), 0i);
  let x_2193 : mat4x4<f32> = mat4x4<f32>(vec4<f32>(bitcast<f32>(x_2092.x), bitcast<f32>(x_2104.x), bitcast<f32>(x_2116.x), bitcast<f32>(x_2128.x)), vec4<f32>(bitcast<f32>(x_2092.y), bitcast<f32>(x_2104.y), bitcast<f32>(x_2116.y), bitcast<f32>(x_2128.y)), vec4<f32>(bitcast<f32>(x_2092.z), bitcast<f32>(x_2104.z), bitcast<f32>(x_2116.z), bitcast<f32>(x_2128.z)), vec4<f32>(bitcast<f32>(x_2092.w), bitcast<f32>(x_2104.w), bitcast<f32>(x_2116.w), bitcast<f32>(x_2128.w)));
  let x_2197 : f32 = bitcast<f32>(x_2140.w);
  let x_2208 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ColorLibraryData_natural, 0i));
  let x_2213 : i32 = x_2208.x;
  let x_2220 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((28i % x_2213), (28i / x_2213)), 0i);
  let x_2232 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((30i % x_2213), (30i / x_2213)), 0i);
  let x_2244 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((31i % x_2213), (31i / x_2213)), 0i);
  let x_2257 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2220.x), bitcast<f32>(x_2220.y), bitcast<f32>(x_2220.z), 0.0f);
  let x_2271 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2232.x), bitcast<f32>(x_2232.y), bitcast<f32>(x_2232.z), 0.0f);
  let x_2285 : vec4<f32> = vec4<f32>(bitcast<f32>(x_2244.x), bitcast<f32>(x_2244.y), bitcast<f32>(x_2244.z), 0.0f);
  let x_2297 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_2302 : i32 = x_2297.x;
  let x_2309 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_2302), (8i / x_2302)), 0i);
  let x_2321 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_2302), (17i / x_2302)), 0i);
  let x_2333 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_2302), (18i / x_2302)), 0i);
  let x_2345 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_2302), (19i / x_2302)), 0i);
  let x_2347 : u32 = x_2309.w;
  let x_2358 : vec3<f32> = vec3<f32>(bitcast<f32>(x_2321.x), 0.0f, bitcast<f32>(x_2321.z));
  let x_2362 : f32 = bitcast<f32>(x_2321.w);
  let x_2365 : u32 = x_2333.w;
  let x_2368 : u32 = x_2345.x;
  let x_2486 : f32 = v2.y;
  let x_2487 : f32 = v8;
  if ((x_2486 < x_2487)) {
    discard;
  }
  let x_2491 : i32 = v12;
  let x_2493 : bool = ((x_2491 & 8i) != 0i);
  let x_2496 : bool = ((x_2491 & 16i) != 0i);
  let x_2499 : bool = ((x_2491 & 2048i) != 0i);
  let x_2502 : vec4<f32> = (x_2193 * vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f));
  let x_2503 : vec3<f32> = v3;
  let x_2505 : vec3<f32> = ((x_2503 * 0.875f) + x_858);
  let x_3391 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3395 : i32 = x_3391.z;
  let x_3402 : f32 = f32((x_3395 - 1i));
  let x_3403 : f32 = clamp(((x_2505.z * f32(x_3395)) - 0.5f), 0.0f, x_3402);
  let x_3405 : f32 = floor(x_3403);
  let x_3419 : f32 = x_2505.x;
  let x_3420 : f32 = x_2505.y;
  let x_3422 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3419, x_3420, x_3405).xy, i32(round(vec3<f32>(x_3419, x_3420, x_3405).z)), 0.0f);
  let x_3432 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3419, x_3420, min((x_3405 + 1.0f), x_3402)).xy, i32(round(vec3<f32>(x_3419, x_3420, min((x_3405 + 1.0f), x_3402)).z)), 0.0f);
  let x_3435 : f32 = (x_3403 - x_3405);
  let x_2508 : f32 = ((((mix(x_3422, x_3432, vec4<f32>(x_3435, x_3435, x_3435, x_3435)) * 255.0f) - x_6027) * x_6034)).x;
  let x_2510 : f32 = (x_2508 * 0.25624999403953552246f);
  let x_2513 : vec3<f32> = v4;
  let x_2516 : vec3<f32> = ((x_2503 + x_858) + (x_2513 * x_2510));
  let x_2520 : vec3<f32> = (((x_2516 - x_858) * 0.875f) + x_858);
  let x_3453 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3457 : i32 = x_3453.z;
  let x_3464 : f32 = f32((x_3457 - 1i));
  let x_3465 : f32 = clamp(((x_2520.z * f32(x_3457)) - 0.5f), 0.0f, x_3464);
  let x_3467 : f32 = floor(x_3465);
  let x_3481 : f32 = x_2520.x;
  let x_3482 : f32 = x_2520.y;
  let x_3484 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3481, x_3482, x_3467).xy, i32(round(vec3<f32>(x_3481, x_3482, x_3467).z)), 0.0f);
  let x_3494 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3481, x_3482, min((x_3467 + 1.0f), x_3464)).xy, i32(round(vec3<f32>(x_3481, x_3482, min((x_3467 + 1.0f), x_3464)).z)), 0.0f);
  let x_3497 : f32 = (x_3465 - x_3467);
  let x_2523 : f32 = ((((mix(x_3484, x_3494, vec4<f32>(x_3497, x_3497, x_3497, x_3497)) * 255.0f) - x_6027) * x_6034)).x;
  let x_2525 : f32 = (x_2523 * 0.19099999964237213135f);
  let x_2530 : vec3<f32> = (x_2516 + (x_2513 * x_2525));
  let x_2534 : vec3<f32> = (((x_2530 - x_858) * 0.875f) + x_858);
  let x_3515 : vec3<i32> = vec3<i32>(vec3<u32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf, 0i), textureNumLayers(gs_wgpu_tex_material_data_brick_sdf)));
  let x_3519 : i32 = x_3515.z;
  let x_3526 : f32 = f32((x_3519 - 1i));
  let x_3527 : f32 = clamp(((x_2534.z * f32(x_3519)) - 0.5f), 0.0f, x_3526);
  let x_3529 : f32 = floor(x_3527);
  let x_3543 : f32 = x_2534.x;
  let x_3544 : f32 = x_2534.y;
  let x_3546 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3543, x_3544, x_3529).xy, i32(round(vec3<f32>(x_3543, x_3544, x_3529).z)), 0.0f);
  let x_3556 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf, gs_wgpu_samp_material_data_brick_sdf, vec3<f32>(x_3543, x_3544, min((x_3529 + 1.0f), x_3526)).xy, i32(round(vec3<f32>(x_3543, x_3544, min((x_3529 + 1.0f), x_3526)).z)), 0.0f);
  let x_3559 : f32 = (x_3527 - x_3529);
  let x_2537 : f32 = ((((mix(x_3546, x_3556, vec4<f32>(x_3559, x_3559, x_3559, x_3559)) * 255.0f) - x_6027) * x_6034)).x;
  let x_2539 : f32 = (x_2537 * 0.16312499344348907471f);
  let x_2545 : vec3<f32> = ((x_2530 + (x_2513 * x_2539)) - x_858);
  let x_2547 : vec3<f32> = abs(x_2545);
  let x_2549 : f32 = x_2547.x;
  let x_2551 : f32 = x_2547.y;
  let x_2553 : f32 = x_2547.z;
  let x_2556 : bool = (max(x_2549, max(x_2551, x_2553)) < 0.4930000007152557373f);
  let x_2559 : f32 = (-1.0f + x_2197);
  let x_3584 : vec3<f32> = dpdx(x_2545);
  let x_3587 : vec3<f32> = -(dpdy(x_2545));
  let x_3594 : bool = (x_2549 >= x_2551);
  x_3602 = x_3594;
  if (x_3594) {
    x_3600 = (x_2549 >= x_2553);
    x_3602 = x_3600;
  }
  var x_3632 : vec2<f32>;
  var x_3634 : vec2<f32>;
  var x_3636 : vec2<f32>;
  var x_3644 : f32;
  var x_3650 : f32;
  var x_3611 : vec2<f32>;
  var x_3613 : vec2<f32>;
  var x_3615 : vec2<f32>;
  var x_3623 : f32;
  var x_3629 : f32;
  if (x_3602) {
    x_3654 = vec2<f32>(x_2545.y, x_2545.z);
    x_3656 = vec2<f32>(x_3584.y, x_3584.z);
    x_3658 = vec2<f32>(x_3587.y, x_3587.z);
    let x_3663 : f32 = sign(x_2545.x);
    x_3666 = (x_3663 * x_3584.x);
    x_3672 = (x_3663 * x_3587.x);
    x_5486 = x_3672;
    x_5484 = x_3658;
    x_5482 = x_3666;
    x_5480 = x_3654;
    x_5478 = x_3656;
    x_5476 = x_2549;
  } else {
    if ((x_2551 >= x_2553)) {
      x_3632 = vec2<f32>(x_2545.x, x_2545.z);
      x_3634 = vec2<f32>(x_3584.x, x_3584.z);
      x_3636 = vec2<f32>(x_3587.x, x_3587.z);
      let x_3641 : f32 = sign(x_2545.y);
      x_3644 = (x_3641 * x_3584.y);
      x_3650 = (x_3641 * x_3587.y);
      x_5487 = x_3650;
      x_5485 = x_3636;
      x_5483 = x_3644;
      x_5481 = x_3632;
      x_5479 = x_3634;
      x_5477 = x_2551;
    } else {
      x_3611 = vec2<f32>(x_2545.x, x_2545.y);
      x_3613 = vec2<f32>(x_3584.x, x_3584.y);
      x_3615 = vec2<f32>(x_3587.x, x_3587.y);
      let x_3620 : f32 = sign(x_2545.z);
      x_3623 = (x_3620 * x_3584.z);
      x_3629 = (x_3620 * x_3587.z);
      x_5487 = x_3629;
      x_5485 = x_3615;
      x_5483 = x_3623;
      x_5481 = x_3611;
      x_5479 = x_3613;
      x_5477 = x_2553;
    }
    x_5486 = x_5487;
    x_5484 = x_5485;
    x_5482 = x_5483;
    x_5480 = x_5481;
    x_5478 = x_5479;
    x_5476 = x_5477;
  }
  let x_3675 : f32 = max(x_5476, 0.00000099999999747524f);
  let x_3684 : f32 = (0.5f / x_3675);
  let x_3685 : vec2<f32> = ((x_5478 - (x_5480 * (x_5482 / x_3675))) * x_3684);
  let x_3695 : vec2<f32> = ((x_5484 - (x_5480 * (x_5486 / x_3675))) * x_3684);
  let x_3700 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_material_data_brick_sdf_normal, 0i).xy);
  let x_3702 : f32 = f32(x_3700.x);
  let x_3726 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_data_brick_sdf_normal, gs_wgpu_samp_material_data_brick_sdf_normal, x_2545, clamp(((0.5f * log2(max(((max(dot(x_3685, x_3685), dot(x_3695, x_3695)) * x_3702) * x_3702), 0.00000000999999993923f))) + x_2559), 0.0f, 2.0f));
  let x_2568 : vec3<f32> = (((vec3<f32>(x_3726.x, x_3726.y, x_3726.z) * 255.0f) - vec3<f32>(128.0f, 128.0f, 128.0f)) * vec3<f32>(0.00787401571869850159f, 0.00787401571869850159f, 0.00787401571869850159f));
  if ((dot(x_2568, x_2513) > 0.0f)) {
    discard;
  }
  let x_2575 : vec3<f32> = v2;
  let x_2580 : f32 = x_2502.w;
  let x_2591 : f32 = v5;
  let x_2593 : vec3<f32> = (x_2575 + ((normalize((x_2575 - (vec3<f32>(x_2502.x, x_2502.y, x_2502.z) / vec3<f32>(x_2580, x_2580, x_2580)))) * ((x_2510 + x_2525) + x_2539)) * x_2591));
  let x_2598 : bool = ((x_2508 * 0.125f) <= 0.01499999966472387314f);
  x_2606 = x_2598;
  if (!(x_2598)) {
    x_2604 = ((x_2523 * 0.125f) <= 0.01499999966472387314f);
    x_2606 = x_2604;
  }
  x_2613 = x_2606;
  if (!(x_2606)) {
    x_2611 = ((x_2537 * 0.125f) <= 0.01499999966472387314f);
    x_2613 = x_2611;
  }
  if (!(x_2613)) {
    discard;
  }
  let x_2652 : vec3<f32> = (x_2568 * mat3x3<f32>(vec3<f32>(x_2022.x, x_2024.x, x_2026.x), vec3<f32>(x_2022.y, x_2024.y, x_2026.y), vec3<f32>(x_2022.z, x_2024.z, x_2026.z)));
  let x_2655 : mat4x4<f32> = x_1050.renderer_MVPMat;
  let x_2661 : vec4<f32> = (x_2655 * vec4<f32>(x_2593.x, x_2593.y, x_2593.z, 1.0f));
  if (!(x_2493)) {
    let x_2666 : f32 = v7;
    x_2667 = (x_2666 > -2.5f);
    x_5519 = x_2667;
  } else {
    x_5519 = false;
  }
  if (x_5519) {
    let x_2674 : f32 = v7;
    x_2675 = (x_2486 < x_2674);
    x_5520 = x_2675;
  } else {
    x_5520 = false;
  }
  var x_2685 : bool;
  var x_5523 : bool;
  if (x_5520) {
    discard;
  } else {
    if (x_2493) {
      let x_2684 : f32 = v7;
      x_2685 = (x_2486 > x_2684);
      x_5523 = x_2685;
    } else {
      x_5523 = false;
    }
    if (x_5523) {
      discard;
    }
  }
  var x_2692 : i32;
  var x_2693 : u32;
  var x_2774 : vec2<f32>;
  var x_2702 : vec2<f32>;
  var x_5545 : vec2<f32>;
  var x_2781 : vec2<f32>;
  var x_5608 : vec2<f32>;
  var x_2787 : bool;
  var x_5551 : bool;
  var x_2801 : vec3<f32>;
  var x_2796 : vec3<f32>;
  var x_5646 : vec3<f32>;
  var x_2809 : bool;
  var x_5582 : bool;
  var x_2815 : bool;
  var x_5584 : bool;
  var x_2821 : bool;
  var x_5586 : bool;
  var x_2928 : vec3<f32>;
  var x_5612 : vec3<f32>;
  var x_5630 : vec3<f32>;
  var x_2935 : bool;
  var x_5626 : bool;
  var x_2941 : bool;
  var x_5647 : bool;
  var x_2985 : vec3<f32>;
  var x_5667 : vec3<f32>;
  var x_3032 : vec3<f32>;
  x_2692 = v10;
  x_2693 = bitcast<u32>(x_2692);
  if (((x_2491 & 2i) != 0i)) {
    let x_3039 : u32 = v0;
    let x_3046 : vec2<f32> = ((vec2<f32>(vec2<u32>(x_3039, x_3039)) * 0.20000000298023223877f) + (vec2<f32>(x_2575.x, x_2575.z) * 0.20000000298023223877f));
    let x_3052 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_3046.x, x_3046.y, f32(x_2693)).xy, i32(round(vec3<f32>(x_3046.x, x_3046.y, f32(x_2693)).z)));
    x_3054 = (vec3<f32>(x_3052.x, x_3052.y, x_3052.z) * 0.69999998807907104492f);
    x_5734 = x_3054;
  } else {
    var x_2727 : vec2<f32>;
    var x_5530 : vec2<f32>;
    var x_5541 : vec2<f32>;
    var x_2739 : vec2<f32>;
    var x_5542 : vec2<f32>;
    if (((x_2491 & 32i) != 0i)) {
      var x_2705 : vec3<f32>;
      var x_2721 : vec2<f32>;
      var x_2717 : vec2<f32>;
      x_2705 = normalize(x_2652);
      if ((x_2705.y > 0.89999997615814208984f)) {
        x_2727 = (vec2<f32>(x_2593.x, x_2593.z) * 0.69999998807907104492f);
        x_5541 = x_2727;
      } else {
        if ((abs(x_2705.x) > 0.89999997615814208984f)) {
          x_2721 = (vec2<f32>(x_2593.z, x_2593.y) * 0.69999998807907104492f);
          x_5530 = x_2721;
        } else {
          x_2717 = (vec2<f32>(x_2593.x, x_2593.y) * 0.69999998807907104492f);
          x_5530 = x_2717;
        }
        x_5541 = x_5530;
      }
      if (x_2556) {
        let x_2733 : u32 = v13;
        let x_3833 : i32 = ((bitcast<i32>(x_2733) * 16i) + 11i);
        let x_4165 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
        let x_4170 : i32 = (x_3833 / 4i);
        let x_4172 : i32 = x_4165.x;
        let x_4181 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4170 % x_4172), (x_4170 / x_4172)), 0i);
        let x_2738 : f32 = unpack2x16float(x_4181[(x_3833 % 4i)]).y;
        x_2739 = vec2<f32>(x_2738, x_2738);
        x_5542 = x_2739;
      } else {
        x_5542 = x_5541;
      }
      let x_2741 : u32 = v13;
      let x_4412 : i32 = ((bitcast<i32>(x_2741) * 16i) + 13i);
      let x_4784 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_4789 : i32 = (x_4412 / 4i);
      let x_4791 : i32 = x_4784.x;
      let x_4800 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4789 % x_4791), (x_4789 / x_4791)), 0i);
      let x_4802 : i32 = (x_4412 % 4i);
      let x_5349 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
      let x_5356 : i32 = x_5349.x;
      let x_5365 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4789 % x_5356), (x_4789 / x_5356)), 0i);
      let x_2750 : u32 = (x_4800[x_4802] + (x_5365[x_4802] << 10u));
      let x_2754 : u32 = (x_2750 ^ (x_2750 >> 6u));
      let x_2758 : u32 = (x_2754 + (x_2754 << 3u));
      let x_2762 : u32 = (x_2758 ^ (x_2758 >> 11u));
      let x_2772 : f32 = (bitcast<f32>((((x_2762 + (x_2762 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
      x_2774 = ((x_5542 * 0.30000001192092895508f) + vec2<f32>(x_2772, x_2772));
      x_5545 = x_2774;
    } else {
      x_2702 = v9;
      x_5545 = x_2702;
    }
    if (x_2556) {
      x_2781 = (x_5545 + vec2<f32>(0.20999999344348907471f, 0.20999999344348907471f));
      x_5608 = x_2781;
    } else {
      x_5608 = x_5545;
    }
    if ((x_2693 == 1u)) {
      x_5551 = true;
    } else {
      x_2787 = (x_2693 == 0u);
      x_5551 = x_2787;
    }
    if (x_5551) {
      x_2801 = pow(vec3<f32>(x_2285.x, x_2285.y, x_2285.z), vec3<f32>(1.29999995231628417969f, 1.29999995231628417969f, 1.29999995231628417969f));
      x_5646 = x_2801;
    } else {
      x_2796 = (pow(vec3<f32>(x_2271.x, x_2271.y, x_2271.z), x_1267) * 0.80000001192092895508f);
      x_5646 = x_2796;
    }
    if ((x_2692 == 0i)) {
      x_5582 = true;
    } else {
      x_2809 = (x_2692 == 4i);
      x_5582 = x_2809;
    }
    if (x_5582) {
      x_5584 = true;
    } else {
      x_2815 = (x_2692 == 10i);
      x_5584 = x_2815;
    }
    if (x_5584) {
      x_5586 = true;
    } else {
      x_2821 = (x_2692 == 12i);
      x_5586 = x_2821;
    }
    var x_2830 : bool;
    var x_5588 : bool;
    var x_2915 : vec3<f32>;
    var x_5611 : vec3<f32>;
    if (x_5586) {
      let x_2923 : vec2<f32> = (x_5608 + vec2<f32>(0.85000002384185791016f, 0.85000002384185791016f));
      let x_2927 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2923.x, x_2923.y, 0.0f).xy, i32(round(vec3<f32>(x_2923.x, x_2923.y, 0.0f).z)));
      x_2928 = vec3<f32>(x_2927.x, x_2927.y, x_2927.z);
      x_5630 = x_2928;
    } else {
      if ((x_2692 == 1i)) {
        x_5588 = true;
      } else {
        x_2830 = (x_2692 == 5i);
        x_5588 = x_2830;
      }
      var x_2839 : bool;
      var x_5590 : bool;
      var x_2901 : vec3<f32>;
      var x_5610 : vec3<f32>;
      if (x_5588) {
        let x_2909 : vec2<f32> = (x_5608 + vec2<f32>(0.44999998807907104492f, 0.44999998807907104492f));
        let x_2913 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2909.x, x_2909.y, 1.0f).xy, i32(round(vec3<f32>(x_2909.x, x_2909.y, 1.0f).z)));
        x_2915 = pow(vec3<f32>(x_2913.x, x_2913.y, x_2913.z), vec3<f32>(1.10000002384185791016f, 1.10000002384185791016f, 1.10000002384185791016f));
        x_5612 = x_2915;
      } else {
        if ((x_2692 == 2i)) {
          x_5590 = true;
        } else {
          x_2839 = (x_2692 == 7i);
          x_5590 = x_2839;
        }
        var x_2848 : bool;
        var x_5592 : bool;
        var x_2854 : bool;
        var x_5594 : bool;
        var x_2860 : bool;
        var x_5596 : bool;
        var x_2889 : vec3<f32>;
        var x_5609 : vec3<f32>;
        if (x_5590) {
          let x_2900 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_5608.x, x_5608.y, 2.0f).xy, i32(round(vec3<f32>(x_5608.x, x_5608.y, 2.0f).z)));
          x_2901 = vec3<f32>(x_2900.x, x_2900.y, x_2900.z);
          x_5611 = x_2901;
        } else {
          if ((x_2692 == 3i)) {
            x_5592 = true;
          } else {
            x_2848 = (x_2692 == 6i);
            x_5592 = x_2848;
          }
          if (x_5592) {
            x_5594 = true;
          } else {
            x_2854 = (x_2692 == 8i);
            x_5594 = x_2854;
          }
          if (x_5594) {
            x_5596 = true;
          } else {
            x_2860 = (x_2692 == 9i);
            x_5596 = x_2860;
          }
          var x_2877 : vec3<f32>;
          if (x_5596) {
            let x_2888 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_5608.x, x_5608.y, 3.0f).xy, i32(round(vec3<f32>(x_5608.x, x_5608.y, 3.0f).z)));
            x_2889 = vec3<f32>(x_2888.x, x_2888.y, x_2888.z);
            x_5610 = x_2889;
          } else {
            if ((x_2692 == 11i)) {
              let x_2876 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_5608.x, x_5608.y, 4.0f).xy, i32(round(vec3<f32>(x_5608.x, x_5608.y, 4.0f).z)));
              x_2877 = vec3<f32>(x_2876.x, x_2876.y, x_2876.z);
              x_5609 = x_2877;
            } else {
              x_5609 = x_1422;
            }
            x_5610 = x_5609;
          }
          x_5611 = x_5610;
        }
        x_5612 = x_5611;
      }
      x_5630 = x_5612;
    }
    let x_2931 : bool = (x_2693 == 7u);
    if (x_2931) {
      x_5626 = true;
    } else {
      x_2935 = (x_2693 == 2u);
      x_5626 = x_2935;
    }
    if (x_5626) {
      x_5647 = true;
    } else {
      x_2941 = (x_2693 == 11u);
      x_5647 = x_2941;
    }
    if (((x_2491 & 512i) != 0i)) {
      let x_2950 : u32 = v0;
      let x_2951 : u32 = (x_2950 ^ 8902390u);
      let x_2955 : u32 = (x_2951 + (x_2951 << 10u));
      let x_2959 : u32 = (x_2955 ^ (x_2955 >> 6u));
      let x_2963 : u32 = (x_2959 + (x_2959 << 3u));
      let x_2967 : u32 = (x_2963 ^ (x_2963 >> 11u));
      let x_2983 : f32 = mix(0.0f, 0.5f, smoothstep(0.20000000298023223877f, 0.80000001192092895508f, (bitcast<f32>((((x_2967 + (x_2967 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_2985 = mix(x_5630, select(x_5646, x_5630, vec3<bool>(x_5647, x_5647, x_5647)), vec3<f32>(x_2983, x_2983, x_2983));
      x_5667 = x_2985;
    } else {
      x_5667 = x_5630;
    }
    var x_2994 : bool;
    var x_5706 : bool;
    if (x_2556) {
      if (x_2931) {
        x_5706 = true;
      } else {
        x_2994 = (x_2693 == 2u);
        x_5706 = x_2994;
      }
      let x_2997 : u32 = v0;
      let x_2998 : u32 = (x_2997 ^ 239085u);
      let x_3002 : u32 = (x_2998 + (x_2998 << 10u));
      let x_3006 : u32 = (x_3002 ^ (x_3002 >> 6u));
      let x_3010 : u32 = (x_3006 + (x_3006 << 3u));
      let x_3014 : u32 = (x_3010 ^ (x_3010 >> 11u));
      let x_3030 : f32 = mix(0.0f, select(0.40000000596046447754f, 0.20000000298023223877f, x_5706), smoothstep(0.0f, 0.80000001192092895508f, (bitcast<f32>((((x_3014 + (x_3014 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_3032 = mix(x_5667, vec3<f32>(x_2257.x, x_2257.y, x_2257.z), vec3<f32>(x_3030, x_3030, x_3030));
      x_5707 = x_3032;
    } else {
      x_5707 = x_5667;
    }
    x_5734 = x_5707;
  }
  var x_3090 : vec3<f32>;
  var x_3077 : bool;
  var x_5772 : vec3<f32>;
  var x_5893 : bool;
  var x_5886 : vec3<f32>;
  var x_3105 : bool;
  var x_5884 : bool;
  var x_3112 : vec3<f32>;
  let x_3057 : vec3<f32> = normalize(x_2652);
  if (((x_2491 & 64i) == 0i)) {
    var x_6056 : u32;
    var x_3083 : vec3<f32>;
    x_6056 = select(0u, x_2365, ((x_2491 & 4096i) != 0i));
    if ((x_6056 == 1u)) {
      x_3090 = mix(x_5734, x_1582, x_858);
      x_5893 = true;
      x_5886 = x_3090;
    } else {
      x_3077 = (x_6056 == 2u);
      if (x_3077) {
        x_3083 = mix(x_5734, x_858, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_5772 = x_3083;
      } else {
        x_5772 = x_5734;
      }
      x_5893 = x_3077;
      x_5886 = x_5772;
    }
    if ((x_2368 == 1u)) {
      let x_3100 : vec2<f32> = v11;
      x_3105 = (distance(vec2<f32>(x_2358.x, x_2358.z), x_3100) < (1.88900005817413330078f * x_2362));
      x_5884 = x_3105;
    } else {
      x_5884 = false;
    }
    if (x_5884) {
      x_3112 = mix(x_5734, x_1582, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_5894 = x_3112;
    } else {
      x_5894 = x_5886;
    }
    x_3116 = select(x_5893, true, x_5884);
    x_6026 = x_3116;
    x_5935 = x_5894;
  } else {
    x_6026 = false;
    x_5935 = x_5734;
  }
  if (x_2499) {
    x_3124 = mix(x_5734, x_1582, x_858);
    x_5979 = x_3124;
  } else {
    x_5979 = x_5935;
  }
  if ((x_2347 == 4u)) {
    let x_3134 : vec2<f32> = (vec2<f32>(x_2575.x, x_2575.z) * 0.40000000596046447754f);
    let x_3137 : f32 = dot(x_3134, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
    let x_3140 : vec2<f32> = floor((x_3134 + vec2<f32>(x_3137, x_3137)));
    let x_3145 : f32 = dot(x_3140, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
    let x_3147 : vec2<f32> = ((x_3134 - x_3140) + vec2<f32>(x_3145, x_3145));
    let x_3149 : f32 = x_3147.x;
    let x_3151 : f32 = x_3147.y;
    let x_3154 : bool = (x_3149 > x_3151);
    let x_3156 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_3154, x_3154));
    let x_3159 : vec4<f32> = (vec4<f32>(x_3147.x, x_3147.y, x_3147.x, x_3147.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
    let x_3163 : vec2<f32> = (vec2<f32>(x_3159.x, x_3159.y) - x_3156);
    var x_6184_1 : vec4<f32> = x_3159;
    x_6184_1.x = x_3163.x;
    let x_6184 : vec4<f32> = x_6184_1;
    var x_6187_1 : vec4<f32> = x_6184;
    x_6187_1.y = x_3163.y;
    let x_6187 : vec4<f32> = x_6187_1;
    let x_3176 : vec2<f32> = (x_3140 - (vec2<f32>(289.0f, 289.0f) * trunc((x_3140 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
    let x_3178 : f32 = x_3176.y;
    let x_3183 : vec3<f32> = (vec3<f32>(x_3178, x_3178, x_3178) + vec3<f32>(0.0f, x_3156.y, 1.0f));
    let x_3188 : vec3<f32> = (((x_3183 * 34.0f) + x_1267) * x_3183);
    let x_3196 : f32 = x_3176.x;
    let x_3202 : vec3<f32> = (((x_3188 - (x_1733 * trunc((x_3188 * x_6038)))) + vec3<f32>(x_3196, x_3196, x_3196)) + vec3<f32>(0.0f, x_3156.x, 1.0f));
    let x_3207 : vec3<f32> = (((x_3202 * 34.0f) + x_1267) * x_3202);
    let x_3212 : vec2<f32> = vec2<f32>(x_6187.x, x_6187.y);
    let x_3217 : vec2<f32> = vec2<f32>(x_6187.z, x_6187.w);
    let x_3223 : vec3<f32> = max((x_858 - vec3<f32>(dot(x_3147, x_3147), dot(x_3212, x_3212), dot(x_3217, x_3217))), x_1422);
    let x_3226 : vec3<f32> = (x_3223 * x_3223);
    let x_3235 : vec3<f32> = (fract(((x_3207 - (x_1733 * trunc((x_3207 * x_6038)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
    let x_3237 : vec3<f32> = (x_3235 - x_1267);
    let x_3240 : vec3<f32> = (abs(x_3237) - x_858);
    let x_3245 : vec3<f32> = (x_3237 - floor((x_3235 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
    let x_3287 : vec2<f32> = ((vec2<f32>(x_3245.y, x_3245.z) * vec2<f32>(x_6187.x, x_6187.z)) + (vec2<f32>(x_3240.y, x_3240.z) * vec2<f32>(x_6187.y, x_6187.w)));
    let x_3300 : f32 = (smoothstep(0.0f, 1.0f, (smoothstep(-0.10000000149011611938f, 0.0f, x_2486) * clamp(x_3057.y, 0.0f, 1.0f))) * clamp(clamp(((130.0f * dot(((x_3226 * x_3226) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_3245 * x_3245) + (x_3240 * x_3240)) * 0.85373473167419433594f))), vec3<f32>(((x_3245.x * x_3149) + (x_3240.x * x_3151)), x_3287.x, x_3287.y))) + 0.75f), 0.0f, 1.0f), select(0.40000000596046447754f, 0.0f, x_2496), select(1.0f, 0.10000000149011611938f, x_2496)));
    x_3302 = mix(x_5979, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_3300, x_3300, x_3300));
    x_6021 = x_3302;
  } else {
    x_6021 = x_5979;
  }
  let x_3309 : vec3<f32> = sqrt(clamp(x_6021, x_1422, x_1267));
  let x_3366 : u32 = (((u32(((clamp(x_3309.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_3309.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_3309.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(2264924160u, 2399141888u, select(x_6026, true, x_2499)));
  let x_3377 : f32 = gl_FragCoord.z;
  gl_FragDepth = clamp(max((((x_2661.z / x_2661.w) * 0.5f) + 0.5f), x_3377), 0.0f, 1.0f);
  let x_2049 : vec3<f32> = vec3<f32>(f32((x_3366 & 255u)), f32(((x_3366 >> 8u) & 255u)), f32(((x_3366 >> 16u) & 255u)));
  let x_2054 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_2049 * x_2049));
  let x_2064 : vec3<f32> = select((x_2054 * 12.9200000762939453125f), ((pow(x_2054, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_2054 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_2064.x, x_2064.y, x_2064.z, 1.0f);
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
