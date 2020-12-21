
-- Vec4(R, G, B, idk)

local variationParameters = {
    red = {
        name = "Props/Vehicles/CivilianCar_03/CivilianCar_03_Red",
        nameHash = -2050836413,
        CoatColor = Vec4(0.184, 0.062, 0.082, 1)
    },
    orange = {
        name = "Props/Vehicles/CivilianCar_03/CivilianCar_03_Orange",
        nameHash = 1760211808,
        CoatColor = Vec4(0.184, 0.137, 0.062, 1)
    },
    yellow = {
        name = "Props/Vehicles/CivilianCar_03/CivilianCar_03_Yellow",
        nameHash = 1073326868,
        CoatColor = Vec4(0.184, 0.180, 0.062, 1)
    },
    green = {
        name = "Props/Vehicles/CivilianCar_03/CivilianCar_03_Green",
        nameHash = 43848331,
        CoatColor = Vec4(0.058, 0.2, 0.078, 1)
    },
    blue = {
        name = "Props/Vehicles/CivilianCar_03/CivilianCar_03_Bleu",
        nameHash = 1042459822,
        CoatColor = Vec4(0.062, 0.074, 0.184, 1)
    },
    purple = {
        name = "Props/Vehicles/CivilianCar_03/CivilianCar_03_Purple",
        nameHash = 519225566,
        CoatColor = Vec4(0.1, 0.058, 0.2, 1)
    },
    pink = {
        name = "Props/Vehicles/CivilianCar_03/CivilianCar_03_Pink",
        nameHash = 1041668300,
        CoatColor = Vec4(0.3, 0.058, 0.172, 1)
    },
}

Events:Subscribe('Partition:Loaded', function(partition)
    
    if not partition.primaryInstance:Is('MeshVariationDatabase') then
        return
    end

    local meshVariationDatabase = MeshVariationDatabase(partition.primaryInstance)

    if meshVariationDatabase.name ~= SharedUtils:GetLevelName().."/MeshVariationDb_Win32" then
        return
    end

    meshVariationDatabase:MakeWritable()
    
    local originalVariationEntry = nil

    for _, entry in pairs(meshVariationDatabase.entries) do

        local meshVariationDatabaseEntry = MeshVariationDatabaseEntry(entry)

        -- The nameHash of the entry (with a variation) that will be cloned
        if meshVariationDatabaseEntry.variationAssetNameHash == 4245080718 then -- blue 4245080718, gray 4245162941
           
            originalVariationEntry = meshVariationDatabaseEntry
            break
        end
    end

    for _, params in pairs(variationParameters) do

        local customVariationEntry = MeshVariationDatabaseEntry(originalVariationEntry:Clone(MathUtils:RandomGuid()))

        customVariationEntry.variationAssetNameHash = params.nameHash

        for _, material in pairs(customVariationEntry.materials) do

            if material.materialVariation ~= nil then

                local args = { material = material, values = params }

                if material.materialVariation.isLazyLoaded then

                    material.materialVariation:RegisterLoadHandler(args, CloneMaterialVariation)
                else
                    CloneMaterialVariation(args)
                end
            end
        end

        meshVariationDatabase.entries:add(customVariationEntry)

        print("Added "..params.name.." variation")
    end
end)

function CloneMaterialVariation(args)

    local customMaterialVariation = MeshMaterialVariation(args.material.materialVariation:Clone())

    for _, parameter in pairs(customMaterialVariation.shader.vectorParameters) do

        -- Only change the vectorParameters if we defined a new value for it
        if args.values[parameter.parameterName] ~= nil then

            parameter.value = args.values[parameter.parameterName]
        end
    end

    args.material.materialVariation = customMaterialVariation
end

-- Spawning stuff
Events:Subscribe('Player:Chat', function(player, recipientMask, message)

    if variationParameters[string.lower(message)] then

        local variation = variationParameters[string.lower(message)].nameHash

        local transform = player.soldier.transform
        transform.trans = transform.trans + (player.soldier.transform.forward * 3)

        NetEvents:Broadcast("spawn", transform, variation)
        Spawn(transform, variation)
    end
end)

function Spawn(transform, variation)

    print("spawning "..variation)

    local params = EntityCreationParams()
    params.transform = transform
    params.variationNameHash = variation or 0
    params.networked = false

    local blueprint = ObjectBlueprint(ResourceManager:SearchForDataContainer('Props/Vehicles/CivilianCar_03/CivilianCar_03'))   
    
    local entityBus = EntityBus(EntityManager:CreateEntitiesFromBlueprint(blueprint, params))

    for i, entity in pairs(entityBus.entities) do

        entity = Entity(entity)
        entity:Init(Realm.Realm_ClientAndServer, true)
    end
end

NetEvents:Subscribe('spawn', Spawn)