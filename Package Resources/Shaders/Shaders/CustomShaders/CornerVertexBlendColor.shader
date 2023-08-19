Shader "MUGCUP Custom Shaders/Unlit/Corner vertex blend color"
{
    Properties
    {
        _Color ("Main Color", color) = (1, 1, 1, 1)
          
        _ColorNE("Color NE" , color) = (1, 1, 1, 1)
        _ColorNW("Color NW" , color) = (1, 1, 1, 1)
        _ColorSW("Color SW" , color) = (1, 1, 1, 1)
        _ColorSE("Color SE" , color) = (1, 1, 1, 1)
    }
    
    SubShader
    {
        Name "URPSceneColorPass"
        
        Tags
        { 
            "Queue"          = "Transparent"
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _Color;

            float4 _ColorNE;
            float4 _ColorNW;
            float4 _ColorSW;
            float4 _ColorSE;

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
                _o.vertex    = TransformObjectToHClip(v.vertex);
                _o.screenPos = ComputeScreenPos(_o.vertex);

                _o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return _o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 _topCol    = lerp(_ColorNE, _ColorNW, i.uv.x);
                float4 _bottomCol = lerp(_ColorSE, _ColorSW, i.uv.x);

                float4 col = lerp(_topCol, _bottomCol, i.uv.y);

                return col;
            }
            ENDHLSL
        }
    }
}
