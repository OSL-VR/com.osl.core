#ifndef OSL_COMMON_INPUTS_INCLUDED
#define OSL_COMMON_INPUTS_INCLUDED

// Detect if we are processing a surface shader vs unlit
#if defined(SHADER_TARGET_SURFACE_ANALYSIS) && defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER)
    #define OSL_SURFACE_SHADER
#endif

#ifdef OSL_SURFACE_SHADER
    #define OSL_GlobalTimerType sampler2D
#else
    #define OSL_GlobalTimerType Texture2D<float4>
#endif //OSL_SURFACE_SHADER

uniform OSL_GlobalTimerType OSL_GlobalTimerTex;

#endif //OSL_COMMON_INPUTS_INCLUDED