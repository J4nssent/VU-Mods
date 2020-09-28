class 'ConsoleWeaponsClient'

function ConsoleWeaponsClient:__init()
	print("Initializing ConsoleWeaponsClient")
	self:RegisterVars()
	self:RegisterEvents()
	self:RegisterConsoleCommands()
end


function ConsoleWeaponsClient:RegisterVars()
	self.weaponTable = {}
	self.weaponKeys = {"870", "A91", "ACR", "AEK971", "AEK971_M320_HE", "AEK971_M320_LVG", "AEK971_M320_SHG", "AEK971_M320_SMK", "AK74M", "AK74M_M26Mass", "AK74M_M26Mass_Flechette", "AK74M_M26Mass_Frag", "AK74M_M26Mass_Slug", "AK74M_M320_HE", "AK74M_M320_LVG", "AK74M_M320_SHG", "AK74M_M320_SMK", "AK74M_US", "AKS74u", "AKS74u_US", "AN94", "AN94_M320_HE", "AN94_M320_LVG", "AN94_M320_SHG", "AN94_M320_SMK", "ASVal", "Crossbow_Scoped_Cobra", "Crossbow_Scoped_RifleScope", "DAO-12", "F2000", "FAMAS", "FGM148", "FIM92", "G36C", "G3A3", "G3A3_M26_Buck", "G3A3_M26_Flechette", "G3A3_M26_Frag", "G3A3_M26_Slug", "Glock17", "Glock17_Silenced", "Glock18", "Glock18_Silenced", "HK417", "HK53", "JNG90", "Jackhammer", "KH2002", "Knife", "Knife_Razor", "L85A2", "L86", "L96", "LSAT", "M1014", "M16A4", "M16A4_M26_Buck", "M16A4_M26_Flechette", "M16A4_M26_Frag", "M16A4_M26_Slug", "M16A4_M320_HE", "M16A4_M320_LVG", "M16A4_M320_SHG", "M16A4_M320_SMK", "M16A4_RU", "M16_Burst", "M1911", "M1911_Lit", "M1911_Silenced", "M1911_Tactical", "M240", "M249", "M27IAR", "M27IAR_RU", "M39EBR", "M4", "M40A5", "M416", "M416_M26_Buck", "M416_M26_Flechette", "M416_M26_Frag", "M416_M26_Slug", "M416_M320_HE", "M416_M320_LVG", "M416_M320_SHG", "M416_M320_SMK", "M4A1", "M4A1_RU", "M60", "M67", "M9", "M93R", "M98B", "M9_RU", "M9_Silenced", "M9_TacticalLight", "MG36", "MK11", "MK11_RU", "MP412Rex", "MP443", "MP443_Silenced", "MP443_TacticalLight", "MP443_US", "MP5K", "MP7", "MTAR", "MagpulPDR", "P90", "PP-19", "PP2000", "Pecheneg", "QBB-95", "QBU-88_Sniper", "QBZ-95B", "RPG7", "RPK-74M", "RPK-74M_US", "SAIGA_20K", "SCAR-H", "SCAR-L", "SCAR-L_M26_Buck", "SCAR-L_M26_Flechette", "SCAR-L_M26_Frag", "SCAR-L_M26_Slug", "SCAR-L_M320_HE", "SCAR-L_M320_LVG", "SCAR-L_M320_SHG", "SCAR-L_M320_SMK", "SG553LB", "SKS", "SMAW", "SPAS12", "SV98", "SVD", "SVD_US", "Sa18IGLA", "SteyrAug", "SteyrAug_M26_Buck", "SteyrAug_M26_Flechette", "SteyrAug_M26_Frag", "SteyrAug_M26_Slug", "SteyrAug_M320_HE", "SteyrAug_M320_LVG", "SteyrAug_M320_SHG", "SteyrAug_M320_SMK", "Taurus44", "Taurus44_Scoped", "Type88", "UMP45", "USAS-12"}	
	self.gadgetKeys = {"Ammobag", "C4", "Claymore", "Defib", "EODBot", "M15", "M224", "M26Mass", "M26Mass_Flechette", "M26Mass_Frag", "M26Mass_Slug", "M320_HE", "M320_LVG", "M320_SHG", "M320_SMK", "MAV", "Medkit", "RadioBeacon", "Repairtool", "SOFLAM", "UGS"}
	self.unlockTables = {}
end


function ConsoleWeaponsClient:RegisterEvents()
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
	Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
end

-- Registering console commands is only possible in a client script.
function ConsoleWeaponsClient:RegisterConsoleCommands()
	Console:Register('list', '[weapons | gadgets] List all available weapons/gadgets', self, self.OnListWeapons)
	Console:Register('listAttachments', '<weapon> List available attachments for (equipped) weapon', self, self.OnListAttachments)
	Console:Register('equip', '<weapon/gadget> [weaponSlot] [attachment] [attachment]... Equip a weapon/gadget in weaponSlot with attachments', self, self.OnEquipWeapon)
