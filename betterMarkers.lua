

bm = {}
bm.debug = true
bm.separator = "-" --might get used
bm.key = "bm" --string needs to be included for the script to work
bm.color = "blue" --default color
bm.markId = 700 --starting value for new IDs

local font = {}
font.size = 20
font.offset = {x = 50, y = 0, z = 100}
font.radius = 20
font.color = {}
font.color.blue = {0, 0, 1, 0.8}
font.color.red = {1, 0, 0, 0.8}
font.color.green = {0, 1, 0, 0.8}
font.color.none = {0,0,0,0}

bm.markTable = {}



local function debug(message) --generic debug function. Outputs on the screen if debug mode is enabled, always outputs to the log
    local _outputString = "bm_Debug: " .. tostring(message)
    if bm.debug == true then
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

function bm.eventHandler(event)
    
    if event.id==26 then --mark change https://wiki.hoggitworld.com/view/DCS_event_mark_change

        local _string = event.text
        if string.find(_string, bm.key)  then --valid entry
            --main code
            bm.markTable[event.idx] = event --save the event data for future reference

            trigger.action.textToAll(-1 , bm.markId , event.pos , font.color.blue , font.color.none , font.size , false ,  event.text)
            bm.markTable[event.idx].textId = bm.markId
            bm.markId = bm.markId+1

            trigger.action.circleToAll(-1 , bm.markId , event.pos , font.radius , font.color.blue , font.color.none , 1 , false)
            bm.markTable[event.idx].circletId = bm.markId
            bm.markId = bm.markId+1



        end
    elseif event.id==27 then --mark delete https://wiki.hoggitworld.com/view/DCS_event_mark_remove
        if bm.markTable[event.idx] then --exists

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

bmHandler = {}
function bmHandler:onEvent(event)
    if bm.debug == true then
        bm.eventHandler(event)
    else
        protectedCall(bm.eventHandler, event)
    end
end

do
    world.addEventHandler(bmHandler)
    debug("betterMarkers.lua initiated")
end