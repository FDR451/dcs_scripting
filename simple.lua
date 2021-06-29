--[[
    simple.lua
    a small personal scripting liberary
]]

simple = {}
simple.debug = false

function simple.notify(message, duration) --used this so often now... 
    trigger.action.outText(tostring(message), duration)
    env.info("Notify: " .. tostring(message), false)
end

function simple.debugOutput(message)
    local _outputString = "Debug: " .. tostring(message)
    if simple.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function simple.errorOutput(message)
    local _outputString = "ERROR: " .. tostring(message)
    trigger.action.outText(tostring(_outputString), 300)
    env.error(_outputString, false)
end

function simple.smokeVec3 (vec3) --puts smoke at vec3 for debugging
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

function simple.printVec3 (vec3) --prints a vec3 to the message box
    trigger.action.outText("vec3.x: " .. vec3.x .. " ; vec3.y: " .. vec3.y .. " ; vec3.z: " .. vec3.z, 5)
end

function simple.getAltitudeAgl (vec3) --returns the altitude AGL of a given vec3
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    local output = vec3.y - _vec3GL.y
    --simple.debugOutput ("getAltitudeAgl: altitude is " .. output .. "m AGL.")
    return output
end

function simple.getAngle (vec3From, vec3To)
    local _angleR = math.atan2 (vec3To.z - vec3From.z, vec3To.x - vec3From.x)-- - math.atan2 (vec3To.z, vec3To.x)
    if _angleR < 0 then
        _angleR = _angleR + 2 * math.pi
    end
    --local _angleD = math.deg (_angleR)
    return _angleR
end

function simple.getCompassDirection (vec3From, vec3To) --returns a string of the cardinal direction
    local _compassDir = nil
    local _angleD = math.deg ( simple.getAngle(vec3From, vec3To) )
    if _angleD >= 23 and _angleD <=68 then --NE
        _compassDir = "north-east"
    elseif _angleD >= 69 and _angleD <= 113 then --E
        _compassDir = "east"
    elseif _angleD >= 114 and _angleD <= 158 then --SE
        _compassDir = "south-east"
    elseif _angleD >= 159 and _angleD <= 203 then --S
        _compassDir = "south"
    elseif _angleD >= 204 and _angleD <= 248 then --SW
        _compassDir = "south-west"
    elseif _angleD >= 249 and _angleD <= 293 then --W
        _compassDir = "west"
    elseif _angleD >= 294 and _angleD <= 338 then -- NW
        _compassDir = "north-west"
    else --N
        _compassDir = "north"
    end
    return _compassDir
end

function simple.getTblLenght (table) --works for keyed tables where #table would not work
    local _tblLenght = 0
    for k, v in pairs (table) do
        _tblLenght = _tblLenght + 1
    end
    return _tblLenght
end

local function dump(table) --https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
	if type(table) == 'table' then
	   local s = '{ \n'
  
	   for k,v in pairs(table) do
		  if type(k) ~= 'number' then
			  k = '"'..k..'"'
		  end
		  s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
	   end
  
	   return s .. '}'
	else
	   return tostring(table)
	end
end

function simple.dumpTable(table) --call this to dumb a table
	env.info("dumpTable: \n" .. dump(table))
end

do
    simple.debugOutput("simple.lua loaded")
end