#ifndef OSL_MASTERBUS_INDEX_INCLUDED
#define OSL_MASTERBUS_INDEX_INCLUDED

/** NOTE:
 * These functions expect 4 dmx channels per pixel stored in the masterbus
 * but im expecting a typical dmx channel offset
 * for all OSL_dmxChannelTo**x / OSL_**xToDmxChannel functions.
 */

/* == 16x16 MasterBus (2 universes / 1024 channels) == */

uint2 OSL_dmxChannelTo16x(uint idx)
{
    uint2 pos = idx.xx;
    pos *= uint2(0x802000, 0x401000);
    pos &= 0x88088000;
    pos *= 0x2805;
    return pos >> 28;
}

uint OSL_16xToDmxChannel(uint2 pos)
{
    pos *= uint2(0x08081020, 0x10080810);
    pos &= uint2(0x40202020, 0x80201010);
    pos *= uint2(0x00082081, 0x00208101);
    return (pos.x >> 22) | (pos.y >> 22);
}

/* == 32x32 MasterBus (8 universes / 4096 channels) == */

uint2 OSL_dmxChannelTo32x(uint idx)
{
    uint2 pos = idx.xx;
    pos &= uint2(0x554, 0xAA8);
    pos *= uint2(0x601800, 0x300C00);
    pos &= 0xC1030000;
    pos *= 0x1009;
    return pos >> 27;
}

uint OSL_32xToDmxChannel(uint2 pos)
{
    pos *= uint2(0x04208208, 0x08410410);
    pos &= uint2(0x40840408, 0x81080810);
    pos *= uint2(0x00084409, 0x00084409);
    pos &= uint2(0x55400000, 0xAA800000);
    return (pos.x >> 20) | (pos.y >> 20);
}

#endif //OSL_MASTERBUS_INDEX_INCLUDED