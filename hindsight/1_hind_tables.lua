hindTables = {}

hindTables.targetDisplayNames = { --we are taking fire from .. string 
    ["mortar"] = {"group of mortars", "mortar squad", "mortar section",},
    ["technical"] = {"armed trucks", "technicals"},
    ["aaa"] = {"aaa"},
    ["ied"] = {"ied"},
    ["manpad"] = {"manpad"},
    ["infantry"] = {"infantry"},
}

hindTables.blueCheckPoints = {
    ["roadCheckPointCenter-2"] = {
        groupName = "roadCheckPointCenter-2",
        displayName = "checkpoint CENTER",
    },
    ["roadCheckPointCenter-1"] = {
        groupName = "roadCheckPointCenter-1",
        displayName = "checkpoint NORTH",
    },
    ["roadCheckPointSouth-1"] = {
        groupName = "roadCheckPointSouth-1",
        displayName = "checkpoint SOUTH",
    },
    ["rayakCheckPointNorth-1"] = {
        groupName = "rayakCheckPointNorth-1",
        displayName = "Rayak checkpoint SOUTH",
    },
    ["rayakCheckPointSouth-1"] = {
        groupName = "rayakCheckPointSouth-1", 
        displayName = "Rayak checkpoint SOUTH",
    },
}

hindTables.blueConvoys = {
    ["blue_convoy_south-1"] = { groupName = "blue_convoy_south-1", displayName = "supply convoy", },
}

hindTables.targets = {
    ["red_mortar-1"] = {
        groupName = "red_mortar-1",
        displayName = hindTables.targetDisplayNames.mortar,
        type = "arty",
        message = "A group of mortars is attacking TOWNNAME from the south east",
        messageSound = "",
        messageDelay = 20, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    ["red_mortar-2"] = {
        groupName = "red_mortar-2",
        displayName = hindTables.targetDisplayNames.mortar,
        type = "arty",
        message = "a mortar group is bombarding TOWNNAME from the south east in the mountains!",
        messageSound = "",
        messageDelay = 20, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    ["red_mortar-3"] = { --testing
        groupName = "red_mortar-3",
        displayName = hindTables.targetDisplayNames.mortar,
        type = "arty",
        message = "a group of mortars have been spotted 4km south of " .. hindTables.blueCheckPoints["roadCheckPointCenter-2"].displayName,
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    ["red_mortar-4"] = {
        groupName = "red_mortar-4",
        displayName = hindTables.targetDisplayNames.mortar,
        type = "arty",
        message = "a mortar is attacking the northern checkpoint!",
        messageSound = "",
        messageDelay = 20, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    ["red_aaa-1"] = {
        groupName = "red_aaa-1", --test
        displayName = hindTables.targetDisplayNames.aaa,
        type = "aa",
        message = nil,
        messageSound = "",
        messageDelay = 10, --not used maybe?
        actDist = 10000, --not used. Maybe?
    },
    ["red_manpad-1"] = {
        groupName = "red_manpad-1",
        displayName = hindTables.targetDisplayNames.manpad,
        type = "aa",
        message = nil,
        messageSound = "",
        messageDelay = 10, --not used maybe?
        actDist = 10000, --not used. Maybe?
    },
    ["red_ied-1"] = {
        groupName = "red_ied-1",
        displayName = hindTables.targetDisplayNames.ied,
        type = "bomb",
        message = "an IED is being planted near a road in the west",
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    ["red_technical-1"] = {
        groupName = "red_technical-1",
        displayName = hindTables.targetDisplayNames.technical,
        type = "veh",
        message = "the southern checkpoint is under attack!",
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 6000, --not used. Maybe?
    },
    ["red_technical-2"] = {
        groupName = "red_technical-2",
        displayName = hindTables.targetDisplayNames.technical,
        type = "veh",
        message = "the southern checkpoint is under attack!",
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 6000, --not used. Maybe?
    },
    ["red_infantry-1"] = {
        groupName = "red_infantry-1",
        displayName = hindTables.targetDisplayNames.infantry,
        type = "inf",
        message = "someone is shooting at the refugee camp",
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 5000, --not used. Maybe?
    },
    ["red_infantry-2"] = {
        groupName = "red_infantry-2",
        displayName = hindTables.targetDisplayNames.infantry,
        type = "inf",
        message = "someone is shooting at the refugee camp",
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 5000, --not used. Maybe?
    },
}

function getTblLenght (table) --works for keyed tables where #table would not work
    local _tblLenght = 0
    for k, v in pairs (table) do
        _tblLenght = _tblLenght + 1
    end
    return _tblLenght
end

print ( getTblLenght(hindTables.targets["red_mortar-4"].displayName) )