float clearcoatDHRApprox( const in float roughness, const in float dotNL ) {
    return DEFAULT_SPECULAR_COEFFICIENT + ( 1.0 - DEFAULT_SPECULAR_COEFFICIENT ) * ( pow( 1.0 - dotNL, 5.0 ) * pow( 1.0 - roughness, 2.0 ) );
}

void RE_Direct_Physical( const in IncidentLight directLight, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
    float dotNL = saturate( dot( geometry.normal, directLight.direction ) );
    vec3 irradiance = dotNL * directLight.color;

 	#ifdef CLEARCOAT
        float ccDotNL = saturate( dot( geometry.normal, directLight.direction ) );
        vec3 ccIrradiance = ccDotNL * directLight.color;
        float clearcoatDHR = material.clearcoat * clearcoatDHRApprox( material.clearcoatRoughness, ccDotNL );
        reflectedLight.directSpecular += ccIrradiance * material.clearcoat * BRDF_Specular_GGX( directLight, geometry.viewDir, geometry.clearcoatNormal, vec3( DEFAULT_SPECULAR_COEFFICIENT ), material.clearcoatRoughness );
    #else
        float clearcoatDHR = 0.0;
    #endif

    reflectedLight.directSpecular += ( 1.0 - clearcoatDHR ) * irradiance * BRDF_Specular_GGX( directLight, geometry.viewDir, geometry.normal, material.specularColor, material.specularRoughness );
    reflectedLight.directDiffuse +=  ( 1.0 - clearcoatDHR ) * irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );

}



#ifdef O3_DIRECT_LIGHT_COUNT

    void getDirectionalDirectLightIrradiance( const in DirectLight directionalLight, const in GeometricContext geometry, out IncidentLight directLight ) {
        directLight.color = directionalLight.color;
        directLight.direction = -directionalLight.direction;
    }

#endif

#ifdef O3_POINT_LIGHT_COUNT

	// directLight is an out parameter as having it as a return value caused compiler errors on some devices
	void getPointDirectLightIrradiance( const in PointLight pointLight, const in GeometricContext geometry, out IncidentLight directLight ) {

		vec3 lVector = pointLight.position - geometry.position;
		directLight.direction = normalize( lVector );

		float lightDistance = length( lVector );

		directLight.color = pointLight.color;
		directLight.color *= clamp(1.0 - pow(lightDistance/pointLight.distance, 4.0), 0.0, 1.0);

	}

#endif

#ifdef O3_SPOT_LIGHT_COUNT

	// directLight is an out parameter as having it as a return value caused compiler errors on some devices
	void getSpotDirectLightIrradiance( const in SpotLight spotLight, const in GeometricContext geometry, out IncidentLight directLight  ) {

		vec3 lVector = spotLight.position - geometry.position;
		directLight.direction = normalize( lVector );

		float lightDistance = length( lVector );
		float angleCos = dot( directLight.direction, -spotLight.direction );

		float spotEffect = smoothstep( spotLight.penumbraCos, spotLight.angleCos, angleCos );
		float decayEffect = clamp(1.0 - pow(lightDistance/spotLight.distance, 4.0), 0.0, 1.0);

		directLight.color = spotLight.color;
		directLight.color *= spotEffect * decayEffect;
		
	}


#endif
