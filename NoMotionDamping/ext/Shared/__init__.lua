
local helicopters = { "Vehicles/Mi28/Mi28", "Vehicles/Z11W/Z-11w", "Vehicles/AH1Z/AH1Z", "Vehicles/AH6/AH6_Littlebird", "Vehicles/Venom/Venom", "Vehicles/KA-60_Kasatka/KA-60_Kasatka",}

function OnPartitionLoaded(partition)

	local instances = partition.instances

	for _, instance in pairs(instances) do

		if instance.typeInfo.name == 'VehicleBlueprint' then
			
			local vehicleBlueprint = VehicleBlueprint(instance)

			for _,name in pairs(helicopters) do

				if vehicleBlueprint.name == name then
					local vehicleConfig = VehicleConfigData(ChassisComponentData(VehicleEntityData(vehicleBlueprint.object).components[1]).vehicleConfig)
					vehicleConfig:MakeWritable()
					vehicleConfig.motionDamping = nil
		
					print("modified "..vehicleBlueprint.name)
				end
			end
		end
	end
end

Events:Subscribe('Partition:Loaded', OnPartitionLoaded)


