diagnostic(off, derivative_uniformity);
@binding(2) @group(3) var gs_wgpu_tex_storage_0_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_0 : sampler;

@binding(14) @group(3) var gs_wgpu_tex_storage_21_0 : texture_2d<u32>;

@binding(15) @group(3) var gs_wgpu_samp_storage_21_0 : sampler;

@binding(16) @group(3) var gs_wgpu_tex_storage_20_0 : texture_2d<u32>;

@binding(17) @group(3) var gs_wgpu_samp_storage_20_0 : sampler;

@binding(10) @group(3) var gs_wgpu_tex_uniform_ColorLibraryData_natural : texture_2d<u32>;

@binding(11) @group(3) var gs_wgpu_samp_uniform_ColorLibraryData_natural : sampler;

@binding(12) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(13) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

var<private> v2 : vec3<f32>;

var<private> v8 : f32;

var<private> v12 : i32;

var<private> v7 : f32;

var<private> v10 : i32;

@binding(18) @group(3) var gs_wgpu_tex_roof_colors_tex : texture_2d_array<f32>;

@binding(19) @group(3) var gs_wgpu_samp_roof_colors_tex : sampler;

var<private> v0 : u32;

var<private> v9 : vec2<f32>;

@binding(20) @group(3) var gs_wgpu_tex_wall_color_data_brick_colors : texture_2d_array<f32>;

@binding(21) @group(3) var gs_wgpu_samp_wall_color_data_brick_colors : sampler;

var<private> v1 : vec3<f32>;

var<private> v11 : vec2<f32>;

var<private> v13 : u32;

@binding(22) @group(3) var gs_wgpu_tex_wooden_wall_colors_tex : texture_2d_array<f32>;

@binding(23) @group(3) var gs_wgpu_samp_wooden_wall_colors_tex : sampler;

@binding(24) @group(3) var gs_wgpu_tex_halftimber_colors_tex : texture_2d_array<f32>;

@binding(25) @group(3) var gs_wgpu_samp_halftimber_colors_tex : sampler;

var<private> residentColor : vec4<f32>;

const x_787 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_940 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_1108 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_1109 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_6459 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_1330 = vec3<f32>(289.0f, 289.0f, 289.0f);

