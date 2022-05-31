Shader "MUGCUP Custom Shaders/Custom Lightings/URP/URP Multiple Lights"
{
    Properties
    {
        _Tint               ("Tint", color)             = (1.0, 1.0, 1.0, 1.0)
        _MainTex            ("Albedo", 2D)              = "white" {}
        [Gamma] _Metallic   ("Metallic",   Range(0, 1)) = 0
        _Smoothness         ("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Pass
        {
	        Tags { "LightMode" = "UniversalForward" "RenderType"="Opaque" }
	        LOD 100
            
            HLSLPROGRAM
            
            #pragma target 4.5
            
            #pragma vertex   vert
            #pragma fragment frag

            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
			float4    _Tint;
			float     _Metallic;
			float     _Smoothness;
			sampler2D _MainTex;
			float4    _MainTex_ST;

            struct appdata
			{
				float4 vertex : POSITION;
				// float3 normal : NORMAL;
				// float2 uv     : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				float2 uv       : TEXCOORD0;
				float3 normal   : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};
	
			v2f vert (appdata v)
			{
				v2f o;

				

				o.vertex = v.vertex;
			    
				return o;
			}

			float4 frag (v2f i) : SV_Target
			{
				i.normal = normalize(i.normal);
			    
				return float4(1.0, 1.0, 1.0, 1.0);
			}
            ENDHLSL
        }
    }
}
