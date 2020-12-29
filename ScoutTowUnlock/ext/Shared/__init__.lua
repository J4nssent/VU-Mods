-- This mod adds the ATGM/TOW guided missile from the IFV to the scout helicopters. 
-- Since creating new UnlockAssets (with description) is impossible, the mod reuses the TOW unlock from the IFV.
-- If a soldiers current IFV loadout has the TOW selected, it will be "selected" for the heli as well.

local ahBlueprintGuids = { instanceGuid = Guid('FD8AB748-FF4D-11DD-A7B1-F7C6DEEC9D32'), partitionGuid = Guid('FD8AB747-FF4D-11DD-A7B1-F7C6DEEC9D32') } -- Vehicles/AH6/AH6_Littlebird
local z11BlueprintGuids = { instanceGuid = Guid('D780AFF6-38B7-11DE-BF1C-984D9AEE762C'), partitionGuid = Guid('D78088E5-38B7-11DE-BF1C-984D9AEE762C') } -- Vehicles/Z11W/Z-11w

-- This one will be loaded on maps that have the IFV
local atgmFiringDataGuids = { instanceGuid = Guid('FD364562-ECDE-417B-A5D4-450F1980732A'), partitionGuid = Guid('ACFD0C2A-2D69-496A-AE55-9E09EE43BAF0') } -- Vehicles/common/WeaponData/IFV_ATGM_Firing
-- This one will be loaded on maps that have the stationary TOW 
--local atgmFiringDataGuids = { instanceGuid = Guid('938DFDC8-E138-0D20-2BEC-9743208CE358'), partitionGuid = Guid('9A3C60F7-4A0F-B735-3B7C-FA64DDE35E4E') } -- Vehicles/common/WeaponData/spec/IFV_ATGM_Firing_Kornet
local ifvTowUnlockGuids = { instanceGuid = Guid('9BD7BBE5-6A75-4067-A63A-BA99CD56E9F1'), partitionGuid = Guid('A717E586-C892-4F76-87DC-A8AEA0AD9FA2') } -- Persistence/Unlocks/Vehicles/IfvTOW

local scoutCustomizationGuids = { instanceGuid = Guid('93DB5A0B-1400-4370-8866-0F98592BB90E'), partitionGuid = Guid('93EA7787-829C-4491-8FBB-36358CDCB092') } -- Gameplay/Vehicles/SCOUTCustomization

Events:Subscribe('Level:LoadResources', function()

	WaitForInstances({ atgmFiringDataGuids, ifvTowUnlockGuids, ahBlueprintGuids }, ModifyBlueprint)
	WaitForInstances({ atgmFiringDataGuids, ifvTowUnlockGuids, z11BlueprintGuids }, ModifyBlueprint)

	WaitForInstances({ ifvTowUnlockGuids, scoutCustomizationGuids }, AddUnlock)
end)

function ModifyBlueprint(firingData, unlock, blueprint)

	print("Modifying scout heli blueprint")

	local scoutHeliBp = VehicleBlueprint(blueprint)
	local scoutHeliData = VehicleEntityData(scoutHeliBp.object)

	local chassisComponent = ChassisComponentData(scoutHeliData.components[1])

	-- Custom WeaponComponent using the "Vehicles/common/WeaponData/IFV_ATGM_Firing" WeaponFiringData
	local weaponFiringAsset = WeaponFiringDataAsset(firingData)

	local weaponComponent = WeaponComponentData()
	weaponComponent.weaponFiring = WeaponFiringData(weaponFiringAsset.data:Clone())
	weaponComponent.classification = WeaponClassification.WCNone
	
	-- The UI decides what crosshair to use depending on the weaponName hash it gets from the UIVehicleCompData
	-- https://github.com/EmulatorNexus/Venice-EBX/blob/b80b49f6be7010b968eca36654e70819402fa259/UI/Flow/Screen/Vehicle/DefaultHelicopterScreen.txt#L351
	weaponComponent.weaponItemHash = 2240645269

	-- The TOW requires LockingWeaponData with a LockingController to function properly
	local zoomLevelLockData = ZoomLevelLockData()
	zoomLevelLockData.outlineTaggedDistance = 0.0
	zoomLevelLockData.lockType = LockType.LockOnHeat

	local lockingController = LockingControllerData()
	lockingController.zoomLevelLock:add(zoomLevelLockData)

	local lockingWeaponData = LockingWeaponData()
	lockingWeaponData.isHoming = false
	lockingWeaponData.isGuided = true
	lockingWeaponData.lockingController = lockingController

	weaponComponent.customWeaponType = lockingWeaponData

	-- A stancefilter is used so the weaponComponent is only active on stance 1 (= secondary weapon equipped)
	local stanceFilterComponent = StanceFilterComponentData()
	stanceFilterComponent.validStances:add(1)
	stanceFilterComponent.stanceChangeTime = 1
	stanceFilterComponent.filterSpecificActions = false
	stanceFilterComponent.undoParentStanceFilter = false 
	stanceFilterComponent.components:add(weaponComponent)

	-- The components of this UnlockComponent will be active when "IfvTOW" is selected
	local cannonUnlockComponent = UnlockComponentData()
	cannonUnlockComponent.unlockAsset = ValueUnlockAsset(unlock)
	cannonUnlockComponent.components:add(stanceFilterComponent)

	-- Add the UnlockComponent containing our custom components to the PartComponent that contains the other UnlockComponents for this vehicle.
	local unlocksParentComponent = PartComponentData(chassisComponent.components[6])
	unlocksParentComponent:MakeWritable()
	unlocksParentComponent.components:add(cannonUnlockComponent)

	-- Adjust the componentCount to account for the components added
	scoutHeliData:MakeWritable()
	scoutHeliData.runtimeComponentCount = scoutHeliData.runtimeComponentCount + 3
end

function AddUnlock(unlock, customization)

	print("Adding IfvTOW UnlockAsset to scout customization")

	-- Custom unlocks are possible but they won't have any UI descriptions or icons in the menu.
	-- We can steal unlocks from other vehicles and add them to the vehicles customization. Downside is that the weapon will be equipped if the unlock is selected in either of the vehicles customization.
	local towUnlock = ValueUnlockAsset(unlock)

	-- Vehicles have an active, passive and stance unlockslot, each slot is a CustomizationUnlockParts instance
	local scoutCustomization = VeniceVehicleCustomizationAsset(customization)
	local stanceUnlocks = CustomizationUnlockParts(scoutCustomization.customization.unlockParts[3])
	stanceUnlocks:MakeWritable()
	stanceUnlocks.selectableUnlocks:add(towUnlock)
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