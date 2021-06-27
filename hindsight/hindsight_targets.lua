hindTables = {}

hindTables.targets = {
    {
        groupName = "red_mortar-1",
        type = "arty",
        message = "A group of mortars is attacking TOWNNAME from the south east",
        messageSound = "string.ogg",
        messageDelay = 10, --not used maybe?
        actDist = 5000, --not used. Maybe?
        actChance = 0.5, --not used. Maybe?
    },
    {
        groupName = "red_mortar-2",
        type = "arty",
        message = "a mortar group is bombarding TOWNNAME from the south east in the mountains!",
    },
    {
        groupName = "red_mortar-3",
        type = "arty",
        message = "a mortar is attacking the southern checkpoint!",
    },
    {
        groupName = "red_mortar-4",
        type = "arty",
        message = "a mortar is attacking the northern checkpoint!",
    },
    {
        groupName = "red_aaa-1", --test
        type = "aa",
        message = nil,
    },
    {
        groupName = "red_manpad-1",
        type = "aa",
        message = nil,
    },
    {
        groupName = "red_ied-1",
        type = "bomb",
        message = "an IED is being planted near a road in the west",
    },
    {
        groupName = "red_technical-1",
        type = "veh",
        message = "the southern checkpoint is under attack!",
    },
    {
        groupName = "red_technical-2",
        type = "veh",
        message = "the southern checkpoint is under attack!",
    },
    {
        groupName = "red_infantry-1",
        type = "veh",
        message = "someone is shooting at the refugee camp",
    },
    {
        groupName = "red_infantry-2",
        type = "veh",
        message = "someone is shooting at the refugee camp",
    },
}

hindTables.checkPoints = {
    ["roadCheckPointCenter-2"] = {
        groupName = "roadCheckPointCenter-2",
        displayName = "checkpoint CENTER",
    },
    {
        groupName = "roadCheckPointCenter-1",
        displayName = "checkpoint NORTH",
    },
    {
        groupName = "roadCheckPointSouth-1",
        displayName = "checkpoint SOUTH",
    },
    {
        groupName = "rayakCheckPointNorth-1",
        displayName = "Rayak checkpoint SOUTH",
    },
    {
        groupName = "rayakCheckPointSouth-1",
        displayName = "Rayak checkpoint SOUTH",
    },
}

hindTables.blueConvoys = {
    ["blue_convoy_south-1"] = { groupName = "blue_convoy_south-1", displayName = "convoy", },
}
