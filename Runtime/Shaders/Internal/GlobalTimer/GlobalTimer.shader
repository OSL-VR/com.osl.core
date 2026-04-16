Shader "OSL/Processors/GlobalTimer (CRT)"
{
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Tags
        {
            "Queue"="Background-999"
            "PreviewType"="Skybox"
        }

        Pass
        {
            Name "GlobalTimer"
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.osl.core/Runtime/Shaders/Internal/Common/CRTStandard2D.cginc"

            Texture2D<float4> _SelfTexture2D;

            float4 vert(CRT_INPUT_ARGS) : SV_POSITION
            {
                crt_v2f _v2f = crt_vert(CRT_VID);
                return _v2f.vertex;
            }

            float4 frag(float4 vertex : SV_POSITION) : SV_Target
            {
                float t = _Time.y;

                // r: Time of the previous frame
                // g: Delta time of previous frame
                float2 last = _SelfTexture2D.Load(0).rg;

                // t | dt | 1/dt | last dt
                return float4(t, t - last.r, 1.0 / (t - last.r), last.g);
            }

            ENDCG
        }
    }
}