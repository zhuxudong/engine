#ifdef SCENE_GRASSLANDS_CLOUD_SHADOW
  sampler2D scene_GrasslandsCloudShadow;
  vec3 scene_GrasslandsCloudRight;
  vec3 scene_GrasslandsCloudUp;
  vec4 scene_GrasslandsCloudParams;

  float grasslandsCloudShadow(vec3 worldPosition) {
    vec2 projected = vec2(
      dot(worldPosition, scene_GrasslandsCloudRight),
      dot(worldPosition, scene_GrasslandsCloudUp)
    );
    vec2 uv = projected * scene_GrasslandsCloudParams.x + scene_GrasslandsCloudParams.yz;
    float cookie = texture2D(scene_GrasslandsCloudShadow, fract(uv)).r;
    return mix(1.0, cookie, scene_GrasslandsCloudParams.w);
  }
#else
  float grasslandsCloudShadow(vec3 worldPosition) {
    return 1.0;
  }
#endif
