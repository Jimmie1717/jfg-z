local mem={
	read={
		u8=memory.read_u8,
		s8=memory.read_s8,
		u16=memory.read_u16_be,
		s16=memory.read_s16_be,
		u32=memory.read_u32_be,
		s32=memory.read_s32_be,
		float=memory.readfloat
	},
	write={
		u8=memory.write_u8,
		s8=memory.write_s8,
		u16=memory.write_u16_be,
		s16=memory.write_s16_be,
		u32=memory.write_u32_be,
		s32=memory.write_s32_be,
		float=memory.writefloat
	}
}

return mem;