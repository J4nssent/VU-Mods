
-- This mod adds the rocket pods from the attack helis to the scout helicopters.
-- This event happens after the data is loaded but before the level is created
Events:Subscribe('Level:RegisterEntityResources', function()
	-- The scout helis components dont share the exact same layout, pass the index of the minigun weaponComponent to the handler.
	local ah6Bp = ResourceManager:SearchForDataContainer("Vehicles/AH6/AH6_Littlebird")
	ModifyBlueprint(3, ah6Bp)
	local z11Bp = ResourceManager:SearchForDataContainer("Vehicles/Z11W/Z-11w")
	ModifyBlueprint(1, z11Bp)

	local customization = ResourceManager:SearchForDataContainer("Gameplay/Vehicles/SCOUTCustomization")
	AddUnlock(customization)
end)

function ModifyBlueprint(minigunIndex, blueprint)
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
	local weaponFiringAsset = WeaponFiringDataAsset(ResourceManager:SearchForDataContainer("Vehicles/common/WeaponData/RocketPods_Firing"))

	local rocketpodsWeaponComponent = WeaponComponentData()
	rocketpodsWeaponComponent.weaponFiring = WeaponFiringData(weaponFiringAsset.data:Clone())
	
	-- The UI decides what crosshair to use depending on the weaponName hash it gets from the UIVehicleCompData
	-- https://github.com/EmulatorNexus/Venice-EBX/blob/b80b49f6be7010b968eca36654e70819402fa259/UI/Flow/Screen/Vehicle/DefaultHelicopterScreen.txt#L351
	rocketpodsWeaponComponent.weaponItemHash = 145711230

	-- The same unlockAsset that is added to the SCOUTCustomization
	local rocketpodsUnlock = ValueUnlockAsset(ResourceManager:SearchForDataContainer("Persistence/Unlocks/Vehicles/JetRocketStance"))

	-- The components of this UnlockComponent will be active when "JetRocketStance" is equipped
	local rocketpodsUnlockComponent = UnlockComponentData()
	rocketpodsUnlockComponent.unlockAsset = rocketpodsUnlock
	rocketpodsUnlockComponent.components:add(rocketpodsWeaponComponent)

	-- Create an identical UnlockComponent with "invertUnlockTest" set to true (its components will be activated when the unlock isn't selected. The original minigun weaponComponent is added to this UnlockComponent.
	local minigunUnlockComponent = UnlockComponentData()
	minigunUnlockComponent.unlockAsset = rocketpodsUnlock
	minigunUnlockComponent.invertUnlockTest = true
	minigunUnlockComponent.components:add(miniGunWeaponComponent)

	-- Add both UnlockComponents to the stanceFilters components
	stanceFilterComponent.components:add(minigunUnlockComponent)
	stanceFilterComponent.components:add(rocketpodsUnlockComponent)

	-- Adjust the componentCount to account for the added components 
	scoutHeliData:MakeWritable()
	scoutHeliData.runtimeComponentCount = scoutHeliData.runtimeComponentCount + 3
end

function AddUnlock(instance)
	
	local scoutCustomization = VeniceVehicleCustomizationAsset(instance)
	-- Custom unlocks are possible but they will always be empty selections, I have been unable to link a UIVehicleUnlockDescription to a custom UnlockAsset
	-- We can steal unlocks from other vehicles and add them to the vehicles customization.
	local rocketpodsUnlock = ValueUnlockAsset(ResourceManager:SearchForDataContainer("Persistence/Unlocks/Vehicles/JetRocketStance"))

	-- Vehicles have an active, passive and stance unlockslot, each slot is a CustomizationUnlockParts instance
	local activeUnlocks = CustomizationUnlockParts(scoutCustomization.customization.unlockParts[1])
	activeUnlocks:MakeWritable()
	activeUnlocks.selectableUnlocks:insert(#activeUnlocks.selectableUnlocks, rocketpodsUnlock)
end



