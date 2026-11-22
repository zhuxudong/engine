diagnostic(off, derivative_uniformity);
@binding(12) @group(3) var gs_wgpu_tex_resource0 : texture_2d<f32>;

@binding(13) @group(3) var gs_wgpu_samp_resource0 : sampler;

@binding(14) @group(3) var gs_wgpu_tex_resource1 : texture_2d<f32>;

@binding(15) @group(3) var gs_wgpu_samp_resource1 : sampler;

@binding(16) @group(3) var gs_wgpu_tex_resource2 : texture_2d<f32>;

@binding(17) @group(3) var gs_wgpu_samp_resource2 : sampler;

@binding(2) @group(3) var gs_wgpu_tex_storage_0_1 : texture_2d<u32>;

@binding(3) @group(3) var gs_wgpu_samp_storage_0_1 : sampler;

@binding(6) @group(3) var gs_wgpu_tex_uniform_FrameCounter_natural : texture_2d<u32>;

@binding(7) @group(3) var gs_wgpu_samp_uniform_FrameCounter_natural : sampler;

@binding(4) @group(3) var gs_wgpu_tex_uniform_ViewConstants_natural : texture_2d<u32>;

@binding(5) @group(3) var gs_wgpu_samp_uniform_ViewConstants_natural : sampler;

@binding(8) @group(3) var gs_wgpu_tex_uniform_MaterialData_natural : texture_2d<u32>;

@binding(9) @group(3) var gs_wgpu_samp_uniform_MaterialData_natural : sampler;

var<private> v4 : u32;

var<private> gl_FragCoord : vec4<f32>;

var<private> v5 : u32;

var<private> v3 : vec2<f32>;

var<private> v0 : vec3<f32>;

var<private> v2 : vec3<f32>;

var<private> v6 : vec3<f32>;

var<private> residentColor : vec4<f32>;

const x_7171 = vec2<i32>(0i, 0i);

const x_661 = vec2<u32>(1u, 1u);

const x_1380 = vec2<f32>(0.00100000004749745131f, 0.0f);

const x_1382 = vec2<f32>(0.0f, 0.40000000596046447754f);

