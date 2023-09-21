XCORE_VERSION = "1.1.8"
XCORE_LUA_NAME = "xCore.lua"
XCORE_REPO_BASE_URL = "https://raw.githubusercontent.com/xAIO-Slotted/xCore/main/"
XCORE_REPO_SCRIPT_PATH = XCORE_REPO_BASE_URL .. XCORE_LUA_NAME
local std_math = math

--------------------------------------------------------------------------------

local font = 'Corbel'

local e_key = {
	lbutton = 1,
	rbutton = 2,
	cancel = 3,
	mbutton = 4,
	xbutton1 = 5,
	xbutton2 = 6,
	back = 8,
	tab = 9,
	clear = 12,
	return_key = 13,
	shift = 16,
	control = 17,
	menu = 18,
	pause = 19,
	capital = 20,
	kana = 21,
	hanguel = 22,
	hangul = 23,
	escape = 27,
	convert = 28,
	nonconvert = 29,
	accept = 30,
	modechange = 31,
	space = 32,
	prior = 33,
	next = 34,
	end_key = 35,
	home = 36,
	left = 37,
	up = 38,
	right = 39,
	down = 40,
	select = 41,
	print = 42,
	execute = 43,
	snapshot = 44,
	insert = 45,
	delete_key = 46,
	help = 47,
	_0 = 48,
	_1 = 49,
	_2 = 50,
	_3 = 51,
	_4 = 52,
	_5 = 53,
	_6 = 54,
	_7 = 55,
	_8 = 56,
	_9 = 57,
	A = 65,
	B = 66,
	C = 67,
	D = 68,
	E = 69,
	F = 70,
	G = 71,
	H = 72,
	I = 73,
	J = 74,
	K = 75,
	L = 76,
	M = 77,
	N = 78,
	O = 79,
	P = 80,
	Q = 81,
	R = 82,
	S = 83,
	T = 84,
	U = 85,
	V = 86,
	W = 87,
	X = 88,
	Y = 89,
	Z = 90,
	n0 = 96,
	n1 = 97,
	n2 = 98,
	n3 = 99,
	n4 = 100,
	n5 = 101,
	n6 = 102,
	n7 = 103,
	n8 = 104,
	n9 = 105,
	f1 = 112,
 }


local mode = {
	Combo_key = 1,
	Harass_key = 4,
	Clear_key = 3,
	Lasthit = 2,
	Freeze = 7,
	Flee = 5,
	Idle_key = 0,
	Recalling = 6
}

local chance_strings = {
	[0] = "low",
	[1] = "medium",
	[2] = "high",
	[3] = "very_high",
	[4] = "immobile"
}

 local buff_type = {
	Internal = 0,
	Aura = 1,
	CombatEnchancer = 2,
	CombatDehancer = 3,
	SpellShield = 4,
	Stun = 5,
	Invisibility = 6,
	Silence = 7,
	Taunt = 8,
	Berserk = 9,
	Polymorph = 10,
	Slow = 11,
	Snare = 12,
	Damage = 13,
	Heal = 14,
	Haste = 15,
	SpellImmunity = 16,
	PhysicalImmunity = 17,
	Invulnerability = 18,
	AttackSpeedSlow = 19,
	NearSight = 20,
	Currency = 21,
	Fear = 22,
	Charm = 23,
	Poison = 24,
	Suppression = 25,
	Blind = 26,
	Counter = 27,
	Shred = 28,
	Flee = 29,
	Knockup = 30,
	Knockback = 31,
	Disarm = 32,
	Grounded = 33,
	Drowsy = 34,
	Asleep = 35,
	Obscured = 36,
	ClickProofToEnemies = 37,
	Unkillable = 38
 }
 local rates = { "slow", "instant", "very slow" }
 
 function get_menu_val(cfg)
	return cfg:get_value()
end

dancing = false
state = "atMiddle" -- can be "atTop", "atMiddle", or "atBottom"
top, mid, bot = nil, nil, nil


--------------------------------------------------------------------------------

--- @alias Color table<string, table<string, table<number, number, number, number>>>
--- @alias Vec3 table<string, table<number, number, number>>
--- @alias Vec2 table<string, table<number, number>>
--- @alias Screen table<string, table<number, number>>

--------------------------------------------------------------------------------

local function fetch_remote_version_number()
	local command = "curl -s -H 'Cache-Control: no-cache, no-store, must-revalidate' " .. XCORE_REPO_SCRIPT_PATH

	local handle = io.popen(command)
	if not handle then
		print("Failed to fetch the remote version number.")
		return nil
	end
	local content = handle:read("*a")
	handle:close()

	if content == "" then
		print("Failed to fetch the remote version number.")
		return nil
	end

	local remote_version = content:match("VERSION%s*=%s*\"(%d+%.%d+%.%d+)\"")

	return remote_version
end

local function replace_current_file_with_latest_version(latest_version_script)
	local resources_path = cheat:get_resource_path()
	local current_file_path = resources_path:gsub("resources$", "lua\\lib\\" .. XCORE_LUA_NAME)
	print("got file path:" .. tostring(current_file_path))
	local file, errorMessage = io.open(current_file_path, "w")

	if not file then
		print("Failed to open the current file for writing. Error: " .. errorMessage)
		return false
	end

	file:write(latest_version_script)
	file:close()

	return true
end

local function check_for_update(x)
	local remote_version = fetch_remote_version_number()
	x.debug:Print("xCore: local version: " .. XCORE_VERSION .. " remote version: " .. remote_version, 1)

	if remote_version and remote_version > XCORE_VERSION then
		local command = "curl -s " .. XCORE_REPO_SCRIPT_PATH
		local handle = io.popen(command)
		if not handle then
			print("Failed to fetch the remote version number.")
			return nil
		end
		local latest_version_script = handle:read("*a")
		handle:close()

		if latest_version_script then
			if replace_current_file_with_latest_version(latest_version_script) then
				x.debug:Print("Please click reload lua ", 0)
				x.debug:Print("Successfully updated " .. XCORE_LUA_NAME .. " to version " .. remote_version .. ".", 0)
				x.debug:Print("Please click reload lua  ", 0)
				-- You may need to restart the program to use the updated script
			else
				x.debug:Print("Failed to update " .. XCORE_LUA_NAME .. ".", 0)
			end
		end
	else
		x.debug:Print("You are running the latest version of " .. XCORE_LUA_NAME .. ".", 0)
	end
end


local function class(properties, ...)
	local cls = {}
	cls.__index = cls

	for k, v in pairs(properties) do
		cls[k] = v
	end

	for _, property in ipairs({ ... }) do
		for k, v in pairs(property) do
			cls[k] = v
		end
	end

	function cls:new(...)
		local instance = setmetatable({}, cls)
		if self.init then
			self:init(...)
		end
		return instance
	end

	return cls
end

--------------------------------------------------------------------------------

-- Vec3 Utility

--------------------------------------------------------------------------------

--- @class vec3Util
--- @field print fun(self:vec3Util, point:Vec3):nil
--- @field rotate fun(self:vec3Util, position:Vec3, point:Vec3, angle:number):Vec3
--- @field translate fun(self:vec3Util, position:Vec3, offsetX:number, offsetZ:number):Vec3
--- @field translateX fun(self:vec3Util, position:Vec3, offsetX:number):Vec3
--- @field translateZ fun(self:vec3Util, position:Vec3, offsetZ:number):Vec3
--- @field drawCircle fun(self:vec3Util, position:Vec3, color:Color, radius:number):nil
--- @field drawCircleFull fun(self:vec3Util, position:Vec3, color:Color, radius:number):nil
--- @field drawLine fun(self:vec3Util, position:Vec3, destination:Vec3, color:Color):nil
--- @field drawBox fun(self:vec3Util, start_pos:Vec3, end_pos:Vec3, width:number, color:Color, thickness:number):nil
local vec3Util = class({
	print = function(self, point)
		print("x: " .. point.x .. " y: " .. point.y .. " z: " .. point.z)
	end,

	rotate = function(self, position, point, angle)
		local angle = angle * (math.pi / 180)
		local rotatedX = math.cos(angle) * (point.x - position.x) - math.sin(angle) * (point.z - position.z) + position.x
		local rotatedZ = math.sin(angle) * (point.x - position.x) + math.cos(angle) * (point.z - position.z) + position.z
		return vec3:new(rotatedX, point.y, rotatedZ)
	end,
	distance = function(self, start_point, end_point)
		--print all types
		-- console:log("start_point: " .. type(start_point))
		-- console:log("end_point: " .. type(end_point) .. "x: " .. end_point.x .. " y: " .. end_point.y)

		local dx = start_point.x - end_point.x
		local dy = start_point.y - end_point.y
		local dz = start_point.z - end_point.z
		
		local distance_squared = dx*dx + dy*dy + dz*dz
		return std_math.sqrt(distance_squared)
	end,
	extend = function (self, v1, v2, dist)
		local dx = v2.x - v1.x
		local dy = v2.y - v1.y
		local dz = v2.z - v1.z
		local length = std_math.sqrt(dx * dx + dy * dy + dz * dz)
		

		-- Check if length is zero to avoid division by zero
		if length == 0 then
			return vec3:new(v1.x,v1.y,v1.z)
		end
		local scale = dist / length
		local _x = v1.x + dx * scale
		local _y = v1.y + dy * scale
		local _z = v1.z + dz * scale
		local ret = vec3:new(_x, _y, _z)

		return ret
		
	end,
	subtract = function(self, v1, v2)
		local x = v1.x - v2.x
		local y = v1.y - v2.y
		local z = v1.z - v2.z
		return vec3:new(x, y, z)
	end,
    midpoint = function(self, v1, v2)
        local x = (v1.x + v2.x) / 2
        local y = (v1.y + v2.y) / 2
        local z = (v1.z + v2.z) / 2
        return vec3:new(x, y, z)
    end,
    normalize = function(self, v)
        local dx = v.x
        local dy = v.y
        local dz = v.z
        local length = math.sqrt(dx * dx + dy * dy + dz * dz)
        
        -- Check if length is zero to avoid division by zero
        if length == 0 then
            return {
                x = 0,
                y = 0,
                z = 0
            }
        end
        local x = dx / length
        local y = dy / length
        local z =  dz / length
        return vec3:new(x, y, z)
    end,
    translate = function(self, position, offsetX, offsetZ)
        local translatedX = position.x + offsetX
        local translatedZ = position.z + offsetZ
        return vec3:new(translatedX, position.y, translatedZ)
    end,
    avoid_circle_by_closest_tangent = function(self, start, circle_center, circle_radius, mouse, offset)
        -- 1. Get both tangent points to the circle from start position
        local tangent_point_1, tangent_point_2 = self:get_tangent_points(circle_center, circle_radius, start)
        
        tangent_point_1 = self:extend(circle_center, tangent_point_1, circle_radius+g_local:get_bounding_radius()+25)
        tangent_point_2 = self:extend(circle_center, tangent_point_2, circle_radius+g_local:get_bounding_radius()+25)
        
        if circle_center then
            mid = circle_center
        end
        
        if not tangent_point_1 then
            top = nil
            return nil
        end
        
        if not tangent_point_2 then
            bot = nil
            return nil
        end
    
        -- 2. Check which tangent point is closer to the mouse
        local dist_to_mouse_from_tangent_1 = self:distance(tangent_point_1, mouse)
        local dist_to_mouse_from_tangent_2 = self:distance(tangent_point_2, mouse)
    
        local closest_tangent_point = tangent_point_1
        bot = tangent_point_2
        
        if dist_to_mouse_from_tangent_2 < dist_to_mouse_from_tangent_1 then
            closest_tangent_point = tangent_point_2
            bot = tangent_point_1
        end
        top = closest_tangent_point
        
        return closest_tangent_point
    end,
    get_tangent_points = function(self, center, radius, outside_point)
        -- Default values
        center = center or vec3:new(0, 0, 0)
        radius = radius or 10
        outside_point = outside_point or vec3:new(15, 0, 15)

        -- Extract coordinates for easier calculations
        local a, b = outside_point.x, outside_point.z
        local h, k = center.x, center.z
        local r = radius

        -- Calculate common terms
        local d = (a - h)^2 + (b - k)^2
        local sqrt_term = math.sqrt(d - r^2)

        -- Calculate the coordinates of the tangent points
        local x1 = ((r^2 * (a - h)) + r * (b - k) * sqrt_term) / d + h
        local z1 = ((r^2 * (b - k)) - r * (a - h) * sqrt_term) / d + k

        local x2 = ((r^2 * (a - h)) - r * (b - k) * sqrt_term) / d + h
        local z2 = ((r^2 * (b - k)) + r * (a - h) * sqrt_term) / d + k

        local tangent_point_1 = vec3:new(x1, 0, z1)
        local tangent_point_2 = vec3:new(x2, 0, z2)

        return tangent_point_1, tangent_point_2
    end,
	doesLineIntersectCircle = function (self, line_start, line_end, circle_center, circle_radius)
        local dx = line_end.x - line_start.x
        local dz = line_end.z - line_start.z
    
        local a = dx * dx + dz * dz
        local b = 2 * (dx * (line_start.x - circle_center.x) + dz * (line_start.z - circle_center.z))
        local c = (line_start.x - circle_center.x) * (line_start.x - circle_center.x) + 
                  (line_start.z - circle_center.z) * (line_start.z - circle_center.z) - 
                  circle_radius * circle_radius
    
                  
        local discriminant = b * b - 4 * a * c
    
        local isInsideCircle = function(point)
            local distSquared = (point.x - circle_center.x) * (point.x - circle_center.x) +
                                (point.z - circle_center.z) * (point.z - circle_center.z)
            return distSquared < circle_radius * circle_radius
        end
        
        -- Check if both endpoints are inside the circle
        if isInsideCircle(line_start) and isInsideCircle(line_end) then
            -- if they are we need to shove(extend) them towards the outer circle
            local extendedLineStart = self:extend(circle_center, line_start, circle_radius)
            local extendedLineEnd = self:extend(circle_center, line_end, circle_radius)
            
            return true, extendedLineStart, extendedLineEnd
        end
        
        -- If the discriminant is negative, the line doesn't intersect the circle
        if discriminant < 0 then
            return false, nil, nil
        end
    
        local t1 = (-b - math.sqrt(discriminant)) / (2 * a)
        local t2 = (-b + math.sqrt(discriminant)) / (2 * a)
        
        local intersectionVec3_1, intersectionVec3_2 = nil, nil
    
        if 0 <= t1 and t1 <= 1 then
            intersectionVec3_1 = vec3:new(line_start.x + t1 * dx, line_start.y, line_start.z + t1 * dz)
        end
    
        if t1 ~= t2 and 0 <= t2 and t2 <= 1 then
            intersectionVec3_2 = vec3:new(line_start.x + t2 * dx, line_start.y, line_start.z + t2 * dz)
        end
    
        if intersectionVec3_1 or intersectionVec3_2 then
            return true, intersectionVec3_1, intersectionVec3_2
        else
            return false, nil, nil
        end
    end,
	isPointInsideCircle = function(self, point, circle_center, circle_radius)
		local dx = point.x - circle_center.x
		local dy = point.z - circle_center.z
		
		return (dx * dx + dy * dy) <= circle_radius * circle_radius
	end,
	translateX = function(self, position, offsetX)
		local translatedX = position.x + offsetX
		return vec3:new(translatedX, position.y, position.z)
	end,
	translateZ = function(self, position, offsetZ)
		local translatedZ = position.z + offsetZ
		return vec3:new(position.x, position.y, translatedZ)
	end,
	project_vector_on_segment = function(self, v1, v2, v)
		local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
		local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
		local pointLine = vec3:new(ax + rL * (bx - ax), 0, ay + rL * (by - ay))
		local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
		local isOnSegment = rS == rL
		local pointSegment = isOnSegment and pointLine or vec3:new(ax + rS * (bx - ax), 0, ay + rS * (by - ay))

		return {PointSegment = pointSegment, PointLine = pointLine, IsOnSegment = isOnSegment}
	end,
	is_colliding = function(self, start_pos, end_pos, target, width)
		for i, enemy in pairs(features.entity_list:get_enemies()) do
			if  enemy and enemy:is_alive() and target.champion_name.text ~= enemy.champion_name.text then       
				local ProjectionInfo = self:project_vector_on_segment(start_pos, end_pos, enemy.position)
				local DistSegToEnemy = ProjectionInfo.PointSegment:dist_to(enemy.position)
				local DistToBase = start_pos:dist_to(end_pos)
				local EnemyDistToBase = start_pos:dist_to(start_pos, enemy.position)
				if ProjectionInfo.IsOnSegment and DistSegToEnemy < width + 65 and DistToBase > EnemyDistToBase then             
					return true
				end
			end
		end
		return false
	end,
	drawCircle = function(self, position, color, radius)
		g_render:circle_3d(position, color, radius, 2, 100, 2)
	end,
	drawCircleFull = function(self, position, color, radius)
		g_render:circle_3d(position, color, radius, 3, 100, 2)
	end,
	drawLine = function(self, position, destination, color)
		g_render:line_3d(position, destination, color, 2)
	end,
	drawBox = function(self, start_pos, end_pos, width, color, thickness)
		-- Calculate the direction vector
		local dir = vec3:new(end_pos.x - start_pos.x, 0, end_pos.z - start_pos.z)
		dir = dir:normalized()

		-- Calculate the half width vector
		local half_width_vec = vec3:new(-dir.z * (width), 0, dir.x * (width))

		-- Calculate the corner points of the box
		local p1 = vec3:new(start_pos.x + half_width_vec.x, start_pos.y, start_pos.z + half_width_vec.z)
		local p2 = vec3:new(start_pos.x - half_width_vec.x, start_pos.y, start_pos.z - half_width_vec.z)
		local p3 = vec3:new(end_pos.x + half_width_vec.x, end_pos.y, end_pos.z + half_width_vec.z)
		local p4 = vec3:new(end_pos.x - half_width_vec.x, end_pos.y, end_pos.z - half_width_vec.z)

		-- Draw lines connecting the corner points
		g_render:line_3d(p1, p2, color, thickness)
		g_render:line_3d(p1, p3, color, thickness)
		g_render:line_3d(p2, p4, color, thickness)
		g_render:line_3d(p3, p4, color, thickness)

		-- Draw lines connecting start and end points (vertical edges)
		g_render:line_3d(p1, p3, color, thickness)
		g_render:line_3d(p2, p4, color, thickness)
	end,
	drawText = function(self, text, position, color, size)
		if position:to_screen() then
			g_render:text(position:to_screen(), color, tostring(text), font, size)
		end
	end,
})

