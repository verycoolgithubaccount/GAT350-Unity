Shader "GAT350/Fun"
{
    Properties
    {
        // All the variables and stuff
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 1)) = 1
        _MainTex ("Texture", 2D) = "white" {}
        _Bloat ("Bloat", Range(-1, 1.0)) = 0.0
        _Rate ("Rate", Range(0.1, 5)) = 1
        _StripeSpacing ("Stripe Spacing", Range(-20, 20)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float bloat;
            float _Amplitude;
            float _Rate;
            float _Bloat;
            float _Period;
            fixed4 _Color;
            float _Intensity;
            float _StripeSpacing;


            v2f vert (appdata v)
            {
                v2f o;

                bloat = abs(sin((_Time.y * _Rate))) * _Bloat; // set the bloat variable to expand and contract scaled by the _Bloat slider

                v.vertex.xyz = v.vertex.xyz + v.normal.xyz * bloat; // apply the bloat

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float stripes = abs(sin(i.uv.y * _StripeSpacing * sin((_Time.y * _Rate)) + _Time.y * _Rate)); // horizontal stripes
                float stripes2 = abs(cos(i.uv.x * _StripeSpacing * cos((_Time.y * _Rate)) + _Time.y * _Rate)); // vertical stripes

                fixed4 color = fixed4(_Color.r * (stripes + stripes2)/2, // apply the stripes 
                                      _Color.g * (stripes + stripes2)/2, 
                                      _Color.b * (stripes + stripes2)/2 + 1/stripes, // this one is 1/stripes, it makes the stripes glow which is cool
                                      _Color.a);

                return color;
            }
            ENDCG
        }
    }
}
