
local dcExt = require "__shared/Util/DataContainerExt"

local humveeVehicleEntityData = nil
local m2hbFiringFunctionData = nil

local cameraIndexes = { {3,2}, {4,2,2,1,1,1}, {5,1,2}, {6,1,2} }
local excludedIndexes = { {1}, {2}, {14, 26}, {14, 27}, {14, 28}, {14, 29} }
local loaded = false
local done = false

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end
	
	local instances = partition.instances

	for _, instance in ipairs(instances) do
		
		if instance.instanceGuid == Guid("C955ED1B-9EE8-4FB2-BA54-1C848A50EB83") then
			humveeVehicleEntityData = VehicleEntityData(instance)
		end
		if instance.instanceGuid == Guid("1E98B2EB-7272-4899-9D55-78C5EEDB4305") then
			m2hbFiringFunctionData = FiringFunctionData(instance)
		end
		if instance.instanceGuid == Guid("A90FFC31-3B0C-4217-B022-83DCC0097D1B") then
			loaded = true
		end
	end

	
	if loaded and not done and humveeVehicleEntityData ~= nil and m2hbFiringFunctionData ~= nil then
	
		humveeVehicleEntityData:MakeWritable()
		
		local humveeChassisComponentData = ChassisComponentData(humveeVehicleEntityData.components[1])
		humveeChassisComponentData:MakeWritable()
		
		local engineComponentData = EngineComponentData(humveeChassisComponentData.components[8])
		engineComponentData:MakeWritable()
		
		local driverPlayerEntryComponentData = PlayerEntryComponentData(humveeChassisComponentData.components[3])
		driverPlayerEntryComponentData:MakeWritable()
		
		-- Modify FOV --------------------------------------------------------------------------------------------------
		for _,indexes in pairs(cameraIndexes) do
			local componentData = humveeChassisComponentData
			for _,i in pairs(indexes) do 
				componentData = componentData.components[i]
				componentData = _G[componentData.typeInfo.name](componentData)
			end
			componentData:MakeWritable()
			componentData.forceFieldOfView = 75
		end
		
		-- Exclude light components ------------------------------------------------------------------------------------
		for _,indexes in pairs(excludedIndexes) do
			local componentData = humveeChassisComponentData
			for _,i in pairs(indexes) do 
				componentData = componentData.components[i]
				componentData = _G[componentData.typeInfo.name](componentData)
			end
			componentData:MakeWritable()
			componentData.excluded = true
		end
		
		-- Copy normal humvee driving physics --------------------------------------------------------------------------
		humveeChassisComponentData.vehicleConfig = VehicleConfigData(ResourceManager:FindInstanceByGuid(Guid("611F48A3-0919-11E0-985D-C512734E48AF"), Guid("483DBCF5-FA57-4324-B3E3-38B9462BE806")))
		humveeChassisComponentData.gearboxConfig = GearboxConfigData(ResourceManager:FindInstanceByGuid(Guid("611F48A3-0919-11E0-985D-C512734E48AF"), Guid("1A2500A7-255D-4BC2-915B-002B21C69FE8")))
		engineComponentData.config = CombustionEngineConfigData(ResourceManager:FindInstanceByGuid(Guid("611F48A3-0919-11E0-985D-C512734E48AF"), Guid("7ED9EDBE-034C-4CEE-9BA0-EFAB0698E167")))
		engineComponentData.soundEffect = SoundPatchAsset(ResourceManager:FindInstanceByGuid(Guid("089906E0-08A1-41A6-83DF-4007D949DE1C"), Guid("8DB96F7D-FCBD-4A30-A4CB-37CAFDFE4564")))

		-- Add disabled state ------------------------------------------------------------------------------------------
		humveeVehicleEntityData.disabledDamageThreshold = 700
		
		-- Add horn ----------------------------------------------------------------------------------------------------
		local weaponComponentData = WeaponComponentData()
		weaponComponentData.weaponFiring =  WeaponFiringData(ResourceManager:FindInstanceByGuid(Guid("21AF0CBF-33E9-4548-B5C4-275192008D4E"), Guid("A90FFC31-3B0C-4217-B022-83DCC0097D1B")))
		driverPlayerEntryComponentData.components:add(weaponComponentData)
		
		-- Adjust entry radius -----------------------------------------------------------------------------------------
		humveeVehicleEntityData.interactionOffset =  Vec3(0, 1.335, 0)
		driverPlayerEntryComponentData.entryRadius = 1.5
		
		-- Add 4th passenger seat --------------------------------------------------------------------------------------
		local passengerEntry = PartComponentData(dcExt:DeepCopy(humveeChassisComponentData.components[6]))
		passengerEntry.transform = LinearTransform(
		Vec3(1, 0, 0),
		Vec3(0, 1, 0),
		Vec3(0, 0, 1),
		Vec3(0.7262304, 0.866977751, -0.51943475)
		)
		humveeChassisComponentData.components:add(passengerEntry)
		
		-- Adjust HMG ammo ---------------------------------------------------------------------------------------------
		m2hbFiringFunctionData:MakeWritable()
		m2hbFiringFunctionData.ammo.magazineCapacity = 200
		m2hbFiringFunctionData.ammo.numberOfMagazines = 2
		
		print("HumveeHMG modified")
		done = true
	end
end)

Events:Subscribe('Level:Destroy', function()

	humveeVehicleEntityData = nil
	m2hbFiringFunctionData = nil
	done = false
end)

-- Bundle mounting -----------------------------------------------------------------------------------------------------

Events:Subscribe('Level:LoadResources', function()
	ResourceManager:MountSuperBundle('levels/coop_009/coop_009')
end)

Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
	if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
		print('Injecting bundles.')

		bundles = {
			'levels/coop_009/coop_009',
			bundles[1],
		}

		hook:Pass(bundles, compartment)
	end
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)
	local registry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('F05798B2-31EC-210D-CC1D-0F7535BECA30')))
	ResourceManager:AddRegistry(registry, ResourceCompartment.ResourceCompartment_Game)
end)