#ifndef OSL_CONNECTORS_FIELDS_INCLUDED
#define OSL_CONNECTORS_FIELDS_INCLUDED

struct OSL_DmxDecoderFields
{
    /* == OSL V0.1.0 == */

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

#endif //OSL_CONNECTORS_FIELDS_INCLUDED