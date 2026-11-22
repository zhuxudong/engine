diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  @size(64)
  padding : u32,
  /* @offset(64) */
  renderer_DormerGrid : vec4<f32>,
}

@binding(8) @group(3) var gs_wgpu_tex_storage_9_0 : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_storage_9_0 : sampler;

@binding(10) @group(3) var gs_wgpu_tex_storage_8_0 : texture_2d<u32>;

@binding(11) @group(3) var gs_wgpu_samp_storage_8_0 : sampler;

@binding(4) @group(3) var gs_wgpu_tex_uniform_ViewConstants_natural : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_uniform_ViewConstants_natural : sampler;

@binding(6) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

var<private> v1 : vec3<f32>;

var<private> v0 : vec3<f32>;

var<private> v7 : vec2<f32>;

var<private> v12 : i32;

var<private> v8 : i32;

var<private> v11 : i32;

var<private> v6 : i32;

@binding(12) @group(3) var gs_wgpu_tex_wooden_wall_colors_tex : texture_2d_array<f32>;

@binding(13) @group(3) var gs_wgpu_samp_wooden_wall_colors_tex : sampler;

@binding(14) @group(3) var gs_wgpu_tex_halftimber_colors_tex : texture_2d_array<f32>;

@binding(15) @group(3) var gs_wgpu_samp_halftimber_colors_tex : sampler;

var<private> v5 : i32;

@binding(1) @group(2) var gs_wgpu_tex_material_data_wood_roughness : texture_2d<f32>;

@binding(2) @group(2) var gs_wgpu_samp_material_data_wood_roughness : sampler;

var<private> v10 : i32;

var<private> v13 : i32;

var<private> v9 : i32;

@binding(3) @group(2) var gs_wgpu_tex_material_data_dirtpath_heightmap : texture_2d<f32>;

@binding(4) @group(2) var gs_wgpu_samp_material_data_dirtpath_heightmap : sampler;

@binding(20) @group(3) var gs_wgpu_tex_domain_holes : texture_2d<u32>;

@binding(21) @group(3) var gs_wgpu_samp_domain_holes : sampler;

@binding(16) @group(3) var gs_wgpu_tex_domain_roof : texture_2d<u32>;

@binding(17) @group(3) var gs_wgpu_samp_domain_roof : sampler;

@binding(0) @group(2) var<uniform> x_868 : gs_Auto_0;

@binding(18) @group(3) var gs_wgpu_tex_domain_counts : texture_2d<u32>;

@binding(19) @group(3) var gs_wgpu_samp_domain_counts : sampler;

var<private> v2 : u32;

var<private> residentColor : vec4<f32>;

const x_713 = vec3<f32>(0.0f, 1.0f, 0.0f);

const x_449 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_451 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_552 = vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f);