end

-- Store the reference of all the SoldierWeaponUnlockAssets that get loaded. 
function ConsoleWeaponsClient:OnPartitionLoaded(partition)
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

-- Once the everything is loaded, store the names of the UnlockAssets in each CustomizationUnlockParts array (each array is an attachment/sight/camo slot).
function ConsoleWeaponsClient:OnLevelLoaded()
	
	for weaponName, weaponUnlockAsset in pairs(self.weaponTable) do
	
		if SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization ~= nil then
		
			self.unlockTables[weaponName] = {}
			
			local customizationUnlockParts = CustomizationTable(VeniceSoldierWeaponCustomizationAsset(SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization).customization).unlockParts
			
			for _, unlockParts in pairs(customizationUnlockParts) do
			
				for _, asset in pairs(unlockParts.selectableUnlocks) do
				
					local unlockAssetName = asset.debugUnlockId:gsub("U_.+_","")
					
					self.unlockTables[weaponName][unlockAssetName] = unlockAssetName
				end
			end
		end
	end
end

function ConsoleWeaponsClient:OnListWeapons(args)

	local response = ""
		
	if args[1] == nil then
		
		for key,value in pairs(self.weaponTable) do
			response = response..string.format("\n")..key
		end
			
	elseif string.lower(args[1]) == 'weapons' then
		
		for _,key in pairs(self.weaponKeys) do
			response = response..string.format("\n")..key
		end
		
	elseif string.lower(args[1]) == 'gadgets' then
		
		for _,key in pairs(self.gadgetKeys) do
			response = response..string.format("\n")..key
		end
		
	else
	
		response = 'Usage: _weapons.list_ [weapons | gadgets]'	
	end
	
	return response
end


function ConsoleWeaponsClient:OnListAttachments(args)

	-- Print usage instructions if we get an invalid number of arguments or the wrong arguments
	if  (#args > 1) or args[1] == nil then
	
		return 'Usage: _weapons.listAttachments_ <*weapon*>'	
	end

	args[1] = firstToUpper(args[1])
	
	if self.weaponTable[args[1]] == nil then 
	
		for weaponName,_ in pairs(self.weaponTable) do
			
			if string.lower(weaponName):match(string.lower(args[1])) then
			
				args[1] = weaponName
				
				break
			end
		end
	end
	
	if self.weaponTable[args[1]] == nil then 
	
		return 'Error: **Invalid weapon specified.**'	
	end
	
	if self.unlockTables[args[1]] == nil then

		return "**No attachments for "..args[1].."**"	
	end
	
	local response = args[1]..':\n'

	for key,_ in pairs(self.unlockTables[args[1]]) do
		response = response..'\n'..key
	end

	return response
end
	
	
function ConsoleWeaponsClient:OnEquipWeapon(args)

	-- The player is alive when player.soldier ~= nil
	if PlayerManager:GetLocalPlayer().soldier == nil then
		
		return "Error: **Player isn't spawned**"
	end
	
	-- Validate the arguments.
	if  args[1] == nil or (args[2] ~= nil and tonumber(args[2]) == nil) then
	
		return 'Usage: `consoleweapons.equip` <*weapon*> [*weaponSlot*][*attachment*][*attachment*]...'
		
	elseif args[2] ~= nil and tonumber(args[2]) > 9 then
	
		return 'Error: **Invalid weaponSlot specified.**'

	end

	args[1] = firstToUpper(args[1])
	
	if self.weaponTable[args[1]] == nil then 
	
		for weaponName,_ in pairs(self.weaponTable) do

			if string.lower(weaponName):match(string.lower(args[1])) then
		
				-- Prevent the mod from equipping AN94_M320_HE when typing AN, use the full name to equip these variants
				if weaponName:match("M320") or weaponName:match("M26") then
				
					if string.lower(args[1]):match("m320") or string.lower(args[1]):match("m26") then

						args[1] = weaponName
		
						break
					end
				else
					args[1] = weaponName

					break
				end
			end
		end
	end
	
	if self.weaponTable[args[1]] == nil then 
	
		return 'Error: **Invalid weapon specified.**'
	end
	
	if #args > 2 then
	
		for i = 3, #args do
		
			local matched = false
	
			for unlockName,_ in pairs(self.unlockTables[args[1]]) do

				if string.lower(unlockName):match(string.lower(args[i])) then
				
					matched = true
					
					args[i] = unlockName
					
					break
				end
			end
			
			if not matched then

				return 'Error: **Invalid attachment specified.**'
			end
		end
	end

	-- Notify the server it needs to change the players weapon
	NetEvents:SendLocal('ConsoleWeapons:EquipWeapon', args)
	return 'Equipped *'..args[1]..'*'
end

function firstToUpper(str)

    return (str:gsub("^%l", string.upper))
end

g_ConsoleWeaponsClient = ConsoleWeaponsClient()

