
local passengerComponents = require "__shared/PassengerComponents"
local eventConnections = require "__shared/EventConnections"
local dcExt = require "__shared/Util/DataContainerExt"

local excludedIndexes = { {7}, {8}, {9}, {10}, {11}, {12}, {19, 3} }
local passengerTransforms = require "__shared/PassengerTransforms"

local venomVehicleBlueprint = nil
local loaded = false
local done = false

Events:Subscribe('Partition:Loaded', function(partition)
	if partition == nil then
		return
	end
	
	local instances = partition.instances

	for _, instance in ipairs(instances) do
		
		if instance.instanceGuid == Guid("0E09B2D0-BA4A-1509-E1D2-949FB0C04DBE") then
			venomVehicleBlueprint = VehicleBlueprint(instance)
		end
		
		if instance.instanceGuid == Guid("E6D4A457-2200-4F56-A07E-C463EA9CFE18") then --Last GUID to load of all the ones in this mod
			loaded = true
		end
	end
	
	if loaded and not done and venomVehicleBlueprint ~= nil then
	
		venomVehicleBlueprint:MakeWritable()
		
		local venomVehicleEntityData = VehicleEntityData(venomVehicleBlueprint.object)
		venomVehicleEntityData:MakeWritable()

		local venomMaterialContainerPair = MaterialContainerPair(venomVehicleEntityData.materialPair)
		venomMaterialContainerPair:MakeWritable()

		local venomChassisComponentData = ChassisComponentData(venomVehicleEntityData.components[1])
		venomChassisComponentData:MakeWritable()
		
		local venomPlayerEntryComponentData = PlayerEntryComponentData(venomChassisComponentData.components[5])
		local venomPilotCameraComponentData = CameraComponentData(venomPlayerEntryComponentData.components[5])
		venomPilotCameraComponentData:MakeWritable()
		
		local venomVehicleConfigData = VehicleConfigData(venomChassisComponentData.vehicleConfig)
		venomVehicleConfigData:MakeWritable()
		
		local venomMainRotorEngineComponentData = EngineComponentData(venomChassisComponentData.components[6])
		local venomMainRotorPropellorEngineConfigData = PropellerEngineConfigData(venomMainRotorEngineComponentData.config)
		venomMainRotorPropellorEngineConfigData:MakeWritable()
		local venomMainRotorParameters = RotorParameters(venomMainRotorPropellorEngineConfigData.rotorConfig)
		venomMainRotorParameters:MakeWritable()
		
		local venomTailRotorEngineComponentData = EngineComponentData(venomChassisComponentData.components[4])
		local venomTailRotorPropellorEngineConfigData = PropellerEngineConfigData(venomTailRotorEngineComponentData.config)
		venomTailRotorPropellorEngineConfigData:MakeWritable()
		
		local venomMotionDampingData = MotionDampingData(venomVehicleConfigData.motionDamping)
		venomMotionDampingData:MakeWritable()

		-- Modify FOV --------------------------------------------------------------------------------------------------
		venomPilotCameraComponentData.forceFieldOfView = 75
		
		-- Modify startup time -----------------------------------------------------------------------------------------
		venomVehicleConfigData.vehicleModeChangeStartingTime = 0
		
		-- Modify damage model -----------------------------------------------------------------------------------------
		venomVehicleEntityData.velocityDamageThreshold = 0					--default 20
		venomVehicleEntityData.velocityDamageMagnifier = 15					--default 5

		-- Enable damage from small arms fire --------------------------------------------------------------------------
		-- TODO: Modify level MaterialGrid to adjust the venom materials properties

		-- Modify flight physics ---------------------------------------------------------------------------------------
		venomVehicleConfigData.centerOfMassHandlingOffset = Vec3(0, 1.8, 0)	--default Vec3(0, 2, 0)
		
		venomMotionDampingData.pitch = 0.1									--default 0.2
		venomMotionDampingData.yaw = 0.04									--default 0.08
		venomMotionDampingData.roll = 0.05									--default 0.2
		
		venomVehicleConfigData.inertiaModifier = Vec3(3, 3, 3)				--default Vec3(1.04, 2.1, 0.8)
		venomVehicleConfigData.bodyMass = 5000								--default 5000
		
		venomMainRotorPropellorEngineConfigData.gravityMod = 1				--default 0.1
		
		venomMainRotorParameters.cyclicInputScaleRoll = 0.18				--default 0.18
		venomMainRotorParameters.cyclicInputScalePitch = 0.85				--default 0.85
		venomMainRotorParameters.collectiveThrottleInputScale = 2.5			--default 2.5
		
		-- Disable regeneration ----------------------------------------------------------------------------------------
		venomVehicleEntityData.regenerationRate = 0							--default 10
	
		-- Exclude gunner components -----------------------------------------------------------------------------------
		for _,indexes in pairs(excludedIndexes) do
			local componentData = venomChassisComponentData
			for _,i in pairs(indexes) do 
				componentData = componentData.components[i]
				componentData = _G[componentData.typeInfo.name](componentData)
			end
			componentData:MakeWritable()
			componentData.excluded = true
		end
		
		-- Add copilot seat ----------------------------------------------------------------------------------------------
		local pilotPartComponentData = require "__shared/PilotPartComponentData" -- recreates the pilot PartComponentData and its components
		pilotPartComponentData.transform = LinearTransform(
			Vec3(1, 0, 0),
			Vec3(0, 1, 0),
			Vec3(0, 0, 1),
			Vec3(-0.391037047, -1.03854346, 2.8959167))
		venomChassisComponentData.components:add(pilotPartComponentData)

		local pilotSuitLogicReferenceObjectData = LogicReferenceObjectData(ResourceManager:FindInstanceByGuid(Guid("97945D87-011D-11E0-B97C-FC495C335A52"), Guid("F8BE651E-8AC5-4189-A1D9-1743DAA3C56C"))) --Changes soldier appearance to pilot suits (EventId.Enter) and back (EventId.Exit)

		local pilotSuitEnterEventConnection = eventConnections:Create(pilotPartComponentData.components[1], pilotSuitLogicReferenceObjectData, 1577401599, 201149837, 3)	--OnPlayerEnter, Enter, EventConnectionTargetType_Server
		venomVehicleBlueprint.eventConnections:add(pilotSuitEnterEventConnection)

		local pilotSuitExitEventConnection = eventConnections:Create(pilotPartComponentData.components[1], pilotSuitLogicReferenceObjectData, 47785047, 2088518501, 3)	--OnPlayerExit, Exit, EventConnectionTargetType_Server
		venomVehicleBlueprint.eventConnections:add(pilotSuitExitEventConnection)

		-- Add passenger seats -----------------------------------------------------------------------------------------
		local inputRestrictionEntityData = InputRestrictionEntityData()
		inputRestrictionEntityData.fire = false -- Disabling the fire input will "lower" the soldiers weapon
		inputRestrictionEntityData.overridePreviousInputRestriction = true
		inputRestrictionEntityData.applyRestrictionsToSpecificPlayer = true
		inputRestrictionEntityData.isEventConnectionTarget = 1
		venomVehicleEntityData.components:add(inputRestrictionEntityData)

		for index, params in pairs(passengerTransforms) do	-- params[1] = entry LT, params[2] = entry antEnum value
			local passengerPartComponentData = passengerComponents:CreateEntry(index, params[2] , params[1])
			venomChassisComponentData.components:add(passengerPartComponentData)

			local inputRestrictionEnterEventConnection = eventConnections:Create(passengerPartComponentData.components[1], inputRestrictionEntityData, 1577401599, -559281700, 3)	--OnPlayerEnter, Activate, EventConnectionTargetType_Server
			venomVehicleBlueprint.eventConnections:add(inputRestrictionEnterEventConnection)

			local inputRestrictionExitEventConnection = eventConnections:Create(passengerPartComponentData.components[1], inputRestrictionEntityData, 47785047, 1928776733, 3)	--OnPlayerExit, Deactivate, EventConnectionTargetType_Server
			venomVehicleBlueprint.eventConnections:add(inputRestrictionExitEventConnection)
		end

		print("Venom modified")
		done = true
	end
end)

