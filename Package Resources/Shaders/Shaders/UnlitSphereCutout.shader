Shader "Unlit/UnlitSphereCutout"
{
    Properties
    {
        _Color     ("Color", color)            = (1.0, 1.0, 1.0, 1.0)
        _SamplePos ("Sample Position", Vector) = (0.0, 0.0, 0.0)
        _Radius    ("Radius", float)           = 1.0
        
        _MainTex   ("Texture", 2D)             = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "TransparentCutout" "Queue" = "AlphaTest" }
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 uv     : TEXCOORD0;
            };

            fixed4    _Color;
            sampler2D _MainTex;

            float3 _SamplePos;

            float _Radius;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv     = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 0;

                float _dis = saturate(distance(_SamplePos, i.uv) - _Radius);

                //clip(col.a - _dis);

                col = _Color * _dis;

                col = _dis;
               
                return col;
            }
            ENDCG
        }
    }
}
