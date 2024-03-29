Shader "MUGCUP Custom Shaders/URPReconstructWorldPos"
{
    Properties
    {
        [MainTexture]_Mask ("Mask", 2D) = "" {}
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
                float4 vertex    : SV_POSITION;
                float2 uv        : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _Mask;
            float4 _Mask_ST;

            TEXTURE2D(_CameraColorTexture);
            SAMPLER(sampler_CameraColorTexture);

            v2f vert (appdata _v)
            {
                v2f _o;
                _o.vertex    = TransformObjectToHClip(_v.vertex);
                _o.uv        = TRANSFORM_TEX(_v.uv, _Mask);
                _o.screenPos = ComputeScreenPos(_o.vertex);

                return _o;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float2 _positionNDC = i.vertex.xy / _ScaledScreenParams.xy;
                
                const real   _depth      = SampleSceneDepth(_positionNDC);
                const float3 _positionWS = ComputeWorldSpacePosition(_positionNDC, _depth, UNITY_MATRIX_I_VP);

                //This is for visualize world space
                half4 _color = half4(frac(_positionWS), 1.0);
                if(_depth < 0.0001)
                    return half4(0,0,0,1);
                
                return _color;
            }
            ENDHLSL
        }
    }
}
