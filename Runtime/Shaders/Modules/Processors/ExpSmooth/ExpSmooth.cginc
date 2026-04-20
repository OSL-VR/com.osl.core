#pragma once

// Thanks Freya! https://www.youtube.com/watch?v=LSNQuFEDOyQ
// "I want to be `decay` percent away from `b` after 1 second of moving from `a`"
// Example:
// a=1, b=2, decay=0.25:
// 0s -> 1.0
// 1s -> 1.75
// 2s -> 1.9375
// 3s -> 1.98438
float OSL_expSmooth(float a, float b, float decay, float dt)
{
    // return b + (a - b) * exp2(log2(decay) * dt);
    return b + (a - b) * pow(decay, dt);
}

// [00:11] decay rate
// [12:23] max deviation
void decode_icb(uint icb, out float decay, out float deviation)
{
    decay = (float)(icb & 0xFFF) / 4095.0;
    deviation = (float)((icb >> 12u) & 0xFFF) / 4095.0;
}


inline uint encode_16(OSL_DmxProcessorFields fields)
{
    // Get the last frames processor value
    uint last_raw   = fields.last_result.x;
    float last_norm = ((float)last_raw) / 65535.0;

    // Get the target value
    float target_norm = fields.dmx_norm.x;
    uint target_raw = (uint)(target_norm * 65535.0);

    // Early-out if the delta register is the same as the target
    if(last_raw == target_raw)
    {
        return last_raw;
    }

    // Decode the icb TODO: deviation
    float decay, deviation;
    decode_icb(0xFFF, decay, deviation);

    // Remap to usable bounds
    decay = lerp(0.0001, 0.9999, decay);

    // Get the frame delta time
    float dt = fields.global_dt;

    float next_norm = OSL_expSmooth(
        last_norm, target_norm,
        decay, dt
    );

    uint next_value = uint(saturate(next_norm) * 65535.0);

    // Enforce at least a single substep per frame to
    // force the delta buffer away from plateau
    return (last_raw < target_raw)
        ? max(last_raw + 1, next_value)
        : min(last_raw - 1, next_value);
}
