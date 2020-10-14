
-- This mod adds the ATGM/TOW guided missile from the IFV to the scout helicopters.
-- This event happens after the data is loaded but before the level is created
Events:Subscribe('Level:RegisterEntityResources', function()
	-- The scout helis components dont share the exact same layout, pass the index of the minigun weaponComponent to the handler.
	local ah6Bp = ResourceManager:SearchForDataContainer("Vehicles/AH6/AH6_Littlebird")
	ModifyBlueprint(ah6Bp)
	local z11Bp = ResourceManager:SearchForDataContainer("Vehicles/Z11W/Z-11w")
	ModifyBlueprint(z11Bp)

	local customization = ResourceManager:SearchForDataContainer("Gameplay/Vehicles/SCOUTCustomization")
	AddUnlock(customization)
end)


function ModifyBlueprint(instance)
	local scoutHeliBp = VehicleBlueprint(instance)
	local scoutHeliData = VehicleEntityData(scoutHeliBp.object)

	local chassisComponent = ChassisComponentData(scoutHeliData.components[1])

	-- Custom WeaponComponent using the "Vehicles/common/WeaponData/IFV_ATGM_Firing" WeaponFiringData
	local weaponFiringAsset = WeaponFiringDataAsset(ResourceManager:SearchForDataContainer("Vehicles/common/WeaponData/IFV_ATGM_Firing"))

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

	-- The same unlockAsset that is added to the SCOUTCustomization
	local towUnlock = ValueUnlockAsset(ResourceManager:SearchForDataContainer("Persistence/Unlocks/Vehicles/IfvTOW"))

	-- The components of this UnlockComponent will be active when "IfvTOW" is selected
	local cannonUnlockComponent = UnlockComponentData()
	cannonUnlockComponent.unlockAsset = towUnlock
	cannonUnlockComponent.components:add(stanceFilterComponent)

	-- Add the UnlockComponent containing our custom components to the PartComponent that contains the other UnlockComponents for this vehicle.
	local unlocksParentComponent = PartComponentData(chassisComponent.components[6])
	unlocksParentComponent:MakeWritable()
	unlocksParentComponent.components:add(cannonUnlockComponent)

	-- Adjust the componentCount to account for the components added
	scoutHeliData:MakeWritable()
	scoutHeliData.runtimeComponentCount = scoutHeliData.runtimeComponentCount + 3
end

function AddUnlock(instance)
	
	local scoutCustomization = VeniceVehicleCustomizationAsset(instance)
	-- Custom unlocks are possible but they will always be empty selections, have been unable to link a UIVehicleUnlockDescription to a custom UnlockAsset
	-- We can steal unlocks from other vehicles and add them to the vehicles customization. Downside is that the weapon will be equipped if the unlock is selected in either of the vehicles customization.
	local towUnlock = ValueUnlockAsset(ResourceManager:SearchForDataContainer("Persistence/Unlocks/Vehicles/IfvTOW"))

	-- Vehicles have an active, passive and stance unlockslot, each slot is a CustomizationUnlockParts instance
	local stanceUnlocks = CustomizationUnlockParts(scoutCustomization.customization.unlockParts[3])
	stanceUnlocks:MakeWritable()
	stanceUnlocks.selectableUnlocks:insert(#stanceUnlocks.selectableUnlocks, towUnlock)
end
