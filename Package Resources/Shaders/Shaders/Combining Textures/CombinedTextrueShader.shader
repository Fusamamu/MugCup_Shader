Shader "Unlit/CombinedTextrueShader"
{
    Properties
    {
        _Tint      ("Tint", color)        = (1.0, 1.0, 1.0, 1.0)
        _MainTex   ("Texture", 2D)        = "white" {}
        _DetailTex ("Detail Texture", 2D) = "white" {}
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
                float4 vertex   : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float2 uvDetail : TEXCOORD1;
            };

            float4    _Tint;
            
            sampler2D _MainTex;
            float4    _MainTex_ST;

            sampler2D _DetailTex;
            float4    _DetailTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv       = TRANSFORM_TEX(v.uv, _MainTex  );
                o.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Tint;

                col *= tex2D(_DetailTex, i.uvDetail) * unity_ColorSpaceDouble;
              
                return col;
            }
            ENDCG
        }
    }
}
