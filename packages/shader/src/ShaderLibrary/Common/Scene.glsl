#ifndef GALACEAN_SCENE_INCLUDED
#define GALACEAN_SCENE_INCLUDED

uniform Scene {
    vec4 scene_FogColor;
    vec4 scene_FogParams;
    vec4 scene_SunlightColor;
    vec3 scene_SunlightDirection;
    vec3 scene_LightDirection;
    vec2 scene_ShadowBias;
};

#endif
