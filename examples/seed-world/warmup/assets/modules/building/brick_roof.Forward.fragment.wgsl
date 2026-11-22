diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  @size(64)
  padding : u32,
  /* @offset(64) */
  renderer_DormerGrid : vec4<f32>,
}

@binding(18) @group(3) var gs_wgpu_tex_uniform_ColorLibraryData_natural : texture_2d<u32>;

@binding(19) @group(3) var gs_wgpu_samp_uniform_ColorLibraryData_natural : sampler;

@binding(8) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

var<private> v2 : vec3<f32>;

var<private> v8 : f32;

var<private> v12 : i32;

var<private> v7 : f32;

var<private> v10 : i32;

@binding(20) @group(3) var gs_wgpu_tex_roof_colors_tex : texture_2d_array<f32>;

@binding(21) @group(3) var gs_wgpu_samp_roof_colors_tex : sampler;

var<private> v0 : u32;

var<private> v9 : vec2<f32>;

@binding(22) @group(3) var gs_wgpu_tex_wall_color_data_brick_colors : texture_2d_array<f32>;

@binding(23) @group(3) var gs_wgpu_samp_wall_color_data_brick_colors : sampler;

var<private> v1 : vec3<f32>;

var<private> v11 : vec2<f32>;

@binding(28) @group(3) var gs_wgpu_tex_domain_holes : texture_2d<u32>;

@binding(29) @group(3) var gs_wgpu_samp_domain_holes : sampler;

@binding(24) @group(3) var gs_wgpu_tex_domain_roof : texture_2d<u32>;

@binding(25) @group(3) var gs_wgpu_samp_domain_roof : sampler;

@binding(0) @group(2) var<uniform> x_1295 : gs_Auto_0;

@binding(26) @group(3) var gs_wgpu_tex_domain_counts : texture_2d<u32>;

@binding(27) @group(3) var gs_wgpu_samp_domain_counts : sampler;

var<private> v13 : u32;

var<private> residentColor : vec4<f32>;

const x_1145 = vec3<f32>(0.0f, 1.0f, 0.0f);

const x_403 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_565 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_733 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_734 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_3690 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_887 = vec3<f32>(289.0f, 289.0f, 289.0f);

