
local dcExt = require "__shared/Util/DataContainerExt"

local passengerComponents = require "__shared/PassengerComponents"
local passengerTransforms = require "__shared/PassengerTransforms"

local rhibVehicleEntityData = nil
local m2hbFiringFunctionData = nil

local cameraIndexes = { {4,3}, {5,1,1,3} }
local excludedIndexes = { {6}, {7} }	--indexes of vanilla passenger entrycomponents
local loaded = false
local done = false

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end
	
	local instances = partition.instances

	for _, instance in pairs(instances) do
		
		if instance.instanceGuid == Guid("48F7D0D9-50BC-BBFD-0FC2-6B6AE89F44BA") then
			rhibVehicleEntityData = VehicleEntityData(instance)
		end
		if instance.instanceGuid == Guid("1E98B2EB-7272-4899-9D55-78C5EEDB4305") then
			m2hbFiringFunctionData = FiringFunctionData(instance)
		end
	end

	
	if not done and rhibVehicleEntityData ~= nil and m2hbFiringFunctionData ~= nil then

		rhibVehicleEntityData:MakeWritable()
		rhibVehicleEntityData.runtimeComponentCount = 52 --47
		
		local rhibChassisComponentData = ChassisComponentData(rhibVehicleEntityData.components[1])
		rhibChassisComponentData:MakeWritable()

		-- Modify FOV --------------------------------------------------------------------------------------------------
		for _,indexes in pairs(cameraIndexes) do
			local componentData = rhibChassisComponentData
			for _,i in pairs(indexes) do 
				componentData = componentData.components[i]
				componentData = _G[componentData.typeInfo.name](componentData)
			end
			componentData:MakeWritable()
			componentData.forceFieldOfView = 75
		end
		
		-- Exclude components ------------------------------------------------------------------------------------------
		for _,indexes in pairs(excludedIndexes) do
			local componentData = rhibChassisComponentData
			for _,i in pairs(indexes) do
				componentData = componentData.components[i]
				componentData = _G[componentData.typeInfo.name](componentData)
			end
			componentData:MakeWritable()
			componentData.excluded = true
		end

		-- Add passenger seats -----------------------------------------------------------------------------------------
		for index, params in pairs(passengerTransforms) do	-- params[1] = entry LT, params[2] = entry antEnum value
			local passengerPartComponentData = passengerComponents:CreateEntry(3 + index, params[2] , params[1], params[3])
			rhibChassisComponentData.components:add(passengerPartComponentData)
		end

--		local test = PlayerEntryComponentData()
--		rhibChassisComponentData.components:add(test)

		-- Adjust HMG ammo ---------------------------------------------------------------------------------------------
		m2hbFiringFunctionData:MakeWritable()
		m2hbFiringFunctionData.ammo.magazineCapacity = 200
		m2hbFiringFunctionData.ammo.numberOfMagazines = 2
		
		print("RHIB modified")
		done = true
	end
end)

Events:Subscribe('Level:Destroy', function()

	rhibVehicleEntityData = nil
	m2hbFiringFunctionData = nil
	done = false
end)
