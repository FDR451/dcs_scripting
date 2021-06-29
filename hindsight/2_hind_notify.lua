hindNotify = {}

hindNotify.overviewTbl = {}
hindNotify.overviewFreq = 60
hindNotify.overviewDur = 59

hindNotify.msgDuration = 20
hindNotify.msgFreqLimit = 10

hindNotify.debug = false

local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "Debug: " .. tostring(message)
    if hindNotify.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function hindNotify.informPlayers(groupTable) --notifies the players about the position of a group
    simple.notify(groupTable.message, hindNotify.msgDuration)
    trigger.action.outSound("Alert.ogg")
end

function hindNotify.checkpointUnderAttack(checkPointGroupName, attackerGroupName) --might still need a delay to lessen the lua load
    if hindNotify.overviewTbl[checkPointGroupName] == nil or hindNotify.overviewTbl[checkPointGroupName].time + hindNotify.msgFreqLimit <= timer.getTime()  then --check if the entry does not exist, or if it is to old
        local _cpVec3 = Group.getByName(checkPointGroupName):getUnit(1):getPoint()
        local _attVec3 = Group.getByName(attackerGroupName):getUnit(1):getPoint()

        local _time = timer.getTime()
        local _compassDir = simple.getCompassDirection(_cpVec3, _attVec3)
        local _tgtDispName = hindTables.blueCheckPoints[checkPointGroupName].displayName
        local _attDispName = hindTables.targets[attackerGroupName].displayName[math.random(simple.getTblLenght(hindTables.targets[attackerGroupName].displayName))]

        trigger.action.outSound("Alert.ogg")

        local data = {
            ["target"] = _tgtDispName, --the friendly being attacked
            ["attacker"] = _attDispName,
            ["direction"] = _compassDir,
            ["distance"] = "",
            ["time"] = _time,
        }

        hindNotify.overviewTbl[checkPointGroupName] = data

        --simple.notify(_tgtDispName .. " is being attacked by " .. _attDispName .. " from the " ..  _compassDir , hindNotify.msgDuration)
    end
end

function hindNotify.convoyUnderAttack(convoyGroupName, attackerGroupName) --might still need a delay to lessen the lua load
    if hindNotify.overviewTbl[convoyGroupName] == nil or hindNotify.overviewTbl[convoyGroupName].time + hindNotify.msgFreqLimit <= timer.getTime()  then --check if the entry does not exist, or if it is to old
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
    
        trigger.action.outSound("Alert.ogg")
        --simple.notify("The " .. _tgtDispName .. " is being attacked by " .. _attDispName .. " from the " ..  _compassDir , hindNotify.msgDuration)
    end
end

function hindNotify.provideOverview() --provides periodic overview over the situation
    local _msg = "OVERVIEW:"

    for key, value in pairs (hindNotify.overviewTbl) do
        _msg = _msg .. "\n    target: " .. value.target .. "; aggressor: " .. value.attacker .. "; direction: " .. value.direction .. "; distance " .. value.distance .. "km"
    end

    if _msg ~= "OVERVIEW: \n" then
        simple.notify(_msg, 20)
        trigger.action.outSound("Alert.ogg")
    end
    hindNotify.overviewTbl = {} --reset
end

do
    mist.scheduleFunction(hindNotify.provideOverview, {}, timer.getTime() + hindNotify.overviewFreq, hindNotify.overviewFreq )
    debug("hindNotify.lua initiated")
end