fn main_1() {
  var x_1493 : u32;
  var x_3219 : u32;
  var x_3238 : bool;
  var x_3231 : bool;
  var x_3237 : bool;
  var x_2543 : bool;
  var x_3245 : bool;
  var x_2551 : bool;
  var x_3246 : bool;
  var x_2593 : vec3<f32>;
  var x_3404 : vec3<f32>;
  var x_3405 : vec3<f32>;
  var x_3557 : vec3<f32>;
  var x_2913 : bool;
  var x_3669 : bool;
  var x_3589 : vec3<f32>;
  var x_2921 : vec3<f32>;
  var x_3631 : vec3<f32>;
  var x_3099 : vec3<f32>;
  var x_3664 : vec3<f32>;
  let x_1542 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ColorLibraryData_natural, 0i));
  let x_1547 : i32 = x_1542.x;
  let x_1554 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((28i % x_1547), (28i / x_1547)), 0i);
  let x_1566 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((30i % x_1547), (30i / x_1547)), 0i);
  let x_1578 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((31i % x_1547), (31i / x_1547)), 0i);
  let x_1591 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1554.x), bitcast<f32>(x_1554.y), bitcast<f32>(x_1554.z), 0.0f);
  let x_1605 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1566.x), bitcast<f32>(x_1566.y), bitcast<f32>(x_1566.z), 0.0f);
  let x_1619 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1578.x), bitcast<f32>(x_1578.y), bitcast<f32>(x_1578.z), 0.0f);
  let x_1631 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_1636 : i32 = x_1631.x;
  let x_1643 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_1636), (8i / x_1636)), 0i);
  let x_1655 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_1636), (17i / x_1636)), 0i);
  let x_1667 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_1636), (18i / x_1636)), 0i);
  let x_1679 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_1636), (19i / x_1636)), 0i);
  let x_1681 : u32 = x_1643.w;
  let x_1692 : vec3<f32> = vec3<f32>(bitcast<f32>(x_1655.x), 0.0f, bitcast<f32>(x_1655.z));
  let x_1696 : f32 = bitcast<f32>(x_1655.w);
  let x_1699 : u32 = x_1667.w;
  let x_1702 : u32 = x_1679.x;
  x_1493 = v13;
  let x_1494 : vec3<f32> = v2;
  switch(0u) {
    default: {
      let x_1736 : i32 = (bitcast<i32>(x_1493) * 16i);
      let x_1738 : i32 = (x_1736 + 15i);
      let x_1855 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_roof, 0i));
      let x_1860 : i32 = (x_1738 / 4i);
      let x_1862 : i32 = x_1855.x;
      let x_1871 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_roof, vec2<i32>((x_1860 % x_1862), (x_1860 / x_1862)), 0i);
      if ((x_1871[(x_1738 % 4i)] == 0u)) {
        x_3237 = false;
        break;
      }
      let x_1744 : i32 = (x_1736 + 10i);
      let x_1882 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_roof, 0i));
      let x_1887 : i32 = (x_1744 / 4i);
      let x_1889 : i32 = x_1882.x;
      let x_1898 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_roof, vec2<i32>((x_1887 % x_1889), (x_1887 / x_1889)), 0i);
      let x_1901 : u32 = x_1898[(x_1744 % 4i)];
      let x_1749 : vec4<f32> = x_1295.renderer_DormerGrid;
      let x_1757 : vec2<i32> = vec2<i32>(floor(((vec2<f32>(x_1494.x, x_1494.z) - vec2<f32>(x_1749.x, x_1749.y)) * vec2<f32>(x_1749.z, x_1749.w))));
      let x_1763 : i32 = (x_1757.x + (15i * x_1757.y));
      if (((x_1763 < 0i) | (x_1763 >= 225i))) {
        x_3237 = false;
        break;
      }
      let x_1909 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_counts, 0i));
      let x_1914 : i32 = (x_1763 / 4i);
      let x_1916 : i32 = x_1909.x;
      let x_1925 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_counts, vec2<i32>((x_1914 % x_1916), (x_1914 / x_1916)), 0i);
      let x_1773 : u32 = min(128u, x_1925[(x_1763 % 4i)]);
      x_3219 = 0u;
      loop {
        var x_3226 : bool;
        var x_1837 : bool;
        var x_1842 : u32;
        x_3238 = false;
        x_3231 = false;
        if ((x_3219 < x_1773)) {
        } else {
          break;
        }
        var x_1794 : vec3<f32>;
        var x_1808 : vec3<f32>;
        var x_2186 : f32;
        var x_2219 : f32;
        var x_2252 : f32;
        var x_2285 : f32;
        var x_3224 : bool;
        var x_3225 : bool;
        var x_2438 : bool;
        let x_1785 : i32 = (((x_1763 * 50i) + bitcast<i32>(x_3219)) * 12i);
        let x_1942 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1947 : i32 = (x_1785 / 4i);
        let x_1949 : i32 = x_1942.x;
        let x_1958 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1947 % x_1949), (x_1947 / x_1949)), 0i);
        let x_1789 : i32 = (x_1785 + 1i);
        let x_1975 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1980 : i32 = (x_1789 / 4i);
        let x_1982 : i32 = x_1975.x;
        let x_1991 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1980 % x_1982), (x_1980 / x_1982)), 0i);
        let x_1792 : i32 = (x_1785 + 2i);
        let x_2008 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2013 : i32 = (x_1792 / 4i);
        let x_2015 : i32 = x_2008.x;
        let x_2024 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2013 % x_2015), (x_2013 / x_2015)), 0i);
        x_1794 = vec3<f32>(bitcast<f32>(x_1958[(x_1785 % 4i)]), bitcast<f32>(x_1991[(x_1789 % 4i)]), bitcast<f32>(x_2024[(x_1792 % 4i)]));
        let x_1796 : i32 = (x_1785 + 3i);
        let x_2035 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2040 : i32 = (x_1796 / 4i);
        let x_2042 : i32 = x_2035.x;
        let x_2051 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2040 % x_2042), (x_2040 / x_2042)), 0i);
        let x_1800 : i32 = (x_1785 + 4i);
        let x_2068 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2073 : i32 = (x_1800 / 4i);
        let x_2075 : i32 = x_2068.x;
        let x_2084 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2073 % x_2075), (x_2073 / x_2075)), 0i);
        let x_1803 : i32 = (x_1785 + 5i);
        let x_2101 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2106 : i32 = (x_1803 / 4i);
        let x_2108 : i32 = x_2101.x;
        let x_2117 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2106 % x_2108), (x_2106 / x_2108)), 0i);
        let x_1806 : i32 = (x_1785 + 6i);
        let x_2134 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2139 : i32 = (x_1806 / 4i);
        let x_2141 : i32 = x_2134.x;
        let x_2150 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2139 % x_2141), (x_2139 / x_2141)), 0i);
        x_1808 = vec3<f32>(bitcast<f32>(x_2084[(x_1800 % 4i)]), bitcast<f32>(x_2117[(x_1803 % 4i)]), bitcast<f32>(x_2150[(x_1806 % 4i)]));
        let x_1814 : i32 = (x_1785 + 8i);
        let x_2194 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2199 : i32 = (x_1814 / 4i);
        let x_2201 : i32 = x_2194.x;
        let x_2210 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2199 % x_2201), (x_2199 / x_2201)), 0i);
        x_2186 = bitcast<f32>(x_2210[(x_1814 % 4i)]);
        let x_1817 : i32 = (x_1785 + 9i);
        let x_2227 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2232 : i32 = (x_1817 / 4i);
        let x_2234 : i32 = x_2227.x;
        let x_2243 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2232 % x_2234), (x_2232 / x_2234)), 0i);
        x_2219 = bitcast<f32>(x_2243[(x_1817 % 4i)]);
        let x_1821 : i32 = (x_1785 + 10i);
        let x_2260 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2265 : i32 = (x_1821 / 4i);
        let x_2267 : i32 = x_2260.x;
        let x_2276 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2265 % x_2267), (x_2265 / x_2267)), 0i);
        x_2252 = bitcast<f32>(x_2276[(x_1821 % 4i)]);
        let x_1824 : i32 = (x_1785 + 11i);
        let x_2293 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_2298 : i32 = (x_1824 / 4i);
        let x_2300 : i32 = x_2293.x;
        let x_2309 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_2298 % x_2300), (x_2298 / x_2300)), 0i);
        x_2285 = bitcast<f32>(x_2309[(x_1824 % 4i)]);
        let x_1831 : bool = (x_2051[(x_1796 % 4i)] == x_1901);
        x_1837 = x_1831;
        if (x_1831) {
          var x_2399 : f32;
          var x_2427 : bool;
          let x_2332 : vec3<f32> = vec3<f32>(x_2186, 0.0f, x_2219);
          let x_2349 : mat3x3<f32> = transpose(mat3x3<f32>(cross(x_2332, x_1145), x_1145, x_2332));
          let x_2351 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_2349);
          let x_2353 : vec3<f32> = (x_1145 * x_2349);
          let x_2355 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_2349);
          let x_2358 : vec3<f32> = cross(x_2351, x_2353);
          let x_2362 : f32 = (1.0f / dot(x_2355, x_2358));
          let x_2363 : vec3<f32> = vec3<f32>(x_2362, x_2362, x_2362);
          let x_2397 : vec3<f32> = ((mat3x3<f32>((cross(x_2353, x_2355) * x_2363), (cross(x_2355, x_2351) * x_2363), (x_2358 * x_2363)) * (x_1494 - x_1794)) / x_1808);
          x_2399 = x_2397.y;
          let x_2407 : f32 = clamp(((x_2399 * x_2252) + x_2285), 0.0f, 1.0f);
          if ((abs(x_2397.x) < mix(0.5f, 0.0f, ((x_2407 * x_2407) * x_2407)))) {
            if ((x_2399 < select(0.69999998807907104492f, 0.5f, (x_2252 == 1.0f)))) {
              x_2427 = (x_2399 > -0.5f);
              x_3224 = x_2427;
            } else {
              x_3224 = false;
            }
            x_3225 = x_3224;
          } else {
            x_3225 = false;
          }
          if (x_3225) {
            x_2438 = (abs(x_2397.z) < 0.5f);
            x_3226 = x_2438;
          } else {
            x_3226 = false;
          }
          x_1837 = x_3226;
        }
        if (x_1837) {
          x_3238 = true;
          x_3231 = true;
          break;
        }

        continuing {
          x_1842 = (x_3219 + bitcast<u32>(1i));
          x_3219 = x_1842;
        }
      }
      x_3237 = x_3238;
      if (x_3231) {
        break;
      }
      x_3237 = false;
    }
  }
  if (x_3237) {
    discard;
  }
  let x_2522 : f32 = v2.y;
  let x_2523 : f32 = v8;
  if ((x_2522 < x_2523)) {
    discard;
  }
  let x_2527 : i32 = v12;
  let x_2529 : bool = ((x_2527 & 8i) != 0i);
  let x_2532 : bool = ((x_2527 & 16i) != 0i);
  let x_2535 : bool = ((x_2527 & 2048i) != 0i);
  let x_2538 : bool = ((x_2527 & 256i) != 0i);
  if (!(x_2529)) {
    let x_2542 : f32 = v7;
    x_2543 = (x_2542 > -2.5f);
    x_3245 = x_2543;
  } else {
    x_3245 = false;
  }
  if (x_3245) {
    let x_2550 : f32 = v7;
    x_2551 = (x_2522 < x_2550);
    x_3246 = x_2551;
  } else {
    x_3246 = false;
  }
  var x_2562 : bool;
  var x_3249 : bool;
  if (x_3246) {
    discard;
  } else {
    if (x_2529) {
      let x_2561 : f32 = v7;
      x_2562 = (x_2522 > x_2561);
      x_3249 = x_2562;
    } else {
      x_3249 = false;
    }
    if (x_3249) {
      discard;
    }
  }
  var x_2569 : i32;
  var x_2570 : u32;
  var x_2598 : vec2<f32>;
  var x_2600 : vec2<f32>;
  var x_3307 : vec2<f32>;
  var x_2607 : bool;
  var x_3254 : bool;
  var x_2614 : vec3<f32>;
  var x_2620 : vec3<f32>;
  var x_3336 : vec3<f32>;
  var x_2629 : bool;
  var x_3281 : bool;
  var x_2635 : bool;
  var x_3283 : bool;
  var x_2641 : bool;
  var x_3285 : bool;
  var x_2654 : vec3<f32>;
  var x_3311 : vec3<f32>;
  var x_3329 : vec3<f32>;
  var x_2755 : bool;
  var x_3325 : bool;
  var x_2761 : bool;
  var x_3346 : bool;
  var x_2802 : vec3<f32>;
  var x_3366 : vec3<f32>;
  var x_2849 : vec3<f32>;
  x_2569 = v10;
  x_2570 = bitcast<u32>(x_2569);
  if (((x_2527 & 2i) != 0i)) {
    let x_2578 : u32 = v0;
    let x_2585 : vec2<f32> = ((vec2<f32>(vec2<u32>(x_2578, x_2578)) * 0.20000000298023223877f) + (vec2<f32>(x_1494.x, x_1494.z) * 0.20000000298023223877f));
    let x_2591 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_2585.x, x_2585.y, f32(x_2570)).xy, i32(round(vec3<f32>(x_2585.x, x_2585.y, f32(x_2570)).z)));
    x_2593 = (vec3<f32>(x_2591.x, x_2591.y, x_2591.z) * 0.69999998807907104492f);
    x_3405 = x_2593;
  } else {
    if (x_2538) {
      let x_2597 : vec2<f32> = v9;
      x_2598 = (x_2597 + vec2<f32>(0.20999999344348907471f, 0.20999999344348907471f));
      x_3307 = x_2598;
    } else {
      x_2600 = v9;
      x_3307 = x_2600;
    }
    if ((x_2570 == 1u)) {
      x_3254 = true;
    } else {
      x_2607 = (x_2570 == 0u);
      x_3254 = x_2607;
    }
    if (x_3254) {
      x_2614 = pow(vec3<f32>(x_1619.x, x_1619.y, x_1619.z), vec3<f32>(1.29999995231628417969f, 1.29999995231628417969f, 1.29999995231628417969f));
      x_3336 = x_2614;
    } else {
      x_2620 = (pow(vec3<f32>(x_1605.x, x_1605.y, x_1605.z), x_403) * 0.80000001192092895508f);
      x_3336 = x_2620;
    }
    if ((x_2569 == 0i)) {
      x_3281 = true;
    } else {
      x_2629 = (x_2569 == 4i);
      x_3281 = x_2629;
    }
    if (x_3281) {
      x_3283 = true;
    } else {
      x_2635 = (x_2569 == 10i);
      x_3283 = x_2635;
    }
    if (x_3283) {
      x_3285 = true;
    } else {
      x_2641 = (x_2569 == 12i);
      x_3285 = x_2641;
    }
    var x_2661 : bool;
    var x_3287 : bool;
    var x_2675 : vec3<f32>;
    var x_3310 : vec3<f32>;
    if (x_3285) {
      let x_2649 : vec2<f32> = (x_3307 + vec2<f32>(0.85000002384185791016f, 0.85000002384185791016f));
      let x_2653 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2649.x, x_2649.y, 0.0f).xy, i32(round(vec3<f32>(x_2649.x, x_2649.y, 0.0f).z)));
      x_2654 = vec3<f32>(x_2653.x, x_2653.y, x_2653.z);
      x_3329 = x_2654;
    } else {
      if ((x_2569 == 1i)) {
        x_3287 = true;
      } else {
        x_2661 = (x_2569 == 5i);
        x_3287 = x_2661;
      }
      var x_2682 : bool;
      var x_3289 : bool;
      var x_2694 : vec3<f32>;
      var x_3309 : vec3<f32>;
      if (x_3287) {
        let x_2669 : vec2<f32> = (x_3307 + vec2<f32>(0.44999998807907104492f, 0.44999998807907104492f));
        let x_2673 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2669.x, x_2669.y, 1.0f).xy, i32(round(vec3<f32>(x_2669.x, x_2669.y, 1.0f).z)));
        x_2675 = pow(vec3<f32>(x_2673.x, x_2673.y, x_2673.z), vec3<f32>(1.10000002384185791016f, 1.10000002384185791016f, 1.10000002384185791016f));
        x_3311 = x_2675;
      } else {
        if ((x_2569 == 2i)) {
          x_3289 = true;
        } else {
          x_2682 = (x_2569 == 7i);
          x_3289 = x_2682;
        }
        var x_2701 : bool;
        var x_3291 : bool;
        var x_2707 : bool;
        var x_3293 : bool;
        var x_2713 : bool;
        var x_3295 : bool;
        var x_2725 : vec3<f32>;
        var x_3308 : vec3<f32>;
        if (x_3289) {
          let x_2693 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3307.x, x_3307.y, 2.0f).xy, i32(round(vec3<f32>(x_3307.x, x_3307.y, 2.0f).z)));
          x_2694 = vec3<f32>(x_2693.x, x_2693.y, x_2693.z);
          x_3310 = x_2694;
        } else {
          if ((x_2569 == 3i)) {
            x_3291 = true;
          } else {
            x_2701 = (x_2569 == 6i);
            x_3291 = x_2701;
          }
          if (x_3291) {
            x_3293 = true;
          } else {
            x_2707 = (x_2569 == 8i);
            x_3293 = x_2707;
          }
          if (x_3293) {
            x_3295 = true;
          } else {
            x_2713 = (x_2569 == 9i);
            x_3295 = x_2713;
          }
          var x_2738 : vec3<f32>;
          if (x_3295) {
            let x_2724 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3307.x, x_3307.y, 3.0f).xy, i32(round(vec3<f32>(x_3307.x, x_3307.y, 3.0f).z)));
            x_2725 = vec3<f32>(x_2724.x, x_2724.y, x_2724.z);
            x_3309 = x_2725;
          } else {
            if ((x_2569 == 11i)) {
              let x_2737 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3307.x, x_3307.y, 4.0f).xy, i32(round(vec3<f32>(x_3307.x, x_3307.y, 4.0f).z)));
              x_2738 = vec3<f32>(x_2737.x, x_2737.y, x_2737.z);
              x_3308 = x_2738;
            } else {
              x_3308 = x_565;
            }
            x_3309 = x_3308;
          }
          x_3310 = x_3309;
        }
        x_3311 = x_3310;
      }
      x_3329 = x_3311;
    }
    let x_2750 : bool = (x_2570 == 7u);
    if (x_2750) {
      x_3325 = true;
    } else {
      x_2755 = (x_2570 == 2u);
      x_3325 = x_2755;
    }
    if (x_3325) {
      x_3346 = true;
    } else {
      x_2761 = (x_2570 == 11u);
      x_3346 = x_2761;
    }
    if (((x_2527 & 512i) != 0i)) {
      let x_2767 : u32 = v0;
      let x_2768 : u32 = (x_2767 ^ 8902390u);
      let x_2772 : u32 = (x_2768 + (x_2768 << 10u));
      let x_2776 : u32 = (x_2772 ^ (x_2772 >> 6u));
      let x_2780 : u32 = (x_2776 + (x_2776 << 3u));
      let x_2784 : u32 = (x_2780 ^ (x_2780 >> 11u));
      let x_2800 : f32 = mix(0.0f, 0.5f, smoothstep(0.20000000298023223877f, 0.80000001192092895508f, (bitcast<f32>((((x_2784 + (x_2784 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_2802 = mix(x_3329, select(x_3336, x_3329, vec3<bool>(x_3346, x_3346, x_3346)), vec3<f32>(x_2800, x_2800, x_2800));
      x_3366 = x_2802;
    } else {
      x_3366 = x_3329;
    }
    var x_2812 : bool;
    var x_3403 : bool;
    if (x_2538) {
      if (x_2750) {
        x_3403 = true;
      } else {
        x_2812 = (x_2570 == 2u);
        x_3403 = x_2812;
      }
      let x_2814 : u32 = v0;
      let x_2815 : u32 = (x_2814 ^ 239085u);
      let x_2819 : u32 = (x_2815 + (x_2815 << 10u));
      let x_2823 : u32 = (x_2819 ^ (x_2819 >> 6u));
      let x_2827 : u32 = (x_2823 + (x_2823 << 3u));
      let x_2831 : u32 = (x_2827 ^ (x_2827 >> 11u));
      let x_2847 : f32 = mix(0.0f, select(0.40000000596046447754f, 0.20000000298023223877f, x_3403), smoothstep(0.0f, 0.80000001192092895508f, (bitcast<f32>((((x_2831 + (x_2831 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_2849 = mix(x_3366, vec3<f32>(x_1591.x, x_1591.y, x_1591.z), vec3<f32>(x_2847, x_2847, x_2847));
      x_3404 = x_2849;
    } else {
      x_3404 = x_3366;
    }
    x_3405 = x_3404;
  }
  var x_2874 : vec3<f32>;
  var x_2877 : bool;
  var x_3441 : vec3<f32>;
  var x_3556 : bool;
  var x_3549 : vec3<f32>;
  var x_2901 : bool;
  var x_3547 : bool;
  var x_2907 : vec3<f32>;
  let x_2855 : vec3<f32> = v1;
  let x_2856 : vec3<f32> = normalize(x_2855);
  if (((x_2527 & 64i) == 0i)) {
    var x_3708 : u32;
    var x_2881 : vec3<f32>;
    x_3708 = select(0u, x_1699, ((x_2527 & 4096i) != 0i));
    if ((x_3708 == 1u)) {
      x_2874 = mix(x_3405, x_733, x_734);
      x_3556 = true;
      x_3549 = x_2874;
    } else {
      x_2877 = (x_3708 == 2u);
      if (x_2877) {
        x_2881 = mix(x_3405, x_734, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_3441 = x_2881;
      } else {
        x_3441 = x_3405;
      }
      x_3556 = x_2877;
      x_3549 = x_3441;
    }
    if ((x_1702 == 1u)) {
      let x_2896 : vec2<f32> = v11;
      x_2901 = (distance(vec2<f32>(x_1692.x, x_1692.z), x_2896) < (1.88900005817413330078f * x_1696));
      x_3547 = x_2901;
    } else {
      x_3547 = false;
    }
    if (x_3547) {
      x_2907 = mix(x_3405, x_733, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_3557 = x_2907;
    } else {
      x_3557 = x_3549;
    }
    x_2913 = select(x_3556, true, x_3547);
    x_3669 = x_2913;
    x_3589 = x_3557;
  } else {
    x_3669 = false;
    x_3589 = x_3405;
  }
  if (x_2535) {
    x_2921 = mix(x_3405, x_733, x_734);
    x_3631 = x_2921;
  } else {
    x_3631 = x_3589;
  }
  if ((x_1681 == 4u)) {
    let x_2931 : vec2<f32> = (vec2<f32>(x_1494.x, x_1494.z) * 0.40000000596046447754f);
    let x_2934 : f32 = dot(x_2931, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
    let x_2937 : vec2<f32> = floor((x_2931 + vec2<f32>(x_2934, x_2934)));
    let x_2942 : f32 = dot(x_2937, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
    let x_2944 : vec2<f32> = ((x_2931 - x_2937) + vec2<f32>(x_2942, x_2942));
    let x_2946 : f32 = x_2944.x;
    let x_2948 : f32 = x_2944.y;
    let x_2951 : bool = (x_2946 > x_2948);
    let x_2953 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_2951, x_2951));
    let x_2956 : vec4<f32> = (vec4<f32>(x_2944.x, x_2944.y, x_2944.x, x_2944.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
    let x_2960 : vec2<f32> = (vec2<f32>(x_2956.x, x_2956.y) - x_2953);
    var x_3781_1 : vec4<f32> = x_2956;
    x_3781_1.x = x_2960.x;
    let x_3781 : vec4<f32> = x_3781_1;
    var x_3784_1 : vec4<f32> = x_3781;
    x_3784_1.y = x_2960.y;
    let x_3784 : vec4<f32> = x_3784_1;
    let x_2973 : vec2<f32> = (x_2937 - (vec2<f32>(289.0f, 289.0f) * trunc((x_2937 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
    let x_2975 : f32 = x_2973.y;
    let x_2980 : vec3<f32> = (vec3<f32>(x_2975, x_2975, x_2975) + vec3<f32>(0.0f, x_2953.y, 1.0f));
    let x_2985 : vec3<f32> = (((x_2980 * 34.0f) + x_403) * x_2980);
    let x_2993 : f32 = x_2973.x;
    let x_2999 : vec3<f32> = (((x_2985 - (x_887 * trunc((x_2985 * x_3690)))) + vec3<f32>(x_2993, x_2993, x_2993)) + vec3<f32>(0.0f, x_2953.x, 1.0f));
    let x_3004 : vec3<f32> = (((x_2999 * 34.0f) + x_403) * x_2999);
    let x_3009 : vec2<f32> = vec2<f32>(x_3784.x, x_3784.y);
    let x_3014 : vec2<f32> = vec2<f32>(x_3784.z, x_3784.w);
    let x_3020 : vec3<f32> = max((x_734 - vec3<f32>(dot(x_2944, x_2944), dot(x_3009, x_3009), dot(x_3014, x_3014))), x_565);
    let x_3023 : vec3<f32> = (x_3020 * x_3020);
    let x_3032 : vec3<f32> = (fract(((x_3004 - (x_887 * trunc((x_3004 * x_3690)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
    let x_3034 : vec3<f32> = (x_3032 - x_403);
    let x_3037 : vec3<f32> = (abs(x_3034) - x_734);
    let x_3042 : vec3<f32> = (x_3034 - floor((x_3032 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
    let x_3084 : vec2<f32> = ((vec2<f32>(x_3042.y, x_3042.z) * vec2<f32>(x_3784.x, x_3784.z)) + (vec2<f32>(x_3037.y, x_3037.z) * vec2<f32>(x_3784.y, x_3784.w)));
    let x_3097 : f32 = (smoothstep(0.0f, 1.0f, (smoothstep(-0.10000000149011611938f, 0.0f, x_2522) * clamp(x_2856.y, 0.0f, 1.0f))) * clamp(clamp(((130.0f * dot(((x_3023 * x_3023) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_3042 * x_3042) + (x_3037 * x_3037)) * 0.85373473167419433594f))), vec3<f32>(((x_3042.x * x_2946) + (x_3037.x * x_2948)), x_3084.x, x_3084.y))) + 0.75f), 0.0f, 1.0f), select(0.40000000596046447754f, 0.0f, x_2532), select(1.0f, 0.10000000149011611938f, x_2532)));
    x_3099 = mix(x_3631, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_3097, x_3097, x_3097));
    x_3664 = x_3099;
  } else {
    x_3664 = x_3631;
  }
  let x_3108 : vec3<f32> = sqrt(clamp(x_3664, x_565, x_403));
  let x_3165 : u32 = (((u32(((clamp(x_3108.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_3108.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_3108.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(2264924160u, 2399141888u, select(x_3669, true, x_2535)));
  let x_1512 : vec3<f32> = vec3<f32>(f32((x_3165 & 255u)), f32(((x_3165 >> 8u) & 255u)), f32(((x_3165 >> 16u) & 255u)));
  let x_1517 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_1512 * x_1512));
  let x_1527 : vec3<f32> = select((x_1517 * 12.9200000762939453125f), ((pow(x_1517, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_1517 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_1527.x, x_1527.y, x_1527.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(2) v2_param : vec3<f32>, @location(4) @interpolate(flat) v8_param : f32, @location(8) @interpolate(flat) v12_param : i32, @location(3) v7_param : f32, @location(6) @interpolate(flat) v10_param : i32, @location(0) @interpolate(flat) v0_param : u32, @location(5) v9_param : vec2<f32>, @location(1) v1_param : vec3<f32>, @location(7) @interpolate(flat) v11_param : vec2<f32>, @location(9) @interpolate(flat) v13_param : u32) -> main_out {
  v2 = v2_param;
  v8 = v8_param;
  v12 = v12_param;
  v7 = v7_param;
  v10 = v10_param;
  v0 = v0_param;
  v9 = v9_param;
  v1 = v1_param;
  v11 = v11_param;
  v13 = v13_param;
  main_1();
  return main_out(residentColor);
}
