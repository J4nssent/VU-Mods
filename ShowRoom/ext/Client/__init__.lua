
local ROTATE_SENS = 0.002
local MOVE_SENS = 0.0002
local ZOOM_SENS = 0.003

local HEIGHT_OFFSET = -1
local MIN_HEIGHT_ZOOMED = -0.5
local MAX_HEIGHT_ZOOMED =  0.5

local ZOOM_OFFSET = -5
local MAX_ZOOM = 3.5

local PITCH_MULTIPLIER = 2
local MAX_PITCH = 0.7
local MIN_PITCH = -0.3

local INERTIA = 0.9

Events:Subscribe('Extension:Loaded', function()
	-- WebUI to update mouse button and mouse wheel levels
	WebUI:Init()
end)

local mouseButtonLevel = 0
local mouseWheelLevel = 0

local uiCompData = nil
local defaultData = nil

local updateInputEvent = nil
local updateSoldierEvent = nil
local updateVehicleEvent = nil
local mouseButtonEvent = nil
local mouseWheelEvent = nil
local unloadEvent = nil

Hooks:Install('UI:PushScreen', 999, function(hook, screen, graphPriority, parentGraph)
	-- Cast the screen to access its properties.
	screen = UIGraphAsset(screen)

	-- Don't unsubscribe when opening or closing chat
	if screen.name == "UI/Flow/Screen/Chat/ChatScreen" or screen.name == "UI/Flow/Screen/EmptyScreen" then
		return
	end

	-- Only subscribe to the update events when in a customization screen
	if screen.name:starts('UI/Flow/Screen/Customize') then

		if uiCompData == nil then
			-- This instance has offset and rotation Vec3 properties for the preview soldier and vehicles
			uiCompData = UICustomizationCompData(ResourceManager:SearchForDataContainer("UI/UIComponents/UICustomizationComp"))
			uiCompData:MakeWritable()
			-- Store a clone for default values
			defaultData = UICustomizationCompData(uiCompData:Clone())
		end

		if updateInputEvent == nil then
			-- The WebUI has 2 div elements over the areas of the preview soldier and vehicle
			WebUI:Show()
			-- Reset data when unloading (the soldier will remain rotated for all servers joined later)
			unloadEvent = Events:Subscribe('Extension:Unloading', ResetData)
			updateInputEvent = Events:Subscribe('Client:UpdateInput', OnUpdateInput)
			-- Update mouse button and wheel levels from WebUI, the InputManager methods don't work in the menus
			mouseButtonEvent = Events:Subscribe('Showroom:MouseButtonLevel', function(value) mouseButtonLevel = value end)
			mouseWheelEvent = Events:Subscribe('Showroom:MouseWheelLevel', function(value) mouseWheelLevel = value end)
		end

		-- Matches all vehicle customization screens
		if screen.name:starts("UI/Flow/Screen/CustomizeLand") or screen.name:starts("UI/Flow/Screen/CustomizeAir") then
			if updateSoldierEvent ~= nil then updateSoldierEvent:Unsubscribe() updateSoldierEvent = nil end
			if updateVehicleEvent == nil then updateVehicleEvent = Events:Subscribe('Client:UpdateInput', UpdateVehicle) end

			-- The mouse levels will only be updated if they happen over one of the overlays.
			WebUI:ExecuteJS('EnableVehicleOverlay(true); EnableSoldierOverlay(false)')

			-- Reset soldier
			uiCompData.soldierOffset = defaultData.soldierOffset
			uiCompData.soldierRotation = defaultData.soldierRotation
		
		-- Soldier customization screens
		else
			if updateVehicleEvent ~= nil then updateVehicleEvent:Unsubscribe() updateVehicleEvent = nil end
			if updateSoldierEvent == nil then updateSoldierEvent = Events:Subscribe('Client:UpdateInput', UpdateSoldier) end

			WebUI:ExecuteJS('EnableSoldierOverlay(true); EnableVehicleOverlay(false)')

			-- Reset vehicle
			uiCompData.vehicleRotation = defaultData.vehicleRotation
		end

	elseif updateInputEvent ~= nil then

		WebUI:Hide()
		UnsubscribeEvents()
		ResetData()	
		uiCompData = nil
	end
end)


