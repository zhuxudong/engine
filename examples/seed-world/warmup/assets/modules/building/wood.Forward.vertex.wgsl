diagnostic(off, derivative_uniformity);
struct gs_Auto_0 {
  /* @offset(0) */
  renderer_MVPMat : mat4x4<f32>,
}

@binding(0) @group(3) var gs_wgpu_tex_storage_6_0 : texture_2d<u32>;

@binding(1) @group(3) var gs_wgpu_samp_storage_6_0 : sampler;

@binding(2) @group(3) var gs_wgpu_tex_storage_0_0 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_0 : sampler;

var<private> gl_InstanceIndex : i32;

var<private> Vertex_Position : vec3<f32>;

@binding(0) @group(2) var<uniform> x_2365 : gs_Auto_0;

var<private> v0 : vec3<f32>;

var<private> v1 : vec3<f32>;

var<private> Vertex_Normal : vec3<f32>;

var<private> v2 : u32;

var<private> v3 : u32;

var<private> v5 : i32;

var<private> is_bevel : i32;

var<private> v6 : i32;

var<private> v7 : vec2<f32>;

var<private> Vertex_UV : vec2<f32>;

var<private> v8 : i32;

var<private> v9 : i32;

var<private> v10 : i32;

var<private> v11 : i32;

var<private> v12 : i32;

var<private> v13 : i32;

var<private> gl_Position : vec4<f32>;

const x_780 = vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f);

const x_2236 = vec2<f32>(0.5f, 0.5f);

