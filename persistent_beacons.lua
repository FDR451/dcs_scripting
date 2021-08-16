--[[
    persistent_beacons.lua
    requierments: MIST
    useage: add an .ogg or .wave file through the triggers into the mission file. Afterwards use do script pb.newBeacon(arguments)
    example:
    pb.newBeacon("refugeeCampMorse.wav", mist.utils.zoneToVec3("hospitalWpZone-1"), "AM", true, 000300000, 100, "refCamp") --creates a beacon on 300kHz

    creates a radio beacon that refreshes itself, to eliminate a bug in multiplayer that prevents players from hearing a beacon if they join after the beacon was started
]]

pb = {}
pb.activeBeacons = {}
pb.refreshInterval = 60
pb.debug = false

local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "PB_Debug: " .. tostring(message)
    if pb.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

function pb.newBeacon(soundFileName, vec3, modulation, loop, frequency, power, beaconName)
    --check correct input type first
    local _mod = 0 --more intutive way to set modulation
    if modulation == "AM" or modulation == 0 then
        _mod = 0
    elseif modulation == "FM" or modulation == 1 then
        _mod = 1
    end

    local _freq = frequency
    local _fileName = "l10n/DEFAULT/"..soundFileName

    pb.activeBeacons[beaconName] = { fileName = _fileName, vec3 = vec3, modulation = _mod, loop = loop, frequency = _freq, power = power, beaconName = beaconName,}
    
    trigger.action.radioTransmission(_fileName , vec3 , _mod , loop , _freq , power , beaconName)
    mist.scheduleFunction(pb.refreshBeacon, {beaconName}, timer.getTime() + pb.refreshInterval )
    
    debug(beaconName .. " beacon started")
    return beaconName
end

function pb.refreshBeacon(beaconName) --refreshes a placed beacon
    if pb.activeBeacons[beaconName] ~= nil then
        trigger.action.stopRadioTransmission(beaconName)

        local _fileName = pb.activeBeacons[beaconName].fileName
        local _vec3 = pb.activeBeacons[beaconName].vec3
        local _mod = pb.activeBeacons[beaconName].modulation
        local _loop = pb.activeBeacons[beaconName].loop
        local _freq = pb.activeBeacons[beaconName].frequency
        local _power = pb.activeBeacons[beaconName].power

        trigger.action.radioTransmission(_fileName , _vec3 , _mod , _loop , _freq , _power , beaconName)
        mist.scheduleFunction(pb.refreshBeacon, {beaconName}, timer.getTime() + pb.refreshInterval )
        debug(beaconName .. " beacon refreshed")
    end
end

function pb.stopBeacon(beaconName) --stops a transmission
    trigger.action.stopRadioTransmission(beaconName)
    pb.activeBeacons[beaconName] = nil
    debug(beaconName .. " beacon stopped")
end

do
    debug ("persistent_beacons initialised")
end