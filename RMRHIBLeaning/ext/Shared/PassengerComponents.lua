
class "PassengerComponents"

function PassengerComponents:CreateEntry(index, antEnumerationValue, linearTransform, aimingConstraints)

    local antEnumeration
    if antEnumerationValue then
        antEnumeration = AntEnumeration()
        antEnumeration.antAsset.assetId = 357045034
        antEnumeration.value = antEnumerationValue
    end

    local aimingConstraintsData = AimingConstraintsData()
    aimingConstraintsData.minYaw = aimingConstraints[1]
    aimingConstraintsData.maxYaw = aimingConstraints[2]
    aimingConstraintsData.minPitch = aimingConstraints[3]
    aimingConstraintsData.maxPitch = aimingConstraints[4]

    local soldierEntryComponentData = SoldierEntryComponentData()
    soldierEntryComponentData.antEntryEnumeration = antEnumeration
    soldierEntryComponentData.aimingConstraints = aimingConstraintsData
    soldierEntryComponentData.inputConceptDefinition = EntryInputActionMapsData(ResourceManager:FindInstanceByGuid(Guid("41EBA837-6162-48EE-8469-A78669F5DB3B"), Guid("D2B06E08-13A0-4E3B-BEE5-C674F06F9D44")))
    soldierEntryComponentData.inputMapping = InputActionMappingsData(ResourceManager:FindInstanceByGuid(Guid("18A9880D-FFB4-456A-80B2-56B4EDBE02E0"), Guid("115D78B4-D4CE-46E5-84DC-73F5C092B882")))
    soldierEntryComponentData.poseConstraints.standPose = false
    soldierEntryComponentData.poseConstraints.crouchPose = true
    soldierEntryComponentData.poseConstraints.pronePose = false
    soldierEntryComponentData.hudData.seatType = EntrySeatType.EST_Passenger
    soldierEntryComponentData.entryRadius = 5
    soldierEntryComponentData.show1pSoldierInEntry = true
    soldierEntryComponentData.showSoldierWeaponInEntry = true --not sure what this does
    soldierEntryComponentData.show3pSoldierWeaponInEntry = true
    soldierEntryComponentData.showSoldierGearInEntry = true
    soldierEntryComponentData.entryOrderNumber = index
    soldierEntryComponentData.soldierOffset = Vec3( 0, 0 ,0)

    local partComponentData = PartComponentData()
    partComponentData.transform = linearTransform
    partComponentData.components:add(soldierEntryComponentData)

    return partComponentData
end

return PassengerComponents()