fn main_1() {
  var x_2688 : vec2<f32>;
  var x_2712 : vec2<f32>;
  var x_2736 : vec2<f32>;
  var x_2760 : vec2<f32>;
  var x_2784 : vec2<f32>;
  var x_2808 : vec2<f32>;
  var x_2832 : vec2<f32>;
  var x_2856 : vec2<f32>;
  var x_3025 : bool;
  var x_24880 : bool;
  var x_25082 : vec3<f32>;
  var x_25198 : vec3<f32>;
  var x_3319 : bool;
  var x_24918 : bool;
  var x_25118 : vec3<f32>;
  var x_3419 : mat4x4<f32>;
  var x_24921 : vec3<f32>;
  var x_24920 : mat4x4<f32>;
  var x_24923 : u32;
  var x_24922 : u32;
  var x_24926 : u32;
  var x_24925 : u32;
  var x_24929 : u32;
  var x_24928 : u32;
  var x_24932 : u32;
  var x_24931 : u32;
  var x_24935 : u32;
  var x_24934 : u32;
  var x_24938 : u32;
  var x_24937 : u32;
  var x_24941 : u32;
  var x_24940 : u32;
  var x_24944 : u32;
  var x_24943 : u32;
  let x_2902 : i32 = gl_InstanceIndex;
  let x_4682 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_4687 : i32 = (x_2902 / 4i);
  let x_4689 : i32 = x_4682.x;
  let x_4698 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_4689), (x_4687 / x_4689)), 0i);
  let x_4700 : i32 = (x_2902 % 4i);
  let x_4726 : i32 = (bitcast<i32>(x_4698[x_4700]) * 20i);
  let x_4887 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_4892 : i32 = (x_4726 / 4i);
  let x_4894 : i32 = x_4887.x;
  let x_4903 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_4892 % x_4894), (x_4892 / x_4894)), 0i);
  let x_5434 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_5441 : i32 = x_5434.x;
  let x_5450 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_5441), (x_4687 / x_5441)), 0i);
  let x_5490 : i32 = ((bitcast<i32>(x_5450[x_4700]) * 20i) + 1i);
  let x_5665 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_5670 : i32 = (x_5490 / 4i);
  let x_5672 : i32 = x_5665.x;
  let x_5681 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_5670 % x_5672), (x_5670 / x_5672)), 0i);
  let x_6185 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_6192 : i32 = x_6185.x;
  let x_6201 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_6192), (x_4687 / x_6192)), 0i);
  let x_6250 : i32 = ((bitcast<i32>(x_6201[x_4700]) * 20i) + 2i);
  let x_6443 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_6448 : i32 = (x_6250 / 4i);
  let x_6450 : i32 = x_6443.x;
  let x_6459 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_6448 % x_6450), (x_6448 / x_6450)), 0i);
  let x_6936 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_6943 : i32 = x_6936.x;
  let x_6952 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_6943), (x_4687 / x_6943)), 0i);
  let x_7010 : i32 = ((bitcast<i32>(x_6952[x_4700]) * 20i) + 3i);
  let x_7221 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_7226 : i32 = (x_7010 / 4i);
  let x_7228 : i32 = x_7221.x;
  let x_7237 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_7226 % x_7228), (x_7226 / x_7228)), 0i);
  let x_7687 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_7694 : i32 = x_7687.x;
  let x_7703 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_7694), (x_4687 / x_7694)), 0i);
  let x_7770 : i32 = ((bitcast<i32>(x_7703[x_4700]) * 20i) + 4i);
  let x_7999 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_8004 : i32 = (x_7770 / 4i);
  let x_8006 : i32 = x_7999.x;
  let x_8015 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_8004 % x_8006), (x_8004 / x_8006)), 0i);
  let x_8438 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_8445 : i32 = x_8438.x;
  let x_8454 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_8445), (x_4687 / x_8445)), 0i);
  let x_8530 : i32 = ((bitcast<i32>(x_8454[x_4700]) * 20i) + 5i);
  let x_8777 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_8782 : i32 = (x_8530 / 4i);
  let x_8784 : i32 = x_8777.x;
  let x_8793 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_8782 % x_8784), (x_8782 / x_8784)), 0i);
  let x_9189 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_9196 : i32 = x_9189.x;
  let x_9205 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_9196), (x_4687 / x_9196)), 0i);
  let x_9290 : i32 = ((bitcast<i32>(x_9205[x_4700]) * 20i) + 6i);
  let x_9555 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_9560 : i32 = (x_9290 / 4i);
  let x_9562 : i32 = x_9555.x;
  let x_9571 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_9560 % x_9562), (x_9560 / x_9562)), 0i);
  let x_9940 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_9947 : i32 = x_9940.x;
  let x_9956 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_9947), (x_4687 / x_9947)), 0i);
  let x_10050 : i32 = ((bitcast<i32>(x_9956[x_4700]) * 20i) + 7i);
  let x_10333 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_10338 : i32 = (x_10050 / 4i);
  let x_10340 : i32 = x_10333.x;
  let x_10349 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_10338 % x_10340), (x_10338 / x_10340)), 0i);
  let x_10691 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_10698 : i32 = x_10691.x;
  let x_10707 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_10698), (x_4687 / x_10698)), 0i);
  let x_10810 : i32 = ((bitcast<i32>(x_10707[x_4700]) * 20i) + 8i);
  let x_11111 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_11116 : i32 = (x_10810 / 4i);
  let x_11118 : i32 = x_11111.x;
  let x_11127 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_11116 % x_11118), (x_11116 / x_11118)), 0i);
  let x_11442 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_11449 : i32 = x_11442.x;
  let x_11458 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_11449), (x_4687 / x_11449)), 0i);
  let x_11570 : i32 = ((bitcast<i32>(x_11458[x_4700]) * 20i) + 9i);
  let x_11889 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_11894 : i32 = (x_11570 / 4i);
  let x_11896 : i32 = x_11889.x;
  let x_11905 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_11894 % x_11896), (x_11894 / x_11896)), 0i);
  let x_12193 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_12200 : i32 = x_12193.x;
  let x_12209 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_12200), (x_4687 / x_12200)), 0i);
  let x_12330 : i32 = ((bitcast<i32>(x_12209[x_4700]) * 20i) + 10i);
  let x_12667 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_12672 : i32 = (x_12330 / 4i);
  let x_12674 : i32 = x_12667.x;
  let x_12683 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_12672 % x_12674), (x_12672 / x_12674)), 0i);
  let x_12944 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_12951 : i32 = x_12944.x;
  let x_12960 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_12951), (x_4687 / x_12951)), 0i);
  let x_13090 : i32 = ((bitcast<i32>(x_12960[x_4700]) * 20i) + 11i);
  let x_13445 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_13450 : i32 = (x_13090 / 4i);
  let x_13452 : i32 = x_13445.x;
  let x_13461 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_13450 % x_13452), (x_13450 / x_13452)), 0i);
  let x_2997 : mat3x4<f32> = transpose(mat4x3<f32>(vec3<f32>(bitcast<f32>(x_4903[(x_4726 % 4i)]), bitcast<f32>(x_5681[(x_5490 % 4i)]), bitcast<f32>(x_6459[(x_6250 % 4i)])), vec3<f32>(bitcast<f32>(x_7237[(x_7010 % 4i)]), bitcast<f32>(x_8015[(x_7770 % 4i)]), bitcast<f32>(x_8793[(x_8530 % 4i)])), vec3<f32>(bitcast<f32>(x_9571[(x_9290 % 4i)]), bitcast<f32>(x_10349[(x_10050 % 4i)]), bitcast<f32>(x_11127[(x_10810 % 4i)])), vec3<f32>(bitcast<f32>(x_11905[(x_11570 % 4i)]), bitcast<f32>(x_12683[(x_12330 % 4i)]), bitcast<f32>(x_13461[(x_13090 % 4i)]))));
  let x_2998 : vec3<f32> = Vertex_Position;
  let x_3006 : f32 = length(vec3<f32>(x_2997[0u].y, x_2997[1u].y, x_2997[2u].y));
  let x_13695 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_13702 : i32 = x_13695.x;
  let x_13711 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_13702), (x_4687 / x_13702)), 0i);
  let x_13867 : i32 = ((bitcast<i32>(x_13711[x_4700]) * 20i) + 15i);
  let x_14304 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_14309 : i32 = (x_13867 / 4i);
  let x_14311 : i32 = x_14304.x;
  let x_14320 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_14309 % x_14311), (x_14309 / x_14311)), 0i);
  let x_3014 : bool = ((x_14320[(x_13867 % 4i)] & 64u) != 0u);
  if (x_3014) {
    x_24880 = true;
  } else {
    let x_14446 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
    let x_14453 : i32 = x_14446.x;
    let x_14462 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_14453), (x_4687 / x_14453)), 0i);
    let x_14618 : i32 = ((bitcast<i32>(x_14462[x_4700]) * 20i) + 15i);
    let x_15055 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_15060 : i32 = (x_14618 / 4i);
    let x_15062 : i32 = x_15055.x;
    let x_15071 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_15060 % x_15062), (x_15060 / x_15062)), 0i);
    x_3025 = ((x_15071[(x_14618 % 4i)] & 128u) != 0u);
    x_24880 = x_3025;
  }
  var x_3055 : f32;
  var x_3086 : f32;
  var x_3106 : f32;
  var x_3123 : f32;
  var x_24906 : f32;
  if (x_24880) {
    let x_15197 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
    let x_15204 : i32 = x_15197.x;
    let x_15213 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_15204), (x_4687 / x_15204)), 0i);
    let x_15369 : i32 = ((bitcast<i32>(x_15213[x_4700]) * 20i) + 15i);
    let x_15806 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
    let x_15811 : i32 = (x_15369 / 4i);
    let x_15813 : i32 = x_15806.x;
    let x_15822 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_15811 % x_15813), (x_15811 / x_15813)), 0i);
    let x_3036 : bool = ((x_15822[(x_15369 % 4i)] & 128u) != 0u);
    loop {
      var x_24887 : bool;
      var x_24888 : bool;
      var x_3076 : bool;
      var x_24895 : bool;
      var x_3094 : bool;
      var x_24898 : bool;
      var x_3047 : bool;
      if ((x_3006 <= 0.00009999999747378752f)) {
        x_24888 = true;
      } else {
        if (!(x_3014)) {
          x_3047 = !(x_3036);
          x_24887 = x_3047;
        } else {
          x_24887 = false;
        }
        x_24888 = x_24887;
      }
      if (x_24888) {
        x_3055 = x_2998.y;
        x_24906 = x_3055;
        break;
      }
      let x_3060 : f32 = min(0.15999999642372131348f, min((0.07999999821186065674f / x_3006), 0.44999998807907104492f));
      let x_3062 : f32 = select(0.0f, 0.15999999642372131348f, x_3014);
      let x_3065 : f32 = select(0.0f, x_3060, x_3014);
      let x_3067 : f32 = select(0.0f, 0.15999999642372131348f, x_3036);
      let x_3070 : f32 = select(0.0f, x_3060, x_3036);
      if (x_3014) {
        x_3076 = (x_2998.y < x_3062);
        x_24895 = x_3076;
      } else {
        x_24895 = false;
      }
      if (x_24895) {
        x_3086 = ((x_2998.y * x_3065) / x_3062);
        x_24906 = x_3086;
        break;
      }
      if (x_3036) {
        x_3094 = (x_2998.y > select(1.0f, 0.84000003337860107422f, x_3036));
        x_24898 = x_3094;
      } else {
        x_24898 = false;
      }
      if (x_24898) {
        x_3106 = (1.0f - (((1.0f - x_2998.y) * x_3070) / x_3067));
        x_24906 = x_3106;
        break;
      }
      x_3123 = (x_3065 + (((x_2998.y - x_3062) / (select(1.0f, 0.84000003337860107422f, x_3014) - x_3067)) * ((1.0f - x_3065) - x_3070)));
      x_24906 = x_3123;
      break;
    }
    x_25082 = x_2998;
    x_25082.y = x_24906;
    x_25198 = x_25082;
  } else {
    x_25198 = x_2998;
  }
  let x_15948 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_15955 : i32 = x_15948.x;
  let x_15964 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_15955), (x_4687 / x_15955)), 0i);
  let x_16103 : i32 = ((bitcast<i32>(x_15964[x_4700]) * 20i) + 12i);
  let x_16476 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_16481 : i32 = (x_16103 / 4i);
  let x_16483 : i32 = x_16476.x;
  let x_16492 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_16481 % x_16483), (x_16481 / x_16483)), 0i);
  let x_16699 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_16706 : i32 = x_16699.x;
  let x_16715 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_16706), (x_4687 / x_16706)), 0i);
  let x_16860 : i32 = ((bitcast<i32>(x_16715[x_4700]) * 20i) + 13i);
  let x_17254 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_17259 : i32 = (x_16860 / 4i);
  let x_17261 : i32 = x_17254.x;
  let x_17270 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_17259 % x_17261), (x_17259 / x_17261)), 0i);
  let x_3145 : i32 = (bitcast<i32>(x_16492[(x_16103 % 4i)]) + bitcast<i32>(x_17270[(x_16860 % 4i)]));
  let x_3147 : i32 = (x_3145 + 45i);
  let x_3149 : u32 = bitcast<u32>(x_3147);
  let x_3153 : u32 = (x_3149 + (x_3149 << 10u));
  let x_3157 : u32 = (x_3153 ^ (x_3153 >> 6u));
  let x_3161 : u32 = (x_3157 + (x_3157 << 3u));
  let x_3165 : u32 = (x_3161 ^ (x_3161 >> 11u));
  let x_3177 : f32 = (1.57000005245208740234f * f32(i32(((bitcast<f32>((((x_3165 + (x_3165 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) * 4.0f))));
  let x_3179 : f32 = sin(x_3177);
  let x_3181 : f32 = cos(x_3177);
  let x_3280 : mat4x4<f32> = transpose(mat4x4<f32>(vec4<f32>(x_3181, 0.0f, x_3179, 0.0f), vec4<f32>(0.0f, 1.0f, 0.0f, 0.0f), vec4<f32>(-(x_3179), 0.0f, x_3181, 0.0f), x_780));
  let x_17450 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_17457 : i32 = x_17450.x;
  let x_17466 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_17457), (x_4687 / x_17457)), 0i);
  let x_17622 : i32 = ((bitcast<i32>(x_17466[x_4700]) * 20i) + 15i);
  let x_18059 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_18064 : i32 = (x_17622 / 4i);
  let x_18066 : i32 = x_18059.x;
  let x_18075 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_18064 % x_18066), (x_18064 / x_18066)), 0i);
  if ((x_3014 == ((x_18075[(x_17622 % 4i)] & 128u) != 0u))) {
    let x_3294 : u32 = bitcast<u32>((x_3145 + 500i));
    let x_3298 : u32 = (x_3294 + (x_3294 << 10u));
    let x_3302 : u32 = (x_3298 ^ (x_3298 >> 6u));
    let x_3306 : u32 = (x_3302 + (x_3302 << 3u));
    let x_3310 : u32 = (x_3306 ^ (x_3306 >> 11u));
    x_3319 = ((bitcast<f32>((((x_3310 + (x_3310 << 15u)) & 8388607u) | 1065353216u)) - 1.0f) > 0.5f);
    x_24918 = x_3319;
  } else {
    x_24918 = false;
  }
  if (x_24918) {
    x_25118 = x_25198;
    x_25118.y = (x_25198.y - 1.0f);
    x_3419 = (mat4x4<f32>(vec4<f32>(-0.9999987483024597168f, 0.00159254798199981451f, 0.0f, 0.0f), vec4<f32>(-0.00159254798199981451f, -0.9999987483024597168f, 0.0f, 0.0f), vec4<f32>(0.0f, 0.0f, 1.0f, 0.0f), x_780) * x_3280);
    x_24921 = x_25118;
    x_24920 = x_3419;
  } else {
    x_24921 = x_25198;
    x_24920 = x_3280;
  }
  let x_3426 : mat3x4<f32> = (x_24920 * x_2997);
  let x_3433 : vec3<f32> = (vec4<f32>(x_24921.x, x_24921.y, x_24921.z, 1.0f) * x_3426);
  let x_3437 : vec4<f32> = vec4<f32>(x_3433.x, x_3433.y, x_3433.z, 1.0f);
  let x_3439 : vec3<f32> = vec3<f32>(x_3437.x, x_3437.y, x_3437.z);
  let x_3441 : vec3<f32> = (x_3439 * 0.40000000596046447754f);
  let x_3444 : vec3<i32> = vec3<i32>(floor(x_3441));
  let x_3446 : vec3<f32> = fract(x_3441);
  let x_3448 : vec3<u32> = bitcast<vec3<u32>>(x_3444);
  let x_3450 : u32 = x_3448.z;
  let x_3454 : u32 = (x_3450 + (x_3450 << 10u));
  let x_3458 : u32 = (x_3454 ^ (x_3454 >> 6u));
  let x_3462 : u32 = (x_3458 + (x_3458 << 3u));
  let x_3466 : u32 = (x_3462 ^ (x_3462 >> 11u));
  let x_3476 : u32 = ((((x_3448.y * 1664525u) + (x_3466 + (x_3466 << 15u))) + 1013904223u) * 1664525u);
  let x_3480 : u32 = (x_3476 ^ (x_3476 >> 11u));
  let x_3485 : u32 = (x_3480 ^ ((x_3480 << 7u) & 2636928640u));
  let x_3490 : u32 = (x_3485 ^ ((x_3485 << 15u) & 4022730752u));
  let x_3500 : u32 = ((((x_3448.x * 1664525u) + (x_3490 ^ (x_3490 >> 18u))) + 1013904223u) * 1664525u);
  let x_3504 : u32 = (x_3500 ^ (x_3500 >> 11u));
  let x_3509 : u32 = (x_3504 ^ ((x_3504 << 7u) & 2636928640u));
  let x_3514 : u32 = (x_3509 ^ ((x_3509 << 15u) & 4022730752u));
  let x_3518 : u32 = (x_3514 ^ (x_3514 >> 18u));
  x_24923 = x_3518;
  x_24922 = 0u;
  loop {
    if ((x_24922 >= 2u)) {
      break;
    }
    let x_3530 : u32 = (x_24923 + (x_24923 << 10u));
    let x_3534 : u32 = (x_3530 ^ (x_3530 >> 6u));
    let x_3538 : u32 = (x_3534 + (x_3534 << 3u));
    let x_3542 : u32 = (x_3538 ^ (x_3538 >> 11u));
    x_2688[x_24922] = (bitcast<f32>(((x_24923 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24923 = (x_3542 + (x_3542 << 15u));
      x_24922 = (x_24922 + 1u);
    }
  }
  let x_3562 : vec3<u32> = bitcast<vec3<u32>>((x_3444 + vec3<i32>(1i, 0i, 0i)));
  let x_3564 : u32 = x_3562.z;
  let x_3568 : u32 = (x_3564 + (x_3564 << 10u));
  let x_3572 : u32 = (x_3568 ^ (x_3568 >> 6u));
  let x_3576 : u32 = (x_3572 + (x_3572 << 3u));
  let x_3580 : u32 = (x_3576 ^ (x_3576 >> 11u));
  let x_3590 : u32 = ((((x_3562.y * 1664525u) + (x_3580 + (x_3580 << 15u))) + 1013904223u) * 1664525u);
  let x_3594 : u32 = (x_3590 ^ (x_3590 >> 11u));
  let x_3599 : u32 = (x_3594 ^ ((x_3594 << 7u) & 2636928640u));
  let x_3604 : u32 = (x_3599 ^ ((x_3599 << 15u) & 4022730752u));
  let x_3614 : u32 = ((((x_3562.x * 1664525u) + (x_3604 ^ (x_3604 >> 18u))) + 1013904223u) * 1664525u);
  let x_3618 : u32 = (x_3614 ^ (x_3614 >> 11u));
  let x_3623 : u32 = (x_3618 ^ ((x_3618 << 7u) & 2636928640u));
  let x_3628 : u32 = (x_3623 ^ ((x_3623 << 15u) & 4022730752u));
  let x_3632 : u32 = (x_3628 ^ (x_3628 >> 18u));
  x_24926 = x_3632;
  x_24925 = 0u;
  loop {
    if ((x_24925 >= 2u)) {
      break;
    }
    let x_3644 : u32 = (x_24926 + (x_24926 << 10u));
    let x_3648 : u32 = (x_3644 ^ (x_3644 >> 6u));
    let x_3652 : u32 = (x_3648 + (x_3648 << 3u));
    let x_3656 : u32 = (x_3652 ^ (x_3652 >> 11u));
    x_2712[x_24925] = (bitcast<f32>(((x_24926 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24926 = (x_3656 + (x_3656 << 15u));
      x_24925 = (x_24925 + 1u);
    }
  }
  let x_3676 : vec3<u32> = bitcast<vec3<u32>>((x_3444 + vec3<i32>(0i, 1i, 0i)));
  let x_3678 : u32 = x_3676.z;
  let x_3682 : u32 = (x_3678 + (x_3678 << 10u));
  let x_3686 : u32 = (x_3682 ^ (x_3682 >> 6u));
  let x_3690 : u32 = (x_3686 + (x_3686 << 3u));
  let x_3694 : u32 = (x_3690 ^ (x_3690 >> 11u));
  let x_3704 : u32 = ((((x_3676.y * 1664525u) + (x_3694 + (x_3694 << 15u))) + 1013904223u) * 1664525u);
  let x_3708 : u32 = (x_3704 ^ (x_3704 >> 11u));
  let x_3713 : u32 = (x_3708 ^ ((x_3708 << 7u) & 2636928640u));
  let x_3718 : u32 = (x_3713 ^ ((x_3713 << 15u) & 4022730752u));
  let x_3728 : u32 = ((((x_3676.x * 1664525u) + (x_3718 ^ (x_3718 >> 18u))) + 1013904223u) * 1664525u);
  let x_3732 : u32 = (x_3728 ^ (x_3728 >> 11u));
  let x_3737 : u32 = (x_3732 ^ ((x_3732 << 7u) & 2636928640u));
  let x_3742 : u32 = (x_3737 ^ ((x_3737 << 15u) & 4022730752u));
  let x_3746 : u32 = (x_3742 ^ (x_3742 >> 18u));
  x_24929 = x_3746;
  x_24928 = 0u;
  loop {
    if ((x_24928 >= 2u)) {
      break;
    }
    let x_3758 : u32 = (x_24929 + (x_24929 << 10u));
    let x_3762 : u32 = (x_3758 ^ (x_3758 >> 6u));
    let x_3766 : u32 = (x_3762 + (x_3762 << 3u));
    let x_3770 : u32 = (x_3766 ^ (x_3766 >> 11u));
    x_2736[x_24928] = (bitcast<f32>(((x_24929 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24929 = (x_3770 + (x_3770 << 15u));
      x_24928 = (x_24928 + 1u);
    }
  }
  let x_3790 : vec3<u32> = bitcast<vec3<u32>>((x_3444 + vec3<i32>(1i, 1i, 0i)));
  let x_3792 : u32 = x_3790.z;
  let x_3796 : u32 = (x_3792 + (x_3792 << 10u));
  let x_3800 : u32 = (x_3796 ^ (x_3796 >> 6u));
  let x_3804 : u32 = (x_3800 + (x_3800 << 3u));
  let x_3808 : u32 = (x_3804 ^ (x_3804 >> 11u));
  let x_3818 : u32 = ((((x_3790.y * 1664525u) + (x_3808 + (x_3808 << 15u))) + 1013904223u) * 1664525u);
  let x_3822 : u32 = (x_3818 ^ (x_3818 >> 11u));
  let x_3827 : u32 = (x_3822 ^ ((x_3822 << 7u) & 2636928640u));
  let x_3832 : u32 = (x_3827 ^ ((x_3827 << 15u) & 4022730752u));
  let x_3842 : u32 = ((((x_3790.x * 1664525u) + (x_3832 ^ (x_3832 >> 18u))) + 1013904223u) * 1664525u);
  let x_3846 : u32 = (x_3842 ^ (x_3842 >> 11u));
  let x_3851 : u32 = (x_3846 ^ ((x_3846 << 7u) & 2636928640u));
  let x_3856 : u32 = (x_3851 ^ ((x_3851 << 15u) & 4022730752u));
  let x_3860 : u32 = (x_3856 ^ (x_3856 >> 18u));
  x_24932 = x_3860;
  x_24931 = 0u;
  loop {
    if ((x_24931 >= 2u)) {
      break;
    }
    let x_3872 : u32 = (x_24932 + (x_24932 << 10u));
    let x_3876 : u32 = (x_3872 ^ (x_3872 >> 6u));
    let x_3880 : u32 = (x_3876 + (x_3876 << 3u));
    let x_3884 : u32 = (x_3880 ^ (x_3880 >> 11u));
    x_2760[x_24931] = (bitcast<f32>(((x_24932 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24932 = (x_3884 + (x_3884 << 15u));
      x_24931 = (x_24931 + 1u);
    }
  }
  let x_3904 : vec3<u32> = bitcast<vec3<u32>>((x_3444 + vec3<i32>(0i, 0i, 1i)));
  let x_3906 : u32 = x_3904.z;
  let x_3910 : u32 = (x_3906 + (x_3906 << 10u));
  let x_3914 : u32 = (x_3910 ^ (x_3910 >> 6u));
  let x_3918 : u32 = (x_3914 + (x_3914 << 3u));
  let x_3922 : u32 = (x_3918 ^ (x_3918 >> 11u));
  let x_3932 : u32 = ((((x_3904.y * 1664525u) + (x_3922 + (x_3922 << 15u))) + 1013904223u) * 1664525u);
  let x_3936 : u32 = (x_3932 ^ (x_3932 >> 11u));
  let x_3941 : u32 = (x_3936 ^ ((x_3936 << 7u) & 2636928640u));
  let x_3946 : u32 = (x_3941 ^ ((x_3941 << 15u) & 4022730752u));
  let x_3956 : u32 = ((((x_3904.x * 1664525u) + (x_3946 ^ (x_3946 >> 18u))) + 1013904223u) * 1664525u);
  let x_3960 : u32 = (x_3956 ^ (x_3956 >> 11u));
  let x_3965 : u32 = (x_3960 ^ ((x_3960 << 7u) & 2636928640u));
  let x_3970 : u32 = (x_3965 ^ ((x_3965 << 15u) & 4022730752u));
  let x_3974 : u32 = (x_3970 ^ (x_3970 >> 18u));
  x_24935 = x_3974;
  x_24934 = 0u;
  loop {
    if ((x_24934 >= 2u)) {
      break;
    }
    let x_3986 : u32 = (x_24935 + (x_24935 << 10u));
    let x_3990 : u32 = (x_3986 ^ (x_3986 >> 6u));
    let x_3994 : u32 = (x_3990 + (x_3990 << 3u));
    let x_3998 : u32 = (x_3994 ^ (x_3994 >> 11u));
    x_2784[x_24934] = (bitcast<f32>(((x_24935 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24935 = (x_3998 + (x_3998 << 15u));
      x_24934 = (x_24934 + 1u);
    }
  }
  let x_4018 : vec3<u32> = bitcast<vec3<u32>>((x_3444 + vec3<i32>(1i, 0i, 1i)));
  let x_4020 : u32 = x_4018.z;
  let x_4024 : u32 = (x_4020 + (x_4020 << 10u));
  let x_4028 : u32 = (x_4024 ^ (x_4024 >> 6u));
  let x_4032 : u32 = (x_4028 + (x_4028 << 3u));
  let x_4036 : u32 = (x_4032 ^ (x_4032 >> 11u));
  let x_4046 : u32 = ((((x_4018.y * 1664525u) + (x_4036 + (x_4036 << 15u))) + 1013904223u) * 1664525u);
  let x_4050 : u32 = (x_4046 ^ (x_4046 >> 11u));
  let x_4055 : u32 = (x_4050 ^ ((x_4050 << 7u) & 2636928640u));
  let x_4060 : u32 = (x_4055 ^ ((x_4055 << 15u) & 4022730752u));
  let x_4070 : u32 = ((((x_4018.x * 1664525u) + (x_4060 ^ (x_4060 >> 18u))) + 1013904223u) * 1664525u);
  let x_4074 : u32 = (x_4070 ^ (x_4070 >> 11u));
  let x_4079 : u32 = (x_4074 ^ ((x_4074 << 7u) & 2636928640u));
  let x_4084 : u32 = (x_4079 ^ ((x_4079 << 15u) & 4022730752u));
  let x_4088 : u32 = (x_4084 ^ (x_4084 >> 18u));
  x_24938 = x_4088;
  x_24937 = 0u;
  loop {
    if ((x_24937 >= 2u)) {
      break;
    }
    let x_4100 : u32 = (x_24938 + (x_24938 << 10u));
    let x_4104 : u32 = (x_4100 ^ (x_4100 >> 6u));
    let x_4108 : u32 = (x_4104 + (x_4104 << 3u));
    let x_4112 : u32 = (x_4108 ^ (x_4108 >> 11u));
    x_2808[x_24937] = (bitcast<f32>(((x_24938 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24938 = (x_4112 + (x_4112 << 15u));
      x_24937 = (x_24937 + 1u);
    }
  }
  let x_4132 : vec3<u32> = bitcast<vec3<u32>>((x_3444 + vec3<i32>(0i, 1i, 1i)));
  let x_4134 : u32 = x_4132.z;
  let x_4138 : u32 = (x_4134 + (x_4134 << 10u));
  let x_4142 : u32 = (x_4138 ^ (x_4138 >> 6u));
  let x_4146 : u32 = (x_4142 + (x_4142 << 3u));
  let x_4150 : u32 = (x_4146 ^ (x_4146 >> 11u));
  let x_4160 : u32 = ((((x_4132.y * 1664525u) + (x_4150 + (x_4150 << 15u))) + 1013904223u) * 1664525u);
  let x_4164 : u32 = (x_4160 ^ (x_4160 >> 11u));
  let x_4169 : u32 = (x_4164 ^ ((x_4164 << 7u) & 2636928640u));
  let x_4174 : u32 = (x_4169 ^ ((x_4169 << 15u) & 4022730752u));
  let x_4184 : u32 = ((((x_4132.x * 1664525u) + (x_4174 ^ (x_4174 >> 18u))) + 1013904223u) * 1664525u);
  let x_4188 : u32 = (x_4184 ^ (x_4184 >> 11u));
  let x_4193 : u32 = (x_4188 ^ ((x_4188 << 7u) & 2636928640u));
  let x_4198 : u32 = (x_4193 ^ ((x_4193 << 15u) & 4022730752u));
  let x_4202 : u32 = (x_4198 ^ (x_4198 >> 18u));
  x_24941 = x_4202;
  x_24940 = 0u;
  loop {
    if ((x_24940 >= 2u)) {
      break;
    }
    let x_4214 : u32 = (x_24941 + (x_24941 << 10u));
    let x_4218 : u32 = (x_4214 ^ (x_4214 >> 6u));
    let x_4222 : u32 = (x_4218 + (x_4218 << 3u));
    let x_4226 : u32 = (x_4222 ^ (x_4222 >> 11u));
    x_2832[x_24940] = (bitcast<f32>(((x_24941 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24941 = (x_4226 + (x_4226 << 15u));
      x_24940 = (x_24940 + 1u);
    }
  }
  let x_4246 : vec3<u32> = bitcast<vec3<u32>>((x_3444 + vec3<i32>(1i, 1i, 1i)));
  let x_4248 : u32 = x_4246.z;
  let x_4252 : u32 = (x_4248 + (x_4248 << 10u));
  let x_4256 : u32 = (x_4252 ^ (x_4252 >> 6u));
  let x_4260 : u32 = (x_4256 + (x_4256 << 3u));
  let x_4264 : u32 = (x_4260 ^ (x_4260 >> 11u));
  let x_4274 : u32 = ((((x_4246.y * 1664525u) + (x_4264 + (x_4264 << 15u))) + 1013904223u) * 1664525u);
  let x_4278 : u32 = (x_4274 ^ (x_4274 >> 11u));
  let x_4283 : u32 = (x_4278 ^ ((x_4278 << 7u) & 2636928640u));
  let x_4288 : u32 = (x_4283 ^ ((x_4283 << 15u) & 4022730752u));
  let x_4298 : u32 = ((((x_4246.x * 1664525u) + (x_4288 ^ (x_4288 >> 18u))) + 1013904223u) * 1664525u);
  let x_4302 : u32 = (x_4298 ^ (x_4298 >> 11u));
  let x_4307 : u32 = (x_4302 ^ ((x_4302 << 7u) & 2636928640u));
  let x_4312 : u32 = (x_4307 ^ ((x_4307 << 15u) & 4022730752u));
  let x_4316 : u32 = (x_4312 ^ (x_4312 >> 18u));
  x_24944 = x_4316;
  x_24943 = 0u;
  loop {
    if ((x_24943 >= 2u)) {
      break;
    }
    let x_4328 : u32 = (x_24944 + (x_24944 << 10u));
    let x_4332 : u32 = (x_4328 ^ (x_4328 >> 6u));
    let x_4336 : u32 = (x_4332 + (x_4332 << 3u));
    let x_4340 : u32 = (x_4336 ^ (x_4336 >> 11u));
    x_2856[x_24943] = (bitcast<f32>(((x_24944 & 8388607u) | 1065353216u)) - 1.0f);

    continuing {
      x_24944 = (x_4340 + (x_4340 << 15u));
      x_24943 = (x_24943 + 1u);
    }
  }
  let x_4364 : vec3<f32> = ((x_3446 * x_3446) * (vec3<f32>(3.0f, 3.0f, 3.0f) - (vec3<f32>(2.0f, 2.0f, 2.0f) * x_3446)));
  let x_4366 : f32 = x_4364.x;
  let x_4368 : f32 = (1.0f - x_4366);
  let x_4370 : f32 = x_4364.y;
  let x_4372 : f32 = (1.0f - x_4370);
  let x_4374 : f32 = x_4364.z;
  let x_4376 : f32 = (1.0f - x_4374);
  let x_4377 : vec2<f32> = x_2688;
  let x_4384 : vec2<f32> = x_2712;
  let x_4392 : vec2<f32> = x_2736;
  let x_4400 : vec2<f32> = x_2760;
  let x_4408 : vec2<f32> = x_2784;
  let x_4416 : vec2<f32> = x_2808;
  let x_4424 : vec2<f32> = x_2832;
  let x_4432 : vec2<f32> = x_2856;
  let x_4442 : vec2<f32> = clamp(((((((((((((x_4377 * x_4368) * x_4372) * x_4376) + (((x_4384 * x_4366) * x_4372) * x_4376)) + (((x_4392 * x_4368) * x_4370) * x_4376)) + (((x_4400 * x_4366) * x_4370) * x_4376)) + (((x_4408 * x_4368) * x_4372) * x_4374)) + (((x_4416 * x_4366) * x_4372) * x_4374)) + (((x_4424 * x_4368) * x_4370) * x_4374)) + (((x_4432 * x_4366) * x_4370) * x_4374)) - x_2236) * 2.5f), vec2<f32>(-0.5f, -0.5f), x_2236);
  let x_4450 : vec3<f32> = (x_3439 + (vec3<f32>(x_4442.x, 0.0f, x_4442.y) * 0.05999999865889549255f));
  var x_25153_1 : vec4<f32> = x_3437;
  x_25153_1.x = x_4450.x;
  let x_25153 : vec4<f32> = x_25153_1;
  var x_25156_1 : vec4<f32> = x_25153;
  x_25156_1.y = x_4450.y;
  let x_25156 : vec4<f32> = x_25156_1;
  var x_25159_1 : vec4<f32> = x_25156;
  x_25159_1.z = x_4450.z;
  let x_25159 : vec4<f32> = x_25159_1;
  let x_4462 : vec4<f32> = x_3426[0u];
  let x_4465 : vec4<f32> = x_3426[1u];
  let x_4468 : vec4<f32> = x_3426[2u];
  let x_4482 : mat3x3<f32> = mat3x3<f32>(vec3<f32>(x_4462.x, x_4462.y, x_4462.z), vec3<f32>(x_4465.x, x_4465.y, x_4465.z), vec3<f32>(x_4468.x, x_4468.y, x_4468.z));
  let x_4484 : vec3<f32> = (vec3<f32>(1.0f, 0.0f, 0.0f) * x_4482);
  let x_4486 : vec3<f32> = (vec3<f32>(0.0f, 1.0f, 0.0f) * x_4482);
  let x_4488 : vec3<f32> = (vec3<f32>(0.0f, 0.0f, 1.0f) * x_4482);
  let x_4491 : vec3<f32> = cross(x_4484, x_4486);
  let x_4495 : f32 = (1.0f / dot(x_4488, x_4491));
  let x_4496 : vec3<f32> = vec3<f32>(x_4495, x_4495, x_4495);
  let x_4499 : u32 = bitcast<u32>((x_3147 ^ 2340774i));
  let x_4503 : u32 = (x_4499 + (x_4499 << 10u));
  let x_4507 : u32 = (x_4503 ^ (x_4503 >> 6u));
  let x_4511 : u32 = (x_4507 + (x_4507 << 3u));
  let x_4515 : u32 = (x_4511 ^ (x_4511 >> 11u));
  let x_4518 : u32 = bitcast<u32>((x_3147 ^ 934565i));
  let x_4522 : u32 = (x_4518 + (x_4518 << 10u));
  let x_4526 : u32 = (x_4522 ^ (x_4522 >> 6u));
  let x_4530 : u32 = (x_4526 + (x_4526 << 3u));
  let x_4534 : u32 = (x_4530 ^ (x_4530 >> 11u));
  let x_4536 : mat4x4<f32> = x_2365.renderer_MVPMat;
  gl_Position = (x_4536 * x_25159);
  v0 = vec3<f32>(x_25159.x, x_25159.y, x_25159.z);
  let x_4542 : vec3<f32> = Vertex_Normal;
  v1 = normalize((x_4542 * transpose(mat3x3<f32>((cross(x_4486, x_4488) * x_4496), (cross(x_4488, x_4484) * x_4496), (x_4491 * x_4496)))));
  let x_18201 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_18208 : i32 = x_18201.x;
  let x_18217 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_18208), (x_4687 / x_18208)), 0i);
  v2 = x_18217[x_4700];
  let x_18235 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_18242 : i32 = x_18235.x;
  let x_18251 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_18242), (x_4687 / x_18242)), 0i);
  let x_18423 : i32 = ((bitcast<i32>(x_18251[x_4700]) * 20i) + 18i);
  let x_18925 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_18930 : i32 = (x_18423 / 4i);
  let x_18932 : i32 = x_18925.x;
  let x_18941 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_18930 % x_18932), (x_18930 / x_18932)), 0i);
  v3 = x_18941[(x_18423 % 4i)];
  let x_4582 : i32 = is_bevel;
  v5 = x_4582;
  let x_18986 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_18993 : i32 = x_18986.x;
  let x_19002 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_18993), (x_4687 / x_18993)), 0i);
  let x_19158 : i32 = ((bitcast<i32>(x_19002[x_4700]) * 20i) + 15i);
  let x_19595 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_19600 : i32 = (x_19158 / 4i);
  let x_19602 : i32 = x_19595.x;
  let x_19611 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_19600 % x_19602), (x_19600 / x_19602)), 0i);
  v6 = select(0i, 1i, ((x_19611[(x_19158 % 4i)] & 2u) != 0u));
  let x_4592 : vec2<f32> = Vertex_UV;
  let x_4614 : f32 = (f32(x_4582) * 0.12000000476837158203f);
  v7 = ((((x_4592 * 0.40000000596046447754f) + vec2<f32>((bitcast<f32>((((x_4515 + (x_4515 << 15u)) & 8388607u) | 1065353216u)) - 1.0f), (bitcast<f32>((((x_4534 + (x_4534 << 15u)) & 8388607u) | 1065353216u)) - 1.0f))) + vec2<f32>(x_4614, x_4614)) * vec2<f32>(1.0f, (x_3006 * 0.40000000596046447754f)));
  let x_19737 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_19744 : i32 = x_19737.x;
  let x_19753 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_19744), (x_4687 / x_19744)), 0i);
  let x_19904 : i32 = ((bitcast<i32>(x_19753[x_4700]) * 20i) + 14i);
  let x_20319 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_20324 : i32 = (x_19904 / 4i);
  let x_20326 : i32 = x_20319.x;
  let x_20335 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_20324 % x_20326), (x_20324 / x_20326)), 0i);
  v8 = bitcast<i32>(x_20335[(x_19904 % 4i)]);
  let x_20488 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_20495 : i32 = x_20488.x;
  let x_20504 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_20495), (x_4687 / x_20495)), 0i);
  let x_20660 : i32 = ((bitcast<i32>(x_20504[x_4700]) * 20i) + 15i);
  let x_21097 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_21102 : i32 = (x_20660 / 4i);
  let x_21104 : i32 = x_21097.x;
  let x_21113 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_21102 % x_21104), (x_21102 / x_21104)), 0i);
  v9 = bitcast<i32>((x_21113[(x_20660 % 4i)] & 4u));
  let x_21239 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_21246 : i32 = x_21239.x;
  let x_21255 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_21246), (x_4687 / x_21246)), 0i);
  let x_21411 : i32 = ((bitcast<i32>(x_21255[x_4700]) * 20i) + 15i);
  let x_21848 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_21853 : i32 = (x_21411 / 4i);
  let x_21855 : i32 = x_21848.x;
  let x_21864 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_21853 % x_21855), (x_21853 / x_21855)), 0i);
  v10 = bitcast<i32>((x_21864[(x_21411 % 4i)] & 8u));
  let x_21990 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_21997 : i32 = x_21990.x;
  let x_22006 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_21997), (x_4687 / x_21997)), 0i);
  let x_22162 : i32 = ((bitcast<i32>(x_22006[x_4700]) * 20i) + 15i);
  let x_22599 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_22604 : i32 = (x_22162 / 4i);
  let x_22606 : i32 = x_22599.x;
  let x_22615 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_22604 % x_22606), (x_22604 / x_22606)), 0i);
  v11 = bitcast<i32>((x_22615[(x_22162 % 4i)] & 16u));
  let x_22741 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_22748 : i32 = x_22741.x;
  let x_22757 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_22748), (x_4687 / x_22748)), 0i);
  let x_22913 : i32 = ((bitcast<i32>(x_22757[x_4700]) * 20i) + 15i);
  let x_23350 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_23355 : i32 = (x_22913 / 4i);
  let x_23357 : i32 = x_23350.x;
  let x_23366 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_23355 % x_23357), (x_23355 / x_23357)), 0i);
  v12 = bitcast<i32>((x_23366[(x_22913 % 4i)] & 32u));
  let x_23492 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_6_0, 0i));
  let x_23499 : i32 = x_23492.x;
  let x_23508 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_6_0, vec2<i32>((x_4687 % x_23499), (x_4687 / x_23499)), 0i);
  let x_23664 : i32 = ((bitcast<i32>(x_23508[x_4700]) * 20i) + 15i);
  let x_24101 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_0, 0i));
  let x_24106 : i32 = (x_23664 / 4i);
  let x_24108 : i32 = x_24101.x;
  let x_24117 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_0, vec2<i32>((x_24106 % x_24108), (x_24106 / x_24108)), 0i);
  v13 = bitcast<i32>((x_24117[(x_23664 % 4i)] & 256u));
  let x_2551 : f32 = gl_Position.z;
  let x_2553 : f32 = gl_Position.w;
  gl_Position.z = (0.5f * (x_2551 + x_2553));
  return;
}

