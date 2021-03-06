#if !defined(LOOKING_THROUGH_WATER_INCLUDED)
#define LOOKING_THROUGH_WATER_INCLUDED

sampler2D _CameraDepthTexture, _WaterBackground;
float4 _CameraDepthTexture_TexelSize;
float3 _WaterFogColor;
float _WaterFogDensity;
float _RefractionStrength;

float2 _AlignWithGrabTexel(float2 uv)
{
   
    #if UNITY_UV_STARTS_AT_TOP
    {
        if (_CameraDepthTexture_TexelSize.y < 0)
        {
            uv.y = 1 -uv.y;
        }
    }
    #endif
    return (floor(uv * _CameraDepthTexture_TexelSize.zw)+ 0.5)* abs(_CameraDepthTexture_TexelSize.xy);
}


float3 ColorBelowWater(float4 screenPos, float3 tangentSpaceNormal)
{
    float2 uvOffset = tangentSpaceNormal.xy * _RefractionStrength;
    uvOffset.y *= _CameraDepthTexture_TexelSize.z * abs( _CameraDepthTexture_TexelSize.y);
    float2 uv = _AlignWithGrabTexel((screenPos.xy + uvOffset)/ screenPos.w);
    #if UNITY_UV_STARTS_AT_TOP
    if (_CameraDepthTexture_TexelSize.y < 0)
    {
        uv.y = 1 -uv.y;
    }
    #endif
    
    float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
    float surfaceDepth =  UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
    float depthDifferent = backgroundDepth - surfaceDepth;
    
   uvOffset *= saturate(depthDifferent);
   uv = _AlignWithGrabTexel((screenPos.xy + uvOffset)/screenPos.w);
      
        
   backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,uv));
   depthDifferent = backgroundDepth - surfaceDepth;
        
    
    float3 backgroundColour = tex2D(_WaterBackground, uv).rgb;
    float fogFactor = exp2(-_WaterFogDensity * depthDifferent);
    
    return lerp(_WaterFogColor, backgroundColour,fogFactor);
    
}
#endif