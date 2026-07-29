      struct Attributes {
        vec3 POSITION;
        vec3 NORMAL;
        vec2 TEXCOORD_0;
        vec4 COLOR_0;
        #ifdef RENDERER_SURFACE_INSTANCED
          vec4 INSTANCE_POSITION_META;
          vec4 INSTANCE_ROTATION;
          vec4 INSTANCE_SCALE_WIND;
        #endif
      };

      struct Varyings {
        vec2 uv;
        #ifdef RENDERER_SURFACE_PACKED_META
          float instanceLodFade;
        #endif
      };

      #include "ShaderLibrary/Common/Common.glsl"
      #include "ShaderLibrary/Common/Transform.glsl"

      sampler2D material_Albedo;
      sampler2D material_LodDither;
      float material_AlphaCutoff;
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
      float material_FadeDistance;
      float material_FadeFalloff;
      vec3 renderer_SurfaceLocalPosition;
      vec4 renderer_SurfaceLocalRotation;
      vec3 renderer_SurfaceLocalScale;
      float renderer_SurfaceLodFade;
      int renderer_SurfaceLodFadeEnabled;
      vec2 scene_ShadowBias;
      vec3 scene_LightDirection;
      float renderer_SurfaceScale;
      #ifdef RENDERER_SURFACE_FINE_CULL
        float renderer_SurfaceFineCullDistance;
        float renderer_SurfaceFineCullRadius;
      #endif
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

      vec3 mod289(vec3 value) {
        return value - floor(value * (1.0 / 289.0)) * 289.0;
      }

      vec4 mod289(vec4 value) {
        return value - floor(value * (1.0 / 289.0)) * 289.0;
      }

      vec4 permute(vec4 value) {
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

      vec3 displacedWorldPosition(Attributes attributes, out vec3 worldNormal) {
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
          #else
            worldPosition = attributes.INSTANCE_POSITION_META.xyz +
              rotateByQuaternion(scaledPosition, attributes.INSTANCE_ROTATION);
            worldNormal = normalize(
              rotateByQuaternion(
                rotateByQuaternion(
                  attributes.NORMAL / max(abs(renderer_SurfaceLocalScale), vec3(0.0001)),
                  renderer_SurfaceLocalRotation
                ) / max(abs(attributes.INSTANCE_SCALE_WIND.xyz), vec3(0.0001)),
                attributes.INSTANCE_ROTATION
              )
            );
          #endif
          fadeAnchor = attributes.INSTANCE_POSITION_META.xyz;
          windPhase = attributes.INSTANCE_SCALE_WIND.w;
        #else
          worldPosition = (renderer_ModelMat * vec4(attributes.POSITION, 1.0)).xyz;
          worldNormal = normalize((renderer_NormalMat * vec4(attributes.NORMAL, 0.0)).xyz);
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
        if (material_WindEnabled != 0) {
          float timeOffset = material_Time * material_GlobalWindForce * material_WindForce * 5.0 +
            windPhase;
          float frequency = max((1.0 - material_WindWavesScale) * material_GlobalWavesScale, 0.00001);
          float noise = surfaceNoise3D((worldPosition + vec3(timeOffset)) * frequency) * 0.5 + 0.5;
          float flow = pow(max(noise, 0.00001), material_WindFlowDensity * material_GlobalFlowDensity) * 0.01;
          worldPosition += material_WindDirection *
            (flow * effectiveWindWeight(attributes) * material_WindForce * 100.0 * material_GlobalWindForce);
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
        vec3 worldNormal;
        vec3 worldPosition = displacedWorldPosition(attributes, worldNormal);
        #ifdef SURFACE_DEPTH_SHADOW_CASTER
          float invNdotL = 1.0 - clamp(dot(-scene_LightDirection, worldNormal), 0.0, 1.0);
          worldPosition -= scene_LightDirection * scene_ShadowBias.x;
          worldPosition += worldNormal * (invNdotL * scene_ShadowBias.y);
        #endif
        vec4 positionCS = camera_VPMat * vec4(worldPosition, 1.0);
        #ifdef SURFACE_DEPTH_SHADOW_CASTER
          positionCS.z = max(positionCS.z, -1.0);
        #endif
        gl_Position = positionCS;
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
        output.uv = attributes.TEXCOORD_0;
        #ifdef RENDERER_SURFACE_PACKED_META
          float packedLodFade = mod(attributes.INSTANCE_POSITION_META.w, 65536.0);
          output.instanceLodFade = packedLodFade * (1.0 / 32767.5) - 1.0;
        #endif
        return output;
      }

      #ifdef ENGINE_NO_DEPTH_TEXTURE
        vec4 packDepth(float depth) {
          const vec4 shift = vec4(1.0, 256.0, 65536.0, 16777216.0);
          const vec4 mask = vec4(1.0 / 256.0, 1.0 / 256.0, 1.0 / 256.0, 0.0);
          vec4 packed = fract(depth * shift);
          return packed - packed.gbaa * mask;
        }
      #endif

      void frag(Varyings varyings) {
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
        if (texture2D(material_Albedo, varyings.uv).a < material_AlphaCutoff) discard;
        #ifdef ENGINE_NO_DEPTH_TEXTURE
          gl_FragColor = packDepth(gl_FragCoord.z);
        #else
          gl_FragColor = vec4(0.0);
        #endif
      }
