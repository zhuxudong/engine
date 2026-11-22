diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  @size(64)
  padding : u32,
  /* @offset(64) */
  renderer_DormerGrid : vec4<f32>,
}

var<private> instanceRecord0 : vec4<u32>;

var<private> instanceRecord1 : vec4<u32>;

var<private> instanceRecord2 : vec4<u32>;

var<private> instanceRecord3 : vec4<u32>;

@binding(8) @group(3) var gs_wgpu_tex_storage_8_1 : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_storage_8_1 : sampler;

@binding(10) @group(3) var gs_wgpu_tex_storage_9_1 : texture_2d<u32>;

@binding(11) @group(3) var gs_wgpu_samp_storage_9_1 : sampler;

@binding(12) @group(3) var gs_wgpu_tex_storage_9_0 : texture_2d<u32>;

@binding(13) @group(3) var gs_wgpu_samp_storage_9_0 : sampler;

@binding(6) @group(3) var gs_wgpu_tex_uniform_FrameConstants_natural : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_uniform_FrameConstants_natural : sampler;

@binding(4) @group(3) var gs_wgpu_tex_uniform_ViewConstants_natural : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_uniform_ViewConstants_natural : sampler;

var<private> v6 : u32;

var<private> v0 : vec3<f32>;

var<private> v5 : vec4<f32>;

@binding(0) @group(2) var<uniform> x_624 : gs_Auto_0;

@binding(14) @group(3) var gs_wgpu_tex_roof_colors_tex : texture_2d_array<f32>;

@binding(15) @group(3) var gs_wgpu_samp_roof_colors_tex : sampler;

var<private> v7 : f32;

var<private> v8 : vec2<f32>;

var<private> v4 : vec2<f32>;

@binding(1) @group(2) var gs_wgpu_tex_material_data_roof_tile_damage : texture_2d<f32>;

@binding(2) @group(2) var gs_wgpu_samp_material_data_roof_tile_damage : sampler;

var<private> v1 : f32;

var<private> v2 : f32;

var<private> v3 : f32;

var<private> residentColor : vec4<f32>;

const x_699 = vec3<f32>(0.0f, 1.0f, 0.0f);

const x_1350 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_1357 = vec3<f32>(0.21259999275207519531f, 0.71520000696182250977f, 0.07220000028610229492f);

const x_1438 = vec3<f32>(0.5f, 0.5f, 0.5f);