fn main_1() {
  var x_1910 : bool;
  var x_6070 : bool;
  var x_1918 : bool;
  var x_6071 : bool;
  var x_1960 : vec3<f32>;
  var x_6208 : vec3<f32>;
  var x_6209 : vec3<f32>;
  var x_6333 : vec3<f32>;
  var x_2280 : bool;
  var x_6448 : bool;
  var x_6365 : vec3<f32>;
  var x_2288 : vec3<f32>;
  var x_6368 : vec3<f32>;
  var x_6369 : vec3<f32>;
  var x_6404 : vec3<f32>;
  var x_2521 : vec3<f32>;
  var x_6439 : vec3<f32>;
  let x_1640 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ColorLibraryData_natural, 0i));
  let x_1645 : i32 = x_1640.x;
  let x_1652 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((28i % x_1645), (28i / x_1645)), 0i);
  let x_1664 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((30i % x_1645), (30i / x_1645)), 0i);
  let x_1676 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((31i % x_1645), (31i / x_1645)), 0i);
  let x_1689 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1652.x), bitcast<f32>(x_1652.y), bitcast<f32>(x_1652.z), 0.0f);
  let x_1703 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1664.x), bitcast<f32>(x_1664.y), bitcast<f32>(x_1664.z), 0.0f);
  let x_1717 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1676.x), bitcast<f32>(x_1676.y), bitcast<f32>(x_1676.z), 0.0f);
  let x_1729 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_1734 : i32 = x_1729.x;
  let x_1741 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_1734), (8i / x_1734)), 0i);
  let x_1753 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_1734), (17i / x_1734)), 0i);
  let x_1765 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_1734), (18i / x_1734)), 0i);
  let x_1777 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_1734), (19i / x_1734)), 0i);
  let x_1779 : u32 = x_1741.w;
  let x_1790 : vec3<f32> = vec3<f32>(bitcast<f32>(x_1753.x), 0.0f, bitcast<f32>(x_1753.z));
  let x_1794 : f32 = bitcast<f32>(x_1753.w);
  let x_1797 : u32 = x_1765.w;
  let x_1800 : u32 = x_1777.x;
  let x_1889 : f32 = v2.y;
  let x_1890 : f32 = v8;
  if ((x_1889 < x_1890)) {
    discard;
  }
  let x_1894 : i32 = v12;
  let x_1896 : bool = ((x_1894 & 8i) != 0i);
  let x_1899 : bool = ((x_1894 & 16i) != 0i);
  let x_1902 : bool = ((x_1894 & 2048i) != 0i);
  let x_1905 : bool = ((x_1894 & 256i) != 0i);
  if (!(x_1896)) {
    let x_1909 : f32 = v7;
    x_1910 = (x_1909 > -2.5f);
    x_6070 = x_1910;
  } else {
    x_6070 = false;
  }
  if (x_6070) {
    let x_1917 : f32 = v7;
    x_1918 = (x_1889 < x_1917);
    x_6071 = x_1918;
  } else {
    x_6071 = false;
  }
  var x_1929 : bool;
  var x_6074 : bool;
  if (x_6071) {
    discard;
  } else {
    if (x_1896) {
      let x_1928 : f32 = v7;
      x_1929 = (x_1889 > x_1928);
      x_6074 = x_1929;
    } else {
      x_6074 = false;
    }
    if (x_6074) {
      discard;
    }
  }
  var x_1936 : i32;
  var x_1937 : u32;
  var x_1965 : vec2<f32>;
  var x_1967 : vec2<f32>;
  var x_6118 : vec2<f32>;
  var x_1974 : bool;
  var x_6079 : bool;
  var x_1981 : vec3<f32>;
  var x_1987 : vec3<f32>;
  var x_6147 : vec3<f32>;
  var x_1996 : bool;
  var x_6092 : bool;
  var x_2002 : bool;
  var x_6094 : bool;
  var x_2008 : bool;
  var x_6096 : bool;
  var x_2021 : vec3<f32>;
  var x_6122 : vec3<f32>;
  var x_6140 : vec3<f32>;
  var x_2122 : bool;
  var x_6136 : bool;
  var x_2128 : bool;
  var x_6157 : bool;
  var x_2169 : vec3<f32>;
  var x_6177 : vec3<f32>;
  var x_2216 : vec3<f32>;
  x_1936 = v10;
  x_1937 = bitcast<u32>(x_1936);
  if (((x_1894 & 2i) != 0i)) {
    let x_1945 : u32 = v0;
    let x_1949 : vec3<f32> = v2;
    let x_1952 : vec2<f32> = ((vec2<f32>(vec2<u32>(x_1945, x_1945)) * 0.20000000298023223877f) + (vec2<f32>(x_1949.x, x_1949.z) * 0.20000000298023223877f));
    let x_1958 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_1952.x, x_1952.y, f32(x_1937)).xy, i32(round(vec3<f32>(x_1952.x, x_1952.y, f32(x_1937)).z)));
    x_1960 = (vec3<f32>(x_1958.x, x_1958.y, x_1958.z) * 0.69999998807907104492f);
    x_6209 = x_1960;
  } else {
    if (x_1905) {
      let x_1964 : vec2<f32> = v9;
      x_1965 = (x_1964 + vec2<f32>(0.20999999344348907471f, 0.20999999344348907471f));
      x_6118 = x_1965;
    } else {
      x_1967 = v9;
      x_6118 = x_1967;
    }
    if ((x_1937 == 1u)) {
      x_6079 = true;
    } else {
      x_1974 = (x_1937 == 0u);
      x_6079 = x_1974;
    }
    if (x_6079) {
      x_1981 = pow(vec3<f32>(x_1717.x, x_1717.y, x_1717.z), vec3<f32>(1.29999995231628417969f, 1.29999995231628417969f, 1.29999995231628417969f));
      x_6147 = x_1981;
    } else {
      x_1987 = (pow(vec3<f32>(x_1703.x, x_1703.y, x_1703.z), x_787) * 0.80000001192092895508f);
      x_6147 = x_1987;
    }
    if ((x_1936 == 0i)) {
      x_6092 = true;
    } else {
      x_1996 = (x_1936 == 4i);
      x_6092 = x_1996;
    }
    if (x_6092) {
      x_6094 = true;
    } else {
      x_2002 = (x_1936 == 10i);
      x_6094 = x_2002;
    }
    if (x_6094) {
      x_6096 = true;
    } else {
      x_2008 = (x_1936 == 12i);
      x_6096 = x_2008;
    }
    var x_2028 : bool;
    var x_6098 : bool;
    var x_2042 : vec3<f32>;
    var x_6121 : vec3<f32>;
    if (x_6096) {
      let x_2016 : vec2<f32> = (x_6118 + vec2<f32>(0.85000002384185791016f, 0.85000002384185791016f));
      let x_2020 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2016.x, x_2016.y, 0.0f).xy, i32(round(vec3<f32>(x_2016.x, x_2016.y, 0.0f).z)));
      x_2021 = vec3<f32>(x_2020.x, x_2020.y, x_2020.z);
      x_6140 = x_2021;
    } else {
      if ((x_1936 == 1i)) {
        x_6098 = true;
      } else {
        x_2028 = (x_1936 == 5i);
        x_6098 = x_2028;
      }
      var x_2049 : bool;
      var x_6100 : bool;
      var x_2061 : vec3<f32>;
      var x_6120 : vec3<f32>;
      if (x_6098) {
        let x_2036 : vec2<f32> = (x_6118 + vec2<f32>(0.44999998807907104492f, 0.44999998807907104492f));
        let x_2040 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2036.x, x_2036.y, 1.0f).xy, i32(round(vec3<f32>(x_2036.x, x_2036.y, 1.0f).z)));
        x_2042 = pow(vec3<f32>(x_2040.x, x_2040.y, x_2040.z), vec3<f32>(1.10000002384185791016f, 1.10000002384185791016f, 1.10000002384185791016f));
        x_6122 = x_2042;
      } else {
        if ((x_1936 == 2i)) {
          x_6100 = true;
        } else {
          x_2049 = (x_1936 == 7i);
          x_6100 = x_2049;
        }
        var x_2068 : bool;
        var x_6102 : bool;
        var x_2074 : bool;
        var x_6104 : bool;
        var x_2080 : bool;
        var x_6106 : bool;
        var x_2092 : vec3<f32>;
        var x_6119 : vec3<f32>;
        if (x_6100) {
          let x_2060 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_6118.x, x_6118.y, 2.0f).xy, i32(round(vec3<f32>(x_6118.x, x_6118.y, 2.0f).z)));
          x_2061 = vec3<f32>(x_2060.x, x_2060.y, x_2060.z);
          x_6121 = x_2061;
        } else {
          if ((x_1936 == 3i)) {
            x_6102 = true;
          } else {
            x_2068 = (x_1936 == 6i);
            x_6102 = x_2068;
          }
          if (x_6102) {
            x_6104 = true;
          } else {
            x_2074 = (x_1936 == 8i);
            x_6104 = x_2074;
          }
          if (x_6104) {
            x_6106 = true;
          } else {
            x_2080 = (x_1936 == 9i);
            x_6106 = x_2080;
          }
          var x_2105 : vec3<f32>;
          if (x_6106) {
            let x_2091 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_6118.x, x_6118.y, 3.0f).xy, i32(round(vec3<f32>(x_6118.x, x_6118.y, 3.0f).z)));
            x_2092 = vec3<f32>(x_2091.x, x_2091.y, x_2091.z);
            x_6120 = x_2092;
          } else {
            if ((x_1936 == 11i)) {
              let x_2104 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_6118.x, x_6118.y, 4.0f).xy, i32(round(vec3<f32>(x_6118.x, x_6118.y, 4.0f).z)));
              x_2105 = vec3<f32>(x_2104.x, x_2104.y, x_2104.z);
              x_6119 = x_2105;
            } else {
              x_6119 = x_940;
            }
            x_6120 = x_6119;
          }
          x_6121 = x_6120;
        }
        x_6122 = x_6121;
      }
      x_6140 = x_6122;
    }
    let x_2117 : bool = (x_1937 == 7u);
    if (x_2117) {
      x_6136 = true;
    } else {
      x_2122 = (x_1937 == 2u);
      x_6136 = x_2122;
    }
    if (x_6136) {
      x_6157 = true;
    } else {
      x_2128 = (x_1937 == 11u);
      x_6157 = x_2128;
    }
    if (((x_1894 & 512i) != 0i)) {
      let x_2134 : u32 = v0;
      let x_2135 : u32 = (x_2134 ^ 8902390u);
      let x_2139 : u32 = (x_2135 + (x_2135 << 10u));
      let x_2143 : u32 = (x_2139 ^ (x_2139 >> 6u));
      let x_2147 : u32 = (x_2143 + (x_2143 << 3u));
      let x_2151 : u32 = (x_2147 ^ (x_2147 >> 11u));
      let x_2167 : f32 = mix(0.0f, 0.5f, smoothstep(0.20000000298023223877f, 0.80000001192092895508f, (bitcast<f32>((((x_2151 + (x_2151 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_2169 = mix(x_6140, select(x_6147, x_6140, vec3<bool>(x_6157, x_6157, x_6157)), vec3<f32>(x_2167, x_2167, x_2167));
      x_6177 = x_2169;
    } else {
      x_6177 = x_6140;
    }
    var x_2179 : bool;
    var x_6207 : bool;
    if (x_1905) {
      if (x_2117) {
        x_6207 = true;
      } else {
        x_2179 = (x_1937 == 2u);
        x_6207 = x_2179;
      }
      let x_2181 : u32 = v0;
      let x_2182 : u32 = (x_2181 ^ 239085u);
      let x_2186 : u32 = (x_2182 + (x_2182 << 10u));
      let x_2190 : u32 = (x_2186 ^ (x_2186 >> 6u));
      let x_2194 : u32 = (x_2190 + (x_2190 << 3u));
      let x_2198 : u32 = (x_2194 ^ (x_2194 >> 11u));
      let x_2214 : f32 = mix(0.0f, select(0.40000000596046447754f, 0.20000000298023223877f, x_6207), smoothstep(0.0f, 0.80000001192092895508f, (bitcast<f32>((((x_2198 + (x_2198 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_2216 = mix(x_6177, vec3<f32>(x_1689.x, x_1689.y, x_1689.z), vec3<f32>(x_2214, x_2214, x_2214));
      x_6208 = x_2216;
    } else {
      x_6208 = x_6177;
    }
    x_6209 = x_6208;
  }
  var x_2241 : vec3<f32>;
  var x_2244 : bool;
  var x_6238 : vec3<f32>;
  var x_6332 : bool;
  var x_6325 : vec3<f32>;
  var x_2268 : bool;
  var x_6323 : bool;
  var x_2274 : vec3<f32>;
  let x_2222 : vec3<f32> = v1;
  let x_2223 : vec3<f32> = normalize(x_2222);
  if (((x_1894 & 64i) == 0i)) {
    var x_6477 : u32;
    var x_2248 : vec3<f32>;
    x_6477 = select(0u, x_1797, ((x_1894 & 4096i) != 0i));
    if ((x_6477 == 1u)) {
      x_2241 = mix(x_6209, x_1108, x_1109);
      x_6332 = true;
      x_6325 = x_2241;
    } else {
      x_2244 = (x_6477 == 2u);
      if (x_2244) {
        x_2248 = mix(x_6209, x_1109, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_6238 = x_2248;
      } else {
        x_6238 = x_6209;
      }
      x_6332 = x_2244;
      x_6325 = x_6238;
    }
    if ((x_1800 == 1u)) {
      let x_2263 : vec2<f32> = v11;
      x_2268 = (distance(vec2<f32>(x_1790.x, x_1790.z), x_2263) < (1.88900005817413330078f * x_1794));
      x_6323 = x_2268;
    } else {
      x_6323 = false;
    }
    if (x_6323) {
      x_2274 = mix(x_6209, x_1108, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_6333 = x_2274;
    } else {
      x_6333 = x_6325;
    }
    x_2280 = select(x_6332, true, x_6323);
    x_6448 = x_2280;
    x_6365 = x_6333;
  } else {
    x_6448 = false;
    x_6365 = x_6209;
  }
  if (x_1902) {
    x_2288 = mix(x_6209, x_1108, x_1109);
    x_6368 = x_2288;
  } else {
    x_6368 = x_6365;
  }
  var x_2322 : vec3<f32>;
  var x_2341 : vec3<f32>;
  if (((x_1894 & 1024i) != 0i)) {
    let x_2298 : u32 = v13;
    let x_2755 : i32 = (bitcast<i32>(x_2298) * 32i);
    let x_2756 : i32 = (x_2755 + 15i);
    let x_3266 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_3271 : i32 = (x_2756 / 4i);
    let x_3273 : i32 = x_3266.x;
    let x_3282 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_3271 % x_3273), (x_3271 / x_3273)), 0i);
    if (((x_3282[(x_2756 % 4i)] & 2u) != 0u)) {
      let x_2308 : vec2<f32> = v9;
      let x_3871 : i32 = (x_2755 + 13i);
      let x_4339 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_4344 : i32 = (x_3871 / 4i);
      let x_4346 : i32 = x_4339.x;
      let x_4355 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_4344 % x_4346), (x_4344 / x_4346)), 0i);
      let x_2314 : i32 = bitcast<i32>(x_4355[(x_3871 % 4i)]);
      let x_4859 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_21_0, 0i));
      let x_4864 : i32 = (x_2314 / 4i);
      let x_4866 : i32 = x_4859.x;
      let x_4875 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_21_0, vec2<i32>((x_4864 % x_4866), (x_4864 / x_4866)), 0i);
      let x_2321 : vec4<f32> = textureSample(gs_wgpu_tex_wooden_wall_colors_tex, gs_wgpu_samp_wooden_wall_colors_tex, vec3<f32>(x_2308.x, x_2308.y, f32(bitcast<i32>(x_4875[(x_2314 % 4i)]))).xy, i32(round(vec3<f32>(x_2308.x, x_2308.y, f32(bitcast<i32>(x_4875[(x_2314 % 4i)]))).z)));
      x_2322 = vec3<f32>(x_2321.x, x_2321.y, x_2321.z);
      x_6369 = x_2322;
    } else {
      let x_2327 : vec2<f32> = v9;
      let x_5032 : i32 = (x_2755 + 13i);
      let x_5500 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_5505 : i32 = (x_5032 / 4i);
      let x_5507 : i32 = x_5500.x;
      let x_5516 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5505 % x_5507), (x_5505 / x_5507)), 0i);
      let x_2333 : i32 = bitcast<i32>(x_5516[(x_5032 % 4i)]);
      let x_6020 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_20_0, 0i));
      let x_6025 : i32 = (x_2333 / 4i);
      let x_6027 : i32 = x_6020.x;
      let x_6036 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_20_0, vec2<i32>((x_6025 % x_6027), (x_6025 / x_6027)), 0i);
      let x_2340 : vec4<f32> = textureSample(gs_wgpu_tex_halftimber_colors_tex, gs_wgpu_samp_halftimber_colors_tex, vec3<f32>(x_2327.x, x_2327.y, f32(bitcast<i32>(x_6036[(x_2333 % 4i)]))).xy, i32(round(vec3<f32>(x_2327.x, x_2327.y, f32(bitcast<i32>(x_6036[(x_2333 % 4i)]))).z)));
      x_2341 = vec3<f32>(x_2340.x, x_2340.y, x_2340.z);
      x_6369 = x_2341;
    }
    x_6404 = x_6369;
  } else {
    x_6404 = x_6368;
  }
  if ((x_1779 == 4u)) {
    let x_2351 : vec3<f32> = v2;
    let x_2353 : vec2<f32> = (vec2<f32>(x_2351.x, x_2351.z) * 0.40000000596046447754f);
    let x_2356 : f32 = dot(x_2353, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
    let x_2359 : vec2<f32> = floor((x_2353 + vec2<f32>(x_2356, x_2356)));
    let x_2364 : f32 = dot(x_2359, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
    let x_2366 : vec2<f32> = ((x_2353 - x_2359) + vec2<f32>(x_2364, x_2364));
    let x_2368 : f32 = x_2366.x;
    let x_2370 : f32 = x_2366.y;
    let x_2373 : bool = (x_2368 > x_2370);
    let x_2375 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_2373, x_2373));
    let x_2378 : vec4<f32> = (vec4<f32>(x_2366.x, x_2366.y, x_2366.x, x_2366.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
    let x_2382 : vec2<f32> = (vec2<f32>(x_2378.x, x_2378.y) - x_2375);
    var x_6525_1 : vec4<f32> = x_2378;
    x_6525_1.x = x_2382.x;
    let x_6525 : vec4<f32> = x_6525_1;
    var x_6528_1 : vec4<f32> = x_6525;
    x_6528_1.y = x_2382.y;
    let x_6528 : vec4<f32> = x_6528_1;
    let x_2395 : vec2<f32> = (x_2359 - (vec2<f32>(289.0f, 289.0f) * trunc((x_2359 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
    let x_2397 : f32 = x_2395.y;
    let x_2402 : vec3<f32> = (vec3<f32>(x_2397, x_2397, x_2397) + vec3<f32>(0.0f, x_2375.y, 1.0f));
    let x_2407 : vec3<f32> = (((x_2402 * 34.0f) + x_787) * x_2402);
    let x_2415 : f32 = x_2395.x;
    let x_2421 : vec3<f32> = (((x_2407 - (x_1330 * trunc((x_2407 * x_6459)))) + vec3<f32>(x_2415, x_2415, x_2415)) + vec3<f32>(0.0f, x_2375.x, 1.0f));
    let x_2426 : vec3<f32> = (((x_2421 * 34.0f) + x_787) * x_2421);
    let x_2431 : vec2<f32> = vec2<f32>(x_6528.x, x_6528.y);
    let x_2436 : vec2<f32> = vec2<f32>(x_6528.z, x_6528.w);
    let x_2442 : vec3<f32> = max((x_1109 - vec3<f32>(dot(x_2366, x_2366), dot(x_2431, x_2431), dot(x_2436, x_2436))), x_940);
    let x_2445 : vec3<f32> = (x_2442 * x_2442);
    let x_2454 : vec3<f32> = (fract(((x_2426 - (x_1330 * trunc((x_2426 * x_6459)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
    let x_2456 : vec3<f32> = (x_2454 - x_787);
    let x_2459 : vec3<f32> = (abs(x_2456) - x_1109);
    let x_2464 : vec3<f32> = (x_2456 - floor((x_2454 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
    let x_2506 : vec2<f32> = ((vec2<f32>(x_2464.y, x_2464.z) * vec2<f32>(x_6528.x, x_6528.z)) + (vec2<f32>(x_2459.y, x_2459.z) * vec2<f32>(x_6528.y, x_6528.w)));
    let x_2519 : f32 = (smoothstep(0.0f, 1.0f, (smoothstep(-0.10000000149011611938f, 0.0f, x_1889) * clamp(x_2223.y, 0.0f, 1.0f))) * clamp(clamp(((130.0f * dot(((x_2445 * x_2445) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_2464 * x_2464) + (x_2459 * x_2459)) * 0.85373473167419433594f))), vec3<f32>(((x_2464.x * x_2368) + (x_2459.x * x_2370)), x_2506.x, x_2506.y))) + 0.75f), 0.0f, 1.0f), select(0.40000000596046447754f, 0.0f, x_1899), select(1.0f, 0.10000000149011611938f, x_1899)));
    x_2521 = mix(x_6404, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_2519, x_2519, x_2519));
    x_6439 = x_2521;
  } else {
    x_6439 = x_6404;
  }
  let x_2530 : vec3<f32> = sqrt(clamp(x_6439, x_940, x_787));
  let x_2587 : u32 = (((u32(((clamp(x_2530.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_2530.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_2530.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(2264924160u, 2399141888u, select(x_6448, true, x_1902)));
  let x_1611 : vec3<f32> = vec3<f32>(f32((x_2587 & 255u)), f32(((x_2587 >> 8u) & 255u)), f32(((x_2587 >> 16u) & 255u)));
  let x_1616 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_1611 * x_1611));
  let x_1626 : vec3<f32> = select((x_1616 * 12.9200000762939453125f), ((pow(x_1616, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_1616 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_1626.x, x_1626.y, x_1626.z, 1.0f);
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
