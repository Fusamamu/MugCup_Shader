Shader "MUGCUP Custom Shaders/Custom Lightings/PBS Light"
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
        Tags { "LightMode" = "UniversalForward" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            
            #pragma vertex vert
            #pragma fragment frag
        
            #include "UnityPBSLighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float3 normal   : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            float4    _Tint;
            float     _Metallic;
            float     _Smoothness;
            
            sampler2D _MainTex;
            float4    _MainTex_ST;


            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex   = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                o.uv     = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal = UnityObjectToWorldNormal(v.normal);

                o.normal = normalize(o.normal);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);
                
                float3 _lightDir   = _WorldSpaceLightPos0.xyz;
                float3 _lightColor = _LightColor0.rgb;
                
				float3 _albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

                float3 _specularTint;
				float _oneMinusReflectivity;

                _albedo = DiffuseAndSpecularFromMetallic(_albedo, _Metallic, _specularTint, _oneMinusReflectivity);
                
                float3 _viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);


                UnityLight _light;
                
				_light.color = _lightColor;
				_light.dir   = _lightDir;
				_light.ndotl = DotClamped(i.normal, _lightDir);

                UnityIndirect _indirectLight;
                
				_indirectLight.diffuse  = 0;
				_indirectLight.specular = 0;

                return BRDF1_Unity_PBS(
					_albedo              , _specularTint,
					_oneMinusReflectivity, _Smoothness,
					i.normal             , _viewDir,
					_light               , _indirectLight
				);
            }
            ENDCG
        }
    }
}
