Shader "Unlit/First Light"
{
    Properties
    {
        _Tint       ("Tint", color)             = (1.0, 1.0, 1.0, 1.0)
        _MainTex    ("Albedo", 2D)              = "white" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "LightMode" = "UniversalForward" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            #include "UnityCG.cginc"
            #include "UnityStandardBRDF.cginc"


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
            float     _Smoothness;
            
            sampler2D _MainTex;
            float4    _MainTex_ST;


            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex   = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                o.uv     = TRANSFORM_TEX(v.uv, _MainTex);

                /*This gets "Normal" directly from the object.*/
                //o.normal = v.normal;
                
                /*This convert "Object Normal" into "World Space Normal       */
                /*These two lines of code essentially produce the same result.*/
                
                //o.normal = mul(unity_ObjectToWorld, float4(v.normal, 0));
                //o.normal = mul((float3x3)unity_WorldToObject, v.normal);
                
                /*To account for non-uniform scaling, worldToObject Matrix need to be transposed*/
                //o.normal = mul(transpose((float3x3)unity_WorldToObject), v.normal);

                /*Thankfully, Unity has macro for that called "UnityObjectToWorldNormal".*/
                o.normal = UnityObjectToWorldNormal(v.normal);

                o.normal = normalize(o.normal);

                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                /*
                Unfortunately, linearly interpolating between different
                unit-length vectors does not result in another unit-length vector.
                It will be shorter.
                */
                
                i.normal = normalize(i.normal);

                /*This display normal*/
                //return float4(i.normal, 1);

                /*We can use "DotClamped" for the line below*/
                //return saturate(dot(float3(0, 1, 0), i.normal));

                
                float3 _lightDir   = _WorldSpaceLightPos0.xyz;
                float3 _lightColor = _LightColor0.rgb;
                
				float3 _albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
                
				float3 diffuse =_albedo * _lightColor * DotClamped(_lightDir, i.normal);

                float3 _viewDir       = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 _reflectionDir = reflect(-_lightDir, i.normal);

                /*This shows reflection direction normal vector*/
                //return float4(_reflectionDir, 1);
                
                /*This shows reflection light.*/
                //return DotClamped(_viewDir, _reflectionDir);

                /*This uses _Smoothness to control how much intensity of the reflection area.*/
                return pow(DotClamped(_viewDir, _reflectionDir),_Smoothness * 100);
            }
            ENDCG
        }
    }
}
