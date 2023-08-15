Shader "MUGCUP Custom Shaders/Unlit/UnlitTransparentWater"
{
    Properties
    {
        _Color ("Main Color", color) = (1, 1, 1, 1)
          
        _ColorNE("Color NE" , color) = (1, 1, 1, 1)
        _ColorNW("Color NW" , color) = (1, 1, 1, 1)
        _ColorSW("Color SW" , color) = (1, 1, 1, 1)
        _ColorSE("Color SE" , color) = (1, 1, 1, 1)
        
        _WaterLevel("Water Level", float) = 1.0
    }
    
    SubShader
    {
        Name "URPSceneColorPass"
        
        Tags
        { 
            "Queue"          = "Transparent"
            //"IgnoreProjector" = "True"
            "RenderType"     = "Transparent" 
        }
        
        ZWrite Off
        Lighting Off
        Fog { Mode Off }

        Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //#include "UnityCG.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _Color;

            float4 _ColorNE;
            float4 _ColorNW;
            float4 _ColorSW;
            float4 _ColorSE;

            float _WaterLevel;

            TEXTURE2D(_CameraColorTexture);
            SAMPLER(sampler_CameraColorTexture);

            TEXTURE2D_X_FLOAT(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);
            float4 _CameraDepthTexture_TexelSize;

            // float SampleSceneDepth(float2 uv)
            // {
            //     uv = ClampAndScaleUVForBilinear(UnityStereoTransformScreenSpaceTex(uv), _CameraDepthTexture_TexelSize.xy);
            //     return SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r;
            // }



            // Z buffer to linear 0..1 depth (0 at camera position, 1 at far plane).
// Does NOT work with orthographic projections.
// Does NOT correctly handle oblique view frustums.
// zBufferParam = { (f-n)/n, 1, (f-n)/n*f, 1/f }
// float Linear01Depth(float depth, float4 zBufferParam)
// {
//     return 1.0 / (zBufferParam.x * depth + zBufferParam.y);
// }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex    : SV_POSITION;
                float2 uv        : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float3 worldPos  : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f _o;
                _o.uv = v.uv;
                _o.vertex = TransformObjectToHClip(v.vertex);
                _o.screenPos = ComputeScreenPos(_o.vertex);

                _o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return _o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //  fixed4 colorTop = lerp(_ColorA, _ColorB, screenPosition.y);
                // fixed4 colorBottom = lerp(_ColorC, _ColorD, screenPosition.y);
                // fixed4 color =  lerp(colorTop, colorBottom, screenPosition.x);

                
                // float r = i.uv.x * _Color.x;
                // float g = i.uv.x * _Color.y;
                // float b = i.uv.x * _Color.z;
                //
                // float _alpha = max(1 - i.uv.x, 0.25);
                //
                // float4 col = float4(r, g, b, _alpha);

                float4 topCol    = lerp(_ColorNE, _ColorNW, i.uv.x);
                float4 bottomCol = lerp(_ColorSE, _ColorSW, i.uv.x);

                float4 col = lerp(topCol, bottomCol, i.uv.y);

                half4 sceneColor = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, i.screenPos.xy/i.screenPos.w);
                //
                // col = lerp(sceneColor, _Color, i.uv.x);

               // sceneColor = tex2D(_CameraColorTexture, i.screenPos.xy);

                col = lerp(sceneColor, _Color, _WaterLevel);



                 float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv);

                depth = LinearEyeDepth(depth, _ZBufferParams);

                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture,  i.screenPos.xy / i.screenPos.w), _ZBufferParams);
			    //float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;
			
                
                return depth;
            }
            ENDHLSL
        }
    }
}
