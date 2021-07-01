uniform float u_alphaCutoff;

uniform vec4 u_baseColorFactor;
uniform float u_metal;
uniform float u_roughness;
uniform vec3 u_specularFactor;
uniform float u_glossinessFactor;
uniform vec3 u_emissiveFactor;

uniform float u_envMapIntensity;
uniform float u_refractionRatio;

uniform vec2 u_resolution;

#ifdef CLEARCOAT
    uniform float u_clearcoatFactor;
    uniform float u_clearcoatRoughnessFactor;
#endif



// todo: delete
uniform float u_normalIntensity;
uniform float u_occlusionStrength;

