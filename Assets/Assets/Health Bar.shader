//slider property from 0 to 1
//change colour depending on health

Shader "Unlit/Health Bar"
{
    Properties
    {
        [NoScaleOffset]
        _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1
        _Chunks ("Chunks", Range(0,1)) = 1
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
          

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Health;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            float InverseLerp(float a, float b, float v) 
            {
                return(v - a) / (b - a);
            }
            fixed4 frag(v2f i) : SV_Target
            {
                float3 healthBarColour = tex2D(_MainTex, float2(_Health, i.uv.y));
                //return float4 (1,0,0,i.uv.x);
                //Set up colours
                //float tHealthColour = saturate(InverseLerp(0.2,0.8, _Health));
                //float3 healthBarColour = lerp(float3(1,0,0) , float3(0,1,0), tHealthColour);
                //float3 bgColour = float3(0, 0, 0);

                //Mask
                float healthBarMask = _Health > i.uv.x;//floor(i.uv.x * _Chunks)/_Chunks;

                float minFlashHealth = floor(0.3f > _Health);

                float flash = minFlashHealth * cos(_Time.y * 4) * 0.1f;
                return float4(healthBarColour +  flash.xxx,healthBarMask);
                //clip(healthBarMask - 0.0001);

                //float3 outColour = lerp(bgColour, healthBarColour, healthBarMask);

                return float4(healthBarColour.rgb * healthBarMask, 1);
                // sample the texture
              //fixed4 col = tex2D(_MainTex, i.uv);
               // float healthBarMask = _Health < i.uv.x;
               // return healthBarMask;
               // return i.uv.x;
            }
            ENDCG
        }
    }
}