--------------------------------------------------------------------------------

-- Vec2 Utility

--------------------------------------------------------------------------------

--- @class vec2Util
--- @field print fun(self:vec2Util, point:Vec2):nil
--- @field rotate fun(self:vec2Util, position:Vec2, point:Vec2, angle:number):Vec2
--- @field translate fun(self:vec2Util, position:Vec2, offsetX:number, offsetY:number):Vec2
--- @field translateX fun(self:vec2Util, position:Vec2, offsetX:number):Vec2
--- @field translateY fun(self:vec2Util, position:Vec2, offsetY:number):Vec2
--- @field drawCircle fun(self:vec2Util, position:Vec2, color:Color, radius:number):nil
--- @field drawLine fun(self:vec2Util, position:Vec2, destination:Vec2, color:Color):nil
--- @field drawBox fun(self:vec2Util, start_pos:Vec2, end_pos:Vec2, width:number, color:Color, thickness:number):nil
local vec2Util = class({
	print = function(self, point)
		print("x: " .. point.x .. " y: " .. point.y)
	end,

	rotate = function(self, position, point, angle)
		local angle = angle * (math.pi / 180)
		local rotatedX = math.cos(angle) * (point.x - position.x) - math.sin(angle) * (point.y - position.y) + position.x
		local rotatedY = math.sin(angle) * (point.x - position.x) + math.cos(angle) * (point.y - position.y) + position.y
		return vec3:new(rotatedX, rotatedY)
	end,

	translate = function(self, position, offsetX, offsetY)
		local translatedX = position.x + offsetX
		local translatedY = position.y + offsetY
		return vec2:new(translatedX, translatedY)
	end,

	translateX = function(self, position, offsetX)
		local translatedX = position.x + offsetX
		return vec2:new(translatedX, position.y)
	end,

	translateY = function(self, position, offsetY)
		local translatedY = position.y + offsetY
		return vec2:new(position.x, translatedY)
	end,

	drawCircle = function(self, position, color, radius)
		g_render:circle(position, color, radius, 100)
	end,

	drawFullCircle = function(self, position, color, radius)
		g_render:filled_circle(position, color, radius, 100)
	end,

	drawLine = function(self, position, destination, color)
		g_render:line(position, destination, color, 2)
	end,

	drawBox = function(self, start, size, color)
		g_render:box(start, size, color, 0, 2)
	end,
})

--------------------------------------------------------------------------------
-- Utility
--------------------------------------------------------------------------------
--- @class util
--- @field screen Screen
--- @field screenX number
--- @field screenY number
--- @field font string
--- @field fontSize number
--- @field Colors table<string, table<string,Color>>
--- @field textAt fun(self:util, pos:Vec2, color:Color, text:string):nil
--- @field new fun(self:util):util
local util = class({
	screen = nil,
	screenX = nil,
	screenY = nil,
	font = font,
	fontSize = 30,

	Colors = {
		solid = {
			white = color:new(255, 255, 255),
			black = color:new(0, 0, 0),
			gray = color:new(128, 128, 128),
			lightGray = color:new(192, 192, 192),
			darkGray = color:new(64, 64, 64),
			red = color:new(255, 0, 0),
			lightRed = color:new(255, 128, 128),
			darkRed = color:new(128, 0, 0),
			orange = color:new(255, 127, 0),
			lightOrange = color:new(255, 180, 128),
			darkOrange = color:new(191, 95, 0),
			yellow = color:new(255, 255, 0),
			lightYellow = color:new(255, 255, 128),
			darkYellow = color:new(191, 191, 0),
			green = color:new(0, 255, 0),
			lightGreen = color:new(128, 255, 128),
			darkGreen = color:new(0, 128, 0),
			cyan = color:new(0, 255, 255),
			lightCyan = color:new(128, 255, 255),
			darkCyan = color:new(0, 128, 128),
			blue = color:new(0, 0, 255),
			lightBlue = color:new(128, 128, 255),
			darkBlue = color:new(0, 0, 128),
			purple = color:new(143, 0, 255),
			lightPurple = color:new(191, 128, 255),
			darkPurple = color:new(95, 0, 191),
			magenta = color:new(255, 0, 255),
			lightMagenta = color:new(255, 128, 255),
			darkMagenta = color:new(128, 0, 128),
		},
		transparent = {
			white = color:new(255, 255, 255, 130),
			black = color:new(0, 0, 0, 130),
			gray = color:new(128, 128, 128, 130),
			lightGray = color:new(192, 192, 192, 130),
			darkGray = color:new(64, 64, 64, 130),
			red = color:new(255, 0, 0, 200),
			lightRed = color:new(255, 128, 128, 130),
			darkRed = color:new(128, 0, 0, 130),
			orange = color:new(255, 127, 0, 130),
			lightOrange = color:new(255, 180, 128, 130),
			darkOrange = color:new(191, 95, 0, 130),
			yellow = color:new(255, 255, 0, 130),
			lightYellow = color:new(255, 255, 128, 130),
			darkYellow = color:new(191, 191, 0, 130),
			green = color:new(0, 255, 0, 150),
			lightGreen = color:new(128, 255, 128, 130),
			darkGreen = color:new(0, 128, 0, 130),
			cyan = color:new(0, 255, 255, 130),
			lightCyan = color:new(128, 255, 255, 130),
			darkCyan = color:new(0, 128, 128, 130),
			blue = color:new(63, 72, 204, 200),
			lightBlue = color:new(128, 128, 255, 130),
			darkBlue = color:new(0, 0, 128, 130),
			purple = color:new(143, 0, 255, 100),
			lightPurple = color:new(191, 128, 255, 130),
			darkPurple = color:new(95, 0, 191, 130),
			magenta = color:new(255, 0, 255, 130),
			lightMagenta = color:new(255, 128, 255, 130),
			darkMagenta = color:new(128, 0, 128, 130),
		}
	},
	rift_locations = {
		["Blue_Base"] = {x = 1184, y = 95, z = 1176},
		["Red_Base"] = {x = 13500, y = 91, z = 13592},
		["Red_Recall"] = {x = 14312, y = 171, z = 14348},
		["Blue_Recall"] = {x = 420, y = 183, z = 410},
		["Blue_Bot_Tier_1"] = {x = 10452, y = 50, z = 1328},
		["Blue_Bot_Tier_2"] = {x = 7024, y = 49, z = 1282},
		["Blue_Bot_Tier_3"] = {x = 3868, y = 95, z = 880},
		["Red_Bot_Tier_1"] = {x = 13732, y = 91, z = 10426},
		["Red_Bot_Tier_2"] = {x = 13550, y = 52, z = 7848},
		["Red_Bot_Tier_3"] = {x = 13670, y = 52, z = 4282},
		["Blue_Mid_Tier_1"] = {x = 5974, y = 51, z = 6054},
		["Blue_Mid_Tier_2"] = {x = 5048, y = 50, z = 4606},
		["Blue_Mid_Tier_3"] = {x = 3880, y = 95, z = 3676},
		["Red_Mid_Tier_1"] = {x = 11218, y = 91, z = 10952},
		["Red_Mid_Tier_2"] = {x = 9810, y = 51, z = 9818},
		["Red_Mid_Tier_3"] = {x = 8814, y = 53, z = 8362},
		["Blue_Top_Tier_1"] = {x = 1130, y = 52, z = 10368},
		["Blue_Top_Tier_2"] = {x = 1164, y = 52, z = 6726},
		["Blue_Top_Tier_3"] = {x = 10022, y = -72, z = 4614},
		["Red_Top_Tier_1"] = {x = 4434, y = -67, z = 9660},
		["Red_Top_Tier_2"] = {x = 7600, y = 52, z = 13559},
		["Red_Top_Tier_3"] =  {x = 10734, y = 91, z = 13464},
		["Dragon"] = {x = 10226, y = -72, z = 4712},
		["Baron"] = {x = 5014, y = -72, z = 10096},
		["Blue_Red_Buff"] = {x = 7354, y = 51, z = 3792},
		["Blue_Blue_Buff"] = {x = 3804, y = 51, z = 7692},
		["Red_Red_Buff"] = {x = 7442, y = 56, z = 10978},
		["Red_Blue_Buff"] = {x = 11228, y = 51, z = 6624},
		["Blue_Gromp"] = {x = 2434, y = 51, z = 8272},
		["Blue_Wolves"] = {x = 3658, y = 52, z = 6174},
		["Blue_Raptors"] =  {x = 7102, y = 48, z = 4942},
		["Blue_Krugs"] = {x = 8176, y = 51, z = 2392},
		["Red_Gromp"] = {x = 12300, y = 52, z = 6360},
		["Red_Wolves"] = {x = 11206, y = 58, z = 8438},
		["Red_Raptors"] = {x = 7618, y = 51, z = 9872},
		["Red_Krugs"] = {x = 6496, y = 56, z = 12336},
		["Bot_Tri_Bush"] = {x = 10414, y = 50, z = 3048},
		["Top_Tri_Bush"] = {x = 4444, y = 56, z = 11736},
		["Top_River_Bush"] = {x = 2954, y = -73, z = 10888},
		["Bot_River_Bush"] = {x = 11838, y = -68, z = 3792},
		["Mid_Lane"] = {x = 7352, y = 54, z = 7202},
		["Bot_Lane"] = {x = 12492, y = 51, z = 2306},
		["Top_Lane"] = {x = 2161, y = 52, z = 12369},
	},
	init = function(self)
		self.screen = g_render:get_screensize()
		self.screenX = self.screen.x
		self.screenY = self.screen.y
	end,
	textAt = function(self, pos, color, text)
		g_render:text(pos, color, text, self.font, self.fontSize)
	end,
	GetClosestRiftLocation = function(self, x, y, z)
		-- Prints("My hero position: x=" .. tostring(g_local.position.x) .. ", y=" .. tostring(g_local.position.y) .. ", z=" .. tostring(g_local.position.z))
		
		local closestLocation = ""
		local shortestDistance = std_math.huge
		
		for location, coords in pairs(self.rift_locations) do
			local distance = std_math.sqrt((coords.x - x)^2 + (coords.y - y)^2 + (coords.z - z)^2)
			if distance < shortestDistance then
				closestLocation = location
				shortestDistance = distance
			end
		end
		 
		return closestLocation,std_math.floor(shortestDistance)
	end,

})

