diagnostic(off, derivative_uniformity);
@binding(2) @group(3) var gs_wgpu_tex_storage_0_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_0 : sampler;

@binding(14) @group(3) var gs_wgpu_tex_storage_20_0 : texture_2d<u32>;

@binding(15) @group(3) var gs_wgpu_samp_storage_20_0 : sampler;

@binding(10) @group(3) var gs_wgpu_tex_uniform_ColorLibraryData_natural : texture_2d<u32>;

@binding(11) @group(3) var gs_wgpu_samp_uniform_ColorLibraryData_natural : sampler;

@binding(12) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(13) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

var<private> v2 : vec3<f32>;

var<private> v8 : f32;

var<private> v12 : i32;

var<private> v7 : f32;

var<private> v10 : i32;

@binding(16) @group(3) var gs_wgpu_tex_roof_colors_tex : texture_2d_array<f32>;

@binding(17) @group(3) var gs_wgpu_samp_roof_colors_tex : sampler;

var<private> v0 : u32;

var<private> v9 : vec2<f32>;

@binding(18) @group(3) var gs_wgpu_tex_wall_color_data_brick_colors : texture_2d_array<f32>;

@binding(19) @group(3) var gs_wgpu_samp_wall_color_data_brick_colors : sampler;

var<private> v1 : vec3<f32>;

var<private> v11 : vec2<f32>;

@binding(20) @group(3) var gs_wgpu_tex_halftimber_colors_tex : texture_2d_array<f32>;

@binding(21) @group(3) var gs_wgpu_samp_halftimber_colors_tex : sampler;

var<private> v13 : u32;

var<private> residentColor : vec4<f32>;

const x_628 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_781 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_949 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_950 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_3386 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_1138 = vec3<f32>(289.0f, 289.0f, 289.0f);

