diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
  /* @offset(64) */
  renderer_ModelMat : mat4x4<f32>,
  /* @offset(128) */
  renderer_NormalMat : mat4x4<f32>,
}

var<private> masonryPickIndex : f32;

var<private> decorationPickIndex : f32;

var<private> vertexTintRole : f32;

var<private> decorationTintRole : f32;

var<private> vertexSourceColor : vec3<f32>;

var<private> decorationSourceColor : vec3<f32>;

var<private> vertexNormal : vec3<f32>;

@binding(0) @group(2) var<uniform> x_333 : gs_Auto_0;

var<private> decorationNormal : vec3<f32>;

var<private> vertexColor : vec3<f32>;

var<private> decorationColor : vec3<f32>;

var<private> vertexEmission : f32;

var<private> decorationEmission : f32;

var<private> vertexUV : vec2<f32>;

var<private> decorationUV : vec2<f32>;

var<private> vertexKind : f32;

var<private> decorationKind : f32;

var<private> windowCenterWS : vec3<f32>;

var<private> decorationCenter : vec3<f32>;

var<private> decorationPosition : vec3<f32>;

var<private> decorationPositionWS : vec3<f32>;

var<private> gl_Position : vec4<f32>;

const x_324 = mat4x4<f32>(vec4<f32>(1.0f, 0.0f, 0.0f, 0.0f), vec4<f32>(0.0f, 1.0f, 0.0f, 0.0f), vec4<f32>(0.0f, 0.0f, 1.0f, 0.0f), vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f));

const x_289 = vec2<f32>(0.5f, 0.5f);

