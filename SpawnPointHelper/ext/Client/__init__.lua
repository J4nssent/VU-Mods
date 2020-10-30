
local points = {}

local selectedIndex = nil
local activeIndex = nil
local savedPosition = nil

local up = Vec3(0, 1.5, 0)

local center = ClientUtils:GetWindowSize()/2

Events:Subscribe('UI:DrawHud', function()

	for i, point in pairs(points) do

		-- Draw white SpawnPoint at every point that isn't the active one
		if i ~= activeIndex then

			DrawSpawnPoint(point, Vec4(1, 1, 1, 0.5))
		end
	end

	-- Draw red SpawnPoint on the active point
	if activeIndex then

		DrawSpawnPoint(points[activeIndex], Vec4(1, 0, 0, 0.5))

	-- Draw blue SpawnPoint on the selected point
	elseif selectedIndex then

		DrawSpawnPoint(points[selectedIndex], Vec4(0, 0, 1, 0.5))
	end
end)

function DrawSpawnPoint(linearTransform, color)

	local offset = GetForwardOffsetFromLT(linearTransform)

	DebugRenderer:DrawSphere(linearTransform.trans, 0.3, color, true, false)
	DebugRenderer:DrawSphere(linearTransform.trans+up, 0.15, color, true, false)
	DebugRenderer:DrawSphere(offset+up, 0.1, color, true, false)

	DebugRenderer:DrawLine(linearTransform.trans, linearTransform.trans+up, color, color)
	DebugRenderer:DrawLine(linearTransform.trans+up, offset+up, color, color)
end

-- Returns a Vec3 thats offset in the direction of the linearTransform
function GetForwardOffsetFromLT(linearTransform)

	-- We get the direction from the forward vector
	local direction = linearTransform.forward 

	local forward = Vec3(
		linearTransform.trans.x + (direction.x * 0.4),
		linearTransform.trans.y + (direction.y * 0.4),
		linearTransform.trans.z + (direction.z * 0.4))

	return forward
end


Events:Subscribe('Player:UpdateInput', function()

	local player = PlayerManager:GetLocalPlayer()

	if player == nil then
		return
	end

	if player.soldier == nil then
		return
	end

	-- Press F5 to start or stop moving points
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F5) then
		
		-- print(savedPosition)

		-- If the active point is the last, and unconfirmed, remove it
		if activeIndex == #points and not savedPosition then
	
			points[activeIndex] = nil
			activeIndex = nil

		-- If a previous point was being moved, revert it back to the saved position
		elseif savedPosition then
	
			points[activeIndex] = savedPosition:Clone()
			activeIndex = nil
			savedPosition = nil

		-- If a point is being moved, stop moving it
		elseif activeIndex then

			activeIndex = nil

		-- Start or continue adding points
		else
			activeIndex = #points + 1
			points[activeIndex] = LinearTransform()
		end
	end

	-- Press F4 to clear point(s)
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F4) then

		-- If theres a point being moved, clear only it
		if activeIndex then

			table.remove(points, activeIndex)
			
		-- If theres a point selected, clear only it
		elseif selectedIndex then

			table.remove(points, selectedIndex)
			
		-- Otherwise, clear all points
		else
			points = {}	
		end

		activeIndex = nil
		selectedIndex = nil
		savedPosition = nil
	end

	-- Press E to select point or confirm point placement
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_E) then

		if activeIndex then

			-- If a point was being moved and it has now been confirmed
			if savedPosition then

				activeIndex = nil
				savedPosition = nil

			-- If the point that will be confirmed is the last, start drawing the next one
			elseif activeIndex == #points then

				activeIndex = #points + 1
				points[activeIndex] = LinearTransform()
				savedPosition = nil

			-- If theres no saved position and the point being moved is not the last, an inserted point was being placed and it has now been confirmed
			else
				activeIndex = nil
			end

		-- If E is pressed while a previous point is selected, that point becomes the active point
		elseif selectedIndex then

			savedPosition = points[selectedIndex]:Clone()
			activeIndex = selectedIndex
			selectedIndex = nil
		end
	end

	-- Use the scrollwheel to rotate points
	if activeIndex or selectedIndex then

		-- GetLevel returns an int that can be negative with the amount of wheel steps (-2, -1, 0, 1, etc) 
		local steps = InputManager:GetLevel(InputConceptIdentifiers.ConceptFreeCameraSwitchSpeed)

		if steps ~= 0.0 then
			
			index = activeIndex or selectedIndex

			points[index] = GetRotatedLT(points[index], 0.3 * steps)
		end
	end

	-- Press F1 to print points as LinearTransforms
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F1) then
			
		PrintPointsAsLinearTransforms()
	end
end)