struct main_out {
  @builtin(position)
  gl_Position : vec4<f32>,
  @location(0)
  v0_1 : vec3<f32>,
  @location(1)
  v1_1 : vec3<f32>,
  @location(2) @interpolate(flat)
  v2_1 : u32,
  @location(3) @interpolate(flat)
  v3_1 : u32,
  @location(4) @interpolate(flat)
  v5_1 : i32,
  @location(5) @interpolate(flat)
  v6_1 : i32,
  @location(6)
  v7_1 : vec2<f32>,
  @location(7) @interpolate(flat)
  v8_1 : i32,
  @location(8) @interpolate(flat)
  v9_1 : i32,
  @location(9) @interpolate(flat)
  v10_1 : i32,
  @location(10) @interpolate(flat)
  v11_1 : i32,
  @location(11) @interpolate(flat)
  v12_1 : i32,
  @location(12) @interpolate(flat)
  v13_1 : i32,
}

@vertex
fn main(@builtin(instance_index) gl_InstanceIndex_param : u32, @location(0) Vertex_Position_param : vec3<f32>, @location(1) Vertex_Normal_param : vec3<f32>, @location(3) @interpolate(flat) is_bevel_param : i32, @location(2) Vertex_UV_param : vec2<f32>) -> main_out {
  gl_InstanceIndex = bitcast<i32>(gl_InstanceIndex_param);
  Vertex_Position = Vertex_Position_param;
  Vertex_Normal = Vertex_Normal_param;
  is_bevel = is_bevel_param;
  Vertex_UV = Vertex_UV_param;
  main_1();
  return main_out(gl_Position, v0, v1, v2, v3, v5, v6, v7, v8, v9, v10, v11, v12, v13);
}
