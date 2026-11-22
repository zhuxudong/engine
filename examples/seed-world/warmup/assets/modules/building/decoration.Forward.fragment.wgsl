diagnostic(off, derivative_uniformity);
alias Arr = array<vec4<f32>, 8u>;

alias Arr_1 = array<vec4<f32>, 8u>;

struct gs_Auto_0 {
  @size(248)
  padding : u32,
  /* @offset(248) */
  scene_MasonryFallbackMask : i32,
  /* @offset(256) */
  scene_MasonryLightPositionRange : Arr_1,
  /* @offset(384) */
  scene_MasonryLightColorIntensity : Arr_1,
}

struct gs_Camera {
  @size(192)
  padding_1 : u32,
  /* @offset(192) */
  camera_Position : vec3<f32>,
}

alias Arr_2 = array<vec4<u32>, 2u>;

struct gs_Auto_2 {
  /* @offset(0) */
  words : Arr_2,
}

@binding(0) @group(2) var<uniform> x_1017 : gs_Auto_0;

@binding(0) @group(1) var<uniform> x_1109 : gs_Camera;

@binding(4) @group(2) var gs_wgpu_tex_material_WindowCurtains : texture_2d<f32>;

@binding(5) @group(2) var gs_wgpu_samp_material_WindowCurtains : sampler;

@binding(6) @group(2) var gs_wgpu_tex_material_WindowIndoors : texture_2d<f32>;

@binding(7) @group(2) var gs_wgpu_samp_material_WindowIndoors : sampler;

@binding(2) @group(2) var gs_wgpu_tex_material_WindowTimber : texture_2d_array<f32>;

@binding(3) @group(2) var gs_wgpu_samp_material_WindowTimber : sampler;

@binding(8) @group(2) var gs_wgpu_tex_material_WindowGlass : texture_2d<f32>;

@binding(9) @group(2) var gs_wgpu_samp_material_WindowGlass : sampler;

var<private> vertexNormal : vec3<f32>;

var<private> vertexColor : vec3<f32>;

var<private> vertexUV : vec2<f32>;

var<private> vertexKind : f32;

var<private> windowCenterWS : vec3<f32>;

var<private> decorationPositionWS : vec3<f32>;

var<private> vertexEmission : f32;

var<private> residentColor : vec4<f32>;

@binding(1) @group(2) var<uniform> gs_wgpu_data_2 : gs_Auto_2;

const x_678 = vec3<f32>(0.0f, 0.0f, 0.0f);

const x_1550 = vec2<i32>(1i, 0i);

const x_1653 = vec2<i32>(0i, 1i);

const x_1756 = vec2<i32>(1i, 1i);

const x_1862 = vec2<f32>(2.0f, 2.0f);

const x_1861 = vec2<f32>(3.0f, 3.0f);

const x_1945 = vec2<f32>(3.0f, 1.0f);

const x_1948 = vec2<f32>(0.00100000004749745131f, 0.0f);

const x_1950 = vec2<f32>(0.0f, 0.40000000596046447754f);

const x_2005 = vec2<f32>(0.5f, 0.5f);

const x_1998 = vec3<f32>(0.07500000298023223877f, 0.07500000298023223877f, 0.07500000298023223877f);

const x_2034 = vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);

const x_2035 = vec4<f32>(1.0f, 1.0f, 1.0f, 1.0f);

const x_2099 = vec2<f32>(1234.0f, 1234.0f);

const x_2054 = vec3<f32>(0.87999999523162841797f, 0.84178292751312255859f, 0.21120001375675201416f);

const x_7589 = vec3<f32>(0.17599999904632568359f, 0.16835658252239227295f, 0.04224000498652458191f);