fn main_1() {
  var x_1074 : u32;
  var x_2403 : u32;
  var x_2422 : bool;
  var x_2415 : bool;
  var x_2421 : bool;
  var x_2315 : u32;
  var x_2349 : u32;
  var x_2429 : u32;
  var x_2021 : i32;
  var x_2430 : i32;
  var x_2437 : i32;
  var x_2047 : vec3<f32>;
  var x_2062 : vec3<f32>;
  var x_2453 : vec3<f32>;
  var x_2527 : vec3<f32>;
  var x_2147 : bool;
  var x_2570 : bool;
  var x_2548 : vec3<f32>;
  var x_2157 : bool;
  var x_2546 : bool;
  var x_2563 : vec3<f32>;
  var x_2566 : vec3<f32>;
  let x_1121 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_1126 : i32 = x_1121.x;
  let x_1133 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_1126), (63i / x_1126)), 0i);
  let x_1136 : f32 = bitcast<f32>(x_1133.w);
  let x_1148 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_1153 : i32 = x_1148.x;
  let x_1160 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_1153), (8i / x_1153)), 0i);
  let x_1172 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_1153), (17i / x_1153)), 0i);
  let x_1184 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_1153), (18i / x_1153)), 0i);
  let x_1196 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_1153), (19i / x_1153)), 0i);
  let x_1198 : u32 = x_1160.w;
  let x_1202 : f32 = bitcast<f32>(x_1172.x);
  let x_1208 : f32 = bitcast<f32>(x_1172.z);
  let x_1213 : f32 = bitcast<f32>(x_1172.w);
  let x_1216 : u32 = x_1184.z;
  let x_1219 : u32 = x_1184.w;
  let x_1222 : u32 = x_1196.x;
  x_1074 = v2;
  let x_1075 : vec3<f32> = v0;
  switch(0u) {
    default: {
      let x_1256 : i32 = (bitcast<i32>(x_1074) * 16i);
      let x_1258 : i32 = (x_1256 + 15i);
      let x_1375 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_roof, 0i));
      let x_1380 : i32 = (x_1258 / 4i);
      let x_1382 : i32 = x_1375.x;
      let x_1391 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_roof, vec2<i32>((x_1380 % x_1382), (x_1380 / x_1382)), 0i);
      if ((x_1391[(x_1258 % 4i)] == 0u)) {
        x_2421 = false;
        break;
      }
      let x_1264 : i32 = (x_1256 + 10i);
      let x_1402 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_roof, 0i));
      let x_1407 : i32 = (x_1264 / 4i);
      let x_1409 : i32 = x_1402.x;
      let x_1418 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_roof, vec2<i32>((x_1407 % x_1409), (x_1407 / x_1409)), 0i);
      let x_1421 : u32 = x_1418[(x_1264 % 4i)];
      let x_1269 : vec4<f32> = x_868.renderer_DormerGrid;
      let x_1277 : vec2<i32> = vec2<i32>(floor(((vec2<f32>(x_1075.x, x_1075.z) - vec2<f32>(x_1269.x, x_1269.y)) * vec2<f32>(x_1269.z, x_1269.w))));
      let x_1283 : i32 = (x_1277.x + (15i * x_1277.y));
      if (((x_1283 < 0i) | (x_1283 >= 225i))) {
        x_2421 = false;
        break;
      }
      let x_1429 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_counts, 0i));
      let x_1434 : i32 = (x_1283 / 4i);
      let x_1436 : i32 = x_1429.x;
      let x_1445 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_counts, vec2<i32>((x_1434 % x_1436), (x_1434 / x_1436)), 0i);
      let x_1293 : u32 = min(128u, x_1445[(x_1283 % 4i)]);
      x_2403 = 0u;
      loop {
        var x_2410 : bool;
        var x_1357 : bool;
        var x_1362 : u32;
        x_2422 = false;
        x_2415 = false;
        if ((x_2403 < x_1293)) {
        } else {
          break;
        }
        var x_1314 : vec3<f32>;
        var x_1328 : vec3<f32>;
        var x_1706 : f32;
        var x_1739 : f32;
        var x_1772 : f32;
        var x_1805 : f32;
        var x_2408 : bool;
        var x_2409 : bool;
        var x_1958 : bool;
        let x_1305 : i32 = (((x_1283 * 50i) + bitcast<i32>(x_2403)) * 12i);
        let x_1462 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1467 : i32 = (x_1305 / 4i);
        let x_1469 : i32 = x_1462.x;
        let x_1478 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1467 % x_1469), (x_1467 / x_1469)), 0i);
        let x_1309 : i32 = (x_1305 + 1i);
        let x_1495 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1500 : i32 = (x_1309 / 4i);
        let x_1502 : i32 = x_1495.x;
        let x_1511 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1500 % x_1502), (x_1500 / x_1502)), 0i);
        let x_1312 : i32 = (x_1305 + 2i);
        let x_1528 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1533 : i32 = (x_1312 / 4i);
        let x_1535 : i32 = x_1528.x;
        let x_1544 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1533 % x_1535), (x_1533 / x_1535)), 0i);
        x_1314 = vec3<f32>(bitcast<f32>(x_1478[(x_1305 % 4i)]), bitcast<f32>(x_1511[(x_1309 % 4i)]), bitcast<f32>(x_1544[(x_1312 % 4i)]));
        let x_1316 : i32 = (x_1305 + 3i);
        let x_1555 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1560 : i32 = (x_1316 / 4i);
        let x_1562 : i32 = x_1555.x;
        let x_1571 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1560 % x_1562), (x_1560 / x_1562)), 0i);
        let x_1320 : i32 = (x_1305 + 4i);
        let x_1588 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1593 : i32 = (x_1320 / 4i);
        let x_1595 : i32 = x_1588.x;
        let x_1604 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1593 % x_1595), (x_1593 / x_1595)), 0i);
        let x_1323 : i32 = (x_1305 + 5i);
        let x_1621 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1626 : i32 = (x_1323 / 4i);
        let x_1628 : i32 = x_1621.x;
        let x_1637 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1626 % x_1628), (x_1626 / x_1628)), 0i);
        let x_1326 : i32 = (x_1305 + 6i);
        let x_1654 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1659 : i32 = (x_1326 / 4i);
        let x_1661 : i32 = x_1654.x;
        let x_1670 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1659 % x_1661), (x_1659 / x_1661)), 0i);
        x_1328 = vec3<f32>(bitcast<f32>(x_1604[(x_1320 % 4i)]), bitcast<f32>(x_1637[(x_1323 % 4i)]), bitcast<f32>(x_1670[(x_1326 % 4i)]));
        let x_1334 : i32 = (x_1305 + 8i);
        let x_1714 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1719 : i32 = (x_1334 / 4i);
        let x_1721 : i32 = x_1714.x;
        let x_1730 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1719 % x_1721), (x_1719 / x_1721)), 0i);
        x_1706 = bitcast<f32>(x_1730[(x_1334 % 4i)]);
        let x_1337 : i32 = (x_1305 + 9i);
        let x_1747 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1752 : i32 = (x_1337 / 4i);
        let x_1754 : i32 = x_1747.x;
        let x_1763 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1752 % x_1754), (x_1752 / x_1754)), 0i);
        x_1739 = bitcast<f32>(x_1763[(x_1337 % 4i)]);
        let x_1341 : i32 = (x_1305 + 10i);
        let x_1780 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1785 : i32 = (x_1341 / 4i);
        let x_1787 : i32 = x_1780.x;
        let x_1796 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1785 % x_1787), (x_1785 / x_1787)), 0i);
        x_1772 = bitcast<f32>(x_1796[(x_1341 % 4i)]);
        let x_1344 : i32 = (x_1305 + 11i);
        let x_1813 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_domain_holes, 0i));
        let x_1818 : i32 = (x_1344 / 4i);
        let x_1820 : i32 = x_1813.x;
        let x_1829 : vec4<u32> = textureLoad(gs_wgpu_tex_domain_holes, vec2<i32>((x_1818 % x_1820), (x_1818 / x_1820)), 0i);
        x_1805 = bitcast<f32>(x_1829[(x_1344 % 4i)]);
        let x_1351 : bool = (x_1571[(x_1316 % 4i)] == x_1421);
        x_1357 = x_1351;
        if (x_1351) {
          var x_1919 : f32;
          var x_1947 : bool;
          let x_1852 : vec3<f32> = vec3<f32>(x_1706, 0.0f, x_1739);
          let x_1869 : mat3x3<f32> = transpose(mat3x3<f32>(cross(x_1852, x_713), x_713, x_1852));
          let x_1871 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_1869);
          let x_1873 : vec3<f32> = (x_713 * x_1869);
          let x_1875 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_1869);
          let x_1878 : vec3<f32> = cross(x_1871, x_1873);
          let x_1882 : f32 = (1.0f / dot(x_1875, x_1878));
          let x_1883 : vec3<f32> = vec3<f32>(x_1882, x_1882, x_1882);
          let x_1917 : vec3<f32> = ((mat3x3<f32>((cross(x_1873, x_1875) * x_1883), (cross(x_1875, x_1871) * x_1883), (x_1878 * x_1883)) * (x_1075 - x_1314)) / x_1328);
          x_1919 = x_1917.y;
          let x_1927 : f32 = clamp(((x_1919 * x_1772) + x_1805), 0.0f, 1.0f);
          if ((abs(x_1917.x) < mix(0.5f, 0.0f, ((x_1927 * x_1927) * x_1927)))) {
            if ((x_1919 < select(0.69999998807907104492f, 0.5f, (x_1772 == 1.0f)))) {
              x_1947 = (x_1919 > -0.5f);
              x_2408 = x_1947;
            } else {
              x_2408 = false;
            }
            x_2409 = x_2408;
          } else {
            x_2409 = false;
          }
          if (x_2409) {
            x_1958 = (abs(x_1917.z) < 0.5f);
            x_2410 = x_1958;
          } else {
            x_2410 = false;
          }
          x_1357 = x_2410;
        }
        if (x_1357) {
          x_2422 = true;
          x_2415 = true;
          break;
        }

        continuing {
          x_1362 = (x_2403 + bitcast<u32>(1i));
          x_2403 = x_1362;
        }
      }
      x_2421 = x_2422;
      if (x_2415) {
        break;
      }
      x_2421 = false;
    }
  }
  if (x_2421) {
    discard;
  }
  let x_2001 : vec3<f32> = v1;
  let x_2002 : vec3<f32> = normalize(x_2001);
  let x_2007 : vec2<f32> = v7;
  let x_2008 : i32 = v12;
  let x_2009 : bool = (x_2008 > 0i);
  if (x_2009) {
    let x_2012 : i32 = v8;
    let x_2296 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
    let x_2301 : i32 = (x_2012 / 4i);
    let x_2303 : i32 = x_2296.x;
    let x_2312 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_2301 % x_2303), (x_2301 / x_2303)), 0i);
    x_2315 = x_2312[(x_2012 % 4i)];
    x_2429 = x_2315;
  } else {
    let x_2015 : i32 = v8;
    let x_2330 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_0, 0i));
    let x_2335 : i32 = (x_2015 / 4i);
    let x_2337 : i32 = x_2330.x;
    let x_2346 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_0, vec2<i32>((x_2335 % x_2337), (x_2335 / x_2337)), 0i);
    x_2349 = x_2346[(x_2015 % 4i)];
    x_2429 = x_2349;
  }
  var x_2028 : i32;
  let x_2018 : i32 = v11;
  if ((x_2018 > 0i)) {
    x_2021 = v8;
    x_2437 = x_2021;
  } else {
    let x_2023 : i32 = v6;
    if ((x_2023 != 0i)) {
      x_2430 = 0i;
    } else {
      x_2028 = bitcast<i32>(x_2429);
      x_2430 = x_2028;
    }
    x_2437 = x_2430;
  }
  if (x_2009) {
    let x_2046 : vec4<f32> = textureSampleBias(gs_wgpu_tex_wooden_wall_colors_tex, gs_wgpu_samp_wooden_wall_colors_tex, vec3<f32>(x_2007.x, x_2007.y, f32(x_2437)).xy, i32(round(vec3<f32>(x_2007.x, x_2007.y, f32(x_2437)).z)), x_1136);
    x_2047 = vec3<f32>(x_2046.x, x_2046.y, x_2046.z);
    x_2453 = x_2047;
  } else {
    let x_2061 : vec4<f32> = textureSampleBias(gs_wgpu_tex_halftimber_colors_tex, gs_wgpu_samp_halftimber_colors_tex, vec3<f32>(x_2007.x, x_2007.y, f32(x_2437)).xy, i32(round(vec3<f32>(x_2007.x, x_2007.y, f32(x_2437)).z)), x_1136);
    x_2062 = vec3<f32>(x_2061.x, x_2061.y, x_2061.z);
    x_2453 = x_2062;
  }
  var x_2104 : vec3<f32>;
  var x_2107 : bool;
  var x_2486 : vec3<f32>;
  var x_2526 : bool;
  var x_2519 : vec3<f32>;
  var x_2135 : bool;
  var x_2517 : bool;
  var x_2141 : vec3<f32>;
  let x_2067 : i32 = v5;
  let x_2075 : vec3<f32> = mix(x_2453, (x_2453 * 1.10000002384185791016f), vec3<f32>(vec3<i32>(x_2067, x_2067, x_2067)));
  let x_2082 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_wood_roughness, gs_wgpu_samp_material_data_wood_roughness, x_2007, x_1136);
  let x_2086 : f32 = mix(0.69999998807907104492f, 0.89999997615814208984f, smoothstep(0.89999997615814208984f, 1.0f, x_2082.x));
  let x_2087 : i32 = v10;
  if ((x_2087 == 0i)) {
    var x_2603 : u32;
    var x_2111 : vec3<f32>;
    let x_2090 : i32 = v8;
    x_2603 = select(0u, x_1219, (bitcast<u32>(x_2090) == x_1216));
    if ((x_2603 == 1u)) {
      x_2104 = mix(x_2075, x_449, x_451);
      x_2526 = true;
      x_2519 = x_2104;
    } else {
      x_2107 = (x_2603 == 2u);
      if (x_2107) {
        x_2111 = mix(x_2075, x_451, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_2486 = x_2111;
      } else {
        x_2486 = x_2075;
      }
      x_2526 = x_2107;
      x_2519 = x_2486;
    }
    if ((x_1222 == 1u)) {
      x_2135 = (distance(vec2<f32>(x_1202, x_1208), vec2<f32>(x_1075.x, x_1075.z)) < ((1.88900005817413330078f * x_1213) - 0.20000000298023223877f));
      x_2517 = x_2135;
    } else {
      x_2517 = false;
    }
    if (x_2517) {
      x_2141 = mix(x_2075, x_449, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_2527 = x_2141;
    } else {
      x_2527 = x_2519;
    }
    x_2147 = select(x_2526, true, x_2517);
    x_2570 = x_2147;
    x_2548 = x_2527;
  } else {
    x_2570 = false;
    x_2548 = x_2075;
  }
  if ((x_1198 == 4u)) {
    let x_2156 : i32 = v13;
    x_2157 = (x_2156 == 0i);
    x_2546 = x_2157;
  } else {
    x_2546 = false;
  }
  var x_2197 : vec3<f32>;
  var x_2207 : vec3<f32>;
  if (x_2546) {
    let x_2164 : f32 = smoothstep(-0.10000000149011611938f, 0.0f, x_1075.y);
    let x_2165 : i32 = v9;
    if ((x_2165 > 0i)) {
      let x_2176 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_dirtpath_heightmap, gs_wgpu_samp_material_data_dirtpath_heightmap, (vec2<f32>(x_1075.x, x_1075.z) * 0.05000000074505805969f), x_1136);
      let x_2178 : f32 = x_2176.x;
      let x_2195 : f32 = ((((smoothstep(0.0f, 0.20000000298023223877f, (smoothstep(0.5f, 1.0f, x_2086) * mix(0.0f, 0.5f, x_2178))) * 0.60000002384185791016f) + (x_2178 * 0.20000000298023223877f)) * clamp(x_2002.y, 0.0f, 1.0f)) * x_2164);
      x_2197 = mix(x_2548, x_552, vec3<f32>(x_2195, x_2195, x_2195));
      x_2563 = x_2197;
    } else {
      let x_2205 : f32 = (x_2164 * smoothstep(0.5f, 1.0f, clamp(x_2002.y, 0.0f, 1.0f)));
      x_2207 = mix(x_2548, x_552, vec3<f32>(x_2205, x_2205, x_2205));
      x_2563 = x_2207;
    }
    x_2566 = x_2563;
  } else {
    x_2566 = x_2548;
  }
  let x_2248 : vec3<f32> = sqrt(clamp(x_2566, vec3<f32>(0.0f, 0.0f, 0.0f), vec3<f32>(1.0f, 1.0f, 1.0f)));
  let x_2279 : u32 = (((u32(((clamp(x_2248.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_2248.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_2248.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(117440512u, 251658240u, x_2570));
  let x_1093 : vec3<f32> = vec3<f32>(f32((x_2279 & 255u)), f32(((x_2279 >> 8u) & 255u)), f32(((x_2279 >> 16u) & 255u)));
  let x_1098 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_1093 * x_1093));
  let x_1108 : vec3<f32> = select((x_1098 * 12.9200000762939453125f), ((pow(x_1098, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_1098 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_1108.x, x_1108.y, x_1108.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(1) v1_param : vec3<f32>, @location(0) v0_param : vec3<f32>, @location(6) v7_param : vec2<f32>, @location(11) @interpolate(flat) v12_param : i32, @location(7) @interpolate(flat) v8_param : i32, @location(10) @interpolate(flat) v11_param : i32, @location(5) @interpolate(flat) v6_param : i32, @location(4) @interpolate(flat) v5_param : i32, @location(9) @interpolate(flat) v10_param : i32, @location(12) @interpolate(flat) v13_param : i32, @location(8) @interpolate(flat) v9_param : i32, @location(2) @interpolate(flat) v2_param : u32) -> main_out {
  v1 = v1_param;
  v0 = v0_param;
  v7 = v7_param;
  v12 = v12_param;
  v8 = v8_param;
  v11 = v11_param;
  v6 = v6_param;
  v5 = v5_param;
  v10 = v10_param;
  v13 = v13_param;
  v9 = v9_param;
  v2 = v2_param;
  main_1();
  return main_out(residentColor);
}
