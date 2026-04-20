Shader "OSL/Processors/MasterBus (CRT)"
{
    Properties
    {
        [NoScaleOffset] OSL_DmxTable("Dmx Table", 2D) = "black" {}

        [NoScaleOffset] OSL_GlobalTimerTex("Global Timer", 2D) = "black" {}

        [NoScaleOffset] _IcbTex("ICB Texture", 2D) = "black" {}
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
            #include "Packages/com.osl.core/Runtime/Shaders/Internal/Connectors/Fields.cginc"
            #include "Packages/com.osl.core/Runtime/Shaders/Internal/Connectors/Processors.hlsl"
            #include "Encode.cginc"
            #include "Decode.cginc"
            #include "Links.cginc"

            Texture2D<fixed4> OSL_DmxTable;
            Texture2D<uint4> _IcbTex;

            Texture2D<uint4> _SelfTexture2D;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                nointerpolation float4 gt : TEXCOORD1;
            };


            v2f vert(CRT_INPUT_ARGS)
            {
                v2f o;

                crt_v2f _v2f = crt_vert(CRT_VID);

                o.vertex = _v2f.vertex;
                o.uv = _v2f.crt_uv.xy * float2(16.0, 16.0);

                o.gt = OSL_sampleGlobalTimer();

                return o;
            }

            // TODO: REPLACE THIS
            uint2 NextMortonIndex(uint2 index)
            {
                uint2 mask = index ^ (index + 1);
                return index ^ uint2(mask.x & mask.y, (mask.x >> 1) & mask.y);
            }

            inline uint callProc(fixed2 dmx_raw, uint2 dmx_last, uint2 last_proc, uint dmx_offset, uint icb, float4 gt)
            {
                OSL_DmxProcessorFields fields = (OSL_DmxProcessorFields)0;

                fields.dmx_raw.xy = (uint2)(dmx_raw * 255.0);
                fields.dmx_raw.zw = dmx_last;

                fields.dmx_norm.xy = dmx_raw.xy;
                fields.dmx_norm.zw = ((float2)dmx_last) / 255.0;

                fields.dmx_channel = dmx_offset;

                fields.proc_id = icb & 0xFF;
                fields.icb_value = icb >> 8u;

                fields.last_result.xy = last_proc.xy;

                fields.gt = gt;
                fields.global_time = gt.r;
                fields.global_dt = gt.g;
                fields.global_idt = gt.b;
                fields.global_last_dt = gt.a;

                return OSL_callProcessor(fields);
            }

            uint4 frag(v2f i) : SV_Target
            {
                uint4 crt_result = 0;

                // Get the previous MasterBus values for this pixel
                uint3 crt_pos = uint3(i.uv, 0);
                uint4 crt_last = _SelfTexture2D.Load(crt_pos);

                // Get the DMX offset for this pixel
                uint dmx_offset = OSL_busPosToDmxChannel(crt_pos.xy);

                // Encode the raw DMX channels
                fixed4 dmx_values = OSL_DmxTable.Load(crt_pos);
                crt_result.r = OSL_encodeTrack4xU8(dmx_values * 255.0);

                // Get the previous DMX values
                uint4 last_raw = OSL_decodeTrackRaw4xU8(crt_last.r);

                // Get the previous 16-bit processor values
                uint4 last_p16 = uint4(
                    crt_last.g & 0xFFFF,
                    crt_last.g >> 16u,
                    crt_last.b & 0xFFFF,
                    crt_last.b >> 16u
                );

                // Get the previous 32-bit processor values
                uint4 last_p32 = uint4(
                    crt_last.g,
                    (crt_last.g >> 16u) | (crt_last.b << 16u),
                    crt_last.b,
                    (crt_last.b >> 16u) | (crt_last.a << 16u)
                );

                // Load the indexed constant buffer values
                uint4 icb_raw = _IcbTex.Load(crt_pos);

                // dmx_raw.xy, dmx_last.xy, last_proc.xy, dmx_offset.x, icb.x, gt.xyzw

                uint p1 = callProc(
                    dmx_values.xy,
                    last_raw.xy,
                    uint2(last_p16.x, last_p32.x),
                    dmx_offset + 0,
                    icb_raw.x, i.gt
                );

                uint p2 = callProc(
                    dmx_values.yz,
                    last_raw.yz,
                    uint2(last_p16.y, last_p32.y),
                    dmx_offset + 1,
                    icb_raw.y, i.gt
                );

                uint p3 = callProc(
                    dmx_values.zw,
                    last_raw.zw,
                    uint2(last_p16.z, last_p32.z),
                    dmx_offset + 2,
                    icb_raw.z, i.gt
                );

                // Get the DMX value of ch+4
                uint3 adv_pos = uint3(NextMortonIndex(crt_pos.xy).xy, crt_pos.z);
                uint adv_raw = _SelfTexture2D.Load(adv_pos).r & 0xFF;
                fixed adv_value = OSL_DmxTable.Load(adv_pos).r;

                uint p4 = callProc(
                    fixed2(dmx_values.w, adv_value),
                    uint2(last_raw.w, adv_raw),
                    uint2(last_p16.w, last_p32.w),
                    dmx_offset + 3,
                    icb_raw.w, i.gt
                );

                crt_result.g |= p1;             // (C1/C2) | C1
                crt_result.g |= (p2 << 16u);    // (C2/C3) | C2
                crt_result.b |= p3;             // (C3/C4) | C3
                crt_result.b |= (p4 << 16u);    // (C3/C4) | C4

                crt_result.b |= (p2 >> 16u);    // (C2/C3)
                crt_result.a |= (p4 >> 16u);    // (C3/C4)

                return crt_result;
            }

            ENDCG
        }
    }
}