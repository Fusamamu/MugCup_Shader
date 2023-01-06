Shader "MUGCUP Custom Shaders/Unlit/TestCombineTexture"
{
    Properties
    {
        _MainTex   ("Main Map"  , 2D) = "white" {}
        _DetailTex ("Detail Map", 2D) = "white" {}
        
        [Space(10)]
        _R1 ("Red Channel Color 1"  , color) = (1.0, 1.0, 1.0, 1.0)
        _G1 ("Green Channel Color 1", color) = (1.0, 1.0, 1.0, 1.0)
        _B1 ("Blue Channel Color 1" , color) = (1.0, 1.0, 1.0, 1.0)
        _A1 ("Black Channel Color 1", color) = (1.0, 1.0, 1.0, 1.0)
         
        [Space(10)]
        _R2("Red Channel Color 2"  , color) = (1.0, 1.0, 1.0, 1.0)
        _G2("Green Channel Color 2", color) = (1.0, 1.0, 1.0, 1.0)
        _B2("Blue Channel Color 2" , color) = (1.0, 1.0, 1.0, 1.0)
        _A2("Black Channel Color 2", color) = (1.0, 1.0, 1.0, 1.0)
        
        [Space(10)]
        _Mask1("Red Channel Mask"  , color) = (1.0, 1.0, 1.0, 1.0)
        _Mask2("Green Channel Mask", color) = (1.0, 1.0, 1.0, 1.0)
        _Mask3("Blue Channel Mask" , color) = (1.0, 1.0, 1.0, 1.0)
        _Mask4("Black Channel Mask", color) = (1.0, 1.0, 1.0, 1.0)
        
        [Header(Triplanar Color)]
        [Space(10)]
        _FrontCol ("Front Color", color) = (1.0, 1.0, 1.0, 1.0)
        _TopCol   ("Top Color"  , color) = (1.0, 1.0, 1.0, 1.0)
        _SideCol  ("Side Color" , color) = (1.0, 1.0, 1.0, 1.0)
        
        [Toggle(OVERLAY)]   _EnableOverlay   ("Enable Overlay"  , Float) = 0
        [Toggle(COLORBURN)] _EnableColorBurn ("Enable ColorBurn", Float) = 0
        [Toggle(HARDLIGHT)] _EnableHardLight ("Enable HardLight", Float) = 0
        
        
        [Header(Gradient Color In World Space from Top to Bottom)]
        [Space(10)]
        _GradientCol2 ("Gradient Color 2", color) = (1.0, 1.0, 1.0, 1.0)
        _GradientCol1 ("Gradient Color 1", color) = (1.0, 1.0, 1.0, 1.0)
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
                float2 uv0    : TEXCOORD0;
                float2 uv1    : TEXCOORD1;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv0      : TEXCOORD1;
                float2 uv1      : TEXCOORD2;
                float3 normal   : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _DetailTex;
            float4 _DetailTex_ST;

            float4 _R1, _G1, _B1, _A1;
            float4 _R2, _G2, _B2, _A2;
    
            float4 _FrontCol, _TopCol, _SideCol;

            float4 _GradientCol1,  _GradientCol2;

            float overlay(float s, float d)
            {
                return (d < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
            }
            
            fixed3 Overlay(fixed3 s, fixed3 d)
            {
                fixed3 c;
                c.x = overlay(s.x, d.x);
                c.y = overlay(s.y, d.y);
                c.z = overlay(s.z, d.z);
                return c;
            }

            fixed3 ColorBurn(fixed3 s, fixed3 d)
            {
                return 1.0 - (1.0 - d) / s;
            }

            float hardLight(float s, float d)
            {
                return (s < 0.5) ? 2.0*s*d : 1.0 - 2.0*(1.0 - s)*(1.0 - d);
            }

            fixed3 HardLight(fixed3 s, fixed3 d)
            {
                fixed3 c;
                c.x = hardLight(s.x, d.x);
                c.y = hardLight(s.y, d.y);
                c.z = hardLight(s.z, d.z);
                return c;
            }


            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex   = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                o.uv0 = TRANSFORM_TEX(v.uv0 , _MainTex  );
                o.uv1 = TRANSFORM_TEX(v.uv1 , _DetailTex);

                const float3 _worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.normal = normalize(_worldNormal);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 _mainMap = tex2D(_MainTex, i.uv0);

                float4 _baseColor =
                    _R1 * _mainMap.r +
					_G1 * _mainMap.g +
					_B1 * _mainMap.b +
					_A1 * (1 - _mainMap.r - _mainMap.g - _mainMap.b);

                float4 _detailMap = tex2D(_DetailTex, i.uv1);

                float4 _finalCol = lerp(_baseColor, _R2, _detailMap.r);
                _finalCol = lerp(_finalCol, _G2, _detailMap.g);
                _finalCol = lerp(_finalCol, _B2, _detailMap.b);


                float3 _weights = i.normal;
                
                _weights = abs(_weights);
                _weights = _weights / (_weights.x + _weights.y + _weights.z);

                _FrontCol *= _weights.z;
                _SideCol  *= _weights.x;
                _TopCol   *= _weights.y;

                const fixed4 _triPlanarCol = _FrontCol + _SideCol + _TopCol;

                _finalCol += _triPlanarCol;

                float4 _gradient = lerp(_GradientCol1, _GradientCol2, i.worldPos.y);

                _finalCol.xyz = ColorBurn(_finalCol.xyz, _gradient.xyz);

                return _finalCol;


                
                #ifdef OVERLAY
                _finalCol.xyz = Overlay(_finalCol.xyz, _triPlanarCol.xyz);
                return _finalCol;
                #elseif COLORBURN
                _finalCol.xyz = ColorBurn(_finalCol.xyz, _triPlanarCol.xyz);
                return _finalCol;
                #elseif HARDLIGHT
                _finalCol.xyz = HardLight(_finalCol.xyz, _triPlanarCol.xyz);
                return _finalCol;
                #endif
             
                return _finalCol + _triPlanarCol;
            }
            ENDCG
        }
    }
}