fn main_1() {
  var x_1714 : bool;
  var x_3006 : bool;
  var x_1722 : bool;
  var x_3007 : bool;
  var x_1764 : vec3<f32>;
  var x_3144 : vec3<f32>;
  var x_3145 : vec3<f32>;
  var x_3269 : vec3<f32>;
  var x_2084 : bool;
  var x_3379 : bool;
  var x_3301 : vec3<f32>;
  var x_2092 : vec3<f32>;
  var x_3304 : vec3<f32>;
  var x_2119 : vec3<f32>;
  var x_3338 : vec3<f32>;
  var x_2297 : vec3<f32>;
  var x_3372 : vec3<f32>;
  let x_1448 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ColorLibraryData_natural, 0i));
  let x_1453 : i32 = x_1448.x;
  let x_1460 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((28i % x_1453), (28i / x_1453)), 0i);
  let x_1472 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((30i % x_1453), (30i / x_1453)), 0i);
  let x_1484 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((31i % x_1453), (31i / x_1453)), 0i);
  let x_1497 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1460.x), bitcast<f32>(x_1460.y), bitcast<f32>(x_1460.z), 0.0f);
  let x_1511 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1472.x), bitcast<f32>(x_1472.y), bitcast<f32>(x_1472.z), 0.0f);
  let x_1525 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1484.x), bitcast<f32>(x_1484.y), bitcast<f32>(x_1484.z), 0.0f);
  let x_1537 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_1542 : i32 = x_1537.x;
  let x_1549 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_1542), (8i / x_1542)), 0i);
  let x_1561 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_1542), (17i / x_1542)), 0i);
  let x_1573 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_1542), (18i / x_1542)), 0i);
  let x_1585 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_1542), (19i / x_1542)), 0i);
  let x_1587 : u32 = x_1549.w;
  let x_1598 : vec3<f32> = vec3<f32>(bitcast<f32>(x_1561.x), 0.0f, bitcast<f32>(x_1561.z));
  let x_1602 : f32 = bitcast<f32>(x_1561.w);
  let x_1605 : u32 = x_1573.w;
  let x_1608 : u32 = x_1585.x;
  let x_1693 : f32 = v2.y;
  let x_1694 : f32 = v8;
  if ((x_1693 < x_1694)) {
    discard;
  }
  let x_1698 : i32 = v12;
  let x_1700 : bool = ((x_1698 & 8i) != 0i);
  let x_1703 : bool = ((x_1698 & 16i) != 0i);
  let x_1706 : bool = ((x_1698 & 2048i) != 0i);
  let x_1709 : bool = ((x_1698 & 256i) != 0i);
  if (!(x_1700)) {
    let x_1713 : f32 = v7;
    x_1714 = (x_1713 > -2.5f);
    x_3006 = x_1714;
  } else {
    x_3006 = false;
  }
  if (x_3006) {
    let x_1721 : f32 = v7;
    x_1722 = (x_1693 < x_1721);
    x_3007 = x_1722;
  } else {
    x_3007 = false;
  }
  var x_1733 : bool;
  var x_3010 : bool;
  if (x_3007) {
    discard;
  } else {
    if (x_1700) {
      let x_1732 : f32 = v7;
      x_1733 = (x_1693 > x_1732);
      x_3010 = x_1733;
    } else {
      x_3010 = false;
    }
    if (x_3010) {
      discard;
    }
  }
  var x_1740 : i32;
  var x_1741 : u32;
  var x_1769 : vec2<f32>;
  var x_1771 : vec2<f32>;
  var x_3054 : vec2<f32>;
  var x_1778 : bool;
  var x_3015 : bool;
  var x_1785 : vec3<f32>;
  var x_1791 : vec3<f32>;
  var x_3083 : vec3<f32>;
  var x_1800 : bool;
  var x_3028 : bool;
  var x_1806 : bool;
  var x_3030 : bool;
  var x_1812 : bool;
  var x_3032 : bool;
  var x_1825 : vec3<f32>;
  var x_3058 : vec3<f32>;
  var x_3076 : vec3<f32>;
  var x_1926 : bool;
  var x_3072 : bool;
  var x_1932 : bool;
  var x_3093 : bool;
  var x_1973 : vec3<f32>;
  var x_3113 : vec3<f32>;
  var x_2020 : vec3<f32>;
  x_1740 = v10;
  x_1741 = bitcast<u32>(x_1740);
  if (((x_1698 & 2i) != 0i)) {
    let x_1749 : u32 = v0;
    let x_1753 : vec3<f32> = v2;
    let x_1756 : vec2<f32> = ((vec2<f32>(vec2<u32>(x_1749, x_1749)) * 0.20000000298023223877f) + (vec2<f32>(x_1753.x, x_1753.z) * 0.20000000298023223877f));
    let x_1762 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_1756.x, x_1756.y, f32(x_1741)).xy, i32(round(vec3<f32>(x_1756.x, x_1756.y, f32(x_1741)).z)));
    x_1764 = (vec3<f32>(x_1762.x, x_1762.y, x_1762.z) * 0.69999998807907104492f);
    x_3145 = x_1764;
  } else {
    if (x_1709) {
      let x_1768 : vec2<f32> = v9;
      x_1769 = (x_1768 + vec2<f32>(0.20999999344348907471f, 0.20999999344348907471f));
      x_3054 = x_1769;
    } else {
      x_1771 = v9;
      x_3054 = x_1771;
    }
    if ((x_1741 == 1u)) {
      x_3015 = true;
    } else {
      x_1778 = (x_1741 == 0u);
      x_3015 = x_1778;
    }
    if (x_3015) {
      x_1785 = pow(vec3<f32>(x_1525.x, x_1525.y, x_1525.z), vec3<f32>(1.29999995231628417969f, 1.29999995231628417969f, 1.29999995231628417969f));
      x_3083 = x_1785;
    } else {
      x_1791 = (pow(vec3<f32>(x_1511.x, x_1511.y, x_1511.z), x_628) * 0.80000001192092895508f);
      x_3083 = x_1791;
    }
    if ((x_1740 == 0i)) {
      x_3028 = true;
    } else {
      x_1800 = (x_1740 == 4i);
      x_3028 = x_1800;
    }
    if (x_3028) {
      x_3030 = true;
    } else {
      x_1806 = (x_1740 == 10i);
      x_3030 = x_1806;
    }
    if (x_3030) {
      x_3032 = true;
    } else {
      x_1812 = (x_1740 == 12i);
      x_3032 = x_1812;
    }
    var x_1832 : bool;
    var x_3034 : bool;
    var x_1846 : vec3<f32>;
    var x_3057 : vec3<f32>;
    if (x_3032) {
      let x_1820 : vec2<f32> = (x_3054 + vec2<f32>(0.85000002384185791016f, 0.85000002384185791016f));
      let x_1824 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_1820.x, x_1820.y, 0.0f).xy, i32(round(vec3<f32>(x_1820.x, x_1820.y, 0.0f).z)));
      x_1825 = vec3<f32>(x_1824.x, x_1824.y, x_1824.z);
      x_3076 = x_1825;
    } else {
      if ((x_1740 == 1i)) {
        x_3034 = true;
      } else {
        x_1832 = (x_1740 == 5i);
        x_3034 = x_1832;
      }
      var x_1853 : bool;
      var x_3036 : bool;
      var x_1865 : vec3<f32>;
      var x_3056 : vec3<f32>;
      if (x_3034) {
        let x_1840 : vec2<f32> = (x_3054 + vec2<f32>(0.44999998807907104492f, 0.44999998807907104492f));
        let x_1844 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_1840.x, x_1840.y, 1.0f).xy, i32(round(vec3<f32>(x_1840.x, x_1840.y, 1.0f).z)));
        x_1846 = pow(vec3<f32>(x_1844.x, x_1844.y, x_1844.z), vec3<f32>(1.10000002384185791016f, 1.10000002384185791016f, 1.10000002384185791016f));
        x_3058 = x_1846;
      } else {
        if ((x_1740 == 2i)) {
          x_3036 = true;
        } else {
          x_1853 = (x_1740 == 7i);
          x_3036 = x_1853;
        }
        var x_1872 : bool;
        var x_3038 : bool;
        var x_1878 : bool;
        var x_3040 : bool;
        var x_1884 : bool;
        var x_3042 : bool;
        var x_1896 : vec3<f32>;
        var x_3055 : vec3<f32>;
        if (x_3036) {
          let x_1864 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3054.x, x_3054.y, 2.0f).xy, i32(round(vec3<f32>(x_3054.x, x_3054.y, 2.0f).z)));
          x_1865 = vec3<f32>(x_1864.x, x_1864.y, x_1864.z);
          x_3057 = x_1865;
        } else {
          if ((x_1740 == 3i)) {
            x_3038 = true;
          } else {
            x_1872 = (x_1740 == 6i);
            x_3038 = x_1872;
          }
          if (x_3038) {
            x_3040 = true;
          } else {
            x_1878 = (x_1740 == 8i);
            x_3040 = x_1878;
          }
          if (x_3040) {
            x_3042 = true;
          } else {
            x_1884 = (x_1740 == 9i);
            x_3042 = x_1884;
          }
          var x_1909 : vec3<f32>;
          if (x_3042) {
            let x_1895 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3054.x, x_3054.y, 3.0f).xy, i32(round(vec3<f32>(x_3054.x, x_3054.y, 3.0f).z)));
            x_1896 = vec3<f32>(x_1895.x, x_1895.y, x_1895.z);
            x_3056 = x_1896;
          } else {
            if ((x_1740 == 11i)) {
              let x_1908 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_3054.x, x_3054.y, 4.0f).xy, i32(round(vec3<f32>(x_3054.x, x_3054.y, 4.0f).z)));
              x_1909 = vec3<f32>(x_1908.x, x_1908.y, x_1908.z);
              x_3055 = x_1909;
            } else {
              x_3055 = x_781;
            }
            x_3056 = x_3055;
          }
          x_3057 = x_3056;
        }
        x_3058 = x_3057;
      }
      x_3076 = x_3058;
    }
    let x_1921 : bool = (x_1741 == 7u);
    if (x_1921) {
      x_3072 = true;
    } else {
      x_1926 = (x_1741 == 2u);
      x_3072 = x_1926;
    }
    if (x_3072) {
      x_3093 = true;
    } else {
      x_1932 = (x_1741 == 11u);
      x_3093 = x_1932;
    }
    if (((x_1698 & 512i) != 0i)) {
      let x_1938 : u32 = v0;
      let x_1939 : u32 = (x_1938 ^ 8902390u);
      let x_1943 : u32 = (x_1939 + (x_1939 << 10u));
      let x_1947 : u32 = (x_1943 ^ (x_1943 >> 6u));
      let x_1951 : u32 = (x_1947 + (x_1947 << 3u));
      let x_1955 : u32 = (x_1951 ^ (x_1951 >> 11u));
      let x_1971 : f32 = mix(0.0f, 0.5f, smoothstep(0.20000000298023223877f, 0.80000001192092895508f, (bitcast<f32>((((x_1955 + (x_1955 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_1973 = mix(x_3076, select(x_3083, x_3076, vec3<bool>(x_3093, x_3093, x_3093)), vec3<f32>(x_1971, x_1971, x_1971));
      x_3113 = x_1973;
    } else {
      x_3113 = x_3076;
    }
    var x_1983 : bool;
    var x_3143 : bool;
    if (x_1709) {
      if (x_1921) {
        x_3143 = true;
      } else {
        x_1983 = (x_1741 == 2u);
        x_3143 = x_1983;
      }
      let x_1985 : u32 = v0;
      let x_1986 : u32 = (x_1985 ^ 239085u);
      let x_1990 : u32 = (x_1986 + (x_1986 << 10u));
      let x_1994 : u32 = (x_1990 ^ (x_1990 >> 6u));
      let x_1998 : u32 = (x_1994 + (x_1994 << 3u));
      let x_2002 : u32 = (x_1998 ^ (x_1998 >> 11u));
      let x_2018 : f32 = mix(0.0f, select(0.40000000596046447754f, 0.20000000298023223877f, x_3143), smoothstep(0.0f, 0.80000001192092895508f, (bitcast<f32>((((x_2002 + (x_2002 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_2020 = mix(x_3113, vec3<f32>(x_1497.x, x_1497.y, x_1497.z), vec3<f32>(x_2018, x_2018, x_2018));
      x_3144 = x_2020;
    } else {
      x_3144 = x_3113;
    }
    x_3145 = x_3144;
  }
  var x_2045 : vec3<f32>;
  var x_2048 : bool;
  var x_3174 : vec3<f32>;
  var x_3268 : bool;
  var x_3261 : vec3<f32>;
  var x_2072 : bool;
  var x_3259 : bool;
  var x_2078 : vec3<f32>;
  let x_2026 : vec3<f32> = v1;
  let x_2027 : vec3<f32> = normalize(x_2026);
  if (((x_1698 & 64i) == 0i)) {
    var x_3404 : u32;
    var x_2052 : vec3<f32>;
    x_3404 = select(0u, x_1605, ((x_1698 & 4096i) != 0i));
    if ((x_3404 == 1u)) {
      x_2045 = mix(x_3145, x_949, x_950);
      x_3268 = true;
      x_3261 = x_2045;
    } else {
      x_2048 = (x_3404 == 2u);
      if (x_2048) {
        x_2052 = mix(x_3145, x_950, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_3174 = x_2052;
      } else {
        x_3174 = x_3145;
      }
      x_3268 = x_2048;
      x_3261 = x_3174;
    }
    if ((x_1608 == 1u)) {
      let x_2067 : vec2<f32> = v11;
      x_2072 = (distance(vec2<f32>(x_1598.x, x_1598.z), x_2067) < (1.88900005817413330078f * x_1602));
      x_3259 = x_2072;
    } else {
      x_3259 = false;
    }
    if (x_3259) {
      x_2078 = mix(x_3145, x_949, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_3269 = x_2078;
    } else {
      x_3269 = x_3261;
    }
    x_2084 = select(x_3268, true, x_3259);
    x_3379 = x_2084;
    x_3301 = x_3269;
  } else {
    x_3379 = false;
    x_3301 = x_3145;
  }
  if (x_1706) {
    x_2092 = mix(x_3145, x_949, x_950);
    x_3304 = x_2092;
  } else {
    x_3304 = x_3301;
  }
  if (((x_1698 & 1024i) != 0i)) {
    let x_2105 : vec2<f32> = v9;
    let x_2106 : u32 = v13;
    let x_2509 : i32 = ((bitcast<i32>(x_2106) * 16i) + 14i);
    let x_2905 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_2910 : i32 = (x_2509 / 4i);
    let x_2912 : i32 = x_2905.x;
    let x_2921 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_2910 % x_2912), (x_2910 / x_2912)), 0i);
    let x_2111 : i32 = bitcast<i32>((x_2921[(x_2509 % 4i)] & 2147483647u));
    let x_2966 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_20_0, 0i));
    let x_2971 : i32 = (x_2111 / 4i);
    let x_2973 : i32 = x_2966.x;
    let x_2982 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_20_0, vec2<i32>((x_2971 % x_2973), (x_2971 / x_2973)), 0i);
    let x_2118 : vec4<f32> = textureSample(gs_wgpu_tex_halftimber_colors_tex, gs_wgpu_samp_halftimber_colors_tex, vec3<f32>(x_2105.x, x_2105.y, f32(bitcast<i32>(x_2982[(x_2111 % 4i)]))).xy, i32(round(vec3<f32>(x_2105.x, x_2105.y, f32(bitcast<i32>(x_2982[(x_2111 % 4i)]))).z)));
    x_2119 = vec3<f32>(x_2118.x, x_2118.y, x_2118.z);
    x_3338 = x_2119;
  } else {
    x_3338 = x_3304;
  }
  if ((x_1587 == 4u)) {
    let x_2127 : vec3<f32> = v2;
    let x_2129 : vec2<f32> = (vec2<f32>(x_2127.x, x_2127.z) * 0.40000000596046447754f);
    let x_2132 : f32 = dot(x_2129, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
    let x_2135 : vec2<f32> = floor((x_2129 + vec2<f32>(x_2132, x_2132)));
    let x_2140 : f32 = dot(x_2135, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
    let x_2142 : vec2<f32> = ((x_2129 - x_2135) + vec2<f32>(x_2140, x_2140));
    let x_2144 : f32 = x_2142.x;
    let x_2146 : f32 = x_2142.y;
    let x_2149 : bool = (x_2144 > x_2146);
    let x_2151 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_2149, x_2149));
    let x_2154 : vec4<f32> = (vec4<f32>(x_2142.x, x_2142.y, x_2142.x, x_2142.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
    let x_2158 : vec2<f32> = (vec2<f32>(x_2154.x, x_2154.y) - x_2151);
    var x_3446_1 : vec4<f32> = x_2154;
    x_3446_1.x = x_2158.x;
    let x_3446 : vec4<f32> = x_3446_1;
    var x_3449_1 : vec4<f32> = x_3446;
    x_3449_1.y = x_2158.y;
    let x_3449 : vec4<f32> = x_3449_1;
    let x_2171 : vec2<f32> = (x_2135 - (vec2<f32>(289.0f, 289.0f) * trunc((x_2135 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
    let x_2173 : f32 = x_2171.y;
    let x_2178 : vec3<f32> = (vec3<f32>(x_2173, x_2173, x_2173) + vec3<f32>(0.0f, x_2151.y, 1.0f));
    let x_2183 : vec3<f32> = (((x_2178 * 34.0f) + x_628) * x_2178);
    let x_2191 : f32 = x_2171.x;
    let x_2197 : vec3<f32> = (((x_2183 - (x_1138 * trunc((x_2183 * x_3386)))) + vec3<f32>(x_2191, x_2191, x_2191)) + vec3<f32>(0.0f, x_2151.x, 1.0f));
    let x_2202 : vec3<f32> = (((x_2197 * 34.0f) + x_628) * x_2197);
    let x_2207 : vec2<f32> = vec2<f32>(x_3449.x, x_3449.y);
    let x_2212 : vec2<f32> = vec2<f32>(x_3449.z, x_3449.w);
    let x_2218 : vec3<f32> = max((x_950 - vec3<f32>(dot(x_2142, x_2142), dot(x_2207, x_2207), dot(x_2212, x_2212))), x_781);
    let x_2221 : vec3<f32> = (x_2218 * x_2218);
    let x_2230 : vec3<f32> = (fract(((x_2202 - (x_1138 * trunc((x_2202 * x_3386)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
    let x_2232 : vec3<f32> = (x_2230 - x_628);
    let x_2235 : vec3<f32> = (abs(x_2232) - x_950);
    let x_2240 : vec3<f32> = (x_2232 - floor((x_2230 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
    let x_2282 : vec2<f32> = ((vec2<f32>(x_2240.y, x_2240.z) * vec2<f32>(x_3449.x, x_3449.z)) + (vec2<f32>(x_2235.y, x_2235.z) * vec2<f32>(x_3449.y, x_3449.w)));
    let x_2295 : f32 = (smoothstep(0.0f, 1.0f, (smoothstep(-0.10000000149011611938f, 0.0f, x_1693) * clamp(x_2027.y, 0.0f, 1.0f))) * clamp(clamp(((130.0f * dot(((x_2221 * x_2221) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_2240 * x_2240) + (x_2235 * x_2235)) * 0.85373473167419433594f))), vec3<f32>(((x_2240.x * x_2144) + (x_2235.x * x_2146)), x_2282.x, x_2282.y))) + 0.75f), 0.0f, 1.0f), select(0.40000000596046447754f, 0.0f, x_1703), select(1.0f, 0.10000000149011611938f, x_1703)));
    x_2297 = mix(x_3338, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_2295, x_2295, x_2295));
    x_3372 = x_2297;
  } else {
    x_3372 = x_3338;
  }
  let x_2306 : vec3<f32> = sqrt(clamp(x_3372, x_781, x_628));
  let x_2363 : u32 = (((u32(((clamp(x_2306.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_2306.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_2306.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(2264924160u, 2399141888u, select(x_3379, true, x_1706)));
  let x_1419 : vec3<f32> = vec3<f32>(f32((x_2363 & 255u)), f32(((x_2363 >> 8u) & 255u)), f32(((x_2363 >> 16u) & 255u)));
  let x_1424 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_1419 * x_1419));
  let x_1434 : vec3<f32> = select((x_1424 * 12.9200000762939453125f), ((pow(x_1424, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_1424 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_1434.x, x_1434.y, x_1434.z, 1.0f);
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
