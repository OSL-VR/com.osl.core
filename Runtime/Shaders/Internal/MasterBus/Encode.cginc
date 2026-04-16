#ifndef OSL_MASTERBUS_ENCODE_INCLUDED
#define OSL_MASTERBUS_ENCODE_INCLUDED

/* Layout: 32 [ v.w | v.z | v.y | v.x ] 0 */
uint OSL_encodeTrack4xU8(uint4 v)
{
    return v.x | (v.y << 8u) | (v.z << 16u) | (v.w << 24u);
}

/* Layout: 32 [ v.y | v.x ] 0 */
uint OSL_encodeTrack2xU16(uint2 v)
{
    return v.x | (v.y << 16u);
}
uint OSL_encodeTrack2xU16(uint vx, uint vy)
{
    return vx | (vy << 16u);
}

#endif //OSL_MASTERBUS_ENCODE_INCLUDED