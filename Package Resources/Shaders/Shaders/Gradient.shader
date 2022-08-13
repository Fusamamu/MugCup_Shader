Shader "MUGCUP Custom Shaders/Unlit/Gradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _SpreadPos1 ("Spread Position"       , Vector) = (0.0, 0.0, 0.0)
        _SpreadPos2 ("Second Spread Position", Vector) = (0.0, 0.0, 0.0)
        
        _ColTop    ("Color Top"   , Color) = (1.0, 1.0, 1.0, 1.0)
        _ColMid    ("Color Middle", Color) = (1.0, 1.0, 1.0, 1.0)
        _ColBottom ("Color Bottom", Color) = (1.0, 1.0, 1.0, 1.0)
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

            float3 _SpreadPos1;
            float3 _SpreadPos2;

            float4 _ColTop;
            float4 _ColMid;
            float4 _ColBottom;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = v.vertex;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 _col;

                _col = lerp(_ColTop, _ColMid, i.uv.y + _SpreadPos1.y);
                _col = lerp(_col, _ColBottom, i.uv.y + _SpreadPos2.y);
              
                return _col;
            }
            ENDCG
        }
    }
}
