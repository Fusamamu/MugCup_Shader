Shader "MUGCUP Custom Shaders/Unlit/Toon Unlit Shader with Shadow"
{
    Properties
    {
        _Color       ("Main color"   , Color) = (1.0, 1.0, 1.0, 1.0)
        _AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
        
        _ShadowStep ("Shadow step value", Range(0, 1)) = 0.1
        _ShadowMin ("Minimum shadow value", Range(0, 1)) = 0.2
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        
        Cull Back

        Pass
        {
            Name "ForwardLit"
            
            Tags 
            { 
                "LightMode" = "UniversalForward" 
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
            };

            struct Varyings
            {
                float4 posCS        : SV_POSITION;
                float3 posWS        : TEXCOORD0;
                float3 normalWS     : TEXCOORD1;
            };

            float4 _Color;
            float4 _AmbientColor;
            
            float _ShadowStep, _ShadowMin;

            Varyings vert(Attributes IN)
            {
                Varyings OUT = (Varyings)0;
                
                const VertexPositionInputs _vertexInput = GetVertexPositionInputs(IN.vertex.xyz);
                
                OUT.posCS = _vertexInput.positionCS;
                OUT.posWS = _vertexInput.positionWS;

                const VertexNormalInputs _normalInput = GetVertexNormalInputs(IN.normal);
                OUT.normalWS = _normalInput.normalWS;

                return OUT;
            }

            float4 frag (Varyings IN) : SV_Target
            {
                float4 shadowCoord = TransformWorldToShadowCoord(IN.posWS);
                float shadowMap    = MainLightRealtimeShadow(shadowCoord) - 0.5;

                float NdotL = saturate(dot(_MainLightPosition.xyz, IN.normalWS));

                float combinedShadow = min(NdotL, shadowMap);


                //return combinedShadow;
                
                float shadowValue = saturate(step(_ShadowStep, combinedShadow) + _ShadowMin);
                
                float3 _mask = float3(1, 1, 1) * shadowValue;

                float3 col = _mask.xyz * _Color;

                float3 _IMask = saturate(1 - _mask);

                float3 colB = _IMask * _AmbientColor;

                float3 colC = col + colB;

                return float4(colC, 1);;
            }
            ENDHLSL
        }
             
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
            };

            struct Varyings
            {
                float4 posCS        : SV_POSITION;
            };

            float3 _LightDirection;

            Varyings vert(Attributes IN)
            {
                Varyings OUT = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.vertex.xyz);

                float3 posWS = vertexInput.positionWS;

                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normal);

                float3 normalWS = normalInput.normalWS;

                // Shadow biased ClipSpace position
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(posWS, normalWS, _LightDirection));

                #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif

                OUT.posCS = positionCS;
                return OUT;
            }

            float4 frag (Varyings IN) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }
    }
}