fn main_1() {
  var x_3010 : vec2<f32>;
  var x_3011 : f32;
  var x_3012 : vec3<f32>;
  var x_3015 : f32;
  var x_3017 : vec3<f32>;
  var x_3078 : vec3<f32>;
  var x_7204 : vec3<f32>;
  var x_7667 : vec3<f32>;
  var x_7200 : vec3<f32>;
  var x_7194 : vec3<f32>;
  var x_7138 : vec3<f32>;
  var x_3243 : vec3<f32>;
  var x_4773 : vec3<f32>;
  var x_7662 : vec3<f32>;
  var x_5306 : vec3<f32>;
  var x_5309 : vec3<f32>;
  var x_7129 : vec3<f32>;
  var x_7122 : vec3<f32>;
  var x_7123 : vec3<f32>;
  var x_7210 : vec3<f32>;
  var x_7206 : vec3<f32>;
  var x_7205 : vec3<f32>;
  var x_7216 : vec3<f32>;
  var x_7215 : vec3<f32>;
  let x_2923 : u32 = gs_wgpu_data_2.words[0i].x;
  let x_2926 : u32 = gs_wgpu_data_2.words[0i].y;
  let x_2929 : u32 = gs_wgpu_data_2.words[0i].z;
  let x_2931 : vec3<f32> = vec3<f32>(bitcast<f32>(x_2923), bitcast<f32>(x_2926), bitcast<f32>(x_2929));
  let x_2938 : u32 = gs_wgpu_data_2.words[1i].x;
  let x_2939 : f32 = bitcast<f32>(x_2938);
  let x_3007 : vec3<f32> = vertexNormal;
  let x_3008 : vec3<f32> = normalize(x_3007);
  let x_3009 : vec3<f32> = vertexColor;
  x_3010 = vertexUV;
  x_3011 = vertexKind;
  x_3012 = windowCenterWS;
  let x_3013 : vec3<f32> = decorationPositionWS;
  x_3015 = vertexEmission;
  x_3017 = x_1109.camera_Position;
  switch(0u) {
    default: {
      let x_3074 : f32 = floor((x_3011 * 0.0625f));
      let x_3076 : f32 = (x_3011 - (16.0f * floor((x_3011 / 16.0f))));
      x_3078 = (vec3<f32>(1.0f, 0.56999999284744262695f, 0.18000000715255737305f) * x_3015);
      if ((x_3076 < 0.5f)) {
        x_7210 = x_3078;
        x_7206 = x_3008;
        x_7205 = x_3009;
        break;
      }
      var x_3146 : vec3<f32>;
      if (((x_3076 > 3.5f) & (x_3076 < 5.5f))) {
        if ((x_3076 > 4.5f)) {
          x_7210 = x_678;
          x_7206 = x_3008;
          x_7205 = x_3009;
          break;
        }
        let x_3096 : u32 = u32(x_3074);
        let x_3100 : u32 = (x_3096 + (x_3096 << 10u));
        let x_3104 : u32 = (x_3100 ^ (x_3100 >> 6u));
        let x_3108 : u32 = (x_3104 + (x_3104 << 3u));
        let x_3112 : u32 = (x_3108 ^ (x_3108 >> 11u));
        let x_3121 : f32 = (bitcast<f32>((((x_3112 + (x_3112 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
        let x_3132 : vec2<f32> = ((x_3010 + vec2<f32>(x_3121, x_3121)) + (vec2<f32>(x_3013.x, x_3013.z) * 0.10000000149011611938f));
        let x_3137 : vec4<f32> = textureSample(gs_wgpu_tex_material_WindowTimber, gs_wgpu_samp_material_WindowTimber, vec3<f32>(x_3132.x, x_3132.y, x_3074).xy, i32(round(vec3<f32>(x_3132.x, x_3132.y, x_3074).z)));
        let x_3138 : vec3<f32> = vec3<f32>(x_3137.x, x_3137.y, x_3137.z);
        if ((x_3074 < 0.5f)) {
          x_3146 = mix((x_3138 * 0.69999998807907104492f), x_3009, vec3<f32>(0.30000001192092895508f, 0.30000001192092895508f, 0.30000001192092895508f));
          x_7204 = x_3146;
        } else {
          x_7204 = x_3138;
        }
        x_7210 = x_678;
        x_7206 = x_3008;
        x_7205 = x_7204;
        break;
      }
      var x_3167 : bool;
      var x_3169 : bool;
      var x_3494 : vec3<f32>;
      var x_4027 : vec3<f32>;
      var x_4030 : vec3<f32>;
      var x_7193 : vec3<f32>;
      if ((x_3076 > 7.5f)) {
        let x_3159 : vec4<f32> = textureSample(gs_wgpu_tex_material_WindowGlass, gs_wgpu_samp_material_WindowGlass, x_3010);
        let x_3160 : vec3<f32> = vec3<f32>(x_3159.x, x_3159.y, x_3159.z);
        let x_3162 : bool = (x_3076 > 8.5f);
        x_3169 = x_3162;
        if (!(x_3162)) {
          x_3167 = (length(x_3160) > 0.11999999731779098511f);
          x_3169 = x_3167;
        }
        let x_3487 : vec3<f32> = normalize(cross(dpdx(x_3013), (-(dpdy(x_3013)) * -1.0f)));
        x_7667 = x_3487;
        if ((dot(x_3487, x_3008) < 0.0f)) {
          x_3494 = -(x_3487);
          x_7667 = x_3494;
        }
        var x_3947 : f32;
        var x_7154 : f32;
        if (x_3169) {
          let x_3503 : vec3<f32> = vec3<f32>(-(x_7667.z), 0.0f, x_7667.x);
          let x_3508 : vec4<f32> = vec4<f32>(x_3017.x, x_3017.y, x_3017.z, 1.0f);
          let x_3517 : vec3<f32> = normalize((x_3013 - vec3<f32>(x_3508.x, x_3508.y, x_3508.z)));
          let x_3520 : f32 = dot(x_3517, x_7667);
          let x_3529 : f32 = (sign(select(x_3520, 1.0f, (x_3520 == 0.0f))) * max(abs(x_3520), 0.00009999999747378752f));
          let x_3545 : vec3<f32> = ((x_3013 + (x_3517 * (dot(((x_3012 - (x_7667 * 0.20000000298023223877f)) - x_3013), x_7667) / x_3529))) - x_3012);
          let x_3548 : f32 = dot(x_3545, x_3503);
          let x_3550 : f32 = x_3545.y;
          let x_3560 : f32 = (((x_3548 - (x_3550 * -0.30000001192092895508f)) + x_3012.x) + x_3012.y);
          let x_3561 : vec2<f32> = vec2<f32>(x_3560, x_3560);
          let x_3564 : vec2<i32> = vec2<i32>(floor(x_3561));
          let x_3566 : vec2<f32> = fract(x_3561);
          let x_3568 : vec2<u32> = bitcast<vec2<u32>>(x_3564);
          let x_3570 : u32 = x_3568.y;
          let x_3574 : u32 = (x_3570 + (x_3570 << 10u));
          let x_3578 : u32 = (x_3574 ^ (x_3574 >> 6u));
          let x_3582 : u32 = (x_3578 + (x_3578 << 3u));
          let x_3586 : u32 = (x_3582 ^ (x_3582 >> 11u));
          let x_3596 : u32 = ((((x_3568.x * 1664525u) + (x_3586 + (x_3586 << 15u))) + 1013904223u) * 1664525u);
          let x_3600 : u32 = (x_3596 ^ (x_3596 >> 11u));
          let x_3605 : u32 = (x_3600 ^ ((x_3600 << 7u) & 2636928640u));
          let x_3610 : u32 = (x_3605 ^ ((x_3605 << 15u) & 4022730752u));
          let x_3649 : vec2<u32> = bitcast<vec2<u32>>((x_3564 + x_1550));
          let x_3651 : u32 = x_3649.y;
          let x_3655 : u32 = (x_3651 + (x_3651 << 10u));
          let x_3659 : u32 = (x_3655 ^ (x_3655 >> 6u));
          let x_3663 : u32 = (x_3659 + (x_3659 << 3u));
          let x_3667 : u32 = (x_3663 ^ (x_3663 >> 11u));
          let x_3677 : u32 = ((((x_3649.x * 1664525u) + (x_3667 + (x_3667 << 15u))) + 1013904223u) * 1664525u);
          let x_3681 : u32 = (x_3677 ^ (x_3677 >> 11u));
          let x_3686 : u32 = (x_3681 ^ ((x_3681 << 7u) & 2636928640u));
          let x_3691 : u32 = (x_3686 ^ ((x_3686 << 15u) & 4022730752u));
          let x_3730 : vec2<u32> = bitcast<vec2<u32>>((x_3564 + x_1653));
          let x_3732 : u32 = x_3730.y;
          let x_3736 : u32 = (x_3732 + (x_3732 << 10u));
          let x_3740 : u32 = (x_3736 ^ (x_3736 >> 6u));
          let x_3744 : u32 = (x_3740 + (x_3740 << 3u));
          let x_3748 : u32 = (x_3744 ^ (x_3744 >> 11u));
          let x_3758 : u32 = ((((x_3730.x * 1664525u) + (x_3748 + (x_3748 << 15u))) + 1013904223u) * 1664525u);
          let x_3762 : u32 = (x_3758 ^ (x_3758 >> 11u));
          let x_3767 : u32 = (x_3762 ^ ((x_3762 << 7u) & 2636928640u));
          let x_3772 : u32 = (x_3767 ^ ((x_3767 << 15u) & 4022730752u));
          let x_3811 : vec2<u32> = bitcast<vec2<u32>>((x_3564 + x_1756));
          let x_3813 : u32 = x_3811.y;
          let x_3817 : u32 = (x_3813 + (x_3813 << 10u));
          let x_3821 : u32 = (x_3817 ^ (x_3817 >> 6u));
          let x_3825 : u32 = (x_3821 + (x_3821 << 3u));
          let x_3829 : u32 = (x_3825 ^ (x_3825 >> 11u));
          let x_3839 : u32 = ((((x_3811.x * 1664525u) + (x_3829 + (x_3829 << 15u))) + 1013904223u) * 1664525u);
          let x_3843 : u32 = (x_3839 ^ (x_3839 >> 11u));
          let x_3848 : u32 = (x_3843 ^ ((x_3843 << 7u) & 2636928640u));
          let x_3853 : u32 = (x_3848 ^ ((x_3848 << 15u) & 4022730752u));
          let x_3896 : vec2<f32> = ((x_3566 * x_3566) * (x_1861 - (x_1862 * x_3566)));
          let x_3898 : f32 = x_3896.x;
          let x_3900 : f32 = (1.0f - x_3898);
          let x_3902 : f32 = x_3896.y;
          let x_3928 : f32 = (x_3548 + ((((((1.0f - x_3902) * (((bitcast<f32>((((x_3610 ^ (x_3610 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_3900) + ((bitcast<f32>((((x_3691 ^ (x_3691 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_3898))) + (((bitcast<f32>((((x_3772 ^ (x_3772 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_3900) * x_3902)) + (((bitcast<f32>((((x_3853 ^ (x_3853 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_3898) * x_3902)) - 0.5f) * 0.30000001192092895508f));
          let x_3933 : f32 = abs(max(0.0f, (abs(x_3928) - 0.35499998927116394043f)));
          if ((x_3933 > 0.10000000149011611938f)) {
            x_7154 = 0.0f;
          } else {
            x_3947 = (1.0f - ((100.0f * (x_3933 * x_3933)) * (3.0f - (x_3933 * 20.0f))));
            x_7154 = x_3947;
          }
          let x_3957 : vec4<f32> = textureSampleGrad(gs_wgpu_tex_material_WindowCurtains, gs_wgpu_samp_material_WindowCurtains, (vec2<f32>(x_3928, (x_3550 * -1.0f)) * x_1945), x_1948, x_1950);
          let x_3959 : vec3<f32> = sqrt(vec3<f32>(x_3957.x, x_3957.y, x_3957.z));
          let x_3966 : vec4<f32> = (vec4<f32>(x_3959.x, x_3959.y, x_3959.z, 1.0f) * (1.0f - x_7154));
          let x_3982 : vec3<f32> = ((x_3013 + (x_3517 * (dot(((x_3012 - (x_7667 * 1.20000004768371582031f)) - x_3013), x_7667) / x_3529))) - x_3012);
          let x_3985 : f32 = dot(x_3982, x_3503);
          let x_3987 : f32 = x_3982.y;
          var x_7615_1 : vec2<f32> = vec2<f32>(x_3985, x_3987);
          x_7615_1.y = (x_3987 * -1.0f);
          let x_7615 : vec2<f32> = x_7615_1;
          let x_4001 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_WindowIndoors, gs_wgpu_samp_material_WindowIndoors, (x_7615 + x_2005), 4.5f);
          let x_4015 : vec3<f32> = (x_1998 + (sqrt(vec3<f32>(x_4001.x, x_4001.y, x_4001.z)) * (0.40000000596046447754f * exp((-0.5f * ((x_3985 * x_3985) + (x_3987 * x_3987)))))));
          let x_4022 : f32 = (1.0f - x_3966.w);
          let x_4026 : vec4<f32> = clamp((mix(x_3966, vec4<f32>(x_4015.x, x_4015.y, x_4015.z, 1.0f), vec4<f32>(x_4022, x_4022, x_4022, x_4022)) * 0.40000000596046447754f), x_2034, x_2035);
          x_4027 = vec3<f32>(x_4026.x, x_4026.y, x_4026.z);
          x_7200 = x_4027;
        } else {
          x_4030 = (x_3160 * 0.5f);
          x_7200 = x_4030;
        }
        var x_4443 : vec3<f32>;
        var x_4449 : vec3<f32>;
        if ((x_3015 > 0.05000000074505805969f)) {
          let x_4069 : vec2<f32> = (((vec2<f32>(x_3013.x, x_3013.y) + vec2<f32>(x_3013.z, x_3013.y)) + x_2099) * 0.20000000298023223877f);
          let x_4072 : vec2<i32> = vec2<i32>(floor(x_4069));
          let x_4074 : vec2<f32> = fract(x_4069);
          let x_4076 : vec2<u32> = bitcast<vec2<u32>>(x_4072);
          let x_4078 : u32 = x_4076.y;
          let x_4082 : u32 = (x_4078 + (x_4078 << 10u));
          let x_4086 : u32 = (x_4082 ^ (x_4082 >> 6u));
          let x_4090 : u32 = (x_4086 + (x_4086 << 3u));
          let x_4094 : u32 = (x_4090 ^ (x_4090 >> 11u));
          let x_4104 : u32 = ((((x_4076.x * 1664525u) + (x_4094 + (x_4094 << 15u))) + 1013904223u) * 1664525u);
          let x_4108 : u32 = (x_4104 ^ (x_4104 >> 11u));
          let x_4113 : u32 = (x_4108 ^ ((x_4108 << 7u) & 2636928640u));
          let x_4118 : u32 = (x_4113 ^ ((x_4113 << 15u) & 4022730752u));
          let x_4157 : vec2<u32> = bitcast<vec2<u32>>((x_4072 + x_1550));
          let x_4159 : u32 = x_4157.y;
          let x_4163 : u32 = (x_4159 + (x_4159 << 10u));
          let x_4167 : u32 = (x_4163 ^ (x_4163 >> 6u));
          let x_4171 : u32 = (x_4167 + (x_4167 << 3u));
          let x_4175 : u32 = (x_4171 ^ (x_4171 >> 11u));
          let x_4185 : u32 = ((((x_4157.x * 1664525u) + (x_4175 + (x_4175 << 15u))) + 1013904223u) * 1664525u);
          let x_4189 : u32 = (x_4185 ^ (x_4185 >> 11u));
          let x_4194 : u32 = (x_4189 ^ ((x_4189 << 7u) & 2636928640u));
          let x_4199 : u32 = (x_4194 ^ ((x_4194 << 15u) & 4022730752u));
          let x_4238 : vec2<u32> = bitcast<vec2<u32>>((x_4072 + x_1653));
          let x_4240 : u32 = x_4238.y;
          let x_4244 : u32 = (x_4240 + (x_4240 << 10u));
          let x_4248 : u32 = (x_4244 ^ (x_4244 >> 6u));
          let x_4252 : u32 = (x_4248 + (x_4248 << 3u));
          let x_4256 : u32 = (x_4252 ^ (x_4252 >> 11u));
          let x_4266 : u32 = ((((x_4238.x * 1664525u) + (x_4256 + (x_4256 << 15u))) + 1013904223u) * 1664525u);
          let x_4270 : u32 = (x_4266 ^ (x_4266 >> 11u));
          let x_4275 : u32 = (x_4270 ^ ((x_4270 << 7u) & 2636928640u));
          let x_4280 : u32 = (x_4275 ^ ((x_4275 << 15u) & 4022730752u));
          let x_4319 : vec2<u32> = bitcast<vec2<u32>>((x_4072 + x_1756));
          let x_4321 : u32 = x_4319.y;
          let x_4325 : u32 = (x_4321 + (x_4321 << 10u));
          let x_4329 : u32 = (x_4325 ^ (x_4325 >> 6u));
          let x_4333 : u32 = (x_4329 + (x_4329 << 3u));
          let x_4337 : u32 = (x_4333 ^ (x_4333 >> 11u));
          let x_4347 : u32 = ((((x_4319.x * 1664525u) + (x_4337 + (x_4337 << 15u))) + 1013904223u) * 1664525u);
          let x_4351 : u32 = (x_4347 ^ (x_4347 >> 11u));
          let x_4356 : u32 = (x_4351 ^ ((x_4351 << 7u) & 2636928640u));
          let x_4361 : u32 = (x_4356 ^ ((x_4356 << 15u) & 4022730752u));
          let x_4404 : vec2<f32> = ((x_4074 * x_4074) * (x_1861 - (x_1862 * x_4074)));
          let x_4406 : f32 = x_4404.x;
          let x_4408 : f32 = (1.0f - x_4406);
          let x_4410 : f32 = x_4404.y;
          let x_4437 : f32 = ((mix(0.0f, 1.0f, clamp(((((1.0f - x_4410) * (((bitcast<f32>((((x_4118 ^ (x_4118 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_4408) + ((bitcast<f32>((((x_4199 ^ (x_4199 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_4406))) + (((bitcast<f32>((((x_4280 ^ (x_4280 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_4408) * x_4410)) + (((bitcast<f32>((((x_4361 ^ (x_4361 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_4406) * x_4410)), 0.0f, 1.0f)) * 0.60000002384185791016f) * x_3015);
          if (x_3169) {
            x_4443 = ((x_2054 * x_4437) * 1.0f);
            x_7193 = x_4443;
          } else {
            x_4449 = ((x_7589 * x_4437) * 1.0f);
            x_7193 = x_4449;
          }
          x_7194 = x_7193;
        } else {
          x_7194 = x_678;
        }
        x_7210 = x_7194;
        x_7206 = x_7667;
        x_7205 = x_7200;
        break;
      }
      var x_4512 : vec3<f32>;
      if ((x_3076 > 5.5f)) {
        var x_7133 : vec3<f32>;
        x_7138 = x_678;
        if (((x_3076 > 6.5f) & (x_3015 > 0.0f))) {
          let x_4474 : vec3<f32> = (x_3013 - x_3017);
          let x_4481 : vec3<f32> = (x_4474 * inverseSqrt(max(dot(x_4474, x_4474), 0.000000000001f)));
          let x_4492 : vec3<f32> = (x_3012 - (x_3017 + (x_4481 * dot((x_3012 - x_3017), x_4481))));
          let x_4495 : f32 = dot(x_4492, x_4492);
          let x_4505 : f32 = (3.0f * ((0.80000001192092895508f * exp2((-50.0f * x_4495))) + (2.0f * exp2((-200.0f * x_4495)))));
          switch(0u) {
            default: {
              if ((x_3074 < 0.5f)) {
                x_7133 = vec3<f32>(1.0f, 0.80000001192092895508f, 0.10000000149011611938f);
                break;
              }
              if ((x_3074 < 1.5f)) {
                x_7133 = vec3<f32>(0.0f, 0.73590415716171264648f, 3.67952060699462890625f);
                break;
              }
              if ((x_3074 < 2.5f)) {
                x_7133 = vec3<f32>(0.20513366162776947021f, 1.02566826343536376953f, 0.20513366162776947021f);
                break;
              }
              if ((x_3074 < 3.5f)) {
                x_7133 = vec3<f32>(0.85153043270111083984f, 0.56768691539764404297f, 2.83843445777893066406f);
                break;
              }
              x_7133 = vec3<f32>(1.82324230670928955078f, 0.54697269201278686523f, 0.18232423067092895508f);
            }
          }
          x_4512 = ((x_7133 * (1.39999997615814208984f * x_3015)) * x_4505);
          x_7138 = x_4512;
        }
        x_7210 = x_7138;
        x_7206 = x_3008;
        x_7205 = x_3009;
        break;
      }
      if ((x_3076 < 1.5f)) {
        let x_3200 : u32 = u32(x_3074);
        let x_3204 : u32 = (x_3200 + (x_3200 << 10u));
        let x_3208 : u32 = (x_3204 ^ (x_3204 >> 6u));
        let x_3212 : u32 = (x_3208 + (x_3208 << 3u));
        let x_3216 : u32 = (x_3212 ^ (x_3212 >> 11u));
        let x_3225 : f32 = (bitcast<f32>((((x_3216 + (x_3216 << 15u)) & 8388607u) | 1065353216u)) - 1.0f);
        let x_3233 : vec2<f32> = ((x_3010 * 0.5f) + vec2<f32>(x_3225, x_3225));
        let x_3238 : vec4<f32> = textureSample(gs_wgpu_tex_material_WindowTimber, gs_wgpu_samp_material_WindowTimber, vec3<f32>(x_3233.x, x_3233.y, x_3074).xy, i32(round(vec3<f32>(x_3233.x, x_3233.y, x_3074).z)));
        x_3243 = (vec3<f32>(x_3238.x, x_3238.y, x_3238.z) * select(1.0f, 0.69999998807907104492f, (x_3074 < 0.5f)));
        x_7210 = x_678;
        x_7206 = x_3008;
        x_7205 = x_3243;
        break;
      }
      let x_3246 : bool = (x_3076 > 2.5f);
      let x_4766 : vec3<f32> = normalize(cross(dpdx(x_3013), (-(dpdy(x_3013)) * -1.0f)));
      x_7662 = x_4766;
      if ((dot(x_4766, x_3008) < 0.0f)) {
        x_4773 = -(x_4766);
        x_7662 = x_4773;
      }
      var x_5226 : f32;
      var x_7083 : f32;
      if (x_3246) {
        let x_4782 : vec3<f32> = vec3<f32>(-(x_7662.z), 0.0f, x_7662.x);
        let x_4787 : vec4<f32> = vec4<f32>(x_3017.x, x_3017.y, x_3017.z, 1.0f);
        let x_4796 : vec3<f32> = normalize((x_3013 - vec3<f32>(x_4787.x, x_4787.y, x_4787.z)));
        let x_4799 : f32 = dot(x_4796, x_7662);
        let x_4808 : f32 = (sign(select(x_4799, 1.0f, (x_4799 == 0.0f))) * max(abs(x_4799), 0.00009999999747378752f));
        let x_4824 : vec3<f32> = ((x_3013 + (x_4796 * (dot(((x_3012 - (x_7662 * 0.20000000298023223877f)) - x_3013), x_7662) / x_4808))) - x_3012);
        let x_4827 : f32 = dot(x_4824, x_4782);
        let x_4829 : f32 = x_4824.y;
        let x_4839 : f32 = (((x_4827 - (x_4829 * -0.30000001192092895508f)) + x_3012.x) + x_3012.y);
        let x_4840 : vec2<f32> = vec2<f32>(x_4839, x_4839);
        let x_4843 : vec2<i32> = vec2<i32>(floor(x_4840));
        let x_4845 : vec2<f32> = fract(x_4840);
        let x_4847 : vec2<u32> = bitcast<vec2<u32>>(x_4843);
        let x_4849 : u32 = x_4847.y;
        let x_4853 : u32 = (x_4849 + (x_4849 << 10u));
        let x_4857 : u32 = (x_4853 ^ (x_4853 >> 6u));
        let x_4861 : u32 = (x_4857 + (x_4857 << 3u));
        let x_4865 : u32 = (x_4861 ^ (x_4861 >> 11u));
        let x_4875 : u32 = ((((x_4847.x * 1664525u) + (x_4865 + (x_4865 << 15u))) + 1013904223u) * 1664525u);
        let x_4879 : u32 = (x_4875 ^ (x_4875 >> 11u));
        let x_4884 : u32 = (x_4879 ^ ((x_4879 << 7u) & 2636928640u));
        let x_4889 : u32 = (x_4884 ^ ((x_4884 << 15u) & 4022730752u));
        let x_4928 : vec2<u32> = bitcast<vec2<u32>>((x_4843 + x_1550));
        let x_4930 : u32 = x_4928.y;
        let x_4934 : u32 = (x_4930 + (x_4930 << 10u));
        let x_4938 : u32 = (x_4934 ^ (x_4934 >> 6u));
        let x_4942 : u32 = (x_4938 + (x_4938 << 3u));
        let x_4946 : u32 = (x_4942 ^ (x_4942 >> 11u));
        let x_4956 : u32 = ((((x_4928.x * 1664525u) + (x_4946 + (x_4946 << 15u))) + 1013904223u) * 1664525u);
        let x_4960 : u32 = (x_4956 ^ (x_4956 >> 11u));
        let x_4965 : u32 = (x_4960 ^ ((x_4960 << 7u) & 2636928640u));
        let x_4970 : u32 = (x_4965 ^ ((x_4965 << 15u) & 4022730752u));
        let x_5009 : vec2<u32> = bitcast<vec2<u32>>((x_4843 + x_1653));
        let x_5011 : u32 = x_5009.y;
        let x_5015 : u32 = (x_5011 + (x_5011 << 10u));
        let x_5019 : u32 = (x_5015 ^ (x_5015 >> 6u));
        let x_5023 : u32 = (x_5019 + (x_5019 << 3u));
        let x_5027 : u32 = (x_5023 ^ (x_5023 >> 11u));
        let x_5037 : u32 = ((((x_5009.x * 1664525u) + (x_5027 + (x_5027 << 15u))) + 1013904223u) * 1664525u);
        let x_5041 : u32 = (x_5037 ^ (x_5037 >> 11u));
        let x_5046 : u32 = (x_5041 ^ ((x_5041 << 7u) & 2636928640u));
        let x_5051 : u32 = (x_5046 ^ ((x_5046 << 15u) & 4022730752u));
        let x_5090 : vec2<u32> = bitcast<vec2<u32>>((x_4843 + x_1756));
        let x_5092 : u32 = x_5090.y;
        let x_5096 : u32 = (x_5092 + (x_5092 << 10u));
        let x_5100 : u32 = (x_5096 ^ (x_5096 >> 6u));
        let x_5104 : u32 = (x_5100 + (x_5100 << 3u));
        let x_5108 : u32 = (x_5104 ^ (x_5104 >> 11u));
        let x_5118 : u32 = ((((x_5090.x * 1664525u) + (x_5108 + (x_5108 << 15u))) + 1013904223u) * 1664525u);
        let x_5122 : u32 = (x_5118 ^ (x_5118 >> 11u));
        let x_5127 : u32 = (x_5122 ^ ((x_5122 << 7u) & 2636928640u));
        let x_5132 : u32 = (x_5127 ^ ((x_5127 << 15u) & 4022730752u));
        let x_5175 : vec2<f32> = ((x_4845 * x_4845) * (x_1861 - (x_1862 * x_4845)));
        let x_5177 : f32 = x_5175.x;
        let x_5179 : f32 = (1.0f - x_5177);
        let x_5181 : f32 = x_5175.y;
        let x_5207 : f32 = (x_4827 + ((((((1.0f - x_5181) * (((bitcast<f32>((((x_4889 ^ (x_4889 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_5179) + ((bitcast<f32>((((x_4970 ^ (x_4970 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_5177))) + (((bitcast<f32>((((x_5051 ^ (x_5051 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_5179) * x_5181)) + (((bitcast<f32>((((x_5132 ^ (x_5132 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_5177) * x_5181)) - 0.5f) * 0.30000001192092895508f));
        let x_5212 : f32 = abs(max(0.0f, (abs(x_5207) - 0.35499998927116394043f)));
        if ((x_5212 > 0.10000000149011611938f)) {
          x_7083 = 0.0f;
        } else {
          x_5226 = (1.0f - ((100.0f * (x_5212 * x_5212)) * (3.0f - (x_5212 * 20.0f))));
          x_7083 = x_5226;
        }
        let x_5236 : vec4<f32> = textureSampleGrad(gs_wgpu_tex_material_WindowCurtains, gs_wgpu_samp_material_WindowCurtains, (vec2<f32>(x_5207, (x_4829 * -1.0f)) * x_1945), x_1948, x_1950);
        let x_5238 : vec3<f32> = sqrt(vec3<f32>(x_5236.x, x_5236.y, x_5236.z));
        let x_5245 : vec4<f32> = (vec4<f32>(x_5238.x, x_5238.y, x_5238.z, 1.0f) * (1.0f - x_7083));
        let x_5261 : vec3<f32> = ((x_3013 + (x_4796 * (dot(((x_3012 - (x_7662 * 1.20000004768371582031f)) - x_3013), x_7662) / x_4808))) - x_3012);
        let x_5264 : f32 = dot(x_5261, x_4782);
        let x_5266 : f32 = x_5261.y;
        var x_7645_1 : vec2<f32> = vec2<f32>(x_5264, x_5266);
        x_7645_1.y = (x_5266 * -1.0f);
        let x_7645 : vec2<f32> = x_7645_1;
        let x_5280 : vec4<f32> = textureSampleLevel(gs_wgpu_tex_material_WindowIndoors, gs_wgpu_samp_material_WindowIndoors, (x_7645 + x_2005), 4.5f);
        let x_5294 : vec3<f32> = (x_1998 + (sqrt(vec3<f32>(x_5280.x, x_5280.y, x_5280.z)) * (0.40000000596046447754f * exp((-0.5f * ((x_5264 * x_5264) + (x_5266 * x_5266)))))));
        let x_5301 : f32 = (1.0f - x_5245.w);
        let x_5305 : vec4<f32> = clamp((mix(x_5245, vec4<f32>(x_5294.x, x_5294.y, x_5294.z, 1.0f), vec4<f32>(x_5301, x_5301, x_5301, x_5301)) * 0.40000000596046447754f), x_2034, x_2035);
        x_5306 = vec3<f32>(x_5305.x, x_5305.y, x_5305.z);
        x_7129 = x_5306;
      } else {
        x_5309 = (x_3009 * 0.5f);
        x_7129 = x_5309;
      }
      var x_5722 : vec3<f32>;
      var x_5728 : vec3<f32>;
      if ((x_3015 > 0.05000000074505805969f)) {
        let x_5348 : vec2<f32> = (((vec2<f32>(x_3013.x, x_3013.y) + vec2<f32>(x_3013.z, x_3013.y)) + x_2099) * 0.20000000298023223877f);
        let x_5351 : vec2<i32> = vec2<i32>(floor(x_5348));
        let x_5353 : vec2<f32> = fract(x_5348);
        let x_5355 : vec2<u32> = bitcast<vec2<u32>>(x_5351);
        let x_5357 : u32 = x_5355.y;
        let x_5361 : u32 = (x_5357 + (x_5357 << 10u));
        let x_5365 : u32 = (x_5361 ^ (x_5361 >> 6u));
        let x_5369 : u32 = (x_5365 + (x_5365 << 3u));
        let x_5373 : u32 = (x_5369 ^ (x_5369 >> 11u));
        let x_5383 : u32 = ((((x_5355.x * 1664525u) + (x_5373 + (x_5373 << 15u))) + 1013904223u) * 1664525u);
        let x_5387 : u32 = (x_5383 ^ (x_5383 >> 11u));
        let x_5392 : u32 = (x_5387 ^ ((x_5387 << 7u) & 2636928640u));
        let x_5397 : u32 = (x_5392 ^ ((x_5392 << 15u) & 4022730752u));
        let x_5436 : vec2<u32> = bitcast<vec2<u32>>((x_5351 + x_1550));
        let x_5438 : u32 = x_5436.y;
        let x_5442 : u32 = (x_5438 + (x_5438 << 10u));
        let x_5446 : u32 = (x_5442 ^ (x_5442 >> 6u));
        let x_5450 : u32 = (x_5446 + (x_5446 << 3u));
        let x_5454 : u32 = (x_5450 ^ (x_5450 >> 11u));
        let x_5464 : u32 = ((((x_5436.x * 1664525u) + (x_5454 + (x_5454 << 15u))) + 1013904223u) * 1664525u);
        let x_5468 : u32 = (x_5464 ^ (x_5464 >> 11u));
        let x_5473 : u32 = (x_5468 ^ ((x_5468 << 7u) & 2636928640u));
        let x_5478 : u32 = (x_5473 ^ ((x_5473 << 15u) & 4022730752u));
        let x_5517 : vec2<u32> = bitcast<vec2<u32>>((x_5351 + x_1653));
        let x_5519 : u32 = x_5517.y;
        let x_5523 : u32 = (x_5519 + (x_5519 << 10u));
        let x_5527 : u32 = (x_5523 ^ (x_5523 >> 6u));
        let x_5531 : u32 = (x_5527 + (x_5527 << 3u));
        let x_5535 : u32 = (x_5531 ^ (x_5531 >> 11u));
        let x_5545 : u32 = ((((x_5517.x * 1664525u) + (x_5535 + (x_5535 << 15u))) + 1013904223u) * 1664525u);
        let x_5549 : u32 = (x_5545 ^ (x_5545 >> 11u));
        let x_5554 : u32 = (x_5549 ^ ((x_5549 << 7u) & 2636928640u));
        let x_5559 : u32 = (x_5554 ^ ((x_5554 << 15u) & 4022730752u));
        let x_5598 : vec2<u32> = bitcast<vec2<u32>>((x_5351 + x_1756));
        let x_5600 : u32 = x_5598.y;
        let x_5604 : u32 = (x_5600 + (x_5600 << 10u));
        let x_5608 : u32 = (x_5604 ^ (x_5604 >> 6u));
        let x_5612 : u32 = (x_5608 + (x_5608 << 3u));
        let x_5616 : u32 = (x_5612 ^ (x_5612 >> 11u));
        let x_5626 : u32 = ((((x_5598.x * 1664525u) + (x_5616 + (x_5616 << 15u))) + 1013904223u) * 1664525u);
        let x_5630 : u32 = (x_5626 ^ (x_5626 >> 11u));
        let x_5635 : u32 = (x_5630 ^ ((x_5630 << 7u) & 2636928640u));
        let x_5640 : u32 = (x_5635 ^ ((x_5635 << 15u) & 4022730752u));
        let x_5683 : vec2<f32> = ((x_5353 * x_5353) * (x_1861 - (x_1862 * x_5353)));
        let x_5685 : f32 = x_5683.x;
        let x_5687 : f32 = (1.0f - x_5685);
        let x_5689 : f32 = x_5683.y;
        let x_5716 : f32 = ((mix(0.0f, 1.0f, clamp(((((1.0f - x_5689) * (((bitcast<f32>((((x_5397 ^ (x_5397 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_5687) + ((bitcast<f32>((((x_5478 ^ (x_5478 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_5685))) + (((bitcast<f32>((((x_5559 ^ (x_5559 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_5687) * x_5689)) + (((bitcast<f32>((((x_5640 ^ (x_5640 >> 18u)) & 8388607u) | 1065353216u)) - 1.0f) * x_5685) * x_5689)), 0.0f, 1.0f)) * 0.60000002384185791016f) * x_3015);
        if (x_3246) {
          x_5722 = ((x_2054 * x_5716) * 1.0f);
          x_7122 = x_5722;
        } else {
          x_5728 = ((x_7589 * x_5716) * 1.0f);
          x_7122 = x_5728;
        }
        x_7123 = x_7122;
      } else {
        x_7123 = x_678;
      }
      x_7210 = x_7123;
      x_7206 = x_7662;
      x_7205 = x_7129;
    }
  }
  var x_6033 : i32;
  var x_7214 : i32;
  let x_5916 : vec3<f32> = ((x_7205 * 1.0f) * 0.95999997854232788086f);
  x_6033 = x_1017.scene_MasonryFallbackMask;
  x_7215 = x_678;
  if ((x_6033 != 0i)) {
    x_7216 = x_678;
    x_7214 = 0i;
    loop {
      var x_7353 : vec3<f32>;
      var x_7366 : vec3<f32>;
      var x_6077 : i32;
      if ((x_7214 < 8i)) {
      } else {
        break;
      }
      var x_7354 : vec3<f32>;
      x_7366 = x_7216;
      if (((bitcast<u32>(x_6033) & (1u << bitcast<u32>(x_7214))) != 0u)) {
        var x_6060 : vec3<f32>;
        var x_6066 : vec3<f32>;
        var x_6068 : f32;
        var x_6188 : vec3<f32>;
        let x_6052 : vec4<f32> = x_1017.scene_MasonryLightPositionRange[x_7214];
        let x_6055 : vec4<f32> = x_1017.scene_MasonryLightColorIntensity[x_7214];
        x_6060 = (vec3<f32>(x_6055.x, x_6055.y, x_6055.z) * x_6055.w);
        x_6066 = vec3<f32>(x_6052.x, x_6052.y, x_6052.z);
        x_6068 = x_6052.w;
        x_7353 = x_7216;
        if (any(!((x_6060 == x_678)))) {
          let x_6111 : vec3<f32> = (x_6066 - x_3013);
          let x_6114 : f32 = dot(x_6111, x_6111);
          let x_6117 : f32 = (x_6068 * x_6068);
          x_7354 = x_7216;
          if (((x_6114 < x_6117) & (x_6068 > 0.0f))) {
            let x_6173 : f32 = (1.0f - (x_6114 / x_6117));
            x_6188 = (x_7216 + ((x_7205 * x_6060) * (((max(0.0f, dot(x_7206, (x_6111 * select(100.0f, inverseSqrt(max(x_6114, 0.00000000000000000001f)), (x_6114 > 0.00009999999747378752f))))) * x_6173) * x_6173) / (1.0f + x_6114))));
            x_7354 = x_6188;
          }
          x_7353 = x_7354;
        }
        x_7366 = x_7353;
      }

      continuing {
        x_6077 = (x_7214 + 1i);
        x_7216 = x_7366;
        x_7214 = x_6077;
      }
    }
    x_7215 = x_7216;
  }
  let x_3029 : vec3<f32> = ((x_7215 + ((((x_2931 * 3.14159274101257324219f) * x_2939) * 1.0f) * (x_5916 * 0.31830987334251403809f))) + x_7210);
  let x_2980 : vec3<f32> = select((x_3029 * 12.9200000762939453125f), ((pow(x_3029, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_3029 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_2980.x, x_2980.y, x_2980.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(4) vertexNormal_param : vec3<f32>, @location(5) vertexColor_param : vec3<f32>, @location(7) vertexUV_param : vec2<f32>, @location(8) vertexKind_param : f32, @location(9) windowCenterWS_param : vec3<f32>, @location(3) decorationPositionWS_param : vec3<f32>, @location(6) vertexEmission_param : f32) -> main_out {
  vertexNormal = vertexNormal_param;
  vertexColor = vertexColor_param;
  vertexUV = vertexUV_param;
  vertexKind = vertexKind_param;
  windowCenterWS = windowCenterWS_param;
  decorationPositionWS = decorationPositionWS_param;
  vertexEmission = vertexEmission_param;
  main_1();
  return main_out(residentColor);
}
