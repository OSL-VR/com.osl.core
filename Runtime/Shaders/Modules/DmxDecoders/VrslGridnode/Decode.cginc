float decodeVrslGridnode(OSL_DmxDecoderFields fields)
{
    uint ch = fields.dmx_channel;
    uint2 base_pos = (uint2)(fields.stream_st.zw);
    Texture2D gridnode = fields.stream;

    // Comment this out if you dont need the universe padding
    uint universe_offset = ch / 512u;
    ch += universe_offset * 8u;


    // TODO: Optimize this division with invariant integer multiplication
    uint col = ch / 13u;
    uint row = ch - col * 13u;

    // Remember: each DMX pixel in the stream is 16x16
    uint2 pixel_pos = base_pos + uint2(col * 16u + 8u, row * 16u + 8u);
    float3 color = gridnode.Load(uint3(pixel_pos, 0)).rgb;
    return dot(color, float3(0.299, 0.587, 0.114));
}