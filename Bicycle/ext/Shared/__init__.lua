
local klrVehicleEntityData = nil
local klrCompositeMeshAsset = nil
local bicycleRigidMeshAsset = nil

local done = false

Events:Subscribe('Level:LoadResources', function()
	-- bicycle bundles
  	ResourceManager:MountSuperBundle('spchunks')
	ResourceManager:MountSuperBundle('levels/sp_paris/sp_paris')
	-- dirtbike bundles
	ResourceManager:MountSuperBundle('xp5chunks')
	ResourceManager:MountSuperBundle('levels/xp5_002/xp5_002')
end)

Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
    if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
        print('Injecting bundles.')

        bundles = {
            'levels/sp_paris/sp_paris',
            'levels/sp_paris/parkingdeck',
			'levels/xp5_002/xp5_002',
			'levels/xp5_002/cql',
            bundles[1],
        }

        hook:Pass(bundles, compartment)
    end
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)
    local sp_parisRegistry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('CB062F45-0DEC-4AF4-D59D-63A0ABF18404')))
    ResourceManager:AddRegistry(sp_parisRegistry, ResourceCompartment.ResourceCompartment_Game)
	
	local xp5_002Registry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('421454A2-6F76-B4C6-7240-322C71D8DDAB')))
    ResourceManager:AddRegistry(xp5_002Registry, ResourceCompartment.ResourceCompartment_Game)
end)

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end
	
	local instances = partition.instances

	for _, instance in pairs(instances) do
		
		if instance.instanceGuid == Guid("33960E31-BB2A-4CAD-80B9-FBDA32E36745") then
		
			klrVehicleEntityData = VehicleEntityData(instance)
		end

		if instance.instanceGuid == Guid("1EEA9A32-E536-475D-A674-C300519B6E1A") then
		
			klrCompositeMeshAsset = CompositeMeshAsset(instance)
		end
		
		if instance.instanceGuid == Guid("7CFE056D-BD31-857C-E262-9BA30E8E4CDD") then
		
			bicycleRigidMeshAsset = RigidMeshAsset(instance)
		end
	end
	
	if not done and klrVehicleEntityData ~= nil and bicycleRigidMeshAsset ~= nil and klrCompositeMeshAsset ~= nil then
	
		klrVehicleEntityData:MakeWritable()
		
		local chassisComponentData = ChassisComponentData(klrVehicleEntityData.components[1])
		chassisComponentData:MakeWritable()
		
		local engineComponentData = EngineComponentData(chassisComponentData.components[7])
		engineComponentData:MakeWritable()
		engineComponentData.soundEffect = nil
		
		for _,effectComponentData in pairs(engineComponentData.components) do
			effectComponentData = ComponentData(effectComponentData)
			effectComponentData:MakeWritable()
			effectComponentData.excluded = true
		end
		
		local meshComponentData = MeshComponentData()
		meshComponentData.transform = LinearTransform(
		Vec3(0,   0,   -1.2),
		Vec3(0,   1.2,  0),
		Vec3(1.2, 0,    0),
		Vec3(0,  -0.1,  0)
		)
		meshComponentData.mesh = bicycleRigidMeshAsset
		chassisComponentData.components:add(meshComponentData)

		klrCompositeMeshAsset:ReplaceReferences(bicycleRigidMeshAsset) -- makes klr mesh go away
		
		--setComponentPartIndexes(chassisComponentData)
		
		done = true
	end
end)

function setComponentPartIndexes(componentData) -- hides mesh but also breaks physics

	componentData = _G[componentData.typeInfo.name](componentData)

	if componentData.healthStates and #componentData.healthStates > 0 then
		for _,state in pairs(componentData.healthStates) do
		
			state = HealthStateData(state)
			state:MakeWritable()
			state.partIndex = 0
		end
	end
	
	if	componentData.components ~= nil and #componentData.components > 0 then
		for _,data in pairs(componentData.components) do
		
			setComponentPartIndexes(data)
		end
	end
end
