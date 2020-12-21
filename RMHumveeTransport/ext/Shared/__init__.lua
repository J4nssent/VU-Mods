
local dcExt = require "__shared/Util/DataContainerExt"

local humveeVehicleEntityData = nil
local cameraIndexes = { {3,3}, {5,1,2}, {6,1,2} }
local excludedIndexes = { {4}, {17}, {18} }
local done = false

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end
	
	local instances = partition.instances

	for _, instance in ipairs(instances) do
		
		if instance.instanceGuid == Guid("34ADD228-7E03-C4A4-665F-E0F0955098EE") then
			humveeVehicleEntityData = VehicleEntityData(instance)
		end
	end
	
	if not done and humveeVehicleEntityData ~= nil then
	
		humveeVehicleEntityData:MakeWritable()
	
		local humveeChassisComponentData = ChassisComponentData(humveeVehicleEntityData.components[1])
		humveeChassisComponentData:MakeWritable()

		local humveeGearboxConfigData = GearboxConfigData(humveeChassisComponentData.gearboxConfig)
		humveeGearboxConfigData:MakeWritable()

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
		
		-- Exclude 50cal components ------------------------------------------------------------------------------------
		for _,indexes in pairs(excludedIndexes) do
			local componentData = humveeChassisComponentData
			for _,i in pairs(indexes) do
				componentData = componentData.components[i]
				componentData = _G[componentData.typeInfo.name](componentData)
			end
			componentData:MakeWritable()
			componentData.excluded = true
		end

		-- Reduce top speed --------------------------------------------------------------------------------------------
		humveeGearboxConfigData.forwardGearRatios:erase(5)
		humveeGearboxConfigData.forwardGearSpeeds:erase(5)
		
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

		print("Humvee modified")
		done = true
	end
end)

Events:Subscribe('Level:Destroy', function()
	humveeVehicleEntityData = nil
	done = false
end)
