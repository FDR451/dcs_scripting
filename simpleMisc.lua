simpleMisc = {}
simpleMisc.debug = true

function simpleMisc.notify(message, duration) --used this so often now... 
    trigger.action.outText(tostring(message), duration)
    env.info("Notify: " .. tostring(message), false)
end

function simpleMisc.debugOutput(message)
    local _outputString = "Debug: " .. tostring(message)
    if simpleMisc.debug == true then
        simpleMisc.notify(_outputString, 5)
    end
    env.warning(_outputString, false)
end

function simpleMisc.errorOutput(message)
    local _outputString = "ERROR: " .. tostring(message)
    env.error(_outputString, false)
    simpleMisc.notify(_outputString, 300)
end

function simpleMisc.smokeVec3 (vec3) --puts smoke at vec3 for debugging
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

function simpleMisc.printVec3 (vec3)
    trigger.action.outText("vec3.x: " .. vec3.x .. " ; vec3.y: " .. vec3.y .. " ; vec3.z: " .. vec3.z, 5)
end

do
    simpleMisc.notify("simpleMisc finished loading", 15)
end