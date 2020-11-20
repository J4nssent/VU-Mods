
local mortarPartitionGuid = Guid('5350B268-18C9-11E0-B820-CD6C272E4FCC')

local customBlueprintGuid = Guid('D407033B-49AE-DF14-FE19-FC776AE04E2C')
local customProjectileDataGuid = Guid('81E0126A-8452-AEC6-5E4E-94A72DBBB964')
local customExplosionDataGuid = Guid('6B1E1B5F-2487-2511-A0D4-39262CFC74B5')

Events:Subscribe('Partition:Loaded', function(partition)

    if partition.guid ~= mortarPartitionGuid then
        return
    end

    local mortarBlueprint = partition.primaryInstance

    local artyProjectileBlueprint = ProjectileBlueprint(mortarBlueprint:Clone(customBlueprintGuid))
    local artyProjectileData = ProjectileEntityData(artyProjectileBlueprint.object:Clone(customProjectileDataGuid))
    local artyExplosionData = ExplosionEntityData(artyProjectileData.explosion:Clone(customExplosionDataGuid))

    artyProjectileBlueprint.object = artyProjectileData
    artyProjectileData.explosion = artyExplosionData

    -- Make changes...

    partition:AddInstance(artyProjectileBlueprint)
    partition:AddInstance(artyProjectileData)
    partition:AddInstance(artyExplosionData)

    print("instances cloned")
end)

Events:Subscribe('Level:RegisterEntityResources', function(levelData)
 
    local partition = ResourceManager:FindDatabasePartition(mortarPartitionGuid)

    local artyProjectileBlueprint = ProjectileBlueprint(partition:FindInstance(customBlueprintGuid))
    local artyProjectileData = ProjectileEntityData(partition:FindInstance(customProjectileDataGuid))
    local artyExplosionData = ExplosionEntityData(partition:FindInstance(customExplosionDataGuid))

    local registry = RegistryContainer()
    registry.blueprintRegistry:add(artyProjectileBlueprint)
    registry.entityRegistry:add(artyProjectileData)
    registry.entityRegistry:add(artyExplosionData)

    ResourceManager:AddRegistry(registry, ResourceCompartment.ResourceCompartment_Game)

    print("registry added")
end)