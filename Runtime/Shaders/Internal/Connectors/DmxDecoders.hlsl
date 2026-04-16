#ifndef OSL_CONNECTORS_DMXDECODERS_INCLUDED
#define OSL_CONNECTORS_DMXDECODERS_INCLUDED

#include "Fields.cginc"

namespace VRSL
{
    #include "Packages/com.osl.core/Runtime/Shaders/Modules/DmxDecoders/VrslGridnode/Decode.cginc"
}

inline float OSL_decodeDmxChannel(OSL_DmxDecoderFields fields)
{
    return VRSL::decodeVrslGridnode(fields);
}

#endif //OSL_CONNECTORS_DMXDECODERS_INCLUDED