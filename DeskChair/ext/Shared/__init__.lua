
local quadVehicleEntityData = nil
local chairRigidMeshAsset = nil

local done = false

Events:Subscribe('Level:LoadResources', function()
	-- deskchair bundles
	ResourceManager:MountSuperBundle('spchunks')
	ResourceManager:MountSuperBundle('levels/sp_paris/sp_paris')
	-- quadbike bundles
	ResourceManager:MountSuperBundle('xp3chunks')
	ResourceManager:MountSuperBundle('levels/xp3_shield/xp3_shield')
end)

Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
    if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
        print('Injecting bundles.')

        bundles = {
			'levels/sp_paris/sp_paris',
            'levels/sp_paris/lobby',
            'levels/xp3_shield/xp3_shield',
            'levels/xp3_shield/conquestsmall0',
            bundles[1],
        }

        hook:Pass(bundles, compartment)
    end
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)
	local sp_paris_lobbyRegistry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('1681B495-8C73-CE77-AE1B-128D4427AF7A')))
    ResourceManager:AddRegistry(sp_paris_lobbyRegistry, ResourceCompartment.ResourceCompartment_Game)
	local xp3_shield_conquestsmall0Registry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('336CEB6A-E4C0-DB68-3A96-883F6A239F7F')))
    ResourceManager:AddRegistry(xp3_shield_conquestsmall0Registry, ResourceCompartment.ResourceCompartment_Game)
end)

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end
	
	local instances = partition.instances

	for _, instance in pairs(instances) do
		
		if instance.instanceGuid == Guid("0E347B4B-B579-F65D-BC97-D11B28D7EDC8") then
		
			quadVehicleEntityData = VehicleEntityData(instance)
		end
		
		if instance.instanceGuid == Guid("5C16AE25-1208-11DE-9120-FCCFDFD200C9") then
		
			chairRigidMeshAsset = RigidMeshAsset(instance)
		end
	end
	
	if not done and quadVehicleEntityData ~= nil and chairRigidMeshAsset ~= nil then
	
		quadVehicleEntityData:MakeWritable()
		quadVehicleEntityData.mesh:ReplaceReferences(chairRigidMeshAsset)
		
		local chassisComponentData = ChassisComponentData(quadVehicleEntityData.components[1])
		chassisComponentData:MakeWritable()
		
		-- change quad driver animation to humvee passenger (sitting) animation
		local playerEntryComponentData = PlayerEntryComponentData(chassisComponentData.components[1])
		playerEntryComponentData:MakeWritable()
		playerEntryComponentData.antEntryId = 11
		playerEntryComponentData.antEntryID = "Humvee_PassengerFrontRight"
		playerEntryComponentData.antEntryEnumeration = nil
		playerEntryComponentData.show3pSoldierWeaponInEntry = false
		playerEntryComponentData.showSoldierGearInEntry = false
		playerEntryComponentData.soldierOffset = Vec3(0.8, -0.18, -0.4)
		
		-- remove engine sound effect
		local engineComponentData = EngineComponentData(chassisComponentData.components[2])
		engineComponentData:MakeWritable()
		engineComponentData.soundEffect = nil
	
		-- add deskchair mesh
		local meshComponentData = MeshComponentData()
		meshComponentData.transform = LinearTransform(
		Vec3(1, 0, 0),
		Vec3(0, 1, 0),
		Vec3(0, 0, 1),
		Vec3(0, 0.1, 0)
		)
		meshComponentData.mesh = chairRigidMeshAsset
		chassisComponentData.components:add(meshComponentData)
		
		print("done")
		done = true
	end
end)
