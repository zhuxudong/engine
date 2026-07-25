Shader "Terrain/GrasslandsCloud" {
  SubShader "Default" {
    Pass "Forward" {
      Tags { pipelineStage = "Forward" }

      RenderQueueType renderQueueType;
      BlendFactor sourceColorBlendFactor;
      BlendFactor destinationColorBlendFactor;
      BlendFactor sourceAlphaBlendFactor;
      BlendFactor destinationAlphaBlendFactor;
      CullMode rasterStateCullMode;
      Bool blendEnabled;
      Bool depthWriteEnabled;

      BlendState = {
        Enabled = blendEnabled;
        SourceColorBlendFactor = sourceColorBlendFactor;
        DestinationColorBlendFactor = destinationColorBlendFactor;
        SourceAlphaBlendFactor = sourceAlphaBlendFactor;
        DestinationAlphaBlendFactor = destinationAlphaBlendFactor;
      }
      DepthState = { WriteEnabled = depthWriteEnabled; }
      RasterState = { CullMode = rasterStateCullMode; }
      RenderQueueType = renderQueueType;

      struct Attributes {
        vec4 POSITION_UV;
        vec4 INSTANCE_POSITION_PHASE;
        vec4 INSTANCE_DIRECTION_SPEED;
        vec4 INSTANCE_RIGHT_LIFETIME;
        vec4 INSTANCE_UP_WIDTH;
        vec4 INSTANCE_HEIGHT;
      };

      struct Varyings {
        vec2 uv;
        vec4 color;
        vec3 positionVS;
        vec4 positionCS;
      };

      #include "ShaderLibrary/Common/Common.glsl"
      #include "ShaderLibrary/Common/Transform.glsl"
      #include "ShaderLibrary/Common/Fog.glsl"

      sampler2D material_CloudTexture;
      highp sampler2D camera_DepthTexture;
      float material_Time;
      float material_SimulationSpeed;
      float material_Softness;
      vec4 material_CloudColor;

      VertexShader = vert;
      FragmentShader = frag;

      Varyings vert(Attributes attributes) {
        Varyings varyings;
        float lifetime = attributes.INSTANCE_RIGHT_LIFETIME.w;
        float age = mod(
          material_Time + attributes.INSTANCE_POSITION_PHASE.w,
          lifetime
        );
        float normalizedAge = age / lifetime;
        vec3 center = attributes.INSTANCE_POSITION_PHASE.xyz +
          attributes.INSTANCE_DIRECTION_SPEED.xyz *
          attributes.INSTANCE_DIRECTION_SPEED.w *
          age * material_SimulationSpeed;
        vec3 right = attributes.INSTANCE_RIGHT_LIFETIME.xyz;
        vec3 up = attributes.INSTANCE_UP_WIDTH.xyz;
        vec3 worldPosition = center +
          right * attributes.POSITION_UV.x * attributes.INSTANCE_UP_WIDTH.w +
          up * attributes.POSITION_UV.y * attributes.INSTANCE_HEIGHT.x;
        vec4 viewPosition = camera_ViewMat * vec4(worldPosition, 1.0);
        varyings.positionVS = viewPosition.xyz;
        varyings.positionCS = camera_ProjMat * viewPosition;
        varyings.uv = attributes.POSITION_UV.zw;
        float fadeIn = clamp(normalizedAge / 0.3, 0.0, 1.0);
        float fadeOut = clamp((1.0 - normalizedAge) / 0.3, 0.0, 1.0);
        varyings.color = material_CloudColor;
        varyings.color.a *= min(fadeIn, fadeOut);
        gl_Position = varyings.positionCS;
        return varyings;
      }

      void frag(Varyings varyings) {
        vec4 color = texture2DSRGB(material_CloudTexture, varyings.uv) * varyings.color;
        vec2 screenUv = varyings.positionCS.xy / varyings.positionCS.w * 0.5 + 0.5;
        float sceneEyeDepth = remapDepthBufferEyeDepth(
          texture2D(camera_DepthTexture, screenUv).r
        );
        float fragmentEyeDepth = -varyings.positionVS.z;
        color.a *= saturate(
          abs(sceneEyeDepth - fragmentEyeDepth) / max(material_Softness, 0.0001)
        );
        #if SCENE_FOG_MODE != 0
          color = fog(color, varyings.positionVS);
        #endif
        gl_FragColor = color;
      }
    }
  }
}
