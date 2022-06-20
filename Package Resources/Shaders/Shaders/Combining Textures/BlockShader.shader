Shader "MUGCUP Custom Shaders/Unlit/RGBSplat"
{
    Properties
    {
        _MainTex  ("Splat Map", 2D) = "white" {}
        
		[NoScaleOffset] _Texture1 ("Texture 1", 2D) = "white" {}
		[NoScaleOffset] _Texture2 ("Texture 2", 2D) = "white" {}
        [NoScaleOffset] _Texture3 ("Texture 3", 2D) = "white" {}
		[NoScaleOffset] _Texture4 ("Texture 4", 2D) = "white" {}
        
        _R1 ("Red Channel Color 1"  , color) = (1.0, 1.0, 1.0, 1.0)
        _G1 ("Green Channel Color 1", color) = (1.0, 1.0, 1.0, 1.0)
        _B1 ("Blue Channel Color 1" , color) = (1.0, 1.0, 1.0, 1.0)
        _A1 ("Black Channel Color 1", color) = (1.0, 1.0, 1.0, 1.0)
        
        
        
        _R2("Red Channel Color 2"  , color) = (1.0, 1.0, 1.0, 1.0)
        _G2("Green Channel Color 2", color) = (1.0, 1.0, 1.0, 1.0)
        _B2("Blue Channel Color 2" , color) = (1.0, 1.0, 1.0, 1.0)
        _A2("Black Channel Color 2", color) = (1.0, 1.0, 1.0, 1.0)
        
        
        _SamplePos("Sample Position", Vector) = (0.0, 0.0, 0.0)
        _Radius("Radius", float) = 1
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
                //float3 uv     : TEXCOORD1;
            };
            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float2 uvSplat  : TEXCOORD1;
                float3 uvWorld     : TEXCOORD2;
            };
            
            sampler2D _MainTex   ;
            float4    _MainTex_ST;

            sampler2D _Texture1;
            sampler2D _Texture2;
            sampler2D _Texture3;
            sampler2D _Texture4;

            float4 _R1;
            float4 _G1;
            float4 _B1;
            float4 _A1;


            float4 _R2;
            float4 _G2;
            float4 _B2;
            float4 _A2;

            float3 _SamplePos;
            float _Radius;
            
            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv      = TRANSFORM_TEX(v.uv, _MainTex);

                
                o.uvSplat = v.uv;

                o.uvWorld = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {

                float _dis = saturate(distance(_SamplePos, i.uvWorld) - _Radius);
                
                float4 splat = tex2D(_MainTex, i.uvSplat);
                
     //            return
     //                tex2D(_Texture1, i.uv) * splat.r +
					// tex2D(_Texture2, i.uv) * splat.g +
					// tex2D(_Texture3, i.uv) * splat.b +
					// tex2D(_Texture4, i.uv) * (1 - splat.r - splat.g - splat.b);


                float4 _col1 =    _R1   * splat.r +
					_G1 * splat.g +
					_B1 * splat.b +
					_A1 * (1 - splat.r - splat.g - splat.b);


                float4 _col2 =    _R2   * splat.r +
					_G2 * splat.g +
					_B2 * splat.b +
					_A2 * (1 - splat.r - splat.g - splat.b);

                float4 _result;


                if(_dis >= 1)
                {
                    _result = _col1;
                }else
                {
                    _result = _col2;
                    
                }

                return  _result;

  
            }
            ENDCG
        }
    }  
}
