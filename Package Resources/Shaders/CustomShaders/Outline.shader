Shader "MUGCUP Custom Shaders/Unlit/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _OutlineColor("Outline Color", color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineWidth("Outline Width", float ) = 1.0
    }
    
    SubShader
    {
        Pass
        {
            Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
            LOD 100
            
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
             
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            float _OutlineWidth;
            float4 _OutlineColor;

            v2f vert(appdata _v)
            {
                _v.vertex.xyz *= _OutlineWidth;

                v2f _o;
                _o.vertex = UnityObjectToClipPos(_v.vertex);
                _o.uv     = _v.uv;

                return _o;
            }
            float4 frag(v2f _i) : COLOR
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
