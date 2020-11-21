
require '__shared/MaterialNameIndexes'

-- Entities have a MaterialPair with 2 indexes that correspond with a MaterialName in the games MaterialContainerAsset
--   PhysicsMaterialIndex: How the material behaves when impacted: decals, effects, sounds...
--   PhysicsPropertyIndex: How the material behaves when impacting: damage, penetration, craters...

-- All index vars are 0-indexed, frostbite indexes

local destructivePropertyMaterialNameIndexes = { 
	MaterialNameIndex.Missile_87,		-- SMAW, RPG
	MaterialNameIndex._40mm_116,		-- M320
}

local destructiblePropertyMaterialNameIndexes = {
 	MaterialNameIndex.DamageClass_4_72,	-- Material of the destructable buildings
}

local DAMAGE_MODIFIER = 0.2				-- 4 40mm hits or 2 RPG hits

Events:Subscribe('Partition:Loaded', function(partition)

	if not partition.primaryInstance:Is('MaterialGridData') then -- or instance:Is('MaterialGridData')
		return
	end

	local materialGrid = MaterialGridData(partition.primaryInstance)
	materialGrid:MakeWritable()

	for _, destructiveNameIndex in pairs(destructivePropertyMaterialNameIndexes) do

		for _, destructibleNameIndex in pairs(destructiblePropertyMaterialNameIndexes) do

			-- The "global" materialName indexes are mapped to a level-specific grid index in MaterialGridData.materialIndexMap
			local destructiveLevelPropertyIndex = materialGrid.materialIndexMap[destructiveNameIndex]
			local destructibleLevelPropertyIndex = materialGrid.materialIndexMap[destructibleNameIndex]

			-- If the level-specific index is 0 than the material inst in this levels MaterialGrid
			if destructiveLevelPropertyIndex == MaterialNameIndex.Default_0 or destructibleLevelPropertyIndex == MaterialNameIndex.Default_0 then
				break
			end

			-- The PropertyPair at the intersection of 2 materials contains the data that determines what happens when the 2 materials collide.
			-- The materialGrid is symmetric, meaning that the PropertyPair at row X and column Y contains the same data as the PropertyPair at row Y and column X.
			local xyPropertyPair = materialGrid.interactionGrid[destructiveLevelPropertyIndex+1].items[destructibleLevelPropertyIndex+1]
			local yxPropertyPair = materialGrid.interactionGrid[destructibleLevelPropertyIndex+1].items[destructiveLevelPropertyIndex+1]

			-- These PropertyPairs already contain MaterialRelationDamageData, but since its shared with other materials, it needs to be replaced with a new MaterialRelationDamageData instance.
		    for _,propertyPair in pairs({xyPropertyPair, yxPropertyPair}) do

		    	for i = 1, #propertyPair.physicsPropertyProperties do

		    		-- Replace the existing MaterialRelationDamageData with custom damage data
		    		if propertyPair.physicsPropertyProperties[i]:Is('MaterialRelationDamageData') then

		    			local originalDamageData = propertyPair.physicsPropertyProperties[i]

		    			local customDamageData = MaterialRelationDamageData(originalDamageData:Clone())
		    			customDamageData.damageProtectionMultiplier = customDamageData.damageProtectionMultiplier * DAMAGE_MODIFIER

		    			propertyPair.physicsPropertyProperties[i] = customDamageData
		    		end
		    	end
			end
		end
	end
end)