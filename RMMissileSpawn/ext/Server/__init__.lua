
local mortarPartitionGuid = Guid('5350B268-18C9-11E0-B820-CD6C272E4FCC')

local customBlueprintGuid = Guid('D407033B-49AE-DF14-FE19-FC776AE04E2C')

Events:Subscribe('Player:Chat', function(player, recipientMask, message)

	if message == "!yeet" then

		local trans = player.soldier.transform.trans
		trans.y = 500
		
		local spawnTransform = LinearTransform(
			Vec3(1, 0, 0),
			Vec3(0, 0, 1),
			Vec3(0,-1, 0),
			trans
		)

		local params = EntityCreationParams()
		params.networked = true
		params.transform = spawnTransform

		local projectileBlueprint = ResourceManager:FindInstanceByGuid(mortarPartitionGuid, customBlueprintGuid)

		local projectileEntityBus = EntityManager:CreateEntitiesFromBlueprint(projectileBlueprint, params)

		for _,entity in pairs(projectileEntityBus.entities) do

			entity:Init(Realm.Realm_ClientAndServer, true)
		end
	end
end)