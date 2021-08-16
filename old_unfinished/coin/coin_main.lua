--[[ 

    do not touch

]]

playerAircraft = {"L-39",}

zoneTable = {}
repeatTable = {}

templateTable = {
    forest = {},
    road = {},
    field = {},
}

redTable = {}
spawnIndex = 0

--[[

    variables, do touch

]]

enableDebug = true
clockTiming = 20 --how often the main mission lock runs
destThreshold = 0.5
destTimer = 60
--show of force
sofProb = 0.5
sofRadius = 1000
sofAlt = 1000

--[[

    table management functions

]]

function genZoneTable() --generates the main zone table out of coin_zones.lua. 
    for k, v in pairs(coinZones.allZones) do
        for k2, v2 in pairs(v) do
            zoneTable[#zoneTable+1] = {
                --zones&vec3
                zone = v2.zone,
                zoneVec3 = mist.utils.zoneToVec3(v2.zone),
                root = tostring(k), --"main" root zone, ie "Tiberius1"
                rootVec3 = mist.utils.zoneToVec3(k),
                retreatVec3 = genRetreatVec3( mist.utils.zoneToVec3(v2.zone), mist.utils.zoneToVec3(k) ),
                --other information
                type = v2.type,
                desc = v2.desc,     
                inUse = false,
                activeType = nil,
                activeTemplate = nil,
                timesUsed = 0,
            }
        end
    end
end

function genTemplateTable () --generates a template table with subtubles out of the "input" table in coin_templates.lua
    for k, v in pairs (coinTemplates.allTemplates) do

        if v.forest == true then
            templateTable.forest[#templateTable.forest+1] = {
                name = v.name,
                type = v.type,
            }
        end
        if v.road == true then
            templateTable.road[#templateTable.road+1] = {
                name = v.name,
                type = v.type,
            }
        end
        if v.field == true then
            templateTable.field[#templateTable.field+1] = {
                name = v.name,
                type = v.type,
            }
        end
    end
end

function genRetreatVec3(zoneVec3, rootVec3) --gives sends the unit to a WP ~2km away from it's origin zone and starts a despawn timer
    
    local _angleR = getAngle ( zoneVec3 , rootVec3 ) + math.pi
    local _offset = rotateOffset(_angleR, 2000)
    local _retreatVec3 = mist.utils.makeVec3GL ( mist.vec.add (zoneVec3, _offset) )

    return _retreatVec3
    --smokeVec3 ( _retreatVec3 )
end

function readZoneTable()
    for k, v in pairs (zoneTable) do
        debugNotify ("index: " .. k .. "; zoneName: " .. v.zone .. "; root: " .. v.root .. "; type: " .. v.type .. "; desc: " .. v.desc .. "; inUse: " .. tostring(v.inUse))
    end
end

function readTemplateTable() --should work... ish
    for k, v in pairs (templateTable) do
        for k2, v2 in pairs (v) do
            for k3, v3 in pairs (v2) do
                debugNotify("k: " .. k .. " k2: " .. k2 .. " k3: " .. k3 .. "; v3: " .. v3)
            end
        end
    end
end

--[[

    main functions for spawning and tasking

]]

