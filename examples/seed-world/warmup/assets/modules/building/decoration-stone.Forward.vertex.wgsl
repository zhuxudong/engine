diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(0) @group(3) var gs_wgpu_tex_storage_7_0 : texture_2d<u32>;

@binding(1) @group(3) var gs_wgpu_samp_storage_7_0 : sampler;

@binding(2) @group(3) var gs_wgpu_tex_storage_0_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_0 : sampler;

@binding(6) @group(3) var gs_wgpu_tex_storage_6_0 : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_storage_6_0 : sampler;

@binding(8) @group(3) var gs_wgpu_tex_storage_22_0 : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_storage_22_0 : sampler;

var<private> gl_InstanceIndex : i32;

var<private> Vertex_Position : vec3<f32>;

var<private> bbx_x : f32;

var<private> is_bevel : i32;

var<private> brick_id : i32;

var<private> Vertex_UV : vec2<f32>;

@binding(0) @group(2) var<uniform> x_2436 : gs_Auto_0;

var<private> v0 : u32;

var<private> v1 : vec3<f32>;

var<private> Vertex_Normal : vec3<f32>;

var<private> v2 : vec3<f32>;

var<private> v7 : f32;

var<private> v8 : f32;

var<private> v9 : vec2<f32>;

var<private> v10 : i32;

var<private> v11 : vec2<f32>;

var<private> v12 : i32;

var<private> v13 : u32;

var<private> gl_Position : vec4<f32>;

const x_2188 = vec2<f32>(0.5f, 0.5f);

