--[[
    Name:           markerFlags.lua
    Author:         SuumCuique
    Dependencies:   none
    Usage:          "do script file" in the mission editor.
    Description:
        allows to set mission editor flags in game. To trigger things manually or safe broken triggers. Supports passwords to stop trolling

    Format:
    flag-flagNumber-flagValue-password
    password is optional and only used if set
    separator can be changed
]]

mf = {} --don't touch
--config
mf.debug = false
mf.password = nil --set to nil if not in use
mf.separator = "-" --set to anything

local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "Debug: " .. tostring(message)
    if mf.debug == true then
        trigger.action.outText(tostring(_outputString), 5)
    end
    env.info(_outputString, false)
end

local function mysplit (inputstr, sep) --thanks toni
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

local function setFlag(flagNumber, flagValue, markId) --sets the flag and deletes the mark afterwards
    trigger.action.setUserFlag(flagNumber , flagValue )
    trigger.action.removeMark(markId)
    debug("set Flag: " .. flagNumber .. " to value: " .. flagValue)
end

function mf.eventHandler(event)
    if event.id==26 then

        local _pwCorrect = true
        local _string = event.text

        if mf.password ~= nil then --password in use
            if not string.find(_string, mf.password) then
                _pwCorrect = false
            end
        end
        
        if string.find(_string, "flag") and _pwCorrect == true  then
            local _table = mysplit(_string, mf.separator)

            if (#_table >= 3 ) then --if less than 3 it means that the format is not correct
            
                local _flagNumber = tonumber(_table[2])
                local _flagValue = tonumber(_table[3])
                setFlag(_flagNumber, _flagValue, event.idx )
            end
        end
    end
end


--eventhandler

local function protectedCall(...) --from splash_damage
    local status, retval = pcall(...)
    if not status then
        env.warning("markerFlags.lua script errors caught!" .. retval, false)
    end
end

mfHandler = {}
function mfHandler:onEvent(event)
    protectedCall(mf.eventHandler, event)
end

do
    world.addEventHandler(mfHandler)
    debug("markerFlags.lua initiated")
end