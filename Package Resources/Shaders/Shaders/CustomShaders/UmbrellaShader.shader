Shader "MUGCUP Custom Shaders/Unlit/UmbrellaShader"
{
    Properties
    {
        [Header(Splat Texture)]
        [Space(10)]
        _MainTex        ("Splat Map", 2D) = "white" {}
        _StretchAmount  ("Stretch Amount", Range(-1, 1)) = 0.0
        
        _R1("Red Channel Color"  , color) = (1.0, 1.0, 1.0, 1.0)
        _G1("Green Channel Color", color) = (1.0, 1.0, 1.0, 1.0)
        _B1("Blue Channel Color" , color) = (1.0, 1.0, 1.0, 1.0)
        _A1("Black Channel Color", color) = (1.0, 1.0, 1.0, 1.0)
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"     = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            "Queue"          = "Transparent+1"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color  : COLOR;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex    : SV_POSITION;
                float4 color     : COLOR;
                float2 uv        : TEXCOORD0;
                float2 uvSplat   : TEXCOORD1;
            };

            sampler2D _MainTex   ;
            float4    _MainTex_ST;

            float _StretchAmount;

            float4 _R1;
            float4 _G1;
            float4 _B1;
            float4 _A1;

            v2f vert (appdata _v)
            {
                v2f _o;

                float _y = _v.vertex.y + _v.color.r * _StretchAmount * 0.3f;

                float _x = _v.vertex.x * lerp(1, 0, abs(_StretchAmount) * step(0, -_StretchAmount));
                float _z = _v.vertex.z * lerp(1, 0, abs(_StretchAmount) * step(0, -_StretchAmount));

                _v.vertex.xyz = float3(_x, _y, _z);
                
                _o.vertex  = TransformObjectToHClip(_v.vertex);
                _o.uvSplat = _v.uv;
                _o.color   = _v.color;
                
                return _o;
            }

            float4 frag (v2f _i) : SV_Target
            {
                float4 splat = tex2D(_MainTex, _i.uvSplat);

                float4 _col1 =
                    _R1 * splat.r +
					_G1 * splat.g +
					_B1 * splat.b +
					_A1 * (1 - splat.r - splat.g - splat.b);
                
                return _col1;
            }
            ENDHLSL
        }
    }
}
