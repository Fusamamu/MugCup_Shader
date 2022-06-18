#ifndef CUSTOM_TOON_SHADING_INCLUDED
#define CUSTOM_TOON_SHADING_INCLUDED

void ToonShading_float(
	in float3 Normal, in float ToonRampSmoothness, in float3 ClipSpacePos, in float3 WorldPos, in float4 ToonRampTinting, in float ToonRampOffset,
	out float3 ToonRampOutput, out float3 Direction)
{
	#ifdef SHADERGRAPH_PREVIEW
		ToonRampOutput = float3(0.5, 0.5, 0.0);
		Direction      = float3(0.5, 0.5, 0.0);
	#else
		#if SHADOWS_SCREEN
			half4 _shadowCoord = ComputeScreenPos(ClipSpacePos);
	    #else
			half4 _shadowCoord = TransformWorldToShadowCoord(WorldPos);
		#endif

		#if _MAIN_LIGHT_SHADOWS_CASCADE || _MAIN_LIGHT_SHADOWS
			Light _light = GetMainLight(_shadowCoord);
		#else
			Light _light = GetMainLight();
		#endif


		half d = dot(Normal, _light.direction) * 0.5 + 0.5;

		half toonRamp = smoothstep(ToonRampOffset, ToonRampOffset + ToonRampSmoothness, d);

		toonRamp *= _light.shadowAttenuation;

		ToonRampOutput = _light.color * (toonRamp + ToonRampTinting);

		Direction = _light.direction;
	#endif
}


#endif