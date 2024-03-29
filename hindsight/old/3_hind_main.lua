--[[
    hind:
    A patrol or XCAS style mission with random elements.

    TODO:
    add radioMenu to decide the mode
    make IEDs do something

    detection of convoy arriving at the camp and turn around a few minutes latter
    change message strings
    
]]

hind = {}

hind.debug = false
--don't change
hind.activeTargets = {}
hind.tgtSpawnAllowed = true
hind.activeConvoy = nil
--configuration variables
hind.actDistMult = 1 --mult for the action distance in tables.lua
hind.probability = 0.3 --chance for a spawn event to trigger
hind.targetsMax = 99 --max number of target groups to be spawned
hind.spawnDelay = 120 --average time between target spawns in seconds (randomised)
hind.updateFreq = 3 --to reduce the lua load
hind.notActivationDelay = 600 --delay if a unit did not spawn the first time to delay for a second check

hind.playerAircraft = {"Mi-24P_Tester", "L-39_Tester"} --move to tables

local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "Debug: " .. tostring(message)
    if hind.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function hind.startPatrolMode() --spawns around the players
    local counter = 0 --to offset the check times
    for groupKey, groupTable in pairs (hindTables.targets) do
        counter = counter + 1
        mist.scheduleFunction(hind.isPlayerInRange, {groupTable}, timer.getTime() + counter * hind.updateFreq)
    end
end

function hind.startConvoyMode() --spawns around the convoy
    local counter = 0
    for groupKey, groupTable in pairs (hindTables.targets) do
        counter = counter + 1
        mist.scheduleFunction(hind.isConvoyInRange, {groupTable}, timer.getTime() + counter * hind.updateFreq)
    end
end

function hind.isPlayerInRange(groupTable) --update like the convoy function
    local reschedulue = true
    local reschedulueOffset = 0
    if hind.targetsMax > 0 then --check if maximum amount of targets is reached
        local _targetPos = Group.getByName(groupTable.groupName):getUnit(1):getPoint()
        for k, playerGroupName in pairs (hind.playerAircraft) do --iterate through the playerAircraft table
            if Group.getByName(playerGroupName) then --check if the group exists
                local _playerPos = Group.getByName(playerGroupName):getUnit(1):getPoint()
                local _distance = mist.utils.get2DDist(_targetPos, _playerPos)
                if hind.tgtSpawnAllowed == true and _distance <= groupTable.actDist * hind.actDistMult then -- in range
                    if math.random(0, 1) <= hind.probability then --in range but spawning
                        reschedulue = false
                        debug(playerGroupName .. " in range of " .. groupTable.groupName .. ". Activating group." )
                        hind.spawnTarget(groupTable)
                    else --in range but not spawning
                        reschedulueOffset = hind.notActivationDelay
                        debug(playerGroupName .. " in range of " .. groupTable.groupName .. ", but not activating yet." )
                    end
                end
            end
        end
    else -- max targets reached
        reschedulue = false
    end
    if reschedulue == true then --only reschedule if no player was in range
        debug(groupTable.groupName .. ": no player in range, or spawning not allowed")
        mist.scheduleFunction(hind.isPlayerInRange, {groupTable}, timer.getTime() + reschedulueOffset + simple.getTblLenght(hindTables.targets) * hind.updateFreq)
    end
end

function hind.isConvoyInRange(groupTable) --same as isPlayerInRange but checks range towards the convoy instead
    local reschedulue = true
    local reschedulueOffset = 0
    if hind.targetsMax > 0 and hind.activeConvoy ~= nil then
        local _targetPos = Group.getByName(groupTable.groupName):getUnit(1):getPoint()
        local _convoyPos = Group.getByName(hind.activeConvoy):getUnit(1):getPoint()
        local _distance = mist.utils.get2DDist(_targetPos, _convoyPos)
        if hind.tgtSpawnAllowed == true and _distance <= groupTable.actDist * hind.actDistMult then
            
            if math.random(0, 1) <= hind.probability then --in range but spawning
                reschedulue = false
                debug(hind.activeConvoy .. " in range of " .. groupTable.groupName .. ". Activating group." )
                hind.spawnTarget(groupTable)
            else --in range but not spawning
                reschedulueOffset = hind.notActivationDelay
                debug(hind.activeConvoy .. " in range of " .. groupTable.groupName .. ", but not activating yet. Next check in " .. reschedulueOffset .. " seconds." )
            end
        end
    else --max targets reached
        reschedulue = false
    end
    if reschedulue == true then --only reschedule if no player was in range
        debug(groupTable.groupName .. ": NOT ACTIVATED. Nxt check in " .. reschedulueOffset .. " seconds")
        mist.scheduleFunction(hind.isConvoyInRange, {groupTable}, timer.getTime() + reschedulueOffset + simple.getTblLenght(hindTables.targets) * hind.updateFreq)
    end
end

function hind.setSpawnAllowed(onOff) --stops further targets from spawning for a while
    if onOff == false then
        hind.tgtSpawnAllowed = false
        local actualSpawnDelay = math.ceil ( math.random (hind.spawnDelay/2 , hind.spawnDelay*1.5) )
        mist.scheduleFunction (hind.setSpawnAllowed, {true}, timer.getTime() + actualSpawnDelay )
        debug("tgtSpawnAllowed set to false. actualSpawnDelay = " ..actualSpawnDelay)
    elseif onOff == true then
        hind.tgtSpawnAllowed = true
        debug("tgtSpawnAllowed set to true")
    end
end

function hind.spawnTarget(groupTable) --spawns a group and schedules the notification to the players about it's position
    hind.targetsMax = hind.targetsMax - 1
    --hind.activeTargets[#hind.activeTargets+1] = groupTable
    Group.getByName(groupTable.groupName):activate()
    debug(groupTable.groupName .. " spawned")
    if groupTable.message ~= nil then
        mist.scheduleFunction (hindNotify.informPlayers, {groupTable}, timer.getTime() + groupTable.messageDelay)
    end
    hind.setSpawnAllowed(false)
end

--[[
    eventhandler
]]

function hind.hitEventHandler (event)
    if event.id == 2 then --hit / S_EVENT_HIT
        if event.target and event.target:getCategory() == 1 then --check if the target is a unit
            local _targetGroupName = event.target:getGroup():getName()
            local _attackerGroupName = event.initiator:getGroup():getName()
            if hindTables.blueCheckPoints[_targetGroupName] then --target is checkpoint
                hindNotify.checkpointUnderAttack(_targetGroupName, _attackerGroupName)
            elseif hindTables.blueConvoys[_targetGroupName] then --target is convoy
                hindNotify.convoyUnderAttack (_targetGroupName, _attackerGroupName)
            end
        end
    end
end

local function protectedCall(...) --from splash_damage
    local status, retval = pcall(...)
    if not status then
        env.warning("hit eventhandler script errors caught!" .. retval, false)
    end
end

hitHandler = {}
function hitHandler:onEvent(event)
    --hit.hitEventHandler (event)
    protectedCall(hind.hitEventHandler, event)
end

do
    world.addEventHandler(hitHandler)
    debug("hindsight.lua loaded")
end