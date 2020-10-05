
function ServerTest(player)

	print("ServerTest")

	--Test stuff
end

local isBool = {
	["true"] = true,
	["false"] = true,
	["1"] = true,
	["0"] = true,
}

local asBool = {
	["true"] = true,
	["false"] = false,
	["1"] = true,
	["0"] = false,
}

local createFromBlueprintHook = nil
local entityCreateHook = nil
local soldierDamageHook = nil

Events:Subscribe('Player:Chat', function(player, recipientMask, message)
	local parts = string.lower(message):split(' ')

	-- RCON commands ---------------------------------------------------------------------------------------------------
		if parts[1] == "!bluetint" then
		if not isBool[parts[2]] then
			return
		end
		RCON:SendCommand("vu.ColorCorrectionEnabled", { parts[2] })
	end

	if parts[1] == "!sunflare" then
		if not isBool[parts[2]] then
			return
		end
		RCON:SendCommand("vu.sunFlareEnabled", { parts[2] })
	end

	if parts[1] == "!destruction" then
		if not isBool[parts[2]] then
			return
		end
		RCON:SendCommand("vu.DestructionEnabled", { parts[2] })
	end

	if parts[1] == "!deserting" then
		if not isBool[parts[2]] then
			return
		end
		RCON:SendCommand("vu.DesertingAllowed", { parts[2] })
	end

	if parts[1] == "!timescale" then
		local arg = tonumber(parts[2]) or 1
		if arg < 0 or arg > 2 then
			return
		end
		RCON:SendCommand("vu.timeScale", { tostring(arg) })
	end

	if parts[1] == "!suppression" then
		local arg = tonumber(parts[2]) or 1
		if arg < 0 or arg > 2 then
			return
		end
		RCON:SendCommand("vu.SuppressionMultiplier", { tostring(arg) })
	end

	if parts[1] == "!restart" then
		RCON:SendCommand("mapList.restartRound")
	end

	--------------------------------------------------------------------------------------------------------------------
	if parts[1] == "!ammo" then
		if player.soldier == nil then
			return
		end
		local ammo = tonumber(parts[2]) or 100
		local weaponsComponent = player.soldier.weaponsComponent
		SoldierWeapon(weaponsComponent.currentWeapon).primaryAmmo = ammo
	end

	if parts[1] == '!tel' or parts[1] == '!teleport' then
		if player.soldier == nil then
			return
		end
		local yaw = player.input.authoritativeAimingYaw
		local spacing = tonumber(parts[2]) or 10
		local height = tonumber(parts[3]) or 0
		local position = Vec3()
		position.x = player.soldier.transform.trans.x + (math.cos(yaw + (math.pi/2)) * spacing)
		position.y = player.soldier.transform.trans.y + height
		position.z = player.soldier.transform.trans.z + (math.sin(yaw + (math.pi/2)) * spacing)
		player.soldier:SetPosition(position)
	end

	if parts[1] == '!abs' or parts[1] == '!absolute' then
		if player.soldier == nil then
			return
		end
		if not tonumber(parts[2]) or not tonumber(parts[3]) or not tonumber(parts[4]) then
			return
		end
		local position = Vec3()
		position.x = tonumber(parts[2]) == 0 and player.soldier.transform.trans.x or tonumber(parts[2])
		position.y = tonumber(parts[3]) == 0 and player.soldier.transform.trans.y or tonumber(parts[3])
		position.z = tonumber(parts[4]) == 0 and player.soldier.transform.trans.z or tonumber(parts[4])
		player.soldier:SetPosition(position)
	end

	if parts[1] == "!killme" then
		if player.soldier == nil then
			return
		end
		player.soldier:Kill()
	end
	

	--------------------------------------------------------------------------------------------------------------------
	if parts[1] == "!printtransform" then
		if player.soldier == nil then
			return
		end
		print("LinearTransform(")
		print("Vec3"..tostring(player.soldier.transform.left)..",")
		print("Vec3"..tostring(player.soldier.transform.up)..",")
		print("Vec3"..tostring(player.soldier.transform.forward)..",")
		print("Vec3"..tostring(player.soldier.transform.trans)..")")
	end

	if parts[1] == "!printtrans" then
		if player.soldier == nil then
			return
		end
		print("LinearTransform(")
		print("Vec3(1, 0, 0),")
		print("Vec3(0, 1, 0),")
		print("Vec3(0, 0, 1),")
		print("Vec3"..tostring(player.soldier.transform.trans)..")")
	end

	--------------------------------------------------------------------------------------------------------------------
	if parts[1] == "!damage" then
		local arg = tonumber(parts[2]) or 1
		if arg < 0 then
			return
		end
		DamageModifier(parts[2])
	end

	if parts[1] == "!servertest" then
		ServerTest(player)
	end

	if parts[1] == "!serverblueprints" then
		ServerBlueprints(parts[2])
	end

	if parts[1] == "!serverentities" then
		ServerEntities(parts[2])
	end

	if parts[1] == "!clienttest" then
		NetEvents:Broadcast("clientTest", message:gsub(parts[1].." ", ""))
	end

	if parts[1] == "!clientblueprints" then
		NetEvents:Broadcast("clientBlueprints", parts[2])
	end

	if parts[1] == "!cliententities" then
		NetEvents:Broadcast("clientEntities", parts[2])
	end
end)


function ServerBlueprints(enable)

	if asBool[enable] then

		print("serverBlueprints enabled")

		createFromBlueprintHook = Hooks:Install('EntityFactory:CreateFromBlueprint', 1, function(hook, blueprint)
			blueprint = Blueprint(blueprint)
			print(blueprint.name)
		end)

	elseif not asBool[enable] and createFromBlueprintHook then

		createFromBlueprintHook:Uninstall()
	end
end

function ServerEntities(enable)

	if asBool[enable] then

		print("serverEntities enabled")

		entityCreateHook = Hooks:Install('EntityFactory:Create', 1, function(hook, entityData)
			print(entityData.typeInfo.name)
			print(entityData.instanceGuid)
		end)

	elseif not asBool[enable] and entityCreateHook then

		entityCreateHook:Uninstall()
	end
end

function DamageModifier(mod)

	if mod ~= 1 then

		print("Damagemodifier "..tostring(mod))

		if soldierDamageHook then

			soldierDamageHook:Uninstall()
		end

		soldierDamageHook = Hooks:Install('Soldier:Damage', 1, function(hook, soldier, info, giverInfo)
			
			info.damage = info.damage * mod
			hook:Pass(soldier, info, giverInfo)
		end)

	elseif soldierDamageHook then
			
		soldierDamageHook:Uninstall()
	end
end

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields + 1] = c end)
	return fields
end

