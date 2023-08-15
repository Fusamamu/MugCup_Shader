Shader "MUGCUP Custom Shaders/Unlit/Block Icon Shader"
{
    Properties
    {
        //_TestTex ("Test Texture", 2D) = "white" {}
        [Toggle(GRADIENT_WORLDPOS)] _EnableGradientWorld ("Enable World Gradient", Float) = 0
        
        _COL1 ("Color one", color) = (1.0, 1.0, 1.0, 1.0)
        _COL2 ("Color two", color) = (1.0, 1.0, 1.0, 1.0)
        
        [Header(Splat Texture)]
        [Space(10)]
        _MainTex("Splat Map", 2D) = "white" {}
        
        [Header(Mask Texture)]
        [Space(10)]
        _MaskTex ("Mask Texture", 2D) = "white" {}
        
        [Header(Flow Map Texture)]
        [Space(10)]
        _FlowMapTexture ("Flow Map Texture", 2D) = "white" {}
        
        [Header(Triplanar Color)]
        [Space(10)]
        _FrontCol ("Front Color", color) = (1.0, 1.0, 1.0, 1.0)
        _TopCol   ("Top Color"  , color) = (1.0, 1.0, 1.0, 1.0)
        _SideCol  ("Side Color" , color) = (1.0, 1.0, 1.0, 1.0)
        
        [Header(Gradient Color In World Space from Top to Bottom)]
        [Space(10)]
        _GradientCol2 ("Gradient Color 2", color) = (1.0, 1.0, 1.0, 1.0)
        _GradientCol1 ("Gradient Color 1", color) = (1.0, 1.0, 1.0, 1.0)

        [Header(RGBA Color Dark Zone)]
        [Space(10)]
        _R1 ("Red Channel Color 1"  , color) = (1.0, 1.0, 1.0, 1.0)
        _G1 ("Green Channel Color 1", color) = (1.0, 1.0, 1.0, 1.0)
        _B1 ("Blue Channel Color 1" , color) = (1.0, 1.0, 1.0, 1.0)
        _A1 ("Black Channel Color 1", color) = (1.0, 1.0, 1.0, 1.0)
        
        [Header(RGBA Color Light Zone)]
        [Space(10)]
        _R2("Red Channel Color 2"  , color) = (1.0, 1.0, 1.0, 1.0)
        _G2("Green Channel Color 2", color) = (1.0, 1.0, 1.0, 1.0)
        _B2("Blue Channel Color 2" , color) = (1.0, 1.0, 1.0, 1.0)
        _A2("Black Channel Color 2", color) = (1.0, 1.0, 1.0, 1.0)
        
        [Header(Filter Color for Lerp betwern Dark and Light Zone)]
        [Space(10)]
        _FilterCol("Filter Color", color) = (1.0, 1.0, 1.0, 1.0)
        
        [Header(Light Position)]
        [Space(10)]
        _SamplePos("Light Position", Vector) = (0.0, 0.0, 0.0)
        
        [Header(Light Radius)]
        [Space(10)]
        _MainRadius     ("Main Radius"    , float) = 1
        _SecondaryRadius("SecondaryRadius", float) = 0.5
         
        [Header(Flow Map Attributes)]
        [Space(10)]
        _NoiseScale ("Noise Scale" , Range(0, 10)) = 1 
        _WobbleSpeed("Wobble Speed", float) = 1
        _ClockFrame ("Clock Frame" , int  ) = 1
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

            #pragma multi_compile __ GRADIENT_WORLDPOS
        
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                //float3 uv     : TEXCOORD1;

                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv       : TEXCOORD1;
                float2 uvSplat  : TEXCOORD2;
                float3 uvWorld  : TEXCOORD3;
                float3 normal   : TEXCOORD4;
            };

            sampler2D _TestTex;
            float4    _TestTex_ST;

            sampler2D _MaskTex;
            float4    _MaskTex_ST;
            
            sampler2D _MainTex   ;
            float4    _MainTex_ST;

            sampler2D _FlowMapTexture;
            float4  _FlowMapTexture_ST;

            sampler2D _Texture1;
            sampler2D _Texture2;
            sampler2D _Texture3;
            sampler2D _Texture4;

            float4 _COL1;
            float4 _COL2;

            float4 _GradientCol1;
            float4 _GradientCol2;

            float4 _FrontCol;
            float4 _TopCol;
            float4 _SideCol;

            float4 _R1;
            float4 _G1;
            float4 _B1;
            float4 _A1;

            float4 _R2;
            float4 _G2;
            float4 _B2;
            float4 _A2;

            float4 _FilterCol;

            float3 _SamplePos;
            
            float _MainRadius;
            float _SecondaryRadius;

            float _NoiseScale;
            float _WobbleSpeed;
            int   _ClockFrame;

            float GetClockFrame()
            {
                return floor(fmod(_Time.y * _WobbleSpeed, _ClockFrame)) / _ClockFrame;
            }
            
            v2f vert (appdata _v)
            {
                v2f o;
                
                o.vertex   = UnityObjectToClipPos(_v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, _v.vertex);

                o.uv      = TRANSFORM_TEX(_v.uv, _FlowMapTexture);
                o.uvSplat = _v.uv;
                o.uvWorld = mul(unity_ObjectToWorld, _v.vertex);

                o.normal = _v.normal;


                float3 worldNormal = mul(_v.normal, (float3x3)unity_WorldToObject);
                
                o.normal = normalize(worldNormal);
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float _dis = distance(_SamplePos, i.uvWorld);
                
                
                float4 splat = tex2D(_MainTex, i.uvSplat);

                float2 uv_front = TRANSFORM_TEX(i.worldPos.xy, _TestTex);
                float2 uv_side  = TRANSFORM_TEX(i.worldPos.yz, _TestTex);
                float2 uv_top   = TRANSFORM_TEX(i.worldPos.xz, _TestTex);
                
                fixed4 col_front = tex2D(_TestTex, uv_front);
                fixed4 col_side  = tex2D(_TestTex, uv_side);
                fixed4 col_top   = tex2D(_TestTex, uv_top);

                float3 _weights = i.normal;
                
                //show texture on both sides of the object (positive and negative)
                _weights = abs(_weights);
                _weights = _weights / (_weights.x + _weights.y + _weights.z);

                //combine weights with projected colors
                col_front *= _weights.z;
                col_side  *= _weights.x;
                col_top   *= _weights.y;

                //combine the projected colors
                //fixed4 col = col_front + col_side + col_top;

                _FrontCol *= _weights.z;
                _SideCol  *= _weights.x;
                _TopCol   *= _weights.y;

                fixed4 _triPlanarCol = _FrontCol + _SideCol + _TopCol;

                
                // triplanar noise
                // float3 blendNormal = saturate(pow(IN.worldNormal * 1.4,4));
                // half4 nSide1 = tex2D(_NoiseTex, (IN.worldPos.xy + _Time.x) * _NScale); 
                // half4 nSide2 = tex2D(_NoiseTex, (IN.worldPos.xz + _Time.x) * _NScale);
                // half4 nTop = tex2D(_NoiseTex, (IN.worldPos.yz + _Time.x) * _NScale);
                // float3 noisetexture = nSide1;
                // noisetexture = lerp(noisetexture, nTop, blendNormal.x);
                // noisetexture = lerp(noisetexture, nSide2, blendNormal.y);

                float3 _blendNormal = saturate(pow(i.normal * 1.4, 4));

                half4 _nSide1 = tex2D(_FlowMapTexture, (i.worldPos.xy + _Time.x * _WobbleSpeed) * _NoiseScale);
                half4 _nSide2 = tex2D(_FlowMapTexture, (i.worldPos.xz + _Time.x * _WobbleSpeed) * _NoiseScale);
                half4 _nTop   = tex2D(_FlowMapTexture, (i.worldPos.yz + _Time.x * _WobbleSpeed) * _NoiseScale);

                float3 _noiseTexture = _nSide1;
                _noiseTexture = lerp(_noiseTexture, _nTop  , _blendNormal.x);
                _noiseTexture = lerp(_noiseTexture, _nSide2, _blendNormal.y);

                _dis *= _noiseTexture;

                float4 _col1 =
                    _R1 * splat.r +
					_G1 * splat.g +
					_B1 * splat.b +
					_A1 * (1 - splat.r - splat.g - splat.b);

                float4 _col2 =
                    _R2 * splat.r +
					_G2 * splat.g +
					_B2 * splat.b +
					_A2 * (1 - splat.r - splat.g - splat.b);

                float4 _baseCol;

                _baseCol = lerp(_col2, _col1, step(_MainRadius, _dis));
                _baseCol = lerp(_baseCol, _FilterCol * _col1, step(_SecondaryRadius, _dis));

                float4 _gradient = lerp(_GradientCol1, _GradientCol2, i.worldPos.y);
                
                // float2 uv_topp   = TRANSFORM_TEX(i.worldPos.xz, _MaskTex);
                //
                // fixed4 _mask = tex2D(_MaskTex, uv_topp * 0.05) * _weights.y;
                //
                // fixed4 _mask = tex2D(_MaskTex, uv_topp * 0.05) * _weights.y;
                // + fixed4(1, 1, 1,1) * _weights.x + fixed4(1, 1, 1,1) * _weights.z;
                //
                // fixed4 _baseWithMask = _baseCol * _mask  + _COL2 * (1 - _mask);
                //
                // return  _baseWithMask * _triPlanarCol * _gradient;
                //
                // return _baseWithMask;

                #ifdef GRADIENT_WORLDPOS
                return  _baseCol * _triPlanarCol * _gradient;
                #else
                return  _baseCol * _triPlanarCol;
                #endif
                
                
                

                
                // float2 newUV = i.uv * GetClockFrame();
                // float flowtex = tex2D(_FlowMapTexture, newUV);
                // _result *= flowtex;
                // return _result;
  
            }
            ENDCG
        }
    }  
}

