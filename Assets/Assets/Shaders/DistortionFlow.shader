Shader "Custom/DistortionFlow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _FlowMap ("Flow (RG and Noise)", 2D) = "black" {}
        [NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
        [NoScaleOffset] _DerivHeightMap ("Deriv (AG) Height (B)", 2D) = "black" {}
        _UJump ("U Jump per phase", Range(-0.25, 0.25)) = 0.25
        _VJump ("V Jump per phase", Range(-0.25, 0.25)) = 0.25
        _Tiling ("Tiling", Float) = 1
        _Speed ("Speed", Float) = 1
        _FlowStrength ("Flow Strength", Float) = 1
        _FlowOffset("Flow Offset", Float) = 0
        _HeightScale("Height Scale, Constant", Float) = 0.25
        _HeightScaleModulated("Height Scale, Modlulated", Float) = 0.75
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        _WaterFogColor("Water Fog Colour", Color) = (0,0,0,0)
        _WaterFogDensity("Water Fog Density", Range(0,2)) = 0.5
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 200

        GrabPass {"_WaterBackground"}
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha finalcolor:ResetAlpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "Flow.cginc"
        #include "LookingThroughWater.cginc"

        sampler2D _MainTex, _FlowMap, _NormalMap, _DerivHeightMap;
        
        float _UJump, _VJump, _Tiling, _Speed, _FlowStrength, _FlowOffset;
        float _HeightScale, _HeightScaleModulated;
        
        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
        };
        void ResetAlpha(Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
            color.a= 1;
        }
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float3 UnpackDerivativeHeight(float4 textureData)
        {
            float3 dh = textureData.agb;
            dh.xy = dh.xy * 2 - 1;
            return dh;
        }
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 flowVector = tex2D(_FlowMap, IN.uv_MainTex).rg * 2-1;
            flowVector.xy = flowVector.xy * 2 - 1;
            flowVector *= _FlowStrength;
            float noise = tex2D(_FlowMap, IN.uv_MainTex).a;
            float time = _Time.y * _Speed + noise;
            float2 jump = float2(_UJump,_VJump);
            
            float3 uvwA = FlowUVW(IN.uv_MainTex, flowVector.xy, jump,_FlowOffset, _Tiling, time, false);
            float3 uvwB = FlowUVW(IN.uv_MainTex, flowVector.xy, jump,_FlowOffset, _Tiling, time, true);

            float finalHeightScale = (flowVector * _HeightScaleModulated) + (_HeightScale);

             float3 dhA = UnpackDerivativeHeight(tex2D(_DerivHeightMap,uvwA.xy)) * (uvwA.z * finalHeightScale);
            float3 dhB = UnpackDerivativeHeight(tex2D(_DerivHeightMap,uvwB.xy)) * (uvwB.z * finalHeightScale);
            o.Normal = normalize(float3(-(dhA.xy + dhB.xy),1));
            
           // float3 normalA = UnpackNormal(tex2D(_NormalMap,uvwA.xy)) * uvwA.z;
          //  float3 normalB = UnpackNormal(tex2D(_NormalMap,uvwB.xy)) * uvwB.z;
            //o.Normal = normalize(normalA + normalB);

            
            // Albedo comes from a texture tinted by color
            fixed4 texA = tex2D (_MainTex, uvwA.xy)* uvwA.z;
            fixed4 texB = tex2D (_MainTex, uvwB.xy)* uvwB.z;

            fixed4 c = (texA + texB) * _Color;
            o.Albedo = c.rgb;
           
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

           // o.Albedo = ColorBelowWater(IN.screenPos);
           // o.Alpha = 0.1;

            o.Emission = ColorBelowWater(IN.screenPos) * (1-c.a);
        }
        ENDCG
    }
    
}
