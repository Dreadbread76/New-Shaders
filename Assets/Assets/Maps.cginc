
#pragma vertex vert
#pragma fragment frag


#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING
struct appdata
{
    
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    float4 tangent : TANGENT;

};

struct v2f
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 tangent : TEXCOORD2;
    float3 bitangent : TEXCOORD3;
    float3 wPos : TEXCOORD4;
    LIGHTING_COORDS(5,6)
};
sampler2D _Albedo;
float4 _Albedo_ST;
sampler2D _MainTex;
sampler2D _Normals;
float4 _MainTex_ST;
float _Gloss;
float4 _Color;
float _glowMag;
float _glowFreq;
float _NormalIntensity;

v2f vert(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.bitangent = cross(o.normal, o.tangent);

    TRANSFER_VERTEX_TO_FRAGMENT(o);
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    float3 albedo = tex2D(_Albedo, i.uv).rgb;
    float3 surfaceColor = albedo * _Color.rgb;


    float3 tangentSpaceNormal = UnpackNormal(tex2D(_Normals, i.uv));
    tangentSpaceNormal = normalize(lerp(float3(0,0,1),tangentSpaceNormal,_NormalIntensity));
    float3x3 mtxTangToWorld =
    {
        i.tangent.x, i.bitangent.x, i.normal.x,
        i.tangent.y, i.bitangent.y, i.normal.y,
        i.tangent.z, i.bitangent.z, i.normal.z
    };
    float3 N = mul(mtxTangToWorld, tangentSpaceNormal);
  //  return float4(surfaceColor,0);

    
    #ifdef USE_LIGHTING
    //diffuse lighting
    //float3 N = normalize(i.normal);
    float3 L = normalize(UnityWorldSpaceLightDir(i.wPos));
    float attenuation = LIGHT_ATTENUATION(i);
    
    float3 lambert = saturate(dot(N,L));
    float3 diffuseLight = lambert * attenuation * _LightColor0.xyz;
    

    //specular lighting
    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
    //float3 R = reflect(-L, N);
    float3 H = normalize(L + V);
    

    
    float3 specularLight = saturate(dot(H, N));
    float specularExponent = exp2(_Gloss * 11) + 2;
    specularLight = pow(specularLight, specularExponent) * _Gloss;
    specularLight *= _LightColor0.xyz;

    return float4(diffuseLight * surfaceColor + specularLight, 1);

   
#else
               
    #ifdef IS_IN_BASE_PASS
    return _Color;
    #else
    return  0;
    #endif               //   return float4(diffuseLight,1);
#endif
                    //    return float4(H,1);
}
                                  