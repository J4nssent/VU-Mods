
local bigTransform = LinearTransform(
	Vec3(0.6, 0, 0),
	Vec3(0, 0.6, 0),
	Vec3(0, 0, 0.6),
	Vec3(0, -0.35, 0))

local caseTransform = LinearTransform(
	Vec3(0.4, 0, 0),
	Vec3(0, 0.4, 0),
	Vec3(0, 0, 0.4),
	Vec3(0, -0.20, 0))

local mesh3pTransform = LinearTransform(
	Vec3(0.4, 0, 0),
	Vec3(0, 0.4, 0),
	Vec3(0, 0, 0.4),
	Vec3(0.10, -0.20, 0.10))

 Events:Subscribe('Level:RegisterEntityResources', function(levelData)

	local medicbagWeaponBp = SoldierWeaponBlueprint(ResourceManager:SearchForDataContainer("Weapons/Gadgets/Medicbag/MedicBag"))
	medicbagWeaponBp:MakeWritable()

	local medicbagWeapon = SoldierWeaponData(medicbagWeaponBp.object)
	medicbagWeapon:MakeWritable()

	local medicbagWeaponUnlock = SoldierWeaponUnlockAsset(ResourceManager:SearchForDataContainer("Weapons/Gadgets/Medicbag/U_Medkit"))
	medicbagWeaponUnlock:MakeWritable()

	local mesh = RigidMeshAsset(ResourceManager:SearchForDataContainer("props/streetprops/civiliancase_01/civiliancase_01_closed_Mesh"))

	-- since weaponMeshes can't be RigidMeshAssets, add a SocketObject (an attachment) and give it the rigidMesh instead
	local socketObject = WeaponRegularSocketObjectData()
	socketObject.asset1p = mesh
	socketObject.asset1pzoom = mesh
	socketObject.asset3p = mesh
	socketObject.transform = caseTransform
		
	local rigidMeshSocketTransform = RigidMeshSocketTransform()
	rigidMeshSocketTransform.socketObject = socketObject
	rigidMeshSocketTransform.transform = caseTransform

	-- Setting the attachments unlock to the medkit unlock will make it equipped by default
	local socket = SocketData()
	socket.unlockAsset = medicbagWeaponUnlock
	socket.boneName = "Wep_Root"
	socket.availableObjects:add(socketObject)
	
	medicbagWeapon.sockets:clear()
	medicbagWeapon.sockets:add(socket)

	local weaponState = WeaponStateData(medicbagWeapon.weaponStates[1])
	weaponState.referencedAssetHashes:add(2439325642)
	weaponState.mesh1p:ReplaceReferences(mesh)			-- This will not change the mesh but it will dissapear
	weaponState.meshZoom1p:ReplaceReferences(mesh)
	weaponState.mesh3p:ReplaceReferences(mesh)			-- This does actually work for some reason
	weaponState.mesh3pTransforms:clear()
	weaponState.mesh3pTransforms:add(mesh3pTransform)
	weaponState.mesh3pRigidMeshSocketObjectTransforms:clear()
	weaponState.mesh3pRigidMeshSocketObjectTransforms:add(rigidMeshSocketTransform)
end)


--Bundles ------------------------------------------------------
Events:Subscribe('Level:LoadResources', function()
   
	ResourceManager:MountSuperBundle('spchunks')
	ResourceManager:MountSuperBundle('levels/sp_new_york/sp_new_york')
	--ResourceManager:MountSuperBundle('levels/sp_bank/sp_bank')
end)

Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
    if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
        print('Injecting bundles.')

        bundles = {
		'levels/sp_new_york/sp_new_york',
		'levels/sp_new_york/trainride_sub',
		--'levels/sp_bank/sp_bank',
		--'levels/sp_bank/vaultart_sub',
		--'levels/sp_bank/vault_sub',
		bundles[1],
	    }

        hook:Pass(bundles, compartment)
    end
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)
    local nyregistry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('2542484D-BBEF-7B3C-4EC2-1AE0C537DDE4')))
    ResourceManager:AddRegistry(nyregistry, ResourceCompartment.ResourceCompartment_Game)

    --local vaultartregistry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('55592C91-90A9-8F88-0F46-E9C865CC3953')))
    --ResourceManager:AddRegistry(vaultartregistry, ResourceCompartment.ResourceCompartment_Game)

    --local vaultregistry = RegistryContainer(ResourceManager:SearchForInstanceByGuid(Guid('E9F1A353-C3DE-9630-E23B-C893F906E05B')))
    --ResourceManager:AddRegistry(vaultregistry, ResourceCompartment.ResourceCompartment_Game)
end)


