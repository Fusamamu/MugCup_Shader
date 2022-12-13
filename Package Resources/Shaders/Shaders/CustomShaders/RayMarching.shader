Shader "Unlit/RayMarching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 1e-3

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro     : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float GetDist(float3 _p)
            {
                float _dist = length(_p) - 0.5f;

                return _dist;
            }

            float RayMarch(float3 _ro, float3 _rd)
            {
                float _dO = 0;
                float _dS = 0;

                for(int _i = 0; _i < MAX_STEPS; _i++)
                {
                    float3 _p = _ro + _dO * _rd;

                    _dS = GetDist(_p);

                    _dO += _dS;

                    if(_dO < SURF_DIST || _dO > MAX_DIST)
                        break;
                }

                return _dO;
            }

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv     = TRANSFORM_TEX(v.uv, _MainTex);
                o.ro     = _WorldSpaceCameraPos;
                o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            float3 GetNormal(float3 _p)
            {
                float2 _e = float2(1e-2, 0);

                float3 _n = GetDist(_p) - float3(   
                    GetDist(_p - _e.xyy),
                    GetDist(_p - _e.yxy),
                    GetDist(_p - _e.yyx));

                return normalize(_n);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv  = i.uv - 0.5f;
                float3 _ro = i.ro;
                float3 _rd = normalize(i.hitPos - _ro);

                float _d = RayMarch(_ro, _rd);

                fixed4 col = 0;
                
                if(_d < MAX_DIST)
                {
                    float3 _p = _ro + _rd * _d;
                    float3 _n = GetNormal(_p);

                    col.rgb = _n;
                }else
                {
                    discard;
                }
              
                return col;
            }
            ENDCG
        }
    }
}
