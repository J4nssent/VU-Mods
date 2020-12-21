
local BULLET_SPEED_MULTIPLIER = 0.3

local IMPACT_SHADER_NAME = 'XP2/Objects/DecalPlane_04/SS_Dirt_01_CoffeStain'

-- XP2/Objects/DecalPlane_04/SS_Dirt_01_CoffeStain  XP2_Office
-- Decals/Static/Paint/Splatter_Yellow_01           XP2_Office  
-- Decals/Static/Paint/Splatter_Red_01              XP2_Office
-- Decals/Blood/Shader_Decal_Blood_01

Events:Subscribe('Partition:Loaded', function(partition)

    if partition.primaryInstance:Is('MaterialGridData') then

        local materialGrid = MaterialGridData(partition.primaryInstance)
        materialGrid:MakeWritable()

        local bulletMaterialIndex = 1

        for rowIndex, row in pairs(materialGrid.interactionGrid) do

            for _, materialProperty in pairs(row.items[bulletMaterialIndex+1].physicsMaterialProperties) do

                if materialProperty:Is('MaterialRelationDecalData') then

                    local property = MaterialRelationDecalData(materialProperty)

                    if property.decal ~= nil then

                        print("registering load handler")

                        property.decal:RegisterLoadHandler(function(instance)

                            print("decal loaded")

                            local template = DecalTemplateData(instance)
                            template:MakeWritable()
                            template.size = 2
                            template.randomSize = 1

                            local shader = ShaderGraph()
                            shader.name = IMPACT_SHADER_NAME

                            template.shader = shader
                        end)
                    end
                end
            end
        end

        for _, item in pairs(materialGrid.interactionGrid[bulletMaterialIndex+1].items) do

            for _, materialProperty in pairs(item.physicsMaterialProperties) do

                if materialProperty:Is('MaterialRelationDecalData') then

                    local property = MaterialRelationDecalData(materialProperty)

                    if property.decal ~= nil then

                        print("registering load handler")

                        property.decal:RegisterLoadHandler(function(instance)

                            print("decal loaded")

                            local template = DecalTemplateData(instance)
                            template:MakeWritable()
                            template.size = 2
                            template.randomSize = 1

                            local shader = ShaderGraph()
                            shader.name = IMPACT_SHADER_NAME

                            template.shader = shader
                        end)
                    end
                end
            end
        end
    end

    if partition.primaryInstance:Is('SoldierWeaponBlueprint') then

        for _, instance in pairs(partition.instances) do
        
            if instance:Is('FiringFunctionData') then

                local firingFunctionData = FiringFunctionData(instance)
                firingFunctionData:MakeWritable()

                print("modifying bullet speed")

                firingFunctionData.shot.initialSpeed.z = firingFunctionData.shot.initialSpeed.z * BULLET_SPEED_MULTIPLIER 
            end
        end
    end
end)