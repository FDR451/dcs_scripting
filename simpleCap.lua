simpleCap = {}
simpleCap.debug = true
simpleCap.interceptors = {"Mig-1", "Mig-2"}

function simpleCap.notify(message) --used this so often now... 
    if simpleCap.debug == true then
        trigger.action.outText(tostring(message), 5)
    end
end

function simpleCap.smokeVec3 (vec3) --puts smoke at vec3 for debugging
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

function simpleCap.printVec3 (vec3)
    trigger.action.outText("vec3.x: " .. vec3.x .. " ; vec3.y: " .. vec3.y .. " ; vec3.z: " .. vec3.z, 5)
end

function simpleCap.getEwrTargets()
    local _targets = simpleEwr.getKnownTargets()
    return _targets
end

-- https://wiki.hoggitworld.com/view/DCS_task_mission