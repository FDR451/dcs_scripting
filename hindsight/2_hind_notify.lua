hindNotify = {}

hindNotify.msgDuration = 20
hindNotify.msgDelay = 30

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

function hindNotify.checkpointUnderAttack(checkPointGroupName, attackerGroupName)
    local _cpVec3 = Group.getByName(checkPointGroupName):getUnit(1):getPoint()
    local _attVec3 = Group.getByName(attackerGroupName):getUnit(1):getPoint()
    local _compassDir = simple.getCompassDirection(_cpVec3, _attVec3)
    local _cpDisName = hindTables.blueCheckPoints[checkPointGroupName].displayName
    local _attDisName = hindTables.targets[attackerGroupName].displayName[math.random(simple.getTblLenght(hindTables.targets[attackerGroupName].displayName))]

    trigger.action.outSound("Alert.ogg")
    simple.notify(_cpDisName .. " is being attacked by " .. _attDisName .. " from the " ..  _compassDir , hindNotify.msgDuration)
end

function hindNotify.convoyUnderAttack(convoyGroupName, attackerGroupName)
    local _conVec3 = Group.getByName(convoyGroupName):getUnit(1):getPoint()
    local _attVec3 = Group.getByName(attackerGroupName):getUnit(1):getPoint()
    local _compassDir = simple.getCompassDirection(_conVec3, _attVec3)
    local _convDisName = hindTables.blueConvoys[convoyGroupName].displayName
    local _attDisName = hindTables.targets[attackerGroupName].displayName[math.random(simple.getTblLenght(hindTables.targets[attackerGroupName].displayName))]

    trigger.action.outSound("Alert.ogg")
    simple.notify("The " .. _convDisName .. " is being attacked by " .. _attDisName .. " from the " ..  _compassDir , hindNotify.msgDuration)
end




do
    debug("hindNotify.lua initiated")
end