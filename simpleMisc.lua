simpleMisc = {}
debug = true

function simpleMisc.notify(message, duration) --used this so often now... 
    trigger.action.outText(tostring(message), duration)
    env.error("Notify: " .. tostring(message), false)
end

function simpleMisc.debug(message)
    if debug == true then
        trigger.action.outText(tostring(message), 5)
    end
    env.error("Debug: " .. tostring(message), false)
end

function simpleMisc.smokeVec3 (vec3) --puts smoke at vec3 for debugging
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

function simpleMisc.printVec3 (vec3)
    trigger.action.outText("vec3.x: " .. vec3.x .. " ; vec3.y: " .. vec3.y .. " ; vec3.z: " .. vec3.z, 5)
end

do
    simpleMisc.notify("simpleMisc finished loading")
end