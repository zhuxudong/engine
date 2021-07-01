vec3 radiance = getIndirectRadiance( geometry.viewDir, geometry.normal, material.specularRoughness, int(u_envMapLight.maxMipMapLevel) );
vec3 clearcoatRadiance = vec3(0);

#ifdef CLEARCOAT
    clearcoatRadiance = getIndirectRadiance( geometry.viewDir, geometry.clearcoatNormal, material.clearcoatRoughness, int(u_envMapLight.maxMipMapLevel) );
#endif

RE_IndirectSpecular_Physical( radiance, irradiance * u_envMapLight.specularIntensity * RECIPROCAL_PI, clearcoatRadiance, geometry, material, reflectedLight );