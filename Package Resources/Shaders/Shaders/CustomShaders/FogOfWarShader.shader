Shader "MUGCUP Custom Shaders/Unlit/FogOfWarShader"
{
    Properties
    {
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/MugCup_Shader/Package Resources/Shaders/Shaders/Shapes/SDF2DLIB.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 uv     : TEXCOORD0;
            };

            float4 _Color;

            v2f vert (appdata _v)
            {
                v2f _o;
                _o.vertex = UnityObjectToClipPos(_v.vertex);
                _o.uv     = _v.vertex;
                return _o;
            }

            fixed4 frag (v2f _i) : SV_Target
            {
                float a = AABoxSDF(_i.uv.xz, float2(1, 1));
                float b = AABoxSDF(_i.uv.xz + float2(1, 0), float2(1, 1));
                float c = AABoxSDF(_i.uv.xz + float2(0, 1), float2(1, 1));

                float d = Union(a, b);
                float cc = Union(d, c);
                
                return cc;
            }
            ENDHLSL
        }
    }
}
