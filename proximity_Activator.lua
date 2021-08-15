pa = {}
pa.debug = false
pa.actAllowed = true
pa.updateFreq = 1
pa.actMax = 4 --maximum activations
pa.actChance = 0.3 --30% chance of activation
pa.actDist = 1000
pa.actSpawnDelay = 120 --time between spawn events
pa.notActivationDelay = 60 --time between checks if a group was in range but did not activate

pa.bluePlayerGroupName = ctld.transportPilotNames --groupName

pa.redTargets = { --table of units that can be activated by proximity
    { groupName = "0_redInf-1",  },
    { groupName = "0_redInf-2",  },
    { groupName = "0_redInf-3",  },
    { groupName = "0_redInf-4",  },
    { groupName = "0_redInf-5",  },
    { groupName = "0_redInf-6",  },
    { groupName = "0_redInf-7",  },
    { groupName = "0_redInf-8",  },
    { groupName = "0_redInf-9",  },
    { groupName = "0_redInf-10", actDist = 2000, actChance = 0.5 },
    { groupName = "0_redInf-11", actDist = 2000, actChance = 0.5 },
    { groupName = "0_redInf-12", actDist = 2000, actChance = 0.5 },
}


local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "Debug: " .. tostring(message)
    if pa.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function pa.start()
    local counter = 0
    for key, groupData in pairs (pa.redTargets) do
        counter = counter + 1

        if groupData.actDist == nil then --if no custom actDist is set the default is used instead
            pa.redTargets[key].actDist = pa.actDist
            debug(groupData.groupName .. " actDist not set, setting to the default of " .. pa.actDist)
        end

        if groupData.actChance == nil then --if no custom actChance is set the default is used instead
            pa.redTargets[key].actChance = pa.actChance
            debug(groupData.groupName .. " actChance not set, setting to the default of " .. pa.actChance)
        end

        mist.scheduleFunction(pa.isPlayerInRange, {groupData}, timer.getTime() + counter * pa.updateFreq)
    end
end

function pa.isPlayerInRange(groupData)
    local reschedulue = true
    local reschedulueOffset = 0
    if pa.actMax > 0 then --check if maximum amount of targets is reached
        local _targetPos = Group.getByName(groupData.groupName):getUnit(1):getPoint()
        for _key, playerGroupName in pairs (pa.bluePlayerGroupName) do --iterate through the playerAircraft table
            if Group.getByName(playerGroupName) then --check if the group exists
                local _playerPos = Group.getByName(playerGroupName):getUnit(1):getPoint()
                local _distance = mist.utils.get2DDist(_targetPos, _playerPos)
                if pa.actAllowed == true and _distance <= groupData.actDist then -- in range
                    if math.random(0, 1) <= pa.actChance then --in range and spawning
                        reschedulue = false
                        debug(playerGroupName .. " in range of " .. groupData.groupName .. ". Activating group." )
                        pa.spawnTarget(groupData.groupName)
                    else --in range but not spawning
                        reschedulueOffset = pa.notActivationDelay
                        debug(playerGroupName .. " in range of " .. groupData.groupName .. ", but not activating yet." )
                    end
                end
            end
        end
    else -- max targets reached
        reschedulue = false
    end
    if reschedulue == true then --only reschedule if no player was in range
        debug(groupData.groupName .. ": no player in range, or spawning not allowed")
        mist.scheduleFunction(pa.isPlayerInRange, {groupData}, timer.getTime() + reschedulueOffset + simple.getTblLenght(pa.redTargets) * pa.updateFreq)
    end
end

function pa.setSpawnAllowed(onOff) --stops further targets from spawning for a while
    if onOff == false then
        pa.actAllowed = false
        local actualSpawnDelay = math.ceil ( math.random (pa.actSpawnDelay/2 , pa.actSpawnDelay*1.5) )
        mist.scheduleFunction (pa.setSpawnAllowed, {true}, timer.getTime() + actualSpawnDelay )
        debug("tgtSpawnAllowed set to false. actualSpawnDelay = " ..actualSpawnDelay)
    elseif onOff == true then
        pa.tgtSpawnAllowed = true
        debug("tgtSpawnAllowed set to true")
    end
end

function pa.spawnTarget(groupName) --spawns a group and schedules the notification to the players about it's position
    pa.actMax = pa.actMax - 1
    Group.getByName(groupName):activate()
    debug(groupName .. " spawned")
    pa.setSpawnAllowed(false)
end

do
    pa.start()
    debug ("proximityActivator loaded")
end