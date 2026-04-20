#ifndef OSL_MASTERBUS_DECODE_INCLUDED
#define OSL_MASTERBUS_DECODE_INCLUDED

#include "Packages/com.osl.core/Runtime/Shaders/Internal/Common/Inputs.cginc"
#include "Links.cginc"

#ifdef OSL_SURFACE_SHADER
    // Dummy value for mojo shader to not complain
    #define OSL_sampleMasterBusPixel(POS) uint4(0,0,0,0)
#else
    #define OSL_sampleMasterBusPixel(POS) OSL_MasterBusTex.Load(uint3((POS).xy, 0))
#endif //OSL_SURFACE_SHADER

uint4 OSL_decodeTrackRaw4xU8(uint v)
{
    uint4 cells = v.xxxx;
    cells.yzw >>= uint3(8,16,24);
    return cells & 0xFF;
}

float4 OSL_decodeTrack4xU8(uint v)
{
    uint4 cells = v.xxxx;
    cells.yzw >>= uint3(8,16,24);
    return saturate(float4(cells & 0xFF) / 255.0);
}

float2 OSL_decodeTrack2xU16(uint v)
{
    uint2 cells = v.xx;
    cells.y >>= 16;
    return saturate(float2(cells & 0xFFFF) / 65535.0);
}


float4 OSL_channelTo4xMask(uint channel)
{
    uint4 masks = uint4(8,4,2,1) << (channel & 3u);
    return float4((masks >> 3u) & 1u);
}

float OSL_valueFromTrack4xU8(uint channel, float4 values)
{
    return dot(OSL_channelTo4xMask(channel), values);
}
float OSL_valueFromTrack4xU8(uint channel, uint v)
{
    v >>= (channel & 3u) * 8u;
    return saturate(float(v & 0xFF) / 255.0);
}

float OSL_valueFromTrack2xU16(uint channel, float2 values)
{
    return lerp(values.x, values.y, channel & 1u);
}
float OSL_valueFromTrack2xU16(uint channel, uint v)
{
    v >>= (channel & 1u) * 16u;
    return saturate(float(v & 0xFFFF) / 65535.0);
}

#endif //OSL_MASTERBUS_DECODE_INCLUDED