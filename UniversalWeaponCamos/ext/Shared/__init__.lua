
-- This mod creates a mesh texture variation and matching unlockAsset for every texture in the config file, for every primary weapon in the game.
-- It does not create a MeshMaterialVariation for the custom MeshVariationDatabaseEntry (unlike vanilla), so the replaced textures use the same shader and shader parameters as the original

local ITEMS_PER_FRAME = 100
local Async = require('__shared/Async')

local config = require('__shared/config')
local isWeaponMesh = require('__shared/weaponMeshes')

local variationDataTables = {}

Events:Subscribe('Partition:Loaded', function(partition)
	
	if partition.primaryInstance:Is('MeshVariationDatabase') then

		local meshVariationDatabase = MeshVariationDatabase(partition.primaryInstance)

		local level = meshVariationDatabase.name:match('/[^/]+') -- /MP_001

		-- Find the gamemode MeshVariationDatabase, it contains all weapon meshes
		if meshVariationDatabase.name:gsub(level,''):match('Levels/.+/MeshVariationDb_Win32') then -- Level: Levels/MeshVariationDb_Win32, Gamemode: Levels/Conquest_Large/MeshVariationDb_Win32

			Async:Start(function()
				AddWeaponSkinEntries(meshVariationDatabase)
			end)
		end
	end
end)

function AddWeaponSkinEntries(meshVariationDatabase)

	-- Iterate all entries in the gamemodes MeshVariationDatabase
	for index, entry in pairs(meshVariationDatabase.entries) do

		if math.fmod(index, ITEMS_PER_FRAME) == 0 then

			Async:Yield()
		end

		entry = MeshVariationDatabaseEntry(entry)

		-- Clone the "Default"/"No Camo" MeshVariationDatabaseEntries, none of the weapon meshes are lazy loaded.
		if entry.variationAssetNameHash == 0 and not entry.mesh.isLazyLoaded then

			local meshName = MeshAsset(entry.mesh).name

			-- Check if mesh is a weapon mesh
			if isWeaponMesh(meshName) then

				local weaponName = meshName:gsub('_.p_Mesh','')

				-- Create an array for every weapon
				if variationDataTables[weaponName] == nil then
					
					variationDataTables[weaponName] = {}

					-- Add a table to the array with relevant data for each weapon/camo combination (2 meshes/database entries per table).
					for camoId, camoInfo in pairs(config) do
					
						local variationName = weaponName..'_'..camoId					-- Weapons/AEK971/AEK971_RU_PARTIZAN		
						local variationNameHash = MathUtils:FNVHash(variationName)

						variationDataTables[weaponName][camoId] = 
						{ 
							mesh1pEntry = nil,
							mesh3pEntry = nil,
							variationName = variationName,
							variationNameHash = variationNameHash,
							camoInfo = camoInfo
						}
					end
				end

				-- Clone the default weapon mesh entry (and change name hash and texture values) for each camo
				if meshName:ends('1p_Mesh') then

					for camoId, entryData in pairs(variationDataTables[weaponName]) do
					
						entryData.mesh1pEntry = CloneEntry(entry, entryData.variationNameHash, config[camoId].textureName)
					end

				elseif meshName:ends('3p_Mesh') then

					for camoId, entryData in pairs(variationDataTables[weaponName]) do

						entryData.mesh3pEntry = CloneEntry(entry, entryData.variationNameHash, config[camoId].textureName)
					end
				end
			end 
		end
	end

	-- Add the custom entries to the MeshVariationDatabase after iterating it
	meshVariationDatabase:MakeWritable()

	for weaponName, weaponVariations in pairs(variationDataTables) do
	
		for _, variationData in pairs(weaponVariations) do

			meshVariationDatabase.entries:add(variationData.mesh1pEntry)
			meshVariationDatabase.entries:add(variationData.mesh3pEntry)
		end
	end
end

function CloneEntry(entry, variationNameHash, textureName)

	-- Clone "Default"/"No Camo" MeshVariationDatabaseEntry
	local clonedEntry = MeshVariationDatabaseEntry(entry:Clone(MathUtils:RandomGuid()))

	-- Change variation hash (the unlockAsset for the weapon camo will be linked to a variation with the same hash)
	clonedEntry.variationAssetNameHash = variationNameHash
	
	-- Only modify materials with these shaders: Weapons/Shaders/WeaponPresetShadow(NoCamo)FP(_xp2) or Weapons/Shaders/WeaponPreset(NoCamo)3P(_xp2)
	for _, databaseMaterial in pairs(clonedEntry.materials) do

		local originalShaderName = MeshMaterial(databaseMaterial.material).shader.shader.name:gsub('_xp2','')

		if originalShaderName:ends('FP') or originalShaderName:ends('3P') then

			ModifyTextureParameters(databaseMaterial, textureName)
		else
			-- print("Did not modify \""..originalShaderName.."\" material of entry: "..entry.instanceGuid:ToString('D'))
		end
	end

	return clonedEntry
