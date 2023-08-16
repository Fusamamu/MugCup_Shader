Shader "MUGCUP Custom Shaders/FogOfWarBlitOverlayShader"
{
    /*If there is second camera stacked on to the main camera,
     *Do not forget to toggle on the Postprocess box in the second camera
     *Otherwise, the image will be upside down.
    */
    Properties
    {
        [MainTexture]_Mask ("Mask", 2D) = "" {}
        _OverlayColor ("Overlay color", Color) = (1.0, 1.0, 1.0, 1.0)
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

            float4 _OverlayColor;

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

                float _xPos = (_positionWS.x + 0.5) / 16;
                float _zPos = (_positionWS.z + 0.5) / 16;

                const half4 _sceneColor = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, i.screenPos.xy/i.screenPos.w);
                
                if(_xPos < 0.0 || _xPos > 1.0)
                    return _OverlayColor * _sceneColor;
                
                if(_zPos < 0.0 || _zPos > 1.0)
                    return _OverlayColor * _sceneColor;

                half4 _color = tex2D(_Mask, float2(_xPos, _zPos));
               
                return _color * _sceneColor;
            }
            ENDHLSL
        }
    }
}
