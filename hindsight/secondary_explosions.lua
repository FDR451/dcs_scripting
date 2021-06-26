--[[
    secondary_explosions.lua
    a simple script to enable secondary explosions on supply vehicles
]]

boom ={}
boom.threshold = 0.7
boom.big = 750
boom.small = 500

boom.table = { --table of units that produce secondary explosions
    ["Truck Ural-375"] = boom.big,
    ["TRM-2000"] = boom.small,
    ["TRM-2000 Fuel"] = boom.small,
    ["Truck Bedford"] = boom.small,
    ["Truck GAZ-3308"] = boom.big,
    ["Truck GAZ-66"] = boom.small,
    ["Truck KAMAZ 43101"] = boom.big,
    ["Truck KrAZ-6322 6x6"] = boom.big,
    ["Truck M939 Heavy"] = boom.big,
    ["Truck Opel Blitz"] = boom.small,
    ["Truck Ural-375 Mobile C2"] = boom.big,
    ["Truck Ural-4320-31 Arm'd"] = boom.big,
    ["Truck ZIL-135"] = boom.big,
    ["Caisse de munitions"] = boom.small,
    --STATICS
    [".Ammunition depot"] = 1000 --not implemented
}

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
                            env.info(targetDesc.displayName .. " is exploding!", false)

                            local args = {["vec3"] = targetVec3, ["yield"] = yield }
                            timer.scheduleFunction( boom.explode , args , timer.getTime() + math.random(1, 3) )
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

function boom.explode(args) --dcs
    local yieldActual = math.ceil ( math.random(args.yield/3, args.yield) )
    trigger.action.explosion(args.vec3, yieldActual)
    trigger.action.effectSmokeBig(args.vec3 , 1 , 0.5 )
    env.info("yieldActual: " .. yieldActual, false)
    return nil
end

local function protectedCall(...)
    local status, retval = pcall(...)
    if not status then
        env.warning("secondary_explosions.lua script errors caught!" .. retval, true)
    end
end

boomHandler = {}
function boomHandler:onEvent(event)
    protectedCall(boom.eventHandler, event)
end

do
    world.addEventHandler(boomHandler)
    --trigger.action.outText("secondary_explosions.lua initiated", 5)
end