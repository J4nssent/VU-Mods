
local STRIKE_AREA_RADIUS = 70
local STRIKE_DURATION = 20
local STRIKE_MISSILE_COUNT = 50

local FiringMode = {
	Disabled = 0,
	Target = 1,
	Area = 2
}

local configs = {
	[FiringMode.Target] = { {radius = 1, segments = 15, width = 0.5}, {radius = 2, segments = 20, width = 0.5}, {radius = 3, segments = 25, width = 0.5}},
	[FiringMode.Area] = { {radius = STRIKE_AREA_RADIUS, segments = 100, width = 2} }
} 

local pointOfAim = { 
	position = Vec3(), 
	points = {},
	mode = FiringMode.Disabled
}

local targets = {}
local pending = {}
local zones = {}

local drawHudEvent = nil
local updateEvent = nil

local RED = Vec4(1, 0, 0, 0.5)
local WHITE = Vec4(1, 1, 1, 0.5)

local MISSILE_AIRTIME = 3.3

Events:Subscribe('Player:UpdateInput', function()

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F1) then

		pointOfAim.mode = FiringMode.Target

		if drawHudEvent == nil then
			drawHudEvent = Events:Subscribe('UI:DrawHud', OnDrawHud)
		end

		if updateEvent == nil then
			updateEvent = Events:Subscribe('UpdateManager:Update', OnUpdate)
		end
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F2) then

		pointOfAim.mode = FiringMode.Area

		if updateEvent == nil then
			updateEvent = Events:Subscribe('UpdateManager:Update', OnUpdate)
		end

		if drawHudEvent == nil then
			drawHudEvent = Events:Subscribe('UI:DrawHud', OnDrawHud)
		end
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F3) then

		pointOfAim.mode = FiringMode.Disabled
	end	

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F4) then
		
		if drawHudEvent ~= nil then
			drawHudEvent:Unsubscribe()
			drawHudEvent = nil
		end

		if updateEvent ~= nil then
			updateEvent:Unsubscribe()
			updateEvent = nil
		end
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_E) and pointOfAim.mode == FiringMode.Target then

		NetEvents:Send('Airstrike:Launch', pointOfAim.position)

		targets[#targets+1] = { position = pointOfAim.position:Clone(), points = {}, timer = MISSILE_AIRTIME }
	end	

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_E) and pointOfAim.mode == FiringMode.Area then
	
		AreaStrike(pointOfAim.position)

		zones[#zones+1] = { position = pointOfAim.position, points = {}, timer = STRIKE_DURATION + MISSILE_AIRTIME}
	end	
end)