local previousPosition = Vec2()
local pendingRotation = 0
local pendingMovement = 0
local pendingZoom = 0

function OnUpdateInput(deltaTime)
	local cursorPosition = InputManager:GetCursorPosition()

	if mouseButtonLevel == 1 then
		pendingMovement = (cursorPosition.y - previousPosition.y) * MOVE_SENS
		pendingRotation = (cursorPosition.x - previousPosition.x) * ROTATE_SENS
	else
		pendingMovement = pendingMovement * INERTIA
		pendingRotation = pendingRotation * INERTIA
	end

	if mouseWheelLevel ~= 0 then
		pendingZoom = -mouseWheelLevel * ZOOM_SENS
	else
		pendingZoom = pendingZoom * INERTIA
	end

	mouseWheelLevel = 0
	previousPosition = cursorPosition
end

function UpdateSoldier()
	-- Rotate soldier
	uiCompData.soldierRotation = GetPitchedRotation(uiCompData.soldierRotation.y, pendingRotation, 0)
	
	-- Move soldier forwards or backwards
	local zoom = MathUtils:Clamp(uiCompData.soldierOffset.z + pendingZoom, ZOOM_OFFSET, ZOOM_OFFSET + MAX_ZOOM)
	uiCompData.soldierOffset.z =  zoom
	uiCompData.soldierOffset.x = -zoom * 0.2
	uiCompData.soldierOffset.y = uiCompData.soldierOffset.y - (zoom == ZOOM_OFFSET + MAX_ZOOM and 0 or pendingZoom * 0.08) -- Move up when zooming in (towards weapon instead of crotch)

	-- Move soldier up and down
	local min_movement = HEIGHT_OFFSET + (zoom - ZOOM_OFFSET) * MIN_HEIGHT_ZOOMED/MAX_ZOOM
	local max_movement = HEIGHT_OFFSET + (zoom - ZOOM_OFFSET) * MAX_HEIGHT_ZOOMED/MAX_ZOOM
	uiCompData.soldierOffset.y = MathUtils:Clamp(uiCompData.soldierOffset.y - pendingMovement, min_movement, max_movement)
end

local vehiclePitch = 0.1

-- Rotate vehicle
function UpdateVehicle()
	vehiclePitch = MathUtils:Clamp(vehiclePitch + pendingMovement * PITCH_MULTIPLIER, MIN_PITCH, MAX_PITCH)
	uiCompData.vehicleRotation = GetPitchedRotation(uiCompData.vehicleRotation.y, pendingRotation, vehiclePitch)
end

function GetPitchedRotation(yaw, yawOffset, pitch)
	local y = yaw + yawOffset

	-- Keep yaw between 0 and 2pi
	while y < 0 do y = y + 2*math.pi end
	while y > 2*math.pi do y = y - 2*math.pi end

	local x = pitch * math.cos(y)
	local z = pitch * math.sin(y) 

	return Vec3(x, y, z)
end

function UnsubscribeEvents()
	if updateInputEvent ~= nil then updateInputEvent:Unsubscribe() updateInputEvent = nil end
	if updateSoldierEvent ~= nil then updateSoldierEvent:Unsubscribe() updateSoldierEvent = nil end
	if updateVehicleEvent ~= nil then updateVehicleEvent:Unsubscribe() updateVehicleEvent = nil end
	if mouseButtonEvent ~= nil then mouseButtonEvent:Unsubscribe() mouseButtonEvent = nil end
	if mouseWheelEvent ~= nil then mouseWheelEvent:Unsubscribe() mouseWheelEvent = nil end
	if unloadEvent ~= nil then unloadEvent:Unsubscribe() unloadEvent = nil end
	if levelDestroyEvent ~= nil then levelDestroyEvent:Unsubscribe() levelDestroyEvent = nil end
end

function ResetData()
	uiCompData.soldierOffset = defaultData.soldierOffset
	uiCompData.soldierRotation = defaultData.soldierRotation
	uiCompData.vehicleRotation = defaultData.vehicleRotation
end
