
local dcExt = require "__shared/Util/DataContainerExt"

local entryComponentHelper = require "__shared/EntryComponentHelper"

local tvVehicleBlueprint = nil

local excludedIndexes = { 3, 4 }

local loaded = false
local done = false

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end
	
	local instances = partition.instances

	for _, instance in pairs(instances) do
		
		if instance.instanceGuid == Guid("0DD3BA2E-4434-371C-8383-0E11272D7F1C") then
			tvVehicleBlueprint = VehicleBlueprint(instance)
		end

		if instance.instanceGuid == Guid("7B0181B4-D65F-43F8-AF50-CAEF929198C0") then
			local data = RemoteEntryComponentData(instance)
			data:MakeWritable()
			data.excluded = true
		end

		if instance.instanceGuid == Guid("E68C2506-F680-4198-8750-CC9A6106BEBA") then
			local data = CameraComponentData(instance)
			data:MakeWritable()
			data.excluded = true
		end
	end

	
	if not done and tvVehicleBlueprint ~= nil then

		tvVehicleBlueprint:MakeWritable()
		--tvVehicleBlueprint.eventConnections:clear()

		local tvVehicleEntityData = VehicleEntityData(tvVehicleBlueprint.object)
		tvVehicleEntityData:MakeWritable()

		local tvChassisComponentData = ChassisComponentData(tvVehicleEntityData.components[1])
		tvChassisComponentData:MakeWritable()

		--tvVehicleEntityData.components:clear()
		--tvVehicleEntityData.components:add(tvChassisComponentData)

		-- Add driver seat ---------------------------------------------------------------------------------------------
		local chaseCameraData = ChaseCameraData()
		chaseCameraData.targetOffset = Vec3(2, 2, -2)
		chaseCameraData.toWantedPositionScale= Vec3(100, 200, 100)
		chaseCameraData.awayFromTargetForceScale = 100
		chaseCameraData.targetRotationOffset = 0
		chaseCameraData.maxViewRotationAngleDeg = 0
		chaseCameraData.wantedAngleDeg = 5
		chaseCameraData.wantedDistance = 8
		chaseCameraData.maxDistance = 10
		chaseCameraData.snapDistance = 20
		chaseCameraData.forceFieldRadius = 2
		chaseCameraData.collisionRadius = 0.1
		chaseCameraData.forceFieldForceScale = 80
		chaseCameraData.maxVelocity = 100
		chaseCameraData.velocityDrag = 25
		chaseCameraData.pillExpandSizeSpeedAcceleration = 50
		chaseCameraData.pillMinimumCollisionRadius = 0.5
		chaseCameraData.pillMaximumCollisionRadius = 1.5
		chaseCameraData.pillMinimumCollisionLength = 0.3
		chaseCameraData.lookDistanceScale = 0
		chaseCameraData.lookDistanceInFrontOfTarget = 0
		chaseCameraData.updateRate = 200
		chaseCameraData.keepTargetPitch = true
		chaseCameraData.inheritTargetVelocity = true
		chaseCameraData.shouldRollWithTarget = false
		chaseCameraData.hasCollision = true
		chaseCameraData.occlusionRayOffset = Vec3(0, 0, 0)
		chaseCameraData.shakeFactor = 1
		chaseCameraData.preFadeTime = 0
		chaseCameraData.fadeTime = 0
		chaseCameraData.fadeWaitTime = 0
		chaseCameraData.soundListenerRadius = 0.5
		chaseCameraData.nearPlane = -1
		chaseCameraData.shadowViewDistanceScale = 1.5

		local cameraComponentData = CameraComponentData()
		cameraComponentData.camera = chaseCameraData
		cameraComponentData.transform = LinearTransform(
			Vec3(1, 0, 0),
			Vec3(0, 1, 0),
			Vec3(0, 0, 1),
			Vec3(0, 2, -5)
		)

		local transform = LinearTransform(
			Vec3(1, 0, 0),
			Vec3(0, 1, 0),
			Vec3(0, 0, 1),
			Vec3(0.4, 1, -1.5)
		)
		local entry = entryComponentHelper:CreatePlayerEntry(1, 41, transform)
		entry.components:add(cameraComponentData)
		tvChassisComponentData.components:add(entry)

		tvVehicleEntityData.runtimeComponentCount = 7


		print("Yeehaw")
		done = true
	end
end)

Events:Subscribe('Level:Destroy', function()

	tvVehicleEntityData = nil
	done = false
end)