diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(6) @group(3) var gs_wgpu_tex_woodArchSamples : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_woodArchSamples : sampler;

@binding(2) @group(3) var gs_wgpu_tex_storage_6_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_6_0 : sampler;

@binding(4) @group(3) var gs_wgpu_tex_storage_0_0 : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_storage_0_0 : sampler;

var<private> gl_InstanceIndex : i32;

var<private> gl_VertexIndex : i32;

var<private> Vertex_Position : vec3<f32>;

@binding(0) @group(2) var<uniform> x_1141 : gs_Auto_0;

var<private> v0 : vec3<f32>;

var<private> v1 : vec3<f32>;

var<private> v2 : vec3<f32>;

var<private> v3 : vec3<f32>;

var<private> v4 : u32;

var<private> v5 : f32;

var<private> v6 : vec2<f32>;

var<private> v7 : vec2<f32>;

var<private> gl_Position : vec4<f32>;

const x_403 = vec2<f32>(0.0f, 1.0f);

const x_406 = vec2<f32>(1.0f, 0.0f);

const x_409 = vec2<f32>(0.0f, -1.0f);

const x_399 = vec2<f32>(-0.70710676908493041992f, -0.70710676908493041992f);

const x_411 = vec2<f32>(-1.0f, 0.0f);

const x_1156 = array<vec2<f32>, 9u>(x_411, x_411, x_403, x_403, x_406, x_406, x_409, x_409, x_411);

