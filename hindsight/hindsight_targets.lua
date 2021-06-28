hindTables = {}

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
    {
        groupName = "red_mortar-1",
        type = "arty",
        message = "A group of mortars is attacking TOWNNAME from the south east",
        messageSound = "",
        messageDelay = 20, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    {
        groupName = "red_mortar-2",
        type = "arty",
        message = "a mortar group is bombarding TOWNNAME from the south east in the mountains!",
        messageSound = "",
        messageDelay = 20, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    {
        groupName = "red_mortar-3",
        type = "arty",
        message = "a group of mortars have been spotted 4km south of " .. hindTables.blueCheckPoints["roadCheckPointCenter-2"].displayName,
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    {
        groupName = "red_mortar-4",
        type = "arty",
        message = "a mortar is attacking the northern checkpoint!",
        messageSound = "",
        messageDelay = 20, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    {
        groupName = "red_aaa-1", --test
        type = "aa",
        message = nil,
        messageSound = "",
        messageDelay = 10, --not used maybe?
        actDist = 10000, --not used. Maybe?
    },
    {
        groupName = "red_manpad-1",
        type = "aa",
        message = nil,
        messageSound = "",
        messageDelay = 10, --not used maybe?
        actDist = 10000, --not used. Maybe?
    },
    {
        groupName = "red_ied-1",
        type = "bomb",
        message = "an IED is being planted near a road in the west",
        messageSound = "",
        messageDelay = 120, --not used maybe?
        actDist = 7000, --not used. Maybe?
    },
    {
        groupName = "red_technical-1",
        type = "veh",
        message = "the southern checkpoint is under attack!",
        messageSound = "",
        messageDelay = 120, --not used maybe?
        actDist = 6000, --not used. Maybe?
    },
    {
        groupName = "red_technical-2",
        type = "veh",
        message = "the southern checkpoint is under attack!",
        messageSound = "",
        messageDelay = 120, --not used maybe?
        actDist = 6000, --not used. Maybe?
    },
    {
        groupName = "red_infantry-1",
        type = "veh",
        message = "someone is shooting at the refugee camp",
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 5000, --not used. Maybe?
    },
    {
        groupName = "red_infantry-2",
        type = "veh",
        message = "someone is shooting at the refugee camp",
        messageSound = "",
        messageDelay = 30, --not used maybe?
        actDist = 5000, --not used. Maybe?
    },
}