end

function ModifyTextureParameters(databaseMaterial, textureName)

	-- Table that maps ParameterNames to their index in the databaseMaterial
	local parameterIndexes = {}

	for i, textureParameter in pairs(databaseMaterial.textureParameters) do

		parameterIndexes[textureParameter.parameterName] = i
	end

	-- Create a new texture with the right name (textures are looked up by their name)
	local camoTexture = TextureAsset()
	camoTexture.name = textureName

	-- If the material has a Camo texture, replace it
	if parameterIndexes['Camo'] ~= nil then

		local parameter = databaseMaterial.textureParameters[parameterIndexes['Camo']]
		parameter.value = camoTexture

	-- If not, replace the Diffuse texture
	elseif parameterIndexes['Diffuse'] ~= nil then

		local parameter = databaseMaterial.textureParameters[parameterIndexes['Diffuse']]
		parameter.value = camoTexture
	else
		print("no Diffuse or Camo parameters for material: "..databaseMaterial.material.instanceGuid:ToString('D'))
	end
end


local unlockAssets = {}
local unlockPartsGuids = {}

Events:Subscribe('Level:RegisterEntityResources', function(levelData)

	-- The unlockAssets only need to be created and added to customization once
	if #unlockAssets == 0 then

		CreateUnlockAssets()

		if SharedUtils:IsClientModule() then
			-- CreateUnlockDescriptions()
		end
	end

	-- Sort table keys so stuff gets added to the registry in the same order
   	local sortedWeaponNames = {}
    for weaponName in pairs(variationDataTables) do table.insert(sortedWeaponNames, weaponName) end
    table.sort(sortedWeaponNames)

    local sortedCamoIds = {}
	for id in pairs(config) do table.insert(sortedCamoIds, id) end
	table.sort(sortedCamoIds)

	-- Add custom UnlockAssets to a registry
	local registry = RegistryContainer()

	for _, weaponName in ipairs(sortedWeaponNames) do

		for _, camoId in ipairs(sortedCamoIds) do

			local data = unlockAssets[weaponName][camoId]

			registry.assetRegistry:add(data.unlockAsset)
			registry.assetRegistry:add(data.variation)
		end
	end

	-- Add the registry
	ResourceManager:AddRegistry(registry, ResourceCompartment.ResourceCompartment_Game)

	variationDataTables = {}
end)

function CreateUnlockAssets()

	for weaponName, weaponVariations in pairs(variationDataTables) do

		-- Find the weapon blueprint by name.
		local soldierWeaponBlueprint = SoldierWeaponBlueprint(ResourceManager:SearchForDataContainer(weaponName))

		local customizationAsset = VeniceSoldierWeaponCustomizationAsset(SoldierWeaponData(soldierWeaponBlueprint.object).customization)
		local customizationTable = CustomizationTable(customizationAsset.customization)

		local customizationPartition = ResourceManager:FindPartitionForInstance(customizationAsset)

		-- Every unlock slot is a CustomizationUnlockParts instance, the 4th one is for camos 
		local originalUnlockParts = customizationTable.unlockParts[4]
	
		-- Store the Guids of the unlockParts so we can revert the changes when the extension unloads
		unlockPartsGuids[weaponName] = { customization = customizationTable.instanceGuid, unlockParts = originalUnlockParts.instanceGuid }
		
		unlockAssets[weaponName] = {}

		-- Custom CustomizationUnlockParts to replace the vanilla one
		local customUnlockParts	= CustomizationUnlockParts()

		for camoId, variationData in pairs(weaponVariations) do

			local objectVariation = ObjectVariation(MathUtils:RandomGuid())
			objectVariation.name = variationData.variationName
			objectVariation.nameHash = variationData.variationNameHash

			local unlock = CreateCustomUnlock(weaponName, camoId, soldierWeaponBlueprint, objectVariation)

			customUnlockParts.selectableUnlocks:add(unlock)
			customizationPartition:AddInstance(unlock)

			unlockAssets[weaponName][camoId] = { unlockAsset = unlock, variation = objectVariation }
		end

		-- Replace vanilla unlockParts
		customizationTable:MakeWritable()
		customizationTable.unlockParts[4] = customUnlockParts
	end