fn main_1() {
  var x_1248 : array<vec2<f32>, 9u>;
  var x_1252 : array<vec2<f32>, 9u>;
  var x_1253 : array<f32, 9u>;
  var x_1264 : array<f32, 9u>;
  var x_1370 : array<vec2<f32>, 9u>;
  var x_1371 : array<vec2<f32>, 9u>;
  var x_1582 : bool;
  var x_11481 : bool;
  var x_11493 : f32;
  var x_1619 : f32;
  var x_11505 : f32;
  var x_11494 : f32;
  var x_1731 : vec3<f32>;
  var x_11555 : vec3<f32>;
  var x_1742 : bool;
  var x_11516 : bool;
  var x_1748 : bool;
  var x_11519 : bool;
  var x_1756 : bool;
  var x_11547 : bool;
  var x_1768 : bool;
  var x_11536 : bool;
  var x_1774 : bool;
  var x_11540 : bool;
  var x_1783 : bool;
  var x_11548 : bool;
  var x_11556 : vec3<f32>;
  var x_11593 : vec3<f32>;
  var x_1866 : vec2<f32>;
  var x_2025 : vec2<f32>;
  var x_2031 : vec2<f32>;
  var x_11646 : vec2<f32>;
  var x_11645 : vec2<f32>;
  let x_1374 : i32 = gl_InstanceIndex;
  let x_2088 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_2093 : i32 = (x_1374 / 4i);
  let x_2095 : i32 = x_2088.x;
  let x_2104 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_2095), (x_2093 / x_2095)), 0i);
  let x_2106 : i32 = (x_1374 % 4i);
  let x_2152 : i32 = ((bitcast<i32>(x_2104[x_2106]) * 14i) + 4i);
  let x_2321 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_2326 : i32 = (x_2152 / 4i);
  let x_2328 : i32 = x_2321.x;
  let x_2337 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_2326 % x_2328), (x_2326 / x_2328)), 0i);
  let x_2340 : u32 = x_2337[(x_2152 % 4i)];
  let x_2598 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_2605 : i32 = x_2598.x;
  let x_2614 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_2605), (x_2093 / x_2605)), 0i);
  let x_2698 : i32 = ((bitcast<i32>(x_2614[x_2106]) * 14i) + 11i);
  let x_3019 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_3024 : i32 = (x_2698 / 4i);
  let x_3026 : i32 = x_3019.x;
  let x_3035 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_3024 % x_3026), (x_3024 / x_3026)), 0i);
  let x_1388 : f32 = (bitcast<f32>(x_3035[(x_2698 % 4i)]) * 0.5f);
  let x_3107 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_3114 : i32 = x_3107.x;
  let x_3123 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_3114), (x_2093 / x_3114)), 0i);
  let x_3201 : i32 = ((bitcast<i32>(x_3123[x_2106]) * 14i) + 10i);
  let x_3501 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_3506 : i32 = (x_3201 / 4i);
  let x_3508 : i32 = x_3501.x;
  let x_3517 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_3506 % x_3508), (x_3506 / x_3508)), 0i);
  let x_1395 : f32 = (bitcast<f32>(x_3517[(x_3201 % 4i)]) * 0.5f);
  let x_3616 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_3623 : i32 = x_3616.x;
  let x_3632 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_3623), (x_2093 / x_3623)), 0i);
  let x_3722 : i32 = ((bitcast<i32>(x_3632[x_2106]) * 14i) + 12i);
  let x_4064 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_4069 : i32 = (x_3722 / 4i);
  let x_4071 : i32 = x_4064.x;
  let x_4080 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_4069 % x_4071), (x_4069 / x_4071)), 0i);
  let x_1406 : f32 = min(bitcast<f32>(x_4080[(x_3722 % 4i)]), (min(x_1388, x_1395) * 0.94999998807907104492f));
  let x_1408 : f32 = (x_1406 * 0.40000000596046447754f);
  let x_4125 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_4132 : i32 = x_4125.x;
  let x_4141 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_4132), (x_2093 / x_4132)), 0i);
  let x_4225 : i32 = ((bitcast<i32>(x_4141[x_2106]) * 14i) + 11i);
  let x_4546 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_4551 : i32 = (x_4225 / 4i);
  let x_4553 : i32 = x_4546.x;
  let x_4562 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_4551 % x_4553), (x_4551 / x_4553)), 0i);
  let x_1415 : f32 = (bitcast<f32>(x_4562[(x_4225 % 4i)]) * -0.5f);
  let x_4634 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_4641 : i32 = x_4634.x;
  let x_4650 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_4641), (x_2093 / x_4641)), 0i);
  let x_4728 : i32 = ((bitcast<i32>(x_4650[x_2106]) * 14i) + 10i);
  let x_5028 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_5033 : i32 = (x_4728 / 4i);
  let x_5035 : i32 = x_5028.x;
  let x_5044 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5033 % x_5035), (x_5033 / x_5035)), 0i);
  let x_1422 : f32 = (bitcast<f32>(x_5044[(x_4728 % 4i)]) * -0.5f);
  let x_1425 : vec2<f32> = vec2<f32>(x_1415, x_1422);
  let x_1428 : f32 = (x_1395 - x_1408);
  let x_1431 : vec2<f32> = vec2<f32>(x_1415, x_1428);
  let x_1434 : f32 = (x_1415 + x_1408);
  let x_1437 : vec2<f32> = vec2<f32>(x_1434, x_1395);
  let x_1440 : f32 = (x_1388 - x_1408);
  let x_1443 : vec2<f32> = vec2<f32>(x_1440, x_1395);
  let x_1446 : vec2<f32> = vec2<f32>(x_1388, x_1428);
  let x_1451 : vec2<f32> = vec2<f32>(x_1388, (x_1422 + x_1408));
  let x_1454 : vec2<f32> = vec2<f32>(x_1440, x_1422);
  let x_1457 : vec2<f32> = vec2<f32>(x_1434, x_1422);
  x_1248 = array<vec2<f32>, 9u>(x_1425, x_1431, x_1437, x_1443, x_1446, x_1451, x_1454, x_1457, x_1425);
  let x_1469 : i32 = gl_VertexIndex;
  let x_1471 : u32 = (bitcast<u32>(x_1469) % 9u);
  x_1252 = array<vec2<f32>, 9u>(x_403, x_403, vec2<f32>(0.70710676908493041992f, 0.70710676908493041992f), x_406, vec2<f32>(0.70710676908493041992f, -0.70710676908493041992f), x_409, x_399, x_411, x_399);
  x_1253[0i] = 0.0f;
  let x_1478 : f32 = x_1253[0i];
  let x_1483 : f32 = (x_1478 + distance(x_1431, x_1425));
  x_1253[1i] = x_1483;
  let x_1490 : f32 = (x_1483 + distance(x_1437, x_1431));
  x_1253[2i] = x_1490;
  let x_1497 : f32 = (x_1490 + distance(x_1443, x_1437));
  x_1253[3i] = x_1497;
  let x_1504 : f32 = (x_1497 + distance(x_1446, x_1443));
  x_1253[4i] = x_1504;
  let x_1511 : f32 = (x_1504 + distance(x_1451, x_1446));
  x_1253[5i] = x_1511;
  let x_1518 : f32 = (x_1511 + distance(x_1454, x_1451));
  x_1253[6i] = x_1518;
  let x_1525 : f32 = (x_1518 + distance(x_1457, x_1454));
  x_1253[7i] = x_1525;
  x_1253[8i] = (x_1525 + distance(x_1425, x_1457));
  let x_1535 : f32 = (x_1406 * 0.20000000298023223877f);
  x_1264 = array<f32, 9u>(0.0f, (1.0f - x_1535), (1.0f + x_1535), (2.0f - x_1535), (2.0f + x_1535), (3.0f - x_1535), (3.0f + x_1535), (4.0f - x_1535), 4.0f);
  let x_5143 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_5150 : i32 = x_5143.x;
  let x_5159 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_5150), (x_2093 / x_5150)), 0i);
  let x_5227 : i32 = ((bitcast<i32>(x_5159[x_2106]) * 14i) + 8i);
  let x_5483 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_5488 : i32 = (x_5227 / 4i);
  let x_5490 : i32 = x_5483.x;
  let x_5499 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5488 % x_5490), (x_5488 / x_5490)), 0i);
  let x_1560 : f32 = (1.0f / f32((1u << x_5499[(x_5227 % 4i)])));
  let x_5652 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_5659 : i32 = x_5652.x;
  let x_5668 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_5659), (x_2093 / x_5659)), 0i);
  let x_5741 : i32 = ((bitcast<i32>(x_5668[x_2106]) * 14i) + 9i);
  let x_6019 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_6024 : i32 = (x_5741 / 4i);
  let x_6026 : i32 = x_6019.x;
  let x_6035 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_6024 % x_6026), (x_6024 / x_6026)), 0i);
  let x_1568 : bool = ((x_6035[(x_5741 % 4i)] & 1u) != 0u);
  let x_6161 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_6168 : i32 = x_6161.x;
  let x_6177 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_6168), (x_2093 / x_6168)), 0i);
  let x_6250 : i32 = ((bitcast<i32>(x_6177[x_2106]) * 14i) + 9i);
  let x_6528 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_6533 : i32 = (x_6250 / 4i);
  let x_6535 : i32 = x_6528.x;
  let x_6544 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_6533 % x_6535), (x_6533 / x_6535)), 0i);
  let x_1576 : bool = ((x_6544[(x_6250 % 4i)] & 2u) != 0u);
  if (x_1568) {
    let x_1580 : f32 = Vertex_Position.z;
    x_1582 = (x_1580 < x_1560);
    x_11481 = x_1582;
  } else {
    x_11481 = false;
  }
  var x_1594 : bool;
  var x_11484 : bool;
  var x_1616 : f32;
  if (x_11481) {
    x_11505 = 1.0f;
    x_11494 = 0.0f;
  } else {
    if (x_1576) {
      let x_1591 : f32 = Vertex_Position.z;
      x_1594 = (x_1591 > (1.0f - x_1560));
      x_11484 = x_1594;
    } else {
      x_11484 = false;
    }
    var x_1606 : f32;
    var x_11490 : f32;
    if (x_11484) {
      x_11493 = 1.0f;
    } else {
      let x_1602 : f32 = select(0.0f, x_1560, x_1568);
      if (x_1576) {
        x_1606 = (1.0f - x_1560);
        x_11490 = x_1606;
      } else {
        x_11490 = 1.0f;
      }
      let x_1610 : f32 = Vertex_Position.z;
      x_1616 = ((x_1610 - x_1602) / (x_11490 - x_1602));
      x_11493 = x_1616;
    }
    x_1619 = select(0.0f, 1.0f, x_11484);
    x_11505 = x_1619;
    x_11494 = x_11493;
  }
  let x_6670 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_6677 : i32 = x_6670.x;
  let x_6686 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_6677), (x_2093 / x_6677)), 0i);
  let x_6744 : i32 = ((bitcast<i32>(x_6686[x_2106]) * 14i) + 6i);
  let x_6956 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_6961 : i32 = (x_6744 / 4i);
  let x_6963 : i32 = x_6956.x;
  let x_6972 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_6961 % x_6963), (x_6961 / x_6963)), 0i);
  let x_1631 : f32 = (x_11494 * f32((x_6972[(x_6744 % 4i)] - 1u)));
  let x_7179 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_7186 : i32 = x_7179.x;
  let x_7195 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_7186), (x_2093 / x_7186)), 0i);
  let x_7253 : i32 = ((bitcast<i32>(x_7195[x_2106]) * 14i) + 6i);
  let x_7465 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_7470 : i32 = (x_7253 / 4i);
  let x_7472 : i32 = x_7465.x;
  let x_7481 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_7470 % x_7472), (x_7470 / x_7472)), 0i);
  let x_1642 : u32 = min(u32(floor(x_1631)), (x_7481[(x_7253 % 4i)] - 2u));
  let x_1647 : f32 = clamp((x_1631 - f32(x_1642)), 0.0f, 1.0f);
  let x_1649 : u32 = (x_1642 * 3u);
  let x_1656 : u32 = ((x_1642 + 1u) * 3u);
  let x_1662 : vec3<f32> = vec3<f32>(x_1647, x_1647, x_1647);
  let x_7686 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7691 : i32 = bitcast<i32>((x_2340 + (x_1649 + 1u)));
  let x_7693 : i32 = x_7686.x;
  let x_7702 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7691 % x_7693), (x_7691 / x_7693)), 0i);
  let x_7714 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7721 : i32 = x_7714.x;
  let x_7730 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7691 % x_7721), (x_7691 / x_7721)), 0i);
  let x_7742 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7749 : i32 = x_7742.x;
  let x_7758 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7691 % x_7749), (x_7691 / x_7749)), 0i);
  let x_7770 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7775 : i32 = bitcast<i32>((x_2340 + (x_1656 + 1u)));
  let x_7777 : i32 = x_7770.x;
  let x_7786 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7775 % x_7777), (x_7775 / x_7777)), 0i);
  let x_7798 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7805 : i32 = x_7798.x;
  let x_7814 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7775 % x_7805), (x_7775 / x_7805)), 0i);
  let x_7826 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7833 : i32 = x_7826.x;
  let x_7842 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7775 % x_7833), (x_7775 / x_7833)), 0i);
  let x_1687 : vec3<f32> = normalize(mix(bitcast<vec3<f32>>(vec3<u32>(x_7702.x, x_7730.y, x_7758.z)), bitcast<vec3<f32>>(vec3<u32>(x_7786.x, x_7814.y, x_7842.z)), x_1662));
  let x_7854 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7859 : i32 = bitcast<i32>((x_2340 + (x_1649 + 2u)));
  let x_7861 : i32 = x_7854.x;
  let x_7870 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7859 % x_7861), (x_7859 / x_7861)), 0i);
  let x_7882 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7889 : i32 = x_7882.x;
  let x_7898 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7859 % x_7889), (x_7859 / x_7889)), 0i);
  let x_7910 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7917 : i32 = x_7910.x;
  let x_7926 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7859 % x_7917), (x_7859 / x_7917)), 0i);
  let x_7938 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7943 : i32 = bitcast<i32>((x_2340 + (x_1656 + 2u)));
  let x_7945 : i32 = x_7938.x;
  let x_7954 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7943 % x_7945), (x_7943 / x_7945)), 0i);
  let x_7966 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_7973 : i32 = x_7966.x;
  let x_7982 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7943 % x_7973), (x_7943 / x_7973)), 0i);
  let x_7994 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_8001 : i32 = x_7994.x;
  let x_8010 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_7943 % x_8001), (x_7943 / x_8001)), 0i);
  let x_1712 : vec3<f32> = normalize(mix(bitcast<vec3<f32>>(vec3<u32>(x_7870.x, x_7898.y, x_7926.z)), bitcast<vec3<f32>>(vec3<u32>(x_7954.x, x_7982.y, x_8010.z)), x_1662));
  let x_1716 : vec3<f32> = normalize(cross(x_1712, x_1687));
  if ((x_11505 > 0.0f)) {
    x_11555 = vec3<f32>(0.0f, 0.0f, 0.0f);
  } else {
    let x_1724 : f32 = x_1248[x_1471].x;
    let x_1729 : f32 = x_1248[x_1471].y;
    x_1731 = ((x_1712 * x_1724) + (x_1716 * x_1729));
    x_11555 = x_1731;
  }
  if (x_1568) {
    let x_8025 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
    let x_8032 : i32 = x_8025.x;
    let x_8041 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_8032), (x_2093 / x_8032)), 0i);
    let x_8114 : i32 = ((bitcast<i32>(x_8041[x_2106]) * 14i) + 9i);
    let x_8392 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_8397 : i32 = (x_8114 / 4i);
    let x_8399 : i32 = x_8392.x;
    let x_8408 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_8397 % x_8399), (x_8397 / x_8399)), 0i);
    x_1742 = ((x_8408[(x_8114 % 4i)] & 4u) != 0u);
    x_11516 = x_1742;
  } else {
    x_11516 = false;
  }
  if (x_11516) {
    x_1748 = (x_11505 <= 0.0f);
    x_11519 = x_1748;
  } else {
    x_11519 = false;
  }
  if (x_11519) {
    let x_1754 : f32 = Vertex_Position.z;
    x_1756 = (x_1754 <= x_1560);
    x_11547 = x_1756;
  } else {
    x_11547 = false;
  }
  if (x_1576) {
    let x_8534 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
    let x_8541 : i32 = x_8534.x;
    let x_8550 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_8541), (x_2093 / x_8541)), 0i);
    let x_8623 : i32 = ((bitcast<i32>(x_8550[x_2106]) * 14i) + 9i);
    let x_8901 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_8906 : i32 = (x_8623 / 4i);
    let x_8908 : i32 = x_8901.x;
    let x_8917 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_8906 % x_8908), (x_8906 / x_8908)), 0i);
    x_1768 = ((x_8917[(x_8623 % 4i)] & 8u) != 0u);
    x_11536 = x_1768;
  } else {
    x_11536 = false;
  }
  if (x_11536) {
    x_1774 = (x_11505 <= 0.0f);
    x_11540 = x_1774;
  } else {
    x_11540 = false;
  }
  if (x_11540) {
    let x_1780 : f32 = Vertex_Position.z;
    x_1783 = (x_1780 >= (1.0f - x_1560));
    x_11548 = x_1783;
  } else {
    x_11548 = false;
  }
  var x_1815 : vec3<f32>;
  if (select(x_11548, true, x_11547)) {
    let x_1794 : vec3<f32> = vec3<f32>(x_1687.x, 0.0f, x_1687.z);
    let x_1796 : f32 = length(x_1794);
    if ((x_1796 > 0.00009999999747378752f)) {
      let x_1803 : vec3<f32> = (x_1794 / vec3<f32>(x_1796, x_1796, x_1796));
      x_1815 = (x_11555 + (x_1687 * (-(dot(x_1803, x_11555)) / dot(x_1803, x_1687))));
      x_11556 = x_1815;
    } else {
      x_11556 = x_11555;
    }
    x_11593 = x_11556;
  } else {
    x_11593 = x_11555;
  }
  let x_9040 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_9045 : i32 = bitcast<i32>((x_2340 + x_1649));
  let x_9047 : i32 = x_9040.x;
  let x_9056 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_9045 % x_9047), (x_9045 / x_9047)), 0i);
  let x_9068 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_9075 : i32 = x_9068.x;
  let x_9084 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_9045 % x_9075), (x_9045 / x_9075)), 0i);
  let x_9096 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_9103 : i32 = x_9096.x;
  let x_9112 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_9045 % x_9103), (x_9045 / x_9103)), 0i);
  let x_9124 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_9129 : i32 = bitcast<i32>((x_2340 + x_1656));
  let x_9131 : i32 = x_9124.x;
  let x_9140 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_9129 % x_9131), (x_9129 / x_9131)), 0i);
  let x_9152 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_9159 : i32 = x_9152.x;
  let x_9168 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_9129 % x_9159), (x_9129 / x_9159)), 0i);
  let x_9180 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_9187 : i32 = x_9180.x;
  let x_9196 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_9129 % x_9187), (x_9129 / x_9187)), 0i);
  let x_1848 : vec3<f32> = (mix(bitcast<vec3<f32>>(vec3<u32>(x_9056.x, x_9084.y, x_9112.z)), bitcast<vec3<f32>>(vec3<u32>(x_9140.x, x_9168.y, x_9196.z)), x_1662) + x_11593);
  let x_9208 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_9215 : i32 = x_9208.x;
  let x_9224 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_9045 % x_9215), (x_9045 / x_9215)), 0i);
  let x_9236 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_woodArchSamples, 0i));
  let x_9243 : i32 = x_9236.x;
  let x_9252 : vec4<u32> = textureLoad(gs_wgpu_tex_woodArchSamples, vec2<i32>((x_9129 % x_9243), (x_9129 / x_9243)), 0i);
  let x_1858 : f32 = mix(bitcast<f32>(x_9224.w), bitcast<f32>(x_9252.w), x_1647);
  if ((x_11505 > 0.00999999977648258209f)) {
    let x_1864 : vec2<f32> = x_1248[x_1471];
    x_1866 = ((x_1864 * 2.0f) + vec2<f32>(0.37000000476837158203f, 0.37000000476837158203f));
    x_11646 = vec2<f32>(0.0f, 0.0f);
    x_11645 = x_1866;
  } else {
    let x_9267 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
    let x_9274 : i32 = x_9267.x;
    let x_9283 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_9274), (x_2093 / x_9274)), 0i);
    let x_9304 : i32 = (bitcast<i32>(x_9283[x_2106]) * 14i);
    let x_9391 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_9396 : i32 = (x_9304 / 4i);
    let x_9398 : i32 = x_9391.x;
    let x_9407 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_9396 % x_9398), (x_9396 / x_9398)), 0i);
    let x_9776 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
    let x_9783 : i32 = x_9776.x;
    let x_9792 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_9783), (x_2093 / x_9783)), 0i);
    let x_9821 : i32 = ((bitcast<i32>(x_9792[x_2106]) * 14i) + 1i);
    let x_9927 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_9932 : i32 = (x_9821 / 4i);
    let x_9934 : i32 = x_9927.x;
    let x_9943 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_9932 % x_9934), (x_9932 / x_9934)), 0i);
    let x_10285 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
    let x_10292 : i32 = x_10285.x;
    let x_10301 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_10292), (x_2093 / x_10292)), 0i);
    let x_10336 : i32 = ((bitcast<i32>(x_10301[x_2106]) * 14i) + 2i);
    let x_10463 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_10468 : i32 = (x_10336 / 4i);
    let x_10470 : i32 = x_10463.x;
    let x_10479 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_10468 % x_10470), (x_10468 / x_10470)), 0i);
    let x_1889 : vec3<u32> = vec3<u32>((abs(vec3<f32>(bitcast<f32>(x_9407[(x_9304 % 4i)]), bitcast<f32>(x_9943[(x_9821 % 4i)]), bitcast<f32>(x_10479[(x_10336 % 4i)]))) * 100.0f));
    let x_1891 : u32 = x_1889.z;
    let x_1895 : u32 = (x_1891 + (x_1891 << 10u));
    let x_1899 : u32 = (x_1895 ^ (x_1895 >> 6u));
    let x_1903 : u32 = (x_1899 + (x_1899 << 3u));
    let x_1907 : u32 = (x_1903 ^ (x_1903 >> 11u));
    let x_1917 : u32 = ((((x_1889.y * 1664525u) + (x_1907 + (x_1907 << 15u))) + 1013904223u) * 1664525u);
    let x_1921 : u32 = (x_1917 ^ (x_1917 >> 11u));
    let x_1926 : u32 = (x_1921 ^ ((x_1921 << 7u) & 2636928640u));
    let x_1931 : u32 = (x_1926 ^ ((x_1926 << 15u) & 4022730752u));
    let x_1941 : u32 = ((((x_1889.x * 1664525u) + (x_1931 ^ (x_1931 >> 18u))) + 1013904223u) * 1664525u);
    let x_1945 : u32 = (x_1941 ^ (x_1941 >> 11u));
    let x_1950 : u32 = (x_1945 ^ ((x_1945 << 7u) & 2636928640u));
    let x_1955 : u32 = (x_1950 ^ ((x_1950 << 15u) & 4022730752u));
    let x_1959 : u32 = (x_1955 ^ (x_1955 >> 18u));
    let x_1963 : u32 = (x_1959 + (x_1959 << 10u));
    let x_1967 : u32 = (x_1963 ^ (x_1963 >> 6u));
    let x_1971 : u32 = (x_1967 + (x_1967 << 3u));
    let x_1975 : u32 = (x_1971 ^ (x_1971 >> 11u));
    let x_1977 : u32 = (x_1959 ^ 188053769u);
    let x_1981 : u32 = (x_1977 + (x_1977 << 10u));
    let x_1985 : u32 = (x_1981 ^ (x_1981 >> 6u));
    let x_1989 : u32 = (x_1985 + (x_1985 << 3u));
    let x_1993 : u32 = (x_1989 ^ (x_1989 >> 11u));
    let x_1996 : f32 = x_1253[x_1471];
    let x_10794 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
    let x_10801 : i32 = x_10794.x;
    let x_10810 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_10801), (x_2093 / x_10801)), 0i);
    let x_10906 : i32 = ((bitcast<i32>(x_10810[x_2106]) * 14i) + 13i);
    let x_11269 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_11274 : i32 = (x_10906 / 4i);
    let x_11276 : i32 = x_11269.x;
    let x_11285 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_11274 % x_11276), (x_11274 / x_11276)), 0i);
    x_2025 = ((vec2<f32>((x_1996 * 0.20000000298023223877f), min(x_1858, bitcast<f32>(x_11285[(x_10906 % 4i)]))) * 3.0f) + vec2<f32>((bitcast<f32>((((x_1975 + (x_1975 << 15u)) & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_1993 + (x_1993 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
    let x_2028 : f32 = x_1264[x_1471];
    x_2031 = vec2<f32>((x_2028 * 0.3333333432674407959f), x_1858);
    x_11646 = x_2031;
    x_11645 = x_2025;
  }
  let x_2034 : mat4x4<f32> = x_1141.renderer_MVPMat;
  gl_Position = (x_2034 * vec4<f32>(x_1848.x, x_1848.y, x_1848.z, 1.0f));
  x_1370 = x_1156;
  let x_2045 : f32 = x_1370[x_1471].x;
  x_1371 = x_1156;
  let x_2050 : f32 = x_1371[x_1471].y;
  v0 = normalize(((x_1712 * x_2045) + (x_1716 * x_2050)));
  v1 = x_1848;
  let x_2058 : f32 = x_1252[x_1471].x;
  let x_2063 : f32 = x_1252[x_1471].y;
  v2 = normalize(((x_1712 * x_2058) + (x_1716 * x_2063)));
  v3 = x_1687;
  let x_11303 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_11310 : i32 = x_11303.x;
  let x_11319 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_2093 % x_11310), (x_2093 / x_11310)), 0i);
  v4 = x_11319[x_2106];
  v5 = x_11505;
  v6 = x_11645;
  v7 = x_11646;
  let x_1204 : f32 = gl_Position.z;
  let x_1206 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_1204 + x_1206));
  return;
}

struct main_out {
  @builtin(position)
  gl_Position : vec4<f32>,
  @location(0)
  v0_1 : vec3<f32>,
  @location(1)
  v1_1 : vec3<f32>,
  @location(2)
  v2_1 : vec3<f32>,
  @location(3)
  v3_1 : vec3<f32>,
  @location(4) @interpolate(flat)
  v4_1 : u32,
  @location(5)
  v5_1 : f32,
  @location(6)
  v6_1 : vec2<f32>,
  @location(7)
  v7_1 : vec2<f32>,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @builtin(vertex_index) gl_VertexIndex_param : u32, @location(0) Vertex_Position_param : vec3<f32>) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  gl_VertexIndex = bitcast<i32>(gl_VertexIndex_param);
  Vertex_Position = Vertex_Position_param;
  main_1();
  return main_out(gl_Position, v0, v1, v2, v3, v4, v5, v6, v7);
}
