dt = {}
dt.version = 0.1
dt.debug = true
dt.updateRate = 1


dt.detectors = {
    "target-1",
    "target-2",
    "detector-3",
}

local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "dt_Debug: " .. tostring(message)
    if dt.debug == true then
        trigger.action.outText(tostring(_outputString), 1)
    end
    env.info(_outputString, false)
end

local function getDistance3D(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1-x2)
    local dY = math.abs(y1-y2)
    local dZ = math.abs(z1-z2)
    local distance = math.sqrt(dX*dX + dZ*dZ + dY*dY)
    return distance
end

local function checkDetectedTargets()

    for index, unitName in pairs (dt.detectors) do

        if Unit.getByName(unitName) then

            local targetTable = {}
            local outString = ""
    
            local _controller = Unit.getByName(unitName):getController()
    
            local _detectedTargets = {
                visual = _controller:getDetectedTargets(1), --visual
                optic = _controller:getDetectedTargets(2), --optic
                radar = _controller:getDetectedTargets(4), --radar
                irst = _controller:getDetectedTargets(8), --irst
                rwr = _controller:getDetectedTargets(16), --rwr
                dlink = _controller:getDetectedTargets(32), --datalink
            }
    
            for detecType, detecTgts in pairs (_detectedTargets) do
                
                for tgtIndex, tgtData in pairs (detecTgts) do
    
                    if tgtData.object then
                        if targetTable[tgtData.object.id_] == nil then
                            targetTable[tgtData.object.id_] = {}
                        end
                        targetTable[tgtData.object.id_].tgtName = tgtData.object:getName()
                        targetTable[tgtData.object.id_].range = math.floor ( 0.5 + getDistance3D ( Unit.getByName(unitName):getPoint(), tgtData.object:getPoint() ) )
                        targetTable[tgtData.object.id_][detecType] = true
                        
                    end
                    
                end
                
            end
    
            for unitID, data in pairs (targetTable) do
                
                outString = unitName .. " detected " .. data.tgtName .. "; distance: " .. data.range .. "\n detected via: "
                
                if data.visual == true then
                    outString = outString .. "VISUAL, "
                end
    
                if data.optic == true then
                    outString = outString .. "OPTIC, "
                end
    
                if data.radar == true then
                    outString = outString .. "RADAR, "
                end
    
                if data.irst == true then
                    outString = outString .. "IRST, "
                end
    
                if data.rwr == true then
                    outString = outString .. "RWR, "
                end
    
                if data.dlink == true then
                    outString = outString .. "DATALINK"
                end
    
                simple.notify(outString , 1)
    
            end
        end              
    end
    timer.scheduleFunction( checkDetectedTargets , {} , timer.getTime() + dt.updateRate )
end


do
    timer.scheduleFunction( checkDetectedTargets , {} , timer.getTime() + dt.updateRate )
    debug("detectorTest.lua version: " .. dt.version .. " initiated")
end