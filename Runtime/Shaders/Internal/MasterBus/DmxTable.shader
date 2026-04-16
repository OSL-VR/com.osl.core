Shader "OSL/Processors/DmxTable (CRT)"
{
    Properties
    {
        _StreamTex("Stream Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags
        {
            "Queue"="Background-998"
            "PreviewType"="Skybox"
        }

        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            Name "OSL/DmxTable"
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.osl.core/Runtime/Shaders/Internal/Common/CRTStandard2D.cginc"
            #include "Packages/com.osl.core/Runtime/Shaders/Internal/Connectors/DmxDecoders.hlsl"
            #include "Links.cginc"

            Texture2D _StreamTex;
            float4 _StreamTex_ST;
            float4 _StreamTex_TexelSize;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float sampleDmx(uint channel)
            {
                OSL_DmxDecoderFields fields;

                fields.dmx_channel = channel;
                fields.mb_size = 32u;
                fields.stream = _StreamTex;
                fields.stream_st = _StreamTex_ST;
                fields.stream_texelsize = _StreamTex_TexelSize;

                return OSL_decodeDmxChannel(fields);
            }

            v2f vert(CRT_INPUT_ARGS)
            {
                v2f o;

                crt_v2f _v2f = crt_vert(CRT_VID);

                o.vertex = _v2f.vertex;
                o.uv = _v2f.crt_uv.xy * float2(32.0, 32.0);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                uint dmx_offset = OSL_busPosToDmxChannel(uint2(i.uv.xy));

                // [Modules/DmxDecoders]:
                // Decode the dmx texture into raw dmx values
                float4 dmx_raw = float4(
                    sampleDmx(dmx_offset + 0),
                    sampleDmx(dmx_offset + 1),
                    sampleDmx(dmx_offset + 2),
                    sampleDmx(dmx_offset + 3)
                );

                return dmx_raw;
            }
            ENDCG
        }
    }
}