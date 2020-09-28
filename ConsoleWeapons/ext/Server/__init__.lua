class 'ConsoleWeaponsServer'

function ConsoleWeaponsServer:__init()
	print("Initializing ConsoleWeaponsServer")
	self:RegisterVars()
	self:RegisterEvents()
end

function ConsoleWeaponsServer:RegisterVars()
	self.weaponTable = {}
	self.unlockTables = {}
end


function ConsoleWeaponsServer:RegisterEvents()
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
	Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
	NetEvents:Subscribe('ConsoleWeapons:EquipWeapon', self, self.OnEquipWeapon)
end

-- Store the reference of all the SoldierWeaponUnlockAssets that get loaded
function ConsoleWeaponsServer:OnPartitionLoaded(partition)
	local instances = partition.instances

	for _, instance in pairs(instances) do

		if instance:Is('SoldierWeaponUnlockAsset') then
			
			local weaponUnlockAsset = SoldierWeaponUnlockAsset(instance)
		
			-- Weapons/SAIGA20K/U_SAIGA_20K --> SAIGA_20K
			local weaponName = weaponUnlockAsset.name:match("/U_.+"):sub(4)
			
			self.weaponTable[weaponName] = weaponUnlockAsset
		end
	end
end

-- Once the everything is loaded, store the UnlockAssets in each CustomizationUnlockParts array (each array is an attachment/sight/camo slot).
function ConsoleWeaponsServer:OnLevelLoaded()
	
	for weaponName, weaponUnlockAsset in pairs(self.weaponTable) do
	
		if SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization ~= nil then -- Gadgets dont have customization
		
			self.unlockTables[weaponName] = {}
			
			local customizationUnlockParts = CustomizationTable(VeniceSoldierWeaponCustomizationAsset(SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization).customization).unlockParts
			
			for _, unlockParts in pairs(customizationUnlockParts) do
			
				for _, asset in pairs(unlockParts.selectableUnlocks) do
				
					-- Weapons/AN94/U_AN94_Acog --> Acog
					local unlockAssetName = asset.debugUnlockId:gsub("U_.+_","")

					self.unlockTables[weaponName][unlockAssetName] = asset
				end
			end
		end
	end
end

-- args[1]: weaponName, args[2]: weaponSlot, args[3+]: attachments
function ConsoleWeaponsServer:OnEquipWeapon(player, args)

	local attachments = {}
	
	for i = 3, #args do
		attachments[i-2] = self.unlockTables[args[1]][args[i]]
	end

	local weaponslot = tonumber(args[2]) or player.soldier.weaponsComponent.currentWeaponSlot
	player:SelectWeapon(weaponslot, self.weaponTable[args[1]], attachments)
end

g_ConsoleWeaponsServer = ConsoleWeaponsServer()