fn main_1() {
  var x_2741 : vec2<f32>;
  var x_2765 : vec2<f32>;
  var x_2789 : vec2<f32>;
  var x_2813 : vec2<f32>;
  var x_2837 : vec2<f32>;
  var x_2861 : vec2<f32>;
  var x_2885 : vec2<f32>;
  var x_2909 : vec2<f32>;
  var x_3096 : vec3<f32>;
  var x_20849 : f32;
  var x_58605 : f32;
  var x_58606 : f32;
  var x_20877 : f32;
  var x_58609 : f32;
  var x_20900 : f32;
  var x_58613 : f32;
  var x_58614 : f32;
  var x_20928 : f32;
  var x_58617 : f32;
  var x_3159 : vec3<f32>;
  var x_58926 : vec3<f32>;
  var x_3238 : vec3<f32>;
  var x_58960 : vec3<f32>;
  var x_58681 : vec3<f32>;
  var x_58680 : vec3<f32>;
  var x_58815 : vec3<f32>;
  var x_58682 : vec3<f32>;
  var x_58684 : u32;
  var x_58683 : u32;
  var x_58687 : u32;
  var x_58686 : u32;
  var x_58690 : u32;
  var x_58689 : u32;
  var x_58693 : u32;
  var x_58692 : u32;
  var x_58696 : u32;
  var x_58695 : u32;
  var x_58699 : u32;
  var x_58698 : u32;
  var x_58702 : u32;
  var x_58701 : u32;
  var x_58705 : u32;
  var x_58704 : u32;
  var x_4295 : i32;
  var x_58775 : i32;
  var x_40908 : f32;
  var x_58745 : f32;
  var x_58746 : f32;
  var x_40936 : f32;
  var x_58749 : f32;
  var x_40959 : f32;
  var x_58753 : f32;
  var x_58754 : f32;
  var x_40987 : f32;
  var x_58757 : f32;
  var x_4426 : vec2<f32>;
  var x_4432 : vec2<f32>;
  var x_58778 : vec2<f32>;
  var x_4441 : vec2<f32>;
  var x_58788 : vec2<f32>;
  var x_4447 : vec2<f32>;
  var x_58795 : vec2<f32>;
  let x_2986 : i32 = gl_InstanceIndex;
  let x_4593 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_4598 : i32 = (x_2986 / 4i);
  let x_4600 : i32 = x_4593.x;
  let x_4609 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_4600), (x_4598 / x_4600)), 0i);
  let x_4611 : i32 = (x_2986 % 4i);
  let x_4778 : i32 = ((bitcast<i32>(x_4609[x_4611]) * 32i) + 15i);
  let x_5288 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_5293 : i32 = (x_4778 / 4i);
  let x_5295 : i32 = x_5288.x;
  let x_5304 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5293 % x_5295), (x_5293 / x_5295)), 0i);
  if (((x_5304[(x_4778 % 4i)] & 4u) != 0u)) {
    let x_2997 : vec3<f32> = Vertex_Position;
    let x_5754 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_5761 : i32 = x_5754.x;
    let x_5770 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_5761), (x_4598 / x_5761)), 0i);
    let x_5809 : i32 = (bitcast<i32>(x_5770[x_4611]) * 32i);
    let x_6043 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_6048 : i32 = (x_5809 / 4i);
    let x_6050 : i32 = x_6043.x;
    let x_6059 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_6048 % x_6050), (x_6048 / x_6050)), 0i);
    let x_6914 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_6921 : i32 = x_6914.x;
    let x_6930 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_6921), (x_4598 / x_6921)), 0i);
    let x_6982 : i32 = ((bitcast<i32>(x_6930[x_4611]) * 32i) + 1i);
    let x_7230 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_7235 : i32 = (x_6982 / 4i);
    let x_7237 : i32 = x_7230.x;
    let x_7246 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_7235 % x_7237), (x_7235 / x_7237)), 0i);
    let x_8074 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_8081 : i32 = x_8074.x;
    let x_8090 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_8081), (x_4598 / x_8081)), 0i);
    let x_8151 : i32 = ((bitcast<i32>(x_8090[x_4611]) * 32i) + 2i);
    let x_8417 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_8422 : i32 = (x_8151 / 4i);
    let x_8424 : i32 = x_8417.x;
    let x_8433 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_8422 % x_8424), (x_8422 / x_8424)), 0i);
    let x_9234 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_9241 : i32 = x_9234.x;
    let x_9250 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_9241), (x_4598 / x_9241)), 0i);
    let x_9320 : i32 = ((bitcast<i32>(x_9250[x_4611]) * 32i) + 3i);
    let x_9604 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_9609 : i32 = (x_9320 / 4i);
    let x_9611 : i32 = x_9604.x;
    let x_9620 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_9609 % x_9611), (x_9609 / x_9611)), 0i);
    let x_10394 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_10401 : i32 = x_10394.x;
    let x_10410 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_10401), (x_4598 / x_10401)), 0i);
    let x_10489 : i32 = ((bitcast<i32>(x_10410[x_4611]) * 32i) + 4i);
    let x_10791 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_10796 : i32 = (x_10489 / 4i);
    let x_10798 : i32 = x_10791.x;
    let x_10807 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_10796 % x_10798), (x_10796 / x_10798)), 0i);
    let x_11554 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_11561 : i32 = x_11554.x;
    let x_11570 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_11561), (x_4598 / x_11561)), 0i);
    let x_11658 : i32 = ((bitcast<i32>(x_11570[x_4611]) * 32i) + 5i);
    let x_11978 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_11983 : i32 = (x_11658 / 4i);
    let x_11985 : i32 = x_11978.x;
    let x_11994 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_11983 % x_11985), (x_11983 / x_11985)), 0i);
    let x_12714 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_12721 : i32 = x_12714.x;
    let x_12730 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_12721), (x_4598 / x_12721)), 0i);
    let x_12827 : i32 = ((bitcast<i32>(x_12730[x_4611]) * 32i) + 6i);
    let x_13165 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_13170 : i32 = (x_12827 / 4i);
    let x_13172 : i32 = x_13165.x;
    let x_13181 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_13170 % x_13172), (x_13170 / x_13172)), 0i);
    let x_13874 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_13881 : i32 = x_13874.x;
    let x_13890 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_13881), (x_4598 / x_13881)), 0i);
    let x_13996 : i32 = ((bitcast<i32>(x_13890[x_4611]) * 32i) + 7i);
    let x_14352 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_14357 : i32 = (x_13996 / 4i);
    let x_14359 : i32 = x_14352.x;
    let x_14368 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_14357 % x_14359), (x_14357 / x_14359)), 0i);
    let x_15034 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_15041 : i32 = x_15034.x;
    let x_15050 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_15041), (x_4598 / x_15041)), 0i);
    let x_15165 : i32 = ((bitcast<i32>(x_15050[x_4611]) * 32i) + 8i);
    let x_15539 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_15544 : i32 = (x_15165 / 4i);
    let x_15546 : i32 = x_15539.x;
    let x_15555 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_15544 % x_15546), (x_15544 / x_15546)), 0i);
    let x_16194 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_16201 : i32 = x_16194.x;
    let x_16210 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_16201), (x_4598 / x_16201)), 0i);
    let x_16334 : i32 = ((bitcast<i32>(x_16210[x_4611]) * 32i) + 9i);
    let x_16726 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_16731 : i32 = (x_16334 / 4i);
    let x_16733 : i32 = x_16726.x;
    let x_16742 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_16731 % x_16733), (x_16731 / x_16733)), 0i);
    let x_17354 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_17361 : i32 = x_17354.x;
    let x_17370 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_17361), (x_4598 / x_17361)), 0i);
    let x_17503 : i32 = ((bitcast<i32>(x_17370[x_4611]) * 32i) + 10i);
    let x_17913 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_17918 : i32 = (x_17503 / 4i);
    let x_17920 : i32 = x_17913.x;
    let x_17929 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_17918 % x_17920), (x_17918 / x_17920)), 0i);
    let x_18514 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_18521 : i32 = x_18514.x;
    let x_18530 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_18521), (x_4598 / x_18521)), 0i);
    let x_18672 : i32 = ((bitcast<i32>(x_18530[x_4611]) * 32i) + 11i);
    let x_19100 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_19105 : i32 = (x_18672 / 4i);
    let x_19107 : i32 = x_19100.x;
    let x_19116 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_19105 % x_19107), (x_19105 / x_19107)), 0i);
    x_3096 = (vec4<f32>(x_2997.x, x_2997.y, x_2997.z, 1.0f) * transpose(mat4x3<f32>(vec3<f32>(bitcast<f32>(x_6059[(x_5809 % 4i)]), bitcast<f32>(x_7246[(x_6982 % 4i)]), bitcast<f32>(x_8433[(x_8151 % 4i)])), vec3<f32>(bitcast<f32>(x_9620[(x_9320 % 4i)]), bitcast<f32>(x_10807[(x_10489 % 4i)]), bitcast<f32>(x_11994[(x_11658 % 4i)])), vec3<f32>(bitcast<f32>(x_13181[(x_12827 % 4i)]), bitcast<f32>(x_14368[(x_13996 % 4i)]), bitcast<f32>(x_15555[(x_15165 % 4i)])), vec3<f32>(bitcast<f32>(x_16742[(x_16334 % 4i)]), bitcast<f32>(x_17929[(x_17503 % 4i)]), bitcast<f32>(x_19116[(x_18672 % 4i)])))));
    x_58815 = x_3096;
    x_58682 = x_3096;
  } else {
    var x_20841 : u32;
    var x_20843 : u32;
    var x_20857 : f32;
    var x_20867 : f32;
    let x_19674 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
    let x_19681 : i32 = x_19674.x;
    let x_19690 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_19681), (x_4598 / x_19681)), 0i);
    let x_19906 : i32 = ((bitcast<i32>(x_19690[x_4611]) * 32i) + 23i);
    let x_20584 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_20589 : i32 = (x_19906 / 4i);
    let x_20591 : i32 = x_20584.x;
    let x_20600 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_20589 % x_20591), (x_20589 / x_20591)), 0i);
    let x_20603 : u32 = x_20600[(x_19906 % 4i)];
    x_20841 = (((x_20603 & 65535u) >> 10u) & 31u);
    x_20843 = (x_20603 & 1023u);
    if ((x_20841 == 0u)) {
      x_20849 = (f32(x_20843) * 0.00000005960464477539f);
      x_58606 = x_20849;
    } else {
      if ((x_20841 == 31u)) {
        x_20857 = bitcast<f32>((2139095040u | (x_20843 << 13u)));
        x_58605 = x_20857;
      } else {
        x_20867 = ((1.0f + (f32(x_20843) * 0.0009765625f)) * exp2((f32(x_20841) - 15.0f)));
        x_58605 = x_20867;
      }
      x_58606 = x_58605;
    }
    if (((x_20603 & 32768u) != 0u)) {
      x_20877 = -(x_58606);
      x_58609 = x_20877;
    } else {
      x_58609 = x_58606;
    }
    var x_20892 : u32;
    var x_20894 : u32;
    var x_20908 : f32;
    var x_20918 : f32;
    let x_20828 : u32 = (x_20603 >> 16u);
    x_20892 = ((x_20828 >> 10u) & 31u);
    x_20894 = (x_20828 & 1023u);
    if ((x_20892 == 0u)) {
      x_20900 = (f32(x_20894) * 0.00000005960464477539f);
      x_58614 = x_20900;
    } else {
      if ((x_20892 == 31u)) {
        x_20908 = bitcast<f32>((2139095040u | (x_20894 << 13u)));
        x_58613 = x_20908;
      } else {
        x_20918 = ((1.0f + (f32(x_20894) * 0.0009765625f)) * exp2((f32(x_20892) - 15.0f)));
        x_58613 = x_20918;
      }
      x_58614 = x_58613;
    }
    if (((x_20828 & 32768u) != 0u)) {
      x_20928 = -(x_58614);
      x_58617 = x_20928;
    } else {
      x_58617 = x_58614;
    }
    var x_3107 : f32;
    var x_29082 : f32;
    var x_58649 : f32;
    var x_58650 : f32;
    var x_29110 : f32;
    var x_58653 : f32;
    var x_29133 : f32;
    var x_58657 : f32;
    var x_58658 : f32;
    var x_29161 : f32;
    var x_58661 : f32;
    var x_37315 : f32;
    var x_58624 : f32;
    var x_58625 : f32;
    var x_37343 : f32;
    var x_58628 : f32;
    var x_37366 : f32;
    var x_58632 : f32;
    var x_58633 : f32;
    var x_37394 : f32;
    var x_58636 : f32;
    let x_20830 : vec2<f32> = vec2<f32>(x_58609, x_58617);
    x_3107 = bbx_x;
    if ((x_3107 < 0.5f)) {
      var x_29074 : u32;
      var x_29076 : u32;
      var x_29090 : f32;
      var x_29100 : f32;
      let x_3111 : f32 = (x_3107 * 2.0f);
      let x_3113 : f32 = clamp(x_3111, 0.0f, 1.0f);
      let x_20947 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_20954 : i32 = x_20947.x;
      let x_20963 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_20954), (x_4598 / x_20954)), 0i);
      let x_21136 : i32 = ((bitcast<i32>(x_20963[x_4611]) * 32i) + 16i);
      let x_21668 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_21673 : i32 = (x_21136 / 4i);
      let x_21675 : i32 = x_21668.x;
      let x_21684 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_21673 % x_21675), (x_21673 / x_21675)), 0i);
      let x_22107 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_22114 : i32 = x_22107.x;
      let x_22123 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_22114), (x_4598 / x_22114)), 0i);
      let x_22320 : i32 = ((bitcast<i32>(x_22123[x_4611]) * 32i) + 20i);
      let x_22936 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_22941 : i32 = (x_22320 / 4i);
      let x_22943 : i32 = x_22936.x;
      let x_22952 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_22941 % x_22943), (x_22941 / x_22943)), 0i);
      let x_3129 : f32 = Vertex_Position.y;
      let x_23267 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_23274 : i32 = x_23267.x;
      let x_23283 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_23274), (x_4598 / x_23274)), 0i);
      let x_23463 : i32 = ((bitcast<i32>(x_23283[x_4611]) * 32i) + 17i);
      let x_24015 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_24020 : i32 = (x_23463 / 4i);
      let x_24022 : i32 = x_24015.x;
      let x_24031 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_24020 % x_24022), (x_24020 / x_24022)), 0i);
      let x_24427 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_24434 : i32 = x_24427.x;
      let x_24443 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_24434), (x_4598 / x_24434)), 0i);
      let x_24647 : i32 = ((bitcast<i32>(x_24443[x_4611]) * 32i) + 21i);
      let x_25283 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_25288 : i32 = (x_24647 / 4i);
      let x_25290 : i32 = x_25283.x;
      let x_25299 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_25288 % x_25290), (x_25288 / x_25290)), 0i);
      let x_25587 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_25594 : i32 = x_25587.x;
      let x_25603 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_25594), (x_4598 / x_25594)), 0i);
      let x_25789 : i32 = ((bitcast<i32>(x_25603[x_4611]) * 32i) + 18i);
      let x_26362 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_26367 : i32 = (x_25789 / 4i);
      let x_26369 : i32 = x_26362.x;
      let x_26378 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_26367 % x_26369), (x_26367 / x_26369)), 0i);
      let x_26747 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_26754 : i32 = x_26747.x;
      let x_26763 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_26754), (x_4598 / x_26754)), 0i);
      let x_26973 : i32 = ((bitcast<i32>(x_26763[x_4611]) * 32i) + 22i);
      let x_27630 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_27635 : i32 = (x_26973 / 4i);
      let x_27637 : i32 = x_27630.x;
      let x_27646 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_27635 % x_27637), (x_27635 / x_27637)), 0i);
      x_3159 = vec3<f32>(mix(bitcast<f32>(x_21684[(x_21136 % 4i)]), bitcast<f32>(x_22952[(x_22320 % 4i)]), x_3111), (x_3129 + mix(bitcast<f32>(x_24031[(x_23463 % 4i)]), bitcast<f32>(x_25299[(x_24647 % 4i)]), x_3113)), mix(bitcast<f32>(x_26378[(x_25789 % 4i)]), bitcast<f32>(x_27646[(x_26973 % 4i)]), x_3111));
      let x_3161 : vec2<f32> = vec2<f32>(x_3159.x, x_3159.z);
      let x_27907 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_27914 : i32 = x_27907.x;
      let x_27923 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_27914), (x_4598 / x_27914)), 0i);
      let x_28115 : i32 = ((bitcast<i32>(x_27923[x_4611]) * 32i) + 19i);
      let x_28709 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_28714 : i32 = (x_28115 / 4i);
      let x_28716 : i32 = x_28709.x;
      let x_28725 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_28714 % x_28716), (x_28714 / x_28716)), 0i);
      let x_28728 : u32 = x_28725[(x_28115 % 4i)];
      x_29074 = (((x_28728 & 65535u) >> 10u) & 31u);
      x_29076 = (x_28728 & 1023u);
      if ((x_29074 == 0u)) {
        x_29082 = (f32(x_29076) * 0.00000005960464477539f);
        x_58650 = x_29082;
      } else {
        if ((x_29074 == 31u)) {
          x_29090 = bitcast<f32>((2139095040u | (x_29076 << 13u)));
          x_58649 = x_29090;
        } else {
          x_29100 = ((1.0f + (f32(x_29076) * 0.0009765625f)) * exp2((f32(x_29074) - 15.0f)));
          x_58649 = x_29100;
        }
        x_58650 = x_58649;
      }
      if (((x_28728 & 32768u) != 0u)) {
        x_29110 = -(x_58650);
        x_58653 = x_29110;
      } else {
        x_58653 = x_58650;
      }
      var x_29125 : u32;
      var x_29127 : u32;
      var x_29141 : f32;
      var x_29151 : f32;
      let x_29061 : u32 = (x_28728 >> 16u);
      x_29125 = ((x_29061 >> 10u) & 31u);
      x_29127 = (x_29061 & 1023u);
      if ((x_29125 == 0u)) {
        x_29133 = (f32(x_29127) * 0.00000005960464477539f);
        x_58658 = x_29133;
      } else {
        if ((x_29125 == 31u)) {
          x_29141 = bitcast<f32>((2139095040u | (x_29127 << 13u)));
          x_58657 = x_29141;
        } else {
          x_29151 = ((1.0f + (f32(x_29127) * 0.0009765625f)) * exp2((f32(x_29125) - 15.0f)));
          x_58657 = x_29151;
        }
        x_58658 = x_58657;
      }
      if (((x_29061 & 32768u) != 0u)) {
        x_29161 = -(x_58658);
        x_58661 = x_29161;
      } else {
        x_58661 = x_58658;
      }
      let x_3175 : f32 = Vertex_Position.z;
      let x_3177 : vec2<f32> = (x_3161 + (normalize(mix(vec2<f32>(x_58653, x_58661), x_20830, vec2<f32>(x_3113, x_3113))) * x_3175));
      var x_58923_1 : vec3<f32> = x_3159;
      x_58923_1.x = x_3177.x;
      let x_58923 : vec3<f32> = x_58923_1;
      x_58926 = x_58923;
      x_58926.z = x_3177.y;
      x_58681 = x_58926;
      x_58680 = x_3159;
    } else {
      var x_37307 : u32;
      var x_37309 : u32;
      var x_37323 : f32;
      var x_37333 : f32;
      let x_3190 : f32 = ((x_3107 - 0.5f) * 2.0f);
      let x_3192 : f32 = clamp(x_3190, 0.0f, 1.0f);
      let x_29180 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_29187 : i32 = x_29180.x;
      let x_29196 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_29187), (x_4598 / x_29187)), 0i);
      let x_29393 : i32 = ((bitcast<i32>(x_29196[x_4611]) * 32i) + 20i);
      let x_30009 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_30014 : i32 = (x_29393 / 4i);
      let x_30016 : i32 = x_30009.x;
      let x_30025 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_30014 % x_30016), (x_30014 / x_30016)), 0i);
      let x_30340 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_30347 : i32 = x_30340.x;
      let x_30356 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_30347), (x_4598 / x_30347)), 0i);
      let x_30577 : i32 = ((bitcast<i32>(x_30356[x_4611]) * 32i) + 24i);
      let x_31277 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_31282 : i32 = (x_30577 / 4i);
      let x_31284 : i32 = x_31277.x;
      let x_31293 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_31282 % x_31284), (x_31282 / x_31284)), 0i);
      let x_3208 : f32 = Vertex_Position.y;
      let x_31500 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_31507 : i32 = x_31500.x;
      let x_31516 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_31507), (x_4598 / x_31507)), 0i);
      let x_31720 : i32 = ((bitcast<i32>(x_31516[x_4611]) * 32i) + 21i);
      let x_32356 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_32361 : i32 = (x_31720 / 4i);
      let x_32363 : i32 = x_32356.x;
      let x_32372 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_32361 % x_32363), (x_32361 / x_32363)), 0i);
      let x_32660 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_32667 : i32 = x_32660.x;
      let x_32676 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_32667), (x_4598 / x_32667)), 0i);
      let x_32904 : i32 = ((bitcast<i32>(x_32676[x_4611]) * 32i) + 25i);
      let x_33624 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_33629 : i32 = (x_32904 / 4i);
      let x_33631 : i32 = x_33624.x;
      let x_33640 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_33629 % x_33631), (x_33629 / x_33631)), 0i);
      let x_33820 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_33827 : i32 = x_33820.x;
      let x_33836 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_33827), (x_4598 / x_33827)), 0i);
      let x_34046 : i32 = ((bitcast<i32>(x_33836[x_4611]) * 32i) + 22i);
      let x_34703 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_34708 : i32 = (x_34046 / 4i);
      let x_34710 : i32 = x_34703.x;
      let x_34719 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_34708 % x_34710), (x_34708 / x_34710)), 0i);
      let x_34980 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_34987 : i32 = x_34980.x;
      let x_34996 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_34987), (x_4598 / x_34987)), 0i);
      let x_35230 : i32 = ((bitcast<i32>(x_34996[x_4611]) * 32i) + 26i);
      let x_35971 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_35976 : i32 = (x_35230 / 4i);
      let x_35978 : i32 = x_35971.x;
      let x_35987 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_35976 % x_35978), (x_35976 / x_35978)), 0i);
      x_3238 = vec3<f32>(mix(bitcast<f32>(x_30025[(x_29393 % 4i)]), bitcast<f32>(x_31293[(x_30577 % 4i)]), x_3190), (x_3208 + mix(bitcast<f32>(x_32372[(x_31720 % 4i)]), bitcast<f32>(x_33640[(x_32904 % 4i)]), x_3192)), mix(bitcast<f32>(x_34719[(x_34046 % 4i)]), bitcast<f32>(x_35987[(x_35230 % 4i)]), x_3190));
      let x_3240 : vec2<f32> = vec2<f32>(x_3238.x, x_3238.z);
      let x_36140 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
      let x_36147 : i32 = x_36140.x;
      let x_36156 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_36147), (x_4598 / x_36147)), 0i);
      let x_36396 : i32 = ((bitcast<i32>(x_36156[x_4611]) * 32i) + 27i);
      let x_37158 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
      let x_37163 : i32 = (x_36396 / 4i);
      let x_37165 : i32 = x_37158.x;
      let x_37174 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_37163 % x_37165), (x_37163 / x_37165)), 0i);
      let x_37177 : u32 = x_37174[(x_36396 % 4i)];
      x_37307 = (((x_37177 & 65535u) >> 10u) & 31u);
      x_37309 = (x_37177 & 1023u);
      if ((x_37307 == 0u)) {
        x_37315 = (f32(x_37309) * 0.00000005960464477539f);
        x_58625 = x_37315;
      } else {
        if ((x_37307 == 31u)) {
          x_37323 = bitcast<f32>((2139095040u | (x_37309 << 13u)));
          x_58624 = x_37323;
        } else {
          x_37333 = ((1.0f + (f32(x_37309) * 0.0009765625f)) * exp2((f32(x_37307) - 15.0f)));
          x_58624 = x_37333;
        }
        x_58625 = x_58624;
      }
      if (((x_37177 & 32768u) != 0u)) {
        x_37343 = -(x_58625);
        x_58628 = x_37343;
      } else {
        x_58628 = x_58625;
      }
      var x_37358 : u32;
      var x_37360 : u32;
      var x_37374 : f32;
      var x_37384 : f32;
      let x_37294 : u32 = (x_37177 >> 16u);
      x_37358 = ((x_37294 >> 10u) & 31u);
      x_37360 = (x_37294 & 1023u);
      if ((x_37358 == 0u)) {
        x_37366 = (f32(x_37360) * 0.00000005960464477539f);
        x_58633 = x_37366;
      } else {
        if ((x_37358 == 31u)) {
          x_37374 = bitcast<f32>((2139095040u | (x_37360 << 13u)));
          x_58632 = x_37374;
        } else {
          x_37384 = ((1.0f + (f32(x_37360) * 0.0009765625f)) * exp2((f32(x_37358) - 15.0f)));
          x_58632 = x_37384;
        }
        x_58633 = x_58632;
      }
      if (((x_37294 & 32768u) != 0u)) {
        x_37394 = -(x_58633);
        x_58636 = x_37394;
      } else {
        x_58636 = x_58633;
      }
      let x_3254 : f32 = Vertex_Position.z;
      let x_3256 : vec2<f32> = (x_3240 + (normalize(mix(x_20830, vec2<f32>(x_58628, x_58636), vec2<f32>(x_3192, x_3192))) * x_3254));
      var x_58957_1 : vec3<f32> = x_3238;
      x_58957_1.x = x_3256.x;
      let x_58957 : vec3<f32> = x_58957_1;
      x_58960 = x_58957;
      x_58960.z = x_3256.y;
      x_58681 = x_58960;
      x_58680 = x_3238;
    }
    x_58815 = x_58680;
    x_58682 = x_58681;
  }
  let x_3271 : vec3<f32> = (x_58682 * 0.40000000596046447754f);
  let x_3274 : vec3<i32> = vec3<i32>(floor(x_3271));
  let x_3276 : vec3<f32> = fract(x_3271);
  let x_3278 : vec3<u32> = bitcast<vec3<u32>>(x_3274);
  let x_3280 : u32 = x_3278.z;
  let x_3284 : u32 = (x_3280 + (x_3280 << 10u));
  let x_3288 : u32 = (x_3284 ^ (x_3284 >> 6u));
  let x_3292 : u32 = (x_3288 + (x_3288 << 3u));
  let x_3296 : u32 = (x_3292 ^ (x_3292 >> 11u));
  let x_3306 : u32 = ((((x_3278.y * 1664525u) + (x_3296 + (x_3296 << 15u))) + 1013904223u) * 1664525u);
  let x_3310 : u32 = (x_3306 ^ (x_3306 >> 11u));
  let x_3315 : u32 = (x_3310 ^ ((x_3310 << 7u) & 2636928640u));
  let x_3320 : u32 = (x_3315 ^ ((x_3315 << 15u) & 4022730752u));
  let x_3330 : u32 = ((((x_3278.x * 1664525u) + (x_3320 ^ (x_3320 >> 18u))) + 1013904223u) * 1664525u);
  let x_3334 : u32 = (x_3330 ^ (x_3330 >> 11u));
  let x_3339 : u32 = (x_3334 ^ ((x_3334 << 7u) & 2636928640u));
  let x_3344 : u32 = (x_3339 ^ ((x_3339 << 15u) & 4022730752u));
  let x_3348 : u32 = (x_3344 ^ (x_3344 >> 18u));
  x_58684 = x_3348;
  x_58683 = 0u;
  loop {
    if ((x_58683 >= 2u)) {
      break;
    }
    let x_3360 : u32 = (x_58684 + (x_58684 << 10u));
    let x_3364 : u32 = (x_3360 ^ (x_3360 >> 6u));
    let x_3368 : u32 = (x_3364 + (x_3364 << 3u));
    let x_3372 : u32 = (x_3368 ^ (x_3368 >> 11u));
    x_2741[x_58683] = (bitcast<f32>(((x_58684 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_58684 = (x_3372 + (x_3372 << 15u));
      x_58683 = (x_58683 + 1u);
    }
  }
  let x_3392 : vec3<u32> = bitcast<vec3<u32>>((x_3274 + vec3<i32>(1i, 0i, 0i)));
  let x_3394 : u32 = x_3392.z;
  let x_3398 : u32 = (x_3394 + (x_3394 << 10u));
  let x_3402 : u32 = (x_3398 ^ (x_3398 >> 6u));
  let x_3406 : u32 = (x_3402 + (x_3402 << 3u));
  let x_3410 : u32 = (x_3406 ^ (x_3406 >> 11u));
  let x_3420 : u32 = ((((x_3392.y * 1664525u) + (x_3410 + (x_3410 << 15u))) + 1013904223u) * 1664525u);
  let x_3424 : u32 = (x_3420 ^ (x_3420 >> 11u));
  let x_3429 : u32 = (x_3424 ^ ((x_3424 << 7u) & 2636928640u));
  let x_3434 : u32 = (x_3429 ^ ((x_3429 << 15u) & 4022730752u));
  let x_3444 : u32 = ((((x_3392.x * 1664525u) + (x_3434 ^ (x_3434 >> 18u))) + 1013904223u) * 1664525u);
  let x_3448 : u32 = (x_3444 ^ (x_3444 >> 11u));
  let x_3453 : u32 = (x_3448 ^ ((x_3448 << 7u) & 2636928640u));
  let x_3458 : u32 = (x_3453 ^ ((x_3453 << 15u) & 4022730752u));
  let x_3462 : u32 = (x_3458 ^ (x_3458 >> 18u));
  x_58687 = x_3462;
  x_58686 = 0u;
  loop {
    if ((x_58686 >= 2u)) {
      break;
    }
    let x_3474 : u32 = (x_58687 + (x_58687 << 10u));
    let x_3478 : u32 = (x_3474 ^ (x_3474 >> 6u));
    let x_3482 : u32 = (x_3478 + (x_3478 << 3u));
    let x_3486 : u32 = (x_3482 ^ (x_3482 >> 11u));
    x_2765[x_58686] = (bitcast<f32>(((x_58687 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_58687 = (x_3486 + (x_3486 << 15u));
      x_58686 = (x_58686 + 1u);
    }
  }
  let x_3506 : vec3<u32> = bitcast<vec3<u32>>((x_3274 + vec3<i32>(0i, 1i, 0i)));
  let x_3508 : u32 = x_3506.z;
  let x_3512 : u32 = (x_3508 + (x_3508 << 10u));
  let x_3516 : u32 = (x_3512 ^ (x_3512 >> 6u));
  let x_3520 : u32 = (x_3516 + (x_3516 << 3u));
  let x_3524 : u32 = (x_3520 ^ (x_3520 >> 11u));
  let x_3534 : u32 = ((((x_3506.y * 1664525u) + (x_3524 + (x_3524 << 15u))) + 1013904223u) * 1664525u);
  let x_3538 : u32 = (x_3534 ^ (x_3534 >> 11u));
  let x_3543 : u32 = (x_3538 ^ ((x_3538 << 7u) & 2636928640u));
  let x_3548 : u32 = (x_3543 ^ ((x_3543 << 15u) & 4022730752u));
  let x_3558 : u32 = ((((x_3506.x * 1664525u) + (x_3548 ^ (x_3548 >> 18u))) + 1013904223u) * 1664525u);
  let x_3562 : u32 = (x_3558 ^ (x_3558 >> 11u));
  let x_3567 : u32 = (x_3562 ^ ((x_3562 << 7u) & 2636928640u));
  let x_3572 : u32 = (x_3567 ^ ((x_3567 << 15u) & 4022730752u));
  let x_3576 : u32 = (x_3572 ^ (x_3572 >> 18u));
  x_58690 = x_3576;
  x_58689 = 0u;
  loop {
    if ((x_58689 >= 2u)) {
      break;
    }
    let x_3588 : u32 = (x_58690 + (x_58690 << 10u));
    let x_3592 : u32 = (x_3588 ^ (x_3588 >> 6u));
    let x_3596 : u32 = (x_3592 + (x_3592 << 3u));
    let x_3600 : u32 = (x_3596 ^ (x_3596 >> 11u));
    x_2789[x_58689] = (bitcast<f32>(((x_58690 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_58690 = (x_3600 + (x_3600 << 15u));
      x_58689 = (x_58689 + 1u);
    }
  }
  let x_3620 : vec3<u32> = bitcast<vec3<u32>>((x_3274 + vec3<i32>(1i, 1i, 0i)));
  let x_3622 : u32 = x_3620.z;
  let x_3626 : u32 = (x_3622 + (x_3622 << 10u));
  let x_3630 : u32 = (x_3626 ^ (x_3626 >> 6u));
  let x_3634 : u32 = (x_3630 + (x_3630 << 3u));
  let x_3638 : u32 = (x_3634 ^ (x_3634 >> 11u));
  let x_3648 : u32 = ((((x_3620.y * 1664525u) + (x_3638 + (x_3638 << 15u))) + 1013904223u) * 1664525u);
  let x_3652 : u32 = (x_3648 ^ (x_3648 >> 11u));
  let x_3657 : u32 = (x_3652 ^ ((x_3652 << 7u) & 2636928640u));
  let x_3662 : u32 = (x_3657 ^ ((x_3657 << 15u) & 4022730752u));
  let x_3672 : u32 = ((((x_3620.x * 1664525u) + (x_3662 ^ (x_3662 >> 18u))) + 1013904223u) * 1664525u);
  let x_3676 : u32 = (x_3672 ^ (x_3672 >> 11u));
  let x_3681 : u32 = (x_3676 ^ ((x_3676 << 7u) & 2636928640u));
  let x_3686 : u32 = (x_3681 ^ ((x_3681 << 15u) & 4022730752u));
  let x_3690 : u32 = (x_3686 ^ (x_3686 >> 18u));
  x_58693 = x_3690;
  x_58692 = 0u;
  loop {
    if ((x_58692 >= 2u)) {
      break;
    }
    let x_3702 : u32 = (x_58693 + (x_58693 << 10u));
    let x_3706 : u32 = (x_3702 ^ (x_3702 >> 6u));
    let x_3710 : u32 = (x_3706 + (x_3706 << 3u));
    let x_3714 : u32 = (x_3710 ^ (x_3710 >> 11u));
    x_2813[x_58692] = (bitcast<f32>(((x_58693 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_58693 = (x_3714 + (x_3714 << 15u));
      x_58692 = (x_58692 + 1u);
    }
  }
  let x_3734 : vec3<u32> = bitcast<vec3<u32>>((x_3274 + vec3<i32>(0i, 0i, 1i)));
  let x_3736 : u32 = x_3734.z;
  let x_3740 : u32 = (x_3736 + (x_3736 << 10u));
  let x_3744 : u32 = (x_3740 ^ (x_3740 >> 6u));
  let x_3748 : u32 = (x_3744 + (x_3744 << 3u));
  let x_3752 : u32 = (x_3748 ^ (x_3748 >> 11u));
  let x_3762 : u32 = ((((x_3734.y * 1664525u) + (x_3752 + (x_3752 << 15u))) + 1013904223u) * 1664525u);
  let x_3766 : u32 = (x_3762 ^ (x_3762 >> 11u));
  let x_3771 : u32 = (x_3766 ^ ((x_3766 << 7u) & 2636928640u));
  let x_3776 : u32 = (x_3771 ^ ((x_3771 << 15u) & 4022730752u));
  let x_3786 : u32 = ((((x_3734.x * 1664525u) + (x_3776 ^ (x_3776 >> 18u))) + 1013904223u) * 1664525u);
  let x_3790 : u32 = (x_3786 ^ (x_3786 >> 11u));
  let x_3795 : u32 = (x_3790 ^ ((x_3790 << 7u) & 2636928640u));
  let x_3800 : u32 = (x_3795 ^ ((x_3795 << 15u) & 4022730752u));
  let x_3804 : u32 = (x_3800 ^ (x_3800 >> 18u));
  x_58696 = x_3804;
  x_58695 = 0u;
  loop {
    if ((x_58695 >= 2u)) {
      break;
    }
    let x_3816 : u32 = (x_58696 + (x_58696 << 10u));
    let x_3820 : u32 = (x_3816 ^ (x_3816 >> 6u));
    let x_3824 : u32 = (x_3820 + (x_3820 << 3u));
    let x_3828 : u32 = (x_3824 ^ (x_3824 >> 11u));
    x_2837[x_58695] = (bitcast<f32>(((x_58696 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_58696 = (x_3828 + (x_3828 << 15u));
      x_58695 = (x_58695 + 1u);
    }
  }
  let x_3848 : vec3<u32> = bitcast<vec3<u32>>((x_3274 + vec3<i32>(1i, 0i, 1i)));
  let x_3850 : u32 = x_3848.z;
  let x_3854 : u32 = (x_3850 + (x_3850 << 10u));
  let x_3858 : u32 = (x_3854 ^ (x_3854 >> 6u));
  let x_3862 : u32 = (x_3858 + (x_3858 << 3u));
  let x_3866 : u32 = (x_3862 ^ (x_3862 >> 11u));
  let x_3876 : u32 = ((((x_3848.y * 1664525u) + (x_3866 + (x_3866 << 15u))) + 1013904223u) * 1664525u);
  let x_3880 : u32 = (x_3876 ^ (x_3876 >> 11u));
  let x_3885 : u32 = (x_3880 ^ ((x_3880 << 7u) & 2636928640u));
  let x_3890 : u32 = (x_3885 ^ ((x_3885 << 15u) & 4022730752u));
  let x_3900 : u32 = ((((x_3848.x * 1664525u) + (x_3890 ^ (x_3890 >> 18u))) + 1013904223u) * 1664525u);
  let x_3904 : u32 = (x_3900 ^ (x_3900 >> 11u));
  let x_3909 : u32 = (x_3904 ^ ((x_3904 << 7u) & 2636928640u));
  let x_3914 : u32 = (x_3909 ^ ((x_3909 << 15u) & 4022730752u));
  let x_3918 : u32 = (x_3914 ^ (x_3914 >> 18u));
  x_58699 = x_3918;
  x_58698 = 0u;
  loop {
    if ((x_58698 >= 2u)) {
      break;
    }
    let x_3930 : u32 = (x_58699 + (x_58699 << 10u));
    let x_3934 : u32 = (x_3930 ^ (x_3930 >> 6u));
    let x_3938 : u32 = (x_3934 + (x_3934 << 3u));
    let x_3942 : u32 = (x_3938 ^ (x_3938 >> 11u));
    x_2861[x_58698] = (bitcast<f32>(((x_58699 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_58699 = (x_3942 + (x_3942 << 15u));
      x_58698 = (x_58698 + 1u);
    }
  }
  let x_3962 : vec3<u32> = bitcast<vec3<u32>>((x_3274 + vec3<i32>(0i, 1i, 1i)));
  let x_3964 : u32 = x_3962.z;
  let x_3968 : u32 = (x_3964 + (x_3964 << 10u));
  let x_3972 : u32 = (x_3968 ^ (x_3968 >> 6u));
  let x_3976 : u32 = (x_3972 + (x_3972 << 3u));
  let x_3980 : u32 = (x_3976 ^ (x_3976 >> 11u));
  let x_3990 : u32 = ((((x_3962.y * 1664525u) + (x_3980 + (x_3980 << 15u))) + 1013904223u) * 1664525u);
  let x_3994 : u32 = (x_3990 ^ (x_3990 >> 11u));
  let x_3999 : u32 = (x_3994 ^ ((x_3994 << 7u) & 2636928640u));
  let x_4004 : u32 = (x_3999 ^ ((x_3999 << 15u) & 4022730752u));
  let x_4014 : u32 = ((((x_3962.x * 1664525u) + (x_4004 ^ (x_4004 >> 18u))) + 1013904223u) * 1664525u);
  let x_4018 : u32 = (x_4014 ^ (x_4014 >> 11u));
  let x_4023 : u32 = (x_4018 ^ ((x_4018 << 7u) & 2636928640u));
  let x_4028 : u32 = (x_4023 ^ ((x_4023 << 15u) & 4022730752u));
  let x_4032 : u32 = (x_4028 ^ (x_4028 >> 18u));
  x_58702 = x_4032;
  x_58701 = 0u;
  loop {
    if ((x_58701 >= 2u)) {
      break;
    }
    let x_4044 : u32 = (x_58702 + (x_58702 << 10u));
    let x_4048 : u32 = (x_4044 ^ (x_4044 >> 6u));
    let x_4052 : u32 = (x_4048 + (x_4048 << 3u));
    let x_4056 : u32 = (x_4052 ^ (x_4052 >> 11u));
    x_2885[x_58701] = (bitcast<f32>(((x_58702 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_58702 = (x_4056 + (x_4056 << 15u));
      x_58701 = (x_58701 + 1u);
    }
  }
  let x_4076 : vec3<u32> = bitcast<vec3<u32>>((x_3274 + vec3<i32>(1i, 1i, 1i)));
  let x_4078 : u32 = x_4076.z;
  let x_4082 : u32 = (x_4078 + (x_4078 << 10u));
  let x_4086 : u32 = (x_4082 ^ (x_4082 >> 6u));
  let x_4090 : u32 = (x_4086 + (x_4086 << 3u));
  let x_4094 : u32 = (x_4090 ^ (x_4090 >> 11u));
  let x_4104 : u32 = ((((x_4076.y * 1664525u) + (x_4094 + (x_4094 << 15u))) + 1013904223u) * 1664525u);
  let x_4108 : u32 = (x_4104 ^ (x_4104 >> 11u));
  let x_4113 : u32 = (x_4108 ^ ((x_4108 << 7u) & 2636928640u));
  let x_4118 : u32 = (x_4113 ^ ((x_4113 << 15u) & 4022730752u));
  let x_4128 : u32 = ((((x_4076.x * 1664525u) + (x_4118 ^ (x_4118 >> 18u))) + 1013904223u) * 1664525u);
  let x_4132 : u32 = (x_4128 ^ (x_4128 >> 11u));
  let x_4137 : u32 = (x_4132 ^ ((x_4132 << 7u) & 2636928640u));
  let x_4142 : u32 = (x_4137 ^ ((x_4137 << 15u) & 4022730752u));
  let x_4146 : u32 = (x_4142 ^ (x_4142 >> 18u));
  x_58705 = x_4146;
  x_58704 = 0u;
  loop {
    if ((x_58704 >= 2u)) {
      break;
    }
    let x_4158 : u32 = (x_58705 + (x_58705 << 10u));
    let x_4162 : u32 = (x_4158 ^ (x_4158 >> 6u));
    let x_4166 : u32 = (x_4162 + (x_4162 << 3u));
    let x_4170 : u32 = (x_4166 ^ (x_4166 >> 11u));
    x_2909[x_58704] = (bitcast<f32>(((x_58705 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_58705 = (x_4170 + (x_4170 << 15u));
      x_58704 = (x_58704 + 1u);
    }
  }
  let x_4194 : vec3<f32> = ((x_3276 * x_3276) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_3276)));
  let x_4196 : f32 = x_4194.x;
  let x_4198 : f32 = (1.0f - x_4196);
  let x_4200 : f32 = x_4194.y;
  let x_4202 : f32 = (1.0f - x_4200);
  let x_4204 : f32 = x_4194.z;
  let x_4206 : f32 = (1.0f - x_4204);
  let x_4207 : vec2<f32> = x_2741;
  let x_4214 : vec2<f32> = x_2765;
  let x_4222 : vec2<f32> = x_2789;
  let x_4230 : vec2<f32> = x_2813;
  let x_4238 : vec2<f32> = x_2837;
  let x_4246 : vec2<f32> = x_2861;
  let x_4254 : vec2<f32> = x_2885;
  let x_4262 : vec2<f32> = x_2909;
  let x_4272 : vec2<f32> = clamp(((((((((((((x_4207 * x_4198) * x_4202) * x_4206) + (((x_4214 * x_4196) * x_4202) * x_4206)) + (((x_4222 * x_4198) * x_4200) * x_4206)) + (((x_4230 * x_4196) * x_4200) * x_4206)) + (((x_4238 * x_4198) * x_4202) * x_4204)) + (((x_4246 * x_4196) * x_4202) * x_4204)) + (((x_4254 * x_4198) * x_4200) * x_4204)) + (((x_4262 * x_4196) * x_4200) * x_4204)) - x_2188) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_2188);
  let x_4280 : vec3<f32> = (x_58682 + (vec3<f32>(x_4272.x, 0.0f, x_4272.y) * 0.05999999865889549255f));
  let x_4281 : i32 = is_bevel;
  let x_4282 : bool = (x_4281 != 0i);
  let x_4283 : i32 = select(512i, 768i, x_4282);
  let x_37413 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_37420 : i32 = x_37413.x;
  let x_37429 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_37420), (x_4598 / x_37420)), 0i);
  let x_37597 : i32 = ((bitcast<i32>(x_37429[x_4611]) * 32i) + 15i);
  let x_38107 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_38112 : i32 = (x_37597 / 4i);
  let x_38114 : i32 = x_38107.x;
  let x_38123 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_38112 % x_38114), (x_38112 / x_38114)), 0i);
  let x_4291 : bool = ((x_38123[(x_37597 % 4i)] & 1u) != 0u);
  if (x_4291) {
    x_4295 = select(1536i, 1792i, x_4282);
    x_58775 = x_4295;
  } else {
    x_58775 = x_4283;
  }
  var x_40900 : u32;
  var x_40902 : u32;
  var x_40916 : f32;
  var x_40926 : f32;
  let x_38573 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_38580 : i32 = x_38573.x;
  let x_38589 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_38580), (x_4598 / x_38580)), 0i);
  let x_38740 : i32 = ((bitcast<i32>(x_38589[x_4611]) * 32i) + 12i);
  let x_39186 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_39191 : i32 = (x_38740 / 4i);
  let x_39193 : i32 = x_39186.x;
  let x_39202 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_39191 % x_39193), (x_39191 / x_39193)), 0i);
  let x_4305 : i32 = brick_id;
  let x_4307 : u32 = bitcast<u32>((bitcast<i32>(x_39202[(x_38740 % 4i)]) + x_4305));
  let x_39733 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_39740 : i32 = x_39733.x;
  let x_39749 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_39740), (x_4598 / x_39740)), 0i);
  let x_39912 : i32 = ((bitcast<i32>(x_39749[x_4611]) * 32i) + 14i);
  let x_40400 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_40405 : i32 = (x_39912 / 4i);
  let x_40407 : i32 = x_40400.x;
  let x_40416 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_40405 % x_40407), (x_40405 / x_40407)), 0i);
  let x_40419 : u32 = x_40416[(x_39912 % 4i)];
  x_40900 = (((x_40419 & 65535u) >> 10u) & 31u);
  x_40902 = (x_40419 & 1023u);
  if ((x_40900 == 0u)) {
    x_40908 = (f32(x_40902) * 0.00000005960464477539f);
    x_58746 = x_40908;
  } else {
    if ((x_40900 == 31u)) {
      x_40916 = bitcast<f32>((2139095040u | (x_40902 << 13u)));
      x_58745 = x_40916;
    } else {
      x_40926 = ((1.0f + (f32(x_40902) * 0.0009765625f)) * exp2((f32(x_40900) - 15.0f)));
      x_58745 = x_40926;
    }
    x_58746 = x_58745;
  }
  if (((x_40419 & 32768u) != 0u)) {
    x_40936 = -(x_58746);
    x_58749 = x_40936;
  } else {
    x_58749 = x_58746;
  }
  var x_40951 : u32;
  var x_40953 : u32;
  var x_40967 : f32;
  var x_40977 : f32;
  let x_40887 : u32 = (x_40419 >> 16u);
  x_40951 = ((x_40887 >> 10u) & 31u);
  x_40953 = (x_40887 & 1023u);
  if ((x_40951 == 0u)) {
    x_40959 = (f32(x_40953) * 0.00000005960464477539f);
    x_58754 = x_40959;
  } else {
    if ((x_40951 == 31u)) {
      x_40967 = bitcast<f32>((2139095040u | (x_40953 << 13u)));
      x_58753 = x_40967;
    } else {
      x_40977 = ((1.0f + (f32(x_40953) * 0.0009765625f)) * exp2((f32(x_40951) - 15.0f)));
      x_58753 = x_40977;
    }
    x_58754 = x_58753;
  }
  if (((x_40887 & 32768u) != 0u)) {
    x_40987 = -(x_58754);
    x_58757 = x_40987;
  } else {
    x_58757 = x_58754;
  }
  let x_41006 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_41013 : i32 = x_41006.x;
  let x_41022 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_41013), (x_4598 / x_41013)), 0i);
  let x_41179 : i32 = ((bitcast<i32>(x_41022[x_4611]) * 32i) + 13i);
  let x_41646 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_41651 : i32 = (x_41179 / 4i);
  let x_41653 : i32 = x_41646.x;
  let x_41662 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_41651 % x_41653), (x_41651 / x_41653)), 0i);
  let x_4323 : i32 = bitcast<i32>(x_41662[(x_41179 % 4i)]);
  let x_42166 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_22_0, 0i));
  let x_42171 : i32 = (x_4323 / 4i);
  let x_42173 : i32 = x_42166.x;
  let x_42182 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_22_0, vec2<i32>((x_42171 % x_42173), (x_42171 / x_42173)), 0i);
  let x_42184 : i32 = (x_4323 % 4i);
  let x_4325 : u32 = (x_42182[x_42184] & 65535u);
  let x_4327 : u32 = (x_4325 ^ 7993234u);
  let x_4331 : u32 = (x_4327 + (x_4327 << 10u));
  let x_4335 : u32 = (x_4331 ^ (x_4331 >> 6u));
  let x_4339 : u32 = (x_4335 + (x_4335 << 3u));
  let x_4343 : u32 = (x_4339 ^ (x_4339 >> 11u));
  let x_4345 : u32 = (x_4325 ^ 3450234u);
  let x_4349 : u32 = (x_4345 + (x_4345 << 10u));
  let x_4353 : u32 = (x_4349 ^ (x_4349 >> 6u));
  let x_4357 : u32 = (x_4353 + (x_4353 << 3u));
  let x_4361 : u32 = (x_4357 ^ (x_4357 >> 11u));
  let x_4366 : f32 = bbx_x;
  let x_4369 : f32 = x_4280.y;
  let x_4375 : f32 = (f32(x_4325) * 0.20000000298023223877f);
  let x_4395 : vec2<f32> = ((((vec2<f32>(mix(x_58749, x_58757, x_4366), x_4369) * 0.10000000149011611938f) * 0.69999998807907104492f) + vec2<f32>(x_4375, x_4375)) + vec2<f32>((bitcast<f32>((((x_4343 + (x_4343 << 15u)) & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_4361 + (x_4361 << 15u)) & 8388607u) | 1065353216u)) - 1.0f)));
  let x_4397 : u32 = (x_4307 ^ 292478890u);
  let x_4401 : u32 = (x_4397 + (x_4397 << 10u));
  let x_4405 : u32 = (x_4401 ^ (x_4401 >> 6u));
  let x_4409 : u32 = (x_4405 + (x_4405 << 3u));
  let x_4413 : u32 = (x_4409 ^ (x_4409 >> 11u));
  let x_4421 : f32 = (bitcast<f32>((((x_4413 + (x_4413 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
  if ((x_4421 > 0.89999997615814208984f)) {
    x_4426 = (x_4395 * 3.0f);
    x_58778 = x_4426;
  } else {
    let x_4430 : f32 = (0.61000001430511474609f * x_4421);
    x_4432 = (x_4395 + vec2<f32>(x_4430, x_4430));
    x_58778 = x_4432;
  }
  if (((x_58775 & 512i) != 0i)) {
    x_4441 = (x_58778 * 2.20000004768371582031f);
    x_58788 = x_4441;
  } else {
    x_58788 = x_58778;
  }
  if (x_4291) {
    x_4447 = Vertex_UV;
    x_58795 = x_4447;
  } else {
    x_58795 = x_58788;
  }
  let x_4452 : mat4x4<f32> = x_2436.renderer_MVPMat;
  gl_Position = (x_4452 * vec4<f32>(x_4280.x, x_4369, x_4280.z, 1.0f));
  v0 = x_4307;
  let x_4461 : vec3<f32> = Vertex_Normal;
  let x_42200 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_42207 : i32 = x_42200.x;
  let x_42216 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_42207), (x_4598 / x_42207)), 0i);
  let x_42255 : i32 = (bitcast<i32>(x_42216[x_4611]) * 32i);
  let x_42489 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_42494 : i32 = (x_42255 / 4i);
  let x_42496 : i32 = x_42489.x;
  let x_42505 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_42494 % x_42496), (x_42494 / x_42496)), 0i);
  let x_43360 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_43367 : i32 = x_43360.x;
  let x_43376 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_43367), (x_4598 / x_43367)), 0i);
  let x_43428 : i32 = ((bitcast<i32>(x_43376[x_4611]) * 32i) + 1i);
  let x_43676 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_43681 : i32 = (x_43428 / 4i);
  let x_43683 : i32 = x_43676.x;
  let x_43692 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_43681 % x_43683), (x_43681 / x_43683)), 0i);
  let x_44520 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_44527 : i32 = x_44520.x;
  let x_44536 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_44527), (x_4598 / x_44527)), 0i);
  let x_44597 : i32 = ((bitcast<i32>(x_44536[x_4611]) * 32i) + 2i);
  let x_44863 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_44868 : i32 = (x_44597 / 4i);
  let x_44870 : i32 = x_44863.x;
  let x_44879 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_44868 % x_44870), (x_44868 / x_44870)), 0i);
  let x_45680 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_45687 : i32 = x_45680.x;
  let x_45696 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_45687), (x_4598 / x_45687)), 0i);
  let x_45766 : i32 = ((bitcast<i32>(x_45696[x_4611]) * 32i) + 3i);
  let x_46050 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_46055 : i32 = (x_45766 / 4i);
  let x_46057 : i32 = x_46050.x;
  let x_46066 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_46055 % x_46057), (x_46055 / x_46057)), 0i);
  let x_46840 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_46847 : i32 = x_46840.x;
  let x_46856 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_46847), (x_4598 / x_46847)), 0i);
  let x_46935 : i32 = ((bitcast<i32>(x_46856[x_4611]) * 32i) + 4i);
  let x_47237 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_47242 : i32 = (x_46935 / 4i);
  let x_47244 : i32 = x_47237.x;
  let x_47253 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_47242 % x_47244), (x_47242 / x_47244)), 0i);
  let x_48000 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_48007 : i32 = x_48000.x;
  let x_48016 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_48007), (x_4598 / x_48007)), 0i);
  let x_48104 : i32 = ((bitcast<i32>(x_48016[x_4611]) * 32i) + 5i);
  let x_48424 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_48429 : i32 = (x_48104 / 4i);
  let x_48431 : i32 = x_48424.x;
  let x_48440 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_48429 % x_48431), (x_48429 / x_48431)), 0i);
  let x_49160 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_49167 : i32 = x_49160.x;
  let x_49176 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_49167), (x_4598 / x_49167)), 0i);
  let x_49273 : i32 = ((bitcast<i32>(x_49176[x_4611]) * 32i) + 6i);
  let x_49611 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_49616 : i32 = (x_49273 / 4i);
  let x_49618 : i32 = x_49611.x;
  let x_49627 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_49616 % x_49618), (x_49616 / x_49618)), 0i);
  let x_50320 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_50327 : i32 = x_50320.x;
  let x_50336 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_50327), (x_4598 / x_50327)), 0i);
  let x_50442 : i32 = ((bitcast<i32>(x_50336[x_4611]) * 32i) + 7i);
  let x_50798 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_50803 : i32 = (x_50442 / 4i);
  let x_50805 : i32 = x_50798.x;
  let x_50814 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_50803 % x_50805), (x_50803 / x_50805)), 0i);
  let x_51480 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_51487 : i32 = x_51480.x;
  let x_51496 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_51487), (x_4598 / x_51487)), 0i);
  let x_51611 : i32 = ((bitcast<i32>(x_51496[x_4611]) * 32i) + 8i);
  let x_51985 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_51990 : i32 = (x_51611 / 4i);
  let x_51992 : i32 = x_51985.x;
  let x_52001 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_51990 % x_51992), (x_51990 / x_51992)), 0i);
  let x_52640 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_52647 : i32 = x_52640.x;
  let x_52656 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_52647), (x_4598 / x_52647)), 0i);
  let x_52780 : i32 = ((bitcast<i32>(x_52656[x_4611]) * 32i) + 9i);
  let x_53172 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_53177 : i32 = (x_52780 / 4i);
  let x_53179 : i32 = x_53172.x;
  let x_53188 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_53177 % x_53179), (x_53177 / x_53179)), 0i);
  let x_53800 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_53807 : i32 = x_53800.x;
  let x_53816 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_53807), (x_4598 / x_53807)), 0i);
  let x_53949 : i32 = ((bitcast<i32>(x_53816[x_4611]) * 32i) + 10i);
  let x_54359 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_54364 : i32 = (x_53949 / 4i);
  let x_54366 : i32 = x_54359.x;
  let x_54375 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_54364 % x_54366), (x_54364 / x_54366)), 0i);
  let x_54960 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_54967 : i32 = x_54960.x;
  let x_54976 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_54967), (x_4598 / x_54967)), 0i);
  let x_55118 : i32 = ((bitcast<i32>(x_54976[x_4611]) * 32i) + 11i);
  let x_55546 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_55551 : i32 = (x_55118 / 4i);
  let x_55553 : i32 = x_55546.x;
  let x_55562 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_55551 % x_55553), (x_55551 / x_55553)), 0i);
  v1 = (vec4<f32>(x_4461.x, x_4461.y, x_4461.z, 0.0f) * transpose(mat4x3<f32>(vec3<f32>(bitcast<f32>(x_42505[(x_42255 % 4i)]), bitcast<f32>(x_43692[(x_43428 % 4i)]), bitcast<f32>(x_44879[(x_44597 % 4i)])), vec3<f32>(bitcast<f32>(x_46066[(x_45766 % 4i)]), bitcast<f32>(x_47253[(x_46935 % 4i)]), bitcast<f32>(x_48440[(x_48104 % 4i)])), vec3<f32>(bitcast<f32>(x_49627[(x_49273 % 4i)]), bitcast<f32>(x_50814[(x_50442 % 4i)]), bitcast<f32>(x_52001[(x_51611 % 4i)])), vec3<f32>(bitcast<f32>(x_53188[(x_52780 % 4i)]), bitcast<f32>(x_54375[(x_53949 % 4i)]), bitcast<f32>(x_55562[(x_55118 % 4i)])))));
  v2 = x_4280;
  v7 = 0.0f;
  let x_56120 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_56127 : i32 = x_56120.x;
  let x_56136 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_56127), (x_4598 / x_56127)), 0i);
  let x_56381 : i32 = ((bitcast<i32>(x_56136[x_4611]) * 32i) + 28i);
  let x_57165 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_57170 : i32 = (x_56381 / 4i);
  let x_57172 : i32 = x_57165.x;
  let x_57181 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_57170 % x_57172), (x_57170 / x_57172)), 0i);
  v8 = bitcast<f32>(x_57181[(x_56381 % 4i)]);
  v9 = x_58795;
  let x_57280 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_57287 : i32 = x_57280.x;
  let x_57296 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_42171 % x_57287), (x_42171 / x_57287)), 0i);
  v10 = bitcast<i32>(x_57296[x_42184]);
  v11 = vec2<f32>(x_58815.x, x_58815.z);
  v12 = x_58775;
  let x_57314 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_7_0, 0i));
  let x_57321 : i32 = x_57314.x;
  let x_57330 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_7_0, vec2<i32>((x_4598 % x_57321), (x_4598 / x_57321)), 0i);
  v13 = x_57330[x_4611];
  let x_2627 : f32 = gl_Position.z;
  let x_2629 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_2627 + x_2629));
  return;
}

