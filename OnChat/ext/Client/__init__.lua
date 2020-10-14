
local asBool = {
	["true"] = true,
	["false"] = false,
	["1"] = true,
	["0"] = false,
}

local createFromBlueprintHook = nil
local entityCreateHook = nil

NetEvents:Subscribe("clientTest", function(arg)

	print("ClientTest")

	-- test shit, heres an iterator btw

	local iterator = EntityManager:GetIterator("")

	local entity = iterator:Next()
	while entity do

		print(entity.name)

		entity:FireEvent("Something")

		entity = iterator:Next()
	end
end)

NetEvents:Subscribe("clientBlueprints", function(enable)

	if asBool[enable] then

		print("clientBlueprints enabled")

		createFromBlueprintHook = Hooks:Install('EntityFactory:CreateFromBlueprint', 1, function(hook, blueprint)
			blueprint = Blueprint(blueprint)
			print(blueprint.name)
		end)

	elseif not asBool[enable] and createFromBlueprintHook then

		createFromBlueprintHook:Uninstall()
	end
end)

NetEvents:Subscribe("clientEntities", function(enable)

	if asBool[enable] then

		print("clientEntities enabled")

		entityCreateHook = Hooks:Install('EntityFactory:Create', 1, function(hook, entityData)
			print(entityData.typeInfo.name)
			print(entityData.instanceGuid)
		end)

	elseif not asBool[enable] and entityCreateHook then

		entityCreateHook:Uninstall()
	end
end)

NetEvents:Subscribe("worldViewMode", function(mode)

	local renderSettings = WorldRenderSettings(ResourceManager:GetSettings("WorldRenderSettings"))
	renderSettings.viewMode = mode
end)