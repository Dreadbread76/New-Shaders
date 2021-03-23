Shader "Assets/UnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA ("The color", Color) = (1,0,0,1)
        _ColorB ("The color", Color) = (0,1,1,1)
        _ColorStart ("Color Start", Range(0,1)) = 1
        _ColorEnd ("Color End", Range(0,1)) = 0
        _Scale ("UV Scale", float) = 1 
        _Offset ("UV Offset", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
      //  LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION; //Vertex position
              //  float3 normals : NORMAL;  //vertex normal
              float2 uv : TEXCOORD0;  //uv0 diffuse/normal
               // float2 uv1 : TEXCOORD1; //
            };

            struct v2f
            {
               float2 uv : TEXCOORD0;
                
                float4 vertex : SV_POSITION;
              //  float3 normal : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            float4 _MainTex_ST;
            float _Scale;
            float _Offset;

            v2f vert (MeshData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
               // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
               // o.normal = v.normals;
             //   o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = (v.uv + _Offset) *_Scale;
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }
            
            float4 frag (v2f i) : SV_Target
            {

                //float t = InverseLerp(_ColorStart, _ColorEnd, i.uv.x);

                float t = abs(frac(i.uv.x *5) * 2 - 1);

             //   t= frac(t);

                return t.xxxx;
                
                //lerp
                float4 outColor = lerp(_ColorA, _ColorB, t);
                // sample the texture
                //float4 col = float4(outColor); //float4(i.uv, 0,1);
                //return col;
                return outColor;
                
            }
            ENDCG
        }
    }
}
