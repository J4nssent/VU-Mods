class 'ConsoleWeaponsClient'

function ConsoleWeaponsClient:__init()
	print("Initializing ConsoleWeaponsClient")
	self:RegisterVars()
	self:RegisterEvents()
	self:RegisterConsoleCommands()
end


function ConsoleWeaponsClient:RegisterVars()
	self.weaponTable = {}
	self.weaponKeys = {"870", "A91", "ACR", "AEK971", "AEK971-M320-HE", "AEK971-M320-LVG", "AEK971-M320-SHG", "AEK971-M320-SMK", "AK74M", "AK74M-M26Mass", "AK74M-M26Mass-Flechette", "AK74M-M26Mass-Frag", "AK74M-M26Mass-Slug", "AK74M-M320-HE", "AK74M-M320-LVG", "AK74M-M320-SHG", "AK74M-M320-SMK", "AK74M-US", "AKS74u", "AKS74u-US", "AN94", "AN94-M320-HE", "AN94-M320-LVG", "AN94-M320-SHG", "AN94-M320-SMK", "ASVal", "Crossbow-Scoped-Cobra", "Crossbow-Scoped-RifleScope", "DAO-12", "F2000", "FAMAS", "FGM148", "FIM92", "G36C", "G3A3", "G3A3-M26-Buck", "G3A3-M26-Flechette", "G3A3-M26-Frag", "G3A3-M26-Slug", "Glock17", "Glock17-Silenced", "Glock18", "Glock18-Silenced", "HK417", "HK53", "JNG90", "Jackhammer", "KH2002", "Knife", "Knife-Razor", "L85A2", "L86", "L96", "LSAT", "M1014", "M16-Burst", "M16A4", "M16A4-M26-Buck", "M16A4-M26-Flechette", "M16A4-M26-Frag", "M16A4-M26-Slug", "M16A4-M320-HE", "M16A4-M320-LVG", "M16A4-M320-SHG", "M16A4-M320-SMK", "M16A4-RU", "M1911", "M1911-Lit", "M1911-Silenced", "M1911-Tactical", "M240", "M249", "M27IAR", "M27IAR-RU", "M39EBR", "M4", "M40A5", "M416", "M416-M26-Buck", "M416-M26-Flechette", "M416-M26-Frag", "M416-M26-Slug", "M416-M320-HE", "M416-M320-LVG", "M416-M320-SHG", "M416-M320-SMK", "M4A1", "M4A1-RU", "M60", "M67", "M9", "M9-RU", "M9-Silenced", "M9-TacticalLight", "M93R", "M98B", "MG36", "MK11", "MK11-RU", "MP412Rex", "MP443", "MP443-Silenced", "MP443-TacticalLight", "MP443-US", "MP5K", "MP7", "MTAR", "MagpulPDR", "P90", "PP-19", "PP2000", "Pecheneg", "QBB-95", "QBU-88-Sniper", "QBZ-95B", "RPG7", "RPK-74M", "RPK-74M-US", "SAIGA-20K", "SCAR-H", "SCAR-L", "SCAR-L-M26-Buck", "SCAR-L-M26-Flechette", "SCAR-L-M26-Frag", "SCAR-L-M26-Slug", "SCAR-L-M320-HE", "SCAR-L-M320-LVG", "SCAR-L-M320-SHG", "SCAR-L-M320-SMK", "SG553LB", "SKS", "SMAW", "SPAS12", "SV98", "SVD", "SVD-US", "Sa18IGLA", "SteyrAug", "SteyrAug-M26-Buck", "SteyrAug-M26-Flechette", "SteyrAug-M26-Frag", "SteyrAug-M26-Slug", "SteyrAug-M320-HE", "SteyrAug-M320-LVG", "SteyrAug-M320-SHG", "SteyrAug-M320-SMK", "Taurus44", "Taurus44-Scoped", "Type88", "UMP45", "USAS-12",}	
	self.gadgetKeys = {"Ammobag", "C4", "Claymore", "Defib", "EODBot", "M15", "M26Mass", "M26Mass-Flechette", "M26Mass-Slug", "M320-HE", "M320-LVG", "M320-SHG", "M320-SMK", "MAV", "Medkit", "RadioBeacon", "Repairtool", "SOFLAM", "UGS",}
	self.unlockTables = {}
end


function ConsoleWeaponsClient:RegisterEvents()
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
	Events:Subscribe('Client:LevelLoaded', self, self.OnLevelLoaded)
