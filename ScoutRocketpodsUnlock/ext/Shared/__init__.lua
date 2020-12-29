
local ahBlueprint = { instanceGuid = Guid('FD8AB748-FF4D-11DD-A7B1-F7C6DEEC9D32'), partitionGuid = Guid('FD8AB747-FF4D-11DD-A7B1-F7C6DEEC9D32') } -- Vehicles/AH6/AH6_Littlebird
local z11Blueprint = { instanceGuid = Guid('D780AFF6-38B7-11DE-BF1C-984D9AEE762C'), partitionGuid = Guid('D78088E5-38B7-11DE-BF1C-984D9AEE762C') } -- Vehicles/Z11W/Z-11w

local rocketpodsFiringData = { instanceGuid = Guid('173E068D-F66C-4A79-9D6C-7AB0ED3175E5'), partitionGuid = Guid('E64E52BD-4E40-4BFE-B6C3-49523084AE94') } -- Vehicles/common/WeaponData/RocketPods_Firing
local rocketpodsUnlock = { instanceGuid = Guid('814E97DC-1611-4086-8B1B-558CC7CB83E6'), partitionGuid = Guid('55C390EB-84A2-47BF-8DFA-EAA9ED29A331') } -- Persistence/Unlocks/Vehicles/JetRocketStance

local scoutCustomization = { instanceGuid = Guid('93DB5A0B-1400-4370-8866-0F98592BB90E'), partitionGuid = Guid('93EA7787-829C-4491-8FBB-36358CDCB092') } -- Gameplay/Vehicles/SCOUTCustomization

Events:Subscribe('Level:LoadResources', function()
	-- The scout helis dont share the exact same component layout
	WaitForInstances({ rocketpodsFiringData, rocketpodsUnlock, ahBlueprint }, function(firingData, unlock, blueprint) ModifyBlueprint(3, firingData, unlock, blueprint) end)
	WaitForInstances({ rocketpodsFiringData, rocketpodsUnlock, z11Blueprint }, function(firingData, unlock, blueprint) ModifyBlueprint(1, firingData, unlock, blueprint) end)

	WaitForInstances({ rocketpodsUnlock, scoutCustomization }, AddUnlock)
end)

function ModifyBlueprint(minigunIndex, firingData, unlock, blueprint)

	print("Modifying scout heli blueprint")

	local scoutHeliBp = VehicleBlueprint(blueprint)
	local scoutHeliData = VehicleEntityData(scoutHeliBp.object)

	local chassisComponent = ChassisComponentData(scoutHeliData.components[1])

	-- Remove the original MiniGun WeaponComponent from the StanceFilterComponent (the stancefilters components are only active in a specific stance: primary or secondary equipped) 
	local stanceFilterComponent = StanceFilterComponentData(chassisComponent.components[5])
	stanceFilterComponent:MakeWritable()
	
	-- Save the original MiniGun WeaponComponent to readd it later
	local miniGunWeaponComponent = WeaponComponentData(stanceFilterComponent.components[minigunIndex]:Clone())
	stanceFilterComponent.components:erase(minigunIndex)

	-- Custom WeaponComponent using the "Vehicles/common/WeaponData/RocketPods_Firing" WeaponFiringData
	local weaponFiringAsset = WeaponFiringDataAsset(firingData)

	local rocketpodsWeaponComponent = WeaponComponentData()
	rocketpodsWeaponComponent.weaponFiring = WeaponFiringData(weaponFiringAsset.data:Clone())
	
	-- The UI decides what crosshair to use depending on the weaponName hash it gets from the UIVehicleCompData
	-- https://github.com/EmulatorNexus/Venice-EBX/blob/b80b49f6be7010b968eca36654e70819402fa259/UI/Flow/Screen/Vehicle/DefaultHelicopterScreen.txt#L351
	rocketpodsWeaponComponent.weaponItemHash = 145711230

	-- The components of this UnlockComponent will be active when "JetRocketStance" is equipped
	local rocketpodsUnlockComponent = UnlockComponentData()
	rocketpodsUnlockComponent.unlockAsset = ValueUnlockAsset(unlock)
	rocketpodsUnlockComponent.components:add(rocketpodsWeaponComponent)

	-- Create an identical UnlockComponent with "invertUnlockTest" set to true (its components will be activated when the unlock isn't selected. The original minigun weaponComponent is added to this UnlockComponent.
	local minigunUnlockComponent = UnlockComponentData()
	minigunUnlockComponent.unlockAsset = ValueUnlockAsset(unlock)
	minigunUnlockComponent.invertUnlockTest = true
	minigunUnlockComponent.components:add(miniGunWeaponComponent)

	-- Add both UnlockComponents to the stanceFilters components
	stanceFilterComponent.components:add(minigunUnlockComponent)
	stanceFilterComponent.components:add(rocketpodsUnlockComponent)

	-- Adjust the componentCount to account for the added components 
	scoutHeliData:MakeWritable()
	scoutHeliData.runtimeComponentCount = scoutHeliData.runtimeComponentCount + 3
end

function AddUnlock(unlock, customization)
	
	print("Adding RocketPods UnlockAsset to scout customization")

	-- Custom unlocks are possible but they won't have any UI descriptions or icons in the menu.
	-- We can steal unlocks from other vehicles and add them to the vehicles customization.
	local rocketpodsUnlock = ValueUnlockAsset(unlock)

	-- Vehicles have an active, passive and stance unlockslot, each slot is a CustomizationUnlockParts instance
	local scoutCustomization = VeniceVehicleCustomizationAsset(customization)
	local activeUnlocks = CustomizationUnlockParts(scoutCustomization.customization.unlockParts[1])
	activeUnlocks:MakeWritable()
	activeUnlocks.selectableUnlocks:add(rocketpodsUnlock)
end

-- Calls the handler function once all the instances are loaded
function WaitForInstances(guidTable, loadHandler)

	local instances = {}
    -- Register a load handler for each instance
    for index, guids in ipairs(guidTable) do
        -- Each time an instance loads, check if the others have loaded.
        ResourceManager:RegisterInstanceLoadHandlerOnce(guids.partitionGuid, guids.instanceGuid, function(instance)

        	instances[index] = instance

        	for i = 1, #guidTable do
        		-- If an instance hasn't loaded, check if it already was loaded
        		instances[i] = instances[i] or ResourceManager:FindInstanceByGuid(guidTable[i].partitionGuid, guidTable[i].instanceGuid)

    			if instances[i] == nil then 
    				return
    			end
        	end
        	
        	loadHandler(table.unpack(instances))
        end)
    end
end




