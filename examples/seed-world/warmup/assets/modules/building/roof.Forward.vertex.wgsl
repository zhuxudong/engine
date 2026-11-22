diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(0) @group(3) var gs_wgpu_tex_storage_7_0 : texture_2d<u32>;

@binding(1) @group(3) var gs_wgpu_samp_storage_7_0 : sampler;

var<private> instanceWords0 : vec4<u32>;

var<private> instanceWords1 : vec4<u32>;

var<private> instanceWords2 : vec4<u32>;

var<private> instanceWords3 : vec4<u32>;

@binding(2) @group(3) var gs_wgpu_tex_storage_10_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_10_0 : sampler;

var<private> gl_InstanceIndex : i32;

var<private> Vertex_Position : vec3<f32>;

@binding(0) @group(2) var<uniform> x_3504 : gs_Auto_0;

var<private> v0 : vec3<f32>;

var<private> v1 : f32;

var<private> v2 : f32;

var<private> v3 : f32;

var<private> v4 : vec2<f32>;

var<private> v5 : vec4<f32>;

var<private> v6 : u32;

var<private> v7 : f32;

var<private> v8 : vec2<f32>;

var<private> instanceRecord0 : vec4<u32>;

var<private> instanceRecord1 : vec4<u32>;

var<private> instanceRecord2 : vec4<u32>;

var<private> instanceRecord3 : vec4<u32>;

var<private> instanceVisible : u32;

var<private> gl_Position : vec4<f32>;

const x_709 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_1068 = vec2<i32>(1i, 0i);

const x_1182 = vec2<i32>(0i, 1i);

const x_1296 = vec2<i32>(1i, 1i);

const x_1414 = vec2<f32>(2.0f, 2.0f);

const x_1413 = vec2<f32>(3.0f, 3.0f);

const x_2694 = vec2<f32>(0.5f, 0.5f);

const x_3316 = vec3<f32>(1.0f, 1.0f, 1.0f);

const x_25572 = vec3<f32>(0.00346020772121846676f, 0.00346020772121846676f, 0.00346020772121846676f);

const x_3322 = vec3<f32>(289.0f, 289.0f, 289.0f);

const x_3343 = vec3<f32>(0.5f, 0.5f, 0.5f);

