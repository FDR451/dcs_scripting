am = {}
am.debug = true
am.attackerTable = {"attacker"}
local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "Debug: " .. tostring(message)
    if am.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function am.controllerCheck()
    debug ("test")
    local _controller = Group.getByName(am.attackName):getController()
    simple.dumpTable(_controller)
    return timer.getTime() + 1
end

function am.eventHandler(event)
    if event.id == 1 or event.id == 23 or event.id == 24 then --1 shot, 23 shooting starts, 24 shooting ends
        if event.initiator then
            local _ini = event.initiator
            local category = _ini:getCategory()
            if category == 1 then --units
                local iniDesc = _ini:getDesc()
                if iniDesc.category == 2 then --groundUnit
                    debug("eventId: " .. event.id)
                end
            end
        end
    end
end

amHandler = {}
function amHandler:onEvent(event)
    --protectedCall(am.eventHandler, event)
    am.eventHandler(event)
end

do
    world.addEventHandler(amHandler)
    debug("secondary_explosions.lua initiated")
end

--timer.scheduleFunction( am.controllerCheck , {} , timer.getTime() + 1 )
debug ("attackMove.lua loaded")