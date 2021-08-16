hindRadio = {}
hindRadio.debug = false

local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "Debug: " .. tostring(message)
    if hindRadio.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function hindRadio.selectEscortMode() --more test than final but it works
    Group.getByName(hindTables.blueConvoys["blue_convoy_south-1"].groupName):activate()
    hind.activeConvoy = hindTables.blueConvoys["blue_convoy_south-1"].groupName
    hind.startConvoyMode()
    debug("Convoy mode selected")
end

function hindRadio.selectPatrolMode()
    hind.startPatrolMode()
    debug("Patrol mode selected")
end

function hindRadio.markConvoyWithSmoke()
    local _vec3 = Group.getByName(hind.activeConvoy):getUnit(1):getPoint()
    trigger.action.smoke(_vec3,4)
    debug("convoy marked with blue smoke")
end

do
    radioMenuStartCommands = missionCommands.addSubMenu ("HIND Commands")

    radioMenuPatrolMode = missionCommands.addCommand ("Start convoy mode", radioMenuStartCommands, hindRadio.selectPatrolMode)
    radioMenuEscortMode = missionCommands.addCommand ("Start patrol mode", radioMenuStartCommands, hindRadio.selectEscortMode)

    radioMenuShowOverview = missionCommands.addCommand ("Show Overview", radioMenuStartCommands, hindNotify.showOverview)
    radioMenuSmokeConvoy = missionCommands.addCommand ("Smoke Convoy", radioMenuStartCommands, hindRadio.markConvoyWithSmoke)


    hindRadio.selectEscortMode()
    debug("hind_radio.lua loaded")
end