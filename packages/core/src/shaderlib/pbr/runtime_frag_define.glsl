struct IncidentLight {
    vec3 color;
    vec3 direction;
};
struct ReflectedLight {
    vec3 directDiffuse;
    vec3 directSpecular;
    vec3 indirectDiffuse;
    vec3 indirectSpecular;
};
struct GeometricContext {
    vec3 position;
    vec3 normal;
    vec3 viewDir;
    #ifdef CLEARCOAT
        vec3 clearcoatNormal;
    #endif
};
struct PhysicalMaterial {
    vec3 diffuseColor;
    float specularRoughness;
    vec3  specularColor;
    #ifdef CLEARCOAT
        float clearcoat;
        float clearcoatRoughness;
    #endif
};
