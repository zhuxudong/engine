      struct Attributes {
        vec3 POSITION;
      };

      struct Varyings {
        vec3 worldPosition;
        vec2 terrainCoord;
        float cameraDistance;
        #ifdef TERRAIN_DEBUG
          float geomorphFactor;
        #endif
        vec2 worldNoiseDdxDdy;
        float renderable;
      };

      struct TerrainSurface {
        vec4 albedoHeight;
        vec4 normalRoughness;
        float normalDepth;
        float aoStrength;
        float totalWeight;
      };

      #include "ShaderLibrary/Common/Common.glsl"
      #include "ShaderLibrary/Common/Transform.glsl"
      #include "ShaderLibrary/Common/Fog.glsl"
      #include "ShaderLibrary/Shadow/Shadow.glsl"
      #include "ShaderLibrary/Lighting/Light.glsl"
      #include "Terrain/GrasslandsCloudShadow.glsl"
      #ifdef TERRAIN_DEBUG
        float renderer_Lod;
        float renderer_DebugWire;
      #endif

      highp sampler2DArray material_HeightMaps;
      highp sampler2DArray material_ControlMaps;
      highp sampler2DArray material_ColorMaps;
      highp usampler2D material_RegionMap;
      vec4 material_TerrainParams;
      int material_RegionMapSize;
      float material_MeshSize;
      int material_BackgroundMode;
      int material_WorldNoiseFragmentNormals;
      float material_WorldNoiseRegionBlend;
      int material_WorldNoiseMaxOctaves;
      int material_WorldNoiseMinOctaves;
      float material_WorldNoiseLodDistance;
      float material_WorldNoiseScale;
      float material_WorldNoiseHeight;
      vec3 material_WorldNoiseOffset;

      highp sampler2DArray material_LayerAlbedoArray;
      highp sampler2DArray material_LayerNormalArray;
      int material_LayerCount;
      float material_LayerUvScales[32];
      vec2 material_LayerDetiling[32];
      vec3 material_LayerColors[32];
      float material_LayerNormalDepths[32];
      float material_LayerAoStrengths[32];
      float material_LayerRoughnessMods[32];

      float material_AutoSlope;
      float material_AutoHeightReduction;
      int material_AutoBaseTexture;
      int material_AutoOverlayTexture;

      int material_ProjectionEnabled;
      float material_ProjectionThreshold;
      int material_BilerpEnabled;
      float material_BlendSharpness;
      float material_MipmapBias;
      float material_BiasDistance;
      float material_DepthBlur;

      int material_DualTexture;
      float material_DualReduction;
      float material_DualNear;
      float material_DualFar;

      highp sampler2D material_MacroNoise;
      vec3 material_MacroColor1;
      vec3 material_MacroColor2;
      float material_MacroSlope;
      float material_Noise1Scale;
      float material_Noise1Angle;
      vec2 material_Noise1Offset;
      float material_Noise2Scale;
      #ifdef TERRAIN_DEBUG
        int material_DebugView;
        int material_DebugLayer;
      #endif

      float regionSize() {
        return material_TerrainParams.x;
      }

      float regionTexelSize() {
        return material_TerrainParams.y;
      }

      float vertexSpacing() {
        return material_TerrainParams.z;
      }

      float vertexDensity() {
        return material_TerrainParams.w;
      }

      float decodeBlend(uint control) {
        return float((control >> 14u) & 0xffu) * (1.0 / 255.0);
      }

      int decodeBase(uint control) {
        return int((control >> 27u) & 0x1fu);
      }

      int decodeOverlay(uint control) {
        return int((control >> 22u) & 0x1fu);
      }

      float decodeAngle(uint control) {
        return float((control >> 10u) & 0xfu) * -0.392699081698724;
      }

      float decodeScale(uint control) {
        uint scaleIndex = (control >> 7u) & 0x7u;
        return 0.9 - float(((scaleIndex + 3u) % 8u) + 1u) * 0.1;
      }

      bool decodeHole(uint control) {
        return ((control >> 2u) & 0x1u) != 0u;
      }

      bool decodeAuto(uint control) {
        return (control & 0x1u) != 0u;
      }

      bool decodeNavigation(uint control) {
        return ((control >> 1u) & 0x1u) != 0u;
      }

      #include "Terrain/TerrainWorldNoise.glsl"

      // xy: local texel, z: texture-array layer, w: flattened region-map position.
      ivec4 getIndexCoord(vec2 terrainGrid, int searchDepth) {
        vec2 roundedGrid = round(terrainGrid);
        vec2 localGrid = mod(roundedGrid, regionSize());
        ivec2 mapPosition = ivec2(0);
        int layer = -1;
        int flatMapPosition = -1;
        for (int search = -1; search < 2; search++) {
          if (search >= searchDepth) break;
          if ((layer == -1 && material_BackgroundMode == 0) || search < 0) {
            if (search != -1) {
              roundedGrid -= vec2(float(localGrid.x <= localGrid.y), float(localGrid.y <= localGrid.x));
            }
            mapPosition = ivec2(floor(roundedGrid * regionTexelSize())) + ivec2(material_RegionMapSize / 2);
            if (mapPosition.x >= 0 && mapPosition.y >= 0 &&
                mapPosition.x < material_RegionMapSize && mapPosition.y < material_RegionMapSize) {
              flatMapPosition = mapPosition.y * material_RegionMapSize + mapPosition.x;
              layer = int(texelFetch(material_RegionMap, mapPosition, 0).r) - 1;
            } else {
              flatMapPosition = -1;
              layer = -1;
            }
          }
        }
        return ivec4(ivec2(mod(roundedGrid, regionSize())), layer, flatMapPosition);
      }

      vec3 getIndexUv(vec2 regionGrid) {
        ivec2 regionLocation = ivec2(floor(regionGrid));
        int layer = regionLayerAt(regionLocation);
        return vec3(regionGrid - vec2(regionLocation), float(layer));
      }

      float fetchHeight(ivec4 index) {
        if (index.z < 0) return 0.0;
        return texelFetch(material_HeightMaps, ivec3(index.xy, index.z), 0).r;
      }

      uint fetchControl(ivec4 index) {
        if (index.z < 0) return 0u;
        uvec4 bytes = uvec4(round(texelFetch(material_ControlMaps, ivec3(index.xy, index.z), 0) * 255.0));
        return bytes.r | (bytes.g << 8u) | (bytes.b << 16u) | (bytes.a << 24u);
      }

      vec2 rotateVector(vec2 value, vec2 cosineSine) {
        return vec2(
          cosineSine.x * value.x + cosineSine.y * value.y,
          cosineSine.x * value.y - cosineSine.y * value.x
        );
      }

      float randomCell(vec2 cell) {
        return fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
      }

      vec3 diffuseIrradiance(vec3 terrainNormal) {
        vec3 irradiance = scene_EnvMapLight.diffuse * PI;
        #ifdef SCENE_USE_SH
          irradiance = max(
            scene_EnvSH[0] +
              scene_EnvSH[1] * terrainNormal.y +
              scene_EnvSH[2] * terrainNormal.z +
              scene_EnvSH[3] * terrainNormal.x +
              scene_EnvSH[4] * (terrainNormal.y * terrainNormal.x) +
              scene_EnvSH[5] * (terrainNormal.y * terrainNormal.z) +
              scene_EnvSH[6] * (3.0 * terrainNormal.z * terrainNormal.z - 1.0) +
              scene_EnvSH[7] * (terrainNormal.z * terrainNormal.x) +
              scene_EnvSH[8] * (terrainNormal.x * terrainNormal.x - terrainNormal.y * terrainNormal.y),
            vec3(0.0)
          );
        #endif
        return irradiance;
      }

      Varyings vert(Attributes attributes) {
        Varyings output;
        vec3 terrainWorldPosition = (renderer_ModelMat * vec4(attributes.POSITION, 1.0)).xyz;
        output.cameraDistance = length(terrainWorldPosition.xz - camera_Position.xz);
        output.worldNoiseDdxDdy = vec2(0.0);

        float lodScale = length(renderer_ModelMat[0].xyz);
        float vertexLerp = smoothstep(
          0.55,
          0.95,
          (output.cameraDistance / lodScale - material_MeshSize - 4.0) / (material_MeshSize - 2.0)
        );
        #ifdef TERRAIN_DEBUG
          output.geomorphFactor = vertexLerp;
        #endif
        vec2 vertexFract = fract(attributes.POSITION.xz * 0.5) * 2.0;
        vec2 shift;
        if (lodScale < vertexSpacing() + 0.000001) {
          float alternating = round(
            fract(round(mod(terrainWorldPosition.z * vertexDensity(), 4.0))) *
            round(mod(terrainWorldPosition.x * vertexDensity(), 4.0)) * 0.25
          );
          shift = mix(vertexFract, vec2(vertexFract.x, -vertexFract.y), alternating);
        } else {
          shift = vertexFract * round((fract(terrainWorldPosition.xz * 0.25 / lodScale) - 0.5) * 4.0);
        }

        vec2 startPosition = terrainWorldPosition.xz * vertexDensity();
        vec2 endPosition = (terrainWorldPosition.xz - shift * lodScale) * vertexDensity();
        terrainWorldPosition.xz -= shift * lodScale * vertexLerp;

        ivec4 startIndex = getIndexCoord(startPosition, 1);
        uint control = fetchControl(startIndex);
        bool resolveHeight = true;
        bool vertexRenderable = true;
        #ifdef TERRAIN_DEBUG
        if (startIndex.z < 0 && (material_DebugView == 2 || material_DebugView == 10)) {
          terrainWorldPosition.y = 0.0;
          resolveHeight = false;
        } else if ((startIndex.z < 0 && material_BackgroundMode == 0) ||
                   (decodeHole(control) && material_DebugView != 9)) {
          vertexRenderable = false;
          resolveHeight = false;
        }
        #else
        if ((startIndex.z < 0 && material_BackgroundMode == 0) || decodeHole(control)) {
          vertexRenderable = false;
          resolveHeight = false;
        }
        #endif
        if (resolveHeight) {
          ivec4 endIndex = getIndexCoord(endPosition, 1);
          float height = mix(fetchHeight(startIndex), fetchHeight(endIndex), vertexLerp);
          if (material_BackgroundMode == 2) {
            vec2 noiseUvA = startPosition * regionTexelSize() + vec2(0.5 * regionTexelSize());
            vec2 noiseUvB = endPosition * regionTexelSize() + vec2(0.5 * regionTexelSize());
            float noiseHeight = mix(
              getWorldNoiseHeight(noiseUvA, output.cameraDistance),
              getWorldNoiseHeight(noiseUvB, output.cameraDistance),
              vertexLerp
            );
            float noiseU = mix(
              getWorldNoiseHeight(noiseUvA + vec2(regionTexelSize(), 0.0), output.cameraDistance),
              getWorldNoiseHeight(noiseUvB + vec2(regionTexelSize(), 0.0), output.cameraDistance),
              vertexLerp
            );
            float noiseV = mix(
              getWorldNoiseHeight(noiseUvA + vec2(0.0, regionTexelSize()), output.cameraDistance),
              getWorldNoiseHeight(noiseUvB + vec2(0.0, regionTexelSize()), output.cameraDistance),
              vertexLerp
            );
            output.worldNoiseDdxDdy = vec2(noiseHeight - noiseU, noiseHeight - noiseV);
            height += noiseHeight;
          }
          terrainWorldPosition.y = height;
        }

        output.renderable = vertexRenderable ? 1.0 : 0.0;
        output.worldPosition = terrainWorldPosition;
        output.terrainCoord = terrainWorldPosition.xz * vertexDensity();
        gl_Position = vertexRenderable
          ? camera_VPMat * vec4(terrainWorldPosition, 1.0)
          : vec4(2.0, 2.0, 2.0, 1.0);
        return output;
      }
