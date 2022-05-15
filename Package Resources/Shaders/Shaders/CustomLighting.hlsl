#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

struct CustomLightingData
{
	float3 normalWS;
	float3 albedo  ;
};

#ifndef SHADERGRAPH_PREVIEW 
float3 CustomLightHandling(CustomLightingData d, Light light) {

	float3 radiance = light.color;

	float diffuse = saturate(dot(d.normalWS, light.direction));

	float3 color = d.albedo * radiance * diffuse;

	return color;
}
#endif

float3 CalculateCustomLighting(CustomLightingData d)
{
	#ifdef SHADERGRAPH_PREVIEW 
	
		float3 lightDir = float3(0.5, 0.5, 0);
		float intensity = saturate(dot(d.normalWS, lightDir));
		return d.albedo * intensity;
	
	#else
	
		Light mainLight = GetMainLight();

		float3 color = 0;
		
		color += CustomLightHandling(d, mainLight);

	return color;
	
	#endif
}

void MainLight_float (out float3 Direction, out float3 Color, out float DistanceAtten)
{
	#ifdef SHADERGRAPH_PREVIEW
		Direction = normalize(float3(1,1,-0.4));
		Color     = float4(1,1,1,1);
		DistanceAtten = 1;
	#else
	
		Light mainLight = GetMainLight();
	
		Direction     = mainLight.direction;
		Color         = mainLight.color;
		DistanceAtten = mainLight.distanceAttenuation;
	#endif
}

void CalculateCustomLighting_float(float3 Normal, float3 Albedo, out float3 Color)
{
	CustomLightingData d;
	
	d.normalWS = Normal;
	d.albedo   = Albedo;

	Color = CalculateCustomLighting(d);
}
#endif