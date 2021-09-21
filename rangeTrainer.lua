rt = {}
rt.version = 0.1
rt.updateRate = 0.05
rt.debug = true
rt.trackedWeapons = {}

local resultsTable = {}
local resultsInterval = 5


rt.shooter = {"shooter-1"}
rt.targets = {"target-1", "target-2"}


local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "rt_Debug: " .. tostring(message)
    if rt.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

local function notify(message, duration) --used this so often now... 
    trigger.action.outText(tostring(message), duration)
    env.info("rt_Notify: " .. tostring(message), false)
end


--from weapons_damage

local function getDistance(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1-x2)
    local dZ = math.abs(z1-z2)
    local distance = math.sqrt(dX*dX + dZ*dZ)
    return distance
  end
  
  local function getDistance3D(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1-x2)
    local dY = math.abs(y1-y2)
    local dZ = math.abs(z1-z2)
    local distance = math.sqrt(dX*dX + dZ*dZ + dY*dY)
    return distance
  end

local function vec3Mag(speedVec)

	mag = speedVec.x*speedVec.x + speedVec.y*speedVec.y+speedVec.z*speedVec.z
	mag = math.sqrt(mag)
	--trigger.action.outText("X = " .. speedVec.x ..", y = " .. speedVec.y .. ", z = "..speedVec.z, 10)
	--trigger.action.outText("Speed = " .. mag, 1)
	return mag

end

local function lookahead(speedVec)

	speed = vec3Mag(speedVec)
	dist = speed * rt.updateRate * 1.5 
	return dist

end

local function isInitatorValid(iniUnitName)
    for index, unitName in pairs (rt.shooter) do
        if unitName == iniUnitName then 
            return true
        end
    end
    return false
end

local function getClosestTargetAndDistance(vec3)
    local target = "null" --not sure
    local distance = 9999999999 --ugly but works

    for index, targetName in pairs (rt.targets) do
        local _tgtVec3 = Unit.getByName(targetName):getPoint()
        local _dist = getDistance3D(vec3, _tgtVec3)
            if _dist <= distance then 
                target = targetName
                distance = _dist
            end
    end
    distance = math.floor ( distance + 0.5 )
    return target, distance
end

local function track_wpns()
    --  env.info("Weapon Track Start")
        for wpn_id_, wpnData in pairs(rt.trackedWeapons) do   
            if wpnData.wpn:isExist() then  -- just update speed, position and direction.
                wpnData.pos = wpnData.wpn:getPosition().p
                wpnData.dir = wpnData.wpn:getPosition().x
                wpnData.speed = wpnData.wpn:getVelocity()
          --wpnData.lastIP = land.getIP(wpnData.pos, wpnData.dir, 50)
            else -- wpn no longer exists, must be dead.
    --      trigger.action.outText("Weapon impacted, mass of weapon warhead is " .. wpnData.exMass, 2)
                local ip = land.getIP(wpnData.pos, wpnData.dir, lookahead(wpnData.speed))  -- terrain intersection point with weapon's nose.  Only search out 20 meters though.
                local impactPoint
                if not ip then -- use last calculated IP
                    impactPoint = wpnData.pos
        --      	trigger.action.outText("Impact Point:\nPos X: " .. impactPoint.x .. "\nPos Z: " .. impactPoint.z, 2)
                else -- use intersection point
                    impactPoint = ip
        --        trigger.action.outText("Impact Point:\nPos X: " .. impactPoint.x .. "\nPos Z: " .. impactPoint.z, 2)
                end
                
                --trigger.action.smoke(impactPoint, 0)
                wpnData.ip = impactPoint
                resultsTable[wpn_id_] = wpnData
                rt.trackedWeapons[wpn_id_] = nil -- remove from tracked weapons first.         
            end
        end
    --env.info("Weapon Track End")
    timer.scheduleFunction( track_wpns , {} , timer.getTime() + rt.updateRate )
end

local function notifyResults()
    local outString = nil
    local weaponName = ""
    local weaponCount = 0
    local closeDist = 9999999
    local farDist = 0
    local tgtName = ""
    local impactSeparation = 9999999
    local launchSeparation = 9999999

    for wpnId, wpnData in pairs (resultsTable) do --get closest hit, furthest miss, launch and impact separation from the target
        weaponCount = weaponCount + 1
        local _targetName, _distanceFromTgt = getClosestTargetAndDistance(wpnData.ip)
        local _launchDist = math.floor ( 0.5 + getDistance3D ( Unit.getByName(_targetName):getPoint(), wpnData.shooterVec3Init ) )
        local _finalDist  = math.floor ( 0.5 + getDistance3D ( Unit.getByName(_targetName):getPoint(), wpnData.shooter:getPoint() ) )

        if _distanceFromTgt >= farDist then
            farDist = _distanceFromTgt
        end

        if _distanceFromTgt <= closeDist then --smaller is better
            closeDist = _distanceFromTgt
        end

        if _launchDist <= launchSeparation then --larger is better (more standoff)
            launchSeparation = _launchDist
        end

        if _finalDist <= impactSeparation then --larger is better (more standoff)
            impactSeparation = _finalDist
        end
        
        tgtName = _targetName --really... 
        weaponName = wpnData.name
    end

    if weaponCount >= 1 then --build outString
        outString = "RESULTS:"
        outString = outString .. "\n____fired " .. weaponCount .. "x " .. weaponName .. " at " .. tgtName
        outString = outString .. "\n____launch distance: " .. launchSeparation .. "; impact separation: " .. impactSeparation
        outString = outString .. "\n____cloest impact: " .. closeDist .. "; furthest impact: " .. farDist
    end

    if outString then
        notify(outString, 10)
    end
    
    resultsTable = {}
    return timer.getTime() + resultsInterval
end

function rt.eventHandler (event)
    --debug (event.id)
    if event.id == 1 then --shot event

        if isInitatorValid(event.initiator:getName()) then

            local weaponId = event.weapon.id_
            local _params = {
                wpn = event.weapon,
                init = event.initiator:getName(),
                pos = event.weapon:getPoint(),
                dir = event.weapon:getPosition().x,
                name = event.weapon:getTypeName(),
                speed = event.weapon:getVelocity(),
                shooter = event.initiator,
                shooterVec3Init = event.initiator:getPoint(),
                timeInit = event.time,
            }

            rt.trackedWeapons[weaponId] = _params
            
        end
    end
    if event.id == 23 then --shooting start
        --debug(event.target:getName()) --see what it says
    end
end


local function protectedCall(...) --from splash_damage
    local status, retval = pcall(...)
    if not status then
        env.warning("rangeTrainer.lua script errors caught!" .. retval, false)
    end
end

rangeHandler = {} --eventhandler
function rangeHandler:onEvent(event)
    protectedCall(rt.eventHandler, event)
end

do
    timer.scheduleFunction( track_wpns , {} , timer.getTime() + rt.updateRate )
    timer.scheduleFunction( notifyResults , {} , timer.getTime() + resultsInterval )
    world.addEventHandler(rangeHandler)
    debug("rangeTrainer.lua version: " .. rt.version .. " initiated")
end