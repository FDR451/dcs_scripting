allList = {}

allZones = {
    city1 = {
        {
            z = "zone11",
            d = "north of city",
            t = "field"
        },
        {
            z = "zone12",
            d = "east of city",
            t = "forest"
        },
        {
            z = "zone13",
            d = "south of city",
            t = "road"
        },
        {
            z = "zone14",
            d = "forest west of city",
            t = "forest"
        }
    },
    town2 = {
        {
            z = "zone21",
            d = "in the forest",
            t = "forest"
        },
        {
            z = "zone22",
            d = "in the field",
            t = "field"
        },
        {
            z = "zone23",
            d = "on the house",
            t = "building"
        },
        {
            z = "zone24",
            d = "near the lake",
            t = "treeline"
        },
    }   
}


function readAll () --works
    for k, v in pairs(allZones) do
        print(k)
        for k2, v2 in pairs(v) do
            print(v2.z, v2.d, v2.t)
        end
    end
end

function makeList()
    for k, v in pairs(allZones) do
        local origin = tostring(k)
        --print (k)
        for k2, v2 in pairs(v) do
            local zone = v2.z
            local type = v2.t
            local desc = v2.d
            allList[#allList+1] = {o = origin, z = zone, t = type, d = desc}
        end
    end
end

function readList()
    for k, v in pairs (allList) do
        print (k, v.o, v.t, v.d, v.z)
    end
end

function selectRandom()
    math.randomseed( os.time())
    _var = allList[math.random(#allList)]
    print ("random target: ", _var.o, _var.t, _var.d, _var.z)
end

do
    --readAll()
    --math.randomseed( os.time())
    makeList()
    readList()
    --print(allList[2].t)
    --print (#allList)
    selectRandom()

    --print (allList[3])
    --print (#allZones)
    --print (#allZones)
    --_ran0 = math.random(4)
    --_ran1 = math.random(#allZones)
    --_ran2 = math.random(#allZones[_ran1])
    --print (_ran0 ,_ran1, _ran2)
    --print (allZones[2][math.random(4)].z)
 

    --[[

        print ("________________")
    print (allZones.city1[1].d)
    print (#allZones.city1)

    print (#allList)
    
    ]]
end