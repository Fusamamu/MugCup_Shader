Shader "MUGCUP Custom Shaders/Unlit/Hexagon"
{
    Properties
    {
        _Color     ("Color", color)            = (1.0, 1.0, 1.0, 1.0)
        _SamplePos ("Sample Position", Vector) = (0.0, 0.0, 0.0)
        _Radius    ("Radius", float)           = 1.0
        
        _Roundness ("Roundness", float) = 1.0
        
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
            float _Roundness;

            float sdHexagon(float2 p, float r)
            {
                const float3 k = float3(-0.866025404, 0.5, 0.577350269);
                
                p = abs(p);
                
                p -= 2.0 * min(dot(k.xy,p), 0.0) * k.xy;
                
                p -= float2(clamp(p.x, -k.z * r, k.z * r), r);
                
                return length(p) * sign(p.y);
            }

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv     = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv = i.uv;

                i.uv = abs(i.uv);
                
                float col = dot(i.uv.xz, float2(1,1.73)) - _Radius;

                col = max(col, i.uv.x + 0.5) - _Radius;

                col = 1 - col - _Roundness;

                col = sdHexagon(i.uv.xz, _Radius) - _Roundness;
               
                return fixed4(col, col, col, 1.0);
            }
            ENDCG
        }
    }
}
