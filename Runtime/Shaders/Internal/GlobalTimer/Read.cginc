#ifndef OSL_GLOBALTIMER_READ_INCLUDED
#define OSL_GLOBALTIMER_READ_INCLUDED

#include "Packages/com.osl.core/Runtime/Shaders/Internal/Common/Inputs.cginc"

inline float4 OSL_sampleGlobalTimer(OSL_GlobalTimerType tex)
{
#ifdef OSL_SURFACE_SHADER
    return tex2Dlod(tex, 0);
#else
    return tex.Load(0);
#endif //OSL_SURFACE_SHADER
}
inline float4 OSL_sampleGlobalTimer()
{
    return OSL_sampleGlobalTimer(OSL_GlobalTimerTex);
}

inline float OSL_getTime(OSL_GlobalTimerType tex)               { return OSL_sampleGlobalTimer(tex).x; }
inline float OSL_getDeltaTime(OSL_GlobalTimerType tex)          { return OSL_sampleGlobalTimer(tex).y; }
inline float OSL_getInverseDeltaTime(OSL_GlobalTimerType tex)   { return OSL_sampleGlobalTimer(tex).z; }
inline float OSL_getLastDeltaTime(OSL_GlobalTimerType tex)      { return OSL_sampleGlobalTimer(tex).w; }

inline float OSL_getTime()              { return OSL_getTime(OSL_GlobalTimerTex); }
inline float OSL_getDeltaTime()         { return OSL_getDeltaTime(OSL_GlobalTimerTex); }
inline float OSL_getInverseDeltaTime()  { return OSL_getInverseDeltaTime(OSL_GlobalTimerTex); }
inline float OSL_getLastDeltaTime()     { return OSL_getLastDeltaTime(OSL_GlobalTimerTex); }

#endif //OSL_GLOBALTIMER_READ_INCLUDED