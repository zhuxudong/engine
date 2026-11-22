diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(6) @group(3) var gs_wgpu_tex_plaster_vertices : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_plaster_vertices : sampler;

@binding(2) @group(3) var gs_wgpu_tex_storage_8_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_8_0 : sampler;

@binding(4) @group(3) var gs_wgpu_tex_storage_0_1 : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_storage_0_1 : sampler;

var<private> gl_InstanceIndex : i32;

var<private> gl_VertexIndex : i32;

var<private> v0 : u32;

var<private> v1 : vec3<f32>;

var<private> v2 : vec3<f32>;

var<private> v3 : vec2<f32>;

var<private> v4 : vec3<f32>;

var<private> v5 : vec3<f32>;

var<private> v6 : f32;

var<private> v7 : f32;

var<private> v8 : f32;

@binding(0) @group(2) var<uniform> x_1671 : gs_Auto_0;

var<private> v9 : vec3<f32>;

var<private> v10 : vec3<f32>;

var<private> v11 : vec3<f32>;

var<private> gl_Position : vec4<f32>;

const x_278 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_1617 = vec2<f32>(0.5f, 0.5f);

const x_1645 = vec3<f32>(0.0f, 1.0f, 0.0f);

fn main_1() {
  var x_1823 : vec2<f32>;
  var x_1847 : vec2<f32>;
  var x_1871 : vec2<f32>;
  var x_1895 : vec2<f32>;
  var x_1919 : vec2<f32>;
  var x_1943 : vec2<f32>;
  var x_1967 : vec2<f32>;
  var x_1991 : vec2<f32>;
  var x_3161 : vec3<f32>;
  var x_3168 : vec3<f32>;
  var x_3175 : vec3<f32>;
  var x_5177 : vec3<f32>;
  var x_5176 : vec3<f32>;
  var x_5175 : vec3<f32>;
  loop {
    var x_5113 : u32;
    var x_5112 : u32;
    var x_5116 : u32;
    var x_5115 : u32;
    var x_5119 : u32;
    var x_5118 : u32;
    var x_5122 : u32;
    var x_5121 : u32;
    var x_5125 : u32;
    var x_5124 : u32;
    var x_5128 : u32;
    var x_5127 : u32;
    var x_5131 : u32;
    var x_5130 : u32;
    var x_5134 : u32;
    var x_5133 : u32;
    let x_2014 : i32 = gl_InstanceIndex;
    let x_2016 : i32 = gl_VertexIndex;
    let x_2018 : u32 = bitcast<u32>(x_2016);
    let x_2020 : u32 = (x_2018 & 65535u);
    let x_3207 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_0, 0i));
    let x_3212 : i32 = (x_2014 / 4i);
    let x_3214 : i32 = x_3207.x;
    let x_3223 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_0, vec2<i32>((x_3212 % x_3214), (x_3212 / x_3214)), 0i);
    let x_3225 : i32 = (x_2014 % 4i);
    let x_3285 : i32 = ((bitcast<i32>(x_3223[x_3225]) * 12i) + 7i);
    let x_3508 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_3513 : i32 = (x_3285 / 4i);
    let x_3515 : i32 = x_3508.x;
    let x_3524 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_3513 % x_3515), (x_3513 / x_3515)), 0i);
    if ((x_2020 > x_3524[(x_3285 % 4i)])) {
      gl_Position = vec4<f32>(seedBitsToFloat(0x7fbfffffu), seedBitsToFloat(0x7fbfffffu), seedBitsToFloat(0x7fbfffffu), seedBitsToFloat(0x7fbfffffu));
      v0 = 0u;
      v1 = x_278;
      v2 = x_278;
      v3 = vec2<f32>(0.0f, 0.0f);
      v4 = x_278;
      v5 = x_278;
      v6 = 0.0f;
      v7 = 0.0f;
      v8 = 0.0f;
      x_5177 = x_278;
      x_5176 = x_278;
      x_5175 = x_278;
      break;
    }
    let x_3650 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_0, 0i));
    let x_3657 : i32 = x_3650.x;
    let x_3666 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_0, vec2<i32>((x_3212 % x_3657), (x_3212 / x_3657)), 0i);
    let x_3743 : i32 = ((bitcast<i32>(x_3666[x_3225]) * 12i) + 10i);
    let x_4031 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_4036 : i32 = (x_3743 / 4i);
    let x_4038 : i32 = x_4031.x;
    let x_4047 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4036 % x_4038), (x_4036 / x_4038)), 0i);
    let x_4092 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_0, 0i));
    let x_4099 : i32 = x_4092.x;
    let x_4108 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_0, vec2<i32>((x_3212 % x_4099), (x_3212 / x_4099)), 0i);
    let x_4174 : i32 = ((bitcast<i32>(x_4108[x_3225]) * 12i) + 8i);
    let x_4419 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_4424 : i32 = (x_4174 / 4i);
    let x_4426 : i32 = x_4419.x;
    let x_4435 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4424 % x_4426), (x_4424 / x_4426)), 0i);
    let x_2055 : u32 = (x_4435[(x_4174 % 4i)] + bitcast<u32>(((48i * (bitcast<i32>(x_2020) + (bitcast<i32>((x_2018 >> 16u)) * bitcast<i32>(x_4047[(x_3743 % 4i)])))) / 16i)));
    let x_4527 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_plaster_vertices, 0i));
    let x_4532 : i32 = bitcast<i32>(x_2055);
    let x_4534 : i32 = x_4527.x;
    let x_4543 : vec4<u32> = textureLoad(gs_wgpu_tex_plaster_vertices, vec2<i32>((x_4532 % x_4534), (x_4532 / x_4534)), 0i);
    let x_4551 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_plaster_vertices, 0i));
    let x_4556 : i32 = bitcast<i32>((x_2055 + 1u));
    let x_4558 : i32 = x_4551.x;
    let x_4567 : vec4<u32> = textureLoad(gs_wgpu_tex_plaster_vertices, vec2<i32>((x_4556 % x_4558), (x_4556 / x_4558)), 0i);
    let x_4575 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_plaster_vertices, 0i));
    let x_4580 : i32 = bitcast<i32>((x_2055 + 2u));
    let x_4582 : i32 = x_4575.x;
    let x_4591 : vec4<u32> = textureLoad(gs_wgpu_tex_plaster_vertices, vec2<i32>((x_4580 % x_4582), (x_4580 / x_4582)), 0i);
    let x_2066 : vec3<f32> = bitcast<vec3<f32>>(vec3<u32>(x_4567.x, x_4567.y, x_4567.z));
    let x_2069 : vec3<f32> = bitcast<vec3<f32>>(vec3<u32>(x_4543.x, x_4543.y, x_4543.z));
    let x_2073 : vec4<f32> = vec4<f32>(x_2069.x, x_2069.y, x_2069.z, 1.0f);
    let x_2076 : vec3<f32> = vec3<f32>(x_2073.x, x_2073.y, x_2073.z);
    let x_2078 : vec3<f32> = (x_2076 * 0.40000000596046447754f);
    let x_2081 : vec3<i32> = vec3<i32>(floor(x_2078));
    let x_2083 : vec3<f32> = fract(x_2078);
    let x_2085 : vec3<u32> = bitcast<vec3<u32>>(x_2081);
    let x_2087 : u32 = x_2085.z;
    let x_2091 : u32 = (x_2087 + (x_2087 << 10u));
    let x_2095 : u32 = (x_2091 ^ (x_2091 >> 6u));
    let x_2099 : u32 = (x_2095 + (x_2095 << 3u));
    let x_2103 : u32 = (x_2099 ^ (x_2099 >> 11u));
    let x_2113 : u32 = ((((x_2085.y * 1664525u) + (x_2103 + (x_2103 << 15u))) + 1013904223u) * 1664525u);
    let x_2117 : u32 = (x_2113 ^ (x_2113 >> 11u));
    let x_2122 : u32 = (x_2117 ^ ((x_2117 << 7u) & 2636928640u));
    let x_2127 : u32 = (x_2122 ^ ((x_2122 << 15u) & 4022730752u));
    let x_2137 : u32 = ((((x_2085.x * 1664525u) + (x_2127 ^ (x_2127 >> 18u))) + 1013904223u) * 1664525u);
    let x_2141 : u32 = (x_2137 ^ (x_2137 >> 11u));
    let x_2146 : u32 = (x_2141 ^ ((x_2141 << 7u) & 2636928640u));
    let x_2151 : u32 = (x_2146 ^ ((x_2146 << 15u) & 4022730752u));
    let x_2155 : u32 = (x_2151 ^ (x_2151 >> 18u));
    x_5113 = x_2155;
    x_5112 = 0u;
    loop {
      if ((x_5112 >= 2u)) {
        break;
      }
      let x_2167 : u32 = (x_5113 + (x_5113 << 10u));
      let x_2171 : u32 = (x_2167 ^ (x_2167 >> 6u));
      let x_2175 : u32 = (x_2171 + (x_2171 << 3u));
      let x_2179 : u32 = (x_2175 ^ (x_2175 >> 11u));
      x_1823[x_5112] = (bitcast<f32>(((x_5113 & 8388607u) | 1065353216u)) - 1.0f);

      continuing {
        x_5113 = (x_2179 + (x_2179 << 15u));
        x_5112 = (x_5112 + 1u);
      }
    }
    let x_2199 : vec3<u32> = bitcast<vec3<u32>>((x_2081 + vec3<i32>(1i, 0i, 0i)));
    let x_2201 : u32 = x_2199.z;
    let x_2205 : u32 = (x_2201 + (x_2201 << 10u));
    let x_2209 : u32 = (x_2205 ^ (x_2205 >> 6u));
    let x_2213 : u32 = (x_2209 + (x_2209 << 3u));
    let x_2217 : u32 = (x_2213 ^ (x_2213 >> 11u));
    let x_2227 : u32 = ((((x_2199.y * 1664525u) + (x_2217 + (x_2217 << 15u))) + 1013904223u) * 1664525u);
    let x_2231 : u32 = (x_2227 ^ (x_2227 >> 11u));
    let x_2236 : u32 = (x_2231 ^ ((x_2231 << 7u) & 2636928640u));
    let x_2241 : u32 = (x_2236 ^ ((x_2236 << 15u) & 4022730752u));
    let x_2251 : u32 = ((((x_2199.x * 1664525u) + (x_2241 ^ (x_2241 >> 18u))) + 1013904223u) * 1664525u);
    let x_2255 : u32 = (x_2251 ^ (x_2251 >> 11u));
    let x_2260 : u32 = (x_2255 ^ ((x_2255 << 7u) & 2636928640u));
    let x_2265 : u32 = (x_2260 ^ ((x_2260 << 15u) & 4022730752u));
    let x_2269 : u32 = (x_2265 ^ (x_2265 >> 18u));
    x_5116 = x_2269;
    x_5115 = 0u;
    loop {
      if ((x_5115 >= 2u)) {
        break;
      }
      let x_2281 : u32 = (x_5116 + (x_5116 << 10u));
      let x_2285 : u32 = (x_2281 ^ (x_2281 >> 6u));
      let x_2289 : u32 = (x_2285 + (x_2285 << 3u));
      let x_2293 : u32 = (x_2289 ^ (x_2289 >> 11u));
      x_1847[x_5115] = (bitcast<f32>(((x_5116 & 8388607u) | 1065353216u)) - 1.0f);

      continuing {
        x_5116 = (x_2293 + (x_2293 << 15u));
        x_5115 = (x_5115 + 1u);
      }
    }
    let x_2313 : vec3<u32> = bitcast<vec3<u32>>((x_2081 + vec3<i32>(0i, 1i, 0i)));
    let x_2315 : u32 = x_2313.z;
    let x_2319 : u32 = (x_2315 + (x_2315 << 10u));
    let x_2323 : u32 = (x_2319 ^ (x_2319 >> 6u));
    let x_2327 : u32 = (x_2323 + (x_2323 << 3u));
    let x_2331 : u32 = (x_2327 ^ (x_2327 >> 11u));
    let x_2341 : u32 = ((((x_2313.y * 1664525u) + (x_2331 + (x_2331 << 15u))) + 1013904223u) * 1664525u);
    let x_2345 : u32 = (x_2341 ^ (x_2341 >> 11u));
    let x_2350 : u32 = (x_2345 ^ ((x_2345 << 7u) & 2636928640u));
    let x_2355 : u32 = (x_2350 ^ ((x_2350 << 15u) & 4022730752u));
    let x_2365 : u32 = ((((x_2313.x * 1664525u) + (x_2355 ^ (x_2355 >> 18u))) + 1013904223u) * 1664525u);
    let x_2369 : u32 = (x_2365 ^ (x_2365 >> 11u));
    let x_2374 : u32 = (x_2369 ^ ((x_2369 << 7u) & 2636928640u));
    let x_2379 : u32 = (x_2374 ^ ((x_2374 << 15u) & 4022730752u));
    let x_2383 : u32 = (x_2379 ^ (x_2379 >> 18u));
    x_5119 = x_2383;
    x_5118 = 0u;
    loop {
      if ((x_5118 >= 2u)) {
        break;
      }
      let x_2395 : u32 = (x_5119 + (x_5119 << 10u));
      let x_2399 : u32 = (x_2395 ^ (x_2395 >> 6u));
      let x_2403 : u32 = (x_2399 + (x_2399 << 3u));
      let x_2407 : u32 = (x_2403 ^ (x_2403 >> 11u));
      x_1871[x_5118] = (bitcast<f32>(((x_5119 & 8388607u) | 1065353216u)) - 1.0f);

      continuing {
        x_5119 = (x_2407 + (x_2407 << 15u));
        x_5118 = (x_5118 + 1u);
      }
    }
    let x_2427 : vec3<u32> = bitcast<vec3<u32>>((x_2081 + vec3<i32>(1i, 1i, 0i)));
    let x_2429 : u32 = x_2427.z;
    let x_2433 : u32 = (x_2429 + (x_2429 << 10u));
    let x_2437 : u32 = (x_2433 ^ (x_2433 >> 6u));
    let x_2441 : u32 = (x_2437 + (x_2437 << 3u));
    let x_2445 : u32 = (x_2441 ^ (x_2441 >> 11u));
    let x_2455 : u32 = ((((x_2427.y * 1664525u) + (x_2445 + (x_2445 << 15u))) + 1013904223u) * 1664525u);
    let x_2459 : u32 = (x_2455 ^ (x_2455 >> 11u));
    let x_2464 : u32 = (x_2459 ^ ((x_2459 << 7u) & 2636928640u));
    let x_2469 : u32 = (x_2464 ^ ((x_2464 << 15u) & 4022730752u));
    let x_2479 : u32 = ((((x_2427.x * 1664525u) + (x_2469 ^ (x_2469 >> 18u))) + 1013904223u) * 1664525u);
    let x_2483 : u32 = (x_2479 ^ (x_2479 >> 11u));
    let x_2488 : u32 = (x_2483 ^ ((x_2483 << 7u) & 2636928640u));
    let x_2493 : u32 = (x_2488 ^ ((x_2488 << 15u) & 4022730752u));
    let x_2497 : u32 = (x_2493 ^ (x_2493 >> 18u));
    x_5122 = x_2497;
    x_5121 = 0u;
    loop {
      if ((x_5121 >= 2u)) {
        break;
      }
      let x_2509 : u32 = (x_5122 + (x_5122 << 10u));
      let x_2513 : u32 = (x_2509 ^ (x_2509 >> 6u));
      let x_2517 : u32 = (x_2513 + (x_2513 << 3u));
      let x_2521 : u32 = (x_2517 ^ (x_2517 >> 11u));
      x_1895[x_5121] = (bitcast<f32>(((x_5122 & 8388607u) | 1065353216u)) - 1.0f);

      continuing {
        x_5122 = (x_2521 + (x_2521 << 15u));
        x_5121 = (x_5121 + 1u);
      }
    }
    let x_2541 : vec3<u32> = bitcast<vec3<u32>>((x_2081 + vec3<i32>(0i, 0i, 1i)));
    let x_2543 : u32 = x_2541.z;
    let x_2547 : u32 = (x_2543 + (x_2543 << 10u));
    let x_2551 : u32 = (x_2547 ^ (x_2547 >> 6u));
    let x_2555 : u32 = (x_2551 + (x_2551 << 3u));
    let x_2559 : u32 = (x_2555 ^ (x_2555 >> 11u));
    let x_2569 : u32 = ((((x_2541.y * 1664525u) + (x_2559 + (x_2559 << 15u))) + 1013904223u) * 1664525u);
    let x_2573 : u32 = (x_2569 ^ (x_2569 >> 11u));
    let x_2578 : u32 = (x_2573 ^ ((x_2573 << 7u) & 2636928640u));
    let x_2583 : u32 = (x_2578 ^ ((x_2578 << 15u) & 4022730752u));
    let x_2593 : u32 = ((((x_2541.x * 1664525u) + (x_2583 ^ (x_2583 >> 18u))) + 1013904223u) * 1664525u);
    let x_2597 : u32 = (x_2593 ^ (x_2593 >> 11u));
    let x_2602 : u32 = (x_2597 ^ ((x_2597 << 7u) & 2636928640u));
    let x_2607 : u32 = (x_2602 ^ ((x_2602 << 15u) & 4022730752u));
    let x_2611 : u32 = (x_2607 ^ (x_2607 >> 18u));
    x_5125 = x_2611;
    x_5124 = 0u;
    loop {
      if ((x_5124 >= 2u)) {
        break;
      }
      let x_2623 : u32 = (x_5125 + (x_5125 << 10u));
      let x_2627 : u32 = (x_2623 ^ (x_2623 >> 6u));
      let x_2631 : u32 = (x_2627 + (x_2627 << 3u));
      let x_2635 : u32 = (x_2631 ^ (x_2631 >> 11u));
      x_1919[x_5124] = (bitcast<f32>(((x_5125 & 8388607u) | 1065353216u)) - 1.0f);

      continuing {
        x_5125 = (x_2635 + (x_2635 << 15u));
        x_5124 = (x_5124 + 1u);
      }
    }
    let x_2655 : vec3<u32> = bitcast<vec3<u32>>((x_2081 + vec3<i32>(1i, 0i, 1i)));
    let x_2657 : u32 = x_2655.z;
    let x_2661 : u32 = (x_2657 + (x_2657 << 10u));
    let x_2665 : u32 = (x_2661 ^ (x_2661 >> 6u));
    let x_2669 : u32 = (x_2665 + (x_2665 << 3u));
    let x_2673 : u32 = (x_2669 ^ (x_2669 >> 11u));
    let x_2683 : u32 = ((((x_2655.y * 1664525u) + (x_2673 + (x_2673 << 15u))) + 1013904223u) * 1664525u);
    let x_2687 : u32 = (x_2683 ^ (x_2683 >> 11u));
    let x_2692 : u32 = (x_2687 ^ ((x_2687 << 7u) & 2636928640u));
    let x_2697 : u32 = (x_2692 ^ ((x_2692 << 15u) & 4022730752u));
    let x_2707 : u32 = ((((x_2655.x * 1664525u) + (x_2697 ^ (x_2697 >> 18u))) + 1013904223u) * 1664525u);
    let x_2711 : u32 = (x_2707 ^ (x_2707 >> 11u));
    let x_2716 : u32 = (x_2711 ^ ((x_2711 << 7u) & 2636928640u));
    let x_2721 : u32 = (x_2716 ^ ((x_2716 << 15u) & 4022730752u));
    let x_2725 : u32 = (x_2721 ^ (x_2721 >> 18u));
    x_5128 = x_2725;
    x_5127 = 0u;
    loop {
      if ((x_5127 >= 2u)) {
        break;
      }
      let x_2737 : u32 = (x_5128 + (x_5128 << 10u));
      let x_2741 : u32 = (x_2737 ^ (x_2737 >> 6u));
      let x_2745 : u32 = (x_2741 + (x_2741 << 3u));
      let x_2749 : u32 = (x_2745 ^ (x_2745 >> 11u));
      x_1943[x_5127] = (bitcast<f32>(((x_5128 & 8388607u) | 1065353216u)) - 1.0f);

      continuing {
        x_5128 = (x_2749 + (x_2749 << 15u));
        x_5127 = (x_5127 + 1u);
      }
    }
    let x_2769 : vec3<u32> = bitcast<vec3<u32>>((x_2081 + vec3<i32>(0i, 1i, 1i)));
    let x_2771 : u32 = x_2769.z;
    let x_2775 : u32 = (x_2771 + (x_2771 << 10u));
    let x_2779 : u32 = (x_2775 ^ (x_2775 >> 6u));
    let x_2783 : u32 = (x_2779 + (x_2779 << 3u));
    let x_2787 : u32 = (x_2783 ^ (x_2783 >> 11u));
    let x_2797 : u32 = ((((x_2769.y * 1664525u) + (x_2787 + (x_2787 << 15u))) + 1013904223u) * 1664525u);
    let x_2801 : u32 = (x_2797 ^ (x_2797 >> 11u));
    let x_2806 : u32 = (x_2801 ^ ((x_2801 << 7u) & 2636928640u));
    let x_2811 : u32 = (x_2806 ^ ((x_2806 << 15u) & 4022730752u));
    let x_2821 : u32 = ((((x_2769.x * 1664525u) + (x_2811 ^ (x_2811 >> 18u))) + 1013904223u) * 1664525u);
    let x_2825 : u32 = (x_2821 ^ (x_2821 >> 11u));
    let x_2830 : u32 = (x_2825 ^ ((x_2825 << 7u) & 2636928640u));
    let x_2835 : u32 = (x_2830 ^ ((x_2830 << 15u) & 4022730752u));
    let x_2839 : u32 = (x_2835 ^ (x_2835 >> 18u));
    x_5131 = x_2839;
    x_5130 = 0u;
    loop {
      if ((x_5130 >= 2u)) {
        break;
      }
      let x_2851 : u32 = (x_5131 + (x_5131 << 10u));
      let x_2855 : u32 = (x_2851 ^ (x_2851 >> 6u));
      let x_2859 : u32 = (x_2855 + (x_2855 << 3u));
      let x_2863 : u32 = (x_2859 ^ (x_2859 >> 11u));
      x_1967[x_5130] = (bitcast<f32>(((x_5131 & 8388607u) | 1065353216u)) - 1.0f);

      continuing {
        x_5131 = (x_2863 + (x_2863 << 15u));
        x_5130 = (x_5130 + 1u);
      }
    }
    let x_2883 : vec3<u32> = bitcast<vec3<u32>>((x_2081 + vec3<i32>(1i, 1i, 1i)));
    let x_2885 : u32 = x_2883.z;
    let x_2889 : u32 = (x_2885 + (x_2885 << 10u));
    let x_2893 : u32 = (x_2889 ^ (x_2889 >> 6u));
    let x_2897 : u32 = (x_2893 + (x_2893 << 3u));
    let x_2901 : u32 = (x_2897 ^ (x_2897 >> 11u));
    let x_2911 : u32 = ((((x_2883.y * 1664525u) + (x_2901 + (x_2901 << 15u))) + 1013904223u) * 1664525u);
    let x_2915 : u32 = (x_2911 ^ (x_2911 >> 11u));
    let x_2920 : u32 = (x_2915 ^ ((x_2915 << 7u) & 2636928640u));
    let x_2925 : u32 = (x_2920 ^ ((x_2920 << 15u) & 4022730752u));
    let x_2935 : u32 = ((((x_2883.x * 1664525u) + (x_2925 ^ (x_2925 >> 18u))) + 1013904223u) * 1664525u);
    let x_2939 : u32 = (x_2935 ^ (x_2935 >> 11u));
    let x_2944 : u32 = (x_2939 ^ ((x_2939 << 7u) & 2636928640u));
    let x_2949 : u32 = (x_2944 ^ ((x_2944 << 15u) & 4022730752u));
    let x_2953 : u32 = (x_2949 ^ (x_2949 >> 18u));
    x_5134 = x_2953;
    x_5133 = 0u;
    loop {
      if ((x_5133 >= 2u)) {
        break;
      }
      let x_2965 : u32 = (x_5134 + (x_5134 << 10u));
      let x_2969 : u32 = (x_2965 ^ (x_2965 >> 6u));
      let x_2973 : u32 = (x_2969 + (x_2969 << 3u));
      let x_2977 : u32 = (x_2973 ^ (x_2973 >> 11u));
      x_1991[x_5133] = (bitcast<f32>(((x_5134 & 8388607u) | 1065353216u)) - 1.0f);

      continuing {
        x_5134 = (x_2977 + (x_2977 << 15u));
        x_5133 = (x_5133 + 1u);
      }
    }
    let x_3001 : vec3<f32> = ((x_2083 * x_2083) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_2083)));
    let x_3003 : f32 = x_3001.x;
    let x_3005 : f32 = (1.0f - x_3003);
    let x_3007 : f32 = x_3001.y;
    let x_3009 : f32 = (1.0f - x_3007);
    let x_3011 : f32 = x_3001.z;
    let x_3013 : f32 = (1.0f - x_3011);
    let x_3014 : vec2<f32> = x_1823;
    let x_3021 : vec2<f32> = x_1847;
    let x_3029 : vec2<f32> = x_1871;
    let x_3037 : vec2<f32> = x_1895;
    let x_3045 : vec2<f32> = x_1919;
    let x_3053 : vec2<f32> = x_1943;
    let x_3061 : vec2<f32> = x_1967;
    let x_3069 : vec2<f32> = x_1991;
    let x_3079 : vec2<f32> = clamp(((((((((((((x_3014 * x_3005) * x_3009) * x_3013) + (((x_3021 * x_3003) * x_3009) * x_3013)) + (((x_3029 * x_3005) * x_3007) * x_3013)) + (((x_3037 * x_3003) * x_3007) * x_3013)) + (((x_3045 * x_3005) * x_3009) * x_3011)) + (((x_3053 * x_3003) * x_3009) * x_3011)) + (((x_3061 * x_3005) * x_3007) * x_3011)) + (((x_3069 * x_3003) * x_3007) * x_3011)) - x_1617) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_1617);
    let x_3087 : vec3<f32> = (x_2076 + (vec3<f32>(x_3079.x, 0.0f, x_3079.y) * 0.05999999865889549255f));
    var x_5229_1 : vec4<f32> = x_2073;
    x_5229_1.x = x_3087.x;
    let x_5229 : vec4<f32> = x_5229_1;
    let x_3092 : f32 = x_3087.y;
    var x_5232_1 : vec4<f32> = x_5229;
    x_5232_1.y = x_3092;
    let x_5232 : vec4<f32> = x_5232_1;
    var x_5235_1 : vec4<f32> = x_5232;
    x_5235_1.z = x_3087.z;
    let x_5235 : vec4<f32> = x_5235_1;
    let x_3098 : vec3<f32> = cross(x_2066, x_1645);
    let x_3116 : mat3x3<f32> = transpose(mat3x3<f32>(normalize(x_3098), x_1645, normalize(x_2066)));
    let x_3118 : mat4x4<f32> = x_1671.renderer_MVPMat;
    gl_Position = (x_3118 * x_5235);
    let x_4606 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_0, 0i));
    let x_4613 : i32 = x_4606.x;
    let x_4622 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_0, vec2<i32>((x_3212 % x_4613), (x_3212 / x_4613)), 0i);
    v0 = x_4622[x_3225];
    v1 = x_2066;
    v2 = vec3<f32>(x_5235.x, x_5235.y, x_5235.z);
    v3 = bitcast<vec2<f32>>(vec2<u32>(x_4591.x, x_4591.y));
    v4 = x_3098;
    v5 = x_1645;
    v6 = bitcast<f32>(x_4543.w);
    v7 = (bitcast<f32>(x_4567.w) + (1.0f - smoothstep(0.0f, 1.0f, x_3092)));
    let x_4640 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_0, 0i));
    let x_4647 : i32 = x_4640.x;
    let x_4656 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_0, vec2<i32>((x_3212 % x_4647), (x_3212 / x_4647)), 0i);
    let x_4739 : i32 = ((bitcast<i32>(x_4656[x_3225]) * 12i) + 11i);
    let x_5048 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_5053 : i32 = (x_4739 / 4i);
    let x_5055 : i32 = x_5048.x;
    let x_5064 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5053 % x_5055), (x_5053 / x_5055)), 0i);
    v8 = bitcast<f32>(x_5064[(x_4739 % 4i)]);
    let x_3150 : vec3<f32> = x_3116[0u];
    let x_3152 : vec3<f32> = x_3116[1u];
    let x_3154 : vec3<f32> = x_3116[2u];
    x_3161 = vec3<f32>(x_3150.x, x_3152.x, x_3154.x);
    x_3168 = vec3<f32>(x_3150.y, x_3152.y, x_3154.y);
    x_3175 = vec3<f32>(x_3150.z, x_3152.z, x_3154.z);
    x_5177 = x_3175;
    x_5176 = x_3168;
    x_5175 = x_3161;
    break;
  }
  v9 = x_5175;
  v10 = x_5176;
  v11 = x_5177;
  let x_1764 : f32 = gl_Position.z;
  let x_1766 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_1764 + x_1766));
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
  v3_1 : vec2<f32>,
  @location(4)
  v4_1 : vec3<f32>,
  @location(5)
  v5_1 : vec3<f32>,
  @location(6)
  v6_1 : f32,
  @location(7)
  v7_1 : f32,
  @location(8)
  v8_1 : f32,
  @location(9)
  v9_1 : vec3<f32>,
  @location(10)
  v10_1 : vec3<f32>,
  @location(11)
  v11_1 : vec3<f32>,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @builtin(vertex_index) gl_VertexIndex_param : u32) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  gl_VertexIndex = bitcast<i32>(gl_VertexIndex_param);
  main_1();
  return main_out(gl_Position, v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11);
}

fn seedBitsToFloat(bits: u32) -> f32 { return bitcast<f32>(bits); }
