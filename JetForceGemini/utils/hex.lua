local hex={
	u8=function(num) return string.format("%02X",num) end,
	s8=function(num) return string.format("%02X",num) end,
	u16=function(num) return string.format("%04X",num) end,
	s16=function(num) return string.format("%04X",num) end,
	u32=function(num) return string.format("%08X",num) end,
	s32=function(num) return string.format("%08X",num) end
};

return hex;