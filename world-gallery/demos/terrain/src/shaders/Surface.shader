Shader "Terrain/Surface" {
  SubShader "Default" {
    Pass "Forward" {
      Tags { pipelineStage = "Forward" }

      RenderQueueType renderQueueType;
      CullMode rasterStateCullMode;
      Bool depthWriteEnabled;

      DepthState = { WriteEnabled = depthWriteEnabled; }
      RasterState = { CullMode = rasterStateCullMode; }
      RenderQueueType = renderQueueType;

      struct Attributes {
        vec3 POSITION;
        vec3 NORMAL;
        #ifdef RENDERER_HAS_TANGENT
          vec4 TANGENT;
        #endif
        vec2 TEXCOORD_0;
        vec4 COLOR_0;
        #ifdef RENDERER_SURFACE_INSTANCED
          vec4 INSTANCE_POSITION_META;
          vec4 INSTANCE_ROTATION;
          vec4 INSTANCE_SCALE_WIND;
          vec4 INSTANCE_COLOR;
        #endif
      };

      struct Varyings {
        vec2 uv;
        vec3 worldPosition;
        vec3 worldNormal;
        vec4 worldTangent;
        vec4 instanceColor;
        vec3 localPosition;
        float windDisplacementWeight;
        #ifdef RENDERER_SURFACE_PACKED_META
          float instanceLodFade;
        #endif
        vec3 positionVS;
        vec4 positionCS;
        #if defined(SCENE_USE_PROBE_VOLUME) && defined(SCENE_PROBE_VOLUME_PER_VERTEX)
          vec3 probeIrradiance;
          float probeWeight;
        #endif
      };

      #include "ShaderLibrary/Common/Common.glsl"
      #include "ShaderLibrary/Common/Transform.glsl"
      #include "ShaderLibrary/Common/Normal.glsl"
      #include "ShaderLibrary/Common/Fog.glsl"
      #include "ShaderLibrary/Shadow/Shadow.glsl"
      #include "ShaderLibrary/Lighting/Light.glsl"
      #include "ShaderLibrary/PBR/LightDirectPBR.glsl"
      #include "ShaderLibrary/PBR/LightIndirectPBR.glsl"
      #include "Terrain/GrasslandsCloudShadow.glsl"

      sampler2D material_Albedo;
      sampler2D material_Normal;
      sampler2D material_MetallicSmoothness;
      sampler2D material_Occlusion;
      sampler2D material_LodDither;
      #ifdef MATERIAL_SURFACE_COVERAGE
        sampler2D material_CoverageAlbedo;
        sampler2D material_CoverageNormal;
        sampler2D material_CoverageMetallicSmoothness;
        sampler2D material_CoverageMask;
      #endif
      vec4 material_BaseColor;
      vec4 material_SecondColor;
      float material_AlphaCutoff;
      float material_Metallic;
      float material_Roughness;
      float material_OcclusionStrength;
      float material_NormalScale;
      #ifdef MATERIAL_SURFACE_COVERAGE
        vec4 material_CoverageColor;
        float material_CoverageTiling;
        float material_CoverageNormalScale;
        float material_CoverageMetallic;
        float material_CoverageRoughness;
        int material_CoverageSmoothnessSource;
        int material_CoverageOverlayMethod;
        float material_CoverageOffset;
        float material_CoverageBalance;
        float material_CoverageMaskContrast;
        float material_CoverageNormalBlending;
        vec2 material_CoverageMaskTiling;
      #endif
      float material_Time;
      float material_WindForce;
      float material_WindWavesScale;
      float material_WindFlowDensity;
      int material_WindBaseLock;
      int material_WindBaseLockUvInverted;
      int material_WindSupported;
      int material_WindEnabled;
      vec3 material_WindDirection;
      float material_GlobalWindForce;
      float material_GlobalWavesScale;
      float material_GlobalFlowDensity;
      int material_ColorVariationEnabled;
      int material_ColorVariationMode;
      float material_ColorNoiseScale;
      float material_ColorOffset;
      float material_ColorFade;
      float material_LightingFlatness;
      float material_Translucency;
      vec3 material_TranslucencyColor;
      int material_TranslucencyModel;
      float material_FadeDistance;
      float material_FadeFalloff;
      vec3 renderer_SurfaceLocalPosition;
      vec4 renderer_SurfaceLocalRotation;
      vec3 renderer_SurfaceLocalScale;
      float renderer_SurfaceLodFade;
      int renderer_SurfaceLodFadeEnabled;
      vec3 renderer_SurfaceCategoryDebugColor;
      vec3 renderer_SurfaceCellDebugColor;
      vec3 renderer_SurfaceTint;
      float renderer_SurfaceScale;
      #ifdef RENDERER_SURFACE_FINE_CULL
        float renderer_SurfaceFineCullDistance;
        float renderer_SurfaceFineCullRadius;
      #endif
      float renderer_SurfaceWorldCellSize;
      int material_DebugView;
      #ifdef RENDERER_SURFACE_WORLD_NOISE
        highp usampler2D material_RegionMap;
        vec4 material_TerrainParams;
        int material_RegionMapSize;
        float material_WorldNoiseRegionBlend;
        int material_WorldNoiseMaxOctaves;
        int material_WorldNoiseMinOctaves;
        float material_WorldNoiseLodDistance;
        float material_WorldNoiseScale;
        float material_WorldNoiseHeight;
        vec3 material_WorldNoiseOffset;

        float regionSize() { return material_TerrainParams.x; }
        float regionTexelSize() { return material_TerrainParams.y; }
        float vertexDensity() { return material_TerrainParams.w; }
        #include "Terrain/TerrainWorldNoise.glsl"
      #endif

      VertexShader = vert;
      FragmentShader = frag;

      vec3 mod289(vec3 value) {
        return value - floor(value * (1.0 / 289.0)) * 289.0;
      }

      vec4 mod289(vec4 value) {
        return value - floor(value * (1.0 / 289.0)) * 289.0;
      }

      vec2 mod289(vec2 value) {
        return value - floor(value * (1.0 / 289.0)) * 289.0;
      }

      vec4 permute(vec4 value) {
        return mod289(((value * 34.0) + 1.0) * value);
      }

      vec3 permute(vec3 value) {
        return mod289(((value * 34.0) + 1.0) * value);
      }

      vec4 taylorInvSqrt(vec4 value) {
        return 1.79284291400159 - 0.85373472095314 * value;
      }

      float surfaceNoise3D(vec3 value) {
        const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
        const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
        vec3 cell = floor(value + dot(value, C.yyy));
        vec3 x0 = value - cell + dot(cell, C.xxx);
        vec3 stepOrder = step(x0.yzx, x0.xyz);
        vec3 inverseOrder = 1.0 - stepOrder;
        vec3 i1 = min(stepOrder.xyz, inverseOrder.zxy);
        vec3 i2 = max(stepOrder.xyz, inverseOrder.zxy);
        vec3 x1 = x0 - i1 + C.xxx;
        vec3 x2 = x0 - i2 + C.yyy;
        vec3 x3 = x0 - D.yyy;
        cell = mod289(cell);
        vec4 p = permute(
          permute(
            permute(cell.z + vec4(0.0, i1.z, i2.z, 1.0)) +
            cell.y + vec4(0.0, i1.y, i2.y, 1.0)
          ) +
          cell.x + vec4(0.0, i1.x, i2.x, 1.0)
        );
        float n = 1.0 / 7.0;
        vec3 ns = n * D.wyz - D.xzx;
        vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
        vec4 x_ = floor(j * ns.z);
        vec4 y_ = floor(j - 7.0 * x_);
        vec4 x = x_ * ns.x + ns.yyyy;
        vec4 y = y_ * ns.x + ns.yyyy;
        vec4 h = 1.0 - abs(x) - abs(y);
        vec4 b0 = vec4(x.xy, y.xy);
        vec4 b1 = vec4(x.zw, y.zw);
        vec4 s0 = floor(b0) * 2.0 + 1.0;
        vec4 s1 = floor(b1) * 2.0 + 1.0;
        vec4 sh = -step(h, vec4(0.0));
        vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
        vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
        vec3 g0 = vec3(a0.xy, h.x);
        vec3 g1 = vec3(a0.zw, h.y);
        vec3 g2 = vec3(a1.xy, h.z);
        vec3 g3 = vec3(a1.zw, h.w);
        vec4 norm = taylorInvSqrt(vec4(dot(g0, g0), dot(g1, g1), dot(g2, g2), dot(g3, g3)));
        g0 *= norm.x;
        g1 *= norm.y;
        g2 *= norm.z;
        g3 *= norm.w;
        vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
        m *= m;
        return 42.0 * dot(m * m, vec4(dot(x0, g0), dot(x1, g1), dot(x2, g2), dot(x3, g3)));
      }

      float surfaceNoise2D(vec2 value) {
        const vec4 C = vec4(
          0.211324865405187,
          0.366025403784439,
          -0.577350269189626,
          0.024390243902439
        );
        vec2 cell = floor(value + dot(value, C.yy));
        vec2 x0 = value - cell + dot(cell, C.xx);
        vec2 i1 = x0.x > x0.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
        vec4 x12 = x0.xyxy + C.xxzz;
        x12.xy -= i1;
        cell = mod289(cell);
        vec3 p = permute(
          permute(cell.y + vec3(0.0, i1.y, 1.0)) +
          cell.x + vec3(0.0, i1.x, 1.0)
        );
        vec3 m = max(
          0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)),
          0.0
        );
        m *= m;
        m *= m;
        vec3 x = 2.0 * fract(p * C.www) - 1.0;
        vec3 h = abs(x) - 0.5;
        vec3 ox = floor(x + 0.5);
        vec3 a0 = x - ox;
        m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
        vec3 gradient;
        gradient.x = a0.x * x0.x + h.x * x0.y;
        gradient.yz = a0.yz * x12.xz + h.yz * x12.yw;
        return 130.0 * dot(m, gradient);
      }

      vec3 rotateByQuaternion(vec3 value, vec4 rotation) {
        return value + 2.0 * cross(rotation.xyz, cross(rotation.xyz, value) + rotation.w * value);
      }

      void billboardBasis(out vec3 right, out vec3 up, out vec3 forward) {
        right = normalize(vec3(camera_ViewMat[0][0], camera_ViewMat[1][0], camera_ViewMat[2][0]));
        up = vec3(0.0, 1.0, 0.0);
        forward = -normalize(vec3(camera_ViewMat[0][2], camera_ViewMat[1][2], camera_ViewMat[2][2]));
      }

      float vertexWindWeight(Attributes attributes) {
        #ifdef RENDERER_ENABLE_VERTEXCOLOR
          return attributes.COLOR_0.r;
        #else
          return 1.0;
        #endif
      }

      float effectiveWindWeight(Attributes attributes) {
        if (material_WindSupported == 0) return 0.0;
        float baseUv = material_WindBaseLockUvInverted != 0
          ? 1.0 - attributes.TEXCOORD_0.y
          : attributes.TEXCOORD_0.y;
        float rootLock = material_WindBaseLock != 0
          ? pow(clamp(baseUv, 0.0, 1.0), 1.5)
          : 1.0;
        return rootLock * vertexWindWeight(attributes);
      }

      vec3 displacedWorldPosition(
        Attributes attributes,
        out vec3 worldNormal,
        out vec4 worldTangent,
        out float surfaceWindWeight
      ) {
        vec3 worldPosition;
        vec3 fadeAnchor;
        float windPhase = 0.0;
        #ifdef RENDERER_SURFACE_INSTANCED
          vec3 prototypePosition = renderer_SurfaceLocalPosition +
            rotateByQuaternion(attributes.POSITION * renderer_SurfaceLocalScale, renderer_SurfaceLocalRotation);
          vec3 scaledPosition = prototypePosition * attributes.INSTANCE_SCALE_WIND.xyz * renderer_SurfaceScale;
          #ifdef RENDERER_SURFACE_BILLBOARD
            vec3 billboardRight;
            vec3 billboardUp;
            vec3 billboardForward;
            billboardBasis(billboardRight, billboardUp, billboardForward);
            vec3 localNormal = normalize(
              attributes.NORMAL / max(abs(renderer_SurfaceLocalScale * attributes.INSTANCE_SCALE_WIND.xyz), vec3(0.0001))
            );
            worldPosition = attributes.INSTANCE_POSITION_META.xyz +
              billboardRight * scaledPosition.x +
              billboardUp * scaledPosition.y +
              billboardForward * scaledPosition.z;
            worldNormal = normalize(
              billboardRight * localNormal.x +
              billboardUp * localNormal.y +
              billboardForward * localNormal.z
            );
            #ifdef RENDERER_HAS_TANGENT
              vec3 localTangent = normalize(
                attributes.TANGENT.xyz * renderer_SurfaceLocalScale * attributes.INSTANCE_SCALE_WIND.xyz
              );
              worldTangent = vec4(
                normalize(
                  billboardRight * localTangent.x +
                  billboardUp * localTangent.y +
                  billboardForward * localTangent.z
                ),
                attributes.TANGENT.w
              );
            #else
              worldTangent = vec4(0.0, 0.0, 0.0, 1.0);
            #endif
          #else
            vec3 localNormal = normalize(
              rotateByQuaternion(
                attributes.NORMAL / max(abs(renderer_SurfaceLocalScale), vec3(0.0001)),
                renderer_SurfaceLocalRotation
              ) / max(abs(attributes.INSTANCE_SCALE_WIND.xyz), vec3(0.0001))
            );
            localNormal = normalize(mix(localNormal, vec3(0.0, 1.0, 0.0), material_LightingFlatness));
            worldPosition = attributes.INSTANCE_POSITION_META.xyz +
              rotateByQuaternion(scaledPosition, attributes.INSTANCE_ROTATION);
            worldNormal = normalize(rotateByQuaternion(localNormal, attributes.INSTANCE_ROTATION));
            #ifdef RENDERER_HAS_TANGENT
              vec3 localTangent = normalize(
                rotateByQuaternion(
                  attributes.TANGENT.xyz * renderer_SurfaceLocalScale,
                  renderer_SurfaceLocalRotation
                ) * attributes.INSTANCE_SCALE_WIND.xyz
              );
              worldTangent = vec4(
                normalize(rotateByQuaternion(localTangent, attributes.INSTANCE_ROTATION)),
                attributes.TANGENT.w
              );
            #else
              worldTangent = vec4(0.0, 0.0, 0.0, 1.0);
            #endif
          #endif
          fadeAnchor = attributes.INSTANCE_POSITION_META.xyz;
          windPhase = attributes.INSTANCE_SCALE_WIND.w;
        #else
          worldPosition = (renderer_ModelMat * vec4(attributes.POSITION, 1.0)).xyz;
          worldNormal = normalize((renderer_NormalMat * vec4(attributes.NORMAL, 0.0)).xyz);
          worldNormal = normalize(mix(worldNormal, vec3(0.0, 1.0, 0.0), material_LightingFlatness));
          #ifdef RENDERER_HAS_TANGENT
            worldTangent = vec4(
              normalize((renderer_ModelMat * vec4(attributes.TANGENT.xyz, 0.0)).xyz),
              attributes.TANGENT.w
            );
          #else
            worldTangent = vec4(0.0, 0.0, 0.0, 1.0);
          #endif
          fadeAnchor = (renderer_ModelMat * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
        #endif
        #ifdef RENDERER_SURFACE_WORLD_NOISE
          float groundHeight = getWorldNoiseHeightAtWorldPosition(
            worldPosition.xz,
            length(worldPosition.xz - camera_Position.xz)
          );
          worldPosition.y += groundHeight;
          fadeAnchor.y += groundHeight;
        #endif

        surfaceWindWeight = effectiveWindWeight(attributes);
        if (material_WindEnabled != 0) {
          float timeOffset = material_Time * material_GlobalWindForce * material_WindForce * 5.0 +
            windPhase;
          float frequency = max((1.0 - material_WindWavesScale) * material_GlobalWavesScale, 0.00001);
          float noise = surfaceNoise3D((worldPosition + vec3(timeOffset)) * frequency) * 0.5 + 0.5;
          float flow = pow(max(noise, 0.00001), material_WindFlowDensity * material_GlobalFlowDensity) * 0.01;
          worldPosition += material_WindDirection *
            (flow * surfaceWindWeight * material_WindForce * 100.0 * material_GlobalWindForce);
        }

        if (material_FadeDistance > 0.0) {
          float eyeDepth = -(camera_ViewMat * vec4(worldPosition, 1.0)).z;
          float cameraDepthFade = (
            eyeDepth - camera_ProjectionParams.y - material_FadeDistance
          ) / 5.0;
          float fadeMask = clamp(
            mix(1.0 - cameraDepthFade, cameraDepthFade, material_FadeFalloff * 0.5),
            0.0,
            1.0
          );
          worldPosition = mix(fadeAnchor, worldPosition, fadeMask);
        }
        return worldPosition;
      }

      Varyings vert(Attributes attributes) {
        Varyings output;
        vec3 surfaceNormal;
        vec4 surfaceTangent;
        float surfaceWindWeight;
        vec3 surfacePosition = displacedWorldPosition(
          attributes,
          surfaceNormal,
          surfaceTangent,
          surfaceWindWeight
        );
        output.uv = attributes.TEXCOORD_0;
        output.worldPosition = surfacePosition;
        output.worldNormal = surfaceNormal;
        output.worldTangent = surfaceTangent;
        #ifdef RENDERER_SURFACE_INSTANCED
          output.instanceColor = attributes.INSTANCE_COLOR;
          #ifdef RENDERER_SURFACE_PACKED_META
            float packedLodFade = mod(attributes.INSTANCE_POSITION_META.w, 65536.0);
            output.instanceLodFade = packedLodFade * (1.0 / 32767.5) - 1.0;
          #endif
          if (material_DebugView == 4) {
            #ifdef RENDERER_SURFACE_PACKED_META
              output.windDisplacementWeight = floor(attributes.INSTANCE_POSITION_META.w * (1.0 / 65536.0)) * (1.0 / 255.0);
            #else
              output.windDisplacementWeight = attributes.INSTANCE_POSITION_META.w;
            #endif
          } else {
            output.windDisplacementWeight = surfaceWindWeight;
          }
        #else
          output.instanceColor = vec4(1.0);
          output.windDisplacementWeight = surfaceWindWeight;
        #endif
        output.localPosition = attributes.POSITION;
        output.positionVS = (camera_ViewMat * vec4(surfacePosition, 1.0)).xyz;
        output.positionCS = camera_VPMat * vec4(surfacePosition, 1.0);
        #if defined(SCENE_USE_PROBE_VOLUME) && defined(SCENE_PROBE_VOLUME_PER_VERTEX)
          output.probeIrradiance = vec3(0.0);
          output.probeWeight = 0.0;
        #endif
        gl_Position = output.positionCS;
        #ifdef RENDERER_SURFACE_FINE_CULL
          float instanceRadius =
            renderer_SurfaceFineCullRadius *
            max(
              abs(attributes.INSTANCE_SCALE_WIND.x),
              max(abs(attributes.INSTANCE_SCALE_WIND.y), abs(attributes.INSTANCE_SCALE_WIND.z))
            ) *
            renderer_SurfaceScale;
          float distanceLimit = renderer_SurfaceFineCullDistance + instanceRadius;
          vec3 cameraDelta = attributes.INSTANCE_POSITION_META.xyz - camera_Position;
          if (dot(cameraDelta, cameraDelta) > distanceLimit * distanceLimit) {
            gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
          }
        #endif
        return output;
      }

      void applyLodCrossfade() {
        #ifdef RENDERER_SURFACE_PACKED_META
          float threshold = texture2D(material_LodDither, gl_FragCoord.xy * (1.0 / 64.0)).r;
          float signedThreshold = varyings.instanceLodFade >= 0.0 ? threshold : -threshold;
          if (varyings.instanceLodFade - signedThreshold < 0.0) discard;
        #else
          if (renderer_SurfaceLodFadeEnabled != 0) {
            float threshold = texture2D(material_LodDither, gl_FragCoord.xy * (1.0 / 64.0)).r;
            float signedThreshold = renderer_SurfaceLodFade >= 0.0 ? threshold : -threshold;
            if (renderer_SurfaceLodFade - signedThreshold < 0.0) discard;
          }
        #endif
      }

      void surfaceBasis(Varyings varyings, out vec3 normal, out vec3 tangent, out vec3 bitangent) {
        normal = normalize(varyings.worldNormal);
        #ifdef RENDERER_HAS_TANGENT
          tangent = normalize(varyings.worldTangent.xyz - normal * dot(normal, varyings.worldTangent.xyz));
          bitangent = normalize(cross(normal, tangent)) * varyings.worldTangent.w;
        #else
          mat3 derivativeBasis = getTBNByDerivatives(
            varyings.uv,
            normal,
            varyings.worldPosition,
            gl_FrontFacing
          );
          tangent = derivativeBasis[0];
          bitangent = derivativeBasis[1];
        #endif
      }

      vec3 unpackNormal(vec4 packedNormal, float scale) {
        vec3 normal = packedNormal.xyz * 2.0 - 1.0;
        normal.xy *= scale;
        return normal;
      }

      vec3 tangentToWorld(vec3 tangentNormal, vec3 normal, vec3 tangent, vec3 bitangent) {
        return normalize(
          tangent * tangentNormal.x +
          bitangent * tangentNormal.y +
          normal * tangentNormal.z
        );
      }

      #ifdef MATERIAL_SURFACE_COVERAGE
        vec3 triplanarWeights(vec3 worldNormal) {
          vec3 weights = pow(abs(worldNormal), vec3(10.0));
          return weights / (weights.x + weights.y + weights.z + 0.00001);
        }

        vec4 sampleTriplanarColor(
          sampler2D textureMap,
          vec3 worldPosition,
          vec3 worldNormal,
          float tiling
        ) {
          vec3 weights = triplanarWeights(worldNormal);
          vec3 normalSign = sign(worldNormal);
          vec4 xProjection = texture2DSRGB(
            textureMap,
            tiling * worldPosition.zy * vec2(normalSign.x, 1.0)
          );
          vec4 yProjection = texture2DSRGB(
            textureMap,
            tiling * worldPosition.xz * vec2(normalSign.y, 1.0)
          );
          vec4 zProjection = texture2DSRGB(
            textureMap,
            tiling * worldPosition.xy * vec2(-normalSign.z, 1.0)
          );
          return xProjection * weights.x + yProjection * weights.y + zProjection * weights.z;
        }

        vec4 sampleTriplanarLinear(
          sampler2D textureMap,
          vec3 worldPosition,
          vec3 worldNormal,
          float tiling
        ) {
          vec3 weights = triplanarWeights(worldNormal);
          vec3 normalSign = sign(worldNormal);
          vec4 xProjection = texture2D(
            textureMap,
            tiling * worldPosition.zy * vec2(normalSign.x, 1.0)
          );
          vec4 yProjection = texture2D(
            textureMap,
            tiling * worldPosition.xz * vec2(normalSign.y, 1.0)
          );
          vec4 zProjection = texture2D(
            textureMap,
            tiling * worldPosition.xy * vec2(-normalSign.z, 1.0)
          );
          return xProjection * weights.x + yProjection * weights.y + zProjection * weights.z;
        }

        vec3 sampleTriplanarNormal(vec3 worldPosition, vec3 worldNormal) {
          vec3 weights = triplanarWeights(worldNormal);
          vec3 normalSign = sign(worldNormal);
          vec3 xSample = unpackNormal(
            texture2D(
              material_CoverageNormal,
              material_CoverageTiling * worldPosition.zy * vec2(normalSign.x, 1.0)
            ),
            material_CoverageNormalScale
          );
          vec3 ySample = unpackNormal(
            texture2D(
              material_CoverageNormal,
              material_CoverageTiling * worldPosition.xz * vec2(normalSign.y, 1.0)
            ),
            material_CoverageNormalScale
          );
          vec3 zSample = unpackNormal(
            texture2D(
              material_CoverageNormal,
              material_CoverageTiling * worldPosition.xy * vec2(-normalSign.z, 1.0)
            ),
            material_CoverageNormalScale
          );
          vec3 xProjection = vec3(
            xSample.xy * vec2(normalSign.x, 1.0) + worldNormal.zy,
            worldNormal.x
          ).zyx;
          vec3 yProjection = vec3(
            ySample.xy * vec2(normalSign.y, 1.0) + worldNormal.xz,
            worldNormal.y
          ).xzy;
          vec3 zProjection = vec3(
            zSample.xy * vec2(-normalSign.z, 1.0) + worldNormal.xy,
            worldNormal.z
          );
          return normalize(
            xProjection * weights.x +
            yProjection * weights.y +
            zProjection * weights.z
          );
        }

        vec3 blendNormals(vec3 baseNormal, vec3 coverageNormal) {
          return normalize(vec3(
            baseNormal.xy * coverageNormal.z + coverageNormal.xy * baseNormal.z,
            baseNormal.z * coverageNormal.z
          ));
        }
      #endif

      vec3 normalFromTexture(Varyings varyings) {
        vec3 normal;
        vec3 tangent;
        vec3 bitangent;
        surfaceBasis(varyings, normal, tangent, bitangent);
        return tangentToWorld(
          unpackNormal(texture2D(material_Normal, varyings.uv), material_NormalScale),
          normal,
          tangent,
          bitangent
        );
      }

      vec3 shadeSurface(
        Varyings varyings,
        vec3 albedo,
        vec3 normal,
        float metallic,
        float roughness,
        float occlusion
      ) {
        vec3 viewDirection = normalize(camera_Position - varyings.worldPosition);
        float shadowAttenuation = 1.0;
        #if defined(SCENE_DIRECT_LIGHT_COUNT) && defined(NEED_CALCULATE_SHADOWS)
          shadowAttenuation = sampleShadowMap(
            varyings.worldPosition,
            getShadowCoord(varyings.worldPosition)
          );
        #endif
        if (
          material_TranslucencyModel == 1 &&
          material_Translucency > 0.0
        ) {
          #ifdef SCENE_DIRECT_LIGHT_COUNT
            if (!isRendererCulledByLight(renderer_Layer.xy, scene_DirectLightCullingMask[0])) {
              DirectLight directLight;
              #ifdef GRAPHICS_API_WEBGL2
                directLight = getDirectLight(0);
              #else
                directLight.color = scene_DirectLightColor[0];
                directLight.direction = scene_DirectLightDirection[0];
              #endif
              float lightIntensity = max(
                max(directLight.color.r, directLight.color.g),
                directLight.color.b
              );
              vec3 normalizedLightColor = directLight.color / max(lightIntensity, 0.00001);
              float backLight = -dot(viewDirection, -directLight.direction) - 0.3;
              vec3 transmission = backLight * shadowAttenuation *
                normalizedLightColor * material_TranslucencyColor * material_Translucency;
              albedo += clamp(transmission, vec3(0.0), vec3(1.0));
            }
          #endif
        }

        SurfaceData surfaceData;
        surfaceData.albedoColor = albedo;
        surfaceData.emissiveColor = vec3(0.0);
        surfaceData.metallic = metallic;
        surfaceData.roughness = roughness;
        surfaceData.ambientOcclusion = mix(1.0, occlusion, material_OcclusionStrength);
        surfaceData.opacity = 1.0;
        surfaceData.IOR = 1.5;
        surfaceData.position = varyings.worldPosition;
        surfaceData.positionCS = varyings.positionCS;
        surfaceData.normal = normal;
        surfaceData.viewDir = viewDirection;
        surfaceData.dotNV = saturate(dot(surfaceData.normal, surfaceData.viewDir));
        surfaceData.specularIntensity = 1.0;
        surfaceData.specularColor = vec3(1.0);

        BSDFData bsdfData;
        initBSDFData(surfaceData, bsdfData);
        shadowAttenuation *= grasslandsCloudShadow(varyings.worldPosition);

        vec3 diffuse = vec3(0.0);
        vec3 specular = vec3(0.0);
        evaluateDirectRadiance(
          varyings,
          surfaceData,
          bsdfData,
          shadowAttenuation,
          diffuse,
          specular
        );
        evaluateIBL(varyings, surfaceData, bsdfData, diffuse, specular);

        return diffuse + specular;
      }

      void frag(Varyings varyings) {
        applyLodCrossfade();
        vec4 textureColor = texture2DSRGB(material_Albedo, varyings.uv);
        vec4 metallicSmoothness = texture2D(material_MetallicSmoothness, varyings.uv);
        float occlusion = texture2D(material_Occlusion, varyings.uv).g;
        vec3 surfaceColor = material_BaseColor.rgb;
        if (material_ColorVariationEnabled != 0) {
          float overlay;
          if (material_ColorVariationMode == 0) {
            overlay = surfaceNoise2D(varyings.worldPosition.xz * material_ColorNoiseScale) *
              0.5 + 0.5;
          } else if (material_ColorVariationMode == 1) {
            overlay = surfaceNoise3D(varyings.worldPosition * material_ColorNoiseScale) * 0.5 + 0.5;
          } else if (material_ColorVariationMode == 2) {
            overlay = varyings.localPosition.y;
          } else {
            // Restore the source mesh orientation for authored gradients after glTF V conversion.
            overlay = 1.0 - varyings.uv.y;
          }
          float shifted = overlay + (1.0 - material_ColorOffset);
          float blend = clamp(
            mix(shifted, 1.0 - shifted, material_ColorFade + 0.5),
            0.0,
            1.0
          );
          surfaceColor = mix(material_BaseColor.rgb, material_SecondColor.rgb, blend);
        }
        vec4 baseColor = vec4(
          textureColor.rgb * surfaceColor * varyings.instanceColor.rgb * renderer_SurfaceTint,
          textureColor.a
        );
        if (baseColor.a < material_AlphaCutoff) discard;

        vec3 normal = normalFromTexture(varyings);
        float metallic = metallicSmoothness.r * material_Metallic;
        float roughness = 1.0 - metallicSmoothness.a * (1.0 - material_Roughness);
        #ifdef MATERIAL_SURFACE_COVERAGE
          vec3 vertexNormal;
          vec3 tangent;
          vec3 bitangent;
          surfaceBasis(varyings, vertexNormal, tangent, bitangent);
          float overlayNormal = mix(
            normal.y,
            vertexNormal.y,
            float(material_CoverageOverlayMethod)
          );
          float offsetNormal = overlayNormal + (1.0 - material_CoverageOffset);
          float slopeCoverage = mix(
            offsetNormal,
            1.0 - offsetNormal,
            material_CoverageBalance
          );
          float maskSample = texture2D(
            material_CoverageMask,
            varyings.uv * material_CoverageMaskTiling
          ).g;
          float contrastMask = mix(
            1.0 - maskSample,
            maskSample,
            material_CoverageMaskContrast
          );
          float coverageMask = clamp(slopeCoverage * clamp(contrastMask, 0.0, 1.0), 0.0, 1.0);
          vec4 coverageColor = sampleTriplanarColor(
            material_CoverageAlbedo,
            varyings.worldPosition,
            vertexNormal,
            material_CoverageTiling
          );
          vec4 coverageMetallicSmoothness = sampleTriplanarLinear(
            material_CoverageMetallicSmoothness,
            varyings.worldPosition,
            vertexNormal,
            material_CoverageTiling
          );
          baseColor.rgb = mix(
            baseColor.rgb,
            material_CoverageColor.rgb * coverageColor.rgb * varyings.instanceColor.rgb * renderer_SurfaceTint,
            coverageMask
          );
          float coverageSmoothness = mix(
            coverageMetallicSmoothness.a,
            coverageColor.a,
            float(material_CoverageSmoothnessSource)
          ) * (1.0 - material_CoverageRoughness);
          metallic = mix(
            metallic,
            coverageMetallicSmoothness.r * material_CoverageMetallic,
            coverageMask
          );
          roughness = 1.0 - mix(1.0 - roughness, coverageSmoothness, coverageMask);

          vec3 baseTangentNormal = unpackNormal(
            texture2D(material_Normal, varyings.uv),
            material_NormalScale
          );
          vec3 coverageWorldNormal = sampleTriplanarNormal(varyings.worldPosition, vertexNormal);
          vec3 coverageTangentNormal = vec3(
            dot(tangent, coverageWorldNormal),
            dot(bitangent, coverageWorldNormal),
            dot(vertexNormal, coverageWorldNormal)
          );
          vec3 blendedTangentNormal = mix(
            blendNormals(baseTangentNormal, coverageTangentNormal),
            coverageTangentNormal,
            1.0 - material_CoverageNormalBlending
          );
          normal = tangentToWorld(
            normalize(mix(baseTangentNormal, blendedTangentNormal, coverageMask)),
            vertexNormal,
            tangent,
            bitangent
          );
        #endif
        vec4 outputColor;
        if (material_DebugView == 1) {
          outputColor = vec4(normal * 0.5 + 0.5, 1.0);
        } else if (material_DebugView == 2) {
          outputColor = vec4(
            mix(
              vec3(0.03, 0.15, 1.0),
              vec3(1.0, 0.75, 0.02),
              clamp(varyings.windDisplacementWeight, 0.0, 1.0)
            ),
            1.0
          );
        } else if (material_DebugView == 3) {
          outputColor = vec4(renderer_SurfaceCategoryDebugColor, 1.0);
        } else if (material_DebugView == 4) {
          if (renderer_SurfaceWorldCellSize > 0.0) {
            vec2 cell = floor(varyings.worldPosition.xz / renderer_SurfaceWorldCellSize);
            float hue = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
            outputColor = vec4(
              clamp(abs(hue * 6.0 - 3.0) - 1.0, 0.0, 1.0),
              clamp(2.0 - abs(hue * 6.0 - 2.0), 0.0, 1.0),
              clamp(2.0 - abs(hue * 6.0 - 4.0), 0.0, 1.0),
              1.0
            );
          } else {
            #ifdef RENDERER_SURFACE_INSTANCED
              float hue = varyings.windDisplacementWeight;
              outputColor = vec4(
                0.35 + clamp(abs(hue * 6.0 - 3.0) - 1.0, 0.0, 1.0) * 0.65,
                0.35 + clamp(2.0 - abs(hue * 6.0 - 2.0), 0.0, 1.0) * 0.65,
                0.35 + clamp(2.0 - abs(hue * 6.0 - 4.0), 0.0, 1.0) * 0.65,
                1.0
              );
            #else
              outputColor = vec4(renderer_SurfaceCellDebugColor, 1.0);
            #endif
          }
        } else if (material_DebugView == 5) {
          outputColor = vec4(vec3(varyings.instanceColor.a), 1.0);
        } else {
          outputColor = vec4(
            shadeSurface(varyings, baseColor.rgb, normal, metallic, roughness, occlusion),
            baseColor.a
          );
          #if SCENE_FOG_MODE != 0
            outputColor = fog(outputColor, varyings.positionVS);
          #endif
        }
        gl_FragColor = outputColor;
      }
    }

    Pass "ShadowCaster" {
      Tags { pipelineStage = "ShadowCaster" }
      RenderQueueType material_ShadowCasterRenderQueue;
      RenderQueueType = material_ShadowCasterRenderQueue;
      CullMode rasterStateCullMode;
      RasterState = { CullMode = rasterStateCullMode; }

      VertexShader = vert;
      FragmentShader = frag;

      #define SURFACE_DEPTH_SHADOW_CASTER
      #include "Terrain/SurfaceDepthPass.glsl"
      #undef SURFACE_DEPTH_SHADOW_CASTER
    }

    Pass "DepthPrimingOnly" {
      Tags { pipelineStage = "DepthPrimingOnly" }
      RenderQueueType material_DepthOnlyRenderQueue;
      RenderQueueType = material_DepthOnlyRenderQueue;
      CullMode rasterStateCullMode;
      RasterState = { CullMode = rasterStateCullMode; }

      VertexShader = vert;
      FragmentShader = frag;

      #include "Terrain/SurfaceDepthPass.glsl"
    }
  }
}
