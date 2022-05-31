Shader "MUGCUP Custom Shaders/Unlit/Overlap"
{
    Properties
    {
        _MainTex ("Albedo", 2D)  = "white" { }
        _Color   ("Color",Color) = (0.0, 0.0, 1.0, 0.1)
    }
    
    SubShader
    {
        Tags 
        {
            "Queue"           = "Transparent" 
            "IgnoreProjector" = "true" 
            "RenderType"      = "Transparent"
        }
        
        ZWrite Off 
        Blend SrcAlpha OneMinusSrcAlpha 
        Cull Off

        LOD 100

        Pass
        {
//            Stencil 
//            {
//                Ref 0
//                Comp Equal
//                Pass IncrSat 
//                Fail IncrSat 
//            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _ _RENDERING_CUTOUT _RENDERING_FADE

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _Color;

            struct appdata
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct v2f
            {
                float4 vertex  : SV_POSITION;
                half2 texcoord : TEXCOORD0;
                fixed4 color : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.color    = v.color;
                o.texcoord = v.texcoord;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 tex = tex2D(_MainTex, i.texcoord);

                //float _dis = saturate(distance(float2(0.5, 0.5), i.texcoord) - 0);

                //_dis = 1 - _dis;

                //float4 r = float4(_dis, _dis, _dis, _dis);

                //float alpha = r.a;
	            //clip(alpha - 0.5);

                fixed4 col = tex * _Color;
                
                return col;
            }
            ENDCG
        }
    }
}