function AreaStrike(position)

	for i = 1, STRIKE_MISSILE_COUNT do

		local r = STRIKE_AREA_RADIUS * math.sqrt(MathUtils:GetRandom(0,1))

		local theta = 2 * math.pi * MathUtils:GetRandom(0,1)
		
		local x = r * math.sin(theta)
		local z = r * math.cos(theta)

		local position = Vec3(position.x + x, position.y, position.z + z)

		local fireAfter = MathUtils:GetRandom(0, STRIKE_DURATION)

		pending[#pending+1] = { position = position, points = {}, timer = fireAfter}
	end
end

Events:Subscribe('Engine:Update', function(dt)

    for i = #pending, 1, -1 do

    	pending[i].timer = pending[i].timer - dt

		if pending[i].timer < 0 then
		
			pending[i].timer = MISSILE_AIRTIME

			targets[#targets+1] = pending[i]

			NetEvents:Send('Airstrike:Launch', pending[i].position)

			table.remove(pending, i)
		end
	end

   	for i = #targets, 1, -1 do

    	targets[i].timer = targets[i].timer - dt

		if targets[i].timer < 0 then
		
			table.remove(targets, i)
		end
	end

	for i = #zones, 1, -1 do

    	zones[i].timer = zones[i].timer - dt

		if zones[i].timer < 0 then
		
			table.remove(zones, i)
		end
	end
end)

function OnDrawHud()

	if pointOfAim.mode ~= FiringMode.Disabled then

		DrawTarget(pointOfAim.points, pointOfAim.mode, WHITE)
	end

	for _,target in pairs(targets) do

		if #target.points > 0 then
			DrawTarget(target.points, FiringMode.Target, RED)
		end
	end

	for _,zone in pairs(zones) do

		if #zone.points > 0 then
			DrawTarget(zone.points, FiringMode.Area, RED)
		end
	end		
end

function DrawTarget(points, mode, color)

	local vertices = {}

	for index, config in pairs(configs[mode]) do

		local len = #points[index].inner

		for i = 1, len - 1 do

			DrawTriangle(vertices, points[index].inner[i], points[index].outer[i], points[index].outer[i+1], color)
			DrawTriangle(vertices, points[index].inner[i], points[index].inner[i+1], points[index].outer[i+1], color)
		end

		DrawTriangle(vertices, points[index].inner[len], points[index].outer[len], points[index].outer[1], color)
		DrawTriangle(vertices, points[index].inner[len], points[index].inner[1], points[index].outer[1], color)
	end

	DebugRenderer:DrawVertices(0, vertices)
end

function DrawTriangle(vertices, pt1, pt2, pt3, color)

	local i = #vertices 

	vertices[i+1] = GetVertexForPoint(pt1, color)
	vertices[i+2] = GetVertexForPoint(pt2, color)
	vertices[i+3] = GetVertexForPoint(pt3, color)
end

function GetVertexForPoint(vec3, color)

	local vertex = DebugVertex()
	vertex.pos = vec3
	vertex.color = color

	return vertex
end


function OnUpdate(delta, pass)

	-- Only do raycast on presimulation UpdatePass
	if pass ~= UpdatePass.UpdatePass_PreSim then
		return
	end

	-- Point of aim
	local raycastHit = Raycast()

	if raycastHit == nil then
		return
	end

	pointOfAim.position = raycastHit.position

	if pointOfAim.mode ~= FiringMode.Disabled then
		for index, config in pairs(configs[pointOfAim.mode]) do

			local innerPoints = GetCirclePoints(pointOfAim.position, config.radius - config.width, config.segments)
			local outerPoints = GetCirclePoints(pointOfAim.position, config.radius, config.segments)

			pointOfAim.points[index] = { inner = {}, outer = {}}

			for i = 1, config.segments do

				pointOfAim.points[index].inner[i] = RaycastDown(innerPoints[i])
				pointOfAim.points[index].outer[i] = RaycastDown(outerPoints[i])
			end
		end
	end

	-- Targets
	for _,target in pairs(targets) do

		if #target.points == 0 then
		
			for index, config in pairs(configs[FiringMode.Target]) do

				local innerPoints = GetCirclePoints(target.position, config.radius - config.width, config.segments)
				local outerPoints = GetCirclePoints(target.position, config.radius, config.segments)

				target.points[index] = { inner = {}, outer = {}}

				for i = 1, config.segments do

					target.points[index].inner[i] = RaycastDown(innerPoints[i])
					target.points[index].outer[i] = RaycastDown(outerPoints[i])
				end
			end
		end
	end

	-- Targets
	for _,zone in pairs(zones) do

		if #zone.points == 0 then
		
			for index, config in pairs(configs[FiringMode.Area]) do

				local innerPoints = GetCirclePoints(zone.position, config.radius - config.width, config.segments)
				local outerPoints = GetCirclePoints(zone.position, config.radius, config.segments)

				zone.points[index] = { inner = {}, outer = {}}

				for i = 1, config.segments do

					zone.points[index].inner[i] = RaycastDown(innerPoints[i])
					zone.points[index].outer[i] = RaycastDown(outerPoints[i])
				end
			end
		end
	end
end

function GetCirclePoints(center, radius, segmentCount)

	local points = {}

	local yaw = 0
	
	local yawOffset = 2*math.pi/segmentCount

	for i = 0, segmentCount do

		yaw = yaw + yawOffset

		local direction = MathUtils:GetTransformFromYPR(yaw, 0, 0)

		points[#points+1] = center + direction.forward * radius
	end

	return points
end

function RaycastDown(position)

	local castStart = Vec3(position.x, position.y + 100, position.z)

	local castEnd = Vec3(position.x, position.y - 100, position.z)
	
	-- Perform raycast, returns a RayCastHit object.
	local raycastHit = RaycastManager:Raycast(castStart, castEnd, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)

	if raycastHit == nil then
		return position
	end

	return raycastHit.position	
end

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
		transform.trans.x + (direction.x * 1000),
		transform.trans.y + (direction.y * 1000),
		transform.trans.z + (direction.z * 1000))

	-- Perform raycast, returns a RayCastHit object.
	local raycastHit = RaycastManager:Raycast(castStart, castEnd, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)

	return raycastHit	
end