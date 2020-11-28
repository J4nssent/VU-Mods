
local blastImpulseModifier = 1
local blastRadiusModifier = 1
local innerBlastRadiusModifier = 1
local shockWaveImpulseModifier = 1
local shockwaveRadiusModifier = 1
local shockwaveTimeModifier = 1
local cameraShockwaveRadiusModifier = 1

local tvExplosion = nil

ResourceManager:RegisterInstanceLoadHandler(Guid('1DF6F9A2-8BA1-11E0-9EF7-9C4CA6DBFDF3'), Guid('360168D5-1442-42BA-A158-56CEEC950AE4'), function(instance)

    local tvVehicleConfig = VehicleConfigData(instance)
    tvVehicleConfig:MakeWritable()
    tvVehicleConfig.vehicleModeAtReset = VehicleMode.VmStarted
    tvVehicleConfig.motionDamping = nil
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('1DF6F9A2-8BA1-11E0-9EF7-9C4CA6DBFDF3'), Guid('865D93BF-5382-40D5-882B-6E61F36EF6B0'), function(instance)

    local tvGearboxConfig = GearboxConfigData(instance)
    tvGearboxConfig:MakeWritable()
    tvGearboxConfig.forwardGearSpeeds[1] = 10000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('1DF6F9A2-8BA1-11E0-9EF7-9C4CA6DBFDF3'), Guid('D8486FE8-ABF1-45B7-822A-41C4F492CF77'), function(instance)

    tvExplosion = VeniceExplosionEntityData(instance)
    tvExplosion:MakeWritable()
    tvExplosion.blastImpulse = tvExplosion.blastImpulse * blastImpulseModifier
    tvExplosion.blastRadius = tvExplosion.blastRadius * blastRadiusModifier
    tvExplosion.innerBlastRadius = tvExplosion.innerBlastRadius * innerBlastRadiusModifier
    tvExplosion.shockwaveImpulse = tvExplosion.shockwaveImpulse * shockWaveImpulseModifier
    tvExplosion.shockwaveRadius = tvExplosion.shockwaveRadius * shockwaveRadiusModifier
    tvExplosion.shockwaveTime = tvExplosion.shockwaveTime * shockwaveTimeModifier
    tvExplosion.cameraShockwaveRadius = tvExplosion.cameraShockwaveRadius * cameraShockwaveRadiusModifier

    print("blastImpulseModifier = "..tostring(blastImpulseModifier))
    print("blastRadiusModifier = "..tostring(blastRadiusModifier))
    print("innerBlastRadiusModifier = "..tostring(innerBlastRadiusModifier))
    print("shockWaveImpulseModifier = "..tostring(shockWaveImpulseModifier))
    print("shockwaveRadiusModifier = "..tostring(shockwaveRadiusModifier))
    print("shockwaveTimeModifier = "..tostring(shockwaveTimeModifier))
    print("cameraShockwaveRadiusModifier = "..tostring(cameraShockwaveRadiusModifier))
end)

-- Events:Subscribe('Player:Chat', function(player, recipientMask, message)

--     local parts = message:split(' ')

--     if tvExplosion[parts[1]] then
--         ModifyData(parts[1], parts[2])
--         NetEvents:Broadcast('Mod', parts[1], parts[2])
--     end
-- end)

-- function string:split(sep)
--     local sep, fields = sep or ":", {}
--     local pattern = string.format("([^%s]+)", sep)
--     self:gsub(pattern, function(c) fields[#fields + 1] = c end)
--     return fields
-- end

-- function ModifyData(field, value)

--     local text = tostring(tvExplosion[field])
--     tvExplosion[field] = tonumber(value) or tvExplosion[field]
--     print(text.." -> "..tostring(tvExplosion[field]))
-- end

-- NetEvents:Subscribe('Mod', ModifyData)