fn main_1() {
  var x_2471 : array<vec2<u32>, 4u>;
  var x_2273 : u32;
  var x_2744 : vec3<f32>;
  var x_2749 : bool;
  var x_2753 : vec3<f32>;
  var x_6941 : vec3<f32>;
  var x_6940 : bool;
  var x_3323 : vec3<f32>;
  var x_3326 : vec3<f32>;
  var x_7162 : vec3<f32>;
  let x_2271 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_FrameCounter_natural, x_7171, 0i);
  x_2273 = x_2271.x;
  let x_2286 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_ViewConstants_natural, 0i));
  let x_2291 : i32 = x_2286.x;
  let x_2298 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((20i % x_2291), (20i / x_2291)), 0i);
  let x_2310 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((21i % x_2291), (21i / x_2291)), 0i);
  let x_2322 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((22i % x_2291), (22i / x_2291)), 0i);
  let x_2334 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((23i % x_2291), (23i / x_2291)), 0i);
  let x_2346 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_ViewConstants_natural, vec2<i32>((63i % x_2291), (63i / x_2291)), 0i);
  let x_2399 : mat4x4<f32> = mat4x4<f32>(vec4<f32>(bitcast<f32>(x_2298.x), bitcast<f32>(x_2310.x), bitcast<f32>(x_2322.x), bitcast<f32>(x_2334.x)), vec4<f32>(bitcast<f32>(x_2298.y), bitcast<f32>(x_2310.y), bitcast<f32>(x_2322.y), bitcast<f32>(x_2334.y)), vec4<f32>(bitcast<f32>(x_2298.z), bitcast<f32>(x_2310.z), bitcast<f32>(x_2322.z), bitcast<f32>(x_2334.z)), vec4<f32>(bitcast<f32>(x_2298.w), bitcast<f32>(x_2310.w), bitcast<f32>(x_2322.w), bitcast<f32>(x_2334.w)));
  let x_2403 : f32 = bitcast<f32>(x_2346.w);
  let x_2413 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_uniform_MaterialData_natural, 0i));
  let x_2425 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_MaterialData_natural, x_7171, 0i);
  let x_2430 : i32 = x_2413.x;
  let x_2437 : vec4<u32> = textureLoad(gs_wgpu_tex_uniform_MaterialData_natural, vec2<i32>((1i % x_2430), (1i / x_2430)), 0i);
  let x_2439 : u32 = x_2425.x;
  let x_2443 : u32 = x_2437.x;
  let x_2706 : u32 = v4;
  let x_3993 : i32 = (bitcast<i32>(x_2706) * 16i);
  let x_3994 : i32 = (x_3993 + 12i);
  let x_4345 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_4350 : i32 = (x_3994 / 4i);
  let x_4352 : i32 = x_4345.x;
  let x_4361 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4350 % x_4352), (x_4350 / x_4352)), 0i);
  if (((x_4361[(x_3994 % 4i)] >> 31u) != 0u)) {
    let x_2713 : vec4<f32> = gl_FragCoord;
    x_2471 = array<vec2<u32>, 4u>(vec2<u32>(0u, 0u), vec2<u32>(0u, 1u), x_661, vec2<u32>(1u, 0u));
    let x_2721 : vec2<u32> = x_2471[(x_2273 & 3u)];
    if (all(((vec2<u32>(vec2<f32>(x_2713.x, x_2713.y)) & x_661) != x_2721))) {
      discard;
    }
  }
  var x_5624 : vec4<f32>;
  var x_6936 : vec4<f32>;
  var x_6937 : vec4<f32>;
  let x_2727 : u32 = v5;
  let x_2728 : bool = (x_2727 != 0u);
  let x_4588 : i32 = (x_3993 + 14i);
  let x_4982 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
  let x_4987 : i32 = (x_4588 / 4i);
  let x_4989 : i32 = x_4982.x;
  let x_4998 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_4987 % x_4989), (x_4987 / x_4989)), 0i);
  if ((x_4998[(x_4588 % 4i)] != 0u)) {
    var x_2739 : i32;
    var x_2740 : vec2<f32>;
    var x_5634 : vec4<f32>;
    var x_5641 : vec4<f32>;
    let x_5176 : i32 = (x_3993 + 15i);
    let x_5592 : vec2<i32> = vec2<i32>(textureDimensions(gs_wgpu_tex_storage_0_1, 0i));
    let x_5597 : i32 = (x_5176 / 4i);
    let x_5599 : i32 = x_5592.x;
    let x_5608 : vec4<u32> = textureLoad(gs_wgpu_tex_storage_0_1, vec2<i32>((x_5597 % x_5599), (x_5597 / x_5599)), 0i);
    x_2739 = bitcast<i32>(x_5608[(x_5176 % 4i)]);
    x_2740 = v3;
    if ((x_2739 == 0i)) {
      x_5624 = textureSampleBias(gs_wgpu_tex_resource0, gs_wgpu_samp_resource0, x_2740, x_2403);
      x_6937 = x_5624;
    } else {
      if ((x_2739 == 1i)) {
        x_5634 = textureSampleBias(gs_wgpu_tex_resource1, gs_wgpu_samp_resource1, x_2740, x_2403);
        x_6936 = x_5634;
      } else {
        x_5641 = textureSampleBias(gs_wgpu_tex_resource2, gs_wgpu_samp_resource2, x_2740, x_2403);
        x_6936 = x_5641;
      }
      x_6937 = x_6936;
    }
    x_2744 = vec3<f32>(x_6937.x, x_6937.y, x_6937.z);
    x_2749 = select(x_2728, true, (length(x_2744) > 0.11999999731779098511f));
    x_6941 = x_2744;
    x_6940 = x_2749;
  } else {
    x_2753 = v0;
    x_6941 = x_2753;
    x_6940 = x_2728;
  }
  var x_2755 : vec3<f32>;
  var x_2763 : vec3<f32>;
  var x_6952 : u32;
  var x_6951 : u32;
  var x_6976 : f32;
  var x_6956 : u32;
  var x_6955 : u32;
  var x_6979 : f32;
  var x_6960 : u32;
  var x_6959 : u32;
  var x_6981 : f32;
  var x_6964 : u32;
  var x_6963 : u32;
  var x_6982 : f32;
  var x_3242 : f32;
  var x_7004 : f32;
  var x_5665 : vec4<f32>;
  var x_7001 : vec4<f32>;
  var x_7002 : vec4<f32>;
  var x_5701 : vec4<f32>;
  var x_7042 : vec4<f32>;
  var x_7043 : vec4<f32>;
  x_2755 = v2;
  x_2763 = normalize(cross(dpdx(x_2755), (dpdy(x_2755) * -1.0f)));
  if (x_6940) {
    let x_2771 : vec3<f32> = vec3<f32>(-(x_2763.z), 0.0f, x_2763.x);
    let x_2774 : vec4<f32> = (x_2399 * vec4<f32>(0.0f, 0.0f, 0.0f, 1.0f));
    let x_2779 : f32 = x_2774.w;
    let x_2783 : vec3<f32> = normalize((x_2755 - (vec3<f32>(x_2774.x, x_2774.y, x_2774.z) / vec3<f32>(x_2779, x_2779, x_2779))));
    let x_2786 : f32 = dot(x_2783, x_2763);
    let x_2789 : vec3<f32> = v6;
    let x_2802 : vec3<f32> = ((x_2755 + (x_2783 * (dot(((x_2789 - (x_2763 * 0.20000000298023223877f)) - x_2755), x_2763) / x_2786))) - x_2789);
    let x_2805 : f32 = dot(x_2802, x_2771);
    let x_2807 : f32 = x_2802.y;
    let x_2813 : f32 = v6.x;
    let x_2816 : f32 = v6.y;
    let x_2817 : f32 = (((x_2805 - (x_2807 * -0.30000001192092895508f)) + x_2813) + x_2816);
    let x_2818 : vec2<f32> = vec2<f32>(x_2817, x_2817);
    let x_2821 : vec2<i32> = vec2<i32>(floor(x_2818));
    let x_2823 : vec2<f32> = fract(x_2818);
    let x_2825 : vec2<u32> = bitcast<vec2<u32>>(x_2821);
    let x_2827 : u32 = x_2825.y;
    let x_2831 : u32 = (x_2827 + (x_2827 << 10u));
    let x_2835 : u32 = (x_2831 ^ (x_2831 >> 6u));
    let x_2839 : u32 = (x_2835 + (x_2835 << 3u));
    let x_2843 : u32 = (x_2839 ^ (x_2839 >> 11u));
    let x_2853 : u32 = ((((x_2825.x * 1664525u) + (x_2843 + (x_2843 << 15u))) + 1013904223u) * 1664525u);
    let x_2857 : u32 = (x_2853 ^ (x_2853 >> 11u));
    let x_2862 : u32 = (x_2857 ^ ((x_2857 << 7u) & 2636928640u));
    let x_2867 : u32 = (x_2862 ^ ((x_2862 << 15u) & 4022730752u));
    let x_2871 : u32 = (x_2867 ^ (x_2867 >> 18u));
    x_6952 = x_2871;
    x_6951 = 0u;
    x_6976 = 0.0f;
    loop {
      if ((x_6951 >= 1u)) {
        break;
      }
      let x_2884 : u32 = (x_6952 + (x_6952 << 10u));
      let x_2888 : u32 = (x_2884 ^ (x_2884 >> 6u));
      let x_2892 : u32 = (x_2888 + (x_2888 << 3u));
      let x_2896 : u32 = (x_2892 ^ (x_2892 >> 11u));

      continuing {
        x_6952 = (x_2896 + (x_2896 << 15u));
        x_6951 = (x_6951 + 1u);
        x_6976 = (bitcast<f32>(((x_6952 & 8388607u) | 1065353216u)) - 1.0f);
      }
    }
    let x_2915 : vec2<u32> = bitcast<vec2<u32>>((x_2821 + vec2<i32>(1i, 0i)));
    let x_2917 : u32 = x_2915.y;
    let x_2921 : u32 = (x_2917 + (x_2917 << 10u));
    let x_2925 : u32 = (x_2921 ^ (x_2921 >> 6u));
    let x_2929 : u32 = (x_2925 + (x_2925 << 3u));
    let x_2933 : u32 = (x_2929 ^ (x_2929 >> 11u));
    let x_2943 : u32 = ((((x_2915.x * 1664525u) + (x_2933 + (x_2933 << 15u))) + 1013904223u) * 1664525u);
    let x_2947 : u32 = (x_2943 ^ (x_2943 >> 11u));
    let x_2952 : u32 = (x_2947 ^ ((x_2947 << 7u) & 2636928640u));
    let x_2957 : u32 = (x_2952 ^ ((x_2952 << 15u) & 4022730752u));
    let x_2961 : u32 = (x_2957 ^ (x_2957 >> 18u));
    x_6956 = x_2961;
    x_6955 = 0u;
    x_6979 = 0.0f;
    loop {
      if ((x_6955 >= 1u)) {
        break;
      }
      let x_2974 : u32 = (x_6956 + (x_6956 << 10u));
      let x_2978 : u32 = (x_2974 ^ (x_2974 >> 6u));
      let x_2982 : u32 = (x_2978 + (x_2978 << 3u));
      let x_2986 : u32 = (x_2982 ^ (x_2982 >> 11u));

      continuing {
        x_6956 = (x_2986 + (x_2986 << 15u));
        x_6955 = (x_6955 + 1u);
        x_6979 = (bitcast<f32>(((x_6956 & 8388607u) | 1065353216u)) - 1.0f);
      }
    }
    let x_3005 : vec2<u32> = bitcast<vec2<u32>>((x_2821 + vec2<i32>(0i, 1i)));
    let x_3007 : u32 = x_3005.y;
    let x_3011 : u32 = (x_3007 + (x_3007 << 10u));
    let x_3015 : u32 = (x_3011 ^ (x_3011 >> 6u));
    let x_3019 : u32 = (x_3015 + (x_3015 << 3u));
    let x_3023 : u32 = (x_3019 ^ (x_3019 >> 11u));
    let x_3033 : u32 = ((((x_3005.x * 1664525u) + (x_3023 + (x_3023 << 15u))) + 1013904223u) * 1664525u);
    let x_3037 : u32 = (x_3033 ^ (x_3033 >> 11u));
    let x_3042 : u32 = (x_3037 ^ ((x_3037 << 7u) & 2636928640u));
    let x_3047 : u32 = (x_3042 ^ ((x_3042 << 15u) & 4022730752u));
    let x_3051 : u32 = (x_3047 ^ (x_3047 >> 18u));
    x_6960 = x_3051;
    x_6959 = 0u;
    x_6981 = 0.0f;
    loop {
      if ((x_6959 >= 1u)) {
        break;
      }
      let x_3064 : u32 = (x_6960 + (x_6960 << 10u));
      let x_3068 : u32 = (x_3064 ^ (x_3064 >> 6u));
      let x_3072 : u32 = (x_3068 + (x_3068 << 3u));
      let x_3076 : u32 = (x_3072 ^ (x_3072 >> 11u));

      continuing {
        x_6960 = (x_3076 + (x_3076 << 15u));
        x_6959 = (x_6959 + 1u);
        x_6981 = (bitcast<f32>(((x_6960 & 8388607u) | 1065353216u)) - 1.0f);
      }
    }
    let x_3095 : vec2<u32> = bitcast<vec2<u32>>((x_2821 + vec2<i32>(1i, 1i)));
    let x_3097 : u32 = x_3095.y;
    let x_3101 : u32 = (x_3097 + (x_3097 << 10u));
    let x_3105 : u32 = (x_3101 ^ (x_3101 >> 6u));
    let x_3109 : u32 = (x_3105 + (x_3105 << 3u));
    let x_3113 : u32 = (x_3109 ^ (x_3109 >> 11u));
    let x_3123 : u32 = ((((x_3095.x * 1664525u) + (x_3113 + (x_3113 << 15u))) + 1013904223u) * 1664525u);
    let x_3127 : u32 = (x_3123 ^ (x_3123 >> 11u));
    let x_3132 : u32 = (x_3127 ^ ((x_3127 << 7u) & 2636928640u));
    let x_3137 : u32 = (x_3132 ^ ((x_3132 << 15u) & 4022730752u));
    let x_3141 : u32 = (x_3137 ^ (x_3137 >> 18u));
    x_6964 = x_3141;
    x_6963 = 0u;
    x_6982 = 0.0f;
    loop {
      if ((x_6963 >= 1u)) {
        break;
      }
      let x_3154 : u32 = (x_6964 + (x_6964 << 10u));
      let x_3158 : u32 = (x_3154 ^ (x_3154 >> 6u));
      let x_3162 : u32 = (x_3158 + (x_3158 << 3u));
      let x_3166 : u32 = (x_3162 ^ (x_3162 >> 11u));

      continuing {
        x_6964 = (x_3166 + (x_3166 << 15u));
        x_6963 = (x_6963 + 1u);
        x_6982 = (bitcast<f32>(((x_6964 & 8388607u) | 1065353216u)) - 1.0f);
      }
    }
    let x_3189 : vec2<f32> = ((x_2823 * x_2823) * (vec2<f32>(3.0f, 3.0f) - (vec2<f32>(2.0f, 2.0f) * x_2823)));
    let x_3191 : f32 = x_3189.x;
    let x_3193 : f32 = (1.0f - x_3191);
    let x_3195 : f32 = x_3189.y;
    let x_3221 : f32 = (x_2805 + ((((((1.0f - x_3195) * ((x_6976 * x_3193) + (x_6979 * x_3191))) + ((x_6981 * x_3193) * x_3195)) + ((x_6982 * x_3191) * x_3195)) - 0.5f) * 0.30000001192092895508f));
    loop {
      let x_3228 : f32 = abs(max(0.0f, (abs(x_3221) - 0.35499998927116394043f)));
      if ((x_3228 > 0.10000000149011611938f)) {
        x_7004 = 0.0f;
        break;
      }
      x_3242 = (1.0f - ((100.0f * (x_3228 * x_3228)) * (3.0f - (x_3228 * 20.0f))));
      x_7004 = x_3242;
      break;
    }
    var x_3247 : i32;
    var x_3252 : vec2<f32>;
    var x_5676 : vec4<f32>;
    var x_5684 : vec4<f32>;
    x_3247 = bitcast<i32>(x_2439);
    x_3252 = (vec2<f32>(x_3221, (x_2807 * -1.0f)) * vec2<f32>(3.0f, 1.0f));
    if ((x_3247 == 0i)) {
      x_5665 = textureSampleGrad(gs_wgpu_tex_resource0, gs_wgpu_samp_resource0, x_3252, x_1380, x_1382);
      x_7002 = x_5665;
    } else {
      if ((x_3247 == 1i)) {
        x_5676 = textureSampleGrad(gs_wgpu_tex_resource1, gs_wgpu_samp_resource1, x_3252, x_1380, x_1382);
        x_7001 = x_5676;
      } else {
        x_5684 = textureSampleGrad(gs_wgpu_tex_resource2, gs_wgpu_samp_resource2, x_3252, x_1380, x_1382);
        x_7001 = x_5684;
      }
      x_7002 = x_7001;
    }
    var x_3294 : i32;
    var x_3296 : vec2<f32>;
    var x_5711 : vec4<f32>;
    var x_5718 : vec4<f32>;
    let x_3255 : vec3<f32> = sqrt(vec3<f32>(x_7002.x, x_7002.y, x_7002.z));
    let x_3262 : vec4<f32> = (vec4<f32>(x_3255.x, x_3255.y, x_3255.z, 1.0f) * (1.0f - x_7004));
    let x_3278 : vec3<f32> = ((x_2755 + (x_2783 * (dot(((x_2789 - (x_2763 * 1.20000004768371582031f)) - x_2755), x_2763) / x_2786))) - x_2789);
    let x_3281 : f32 = dot(x_3278, x_2771);
    let x_3283 : f32 = x_3278.y;
    var x_7236_1 : vec2<f32> = vec2<f32>(x_3281, x_3283);
    x_7236_1.y = (x_3283 * -1.0f);
    let x_7236 : vec2<f32> = x_7236_1;
    x_3294 = bitcast<i32>(x_2443);
    x_3296 = (x_7236 + vec2<f32>(0.5f, 0.5f));
    if ((x_3294 == 0i)) {
      x_5701 = textureSampleLevel(gs_wgpu_tex_resource0, gs_wgpu_samp_resource0, x_3296, 4.5f);
      x_7043 = x_5701;
    } else {
      if ((x_3294 == 1i)) {
        x_5711 = textureSampleLevel(gs_wgpu_tex_resource1, gs_wgpu_samp_resource1, x_3296, 4.5f);
        x_7042 = x_5711;
      } else {
        x_5718 = textureSampleLevel(gs_wgpu_tex_resource2, gs_wgpu_samp_resource2, x_3296, 4.5f);
        x_7042 = x_5718;
      }
      x_7043 = x_7042;
    }
    let x_3311 : vec3<f32> = (vec3<f32>(0.07500000298023223877f, 0.07500000298023223877f, 0.07500000298023223877f) + (sqrt(vec3<f32>(x_7043.x, x_7043.y, x_7043.z)) * (0.40000000596046447754f * exp((-0.5f * ((x_3281 * x_3281) + (x_3283 * x_3283)))))));
    let x_3318 : f32 = (1.0f - x_3262.w);
    let x_3322 : vec4<f32> = clamp((mix(x_3262, vec4<f32>(x_3311.x, x_3311.y, x_3311.z, 1.0f), vec4<f32>(x_3318, x_3318, x_3318, x_3318)) * 0.40000000596046447754f), vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f), vec4<f32>(1.0f, 1.0f, 1.0f, 1.0f));
    x_3323 = vec3<f32>(x_3322.x, x_3322.y, x_3322.z);
    x_7162 = x_3323;
  } else {
    x_3326 = (x_6941 * 0.5f);
    x_7162 = x_3326;
  }
  let x_3801 : vec3<f32> = sqrt(clamp(x_7162, vec3<f32>(0.0f, 0.0f, 0.0f), vec3<f32>(1.0f, 1.0f, 1.0f)));
  let x_3823 : u32 = ((u32(((clamp(x_3801.x, 0.0f, 1.0f) * 255.0f) + 0.5f)) + (u32(((clamp(x_3801.y, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 8u)) + (u32(((clamp(x_3801.z, 0.0f, 1.0f) * 255.0f) + 0.5f)) << 16u));
  let x_3857 : u32 = (x_3823 | 117440512u);
  let x_2232 : vec3<f32> = vec3<f32>(f32((x_3823 & 255u)), f32(((x_3857 >> 8u) & 255u)), f32(((x_3857 >> 16u) & 255u)));
  let x_2237 : vec3<f32> = (vec3<f32>(0.00001537870230094995f, 0.00001537870230094995f, 0.00001537870230094995f) * (x_2232 * x_2232));
  let x_2247 : vec3<f32> = select((x_2237 * 12.9200000762939453125f), ((pow(x_2237, vec3<f32>(0.4166666567325592041f, 0.4166666567325592041f, 0.4166666567325592041f)) * 1.05499994754791259766f) - vec3<f32>(0.05499999970197677612f, 0.05499999970197677612f, 0.05499999970197677612f)), (x_2237 > vec3<f32>(0.00313080009073019028f, 0.00313080009073019028f, 0.00313080009073019028f)));
  residentColor = vec4<f32>(x_2247.x, x_2247.y, x_2247.z, 1.0f);
  return;
}

struct main_out {
  @location(0)
  residentColor_1 : vec4<f32>,
}

@fragment
fn main(@location(3) @interpolate(flat) v4_param : u32, @builtin(position) gl_FragCoord_param : vec4<f32>, @location(4) @interpolate(flat) v5_param : u32, @location(2) v3_param : vec2<f32>, @location(0) v0_param : vec3<f32>, @location(1) v2_param : vec3<f32>, @location(5) @interpolate(flat) v6_param : vec3<f32>) -> main_out {
  v4 = v4_param;
  gl_FragCoord = gl_FragCoord_param;
  v5 = v5_param;
  v3 = v3_param;
  v0 = v0_param;
  v2 = v2_param;
  v6 = v6_param;
  main_1();
  return main_out(residentColor);
}
