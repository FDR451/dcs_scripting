--[[
    Hindsight:
    A patrol or XCAS style mission with random elements.
]]

hindsight = {}

hindsight.activeTargets = {}

hindsight.actRange = 3000 --30km
hindsight.probability = 1
hindsight.targetsMax = 10
hindsight.messageDelay = 5
hindsight.playerAircraft = {"Mi-24P_Tester", "L-39_tester"}


function hindsight.startPatrolMode()
    local counter = 1
    for key, groupTable in pairs (hindsightTargets.targets) do
        counter = counter + 1
        mist.scheduleFunction(hindsight.isPlayerInRange, {groupTable}, timer.getTime() + counter)
    end
end

function hindsight.startXCASMode()
end

function hindsight.isPlayerInRange(groupTable) --check the distance between the target and all player aircraft, if one is within range activate, if no player exist or none are in range than reschedule the check
    local playerInRange = false
    if hindsight.targetsMax > 0 then --check if maximum amount of targets is reached
        local _targetPos = Group.getByName(groupTable.groupName):getUnit(1):getPoint()

        for key, playerGroupName in pairs (hindsight.playerAircraft) do --iterate through the playerAircraft table

            if Group.getByName(playerGroupName) then --check if the group exists

                local _playerPos = Group.getByName(playerGroupName):getUnit(1):getPoint()
                local _distance = mist.utils.get2DDist(_targetPos, _playerPos)
                simple.debugOutput(groupTable.groupName .. " distance: " .. _distance)

                if _distance <= hindsight.actRange then -- in range
                    playerInRange = true
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
        playerInRange = true
    end
    if playerInRange == false then --only reschedule if no player was in range
        simple.debugOutput(groupTable.groupName .. ": no player was in range or existed. Rescheduling")
        mist.scheduleFunction(hindsight.isPlayerInRange, {groupTable}, timer.getTime() + #hindsightTargets.targets) 
    end
end

function hindsight.spawnTarget(groupTable) --spawns a group and schedules the notification to the players about it's position
    hindsight.targetsMax = hindsight.targetsMax - 1
    Group.getByName(groupTable.groupName):activate()
    simple.debugOutput(groupTable.groupName .. " spawned")
    if groupTable.message ~= nil then
        mist.scheduleFunction (hindsight.informPlayers, {groupTable}, timer.getTime() + hindsight.messageDelay)
    end
end

function hindsight.informPlayers(groupTable) --notifies the players about the position of a group
    simple.notify(groupTable.message, 30)
end


do
    hindsight.startPatrolMode()

    simple.debugOutput("hindsight loaded")
end