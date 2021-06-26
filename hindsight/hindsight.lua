--[[
    Hindsight:
    A patrol or XCAS style mission with random elements.
]]

hindsight = {}

hindsight.activeTargets = {}

hindsight.debug = true
hindsight.actRange = 3000 --30km
hindsight.probability = 1
hindsight.targetsMax = 10
hindsight.messageDelay = 5
hindsight.updateFreq = 1 --to reduce the lua load
hindsight.playerAircraft = {"Mi-24P_Tester", "L-39_tester"}
hindsight.playerAircraftActive = {}


function hindsight.startPatrolMode()
    local counter = 0
    for groupKey, groupTable in pairs (hindsightTargets.targets) do
        counter = counter + 1
        mist.scheduleFunction(hindsight.isPlayerInRange, {groupTable}, timer.getTime() + counter * hindsight.updateFreq)
    end
end

function hindsight.startXCASMode() --maybe at some point
end

function hindsight.startEscortMode()
end

function hindsight.isPlayerInRange(groupTable) --check the distance between the target and all player aircraft, if one is within range activate, if no player exist or none are in range than reschedule the check
    local reschedulue = true
    if hindsight.targetsMax > 0 then --check if maximum amount of targets is reached
        local _targetPos = Group.getByName(groupTable.groupName):getUnit(1):getPoint()

        for k, playerGroupName in pairs (hindsight.playerAircraft) do --iterate through the playerAircraft table

            if Group.getByName(playerGroupName) then --check if the group exists

                local _playerPos = Group.getByName(playerGroupName):getUnit(1):getPoint()
                local _distance = mist.utils.get2DDist(_targetPos, _playerPos)
                --simple.debugOutput(groupTable.groupName .. " distance: " .. _distance)
                if _distance <= hindsight.actRange then -- in range
                    reschedulue = false
                    if math.random(0, 1) <= hindsight.probability then --in range but spawning
                        simple.debugOutput(groupTable.groupName .. ": in range, activating")
                        hindsight.spawnTarget(groupTable)
                    else --in range but not spawning
                        simple.debugOutput(groupTable.groupName .. ": in range, but NOT activating")
                    end
                end
            end
        end
    else -- max targets reached
        reschedulue = false
    end
    if reschedulue == true then --only reschedule if no player was in range
        simple.debugOutput(groupTable.groupName .. ": no player was in range or existed. Rescheduling")
        mist.scheduleFunction(hindsight.isPlayerInRange, {groupTable}, timer.getTime() + #hindsightTargets.targets * hindsight.updateFreq)
    end
end

function hindsight.spawnTarget(groupTable) --spawns a group and schedules the notification to the players about it's position
    hindsight.targetsMax = hindsight.targetsMax - 1
    hindsight.activeTargets[#hindsight.activeTargets+1] = groupTable
    Group.getByName(groupTable.groupName):activate()
    simple.debugOutput(groupTable.groupName .. " spawned")
    if groupTable.message ~= nil then
        mist.scheduleFunction (hindsight.informPlayers, {groupTable}, timer.getTime() + hindsight.messageDelay)
    end
end

function hindsight.informPlayers(groupTable) --notifies the players about the position of a group
    simple.notify(groupTable.message, 30)
    trigger.action.outSound("Alert.ogg")
end

do
    hindsight.startPatrolMode()

    simple.debugOutput("hindsight loaded")
end