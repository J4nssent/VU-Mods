
local weaponUnlockGuid = Guid('9FA0A53B-F767-7A93-C6AD-06EB6BAB49F9')
local sightUnlockGuid = Guid('D3B246DB-3734-F880-6E6A-8E0A9E0BCCC1')

local sightTransform = LinearTransform(
	Vec3(0.7, 0, 0),
	Vec3(0, 0.7, 0),
	Vec3(0, 0, 0.5),
	Vec3(0, 0.038, 0.09))

local flashHideTransform = LinearTransform(
	Vec3(1, 0, 0),
	Vec3(0, 1, 0),
	Vec3(0, 0, 1),
	Vec3(0, 0.022133005783, 0.46))

local lightTransform = LinearTransform(
	Vec3(0, 1, 0),
	Vec3(-1, 0, 0),
	Vec3(0, 0, 1),
	Vec3(0.01, 0.02, 0.17))

local bayonetTransform = LinearTransform(
	Vec3(0, 1, 0),
	Vec3(0, 0, -1),
	Vec3(-1, 0, 0),
	Vec3(0, -0.015, 0.42))

local magnumWeaponUnlock = nil

Events:Subscribe('Partition:Loaded', function(partition)
	for _, instance in pairs(partition.instances) do
		-- The soldier kits (VeniceSoldierCustomizationAsset) get loaded after all other weapon blueprints, unlocks, meshes... 
		if instance:Is("VeniceSoldierCustomizationAsset") then
			local kit = VeniceSoldierCustomizationAsset(instance)

			local sidearmUnlocks = CustomizationUnlockParts(kit.weaponTable.unlockParts[2])

			local unlock = GetCustomWeaponUnlock(partition)
				
			sidearmUnlocks:MakeWritable()
			sidearmUnlocks.selectableUnlocks:add(unlock)
		end
	end
end)