end

local UINT_MAX = 4294967296

function CreateCustomUnlock(weaponName, camoId, soldierWeaponBlueprint, objectVariation)

	local weaponId = weaponName:match('/.-/'):gsub('/',''):upper()		-- AEK971

	local unlockId =  "U_"..weaponId.."_CAMO_"..camoId 					-- U_AEK971_CAMO_RU_IZLOM
	local unlockName = "Weapons/"..weaponId.."/"..unlockId 				-- Weapons/AEK971/U_AEK971_CAMO_RU_IZLOM
	local unlockIdentifier = MathUtils:FNVHash(unlockName) + UINT_MAX

	local blueprintAndVariationPair = BlueprintAndVariationPair(MathUtils:RandomGuid())
	blueprintAndVariationPair.baseAsset = soldierWeaponBlueprint
	blueprintAndVariationPair.variation = objectVariation

	local customUnlock = UnlockAsset(MathUtils:RandomGuid())
	customUnlock.name = unlockName
	customUnlock.debugUnlockId = unlockId
	customUnlock.identifier = unlockIdentifier
	customUnlock.linkedTo:add(blueprintAndVariationPair)

	return customUnlock
end

-- Revert back to vanilla unlockParts when the mod is unloading.
Events:Subscribe('Extension:Unloading', function()
	
	for _, guids in pairs(unlockPartsGuids) do

		local customizationTable = CustomizationTable(ResourceManager:SearchForInstanceByGuid(guids.customization))
		local unlockParts = CustomizationUnlockParts(ResourceManager:SearchForInstanceByGuid(guids.unlockParts))

		customizationTable.unlockParts[4] = unlockParts
	end
end)	

--[[
-- Failed attempt to create a UIWeaponAccessoryDescription for each UnlockAsset
function CreateUnlockDescriptions(unlockAssets)

	local accessoryUIDescriptionAsset = UIItemDescriptionAsset(ResourceManager:SearchForDataContainer("UI/UIWeaponAccessoryMetaData"))
	accessoryUIDescriptionAsset:MakeWritable()

	local accessoryDescriptionPartition = ResourceManager:FindPartitionForInstance(accessoryUIDescriptionAsset)

	local defaultCamoDescription = accessoryDescriptionPartition:FindInstance(Guid('688B1FD0-FB8A-45E8-AEB9-747709C07B41'))

	for weaponName, camoUnlocks in pairs(unlockAssets) do

		for camoId, data in pairs(camoUnlocks) do

			local camoDescription = UIWeaponAccessoryDescription(defaultCamoDescription:Clone(MathUtils:RandomGuid()))
			camoDescription.name = config[camoId].displayName
			camoDescription.description = "The "..config[camoId].displayName.."flage that has been adapted for use with the "..weaponName:match('/.-/'):gsub('/','')
			camoDescription.itemIds:add(data.unlockAsset.identifier)

			accessoryUIDescriptionAsset.items:add(camoDescription)

			accessoryUIDescriptionAsset:AddInstance(camoDescription)
		end
	end
end

-- Failed attempt to add all custom camos of the same type to a vanilla UIWeaponAccessoryDescription for that type
function CreateUnlockDescriptions(unlockAssets)

	local accessoryUIDescriptionAsset = UIItemDescriptionAsset(ResourceManager:SearchForDataContainer("UI/UIWeaponAccessoryMetaData"))
	accessoryUIDescriptionAsset:MakeWritable()

	local accessoryDescriptionPartition = ResourceManager:FindPartitionForInstance(accessoryUIDescriptionAsset)

	local defaultCamoDescription = accessoryDescriptionPartition:FindInstance(Guid('688B1FD0-FB8A-45E8-AEB9-747709C07B41'))

	for camoId, camoInfo in pairs(config) do

		local camoDescription = UIWeaponAccessoryDescription(accessoryDescriptionPartition:FindInstance(camoInfo.uiDescriptionGuid))
		camoDescription:MakeWritable()
		camoDescription.name = camoInfo.displayName
		camoDescription.description = "The "..camoInfo.displayName.."flage that has been adapted for use with small arms"
		camoDescription.texturePath = camoInfo.textureName
		camoDescription.iconTexturePath = camoInfo.textureName
		camoDescription.unlockTexturePath = camoInfo.textureName
		camoDescription.itemIds:clear()

		for _, data in pairs(unlockAssets[camoId]) do

			camoDescription.itemIds:add(identifier)
		end
	end
end
--]]