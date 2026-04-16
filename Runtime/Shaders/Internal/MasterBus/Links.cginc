#ifndef OSL_MASTERBUS_LINKS_INCLUDED
#define OSL_MASTERBUS_LINKS_INCLUDED

#include "Index.cginc"

inline uint2 OSL_dmxChannelToBusPos(uint channel)
{
    //return OSL_dmxChannelTo16x(channel);
    return OSL_dmxChannelTo32x(channel);
}

inline uint2 OSL_busPosToDmxChannel(uint2 pos)
{
    //return OSL_16xToDmxChannel(pos);
    return OSL_32xToDmxChannel(pos);
}

#endif //OSL_MASTERBUS_LINKS_INCLUDED