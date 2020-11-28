
NetEvents:Subscribe('Airstrike:Launch', function(player, position)

	position.y = position.y + 200

	local launchTransform = LinearTransform(
		Vec3(0,  0, -1),
		Vec3(1,  0,  0),
		Vec3(0, -1,  0),
		position
	)

	local params = EntityCreationParams()
	params.transform = launchTransform
	params.networked = true

	local blueprint = VehicleBlueprint(ResourceManager:SearchForDataContainer("Vehicles/common/WeaponData/AGM-144_Hellfire_TV"))
	
	local vehicleEntityBus = EntityBus(EntityManager:CreateEntitiesFromBlueprint(blueprint, params))
	
	for i, entity in pairs(vehicleEntityBus.entities) do
	
		entity = Entity(entity)
		entity:Init(Realm.Realm_ClientAndServer, true)
	end
end)