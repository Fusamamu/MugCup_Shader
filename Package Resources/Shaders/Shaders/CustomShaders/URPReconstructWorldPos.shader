Shader "MUGCUP Custom Shaders/URPReconstructWorldPos"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"     = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            "Queue"          = "Transparent+1"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;

            v2f vert (appdata _v)
            {
                v2f _o;
                _o.vertex    = TransformObjectToHClip(_v.vertex);
                _o.screenPos = ComputeScreenPos(_o.vertex);

                return _o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // const float2 _screenUV = i.screenPos.xy / i.screenPos.w;
                //
                // float _zRaw = SampleSceneDepth(_screenUV);
                // float _z01  = Linear01Depth(_zRaw, _ZBufferParams);
                // float _zEye = LinearEyeDepth(_zRaw, _ZBufferParams);
                //
                // float3 worldPos = ComputeWorldSpacePosition(_screenUV, _zRaw, UNITY_MATRIX_I_VP);
                //
                // return float4(frac(worldPos), 1.0);

                float2 _positionNDC = i.vertex.xy / _ScaledScreenParams.xy;
                real _depth = SampleSceneDepth(_positionNDC);
                
                float3 positionWS = ComputeWorldSpacePosition(_positionNDC, _depth, UNITY_MATRIX_I_VP);
                
                half4 color = half4(frac(positionWS), 1.0);
                
                if(_depth < 0.0001)
                    return half4(0,0,0,1);
                
                return color;

            }
            ENDHLSL
        }
    }
}