end

-- Registering console commands is only possible in a client script.
function ConsoleWeaponsClient:RegisterConsoleCommands()
	Console:Register('list', '[weapons | gadgets] List all available weapons/gadgets', self, self.OnListWeapons)
	Console:Register('listAttachments', '(weapon) List available attachments for a weapon', self, self.OnListAttachments)
	Console:Register('equip', '(weapon/gadget) [weaponSlot] [attachment] [attachment]... Equip a weapon/gadget in weaponSlot with attachments', self, self.OnEquipWeapon)
end

-- Store the reference of all the SoldierWeaponUnlockAssets that get loaded. 
function ConsoleWeaponsClient:OnPartitionLoaded(partition)
	local instances = partition.instances

	for _, instance in pairs(instances) do

		if instance:Is('SoldierWeaponUnlockAsset') then
			
			local weaponUnlockAsset = SoldierWeaponUnlockAsset(instance)
			
			local weaponName = weaponUnlockAsset.name:match("/U_.+"):sub(4):gsub("_","-")
		
			self.weaponTable[weaponName] = weaponUnlockAsset
		end
	end
end

-- Store the UnlockAsset names for each weapon 
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

	-- Print usage instructions if we get an invalid number of arguments or the wrong arguments
	if  (#args > 2) or (args[1] ~= nil and (string.lower(args[1]) ~= 'weapons' and string.lower(args[1]) ~= 'gadgets')) then
	
		return 'Usage: _weapons.list_ [weapons | gadgets]'
		
	elseif args[1] == nil then
		
		local response = ""
		
		-- Loop through weaponTable and append every key (and a newline character) to the response string
		for key, value in pairs(self.weaponTable) do
			response = response..string.format("\n")..key
		end
		
		return response 
		
	elseif string.lower(args[1]) == 'weapons' then
		
		local response = ""
		
		-- In this case the key for weaponTable is a value in weaponKeys (or gadgetKeys)
		for _, key in pairs(self.weaponKeys) do
			response = response..string.format("\n")..key
		end
		
		return response
		
	elseif string.lower(args[1]) == 'gadgets' then
		
		local response = ""
		
		for _,key in pairs(self.gadgetKeys) do
			response = response..string.format("\n")..key
		end
		
		return response
	end
end


function ConsoleWeaponsClient:OnListAttachments(args)

	-- Print usage instructions if we get an invalid number of arguments or the wrong arguments
	if  (#args > 1) or args[1] == nil then
	
		return 'Usage: _weapons.listAttachments_ <*weapon*>'
		
	elseif self.weaponTable[args[1]] == nil then
		
		return 'Error: **Invalid weapon/gadget specified.**'	
		
	elseif self.unlockTables[args[1]] == nil then
		
		return '**No attachments for this weapon**'	
		
	else
		
		local response = ""
		
		for key,_ in pairs(self.unlockTables[args[1]]) do
			response = response..("\n")..key
		end
		
		return response
	end
end
	
	
function ConsoleWeaponsClient:OnEquipWeapon(args)

	-- The player is alive when player.soldier ~= nil
	if PlayerManager:GetLocalPlayer().soldier == nil then
		
		return "Error: **Player isn't spawned**"
		
	end
	
	-- args is a table of all arguments passed by the user. 
	
	-- Validate the arguments.
	if  args[1] == nil or (args[2] ~= nil and tonumber(args[2]) == nil) then
	
		return 'Usage: _weapons.equip_ <*weapon*> [*weaponSlot*][*attachment*][*attachment*]...'
		
	elseif self.weaponTable[args[1]] == nil then
		
		return 'Error: **Invalid weapon/gadget specified.**'
		
	elseif args[2] ~= nil and tonumber(args[2]) > 9 then
	
		return 'Error: **Invalid weaponSlot specified.**'

	elseif #args > 2 then
		
		for i = 3, #args do
			-- Remove any "-M320" or "-US" etc. from the specified weapon to look up the attachments from the base soldierWeapon
			if self.unlockTables[args[1]][args[i]] == nil then
	
				return 'Error: **Invalid attachment specified.**'
				
			end
		end
	end
	
	-- Notify the server it needs to change the players weapon
	NetEvents:SendLocal('ConsoleWeapons:EquipWeapon', args)
	return 'Equipped *'..args[1]..'*'

end


g_ConsoleWeaponsClient = ConsoleWeaponsClient()

