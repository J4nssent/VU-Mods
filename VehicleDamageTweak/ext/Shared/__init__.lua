

-- Entities have a MaterialPair with 2 indexes that correspond with a MaterialName in the games MaterialContainerAsset
--   PhysicsMaterialIndex: How the entity looks and sounds when colliding: decals, effects, sounds...
--   PhysicsPropertyIndex: How the entity behaves when colliding: damage, penetration, craters...

-- All index vars are 0-indexed, frostbite indexes
local vehiclePropertyMaterialNameIndex = 42 	-- HUMVEE: The 'Armored' material (36) -> Changed to 'JeepDamage' material (35) in RM, VENOM: The 'HelicopterDamage' material (42), RHIB: The 'Armored' material (36)
local bulletPropertyMaterialNameIndex = 77	-- The 'BulletDamage' material

Events:Subscribe('Partition:Loaded', function(partition)

	if not partition.primaryInstance:Is('MaterialGridData') then -- or instance:Is('MaterialGridData')
		return
	end

	local materialGrid = MaterialGridData(partition.primaryInstance)
	materialGrid:MakeWritable()

	-- The "global" materialName indexes are mapped to a level-specific index in MaterialGridData.materialIndexMap
	local vehicleLevelPropertyIndex = materialGrid.materialIndexMap[vehiclePropertyMaterialNameIndex+1]
	local bulletLevelPropertyIndex = materialGrid.materialIndexMap[bulletPropertyMaterialNameIndex+1]

	-- If the level-specific index is 0 than the material isn't in this levels MaterialGrid
	if vehicleLevelPropertyIndex == 0 then
		return
	end
		
	-- The materialGrid rows are represented in the EBX as the MaterialGrid.interactionGrid array (MaterialInteractionGridRow[]).
	-- Each row has a MaterialInteractionGridRow.items array (MaterialRelationPropertyPair[]), with as many items as there are rows, forming a square grid.
	
	-- The MaterialRelationPropertyPairs at the intersection of 2 materials indexes contain the data that determines what happens when the 2 materials collide.
	-- The 2 property pairs are interactionGrid[x].items[y] and interactionGrid[y].items[x], these contain the same data, since materialGrid is symmetric
		
	-- MaterialRelationPropertyPairs are structs containing 2 arrays:.
		-- MaterialRelationPropertyPair.physicsMaterialProperties (PhysicsMaterialRelationPropertyData[]): contains data for effects, sounds, decals, and/or vehicle tracks.
		-- MaterialRelationPropertyPair.physicsPropertyProperties (PhysicsPropertyRelationPropertyData[]): contains data for damage, penetration, and/or craters.
	
	-- These property pairs contain identical data that determines what happens when a bullet hits the vehicle.
	local bulletVehiclePropertyPair = materialGrid.interactionGrid[vehicleLevelPropertyIndex+1].items[bulletLevelPropertyIndex+1]
	local vehicleBulletPropertyPair = materialGrid.interactionGrid[bulletLevelPropertyIndex+1].items[vehicleLevelPropertyIndex+1]

	-- Those property pairs already contain MaterialRelationDamageData, but since its shared with other materials, it needs to be replaced with a new MaterialRelationDamageData instance.
	local customDamageData = MaterialRelationDamageData()
	customDamageData.collisionDamageMultiplier = 5.0
    	customDamageData.collisionDamageThreshold = 30.0
    	customDamageData.damageProtectionMultiplier = 0.1		-- A bullet will do 10% of its normal damage against the vehicle
    	customDamageData.damagePenetrationMultiplier = 1.0		-- A bullet will keep 100% of its damage after penetrating (if it could, but it can't in this case) 
    	customDamageData.damageProtectionThreshold = 2.0		-- Bullets with less damage than this (after the damageProtectionMultiplier) won't do any damage
    	customDamageData.explosionCoverDamageModifier = 1.0
    	customDamageData.inflictsDemolitionDamage = false

    	for _,propertyPair in pairs({bulletVehiclePropertyPair, vehicleBulletPropertyPair}) do

    		for i = 1, #propertyPair.physicsPropertyProperties do

    			-- Replace the existing MaterialRelationDamageData with the custom damage data
    			if propertyPair.physicsPropertyProperties[i]:Is('MaterialRelationDamageData') then

    				propertyPair.physicsPropertyProperties[i] = customDamageData
    			end
    		end
	end
end)