fn main_1() {
  var x_3878 : vec2<f32>;
  var x_3902 : vec2<f32>;
  var x_3926 : vec2<f32>;
  var x_3950 : vec2<f32>;
  var x_3974 : vec2<f32>;
  var x_3998 : vec2<f32>;
  var x_4022 : vec2<f32>;
  var x_4046 : vec2<f32>;
  var x_7265 : i32;
  var x_7272 : u32;
  var x_7280 : u32;
  var x_20070 : u32;
  var x_20071 : u32;
  var x_20072 : u32;
  var x_8131 : u32;
  var x_20218 : u32;
  var x_20219 : u32;
  var x_8570 : u32;
  var x_20305 : u32;
  var x_20306 : u32;
  var x_8612 : u32;
  var x_20311 : u32;
  var x_20312 : u32;
  var x_8654 : u32;
  var x_20317 : u32;
  var x_20318 : u32;
  var x_9597 : u32;
  var x_20476 : u32;
  var x_20477 : u32;
  var x_10372 : u32;
  var x_20611 : u32;
  var x_20612 : u32;
  var x_11315 : u32;
  var x_20770 : u32;
  var x_20771 : u32;
  var x_12468 : u32;
  var x_20959 : u32;
  var x_20960 : u32;
  var x_12907 : u32;
  var x_21046 : u32;
  var x_21047 : u32;
  var x_13976 : u32;
  var x_21319 : u32;
  var x_21320 : u32;
  var x_14751 : u32;
  var x_21454 : u32;
  var x_21455 : u32;
  var x_21576 : i32;
  var x_21577 : i32;
  var x_21578 : i32;
  var x_22231 : vec3<f32>;
  var x_25726 : vec3<f32>;
  var x_17753 : u32;
  var x_22788 : u32;
  var x_22789 : u32;
  var x_25661 : vec3<f32>;
  var x_23820 : vec3<f32>;
  var x_23822 : u32;
  var x_23821 : u32;
  var x_23825 : u32;
  var x_23824 : u32;
  var x_23828 : u32;
  var x_23827 : u32;
  var x_23831 : u32;
  var x_23830 : u32;
  var x_23834 : u32;
  var x_23833 : u32;
  var x_23837 : u32;
  var x_23836 : u32;
  var x_23840 : u32;
  var x_23839 : u32;
  var x_23843 : u32;
  var x_23842 : u32;
  var x_18990 : u32;
  var x_24000 : u32;
  var x_24001 : u32;
  var x_24121 : u32;
  var x_24120 : u32;
  var x_25086 : f32;
  var x_24125 : u32;
  var x_24124 : u32;
  var x_25187 : f32;
  var x_24129 : u32;
  var x_24128 : u32;
  var x_25287 : f32;
  var x_24133 : u32;
  var x_24132 : u32;
  var x_25337 : f32;
  var x_19807 : u32;
  var x_24325 : u32;
  var x_24326 : u32;
  var x_6679 : f32;
  var x_25517 : f32;
  let x_4193 : i32 = gl_InstanceIndex;
  let x_6790 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_6795 : i32 = (x_4193 / 4i);
  let x_6797 : i32 = x_6790.x;
  let x_6806 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_6797), (x_6795 / x_6797)), 0i);
  let x_6808 : i32 = (x_4193 % 4i);
  x_7265 = (((bitcast<i32>(x_6806[x_6808]) * 16i) + 8i) % 16i);
  if ((x_7265 < 4i)) {
    x_7272 = instanceWords0[(x_7265 % 4i)];
    x_20072 = x_7272;
  } else {
    var x_7288 : u32;
    var x_7293 : u32;
    if ((x_7265 < 8i)) {
      x_7280 = instanceWords1[(x_7265 % 4i)];
      x_20071 = x_7280;
    } else {
      if ((x_7265 < 12i)) {
        x_7288 = instanceWords2[(x_7265 % 4i)];
        x_20070 = x_7288;
      } else {
        x_7293 = instanceWords3[(x_7265 % 4i)];
        x_20070 = x_7293;
      }
      x_20071 = x_20070;
    }
    x_20072 = x_20071;
  }
  var x_8124 : i32;
  var x_8139 : u32;
  var x_20217 : u32;
  let x_4201 : vec2<f32> = unpack2x16float(x_20072);
  let x_7608 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_7615 : i32 = x_7608.x;
  let x_7624 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_7615), (x_6795 / x_7615)), 0i);
  x_8124 = (((bitcast<i32>(x_7624[x_6808]) * 16i) + 9i) % 16i);
  if ((x_8124 < 4i)) {
    x_8131 = instanceWords0[(x_8124 % 4i)];
    x_20219 = x_8131;
  } else {
    var x_8147 : u32;
    var x_8152 : u32;
    if ((x_8124 < 8i)) {
      x_8139 = instanceWords1[(x_8124 % 4i)];
      x_20218 = x_8139;
    } else {
      if ((x_8124 < 12i)) {
        x_8147 = instanceWords2[(x_8124 % 4i)];
        x_20217 = x_8147;
      } else {
        x_8152 = instanceWords3[(x_8124 % 4i)];
        x_20217 = x_8152;
      }
      x_20218 = x_20217;
    }
    x_20219 = x_20218;
  }
  var x_8563 : i32;
  var x_8578 : u32;
  var x_20304 : u32;
  let x_4208 : vec2<f32> = unpack2x16float(x_20219);
  let x_4210 : f32 = x_4201.x;
  let x_4213 : f32 = (x_4210 + x_4210);
  let x_4215 : f32 = x_4201.y;
  let x_4218 : f32 = (x_4215 + x_4215);
  let x_4220 : f32 = x_4208.x;
  let x_4223 : f32 = (x_4220 + x_4220);
  let x_4226 : f32 = (x_4210 * x_4213);
  let x_4229 : f32 = (x_4210 * x_4218);
  let x_4232 : f32 = (x_4210 * x_4223);
  let x_4235 : f32 = (x_4215 * x_4218);
  let x_4238 : f32 = (x_4215 * x_4223);
  let x_4241 : f32 = (x_4220 * x_4223);
  let x_4243 : f32 = x_4208.y;
  let x_4246 : f32 = (x_4243 * x_4213);
  let x_4249 : f32 = (x_4243 * x_4218);
  let x_4252 : f32 = (x_4243 * x_4223);
  let x_4256 : f32 = (1.0f - (x_4235 + x_4241));
  let x_4259 : f32 = (x_4229 + x_4252);
  let x_4262 : f32 = (x_4232 - x_4249);
  let x_4266 : f32 = (x_4229 - x_4252);
  let x_4270 : f32 = (1.0f - (x_4226 + x_4241));
  let x_4273 : f32 = (x_4238 + x_4246);
  let x_4277 : f32 = (x_4232 + x_4249);
  let x_4280 : f32 = (x_4238 - x_4246);
  let x_4284 : f32 = (1.0f - (x_4226 + x_4235));
  let x_8425 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_8432 : i32 = x_8425.x;
  let x_8441 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_8432), (x_6795 / x_8432)), 0i);
  let x_8464 : i32 = (bitcast<i32>(x_8441[x_6808]) * 16i);
  x_8563 = (x_8464 % 16i);
  if ((x_8563 < 4i)) {
    x_8570 = instanceWords0[(x_8563 % 4i)];
    x_20306 = x_8570;
  } else {
    var x_8586 : u32;
    var x_8591 : u32;
    if ((x_8563 < 8i)) {
      x_8578 = instanceWords1[(x_8563 % 4i)];
      x_20305 = x_8578;
    } else {
      if ((x_8563 < 12i)) {
        x_8586 = instanceWords2[(x_8563 % 4i)];
        x_20304 = x_8586;
      } else {
        x_8591 = instanceWords3[(x_8563 % 4i)];
        x_20304 = x_8591;
      }
      x_20305 = x_20304;
    }
    x_20306 = x_20305;
  }
  var x_8605 : i32;
  var x_8620 : u32;
  var x_20310 : u32;
  let x_8468 : f32 = bitcast<f32>(x_20306);
  x_8605 = ((x_8464 + 1i) % 16i);
  if ((x_8605 < 4i)) {
    x_8612 = instanceWords0[(x_8605 % 4i)];
    x_20312 = x_8612;
  } else {
    var x_8628 : u32;
    var x_8633 : u32;
    if ((x_8605 < 8i)) {
      x_8620 = instanceWords1[(x_8605 % 4i)];
      x_20311 = x_8620;
    } else {
      if ((x_8605 < 12i)) {
        x_8628 = instanceWords2[(x_8605 % 4i)];
        x_20310 = x_8628;
      } else {
        x_8633 = instanceWords3[(x_8605 % 4i)];
        x_20310 = x_8633;
      }
      x_20311 = x_20310;
    }
    x_20312 = x_20311;
  }
  var x_8647 : i32;
  var x_8662 : u32;
  var x_20316 : u32;
  let x_8474 : f32 = bitcast<f32>(x_20312);
  x_8647 = ((x_8464 + 2i) % 16i);
  if ((x_8647 < 4i)) {
    x_8654 = instanceWords0[(x_8647 % 4i)];
    x_20318 = x_8654;
  } else {
    var x_8670 : u32;
    var x_8675 : u32;
    if ((x_8647 < 8i)) {
      x_8662 = instanceWords1[(x_8647 % 4i)];
      x_20317 = x_8662;
    } else {
      if ((x_8647 < 12i)) {
        x_8670 = instanceWords2[(x_8647 % 4i)];
        x_20316 = x_8670;
      } else {
        x_8675 = instanceWords3[(x_8647 % 4i)];
        x_20316 = x_8675;
      }
      x_20317 = x_20316;
    }
    x_20318 = x_20317;
  }
  var x_9590 : i32;
  var x_9605 : u32;
  var x_20475 : u32;
  let x_4309 : mat3x4<f32> = transpose(mat4x3<f32>(vec3<f32>(x_4256, x_4259, x_4262), vec3<f32>(x_4266, x_4270, x_4273), vec3<f32>(x_4277, x_4280, x_4284), vec3<f32>(x_8468, x_8474, bitcast<f32>(x_20318))));
  let x_9242 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_9249 : i32 = x_9242.x;
  let x_9258 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_9249), (x_6795 / x_9249)), 0i);
  x_9590 = (((bitcast<i32>(x_9258[x_6808]) * 16i) + 5i) % 16i);
  if ((x_9590 < 4i)) {
    x_9597 = instanceWords0[(x_9590 % 4i)];
    x_20477 = x_9597;
  } else {
    var x_9613 : u32;
    var x_9618 : u32;
    if ((x_9590 < 8i)) {
      x_9605 = instanceWords1[(x_9590 % 4i)];
      x_20476 = x_9605;
    } else {
      if ((x_9590 < 12i)) {
        x_9613 = instanceWords2[(x_9590 % 4i)];
        x_20475 = x_9613;
      } else {
        x_9618 = instanceWords3[(x_9590 % 4i)];
        x_20475 = x_9618;
      }
      x_20476 = x_20475;
    }
    x_20477 = x_20476;
  }
  var x_10365 : i32;
  var x_10380 : u32;
  var x_20610 : u32;
  let x_4316 : vec2<f32> = unpack2x16float(x_20477);
  let x_10059 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_10066 : i32 = x_10059.x;
  let x_10075 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_10066), (x_6795 / x_10066)), 0i);
  x_10365 = (((bitcast<i32>(x_10075[x_6808]) * 16i) + 4i) % 16i);
  if ((x_10365 < 4i)) {
    x_10372 = instanceWords0[(x_10365 % 4i)];
    x_20612 = x_10372;
  } else {
    var x_10388 : u32;
    var x_10393 : u32;
    if ((x_10365 < 8i)) {
      x_10380 = instanceWords1[(x_10365 % 4i)];
      x_20611 = x_10380;
    } else {
      if ((x_10365 < 12i)) {
        x_10388 = instanceWords2[(x_10365 % 4i)];
        x_20610 = x_10388;
      } else {
        x_10393 = instanceWords3[(x_10365 % 4i)];
        x_20610 = x_10393;
      }
      x_20611 = x_20610;
    }
    x_20612 = x_20611;
  }
  var x_11308 : i32;
  var x_11323 : u32;
  var x_20769 : u32;
  let x_4323 : vec2<f32> = unpack2x16float(x_20612);
  let x_4328 : f32 = x_4316.y;
  let x_4329 : vec4<f32> = vec4<f32>(x_4323.x, x_4323.y, x_4316.x, x_4328);
  let x_10876 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_10883 : i32 = x_10876.x;
  let x_10892 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_10883), (x_6795 / x_10883)), 0i);
  x_11308 = (((bitcast<i32>(x_10892[x_6808]) * 16i) + 7i) % 16i);
  if ((x_11308 < 4i)) {
    x_11315 = instanceWords0[(x_11308 % 4i)];
    x_20771 = x_11315;
  } else {
    var x_11331 : u32;
    var x_11336 : u32;
    if ((x_11308 < 8i)) {
      x_11323 = instanceWords1[(x_11308 % 4i)];
      x_20770 = x_11323;
    } else {
      if ((x_11308 < 12i)) {
        x_11331 = instanceWords2[(x_11308 % 4i)];
        x_20769 = x_11331;
      } else {
        x_11336 = instanceWords3[(x_11308 % 4i)];
        x_20769 = x_11336;
      }
      x_20770 = x_20769;
    }
    x_20771 = x_20770;
  }
  var x_12461 : i32;
  var x_12476 : u32;
  var x_20958 : u32;
  let x_4336 : vec2<f32> = unpack2x16float(x_20771);
  let x_4338 : f32 = x_4336.y;
  let x_11693 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_11700 : i32 = x_11693.x;
  let x_11709 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_11700), (x_6795 / x_11700)), 0i);
  x_12461 = (((bitcast<i32>(x_11709[x_6808]) * 16i) + 15i) % 16i);
  if ((x_12461 < 4i)) {
    x_12468 = instanceWords0[(x_12461 % 4i)];
    x_20960 = x_12468;
  } else {
    var x_12484 : u32;
    var x_12489 : u32;
    if ((x_12461 < 8i)) {
      x_12476 = instanceWords1[(x_12461 % 4i)];
      x_20959 = x_12476;
    } else {
      if ((x_12461 < 12i)) {
        x_12484 = instanceWords2[(x_12461 % 4i)];
        x_20958 = x_12484;
      } else {
        x_12489 = instanceWords3[(x_12461 % 4i)];
        x_20958 = x_12489;
      }
      x_20959 = x_20958;
    }
    x_20960 = x_20959;
  }
  var x_12900 : i32;
  var x_12915 : u32;
  var x_21045 : u32;
  let x_4345 : bool = (bitcast<i32>(x_20960) != 0i);
  let x_12510 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_12517 : i32 = x_12510.x;
  let x_12526 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_12517), (x_6795 / x_12517)), 0i);
  x_12900 = (((bitcast<i32>(x_12526[x_6808]) * 16i) + 6i) % 16i);
  if ((x_12900 < 4i)) {
    x_12907 = instanceWords0[(x_12900 % 4i)];
    x_21047 = x_12907;
  } else {
    var x_12923 : u32;
    var x_12928 : u32;
    if ((x_12900 < 8i)) {
      x_12915 = instanceWords1[(x_12900 % 4i)];
      x_21046 = x_12915;
    } else {
      if ((x_12900 < 12i)) {
        x_12923 = instanceWords2[(x_12900 % 4i)];
        x_21045 = x_12923;
      } else {
        x_12928 = instanceWords3[(x_12900 % 4i)];
        x_21045 = x_12928;
      }
      x_21046 = x_21045;
    }
    x_21047 = x_21046;
  }
  var x_13969 : i32;
  var x_13984 : u32;
  var x_21318 : u32;
  let x_4352 : vec2<f32> = unpack2x16float(x_21047);
  let x_4358 : vec4<f32> = vec4<f32>(x_4352.x, x_4352.y, x_4336.x, 0.0f);
  let x_4359 : vec3<f32> = vec3<f32>(x_4358.x, x_4358.y, x_4358.z);
  let x_4361 : f32 = (x_4338 * 0.80000001192092895508f);
  let x_13327 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_13334 : i32 = x_13327.x;
  let x_13343 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_13334), (x_6795 / x_13334)), 0i);
  x_13969 = (((bitcast<i32>(x_13343[x_6808]) * 16i) + 12i) % 16i);
  if ((x_13969 < 4i)) {
    x_13976 = instanceWords0[(x_13969 % 4i)];
    x_21320 = x_13976;
  } else {
    var x_13992 : u32;
    var x_13997 : u32;
    if ((x_13969 < 8i)) {
      x_13984 = instanceWords1[(x_13969 % 4i)];
      x_21319 = x_13984;
    } else {
      if ((x_13969 < 12i)) {
        x_13992 = instanceWords2[(x_13969 % 4i)];
        x_21318 = x_13992;
      } else {
        x_13997 = instanceWords3[(x_13969 % 4i)];
        x_21318 = x_13997;
      }
      x_21319 = x_21318;
    }
    x_21320 = x_21319;
  }
  var x_14744 : i32;
  var x_14759 : u32;
  var x_21453 : u32;
  let x_4372 : vec3<f32> = ((x_4359 * smoothstep(x_4361, x_4338, pow(bitcast<f32>(x_21320), 0.80000001192092895508f))) * vec3<f32>(0.505970001220703125f, 0.5f, 0.5f));
  let x_4375 : f32 = (x_4372.x * 0.94999998807907104492f);
  var x_25598_1 : vec3<f32> = x_4372;
  x_25598_1.x = x_4375;
  let x_25598 : vec3<f32> = x_25598_1;
  let x_4380 : vec3<f32> = (x_25598 * vec3<f32>(3.58920383453369140625f, 3.70370388031005859375f, 3.70370388031005859375f));
  let x_4397 : f32 = max(min(max(x_4375, max(x_4372.y, x_4372.z)), min(x_4380.x, min(x_4380.y, x_4380.z))), 0.00000999999974737875f);
  let x_4398 : vec3<f32> = Vertex_Position;
  let x_4399 : vec3<f32> = (x_4398 * vec3<f32>(1.97640180587768554688f, 2.0f, 2.0f));
  let x_4402 : vec3<f32> = (x_4399 * x_4397);
  let x_14144 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_14151 : i32 = x_14144.x;
  let x_14160 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_14151), (x_6795 / x_14151)), 0i);
  x_14744 = (((bitcast<i32>(x_14160[x_6808]) * 16i) + 11i) % 16i);
  if ((x_14744 < 4i)) {
    x_14751 = instanceWords0[(x_14744 % 4i)];
    x_21455 = x_14751;
  } else {
    var x_14767 : u32;
    var x_14772 : u32;
    if ((x_14744 < 8i)) {
      x_14759 = instanceWords1[(x_14744 % 4i)];
      x_21454 = x_14759;
    } else {
      if ((x_14744 < 12i)) {
        x_14767 = instanceWords2[(x_14744 % 4i)];
        x_21453 = x_14767;
      } else {
        x_14772 = instanceWords3[(x_14744 % 4i)];
        x_21453 = x_14772;
      }
      x_21454 = x_21453;
    }
    x_21455 = x_21454;
  }
  let x_4411 : f32 = unpack2x16float(x_21455).y;
  let x_4413 : f32 = sin(x_4411);
  let x_4415 : f32 = cos(x_4411);
  let x_4458 : vec3<f32> = (vec3<f32>(x_4397, x_4397, x_4397) - x_25598);
  let x_4460 : vec3<bool> = (x_4402 >= x_709);
  if (x_4460.x) {
    x_21576 = 1i;
  } else {
    x_21576 = -1i;
  }
  if (x_4460.y) {
    x_21577 = 1i;
  } else {
    x_21577 = -1i;
  }
  if (x_4460.z) {
    x_21578 = 1i;
  } else {
    x_21578 = -1i;
  }
  var x_15688 : u32;
  var x_21886 : u32;
  var x_21887 : u32;
  var x_16379 : u32;
  var x_22009 : u32;
  var x_22010 : u32;
  var x_22230 : vec3<f32>;
  let x_4518 : vec3<f32> = ((x_4402 - (x_4458 * vec3<f32>(vec3<i32>(x_21576, x_21577, x_21578)))) * transpose(mat3x3<f32>(vec3<f32>(1.0f, 0.0f, 0.0f), vec3<f32>(0.0f, x_4415, -(x_4413)), vec3<f32>(0.0f, x_4413, x_4415))));
  if (x_4345) {
    var x_15681 : i32;
    var x_15696 : u32;
    var x_21885 : u32;
    let x_14997 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_15004 : i32 = x_14997.x;
    let x_15013 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_15004), (x_6795 / x_15004)), 0i);
    x_15681 = (((bitcast<i32>(x_15013[x_6808]) * 16i) + 13i) % 16i);
    if ((x_15681 < 4i)) {
      x_15688 = instanceWords0[(x_15681 % 4i)];
      x_21887 = x_15688;
    } else {
      var x_15704 : u32;
      var x_15709 : u32;
      if ((x_15681 < 8i)) {
        x_15696 = instanceWords1[(x_15681 % 4i)];
        x_21886 = x_15696;
      } else {
        if ((x_15681 < 12i)) {
          x_15704 = instanceWords2[(x_15681 % 4i)];
          x_21885 = x_15704;
        } else {
          x_15709 = instanceWords3[(x_15681 % 4i)];
          x_21885 = x_15709;
        }
        x_21886 = x_21885;
      }
      x_21887 = x_21886;
    }
    var x_16372 : i32;
    var x_16387 : u32;
    var x_22008 : u32;
    let x_4528 : u32 = bitcast<u32>((bitcast<i32>(x_21887) * 1664525i));
    let x_15814 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_15821 : i32 = x_15814.x;
    let x_15830 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_15821), (x_6795 / x_15821)), 0i);
    x_16372 = (((bitcast<i32>(x_15830[x_6808]) * 16i) + 10i) % 16i);
    if ((x_16372 < 4i)) {
      x_16379 = instanceWords0[(x_16372 % 4i)];
      x_22010 = x_16379;
    } else {
      var x_16395 : u32;
      var x_16400 : u32;
      if ((x_16372 < 8i)) {
        x_16387 = instanceWords1[(x_16372 % 4i)];
        x_22009 = x_16387;
      } else {
        if ((x_16372 < 12i)) {
          x_16395 = instanceWords2[(x_16372 % 4i)];
          x_22008 = x_16395;
        } else {
          x_16400 = instanceWords3[(x_16372 % 4i)];
          x_22008 = x_16400;
        }
        x_22009 = x_22008;
      }
      x_22010 = x_22009;
    }
    var x_4563 : f32;
    var x_17398 : u32;
    var x_22174 : u32;
    var x_22175 : u32;
    var x_25638 : vec3<f32>;
    var x_25641 : vec3<f32>;
    let x_4535 : i32 = bitcast<i32>(x_22010);
    let x_16631 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_10_0, 0i));
    let x_16636 : i32 = (x_4535 / 4i);
    let x_16638 : i32 = x_16631.x;
    let x_16647 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_10_0, vec2<i32>((x_16636 % x_16638), (x_16636 / x_16638)), 0i);
    let x_4537 : u32 = (x_4528 + x_16647[(x_4535 % 4i)]);
    let x_4541 : u32 = (x_4537 + (x_4537 << 10u));
    let x_4545 : u32 = (x_4541 ^ (x_4541 >> 6u));
    let x_4549 : u32 = (x_4545 + (x_4545 << 3u));
    let x_4553 : u32 = (x_4549 ^ (x_4549 >> 11u));
    x_4563 = select(0.05999999865889549255f, 0.01999999955296516418f, ((bitcast<f32>((((x_4553 + (x_4553 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) > 0.89999997615814208984f));
    let x_4565 : f32 = Vertex_Position.y;
    if ((x_4565 > 0.10000000149011611938f)) {
      var x_17391 : i32;
      var x_17406 : u32;
      var x_22173 : u32;
      let x_16665 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_16672 : i32 = x_16665.x;
      let x_16681 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_16672), (x_6795 / x_16672)), 0i);
      x_17391 = (((bitcast<i32>(x_16681[x_6808]) * 16i) + 14i) % 16i);
      if ((x_17391 < 4i)) {
        x_17398 = instanceWords0[(x_17391 % 4i)];
        x_22175 = x_17398;
      } else {
        var x_17414 : u32;
        var x_17419 : u32;
        if ((x_17391 < 8i)) {
          x_17406 = instanceWords1[(x_17391 % 4i)];
          x_22174 = x_17406;
        } else {
          if ((x_17391 < 12i)) {
            x_17414 = instanceWords2[(x_17391 % 4i)];
            x_22173 = x_17414;
          } else {
            x_17419 = instanceWords3[(x_17391 % 4i)];
            x_22173 = x_17419;
          }
          x_22174 = x_22173;
        }
        x_22175 = x_22174;
      }
      if ((bitcast<i32>(x_22175) != 0i)) {
        x_25638 = x_4518;
        x_25638.z = (x_4518.z - x_4563);
        x_22230 = x_25638;
      } else {
        x_25641 = x_4518;
        x_25641.z = (x_4518.z + x_4563);
        x_22230 = x_25641;
      }
      x_22231 = x_22230;
    } else {
      x_22231 = x_4518;
    }
    x_25726 = x_22231;
  } else {
    x_25726 = x_4518;
  }
  var x_17746 : i32;
  var x_17761 : u32;
  var x_22787 : u32;
  let x_4602 : f32 = x_25726.z;
  let x_4622 : vec3<f32> = (vec4<f32>(x_25726.x, x_25726.y, (x_4602 + ((1.0f - smoothstep(0.0f, 0.80000001192092895508f, ((vec4<f32>(x_25726.x, x_25726.y, x_4602, 1.0f) * x_4309)).y)) * 0.11500000208616256714f)), 1.0f) * x_4309);
  let x_4624 : f32 = x_4622.y;
  let x_17482 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_17489 : i32 = x_17482.x;
  let x_17498 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_17489), (x_6795 / x_17489)), 0i);
  x_17746 = (((bitcast<i32>(x_17498[x_6808]) * 16i) + 3i) % 16i);
  if ((x_17746 < 4i)) {
    x_17753 = instanceWords0[(x_17746 % 4i)];
    x_22789 = x_17753;
  } else {
    var x_17769 : u32;
    var x_17774 : u32;
    if ((x_17746 < 8i)) {
      x_17761 = instanceWords1[(x_17746 % 4i)];
      x_22788 = x_17761;
    } else {
      if ((x_17746 < 12i)) {
        x_17769 = instanceWords2[(x_17746 % 4i)];
        x_22787 = x_17769;
      } else {
        x_17774 = instanceWords3[(x_17746 % 4i)];
        x_22787 = x_17774;
      }
      x_22788 = x_22787;
    }
    x_22789 = x_22788;
  }
  var x_23737 : u32;
  var x_23736 : u32;
  var x_23761 : f32;
  var x_23741 : u32;
  var x_23740 : u32;
  var x_23764 : f32;
  var x_23745 : u32;
  var x_23744 : u32;
  var x_23766 : f32;
  var x_23749 : u32;
  var x_23748 : u32;
  var x_23767 : f32;
  let x_4632 : f32 = (x_4624 + bitcast<f32>(x_22789));
  var x_25649_1 : vec3<f32> = x_4622;
  x_25649_1.y = x_4632;
  let x_25649 : vec3<f32> = x_25649_1;
  if (x_4345) {
    let x_4640 : vec2<f32> = (vec2<f32>(x_25649.x, x_25649.z) * 0.5f);
    let x_4643 : vec2<i32> = vec2<i32>(floor(x_4640));
    let x_4645 : vec2<f32> = fract(x_4640);
    let x_4647 : vec2<u32> = bitcast<vec2<u32>>(x_4643);
    let x_4649 : u32 = x_4647.y;
    let x_4653 : u32 = (x_4649 + (x_4649 << 10u));
    let x_4657 : u32 = (x_4653 ^ (x_4653 >> 6u));
    let x_4661 : u32 = (x_4657 + (x_4657 << 3u));
    let x_4665 : u32 = (x_4661 ^ (x_4661 >> 11u));
    let x_4675 : u32 = ((((x_4647.x * 1664525u) + (x_4665 + (x_4665 << 15u))) + 1013904223u) * 1664525u);
    let x_4679 : u32 = (x_4675 ^ (x_4675 >> 11u));
    let x_4684 : u32 = (x_4679 ^ ((x_4679 << 7u) & 2636928640u));
    let x_4689 : u32 = (x_4684 ^ ((x_4684 << 15u) & 4022730752u));
    let x_4693 : u32 = (x_4689 ^ (x_4689 >> 18u));
    x_23737 = x_4693;
    x_23736 = 0u;
    x_23761 = 0.0f;
    loop {
      if ((x_23736 >= 1u)) {
        break;
      }
      let x_4706 : u32 = (x_23737 + (x_23737 << 10u));
      let x_4710 : u32 = (x_4706 ^ (x_4706 >> 6u));
      let x_4714 : u32 = (x_4710 + (x_4710 << 3u));
      let x_4718 : u32 = (x_4714 ^ (x_4714 >> 11u));

      continuing {
        x_23737 = (x_4718 + (x_4718 << 15u));
        x_23736 = (x_23736 + 1u);
        x_23761 = (bitcast<f32>(((x_23737 & 8388607u) | 1065353216u)) - 1.0f);
      }
    }
    let x_4737 : vec2<u32> = bitcast<vec2<u32>>((x_4643 + x_1068));
    let x_4739 : u32 = x_4737.y;
    let x_4743 : u32 = (x_4739 + (x_4739 << 10u));
    let x_4747 : u32 = (x_4743 ^ (x_4743 >> 6u));
    let x_4751 : u32 = (x_4747 + (x_4747 << 3u));
    let x_4755 : u32 = (x_4751 ^ (x_4751 >> 11u));
    let x_4765 : u32 = ((((x_4737.x * 1664525u) + (x_4755 + (x_4755 << 15u))) + 1013904223u) * 1664525u);
    let x_4769 : u32 = (x_4765 ^ (x_4765 >> 11u));
    let x_4774 : u32 = (x_4769 ^ ((x_4769 << 7u) & 2636928640u));
    let x_4779 : u32 = (x_4774 ^ ((x_4774 << 15u) & 4022730752u));
    let x_4783 : u32 = (x_4779 ^ (x_4779 >> 18u));
    x_23741 = x_4783;
    x_23740 = 0u;
    x_23764 = 0.0f;
    loop {
      if ((x_23740 >= 1u)) {
        break;
      }
      let x_4796 : u32 = (x_23741 + (x_23741 << 10u));
      let x_4800 : u32 = (x_4796 ^ (x_4796 >> 6u));
      let x_4804 : u32 = (x_4800 + (x_4800 << 3u));
      let x_4808 : u32 = (x_4804 ^ (x_4804 >> 11u));

      continuing {
        x_23741 = (x_4808 + (x_4808 << 15u));
        x_23740 = (x_23740 + 1u);
        x_23764 = (bitcast<f32>(((x_23741 & 8388607u) | 1065353216u)) - 1.0f);
      }
    }
    let x_4827 : vec2<u32> = bitcast<vec2<u32>>((x_4643 + x_1182));
    let x_4829 : u32 = x_4827.y;
    let x_4833 : u32 = (x_4829 + (x_4829 << 10u));
    let x_4837 : u32 = (x_4833 ^ (x_4833 >> 6u));
    let x_4841 : u32 = (x_4837 + (x_4837 << 3u));
    let x_4845 : u32 = (x_4841 ^ (x_4841 >> 11u));
    let x_4855 : u32 = ((((x_4827.x * 1664525u) + (x_4845 + (x_4845 << 15u))) + 1013904223u) * 1664525u);
    let x_4859 : u32 = (x_4855 ^ (x_4855 >> 11u));
    let x_4864 : u32 = (x_4859 ^ ((x_4859 << 7u) & 2636928640u));
    let x_4869 : u32 = (x_4864 ^ ((x_4864 << 15u) & 4022730752u));
    let x_4873 : u32 = (x_4869 ^ (x_4869 >> 18u));
    x_23745 = x_4873;
    x_23744 = 0u;
    x_23766 = 0.0f;
    loop {
      if ((x_23744 >= 1u)) {
        break;
      }
      let x_4886 : u32 = (x_23745 + (x_23745 << 10u));
      let x_4890 : u32 = (x_4886 ^ (x_4886 >> 6u));
      let x_4894 : u32 = (x_4890 + (x_4890 << 3u));
      let x_4898 : u32 = (x_4894 ^ (x_4894 >> 11u));

      continuing {
        x_23745 = (x_4898 + (x_4898 << 15u));
        x_23744 = (x_23744 + 1u);
        x_23766 = (bitcast<f32>(((x_23745 & 8388607u) | 1065353216u)) - 1.0f);
      }
    }
    let x_4917 : vec2<u32> = bitcast<vec2<u32>>((x_4643 + x_1296));
    let x_4919 : u32 = x_4917.y;
    let x_4923 : u32 = (x_4919 + (x_4919 << 10u));
    let x_4927 : u32 = (x_4923 ^ (x_4923 >> 6u));
    let x_4931 : u32 = (x_4927 + (x_4927 << 3u));
    let x_4935 : u32 = (x_4931 ^ (x_4931 >> 11u));
    let x_4945 : u32 = ((((x_4917.x * 1664525u) + (x_4935 + (x_4935 << 15u))) + 1013904223u) * 1664525u);
    let x_4949 : u32 = (x_4945 ^ (x_4945 >> 11u));
    let x_4954 : u32 = (x_4949 ^ ((x_4949 << 7u) & 2636928640u));
    let x_4959 : u32 = (x_4954 ^ ((x_4954 << 15u) & 4022730752u));
    let x_4963 : u32 = (x_4959 ^ (x_4959 >> 18u));
    x_23749 = x_4963;
    x_23748 = 0u;
    x_23767 = 0.0f;
    loop {
      if ((x_23748 >= 1u)) {
        break;
      }
      let x_4976 : u32 = (x_23749 + (x_23749 << 10u));
      let x_4980 : u32 = (x_4976 ^ (x_4976 >> 6u));
      let x_4984 : u32 = (x_4980 + (x_4980 << 3u));
      let x_4988 : u32 = (x_4984 ^ (x_4984 >> 11u));

      continuing {
        x_23749 = (x_4988 + (x_4988 << 15u));
        x_23748 = (x_23748 + 1u);
        x_23767 = (bitcast<f32>(((x_23749 & 8388607u) | 1065353216u)) - 1.0f);
      }
    }
    let x_5011 : vec2<f32> = ((x_4645 * x_4645) * (x_1413 - (x_1414 * x_4645)));
    let x_5013 : f32 = x_5011.x;
    let x_5015 : f32 = (1.0f - x_5013);
    let x_5017 : f32 = x_5011.y;
    x_25661 = x_25649;
    x_25661.y = (x_4632 + ((((((1.0f - x_5017) * ((x_23761 * x_5015) + (x_23764 * x_5013))) + ((x_23766 * x_5015) * x_5017)) + ((x_23767 * x_5013) * x_5017)) * 0.30000001192092895508f) * smoothstep(0.0f, 1.0f, x_4624)));
    x_23820 = x_25661;
  } else {
    x_23820 = x_25649;
  }
  let x_5053 : vec3<f32> = (x_23820 * 0.40000000596046447754f);
  let x_5056 : vec3<i32> = vec3<i32>(floor(x_5053));
  let x_5058 : vec3<f32> = fract(x_5053);
  let x_5060 : vec3<u32> = bitcast<vec3<u32>>(x_5056);
  let x_5062 : u32 = x_5060.z;
  let x_5066 : u32 = (x_5062 + (x_5062 << 10u));
  let x_5070 : u32 = (x_5066 ^ (x_5066 >> 6u));
  let x_5074 : u32 = (x_5070 + (x_5070 << 3u));
  let x_5078 : u32 = (x_5074 ^ (x_5074 >> 11u));
  let x_5088 : u32 = ((((x_5060.y * 1664525u) + (x_5078 + (x_5078 << 15u))) + 1013904223u) * 1664525u);
  let x_5092 : u32 = (x_5088 ^ (x_5088 >> 11u));
  let x_5097 : u32 = (x_5092 ^ ((x_5092 << 7u) & 2636928640u));
  let x_5102 : u32 = (x_5097 ^ ((x_5097 << 15u) & 4022730752u));
  let x_5112 : u32 = ((((x_5060.x * 1664525u) + (x_5102 ^ (x_5102 >> 18u))) + 1013904223u) * 1664525u);
  let x_5116 : u32 = (x_5112 ^ (x_5112 >> 11u));
  let x_5121 : u32 = (x_5116 ^ ((x_5116 << 7u) & 2636928640u));
  let x_5126 : u32 = (x_5121 ^ ((x_5121 << 15u) & 4022730752u));
  let x_5130 : u32 = (x_5126 ^ (x_5126 >> 18u));
  x_23822 = x_5130;
  x_23821 = 0u;
  loop {
    if ((x_23821 >= 2u)) {
      break;
    }
    let x_5142 : u32 = (x_23822 + (x_23822 << 10u));
    let x_5146 : u32 = (x_5142 ^ (x_5142 >> 6u));
    let x_5150 : u32 = (x_5146 + (x_5146 << 3u));
    let x_5154 : u32 = (x_5150 ^ (x_5150 >> 11u));
    x_3878[x_23821] = (bitcast<f32>(((x_23822 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23822 = (x_5154 + (x_5154 << 15u));
      x_23821 = (x_23821 + 1u);
    }
  }
  let x_5174 : vec3<u32> = bitcast<vec3<u32>>((x_5056 + vec3<i32>(1i, 0i, 0i)));
  let x_5176 : u32 = x_5174.z;
  let x_5180 : u32 = (x_5176 + (x_5176 << 10u));
  let x_5184 : u32 = (x_5180 ^ (x_5180 >> 6u));
  let x_5188 : u32 = (x_5184 + (x_5184 << 3u));
  let x_5192 : u32 = (x_5188 ^ (x_5188 >> 11u));
  let x_5202 : u32 = ((((x_5174.y * 1664525u) + (x_5192 + (x_5192 << 15u))) + 1013904223u) * 1664525u);
  let x_5206 : u32 = (x_5202 ^ (x_5202 >> 11u));
  let x_5211 : u32 = (x_5206 ^ ((x_5206 << 7u) & 2636928640u));
  let x_5216 : u32 = (x_5211 ^ ((x_5211 << 15u) & 4022730752u));
  let x_5226 : u32 = ((((x_5174.x * 1664525u) + (x_5216 ^ (x_5216 >> 18u))) + 1013904223u) * 1664525u);
  let x_5230 : u32 = (x_5226 ^ (x_5226 >> 11u));
  let x_5235 : u32 = (x_5230 ^ ((x_5230 << 7u) & 2636928640u));
  let x_5240 : u32 = (x_5235 ^ ((x_5235 << 15u) & 4022730752u));
  let x_5244 : u32 = (x_5240 ^ (x_5240 >> 18u));
  x_23825 = x_5244;
  x_23824 = 0u;
  loop {
    if ((x_23824 >= 2u)) {
      break;
    }
    let x_5256 : u32 = (x_23825 + (x_23825 << 10u));
    let x_5260 : u32 = (x_5256 ^ (x_5256 >> 6u));
    let x_5264 : u32 = (x_5260 + (x_5260 << 3u));
    let x_5268 : u32 = (x_5264 ^ (x_5264 >> 11u));
    x_3902[x_23824] = (bitcast<f32>(((x_23825 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23825 = (x_5268 + (x_5268 << 15u));
      x_23824 = (x_23824 + 1u);
    }
  }
  let x_5288 : vec3<u32> = bitcast<vec3<u32>>((x_5056 + vec3<i32>(0i, 1i, 0i)));
  let x_5290 : u32 = x_5288.z;
  let x_5294 : u32 = (x_5290 + (x_5290 << 10u));
  let x_5298 : u32 = (x_5294 ^ (x_5294 >> 6u));
  let x_5302 : u32 = (x_5298 + (x_5298 << 3u));
  let x_5306 : u32 = (x_5302 ^ (x_5302 >> 11u));
  let x_5316 : u32 = ((((x_5288.y * 1664525u) + (x_5306 + (x_5306 << 15u))) + 1013904223u) * 1664525u);
  let x_5320 : u32 = (x_5316 ^ (x_5316 >> 11u));
  let x_5325 : u32 = (x_5320 ^ ((x_5320 << 7u) & 2636928640u));
  let x_5330 : u32 = (x_5325 ^ ((x_5325 << 15u) & 4022730752u));
  let x_5340 : u32 = ((((x_5288.x * 1664525u) + (x_5330 ^ (x_5330 >> 18u))) + 1013904223u) * 1664525u);
  let x_5344 : u32 = (x_5340 ^ (x_5340 >> 11u));
  let x_5349 : u32 = (x_5344 ^ ((x_5344 << 7u) & 2636928640u));
  let x_5354 : u32 = (x_5349 ^ ((x_5349 << 15u) & 4022730752u));
  let x_5358 : u32 = (x_5354 ^ (x_5354 >> 18u));
  x_23828 = x_5358;
  x_23827 = 0u;
  loop {
    if ((x_23827 >= 2u)) {
      break;
    }
    let x_5370 : u32 = (x_23828 + (x_23828 << 10u));
    let x_5374 : u32 = (x_5370 ^ (x_5370 >> 6u));
    let x_5378 : u32 = (x_5374 + (x_5374 << 3u));
    let x_5382 : u32 = (x_5378 ^ (x_5378 >> 11u));
    x_3926[x_23827] = (bitcast<f32>(((x_23828 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23828 = (x_5382 + (x_5382 << 15u));
      x_23827 = (x_23827 + 1u);
    }
  }
  let x_5402 : vec3<u32> = bitcast<vec3<u32>>((x_5056 + vec3<i32>(1i, 1i, 0i)));
  let x_5404 : u32 = x_5402.z;
  let x_5408 : u32 = (x_5404 + (x_5404 << 10u));
  let x_5412 : u32 = (x_5408 ^ (x_5408 >> 6u));
  let x_5416 : u32 = (x_5412 + (x_5412 << 3u));
  let x_5420 : u32 = (x_5416 ^ (x_5416 >> 11u));
  let x_5430 : u32 = ((((x_5402.y * 1664525u) + (x_5420 + (x_5420 << 15u))) + 1013904223u) * 1664525u);
  let x_5434 : u32 = (x_5430 ^ (x_5430 >> 11u));
  let x_5439 : u32 = (x_5434 ^ ((x_5434 << 7u) & 2636928640u));
  let x_5444 : u32 = (x_5439 ^ ((x_5439 << 15u) & 4022730752u));
  let x_5454 : u32 = ((((x_5402.x * 1664525u) + (x_5444 ^ (x_5444 >> 18u))) + 1013904223u) * 1664525u);
  let x_5458 : u32 = (x_5454 ^ (x_5454 >> 11u));
  let x_5463 : u32 = (x_5458 ^ ((x_5458 << 7u) & 2636928640u));
  let x_5468 : u32 = (x_5463 ^ ((x_5463 << 15u) & 4022730752u));
  let x_5472 : u32 = (x_5468 ^ (x_5468 >> 18u));
  x_23831 = x_5472;
  x_23830 = 0u;
  loop {
    if ((x_23830 >= 2u)) {
      break;
    }
    let x_5484 : u32 = (x_23831 + (x_23831 << 10u));
    let x_5488 : u32 = (x_5484 ^ (x_5484 >> 6u));
    let x_5492 : u32 = (x_5488 + (x_5488 << 3u));
    let x_5496 : u32 = (x_5492 ^ (x_5492 >> 11u));
    x_3950[x_23830] = (bitcast<f32>(((x_23831 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23831 = (x_5496 + (x_5496 << 15u));
      x_23830 = (x_23830 + 1u);
    }
  }
  let x_5516 : vec3<u32> = bitcast<vec3<u32>>((x_5056 + vec3<i32>(0i, 0i, 1i)));
  let x_5518 : u32 = x_5516.z;
  let x_5522 : u32 = (x_5518 + (x_5518 << 10u));
  let x_5526 : u32 = (x_5522 ^ (x_5522 >> 6u));
  let x_5530 : u32 = (x_5526 + (x_5526 << 3u));
  let x_5534 : u32 = (x_5530 ^ (x_5530 >> 11u));
  let x_5544 : u32 = ((((x_5516.y * 1664525u) + (x_5534 + (x_5534 << 15u))) + 1013904223u) * 1664525u);
  let x_5548 : u32 = (x_5544 ^ (x_5544 >> 11u));
  let x_5553 : u32 = (x_5548 ^ ((x_5548 << 7u) & 2636928640u));
  let x_5558 : u32 = (x_5553 ^ ((x_5553 << 15u) & 4022730752u));
  let x_5568 : u32 = ((((x_5516.x * 1664525u) + (x_5558 ^ (x_5558 >> 18u))) + 1013904223u) * 1664525u);
  let x_5572 : u32 = (x_5568 ^ (x_5568 >> 11u));
  let x_5577 : u32 = (x_5572 ^ ((x_5572 << 7u) & 2636928640u));
  let x_5582 : u32 = (x_5577 ^ ((x_5577 << 15u) & 4022730752u));
  let x_5586 : u32 = (x_5582 ^ (x_5582 >> 18u));
  x_23834 = x_5586;
  x_23833 = 0u;
  loop {
    if ((x_23833 >= 2u)) {
      break;
    }
    let x_5598 : u32 = (x_23834 + (x_23834 << 10u));
    let x_5602 : u32 = (x_5598 ^ (x_5598 >> 6u));
    let x_5606 : u32 = (x_5602 + (x_5602 << 3u));
    let x_5610 : u32 = (x_5606 ^ (x_5606 >> 11u));
    x_3974[x_23833] = (bitcast<f32>(((x_23834 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23834 = (x_5610 + (x_5610 << 15u));
      x_23833 = (x_23833 + 1u);
    }
  }
  let x_5630 : vec3<u32> = bitcast<vec3<u32>>((x_5056 + vec3<i32>(1i, 0i, 1i)));
  let x_5632 : u32 = x_5630.z;
  let x_5636 : u32 = (x_5632 + (x_5632 << 10u));
  let x_5640 : u32 = (x_5636 ^ (x_5636 >> 6u));
  let x_5644 : u32 = (x_5640 + (x_5640 << 3u));
  let x_5648 : u32 = (x_5644 ^ (x_5644 >> 11u));
  let x_5658 : u32 = ((((x_5630.y * 1664525u) + (x_5648 + (x_5648 << 15u))) + 1013904223u) * 1664525u);
  let x_5662 : u32 = (x_5658 ^ (x_5658 >> 11u));
  let x_5667 : u32 = (x_5662 ^ ((x_5662 << 7u) & 2636928640u));
  let x_5672 : u32 = (x_5667 ^ ((x_5667 << 15u) & 4022730752u));
  let x_5682 : u32 = ((((x_5630.x * 1664525u) + (x_5672 ^ (x_5672 >> 18u))) + 1013904223u) * 1664525u);
  let x_5686 : u32 = (x_5682 ^ (x_5682 >> 11u));
  let x_5691 : u32 = (x_5686 ^ ((x_5686 << 7u) & 2636928640u));
  let x_5696 : u32 = (x_5691 ^ ((x_5691 << 15u) & 4022730752u));
  let x_5700 : u32 = (x_5696 ^ (x_5696 >> 18u));
  x_23837 = x_5700;
  x_23836 = 0u;
  loop {
    if ((x_23836 >= 2u)) {
      break;
    }
    let x_5712 : u32 = (x_23837 + (x_23837 << 10u));
    let x_5716 : u32 = (x_5712 ^ (x_5712 >> 6u));
    let x_5720 : u32 = (x_5716 + (x_5716 << 3u));
    let x_5724 : u32 = (x_5720 ^ (x_5720 >> 11u));
    x_3998[x_23836] = (bitcast<f32>(((x_23837 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23837 = (x_5724 + (x_5724 << 15u));
      x_23836 = (x_23836 + 1u);
    }
  }
  let x_5744 : vec3<u32> = bitcast<vec3<u32>>((x_5056 + vec3<i32>(0i, 1i, 1i)));
  let x_5746 : u32 = x_5744.z;
  let x_5750 : u32 = (x_5746 + (x_5746 << 10u));
  let x_5754 : u32 = (x_5750 ^ (x_5750 >> 6u));
  let x_5758 : u32 = (x_5754 + (x_5754 << 3u));
  let x_5762 : u32 = (x_5758 ^ (x_5758 >> 11u));
  let x_5772 : u32 = ((((x_5744.y * 1664525u) + (x_5762 + (x_5762 << 15u))) + 1013904223u) * 1664525u);
  let x_5776 : u32 = (x_5772 ^ (x_5772 >> 11u));
  let x_5781 : u32 = (x_5776 ^ ((x_5776 << 7u) & 2636928640u));
  let x_5786 : u32 = (x_5781 ^ ((x_5781 << 15u) & 4022730752u));
  let x_5796 : u32 = ((((x_5744.x * 1664525u) + (x_5786 ^ (x_5786 >> 18u))) + 1013904223u) * 1664525u);
  let x_5800 : u32 = (x_5796 ^ (x_5796 >> 11u));
  let x_5805 : u32 = (x_5800 ^ ((x_5800 << 7u) & 2636928640u));
  let x_5810 : u32 = (x_5805 ^ ((x_5805 << 15u) & 4022730752u));
  let x_5814 : u32 = (x_5810 ^ (x_5810 >> 18u));
  x_23840 = x_5814;
  x_23839 = 0u;
  loop {
    if ((x_23839 >= 2u)) {
      break;
    }
    let x_5826 : u32 = (x_23840 + (x_23840 << 10u));
    let x_5830 : u32 = (x_5826 ^ (x_5826 >> 6u));
    let x_5834 : u32 = (x_5830 + (x_5830 << 3u));
    let x_5838 : u32 = (x_5834 ^ (x_5834 >> 11u));
    x_4022[x_23839] = (bitcast<f32>(((x_23840 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23840 = (x_5838 + (x_5838 << 15u));
      x_23839 = (x_23839 + 1u);
    }
  }
  let x_5858 : vec3<u32> = bitcast<vec3<u32>>((x_5056 + vec3<i32>(1i, 1i, 1i)));
  let x_5860 : u32 = x_5858.z;
  let x_5864 : u32 = (x_5860 + (x_5860 << 10u));
  let x_5868 : u32 = (x_5864 ^ (x_5864 >> 6u));
  let x_5872 : u32 = (x_5868 + (x_5868 << 3u));
  let x_5876 : u32 = (x_5872 ^ (x_5872 >> 11u));
  let x_5886 : u32 = ((((x_5858.y * 1664525u) + (x_5876 + (x_5876 << 15u))) + 1013904223u) * 1664525u);
  let x_5890 : u32 = (x_5886 ^ (x_5886 >> 11u));
  let x_5895 : u32 = (x_5890 ^ ((x_5890 << 7u) & 2636928640u));
  let x_5900 : u32 = (x_5895 ^ ((x_5895 << 15u) & 4022730752u));
  let x_5910 : u32 = ((((x_5858.x * 1664525u) + (x_5900 ^ (x_5900 >> 18u))) + 1013904223u) * 1664525u);
  let x_5914 : u32 = (x_5910 ^ (x_5910 >> 11u));
  let x_5919 : u32 = (x_5914 ^ ((x_5914 << 7u) & 2636928640u));
  let x_5924 : u32 = (x_5919 ^ ((x_5919 << 15u) & 4022730752u));
  let x_5928 : u32 = (x_5924 ^ (x_5924 >> 18u));
  x_23843 = x_5928;
  x_23842 = 0u;
  loop {
    if ((x_23842 >= 2u)) {
      break;
    }
    let x_5940 : u32 = (x_23843 + (x_23843 << 10u));
    let x_5944 : u32 = (x_5940 ^ (x_5940 >> 6u));
    let x_5948 : u32 = (x_5944 + (x_5944 << 3u));
    let x_5952 : u32 = (x_5948 ^ (x_5948 >> 11u));
    x_4046[x_23842] = (bitcast<f32>(((x_23843 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_23843 = (x_5952 + (x_5952 << 15u));
      x_23842 = (x_23842 + 1u);
    }
  }
  var x_18983 : i32;
  var x_18998 : u32;
  var x_23999 : u32;
  let x_5976 : vec3<f32> = ((x_5058 * x_5058) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_5058)));
  let x_5978 : f32 = x_5976.x;
  let x_5980 : f32 = (1.0f - x_5978);
  let x_5982 : f32 = x_5976.y;
  let x_5984 : f32 = (1.0f - x_5982);
  let x_5986 : f32 = x_5976.z;
  let x_5988 : f32 = (1.0f - x_5986);
  let x_5989 : vec2<f32> = x_3878;
  let x_5996 : vec2<f32> = x_3902;
  let x_6004 : vec2<f32> = x_3926;
  let x_6012 : vec2<f32> = x_3950;
  let x_6020 : vec2<f32> = x_3974;
  let x_6028 : vec2<f32> = x_3998;
  let x_6036 : vec2<f32> = x_4022;
  let x_6044 : vec2<f32> = x_4046;
  let x_6054 : vec2<f32> = clamp(((((((((((((x_5989 * x_5980) * x_5984) * x_5988) + (((x_5996 * x_5978) * x_5984) * x_5988)) + (((x_6004 * x_5980) * x_5982) * x_5988)) + (((x_6012 * x_5978) * x_5982) * x_5988)) + (((x_6020 * x_5980) * x_5984) * x_5986)) + (((x_6028 * x_5978) * x_5984) * x_5986)) + (((x_6036 * x_5980) * x_5982) * x_5986)) + (((x_6044 * x_5978) * x_5982) * x_5986)) - x_2694) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_2694);
  let x_6062 : vec3<f32> = (x_23820 + (vec3<f32>(x_6054.x, 0.0f, x_6054.y) * 0.05999999865889549255f));
  let x_6064 : vec2<f32> = vec2<f32>(x_6062.x, x_6062.z);
  let x_18299 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_18306 : i32 = x_18299.x;
  let x_18315 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_18306), (x_6795 / x_18306)), 0i);
  x_18983 = (((bitcast<i32>(x_18315[x_6808]) * 16i) + 13i) % 16i);
  if ((x_18983 < 4i)) {
    x_18990 = instanceWords0[(x_18983 % 4i)];
    x_24001 = x_18990;
  } else {
    var x_19006 : u32;
    var x_19011 : u32;
    if ((x_18983 < 8i)) {
      x_18998 = instanceWords1[(x_18983 % 4i)];
      x_24000 = x_18998;
    } else {
      if ((x_18983 < 12i)) {
        x_19006 = instanceWords2[(x_18983 % 4i)];
        x_23999 = x_19006;
      } else {
        x_19011 = instanceWords3[(x_18983 % 4i)];
        x_23999 = x_19011;
      }
      x_24000 = x_23999;
    }
    x_24001 = x_24000;
  }
  let x_6072 : u32 = bitcast<u32>((bitcast<i32>(x_24001) ^ 787234i));
  let x_6076 : u32 = (x_6072 + (x_6072 << 10u));
  let x_6080 : u32 = (x_6076 ^ (x_6076 >> 6u));
  let x_6084 : u32 = (x_6080 + (x_6080 << 3u));
  let x_6088 : u32 = (x_6084 ^ (x_6084 >> 11u));
  let x_6097 : f32 = (bitcast<f32>((((x_6088 + (x_6088 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
  let x_6099 : vec2<f32> = (x_6064 + vec2<f32>(x_6097, x_6097));
  let x_6102 : vec2<i32> = vec2<i32>(floor(x_6099));
  let x_6104 : vec2<f32> = fract(x_6099);
  let x_6106 : vec2<u32> = bitcast<vec2<u32>>(x_6102);
  let x_6108 : u32 = x_6106.y;
  let x_6112 : u32 = (x_6108 + (x_6108 << 10u));
  let x_6116 : u32 = (x_6112 ^ (x_6112 >> 6u));
  let x_6120 : u32 = (x_6116 + (x_6116 << 3u));
  let x_6124 : u32 = (x_6120 ^ (x_6120 >> 11u));
  let x_6134 : u32 = ((((x_6106.x * 1664525u) + (x_6124 + (x_6124 << 15u))) + 1013904223u) * 1664525u);
  let x_6138 : u32 = (x_6134 ^ (x_6134 >> 11u));
  let x_6143 : u32 = (x_6138 ^ ((x_6138 << 7u) & 2636928640u));
  let x_6148 : u32 = (x_6143 ^ ((x_6143 << 15u) & 4022730752u));
  let x_6152 : u32 = (x_6148 ^ (x_6148 >> 18u));
  x_24121 = x_6152;
  x_24120 = 0u;
  x_25086 = 0.0f;
  loop {
    if ((x_24120 >= 1u)) {
      break;
    }
    let x_6165 : u32 = (x_24121 + (x_24121 << 10u));
    let x_6169 : u32 = (x_6165 ^ (x_6165 >> 6u));
    let x_6173 : u32 = (x_6169 + (x_6169 << 3u));
    let x_6177 : u32 = (x_6173 ^ (x_6173 >> 11u));

    continuing {
      x_24121 = (x_6177 + (x_6177 << 15u));
      x_24120 = (x_24120 + 1u);
      x_25086 = (bitcast<f32>(((x_24121 & 8388607u) | 1065353216u)) - 1.0f);
    }
  }
  let x_6196 : vec2<u32> = bitcast<vec2<u32>>((x_6102 + x_1068));
  let x_6198 : u32 = x_6196.y;
  let x_6202 : u32 = (x_6198 + (x_6198 << 10u));
  let x_6206 : u32 = (x_6202 ^ (x_6202 >> 6u));
  let x_6210 : u32 = (x_6206 + (x_6206 << 3u));
  let x_6214 : u32 = (x_6210 ^ (x_6210 >> 11u));
  let x_6224 : u32 = ((((x_6196.x * 1664525u) + (x_6214 + (x_6214 << 15u))) + 1013904223u) * 1664525u);
  let x_6228 : u32 = (x_6224 ^ (x_6224 >> 11u));
  let x_6233 : u32 = (x_6228 ^ ((x_6228 << 7u) & 2636928640u));
  let x_6238 : u32 = (x_6233 ^ ((x_6233 << 15u) & 4022730752u));
  let x_6242 : u32 = (x_6238 ^ (x_6238 >> 18u));
  x_24125 = x_6242;
  x_24124 = 0u;
  x_25187 = 0.0f;
  loop {
    if ((x_24124 >= 1u)) {
      break;
    }
    let x_6255 : u32 = (x_24125 + (x_24125 << 10u));
    let x_6259 : u32 = (x_6255 ^ (x_6255 >> 6u));
    let x_6263 : u32 = (x_6259 + (x_6259 << 3u));
    let x_6267 : u32 = (x_6263 ^ (x_6263 >> 11u));

    continuing {
      x_24125 = (x_6267 + (x_6267 << 15u));
      x_24124 = (x_24124 + 1u);
      x_25187 = (bitcast<f32>(((x_24125 & 8388607u) | 1065353216u)) - 1.0f);
    }
  }
  let x_6286 : vec2<u32> = bitcast<vec2<u32>>((x_6102 + x_1182));
  let x_6288 : u32 = x_6286.y;
  let x_6292 : u32 = (x_6288 + (x_6288 << 10u));
  let x_6296 : u32 = (x_6292 ^ (x_6292 >> 6u));
  let x_6300 : u32 = (x_6296 + (x_6296 << 3u));
  let x_6304 : u32 = (x_6300 ^ (x_6300 >> 11u));
  let x_6314 : u32 = ((((x_6286.x * 1664525u) + (x_6304 + (x_6304 << 15u))) + 1013904223u) * 1664525u);
  let x_6318 : u32 = (x_6314 ^ (x_6314 >> 11u));
  let x_6323 : u32 = (x_6318 ^ ((x_6318 << 7u) & 2636928640u));
  let x_6328 : u32 = (x_6323 ^ ((x_6323 << 15u) & 4022730752u));
  let x_6332 : u32 = (x_6328 ^ (x_6328 >> 18u));
  x_24129 = x_6332;
  x_24128 = 0u;
  x_25287 = 0.0f;
  loop {
    if ((x_24128 >= 1u)) {
      break;
    }
    let x_6345 : u32 = (x_24129 + (x_24129 << 10u));
    let x_6349 : u32 = (x_6345 ^ (x_6345 >> 6u));
    let x_6353 : u32 = (x_6349 + (x_6349 << 3u));
    let x_6357 : u32 = (x_6353 ^ (x_6353 >> 11u));

    continuing {
      x_24129 = (x_6357 + (x_6357 << 15u));
      x_24128 = (x_24128 + 1u);
      x_25287 = (bitcast<f32>(((x_24129 & 8388607u) | 1065353216u)) - 1.0f);
    }
  }
  let x_6376 : vec2<u32> = bitcast<vec2<u32>>((x_6102 + x_1296));
  let x_6378 : u32 = x_6376.y;
  let x_6382 : u32 = (x_6378 + (x_6378 << 10u));
  let x_6386 : u32 = (x_6382 ^ (x_6382 >> 6u));
  let x_6390 : u32 = (x_6386 + (x_6386 << 3u));
  let x_6394 : u32 = (x_6390 ^ (x_6390 >> 11u));
  let x_6404 : u32 = ((((x_6376.x * 1664525u) + (x_6394 + (x_6394 << 15u))) + 1013904223u) * 1664525u);
  let x_6408 : u32 = (x_6404 ^ (x_6404 >> 11u));
  let x_6413 : u32 = (x_6408 ^ ((x_6408 << 7u) & 2636928640u));
  let x_6418 : u32 = (x_6413 ^ ((x_6413 << 15u) & 4022730752u));
  let x_6422 : u32 = (x_6418 ^ (x_6418 >> 18u));
  x_24133 = x_6422;
  x_24132 = 0u;
  x_25337 = 0.0f;
  loop {
    if ((x_24132 >= 1u)) {
      break;
    }
    let x_6435 : u32 = (x_24133 + (x_24133 << 10u));
    let x_6439 : u32 = (x_6435 ^ (x_6435 >> 6u));
    let x_6443 : u32 = (x_6439 + (x_6439 << 3u));
    let x_6447 : u32 = (x_6443 ^ (x_6443 >> 11u));

    continuing {
      x_24133 = (x_6447 + (x_6447 << 15u));
      x_24132 = (x_24132 + 1u);
      x_25337 = (bitcast<f32>(((x_24133 & 8388607u) | 1065353216u)) - 1.0f);
    }
  }
  var x_19800 : i32;
  var x_19815 : u32;
  var x_24324 : u32;
  let x_6470 : vec2<f32> = ((x_6104 * x_6104) * (x_1413 - (x_1414 * x_6104)));
  let x_6472 : f32 = x_6470.x;
  let x_6474 : f32 = (1.0f - x_6472);
  let x_6476 : f32 = x_6470.y;
  let x_6484 : vec2<f32> = (((x_6064 * 0.28600001335144042969f) * 0.5f) + ((vec2<f32>(x_6062.y, x_6062.y) * 0.28600001335144042969f) * 0.5f));
  let x_6487 : f32 = dot(x_6484, vec2<f32>(0.36602541804313659668f, 0.36602541804313659668f));
  let x_6490 : vec2<f32> = floor((x_6484 + vec2<f32>(x_6487, x_6487)));
  let x_6495 : f32 = dot(x_6490, vec2<f32>(0.21132487058639526367f, 0.21132487058639526367f));
  let x_6497 : vec2<f32> = ((x_6484 - x_6490) + vec2<f32>(x_6495, x_6495));
  let x_6499 : f32 = x_6497.x;
  let x_6501 : f32 = x_6497.y;
  let x_6504 : bool = (x_6499 > x_6501);
  let x_6506 : vec2<f32> = select(vec2<f32>(0.0f, 1.0f), vec2<f32>(1.0f, 0.0f), vec2<bool>(x_6504, x_6504));
  let x_6509 : vec4<f32> = (vec4<f32>(x_6497.x, x_6497.y, x_6497.x, x_6497.y) + vec4<f32>(0.21132487058639526367f, 0.21132487058639526367f, -0.57735025882720947266f, -0.57735025882720947266f));
  let x_6513 : vec2<f32> = (vec2<f32>(x_6509.x, x_6509.y) - x_6506);
  var x_25707_1 : vec4<f32> = x_6509;
  x_25707_1.x = x_6513.x;
  let x_25707 : vec4<f32> = x_25707_1;
  var x_25710_1 : vec4<f32> = x_25707;
  x_25710_1.y = x_6513.y;
  let x_25710 : vec4<f32> = x_25710_1;
  let x_6526 : vec2<f32> = (x_6490 - (vec2<f32>(289.0f, 289.0f) * trunc((x_6490 * vec2<f32>(0.00346020772121846676f, 0.00346020772121846676f)))));
  let x_6528 : f32 = x_6526.y;
  let x_6533 : vec3<f32> = (vec3<f32>(x_6528, x_6528, x_6528) + vec3<f32>(0.0f, x_6506.y, 1.0f));
  let x_6538 : vec3<f32> = (((x_6533 * 34.0f) + x_3316) * x_6533);
  let x_6546 : f32 = x_6526.x;
  let x_6552 : vec3<f32> = (((x_6538 - (x_3322 * trunc((x_6538 * x_25572)))) + vec3<f32>(x_6546, x_6546, x_6546)) + vec3<f32>(0.0f, x_6506.x, 1.0f));
  let x_6557 : vec3<f32> = (((x_6552 * 34.0f) + x_3316) * x_6552);
  let x_6562 : vec2<f32> = vec2<f32>(x_25710.x, x_25710.y);
  let x_6567 : vec2<f32> = vec2<f32>(x_25710.z, x_25710.w);
  let x_6573 : vec3<f32> = max((x_3343 - vec3<f32>(dot(x_6497, x_6497), dot(x_6562, x_6562), dot(x_6567, x_6567))), x_709);
  let x_6576 : vec3<f32> = (x_6573 * x_6573);
  let x_6585 : vec3<f32> = (fract(((x_6557 - (x_3322 * trunc((x_6557 * x_25572)))) * vec3<f32>(0.02439024299383163452f, 0.02439024299383163452f, 0.02439024299383163452f))) * 2.0f);
  let x_6587 : vec3<f32> = (x_6585 - x_3316);
  let x_6590 : vec3<f32> = (abs(x_6587) - x_3343);
  let x_6595 : vec3<f32> = (x_6587 - floor((x_6585 + vec3<f32>(-0.5f, -0.5f, -0.5f))));
  var x_25717_1 : vec4<f32> = x_4329;
  x_25717_1.w = (x_4328 + dot((x_4622 - x_6062), vec3<f32>(x_4329.x, x_4329.y, x_4329.z)));
  let x_25717 : vec4<f32> = x_25717_1;
  let x_19116 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_19123 : i32 = x_19116.x;
  let x_19132 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_19123), (x_6795 / x_19123)), 0i);
  x_19800 = (((bitcast<i32>(x_19132[x_6808]) * 16i) + 13i) % 16i);
  if ((x_19800 < 4i)) {
    x_19807 = instanceWords0[(x_19800 % 4i)];
    x_24326 = x_19807;
  } else {
    var x_19823 : u32;
    var x_19828 : u32;
    if ((x_19800 < 8i)) {
      x_19815 = instanceWords1[(x_19800 % 4i)];
      x_24325 = x_19815;
    } else {
      if ((x_19800 < 12i)) {
        x_19823 = instanceWords2[(x_19800 % 4i)];
        x_24324 = x_19823;
      } else {
        x_19828 = instanceWords3[(x_19800 % 4i)];
        x_24324 = x_19828;
      }
      x_24325 = x_24324;
    }
    x_24326 = x_24325;
  }
  let x_6612 : i32 = (bitcast<i32>(x_24326) * 1664525i);
  let x_6614 : u32 = bitcast<u32>(x_6612);
  let x_6618 : u32 = (x_6614 + (x_6614 << 10u));
  let x_6622 : u32 = (x_6618 ^ (x_6618 >> 6u));
  let x_6626 : u32 = (x_6622 + (x_6622 << 3u));
  let x_6630 : u32 = (x_6626 ^ (x_6626 >> 11u));
  let x_6633 : u32 = bitcast<u32>((x_6612 + 34568i));
  let x_6637 : u32 = (x_6633 + (x_6633 << 10u));
  let x_6641 : u32 = (x_6637 ^ (x_6637 >> 6u));
  let x_6645 : u32 = (x_6641 + (x_6641 << 3u));
  let x_6649 : u32 = (x_6645 ^ (x_6645 >> 11u));
  let x_6672 : vec2<f32> = vec2<f32>((round(((bitcast<f32>((((x_6630 + (x_6630 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) * 5.0f)) * 0.20000000298023223877f), (round(((bitcast<f32>((((x_6649 + (x_6649 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) * 5.0f)) * 0.20000000298023223877f));
  if (!(x_4345)) {
    x_6679 = (clamp((x_4624 * 0.05000000074505805969f), 0.0f, 1.0f) * 0.69999998807907104492f);
    x_25517 = x_6679;
  } else {
    x_25517 = x_4338;
  }
  let x_6684 : mat4x4<f32> = x_3504.renderer_MVPMat;
  gl_Position = (x_6684 * vec4<f32>(x_6062.x, x_6062.y, x_6062.z, 1.0f));
  v0 = x_6062;
  v1 = pow(fract(((((1.0f - x_6476) * ((x_25086 * x_6474) + (x_25187 * x_6472))) + ((x_25287 * x_6474) * x_6476)) + ((x_25337 * x_6472) * x_6476))), 1.5f);
  let x_6749 : vec2<f32> = ((vec2<f32>(x_6595.y, x_6595.z) * vec2<f32>(x_25710.x, x_25710.z)) + (vec2<f32>(x_6590.y, x_6590.z) * vec2<f32>(x_25710.y, x_25710.w)));
  v2 = (dot(((x_6576 * x_6576) * (vec3<f32>(1.792842864990234375f, 1.792842864990234375f, 1.792842864990234375f) - (((x_6595 * x_6595) + (x_6590 * x_6590)) * 0.85373473167419433594f))), vec3<f32>(((x_6595.x * x_6499) + (x_6590.x * x_6501)), x_6749.x, x_6749.y)) * 32.5f);
  v3 = x_25517;
  v4 = ((((vec2<f32>(x_4398.x, x_4398.y) * vec2<f32>(0.85000002384185791016f, 0.92000001668930053711f)) + x_2694) * 0.20000000298023223877f) + x_6672);
  v5 = x_25717;
  let x_19933 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_19940 : i32 = x_19933.x;
  let x_19949 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_6795 % x_19940), (x_6795 / x_19940)), 0i);
  v6 = x_19949[x_6808];
  v7 = x_4399.z;
  v8 = ((((vec2<f32>(x_4398.y, x_4398.z) * vec2<f32>(0.80000001192092895508f, 0.89999997615814208984f)) + x_2694) * 0.20000000298023223877f) + x_6672);
  let x_3655 : vec4<u32> = instanceWords0;
  instanceRecord0 = x_3655;
  let x_3656 : vec4<u32> = instanceWords1;
  instanceRecord1 = x_3656;
  let x_3657 : vec4<u32> = instanceWords2;
  instanceRecord2 = x_3657;
  let x_3658 : vec4<u32> = instanceWords3;
  instanceRecord3 = x_3658;
  let x_3659 : u32 = instanceVisible;
  if ((x_3659 == 0u)) {
    gl_Position = vec4<f32>(2.0f, 2.0f, 2.0f, 1.0f);
  }
  let x_3642 : f32 = gl_Position.z;
  let x_3644 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_3642 + x_3644));
  return;
}

struct main_out {
  @builtin(position)
  gl_Position : vec4<f32>,
  @location(4)
  v0_1 : vec3<f32>,
  @location(5)
  v1_1 : f32,
  @location(6)
  v2_1 : f32,
  @location(7)
  v3_1 : f32,
  @location(8)
  v4_1 : vec2<f32>,
  @location(9) @interpolate(flat)
  v5_1 : vec4<f32>,
  @location(10) @interpolate(flat)
  v6_1 : u32,
  @location(11)
  v7_1 : f32,
  @location(12)
  v8_1 : vec2<f32>,
  @location(0) @interpolate(flat)
  instanceRecord0_1 : vec4<u32>,
  @location(1) @interpolate(flat)
  instanceRecord1_1 : vec4<u32>,
  @location(2) @interpolate(flat)
  instanceRecord2_1 : vec4<u32>,
  @location(3) @interpolate(flat)
  instanceRecord3_1 : vec4<u32>,
}

@vertex
fn main(@location(8) @interpolate(flat) instanceWords0_param : vec4<u32>, @location(9) @interpolate(flat) instanceWords1_param : vec4<u32>, @location(10) @interpolate(flat) instanceWords2_param : vec4<u32>, @location(11) @interpolate(flat) instanceWords3_param : vec4<u32>, @builtin(instance_index) gl_InstanceIndex_param : u32, @location(0) Vertex_Position_param : vec3<f32>, @location(12) @interpolate(flat) instanceVisible_param : u32) -> main_out {
  instanceWords0 = instanceWords0_param;
  instanceWords1 = instanceWords1_param;
  instanceWords2 = instanceWords2_param;
  instanceWords3 = instanceWords3_param;
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  Vertex_Position = Vertex_Position_param;
  instanceVisible = instanceVisible_param;
  main_1();
  return main_out(gl_Position, v0, v1, v2, v3, v4, v5, v6, v7, v8, instanceRecord0, instanceRecord1, instanceRecord2, instanceRecord3);
}
