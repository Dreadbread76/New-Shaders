Shader "Unlit/LightingMulti"
{
Properties
{
	_Albedo ("Albedo", 2D) = "white" {}
	[NoScaleOffset]_Normals("Normals",2D) = "Bump" {}
	
	_Gloss("Gloss", Range(0,1)) = 1
	_Color("Color", Color) = (1,1,1,1)
	_glowMag("glowMag", Range(0,1)) = 0.5
	_glowFreq("glowFreq", Range(0,1)) = 0.5
	_NormalIntensity("NormalIntensity", Range (0,1)) = 0.5
}
		
SubShader
		{
			Tags { "RenderType" = "Opaque" }
			Pass
			{
				Tags {"Lightmode" = "ForwardBase"}
				CGPROGRAM
				#define IS_IN_BASE_PASS
				#pragma vertex vert
				#pragma fragment frag
				#include "Maps.cginc"

				ENDCG
			}
			
				   Pass
					{
						Tags { "Lightmode" = "ForwardAdd"}
						Blend One One
						CGPROGRAM
						#pragma vertex vert
						#pragma fragment frag
						#pragma multi_compile_fwdadd
						#include "Maps.cginc"

						ENDCG  
					
					}
			
		}
}
