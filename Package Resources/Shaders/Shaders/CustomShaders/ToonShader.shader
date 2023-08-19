Shader "MUGCUP Custom Shaders/Unlit/Toon Unlit Shader"
{
    Properties
    {
        _Color       ("Main color"   , Color) = (1.0, 1.0, 1.0, 1.0)
        _AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"     = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
        }
         
        Cull Back

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // #pragma prefer_hlslcc gles
            // #pragma exclude_renderers d3d11_9x
            // #pragma target 2.0
            // #pragma shader_feature _ALPHATEST_ON
            // #pragma shader_feature _ALPHAPREMULTIPLY_ON

            //#include "UnityCG.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex      : SV_POSITION;
                float3 worldNormal : NORMAL;
                float2 uv          : TEXCOORD0;
                float4 shadowCoord : TEXCOORD1;
            };

            float4 _Color;
            float4 _AmbientColor;

            v2f vert (appdata _v)
            {
                v2f _o;

                _o.vertex      = TransformObjectToHClip(_v.vertex);
                _o.worldNormal = TransformObjectToWorldNormal(_v.normal);
                
                const VertexPositionInputs _vertexInput = GetVertexPositionInputs(_v.vertex.xyz);
                _o.shadowCoord = GetShadowCoord(_vertexInput);

                return _o;
            }

            float4 frag (v2f _i) : SV_Target
            {
                float3 _normal = normalize(_i.worldNormal);

                const Light _mainLight = GetMainLight(_i.shadowCoord);
                const float _NdotL     = dot(_mainLight.direction, _normal);
                
                return _Color * (step(0, _NdotL) + _AmbientColor);
            }
            ENDHLSL
        }
    }
}
