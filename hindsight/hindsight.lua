--[[
    hind:
    A patrol or XCAS style mission with random elements.

    TODO:
    add radioMenu to decide the mode
]]

hind = {}

hind.debug = false
--don't change
hind.activeTargets = {}
hind.tgtSpawnAllowed = true
hind.activeConvoy = nil
--configuration variables
hind.actRange = 7000 --30km
hind.probability = 1 --chance for a spawn event to trigger
hind.targetsMax = 99 --max number of target groups to be spawned
hind.spawnDelay = 90 --time between target spawns in seconds
hind.messageDelay = 60 --time between the spawn event and the notification
hind.updateFreq = 3 --to reduce the lua load
hind.playerAircraft = {"Mi-24P_Tester", "L-39_Tester"}
hind.blueConvoys = {"blue_convoy_south-1"}

local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "Debug: " .. tostring(message)
    if hind.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function hind.checkIfUnderAttack(groupName)

end

function hind.startPatrolMode() --spawns around the players
    local counter = 0
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

function hind.isPlayerInRange(groupTable) --check the distance between the target and all player aircraft, if one is within range activate, if no player exist or none are in range than reschedule the check
    local reschedulue = true
    if hind.targetsMax > 0 then --check if maximum amount of targets is reached
        local _targetPos = Group.getByName(groupTable.groupName):getUnit(1):getPoint()
        for k, playerGroupName in pairs (hind.playerAircraft) do --iterate through the playerAircraft table
            if Group.getByName(playerGroupName) then --check if the group exists
                local _playerPos = Group.getByName(playerGroupName):getUnit(1):getPoint()
                local _distance = mist.utils.get2DDist(_targetPos, _playerPos)
                if hind.tgtSpawnAllowed == true and _distance <= hind.actRange then -- in range
                    reschedulue = false
                    if math.random(0, 1) <= hind.probability then --in range but spawning
                        debug(playerGroupName .. " in range of " .. groupTable.groupName .. ". Activating group." )
                        hind.spawnTarget(groupTable)
                    else --in range but not spawning
                        debug(playerGroupName .. " in range of " .. groupTable.groupName .. ", but not activating." )
                    end
                end
            end
        end
    else -- max targets reached
        reschedulue = false
    end
    if reschedulue == true then --only reschedule if no player was in range
        debug(groupTable.groupName .. ": no player in range, or spawning not allowed")
        mist.scheduleFunction(hind.isPlayerInRange, {groupTable}, timer.getTime() + #hindTables.targets * hind.updateFreq)
    end
end

function hind.isConvoyInRange(groupTable) --same as isPlayerInRange but checks range towards the convoy instead
    local reschedulue = true
    if hind.targetsMax > 0 and hind.activeConvoy ~= nil then
        local _targetPos = Group.getByName(groupTable.groupName):getUnit(1):getPoint()
        local _convoyPos = Group.getByName(hind.activeConvoy):getUnit(1):getPoint()
        local _distance = mist.utils.get2DDist(_targetPos, _convoyPos)
        if hind.tgtSpawnAllowed == true and _distance <= hind.actRange then
            reschedulue = false
            if math.random(0, 1) <= hind.probability then --in range but spawning
                debug(hind.activeConvoy .. " in range of " .. groupTable.groupName .. ". Activating group." )
                hind.spawnTarget(groupTable)
            else --in range but not spawning
                debug(hind.activeConvoy .. " in range of " .. groupTable.groupName .. ", but not activating." )
            end
        end
    else --max targets reached
        reschedulue = false
    end
    if reschedulue == true then --only reschedule if no player was in range
        debug(groupTable.groupName .. ": convoy NOT in range, or spawning not allowed")
        mist.scheduleFunction(hind.isConvoyInRange, {groupTable}, timer.getTime() + #hindTables.targets * hind.updateFreq)
    end
end

function hind.spawnTarget(groupTable) --spawns a group and schedules the notification to the players about it's position
    hind.targetsMax = hind.targetsMax - 1
    hind.activeTargets[#hind.activeTargets+1] = groupTable
    Group.getByName(groupTable.groupName):activate()
    debug(groupTable.groupName .. " spawned")
    if groupTable.message ~= nil then
        mist.scheduleFunction (hind.informPlayers, {groupTable}, timer.getTime() + hind.messageDelay)
    end
    hind.setSpawnAllowed(false)
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

function hind.informPlayers(groupTable) --notifies the players about the position of a group
    simple.notify(groupTable.message, 30)
    trigger.action.outSound("Alert.ogg")
end

--[[
    pure testing
]]

function hind.testConvoy() --purely for testing
    Group.getByName(hind.blueConvoys[1]):activate()
    hind.activeConvoy = hind.blueConvoys[1]
    hind.startConvoyMode()
end

--eventHandler

hit = {}

function hit.hitEventHandler (event)
    if event.id == 2 then --hit / S_EVENT_HIT
        if event.target and event.target:getCategory() == 1 then --check if the target is a unit
            local _targetGroupName = event.target:getGroup():getName()
            if hindTables.checkPoints[_targetGroupName] then --target is checkpoint
                simple.notify(hindTables.checkPoints[_targetGroupName].displayName .. " is under attack!", 10)
            elseif hindTables.blueConvoys[_targetGroupName] then --target is convoy
                simple.notify("The " .. hindTables.blueConvoys[_targetGroupName].displayName .. " is under attack!", 10)
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
    protectedCall(hit.hitEventHandler, event)
end


do
    --hind.startPatrolMode()
    world.addEventHandler(hitHandler)

    hind.testConvoy()

    debug("hindsight.lua loaded")
end