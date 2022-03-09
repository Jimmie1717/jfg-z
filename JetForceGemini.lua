-- JetForceGemini by Jimmie1717
-- Created using BizHawk 1.11.8.2 (lower versions may not work)
console.clear();
print("jfgz by Jimmie1717");
core=require("JetForceGemini.core");
mem=require("JetForceGemini.utils.memory");
hex=require("JetForceGemini.utils.hex");
if(core.init())then
	while true do
		-- form.updateActor();
		emu.frameadvance();
	end
end