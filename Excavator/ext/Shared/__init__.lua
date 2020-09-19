
local excavatorCompositeMeshAsset = nil
local baseMeshAsset = nil
local t90VehicleEntityData = nil
local t90CompositeMeshAsset = nil
local hornWeaponFiringData = nil

local excludedIndexes = { {4, 4}, {4, 3}, {4, 2, 3} }

local doneyet = false

Events:Subscribe("Partition:Loaded", function(partition)
 
	if partition == nil then
		return
	end
	
	local instances = partition.instances

	for _, instance in pairs(instances) do
		
		if instance.instanceGuid == Guid("60106976-DD7D-11DD-A030-B04E425BA11E") then
		
			t90VehicleEntityData = VehicleEntityData(instance)
		end

		if instance.instanceGuid == Guid("60106977-DD7D-11DD-A030-B04E425BA11E") then
		
			t90CompositeMeshAsset = CompositeMeshAsset(instance)
		end
		
		if instance.instanceGuid == Guid("C58FAC63-28BB-2613-BB20-A1EE303E2128") then
		
			excavatorCompositeMeshAsset = CompositeMeshAsset(instance)
		end

		if instance.instanceGuid == Guid("04E87A04-59E0-E1E2-2693-F121AF9417DE") then
		
			baseRigidMeshAsset = MeshAsset(instance)
		end

		if instance.instanceGuid == Guid("A90FFC31-3B0C-4217-B022-83DCC0097D1B") then
		
			hornWeaponFiringData = WeaponFiringData(instance)
		end
	end
	
	if not doneyet 
	and excavatorCompositeMeshAsset ~= nil 
	and baseRigidMeshAsset ~= nil 
	and t90CompositeMeshAsset ~= nil 
	and t90VehicleEntityData ~= nil 
	and hornWeaponFiringData ~= nil then
	
		t90VehicleEntityData:MakeWritable()

		local crosshairReferenceObjectData = ReferenceObjectData(t90VehicleEntityData.components[5])
		crosshairReferenceObjectData:MakeWritable()
		crosshairReferenceObjectData.excluded = true

		local t90ChassisComponentData = ChassisComponentData(t90VehicleEntityData.components[1])
		t90ChassisComponentData:MakeWritable()
		
		for _,indexes in pairs(excludedIndexes) do
			local componentData = t90ChassisComponentData
			for _,i in pairs(indexes) do 
				componentData = componentData.components[i]
				componentData = _G[componentData.typeInfo.name](componentData)
			end
			componentData:MakeWritable()
			componentData.excluded = true
		end
		
		local baseMeshComponentData = MeshComponentData()
		baseMeshComponentData.mesh = baseRigidMeshAsset
		baseMeshComponentData.transform = LinearTransform(
		Vec3(1, 0, 0),
		Vec3(0, 1, 0),
		Vec3(0, 0, 1),
		Vec3(0, 0, -0.3))
		t90ChassisComponentData.components:add(baseMeshComponentData) -- add base mesh to main chassis

		local excavatorMeshComponentData = MeshComponentData()
		excavatorMeshComponentData.mesh = excavatorCompositeMeshAsset
		excavatorMeshComponentData.transform = LinearTransform(
		Vec3(1, 0, 0),
		Vec3(0, 1, 0),
		Vec3(0, 0, 1),
		Vec3(0, -1.3, 0))
		ChildComponentData(t90ChassisComponentData.components[4]):MakeWritable()
		ChildComponentData(t90ChassisComponentData.components[4]).components:add(excavatorMeshComponentData) -- add excavator mesh to rotating turret component

		t90CompositeMeshAsset:ReplaceReferences(baseRigidMeshAsset) --doesnt actually work, but is does make the tank mesh go away (maybe because rigidmesh instead of composite), doing this via vehicleEntityData.mesh doesn't work
		
		local cameraComponentData = CameraComponentData(UnlockComponentData(ChildComponentData(ChildComponentData(t90ChassisComponentData.components[4]).components[1]).components[1]).components[1]) -- static camera
		cameraComponentData:MakeWritable()
		cameraComponentData.enableCameraMesh = false
		cameraComponentData.transform = LinearTransform(
		Vec3(1, 0, 0),
		Vec3(0, 1, 0),
		Vec3(0, 0, 1),
		Vec3(0.5, 0.5, 0.131238282))
	
		local chaseCameraData = ChaseCameraData(CameraComponentData(ChildComponentData(ChildComponentData(t90ChassisComponentData.components[4]).components[2]).components[4]).camera) -- chase camera
		chaseCameraData:MakeWritable()
		chaseCameraData.wantedAngleDeg = 10
		chaseCameraData.wantedDistance = 20
		chaseCameraData.maxDistance = 5
		chaseCameraData.snapDistance = 5

		local weaponComponentData = WeaponComponentData()
		weaponComponentData.weaponFiring =  hornWeaponFiringData

		local playerEntryComponentData = PlayerEntryComponentData(t90ChassisComponentData.components[3]) -- driver animation not possible since its on a rotating turret
		playerEntryComponentData:MakeWritable()
        playerEntryComponentData.components:add(weaponComponentData)

		doneyet = true
		print('done')
	end
end)