fn main_1() {
  var x_686 : vec3<f32>;
  var x_513 : vec3<f32>;
  var x_1687 : vec3<f32>;
  let x_461 : f32 = decorationPickIndex;
  masonryPickIndex = x_461;
  let x_462 : f32 = decorationTintRole;
  vertexTintRole = x_462;
  let x_463 : vec3<f32> = decorationSourceColor;
  vertexSourceColor = x_463;
  let x_465 : mat4x4<f32> = x_333.renderer_NormalMat;
  let x_466 : vec4<f32> = x_465[0u];
  let x_468 : vec4<f32> = x_465[1u];
  let x_470 : vec4<f32> = x_465[2u];
  let x_482 : vec3<f32> = decorationNormal;
  vertexNormal = ((mat3x3<f32>(vec3<f32>(x_466.x, x_466.y, x_466.z), vec3<f32>(x_468.x, x_468.y, x_468.z), vec3<f32>(x_470.x, x_470.y, x_470.z)) * mat3x3<f32>(vec3<f32>(1.0f, 0.0f, 0.0f), vec3<f32>(0.0f, 1.0f, 0.0f), vec3<f32>(0.0f, 0.0f, 1.0f))) * x_482);
  let x_484 : vec3<f32> = decorationColor;
  vertexColor = x_484;
  let x_485 : f32 = decorationEmission;
  vertexEmission = x_485;
  let x_486 : vec2<f32> = decorationUV;
  vertexUV = x_486;
  let x_487 : f32 = decorationKind;
  vertexKind = x_487;
  let x_489 : mat4x4<f32> = x_333.renderer_ModelMat;
  let x_492 : vec3<f32> = decorationCenter;
  let x_497 : vec4<f32> = ((x_489 * x_324) * vec4<f32>(x_492.x, x_492.y, x_492.z, 1.0f));
  windowCenterWS = vec3<f32>(x_497.x, x_497.y, x_497.z);
  let x_500 : f32 = (x_487 - (16.0f * floor((x_487 / 16.0f))));
  if ((((x_500 > 0.5f) & (x_500 < 5.5f)) | (x_500 > 7.5f))) {
    let x_510 : vec3<f32> = decorationPosition;
    let x_564 : vec3<f32> = (x_510 * 0.40000000596046447754f);
    let x_566 : vec3<f32> = fract(x_564);
    let x_569 : vec3<i32> = vec3<i32>(floor(x_564));
    let x_576 : vec3<f32> = ((x_566 * x_566) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (x_566 * 2.0f)));
    let x_578 : f32 = x_576.x;
    let x_580 : f32 = (1.0f - x_578);
    let x_582 : f32 = x_576.y;
    let x_584 : f32 = (1.0f - x_582);
    let x_586 : f32 = x_576.z;
    let x_588 : f32 = (1.0f - x_586);
    let x_696 : vec3<u32> = bitcast<vec3<u32>>(x_569);
    let x_698 : u32 = x_696.z;
    let x_733 : u32 = (x_698 + (x_698 << 10u));
    let x_737 : u32 = (x_733 ^ (x_733 >> 6u));
    let x_741 : u32 = (x_737 + (x_737 << 3u));
    let x_745 : u32 = (x_741 ^ (x_741 >> 11u));
    let x_706 : u32 = ((((x_696.y * 1664525u) + (x_745 + (x_745 << 15u))) + 1013904223u) * 1664525u);
    let x_755 : u32 = (x_706 ^ (x_706 >> 11u));
    let x_760 : u32 = (x_755 ^ ((x_755 << 7u) & 2636928640u));
    let x_765 : u32 = (x_760 ^ ((x_760 << 15u) & 4022730752u));
    let x_714 : u32 = ((((x_696.x * 1664525u) + (x_765 ^ (x_765 >> 18u))) + 1013904223u) * 1664525u);
    let x_775 : u32 = (x_714 ^ (x_714 >> 11u));
    let x_780 : u32 = (x_775 ^ ((x_775 << 7u) & 2636928640u));
    let x_785 : u32 = (x_780 ^ ((x_780 << 15u) & 4022730752u));
    let x_789 : u32 = (x_785 ^ (x_785 >> 18u));
    let x_795 : u32 = (x_789 + (x_789 << 10u));
    let x_799 : u32 = (x_795 ^ (x_795 >> 6u));
    let x_803 : u32 = (x_799 + (x_799 << 3u));
    let x_807 : u32 = (x_803 ^ (x_803 >> 11u));
    let x_821 : vec3<u32> = bitcast<vec3<u32>>((x_569 + vec3<i32>(1i, 0i, 0i)));
    let x_823 : u32 = x_821.z;
    let x_858 : u32 = (x_823 + (x_823 << 10u));
    let x_862 : u32 = (x_858 ^ (x_858 >> 6u));
    let x_866 : u32 = (x_862 + (x_862 << 3u));
    let x_870 : u32 = (x_866 ^ (x_866 >> 11u));
    let x_831 : u32 = ((((x_821.y * 1664525u) + (x_870 + (x_870 << 15u))) + 1013904223u) * 1664525u);
    let x_880 : u32 = (x_831 ^ (x_831 >> 11u));
    let x_885 : u32 = (x_880 ^ ((x_880 << 7u) & 2636928640u));
    let x_890 : u32 = (x_885 ^ ((x_885 << 15u) & 4022730752u));
    let x_839 : u32 = ((((x_821.x * 1664525u) + (x_890 ^ (x_890 >> 18u))) + 1013904223u) * 1664525u);
    let x_900 : u32 = (x_839 ^ (x_839 >> 11u));
    let x_905 : u32 = (x_900 ^ ((x_900 << 7u) & 2636928640u));
    let x_910 : u32 = (x_905 ^ ((x_905 << 15u) & 4022730752u));
    let x_914 : u32 = (x_910 ^ (x_910 >> 18u));
    let x_920 : u32 = (x_914 + (x_914 << 10u));
    let x_924 : u32 = (x_920 ^ (x_920 >> 6u));
    let x_928 : u32 = (x_924 + (x_924 << 3u));
    let x_932 : u32 = (x_928 ^ (x_928 >> 11u));
    let x_946 : vec3<u32> = bitcast<vec3<u32>>((x_569 + vec3<i32>(0i, 1i, 0i)));
    let x_948 : u32 = x_946.z;
    let x_983 : u32 = (x_948 + (x_948 << 10u));
    let x_987 : u32 = (x_983 ^ (x_983 >> 6u));
    let x_991 : u32 = (x_987 + (x_987 << 3u));
    let x_995 : u32 = (x_991 ^ (x_991 >> 11u));
    let x_956 : u32 = ((((x_946.y * 1664525u) + (x_995 + (x_995 << 15u))) + 1013904223u) * 1664525u);
    let x_1005 : u32 = (x_956 ^ (x_956 >> 11u));
    let x_1010 : u32 = (x_1005 ^ ((x_1005 << 7u) & 2636928640u));
    let x_1015 : u32 = (x_1010 ^ ((x_1010 << 15u) & 4022730752u));
    let x_964 : u32 = ((((x_946.x * 1664525u) + (x_1015 ^ (x_1015 >> 18u))) + 1013904223u) * 1664525u);
    let x_1025 : u32 = (x_964 ^ (x_964 >> 11u));
    let x_1030 : u32 = (x_1025 ^ ((x_1025 << 7u) & 2636928640u));
    let x_1035 : u32 = (x_1030 ^ ((x_1030 << 15u) & 4022730752u));
    let x_1039 : u32 = (x_1035 ^ (x_1035 >> 18u));
    let x_1045 : u32 = (x_1039 + (x_1039 << 10u));
    let x_1049 : u32 = (x_1045 ^ (x_1045 >> 6u));
    let x_1053 : u32 = (x_1049 + (x_1049 << 3u));
    let x_1057 : u32 = (x_1053 ^ (x_1053 >> 11u));
    let x_1071 : vec3<u32> = bitcast<vec3<u32>>((x_569 + vec3<i32>(1i, 1i, 0i)));
    let x_1073 : u32 = x_1071.z;
    let x_1108 : u32 = (x_1073 + (x_1073 << 10u));
    let x_1112 : u32 = (x_1108 ^ (x_1108 >> 6u));
    let x_1116 : u32 = (x_1112 + (x_1112 << 3u));
    let x_1120 : u32 = (x_1116 ^ (x_1116 >> 11u));
    let x_1081 : u32 = ((((x_1071.y * 1664525u) + (x_1120 + (x_1120 << 15u))) + 1013904223u) * 1664525u);
    let x_1130 : u32 = (x_1081 ^ (x_1081 >> 11u));
    let x_1135 : u32 = (x_1130 ^ ((x_1130 << 7u) & 2636928640u));
    let x_1140 : u32 = (x_1135 ^ ((x_1135 << 15u) & 4022730752u));
    let x_1089 : u32 = ((((x_1071.x * 1664525u) + (x_1140 ^ (x_1140 >> 18u))) + 1013904223u) * 1664525u);
    let x_1150 : u32 = (x_1089 ^ (x_1089 >> 11u));
    let x_1155 : u32 = (x_1150 ^ ((x_1150 << 7u) & 2636928640u));
    let x_1160 : u32 = (x_1155 ^ ((x_1155 << 15u) & 4022730752u));
    let x_1164 : u32 = (x_1160 ^ (x_1160 >> 18u));
    let x_1170 : u32 = (x_1164 + (x_1164 << 10u));
    let x_1174 : u32 = (x_1170 ^ (x_1170 >> 6u));
    let x_1178 : u32 = (x_1174 + (x_1174 << 3u));
    let x_1182 : u32 = (x_1178 ^ (x_1178 >> 11u));
    let x_1196 : vec3<u32> = bitcast<vec3<u32>>((x_569 + vec3<i32>(0i, 0i, 1i)));
    let x_1198 : u32 = x_1196.z;
    let x_1233 : u32 = (x_1198 + (x_1198 << 10u));
    let x_1237 : u32 = (x_1233 ^ (x_1233 >> 6u));
    let x_1241 : u32 = (x_1237 + (x_1237 << 3u));
    let x_1245 : u32 = (x_1241 ^ (x_1241 >> 11u));
    let x_1206 : u32 = ((((x_1196.y * 1664525u) + (x_1245 + (x_1245 << 15u))) + 1013904223u) * 1664525u);
    let x_1255 : u32 = (x_1206 ^ (x_1206 >> 11u));
    let x_1260 : u32 = (x_1255 ^ ((x_1255 << 7u) & 2636928640u));
    let x_1265 : u32 = (x_1260 ^ ((x_1260 << 15u) & 4022730752u));
    let x_1214 : u32 = ((((x_1196.x * 1664525u) + (x_1265 ^ (x_1265 >> 18u))) + 1013904223u) * 1664525u);
    let x_1275 : u32 = (x_1214 ^ (x_1214 >> 11u));
    let x_1280 : u32 = (x_1275 ^ ((x_1275 << 7u) & 2636928640u));
    let x_1285 : u32 = (x_1280 ^ ((x_1280 << 15u) & 4022730752u));
    let x_1289 : u32 = (x_1285 ^ (x_1285 >> 18u));
    let x_1295 : u32 = (x_1289 + (x_1289 << 10u));
    let x_1299 : u32 = (x_1295 ^ (x_1295 >> 6u));
    let x_1303 : u32 = (x_1299 + (x_1299 << 3u));
    let x_1307 : u32 = (x_1303 ^ (x_1303 >> 11u));
    let x_1321 : vec3<u32> = bitcast<vec3<u32>>((x_569 + vec3<i32>(1i, 0i, 1i)));
    let x_1323 : u32 = x_1321.z;
    let x_1358 : u32 = (x_1323 + (x_1323 << 10u));
    let x_1362 : u32 = (x_1358 ^ (x_1358 >> 6u));
    let x_1366 : u32 = (x_1362 + (x_1362 << 3u));
    let x_1370 : u32 = (x_1366 ^ (x_1366 >> 11u));
    let x_1331 : u32 = ((((x_1321.y * 1664525u) + (x_1370 + (x_1370 << 15u))) + 1013904223u) * 1664525u);
    let x_1380 : u32 = (x_1331 ^ (x_1331 >> 11u));
    let x_1385 : u32 = (x_1380 ^ ((x_1380 << 7u) & 2636928640u));
    let x_1390 : u32 = (x_1385 ^ ((x_1385 << 15u) & 4022730752u));
    let x_1339 : u32 = ((((x_1321.x * 1664525u) + (x_1390 ^ (x_1390 >> 18u))) + 1013904223u) * 1664525u);
    let x_1400 : u32 = (x_1339 ^ (x_1339 >> 11u));
    let x_1405 : u32 = (x_1400 ^ ((x_1400 << 7u) & 2636928640u));
    let x_1410 : u32 = (x_1405 ^ ((x_1405 << 15u) & 4022730752u));
    let x_1414 : u32 = (x_1410 ^ (x_1410 >> 18u));
    let x_1420 : u32 = (x_1414 + (x_1414 << 10u));
    let x_1424 : u32 = (x_1420 ^ (x_1420 >> 6u));
    let x_1428 : u32 = (x_1424 + (x_1424 << 3u));
    let x_1432 : u32 = (x_1428 ^ (x_1428 >> 11u));
    let x_1446 : vec3<u32> = bitcast<vec3<u32>>((x_569 + vec3<i32>(0i, 1i, 1i)));
    let x_1448 : u32 = x_1446.z;
    let x_1483 : u32 = (x_1448 + (x_1448 << 10u));
    let x_1487 : u32 = (x_1483 ^ (x_1483 >> 6u));
    let x_1491 : u32 = (x_1487 + (x_1487 << 3u));
    let x_1495 : u32 = (x_1491 ^ (x_1491 >> 11u));
    let x_1456 : u32 = ((((x_1446.y * 1664525u) + (x_1495 + (x_1495 << 15u))) + 1013904223u) * 1664525u);
    let x_1505 : u32 = (x_1456 ^ (x_1456 >> 11u));
    let x_1510 : u32 = (x_1505 ^ ((x_1505 << 7u) & 2636928640u));
    let x_1515 : u32 = (x_1510 ^ ((x_1510 << 15u) & 4022730752u));
    let x_1464 : u32 = ((((x_1446.x * 1664525u) + (x_1515 ^ (x_1515 >> 18u))) + 1013904223u) * 1664525u);
    let x_1525 : u32 = (x_1464 ^ (x_1464 >> 11u));
    let x_1530 : u32 = (x_1525 ^ ((x_1525 << 7u) & 2636928640u));
    let x_1535 : u32 = (x_1530 ^ ((x_1530 << 15u) & 4022730752u));
    let x_1539 : u32 = (x_1535 ^ (x_1535 >> 18u));
    let x_1545 : u32 = (x_1539 + (x_1539 << 10u));
    let x_1549 : u32 = (x_1545 ^ (x_1545 >> 6u));
    let x_1553 : u32 = (x_1549 + (x_1549 << 3u));
    let x_1557 : u32 = (x_1553 ^ (x_1553 >> 11u));
    let x_1571 : vec3<u32> = bitcast<vec3<u32>>((x_569 + vec3<i32>(1i, 1i, 1i)));
    let x_1573 : u32 = x_1571.z;
    let x_1608 : u32 = (x_1573 + (x_1573 << 10u));
    let x_1612 : u32 = (x_1608 ^ (x_1608 >> 6u));
    let x_1616 : u32 = (x_1612 + (x_1612 << 3u));
    let x_1620 : u32 = (x_1616 ^ (x_1616 >> 11u));
    let x_1581 : u32 = ((((x_1571.y * 1664525u) + (x_1620 + (x_1620 << 15u))) + 1013904223u) * 1664525u);
    let x_1630 : u32 = (x_1581 ^ (x_1581 >> 11u));
    let x_1635 : u32 = (x_1630 ^ ((x_1630 << 7u) & 2636928640u));
    let x_1640 : u32 = (x_1635 ^ ((x_1635 << 15u) & 4022730752u));
    let x_1589 : u32 = ((((x_1571.x * 1664525u) + (x_1640 ^ (x_1640 >> 18u))) + 1013904223u) * 1664525u);
    let x_1650 : u32 = (x_1589 ^ (x_1589 >> 11u));
    let x_1655 : u32 = (x_1650 ^ ((x_1650 << 7u) & 2636928640u));
    let x_1660 : u32 = (x_1655 ^ ((x_1655 << 15u) & 4022730752u));
    let x_1664 : u32 = (x_1660 ^ (x_1660 >> 18u));
    let x_1670 : u32 = (x_1664 + (x_1664 << 10u));
    let x_1674 : u32 = (x_1670 ^ (x_1670 >> 6u));
    let x_1678 : u32 = (x_1674 + (x_1674 << 3u));
    let x_1682 : u32 = (x_1678 ^ (x_1678 >> 11u));
    let x_678 : vec2<f32> = clamp(((((((((((((vec2<f32>((bitcast<f32>(((x_789 & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_807 + (x_807 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)) * x_580) * x_584) * x_588) + (((vec2<f32>((bitcast<f32>(((x_914 & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_932 + (x_932 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)) * x_578) * x_584) * x_588)) + (((vec2<f32>((bitcast<f32>(((x_1039 & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_1057 + (x_1057 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)) * x_580) * x_582) * x_588)) + (((vec2<f32>((bitcast<f32>(((x_1164 & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_1182 + (x_1182 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)) * x_578) * x_582) * x_588)) + (((vec2<f32>((bitcast<f32>(((x_1289 & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_1307 + (x_1307 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)) * x_580) * x_584) * x_586)) + (((vec2<f32>((bitcast<f32>(((x_1414 & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_1432 + (x_1432 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)) * x_578) * x_584) * x_586)) + (((vec2<f32>((bitcast<f32>(((x_1539 & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_1557 + (x_1557 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)) * x_580) * x_582) * x_586)) + (((vec2<f32>((bitcast<f32>(((x_1664 & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_1682 + (x_1682 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)) * x_578) * x_582) * x_586)) - x_289) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_289);
    x_686 = (x_510 + (vec3<f32>(x_678.x, 0.0f, x_678.y) * 0.05999999865889549255f));
    x_1687 = x_686;
  } else {
    x_513 = decorationPosition;
    x_1687 = x_513;
  }
  let x_522 : vec4<f32> = (x_324 * vec4<f32>(x_1687.x, x_1687.y, x_1687.z, 1.0f));
  let x_530 : vec4<f32> = vec4<f32>(x_522.x, x_522.y, x_522.z, 1.0f);
  let x_531 : vec4<f32> = (x_489 * x_530);
  decorationPositionWS = vec3<f32>(x_531.x, x_531.y, x_531.z);
  let x_534 : mat4x4<f32> = x_333.renderer_MVPMat;
  gl_Position = (x_534 * x_530);
  let x_446 : f32 = gl_Position.z;
  let x_448 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_446 + x_448));
  return;
}

struct main_out {
  @location(0) @interpolate(flat)
  masonryPickIndex_1 : f32,
  @location(1)
  vertexTintRole_1 : f32,
  @location(2)
  vertexSourceColor_1 : vec3<f32>,
  @location(4)
  vertexNormal_1 : vec3<f32>,
  @location(5)
  vertexColor_1 : vec3<f32>,
  @location(6)
  vertexEmission_1 : f32,
  @location(7)
  vertexUV_1 : vec2<f32>,
  @location(8)
  vertexKind_1 : f32,
  @location(9)
  windowCenterWS_1 : vec3<f32>,
  @location(3)
  decorationPositionWS_1 : vec3<f32>,
  @builtin(position)
  gl_Position : vec4<f32>,
}

@vertex
fn main(@location(9) decorationPickIndex_param : f32, @location(7) decorationTintRole_param : f32, @location(8) decorationSourceColor_param : vec3<f32>, @location(1) decorationNormal_param : vec3<f32>, @location(2) decorationColor_param : vec3<f32>, @location(3) decorationEmission_param : f32, @location(4) decorationUV_param : vec2<f32>, @location(5) decorationKind_param : f32, @location(6) decorationCenter_param : vec3<f32>, @location(0) decorationPosition_param : vec3<f32>) -> main_out {
  decorationPickIndex = decorationPickIndex_param;
  decorationTintRole = decorationTintRole_param;
  decorationSourceColor = decorationSourceColor_param;
  decorationNormal = decorationNormal_param;
  decorationColor = decorationColor_param;
  decorationEmission = decorationEmission_param;
  decorationUV = decorationUV_param;
  decorationKind = decorationKind_param;
  decorationCenter = decorationCenter_param;
  decorationPosition = decorationPosition_param;
  main_1();
  return main_out(masonryPickIndex, vertexTintRole, vertexSourceColor, vertexNormal, vertexColor, vertexEmission, vertexUV, vertexKind, windowCenterWS, decorationPositionWS, gl_Position);
}