-- Bundle mounting -----------------------------------------------------------------------------------------------------

Events:Subscribe('Level:LoadResources', function()
	ResourceManager:MountSuperBundle('xp1chunks')
	ResourceManager:MountSuperBundle('levels/xp1_004/xp1_004')
	ResourceManager:MountSuperBundle('xp3chunks')
	ResourceManager:MountSuperBundle('levels/xp3_shield/xp3_shield')
end)

Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
	if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
		print('Injecting bundles.')

		bundles = {
			'levels/xp1_004/xp1_004',
			'levels/xp1_004/cq_l',
			'levels/xp3_shield/xp3_shield',
			'levels/xp3_shield/conquestlarge0',
			bundles[1],
		}
		hook:Pass(bundles, compartment)
	end
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)
	local xp1_004_cq_lRegistry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('C7039B02-0415-6F1C-C65A-59A89432C783')))
	ResourceManager:AddRegistry(xp1_004_cq_lRegistry, ResourceCompartment.ResourceCompartment_Game)

	local xp3_shield_conquestlarge0Registry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('FC90635F-4589-EBB6-A323-EBB0050BC5BD')))
	ResourceManager:AddRegistry(xp3_shield_conquestlarge0Registry, ResourceCompartment.ResourceCompartment_Game)
end)
