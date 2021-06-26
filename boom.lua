boom ={}
boom.threshold = 0.7

boom.table = { --table of units that produce secondary explosions
    ["Truck Ural-375"] = 250,
    ["TRM-2000"] = 100,
    ["TRM-2000 Fuel"] = 100,
    ["Truck Bedford"] = 100,
    ["Truck GAZ-3308"] = 250,
    ["Truck GAZ-66"] = 100,
    ["Truck KAMAZ 43101"] = 250,
    ["Truck KrAZ-6322 6x6"] = 250,
    ["Truck M939 Heavy"] = 250,
    ["Truck Opel Blitz"] = 100,
    ["Truck Ural-375 Mobile C2"] = 250,
    ["Truck Ural-4320-31 Arm'd"] = 250,
    ["Truck ZIL-135"] = 250,
    ["Caisse de munitions"] = 100,
    --STATICS
    [".Ammunition depot"] = 1000
}

function expDebug (string)
    trigger.action.outText(string, 5)
end

function boom.eventHandler(event)
    if event.id == 2 then --hit / S_EVENT_HIT
        if event.target then
            local target = event.target
            local category = target:getCategory()
            if category == 1 then --units
                
                local targetDesc = target:getDesc()
                if targetDesc.category == 2 then --groundUnit
                    if boom.table[targetDesc.displayName] then
                        local unitLifeCurrent = target:getLife()
                        local unitLifeInitial = target:getLife0()
                        if unitLifeInitial / unitLifeCurrent <= boom.threshold then
                            local targetVec3 = target:getPoint()
                            local yield = boom.table[targetDesc.displayName]
                            boom.explode(targetVec3, yield)
                        end
                    end
                end

            elseif category == 3 then --structure
                --local targetDesc = target:getDesc()
                --trigger.action.outText("structure", 10) 
            end
        end
    end
end

function boom.explode(vec3, yield)
    trigger.action.explosion(vec3, yield)
    trigger.action.effectSmokeBig(vec3 , 2 , 0.5 )
    expDebug("boom")
end

boomHandler = {}
function boomHandler:onEvent(event)
    boom.eventHandler(event)
end

do
    world.addEventHandler(boomHandler)
    trigger.action.outText("boom.lua initiated", 5)
end 