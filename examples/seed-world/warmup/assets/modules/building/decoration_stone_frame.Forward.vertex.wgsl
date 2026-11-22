diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(0) @group(3) var gs_wgpu_tex_storage_6_0 : texture_2d<u32>;

@binding(1) @group(3) var gs_wgpu_samp_storage_6_0 : sampler;

@binding(2) @group(3) var gs_wgpu_tex_storage_0_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_0 : sampler;

@binding(6) @group(3) var gs_wgpu_tex_storage_19_0 : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_storage_19_0 : sampler;

@binding(8) @group(3) var gs_wgpu_tex_storage_21_0 : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_storage_21_0 : sampler;

var<private> gl_InstanceIndex : i32;

var<private> Vertex_Position : vec3<f32>;

var<private> Vertex_UV : vec2<f32>;

@binding(0) @group(2) var<uniform> x_2004 : gs_Auto_0;

var<private> v0 : u32;

var<private> v1 : vec3<f32>;

var<private> Vertex_Normal : vec3<f32>;

var<private> v2 : vec3<f32>;

var<private> v7 : f32;

var<private> v8 : f32;

var<private> v9 : vec2<f32>;

var<private> v10 : i32;

var<private> v11 : vec2<f32>;

var<private> v12 : i32;

var<private> v13 : u32;

var<private> gl_Position : vec4<f32>;

const x_1757 = vec2<f32>(0.5f, 0.5f);

