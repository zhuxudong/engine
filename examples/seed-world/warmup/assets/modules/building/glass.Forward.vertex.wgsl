diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(0) @group(3) var gs_wgpu_tex_storage_6_0 : texture_2d<u32>;

@binding(1) @group(3) var gs_wgpu_samp_storage_6_0 : sampler;

@binding(2) @group(3) var gs_wgpu_tex_storage_0_1 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_1 : sampler;

var<private> gl_InstanceIndex : i32;

var<private> Vertex_Position : vec3<f32>;

@binding(0) @group(2) var<uniform> x_1697 : gs_Auto_0;

var<private> v0 : vec3<f32>;

var<private> Vertex_Color : vec3<f32>;

var<private> v2 : vec3<f32>;

var<private> v3 : vec2<f32>;

var<private> Vertex_UV : vec2<f32>;

var<private> v4 : u32;

var<private> v5 : u32;

var<private> is_glass : i32;

var<private> v6 : vec3<f32>;

var<private> v7 : u32;

var<private> gl_Position : vec4<f32>;

const x_1673 = vec2<f32>(0.5f, 0.5f);

fn main_1() {
  var x_1826 : vec2<f32>;
  var x_1850 : vec2<f32>;
  var x_1874 : vec2<f32>;
  var x_1898 : vec2<f32>;
  var x_1922 : vec2<f32>;
  var x_1946 : vec2<f32>;
  var x_1970 : vec2<f32>;
  var x_1994 : vec2<f32>;
  var x_11813 : u32;
  var x_11812 : u32;
  var x_11816 : u32;
  var x_11815 : u32;
  var x_11819 : u32;
  var x_11818 : u32;
  var x_11822 : u32;
  var x_11821 : u32;
  var x_11825 : u32;
  var x_11824 : u32;
  var x_11828 : u32;
  var x_11827 : u32;
  var x_11831 : u32;
  var x_11830 : u32;
  var x_11834 : u32;
  var x_11833 : u32;
  let x_2009 : i32 = gl_InstanceIndex;
  let x_3172 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_3177 : i32 = (x_2009 / 4i);
  let x_3179 : i32 = x_3172.x;
  let x_3188 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_3179), (x_3177 / x_3179)), 0i);
  let x_3190 : i32 = (x_2009 % 4i);
  let x_3212 : i32 = (bitcast<i32>(x_3188[x_3190]) * 16i);
  let x_3351 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_3356 : i32 = (x_3212 / 4i);
  let x_3358 : i32 = x_3351.x;
  let x_3367 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_3356 % x_3358), (x_3356 / x_3358)), 0i);
  let x_3790 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_3797 : i32 = x_3790.x;
  let x_3806 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_3797), (x_3177 / x_3797)), 0i);
  let x_3842 : i32 = ((bitcast<i32>(x_3806[x_3190]) * 16i) + 1i);
  let x_3995 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_4000 : i32 = (x_3842 / 4i);
  let x_4002 : i32 = x_3995.x;
  let x_4011 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4000 % x_4002), (x_4000 / x_4002)), 0i);
  let x_4407 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_4414 : i32 = x_4407.x;
  let x_4423 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_4414), (x_3177 / x_4414)), 0i);
  let x_4468 : i32 = ((bitcast<i32>(x_4423[x_3190]) * 16i) + 2i);
  let x_4639 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_4644 : i32 = (x_4468 / 4i);
  let x_4646 : i32 = x_4639.x;
  let x_4655 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4644 % x_4646), (x_4644 / x_4646)), 0i);
  let x_5024 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_5031 : i32 = x_5024.x;
  let x_5040 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_5031), (x_3177 / x_5031)), 0i);
  let x_5094 : i32 = ((bitcast<i32>(x_5040[x_3190]) * 16i) + 3i);
  let x_5283 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_5288 : i32 = (x_5094 / 4i);
  let x_5290 : i32 = x_5283.x;
  let x_5299 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5288 % x_5290), (x_5288 / x_5290)), 0i);
  let x_5641 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_5648 : i32 = x_5641.x;
  let x_5657 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_5648), (x_3177 / x_5648)), 0i);
  let x_5720 : i32 = ((bitcast<i32>(x_5657[x_3190]) * 16i) + 4i);
  let x_5927 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_5932 : i32 = (x_5720 / 4i);
  let x_5934 : i32 = x_5927.x;
  let x_5943 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5932 % x_5934), (x_5932 / x_5934)), 0i);
  let x_6258 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_6265 : i32 = x_6258.x;
  let x_6274 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_6265), (x_3177 / x_6265)), 0i);
  let x_6346 : i32 = ((bitcast<i32>(x_6274[x_3190]) * 16i) + 5i);
  let x_6571 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_6576 : i32 = (x_6346 / 4i);
  let x_6578 : i32 = x_6571.x;
  let x_6587 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_6576 % x_6578), (x_6576 / x_6578)), 0i);
  let x_6875 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_6882 : i32 = x_6875.x;
  let x_6891 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_6882), (x_3177 / x_6882)), 0i);
  let x_6972 : i32 = ((bitcast<i32>(x_6891[x_3190]) * 16i) + 6i);
  let x_7215 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_7220 : i32 = (x_6972 / 4i);
  let x_7222 : i32 = x_7215.x;
  let x_7231 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_7220 % x_7222), (x_7220 / x_7222)), 0i);
  let x_7492 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_7499 : i32 = x_7492.x;
  let x_7508 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_7499), (x_3177 / x_7499)), 0i);
  let x_7598 : i32 = ((bitcast<i32>(x_7508[x_3190]) * 16i) + 7i);
  let x_7859 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_7864 : i32 = (x_7598 / 4i);
  let x_7866 : i32 = x_7859.x;
  let x_7875 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_7864 % x_7866), (x_7864 / x_7866)), 0i);
  let x_8109 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_8116 : i32 = x_8109.x;
  let x_8125 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_8116), (x_3177 / x_8116)), 0i);
  let x_8224 : i32 = ((bitcast<i32>(x_8125[x_3190]) * 16i) + 8i);
  let x_8503 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_8508 : i32 = (x_8224 / 4i);
  let x_8510 : i32 = x_8503.x;
  let x_8519 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_8508 % x_8510), (x_8508 / x_8510)), 0i);
  let x_8726 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_8733 : i32 = x_8726.x;
  let x_8742 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_8733), (x_3177 / x_8733)), 0i);
  let x_8850 : i32 = ((bitcast<i32>(x_8742[x_3190]) * 16i) + 9i);
  let x_9147 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_9152 : i32 = (x_8850 / 4i);
  let x_9154 : i32 = x_9147.x;
  let x_9163 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_9152 % x_9154), (x_9152 / x_9154)), 0i);
  let x_9343 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_9350 : i32 = x_9343.x;
  let x_9359 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_9350), (x_3177 / x_9350)), 0i);
  let x_9476 : i32 = ((bitcast<i32>(x_9359[x_3190]) * 16i) + 10i);
  let x_9791 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_9796 : i32 = (x_9476 / 4i);
  let x_9798 : i32 = x_9791.x;
  let x_9807 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_9796 % x_9798), (x_9796 / x_9798)), 0i);
  let x_9960 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_9967 : i32 = x_9960.x;
  let x_9976 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_9967), (x_3177 / x_9967)), 0i);
  let x_10102 : i32 = ((bitcast<i32>(x_9976[x_3190]) * 16i) + 11i);
  let x_10435 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_10440 : i32 = (x_10102 / 4i);
  let x_10442 : i32 = x_10435.x;
  let x_10451 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_10440 % x_10442), (x_10440 / x_10442)), 0i);
  let x_2104 : mat3x4<f32> = transpose(mat4x3<f32>(vec3<f32>(bitcast<f32>(x_3367[(x_3212 % 4i)]), bitcast<f32>(x_4011[(x_3842 % 4i)]), bitcast<f32>(x_4655[(x_4468 % 4i)])), vec3<f32>(bitcast<f32>(x_5299[(x_5094 % 4i)]), bitcast<f32>(x_5943[(x_5720 % 4i)]), bitcast<f32>(x_6587[(x_6346 % 4i)])), vec3<f32>(bitcast<f32>(x_7231[(x_6972 % 4i)]), bitcast<f32>(x_7875[(x_7598 % 4i)]), bitcast<f32>(x_8519[(x_8224 % 4i)])), vec3<f32>(bitcast<f32>(x_9163[(x_8850 % 4i)]), bitcast<f32>(x_9807[(x_9476 % 4i)]), bitcast<f32>(x_10451[(x_10102 % 4i)]))));
  let x_2105 : vec3<f32> = Vertex_Position;
  let x_2111 : vec3<f32> = (vec4<f32>(x_2105.x, x_2105.y, x_2105.z, 1.0f) * x_2104);
  let x_2113 : vec3<f32> = (x_2111 * 0.40000000596046447754f);
  let x_2116 : vec3<i32> = vec3<i32>(floor(x_2113));
  let x_2118 : vec3<f32> = fract(x_2113);
  let x_2120 : vec3<u32> = bitcast<vec3<u32>>(x_2116);
  let x_2122 : u32 = x_2120.z;
  let x_2126 : u32 = (x_2122 + (x_2122 << 10u));
  let x_2130 : u32 = (x_2126 ^ (x_2126 >> 6u));
  let x_2134 : u32 = (x_2130 + (x_2130 << 3u));
  let x_2138 : u32 = (x_2134 ^ (x_2134 >> 11u));
  let x_2148 : u32 = ((((x_2120.y * 1664525u) + (x_2138 + (x_2138 << 15u))) + 1013904223u) * 1664525u);
  let x_2152 : u32 = (x_2148 ^ (x_2148 >> 11u));
  let x_2157 : u32 = (x_2152 ^ ((x_2152 << 7u) & 2636928640u));
  let x_2162 : u32 = (x_2157 ^ ((x_2157 << 15u) & 4022730752u));
  let x_2172 : u32 = ((((x_2120.x * 1664525u) + (x_2162 ^ (x_2162 >> 18u))) + 1013904223u) * 1664525u);
  let x_2176 : u32 = (x_2172 ^ (x_2172 >> 11u));
  let x_2181 : u32 = (x_2176 ^ ((x_2176 << 7u) & 2636928640u));
  let x_2186 : u32 = (x_2181 ^ ((x_2181 << 15u) & 4022730752u));
  let x_2190 : u32 = (x_2186 ^ (x_2186 >> 18u));
  x_11813 = x_2190;
  x_11812 = 0u;
  loop {
    if ((x_11812 >= 2u)) {
      break;
    }
    let x_2202 : u32 = (x_11813 + (x_11813 << 10u));
    let x_2206 : u32 = (x_2202 ^ (x_2202 >> 6u));
    let x_2210 : u32 = (x_2206 + (x_2206 << 3u));
    let x_2214 : u32 = (x_2210 ^ (x_2210 >> 11u));
    x_1826[x_11812] = (bitcast<f32>(((x_11813 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_11813 = (x_2214 + (x_2214 << 15u));
      x_11812 = (x_11812 + 1u);
    }
  }
  let x_2234 : vec3<u32> = bitcast<vec3<u32>>((x_2116 + vec3<i32>(1i, 0i, 0i)));
  let x_2236 : u32 = x_2234.z;
  let x_2240 : u32 = (x_2236 + (x_2236 << 10u));
  let x_2244 : u32 = (x_2240 ^ (x_2240 >> 6u));
  let x_2248 : u32 = (x_2244 + (x_2244 << 3u));
  let x_2252 : u32 = (x_2248 ^ (x_2248 >> 11u));
  let x_2262 : u32 = ((((x_2234.y * 1664525u) + (x_2252 + (x_2252 << 15u))) + 1013904223u) * 1664525u);
  let x_2266 : u32 = (x_2262 ^ (x_2262 >> 11u));
  let x_2271 : u32 = (x_2266 ^ ((x_2266 << 7u) & 2636928640u));
  let x_2276 : u32 = (x_2271 ^ ((x_2271 << 15u) & 4022730752u));
  let x_2286 : u32 = ((((x_2234.x * 1664525u) + (x_2276 ^ (x_2276 >> 18u))) + 1013904223u) * 1664525u);
  let x_2290 : u32 = (x_2286 ^ (x_2286 >> 11u));
  let x_2295 : u32 = (x_2290 ^ ((x_2290 << 7u) & 2636928640u));
  let x_2300 : u32 = (x_2295 ^ ((x_2295 << 15u) & 4022730752u));
  let x_2304 : u32 = (x_2300 ^ (x_2300 >> 18u));
  x_11816 = x_2304;
  x_11815 = 0u;
  loop {
    if ((x_11815 >= 2u)) {
      break;
    }
    let x_2316 : u32 = (x_11816 + (x_11816 << 10u));
    let x_2320 : u32 = (x_2316 ^ (x_2316 >> 6u));
    let x_2324 : u32 = (x_2320 + (x_2320 << 3u));
    let x_2328 : u32 = (x_2324 ^ (x_2324 >> 11u));
    x_1850[x_11815] = (bitcast<f32>(((x_11816 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_11816 = (x_2328 + (x_2328 << 15u));
      x_11815 = (x_11815 + 1u);
    }
  }
  let x_2348 : vec3<u32> = bitcast<vec3<u32>>((x_2116 + vec3<i32>(0i, 1i, 0i)));
  let x_2350 : u32 = x_2348.z;
  let x_2354 : u32 = (x_2350 + (x_2350 << 10u));
  let x_2358 : u32 = (x_2354 ^ (x_2354 >> 6u));
  let x_2362 : u32 = (x_2358 + (x_2358 << 3u));
  let x_2366 : u32 = (x_2362 ^ (x_2362 >> 11u));
  let x_2376 : u32 = ((((x_2348.y * 1664525u) + (x_2366 + (x_2366 << 15u))) + 1013904223u) * 1664525u);
  let x_2380 : u32 = (x_2376 ^ (x_2376 >> 11u));
  let x_2385 : u32 = (x_2380 ^ ((x_2380 << 7u) & 2636928640u));
  let x_2390 : u32 = (x_2385 ^ ((x_2385 << 15u) & 4022730752u));
  let x_2400 : u32 = ((((x_2348.x * 1664525u) + (x_2390 ^ (x_2390 >> 18u))) + 1013904223u) * 1664525u);
  let x_2404 : u32 = (x_2400 ^ (x_2400 >> 11u));
  let x_2409 : u32 = (x_2404 ^ ((x_2404 << 7u) & 2636928640u));
  let x_2414 : u32 = (x_2409 ^ ((x_2409 << 15u) & 4022730752u));
  let x_2418 : u32 = (x_2414 ^ (x_2414 >> 18u));
  x_11819 = x_2418;
  x_11818 = 0u;
  loop {
    if ((x_11818 >= 2u)) {
      break;
    }
    let x_2430 : u32 = (x_11819 + (x_11819 << 10u));
    let x_2434 : u32 = (x_2430 ^ (x_2430 >> 6u));
    let x_2438 : u32 = (x_2434 + (x_2434 << 3u));
    let x_2442 : u32 = (x_2438 ^ (x_2438 >> 11u));
    x_1874[x_11818] = (bitcast<f32>(((x_11819 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_11819 = (x_2442 + (x_2442 << 15u));
      x_11818 = (x_11818 + 1u);
    }
  }
  let x_2462 : vec3<u32> = bitcast<vec3<u32>>((x_2116 + vec3<i32>(1i, 1i, 0i)));
  let x_2464 : u32 = x_2462.z;
  let x_2468 : u32 = (x_2464 + (x_2464 << 10u));
  let x_2472 : u32 = (x_2468 ^ (x_2468 >> 6u));
  let x_2476 : u32 = (x_2472 + (x_2472 << 3u));
  let x_2480 : u32 = (x_2476 ^ (x_2476 >> 11u));
  let x_2490 : u32 = ((((x_2462.y * 1664525u) + (x_2480 + (x_2480 << 15u))) + 1013904223u) * 1664525u);
  let x_2494 : u32 = (x_2490 ^ (x_2490 >> 11u));
  let x_2499 : u32 = (x_2494 ^ ((x_2494 << 7u) & 2636928640u));
  let x_2504 : u32 = (x_2499 ^ ((x_2499 << 15u) & 4022730752u));
  let x_2514 : u32 = ((((x_2462.x * 1664525u) + (x_2504 ^ (x_2504 >> 18u))) + 1013904223u) * 1664525u);
  let x_2518 : u32 = (x_2514 ^ (x_2514 >> 11u));
  let x_2523 : u32 = (x_2518 ^ ((x_2518 << 7u) & 2636928640u));
  let x_2528 : u32 = (x_2523 ^ ((x_2523 << 15u) & 4022730752u));
  let x_2532 : u32 = (x_2528 ^ (x_2528 >> 18u));
  x_11822 = x_2532;
  x_11821 = 0u;
  loop {
    if ((x_11821 >= 2u)) {
      break;
    }
    let x_2544 : u32 = (x_11822 + (x_11822 << 10u));
    let x_2548 : u32 = (x_2544 ^ (x_2544 >> 6u));
    let x_2552 : u32 = (x_2548 + (x_2548 << 3u));
    let x_2556 : u32 = (x_2552 ^ (x_2552 >> 11u));
    x_1898[x_11821] = (bitcast<f32>(((x_11822 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_11822 = (x_2556 + (x_2556 << 15u));
      x_11821 = (x_11821 + 1u);
    }
  }
  let x_2576 : vec3<u32> = bitcast<vec3<u32>>((x_2116 + vec3<i32>(0i, 0i, 1i)));
  let x_2578 : u32 = x_2576.z;
  let x_2582 : u32 = (x_2578 + (x_2578 << 10u));
  let x_2586 : u32 = (x_2582 ^ (x_2582 >> 6u));
  let x_2590 : u32 = (x_2586 + (x_2586 << 3u));
  let x_2594 : u32 = (x_2590 ^ (x_2590 >> 11u));
  let x_2604 : u32 = ((((x_2576.y * 1664525u) + (x_2594 + (x_2594 << 15u))) + 1013904223u) * 1664525u);
  let x_2608 : u32 = (x_2604 ^ (x_2604 >> 11u));
  let x_2613 : u32 = (x_2608 ^ ((x_2608 << 7u) & 2636928640u));
  let x_2618 : u32 = (x_2613 ^ ((x_2613 << 15u) & 4022730752u));
  let x_2628 : u32 = ((((x_2576.x * 1664525u) + (x_2618 ^ (x_2618 >> 18u))) + 1013904223u) * 1664525u);
  let x_2632 : u32 = (x_2628 ^ (x_2628 >> 11u));
  let x_2637 : u32 = (x_2632 ^ ((x_2632 << 7u) & 2636928640u));
  let x_2642 : u32 = (x_2637 ^ ((x_2637 << 15u) & 4022730752u));
  let x_2646 : u32 = (x_2642 ^ (x_2642 >> 18u));
  x_11825 = x_2646;
  x_11824 = 0u;
  loop {
    if ((x_11824 >= 2u)) {
      break;
    }
    let x_2658 : u32 = (x_11825 + (x_11825 << 10u));
    let x_2662 : u32 = (x_2658 ^ (x_2658 >> 6u));
    let x_2666 : u32 = (x_2662 + (x_2662 << 3u));
    let x_2670 : u32 = (x_2666 ^ (x_2666 >> 11u));
    x_1922[x_11824] = (bitcast<f32>(((x_11825 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_11825 = (x_2670 + (x_2670 << 15u));
      x_11824 = (x_11824 + 1u);
    }
  }
  let x_2690 : vec3<u32> = bitcast<vec3<u32>>((x_2116 + vec3<i32>(1i, 0i, 1i)));
  let x_2692 : u32 = x_2690.z;
  let x_2696 : u32 = (x_2692 + (x_2692 << 10u));
  let x_2700 : u32 = (x_2696 ^ (x_2696 >> 6u));
  let x_2704 : u32 = (x_2700 + (x_2700 << 3u));
  let x_2708 : u32 = (x_2704 ^ (x_2704 >> 11u));
  let x_2718 : u32 = ((((x_2690.y * 1664525u) + (x_2708 + (x_2708 << 15u))) + 1013904223u) * 1664525u);
  let x_2722 : u32 = (x_2718 ^ (x_2718 >> 11u));
  let x_2727 : u32 = (x_2722 ^ ((x_2722 << 7u) & 2636928640u));
  let x_2732 : u32 = (x_2727 ^ ((x_2727 << 15u) & 4022730752u));
  let x_2742 : u32 = ((((x_2690.x * 1664525u) + (x_2732 ^ (x_2732 >> 18u))) + 1013904223u) * 1664525u);
  let x_2746 : u32 = (x_2742 ^ (x_2742 >> 11u));
  let x_2751 : u32 = (x_2746 ^ ((x_2746 << 7u) & 2636928640u));
  let x_2756 : u32 = (x_2751 ^ ((x_2751 << 15u) & 4022730752u));
  let x_2760 : u32 = (x_2756 ^ (x_2756 >> 18u));
  x_11828 = x_2760;
  x_11827 = 0u;
  loop {
    if ((x_11827 >= 2u)) {
      break;
    }
    let x_2772 : u32 = (x_11828 + (x_11828 << 10u));
    let x_2776 : u32 = (x_2772 ^ (x_2772 >> 6u));
    let x_2780 : u32 = (x_2776 + (x_2776 << 3u));
    let x_2784 : u32 = (x_2780 ^ (x_2780 >> 11u));
    x_1946[x_11827] = (bitcast<f32>(((x_11828 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_11828 = (x_2784 + (x_2784 << 15u));
      x_11827 = (x_11827 + 1u);
    }
  }
  let x_2804 : vec3<u32> = bitcast<vec3<u32>>((x_2116 + vec3<i32>(0i, 1i, 1i)));
  let x_2806 : u32 = x_2804.z;
  let x_2810 : u32 = (x_2806 + (x_2806 << 10u));
  let x_2814 : u32 = (x_2810 ^ (x_2810 >> 6u));
  let x_2818 : u32 = (x_2814 + (x_2814 << 3u));
  let x_2822 : u32 = (x_2818 ^ (x_2818 >> 11u));
  let x_2832 : u32 = ((((x_2804.y * 1664525u) + (x_2822 + (x_2822 << 15u))) + 1013904223u) * 1664525u);
  let x_2836 : u32 = (x_2832 ^ (x_2832 >> 11u));
  let x_2841 : u32 = (x_2836 ^ ((x_2836 << 7u) & 2636928640u));
  let x_2846 : u32 = (x_2841 ^ ((x_2841 << 15u) & 4022730752u));
  let x_2856 : u32 = ((((x_2804.x * 1664525u) + (x_2846 ^ (x_2846 >> 18u))) + 1013904223u) * 1664525u);
  let x_2860 : u32 = (x_2856 ^ (x_2856 >> 11u));
  let x_2865 : u32 = (x_2860 ^ ((x_2860 << 7u) & 2636928640u));
  let x_2870 : u32 = (x_2865 ^ ((x_2865 << 15u) & 4022730752u));
  let x_2874 : u32 = (x_2870 ^ (x_2870 >> 18u));
  x_11831 = x_2874;
  x_11830 = 0u;
  loop {
    if ((x_11830 >= 2u)) {
      break;
    }
    let x_2886 : u32 = (x_11831 + (x_11831 << 10u));
    let x_2890 : u32 = (x_2886 ^ (x_2886 >> 6u));
    let x_2894 : u32 = (x_2890 + (x_2890 << 3u));
    let x_2898 : u32 = (x_2894 ^ (x_2894 >> 11u));
    x_1970[x_11830] = (bitcast<f32>(((x_11831 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_11831 = (x_2898 + (x_2898 << 15u));
      x_11830 = (x_11830 + 1u);
    }
  }
  let x_2918 : vec3<u32> = bitcast<vec3<u32>>((x_2116 + vec3<i32>(1i, 1i, 1i)));
  let x_2920 : u32 = x_2918.z;
  let x_2924 : u32 = (x_2920 + (x_2920 << 10u));
  let x_2928 : u32 = (x_2924 ^ (x_2924 >> 6u));
  let x_2932 : u32 = (x_2928 + (x_2928 << 3u));
  let x_2936 : u32 = (x_2932 ^ (x_2932 >> 11u));
  let x_2946 : u32 = ((((x_2918.y * 1664525u) + (x_2936 + (x_2936 << 15u))) + 1013904223u) * 1664525u);
  let x_2950 : u32 = (x_2946 ^ (x_2946 >> 11u));
  let x_2955 : u32 = (x_2950 ^ ((x_2950 << 7u) & 2636928640u));
  let x_2960 : u32 = (x_2955 ^ ((x_2955 << 15u) & 4022730752u));
  let x_2970 : u32 = ((((x_2918.x * 1664525u) + (x_2960 ^ (x_2960 >> 18u))) + 1013904223u) * 1664525u);
  let x_2974 : u32 = (x_2970 ^ (x_2970 >> 11u));
  let x_2979 : u32 = (x_2974 ^ ((x_2974 << 7u) & 2636928640u));
  let x_2984 : u32 = (x_2979 ^ ((x_2979 << 15u) & 4022730752u));
  let x_2988 : u32 = (x_2984 ^ (x_2984 >> 18u));
  x_11834 = x_2988;
  x_11833 = 0u;
  loop {
    if ((x_11833 >= 2u)) {
      break;
    }
    let x_3000 : u32 = (x_11834 + (x_11834 << 10u));
    let x_3004 : u32 = (x_3000 ^ (x_3000 >> 6u));
    let x_3008 : u32 = (x_3004 + (x_3004 << 3u));
    let x_3012 : u32 = (x_3008 ^ (x_3008 >> 11u));
    x_1994[x_11833] = (bitcast<f32>(((x_11834 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_11834 = (x_3012 + (x_3012 << 15u));
      x_11833 = (x_11833 + 1u);
    }
  }
  let x_3036 : vec3<f32> = ((x_2118 * x_2118) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_2118)));
  let x_3038 : f32 = x_3036.x;
  let x_3040 : f32 = (1.0f - x_3038);
  let x_3042 : f32 = x_3036.y;
  let x_3044 : f32 = (1.0f - x_3042);
  let x_3046 : f32 = x_3036.z;
  let x_3048 : f32 = (1.0f - x_3046);
  let x_3049 : vec2<f32> = x_1826;
  let x_3056 : vec2<f32> = x_1850;
  let x_3064 : vec2<f32> = x_1874;
  let x_3072 : vec2<f32> = x_1898;
  let x_3080 : vec2<f32> = x_1922;
  let x_3088 : vec2<f32> = x_1946;
  let x_3096 : vec2<f32> = x_1970;
  let x_3104 : vec2<f32> = x_1994;
  let x_3114 : vec2<f32> = clamp(((((((((((((x_3049 * x_3040) * x_3044) * x_3048) + (((x_3056 * x_3038) * x_3044) * x_3048)) + (((x_3064 * x_3040) * x_3042) * x_3048)) + (((x_3072 * x_3038) * x_3042) * x_3048)) + (((x_3080 * x_3040) * x_3044) * x_3046)) + (((x_3088 * x_3038) * x_3044) * x_3046)) + (((x_3096 * x_3040) * x_3042) * x_3046)) + (((x_3104 * x_3038) * x_3042) * x_3046)) - x_1673) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_1673);
  let x_3122 : vec3<f32> = (x_2111 + (vec3<f32>(x_3114.x, 0.0f, x_3114.y) * 0.05999999865889549255f));
  let x_3124 : mat4x4<f32> = x_1697.renderer_MVPMat;
  gl_Position = (x_3124 * vec4<f32>(x_3122.x, x_3122.y, x_3122.z, 1.0f));
  let x_3132 : vec3<f32> = Vertex_Color;
  v0 = x_3132;
  v2 = x_3122;
  let x_3141 : vec2<f32> = Vertex_UV;
  v3 = (x_3141 * 0.75f);
  let x_10577 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_10584 : i32 = x_10577.x;
  let x_10593 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_10584), (x_3177 / x_10584)), 0i);
  v4 = x_10593[x_3190];
  let x_3146 : i32 = is_glass;
  v5 = bitcast<u32>(x_3146);
  v6 = (vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f) * x_2104);
  let x_10611 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_10618 : i32 = x_10611.x;
  let x_10627 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_3177 % x_10618), (x_3177 / x_10618)), 0i);
  let x_10762 : i32 = ((bitcast<i32>(x_10627[x_3190]) * 16i) + 12i);
  let x_11113 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_11118 : i32 = (x_10762 / 4i);
  let x_11120 : i32 = x_11113.x;
  let x_11129 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_11118 % x_11120), (x_11118 / x_11120)), 0i);
  v7 = ((x_11129[(x_10762 % 4i)] << 1u) >> 1u);
  let x_1761 : f32 = gl_Position.z;
  let x_1763 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_1761 + x_1763));
  return;
}

struct main_out {
  @builtin(position)
  gl_Position : vec4<f32>,
  @location(0)
  v0_1 : vec3<f32>,
  @location(1)
  v2_1 : vec3<f32>,
  @location(2)
  v3_1 : vec2<f32>,
  @location(3) @interpolate(flat)
  v4_1 : u32,
  @location(4) @interpolate(flat)
  v5_1 : u32,
  @location(5) @interpolate(flat)
  v6_1 : vec3<f32>,
  @location(6) @interpolate(flat)
  v7_1 : u32,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @location(0) Vertex_Position_param : vec3<f32>, @location(1) Vertex_Color_param : vec3<f32>, @location(3) Vertex_UV_param : vec2<f32>, @location(4) @interpolate(flat) is_glass_param : i32) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  Vertex_Position = Vertex_Position_param;
  Vertex_Color = Vertex_Color_param;
  Vertex_UV = Vertex_UV_param;
  is_glass = is_glass_param;
  main_1();
  return main_out(gl_Position, v0, v2, v3, v4, v5, v6, v7);
}
