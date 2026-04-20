#ifndef OSL_CONNECTORS_PROCESSORS_INCLUDED
#define OSL_CONNECTORS_PROCESSORS_INCLUDED

#include "Fields.cginc"

namespace OSL
{
    #include "Packages/com.osl.core/Runtime/Shaders/Modules/Processors/Dummy/Dummy.cginc"
    #include "Packages/com.osl.core/Runtime/Shaders/Modules/Processors/ExpSmooth/ExpSmooth.cginc"
}

inline uint OSL_callProcessor(OSL_DmxProcessorFields fields)
{
    // return OSL::encode(fields);
    return OSL::encode_16(fields);
}

#endif //OSL_CONNECTORS_PROCESSORS_INCLUDED