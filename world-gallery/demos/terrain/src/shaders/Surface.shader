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
        vec4 TANGENT;
        vec2 TEXCOORD_0;
        vec4 COLOR_0;
        vec4 INSTANCE_POSITION_HASH;
        vec4 INSTANCE_ROTATION;
        vec4 INSTANCE_SCALE_WIND;
        vec4 INSTANCE_COLOR;
      };

      struct Varyings {
        vec2 uv;
        vec3 worldPosition;
        vec3 worldNormal;
        vec4 worldTangent;
        vec4 instanceColor;
        vec3 positionVS;
      };

      #include "ShaderLibrary/Common/Common.glsl"
      #include "ShaderLibrary/Common/Transform.glsl"
      #include "ShaderLibrary/Common/Fog.glsl"
      #include "ShaderLibrary/Shadow/Shadow.glsl"
      #include "ShaderLibrary/Lighting/Light.glsl"

      sampler2D material_Albedo;
      sampler2D material_Normal;
      vec4 material_BaseColor;
      vec4 material_SecondColor;
      float material_AlphaCutoff;
      float material_Roughness;
      float material_NormalScale;
      float material_Time;
      float material_WindForce;
      float material_WindWavesScale;
      float material_WindFlowDensity;
      int material_WindBaseLock;
      int material_WindEnabled;
      vec3 material_WindDirection;
      float material_GlobalWindForce;
      float material_GlobalWavesScale;
      float material_GlobalFlowDensity;
      int material_ColorVariationEnabled;
      float material_ColorNoiseScale;
      float material_ColorOffset;
      float material_ColorFade;
      float material_LightingFlatness;
      float material_Translucency;
      vec3 material_TranslucencyColor;
      float material_FadeDistance;
      float material_LodFade;
      int material_DebugView;

      VertexShader = vert;
      FragmentShader = frag;

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

      float windWeight(Attributes attributes) {
        #ifdef RENDERER_ENABLE_VERTEXCOLOR
          return attributes.COLOR_0.r;
        #else
          return 1.0;
        #endif
      }

      vec3 displacedWorldPosition(Attributes attributes, out vec3 worldNormal, out vec4 worldTangent) {
        vec3 scaledPosition = attributes.POSITION * attributes.INSTANCE_SCALE_WIND.xyz;
        vec3 localNormal = normalize(attributes.NORMAL / max(attributes.INSTANCE_SCALE_WIND.xyz, vec3(0.0001)));
        localNormal = normalize(mix(localNormal, vec3(0.0, 1.0, 0.0), material_LightingFlatness));
        vec3 localTangent = normalize(attributes.TANGENT.xyz * attributes.INSTANCE_SCALE_WIND.xyz);
        vec3 worldPosition = attributes.INSTANCE_POSITION_HASH.xyz +
          rotateByQuaternion(scaledPosition, attributes.INSTANCE_ROTATION);
        worldNormal = normalize(rotateByQuaternion(localNormal, attributes.INSTANCE_ROTATION));
        worldTangent = vec4(
          normalize(rotateByQuaternion(localTangent, attributes.INSTANCE_ROTATION)),
          attributes.TANGENT.w
        );

        if (material_WindEnabled != 0) {
          float timeOffset = material_Time * material_GlobalWindForce * material_WindForce * 5.0 +
            attributes.INSTANCE_SCALE_WIND.w;
          float frequency = max((1.0 - material_WindWavesScale) * material_GlobalWavesScale, 0.00001);
          float noise = surfaceNoise3D((worldPosition + vec3(timeOffset)) * frequency) * 0.5 + 0.5;
          float flow = pow(max(noise, 0.00001), material_WindFlowDensity * material_GlobalFlowDensity) * 0.01;
          float rootLock = material_WindBaseLock != 0 ? pow(max(attributes.TEXCOORD_0.y, 0.0), 1.5) : 1.0;
          worldPosition += material_WindDirection *
            (flow * rootLock * windWeight(attributes) * material_WindForce * 100.0 * material_GlobalWindForce);
        }

        if (material_FadeDistance > 0.0) {
          float cameraDistance = length(worldPosition - camera_Position);
          float fade = 1.0 - smoothstep(material_FadeDistance, material_FadeDistance + 5.0, cameraDistance);
          worldPosition = mix(attributes.INSTANCE_POSITION_HASH.xyz, worldPosition, fade);
        }
        return worldPosition;
      }

      vec3 diffuseIrradiance(vec3 normal) {
        vec3 irradiance = scene_EnvMapLight.diffuse * PI;
        #ifdef SCENE_USE_SH
          irradiance = max(
            scene_EnvSH[0] +
              scene_EnvSH[1] * normal.y +
              scene_EnvSH[2] * normal.z +
              scene_EnvSH[3] * normal.x +
              scene_EnvSH[4] * (normal.y * normal.x) +
              scene_EnvSH[5] * (normal.y * normal.z) +
              scene_EnvSH[6] * (3.0 * normal.z * normal.z - 1.0) +
              scene_EnvSH[7] * (normal.z * normal.x) +
              scene_EnvSH[8] * (normal.x * normal.x - normal.y * normal.y),
            vec3(0.0)
          );
        #endif
        return irradiance;
      }

      Varyings vert(Attributes attributes) {
        Varyings output;
        vec3 surfaceNormal;
        vec4 surfaceTangent;
        vec3 surfacePosition = displacedWorldPosition(attributes, surfaceNormal, surfaceTangent);
        output.uv = attributes.TEXCOORD_0;
        output.worldPosition = surfacePosition;
        output.worldNormal = surfaceNormal;
        output.worldTangent = surfaceTangent;
        output.instanceColor = attributes.INSTANCE_COLOR;
        output.positionVS = (renderer_MVMat * vec4(surfacePosition, 1.0)).xyz;
        gl_Position = camera_VPMat * vec4(surfacePosition, 1.0);
        return output;
      }

      vec3 normalFromTexture(Varyings varyings) {
        vec3 sampled = texture2D(material_Normal, varyings.uv).xyz * 2.0 - 1.0;
        sampled.xy *= material_NormalScale;
        vec3 normal = normalize(varyings.worldNormal);
        vec3 tangent = normalize(varyings.worldTangent.xyz - normal * dot(normal, varyings.worldTangent.xyz));
        vec3 bitangent = normalize(cross(normal, tangent)) * varyings.worldTangent.w;
        return normalize(tangent * sampled.x + bitangent * sampled.y + normal * sampled.z);
      }

      void frag(Varyings varyings) {
        vec4 textureColor = texture2DSRGB(material_Albedo, varyings.uv);
        vec4 baseColor = vec4(
          textureColor.rgb * material_BaseColor.rgb * varyings.instanceColor.rgb,
          textureColor.a
        );
        if (baseColor.a < material_AlphaCutoff) discard;

        if (material_ColorVariationEnabled != 0) {
          float noise = surfaceNoise3D(varyings.worldPosition * material_ColorNoiseScale) * 0.5 + 0.5;
          float width = max(abs(material_ColorFade), 0.0001);
          float blend = smoothstep(material_ColorOffset - width, material_ColorOffset + width, noise);
          baseColor.rgb *= mix(vec3(1.0), material_SecondColor.rgb, blend);
        }

        vec3 normal = normalFromTexture(varyings);
        vec4 outputColor;
        if (material_DebugView == 1) {
          outputColor = vec4(normal * 0.5 + 0.5, 1.0);
        } else {
          vec3 lighting = baseColor.rgb * diffuseIrradiance(normal) * scene_EnvMapLight.diffuseIntensity / PI;
          #ifdef SCENE_DIRECT_LIGHT_COUNT
            if (!isRendererCulledByLight(renderer_Layer.xy, scene_DirectLightCullingMask[0])) {
              DirectLight directLight = getDirectLight(0);
              vec3 lightDirection = -directLight.direction;
              float shadowAttenuation = 1.0;
              #ifdef NEED_CALCULATE_SHADOWS
                shadowAttenuation = sampleShadowMap(varyings.worldPosition, getShadowCoord(varyings.worldPosition));
              #endif
              vec3 viewDirection = normalize(camera_Position - varyings.worldPosition);
              vec3 halfDirection = normalize(lightDirection + viewDirection);
              float lambert = saturate(dot(normal, lightDirection));
              float gloss = max(1.0 - material_Roughness, 0.001);
              float specular = pow(saturate(dot(normal, halfDirection)), mix(4.0, 128.0, gloss));
              specular *= mix(0.01, 0.12, gloss);
              float backLight = pow(saturate(dot(-lightDirection, viewDirection)), 4.0) * material_Translucency;
              lighting += directLight.color * shadowAttenuation *
                (baseColor.rgb * lambert + vec3(specular) + material_TranslucencyColor * baseColor.rgb * backLight);
            }
          #endif
          outputColor = vec4(lighting, baseColor.a);
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

      struct Attributes {
        vec3 POSITION;
        vec3 NORMAL;
        vec2 TEXCOORD_0;
        vec4 COLOR_0;
        vec4 INSTANCE_POSITION_HASH;
        vec4 INSTANCE_ROTATION;
        vec4 INSTANCE_SCALE_WIND;
      };

      struct Varyings {
        vec2 uv;
      };

      #include "ShaderLibrary/Common/Common.glsl"
      #include "ShaderLibrary/Common/Transform.glsl"

      sampler2D material_Albedo;
      float material_AlphaCutoff;
      float material_Time;
      float material_WindForce;
      float material_WindWavesScale;
      float material_WindFlowDensity;
      int material_WindBaseLock;
      int material_WindEnabled;
      vec3 material_WindDirection;
      float material_GlobalWindForce;
      float material_GlobalWavesScale;
      float material_GlobalFlowDensity;
      float material_FadeDistance;
      vec2 scene_ShadowBias;
      vec3 scene_LightDirection;

      VertexShader = vert;
      FragmentShader = frag;

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

      float windWeight(Attributes attributes) {
        #ifdef RENDERER_ENABLE_VERTEXCOLOR
          return attributes.COLOR_0.r;
        #else
          return 1.0;
        #endif
      }

      vec3 displacedWorldPosition(Attributes attributes, out vec3 worldNormal) {
        vec3 worldPosition = attributes.INSTANCE_POSITION_HASH.xyz +
          rotateByQuaternion(attributes.POSITION * attributes.INSTANCE_SCALE_WIND.xyz, attributes.INSTANCE_ROTATION);
        worldNormal = normalize(rotateByQuaternion(attributes.NORMAL, attributes.INSTANCE_ROTATION));
        if (material_WindEnabled != 0) {
          float timeOffset = material_Time * material_GlobalWindForce * material_WindForce * 5.0 +
            attributes.INSTANCE_SCALE_WIND.w;
          float frequency = max((1.0 - material_WindWavesScale) * material_GlobalWavesScale, 0.00001);
          float noise = surfaceNoise3D((worldPosition + vec3(timeOffset)) * frequency) * 0.5 + 0.5;
          float flow = pow(max(noise, 0.00001), material_WindFlowDensity * material_GlobalFlowDensity) * 0.01;
          float rootLock = material_WindBaseLock != 0 ? pow(max(attributes.TEXCOORD_0.y, 0.0), 1.5) : 1.0;
          worldPosition += material_WindDirection *
            (flow * rootLock * windWeight(attributes) * material_WindForce * 100.0 * material_GlobalWindForce);
        }
        if (material_FadeDistance > 0.0) {
          float cameraDistance = length(worldPosition - camera_Position);
          float fade = 1.0 - smoothstep(material_FadeDistance, material_FadeDistance + 5.0, cameraDistance);
          worldPosition = mix(attributes.INSTANCE_POSITION_HASH.xyz, worldPosition, fade);
        }
        return worldPosition;
      }

      Varyings vert(Attributes attributes) {
        Varyings output;
        vec3 worldNormal;
        vec3 worldPosition = displacedWorldPosition(attributes, worldNormal);
        float invNdotL = 1.0 - clamp(dot(-scene_LightDirection, worldNormal), 0.0, 1.0);
        worldPosition -= scene_LightDirection * scene_ShadowBias.x;
        worldPosition += worldNormal * (invNdotL * scene_ShadowBias.y);
        vec4 positionCS = camera_VPMat * vec4(worldPosition, 1.0);
        positionCS.z = max(positionCS.z, -1.0);
        gl_Position = positionCS;
        output.uv = attributes.TEXCOORD_0;
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
        if (texture2D(material_Albedo, varyings.uv).a < material_AlphaCutoff) discard;
        #ifdef ENGINE_NO_DEPTH_TEXTURE
          gl_FragColor = packDepth(gl_FragCoord.z);
        #else
          gl_FragColor = vec4(0.0);
        #endif
      }
    }
  }
}
