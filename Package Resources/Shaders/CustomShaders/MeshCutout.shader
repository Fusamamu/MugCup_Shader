Shader "Unlit/MeshCutout"
{
    Properties
    {
        [IntRange] _StencilID ("Stencil ID", Range(0, 255)) = 0
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"     = "Opaque" 
            "RenderPipeline" = "UniversalPipeline"
            "Queue"          = "Geometry"
        }

        Pass
        {
            Blend zero one
            ZWrite off
            
            Stencil
            {
                Ref [_StencilID]
                Comp Always
                Pass Replace
                Fail Keep
            }
        }
    }
}
