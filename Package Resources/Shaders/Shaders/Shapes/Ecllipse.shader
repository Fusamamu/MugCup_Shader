Shader "MUGCUP Custom Shaders/Unlit/Ellipse"
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

            float Ellipse(float2 p, in float2 ab )
            {
                p = abs(p);

                if( p.x > p.y )
                {
                    p  = p.yx;
                    ab = ab.yx;
                }
	            
                float l = ab.y*ab.y - ab.x*ab.x;
                float m = ab.x*p.x/l; float m2 = m*m;
                float n = ab.y*p.y/l; float n2 = n*n;
                float c = (m2 + n2 - 1.0)/3.0; float c3 = c*c*c;
                float q = c3 + m2*n2*2.0;
                float d = c3 + m2*n2;
                float g = m + m*n2;

                float co;

                if( d < 0.0 )
                {
                    float p = acos(q/c3)/3.0;
                    float s = cos(p);
                    float t = sin(p)*sqrt(3.0);
                    float rx = sqrt( -c*(s + t + 2.0) + m2 );
                    float ry = sqrt( -c*(s - t + 2.0) + m2 );
                    co = ( ry + sign(l)*rx + abs(g)/(rx*ry) - m)/2.0;
                }
                else
                {
                    float h = 2.0*m*n*sqrt( d );
                    float s = sign(q+h)*pow( abs(q+h), 1.0/3.0 );
                    float u = sign(q-h)*pow( abs(q-h), 1.0/3.0 );
                    float rx = -s - u - c*4.0 + 2.0*m2;
                    float ry = (s - u)*sqrt(3.0);
                    float rm = sqrt( rx*rx + ry*ry );
                    float p = ry/sqrt(rm-rx);
                    co = (p + 2.0*g/rm - m)/2.0;
                }

                float si = sqrt( 1.0 - co*co );

                q = float2( ab.x*co, ab.y*si );
	            
                return length(q-p) * sign(p.y-q.y);
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
                fixed4 col;

                float _dis = Ellipse(float2(0, 0), float2(1, 2));

                col = _dis;
               
                return col;
            }
            ENDCG
        }
    }
}
