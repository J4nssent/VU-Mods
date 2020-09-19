
local isBoolean = {
	["true"] = true,
	["false"] = true,
	["1"] = true,
	["0"] = true,
}

Events:Subscribe('Player:Chat', function(player, recipientMask, message)
	local parts = string.lower(message):split(' ')

	-- RCON commands ---------------------------------------------------------------------------------------------------
		if parts[1] == "!bluetint" then
		if not isBoolean[parts[2]] then
			return
		end
		RCON:SendCommand("vu.ColorCorrectionEnabled", { parts[2] })
	end

	if parts[1] == "!sunflare" then
		if not isBoolean[parts[2]] then
			return
		end
		RCON:SendCommand("vu.sunFlareEnabled", { parts[2] })
	end

	if parts[1] == "!destruction" then
		if not isBoolean[parts[2]] then
			return
		end
		RCON:SendCommand("vu.DestructionEnabled", { parts[2] })
	end

	if parts[1] == "!deserting" then
		if not isBoolean[parts[2]] then
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

	if parts[1] == "!killme" then
		if player.soldier == nil then
			return
		end
		player.soldier:Kill()
	end
end)

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields + 1] = c end)
	return fields
end