fn main_1() {
  var x_2143 : vec2<f32>;
  var x_2167 : vec2<f32>;
  var x_2191 : vec2<f32>;
  var x_2215 : vec2<f32>;
  var x_2239 : vec2<f32>;
  var x_2263 : vec2<f32>;
  var x_2287 : vec2<f32>;
  var x_2311 : vec2<f32>;
  var x_15508 : u32;
  var x_15507 : u32;
  var x_15511 : u32;
  var x_15510 : u32;
  var x_15514 : u32;
  var x_15513 : u32;
  var x_15517 : u32;
  var x_15516 : u32;
  var x_15520 : u32;
  var x_15519 : u32;
  var x_15523 : u32;
  var x_15522 : u32;
  var x_15526 : u32;
  var x_15525 : u32;
  var x_15529 : u32;
  var x_15528 : u32;
  var x_3621 : vec2<f32>;
  var x_3627 : vec2<f32>;
  var x_15555 : vec2<f32>;
  var x_3642 : vec2<f32>;
  var x_15573 : vec2<f32>;
  let x_2363 : i32 = gl_InstanceIndex;
  let x_3692 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_3697 : i32 = (x_2363 / 4i);
  let x_3699 : i32 = x_3692.x;
  let x_3708 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_3699), (x_3697 / x_3699)), 0i);
  let x_3710 : i32 = (x_2363 % 4i);
  let x_3732 : i32 = (bitcast<i32>(x_3708[x_3710]) * 16i);
  let x_3871 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_3876 : i32 = (x_3732 / 4i);
  let x_3878 : i32 = x_3871.x;
  let x_3887 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_3876 % x_3878), (x_3876 / x_3878)), 0i);
  let x_4310 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_4317 : i32 = x_4310.x;
  let x_4326 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_4317), (x_3697 / x_4317)), 0i);
  let x_4362 : i32 = ((bitcast<i32>(x_4326[x_3710]) * 16i) + 1i);
  let x_4515 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_4520 : i32 = (x_4362 / 4i);
  let x_4522 : i32 = x_4515.x;
  let x_4531 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_4520 % x_4522), (x_4520 / x_4522)), 0i);
  let x_4927 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_4934 : i32 = x_4927.x;
  let x_4943 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_4934), (x_3697 / x_4934)), 0i);
  let x_4988 : i32 = ((bitcast<i32>(x_4943[x_3710]) * 16i) + 2i);
  let x_5159 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_5164 : i32 = (x_4988 / 4i);
  let x_5166 : i32 = x_5159.x;
  let x_5175 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5164 % x_5166), (x_5164 / x_5166)), 0i);
  let x_5544 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_5551 : i32 = x_5544.x;
  let x_5560 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_5551), (x_3697 / x_5551)), 0i);
  let x_5614 : i32 = ((bitcast<i32>(x_5560[x_3710]) * 16i) + 3i);
  let x_5803 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_5808 : i32 = (x_5614 / 4i);
  let x_5810 : i32 = x_5803.x;
  let x_5819 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5808 % x_5810), (x_5808 / x_5810)), 0i);
  let x_6161 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_6168 : i32 = x_6161.x;
  let x_6177 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_6168), (x_3697 / x_6168)), 0i);
  let x_6240 : i32 = ((bitcast<i32>(x_6177[x_3710]) * 16i) + 4i);
  let x_6447 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_6452 : i32 = (x_6240 / 4i);
  let x_6454 : i32 = x_6447.x;
  let x_6463 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_6452 % x_6454), (x_6452 / x_6454)), 0i);
  let x_6778 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_6785 : i32 = x_6778.x;
  let x_6794 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_6785), (x_3697 / x_6785)), 0i);
  let x_6866 : i32 = ((bitcast<i32>(x_6794[x_3710]) * 16i) + 5i);
  let x_7091 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_7096 : i32 = (x_6866 / 4i);
  let x_7098 : i32 = x_7091.x;
  let x_7107 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_7096 % x_7098), (x_7096 / x_7098)), 0i);
  let x_7395 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_7402 : i32 = x_7395.x;
  let x_7411 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_7402), (x_3697 / x_7402)), 0i);
  let x_7492 : i32 = ((bitcast<i32>(x_7411[x_3710]) * 16i) + 6i);
  let x_7735 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_7740 : i32 = (x_7492 / 4i);
  let x_7742 : i32 = x_7735.x;
  let x_7751 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_7740 % x_7742), (x_7740 / x_7742)), 0i);
  let x_8012 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_8019 : i32 = x_8012.x;
  let x_8028 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_8019), (x_3697 / x_8019)), 0i);
  let x_8118 : i32 = ((bitcast<i32>(x_8028[x_3710]) * 16i) + 7i);
  let x_8379 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_8384 : i32 = (x_8118 / 4i);
  let x_8386 : i32 = x_8379.x;
  let x_8395 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_8384 % x_8386), (x_8384 / x_8386)), 0i);
  let x_8629 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_8636 : i32 = x_8629.x;
  let x_8645 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_8636), (x_3697 / x_8636)), 0i);
  let x_8744 : i32 = ((bitcast<i32>(x_8645[x_3710]) * 16i) + 8i);
  let x_9023 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_9028 : i32 = (x_8744 / 4i);
  let x_9030 : i32 = x_9023.x;
  let x_9039 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_9028 % x_9030), (x_9028 / x_9030)), 0i);
  let x_9246 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_9253 : i32 = x_9246.x;
  let x_9262 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_9253), (x_3697 / x_9253)), 0i);
  let x_9370 : i32 = ((bitcast<i32>(x_9262[x_3710]) * 16i) + 9i);
  let x_9667 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_9672 : i32 = (x_9370 / 4i);
  let x_9674 : i32 = x_9667.x;
  let x_9683 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_9672 % x_9674), (x_9672 / x_9674)), 0i);
  let x_9863 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_9870 : i32 = x_9863.x;
  let x_9879 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_9870), (x_3697 / x_9870)), 0i);
  let x_9996 : i32 = ((bitcast<i32>(x_9879[x_3710]) * 16i) + 10i);
  let x_10311 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_10316 : i32 = (x_9996 / 4i);
  let x_10318 : i32 = x_10311.x;
  let x_10327 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_10316 % x_10318), (x_10316 / x_10318)), 0i);
  let x_10480 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_10487 : i32 = x_10480.x;
  let x_10496 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_10487), (x_3697 / x_10487)), 0i);
  let x_10622 : i32 = ((bitcast<i32>(x_10496[x_3710]) * 16i) + 11i);
  let x_10955 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_10960 : i32 = (x_10622 / 4i);
  let x_10962 : i32 = x_10955.x;
  let x_10971 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_10960 % x_10962), (x_10960 / x_10962)), 0i);
  let x_2458 : mat3x4<f32> = transpose(mat4x3<f32>(vec3<f32>(bitcast<f32>(x_3887[(x_3732 % 4i)]), bitcast<f32>(x_4531[(x_4362 % 4i)]), bitcast<f32>(x_5175[(x_4988 % 4i)])), vec3<f32>(bitcast<f32>(x_5819[(x_5614 % 4i)]), bitcast<f32>(x_6463[(x_6240 % 4i)]), bitcast<f32>(x_7107[(x_6866 % 4i)])), vec3<f32>(bitcast<f32>(x_7751[(x_7492 % 4i)]), bitcast<f32>(x_8395[(x_8118 % 4i)]), bitcast<f32>(x_9039[(x_8744 % 4i)])), vec3<f32>(bitcast<f32>(x_9683[(x_9370 % 4i)]), bitcast<f32>(x_10327[(x_9996 % 4i)]), bitcast<f32>(x_10971[(x_10622 % 4i)]))));
  let x_2459 : vec3<f32> = Vertex_Position;
  let x_2465 : vec3<f32> = (vec4<f32>(x_2459.x, x_2459.y, x_2459.z, 1.0f) * x_2458);
  let x_2467 : vec3<f32> = (x_2465 * 0.40000000596046447754f);
  let x_2470 : vec3<i32> = vec3<i32>(floor(x_2467));
  let x_2472 : vec3<f32> = fract(x_2467);
  let x_2474 : vec3<u32> = bitcast<vec3<u32>>(x_2470);
  let x_2476 : u32 = x_2474.z;
  let x_2480 : u32 = (x_2476 + (x_2476 << 10u));
  let x_2484 : u32 = (x_2480 ^ (x_2480 >> 6u));
  let x_2488 : u32 = (x_2484 + (x_2484 << 3u));
  let x_2492 : u32 = (x_2488 ^ (x_2488 >> 11u));
  let x_2502 : u32 = ((((x_2474.y * 1664525u) + (x_2492 + (x_2492 << 15u))) + 1013904223u) * 1664525u);
  let x_2506 : u32 = (x_2502 ^ (x_2502 >> 11u));
  let x_2511 : u32 = (x_2506 ^ ((x_2506 << 7u) & 2636928640u));
  let x_2516 : u32 = (x_2511 ^ ((x_2511 << 15u) & 4022730752u));
  let x_2526 : u32 = ((((x_2474.x * 1664525u) + (x_2516 ^ (x_2516 >> 18u))) + 1013904223u) * 1664525u);
  let x_2530 : u32 = (x_2526 ^ (x_2526 >> 11u));
  let x_2535 : u32 = (x_2530 ^ ((x_2530 << 7u) & 2636928640u));
  let x_2540 : u32 = (x_2535 ^ ((x_2535 << 15u) & 4022730752u));
  let x_2544 : u32 = (x_2540 ^ (x_2540 >> 18u));
  x_15508 = x_2544;
  x_15507 = 0u;
  loop {
    if ((x_15507 >= 2u)) {
      break;
    }
    let x_2556 : u32 = (x_15508 + (x_15508 << 10u));
    let x_2560 : u32 = (x_2556 ^ (x_2556 >> 6u));
    let x_2564 : u32 = (x_2560 + (x_2560 << 3u));
    let x_2568 : u32 = (x_2564 ^ (x_2564 >> 11u));
    x_2143[x_15507] = (bitcast<f32>(((x_15508 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_15508 = (x_2568 + (x_2568 << 15u));
      x_15507 = (x_15507 + 1u);
    }
  }
  let x_2588 : vec3<u32> = bitcast<vec3<u32>>((x_2470 + vec3<i32>(1i, 0i, 0i)));
  let x_2590 : u32 = x_2588.z;
  let x_2594 : u32 = (x_2590 + (x_2590 << 10u));
  let x_2598 : u32 = (x_2594 ^ (x_2594 >> 6u));
  let x_2602 : u32 = (x_2598 + (x_2598 << 3u));
  let x_2606 : u32 = (x_2602 ^ (x_2602 >> 11u));
  let x_2616 : u32 = ((((x_2588.y * 1664525u) + (x_2606 + (x_2606 << 15u))) + 1013904223u) * 1664525u);
  let x_2620 : u32 = (x_2616 ^ (x_2616 >> 11u));
  let x_2625 : u32 = (x_2620 ^ ((x_2620 << 7u) & 2636928640u));
  let x_2630 : u32 = (x_2625 ^ ((x_2625 << 15u) & 4022730752u));
  let x_2640 : u32 = ((((x_2588.x * 1664525u) + (x_2630 ^ (x_2630 >> 18u))) + 1013904223u) * 1664525u);
  let x_2644 : u32 = (x_2640 ^ (x_2640 >> 11u));
  let x_2649 : u32 = (x_2644 ^ ((x_2644 << 7u) & 2636928640u));
  let x_2654 : u32 = (x_2649 ^ ((x_2649 << 15u) & 4022730752u));
  let x_2658 : u32 = (x_2654 ^ (x_2654 >> 18u));
  x_15511 = x_2658;
  x_15510 = 0u;
  loop {
    if ((x_15510 >= 2u)) {
      break;
    }
    let x_2670 : u32 = (x_15511 + (x_15511 << 10u));
    let x_2674 : u32 = (x_2670 ^ (x_2670 >> 6u));
    let x_2678 : u32 = (x_2674 + (x_2674 << 3u));
    let x_2682 : u32 = (x_2678 ^ (x_2678 >> 11u));
    x_2167[x_15510] = (bitcast<f32>(((x_15511 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_15511 = (x_2682 + (x_2682 << 15u));
      x_15510 = (x_15510 + 1u);
    }
  }
  let x_2702 : vec3<u32> = bitcast<vec3<u32>>((x_2470 + vec3<i32>(0i, 1i, 0i)));
  let x_2704 : u32 = x_2702.z;
  let x_2708 : u32 = (x_2704 + (x_2704 << 10u));
  let x_2712 : u32 = (x_2708 ^ (x_2708 >> 6u));
  let x_2716 : u32 = (x_2712 + (x_2712 << 3u));
  let x_2720 : u32 = (x_2716 ^ (x_2716 >> 11u));
  let x_2730 : u32 = ((((x_2702.y * 1664525u) + (x_2720 + (x_2720 << 15u))) + 1013904223u) * 1664525u);
  let x_2734 : u32 = (x_2730 ^ (x_2730 >> 11u));
  let x_2739 : u32 = (x_2734 ^ ((x_2734 << 7u) & 2636928640u));
  let x_2744 : u32 = (x_2739 ^ ((x_2739 << 15u) & 4022730752u));
  let x_2754 : u32 = ((((x_2702.x * 1664525u) + (x_2744 ^ (x_2744 >> 18u))) + 1013904223u) * 1664525u);
  let x_2758 : u32 = (x_2754 ^ (x_2754 >> 11u));
  let x_2763 : u32 = (x_2758 ^ ((x_2758 << 7u) & 2636928640u));
  let x_2768 : u32 = (x_2763 ^ ((x_2763 << 15u) & 4022730752u));
  let x_2772 : u32 = (x_2768 ^ (x_2768 >> 18u));
  x_15514 = x_2772;
  x_15513 = 0u;
  loop {
    if ((x_15513 >= 2u)) {
      break;
    }
    let x_2784 : u32 = (x_15514 + (x_15514 << 10u));
    let x_2788 : u32 = (x_2784 ^ (x_2784 >> 6u));
    let x_2792 : u32 = (x_2788 + (x_2788 << 3u));
    let x_2796 : u32 = (x_2792 ^ (x_2792 >> 11u));
    x_2191[x_15513] = (bitcast<f32>(((x_15514 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_15514 = (x_2796 + (x_2796 << 15u));
      x_15513 = (x_15513 + 1u);
    }
  }
  let x_2816 : vec3<u32> = bitcast<vec3<u32>>((x_2470 + vec3<i32>(1i, 1i, 0i)));
  let x_2818 : u32 = x_2816.z;
  let x_2822 : u32 = (x_2818 + (x_2818 << 10u));
  let x_2826 : u32 = (x_2822 ^ (x_2822 >> 6u));
  let x_2830 : u32 = (x_2826 + (x_2826 << 3u));
  let x_2834 : u32 = (x_2830 ^ (x_2830 >> 11u));
  let x_2844 : u32 = ((((x_2816.y * 1664525u) + (x_2834 + (x_2834 << 15u))) + 1013904223u) * 1664525u);
  let x_2848 : u32 = (x_2844 ^ (x_2844 >> 11u));
  let x_2853 : u32 = (x_2848 ^ ((x_2848 << 7u) & 2636928640u));
  let x_2858 : u32 = (x_2853 ^ ((x_2853 << 15u) & 4022730752u));
  let x_2868 : u32 = ((((x_2816.x * 1664525u) + (x_2858 ^ (x_2858 >> 18u))) + 1013904223u) * 1664525u);
  let x_2872 : u32 = (x_2868 ^ (x_2868 >> 11u));
  let x_2877 : u32 = (x_2872 ^ ((x_2872 << 7u) & 2636928640u));
  let x_2882 : u32 = (x_2877 ^ ((x_2877 << 15u) & 4022730752u));
  let x_2886 : u32 = (x_2882 ^ (x_2882 >> 18u));
  x_15517 = x_2886;
  x_15516 = 0u;
  loop {
    if ((x_15516 >= 2u)) {
      break;
    }
    let x_2898 : u32 = (x_15517 + (x_15517 << 10u));
    let x_2902 : u32 = (x_2898 ^ (x_2898 >> 6u));
    let x_2906 : u32 = (x_2902 + (x_2902 << 3u));
    let x_2910 : u32 = (x_2906 ^ (x_2906 >> 11u));
    x_2215[x_15516] = (bitcast<f32>(((x_15517 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_15517 = (x_2910 + (x_2910 << 15u));
      x_15516 = (x_15516 + 1u);
    }
  }
  let x_2930 : vec3<u32> = bitcast<vec3<u32>>((x_2470 + vec3<i32>(0i, 0i, 1i)));
  let x_2932 : u32 = x_2930.z;
  let x_2936 : u32 = (x_2932 + (x_2932 << 10u));
  let x_2940 : u32 = (x_2936 ^ (x_2936 >> 6u));
  let x_2944 : u32 = (x_2940 + (x_2940 << 3u));
  let x_2948 : u32 = (x_2944 ^ (x_2944 >> 11u));
  let x_2958 : u32 = ((((x_2930.y * 1664525u) + (x_2948 + (x_2948 << 15u))) + 1013904223u) * 1664525u);
  let x_2962 : u32 = (x_2958 ^ (x_2958 >> 11u));
  let x_2967 : u32 = (x_2962 ^ ((x_2962 << 7u) & 2636928640u));
  let x_2972 : u32 = (x_2967 ^ ((x_2967 << 15u) & 4022730752u));
  let x_2982 : u32 = ((((x_2930.x * 1664525u) + (x_2972 ^ (x_2972 >> 18u))) + 1013904223u) * 1664525u);
  let x_2986 : u32 = (x_2982 ^ (x_2982 >> 11u));
  let x_2991 : u32 = (x_2986 ^ ((x_2986 << 7u) & 2636928640u));
  let x_2996 : u32 = (x_2991 ^ ((x_2991 << 15u) & 4022730752u));
  let x_3000 : u32 = (x_2996 ^ (x_2996 >> 18u));
  x_15520 = x_3000;
  x_15519 = 0u;
  loop {
    if ((x_15519 >= 2u)) {
      break;
    }
    let x_3012 : u32 = (x_15520 + (x_15520 << 10u));
    let x_3016 : u32 = (x_3012 ^ (x_3012 >> 6u));
    let x_3020 : u32 = (x_3016 + (x_3016 << 3u));
    let x_3024 : u32 = (x_3020 ^ (x_3020 >> 11u));
    x_2239[x_15519] = (bitcast<f32>(((x_15520 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_15520 = (x_3024 + (x_3024 << 15u));
      x_15519 = (x_15519 + 1u);
    }
  }
  let x_3044 : vec3<u32> = bitcast<vec3<u32>>((x_2470 + vec3<i32>(1i, 0i, 1i)));
  let x_3046 : u32 = x_3044.z;
  let x_3050 : u32 = (x_3046 + (x_3046 << 10u));
  let x_3054 : u32 = (x_3050 ^ (x_3050 >> 6u));
  let x_3058 : u32 = (x_3054 + (x_3054 << 3u));
  let x_3062 : u32 = (x_3058 ^ (x_3058 >> 11u));
  let x_3072 : u32 = ((((x_3044.y * 1664525u) + (x_3062 + (x_3062 << 15u))) + 1013904223u) * 1664525u);
  let x_3076 : u32 = (x_3072 ^ (x_3072 >> 11u));
  let x_3081 : u32 = (x_3076 ^ ((x_3076 << 7u) & 2636928640u));
  let x_3086 : u32 = (x_3081 ^ ((x_3081 << 15u) & 4022730752u));
  let x_3096 : u32 = ((((x_3044.x * 1664525u) + (x_3086 ^ (x_3086 >> 18u))) + 1013904223u) * 1664525u);
  let x_3100 : u32 = (x_3096 ^ (x_3096 >> 11u));
  let x_3105 : u32 = (x_3100 ^ ((x_3100 << 7u) & 2636928640u));
  let x_3110 : u32 = (x_3105 ^ ((x_3105 << 15u) & 4022730752u));
  let x_3114 : u32 = (x_3110 ^ (x_3110 >> 18u));
  x_15523 = x_3114;
  x_15522 = 0u;
  loop {
    if ((x_15522 >= 2u)) {
      break;
    }
    let x_3126 : u32 = (x_15523 + (x_15523 << 10u));
    let x_3130 : u32 = (x_3126 ^ (x_3126 >> 6u));
    let x_3134 : u32 = (x_3130 + (x_3130 << 3u));
    let x_3138 : u32 = (x_3134 ^ (x_3134 >> 11u));
    x_2263[x_15522] = (bitcast<f32>(((x_15523 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_15523 = (x_3138 + (x_3138 << 15u));
      x_15522 = (x_15522 + 1u);
    }
  }
  let x_3158 : vec3<u32> = bitcast<vec3<u32>>((x_2470 + vec3<i32>(0i, 1i, 1i)));
  let x_3160 : u32 = x_3158.z;
  let x_3164 : u32 = (x_3160 + (x_3160 << 10u));
  let x_3168 : u32 = (x_3164 ^ (x_3164 >> 6u));
  let x_3172 : u32 = (x_3168 + (x_3168 << 3u));
  let x_3176 : u32 = (x_3172 ^ (x_3172 >> 11u));
  let x_3186 : u32 = ((((x_3158.y * 1664525u) + (x_3176 + (x_3176 << 15u))) + 1013904223u) * 1664525u);
  let x_3190 : u32 = (x_3186 ^ (x_3186 >> 11u));
  let x_3195 : u32 = (x_3190 ^ ((x_3190 << 7u) & 2636928640u));
  let x_3200 : u32 = (x_3195 ^ ((x_3195 << 15u) & 4022730752u));
  let x_3210 : u32 = ((((x_3158.x * 1664525u) + (x_3200 ^ (x_3200 >> 18u))) + 1013904223u) * 1664525u);
  let x_3214 : u32 = (x_3210 ^ (x_3210 >> 11u));
  let x_3219 : u32 = (x_3214 ^ ((x_3214 << 7u) & 2636928640u));
  let x_3224 : u32 = (x_3219 ^ ((x_3219 << 15u) & 4022730752u));
  let x_3228 : u32 = (x_3224 ^ (x_3224 >> 18u));
  x_15526 = x_3228;
  x_15525 = 0u;
  loop {
    if ((x_15525 >= 2u)) {
      break;
    }
    let x_3240 : u32 = (x_15526 + (x_15526 << 10u));
    let x_3244 : u32 = (x_3240 ^ (x_3240 >> 6u));
    let x_3248 : u32 = (x_3244 + (x_3244 << 3u));
    let x_3252 : u32 = (x_3248 ^ (x_3248 >> 11u));
    x_2287[x_15525] = (bitcast<f32>(((x_15526 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_15526 = (x_3252 + (x_3252 << 15u));
      x_15525 = (x_15525 + 1u);
    }
  }
  let x_3272 : vec3<u32> = bitcast<vec3<u32>>((x_2470 + vec3<i32>(1i, 1i, 1i)));
  let x_3274 : u32 = x_3272.z;
  let x_3278 : u32 = (x_3274 + (x_3274 << 10u));
  let x_3282 : u32 = (x_3278 ^ (x_3278 >> 6u));
  let x_3286 : u32 = (x_3282 + (x_3282 << 3u));
  let x_3290 : u32 = (x_3286 ^ (x_3286 >> 11u));
  let x_3300 : u32 = ((((x_3272.y * 1664525u) + (x_3290 + (x_3290 << 15u))) + 1013904223u) * 1664525u);
  let x_3304 : u32 = (x_3300 ^ (x_3300 >> 11u));
  let x_3309 : u32 = (x_3304 ^ ((x_3304 << 7u) & 2636928640u));
  let x_3314 : u32 = (x_3309 ^ ((x_3309 << 15u) & 4022730752u));
  let x_3324 : u32 = ((((x_3272.x * 1664525u) + (x_3314 ^ (x_3314 >> 18u))) + 1013904223u) * 1664525u);
  let x_3328 : u32 = (x_3324 ^ (x_3324 >> 11u));
  let x_3333 : u32 = (x_3328 ^ ((x_3328 << 7u) & 2636928640u));
  let x_3338 : u32 = (x_3333 ^ ((x_3333 << 15u) & 4022730752u));
  let x_3342 : u32 = (x_3338 ^ (x_3338 >> 18u));
  x_15529 = x_3342;
  x_15528 = 0u;
  loop {
    if ((x_15528 >= 2u)) {
      break;
    }
    let x_3354 : u32 = (x_15529 + (x_15529 << 10u));
    let x_3358 : u32 = (x_3354 ^ (x_3354 >> 6u));
    let x_3362 : u32 = (x_3358 + (x_3358 << 3u));
    let x_3366 : u32 = (x_3362 ^ (x_3362 >> 11u));
    x_2311[x_15528] = (bitcast<f32>(((x_15529 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_15529 = (x_3366 + (x_3366 << 15u));
      x_15528 = (x_15528 + 1u);
    }
  }
  let x_3390 : vec3<f32> = ((x_2472 * x_2472) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_2472)));
  let x_3392 : f32 = x_3390.x;
  let x_3394 : f32 = (1.0f - x_3392);
  let x_3396 : f32 = x_3390.y;
  let x_3398 : f32 = (1.0f - x_3396);
  let x_3400 : f32 = x_3390.z;
  let x_3402 : f32 = (1.0f - x_3400);
  let x_3403 : vec2<f32> = x_2143;
  let x_3410 : vec2<f32> = x_2167;
  let x_3418 : vec2<f32> = x_2191;
  let x_3426 : vec2<f32> = x_2215;
  let x_3434 : vec2<f32> = x_2239;
  let x_3442 : vec2<f32> = x_2263;
  let x_3450 : vec2<f32> = x_2287;
  let x_3458 : vec2<f32> = x_2311;
  let x_3468 : vec2<f32> = clamp(((((((((((((x_3403 * x_3394) * x_3398) * x_3402) + (((x_3410 * x_3392) * x_3398) * x_3402)) + (((x_3418 * x_3394) * x_3396) * x_3402)) + (((x_3426 * x_3392) * x_3396) * x_3402)) + (((x_3434 * x_3394) * x_3398) * x_3400)) + (((x_3442 * x_3392) * x_3398) * x_3400)) + (((x_3450 * x_3394) * x_3396) * x_3400)) + (((x_3458 * x_3392) * x_3396) * x_3400)) - x_1757) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_1757);
  let x_3476 : vec3<f32> = (x_2465 + (vec3<f32>(x_3468.x, 0.0f, x_3468.y) * 0.05999999865889549255f));
  let x_11097 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_11104 : i32 = x_11097.x;
  let x_11113 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_11104), (x_3697 / x_11104)), 0i);
  let x_11258 : i32 = ((bitcast<i32>(x_11113[x_3710]) * 16i) + 14i);
  let x_11653 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_11658 : i32 = (x_11258 / 4i);
  let x_11660 : i32 = x_11653.x;
  let x_11669 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_11658 % x_11660), (x_11658 / x_11660)), 0i);
  let x_3484 : bool = ((x_11669[(x_11258 % 4i)] & 2147483648u) != 0u);
  let x_3486 : i32 = select(512i, 1536i, x_3484);
  let x_11714 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_11721 : i32 = x_11714.x;
  let x_11730 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_11721), (x_3697 / x_11721)), 0i);
  let x_11865 : i32 = ((bitcast<i32>(x_11730[x_3710]) * 16i) + 12i);
  let x_12216 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_12221 : i32 = (x_11865 / 4i);
  let x_12223 : i32 = x_12216.x;
  let x_12232 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_12221 % x_12223), (x_12221 / x_12223)), 0i);
  let x_3493 : vec2<f32> = unpack2x16float(x_12232[(x_11865 % 4i)]);
  let x_12331 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_12338 : i32 = x_12331.x;
  let x_12347 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_12338), (x_3697 / x_12338)), 0i);
  let x_12492 : i32 = ((bitcast<i32>(x_12347[x_3710]) * 16i) + 14i);
  let x_12887 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_12892 : i32 = (x_12492 / 4i);
  let x_12894 : i32 = x_12887.x;
  let x_12903 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_12892 % x_12894), (x_12892 / x_12894)), 0i);
  let x_3502 : i32 = bitcast<i32>((x_12903[(x_12492 % 4i)] & 2147483647u));
  let x_12948 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_21_0, 0i));
  let x_12953 : i32 = (x_3502 / 4i);
  let x_12955 : i32 = x_12948.x;
  let x_12964 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_21_0, vec2<i32>((x_12953 % x_12955), (x_12953 / x_12955)), 0i);
  let x_12966 : i32 = (x_3502 % 4i);
  let x_3504 : u32 = (x_12964[x_12966] & 65535u);
  let x_3506 : u32 = (x_3504 ^ 7993234u);
  let x_3510 : u32 = (x_3506 + (x_3506 << 10u));
  let x_3514 : u32 = (x_3510 ^ (x_3510 >> 6u));
  let x_3518 : u32 = (x_3514 + (x_3514 << 3u));
  let x_3522 : u32 = (x_3518 ^ (x_3518 >> 11u));
  let x_3524 : u32 = (x_3504 ^ 3450234u);
  let x_3528 : u32 = (x_3524 + (x_3524 << 10u));
  let x_3532 : u32 = (x_3528 ^ (x_3528 >> 6u));
  let x_3536 : u32 = (x_3532 + (x_3532 << 3u));
  let x_3540 : u32 = (x_3536 ^ (x_3536 >> 11u));
  let x_3546 : f32 = Vertex_Position.x;
  let x_12982 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_12989 : i32 = x_12982.x;
  let x_12998 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_12989), (x_3697 / x_12989)), 0i);
  let x_13148 : i32 = ((bitcast<i32>(x_12998[x_3710]) * 16i) + 15i);
  let x_13565 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_13570 : i32 = (x_13148 / 4i);
  let x_13572 : i32 = x_13565.x;
  let x_13581 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_13570 % x_13572), (x_13570 / x_13572)), 0i);
  let x_3559 : f32 = x_3476.y;
  let x_3565 : f32 = (f32(x_3504) * 0.20000000298023223877f);
  let x_3585 : vec2<f32> = ((((vec2<f32>(mix(x_3493.x, x_3493.y, (((x_3546 / (bitcast<f32>(x_13581[(x_13148 % 4i)]) * 0.5f)) * 0.5f) + 0.5f)), x_3559) * 0.10000000149011611938f) * 0.69999998807907104492f) + vec2<f32>(x_3565, x_3565)) + vec2<f32>((bitcast<f32>((((x_3522 + (x_3522 << 15u)) & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_3540 + (x_3540 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
  let x_13599 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_13606 : i32 = x_13599.x;
  let x_13615 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_13606), (x_3697 / x_13606)), 0i);
  let x_13755 : i32 = ((bitcast<i32>(x_13615[x_3710]) * 16i) + 13i);
  let x_14128 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_14133 : i32 = (x_13755 / 4i);
  let x_14135 : i32 = x_14128.x;
  let x_14144 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_14133 % x_14135), (x_14133 / x_14135)), 0i);
  let x_3592 : u32 = (x_14144[(x_13755 % 4i)] ^ 292478890u);
  let x_3596 : u32 = (x_3592 + (x_3592 << 10u));
  let x_3600 : u32 = (x_3596 ^ (x_3596 >> 6u));
  let x_3604 : u32 = (x_3600 + (x_3600 << 3u));
  let x_3608 : u32 = (x_3604 ^ (x_3604 >> 11u));
  let x_3616 : f32 = (bitcast<f32>((((x_3608 + (x_3608 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
  if ((x_3616 > 0.89999997615814208984f)) {
    x_3621 = (x_3585 * 3.0f);
    x_15555 = x_3621;
  } else {
    let x_3625 : f32 = (0.61000001430511474609f * x_3616);
    x_3627 = (x_3585 + vec2<f32>(x_3625, x_3625));
    x_15555 = x_3627;
  }
  let x_3636 : vec2<f32> = (x_15555 * 2.20000004768371582031f);
  if (x_3484) {
    x_3642 = Vertex_UV;
    x_15573 = x_3642;
  } else {
    x_15573 = x_3636;
  }
  let x_3647 : mat4x4<f32> = x_2004.renderer_MVPMat;
  gl_Position = (x_3647 * vec4<f32>(x_3476.x, x_3559, x_3476.z, 1.0f));
  let x_14216 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_14223 : i32 = x_14216.x;
  let x_14232 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_14223), (x_3697 / x_14223)), 0i);
  let x_14372 : i32 = ((bitcast<i32>(x_14232[x_3710]) * 16i) + 13i);
  let x_14745 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_14750 : i32 = (x_14372 / 4i);
  let x_14752 : i32 = x_14745.x;
  let x_14761 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_14750 % x_14752), (x_14750 / x_14752)), 0i);
  v0 = x_14761[(x_14372 % 4i)];
  let x_3661 : vec3<f32> = Vertex_Normal;
  v1 = (vec4<f32>(x_3661.x, x_3661.y, x_3661.z, 0.0f) * x_2458);
  v2 = x_3476;
  v7 = 0.0f;
  v8 = -100000.0f;
  v9 = x_15573;
  let x_14833 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_14840 : i32 = x_14833.x;
  let x_14849 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_12953 % x_14840), (x_12953 / x_14840)), 0i);
  v10 = bitcast<i32>(x_14849[x_12966]);
  v11 = vec2<f32>(100000.0f, 100000.0f);
  v12 = x_3486;
  let x_14867 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_14874 : i32 = x_14867.x;
  let x_14883 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3697 % x_14874), (x_3697 / x_14874)), 0i);
  v13 = x_14883[x_3710];
  let x_2078 : f32 = gl_Position.z;
  let x_2080 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_2078 + x_2080));
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
  @location(9) @interpolate(flat)
  v13_1 : u32,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @location(0) Vertex_Position_param : vec3<f32>, @location(3) Vertex_UV_param : vec2<f32>, @location(2) Vertex_Normal_param : vec3<f32>) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  Vertex_Position = Vertex_Position_param;
  Vertex_UV = Vertex_UV_param;
  Vertex_Normal = Vertex_Normal_param;
  main_1();
  return main_out(gl_Position, v0, v1, v2, v7, v8, v9, v10, v11, v12, v13);
}
