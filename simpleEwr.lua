--[[
    simpleEwr v0.0.1 Lightweight simple EWR script

    todo:
        eventhandler to remove destroyed targets from the knownTargets table
        autmatic clean up of targets that have not been seen for x minutes, not sure if it is either worth it or useful

]]

simpleEwr = {}
simpleEwr.ewrUnitList = {} --{"EWR-1", "EWR-2"}
simpleEwr.knownTargets = {} --table of known targets
simpleEwr.clockTiming = 6 --tiem between checks, lower interval higher workload
simpleEwr.detectionZone = false --false until set
simpleEwr.detectionFlag = false --false until set

--setup functions

function simpleEwr.start() --starts simpleEWR
end

function simpleEwr.stop() --maybe?
end

function simpleEwr.addEwrByName (unitName) --main function for adding units to the table
    if Unit.getByName(unitName) then --existing unit
        table.insert(simpleEwr.ewrUnitList, unitName)
        simpleMisc.debugOutput("Added " .. unitName .. " to ewrUnitList. New ewrUnitList lenght is " .. #simpleEwr.ewrUnitList)
    else --unit does not exist
        simpleMisc.errorOutput("Tried to add a unit to simpleEwr that does not exist. unitName: " .. unitName .. " has not been added to the table!")
    end
end

function simpleEwr.addEwrByPrefix (prefix) --works, needs a check if the unit is on position 1 of the group
    for unitName, unit in pairs(mist.DBs.unitsByName) do

        local _pos = string.find(unitName, prefix, 1, true)
		--somehow the MIST unit db contains StaticObject, we check to see we only add Unit
        
		if _pos and _pos == 1 then --no idea, stolen from skynet
			simpleEwr.addEwrByName(unitName)
		end
    
    end
end

function simpleEwr.addEwrByTable (unitNameTable) --adds EWRs as a table ie: table = {"EWR-1", "EWR-2", "EWR-n"}
    for k, v in pairs (unitNameTable) do 
        simpleEwr.addEwrByName(v)
    end
end

function simpleEwr.setUpdateInterval (seconds) --sets the interval for the repeated detection check
    simpleEwr.clockTiming = seconds
end

function simpleEwr.setDetectionFlag (flagNumber) --sets the flag that should be used after a detection event
    simpleEwr.detectionFlag = flagNumber
end

function simpleEwr.setDetectionZone (groupName)
    simpleEwr.detectionZone = mist.getGroupPoints(groupName)
end

--logic functions

function simpleEwr.getKnownTargets() -- returns the table of known targets, might be useful for the dispatcher
    return simpleEwr.knownTargets
end

function simpleEwr.ewrDetectTargets () --iterates through the table of EWRs and checks if they detect something, if they detect an aircraft it gets handed off to
    for k, vEwrUnit in pairs (simpleEwr.ewrUnitList) do
        local _targets = Unit.getByName(vEwrUnit):getController():getDetectedTargets(Controller.Detection.Radar)
        if _targets then
            for i = 1, #_targets do

                if _targets[i].object and _targets[i].distance == true then

                    local _object = _targets[i].object

                    if _object:getCoalition() == 2 then

                        local args = {
                            objectId = _object.id_,
                            unitName = _object:getName(),
                            unitPosVec3 = _object:getPoint(),
                            unitVelVec3 = _object:getVelocity(),
                            detectionTime = timer.getTime(),
                            inZone = simpleEwr.isVecInZone(_object:getPoint()),

                            --probalby not saved here, no reason to run the calculation every time a target is detected. Just run it once it is needed for the intercept based on the last known position and heading
                            unitSpeed = mist.vec.mag(_object:getVelocity()), --speed in m/s
                            unitHeading = math.atan2 (_object:getVelocity().x, _object:getVelocity().z), 
                        }

                        simpleEwr.knownTargets[args.objectId] = args
                    end
                end
            end
        end
    end
end

function simpleEwr.decider() --checks if a detected target is inside of the detection zone
    for index, vTargetTable in pairs (simpleEwr.knownTargets) do
        if vTargetTable.inZone == true then
            simpleMisc.debugOutput("Decider: Found target in detectionZone, setting flag " .. simpleEwr.detectionFlag .. " to TRUE")
            simpleEwr.applyFlag()
        else
            simpleMisc.debugOutput("Decider: No target in detectionZone")
        end
    end
end

function simpleEwr.isVecInZone(vec3) --returns true if a vec3 is in the detection zone
    if simpleEwr.detectionZone ~= false then --zone exists / has been defined
        if mist.pointInPolygon(vec3, simpleEwr.detectionZone) then
            simpleMisc.debugOutput("TRUE: detected target is in detectionZone")
            return true
        else
            simpleMisc.debugOutput("FALSE: detected target is NOT in detectionZone")
            return false
        end
    else
        simpleMisc.debugOutput("TRUE: no detectionZone defined")
        return true --true because every detection should matter
    end
end

function simpleEwr.applyFlag () --sets the flag to be used with the mission editor
    if simpleEwr.detectionFlag ~= false then
        trigger.action.setUserFlag(simpleEwr.detectionFlag, true )
    end
end

function simpleEwr.readKnownTargets() --debugging...
    simpleMisc.debugOutput("_____________known targets____________")
    for k, v in pairs (simpleEwr.knownTargets) do
        simpleMisc.debugOutput("k: " .. tostring(k) .. " v: " .. tostring(v))
        for k2, v2 in pairs (v) do
            simpleMisc.debugOutput("____k2: " .. tostring(k2) .. " v2: " .. tostring(v2))
        end
    end
end

function simpleEwr.repeater ()
    simpleMisc.debugOutput ("REPEATER: tick")

    simpleEwr.ewrDetectTargets()
    simpleEwr.decider()

    simpleMisc.debugOutput ("REPEATER: tock")
end

do  
    local repeater = mist.scheduleFunction (simpleEwr.repeater, {}, timer.getTime() + 2, simpleEwr.clockTiming )

    --player input functions, should be set in ME or other file, but here for testing
    simpleEwr.addEwrByName ("EWR-1")
    simpleEwr.addEwrByTable ({"EWR-2", "EWR-3"})
    --simpleEwr.addEwrByPrefix("EWR")
    simpleEwr.setDetectionZone("poly")
    simpleEwr.setDetectionFlag(42)

    simpleMisc.notify("simpleEwr finished loading", 15)
end