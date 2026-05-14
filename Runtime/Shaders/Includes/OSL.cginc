#ifndef OSL_INCLUDED
#define OSL_INCLUDED

#include "Packages/com.osl.core/Runtime/Shaders/Internal/Common/Inputs.cginc"
#include "Packages/com.osl.core/Runtime/Shaders/Internal/MasterBus/Links.cginc"
#include "Packages/com.osl.core/Runtime/Shaders/Internal/MasterBus/Decode.cginc"

#ifndef OSL_PROPS_BUFFER
    #define OSL_PROPS_BUFFER OSL_PROPS
#endif //OSL_PROPS_BUFFER

#include "UnityInstancing.cginc"

UNITY_INSTANCING_BUFFER_START(OSL_PROPS_BUFFER)
    UNITY_DEFINE_INSTANCED_PROP(half4, OSL_PanTiltBounds)
    UNITY_DEFINE_INSTANCED_PROP(half2, OSL_PanTiltOffset)
    UNITY_DEFINE_INSTANCED_PROP(uint, OSL_DmxOffset)
UNITY_INSTANCING_BUFFER_END(OSL_PROPS_BUFFER)

inline half4 OSL_getPanTiltBounds()
{
    return UNITY_ACCESS_INSTANCED_PROP(OSL_PROPS_BUFFER, OSL_PanTiltBounds);
}

inline half OSL_getPanMin()     { return OSL_getPanTiltBounds().x; }
inline half OSL_getPanMax()     { return OSL_getPanTiltBounds().y; }
inline half2 OSL_getPanBounds() { return OSL_getPanTiltBounds().xy; }

inline half OSL_getTiltMin()        { return OSL_getPanTiltBounds().z; }
inline half OSL_getTiltMax()        { return OSL_getPanTiltBounds().w; }
inline half2 OSL_getTiltBounds()    { return OSL_getPanTiltBounds().zw; }

inline half2 OSL_getPanTiltOffset()
{
    return UNITY_ACCESS_INSTANCED_PROP(OSL_PROPS_BUFFER, OSL_PanTiltOffset);
}

inline half OSL_getPanOffset()  { return OSL_getPanTiltOffset().x; }
inline half OSL_getTiltOffset() { return OSL_getPanTiltOffset().y; }

inline uint OSL_getDmxOffset()
{
    return UNITY_ACCESS_INSTANCED_PROP(OSL_PROPS_BUFFER, OSL_DmxOffset);
}

float3x3 OSL_rotorX(float angle_rad)
{
    float s = sin(angle_rad);
    float c = cos(angle_rad);
    return float3x3(
        1, 0,  0,
        0, c, -s,
        0, s,  c
    );
}

float3x3 OSL_rotorY(float angle_rad)
{
    float s = sin(angle_rad);
    float c = cos(angle_rad);
    return float3x3(
         c, 0, s,
         0, 1, 0,
        -s, 0, c
    );
}

float3x3 OSL_rotorZ(float angle_rad)
{
    float s = sin(angle_rad);
    float c = cos(angle_rad);
    return float3x3(
        c, -s, 0,
        s,  c, 0,
        0,  0, 1
    );
}

float OSL_readRawDmx(uint channel)
{
    // Convert the dmx channel to the MasterBus position
    uint2 pos = OSL_dmxChannelToBusPos(channel);

    // Sample the bus data
    uint4 bus_data = OSL_sampleMasterBusPixel(pos);

    // Decode the correct byte
    return OSL_valueFromTrack4xU8(channel, bus_data.r);
}

/* == PAN/TILT FUNCTIONS == */

half OSL_remapPan(half pan)
{
    half2 bounds = OSL_getPanBounds();
    half offset = OSL_getPanOffset();
    return lerp(bounds.x, bounds.y, pan) + offset;
}

half OSL_remapTilt(half tilt)
{
    half2 bounds = OSL_getTiltBounds();
    half offset = OSL_getTiltOffset();
    return lerp(bounds.x, bounds.y, tilt) + offset;
}


float3 OSL_applyVertexPanTilt(float3 vpos, float2 vcolor, float3 pivot, float pan, float tilt)
{
    float tilt_mask = vcolor.r;
    float pan_mask = vcolor.g;

    /* == HEAD TILT == */

    float3 offset = pivot * tilt_mask;

    // Move the head to the object origin
    vpos -= offset;

    // Tilt the head around the Z axis (X forward)
    vpos = mul(OSL_rotorZ(tilt * tilt_mask), vpos);

    // Move the head back to its position
    vpos += offset;

    /* == FIXTURE PAN == */

    // Pan the fixture around the Y axis
    vpos = mul(OSL_rotorY(pan * pan_mask), vpos);

    return vpos;
}
float4 OSL_applyVertexPanTilt(float4 vpos, float2 vcolor, float3 pivot, float pan, float tilt)
{
    return float4(OSL_applyVertexPanTilt(vpos.xyz, vcolor, pivot, pan, tilt), vpos.w);
}

float3 OSL_applyNormalPanTilt(float3 normal, float2 vcolor, float pan, float tilt)
{
    float tilt_mask = vcolor.r;
    float pan_mask = vcolor.g;
    float3x3 tilt_mat = OSL_rotorZ(tilt * tilt_mask);
    float3x3 pan_mat = OSL_rotorY(pan * pan_mask);
    normal = mul(tilt_mat, normal);
    normal = mul(pan_mat, normal);
    return normal;
}

#endif //OSL_INCLUDED