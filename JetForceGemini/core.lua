local core={};
core.get={};
core.get.player={};
core.get.player.weapon={};
core.set={};
core.set.player={};
core.set.player.weapon={};
core.add={};
core.remove={};

-- private

-- ROM header.
local ROM={
	id=nil,
	crc=nil,
	title=nil,
	name=nil,
};
-- common data for all versions.
local common=nil;
-- version specific data.
local version=nil;

-- Get the ROM's ID.
function getGameID()
	local rom_id="";
	for i=0,3,1 do rom_id=string.format("%s%s",rom_id,string.char(mem.read.u8(i+0x3B,"ROM"))); end
	return rom_id..mem.read.u8(0x3F,"ROM");
end
-- Get the ROM's CRCs.
function getGameCRCs(index)
	return {mem.read.u32(0x10,"ROM"),mem.read.u32(0x14,"ROM"),match=false};
end
-- Get the ROM's Title.
function getGameTitle()
	local rom_title="";
	for i=0,19,1 do rom_title=string.format("%s%s",rom_title,string.char(mem.read.u8(i+0x20,"ROM"))); end
	return rom_title;
end
-- Get wether the ROM is supported or not.
function getGameSupport()
	local versions=require("JetForceGemini.data.versions");
	for key,value in pairs(versions) do
		if(ROM.id==key)then
			ROM.name=versions[key].name;
			if(ROM.crc[1]==versions[key].crc[1] and ROM.crc[2]==versions[key].crc[2])then
				ROM.crc.match=true;
			end
			return versions[key].support;
		end
	end
	return false;
end

-- Read a pointer from an address and return it.
function getPointerAddress(pointer)
	local pointer=bit.band(mem.read.u32(pointer),0xFFFFFF);
	if(pointer==0)then return nil; end
	return pointer;
end


-- public

-- Get the pointer to the current loaded player actor.
function core.get.player.address()
	return getPointerAddress(version.player.pointer);
end

-- Get the players' position.
function core.get.player.position()
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	return {
		x=mem.read.float(addr+common.offsets.player.position.x,true),
		y=mem.read.float(addr+common.offsets.player.position.y,true),
		z=mem.read.float(addr+common.offsets.player.position.z,true),
	};
end

-- Get the player's velocity.
function core.get.player.velocity()
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	return {
		horizontal=nil,
		vertical=mem.read.float(addr+common.offsets.player.velocity.vertical,true)
	};
end

function core.get.player.jetfuel()
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	return mem.read.u16(addr+common.offsets.player.jet_fuel);
end
function core.set.player.jetfuel(amount)
	if(type(amount)~="number")then return; end
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	mem.write.u16(addr+common.offsets.player.jet_fuel,amount);
end

function core.get.player.health()
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	return mem.read.u8(addr+common.offsets.player.health);
end
function core.set.player.health(amount)
	if(type(amount)~="number")then return; end
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	mem.write.u8(addr+common.offsets.player.health,amount);
end

function core.get.player.weapon.firerate()
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	return mem.read.u8(addr+common.offsets.player.weapon.fire_rate);
end
function core.set.player.weapon.firerate(amount)
	if(type(amount)~="number")then return; end
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	mem.write.u8(addr+common.offsets.player.weapon.fire_rate,amount);
end

function core.get.player.weapon.gauge()
	local addr=core.get.player.address();
	if(addr==nil)then return nil; end
	return {
		others=mem.read.u8(addr+common.offsets.player.weapon.guage.others),
		pistol=mem.read.u8(addr+common.offsets.player.weapon.guage.pistol)
	};
end
function core.set.player.weapon.firerate(amounts)
	if(type(amount)~="table")then return; end
	local addr=core.get.player.address();
	mem.write.u8(addr+common.offsets.player.weapon.guage.others,amount.others);
	mem.write.u8(addr+common.offsets.player.weapon.guage.pistol,amount.pistol);
end

