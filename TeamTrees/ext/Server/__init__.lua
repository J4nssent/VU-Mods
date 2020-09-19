
local onEntityCreateHook = nil
local activePlayer = nil
local levelLoaded = false

local treeInstanceGuid = Guid("F9366E2C-EBCB-8625-4871-AFD70287736E")
local treePartitionGuid = Guid("7555C348-AEED-11E0-959B-D7802083A6E2")

Events:Subscribe('Player:Chat', function(player, recipientMask, message)
	if message == "!teamtrees" then

		activePlayer = player
		onEntityCreateHook = Hooks:Install('EntityFactory:Create',999, OnEntityCreate)
		
	elseif message == "!globalwarming" then
	
		onEntityCreateHook:Uninstall()
	end
end)

function OnEntityCreate( hook, data, transform )
	if not levelLoaded then
		return
	end
	
	if data.typeInfo.name ~= "BulletEntityData" then
		return
	end
	
	if not activePlayer.soldier then
		return
	end
	
	entity = GameEntity(hook:Call())

	if entity == nil then
		return
	end
	
	entity:RegisterUnspawnCallback(function(ent)
	
		ent = SpatialEntity(ent)
		
		Events:Dispatch('BlueprintManager:SpawnBlueprint', nil, self.treePartitionGuid, self.treeInstanceGuid, tostring(ent.transform), nil)
	end)
end

Events:Subscribe('Level:Loaded', function()
	levelLoaded = true
end)

Events:Subscribe('Level:Destroy', function()
	levelLoaded = false
end)