fn main_1() {
  var x_3386 : u32;
  var x_25779 : u32;
  var x_25780 : u32;
  var x_1985 : bool;
  var x_33100 : bool;
  var x_1998 : bool;
  var x_34218 : bool;
  var x_5168 : u32;
  var x_26141 : u32;
  var x_26142 : u32;
  var x_9871 : u32;
  var x_26513 : u32;
  var x_26514 : u32;
  var x_10688 : u32;
  var x_26606 : u32;
  var x_26607 : u32;
  var x_2256 : bool;
  var x_26731 : bool;
  var x_2267 : bool;
  var x_26825 : bool;
  var x_2278 : bool;
  var x_26919 : bool;
  var x_2283 : vec3<f32>;
  var x_27398 : vec3<f32>;
  var x_32001 : vec3<f32>;
  var x_15590 : u32;
  var x_27460 : u32;
  var x_27461 : u32;
  var x_2328 : bool;
  var x_27585 : bool;
  var x_2339 : bool;
  var x_27679 : bool;
  var x_2350 : bool;
  var x_27773 : bool;
  var x_2361 : bool;
  var x_27867 : bool;
  var x_29271 : f32;
  var x_32812 : f32;
  var x_2419 : bool;
  var x_29272 : bool;
  var x_2424 : vec2<f32>;
  var x_2426 : vec2<f32>;
  var x_29273 : vec2<f32>;
  var x_2478 : vec3<f32>;
  var x_30512 : vec3<f32>;
  var x_23852 : u32;
  var x_30482 : u32;
  var x_30483 : u32;
  var x_2547 : vec3<f32>;
  var x_30795 : vec3<f32>;
  var x_25292 : u32;
  var x_30747 : u32;
  var x_30748 : u32;
  var x_2650 : vec3<f32>;
  var x_35161 : vec3<f32>;
  var x_2660 : vec3<f32>;
  var x_36546 : vec3<f32>;
  var x_2760 : vec3<f32>;
  var x_36746 : vec3<f32>;
  let x_1760 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_1765 : i32 = x_1760.x;
  let x_1772 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_1765), (8i / x_1765)), 0i);
  let x_1784 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_1765), (18i / x_1765)), 0i);
  let x_1786 : u32 = x_1772.w;
  let x_1789 : u32 = x_1784.x;
  let x_1792 : u32 = x_1784.y;
  let x_1801 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_1806 : i32 = x_1801.x;
  let x_1813 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_1806), (63i / x_1806)), 0i);
  let x_1816 : f32 = bitcast<f32>(x_1813.w);
  if ((1u == x_1792)) {
    var x_3379 : i32;
    var x_3394 : u32;
    var x_25778 : u32;
    let x_1979 : u32 = v6;
    x_3379 = (((bitcast<i32>(x_1979) * 16i) + 10i) % 16i);
    if ((x_3379 < 4i)) {
      x_3386 = instanceRecord0[(x_3379 % 4i)];
      x_25780 = x_3386;
    } else {
      var x_3402 : u32;
      var x_3407 : u32;
      if ((x_3379 < 8i)) {
        x_3394 = instanceRecord1[(x_3379 % 4i)];
        x_25779 = x_3394;
      } else {
        if ((x_3379 < 12i)) {
          x_3402 = instanceRecord2[(x_3379 % 4i)];
          x_25778 = x_3402;
        } else {
          x_3407 = instanceRecord3[(x_3379 % 4i)];
          x_25778 = x_3407;
        }
        x_25779 = x_25778;
      }
      x_25780 = x_25779;
    }
    x_1985 = (x_25780 == x_1789);
    x_33100 = x_1985;
  } else {
    x_33100 = false;
  }
  var x_4169 : u32;
  var x_25969 : u32;
  var x_25970 : u32;
  if ((2u == x_1792)) {
    var x_4162 : i32;
    var x_4177 : u32;
    var x_25968 : u32;
    let x_1992 : u32 = v6;
    x_4162 = (((bitcast<i32>(x_1992) * 16i) + 10i) % 16i);
    if ((x_4162 < 4i)) {
      x_4169 = instanceRecord0[(x_4162 % 4i)];
      x_25970 = x_4169;
    } else {
      var x_4185 : u32;
      var x_4190 : u32;
      if ((x_4162 < 8i)) {
        x_4177 = instanceRecord1[(x_4162 % 4i)];
        x_25969 = x_4177;
      } else {
        if ((x_4162 < 12i)) {
          x_4185 = instanceRecord2[(x_4162 % 4i)];
          x_25968 = x_4185;
        } else {
          x_4190 = instanceRecord3[(x_4162 % 4i)];
          x_25968 = x_4190;
        }
        x_25969 = x_25968;
      }
      x_25970 = x_25969;
    }
    x_1998 = (x_25970 == x_1789);
    x_34218 = x_1998;
  } else {
    x_34218 = false;
  }
  let x_2001 : vec3<f32> = v0;
  let x_2009 : vec3<f32> = normalize(cross(dpdx(x_2001), (dpdy(x_2001) * -1.0f)));
  let x_2015 : vec4<f32> = v5;
  if ((dot(vec4<f32>(x_2001.x, x_2001.y, x_2001.z, 1.0f), x_2015) < 0.0f)) {
    discard;
  }
  var x_5161 : i32;
  var x_5176 : u32;
  var x_26140 : u32;
  let x_2020 : u32 = v6;
  let x_4518 : i32 = (bitcast<i32>(x_2020) * 16i);
  x_5161 = ((x_4518 + 15i) % 16i);
  if ((x_5161 < 4i)) {
    x_5168 = instanceRecord0[(x_5161 % 4i)];
    x_26142 = x_5168;
  } else {
    var x_5184 : u32;
    var x_5189 : u32;
    if ((x_5161 < 8i)) {
      x_5176 = instanceRecord1[(x_5161 % 4i)];
      x_26141 = x_5176;
    } else {
      if ((x_5161 < 12i)) {
        x_5184 = instanceRecord2[(x_5161 % 4i)];
        x_26140 = x_5184;
      } else {
        x_5189 = instanceRecord3[(x_5161 % 4i)];
        x_26140 = x_5189;
      }
      x_26141 = x_26140;
    }
    x_26142 = x_26141;
  }
  var x_5741 : u32;
  var x_26204 : u32;
  var x_26205 : u32;
  var x_26450 : bool;
  var x_26451 : bool;
  if ((bitcast<i32>(x_26142) != 0i)) {
    var x_5734 : i32;
    var x_5749 : u32;
    var x_26203 : u32;
    x_5734 = ((x_4518 + 10i) % 16i);
    if ((x_5734 < 4i)) {
      x_5741 = instanceRecord0[(x_5734 % 4i)];
      x_26205 = x_5741;
    } else {
      var x_5757 : u32;
      var x_5762 : u32;
      if ((x_5734 < 8i)) {
        x_5749 = instanceRecord1[(x_5734 % 4i)];
        x_26204 = x_5749;
      } else {
        if ((x_5734 < 12i)) {
          x_5757 = instanceRecord2[(x_5734 % 4i)];
          x_26203 = x_5757;
        } else {
          x_5762 = instanceRecord3[(x_5734 % 4i)];
          x_26203 = x_5762;
        }
        x_26204 = x_26203;
      }
      x_26205 = x_26204;
    }
    let x_2030 : i32 = bitcast<i32>(x_26205);
    loop {
      var x_26236 : u32;
      var x_26449 : bool;
      let x_2036 : vec4<f32> = x_624.renderer_DormerGrid;
      let x_2042 : vec2<f32> = ((vec2<f32>(x_2001.x, x_2001.z) - vec2<f32>(x_2036.x, x_2036.y)) * vec2<f32>(x_2036.z, x_2036.w));
      let x_2052 : i32 = (i32(floor(x_2042.x)) + (15i * i32(floor(x_2042.y))));
      let x_5993 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_1, 0i));
      let x_5998 : i32 = (x_2052 / 4i);
      let x_6000 : i32 = x_5993.x;
      let x_6009 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_1, vec2<i32>((x_5998 % x_6000), (x_5998 / x_6000)), 0i);
      let x_2055 : u32 = min(128u, x_6009[(x_2052 % 4i)]);
      x_26236 = 0u;
      loop {
        if ((x_26236 >= x_2055)) {
          x_26450 = false;
          x_26449 = false;
          break;
        }
        var x_6048 : i32;
        var x_26241 : bool;
        var x_26242 : bool;
        var x_2194 : bool;
        var x_26243 : bool;
        x_6048 = (bitcast<i32>((bitcast<u32>((x_2052 * 50i)) + x_26236)) * 12i);
        let x_6049 : i32 = (x_6048 + 3i);
        let x_6192 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
        let x_6197 : i32 = (x_6049 / 4i);
        let x_6199 : i32 = x_6192.x;
        let x_6208 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_6197 % x_6199), (x_6197 / x_6199)), 0i);
        if ((x_2030 == bitcast<i32>(x_6208[(x_6049 % 4i)]))) {
          var x_2152 : f32;
          var x_8456 : i32;
          var x_8469 : i32;
          var x_2183 : bool;
          let x_6494 : i32 = (x_6048 + 8i);
          let x_6741 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_6746 : i32 = (x_6494 / 4i);
          let x_6748 : i32 = x_6741.x;
          let x_6757 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_6746 % x_6748), (x_6746 / x_6748)), 0i);
          let x_6915 : i32 = (x_6048 + 9i);
          let x_7182 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_7187 : i32 = (x_6915 / 4i);
          let x_7189 : i32 = x_7182.x;
          let x_7198 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_7187 % x_7189), (x_7187 / x_7189)), 0i);
          let x_2083 : vec3<f32> = vec3<f32>(bitcast<f32>(x_6757[(x_6494 % 4i)]), 0.0f, bitcast<f32>(x_7198[(x_6915 % 4i)]));
          let x_2100 : mat3x3<f32> = transpose(mat3x3<f32>(cross(x_2083, x_699), x_699, x_2083));
          let x_2102 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_2100);
          let x_2104 : vec3<f32> = (x_699 * x_2100);
          let x_2106 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_2100);
          let x_2109 : vec3<f32> = cross(x_2102, x_2104);
          let x_2113 : f32 = (1.0f / dot(x_2106, x_2109));
          let x_2114 : vec3<f32> = vec3<f32>(x_2113, x_2113, x_2113);
          let x_7353 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_7358 : i32 = (x_6048 / 4i);
          let x_7360 : i32 = x_7353.x;
          let x_7369 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_7358 % x_7360), (x_7358 / x_7360)), 0i);
          let x_7279 : i32 = (x_6048 + 1i);
          let x_7380 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_7385 : i32 = (x_7279 / 4i);
          let x_7387 : i32 = x_7380.x;
          let x_7396 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_7385 % x_7387), (x_7385 / x_7387)), 0i);
          let x_7285 : i32 = (x_6048 + 2i);
          let x_7407 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_7412 : i32 = (x_7285 / 4i);
          let x_7414 : i32 = x_7407.x;
          let x_7423 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_7412 % x_7414), (x_7412 / x_7414)), 0i);
          let x_7711 : i32 = (x_6048 + 4i);
          let x_7875 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_7880 : i32 = (x_7711 / 4i);
          let x_7882 : i32 = x_7875.x;
          let x_7891 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_7880 % x_7882), (x_7880 / x_7882)), 0i);
          let x_7718 : i32 = (x_6048 + 5i);
          let x_7902 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_7907 : i32 = (x_7718 / 4i);
          let x_7909 : i32 = x_7902.x;
          let x_7918 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_7907 % x_7909), (x_7907 / x_7909)), 0i);
          let x_7724 : i32 = (x_6048 + 6i);
          let x_7929 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_7934 : i32 = (x_7724 / 4i);
          let x_7936 : i32 = x_7929.x;
          let x_7945 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_7934 % x_7936), (x_7934 / x_7936)), 0i);
          let x_2150 : vec3<f32> = ((mat3x3<f32>((cross(x_2104, x_2106) * x_2114), (cross(x_2106, x_2102) * x_2114), (x_2109 * x_2114)) * (x_2001 - vec3<f32>(bitcast<f32>(x_7369[(x_6048 % 4i)]), bitcast<f32>(x_7396[(x_7279 % 4i)]), bitcast<f32>(x_7423[(x_7285 % 4i)])))) / vec3<f32>(bitcast<f32>(x_7891[(x_7711 % 4i)]), bitcast<f32>(x_7918[(x_7718 % 4i)]), bitcast<f32>(x_7945[(x_7724 % 4i)])));
          x_2152 = x_2150.y;
          let x_8163 : i32 = (x_6048 + 10i);
          let x_8451 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          x_8456 = (x_8163 / 4i);
          let x_8458 : i32 = x_8451.x;
          let x_8467 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_8456 % x_8458), (x_8456 / x_8458)), 0i);
          x_8469 = (x_8163 % 4i);
          let x_8583 : i32 = (x_6048 + 11i);
          let x_8892 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
          let x_8897 : i32 = (x_8583 / 4i);
          let x_8899 : i32 = x_8892.x;
          let x_8908 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_8897 % x_8899), (x_8897 / x_8899)), 0i);
          let x_2162 : f32 = clamp(((x_2152 * bitcast<f32>(x_8467[x_8469])) + bitcast<f32>(x_8908[(x_8583 % 4i)])), 0.0f, 1.0f);
          if ((abs(x_2150.x) < mix(0.5f, 0.0f, ((x_2162 * x_2162) * x_2162)))) {
            let x_9279 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
            let x_9286 : i32 = x_9279.x;
            let x_9295 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_8456 % x_9286), (x_8456 / x_9286)), 0i);
            if ((x_2152 < select(0.69999998807907104492f, 0.5f, (bitcast<f32>(x_9295[x_8469]) == 1.0f)))) {
              x_2183 = (x_2152 > -0.5f);
              x_26241 = x_2183;
            } else {
              x_26241 = false;
            }
            x_26242 = x_26241;
          } else {
            x_26242 = false;
          }
          if (x_26242) {
            x_2194 = (abs(x_2150.z) < 0.5f);
            x_26243 = x_2194;
          } else {
            x_26243 = false;
          }
          if (x_26243) {
            x_26450 = true;
            x_26449 = true;
            break;
          }
        }

        continuing {
          x_26236 = (x_26236 + 1u);
        }
      }
      if (x_26449) {
        x_26451 = x_26450;
        break;
      }
      x_26451 = false;
      break;
    }
    if (x_26451) {
      discard;
    }
  }
  var x_9879 : u32;
  var x_26512 : u32;
  let x_9864 : i32 = ((x_4518 + 10i) % 16i);
  let x_9866 : bool = (x_9864 < 4i);
  if (x_9866) {
    x_9871 = instanceRecord0[(x_9864 % 4i)];
    x_26514 = x_9871;
  } else {
    var x_9887 : u32;
    var x_9892 : u32;
    if ((x_9864 < 8i)) {
      x_9879 = instanceRecord1[(x_9864 % 4i)];
      x_26513 = x_9879;
    } else {
      if ((x_9864 < 12i)) {
        x_9887 = instanceRecord2[(x_9864 % 4i)];
        x_26512 = x_9887;
      } else {
        x_9892 = instanceRecord3[(x_9864 % 4i)];
        x_26512 = x_9892;
      }
      x_26513 = x_26512;
    }
    x_26514 = x_26513;
  }
  var x_10696 : u32;
  var x_26605 : u32;
  let x_2220 : i32 = bitcast<i32>(x_26514);
  let x_10123 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
  let x_10128 : i32 = (x_2220 / 4i);
  let x_10130 : i32 = x_10123.x;
  let x_10139 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_10128 % x_10130), (x_10128 / x_10130)), 0i);
  let x_2222 : bool = (x_10139[(x_2220 % 4i)] == 10u);
  let x_2228 : vec2<f32> = (vec2<f32>(x_2001.x, x_2001.z) * 0.20000000298023223877f);
  let x_2235 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_2228.x, x_2228.y, f32(select(1i, 7i, x_2222))).xy, i32(round(vec3<f32>(x_2228.x, x_2228.y, f32(select(1i, 7i, x_2222))).z)));
  let x_2239 : vec3<f32> = ((vec3<f32>(x_2235.x, x_2235.y, x_2235.z) * 0.60000002384185791016f) * 1.5f);
  if (x_9866) {
    x_10688 = instanceRecord0[(x_9864 % 4i)];
    x_26607 = x_10688;
  } else {
    var x_10704 : u32;
    var x_10709 : u32;
    if ((x_9864 < 8i)) {
      x_10696 = instanceRecord1[(x_9864 % 4i)];
      x_26606 = x_10696;
    } else {
      if ((x_9864 < 12i)) {
        x_10704 = instanceRecord2[(x_9864 % 4i)];
        x_26605 = x_10704;
      } else {
        x_10709 = instanceRecord3[(x_9864 % 4i)];
        x_26605 = x_10709;
      }
      x_26606 = x_26605;
    }
    x_26607 = x_26606;
  }
  var x_11505 : u32;
  var x_26699 : u32;
  var x_26700 : u32;
  let x_2244 : i32 = bitcast<i32>(x_26607);
  let x_10940 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
  let x_10945 : i32 = (x_2244 / 4i);
  let x_10947 : i32 = x_10940.x;
  let x_10956 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_10945 % x_10947), (x_10945 / x_10947)), 0i);
  let x_2246 : bool = (x_10956[(x_2244 % 4i)] == 0u);
  if (x_2246) {
    x_26731 = true;
  } else {
    var x_11513 : u32;
    var x_26698 : u32;
    if (x_9866) {
      x_11505 = instanceRecord0[(x_9864 % 4i)];
      x_26700 = x_11505;
    } else {
      var x_11521 : u32;
      var x_11526 : u32;
      if ((x_9864 < 8i)) {
        x_11513 = instanceRecord1[(x_9864 % 4i)];
        x_26699 = x_11513;
      } else {
        if ((x_9864 < 12i)) {
          x_11521 = instanceRecord2[(x_9864 % 4i)];
          x_26698 = x_11521;
        } else {
          x_11526 = instanceRecord3[(x_9864 % 4i)];
          x_26698 = x_11526;
        }
        x_26699 = x_26698;
      }
      x_26700 = x_26699;
    }
    let x_2254 : i32 = bitcast<i32>(x_26700);
    let x_11757 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
    let x_11762 : i32 = (x_2254 / 4i);
    let x_11764 : i32 = x_11757.x;
    let x_11773 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_11762 % x_11764), (x_11762 / x_11764)), 0i);
    x_2256 = (x_11773[(x_2254 % 4i)] == 8u);
    x_26731 = x_2256;
  }
  var x_12322 : u32;
  var x_26793 : u32;
  var x_26794 : u32;
  if (x_26731) {
    x_26825 = true;
  } else {
    var x_12330 : u32;
    var x_26792 : u32;
    if (x_9866) {
      x_12322 = instanceRecord0[(x_9864 % 4i)];
      x_26794 = x_12322;
    } else {
      var x_12338 : u32;
      var x_12343 : u32;
      if ((x_9864 < 8i)) {
        x_12330 = instanceRecord1[(x_9864 % 4i)];
        x_26793 = x_12330;
      } else {
        if ((x_9864 < 12i)) {
          x_12338 = instanceRecord2[(x_9864 % 4i)];
          x_26792 = x_12338;
        } else {
          x_12343 = instanceRecord3[(x_9864 % 4i)];
          x_26792 = x_12343;
        }
        x_26793 = x_26792;
      }
      x_26794 = x_26793;
    }
    let x_2265 : i32 = bitcast<i32>(x_26794);
    let x_12574 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
    let x_12579 : i32 = (x_2265 / 4i);
    let x_12581 : i32 = x_12574.x;
    let x_12590 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_12579 % x_12581), (x_12579 / x_12581)), 0i);
    x_2267 = (x_12590[(x_2265 % 4i)] == 7u);
    x_26825 = x_2267;
  }
  var x_13139 : u32;
  var x_26887 : u32;
  var x_26888 : u32;
  if (x_26825) {
    x_26919 = true;
  } else {
    var x_13147 : u32;
    var x_26886 : u32;
    if (x_9866) {
      x_13139 = instanceRecord0[(x_9864 % 4i)];
      x_26888 = x_13139;
    } else {
      var x_13155 : u32;
      var x_13160 : u32;
      if ((x_9864 < 8i)) {
        x_13147 = instanceRecord1[(x_9864 % 4i)];
        x_26887 = x_13147;
      } else {
        if ((x_9864 < 12i)) {
          x_13155 = instanceRecord2[(x_9864 % 4i)];
          x_26886 = x_13155;
        } else {
          x_13160 = instanceRecord3[(x_9864 % 4i)];
          x_26886 = x_13160;
        }
        x_26887 = x_26886;
      }
      x_26888 = x_26887;
    }
    let x_2276 : i32 = bitcast<i32>(x_26888);
    let x_13391 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
    let x_13396 : i32 = (x_2276 / 4i);
    let x_13398 : i32 = x_13391.x;
    let x_13407 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_13396 % x_13398), (x_13396 / x_13398)), 0i);
    x_2278 = (x_13407[(x_2276 % 4i)] == 6u);
    x_26919 = x_2278;
  }
  var x_13956 : u32;
  var x_26981 : u32;
  var x_26982 : u32;
  var x_2294 : vec3<f32>;
  var x_27397 : vec3<f32>;
  if (x_26919) {
    x_2283 = (x_2239 * 1.5f);
    x_32001 = x_2283;
  } else {
    var x_13964 : u32;
    var x_26980 : u32;
    if (x_9866) {
      x_13956 = instanceRecord0[(x_9864 % 4i)];
      x_26982 = x_13956;
    } else {
      var x_13972 : u32;
      var x_13977 : u32;
      if ((x_9864 < 8i)) {
        x_13964 = instanceRecord1[(x_9864 % 4i)];
        x_26981 = x_13964;
      } else {
        if ((x_9864 < 12i)) {
          x_13972 = instanceRecord2[(x_9864 % 4i)];
          x_26980 = x_13972;
        } else {
          x_13977 = instanceRecord3[(x_9864 % 4i)];
          x_26980 = x_13977;
        }
        x_26981 = x_26980;
      }
      x_26982 = x_26981;
    }
    var x_14773 : u32;
    var x_27074 : u32;
    var x_27075 : u32;
    var x_2305 : vec3<f32>;
    let x_2289 : i32 = bitcast<i32>(x_26982);
    let x_14208 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
    let x_14213 : i32 = (x_2289 / 4i);
    let x_14215 : i32 = x_14208.x;
    let x_14224 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_14213 % x_14215), (x_14213 / x_14215)), 0i);
    if ((x_14224[(x_2289 % 4i)] == 1u)) {
      x_2294 = (x_2239 * 0.34999999403953552246f);
      x_27398 = x_2294;
    } else {
      var x_14781 : u32;
      var x_27073 : u32;
      if (x_9866) {
        x_14773 = instanceRecord0[(x_9864 % 4i)];
        x_27075 = x_14773;
      } else {
        var x_14789 : u32;
        var x_14794 : u32;
        if ((x_9864 < 8i)) {
          x_14781 = instanceRecord1[(x_9864 % 4i)];
          x_27074 = x_14781;
        } else {
          if ((x_9864 < 12i)) {
            x_14789 = instanceRecord2[(x_9864 % 4i)];
            x_27073 = x_14789;
          } else {
            x_14794 = instanceRecord3[(x_9864 % 4i)];
            x_27073 = x_14794;
          }
          x_27074 = x_27073;
        }
        x_27075 = x_27074;
      }
      let x_2300 : i32 = bitcast<i32>(x_27075);
      let x_15025 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
      let x_15030 : i32 = (x_2300 / 4i);
      let x_15032 : i32 = x_15025.x;
      let x_15041 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_15030 % x_15032), (x_15030 / x_15032)), 0i);
      if ((x_15041[(x_2300 % 4i)] == 12u)) {
        x_2305 = (x_2239 * 0.5f);
        x_27397 = x_2305;
      } else {
        x_27397 = x_2239;
      }
      x_27398 = x_27397;
    }
    x_32001 = x_27398;
  }
  var x_15598 : u32;
  var x_27459 : u32;
  if (x_9866) {
    x_15590 = instanceRecord0[(x_9864 % 4i)];
    x_27461 = x_15590;
  } else {
    var x_15606 : u32;
    var x_15611 : u32;
    if ((x_9864 < 8i)) {
      x_15598 = instanceRecord1[(x_9864 % 4i)];
      x_27460 = x_15598;
    } else {
      if ((x_9864 < 12i)) {
        x_15606 = instanceRecord2[(x_9864 % 4i)];
        x_27459 = x_15606;
      } else {
        x_15611 = instanceRecord3[(x_9864 % 4i)];
        x_27459 = x_15611;
      }
      x_27460 = x_27459;
    }
    x_27461 = x_27460;
  }
  var x_16407 : u32;
  var x_27553 : u32;
  var x_27554 : u32;
  let x_2317 : i32 = bitcast<i32>(x_27461);
  let x_15842 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
  let x_15847 : i32 = (x_2317 / 4i);
  let x_15849 : i32 = x_15842.x;
  let x_15858 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_15847 % x_15849), (x_15847 / x_15849)), 0i);
  if ((x_15858[(x_2317 % 4i)] == 2u)) {
    x_27585 = true;
  } else {
    var x_16415 : u32;
    var x_27552 : u32;
    if (x_9866) {
      x_16407 = instanceRecord0[(x_9864 % 4i)];
      x_27554 = x_16407;
    } else {
      var x_16423 : u32;
      var x_16428 : u32;
      if ((x_9864 < 8i)) {
        x_16415 = instanceRecord1[(x_9864 % 4i)];
        x_27553 = x_16415;
      } else {
        if ((x_9864 < 12i)) {
          x_16423 = instanceRecord2[(x_9864 % 4i)];
          x_27552 = x_16423;
        } else {
          x_16428 = instanceRecord3[(x_9864 % 4i)];
          x_27552 = x_16428;
        }
        x_27553 = x_27552;
      }
      x_27554 = x_27553;
    }
    let x_2326 : i32 = bitcast<i32>(x_27554);
    let x_16659 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
    let x_16664 : i32 = (x_2326 / 4i);
    let x_16666 : i32 = x_16659.x;
    let x_16675 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_16664 % x_16666), (x_16664 / x_16666)), 0i);
    x_2328 = (x_16675[(x_2326 % 4i)] == 3u);
    x_27585 = x_2328;
  }
  var x_17224 : u32;
  var x_27647 : u32;
  var x_27648 : u32;
  if (x_27585) {
    x_27679 = true;
  } else {
    var x_17232 : u32;
    var x_27646 : u32;
    if (x_9866) {
      x_17224 = instanceRecord0[(x_9864 % 4i)];
      x_27648 = x_17224;
    } else {
      var x_17240 : u32;
      var x_17245 : u32;
      if ((x_9864 < 8i)) {
        x_17232 = instanceRecord1[(x_9864 % 4i)];
        x_27647 = x_17232;
      } else {
        if ((x_9864 < 12i)) {
          x_17240 = instanceRecord2[(x_9864 % 4i)];
          x_27646 = x_17240;
        } else {
          x_17245 = instanceRecord3[(x_9864 % 4i)];
          x_27646 = x_17245;
        }
        x_27647 = x_27646;
      }
      x_27648 = x_27647;
    }
    let x_2337 : i32 = bitcast<i32>(x_27648);
    let x_17476 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
    let x_17481 : i32 = (x_2337 / 4i);
    let x_17483 : i32 = x_17476.x;
    let x_17492 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_17481 % x_17483), (x_17481 / x_17483)), 0i);
    x_2339 = (x_17492[(x_2337 % 4i)] == 4u);
    x_27679 = x_2339;
  }
  var x_18041 : u32;
  var x_27741 : u32;
  var x_27742 : u32;
  if (x_27679) {
    x_27773 = true;
  } else {
    var x_18049 : u32;
    var x_27740 : u32;
    if (x_9866) {
      x_18041 = instanceRecord0[(x_9864 % 4i)];
      x_27742 = x_18041;
    } else {
      var x_18057 : u32;
      var x_18062 : u32;
      if ((x_9864 < 8i)) {
        x_18049 = instanceRecord1[(x_9864 % 4i)];
        x_27741 = x_18049;
      } else {
        if ((x_9864 < 12i)) {
          x_18057 = instanceRecord2[(x_9864 % 4i)];
          x_27740 = x_18057;
        } else {
          x_18062 = instanceRecord3[(x_9864 % 4i)];
          x_27740 = x_18062;
        }
        x_27741 = x_27740;
      }
      x_27742 = x_27741;
    }
    let x_2348 : i32 = bitcast<i32>(x_27742);
    let x_18293 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
    let x_18298 : i32 = (x_2348 / 4i);
    let x_18300 : i32 = x_18293.x;
    let x_18309 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_18298 % x_18300), (x_18298 / x_18300)), 0i);
    x_2350 = (x_18309[(x_2348 % 4i)] == 6u);
    x_27773 = x_2350;
  }
  var x_18858 : u32;
  var x_27835 : u32;
  var x_27836 : u32;
  if (x_27773) {
    x_27867 = true;
  } else {
    var x_18866 : u32;
    var x_27834 : u32;
    if (x_9866) {
      x_18858 = instanceRecord0[(x_9864 % 4i)];
      x_27836 = x_18858;
    } else {
      var x_18874 : u32;
      var x_18879 : u32;
      if ((x_9864 < 8i)) {
        x_18866 = instanceRecord1[(x_9864 % 4i)];
        x_27835 = x_18866;
      } else {
        if ((x_9864 < 12i)) {
          x_18874 = instanceRecord2[(x_9864 % 4i)];
          x_27834 = x_18874;
        } else {
          x_18879 = instanceRecord3[(x_9864 % 4i)];
          x_27834 = x_18879;
        }
        x_27835 = x_27834;
      }
      x_27836 = x_27835;
    }
    let x_2359 : i32 = bitcast<i32>(x_27836);
    let x_19110 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
    let x_19115 : i32 = (x_2359 / 4i);
    let x_19117 : i32 = x_19110.x;
    let x_19126 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_19115 % x_19117), (x_19115 / x_19117)), 0i);
    x_2361 = (x_19126[(x_2359 % 4i)] == 9u);
    x_27867 = x_2361;
  }
  var x_2377 : bool;
  var x_28989 : bool;
  var x_2388 : bool;
  var x_29083 : bool;
  var x_2399 : bool;
  var x_29177 : bool;
  var x_2411 : f32;
  if (select(x_2222, true, x_27867)) {
    x_32812 = 0.5f;
  } else {
    var x_19675 : u32;
    var x_28957 : u32;
    var x_28958 : u32;
    if (x_2246) {
      x_28989 = true;
    } else {
      var x_19683 : u32;
      var x_28956 : u32;
      if (x_9866) {
        x_19675 = instanceRecord0[(x_9864 % 4i)];
        x_28958 = x_19675;
      } else {
        var x_19691 : u32;
        var x_19696 : u32;
        if ((x_9864 < 8i)) {
          x_19683 = instanceRecord1[(x_9864 % 4i)];
          x_28957 = x_19683;
        } else {
          if ((x_9864 < 12i)) {
            x_19691 = instanceRecord2[(x_9864 % 4i)];
            x_28956 = x_19691;
          } else {
            x_19696 = instanceRecord3[(x_9864 % 4i)];
            x_28956 = x_19696;
          }
          x_28957 = x_28956;
        }
        x_28958 = x_28957;
      }
      let x_2375 : i32 = bitcast<i32>(x_28958);
      let x_19927 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
      let x_19932 : i32 = (x_2375 / 4i);
      let x_19934 : i32 = x_19927.x;
      let x_19943 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_19932 % x_19934), (x_19932 / x_19934)), 0i);
      x_2377 = (x_19943[(x_2375 % 4i)] == 5u);
      x_28989 = x_2377;
    }
    var x_20492 : u32;
    var x_29051 : u32;
    var x_29052 : u32;
    if (x_28989) {
      x_29083 = true;
    } else {
      var x_20500 : u32;
      var x_29050 : u32;
      if (x_9866) {
        x_20492 = instanceRecord0[(x_9864 % 4i)];
        x_29052 = x_20492;
      } else {
        var x_20508 : u32;
        var x_20513 : u32;
        if ((x_9864 < 8i)) {
          x_20500 = instanceRecord1[(x_9864 % 4i)];
          x_29051 = x_20500;
        } else {
          if ((x_9864 < 12i)) {
            x_20508 = instanceRecord2[(x_9864 % 4i)];
            x_29050 = x_20508;
          } else {
            x_20513 = instanceRecord3[(x_9864 % 4i)];
            x_29050 = x_20513;
          }
          x_29051 = x_29050;
        }
        x_29052 = x_29051;
      }
      let x_2386 : i32 = bitcast<i32>(x_29052);
      let x_20744 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
      let x_20749 : i32 = (x_2386 / 4i);
      let x_20751 : i32 = x_20744.x;
      let x_20760 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_20749 % x_20751), (x_20749 / x_20751)), 0i);
      x_2388 = (x_20760[(x_2386 % 4i)] == 7u);
      x_29083 = x_2388;
    }
    var x_21309 : u32;
    var x_29145 : u32;
    var x_29146 : u32;
    if (x_29083) {
      x_29177 = true;
    } else {
      var x_21317 : u32;
      var x_29144 : u32;
      if (x_9866) {
        x_21309 = instanceRecord0[(x_9864 % 4i)];
        x_29146 = x_21309;
      } else {
        var x_21325 : u32;
        var x_21330 : u32;
        if ((x_9864 < 8i)) {
          x_21317 = instanceRecord1[(x_9864 % 4i)];
          x_29145 = x_21317;
        } else {
          if ((x_9864 < 12i)) {
            x_21325 = instanceRecord2[(x_9864 % 4i)];
            x_29144 = x_21325;
          } else {
            x_21330 = instanceRecord3[(x_9864 % 4i)];
            x_29144 = x_21330;
          }
          x_29145 = x_29144;
        }
        x_29146 = x_29145;
      }
      let x_2397 : i32 = bitcast<i32>(x_29146);
      let x_21561 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
      let x_21566 : i32 = (x_2397 / 4i);
      let x_21568 : i32 = x_21561.x;
      let x_21577 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_21566 % x_21568), (x_21566 / x_21568)), 0i);
      x_2399 = (x_21577[(x_2397 % 4i)] == 8u);
      x_29177 = x_2399;
    }
    var x_22126 : u32;
    var x_29239 : u32;
    var x_29240 : u32;
    if (x_29177) {
      x_29271 = 1.0f;
    } else {
      var x_22134 : u32;
      var x_29238 : u32;
      if (x_9866) {
        x_22126 = instanceRecord0[(x_9864 % 4i)];
        x_29240 = x_22126;
      } else {
        var x_22142 : u32;
        var x_22147 : u32;
        if ((x_9864 < 8i)) {
          x_22134 = instanceRecord1[(x_9864 % 4i)];
          x_29239 = x_22134;
        } else {
          if ((x_9864 < 12i)) {
            x_22142 = instanceRecord2[(x_9864 % 4i)];
            x_29238 = x_22142;
          } else {
            x_22147 = instanceRecord3[(x_9864 % 4i)];
            x_29238 = x_22147;
          }
          x_29239 = x_29238;
        }
        x_29240 = x_29239;
      }
      let x_2408 : i32 = bitcast<i32>(x_29240);
      let x_22378 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
      let x_22383 : i32 = (x_2408 / 4i);
      let x_22385 : i32 = x_22378.x;
      let x_22394 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_22383 % x_22385), (x_22383 / x_22385)), 0i);
      x_2411 = select(0.75f, 2.0f, (x_22394[(x_2408 % 4i)] == 1u));
      x_29271 = x_2411;
    }
    x_32812 = x_29271;
  }
  let x_2415 : f32 = v7;
  if ((x_2415 > -0.94999998807907104492f)) {
    x_2419 = (x_2415 < 0.89999997615814208984f);
    x_29272 = x_2419;
  } else {
    x_29272 = false;
  }
  if (x_29272) {
    x_2424 = v8;
    x_29273 = x_2424;
  } else {
    x_2426 = v4;
    x_29273 = x_2426;
  }
  var x_23069 : u32;
  var x_30341 : u32;
  var x_30342 : u32;
  let x_2434 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_roof_tile_damage, gs_wgpu_samp_material_data_roof_tile_damage, x_29273, x_1816);
  let x_2437 : f32 = (1.0f - x_2434.x);
  let x_2439 : f32 = v1;
  let x_2440 : f32 = (x_2437 * x_2439);
  let x_2442 : vec3<f32> = (x_2001 * 0.10000000149011611938f);
  if ((x_2440 > 0.00999999977648258209f)) {
    var x_23062 : i32;
    var x_23077 : u32;
    var x_30340 : u32;
    x_23062 = ((x_4518 + 13i) % 16i);
    if ((x_23062 < 4i)) {
      x_23069 = instanceRecord0[(x_23062 % 4i)];
      x_30342 = x_23069;
    } else {
      var x_23085 : u32;
      var x_23090 : u32;
      if ((x_23062 < 8i)) {
        x_23077 = instanceRecord1[(x_23062 % 4i)];
        x_30341 = x_23077;
      } else {
        if ((x_23062 < 12i)) {
          x_23085 = instanceRecord2[(x_23062 % 4i)];
          x_30340 = x_23085;
        } else {
          x_23090 = instanceRecord3[(x_23062 % 4i)];
          x_30340 = x_23090;
        }
        x_30341 = x_30340;
      }
      x_30342 = x_30341;
    }
    let x_2451 : u32 = bitcast<u32>((bitcast<i32>(x_30342) ^ 2834i));
    let x_2455 : u32 = (x_2451 + (x_2451 << 10u));
    let x_2459 : u32 = (x_2455 ^ (x_2455 >> 6u));
    let x_2463 : u32 = (x_2459 + (x_2459 << 3u));
    let x_2467 : u32 = (x_2463 ^ (x_2463 >> 11u));
    let x_2476 : f32 = (bitcast<f32>((((x_2467 + (x_2467 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
    x_2478 = (x_2442 + vec3<f32>(x_2476, x_2476, x_2476));
    x_30512 = x_2478;
  } else {
    x_30512 = x_2442;
  }
  var x_23860 : u32;
  var x_30481 : u32;
  let x_23845 : i32 = ((x_4518 + 13i) % 16i);
  let x_23847 : bool = (x_23845 < 4i);
  if (x_23847) {
    x_23852 = instanceRecord0[(x_23845 % 4i)];
    x_30483 = x_23852;
  } else {
    var x_23868 : u32;
    var x_23873 : u32;
    if ((x_23845 < 8i)) {
      x_23860 = instanceRecord1[(x_23845 % 4i)];
      x_30482 = x_23860;
    } else {
      if ((x_23845 < 12i)) {
        x_23868 = instanceRecord2[(x_23845 % 4i)];
        x_30481 = x_23868;
      } else {
        x_23873 = instanceRecord3[(x_23845 % 4i)];
        x_30481 = x_23873;
      }
      x_30482 = x_30481;
    }
    x_30483 = x_30482;
  }
  var x_24635 : u32;
  var x_30624 : u32;
  var x_30625 : u32;
  let x_2487 : u32 = bitcast<u32>((bitcast<i32>(x_30483) ^ 34534i));
  let x_2491 : u32 = (x_2487 + (x_2487 << 10u));
  let x_2495 : u32 = (x_2491 ^ (x_2491 >> 6u));
  let x_2499 : u32 = (x_2495 + (x_2495 << 3u));
  let x_2503 : u32 = (x_2499 ^ (x_2499 >> 11u));
  if (((bitcast<f32>((((x_2503 + (x_2503 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) < 0.5f)) {
    var x_24643 : u32;
    var x_30623 : u32;
    if (x_23847) {
      x_24635 = instanceRecord0[(x_23845 % 4i)];
      x_30625 = x_24635;
    } else {
      var x_24651 : u32;
      var x_24656 : u32;
      if ((x_23845 < 8i)) {
        x_24643 = instanceRecord1[(x_23845 % 4i)];
        x_30624 = x_24643;
      } else {
        if ((x_23845 < 12i)) {
          x_24651 = instanceRecord2[(x_23845 % 4i)];
          x_30623 = x_24651;
        } else {
          x_24656 = instanceRecord3[(x_23845 % 4i)];
          x_30623 = x_24656;
        }
        x_30624 = x_30623;
      }
      x_30625 = x_30624;
    }
    let x_2519 : u32 = bitcast<u32>((bitcast<i32>(x_30625) ^ 234i));
    let x_2523 : u32 = (x_2519 + (x_2519 << 10u));
    let x_2527 : u32 = (x_2523 ^ (x_2523 >> 6u));
    let x_2531 : u32 = (x_2527 + (x_2527 << 3u));
    let x_2535 : u32 = (x_2531 ^ (x_2531 >> 11u));
    let x_2545 : f32 = ((bitcast<f32>((((x_2535 + (x_2535 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) * 0.40000000596046447754f);
    x_2547 = (x_30512 + vec3<f32>(x_2545, x_2545, x_2545));
    x_30795 = x_2547;
  } else {
    x_30795 = x_30512;
  }
  var x_25300 : u32;
  var x_30746 : u32;
  if (x_9866) {
    x_25292 = instanceRecord0[(x_9864 % 4i)];
    x_30748 = x_25292;
  } else {
    var x_25308 : u32;
    var x_25313 : u32;
    if ((x_9864 < 8i)) {
      x_25300 = instanceRecord1[(x_9864 % 4i)];
      x_30747 = x_25300;
    } else {
      if ((x_9864 < 12i)) {
        x_25308 = instanceRecord2[(x_9864 % 4i)];
        x_30746 = x_25308;
      } else {
        x_25313 = instanceRecord3[(x_9864 % 4i)];
        x_30746 = x_25313;
      }
      x_30747 = x_30746;
    }
    x_30748 = x_30747;
  }
  let x_2555 : i32 = bitcast<i32>(x_30748);
  let x_25544 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_1, 0i));
  let x_25549 : i32 = (x_2555 / 4i);
  let x_25551 : i32 = x_25544.x;
  let x_25560 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_1, vec2<i32>((x_25549 % x_25551), (x_25549 / x_25551)), 0i);
  let x_2557 : f32 = f32(x_25560[(x_2555 % 4i)]);
  let x_2565 : f32 = x_30795.y;
  let x_2567 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_30795.z, x_2565, x_2557).xy, i32(round(vec3<f32>(x_30795.z, x_2565, x_2557).z)));
  let x_2569 : vec3<f32> = vec3<f32>(x_2567.x, x_2567.y, x_2567.z);
  let x_2579 : vec4<f32> = textureSample(gs_wgpu_tex_roof_colors_tex, gs_wgpu_samp_roof_colors_tex, vec3<f32>(x_30795.x, x_2565, x_2557).xy, i32(round(vec3<f32>(x_30795.x, x_2565, x_2557).z)));
  let x_2581 : vec3<f32> = vec3<f32>(x_2579.x, x_2579.y, x_2579.z);
  let x_2584 : vec3<f32> = pow(abs(x_2009), x_1350);
  let x_2589 : f32 = (dot(x_2569, x_1357) + x_2584.x);
  let x_2594 : f32 = (dot(x_2581, x_1357) + x_2584.z);
  let x_2598 : f32 = (max(x_2589, x_2594) - 0.20000000298023223877f);
  let x_2602 : f32 = max((x_2589 - x_2598), 0.0f);
  let x_2606 : f32 = max((x_2594 - x_2598), 0.0f);
  let x_2616 : f32 = (x_2602 + x_2606);
  let x_2619 : vec3<f32> = ((((x_2569 * x_2602) + (x_2581 * x_2606)) / vec3<f32>(x_2616, x_2616, x_2616)) * 0.60000002384185791016f);
  let x_2627 : f32 = clamp((1.0f - (x_2439 * 3.0f)), 0.0f, 1.0f);
  let x_2636 : f32 = v2;
  let x_2638 : f32 = clamp(((clamp((x_2440 * 5.0f), 0.0f, 1.0f) * x_32812) + x_2636), 0.0f, 1.0f);
  let x_2640 : vec3<f32> = mix(mix((x_2619 * 0.89999997615814208984f), (x_2619 * 1.29999995231628417969f), vec3<f32>(x_2627, x_2627, x_2627)), x_32001, vec3<f32>(x_2638, x_2638, x_2638));
  let x_2646 : vec3<f32> = mix(x_2640, (x_2640 * 0.89999997615814208984f), vec3<f32>(x_2440, x_2440, x_2440));
  if (x_33100) {
    x_2650 = mix(x_2646, vec3<f32>(0.30000001192092895508f, 0.09000000357627868652f, 0.0f), x_1438);
    x_35161 = x_2650;
  } else {
    x_35161 = x_2646;
  }
  if (x_34218) {
    x_2660 = mix(x_35161, x_1438, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
    x_36546 = x_2660;
  } else {
    x_36546 = x_35161;
  }
  if ((x_1786 == 4u)) {
    let x_2750 : f32 = v3;
    let x_2758 : f32 = ((smoothstep(0.10000000149011611938f, 1.0f, x_2750) * 0.5f) + ((x_2437 * 0.5f) * smoothstep(0.0f, 0.5f, x_2750)));
    x_2760 = mix(x_36546, vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f), vec3<f32>(x_2758, x_2758, x_2758));
    x_36746 = x_2760;
  } else {
    x_36746 = x_36546;
  }
  let x_2769 : vec3<f32> = sqrt(clamp(x_36746, vec3<f32>(0.0f, 0.0f, 0.0f), x_1350));
  let x_2836 : u32 = (((u32(((clamp(x_2769.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_2769.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_2769.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(117440512u, 251658240u, select(x_33100, true, x_34218)));
  let x_1732 : vec3<f32> = vec3<f32>(f32((x_2836 & 255u)), f32(((x_2836 >> 8u) & 255u)), f32(((x_2836 >> 16u) & 255u)));
  let x_1737 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_1732 * x_1732));
  let x_1747 : vec3<f32> = select((x_1737 * 12.9200000762939453125f), ((pow(x_1737, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_1737 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_1747.x, x_1747.y, x_1747.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(0) @interpolate(flat) instanceRecord0_param : vec4<u32>, @location(1) @interpolate(flat) instanceRecord1_param : vec4<u32>, @location(2) @interpolate(flat) instanceRecord2_param : vec4<u32>, @location(3) @interpolate(flat) instanceRecord3_param : vec4<u32>, @location(10) @interpolate(flat) v6_param : u32, @location(4) v0_param : vec3<f32>, @location(9) @interpolate(flat) v5_param : vec4<f32>, @location(11) v7_param : f32, @location(12) v8_param : vec2<f32>, @location(8) v4_param : vec2<f32>, @location(5) v1_param : f32, @location(6) v2_param : f32, @location(7) v3_param : f32) -> main_out {
  instanceRecord0 = instanceRecord0_param;
  instanceRecord1 = instanceRecord1_param;
  instanceRecord2 = instanceRecord2_param;
  instanceRecord3 = instanceRecord3_param;
  v6 = v6_param;
  v0 = v0_param;
  v5 = v5_param;
  v7 = v7_param;
  v8 = v8_param;
  v4 = v4_param;
  v1 = v1_param;
  v2 = v2_param;
  v3 = v3_param;
  main_1();
  return main_out(residentColor);
}