function getRandomZoneNumber () --returns the number of a zone that is free for spawning
    local _output = 0
    local _var = #zoneTable
    while _var > 1 do

        _var = _var - 1
        local _rand = math.random(#zoneTable)
        --debugNotify("_var: " .. _var .. "; _rand: " .. _rand)
        
        if zoneTable[_rand].inUse == false then
            --debugNotify ("Random zone: " .. zoneTable[_rand].zone)
            _var = 0
            _output = _rand
            return _output
        end
    end
    debugNotify ("no empty zone found")
    return _output
end

function getTemplateTable (zoneTable) --returns the correct subtable for the type of zone that is input
    local _output = {}
    if zoneTable.type == "forest" then
        _output = templateTable.forest
    elseif zoneTable.type == "field" then
        _output = templateTable.field
    elseif zoneTable.type == "road" then
        _output = templateTable.road
    end
    return _output
end

function getZoneNumberByGroupName (groupName)
    for k, v in pairs (zoneTable) do
        debugNotify(k)
        if v.inUse == groupName then --found
            debugNotify("found" .. k)
            return k
        end
    end
end

function redSpawnInZone (templateTable, zoneNumber)
    local _templateName = templateTable.name
    local _templateType = templateTable.type
    local _vec3 = zoneTable[zoneNumber].zoneVec3

    mist.teleportToPoint {
        groupName = _templateName,
        point = _vec3,
        action = "clone",
    }
    spawnIndex = spawnIndex + 1
    local _groupName = getGroupName(_templateName)

    zoneTable[zoneNumber].inUse = _groupName
    zoneTable[zoneNumber].activeType = _templateType
    zoneTable[zoneNumber].activeTemplate = _templateName
    debugNotify ("Debug: " .. _groupName .. " spawned in Zone " .. zoneTable[zoneNumber].zone)

    redTable[#redTable+1] = { --not sure if it is needed...
        name = _groupName,
        vec3 = _vec3,
        template = _templateName,
    }
    local _rootVec3 = mist.utils.zoneToVec3(zoneTable[zoneNumber].root)

    --show of force
    --mist.getUnitsInMovingZones(playerAircraft, _groupName, sofRadius) --now idea when or how to run this function at this point

    --testing
    --smokeVec3(zoneTable[zoneNumber].retreatVec3)
end

function deleteGroup(zoneNumber)
    Group.getByName(zoneTable[zoneNumber].inUse):destroy()
    debugNotify("zone: " .. zoneNumber .. "; group: " .. zoneTable[zoneNumber].inUse .. " destroyed.", 5)
    repeatTable[zoneNumber] = nil
    zoneTable[zoneNumber].inUse = false
    zoneTable[zoneNumber].activeType = nil
    zoneTable[zoneNumber].activeTemplate = nil

end


function clock () --main logic function
    notify("tick (clock)", 5)

    --spawn new group in zone
    local _zoneNumber = getRandomZoneNumber()
    if _zoneNumber ~= 0 then
        local _templateTable = getTemplateTable (zoneTable[_zoneNumber])
        local _template = _templateTable[math.random(#_templateTable)]
        redSpawnInZone(_template, _zoneNumber)
    end

    --tasking
    if _zoneNumber ~= 0 then
        if zoneTable[_zoneNumber].activeType == "car" then
            tasks.suicideBomb ( zoneTable[_zoneNumber].inUse, zoneTable[_zoneNumber].rootVec3, _zoneNumber )

        elseif zoneTable[_zoneNumber].activeType == "tank" then
            tasks.retreatGroup ( _zoneNumber )

        elseif zoneTable[_zoneNumber].activeType == "vehicle" then
            tasks.retreatGroup ( _zoneNumber )

        elseif zoneTable[_zoneNumber].activeType == "infantry" then
            tasks.retreatGroup ( _zoneNumber )

        elseif zoneTable[_zoneNumber].activeType == "arty" then
            tasks.fireAtVec3 ( zoneTable[_zoneNumber].inUse , zoneTable[_zoneNumber].rootVec3, _zoneNumber )
            --tasks.retreatGroup ( _zoneNumber )
        end
    end

    notify("tock (clock)", 5)
end

function funcRepeater ()
    debugNotify("tick (repeater)")
    for k, v in pairs (repeatTable) do
        if v.func then
            debugNotify("func found. zoneNumber :" .. k)
            v.func(v.args)
        else
            --debugNotify("func NOT found")
        end
    end
    debugNotify("tock (repeater)")
end

--[[

    general functions

]]


function getGroupName(templateName)
    local _groupName = country.name[Group.getByName(templateName):getUnit(1):getCountry()].." gnd "..tostring(spawnIndex)
    return _groupName
end

function notify(message, displayFor)
    trigger.action.outText(message, displayFor)
end

function debugNotify(string)
    if enableDebug == true then
        trigger.action.outText(tostring(string), 5)
    end
    env.error("__COIN__ : "..string, false)
end

function rotateOffset ( radian, offset ) --input degree and radius, rotates the vector and returns a vec3 offset
    local _offset = {
        x = offset,
        y = 0
    }
    local _offset = mist.utils.makeVec3( mist.vec.rotateVec2 ( _offset, radian ) )
    return _offset
end

function getAngle (vec3From, vec3To)
    local _angleR = math.atan2 (vec3To.z - vec3From.z, vec3To.x - vec3From.x)-- - math.atan2 (vec3To.z, vec3To.x)
    if _angleR < 0 then
        _angleR = _angleR + 2 * math.pi
    end
    local _angleD = math.deg (_angleR)
    debugNotify("Angle(r): " .. _angleR .. "; angle(d): " .. _angleD)
    return _angleR
end

function smokeVec3 (vec3)
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

--[[

    do things part

]]

do
    --don't change!
    genZoneTable()
    genTemplateTable()

    --change!
    --readZoneTable()

    local clock = mist.scheduleFunction (clock, {}, timer.getTime() + 5, clockTiming)
    local repeater = mist.scheduleFunction (funcRepeater, {}, timer.getTime() + 5, clockTiming / 2 )

end