--------------------------------------------------------------------------------
-- Math
--------------------------------------------------------------------------------
local math = class({
	xHelper = nil,
	buffcache = nil,

	init = function(self, xHelper, buff_cache)
		self.xHelper = xHelper
		self.buffcache = buff_cache
	end,
	get_menu_value = function(self, cfg)
		return cfg:get_value()
	end,

	dis = function(self, p1, p2)
		return std_math.sqrt(self:DistanceSqr(p1, p2))
	end,

	dis_sq = function(self, p1, p2)
		local dx, dy = p2.x - p1.x, p2.z - p1.z
		return dx * dx + dy * dy
	end,

	angle_between = function(self, p1, p2, p3)
		local angle = std_math.deg(
			std_math.atan(p3.z - p1.z, p3.x - p1.x) -
			std_math.atan(p2.z - p1.z, p2.x - p1.x))
		if angle < 0 then angle = angle + 360 end
		return angle > 180 and 360 - angle or angle
	end,
	is_facing = function(self, source, unit)
		local dir = source.direction
		local angle = self:angle_between(source, unit, dir)
		return angle < 90
	end,

	in_aa_range = function(self, unit, raw)
		local range = self.xHelper:get_aa_range()
		local hitbox = unit:get_bounding_radius() or 80

		if g_local.champion_name == "Aphelios" and unit:is_hero() and self.buffcache:has_buff(unit, "aphelioscalibrumbonusrangedebuff") then
			range, hitbox = 1800, 0
		elseif g_local.champion_name == "Caitlyn" and (self.buffcache:has_buff(unit, "caitlynwsight") or self.buffcache:has_buff(unit, "CaitlynEMissile")) then
			range = range + 650
		elseif g_local.champ_name == "Zeri" and g_local:get_spell_book():get_spell_slot(e_spell_slot.q):is_ready() then
			range, hitbox = 825, 0
		elseif g_local.champ_name == "Samira" and features.buff_cache:is_immobile(unit.index) then
			range = std_math.min(650 + 77.5 * (g_local.level - 1), 960)
		elseif g_local.champ_name == "Karthus" then
			range = 1035
		end
		if raw and not self.xHelper:is_melee(g_local) then
			hitbox = 0
		end
		local dist = self:dis_sq(g_local.position, unit.position)
		return dist <= (range + hitbox) ^ 2
	end,

})

--------------------------------------------------------------------------------
-- Objects
--------------------------------------------------------------------------------

local objects = class({
	xHelper = nil,
	math = nil,
	database = nil,
	util = nil,

	init = function(self, xHelper, math, database, util)
		self.xHelper = xHelper
		self.math = math
		self.database = database
		self.util = util
	end,
	get_ordered_turret_targets = function(self, turret, minions)
		local turret_prio_list = {}
		local priority = {
			[3] = 1,  -- Siege Minions
			[2] = 2,  -- Melee Minions
			[1] = 3   -- Ranged Minions
			-- If Super Minions have a different priority, adjust here.
			-- Currently, Super Minions (4) will be at the end due to the default sorting mechanism.
		}
	
		for i, unit in ipairs(minions) do
			local dist = turret.position:dist_to(unit.position)	
			table.insert(turret_prio_list, {
				minion = unit,
				distance = dist,
				prio = priority[unit.minion_type] or 4  -- defaults to 4 (lowest priority) if minion_type not in priority table
			})
		end
	
		-- Custom sort function
		table.sort(turret_prio_list, function(a, b)
			if a.prio == b.prio then
				return a.distance < b.distance
			end
			return a.prio < b.prio
		end)
	
		-- Extracting the sorted minions from the list
		local sorted_minions = {}
		for _, entry in ipairs(turret_prio_list) do
			table.insert(sorted_minions, entry.minion)
		end
	
		return sorted_minions
	end,
	get_minion_type = function (self, obj_min)
		local object_name = obj_min:get_object_name():lower()
		-- if string.find(object_name, "raned") 
		-- types are ranged 1, melee 2, siege 3
		-- lets return the number
		if string.find(object_name, "siege") then
			return 3
		elseif string.find(object_name, "ranged") then
			return 1
		else
			return 2
		end
		return 0
	end,
	get_current_target_of_slot = function(self, slots, unit)
		unit = unit or g_local
		local target = nil
		if unit and self.xHelper:is_alive(unit) then
			local spell_book = unit:get_spell_book()
			local cast_info = spell_book:get_spell_cast_info()
			if spell_book and cast_info then
				for _, slot in ipairs(slots) do
					if cast_info.slot == slot then
						local target_index = cast_info:get_target_index()
						if target_index then
							target = features.entity_list:get_by_index(target_index)
						end
						break -- If we found the slot, no need to continue the loop
					end
				end
			end
		end
		return target or nil
	end,
	get_current_target = function(self, unit)
		unit = unit or g_local
		local target = nil
		if unit and self.xHelper:is_alive(unit) then
			local spell_book = unit:get_spell_book()
			local cast_info = spell_book:get_spell_cast_info()
			if spell_book and cast_info then
				target = cast_info:get_target_index()
			end
		end
		return target or nil
	end,
	get_name = function(self, unit)
		unit = unit or g_local
		return unit:get_object_name() or nil
	end,
	get_team_color = function(self, unit)
		unit = unit or g_local
		local team = unit.team
		if team == 200 then
			return 200, "red"
		elseif team == 100 then
			return 100, "blue"
		else
			return 0, nil
		end
	end,
	get_baseult_pos = function(self, unit)
		if not unit then return nil end

		local team, color = self:get_team_color(unit)
		local baseult_pos = nil
		if color == "red" then
			baseult_pos = vec3:new(self.util.rift_locations["Red_Recall"].x, self.util.rift_locations["Red_Recall"].y, self.util.rift_locations["Red_Recall"].z)
		elseif color == "blue" then
			baseult_pos = vec3:new(self.util.rift_locations["Blue_Recall"].x, self.util.rift_locations["Blue_Recall"].y, self.util.rift_locations["Blue_Recall"].z)
		end
		return baseult_pos
	end,
	get_bounding_radius = function(self, unit)
		return unit:get_bounding_radius() or 45
	end,
	is_enemy_near = function(self, range, position)
		position = position or g_local.position
		for _, entity in pairs(features.entity_list:get_enemies()) do
			local bounding_radius = self:get_bounding_radius(entity)
			if entity and entity.position:dist_to(position) <= range + bounding_radius then
				return true
			end
		end
		return false
	end,
	get_enemy_champs = function(self, range, position)
		position = position or g_local.position
		local enemy_champs = {}
		for i, unit in ipairs(features.entity_list:get_enemies()) do
			if self.xHelper:is_alive(unit) and self.xHelper:is_valid(unit) and not self.xHelper:is_invincible(unit) and (range and self.math:dis_sq(position, unit.position) <= range ^ 2 or self.math:in_aa_range(unit, true)) then
				table.insert(enemy_champs, unit)
			end
		end
		return enemy_champs
	end,
	get_ally_champs = function(self, range, position)
		position = position or g_local.position
		local ally_champs = {}
		for i, unit in ipairs(features.entity_list:get_allies()) do
			if self.xHelper:is_alive(unit) and self.xHelper:is_valid(unit) and not self.xHelper:is_invincible(unit) and (range and self.math:dis_sq(position, unit.position) <= range ^ 2 or self.math:in_aa_range(unit, true)) then
				table.insert(ally_champs, unit)
			end
		end
		return ally_champs
	end,
	get_aa_travel_time = function(self, target, unit, speed)
		unit = unit or g_local
		speed = speed or nil
		if not speed then
			local champion_name = unit.champion_name.text:lower() -- adjust the variable name as needed

			-- default missile speed
			speed = 1000

			-- Find the champion in the table
			local champion_data = self.database.DMG_LIST[champion_name]
			if champion_data then
				for _, ability_data in ipairs(champion_data) do
					if ability_data.slot == "AA" then
						speed = ability_data.missile_speed
						break
					end
				end
			end
		end

		local distance = unit.position:dist_to(target.position)
		return distance / speed
	end,
	count_enemy_champs = function(self, range, position)
		position = position or g_local.position
		local num = #self:get_enemy_champs(range, position) or 0
		return num
	end,
	get_enemy_minions = function(self, range, pos)
		pos = pos or g_local.position
		local enemies = {}

		for _, entity in pairs(features.entity_list:get_enemy_minions()) do
			if entity and entity.position and entity.position:dist_to(pos) <= range and core.helper:is_alive(entity) then
				local object_name = entity:get_object_name():lower()

				if string.find(object_name, "sru_crab") or string.find(object_name, "sru_dragon") or string.find(object_name, "sru_riftherald") or string.find(object_name, "sru_baron")
				or string.find(object_name, "sru_gromp") or string.find(object_name, "sru_blue") or string.find(object_name, "sru_murkwolf")
				or string.find(object_name, "sru_razorbeak") or string.find(object_name, "sru_red") or string.find(object_name, "sru_krug")
				or string.find(object_name, "sru_chaosminion") or string.find(object_name, "sru_orderminion") then table.insert(enemies, entity) end

			end
		end
		return enemies
	end,
	count_enemy_minions = function(self, range, position)
		position = position or g_local.position
		local num = #self:get_enemy_minions(range, position) or 0
		return num
	end,
	is_big_jungle = function(self, object)
		local name = object:get_object_name():lower()		
		local bigJungleMonsters = {
			"sru_gromp",
			"sru_blue",
			"sru_murkwolf",
			"sru_razorbeak",
			"sru_red",
			"sru_krug",
			"sru_crab",
			"sru_dragon",
			"sru_riftherald",
			"sru_baron",
		}
	
		for _, monsterName in pairs(bigJungleMonsters) do
			if name == monsterName then
				return true
			end
		end
	
		return false
	end,
	is_ready = function(self, slot, unit)
		unit = unit or g_local
		return unit:get_spell_book():get_spell_slot(slot):is_ready()
	end,
	has_enough_mana = function(self, slot, unit)
		unit = unit or g_local
		local spell = unit:get_spell_book():get_spell_slot(slot)
		local level = spell.Level or 0
		local cost = spell:get_mana_cost()[level] or 0

		if unit and spell and cost then
			if unit.mana >= cost then
				return true
			else
				return false
			end
		end
	end,
	can_cast = function(self, slot, unit)
		unit = unit or g_local
		if self:is_ready(slot, unit) and self:has_enough_mana(slot, unit) then
			return true
		end
		return false
	end,
	get_spell_level = function(self, slot, unit)
		unit = unit or g_local
		local level = unit:get_spell_book():get_spell_slot(slot).level or 0
		return level
	end,
})

--------------------------------------------------------------------------------
-- Buffs
--------------------------------------------------------------------------------
local buffcache = class({
	get_buff = function(self, unit, name)
		return features.buff_cache:get_buff(unit.index, name)
	end,

	get_amount = function(self, unit, name)
		return features.buff_cache:get_buff(unit.index, name).amount
	end,

	get_duration = function(self, unit, name)
		local buff = features.buff_cache:get_buff(unit.index, name)
		return buff.end_time - buff.start_time
	end,

	has_buff = function(self, unit, name)
		return features.buff_cache:get_buff(unit.index, name)
	end,

})

--------------------------------------------------------------------------------
-- Helper
--------------------------------------------------------------------------------
local xHelper = class({
	
	HYBRID_RANGED = { "Elise", "Gnar", "Jayce", "Kayle", "Nidalee", "Zeri" },
	INVINCIBILITY_BUFFS = {
		["aatroxpassivedeath"] = true,
		["FioraW"] = true,
		["JaxCounterStrike"] = true,
		["JudicatorIntervention"] = true,
		["KarthusDeathDefiedBuff"] = true,
		["kindredrnodeathbuff"] = false,
		["KogMawIcathianSurprise"] = true,
		["SamiraW"] = true,
		["ShenWBuff"] = true,
		["TaricR"] = true,
		["UndyingRage"] = false,
		["VladimirSanguinePool"] = true,
		["ChronoShift"] = false,
		["chronorevive"] = true,
		["zhonyasringshield"] = true
	},

    vec3_util = nil,
	buffcache = nil,

	init = function(self,vec3_util, buffcache)
        self.vec3_util = vec3_util
		self.buffcache = buffcache
	end,
	is_under_turret = function(self,pos, enemy_only)
		enemy_only = enemy_only or true
		pos = pos or g_local.position
		local range = 915
		
		for _, unit in ipairs(features.entity_list:get_enemy_turrets()) do
		  if unit  and unit:is_alive() then
			local dist_away = self.vec3_util:distance(unit.position, pos)
			if dist_away < range then return true, unit end
		  end
		end
		if not enemy_only then
			for _, unit in ipairs(features.entity_list:get_ally_turrets()) do
				if unit and unit:is_alive() then
					local dist_away = self.vec3_util:distance(unit.position, pos)
					if dist_away < range then return true, unit end
				  end
			end
		end

		return false, nil
	end,
    get_nearest_turret = function(self, pos, enemy_only)
        pos = pos or g_local.position
        enemy_only = enemy_only or true
        -- get all the turrets
        -- sort them by distance to pos
        -- return closest one
        local turrets = {}
        enemy_only = enemy_only or true
        pos = pos or g_local.position
        
        for _, unit in ipairs(features.entity_list:get_enemy_turrets()) do
            if unit  and unit:is_alive() then
                table.insert(turrets, unit)
            end
        end
        if not enemy_only then
            for _, unit in ipairs(features.entity_list:get_ally_turrets()) do
                if unit and unit:is_alive() then
                    table.insert(turrets, unit)
                end
            end
        end
        table.sort(turrets, function(a, b)
            return self.vec3_util:distance(a.position, pos) < self.vec3_util:distance(b.position, pos)
        end)

        return turrets[1]
    end,
	get_ordered_turret_targets = function(self, turret, minions)
		local turret_prio_list = {}
		local priority = {
			[3] = 1,  -- Siege Minions
			[2] = 2,  -- Melee Minions
			[1] = 3   -- Ranged Minions
			-- If Super Minions have a different priority, adjust here.
			-- Currently, Super Minions (4) will be at the end due to the default sorting mechanism.
		}
	
		for i, unit in ipairs(minions) do
			local dist = self.vec3_util:distance(turret.position, unit.position)
			table.insert(turret_prio_list, {
				minion = unit,
				distance = dist,
				prio = priority[self.objects:get_minion_type(unit)] or 4  -- defaults to 4 (lowest priority) if minion_type not in priority table
			})
		end
	
		-- Custom sort function
		table.sort(turret_prio_list, function(a, b)
			if a.prio == b.prio then
				return a.distance < b.distance
			end
			return a.prio < b.prio
		end)
	
		-- Extracting the sorted minions from the list
		local sorted_minions = {}
		for _, entry in ipairs(turret_prio_list) do
			table.insert(sorted_minions, entry.minion)
		end
	
		return sorted_minions
	end,
	get_mode = function (self)
		return features.orbwalker:get_mode()
	end,
	get_menu_val = function(self, cfg)
		return cfg:get_value()
	end,
	get_game_time = function(self)
		return g_time
	end,
	is_melee = function(self, unit)
		return unit.attack_range < 300
			and self.HYBRID_RANGED[unit.champion_name] ~= nil
	end,

	get_local_player = function(self)
		return g_local
	end,

	get_aa_range = function(self, unit)
		local unit = unit or g_local
		if (unit.champion_name == "Karthus") then
			return 1035 + unit:get_bounding_radius()
		end
		return unit.attack_range + unit:get_bounding_radius()
	end,

	is_invincible = function(self, unit)
		for _, buff in ipairs(features.buff_cache:get_all_buffs(unit.index)) do
			if buff and self.buffcache:get_duration(unit, buff.name) > 0 and buff:get_amount() > 0 then
				local invincibility_buff = self.INVINCIBILITY_BUFFS[buff.name]
				if invincibility_buff ~= nil then
					if invincibility_buff == false and unit.health / unit.max_health < 0.05 then
						return true
					elseif invincibility_buff == true then
						return true
					end
				end
			end
		end
		return false
	end,

	get_percent_hp = function(self, unit)
		return 100 * unit.health / unit.max_health
	end,

	get_percent_missing_hp = function(self, unit)
		return (1 - (unit.health / unit.max_health)) * 100
	end,

	get_missing_hp = function(self, unit)
		return (unit.max_health - unit.health)
	end,

	is_alive = function(self, unit)
		local alive = unit and not unit:is_invalid_object() and unit:is_visible() and unit:is_alive() and
			unit:is_targetable()
			and not self.buffcache:has_buff(unit, "sionpassivezombie")
			and not unit:get_object_name():lower():find("corpse")
			and unit.position ~= nil

		-- print("checking alive: " .. tostring(unit:get_object_name()))
		-- print("invalid: " ..tostring( unit:is_invalid_object()))
		-- print("visible: " .. tostring(unit:is_visible()))
		-- print("alive: " .. tostring(unit:is_alive()))
		-- print("targetable: " .. tostring(unit:is_targetable()))
		-- print("sion: " .. tostring(self.buffcache:has_buff(unit, "sionpassivezombie")))
		-- print("corpse: " .. tostring(unit:get_object_name():lower():find("corpse")))
		-- print("pos: " .. tostring(unit.position ~= nil))
		-- print("we will return: " .. tostring(alive))
		return alive
	end
	,

	is_valid = function(self, unit)
		return unit and not unit:is_invalid_object() and unit:is_visible()
			and unit:is_alive() and unit:is_targetable()
	end,

	get_latency = function(self)
		return features.orbwalker:get_ping() / 1000
	end

})

