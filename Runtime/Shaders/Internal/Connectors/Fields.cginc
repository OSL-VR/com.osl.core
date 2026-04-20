#ifndef OSL_CONNECTORS_FIELDS_INCLUDED
#define OSL_CONNECTORS_FIELDS_INCLUDED

struct OSL_DmxDecoderFields
{
    /* == OSL V0.0.1 == */

    // The raw DMX channel being requested
    uint dmx_channel;

    // The resolution of the MasterBus texture
    uint mb_size;

    // The stream texture to sample into
    Texture2D stream;

    // The scale/offset of the stream texture
    float4 stream_st;

    // The texel size of the stream texture
    float4 stream_texelsize;
};

struct OSL_DmxProcessorFields
{
    /* == OSL V0.0.1 == */

    // x: The +0 byte current
    // y: The +1 byte current
    // z: The +0 byte last
    // w: The +1 byte last
    uint4 dmx_raw;

    // x: The current +0 normalized channel
    // y: The current +1 normalized channel
    // z: The last +0 normalized channel
    // w: The last +1 normalized channel
    fixed4 dmx_norm;

    // The DMX channel index being processed;
    uint dmx_channel;

    // This processors index in the processor table
    uint proc_id;

    // This channels 24-bit Indexed Constant Buffer value
    uint icb_value;

    // x: The previous value of the +0 processors output
    // y: The previous value of the +1 processors output
    uint2 last_result;

    // The global time parameters from the `OSL_GlobalTimer` CRT
    float4 gt;
    float global_time;
    float global_dt;
    float global_idt;
    float global_last_dt;
};

#endif //OSL_CONNECTORS_FIELDS_INCLUDED