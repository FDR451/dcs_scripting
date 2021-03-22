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
simpleEwr.safeAlt = 0
simpleEwr.detectionZone = false --false until set

simpleEwr.flagNumber = false --false until set
simpleEwr.flagCounter = 0 -- do not change

--setup functions

function simpleEwr.start() --starts simpleEWR
end

function simpleEwr.stop() --maybe?
end

function simpleEwr.addEwrByName (unitName) --main function for adding units to the table
    if Unit.getByName(unitName) then --existing unit
        table.insert(simpleEwr.ewrUnitList, unitName)
        simple.debugOutput("addEwrByName: Added " .. unitName .. " to ewrUnitList. New ewrUnitList lenght is " .. #simpleEwr.ewrUnitList)
    else --unit does not exist
        simple.errorOutput("addEwrByName: Tried to add a unit to simpleEwr that does not exist. unitName: " .. unitName .. " has not been added to the table!")
    end
end

function simpleEwr.addEwrByPrefix (prefix) --works, needs a check if the unit is on position 1 of the group
    for unitName, unitTable in pairs(mist.DBs.unitsByName) do
        local _prefixPos = string.find(unitName, prefix, 1, true)
        if _prefixPos and _prefixPos == 1 then
            if Unit.getByName(unitName) and Unit.getByName(unitName):getNumber() == 1 then --check if unit exists and is the first one in the group
                simpleEwr.addEwrByName(unitName)
            end
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
    simpleEwr.flagNumber = flagNumber
end

function simpleEwr.setDetectionZone (groupName) --defines the zone, ie the border of a country, in which the EWR network works
    if Group.getByName(groupName) then
        simpleEwr.detectionZone = mist.getGroupPoints(groupName)
    else
        simple.errorOutput("setDetectionZone: tried to add a zone that is not a group in the ME. groupName: " .. groupName)
    end
end

function simpleEwr.setSafeAltitude (meters) --sets the safe altitude AGL that will be ignored. So anything closer than 50 or so meters to the ground will not be picked up by simpleEwr
    simpleEwr.safeAlt = meters
    simple.debugOutput ("setSafeAltitude: set to " .. meters)
end

--logic functions

function simpleEwr.getKnownTargets() -- returns the table of known targets, might be useful for the dispatcher
    return simpleEwr.knownTargets
end

function simpleEwr.ewrDetectTargets () --iterates through the table of EWRs and checks if they detect something, if they detect an aircraft it gets handed off to
    for k, vEwrUnit in pairs (simpleEwr.ewrUnitList) do
        local _targets = Unit.getByName(vEwrUnit):getController():getDetectedTargets(Controller.Detection.Radar)
        if _targets then --if targets are detected
            for i = 1, #_targets do

                if _targets[i].object and _targets[i].distance == true then --if the distance is known and the target is an object
                    local _object = _targets[i].object

                    if _object:getCoalition() == 2 then --only blue coalition
                        if Unit.getByName(_object:getName()) then --check if object is a unit

                            if simple.getAltitudeAgl(_object:getPoint()) > simpleEwr.safeAlt then

                                local args = {
                                    objectId = _object.id_,
                                    unitName = _object:getName(),
                                    unitPosVec3 = _object:getPoint(),
                                    unitVelVec3 = _object:getVelocity(),
                                    detectionTime = timer.getTime(),
                                    inZone = simpleEwr.isVecInZone(_object:getPoint()),
                                }
        
                                simpleEwr.knownTargets[args.objectId] = args

                            end
                        end
                    end
                end
            end
        end
    end
end

function simpleEwr.decider() --runs further functions if a target is inside of a detection zone, no idea if useful tbh
    local notInZone = 0
    local inZone = 0
    for index, vTargetTable in pairs (simpleEwr.knownTargets) do
        if vTargetTable.inZone == true then
            inZone = inZone + 1
            if simpleEwr.flagNumber ~= false then --only run if a flag has been set
                simpleEwr.applyFlag()
            end
        else
            notInZone = notInZone + 1
        end
    end
    simple.debugOutput("decider: \n" .. inZone .. " targets inside the detection zone. \n" .. notInZone .. ' targets outside of the detection zone.')
end

function simpleEwr.isVecInZone(vec3) --returns true if a vec3 is in the detection zone
    if simpleEwr.detectionZone ~= false then --zone exists / has been defined
        if mist.pointInPolygon(vec3, simpleEwr.detectionZone) then
            return true
        else
            return false
        end
    else
        simple.debugOutput("isVecInZone: no detectionZone defined")
        return true
    end
end

function simpleEwr.applyFlag () --increases the number of the 
    simpleEwr.flagCounter = simpleEwr.flagCounter + 1
    trigger.action.setUserFlag(simpleEwr.flagNumber, simpleEwr.flagCounter )
    simple.debugOutput("applyFlag: flag: " .. simpleEwr.flagNumber .. "; value: " .. trigger.misc.getUserFlag(simpleEwr.flagNumber))
end

function simpleEwr.repeater ()
    simpleEwr.ewrDetectTargets()
    simpleEwr.decider()

    simple.debugOutput ("ewrRepeater: finished")
end

function simpleEwr.eventHandler(event)
    if event.id == 30 then --event dead 8, 30 unit lost

        for number, ewrUnit in pairs (simpleEwr.ewrUnitList) do --checks if the dead unit is an EWR --works!
            if event.initiator:getName()  == ewrUnit then
                table.remove(simpleEwr.ewrUnitList, number)
                simple.debugOutput("eventHandler: EWR removed")
            end
        end

        for k, v in pairs (simpleEwr.knownTargets) do -- checks if it is a known target --works
            if k == event.initiator.id_ then
                simpleEwr.knownTargets[event.initiator.id_] = nil
                simple.debugOutput("eventHandler: knownTarget removed. ID: " .. event.initiator.id_)
            end
        end
    end
end

do  
    mist.addEventHandler(simpleEwr.eventHandler)
    local repeater = mist.scheduleFunction (simpleEwr.repeater, {}, timer.getTime() + 2, simpleEwr.clockTiming )
    
    simple.notify("simpleEwr finished loading", 15) --keep at the end of the script
end