--------------------------------------------------------------------------------
-- Damage Library
--------------------------------------------------------------------------------
local damagelib = class({
	xHelper = nil,
	math = nil,
	database = nil,
	buffcache = nil,

	CHAMP_PASSIVES = {
		Jinx = function(self, args)
			local source = args.source -- 13.7
			if not self.buffcache:has_buff(source, "JinxQ") then return end
			args.raw_physical = args.raw_physical
				+ source:get_attack_damage() * 0.1
		end,
	},
	ITEM_PASSIVES = {
		-- TODO: wait for inventory api to be added.
		[3153] = function(self, args)
			local source = args.source -- Blade of the Ruined King
			local mod = self.functions.xHelper:is_melee(source) and 0.12 or 0.08
			args.raw_physical = args.raw_physical + std_math.min(
				60, std_math.max(15, mod * args.unit.health))
		end,
		[3742] = function(self, args)
			local source = args.source -- Dead Man's Plate
			local stacks = std_math.min(100, 0) -- TODO
			args.raw_physical = args.raw_physical + 0.4 * stacks
				+ 0.01 * stacks * source:get_attack_damage()
		end,
		[1056] = function(self, args) -- Doran's Ring
			args.raw_physical = args.raw_physical + 5
		end,
		[1054] = function(self, args) -- Doran's Shield
			args.raw_physical = args.raw_physical + 5
		end,
		[3124] = function(self, args)
			local source = args.source -- Guinsoo's Rageblade
			args.raw_physical = args.raw_physical +
				std_math.min(200, source.crit_chance * 200)
		end,
		[3004] = function(self, args) -- Manamune
			args.raw_physical = args.raw_physical
				+ args.source.max_mana * 0.025
		end,
		[3042] = function(self, args) -- Muramana
			args.raw_physical = args.raw_physical
				+ args.source.max_mana * 0.025
		end,
		[3115] = function(self, args) -- Nashor's Tooth_se
			args.raw_magical = args.raw_magical + 15
				+ 0.2 * args.source:get_ability_power()
		end,
		[6670] = function(self, args) -- Noonquiver
			args.raw_physical = args.raw_physical + 20
		end,
		[6677] = function(self, args)
			local source = args.source -- Rageknife
			args.raw_physical = args.raw_physical +
				std_math.min(175, 175 * source.crit_chance)
		end,
		[1043] = function(self, args) -- Recurve Bow
			args.raw_physical = args.raw_physical + 15
		end,
		[3070] = function(self, args) -- Tear of the Goddess
			args.raw_physical = args.raw_physical + 5
		end,
		[3748] = function(self, args)
			local source = args.source -- Titanic Hydra
			local mod = self.functions.xHelper:is_melee(args.source) and { 4, 0.015 } or { 3, 0.01125 }
			local damage = mod[1] + mod[2] * args.source.max_health
			args.raw_physical = args.raw_physical + damage
		end,
		[3091] = function(self, args)
			local source = args.source -- Wit's End
			local damage = ({ 15, 15, 15, 15, 15, 15, 15, 15, 25, 35,
				45, 55, 65, 75, 76.25, 77.5, 78.75, 80 })[source.level]
			args.raw_magical = args.raw_magical + damage
		end
	},


	init = function(self, xHelper, math, database, buffcache)
		self.xHelper = xHelper
		self.math = math
		self.database = database
		self.buffcache = buffcache
	end,

	check_for_passives = function(self, args)
		local source = args.source
		local buff = self.buffcache:get_buff(source, "6672buff") -- Kraken Slayer
		if buff and buff:get_amount() == 3 then
			args.true_damage = args.true_damage + 50 +
				0.4 * source:get_bonus_attack_damage()
		end
		if self.buffcache:has_buff(source, "3504Buff") then -- Ardent Censer
			args.raw_magical = args.raw_magical + 4.12 + 0.88 * args.unit.level
		end
		if self.buffcache:has_buff(source, "6632buff") then -- Divine Sunderer
			args.raw_physical = args.raw_physical + 1.25 *
				source:get_attack_damage() + (self.functions.xHelper:is_melee(source)
					and 0.06 or 0.03) * args.unit.max_health
		end

		if self.buffcache:has_buff(source, "3508buff") then -- Essence Reaver
			args.raw_physical = args.raw_physical + 0.4 *
				source:get_bonus_attack_damage() + source:get_attack_damage()
		end

		if self.buffcache:has_buff(source, "lichbane") then -- Lich Bane
			args.raw_magical = args.raw_magical + 0.75 *
				source:get_attack_damage() + 0.5 * source:get_ability_power()
		end

		if self.buffcache:has_buff(source, "sheen") then
			args.raw_physical = args.raw_physical + source:get_attack_damage()
		end

		if self.buffcache:has_buff(source, "3078trinityforce") then -- Trinity Force
			args.raw_physical = args.raw_physical + 2 * source:get_attack_damage()
		end

		if self.buffcache:get_buff(source, "item6664counter") then
			if self.buffcache:get_buff(source, "item6664counter"):get_amount() == 100 then -- Turbo Chemtank -- line 350
				local damage = 35.29 + 4.71 * source.level + 0.01 *
					source.max_health + 0.03 * source.movement_speed
				args.raw_magical = args.raw_magical + damage * 1.3
			end
		end

		local buff = self.buffcache:get_buff(source, "itemstatikshankcharge")
		local damage = buff and buff:get_amount() == 100 and 0 or 0

		if buff then -- Kircheis Shard, Rapid Firecannon, Stormrazor
			damage = buff:get_amount() == 100 and 80 or 0
		end

		args.raw_magical = args.raw_magical + damage
	end,

	calc_aa_dmg = function(self, source, target)
		local idx = target.index
		local name = source.champion_name.text
		local physical = source:get_attack_damage()
		local args = {
			raw_magical = 0,
			raw_physical = physical,
			true_damage = 0,
			source = source,
			unit = features.entity_list:get_by_index(idx)
		}
		if name == "Corki" and physical > 0 then
			return
				self:calc_mixed_dmg(source, features.entity_list:get_by_index(idx), physical)
		end
		local items = {}
		for i = 6, 12 do
			local slot = i
			local item = source:get_spell_book():get_spell_slot(slot)
			items[#items + 1] = item
		end

		self:check_for_passives(args) -- TODO: check if this is correct
		if self.CHAMP_PASSIVES[name] then self.CHAMP_PASSIVES[name](self, args) end

		local magical = self:calc_ap_dmg(source, features.entity_list:get_by_index(idx), args.raw_magical)
		local physical = self:calc_ad_dmg(source, features.entity_list:get_by_index(idx), args.raw_physical)

		return magical + physical + args.true_damage
	end,

	calc_dmg = function(self, source, target, amount)
		return source:get_ability_power() > source:get_attack_damage()
			and self:calc_ap_dmg(source, target, amount)
			or self:calc_ad_dmg(source, target, amount)
	end,

	calc_ap_dmg = function(self, source, target, amount)
		return helper.calculate_damage(amount, target.index, false)
	end,

	calc_ad_dmg = function(self, source, target, amount)
		return helper.calculate_damage(amount, target.index, true)
	end,

	calc_spell_dmg = function(self, spell, source, target, stage, level)
		local source = source or g_local
		local stage = stage or 1
		local cache = {}

		if stage > 4 then stage = 4 end

		if spell == "Q" or spell == "W" or spell == "E" or spell == "R" or spell == "QM" or spell == "WM" or spell == "EM" then
			local level = level or source:get_spell_book():get_spell_slot((
				{ ["Q"] = e_spell_slot.q, ["QM"] = e_spell_slot.q, ["W"] = e_spell_slot.w, ["WM"] = e_spell_slot.w,
					["E"] = e_spell_slot.e, ["EM"] = e_spell_slot.e, ["R"] = e_spell_slot.r }
			)[spell]).level

			if level <= 0 then return 0 end
			if level > 5 then level = 5 end

			
			if self.database.DMG_LIST[source.champion_name.text:lower()] then
				
				for _, spells in ipairs(self.database.DMG_LIST[source.champion_name.text:lower()]) do
					if spells.slot == spell then
						table.insert(cache, spells)
					end
				end

				if stage > #cache then stage = #cache end

				for v = #cache, 1, -1 do
					local spells = cache[v]
					if spells.stage == stage then
						local dmg = spells.damage(self, source, target, level)


						return self:calc_dmg(source, target, dmg)
					end
				end
			else
				return 0
			end

		end

		if spell == "AA" then
			return self:calc_aa_dmg(source, target)
		end

		if spell == "IGNITE" then
			return 50 + 20 * source.level - (target.total_health_regen * 3)
		end

		if spell == "SMITE" then
			if stage == 1 then
				if target:is_hero() then
					return 0
				end
				return 600 -- Smite
			end

			if stage == 2 then
				if target:is_hero() then
					return 80 + 80 / 17 * (source.level - 1)
				end
				return 900
			end

			if stage == 3 then
				if target:is_hero() then
					return 80 + 80 / 17 * (source.level - 1)
				end
				return 1200
			end
		end

		return 0
	end,

})

-------------------------------------------------------------------------------
-- Database
--------------------------------------------------------------------------------

local database = class({
	xHelper = nil,

	init = function(self, xHelper)
		self.xHelper = xHelper
	end,

	DASH_LIST = {
		Rakan        = { e_spell_slot.w, e_spell_slot.e },
		Renekton     = { e_spell_slot.e },
		Nocturne     = { e_spell_slot.r },
		Caitlyn      = { e_spell_slot.e },
		Poppy        = { e_spell_slot.e },
		Zeri         = { e_spell_slot.e },
		Samira       = { e_spell_slot.e },
		Talon        = { e_spell_slot.q, e_spell_slot.e },
		Thresh       = { e_spell_slot.q },
		Tristana     = { e_spell_slot.w },
		Tryndamere   = { e_spell_slot.e },
		Riven        = { e_spell_slot.q1, e_spell_slot.q2, e_spell_slot.q3, e_spell_slot.e },
		Urgot        = { e_spell_slot.e },
		Shaco        = { e_spell_slot.q },
		Xinzhao      = { e_spell_slot.e },
		Yasuo        = { e_spell_slot.e },
		Gnar         = { e_spell_slot.e },
		Jayce        = { e_spell_slot.q },
		Shen         = { e_spell_slot.e },
		Aatrox       = { e_spell_slot.e },
		Shyvana      = { e_spell_slot.r },
		Akali        = { e_spell_slot.e, e_spell_slot.r },
		Sylas        = { e_spell_slot.e },
		Monkeyking   = { e_spell_slot.w, e_spell_slot.e },
		Vayne        = { e_spell_slot.q },
		Vex          = { e_spell_slot.r },
		Vi           = { e_spell_slot.q },
		Viego        = { e_spell_slot.w },
		Zac          = { e_spell_slot.e },
		Volibear     = { e_spell_slot.r },
		Diana        = { e_spell_slot.e },
		Warwick      = { e_spell_slot.q, e_spell_slot.r },
		Rell         = { e_spell_slot.w },
		Elise        = { e_spell_slot.q },
		Ekko         = { e_spell_slot.e },
		Corki        = { e_spell_slot.w },
		Yone         = { e_spell_slot.q, e_spell_slot.r },
		Fiddlesticks = { e_spell_slot.r },
		Camille      = { e_spell_slot.e },
		Zed          = { e_spell_slot.w, e_spell_slot.r },
		Fizz         = { e_spell_slot.q },
		Galio        = { e_spell_slot.e },
		Amumu        = { e_spell_slot.q },
		Garen        = { e_spell_slot.q },
		Alistar      = { e_spell_slot.w },
		Malphite     = { e_spell_slot.r },
		Gragas       = { e_spell_slot.e },
		Ahri         = { e_spell_slot.r },
		Gwen         = { e_spell_slot.e },
		Illaoi       = { e_spell_slot.w },
		Sejuani      = { e_spell_slot.q },
		Irelia       = { e_spell_slot.q },
		Ziggs        = { e_spell_slot.w },
		Azir         = { e_spell_slot.e },
		Belveth      = { e_spell_slot.q },
		Jax          = { e_spell_slot.q },
		Yuumi        = { e_spell_slot.w },
		Evelynn      = { e_spell_slot.e },
		Ezreal       = { e_spell_slot.e },
		Nidalee      = { e_spell_slot.w },
		Fiora        = { e_spell_slot.q },
		Quinn        = { e_spell_slot.e },
		Jarvaniv     = { e_spell_slot.q, e_spell_slot.r },
		Kaisa        = { e_spell_slot.r },
		Ksante       = { e_spell_slot.w, e_spell_slot.e, e_spell_slot.r },
		Ivern        = { e_spell_slot.q },
		Kassadin     = { e_spell_slot.r },
		Kalista      = { e_spell_slot.q },
		Braum        = { e_spell_slot.w },
		Katarina     = { e_spell_slot.e },
		Kayn         = { e_spell_slot.q },
		KhaZix       = { e_spell_slot.e },
		Kindred      = { e_spell_slot.q },
		Leona        = { e_spell_slot.e },
		MasterYi     = { e_spell_slot.q },
		Leblanc      = { e_spell_slot.w, e_spell_slot.r },
		LeeSin       = { e_spell_slot.q, e_spell_slot.w },
		Lillia       = { e_spell_slot.w },
		Lissandra    = { e_spell_slot.e },
		Lucian       = { e_spell_slot.e },
		Graves       = { e_spell_slot.e },
		Pyke         = { e_spell_slot.e },
		Maokai       = { e_spell_slot.w },
		Kled         = { e_spell_slot.e },
		Hecarim      = { e_spell_slot.e, e_spell_slot.r },
		Nilah        = { e_spell_slot.e },
		RekSai       = { e_spell_slot.e, e_spell_slot.r },
		-- Rengar? passive TODO
		Orrn         = { e_spell_slot.e },
		Pantheon     = { e_spell_slot.w },
		Nautilus     = { e_spell_slot.q },
		Qiyana       = { e_spell_slot.w, e_spell_slot.e },
		Sion         = { e_spell_slot.e },
	},

	DMG_LIST = {
		jinx = { -- 13.6
			{
				slot = "AA",
				stage = 1,
				damage_type = 1,
				missile_speed = 1700
			},
			{
				slot = "Q",
				stage = 1,
				damage_type = 1,
				damage = function(self, source, target, level) return 0.1 * source:get_attack_damage() end
			},
			{
				slot = "W",
				stage = 1,
				damage_type = 1,
				damage = function(self, source, target, level)
					return ({ 10, 60, 110, 160, 210 })[level] +
						1.6 * source:get_attack_damage()
				end
			},
			{
				slot = "E",
				stage = 1,
				damage_type = 2,
				damage = function(self, source, target, level)
					return ({ 70, 120, 170, 220, 270 })[level] +
						source:get_ability_power()
				end
			},
			{
				slot = "R",
				stage = 1,
				damage_type = 1,
				damage = function(self, source, target, level)
					local distance = source.position:dist_to(target.position)
					local jinx_multiplier

					if distance >= 1500 then
						jinx_multiplier = 1
					elseif distance <= 100 then
						jinx_multiplier = 0.1
					else
						jinx_multiplier = 0.1 + 0.9 * ((distance - 100) / (1500 - 100))
					end

					local dmg = (({ 300, 450, 600 })[level] + (1.5 * source:get_bonus_attack_damage()) * jinx_multiplier) +
						(({ 25, 30, 35 })[level] / 100 * self.xHelper:get_missing_hp(target))

					return dmg
				end
			},
		},
		sion = { -- 13.6
			{
				slot = "Q",
				stage = 1,
				damage_type = 1,
				damage = function(self, source, target, level)
					return 0
				end
			},
			{
				slot = "W",
				stage = 1,
				damage_type = 2,
				damage = function(self, source, target, level)
					return 0
				end
			},
			{
				slot = "E",
				stage = 1,
				damage_type = 2,
				damage = function(self, source, target, level)
					return 0
				end
			},
			{
				slot = "R",
				stage = 1,
				damage_type = 1,
				damage = function(self, source, target, level)
					return 0
				end
			},
		},
	},
	add_champion_data = function(self, new_dmg_data)
		for champ_name, dmg_data in pairs(new_dmg_data) do
			print(champ_name)
			print(dmg_data)
			if self.DMG_LIST[champ_name] then
				for _, new_dmg_entry in ipairs(dmg_data) do
					table.insert(self.DMG_LIST[champ_name], new_dmg_entry)
				end
			else
				self.DMG_LIST[champ_name] = dmg_data
			end
		end
	end,
	has_dash = function(self, unit)
		if self.DASH_LIST[unit.champion_name.text] == nil then return false end
		return true
	end,

	has_dash_available = function(self, unit)
		local champion = unit.champion_name.text
		local dash_spells = self.DASH_LIST[champion]

		if not dash_spells then
			return false
		end

		for _, slot in ipairs(dash_spells) do
			if unit:get_spell_book():get_spell_slot(slot):is_ready() then
				return true
			end
		end

		return false
	end,

})
--------------------------------------------------------------------------------
-- Target Selector // very experimental and wip. needs to be improved.
--------------------------------------------------------------------------------

local Weight = {}
Weight.__index = Weight

function Weight.new(distance, damage, priority, health)
	local self = setmetatable({}, Weight)
	self.distance = distance
	self.damage = damage
	self.priority = priority
	self.health = health
	self.total = 0
	return self
end

local Target = {}
Target.__index = Target

function Target.new(unit, weight)
	local self = setmetatable({}, Target)
	self.unit = unit
	self.weight = weight
	return self
end

local target_selector = class({
	xHelper = nil,
	math = nil,
	objects = nil,
	damagelib = nil,

	add = menu.get_main_window():push_navigation("target selector", 10000),
	nav = menu.get_main_window():find_navigation("target selector"),

	ts_sec = nil,
	ts_enabled = false,
	drawings_sec = nil,
	debug_sec = nil,
	weight_sec = nil,

	focus_target = true,
	draw_target = true,
	draw_weight = false,
	weight_mode = true,

	weight_dis = 0,
	weight_dmg = 0,
	weight_prio = 0,
	weight_hp = 0,

	lastForceChange = 0,
	forceTargetMaxDistance = 240,

	init = function(self, xHelper, math, objects, damagelib)
		self.xHelper = xHelper
		self.math = math
		self.objects = objects
		self.damagelib = damagelib

		self.ts_sec = self.nav:add_section("target selector")
		self.drawings_sec = self.nav:add_section("drawings")
		self.debug_sec = self.nav:add_section("debug")
		self.weight_sec = self.nav:add_section("weight")

		self.ts_enabled = self.ts_sec:checkbox("enabled", g_config:add_bool(true, "ts_enabled"))

		self.focus_target = self.ts_sec:checkbox("click to focus", g_config:add_bool(true, "focus_target"))

		self.forceTargetMaxDistance = self.ts_sec:slider_int("max distance",
			g_config:add_int(240, "force_target_max_distance"), 50, 500, 10)

		self.draw_target = self.drawings_sec:checkbox("visualize targets", g_config:add_bool(true, "draw_targets"))

		self.draw_weight = self.debug_sec:checkbox("draw weight", g_config:add_bool(false, "draw_weight"))

		self.weight_mode = self.weight_sec:checkbox("use weight mode", g_config:add_bool(true, "weight_mode"))

		self.debug_sec:button("made w/ love by ampx", function()
		end)

		self.weight_dis = self.weight_sec:slider_int("distance", g_config:add_int(10, "weight_distance"), 0, 100, 1)
		self.weight_dmg = self.weight_sec:slider_int("damage", g_config:add_int(10, "weight_damage"), 0, 100, 1)
		self.weight_prio = self.weight_sec:slider_int("priority", g_config:add_int(10, "weight_priority"), 0, 100, 1)
		self.weight_hp = self.weight_sec:slider_int("health", g_config:add_int(15, "weight_health"), 0, 100, 1)
		self.lastForceChange = g_time
	end,

	GET_STATUS = function(self)
		return self.ts_enabled:get_value()
	end,

	FORCED_TARGET = nil,
	PRIORITY_LIST = {
		Aatrox = 3,
		Ahri = 4,
		Akali = 4,
		Akshan = 5,
		Alistar = 1,
		Amumu = 1,
		Anivia = 4,
		Annie = 4,
		Aphelios = 5,
		Ashe = 5,
		AurelionSol = 4,
		Azir = 4,
		Bard = 3,
		Belveth = 3,
		Blitzcrank = 1,
		Brand = 4,
		Braum = 1,
		Caitlyn = 5,
		Camille = 4,
		Cassiopeia = 4,
		Chogath = 1,
		Corki = 5,
		Darius = 2,
		Diana = 4,
		DrMundo = 1,
		Draven = 5,
		Ekko = 4,
		Elise = 3,
		Evelynn = 4,
		Ezreal = 5,
		FiddleSticks = 3,
		Fiora = 4,
		Fizz = 4,
		Galio = 1,
		Gangplank = 4,
		Garen = 1,
		Gnar = 1,
		Gragas = 2,
		Graves = 4,
		Gwen = 3,
		Hecarim = 2,
		Heimerdinger = 3,
		Illaoi = 3,
		Irelia = 3,
		Ivern = 1,
		Janna = 2,
		JarvanIV = 3,
		Jax = 3,
		Jayce = 4,
		Jhin = 5,
		Jinx = 5,
		Kaisa = 5,
		Kalista = 5,
		Karma = 4,
		Karthus = 4,
		Kassadin = 4,
		Katarina = 4,
		Kayle = 4,
		Kayn = 4,
		Kennen = 4,
		Khazix = 4,
		Kindred = 4,
		Kled = 2,
		KogMaw = 5,
		KSante = 2,
		Leblanc = 4,
		LeeSin = 3,
		Leona = 1,
		Lillia = 4,
		Lissandra = 4,
		Lucian = 5,
		Lulu = 3,
		Lux = 4,
		Malphite = 1,
		Malzahar = 3,
		Maokai = 2,
		MasterYi = 5,
		Milio = 3,
		MissFortune = 5,
		MonkeyKing = 3,
		Mordekaiser = 4,
		Morgana = 3,
		Nami = 3,
		Nasus = 2,
		Nautilus = 1,
		Neeko = 4,
		Nidalee = 4,
		Nilah = 5,
		Nocturne = 4,
		Nunu = 2,
		Olaf = 2,
		Orianna = 4,
		Ornn = 2,
		Pantheon = 3,
		Poppy = 2,
		Pyke = 4,
		Qiyana = 4,
		Quinn = 5,
		Rakan = 3,
		Rammus = 1,
		RekSai = 2,
		Rell = 5,
		Renata = 3,
		Renekton = 2,
		Rengar = 4,
		Riven = 4,
		Rumble = 4,
		Ryze = 4,
		Samira = 5,
		Sejuani = 2,
		Senna = 5,
		Seraphine = 4,
		Sett = 2,
		Shaco = 4,
		Shen = 1,
		Shyvana = 2,
		Singed = 1,
		Sion = 1,
		Sivir = 5,
		Skarner = 2,
		Sona = 3,
		Soraka = 4,
		Swain = 3,
		Sylas = 4,
		Syndra = 4,
		TahmKench = 1,
		Taliyah = 4,
		Talon = 4,
		Taric = 1,
		Teemo = 4,
		Thresh = 1,
		Tristana = 5,
		Trundle = 2,
		Tryndamere = 4,
		TwistedFate = 4,
		Twitch = 5,
		Udyr = 2,
		Urgot = 2,
		Varus = 5,
		Vayne = 5,
		Veigar = 4,
		Velkoz = 4,
		Vex = 4,
		Vi = 2,
		Viego = 4,
		Viktor = 4,
		Vladimir = 3,
		Volibear = 2,
		Warwick = 2,
		Xayah = 5,
		Xerath = 4,
		Xinzhao = 3,
		Yasuo = 4,
		Yone = 4,
		Yorick = 2,
		Yuumi = 2,
		Zac = 1,
		Zed = 4,
		Zeri = 5,
		Ziggs = 4,
		Zilean = 3,
		Zoe = 4,
		Zyra = 3
	},
	TARGET_CACHE = {},
	WEIGHT_CACHE = {
		function(self, a, b)
			return b.health / a.health
		end
	},

	get_cache = function(self, range)
		return self.TARGET_CACHE[range]
	end,

	refresh_targets = function(self, range)
		if not self.TARGET_CACHE[range] then
			self.TARGET_CACHE[range] = { enemies = {} }
		end

		local all_enemies = objects:get_enemy_champs(range)
		local enemies = {}

		for _, enemy in ipairs(all_enemies) do
			if not self.xHelper:is_invincible(enemy) then
				table.insert(enemies, enemy)
			end
		end

		for i = 1, #enemies do
			local weight = { total = 0 }
			for j = 1, #enemies do
				if i ~= j then
					for k, func in ipairs(self.WEIGHT_CACHE) do
						weight[k] = (weight[k] or 0) + func(self, enemies[i], enemies[j])
					end
				end
			end

			local target = self.TARGET_CACHE[range].enemies[i] or {}
			local new_weight = {}

			local d = self.math:dis_sq(g_local.position, enemies[i].position)
			local w = 10000 / (1 + std_math.sqrt(d))
			if not self.xHelper:is_melee(enemies[i]) then
				w = w * self.weight_dis:get_value() / 10
			else
				w = w *
					(self.weight_dis:get_value() / 10 + 1)
			end

			local factor = {
				damage = self.weight_dmg:get_value(),
				prio = self.weight_prio:get_value() / 10,
				health = self.weight_hp:get_value() / 10
			}
			new_weight.damage = (self.damagelib:calc_dmg(g_local, enemies[i], 100) / (1 + enemies[i].health) * 20) *
				factor.damage
			local mod = { 1, 1.5, 1.75, 2, 2.5 }
			new_weight.priority = mod[self.PRIORITY_LIST[enemies[i].champion_name] or 3] * factor.prio
			new_weight.health = (weight[2] or 0) * factor.health * factor.health
			new_weight.total = w + new_weight.damage + new_weight.priority + new_weight.health
			if not target.target or new_weight.total ~= target.weight.total then
				target.target = enemies[i]
				target.weight = new_weight
				self.TARGET_CACHE[range].enemies[i] = target
			end
		end

		table.sort(self.TARGET_CACHE[range].enemies, function(a, b) return a.weight.total > b.weight.total end)
	end,

	get_main_target = function(self, range)
		range = range or 9999999
		self:refresh_targets(range)
		if #self.TARGET_CACHE[range].enemies == 0 then return nil end
		local target = features.entity_list:get_by_index(self.TARGET_CACHE[range].enemies[1].target.index)
		local good_target = target and not xHelper:is_invincible(target) and tostring(xHelper:is_alive(target)) and
		xHelper:is_valid(target)


		if target and good_target then return target end
		return nil
	end,

	get_second_target = function(self, range)
		range = range or 9999999
		self:refresh_targets(range)
		if #self.TARGET_CACHE[range].enemies < 2 then return nil end
		return features.entity_list:get_by_index(self.TARGET_CACHE[range].enemies[2].target.index)
	end,

	get_forced_target = function(self)
		return self.FORCED_TARGET
	end,

	update_forced_target = function(self)
		if self.FORCED_TARGET then
			local enemy = features.entity_list:get_by_index(self.FORCED_TARGET.index)
			if enemy and xHelper:is_alive(enemy) and xHelper:is_valid(enemy) and not xHelper:is_invincible(enemy) then
				self.FORCED_TARGET = enemy
			else
				self.FORCED_TARGET = nil
			end
		end
	end,

	get_targets = function(self, range)
		self:refresh_targets(range)
		return self.TARGET_CACHE[range].enemies
	end,

	force_target = function(self)
		if self.focus_target:get_value() and self:GET_STATUS() and g_input:is_key_pressed(e_key.lbutton) and g_time - self.lastForceChange >= 0.3 then
			local target = nil
			local mousePos = g_input:get_cursor_position_game()
			local lowestDistance = std_math.huge
			local maxDistance = self.forceTargetMaxDistance:get_value() or 240
			for i, enemy in ipairs(features.entity_list:get_enemies()) do
				if xHelper:is_alive(enemy) and xHelper:is_valid(enemy) and not xHelper:is_invincible(enemy) then
					local dist = mousePos:dist_to(enemy.position)
					if dist < maxDistance and dist < lowestDistance then
						target = enemy
						lowestDistance = dist
					end
				end
			end

			if not target or (target and self.FORCED_TARGET and self.FORCED_TARGET.index == target.index) then
				self.FORCED_TARGET = nil
				self.lastForceChange = g_time
			else
				self.FORCED_TARGET = target
				self.lastForceChange = g_time
			end
		end
	end,

	draw = function(self)
		if not self:GET_STATUS() then return end
		local cache = self:get_cache(9999999)
		local forced = self:get_forced_target()

		if forced and self.focus_target:get_value() and self.draw_target:get_value() then
			-- local targetHpBarPos = forced:get_hpbar_position()
			-- local left = vec2Util:translate(targetHpBarPos, util.screenX * -0.02, util.screenY * -0.15)
			-- local right = vec2Util:translate(targetHpBarPos, util.screenX * 0.02, util.screenY * -0.15)
			-- local center = vec2Util:translate(targetHpBarPos, 0, util.screenY * -0.1)

			-- local textSize = g_render:get_text_size("FORCED", util.font, util.fontSize + 5)
			-- local boxPaddingX = util.screenX * 0.01
			-- local boxPaddingY = util.screenY * 0.01
			-- local boxSize = vec2:new(textSize.x + boxPaddingX, textSize.y + boxPaddingY)
			-- local textPos = vec2Util:translate(targetHpBarPos, textSize.x * -0.5, util.screenY * 0.125)
			-- local boxPos = vec2Util:translate(textPos, boxPaddingX * -0.5, boxPaddingY * -0.5)
			-- g_render:filled_box(boxPos, boxSize, util.Colors.solid.gray, 5)
			-- g_render:text(textPos, util.Colors.solid.cyan, "FORCED", util.font, util.fontSize + 5)
			-- g_render:filled_triangle(left, right, center, util.Colors.solid.yellow)

			-- vec3Util:drawCircle(forced.position, util.Colors.solid.magenta, 100)

			vec3Util:drawCircleFull(forced.position, util.Colors.transparent.magenta,
				objects:get_bounding_radius(forced) or 100)
		end
		if cache and cache.enemies then
			for i, data in ipairs(cache.enemies) do
				local target = features.entity_list:get_by_index(data.target.index)
				if target and self.draw_target:get_value() and target:is_visible() then
					if i == 1 and not forced then
						-- g_render:circle_3d(target.position, color:new(255, 0, 0, 55), 100, 3, 55, 1)
						vec3Util:drawCircleFull(target.position, color:new(255, 0, 0, 55),
							target:get_bounding_radius() or 100)
					end
				end

				if self.draw_weight:get_value() then
					if target.position:to_screen() ~= nil then
						g_render:text(
							vec2:new(target.position:to_screen().x + 60,
								target.position:to_screen().y - 10),
							color:new(255, 255, 255),
							data.weight.total .. "",
							nil,
							15
						)
					end
				end
			end
		end
	end,

	tick = function(self)
		if not self.ts_enabled:get_value() then return end
		self:force_target()
		self:update_forced_target()
		self:get_main_target()
	end

})


--------------------------------------------------------------------------------
-- Permashow
--------------------------------------------------------------------------------
local permashow = class({
	hotkeys_ordered = {},
	hotkeys_id = {},
	title = "PERMASHOW",
	width = 100,
	height = 100,
	dragging = false,
	drag_x = 0,
	drag_y = 0,

	add = menu.get_main_window():push_navigation("permashow", 10000),
	nav = menu.get_main_window():find_navigation("permashow"),

	ps_sec = nil,
	draw_sec = nil,

	ps_enable = false,

	x = 0,
	y = 0,

	ps_color_bg_r = 0,
	ps_color_bg_g = 0,
	ps_color_bg_b = 0,
	ps_color_bg_a = 0,

	ps_color_text_r = 0,
	ps_color_text_g = 0,
	ps_color_text_b = 0,
	ps_color_text_a = 0,

	init = function(self)
		self.ps_sec = self.nav:add_section("permashow")
		self.draw_sec = self.nav:add_section("color settings")

		self.ps_enable = self.ps_sec:checkbox("enabled", g_config:add_bool(true, "ps_enable"))

		self.x = g_config:add_int(0, "ps_x")
		self.y = g_config:add_int(0, "ps_y")
		g_config:add_int(0, "ps_x")
		self.ps_sec:slider_int("x", self.x, 0, g_render:get_screensize().x)
		g_config:add_int(0, "ps_y")
		self.ps_sec:slider_int("y", self.y, 0, g_render:get_screensize().y)

		self.ps_color_bg_r = self.draw_sec:slider_int("bg r", g_config:add_int(0, "ps_color_bg_r"), 0, 255)
		self.ps_color_bg_g = self.draw_sec:slider_int("bg g", g_config:add_int(0, "ps_color_bg_g"), 0, 255)
		self.ps_color_bg_b = self.draw_sec:slider_int("bg b", g_config:add_int(0, "ps_color_bg_b"), 0, 255)
		self.ps_color_bg_a = self.draw_sec:slider_int("bg a", g_config:add_int(180, "ps_color_bg_a"), 0, 255)

		self.ps_color_text_r = self.draw_sec:slider_int("text r", g_config:add_int(255, "ps_color_text_r"), 0, 255)
		self.ps_color_text_g = self.draw_sec:slider_int("text g", g_config:add_int(255, "ps_color_text_g"), 0, 255)
		self.ps_color_text_b = self.draw_sec:slider_int("text b", g_config:add_int(255, "ps_color_text_b"), 0, 255)
		self.ps_color_text_a = self.draw_sec:slider_int("text a", g_config:add_int(255, "ps_color_text_a"), 0, 255)
	end,

	rect = function(self, x, y, width, height)
		return {
			x = x,
			y = y,
			width = width,
			height = height
		}
	end,

	update_keys = function(self)
		local key = -1
		for _, hotkey in ipairs(self.hotkeys_ordered) do
			if #hotkey.key == 1 then
				key = e_key[string.upper(hotkey.key)]
			else
				key = e_key[hotkey.key]
			end
			local key_pressed = g_input:is_key_pressed(key)

			if hotkey.isToggle then
				if key_pressed ~= hotkey.prev_key_pressed and key_pressed then
					local time_diff = g_time - hotkey.last_update
					if time_diff >= 0.3 then
						hotkey.state = not hotkey.state
						hotkey.last_update = g_time

						-- Toggle the associated config_var
						if hotkey.config_var then
							hotkey.config_var:set_bool(not hotkey.config_var:get_bool())
						end
					end
				end
			else
				hotkey.state = key_pressed
			end
			hotkey.prev_key_pressed = key_pressed
		end
	end,

	get_state_text_and_color = function(self, hotkey)
		local state_text = hotkey.state and "[ON]" or "[OFF]"
		local state_color = hotkey.state and color:new(55, 255, 55, 255) or color:new(255, 55, 55, 255)
		return state_text, state_color
	end,

	draw = function(self)
		if not self.ps_enable:get_value() then return end

		if self.dragging then
			local pos = g_input:get_cursor_position_game()
			self.x:set_int(pos.x - self.drag_x)
			self.y:set_int(pos.y - self.drag_y)
		end

		local x = self.x:get_int()
		local y = self.y:get_int()

		local text_size = g_render:get_text_size(self.title, font, 15)
		local text_width = text_size.x + 20
		local tx = x + (self.width - text_width) / 2
		local bg_color = color:new(self.ps_color_bg_r:get_value(), self.ps_color_bg_g:get_value(),
			self.ps_color_bg_b:get_value(), self.ps_color_bg_a:get_value())
		local tx_color = color:new(self.ps_color_text_r:get_value(), self.ps_color_text_g:get_value(),
			self.ps_color_text_b:get_value(), self.ps_color_text_a:get_value())
		local count, height = 0, 0

		g_render:filled_box(vec2:new(x, self.y:get_int()), vec2:new(self.width, self.height), bg_color, 10)

		for _, hotkey in pairs(self.hotkeys_ordered) do
			if hotkey.name then
				count = count + 1
				local text = hotkey.name .. " [" .. hotkey.key .. "] "
				local size = g_render:get_text_size(text, font, 15)
				local state_size = vec2:new(40, 20)

				g_render:text(vec2:new(x + 10, y + 30 + (count - 1) * 20), tx_color, text, font, 15)

				hotkey.state_rect = self:rect(x + 10 + size.x, y + 28 + (height - 1) * 20, state_size.x, state_size.y)

				local state_text, state_color = self:get_state_text_and_color(hotkey)
				local state_x = x + 10 + size.x + (state_size.x - g_render:get_text_size(state_text, font, 15).x) / 2
				local state_y = y + 28 + (count - 1) * 20 +
					(state_size.y - g_render:get_text_size(state_text, font, 15).y) / 2
				g_render:text(vec2:new(state_x, state_y), state_color, state_text, font, 15)

				height = std_math.max(height, size.x + state_size.x)
			end
		end

		local content_height = count * 20 + 30
		if content_height > self.height then self.height = height end

		self.width = std_math.max(text_width, height + 20)

		g_render:filled_box(vec2:new(x, self.y:get_int()), vec2:new(self.width, 25),
			color:new(bg_color.r, bg_color.g, bg_color.b, 255), 10)

		g_render:text(vec2:new(tx + 10, y + 5), tx_color, self.title, font, 15)
	end,

	set_title = function(self, title)
		self.title = title -- line 1161
	end,

	tick = function(self)
		if not self.ps_enable:get_value() then
			return
		end
		local pos = g_input:get_cursor_position_game()
		if g_input:is_key_pressed(e_key.lbutton) then
			if self:is_point_inside(pos) then
				self.dragging = true
				self.drag_x = pos.x - self.x:get_int()
				self.drag_y = pos.y - self.y:get_int()
				return true
			end
			for i, hotkey in ipairs(self.hotkeys_ordered) do
				local state_text, _ = self:get_state_text_and_color(hotkey)
				local state_x = hotkey.state_rect.x + 5
				local state_y = hotkey.state_rect.y + 3
				if self:is_cursor_inside_text(pos, state_text, state_x, state_y, font, 15) then
					hotkey.state = not hotkey.state
					g_input:send_mouse_key_event(e_mouse_button.left, e_key_state.key_up)
					break
				end
			end
		else
			self.dragging = false
		end
		for _, hotkey in ipairs(self.hotkeys_ordered) do
			if hotkey.config_var then
				hotkey.state = hotkey.config_var:get_bool()
			end
		end

		self:update_keys()
	end,

	is_point_inside = function(self, point)
		return point.x >= self.x:get_int() and point.x <= self.x:get_int() + self.width and point.y >= self.y:get_int() and
			point.y <= self.y:get_int() + 25
	end,

	is_cursor_inside_text = function(self, cursorPos, text, x, y, font, fontSize)
		local textSize = g_render:get_text_size(text, font, fontSize)
		return cursorPos.x >= x and cursorPos.x <= x + textSize.x and cursorPos.y >= y and cursorPos.y <= y + textSize.y
	end,

	register = function(self, identifier, name, key, is_toggle, cfg)
		local cgf = cfg or nil
		local is_toggle = is_toggle or false
		print("enterting register")
		if self.hotkeys_id[identifier] then
			print("we already have identifier " .. identifier)
			self.hotkeys_id[identifier].name = name
			self.hotkeys_id[identifier].key = key
			self.hotkeys_id[identifier].isToggle = true
		else
			print("registering " .. identifier)
			local newHotkey = {
				identifier = identifier,
				name = name,
				key = key,
				state = false,
				labels = {},
				isToggle = is_toggle,
				config_var = cfg,
				last_update = g_time
			}
			print("inserting " .. identifier)
			table.insert(self.hotkeys_ordered, newHotkey)
			print("setting " .. identifier)
			self.hotkeys_id[identifier] = newHotkey
		end
	end,

	update = function(self, identifier, options)
		print("updating " .. identifier)
		if self.hotkeys_id[identifier] then
			if options.name then
				self.hotkeys_id[identifier].name = options.name
			end
			if options.key then
				self.hotkeys_id[identifier].key = options.key
			end
		end
	end,

})
--------------------------------------------------------------------------------
-- visualizer
--------------------------------------------------------------------------------
local visualizer = class({
	Last_cast_time = g_time,
	util = nil,
	xHelper = nil,
	math = nil,
	objects = nil,
	damagelib = nil,
	add = menu.get_main_window():push_navigation("xVisuals", 10000),
	visualizer_split_colors = nil,
	visualizer_show_combined_bars = nil,
	visualizer_show_stacked_bars = nil,
	visualizer_visualize_autos = nil,
	visualizer_autos_slider = nil,
	visualizer_visualize_q = nil,
	visualizer_visualize_w = nil,
	visualizer_visualize_e = nil,
	visualizer_visualize_r = nil,
	visualizer_show_text = nil,


	init = function(self, util, vec3_util, xHelper, math, objects, damagelib)
		self.Last_cast_time = g_time
		self.vec3_util = vec3_util
		self.xHelper = xHelper
		self.math = math
		self.util = util
		self.damagelib = damagelib
	
		if self.damagelib == nil then
			print("bad bad bad")
		end
		self.objects = objects
		-- Menus
		self.nav = menu.get_main_window():find_navigation("xVisuals")
		self.vis_sect = self.nav:add_section("visualizer")
		self.min_sect = self.nav:add_section("Minions")
		self.checkboxMinionDmg = self.min_sect:checkbox("draw Minions", g_config:add_bool(true, "MIN"))
		self.checkboxVisualDmg = self.vis_sect:checkbox("damage visual", g_config:add_bool(true, "visualize damage"))
		self.visualizer_split_colors = self.vis_sect:checkbox("^ Split colors", g_config:add_bool(true, "split_colors"))
		self.visualizer_killable_colors = self.vis_sect:checkbox("^ Killable colors", g_config:add_bool(true, "Killable_colors"))

		self.visualizer_show_combined_bars = self.vis_sect:checkbox("Show combined bars",
			g_config:add_bool(true, "show_combined_bars"))
		self.visualizer_show_stacked_bars = self.vis_sect:checkbox("Show stacked bars",
			g_config:add_bool(true, "show_stacked_bars"))
		self.visualizer_visualize_autos = self.vis_sect:checkbox("Visualize Autos",
			g_config:add_bool(true, "visualize_autos"))
		self.visualizer_autos_slider = self.vis_sect:slider_int("x", g_config:add_int(1, "autos_slider"), 1, 5, 1)
		self.visualizer_dynamic_autos = self.vis_sect:checkbox("dynamic mode", g_config:add_bool(true, "dynamic mode"))

		self.visualizer_visualize_q = self.vis_sect:checkbox("Visualize Q", g_config:add_bool(true, "visualize_q"))
		self.visualizer_visualize_w = self.vis_sect:checkbox("Visualize W", g_config:add_bool(true, "visualize_w"))
		self.visualizer_visualize_e = self.vis_sect:checkbox("Visualize E", g_config:add_bool(true, "visualize_e"))
		self.visualizer_visualize_r = self.vis_sect:checkbox("Visualize R", g_config:add_bool(true, "visualize_r"))
		self.visualizer_show_text = self.vis_sect:checkbox("Show text", g_config:add_bool(true, "visualizer_show_text"))

	end,
	
	render_damage_bar = function(self, enemy, combodmg, aadmg, qdmg, wdmg, edmg, rdmg, bar_height, yOffset)
		yOffset = yOffset or 0
		local screen = g_render:get_screensize()
		local width_offset = 0.055
		local base_x_offset = 0.43
		local base_y_offset_ratio = 0.002
		local bar_width = (screen.x * width_offset)
		local base_position = enemy:get_hpbar_position()
	
		local base_y_offset = screen.y * base_y_offset_ratio

		base_position.x = base_position.x - bar_width * base_x_offset
		
		-- console:log(" offset value:".. yOffset .. " Base Position before offset:".. base_position.y)
		base_position.y = (base_position.y - bar_height * base_y_offset) + (yOffset)
		local base_y_with_offset = (base_position.y - bar_height * base_y_offset) + (yOffset)
		-- console:log(" offset value:".. yOffset .. " Base Position after offset:".. base_y_with_offset)
	
		local function DrawDamageSection(color, damage, remaining_health)
			local damage_mod = damage / enemy.max_health
			local box_start_x = base_position.x + bar_width * remaining_health
			local box_size_x = (bar_width * damage_mod) * -1

			-- Prevent the damage bar from going beyond the left bound of the enemy HP bar
			if box_start_x + box_size_x < base_position.x then
				box_size_x = base_position.x - box_start_x
			end

			local box_start = vec2:new(box_start_x, base_position.y)
			local box_size = vec2:new(box_size_x, bar_height)
			g_render:filled_box(box_start, box_size, color)
			return remaining_health - damage_mod
		end
	
		local remaining_health = enemy.health / enemy.max_health
		if combodmg > 0 then
			-- if kill colors
			if self.visualizer_killable_colors:get_value() then
				if enemy.health < combodmg  then
					remaining_health = DrawDamageSection(self.util.Colors.transparent.red, combodmg, remaining_health)
				else
					remaining_health = DrawDamageSection(self.util.Colors.transparent.darkGreen, combodmg, remaining_health)
				end
			else	
				remaining_health = DrawDamageSection(self.util.Colors.transparent.purple, combodmg, remaining_health)
			end
		end
		if aadmg > 0 then
			remaining_health = DrawDamageSection(self.util.Colors.transparent.green, aadmg, remaining_health)
		end
		if qdmg > 0 then
			remaining_health = DrawDamageSection(self.util.Colors.transparent.lightMagenta, qdmg, remaining_health)
		end
		if wdmg > 0 then
			remaining_health = DrawDamageSection(self.util.Colors.transparent.blue, wdmg, remaining_health)
		end
		if edmg > 0 then
			remaining_health = DrawDamageSection(self.util.Colors.transparent.orange, edmg, remaining_health)
		end
		if rdmg > 0 then
			remaining_health = DrawDamageSection(self.util.Colors.transparent.red, rdmg, remaining_health)
		end
	end,
	render_stacked_bars = function(self, enemy, aadmg, qdmg, wdmg, edmg, rdmg)
		local screen = g_render:get_screensize()
		local height_offset = 0.010
		local bar_height = (screen.y * height_offset)
		local last_offset_top = -15
		local last_offset_bottom = 15

		if self.visualizer_visualize_w:get_value() then
			self:render_damage_bar(enemy, 0, 0, 0, wdmg, 0, 0, bar_height, last_offset_top)
			last_offset_top = last_offset_top - 15
		end
		if self.visualizer_visualize_q:get_value() then
			self:render_damage_bar(enemy, 0, 0, qdmg, 0, 0, 0, bar_height, last_offset_top)
			last_offset_top = last_offset_top - 15
		end
		if self.visualizer_visualize_autos:get_value() then
			self:render_damage_bar(enemy, 0, aadmg, 0, 0, 0, 0, bar_height, 0)
		end
		if self.visualizer_visualize_e:get_value() then
			self:render_damage_bar(enemy, 0, 0, 0, 0, edmg, 0, bar_height, last_offset_bottom)
			last_offset_bottom = last_offset_bottom + 15
		end
		if self.visualizer_visualize_r:get_value() then
			self:render_damage_bar(enemy, 0, 0, 0, 0, 0, rdmg, bar_height, last_offset_bottom)
			last_offset_bottom = last_offset_bottom + 15
		end
	end,

	render_combined_bars = function(self, enemy, aadmg, qdmg, wdmg, edmg, rdmg)
		local screen = g_render:get_screensize()
		local height_offset = 0.010
		local bar_height = (screen.y * height_offset)
		if not self.visualizer_visualize_autos:get_value() then
			aadmg = 0
		end
		if not self.visualizer_visualize_q:get_value() then
			qdmg = 0
		end
		if not self.visualizer_visualize_w:get_value() then
			wdmg = 0
		end
		if not self.visualizer_visualize_e:get_value() then
			edmg = 0
		end
		if not self.visualizer_visualize_r:get_value() then
			rdmg = 0
		end
		local combodmg = aadmg + qdmg + wdmg + edmg + rdmg


		if self.visualizer_split_colors:get_value() then
			self:render_damage_bar(enemy, 0, aadmg, qdmg, wdmg, edmg, rdmg, bar_height, 0)
		else
			self:render_damage_bar(enemy, combodmg, 0, 0, 0, 0, 0, bar_height, 0)
		end
	end,
	display_killable_text = function(self, enemy, nmehp, aadmg, qdmg, wdmg, edmg, rdmg)
		local pos = enemy.position
		if pos:to_screen() ~= nil then
			local spells_text = ""
			local killable_text = ""

			local autos_to_kill = std_math.ceil(nmehp / aadmg)
			if nmehp <= aadmg then
				killable_text = "AA Kill"
			elseif nmehp <= qdmg then
				killable_text = "Q Kill"
			elseif nmehp <= wdmg then
				killable_text = "W Kill"
			elseif nmehp <= edmg then
				killable_text = "E Kill"
			elseif nmehp <= rdmg then
				killable_text = "R Kill"
			elseif nmehp <= qdmg + wdmg + edmg + rdmg then
				killable_text = "Combo Kill"
				if self.visualizer_visualize_q:get_value() then
					spells_text = "Q"
				end
				if self.visualizer_visualize_w:get_value() then
					spells_text = spells_text .. (spells_text ~= "" and " + " or "") .. "W"
				end
				if self.visualizer_visualize_e:get_value() then
					spells_text = spells_text .. (spells_text ~= "" and " + " or "") .. "E"
				end
				if self.visualizer_visualize_r:get_value() then
					spells_text = spells_text .. (spells_text ~= "" and " + " or "") .. "R"
				end
			else
				if self.objects:can_cast(e_spell_slot.q) and self.visualizer_visualize_q:get_value() then
					autos_to_kill = std_math.ceil((nmehp - qdmg) / aadmg)
					spells_text = "Q"
				end
				if self.objects:can_cast(e_spell_slot.w) and self.visualizer_visualize_w:get_value() then
					autos_to_kill = std_math.ceil((nmehp - wdmg) / aadmg)
					spells_text = (spells_text ~= "" and " + " or "") .. "W"
				end
				if self.objects:can_cast(e_spell_slot.e) and self.visualizer_visualize_e:get_value() then
					autos_to_kill = std_math.ceil((nmehp - edmg) / aadmg)
					spells_text = (spells_text ~= "" and " + " or "") .. "E"
				end
				if self.objects:can_cast(e_spell_slot.r) and self.visualizer_visualize_r:get_value() then
					autos_to_kill = std_math.ceil((nmehp - rdmg) / aadmg)
					spells_text = (spells_text ~= "" and " + " or "") .. "R"
				end
				killable_text = spells_text ..
				(spells_text ~= "" and " + " or "") .. tostring(autos_to_kill) .. " AA to kill"
			end
			if killable_text ~= "" then
				killable_text = killable_text:gsub("^%s*+", "")
				local killable_pos = vec2:new(pos:to_screen().x, pos:to_screen().y - 80)
				g_render:text(killable_pos, color:new(255, 255, 255), killable_text, font, 30)
			end
		end
	end,
	get_damage_array = function(self, enemy)
	
		local base_auto_dmg = self.damagelib:calc_aa_dmg(g_local, enemy)
		local aadmg = 0
		local qdmg = 0
		local wdmg = 0
		local edmg = 0
		local rdmg = 0
	
		-- Introduce the dynamic auto attack calculation
		local num_autos = self.visualizer_autos_slider:get_value()
		if self.visualizer_dynamic_autos:get_value() then 
			local distance = self.vec3_util:distance(g_local.position, enemy.position)
			local slope = 0.001538
			num_autos = 3 + slope * (distance - 850)
		end
	
		-- Calculate the total auto damage based on the number of autos
		local aadmg = base_auto_dmg * num_autos
	
		-- Calculate damage for other abilities
		if self.objects:can_cast(e_spell_slot.q) then
			qdmg = self.damagelib:calc_spell_dmg("Q", g_local, enemy, 1, self.objects:get_spell_level(e_spell_slot.q))
		end
		if self.objects:can_cast(e_spell_slot.w) then
			wdmg = self.damagelib:calc_spell_dmg("W", g_local, enemy, 1, self.objects:get_spell_level(e_spell_slot.w))
		end
		if self.objects:can_cast(e_spell_slot.e) then
			edmg = self.damagelib:calc_spell_dmg("E", g_local, enemy, 1, self.objects:get_spell_level(e_spell_slot.e))
		end
		if self.objects:can_cast(e_spell_slot.r) then
			rdmg = self.damagelib:calc_spell_dmg("R", g_local, enemy, 1, self.objects:get_spell_level(e_spell_slot.r))
		end
	
		return aadmg, qdmg, wdmg, edmg, rdmg
	end,
	
	Visualize_damage = function(self, enemy)
		local nmehp = enemy.health
		local aadmg, qdmg, wdmg, edmg, rdmg = self:get_damage_array(enemy)

		-- combined bars
		if self.visualizer_show_combined_bars:get_value() then
			self:render_combined_bars(enemy, aadmg, qdmg, wdmg, edmg, rdmg)
		end
		-- stacked bars
		if self.visualizer_show_stacked_bars:get_value() then
			self:render_stacked_bars(enemy, aadmg, qdmg, wdmg, edmg, rdmg)
		end
		-- killable text
		if self.visualizer_show_text:get_value() then
			self:display_killable_text(enemy, nmehp, self.damagelib:calc_aa_dmg(g_local, enemy), qdmg, wdmg, edmg, rdmg)
		end
	end,
	drawMins = function(self)
		local MinionInRange = self.objects:get_enemy_minions(1500)
		for _, obj_min in pairs(MinionInRange) do
			if obj_min and obj_min:is_minion() then
				local color = nil
				local aa = self.damagelib:calc_aa_dmg(g_local, obj_min)
				local real_hp = obj_min.health
				local delay = self.objects:get_aa_travel_time(obj_min) + 0.35
				local pred_hp = features.prediction:predict_health(obj_min, delay, true)
				local dying = pred_hp < 1
				local has_damage_incoming = pred_hp == real_hp
				local can_kill = pred_hp <= aa
				local soon_kill = pred_hp <= aa + aa and has_damage_incoming and pred_hp > aa

				if can_kill then
					if has_damage_incoming then
						if dying then
							color = self.util.Colors.solid.red
						else
							color = self.util.Colors.solid.green
						end
					else
						color = self.util.Colors.solid.blue
					end
				elseif soon_kill then
					if has_damage_incoming then
						color = self.util.Colors.solid.red
					else
						color = self.util.Colors.solid.yellow
					end
				else
					color = self.util.Colors.solid.white
				end
				-- draw 3d circl of color on minion
				if color then
					g_render:circle_3d(obj_min.position, color, 35, 2, 50, 1)
				end
			end
		end
	end,
	draw = function(self)
		if self.checkboxVisualDmg:get_value() then
			
			for i, enemy in pairs(features.entity_list:get_enemies()) do
				if enemy and self.xHelper:is_alive(enemy) and enemy:is_visible() and g_local.position:dist_to(enemy.position) < 3000 then
					self:Visualize_damage(enemy)
				end
			end
		end
		if self.checkboxMinionDmg:get_value() then
			self:drawMins()
		end
	end,
	register = function(self, identifier, name, key, is_toggle, cfg)
		-- Implementation goes here
	end,
})

--------------------------------------------------------------------------------
-- debug
--------------------------------------------------------------------------------
local debug = class({
	add = menu.get_main_window():push_navigation("xVisuals", 10000),
	nav = menu.get_main_window():find_navigation("xVisuals"),
	util = nil,
	Colors = nil,


	init = function(self, util)
		self.util = util
		self.Colors = util.Colors
		self.Last_dbg_msg_time = g_time
		self.LastMsg = "init"
		self.LastMsg1 = "init"
		self.LastMsg2 = "init"

		self.dbg_sec = self.nav:add_section("spacer")
		self.dbg_sec = self.nav:add_section("debug")
		--self.draw_sec = self.nav:add_section("color settings")
		self.dbg_enable = self.dbg_sec:checkbox("enabled", g_config:add_bool(true, "dbg_enable"))

		Res = g_render:get_screensize()
		local dbg_lvl = 0
		local posX = (Res.x / 2) - 100
		local posY = Res.y - 260

		self.Debug_level = g_config:add_int(dbg_lvl, "dbglvl")

		self.x = g_config:add_int(posX, "ps_x")
		self.y = g_config:add_int(posY, "ps_y")

		g_config:add_int(dbg_lvl, "dbglvl")
		self.dbg_sec:slider_int("Debuglvl", self.Debug_level, 0, 6)
		g_config:add_int(posX, "ps_x")
		self.dbg_sec:slider_int("x", self.x, 0, Res.x)
		g_config:add_int(posY, "ps_y")
		self.dbg_sec:slider_int("y", self.y, 0, Res.y)
	end,

	Print = function(self, str, level)
		level = level or 1
		str = tostring(str)

		if level <= self.Debug_level:get_int() then
			print("log: " .. " " .. str)
			if str ~= self.LastMsg then
				self.Last_dbg_msg_time = g_time
				self.LastMsg2 = self.LastMsg1
				self.LastMsg1 = self.LastMsg
				self.LastMsg = str
			end
		end
		if g_time == -1 then
			self.Last_dbg_msg_time = g_time - 15
			self.LastMsg2 = ""
			self.LastMsg1 = ""
			self.LastMsg1 = "bad g_time"
		end
	end,

	draw = function(self)
		local pos = vec2:new((Res.x / 2) - 100, Res.y - 260)
		local pos1 = vec2:new((Res.x / 2) - 100, Res.y - 290)
		local pos2 = vec2:new((Res.x / 2) - 100, Res.y - 320)
		if self.Last_dbg_msg_time == -1 then
			g_render:text(pos, self.Colors.solid.white, "bad g_time", font, 30)
			return false
		end                                                -- skip bad time
		if g_time - self.Last_dbg_msg_time >= 10 then return end -- fade out



		g_render:text(pos, self.Colors.solid.white, self.LastMsg, font, 30)
		g_render:text(pos1, self.Colors.solid.white, self.LastMsg1, font, 30)
		g_render:text(pos2, self.Colors.solid.white, self.LastMsg2, font, 30)
	end

})

--------------------------------------------------------------------------------
-- utils
-------------------------------------------------------------------------------

local utils = class({
	XutilMenuCat = nil,
	add = menu.get_main_window():push_navigation("xUtils", 10000),
	nav = menu.get_main_window():find_navigation("xUtils"),
	dancing = false,
    new_click = nil,
    intersect1 = nil,
    intersect2 = nil,
    midpoint = nil,
    


	init = function(self,vec3_util, util, xHelper, math, objects, damagelib, debug, permashow, target_selector)
		self.helper = xHelper
		self.math = math
		self.util = util
		self.damagelib = damagelib
		self.objects = objects
		self.debug = debug
		self.permashow = permashow
		self.vec3_util = vec3_util
		self.target_selector = target_selector
		self.dancing = false
		self.cancel = true
        self.bad_turret = nil
        self.apm_limiter = g_time
		-- -- Menus -- -- 
		-- add menu for xUtils sect

			
		self.nav = menu.get_main_window():find_navigation("xUtils")
		self.anti_turret_walker = self.nav:add_section("anti turret walker")

        self.checkboxAntiTurretTechGlobal_cfg = g_config:add_bool(false, "deny_turret_walking")
		self.checkboxAntiTurretTechGlobal = self.anti_turret_walker:checkbox("deny turret walking into turrets [beta]", self.checkboxAntiTurretTechGlobal_cfg)
		self.checkboxAntiTurretTechHarass = self.anti_turret_walker:checkbox("^ in harass", g_config:add_bool(true, "deny_turret_walking_harass"))
		self.checkboxAntiTurretTechCombo = self.anti_turret_walker:checkbox("^ in combo", g_config:add_bool(false, "deny_turret_walking_combo"))

        self.checkboxDrawTurretPrioDraws = self.anti_turret_walker:checkbox("draw turret walker draws", g_config:add_bool(true, "draw_turret_walker")) 
        self.checkboxDrawTurretPrioDebugs = self.anti_turret_walker:checkbox("draw turret debug draws", g_config:add_bool(true, "draw_turret_walker_dbg")) 

		-- draw turret prio
		self.other = self.nav:add_section("misc")

		self.checkboxDrawTurretPrio = self.other:checkbox("draw turret prio", g_config:add_bool(true, "draw_turret_prio")) 


	end,
	clear = function(self)
        if not self.dancing then return false end
        
            Prints("no longer dancing --> allowing movement")
			features.orbwalker:allow_movement(true)
			self.dancing = false
            self.intersection1 = nil
            self.intersection2 = nil
            self.midpoint = nil
            self.new_click = nil
			return false 
	end,
	force_move = function(self)


		if self.dancing and self.new_click then
            if self.bad_turret then 
                local turret_pos = self.bad_turret.position
                local radius = 870 + g_local:get_bounding_radius()
                
                local path_end = g_input:get_cursor_position_game()
                if not self.vec3_util:isPointInsideCircle(path_end, turret_pos, radius-40) then
                    
                    Prints("path end not in thing anymore but still dancing wild")
                    self:clear()
                end
            end
            -- apm limiter is the last time we clicked, if we clicked recently then dont click again
            if g_time - self.apm_limiter < 00.5 then Prints("apm skip") return false end
            self.apm_limiter = g_time
			Prints("force moving to a new click",1)
            if self.new_click then g_input:issue_order_move(self.new_click) end
		end
	end,
    cancel_move = function(self, e)
        if self.dancing and self.new_click and self.bad_turret then 

            local should_deny_turret =
            (get_menu_val(self.checkboxAntiTurretTechGlobal) and not get_menu_val(self.checkboxAntiTurretTechHarass) and not get_menu_val(self.checkboxAntiTurretTechCombo)) or
            (get_menu_val(self.checkboxAntiTurretTechHarass) and self.helper:get_mode() == mode.Harass_key) or
            (get_menu_val(self.checkboxAntiTurretTechCombo) and self.helper:get_mode() == mode.Combo_key)

            local ai_man = g_local:get_ai_manager()
            local path_end = ai_man.path_end

            if should_deny_turret and g_local.position and self.bad_turret.position and self.vec3_util:distance(g_local.position, self.bad_turret.position) < 950 and self.helper:is_under_turret(path_end) then
                Prints("canceling move")
                e:cancel()
            end
        end
    end,
	deny_turret_harass = function(self, e)
        
		if not get_menu_val(self.checkboxAntiTurretTechGlobal) then return false end
		-- self.new_click = nil
		local ai_man = g_local:get_ai_manager()
		local path = g_local:get_ai_manager().path
		local mouse_pos = g_input:get_cursor_position_game()

        local should_deny_turret =
        (get_menu_val(self.checkboxAntiTurretTechGlobal) and not get_menu_val(self.checkboxAntiTurretTechHarass) and not get_menu_val(self.checkboxAntiTurretTechCombo)) or
        (get_menu_val(self.checkboxAntiTurretTechHarass) and self.helper:get_mode() == mode.Harass_key) or
        (get_menu_val(self.checkboxAntiTurretTechCombo) and self.helper:get_mode() == mode.Combo_key)
        
        local nearest_enemy_turret = self.helper:get_nearest_turret()
        if not nearest_enemy_turret  then return false end
        self.bad_turret = nearest_enemy_turret
        local turret_pos = nearest_enemy_turret.position
        
        if not should_deny_turret  or self.vec3_util:distance(g_local.position, turret_pos) > 1000 then 
            if self.dancing then
                Prints("should not deny and not dancing so...")
                self:clear()
            end
            return false 
        end

        local radius = 870
        
        local line_start = self.vec3_util:extend(g_local.position,turret_pos, g_local:get_bounding_radius()+15)
        local line_end = self.vec3_util:extend(g_local.position, mouse_pos, self.vec3_util:distance(g_local.position, mouse_pos))

        local does_intersect, point1, point2  = self.vec3_util:doesLineIntersectCircle(line_start, line_end, turret_pos, radius)
        local mouse_within = self.vec3_util:distance(mouse_pos, turret_pos) < 1600
        local player_within = self.vec3_util:distance(g_local.position, turret_pos) < 4000
    
        if (does_intersect or mouse_within or player_within) and point1 then
            self.intersection1 = point1
            self.intersection2 = point2
            self.new_click = nil
            --cleared     
            self.dancing = true
            features.orbwalker:allow_movement(false)              

            local safe_spoot = self.vec3_util:avoid_circle_by_closest_tangent(g_local.position, turret_pos, radius, mouse_pos, 0)
            if safe_spoot then
                self.new_click = safe_spoot
            end


            if self.helper:is_under_turret(g_local.position) then
                -- can we vector this slightly towards the mouse i wonder?
                local self_vector = self.vec3_util:extend(turret_pos, g_local.position, radius+145)
                local mouse_vector = self.vec3_util:extend(turret_pos, mouse_pos, radius+145)
        
                local angled_vector = self.vec3_util:midpoint(self_vector, mouse_vector)
                self.new_click = angled_vector
            end
        else
            -- Prints("no intersect")
        end

    end,
	draw = function (self)	
        if get_menu_val(self.checkboxDrawTurretPrioDraws) then
            local ai_man = g_local:get_ai_manager()
            local path_end = ai_man.path_end
            
            if self.new_click and self.dancing then
                -- draw new click
                self.vec3_util:drawLine(g_local.position, self.new_click, self.util.Colors.solid.green, 2)
                self.vec3_util:drawCircleFull(self.new_click, self.util.Colors.solid.green, 35)
                if get_menu_val(self.checkboxDrawTurretPrioDebugs) then

                    --draw intersect 1
                    if self.intersection1 then
                        self.vec3_util:drawCircleFull(self.intersection1, self.util.Colors.solid.red, 15)
                    end
                    --draw intersect 2
                    if self.intersection2 then
                        self.vec3_util:drawCircleFull(self.intersection2, self.util.Colors.solid.red, 15)
                    end
                    --draw line between intersects
                    if self.intersection1 and self.intersection2 then
                        self.vec3_util:drawLine(self.intersection1, self.intersection2, self.util.Colors.solid.red, 2)
                    end


                    -- pathed
                    self.vec3_util:drawLine(g_local.position, path_end, self.util.Colors.solid.blue, 2)
                    self.vec3_util:drawCircleFull(path_end, self.util.Colors.solid.blue, 35)

                    if top then
                        self.vec3_util:drawCircleFull(top, self.util.Colors.solid.red, 35)
                        self.vec3_util:drawLine(top, g_local.position, self.util.Colors.solid.red, 2)
                    end
                    if mid then 
                        self.vec3_util:drawCircleFull(mid, color:new(128, 255, 255), 35)
                    end
                    
                    if bot then
                        self.vec3_util:drawCircleFull(bot, color:new(128, 255, 255), 35)
                    end
                end
            end

        end

		-- if turret prio

		if self.checkboxDrawTurretPrio:get_value() then	
			for _, v in ipairs(features.entity_list:get_ally_turrets()) do
				local turret = v
				-- print turret dist to me and my attack range
				  
				if v and not v:is_dead() and not v:is_invisible() then 
					local dist = g_local.position:dist_to(turret.position)
					local myatkrange = g_local.attack_range+350
					-- Prints("dist: " .. std_math.floor(dist) .. "/" .. myatkrange, 1)	
				end
				if turret and turret.position and turret.position:dist_to(g_local.position) < g_local.attack_range+350 then
				  local minions = self.objects:get_enemy_minions(860, turret.position)
				  if #minions > 0 then 
					local sorted = self.objects:get_ordered_turret_targets(turret, minions)
					for i, minion in ipairs(sorted) do
				
					  self.vec3_util:drawText(i, minion.position, util.Colors.solid.lightCyan, 30)
					end
				  end
				end
			  end
		end

	end
})


--------------------------------------------------------------------------------

-- Callbacks

--------------------------------------------------------------------------------

local x = class({
	VERSION = "1.0",
	vec2_util = vec2Util,
	vec3_util = vec3Util,
	util = util:new(),
	permashow = permashow:new(),
	buffcache = buffcache:new(),
	helper = xHelper:new(vec3Util, buffcache),
	math = math:new(xHelper, buffcache),
	database = database:new(xHelper),
	objects = objects:new(xHelper, math, database, util),
	damagelib = damagelib:new(xHelper, math, database, buffcache),
	visualizer = visualizer:new(util, vec3Util, xHelper, math, objects, damagelib),
	debug = debug:new(util),
	target_selector = target_selector:new(xHelper, math, objects, damagelib),
	utils = utils:new(vec3Util, util, xHelper, math, objects, damagelib, debug, permashow, target_selector),

	init = function(self)
		features.orbwalker:allow_movement(true)
		print("=-=--=-=-=-=-==-=--==-=-=--=-==--==-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-=--=-")
		local idk = self.damagelib ~= nil
		print("X core loaded: " .. tostring(idk))


        self.permashow:register("anti Turret walker", "Anti turret walker", "N", true, utils.checkboxAntiTurretTechGlobal_cfg)


		cheat.on("features.pre_run", function()
			self.target_selector:tick()
		end)

		cheat.on("renderer.draw", function()
			self.permashow:draw()
			self.debug:draw()
			self.target_selector:draw()
			self.visualizer:draw()
			self.utils:draw()
		end)

		cheat.on("features.run", function()
			self.permashow:tick()
			self.utils:force_move()
		end)
        cheat.on("local.issue_order_move", function(e)
			self.utils:cancel_move(e)
		end)
		cheat.on("features.orbwalker", function(e)
			self.utils:deny_turret_harass(e)
		end)

	end,

})

-- print("-==--=-=-=-= X core Updater: =--=-=-==--=-=-=-=-=")
check_for_update(x)
return x
