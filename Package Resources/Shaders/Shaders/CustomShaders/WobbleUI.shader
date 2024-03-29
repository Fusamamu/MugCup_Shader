Shader "MUGCUP Custom Shaders/WobbleUI"
{
    Properties
    {
        _MainTex   ("Texture", 2D) = "white" {}
        _DispTex   ("Displacement", 2D) = "white" {}
        _Speed     ("Speed", Float) = 0.5
        _Intensity ("Intensity", Float) = 0.025
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue"      = "Transparent"
        }
        
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            //#include "UnityCG.cginc"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct appdata
            {
                float4 vertex      : POSITION;
                float2 uv          : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float4 vertex    : SV_POSITION;
                float2 uv1       : TEXCOORD0;
                float2 uv2       : TEXCOORD1;
                float4 col       : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _DispTex;
            
            float4 _MainTex_ST;
            float4 _DispTex_ST;
            
            float _Speed;
            float _Intensity;

            v2f vert (appdata _v)
            {
                v2f _o;
                _o.vertex = TransformObjectToHClip(_v.vertex);
                _o.uv1 = TRANSFORM_TEX(_v.uv, _DispTex);
                _o.uv2 = TRANSFORM_TEX(_v.uv, _MainTex);
                _o.col = _v.vertexColor;
                return _o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float t = _Time.y * _Speed;
                float disp = tex2D(_DispTex, i.uv1 + float2(t, t)).r;
                float4 col = tex2D(_MainTex, i.uv2 + disp * _Intensity);
                return col * i.col;
            }
            
            ENDHLSL
        }
    }
 

//   SubShader
//   {
//    Tags
//    {
//           "RenderType" = "Transparent"
//           "Queue" = "Transparent"
//    }
//
//    Pass
//    {
//     ZWrite Off
//     Blend SrcAlpha OneMinusSrcAlpha
//
//     CGPROGRAM
//
//     #pragma vertex vert
//     #pragma fragment frag
//     
//     #include "UnityCG.cginc"
//
//     struct appdata
//     {
//      float4 vertex : POSITION;
//      float2 uv : TEXCOORD0;
//      fixed4 vertexColor : COLOR;
//     };
//
//     struct v2f
//     {
//      float2 uv1 : TEXCOORD0;
//      float2 uv2 : TEXCOORD1;
//      float4 vertex : SV_POSITION;
//      fixed4 col : COLOR;
//     };
//
//     sampler2D _MainTex;
//     sampler2D _DispTex;
//     float4 _MainTex_ST;
//     float4 _DispTex_ST;
//     float _Speed;
//     float _Intensity;
//     
//     v2f vert (appdata v)
//     {
//      v2f o;
//      o.vertex = UnityObjectToClipPos(v.vertex);
//      o.uv1 = TRANSFORM_TEX(v.uv, _DispTex);
//      o.uv2 = TRANSFORM_TEX(v.uv, _MainTex);
//      o.col = v.vertexColor;
//      return o;
//     }
//     
//     fixed4 frag (v2f i) : SV_Target
//     {
//      float t = _Time.y * _Speed;
//      fixed disp = tex2D(_DispTex, i.uv1 + fixed2(t, t)).r;
//      fixed4 col = tex2D(_MainTex, i.uv2 + disp * _Intensity);
//      return col * i.col;
//     }
//
//     ENDCG
//    }
//   }
}

