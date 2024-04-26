Shader "Custom/EffectShader"
{
    Properties
    {
        [NoScaleOffset]

        _MainTex ("Texture", 2D) = "white" {}
        _Iterations ("Iterations", Range(1, 10)) = 4


        _DC_Offset_R ("DC Offset Red", Range(-3.141, 3.1384)) = 0.5
        _DC_Offset_G ("DC Offset Green", Range(-3.141, 3.1384)) = 0.5
        _DC_Offset_B ("DC Offset Blue", Range(-3.141, 3.1384)) = 0.5

        _Amplitude_R ("Amplitude Red", Range(-3.141, 3.1384)) = 0.5
        _Amplitude_G ("Amplitude Green", Range(-3.141, 3.1384)) = 0.5
        _Amplitude_B ("Amplitude Blue", Range(-3.141, 3.1384)) = 0.5

        _Frequency_R ("Frequency Red", Range(-3.141, 3.1384)) = 0.5
        _Frequency_G ("Frequency Green", Range(-3.141, 3.1384)) = 0.5
        _Frequency_B ("Frequency Blue", Range(-3.141, 3.1384)) = 0.5

        _Phase_R ("Phase Red", Range(-3.141, 3.1384)) = 0.5
        _Phase_G ("Phase Green", Range(-3.141, 3.1384)) = 0.5
        _Phase_B ("Phase Blue", Range(-3.141, 3.1384)) = 0.5

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
            // Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
            #pragma exclude_renderers d3d11 gles
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            int _Iterations;
            float _DC_Offset_R;
            float _DC_Offset_G;
            float _DC_Offset_B;

            float _Amplitude_R;
            float _Amplitude_G;
            float _Amplitude_B;

            float _Frequency_R;
            float _Frequency_G;
            float _Frequency_B;

            float _Phase_R;
            float _Phase_G;
            float _Phase_B;

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
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed3 palette(float t)
            {
                fixed3 dc_offset = fixed3(_DC_Offset_R, _DC_Offset_G, _DC_Offset_B);
                fixed3 amplitude = fixed3(_Amplitude_R, _Amplitude_G, _Amplitude_B);
                fixed3 frequency = fixed3(_Frequency_R, _Frequency_G, _Frequency_B);
                fixed3 phase = fixed3(_Phase_R, _Phase_G, _Phase_B);

                return dc_offset + amplitude * cos(6.28318*(frequency + phase  + t));
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed2 fragCoord = IN.uv.xy;
                
                IN.uv -= .5;
                IN.uv *= 2;
                IN.uv.x = (IN.uv.x * _ScreenParams.xy) / _ScreenParams.y;

                fixed2 uv0 = IN.uv;

                fixed3 finalColor = fixed3(0,0,0);

                for(float i = 0; i < _Iterations; i++) {

                    IN.uv = frac(IN.uv * 2) - .5;
    
                    float dist = length(IN.uv) * exp(-length(uv0));
                    // dist -= 0.5;
                    fixed3 color = palette(length(uv0) + i*.4 + _Time*_Color_Speed);
    
                    dist = sin(dist * 8.0 + _Time*_Propogation_Speed)/8.0;
                    dist = abs(dist);
    
                    dist = pow(.01 / dist, 2);
    
                    finalColor += color * dist;
                }

                return fixed4(finalColor, 1);;
            }
            ENDCG
        }
    }
}
