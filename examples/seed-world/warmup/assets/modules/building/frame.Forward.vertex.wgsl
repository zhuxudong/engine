diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(0) @group(3) var gs_wgpu_tex_storage_19_0 : texture_2d<u32>;

@binding(1) @group(3) var gs_wgpu_samp_storage_19_0 : sampler;

@binding(2) @group(3) var gs_wgpu_tex_storage_0_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_0 : sampler;

var<private> gl_InstanceIndex : i32;

var<private> Vertex_Position : vec3<f32>;

@binding(0) @group(2) var<uniform> x_1696 : gs_Auto_0;

var<private> v1 : vec3<f32>;

var<private> Vertex_Normal : vec3<f32>;

var<private> v3 : vec2<f32>;

var<private> Vertex_UV : vec2<f32>;

var<private> v4 : u32;

var<private> v5 : u32;

var<private> gl_Position : vec4<f32>;

const x_1672 = vec2<f32>(0.5f, 0.5f);

fn main_1() {
  var x_1817 : vec2<f32>;
  var x_1841 : vec2<f32>;
  var x_1865 : vec2<f32>;
  var x_1889 : vec2<f32>;
  var x_1913 : vec2<f32>;
  var x_1937 : vec2<f32>;
  var x_1961 : vec2<f32>;
  var x_1985 : vec2<f32>;
  var x_12373 : u32;
  var x_12372 : u32;
  var x_12376 : u32;
  var x_12375 : u32;
  var x_12379 : u32;
  var x_12378 : u32;
  var x_12382 : u32;
  var x_12381 : u32;
  var x_12385 : u32;
  var x_12384 : u32;
  var x_12388 : u32;
  var x_12387 : u32;
  var x_12391 : u32;
  var x_12390 : u32;
  var x_12394 : u32;
  var x_12393 : u32;
  let x_2001 : i32 = gl_InstanceIndex;
  let x_3160 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_3165 : i32 = (x_2001 / 4i);
  let x_3167 : i32 = x_3160.x;
  let x_3176 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_3167), (x_3165 / x_3167)), 0i);
  let x_3178 : i32 = (x_2001 % 4i);
  let x_3200 : i32 = (bitcast<i32>(x_3176[x_3178]) * 16i);
  let x_3338 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_3343 : i32 = (x_3200 / 4i);
  let x_3345 : i32 = x_3338.x;
  let x_3354 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_3343 % x_3345), (x_3343 / x_3345)), 0i);
  let x_3777 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_3784 : i32 = x_3777.x;
  let x_3793 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_3784), (x_3165 / x_3784)), 0i);
  let x_3829 : i32 = ((bitcast<i32>(x_3793[x_3178]) * 16i) + 1i);
  let x_3981 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_3986 : i32 = (x_3829 / 4i);
  let x_3988 : i32 = x_3981.x;
  let x_3997 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_3986 % x_3988), (x_3986 / x_3988)), 0i);
  let x_4393 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_4400 : i32 = x_4393.x;
  let x_4409 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_4400), (x_3165 / x_4400)), 0i);
  let x_4454 : i32 = ((bitcast<i32>(x_4409[x_3178]) * 16i) + 2i);
  let x_4624 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_4629 : i32 = (x_4454 / 4i);
  let x_4631 : i32 = x_4624.x;
  let x_4640 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_4629 % x_4631), (x_4629 / x_4631)), 0i);
  let x_5009 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_5016 : i32 = x_5009.x;
  let x_5025 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_5016), (x_3165 / x_5016)), 0i);
  let x_5079 : i32 = ((bitcast<i32>(x_5025[x_3178]) * 16i) + 3i);
  let x_5267 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_5272 : i32 = (x_5079 / 4i);
  let x_5274 : i32 = x_5267.x;
  let x_5283 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5272 % x_5274), (x_5272 / x_5274)), 0i);
  let x_5625 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_5632 : i32 = x_5625.x;
  let x_5641 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_5632), (x_3165 / x_5632)), 0i);
  let x_5704 : i32 = ((bitcast<i32>(x_5641[x_3178]) * 16i) + 4i);
  let x_5910 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_5915 : i32 = (x_5704 / 4i);
  let x_5917 : i32 = x_5910.x;
  let x_5926 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5915 % x_5917), (x_5915 / x_5917)), 0i);
  let x_6241 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_6248 : i32 = x_6241.x;
  let x_6257 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_6248), (x_3165 / x_6248)), 0i);
  let x_6329 : i32 = ((bitcast<i32>(x_6257[x_3178]) * 16i) + 5i);
  let x_6553 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_6558 : i32 = (x_6329 / 4i);
  let x_6560 : i32 = x_6553.x;
  let x_6569 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_6558 % x_6560), (x_6558 / x_6560)), 0i);
  let x_6857 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_6864 : i32 = x_6857.x;
  let x_6873 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_6864), (x_3165 / x_6864)), 0i);
  let x_6954 : i32 = ((bitcast<i32>(x_6873[x_3178]) * 16i) + 6i);
  let x_7196 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_7201 : i32 = (x_6954 / 4i);
  let x_7203 : i32 = x_7196.x;
  let x_7212 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_7201 % x_7203), (x_7201 / x_7203)), 0i);
  let x_7473 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_7480 : i32 = x_7473.x;
  let x_7489 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_7480), (x_3165 / x_7480)), 0i);
  let x_7579 : i32 = ((bitcast<i32>(x_7489[x_3178]) * 16i) + 7i);
  let x_7839 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_7844 : i32 = (x_7579 / 4i);
  let x_7846 : i32 = x_7839.x;
  let x_7855 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_7844 % x_7846), (x_7844 / x_7846)), 0i);
  let x_8089 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_8096 : i32 = x_8089.x;
  let x_8105 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_8096), (x_3165 / x_8096)), 0i);
  let x_8204 : i32 = ((bitcast<i32>(x_8105[x_3178]) * 16i) + 8i);
  let x_8482 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_8487 : i32 = (x_8204 / 4i);
  let x_8489 : i32 = x_8482.x;
  let x_8498 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_8487 % x_8489), (x_8487 / x_8489)), 0i);
  let x_8705 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_8712 : i32 = x_8705.x;
  let x_8721 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_8712), (x_3165 / x_8712)), 0i);
  let x_8829 : i32 = ((bitcast<i32>(x_8721[x_3178]) * 16i) + 9i);
  let x_9125 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_9130 : i32 = (x_8829 / 4i);
  let x_9132 : i32 = x_9125.x;
  let x_9141 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_9130 % x_9132), (x_9130 / x_9132)), 0i);
  let x_9321 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_9328 : i32 = x_9321.x;
  let x_9337 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_9328), (x_3165 / x_9328)), 0i);
  let x_9454 : i32 = ((bitcast<i32>(x_9337[x_3178]) * 16i) + 10i);
  let x_9768 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_9773 : i32 = (x_9454 / 4i);
  let x_9775 : i32 = x_9768.x;
  let x_9784 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_9773 % x_9775), (x_9773 / x_9775)), 0i);
  let x_9937 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_9944 : i32 = x_9937.x;
  let x_9953 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_9944), (x_3165 / x_9944)), 0i);
  let x_10079 : i32 = ((bitcast<i32>(x_9953[x_3178]) * 16i) + 11i);
  let x_10411 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_10416 : i32 = (x_10079 / 4i);
  let x_10418 : i32 = x_10411.x;
  let x_10427 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_10416 % x_10418), (x_10416 / x_10418)), 0i);
  let x_2096 : mat3x4<f32> = transpose(mat4x3<f32>(vec3<f32>(bitcast<f32>(x_3354[(x_3200 % 4i)]), bitcast<f32>(x_3997[(x_3829 % 4i)]), bitcast<f32>(x_4640[(x_4454 % 4i)])), vec3<f32>(bitcast<f32>(x_5283[(x_5079 % 4i)]), bitcast<f32>(x_5926[(x_5704 % 4i)]), bitcast<f32>(x_6569[(x_6329 % 4i)])), vec3<f32>(bitcast<f32>(x_7212[(x_6954 % 4i)]), bitcast<f32>(x_7855[(x_7579 % 4i)]), bitcast<f32>(x_8498[(x_8204 % 4i)])), vec3<f32>(bitcast<f32>(x_9141[(x_8829 % 4i)]), bitcast<f32>(x_9784[(x_9454 % 4i)]), bitcast<f32>(x_10427[(x_10079 % 4i)]))));
  let x_2097 : vec3<f32> = Vertex_Position;
  let x_2103 : vec3<f32> = (vec4<f32>(x_2097.x, x_2097.y, x_2097.z, 1.0f) * x_2096);
  let x_2105 : vec3<f32> = (x_2103 * 0.40000000596046447754f);
  let x_2108 : vec3<i32> = vec3<i32>(floor(x_2105));
  let x_2110 : vec3<f32> = fract(x_2105);
  let x_2112 : vec3<u32> = bitcast<vec3<u32>>(x_2108);
  let x_2114 : u32 = x_2112.z;
  let x_2118 : u32 = (x_2114 + (x_2114 << 10u));
  let x_2122 : u32 = (x_2118 ^ (x_2118 >> 6u));
  let x_2126 : u32 = (x_2122 + (x_2122 << 3u));
  let x_2130 : u32 = (x_2126 ^ (x_2126 >> 11u));
  let x_2140 : u32 = ((((x_2112.y * 1664525u) + (x_2130 + (x_2130 << 15u))) + 1013904223u) * 1664525u);
  let x_2144 : u32 = (x_2140 ^ (x_2140 >> 11u));
  let x_2149 : u32 = (x_2144 ^ ((x_2144 << 7u) & 2636928640u));
  let x_2154 : u32 = (x_2149 ^ ((x_2149 << 15u) & 4022730752u));
  let x_2164 : u32 = ((((x_2112.x * 1664525u) + (x_2154 ^ (x_2154 >> 18u))) + 1013904223u) * 1664525u);
  let x_2168 : u32 = (x_2164 ^ (x_2164 >> 11u));
  let x_2173 : u32 = (x_2168 ^ ((x_2168 << 7u) & 2636928640u));
  let x_2178 : u32 = (x_2173 ^ ((x_2173 << 15u) & 4022730752u));
  let x_2182 : u32 = (x_2178 ^ (x_2178 >> 18u));
  x_12373 = x_2182;
  x_12372 = 0u;
  loop {
    if ((x_12372 >= 2u)) {
      break;
    }
    let x_2194 : u32 = (x_12373 + (x_12373 << 10u));
    let x_2198 : u32 = (x_2194 ^ (x_2194 >> 6u));
    let x_2202 : u32 = (x_2198 + (x_2198 << 3u));
    let x_2206 : u32 = (x_2202 ^ (x_2202 >> 11u));
    x_1817[x_12372] = (bitcast<f32>(((x_12373 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_12373 = (x_2206 + (x_2206 << 15u));
      x_12372 = (x_12372 + 1u);
    }
  }
  let x_2226 : vec3<u32> = bitcast<vec3<u32>>((x_2108 + vec3<i32>(1i, 0i, 0i)));
  let x_2228 : u32 = x_2226.z;
  let x_2232 : u32 = (x_2228 + (x_2228 << 10u));
  let x_2236 : u32 = (x_2232 ^ (x_2232 >> 6u));
  let x_2240 : u32 = (x_2236 + (x_2236 << 3u));
  let x_2244 : u32 = (x_2240 ^ (x_2240 >> 11u));
  let x_2254 : u32 = ((((x_2226.y * 1664525u) + (x_2244 + (x_2244 << 15u))) + 1013904223u) * 1664525u);
  let x_2258 : u32 = (x_2254 ^ (x_2254 >> 11u));
  let x_2263 : u32 = (x_2258 ^ ((x_2258 << 7u) & 2636928640u));
  let x_2268 : u32 = (x_2263 ^ ((x_2263 << 15u) & 4022730752u));
  let x_2278 : u32 = ((((x_2226.x * 1664525u) + (x_2268 ^ (x_2268 >> 18u))) + 1013904223u) * 1664525u);
  let x_2282 : u32 = (x_2278 ^ (x_2278 >> 11u));
  let x_2287 : u32 = (x_2282 ^ ((x_2282 << 7u) & 2636928640u));
  let x_2292 : u32 = (x_2287 ^ ((x_2287 << 15u) & 4022730752u));
  let x_2296 : u32 = (x_2292 ^ (x_2292 >> 18u));
  x_12376 = x_2296;
  x_12375 = 0u;
  loop {
    if ((x_12375 >= 2u)) {
      break;
    }
    let x_2308 : u32 = (x_12376 + (x_12376 << 10u));
    let x_2312 : u32 = (x_2308 ^ (x_2308 >> 6u));
    let x_2316 : u32 = (x_2312 + (x_2312 << 3u));
    let x_2320 : u32 = (x_2316 ^ (x_2316 >> 11u));
    x_1841[x_12375] = (bitcast<f32>(((x_12376 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_12376 = (x_2320 + (x_2320 << 15u));
      x_12375 = (x_12375 + 1u);
    }
  }
  let x_2340 : vec3<u32> = bitcast<vec3<u32>>((x_2108 + vec3<i32>(0i, 1i, 0i)));
  let x_2342 : u32 = x_2340.z;
  let x_2346 : u32 = (x_2342 + (x_2342 << 10u));
  let x_2350 : u32 = (x_2346 ^ (x_2346 >> 6u));
  let x_2354 : u32 = (x_2350 + (x_2350 << 3u));
  let x_2358 : u32 = (x_2354 ^ (x_2354 >> 11u));
  let x_2368 : u32 = ((((x_2340.y * 1664525u) + (x_2358 + (x_2358 << 15u))) + 1013904223u) * 1664525u);
  let x_2372 : u32 = (x_2368 ^ (x_2368 >> 11u));
  let x_2377 : u32 = (x_2372 ^ ((x_2372 << 7u) & 2636928640u));
  let x_2382 : u32 = (x_2377 ^ ((x_2377 << 15u) & 4022730752u));
  let x_2392 : u32 = ((((x_2340.x * 1664525u) + (x_2382 ^ (x_2382 >> 18u))) + 1013904223u) * 1664525u);
  let x_2396 : u32 = (x_2392 ^ (x_2392 >> 11u));
  let x_2401 : u32 = (x_2396 ^ ((x_2396 << 7u) & 2636928640u));
  let x_2406 : u32 = (x_2401 ^ ((x_2401 << 15u) & 4022730752u));
  let x_2410 : u32 = (x_2406 ^ (x_2406 >> 18u));
  x_12379 = x_2410;
  x_12378 = 0u;
  loop {
    if ((x_12378 >= 2u)) {
      break;
    }
    let x_2422 : u32 = (x_12379 + (x_12379 << 10u));
    let x_2426 : u32 = (x_2422 ^ (x_2422 >> 6u));
    let x_2430 : u32 = (x_2426 + (x_2426 << 3u));
    let x_2434 : u32 = (x_2430 ^ (x_2430 >> 11u));
    x_1865[x_12378] = (bitcast<f32>(((x_12379 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_12379 = (x_2434 + (x_2434 << 15u));
      x_12378 = (x_12378 + 1u);
    }
  }
  let x_2454 : vec3<u32> = bitcast<vec3<u32>>((x_2108 + vec3<i32>(1i, 1i, 0i)));
  let x_2456 : u32 = x_2454.z;
  let x_2460 : u32 = (x_2456 + (x_2456 << 10u));
  let x_2464 : u32 = (x_2460 ^ (x_2460 >> 6u));
  let x_2468 : u32 = (x_2464 + (x_2464 << 3u));
  let x_2472 : u32 = (x_2468 ^ (x_2468 >> 11u));
  let x_2482 : u32 = ((((x_2454.y * 1664525u) + (x_2472 + (x_2472 << 15u))) + 1013904223u) * 1664525u);
  let x_2486 : u32 = (x_2482 ^ (x_2482 >> 11u));
  let x_2491 : u32 = (x_2486 ^ ((x_2486 << 7u) & 2636928640u));
  let x_2496 : u32 = (x_2491 ^ ((x_2491 << 15u) & 4022730752u));
  let x_2506 : u32 = ((((x_2454.x * 1664525u) + (x_2496 ^ (x_2496 >> 18u))) + 1013904223u) * 1664525u);
  let x_2510 : u32 = (x_2506 ^ (x_2506 >> 11u));
  let x_2515 : u32 = (x_2510 ^ ((x_2510 << 7u) & 2636928640u));
  let x_2520 : u32 = (x_2515 ^ ((x_2515 << 15u) & 4022730752u));
  let x_2524 : u32 = (x_2520 ^ (x_2520 >> 18u));
  x_12382 = x_2524;
  x_12381 = 0u;
  loop {
    if ((x_12381 >= 2u)) {
      break;
    }
    let x_2536 : u32 = (x_12382 + (x_12382 << 10u));
    let x_2540 : u32 = (x_2536 ^ (x_2536 >> 6u));
    let x_2544 : u32 = (x_2540 + (x_2540 << 3u));
    let x_2548 : u32 = (x_2544 ^ (x_2544 >> 11u));
    x_1889[x_12381] = (bitcast<f32>(((x_12382 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_12382 = (x_2548 + (x_2548 << 15u));
      x_12381 = (x_12381 + 1u);
    }
  }
  let x_2568 : vec3<u32> = bitcast<vec3<u32>>((x_2108 + vec3<i32>(0i, 0i, 1i)));
  let x_2570 : u32 = x_2568.z;
  let x_2574 : u32 = (x_2570 + (x_2570 << 10u));
  let x_2578 : u32 = (x_2574 ^ (x_2574 >> 6u));
  let x_2582 : u32 = (x_2578 + (x_2578 << 3u));
  let x_2586 : u32 = (x_2582 ^ (x_2582 >> 11u));
  let x_2596 : u32 = ((((x_2568.y * 1664525u) + (x_2586 + (x_2586 << 15u))) + 1013904223u) * 1664525u);
  let x_2600 : u32 = (x_2596 ^ (x_2596 >> 11u));
  let x_2605 : u32 = (x_2600 ^ ((x_2600 << 7u) & 2636928640u));
  let x_2610 : u32 = (x_2605 ^ ((x_2605 << 15u) & 4022730752u));
  let x_2620 : u32 = ((((x_2568.x * 1664525u) + (x_2610 ^ (x_2610 >> 18u))) + 1013904223u) * 1664525u);
  let x_2624 : u32 = (x_2620 ^ (x_2620 >> 11u));
  let x_2629 : u32 = (x_2624 ^ ((x_2624 << 7u) & 2636928640u));
  let x_2634 : u32 = (x_2629 ^ ((x_2629 << 15u) & 4022730752u));
  let x_2638 : u32 = (x_2634 ^ (x_2634 >> 18u));
  x_12385 = x_2638;
  x_12384 = 0u;
  loop {
    if ((x_12384 >= 2u)) {
      break;
    }
    let x_2650 : u32 = (x_12385 + (x_12385 << 10u));
    let x_2654 : u32 = (x_2650 ^ (x_2650 >> 6u));
    let x_2658 : u32 = (x_2654 + (x_2654 << 3u));
    let x_2662 : u32 = (x_2658 ^ (x_2658 >> 11u));
    x_1913[x_12384] = (bitcast<f32>(((x_12385 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_12385 = (x_2662 + (x_2662 << 15u));
      x_12384 = (x_12384 + 1u);
    }
  }
  let x_2682 : vec3<u32> = bitcast<vec3<u32>>((x_2108 + vec3<i32>(1i, 0i, 1i)));
  let x_2684 : u32 = x_2682.z;
  let x_2688 : u32 = (x_2684 + (x_2684 << 10u));
  let x_2692 : u32 = (x_2688 ^ (x_2688 >> 6u));
  let x_2696 : u32 = (x_2692 + (x_2692 << 3u));
  let x_2700 : u32 = (x_2696 ^ (x_2696 >> 11u));
  let x_2710 : u32 = ((((x_2682.y * 1664525u) + (x_2700 + (x_2700 << 15u))) + 1013904223u) * 1664525u);
  let x_2714 : u32 = (x_2710 ^ (x_2710 >> 11u));
  let x_2719 : u32 = (x_2714 ^ ((x_2714 << 7u) & 2636928640u));
  let x_2724 : u32 = (x_2719 ^ ((x_2719 << 15u) & 4022730752u));
  let x_2734 : u32 = ((((x_2682.x * 1664525u) + (x_2724 ^ (x_2724 >> 18u))) + 1013904223u) * 1664525u);
  let x_2738 : u32 = (x_2734 ^ (x_2734 >> 11u));
  let x_2743 : u32 = (x_2738 ^ ((x_2738 << 7u) & 2636928640u));
  let x_2748 : u32 = (x_2743 ^ ((x_2743 << 15u) & 4022730752u));
  let x_2752 : u32 = (x_2748 ^ (x_2748 >> 18u));
  x_12388 = x_2752;
  x_12387 = 0u;
  loop {
    if ((x_12387 >= 2u)) {
      break;
    }
    let x_2764 : u32 = (x_12388 + (x_12388 << 10u));
    let x_2768 : u32 = (x_2764 ^ (x_2764 >> 6u));
    let x_2772 : u32 = (x_2768 + (x_2768 << 3u));
    let x_2776 : u32 = (x_2772 ^ (x_2772 >> 11u));
    x_1937[x_12387] = (bitcast<f32>(((x_12388 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_12388 = (x_2776 + (x_2776 << 15u));
      x_12387 = (x_12387 + 1u);
    }
  }
  let x_2796 : vec3<u32> = bitcast<vec3<u32>>((x_2108 + vec3<i32>(0i, 1i, 1i)));
  let x_2798 : u32 = x_2796.z;
  let x_2802 : u32 = (x_2798 + (x_2798 << 10u));
  let x_2806 : u32 = (x_2802 ^ (x_2802 >> 6u));
  let x_2810 : u32 = (x_2806 + (x_2806 << 3u));
  let x_2814 : u32 = (x_2810 ^ (x_2810 >> 11u));
  let x_2824 : u32 = ((((x_2796.y * 1664525u) + (x_2814 + (x_2814 << 15u))) + 1013904223u) * 1664525u);
  let x_2828 : u32 = (x_2824 ^ (x_2824 >> 11u));
  let x_2833 : u32 = (x_2828 ^ ((x_2828 << 7u) & 2636928640u));
  let x_2838 : u32 = (x_2833 ^ ((x_2833 << 15u) & 4022730752u));
  let x_2848 : u32 = ((((x_2796.x * 1664525u) + (x_2838 ^ (x_2838 >> 18u))) + 1013904223u) * 1664525u);
  let x_2852 : u32 = (x_2848 ^ (x_2848 >> 11u));
  let x_2857 : u32 = (x_2852 ^ ((x_2852 << 7u) & 2636928640u));
  let x_2862 : u32 = (x_2857 ^ ((x_2857 << 15u) & 4022730752u));
  let x_2866 : u32 = (x_2862 ^ (x_2862 >> 18u));
  x_12391 = x_2866;
  x_12390 = 0u;
  loop {
    if ((x_12390 >= 2u)) {
      break;
    }
    let x_2878 : u32 = (x_12391 + (x_12391 << 10u));
    let x_2882 : u32 = (x_2878 ^ (x_2878 >> 6u));
    let x_2886 : u32 = (x_2882 + (x_2882 << 3u));
    let x_2890 : u32 = (x_2886 ^ (x_2886 >> 11u));
    x_1961[x_12390] = (bitcast<f32>(((x_12391 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_12391 = (x_2890 + (x_2890 << 15u));
      x_12390 = (x_12390 + 1u);
    }
  }
  let x_2910 : vec3<u32> = bitcast<vec3<u32>>((x_2108 + vec3<i32>(1i, 1i, 1i)));
  let x_2912 : u32 = x_2910.z;
  let x_2916 : u32 = (x_2912 + (x_2912 << 10u));
  let x_2920 : u32 = (x_2916 ^ (x_2916 >> 6u));
  let x_2924 : u32 = (x_2920 + (x_2920 << 3u));
  let x_2928 : u32 = (x_2924 ^ (x_2924 >> 11u));
  let x_2938 : u32 = ((((x_2910.y * 1664525u) + (x_2928 + (x_2928 << 15u))) + 1013904223u) * 1664525u);
  let x_2942 : u32 = (x_2938 ^ (x_2938 >> 11u));
  let x_2947 : u32 = (x_2942 ^ ((x_2942 << 7u) & 2636928640u));
  let x_2952 : u32 = (x_2947 ^ ((x_2947 << 15u) & 4022730752u));
  let x_2962 : u32 = ((((x_2910.x * 1664525u) + (x_2952 ^ (x_2952 >> 18u))) + 1013904223u) * 1664525u);
  let x_2966 : u32 = (x_2962 ^ (x_2962 >> 11u));
  let x_2971 : u32 = (x_2966 ^ ((x_2966 << 7u) & 2636928640u));
  let x_2976 : u32 = (x_2971 ^ ((x_2971 << 15u) & 4022730752u));
  let x_2980 : u32 = (x_2976 ^ (x_2976 >> 18u));
  x_12394 = x_2980;
  x_12393 = 0u;
  loop {
    if ((x_12393 >= 2u)) {
      break;
    }
    let x_2992 : u32 = (x_12394 + (x_12394 << 10u));
    let x_2996 : u32 = (x_2992 ^ (x_2992 >> 6u));
    let x_3000 : u32 = (x_2996 + (x_2996 << 3u));
    let x_3004 : u32 = (x_3000 ^ (x_3000 >> 11u));
    x_1985[x_12393] = (bitcast<f32>(((x_12394 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_12394 = (x_3004 + (x_3004 << 15u));
      x_12393 = (x_12393 + 1u);
    }
  }
  let x_3028 : vec3<f32> = ((x_2110 * x_2110) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_2110)));
  let x_3030 : f32 = x_3028.x;
  let x_3032 : f32 = (1.0f - x_3030);
  let x_3034 : f32 = x_3028.y;
  let x_3036 : f32 = (1.0f - x_3034);
  let x_3038 : f32 = x_3028.z;
  let x_3040 : f32 = (1.0f - x_3038);
  let x_3041 : vec2<f32> = x_1817;
  let x_3048 : vec2<f32> = x_1841;
  let x_3056 : vec2<f32> = x_1865;
  let x_3064 : vec2<f32> = x_1889;
  let x_3072 : vec2<f32> = x_1913;
  let x_3080 : vec2<f32> = x_1937;
  let x_3088 : vec2<f32> = x_1961;
  let x_3096 : vec2<f32> = x_1985;
  let x_3106 : vec2<f32> = clamp(((((((((((((x_3041 * x_3032) * x_3036) * x_3040) + (((x_3048 * x_3030) * x_3036) * x_3040)) + (((x_3056 * x_3032) * x_3034) * x_3040)) + (((x_3064 * x_3030) * x_3034) * x_3040)) + (((x_3072 * x_3032) * x_3036) * x_3038)) + (((x_3080 * x_3030) * x_3036) * x_3038)) + (((x_3088 * x_3032) * x_3034) * x_3038)) + (((x_3096 * x_3030) * x_3034) * x_3038)) - x_1672) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_1672);
  let x_3114 : vec3<f32> = (x_2103 + (vec3<f32>(x_3106.x, 0.0f, x_3106.y) * 0.05999999865889549255f));
  let x_3116 : mat4x4<f32> = x_1696.renderer_MVPMat;
  gl_Position = (x_3116 * vec4<f32>(x_3114.x, x_3114.y, x_3114.z, 1.0f));
  let x_3125 : vec3<f32> = Vertex_Normal;
  v1 = (vec4<f32>(x_3125.x, x_3125.y, x_3125.z, 0.0f) * x_2096);
  let x_3133 : vec2<f32> = Vertex_UV;
  v3 = x_3133;
  let x_10553 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_10560 : i32 = x_10553.x;
  let x_10569 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_10560), (x_3165 / x_10560)), 0i);
  let x_10704 : i32 = ((bitcast<i32>(x_10569[x_3178]) * 16i) + 12i);
  let x_11054 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_11059 : i32 = (x_10704 / 4i);
  let x_11061 : i32 = x_11054.x;
  let x_11070 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_11059 % x_11061), (x_11059 / x_11061)), 0i);
  v4 = x_11070[(x_10704 % 4i)];
  let x_11169 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_19_0, 0i));
  let x_11176 : i32 = x_11169.x;
  let x_11185 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_19_0, vec2<i32>((x_3165 % x_11176), (x_3165 / x_11176)), 0i);
  let x_11325 : i32 = ((bitcast<i32>(x_11185[x_3178]) * 16i) + 13i);
  let x_11697 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_11702 : i32 = (x_11325 / 4i);
  let x_11704 : i32 = x_11697.x;
  let x_11713 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_11702 % x_11704), (x_11702 / x_11704)), 0i);
  v5 = x_11713[(x_11325 % 4i)];
  let x_1752 : f32 = gl_Position.z;
  let x_1754 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_1752 + x_1754));
  return;
}

struct main_out {
  @builtin(position)
  gl_Position : vec4<f32>,
  @location(0)
  v1_1 : vec3<f32>,
  @location(1)
  v3_1 : vec2<f32>,
  @location(2) @interpolate(flat)
  v4_1 : u32,
  @location(3) @interpolate(flat)
  v5_1 : u32,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @location(0) Vertex_Position_param : vec3<f32>, @location(2) Vertex_Normal_param : vec3<f32>, @location(3) Vertex_UV_param : vec2<f32>) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  Vertex_Position = Vertex_Position_param;
  Vertex_Normal = Vertex_Normal_param;
  Vertex_UV = Vertex_UV_param;
  main_1();
  return main_out(gl_Position, v1, v3, v4, v5);
}