function GetRotatedLT(linearTransform, amount)

	-- Get Yaw Pitch Roll from the transform
	local ypr = MathUtils:GetYPRFromULF(linearTransform.up, linearTransform.left, linearTransform.forward)

	-- Rotate the yaw
	ypr.x = ypr.x + amount

	-- Make sure yaw stays within (0, 2pi)
	ypr.x = (ypr.x > 2*math.pi) and ypr.x - 2*math.pi or ypr.x

	-- Get rotated LinearTransform (without trans)
	local newTransform = MathUtils:GetTransformFromYPR(ypr.x, ypr.y, ypr.z)
	
	-- Set trans
	newTransform.trans = linearTransform.trans

	return newTransform
end

Events:Subscribe('UpdateManager:Update', function(delta, pass)

	-- Only do raycast on presimulation UpdatePass
	if pass ~= UpdatePass.UpdatePass_PreSim then
		return
	end

	raycastHit = Raycast()

	if raycastHit == nil then
		return
	end

	local hitPosition = raycastHit.position

	selectedIndex = nil

	-- Move the active point to the "point of aim"
	if activeIndex and raycastHit then

		points[activeIndex].trans = hitPosition
		
	-- If theres no active point, check to see if the POA is near a point
	else
		for index, point in pairs(points) do

			local pointScreenPos = ClientUtils:WorldToScreen(point.trans)

			-- Skip to the next point if this one isn't in view
			if pointScreenPos == nil then
				goto continue
			end

			-- Select point if its close to the hitPosition
			if center:Distance(pointScreenPos) < 20 then

				selectedIndex = index
			end
			::continue::
		end
	end
end)

-- stolen't https://github.com/EmulatorNexus/VEXT-Samples/blob/80cddf7864a2cdcaccb9efa810e65fae1baeac78/no-headglitch-raycast/ext/Client/__init__.lua
function Raycast()

	local localPlayer = PlayerManager:GetLocalPlayer()

	if localPlayer == nil then
		return
	end

	-- We get the camera transform, from which we will start the raycast. We get the direction from the forward vector. Camera transform
	-- is inverted, so we have to invert this vector.
	local transform = ClientUtils:GetCameraTransform()
	local direction = Vec3(-transform.forward.x, -transform.forward.y, -transform.forward.z)

	if transform.trans == Vec3(0,0,0) then
		return
	end

	local castStart = transform.trans

	-- We get the raycast end transform with the calculated direction and the max distance.
	local castEnd = Vec3(
		transform.trans.x + (direction.x * 100),
		transform.trans.y + (direction.y * 100),
		transform.trans.z + (direction.z * 100))

	-- Perform raycast, returns a RayCastHit object.
	local raycastHit = RaycastManager:Raycast(castStart, castEnd, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)

	return raycastHit	
end

Console:Register('help', 'show usage info', function(args)

	print("\nPress F5 to start/stop placing\n"..
		"Rotate points using the scrollwheel\n"..
		"Press E to confirm position or select a previous point\n"..
		"Press F4 to delete a point/all points if none are selected\n"..
		"Press F1 to print as LinearTransforms\n")
end)

Console:Register('load', 'subworldData (i.e: "Levels/MP_Subway/Conquest_Small") + cpObjectData (guid) + TeamID (int)', function(args)
	local subWorldData = SubWorldData(ResourceManager:SearchForDataContainer(args[1]))

	for _, connection in pairs(subWorldData.linkConnections) do

		if connection.source.instanceGuid == Guid(args[2]) and connection.target:Is('AlternateSpawnEntityData') then
			if tonumber(args[3]) == 1 then
				if connection.sourceFieldId == 1751730141 then
					activeIndex = #points + 1
					points[activeIndex] = AlternateSpawnEntityData(connection.target).transform
					savedPosition = nil
				end
				if connection.sourceFieldId == -2001390482 and AlternateSpawnEntityData(connection.target).team == 1 then
					points[#points + 1] = AlternateSpawnEntityData(connection.target).transform
					savedPosition = nil
				end
			elseif tonumber(args[3]) == 2 then
				if connection.sourceFieldId == 1879290430 then
					points[#points + 1] = AlternateSpawnEntityData(connection.target).transform
					savedPosition = nil
				end
				if connection.sourceFieldId == -2001390482 and AlternateSpawnEntityData(connection.target).team == 2 then
					points[#points + 1] = AlternateSpawnEntityData(connection.target).transform
					savedPosition = nil
				end
			end
		end
	end
end)

function PrintPointsAsLinearTransforms()

	print("printing "..tostring(#points).." points")

	local result = "points = { "

	for index, point in pairs(points) do

		result = result.."LinearTransform("..
			"Vec3"..tostring(point.left)..
			", Vec3"..tostring(point.up)..
			", Vec3"..tostring(point.forward)..
			", Vec3"..tostring(point.trans).."), "
	end

	print(result.."}")
end