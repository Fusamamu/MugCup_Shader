#ifndef SDF_2D_LIB
#define SDF_2D_LIB

float2 Translate(float2 pos, float2 offset)
{
    return pos - offset;
}

float2 Rotate(float2 pos, float rotation)
{
    const float PI = 3.14159;
    float angle = rotation * PI * 2 * -1;
    
    float sine, cosine;
    sincos(angle, sine, cosine);

    float x = cosine * pos.x + sine * pos.y;
    float y = cosine * pos.y - sine * pos.x;
    
    return float2(x, y);
}

float2 RotateMatrix(float2 pos, float rotation)
{
    const float PI = 3.14159;
    float angle = rotation * PI * 2 * -1;

    float s = sin(angle);
    float c = cos(angle);

    float2x2 rotationMat = float2x2(c, s, -s, c);

    float2 newPos = mul(rotationMat, pos);

    return newPos;
}

float Circle(float2 pos, float radius)
{
    return length(pos) - radius;
}

//rectSize - Full rectangle size. 
float AABoxSDF(float2 pos, float2 rectSize)
{
    float2 dist = abs(pos) - rectSize * 0.5;
    
    float outsideDist = length(max(dist, 0));
    float insideDist  = min(max(dist.x, dist.y), 0);
    
    return outsideDist + insideDist;
}

float AABoxSDFOutside(float2 pos, float2 rectSize)
{
    float2 dist = abs(pos) - rectSize * 0.5;
    
    float outsideDist = length(max(dist, 0));

    return outsideDist;
}

float AABoxSDFInside(float2 _pos, float2 _rectSize)
{
    float2 _dist = abs(_pos) - _rectSize * 0.5;

    float _insideDist  = length(min(max(_dist.x, _dist.y), 0));

    return _insideDist;
}

float AABoxSDFRounded(float2 _pos, float2 _rectSize, float _rounding)
{
    float2 _dist = abs(_pos) - _rectSize * 0.5 + _rounding;
    
    float _outsideDist = length(max(_dist, 0));
    float _insideDist  = min(max(_dist.x, _dist.y), 0);
    
    return _outsideDist + _insideDist - _rounding;
}

float AABoxSDF_Separate_Rounded_Corner(float2 _pos, float2 _rectSize, float4 _rounding)
{
    float2 _roundingHorizontal = (_pos.x > 0.0) ? _rounding.xw          : _rounding.yz         ;
    float  _roundingFinal      = (_pos.y > 0.0) ? _roundingHorizontal.x : _roundingHorizontal.y;
    
    float2 _dist = abs(_pos) - _rectSize * 0.5 + _roundingFinal;
    
    float _outsideDist = length(max(_dist, 0));
    float _insideDist  = min(max(_dist.x, _dist.y), 0);
    
    return _outsideDist + _insideDist - _roundingFinal;
}

//Not working
float AABoxSDF_Separate_Rounded_Corner_Inside(float2 _pos, float2 _rectSize, float4 _rounding)
{
    float2 _roundingHorizontal = (_pos.x > 0.0) ? _rounding.xw          : _rounding.yz         ;
    float  _roundingFinal      = (_pos.y > 0.0) ? _roundingHorizontal.x : _roundingHorizontal.y;
    
    float2 _dist = abs(_pos) - _rectSize * 0.5 + _roundingFinal;
    
    float _insideDist = length(min(max(_dist.x, _dist.y), 0));
    
    return _insideDist - _roundingFinal;
}

float AABoxSDFRoundedOutside(float2 pos, float2 rectSize, float rounding)
{
    float outsideDist = AABoxSDFOutside(pos, rectSize);
    float roundedDist = outsideDist - rounding;

    return roundedDist;
}

float Union(float shape1, float shape2)
{
    return min(shape1, shape2);
}

float Intersect(float shape1, float shape2)
{
    return max(shape1, shape2);
}

float Subtract(float base, float subtraction)
{
    return Intersect(base, -subtraction);
}


#endif
