
local klrVehicleEntityData = nil
local vespaCompositeMeshAsset = nil
local dummyMeshAsset = nil

local done = false

Events:Subscribe('Level:LoadResources', function()
  
	ResourceManager:MountSuperBundle('xp5chunks')
	ResourceManager:MountSuperBundle('levels/xp5_002/xp5_002')
	ResourceManager:MountSuperBundle('spchunks')
	ResourceManager:MountSuperBundle('levels/sp_paris/sp_paris')
end)

Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
    if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
        print('Injecting bundles.')

        bundles = {
            'levels/sp_paris/sp_paris',
            'levels/sp_paris/street',
			'levels/xp5_002/xp5_002',
			'levels/xp5_002/cql',
            bundles[1],
        }

        hook:Pass(bundles, compartment)
    end
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)
    local sp_parisRegistry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('D657117C-D9C8-9A69-71C0-5C06BB7A76A1')))
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
		
		if instance.instanceGuid == Guid("33CAA032-F2EF-531D-72E9-A87AE320C383") then

			vespaCompositeMeshAsset = CompositeMeshAsset(instance)
		end
	end
	
	if not done and klrVehicleEntityData ~= nil and vespaCompositeMeshAsset ~= nil then
	
		klrVehicleEntityData:MakeWritable()
		
		local chassisComponentData = ChassisComponentData(klrVehicleEntityData.components[1])
		chassisComponentData:MakeWritable()

		PartComponentData(chassisComponentData.components[12]):MakeWritable()
		PartComponentData(chassisComponentData.components[12]).excluded = true

		PlayerEntryComponentData(chassisComponentData.components[5]):MakeWritable()
		PlayerEntryComponentData(chassisComponentData.components[5]).transform = LinearTransform(
			Vec3( 1,  0,   0),
			Vec3( 0,  1,   0),
			Vec3( 0,  0,   1),
			Vec3( 0,  0.7, 0.1)
		)

		local meshComponentData = MeshComponentData()
		meshComponentData.isEventConnectionTarget = 3
		meshComponentData.isPropertyConnectionTarget = 3
		meshComponentData.indexInBlueprint = -1
		meshComponentData.excluded = false
		meshComponentData.transform = LinearTransform(
		Vec3( 0,  0,   1),
		Vec3( 0,  1,   0),
		Vec3(-1,  0,   0),
		Vec3( 0, -0.1, -0.2)
		)
		meshComponentData.mesh = vespaCompositeMeshAsset
		
		chassisComponentData.components:add(meshComponentData)
		
		klrVehicleEntityData.mesh = vespaCompositeMeshAsset
		
		done = true
	end

end)
