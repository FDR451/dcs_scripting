--[[
    hind:
    A patrol or XCAS style mission with random elements.

    TODO:
    Needs a delay between spawns
]]

hind = {}

hind.debug = true

hind.activeTargets = {}

hind.actRange = 7000 --30km
hind.probability = 0.90
hind.targetsMax = 10
hind.spawnDelay = 60 --does nothing right now
hind.messageDelay = 5
hind.updateFreq = 1 --to reduce the lua load
hind.playerAircraft = {"Mi-24P_Tester", "L-39_Tester"}
hind.activeConvoy = nil
hind.blueConvoys = {"blue_convoy_south-1"}
hind.playerAircraftActive = {}

local function debug(message)
    local _outputString = "Debug: " .. tostring(message)
    if hind.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function hind.startPatrolMode()
    local counter = 0
    for groupKey, groupTable in pairs (hindTargets.targets) do
        counter = counter + 1
        mist.scheduleFunction(hind.isPlayerInRange, {groupTable}, timer.getTime() + counter * hind.updateFreq)
    end
end

function hind.startConvoyMode()
    local counter = 0
    for groupKey, groupTable in pairs (hindTargets.targets) do
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

                if _distance <= hind.actRange then -- in range

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
        debug(groupTable.groupName .. ": no player in range")
        mist.scheduleFunction(hind.isPlayerInRange, {groupTable}, timer.getTime() + #hindTargets.targets * hind.updateFreq)
    end
end

function hind.isConvoyInRange(groupTable)
    local reschedulue = true
    if hind.targetsMax > 0 and hind.activeConvoy ~= nil then
        local _targetPos = Group.getByName(groupTable.groupName):getUnit(1):getPoint()
        local _convoyPos = Group.getByName(hind.activeConvoy):getUnit(1):getPoint()
        local _distance = mist.utils.get2DDist(_targetPos, _convoyPos)
        if _distance <= hind.actRange then
            reschedulue = false
            if math.random(0, 1) <= hind.probability then --in range but spawning
                debug(hind.activeConvoy .. " in range of " .. groupTable.groupName .. ". Activating group." )
                hind.spawnTarget(groupTable)
            else --in range but not spawning
                debug(hind.activeConvoy .. " in range of " .. groupTable.groupName .. ", but not activating." )
            end
        end
    else
        reschedulue = false
    end
    if reschedulue == true then --only reschedule if no player was in range
        debug(groupTable.groupName .. ": convoy NOT in range")
        mist.scheduleFunction(hind.isPlayerInRange, {groupTable}, timer.getTime() + #hindTargets.targets * hind.updateFreq)
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



do
    --hind.startPatrolMode()

    hind.testConvoy()

    debug("hindsight.lua loaded")
end