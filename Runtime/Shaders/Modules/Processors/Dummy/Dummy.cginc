#pragma once

// Dummy processor representing PID 0

inline uint encode(OSL_DmxProcessorFields fields)
{
	return 0;
}

inline uint decode(uint proc_value)
{
	return 0;
}