function core.get.gemini_holders(character)
	if(type(character)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.gemini_holders;
		end
	end
	if(addr==nil)then return nil; end
	return mem.read.u16(addr);
end
function core.set.gemini_holders(character,amount)
	if(type(character)~="string" or type(amount)~="number")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.gemini_holders;
		end
	end
	if(addr==nil)then return nil; end
	if(amount>12)then 
		mem.write.u16(addr,12);
	elseif(amount<0)then
		mem.write.u16(addr,0);
	else
		mem.write.u16(addr,amount);
	end
end
function core.get.heads(character,head_type)
	if(type(character)~="string" or type(head_type)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.heads.tribal;
		end
	end
	if(addr==nil)then return nil; end
	local offset=nil;
	for key,value in pairs(common.offsets.character_data.heads) do
		if(key==head_type)then
			addr=addr+common.offsets.character_data.heads[head_type];
		end
	end
	if(offset==nil)then return nil; end
	return mem.read.u16(addr+offset);
end
function core.set.heads(character,head_type,amount)
	if(type(character)~="string" or type(head_type)~="string" or type(amount)~="number")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.heads.tribal;
		end
	end
	if(addr==nil)then return nil; end
	local offset=nil;
	for key,value in pairs(common.offsets.character_data.heads) do
		if(key==head_type)then
			addr=addr+common.offsets.character_data.heads[head_type];
		end
	end
	if(offset==nil)then return nil; end
	if(amount>999)then 
		mem.write.u16(addr+offset,999);
	elseif(amount<0)then
		mem.write.u16(addr+offset,0);
	else
		mem.write.u16(addr+offset,amount);
	end
end
function core.get.mizar_tokens(character)
	if(type(character)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.mizar_tokens;
		end
	end
	if(addr==nil)then return nil; end
	return mem.read.u16(addr);
end
function core.set.mizar_tokens(character,amount)
	if(type(character)~="string" or type(amount)~="number")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.mizar_tokens;
		end
	end
	if(addr==nil)then return nil; end
	if(amount>999)then 
		mem.write.u16(addr,999);
	elseif(amount<0)then
		mem.write.u16(addr,0);
	else
		mem.write.u16(addr,amount);
	end
end


function core.get.ammo(character,weapon)
	if(type(character)~="string" or type(weapon)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.weapons.ammo;
		end
	end
	if(addr==nil)then return nil; end
	local offset=nil;
	for key,value in pairs(common.indexes.weapons) do
		if(key==weapon)then
			offset=value*2;
		end
	end
	if(offset==nil)then return nil; end
	return mem.read.u16(addr+offset);
end
function core.set.ammo(character,weapon,amount)
	if(type(character)~="string" or type(weapon)~="string" or type(amount)~="number")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.weapons.ammo;
		end
	end
	if(addr==nil)then return nil; end
	local offset=nil;
	for key,value in pairs(common.indexes.weapons) do
		if(key==weapon)then
			offset=value*2;
		end
	end
	if(offset==nil)then return nil; end
	if(amount>999)then 
		mem.write.u16(addr+offset,999);
	elseif(amount<0)then
		mem.write.u16(addr+offset,0);
	else
		mem.write.u16(addr+offset,amount);
	end
end
function core.get.capacity(character,weapon)
	if(type(character)~="string" or type(weapon)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.weapons.capacity;
		end
	end
	if(addr==nil)then return nil; end
	local offset=nil;
	for key,value in pairs(common.indexes.weapons) do
		if(key==weapon)then
			offset=value*2;
		end
	end
	if(offset==nil)then return nil; end
	return mem.read.u16(addr+offset);
end
function core.set.capacity(character,weapon,amount)
	if(type(character)~="string" or type(weapon)~="string" or type(amount)~="number")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.weapons.capacity;
		end
	end
	if(addr==nil)then return nil; end
	local offset=nil;
	for key,value in pairs(common.indexes.weapons) do
		if(key==weapon)then
			offset=value*2;
		end
	end
	if(offset==nil)then return nil; end
	if(amount>999)then 
		mem.write.u16(addr+offset,999);
	elseif(amount<0)then
		mem.write.u16(addr+offset,0);
	else
		mem.write.u16(addr+offset,amount);
	end
end
function core.get.weapon_switch(character)
	if(type(character)~="string" or type(character)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.weapons.switch;
		end
	end
	if(addr==nil)then return nil; end
	return mem.read.u16(addr);
end
function core.set.weapon_switch(character,switch)
	if(type(character)~="string" or type(character)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.weapons.switch;
		end
	end
	if(addr==nil)then return nil; end
	for key,value in pairs(common.values.weapon_switch) do
		if(key==switch)then
			mem.write.u16(addr,value);
		end
	end
end



-- Add a weapon to a character.
function core.add.weapon(character,weapon)
	if(type(character)~="string" or type(weapon)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.weapons.collected;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.weapons) do
		if(key==weapon)then
			mem.write.u16(addr,bit.bor(mem.read.u16(addr),value));
		end
	end
end
-- Remove a weapon from a character.
function core.remove.weapon(character,weapon)
	if(type(character)~="string" or type(weapon)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.weapons.collected;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.weapons) do
		if(key==weapon)then
			mem.write.u16(addr,bit.band(mem.read.u16(addr),bit.bnot(value)));
		end
	end
end

-- Add a level to a character.
function core.add.level(character,level)
	if(type(character)~="string" or type(level)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.levels;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.levels) do
		if(key==level)then
			mem.write.u16(addr,bit.bor(mem.read.u16(addr),value));
		end
	end
end
-- Remove a level from a character.
function core.remove.level(character,level)
	if(type(character)~="string" or type(level)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.levels;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.levels) do
		if(key==level)then
			mem.write.u16(addr,bit.band(mem.read.u16(addr),bit.bnot(value)));
		end
	end
end
-- Add a key to a character.
function core.add.key(character,keys)
	if(type(character)~="string" or type(keys)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.keys;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.keys) do
		if(key==keys)then
			mem.write.u16(addr,bit.bor(mem.read.u16(addr),value));
		end
	end
end
-- Remove a key from a character.
function core.remove.key(character,keys)
	if(type(character)~="string" or type(keys)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.keys;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.keys) do
		if(key==keys)then
			mem.write.u16(addr,bit.band(mem.read.u16(addr),bit.bnot(value)));
		end
	end
end
-- Add a object to a character.
function core.add.object(character,object)
	if(type(character)~="string" or type(object)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.objects;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.objects) do
		if(key==object)then
			mem.write.u16(addr,bit.bor(mem.read.u16(addr),value));
		end
	end
end
-- Remove a object from a character.
function core.remove.object(character,object)
	if(type(character)~="string" or type(keys)~="string")then return; end
	local addr=nil;
	for key,value in pairs(common.values.characters) do
		if(key==character)then
			addr=version.character_data+(value*0x76)+common.offsets.character_data.objects;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.objects) do
		if(key==object)then
			mem.write.u16(addr,bit.band(mem.read.u16(addr),bit.bnot(value)));
		end
	end
end


-- Add a robot mission medal.
function core.add.robot_mission_medal(mission,medal)
	if(type(mission)~="string" or type(medal)~="string")then return; end
	local addr=nil;
	for key,value in pairs(version.robot_mission_medals) do
		if(key==mission)then
			addr=value;
		end
	end
	if(addr==nil)then return; end
	for key,value in pairs(common.values.robot_mission_medals) do
		if(key==medal)then
			mem.write.u8(addr,value);
		end
	end
end
-- Remove robot mission medal.
function core.remove.robot_mission_medal(mission)
	if(type(mission)~="string")then return; end
	local addr=nil;
	for key,value in pairs(version.robot_mission_medals) do
		if(key==mission)then
			addr=value;
		end
	end
	if(addr==nil)then return; end
	mem.write.u8(addr,0x0);
end
	

-- Add a shippart.
function core.add.shippart(shippart)
	if(type(shippart)~="string")then return; end
	for key,value in pairs(common.values.shipparts) do
		if(key==shippart)then
			local addr=version.shipparts;
			mem.write.u16(addr,bit.bor(mem.read.u16(addr),value));
		end
	end
end
-- Remove a shippart.
function core.remove.shippart(shippart)
	if(type(shippart)~="string")then return; end
	for key,value in pairs(common.values.shipparts) do
		if(key==shippart)then
			local addr=version.shipparts;
			mem.write.u16(addr,bit.band(mem.read.u16(addr),bit.bnot(value)));
		end
	end
end

-- Add a character.
function core.add.character(character)
	if(type(character)~="string")then return; end
	for key,value in pairs(common.values.unlocked_characters) do
		if(key==character)then
			local addr=version.unlocked_characters;
			mem.write.u8(addr,bit.bor(mem.read.u16(addr),value));
		end
	end
end
-- Remove a charactder.
function core.remove.character(character)
	if(type(character)~="string")then return; end
	for key,value in pairs(common.values.unlocked_characters) do
		if(key==character)then
			local addr=version.unlocked_characters;
			mem.write.u8(addr,bit.band(mem.read.u16(addr),bit.bnot(value)));
		end
	end
end



function core.add.jetpack()
	mem.write.u8(version.character_armor,bit.band(mem.read.u8(version.charcter_armor),0x80));
end



-- Init
function core.init()
	ROM.id=getGameID();
	ROM.crc=getGameCRCs();
	ROM.title=getGameTitle();
	print(string.format("ROM Header: %s, 0x%08X 0x%08X, %s",ROM.id,ROM.crc[1],ROM.crc[2],ROM.title));
	gui.addmessage(string.format("ROM Header: %s, 0x%08X 0x%08X, %s",ROM.id,ROM.crc[1],ROM.crc[2],ROM.title));
	if(getGameSupport())then
		common=require("JetForceGemini.data.common");
		version=require(string.format("JetForceGemini.data.%s",ROM.id));
		gui.addmessage(string.format("%s is supported.",ROM.name));
		gui.addmessage("");
		return true;
	end
	gui.addmessage("This game is not supported.");
	gui.addmessage("");
	return nil;
end

return core;