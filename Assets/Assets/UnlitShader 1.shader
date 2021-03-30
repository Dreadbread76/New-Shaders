Shader "Assets/UnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA ("The color", Color) = (1,0,0,0)
        _ColorB ("The color", Color) = (0,1,0,1)
        _ColorC("The color", Color) = (0.5,0.5,0.5,1)
        _ColorStart ("Color Start", Range(0,1)) = 1
        _ColorMid ("Color Mid", Range(0,1)) = 0.5
        _ColorEnd ("Color End", Range(0,1)) = 0
        _Scale ("UV Scale", float) = 1 
        _Offset ("UV Offset", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" // Tag to inform the render pipeline of what type it is
        "Queue" = "Transparent"} //Changesrender order
      //  LOD 100

        Pass
        {
            Cull Off
            ZWrite Off
          // Blend DstColor Zero
           Blend One One
           // BlendOp Sub
            // Blend SrcAlpha OneMinusSrcAlpha // Traditional Transparency
             // Blend One OneMinusSrcAlpha // Premultiplied Transparency
             //Blend One One //Additive
            //Blend OneMinusDstColor One // Soft Additive
            //Blend DstColor Zero // Multiplicative
            //Blend DstColor SrcColor // 2x Multiplicative


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"
            
            struct MeshData
            {
                float4 vertex : POSITION; //Vertex position
             float3 normals : NORMAL;  //vertex normal
              float2 uv : TEXCOORD0;  //uv0 diffuse/normal
               // float2 uv1 : TEXCOORD1; //
            };

            struct v2f
            {
               float2 uv : TEXCOORD0;
                
                float4 vertex : SV_POSITION;
              float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;

            #define TAU 6.28318420718

            float4 _ColorA;
            float4 _ColorB;
            float4 _ColorC;
            float _ColorStart;
            float _ColorMid;
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
             o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = (v.uv + _Offset) *_Scale;
         
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }
            
            float4 frag(v2f i) : SV_Target
            {

                //float t = InverseLerp(_ColorStart, _ColorEnd, i.uv.x);

               // float t = abs(frac(i.uv.x *5) * 2 - 1);

             //   t= frac(t);
                

                float xOffset = cos(i.uv.x * TAU * 8) * 0.01;
            
               // float t = cos(i.uv.x * xOffset) * 0.5 + 0.5;

                float t = cos((i.uv.y + xOffset -_Time.y*0.1)* TAU * 5) * 0.5f + 0.5f;
                
                t *= 1 - i.uv.y;
                
                t *= (abs(i.normal.y) < 0.999f);

                // t *= abs(i.normal.y) < 0.999f;

                //return t.xxxx;
               
                //lerp
                float4 startColor = lerp(_ColorA, _ColorB, t);
                 float4 endColor = lerp(_ColorB, _ColorC, t);

                 float4 gradient =  lerp(startColor, endColor, i.uv.y);
                // sample the texture
               // float4 col = float4(outColor); //float4(i.uv, 0,1);
               // return col;
                return gradient * t;
                
            }
            ENDCG
        }
    }
}
