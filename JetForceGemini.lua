-- JetForceGemini by Jimmie1717
-- Created using BizHawk 1.11.8.2 (lower versions may not work)
console.clear();
print("jfgz by Jimmie1717");
mem=require("JetForceGemini.utils.memory");
hex=require("JetForceGemini.utils.hex");
core=require("JetForceGemini.core");
--form=require("JetForceGemini.form");
if(core.init())then
	-- form.init();
	while true do
		emu.frameadvance();
	end
end