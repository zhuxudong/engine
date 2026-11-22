diagnostic(off, derivative_uniformity);
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

var<private> residentColor : vec4<f32>;

const x_381 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_543 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_711 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_712 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_2452 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_865 = vec3<f32>(289.0f, 289.0f, 289.0f);

fn main_1() {
  var x_1438 : bool;
  var x_2079 : bool;
  var x_1446 : bool;
  var x_2080 : bool;
  var x_1488 : vec3<f32>;
  var x_2217 : vec3<f32>;
  var x_2218 : vec3<f32>;
  var x_2342 : vec3<f32>;
  var x_1808 : bool;
  var x_2447 : bool;
  var x_2374 : vec3<f32>;
  var x_1816 : vec3<f32>;
  var x_2409 : vec3<f32>;
  var x_1994 : vec3<f32>;
  var x_2442 : vec3<f32>;
  let x_1175 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ColorLibraryData_natural, 0i));
  let x_1180 : i32 = x_1175.x;
  let x_1187 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((28i % x_1180), (28i / x_1180)), 0i);
  let x_1199 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((30i % x_1180), (30i / x_1180)), 0i);
  let x_1211 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ColorLibraryData_natural, vec2<i32>((31i % x_1180), (31i / x_1180)), 0i);
  let x_1224 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1187.x), bitcast<f32>(x_1187.y), bitcast<f32>(x_1187.z), 0.0f);
  let x_1238 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1199.x), bitcast<f32>(x_1199.y), bitcast<f32>(x_1199.z), 0.0f);
  let x_1252 : vec4<f32> = vec4<f32>(bitcast<f32>(x_1211.x), bitcast<f32>(x_1211.y), bitcast<f32>(x_1211.z), 0.0f);
  let x_1264 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_1269 : i32 = x_1264.x;
  let x_1276 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_1269), (8i / x_1269)), 0i);
  let x_1288 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_1269), (17i / x_1269)), 0i);
  let x_1300 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_1269), (18i / x_1269)), 0i);
  let x_1312 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_1269), (19i / x_1269)), 0i);
  let x_1314 : u32 = x_1276.w;
  let x_1325 : vec3<f32> = vec3<f32>(bitcast<f32>(x_1288.x), 0.0f, bitcast<f32>(x_1288.z));
  let x_1329 : f32 = bitcast<f32>(x_1288.w);
  let x_1332 : u32 = x_1300.w;
  let x_1335 : u32 = x_1312.x;
  let x_1417 : f32 = v2.y;
  let x_1418 : f32 = v8;
  if ((x_1417 < x_1418)) {
    discard;
  }
  let x_1422 : i32 = v12;
  let x_1424 : bool = ((x_1422 & 8i) != 0i);
  let x_1427 : bool = ((x_1422 & 16i) != 0i);
  let x_1430 : bool = ((x_1422 & 2048i) != 0i);
  let x_1433 : bool = ((x_1422 & 256i) != 0i);
  if (!(x_1424)) {
    let x_1437 : f32 = v7;
    x_1438 = (x_1437 > -2.5f);
    x_2079 = x_1438;
  } else {
    x_2079 = false;
  }
  if (x_2079) {
    let x_1445 : f32 = v7;
    x_1446 = (x_1417 < x_1445);
    x_2080 = x_1446;
  } else {
    x_2080 = false;
  }
  var x_1457 : bool;
  var x_2083 : bool;
  if (x_2080) {
    discard;
  } else {
    if (x_1424) {
      let x_1456 : f32 = v7;
      x_1457 = (x_1417 > x_1456);
      x_2083 = x_1457;
    } else {
      x_2083 = false;
    }
    if (x_2083) {
      discard;
    }
  }
  var x_1464 : i32;
  var x_1465 : u32;
  var x_1493 : vec2<f32>;
  var x_1495 : vec2<f32>;
  var x_2127 : vec2<f32>;
  var x_1502 : bool;
  var x_2088 : bool;
  var x_1509 : vec3<f32>;
  var x_1515 : vec3<f32>;
  var x_2156 : vec3<f32>;
  var x_1524 : bool;
  var x_2101 : bool;
  var x_1530 : bool;
  var x_2103 : bool;
  var x_1536 : bool;
  var x_2105 : bool;
  var x_1549 : vec3<f32>;
  var x_2131 : vec3<f32>;
  var x_2149 : vec3<f32>;
  var x_1650 : bool;
  var x_2145 : bool;
  var x_1656 : bool;
  var x_2166 : bool;
  var x_1697 : vec3<f32>;
  var x_2186 : vec3<f32>;
  var x_1744 : vec3<f32>;
  x_1464 = v10;
  x_1465 = bitcast<u32>(x_1464);
  if (((x_1422 & 2i) != 0i)) {
    let x_1473 : u32 = v0;
    let x_1477 : vec3<f32> = v2;
    let x_1480 : vec2<f32> = ((vec2<f32>(vec2<u32>(x_1473, x_1473)) * 0.20000000298023223877f) + (vec2<f32>(x_1477.x, x_1477.z) * 0.20000000298023223877f));
    let x_1486 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_1480.x, x_1480.y, f32(x_1465)).xy, i32(round(vec3<f32>(x_1480.x, x_1480.y, f32(x_1465)).z)));
    x_1488 = (vec3<f32>(x_1486.x, x_1486.y, x_1486.z) * 0.69999998807907104492f);
    x_2218 = x_1488;
  } else {
    if (x_1433) {
      let x_1492 : vec2<f32> = v9;
      x_1493 = (x_1492 + vec2<f32>(0.20999999344348907471f, 0.20999999344348907471f));
      x_2127 = x_1493;
    } else {
      x_1495 = v9;
      x_2127 = x_1495;
    }
    if ((x_1465 == 1u)) {
      x_2088 = true;
    } else {
      x_1502 = (x_1465 == 0u);
      x_2088 = x_1502;
    }
    if (x_2088) {
      x_1509 = pow(vec3<f32>(x_1252.x, x_1252.y, x_1252.z), vec3<f32>(1.29999995231628417969f, 1.29999995231628417969f, 1.29999995231628417969f));
      x_2156 = x_1509;
    } else {
      x_1515 = (pow(vec3<f32>(x_1238.x, x_1238.y, x_1238.z), x_381) * 0.80000001192092895508f);
      x_2156 = x_1515;
    }
    if ((x_1464 == 0i)) {
      x_2101 = true;
    } else {
      x_1524 = (x_1464 == 4i);
      x_2101 = x_1524;
    }
    if (x_2101) {
      x_2103 = true;
    } else {
      x_1530 = (x_1464 == 10i);
      x_2103 = x_1530;
    }
    if (x_2103) {
      x_2105 = true;
    } else {
      x_1536 = (x_1464 == 12i);
      x_2105 = x_1536;
    }
    var x_1556 : bool;
    var x_2107 : bool;
    var x_1570 : vec3<f32>;
    var x_2130 : vec3<f32>;
    if (x_2105) {
      let x_1544 : vec2<f32> = (x_2127 + vec2<f32>(0.85000002384185791016f, 0.85000002384185791016f));
      let x_1548 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_1544.x, x_1544.y, 0.0f).xy, i32(round(vec3<f32>(x_1544.x, x_1544.y, 0.0f).z)));
      x_1549 = vec3<f32>(x_1548.x, x_1548.y, x_1548.z);
      x_2149 = x_1549;
    } else {
      if ((x_1464 == 1i)) {
        x_2107 = true;
      } else {
        x_1556 = (x_1464 == 5i);
        x_2107 = x_1556;
      }
      var x_1577 : bool;
      var x_2109 : bool;
      var x_1589 : vec3<f32>;
      var x_2129 : vec3<f32>;
      if (x_2107) {
        let x_1564 : vec2<f32> = (x_2127 + vec2<f32>(0.44999998807907104492f, 0.44999998807907104492f));
        let x_1568 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_1564.x, x_1564.y, 1.0f).xy, i32(round(vec3<f32>(x_1564.x, x_1564.y, 1.0f).z)));
        x_1570 = pow(vec3<f32>(x_1568.x, x_1568.y, x_1568.z), vec3<f32>(1.10000002384185791016f, 1.10000002384185791016f, 1.10000002384185791016f));
        x_2131 = x_1570;
      } else {
        if ((x_1464 == 2i)) {
          x_2109 = true;
        } else {
          x_1577 = (x_1464 == 7i);
          x_2109 = x_1577;
        }
        var x_1596 : bool;
        var x_2111 : bool;
        var x_1602 : bool;
        var x_2113 : bool;
        var x_1608 : bool;
        var x_2115 : bool;
        var x_1620 : vec3<f32>;
        var x_2128 : vec3<f32>;
        if (x_2109) {
          let x_1588 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2127.x, x_2127.y, 2.0f).xy, i32(round(vec3<f32>(x_2127.x, x_2127.y, 2.0f).z)));
          x_1589 = vec3<f32>(x_1588.x, x_1588.y, x_1588.z);
          x_2130 = x_1589;
        } else {
          if ((x_1464 == 3i)) {
            x_2111 = true;
          } else {
            x_1596 = (x_1464 == 6i);
            x_2111 = x_1596;
          }
          if (x_2111) {
            x_2113 = true;
          } else {
            x_1602 = (x_1464 == 8i);
            x_2113 = x_1602;
          }
          if (x_2113) {
            x_2115 = true;
          } else {
            x_1608 = (x_1464 == 9i);
            x_2115 = x_1608;
          }
          var x_1633 : vec3<f32>;
          if (x_2115) {
            let x_1619 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2127.x, x_2127.y, 3.0f).xy, i32(round(vec3<f32>(x_2127.x, x_2127.y, 3.0f).z)));
            x_1620 = vec3<f32>(x_1619.x, x_1619.y, x_1619.z);
            x_2129 = x_1620;
          } else {
            if ((x_1464 == 11i)) {
              let x_1632 : vec4<f32> = textureSample(gs_wgpu_tex_wall_color_data_brick_colors, gs_wgpu_samp_wall_color_data_brick_colors, vec3<f32>(x_2127.x, x_2127.y, 4.0f).xy, i32(round(vec3<f32>(x_2127.x, x_2127.y, 4.0f).z)));
              x_1633 = vec3<f32>(x_1632.x, x_1632.y, x_1632.z);
              x_2128 = x_1633;
            } else {
              x_2128 = x_543;
            }
            x_2129 = x_2128;
          }
          x_2130 = x_2129;
        }
        x_2131 = x_2130;
      }
      x_2149 = x_2131;
    }
    let x_1645 : bool = (x_1465 == 7u);
    if (x_1645) {
      x_2145 = true;
    } else {
      x_1650 = (x_1465 == 2u);
      x_2145 = x_1650;
    }
    if (x_2145) {
      x_2166 = true;
    } else {
      x_1656 = (x_1465 == 11u);
      x_2166 = x_1656;
    }
    if (((x_1422 & 512i) != 0i)) {
      let x_1662 : u32 = v0;
      let x_1663 : u32 = (x_1662 ^ 8902390u);
      let x_1667 : u32 = (x_1663 + (x_1663 << 10u));
      let x_1671 : u32 = (x_1667 ^ (x_1667 >> 6u));
      let x_1675 : u32 = (x_1671 + (x_1671 << 3u));
      let x_1679 : u32 = (x_1675 ^ (x_1675 >> 11u));
      let x_1695 : f32 = mix(0.0f, 0.5f, smoothstep(0.20000000298023223877f, 0.80000001192092895508f, (bitcast<f32>((((x_1679 + (x_1679 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_1697 = mix(x_2149, select(x_2156, x_2149, vec3<bool>(x_2166, x_2166, x_2166)), vec3<f32>(x_1695, x_1695, x_1695));
      x_2186 = x_1697;
    } else {
      x_2186 = x_2149;
    }
    var x_1707 : bool;
    var x_2216 : bool;
    if (x_1433) {
      if (x_1645) {
        x_2216 = true;
      } else {
        x_1707 = (x_1465 == 2u);
        x_2216 = x_1707;
      }
      let x_1709 : u32 = v0;
      let x_1710 : u32 = (x_1709 ^ 239085u);
      let x_1714 : u32 = (x_1710 + (x_1710 << 10u));
      let x_1718 : u32 = (x_1714 ^ (x_1714 >> 6u));
      let x_1722 : u32 = (x_1718 + (x_1718 << 3u));
      let x_1726 : u32 = (x_1722 ^ (x_1722 >> 11u));
      let x_1742 : f32 = mix(0.0f, select(0.40000000596046447754f, 0.20000000298023223877f, x_2216), smoothstep(0.0f, 0.80000001192092895508f, (bitcast<f32>((((x_1726 + (x_1726 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
      x_1744 = mix(x_2186, vec3<f32>(x_1224.x, x_1224.y, x_1224.z), vec3<f32>(x_1742, x_1742, x_1742));
      x_2217 = x_1744;
    } else {
      x_2217 = x_2186;
    }
    x_2218 = x_2217;
  }
  var x_1769 : vec3<f32>;
  var x_1772 : bool;
  var x_2247 : vec3<f32>;
  var x_2341 : bool;
  var x_2334 : vec3<f32>;
  var x_1796 : bool;
  var x_2332 : bool;
  var x_1802 : vec3<f32>;
  let x_1750 : vec3<f32> = v1;
  let x_1751 : vec3<f32> = normalize(x_1750);
  if (((x_1422 & 64i) == 0i)) {
    var x_2470 : u32;
    var x_1776 : vec3<f32>;
    x_2470 = select(0u, x_1332, ((x_1422 & 4096i) != 0i));
    if ((x_2470 == 1u)) {
      x_1769 = mix(x_2218, x_711, x_712);
      x_2341 = true;
      x_2334 = x_1769;
    } else {
      x_1772 = (x_2470 == 2u);
      if (x_1772) {
        x_1776 = mix(x_2218, x_712, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_2247 = x_1776;
      } else {
        x_2247 = x_2218;
      }
      x_2341 = x_1772;
      x_2334 = x_2247;
    }
    if ((x_1335 == 1u)) {
      let x_1791 : vec2<f32> = v11;
      x_1796 = (distance(vec2<f32>(x_1325.x, x_1325.z), x_1791) < (1.88900005817413330078f * x_1329));
      x_2332 = x_1796;
    } else {
      x_2332 = false;
    }
    if (x_2332) {
      x_1802 = mix(x_2218, x_711, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_2342 = x_1802;
    } else {
      x_2342 = x_2334;
    }
    x_1808 = select(x_2341, true, x_2332);
    x_2447 = x_1808;
    x_2374 = x_2342;
  } else {
    x_2447 = false;
    x_2374 = x_2218;
  }
  if (x_1430) {
    x_1816 = mix(x_2218, x_711, x_712);
    x_2409 = x_1816;
  } else {
    x_2409 = x_2374;
  }
  if ((x_1314 == 4u)) {
    let x_1824 : vec3<f32> = v2;
    let x_1826 : vec2<f32> = (vec2<f32>(x_1824.x, x_1824.z) * 0.40000000596046447754f);
    let x_1829 : f32 = dot(x_1826, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
    let x_1832 : vec2<f32> = floor((x_1826 + vec2<f32>(x_1829, x_1829)));
    let x_1837 : f32 = dot(x_1832, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
    let x_1839 : vec2<f32> = ((x_1826 - x_1832) + vec2<f32>(x_1837, x_1837));
    let x_1841 : f32 = x_1839.x;
    let x_1843 : f32 = x_1839.y;
    let x_1846 : bool = (x_1841 > x_1843);
    let x_1848 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_1846, x_1846));
    let x_1851 : vec4<f32> = (vec4<f32>(x_1839.x, x_1839.y, x_1839.x, x_1839.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
    let x_1855 : vec2<f32> = (vec2<f32>(x_1851.x, x_1851.y) - x_1848);
    var x_2508_1 : vec4<f32> = x_1851;
    x_2508_1.x = x_1855.x;
    let x_2508 : vec4<f32> = x_2508_1;
    var x_2511_1 : vec4<f32> = x_2508;
    x_2511_1.y = x_1855.y;
    let x_2511 : vec4<f32> = x_2511_1;
    let x_1868 : vec2<f32> = (x_1832 - (vec2<f32>(289.0f, 289.0f) * trunc((x_1832 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
    let x_1870 : f32 = x_1868.y;
    let x_1875 : vec3<f32> = (vec3<f32>(x_1870, x_1870, x_1870) + vec3<f32>(0.0f, x_1848.y, 1.0f));
    let x_1880 : vec3<f32> = (((x_1875 * 34.0f) + x_381) * x_1875);
    let x_1888 : f32 = x_1868.x;
    let x_1894 : vec3<f32> = (((x_1880 - (x_865 * trunc((x_1880 * x_2452)))) + vec3<f32>(x_1888, x_1888, x_1888)) + vec3<f32>(0.0f, x_1848.x, 1.0f));
    let x_1899 : vec3<f32> = (((x_1894 * 34.0f) + x_381) * x_1894);
    let x_1904 : vec2<f32> = vec2<f32>(x_2511.x, x_2511.y);
    let x_1909 : vec2<f32> = vec2<f32>(x_2511.z, x_2511.w);
    let x_1915 : vec3<f32> = max((x_712 - vec3<f32>(dot(x_1839, x_1839), dot(x_1904, x_1904), dot(x_1909, x_1909))), x_543);
    let x_1918 : vec3<f32> = (x_1915 * x_1915);
    let x_1927 : vec3<f32> = (fract(((x_1899 - (x_865 * trunc((x_1899 * x_2452)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
    let x_1929 : vec3<f32> = (x_1927 - x_381);
    let x_1932 : vec3<f32> = (abs(x_1929) - x_712);
    let x_1937 : vec3<f32> = (x_1929 - floor((x_1927 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
    let x_1979 : vec2<f32> = ((vec2<f32>(x_1937.y, x_1937.z) * vec2<f32>(x_2511.x, x_2511.z)) + (vec2<f32>(x_1932.y, x_1932.z) * vec2<f32>(x_2511.y, x_2511.w)));
    let x_1992 : f32 = (smoothstep(0.0f, 1.0f, (smoothstep(-0.10000000149011611938f, 0.0f, x_1417) * clamp(x_1751.y, 0.0f, 1.0f))) * clamp(clamp(((130.0f * dot(((x_1918 * x_1918) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_1937 * x_1937) + (x_1932 * x_1932)) * 0.85373473167419433594f))), vec3<f32>(((x_1937.x * x_1841) + (x_1932.x * x_1843)), x_1979.x, x_1979.y))) + 0.75f), 0.0f, 1.0f), select(0.40000000596046447754f, 0.0f, x_1427), select(1.0f, 0.10000000149011611938f, x_1427)));
    x_1994 = mix(x_2409, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_1992, x_1992, x_1992));
    x_2442 = x_1994;
  } else {
    x_2442 = x_2409;
  }
  let x_2003 : vec3<f32> = sqrt(clamp(x_2442, x_543, x_381));
  let x_2060 : u32 = (((u32(((clamp(x_2003.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_2003.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_2003.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(2264924160u, 2399141888u, select(x_2447, true, x_1430)));
  let x_1146 : vec3<f32> = vec3<f32>(f32((x_2060 & 255u)), f32(((x_2060 >> 8u) & 255u)), f32(((x_2060 >> 16u) & 255u)));
  let x_1151 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_1146 * x_1146));
  let x_1161 : vec3<f32> = select((x_1151 * 12.9200000762939453125f), ((pow(x_1151, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_1151 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_1161.x, x_1161.y, x_1161.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(2) v2_param : vec3<f32>, @location(4) @interpolate(flat) v8_param : f32, @location(8) @interpolate(flat) v12_param : i32, @location(3) v7_param : f32, @location(6) @interpolate(flat) v10_param : i32, @location(0) @interpolate(flat) v0_param : u32, @location(5) v9_param : vec2<f32>, @location(1) v1_param : vec3<f32>, @location(7) @interpolate(flat) v11_param : vec2<f32>) -> main_out {
  v2 = v2_param;
  v8 = v8_param;
  v12 = v12_param;
  v7 = v7_param;
  v10 = v10_param;
  v0 = v0_param;
  v9 = v9_param;
  v1 = v1_param;
  v11 = v11_param;
  main_1();
  return main_out(residentColor);
}
