
class "EntryComponentHelper"

function EntryComponentHelper:CreateSoldierEntry(index, antEnumerationValue, linearTransform)

    local antEnumeration
    if antEnumerationValue then
        antEnumeration = AntEnumeration()
        antEnumeration.antAsset.assetId = 357045034
        antEnumeration.value = antEnumerationValue
    end

    local aimingConstraintsData = AimingConstraintsData()
    aimingConstraintsData.minYaw = -85.0
    aimingConstraintsData.maxYaw = 85.0
    aimingConstraintsData.minPitch = -25.0
    aimingConstraintsData.maxPitch = 60.0

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
    soldierEntryComponentData.showSoldierWeaponInEntry = true
    soldierEntryComponentData.show3pSoldierWeaponInEntry = true
    soldierEntryComponentData.showSoldierGearInEntry = false
    soldierEntryComponentData.entryOrderNumber = index
    soldierEntryComponentData.soldierOffset = Vec3( 0, 0 ,0)

    local partComponentData = PartComponentData()
    partComponentData.transform = linearTransform
    partComponentData.components:add(soldierEntryComponentData)

    return partComponentData
end

function EntryComponentHelper:CreatePlayerEntry(index, antEnumerationValue, linearTransform)

    local staticCameraData = StaticCameraData()
    staticCameraData.upPitchAngle = 45
    staticCameraData.downPitchAngle = 40
    staticCameraData.leftYawAngle = 75
    staticCameraData.rightYawAngle = 75
    staticCameraData.yawInputAction = EntryInputActionEnum.EIACameraYaw
    staticCameraData.pitchInputAction = EntryInputActionEnum.EIACameraPitch
    staticCameraData.pitchSensitivityNonZoomed = 0
    staticCameraData.yawSensitivityNonZoomed = 0
    staticCameraData.pitchSensitivityZoomed = 55
    staticCameraData.yawSensitivityZoomed = 55
    --staticCameraData.loosePartPhysics:add(CameraLoosePartPhysicsData(ResourceManager:FindInstanceByGuid(Guid("C9F184AE-2BDB-4204-9795-70746B508FD8"), Guid("E6D4A457-2200-4F56-A07E-C463EA9CFE18"))))
    --staticCameraData.loosePartPhysics:add(CameraLoosePartPhysicsData(ResourceManager:FindInstanceByGuid(Guid("257269BC-C239-4530-8EC3-50684E18DDB5"), Guid("86CD4198-3E7F-45F8-9161-6A9E8ABD645E"))))
    staticCameraData.averageFilterFrames = 100

    local pitchActionSuppressor = ActionSuppressor()
    pitchActionSuppressor.actionToSuppress = EntryInputActionEnum.EIAPitch
    pitchActionSuppressor.suppressingValue = 0

    local rollActionSuppressor = ActionSuppressor()
    rollActionSuppressor.actionToSuppress = EntryInputActionEnum.EIARoll
    rollActionSuppressor.suppressingValue = 0

    local cameraComponentData = CameraComponentData()
    cameraComponentData.camera = staticCameraData
    cameraComponentData.alternateView = AlternateCameraViewData()
    cameraComponentData.alternateView.inputSuppression.suppressVehicleInput:add(pitchActionSuppressor)
    cameraComponentData.alternateView.inputSuppression.suppressVehicleInput:add(rollActionSuppressor)
    cameraComponentData.forceFieldOfView = 75
    cameraComponentData.regularView.flirEnabled = false
    cameraComponentData.isFirstPerson = true
    cameraComponentData.transform = LinearTransform(
        Vec3(1, 0, 0),
        Vec3(0, 1, 0),
        Vec3(0, 0, 1),
        Vec3(0.03729239, 0.797225058, 0.0803571343)
    )

    local antEnumeration
    if antEnumerationValue then
        antEnumeration = AntEnumeration()
        antEnumeration.antAsset.assetId = 357078069
        antEnumeration.value = antEnumerationValue
    end

    local playerEntryComponentData = PlayerEntryComponentData()
    playerEntryComponentData.antEntryEnumeration = antEnumeration
    playerEntryComponentData.inputConceptDefinition = EntryInputActionMapsData(ResourceManager:FindInstanceByGuid(Guid("37AD62BA-B271-47E2-A497-12FC2FAEAAE0"), Guid("E4325AD2-906F-4F96-875A-D95FBCE2153F")))
    playerEntryComponentData.inputMapping = InputActionMappingsData(ResourceManager:FindInstanceByGuid(Guid("A31A6367-D498-4415-B71C-93AE0559ABE4"), Guid("5C6A8FCA-2D3F-4CD7-8433-1120C9A89DFE")))
    playerEntryComponentData.poseConstraints.standPose = false
    playerEntryComponentData.poseConstraints.crouchPose = true
    playerEntryComponentData.poseConstraints.pronePose = false
    playerEntryComponentData.hudData.seatType = EntrySeatType.EST_Passenger
    playerEntryComponentData.entryRadius = 10
    playerEntryComponentData.show1pSoldierInEntry = true
    playerEntryComponentData.showSoldierWeaponInEntry = true
    playerEntryComponentData.show3pSoldierWeaponInEntry = false
    playerEntryComponentData.showSoldierGearInEntry = false
    playerEntryComponentData.entryOrderNumber = index
    playerEntryComponentData.soldierOffset = linearTransform.trans
    playerEntryComponentData.components:add(cameraComponentData)

    return playerEntryComponentData
end

return EntryComponentHelper()
