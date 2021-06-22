coinTemplates = {}

templateTable = {
    forest = {},
    road = {},
    field = {},
}

coinTemplates.allTemplates = {
    {
        name = "mortar-1",
        type = "arty",
        road = true,
        field = true,
        forest = true,
        mountain = true,
        building = false,
    },
    {
        name = "btr-1",
        type = "vehicle",
        road = true,
        field = true,
        forest = false,
        mountain = false,
        building = false,
    },
    {
        name = "t55-1",
        type = "tank",
        road = true,
        field = true,
        forest = false,
        mountain = false,
        building = false,
    },
    {
        name = "infantry-1",
        type = "infantry",
        road = true,
        field = true,
        forest = true,
        mountain = true,
        building = true,
    },
}

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

function readTemplateTable() --wont work since changing the templateTable
    for k, v in pairs (templateTable) do
        for k2, v2 in pairs (v) do
            for k3, v3 in pairs (v2) do
                print("k: " .. k .. " k2: " .. k2 .. " k3: " .. k3 .. "; v3: " .. v3)
            end
        end
    end
end

do
    genTemplateTable()
    readTemplateTable()

end