Shader "OSL/Processors/MasterBus (CRT)"
{
    Properties
    {
        [NoScaleOffset] OSL_DmxTable("Dmx Table", 2D) = "black" {}

        [NoScaleOffset] OSL_GlobalTimerTex("Global Timer", 2D) = "black" {}
    }
    SubShader
    {
        Tags
        {
            "Queue"="Background-997"
            "PreviewType"="Skybox"
        }

        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            Name "OSL/MasterBus"
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
            // #pragma enable_d3d11_debug_symbols
            #include "Packages/com.osl.core/Runtime/Shaders/Internal/Common/CRTStandard2D.cginc"
            #include "Packages/com.osl.core/Runtime/Shaders/Internal/GlobalTimer/Read.cginc"
            #include "Encode.cginc"

            Texture2D<fixed4> OSL_DmxTable;

            Texture2D<uint4> _SelfTexture2D;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(CRT_INPUT_ARGS)
            {
                v2f o;

                crt_v2f _v2f = crt_vert(CRT_VID);

                o.vertex = _v2f.vertex;
                o.uv = _v2f.crt_uv.xy * float2(32.0, 32.0);

                return o;
            }

            uint4 frag(v2f i) : SV_Target
            {
                uint4 crt_result = 0;

                // Get the previous MasterBus values for this pixel
                uint3 crt_pos = uint3(i.uv, 0);
                uint4 crt_last = _SelfTexture2D.Load(crt_pos);

                fixed4 dmx_raw = OSL_DmxTable.Load(crt_pos);

                // STATIC: Encode the channel values
                crt_result.r = OSL_encodeTrack4xU8(dmx_raw * 255.0);

                return crt_result;
            }

            ENDCG
        }
    }
}