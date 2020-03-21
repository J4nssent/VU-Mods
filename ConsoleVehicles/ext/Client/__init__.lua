class 'ConsoleVehiclesClient'

function ConsoleVehiclesClient:__init()
	print("Initializing ConsoleVehiclesClient")
	self:RegisterVars()
	self:RegisterEvents()
	self:RegisterConsoleCommands()
end


function ConsoleVehiclesClient:RegisterVars()
	self.vehicleTable = {}
end


function ConsoleVehiclesClient:RegisterEvents()
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
end


function ConsoleVehiclesClient:RegisterConsoleCommands()
	Console:Register('list', 'List all available vehicles', self, self.OnListVehicles)
	Console:Register('spawn', '(vehicle) [distance] [height] Spawn a vehicle', self, self.OnSpawnVehicle)
end

-- Store the reference to every vehicleBlueprint that gets loaded
function ConsoleVehiclesClient:OnPartitionLoaded(partition)
	local instances = partition.instances

	for _, instance in pairs(instances) do

		if instance.typeInfo.name == 'VehicleBlueprint' then
			
			local vehicleBlueprint = VehicleBlueprint(instance)
			
			-- Vehicles/AH6/AH6_Littlebird --> AH6-Littlebird
			local vehicleName = vehicleBlueprint.name:gsub(".+/.+/",""):gsub("_","-")

			-- The Blueprint is only needed in the server script.
			self.vehicleTable[vehicleName] = vehicleName
		end
	end
end


function ConsoleVehiclesClient:OnListVehicles()

	local response = ""
	
	for vehicleName,_ in pairs(self.vehicleTable) do
		response = response.."\n"..vehicleName
	end
	
	return response

end
	

function ConsoleVehiclesClient:OnSpawnVehicle(args)

	-- The player is alive when player.soldier ~= nil
	if PlayerManager:GetLocalPlayer().soldier == nil then
		
		return "Error: **Player isn't spawned**"
		
	end
	
	-- Print usage instructions if we get an invalid number of arguments or the wrong arguments
	if  #args > 3 or args[1] == nil then
	
		return 'Usage: _consolevehicles.spawn_ <*vehicle*> [*distance*] [*height*]'
		
	elseif self.vehicleTable[args[1]] == nil then
		
		return 'Error: **Invalid vehicle specified.**'
		
	elseif args[2] ~= nil and tonumber(args[2]) == nil then
	
		return 'Error: **Distance must be numeric.**'

	elseif args[3] ~= nil and tonumber(args[3]) == nil then
	
		return 'Error: **Height must be numeric.**'

	else
	
		-- Notify the server it needs to spawn a vehicle and pass on the validated arguments.
		NetEvents:SendLocal('VehicleWeapons:SpawnVehicle', args)
		return 'Spawning *'..args[1]..'*'
		
	end
end


g_ConsoleVehiclesClient = ConsoleVehiclesClient()

