
-- Scout heli co-pilot entry recreated but with venom pilot antAnimation

local staticCameraData = StaticCameraData()
staticCameraData.upPitchAngle = 45
staticCameraData.downPitchAngle = 40
staticCameraData.leftYawAngle = 75
staticCameraData.rightYawAngle = 75
staticCameraData.yawInputAction = EntryInputActionEnum.EIACameraYaw
staticCameraData.pitchInputAction = EntryInputActionEnum.EIACameraPitch
staticCameraData.pitchSensitivityNonZoomed = 55
staticCameraData.yawSensitivityNonZoomed = 55
staticCameraData.loosePartPhysics:add(CameraLoosePartPhysicsData(ResourceManager:FindInstanceByGuid(Guid("257269BC-C239-4530-8EC3-50684E18DDB5"), Guid("86CD4198-3E7F-45F8-9161-6A9E8ABD645E"))))
staticCameraData.loosePartPhysics:add(CameraLoosePartPhysicsData(ResourceManager:FindInstanceByGuid(Guid("C9F184AE-2BDB-4204-9795-70746B508FD8"), Guid("E6D4A457-2200-4F56-A07E-C463EA9CFE18"))))
staticCameraData.averageFilterFrames = 100

local cameraComponentData = CameraComponentData()
cameraComponentData.camera = staticCameraData
cameraComponentData.forceFieldOfView = 75
cameraComponentData.regularView.flirEnabled = false
cameraComponentData.isFirstPerson = true
cameraComponentData.transform = LinearTransform(
Vec3(1, 0, 0),
Vec3(0, 1, 0),
Vec3(0, 0, 1),
Vec3(-0.335823834, 0.336274624, -0.187998772))

local playerEntryComponentData = PlayerEntryComponentData()
-- playerEntryComponentData.antEntryId = AntEntryIdEnum.AntEntryIdEnum_Humvee_PassengerFrontRight
-- playerEntryComponentData.antEntryID = "Humvee_PassengerFrontRight"
playerEntryComponentData.antEntryEnumeration =  AntEnumeration(ResourceManager:FindInstanceByGuid(Guid("97945D87-011D-11E0-B97C-FC495C335A52"), Guid("4D99111B-29E1-41F9-871B-AC42B25E4CEE")))
playerEntryComponentData.inputConceptDefinition = EntryInputActionMapsData(ResourceManager:FindInstanceByGuid(Guid("0E2EA492-702D-4FE9-AF4B-6C5129C8D341"), Guid("B6748633-1555-4E66-BFC8-2C0A914119A7")))
playerEntryComponentData.inputMapping = InputActionMappingsData(ResourceManager:FindInstanceByGuid(Guid("A31A6367-D498-4415-B71C-93AE0559ABE4"), Guid("5C6A8FCA-2D3F-4CD7-8433-1120C9A89DFE")))
playerEntryComponentData.inputCurves:add(InputCurveData(ResourceManager:FindInstanceByGuid(Guid("06180299-93FF-436A-B382-6227CD672A42"), Guid("52CE08E2-BA19-4C45-9106-59E6E5C64A85"))))
playerEntryComponentData.inputCurves:add(InputCurveData(ResourceManager:FindInstanceByGuid(Guid("2174C603-9B62-438D-89D7-38C432221982"), Guid("B1AE4D88-E1AB-46A2-8F37-210F50EDC142"))))
playerEntryComponentData.inputCurves:add(InputCurveData(ResourceManager:FindInstanceByGuid(Guid("8D855D2B-0A47-4DF2-B29C-DC6085C9BAED"), Guid("9692CB9B-03F3-4C3D-9DA9-929B376C9A80"))))
playerEntryComponentData.inputCurves:add(InputCurveData(ResourceManager:FindInstanceByGuid(Guid("F07B3F6E-C5B6-4991-B0AE-4B776CDCC1FD"), Guid("FBB91868-E1CC-4A44-8488-CC572B764E70"))))
playerEntryComponentData.hudData.seatType = EntrySeatType.EST_Passenger
playerEntryComponentData.entryRadius = 5
playerEntryComponentData.show1pSoldierInEntry = true
playerEntryComponentData.components:add(cameraComponentData)
playerEntryComponentData.soldierOffset = Vec3( -1.453721762, 0 ,0)

local partComponentData = PartComponentData()
partComponentData.components:add(playerEntryComponentData)

return partComponentData



