hindNotify = {}

hindNotify.overviewTbl = {}
hindNotify.overviewFreq = 120 --how often it is shown automatically
hindNotify.overviewDur = 30 --how long the overview is displayed
hindNotify.overviewUpdFreq = 30 --time between updates, to avoid spamming
hindNotify.overviewTimeout = 121 --when to clear "old" entries

hindNotify.overviewSpotTbl = {}

hindNotify.msgDur = 30

hindNotify.debug = false

local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "Debug: " .. tostring(message)
    if hindNotify.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function hindNotify.informPlayers(groupTable) --notifies the players about the position of a group -- should replace it with a better function
    --simple.notify(groupTable.message, hindNotify.msgDur)
    --trigger.action.outSound("Alert.ogg")

    local _data = {
        ["time"] = timer.getTime(),
        ["message"] = groupTable.message,
        ["groupName"] = groupTable.groupName,
    }

    hindNotify.overviewSpotTbl[groupTable.groupName] = _data
end

function hindNotify.checkpointUnderAttack(checkPointGroupName, attackerGroupName)
    if hindNotify.overviewTbl[checkPointGroupName] == nil or hindNotify.overviewTbl[checkPointGroupName].time + hindNotify.overviewUpdFreq <= timer.getTime()  then --check if the entry does not exist, or if it is to old
        local _cpVec3 = Group.getByName(checkPointGroupName):getUnit(1):getPoint()
        local _attVec3 = Group.getByName(attackerGroupName):getUnit(1):getPoint()

        local _time = timer.getTime()
        local _compassDir = simple.getCompassDirection(_cpVec3, _attVec3)
        local _tgtDispName = hindTables.blueCheckPoints[checkPointGroupName].displayName
        local _attDispName = hindTables.targets[attackerGroupName].displayName[math.random(simple.getTblLenght(hindTables.targets[attackerGroupName].displayName))]

        local data = {
            ["target"] = _tgtDispName, --the friendly being attacked
            ["attacker"] = _attDispName,
            ["direction"] = _compassDir,
            ["distance"] = "",
            ["time"] = _time,
        }

        hindNotify.overviewTbl[checkPointGroupName] = data
    end
end

function hindNotify.convoyUnderAttack(convoyGroupName, attackerGroupName)
    if hindNotify.overviewTbl[convoyGroupName] == nil or hindNotify.overviewTbl[convoyGroupName].time + hindNotify.overviewUpdFreq <= timer.getTime()  then --check if the entry does not exist, or if it is to old
        local _conVec3 = Group.getByName(convoyGroupName):getUnit(1):getPoint()
        local _attVec3 = Group.getByName(attackerGroupName):getUnit(1):getPoint()
    
        local _time = timer.getTime()
        local _compassDir = simple.getCompassDirection(_conVec3, _attVec3)
        local _tgtDispName = hindTables.blueConvoys[convoyGroupName].displayName
        local _attDispName = hindTables.targets[attackerGroupName].displayName[math.random(simple.getTblLenght(hindTables.targets[attackerGroupName].displayName))]
    
        local data = {
            ["target"] = _tgtDispName, --the friendly being attacked
            ["attacker"] = _attDispName,
            ["direction"] = _compassDir,
            ["distance"] = "",
            ["time"] = _time,
        }
    
        hindNotify.overviewTbl[convoyGroupName] = data
    end
end

function hindNotify.showOverview() --provides periodic overview over the situation
    local _msg = "OVERVIEW:"

    for key, value in pairs (hindNotify.overviewTbl) do
        if value.time + hindNotify.overviewTimeout <= timer.getTime()  then --remove outdated entries
            debug(value.attacker .. " is outdated and removed from the overview.")
            hindNotify.overviewTbl[key] = nil
        else --if not outdated print
            _msg = _msg .. "\n    target: " .. value.target .. "; aggressor: " .. value.attacker .. "; direction: " .. value.direction
        end
    end

    _msg = _msg .. "\n \n SPOTTED:"

    for key, value in pairs (hindNotify.overviewSpotTbl) do --newly spotted units
        if value.time + hindNotify.overviewTimeout <= timer.getTime() then --remove outdated entries
            debug(value.groupName .. " is outdated and removed from the SPOT overview.")
            hindNotify.overviewSpotTbl[key] = nil
        else --if not outdated print
            _msg = _msg .. "\n    " .. hindNotify.overviewSpotTbl[key].message
        end
    end
    simple.notify(_msg, hindNotify.overviewDur)
end

do
    mist.scheduleFunction(hindNotify.showOverview, {}, timer.getTime() + hindNotify.overviewFreq, hindNotify.overviewFreq )
    debug("hindNotify.lua initiated")
end