-- Get or create the custom SoldierWeaponUnlockAsset
function GetCustomWeaponUnlock(partition)

	if magnumWeaponUnlock then
		return magnumWeaponUnlock
	end

	local extraUnlock = UnlockAsset(ResourceManager:SearchForDataContainer("Weapons/Taurus44/U_Taurus44_Suppressor")) --UnlockAsset(sightUnlockGuid)

	local magnumWeaponUnlock = SoldierWeaponUnlockAsset(ResourceManager:SearchForDataContainer("Weapons/Taurus44/U_Taurus44_GM"))

	magnumWeaponUnlock:MakeWritable()
	magnumWeaponUnlock.extra = extraUnlock

	-- reflex sight SocketObject ---------------------------------------------------------------
	local rx01SocketObjectData = WeaponRegularSocketObjectData()
	rx01SocketObjectData.asset1p = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/rx01/rx_01_1p_Mesh'))	
	rx01SocketObjectData.asset1pzoom = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/rx01/rx_01_1p_Mesh'))	
	rx01SocketObjectData.asset3p = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/rx01/rx_01_3p_Mesh'))	
	rx01SocketObjectData.referencedAssetHashes:add(297318704)
	rx01SocketObjectData.referencedAssetHashes:add(2156543922)
	rx01SocketObjectData.transform = sightTransform
		
	local rx01RigidMeshSocketTransform = RigidMeshSocketTransform()
	rx01RigidMeshSocketTransform.socketObject = rx01SocketObjectData
	rx01RigidMeshSocketTransform.transform = sightTransform

	-- reticule SocketObject -------------------------------------------------------------------	
	local reticuleSocketObjectData = WeaponRegularSocketObjectData()
	reticuleSocketObjectData.asset1pzoom = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/rx01/rx01_reticule_small_1p_Mesh'))
	reticuleSocketObjectData.referencedAssetHashes:add(3404892965)
	reticuleSocketObjectData.transform = sightTransform
		
	local reticuleRigidMeshSocketTransform = RigidMeshSocketTransform()
	reticuleRigidMeshSocketTransform.socketObject = reticuleSocketObjectData
	reticuleRigidMeshSocketTransform.transform = sightTransform

	-- sightrail SocketObject ------------------------------------------------------------------
	local sightrailSocketObjectData = WeaponRegularSocketObjectData(ResourceManager:SearchForInstanceByGuid(Guid("2BD4B182-5CCE-4002-925F-9E6B74FF7833")))

	-- flashsuppressor SocketObject ---------------------------------------------------------------
	local flashSocketObjectData = WeaponRegularSocketObjectData()
	flashSocketObjectData.asset1p = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/flashsuppressor/flashsuppressor_1p_Mesh'))	
	flashSocketObjectData.asset1pzoom = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/flashsuppressor/flashsuppressor_1p_Mesh'))	
	flashSocketObjectData.asset3p = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/flashsuppressor/flashsuppressor_3p_Mesh'))	
	flashSocketObjectData.referencedAssetHashes:add(3157209455)
	flashSocketObjectData.referencedAssetHashes:add(4164225517)
	flashSocketObjectData.transform = flashHideTransform

	local flashRigidMeshSocketTransform = RigidMeshSocketTransform()
	flashRigidMeshSocketTransform.socketObject = flashSocketObjectData
	flashRigidMeshSocketTransform.transform = flashHideTransform

	-- bayonet SocketObject ---------------------------------------------------------------
	local bayonetSocketObjectData = WeaponRegularSocketObjectData()
	bayonetSocketObjectData.asset1p = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/knife/knife_static_Mesh'))	
	bayonetSocketObjectData.asset1pzoom = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/knife/knife_static_Mesh'))	
	bayonetSocketObjectData.asset3p = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/knife/knife_static_Mesh'))	
	bayonetSocketObjectData.referencedAssetHashes:add(4081655807)
	bayonetSocketObjectData.transform = bayonetTransform

	local bayonetRigidMeshSocketTransform = RigidMeshSocketTransform()
	bayonetRigidMeshSocketTransform.socketObject = bayonetSocketObjectData
	bayonetRigidMeshSocketTransform.transform = bayonetTransform

	-- flashlight SocketObject ---------------------------------------------------------------
	local flashlightSocketObjectData = WeaponRegularSocketObjectData()
	flashlightSocketObjectData.asset1p = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/flashlight/tactical_light_1p_Mesh'))	
	flashlightSocketObjectData.asset1pzoom = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/flashlight/tactical_light_1p_Mesh'))	
	flashlightSocketObjectData.asset3p = RigidMeshAsset(ResourceManager:SearchForDataContainer('weapons/accessories/flashlight/tactical_light_3p_Mesh'))	
	flashlightSocketObjectData.referencedAssetHashes:add(1426670919)
	flashlightSocketObjectData.referencedAssetHashes:add(3862404549)
	flashlightSocketObjectData.transform = lightTransform

	local flashlightRigidMeshSocketTransform = RigidMeshSocketTransform()
	flashlightRigidMeshSocketTransform.socketObject = flashlightSocketObjectData
	flashlightRigidMeshSocketTransform.transform = lightTransform

	-- flashlight1p SocketObject ---------------------------------------------------------------
	local flashlight1pSocketObjectData = WeaponRegularSocketObjectData()	
	flashlight1pSocketObjectData.asset1p = SpatialPrefabBlueprint(ResourceManager:SearchForDataContainer('weapons/accessories/flashlight/flashlight_1p'))	
	flashlight1pSocketObjectData.asset1pzoom = SpatialPrefabBlueprint(ResourceManager:SearchForDataContainer('weapons/accessories/flashlight/flashlight_1p'))	
	flashlight1pSocketObjectData.transform = lightTransform

	local flashlight1pRigidMeshSocketTransform = RigidMeshSocketTransform()
	flashlight1pRigidMeshSocketTransform.socketObject = flashlight1pSocketObjectData
	flashlight1pRigidMeshSocketTransform.transform = lightTransform

	-- flashlight3p SocketObject ---------------------------------------------------------------
	local flashlight3pSocketObjectData = WeaponRegularSocketObjectData()	
	flashlight3pSocketObjectData.asset3p = PrefabBlueprint(ResourceManager:SearchForDataContainer('weapons/accessories/flashlight/flashlight_3p'))	
	flashlight3pSocketObjectData.transform = lightTransform

	local flashlight3pRigidMeshSocketTransform = RigidMeshSocketTransform()
	flashlight3pRigidMeshSocketTransform.socketObject = flashlight3pSocketObjectData
	flashlight3pRigidMeshSocketTransform.transform = lightTransform
	
	-- Adding socketObjects to SocketData
	local mainSocketData = SocketData()
	mainSocketData.unlockAsset = extraUnlock
	mainSocketData.boneName = "Wep_Root"
	mainSocketData.availableObjects:add(rx01SocketObjectData)
	mainSocketData.availableObjects:add(reticuleSocketObjectData)
	mainSocketData.availableObjects:add(sightrailSocketObjectData)
	mainSocketData.availableObjects:add(flashSocketObjectData)
	mainSocketData.availableObjects:add(flashlightSocketObjectData)
	mainSocketData.availableObjects:add(flashlightSocketObjectData)
	mainSocketData.availableObjects:add(bayonetSocketObjectData)
	
	local toggleSocketData = SocketData(ResourceManager:SearchForInstanceByGuid(Guid("17CB58EC-B5D9-4647-8615-48D33D44F22A")))
	toggleSocketData:MakeWritable()
	toggleSocketData.availableObjects:add(flashlight1pSocketObjectData)
	toggleSocketData.availableObjects:add(flashlight3pSocketObjectData)
		
	-- Modifiers
	local animationModifier = WeaponAnimationConfigurationModifier()
	animationModifier.animationConfiguration.weaponOffsetModuleData = WeaponOffsetData()
	animationModifier.animationConfiguration.weaponOffsetModuleData.weaponOffsetY = -0.215
	animationModifier.animationConfiguration.weaponOffsetModuleData.weaponZoomedOffsetY = -0.215
	animationModifier.animationConfiguration.weaponSpeedModuleData = WeaponSpeedData()
	animationModifier.animatedFireType = AnimatedFireEnum.AnimatedFireAutomatic

	-- Adding new data to rex SoldierWeaponData
	local magnumWeaponData = SoldierWeaponData(SoldierWeaponBlueprint(magnumWeaponUnlock.weapon).object)
	magnumWeaponData:MakeWritable()
	magnumWeaponData.sockets:add(mainSocketData)
	
	local extraModifierData = WeaponModifierData(magnumWeaponData.weaponModifierData[2])
	extraModifierData.modifiers:add(animationModifier)

	local magnumWeaponStateData = WeaponStateData(magnumWeaponData.weaponStates[1])
	magnumWeaponStateData.mesh3pRigidMeshSocketObjectTransforms:add(rx01RigidMeshSocketTransform)
	magnumWeaponStateData.mesh3pRigidMeshSocketObjectTransforms:add(reticuleRigidMeshSocketTransform)
	magnumWeaponStateData.mesh3pRigidMeshSocketObjectTransforms:add(flashRigidMeshSocketTransform)
	magnumWeaponStateData.mesh3pRigidMeshSocketObjectTransforms:add(flashlight1pRigidMeshSocketTransform)
	magnumWeaponStateData.mesh3pRigidMeshSocketObjectTransforms:add(flashlight3pRigidMeshSocketTransform)
	magnumWeaponStateData.mesh3pRigidMeshSocketObjectTransforms:add(flashlightRigidMeshSocketTransform)
	magnumWeaponStateData.mesh3pRigidMeshSocketObjectTransforms:add(bayonetRigidMeshSocketTransform)

	-- Change laser transform (sorry) -----------------------------------------------------------
	for i = 4, 7 do
		local socketTransform =  RigidMeshSocketTransform(magnumWeaponStateData.mesh3pRigidMeshSocketObjectTransforms[i])
		local transform = LinearTransform(
		Vec3(0, 1, 0),
		Vec3(-1, 0, 0),
		Vec3(0, 0, 1),
		Vec3(socketTransform.transform.trans.x + 0.002, socketTransform.transform.trans.y - 0.002, socketTransform.transform.trans.z + 0.02))
		if i == 4 then
			transform.trans = Vec3(transform.trans.x + 0.0015, transform.trans.y + 0.0015, transform.trans.z)
		end
		local socketObject = WeaponRegularSocketObjectData(socketTransform.socketObject)
		socketObject:MakeWritable()
		socketObject.transform = transform
		socketTransform.transform = transform
	end

	return magnumWeaponUnlock
end

Events:Subscribe('Level:LoadResources', function()
	-- static knife bundles
	ResourceManager:MountSuperBundle('spchunks')
	ResourceManager:MountSuperBundle('levels/sp_finale/sp_finale')
end)

Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
    if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
        print('Injecting bundles.')

        bundles = {
			'levels/sp_finale/sp_finale',
            'levels/sp_finale/trainride_sub',
            bundles[1],
        }

        hook:Pass(bundles, compartment)
    end
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)

	local trainride_sub_Registry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('0CDAD375-7094-E0B3-3D70-28B612C0DF61')))
    ResourceManager:AddRegistry(trainride_sub_Registry, ResourceCompartment.ResourceCompartment_Game)
end)