struct main_out {
  @builtin(position)
  gl_Position : vec4<f32>,
  @location(0) @interpolate(flat)
  v0_1 : u32,
  @location(1)
  v1_1 : vec3<f32>,
  @location(2)
  v2_1 : vec3<f32>,
  @location(3)
  v7_1 : f32,
  @location(4) @interpolate(flat)
  v8_1 : f32,
  @location(5)
  v9_1 : vec2<f32>,
  @location(6) @interpolate(flat)
  v10_1 : i32,
  @location(7) @interpolate(flat)
  v11_1 : vec2<f32>,
  @location(8) @interpolate(flat)
  v12_1 : i32,
  @location(9) @interpolate(flat)
  v13_1 : u32,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @location(0) Vertex_Position_param : vec3<f32>, @location(6) bbx_x_param : f32, @location(4) @interpolate(flat) is_bevel_param : i32, @location(5) @interpolate(flat) brick_id_param : i32, @location(3) Vertex_UV_param : vec2<f32>, @location(2) Vertex_Normal_param : vec3<f32>) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  Vertex_Position = Vertex_Position_param;
  bbx_x = bbx_x_param;
  is_bevel = is_bevel_param;
  brick_id = brick_id_param;
  Vertex_UV = Vertex_UV_param;
  Vertex_Normal = Vertex_Normal_param;
  main_1();
  return main_out(gl_Position, v0, v1, v2, v7, v8, v9, v10, v11, v12, v13);
}
