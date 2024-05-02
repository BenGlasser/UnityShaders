Shader "Custom/ExperimentalShader"
{
    Properties
    {
        [NoScaleOffset]
        
        _MainTex ("Texture", 2D) = "white" {}
        
        _DC_Color ("DC Color", Color) = (1,1,1,1)
        _Amplitude_Color ("Amplitude Color", Color) = (.5,.5,.5,1)
        _Frequency_Color ("Frequency Color", Color) = (.5,.5,.5,1)
        _Phase_Color ("Phase Color", Color) = (.346,.487,.632,1)
        
        _Iterations ("Iterations", Range(1, 10)) = 4

        _Color_Speed ("Color Speed", Range(0, 100)) = 4
        _Propogation_Speed ("Propogation Speed", Range(0, 100)) = 10
    }

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            int _Iterations;

            float3 _DC_Color;
            float3 _Amplitude_Color;
            float3 _Frequency_Color;
            float3 _Phase_Color;

            float _Color_Speed;
            float _Propogation_Speed;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                v.uv = ((v.uv - .5)  * _ScreenParams.xy) / _ScreenParams.y; // normalize the uv
                o.uv = v.uv * 2;

                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            float3 palette(float t)
            {
                float3 dc_offset = _DC_Color.rgb;
                float3 amplitude = _Amplitude_Color.rgb;
                float3 frequency = _Frequency_Color.rgb;
                float3 phase = _Phase_Color.rgb;

                return dc_offset + amplitude * cos(6.28318*(frequency + phase  + t));
            }

            float2 rotate(float2 uv, float angle)
            {
                return float2(uv.x * cos(angle) - uv.y * sin(angle), uv.x * sin(angle) + uv.y * cos(angle));
            }

            float2 zoom(float2 uv, float zoom)
            {
                return zoom * sin(uv.xy);
            }

            float4 frag (v2f IN) : SV_Target
            {
                float2 uv0 = IN.uv;

                IN.uv.xy = rotate(IN.uv, _Time);
                
                IN.uv.xy = zoom(IN.uv, sin(_Time * 1.5));

                float3 finalColor = float3(0,0,0);

                for(float i = 0; i < _Iterations; i++) {

                    IN.uv = frac(IN.uv * 2) - .5;
    
                    float dist = length(IN.uv) * exp(-length(uv0));

                    float3 color = palette(length(uv0) + i*.4 + _Time*_Color_Speed);
    
                    dist = sin(dist * 8.0 + _Time*_Propogation_Speed)/8.0;
                    dist = abs(dist);
                    dist = pow(.01 / dist, 2);
    
                    finalColor += color * dist;
                }

                return float4(finalColor, 1);;
            }
            ENDCG
        }
    }
}
