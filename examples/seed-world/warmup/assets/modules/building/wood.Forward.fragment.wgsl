diagnostic(off, derivative_uniformity);
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

var<private> residentColor : vec4<f32>;

const x_427 = vec3<f32>(0.69999998807907104492f, 0.21000000834465026855f, 0.0f);

const x_429 = vec3<f32>(0.5f, 0.5f, 0.5f);

const x_530 = vec3<f32>(0.69999998807907104492f, 0.69999998807907104492f, 0.69999998807907104492f);

fn main_1() {
  var x_1201 : u32;
  var x_1235 : u32;
  var x_1254 : u32;
  var x_907 : i32;
  var x_1255 : i32;
  var x_1262 : i32;
  var x_933 : vec3<f32>;
  var x_948 : vec3<f32>;
  var x_1271 : vec3<f32>;
  var x_1317 : vec3<f32>;
  var x_1033 : bool;
  var x_1353 : bool;
  var x_1331 : vec3<f32>;
  var x_1043 : bool;
  var x_1329 : bool;
  var x_1346 : vec3<f32>;
  var x_1349 : vec3<f32>;
  let x_745 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_750 : i32 = x_745.x;
  let x_757 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_750), (63i / x_750)), 0i);
  let x_760 : f32 = bitcast<f32>(x_757.w);
  let x_772 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_FrameConstants_natural, 0i));
  let x_777 : i32 = x_772.x;
  let x_784 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((8i % x_777), (8i / x_777)), 0i);
  let x_796 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((17i % x_777), (17i / x_777)), 0i);
  let x_808 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((18i % x_777), (18i / x_777)), 0i);
  let x_820 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameConstants_natural, vec2<i32>((19i % x_777), (19i / x_777)), 0i);
  let x_822 : u32 = x_784.w;
  let x_826 : f32 = bitcast<f32>(x_796.x);
  let x_832 : f32 = bitcast<f32>(x_796.z);
  let x_837 : f32 = bitcast<f32>(x_796.w);
  let x_840 : u32 = x_808.z;
  let x_843 : u32 = x_808.w;
  let x_846 : u32 = x_820.x;
  let x_887 : vec3<f32> = v1;
  let x_888 : vec3<f32> = normalize(x_887);
  let x_892 : vec3<f32> = v0;
  let x_893 : vec2<f32> = v7;
  let x_894 : i32 = v12;
  let x_895 : bool = (x_894 > 0i);
  if (x_895) {
    let x_898 : i32 = v8;
    let x_1182 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_9_0, 0i));
    let x_1187 : i32 = (x_898 / 4i);
    let x_1189 : i32 = x_1182.x;
    let x_1198 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_9_0, vec2<i32>((x_1187 % x_1189), (x_1187 / x_1189)), 0i);
    x_1201 = x_1198[(x_898 % 4i)];
    x_1254 = x_1201;
  } else {
    let x_901 : i32 = v8;
    let x_1216 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_8_0, 0i));
    let x_1221 : i32 = (x_901 / 4i);
    let x_1223 : i32 = x_1216.x;
    let x_1232 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_8_0, vec2<i32>((x_1221 % x_1223), (x_1221 / x_1223)), 0i);
    x_1235 = x_1232[(x_901 % 4i)];
    x_1254 = x_1235;
  }
  var x_914 : i32;
  let x_904 : i32 = v11;
  if ((x_904 > 0i)) {
    x_907 = v8;
    x_1262 = x_907;
  } else {
    let x_909 : i32 = v6;
    if ((x_909 != 0i)) {
      x_1255 = 0i;
    } else {
      x_914 = bitcast<i32>(x_1254);
      x_1255 = x_914;
    }
    x_1262 = x_1255;
  }
  if (x_895) {
    let x_932 : vec4<f32> = textureSampleBias(gs_wgpu_tex_wooden_wall_colors_tex, gs_wgpu_samp_wooden_wall_colors_tex, vec3<f32>(x_893.x, x_893.y, f32(x_1262)).xy, i32(round(vec3<f32>(x_893.x, x_893.y, f32(x_1262)).z)), x_760);
    x_933 = vec3<f32>(x_932.x, x_932.y, x_932.z);
    x_1271 = x_933;
  } else {
    let x_947 : vec4<f32> = textureSampleBias(gs_wgpu_tex_halftimber_colors_tex, gs_wgpu_samp_halftimber_colors_tex, vec3<f32>(x_893.x, x_893.y, f32(x_1262)).xy, i32(round(vec3<f32>(x_893.x, x_893.y, f32(x_1262)).z)), x_760);
    x_948 = vec3<f32>(x_947.x, x_947.y, x_947.z);
    x_1271 = x_948;
  }
  var x_990 : vec3<f32>;
  var x_993 : bool;
  var x_1290 : vec3<f32>;
  var x_1316 : bool;
  var x_1309 : vec3<f32>;
  var x_1021 : bool;
  var x_1307 : bool;
  var x_1027 : vec3<f32>;
  let x_953 : i32 = v5;
  let x_961 : vec3<f32> = mix(x_1271, (x_1271 * 1.10000002384185791016f), vec3<f32>(vec3<i32>(x_953, x_953, x_953)));
  let x_968 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_wood_roughness, gs_wgpu_samp_material_data_wood_roughness, x_893, x_760);
  let x_972 : f32 = mix(0.69999998807907104492f, 0.89999997615814208984f, smoothstep(0.89999997615814208984f, 1.0f, x_968.x));
  let x_973 : i32 = v10;
  if ((x_973 == 0i)) {
    var x_1370 : u32;
    var x_997 : vec3<f32>;
    let x_976 : i32 = v8;
    x_1370 = select(0u, x_843, (bitcast<u32>(x_976) == x_840));
    if ((x_1370 == 1u)) {
      x_990 = mix(x_961, x_427, x_429);
      x_1316 = true;
      x_1309 = x_990;
    } else {
      x_993 = (x_1370 == 2u);
      if (x_993) {
        x_997 = mix(x_961, x_429, vec3<f32>(0.10000000149011611938f, 0.10000000149011611938f, 0.10000000149011611938f));
        x_1290 = x_997;
      } else {
        x_1290 = x_961;
      }
      x_1316 = x_993;
      x_1309 = x_1290;
    }
    if ((x_846 == 1u)) {
      x_1021 = (distance(vec2<f32>(x_826, x_832), vec2<f32>(x_892.x, x_892.z)) < ((1.88900005817413330078f * x_837) - 0.20000000298023223877f));
      x_1307 = x_1021;
    } else {
      x_1307 = false;
    }
    if (x_1307) {
      x_1027 = mix(x_961, x_427, vec3<f32>(0.80000001192092895508f, 0.80000001192092895508f, 0.80000001192092895508f));
      x_1317 = x_1027;
    } else {
      x_1317 = x_1309;
    }
    x_1033 = select(x_1316, true, x_1307);
    x_1353 = x_1033;
    x_1331 = x_1317;
  } else {
    x_1353 = false;
    x_1331 = x_961;
  }
  if ((x_822 == 4u)) {
    let x_1042 : i32 = v13;
    x_1043 = (x_1042 == 0i);
    x_1329 = x_1043;
  } else {
    x_1329 = false;
  }
  var x_1083 : vec3<f32>;
  var x_1093 : vec3<f32>;
  if (x_1329) {
    let x_1050 : f32 = smoothstep(-0.10000000149011611938f, 0.0f, x_892.y);
    let x_1051 : i32 = v9;
    if ((x_1051 > 0i)) {
      let x_1062 : vec4<f32> = textureSampleBias(gs_wgpu_tex_material_data_dirtpath_heightmap, gs_wgpu_samp_material_data_dirtpath_heightmap, (vec2<f32>(x_892.x, x_892.z) * 0.05000000074505805969f), x_760);
      let x_1064 : f32 = x_1062.x;
      let x_1081 : f32 = ((((smoothstep(0.0f, 0.20000000298023223877f, (smoothstep(0.5f, 1.0f, x_972) * mix(0.0f, 0.5f, x_1064))) * 0.60000002384185791016f) + (x_1064 * 0.20000000298023223877f)) * clamp(x_888.y, 0.0f, 1.0f)) * x_1050);
      x_1083 = mix(x_1331, x_530, vec3<f32>(x_1081, x_1081, x_1081));
      x_1346 = x_1083;
    } else {
      let x_1091 : f32 = (x_1050 * smoothstep(0.5f, 1.0f, clamp(x_888.y, 0.0f, 1.0f)));
      x_1093 = mix(x_1331, x_530, vec3<f32>(x_1091, x_1091, x_1091));
      x_1346 = x_1093;
    }
    x_1349 = x_1346;
  } else {
    x_1349 = x_1331;
  }
  let x_1134 : vec3<f32> = sqrt(clamp(x_1349, vec3<f32>(0.0f, 0.0f, 0.0f), vec3<f32>(1.0f, 1.0f, 1.0f)));
  let x_1165 : u32 = (((u32(((clamp(x_1134.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_1134.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_1134.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u)) | select(117440512u, 251658240u, x_1353));
  let x_718 : vec3<f32> = vec3<f32>(f32((x_1165 & 255u)), f32(((x_1165 >> 8u) & 255u)), f32(((x_1165 >> 16u) & 255u)));
  let x_723 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_718 * x_718));
  let x_733 : vec3<f32> = select((x_723 * 12.9200000762939453125f), ((pow(x_723, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_723 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_733.x, x_733.y, x_733.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(1) v1_param : vec3<f32>, @location(0) v0_param : vec3<f32>, @location(6) v7_param : vec2<f32>, @location(11) @interpolate(flat) v12_param : i32, @location(7) @interpolate(flat) v8_param : i32, @location(10) @interpolate(flat) v11_param : i32, @location(5) @interpolate(flat) v6_param : i32, @location(4) @interpolate(flat) v5_param : i32, @location(9) @interpolate(flat) v10_param : i32, @location(12) @interpolate(flat) v13_param : i32, @location(8) @interpolate(flat) v9_param : i32) -> main_out {
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
  main_1();
  return main_out(residentColor);
}
