#include <UnityShaderVariables.cginc>
#ifndef INVERTSCREEN_INCLUDED
#define INVERTSCREEN_INCLUDED

void InvertScreen_float(float2 uv, out float2 output)
{
    output = uv;
    if (_ProjectionParams.x >= 0)
        output.y = 1 - output.y;
}
#endif 