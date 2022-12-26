Shader "MUGCUP Custom Shaders/Unlit/TestDepthScene"
{
    Properties
    {
        _MainTex       ("Texture", 2D)           = "white" {}
        _DepthDistance ("Depth Distance", float) = 0.5
        _Spread        ("Spread", float)         = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CameraDepthTexture;

            float _DepthDistance;
            float _Spread;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex    = UnityObjectToClipPos(v.vertex);
                o.uv        = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                const float2 _screenSpaceUV = i.screenPos.xy / i.screenPos.w;

                float _depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, _screenSpaceUV));

                _depth *= _DepthDistance;
                _depth /= _Spread;
                _depth = saturate(_depth);
                
                return fixed4(_depth, _depth, _depth, 1);
            }
            ENDCG
        }
    }
}
