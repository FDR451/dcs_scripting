--[[
-- https://wiki.hoggitworld.com/view/DCS_task_mission

--https://wiki.hoggitworld.com/view/MIST_getGroupData
--https://wiki.hoggitworld.com/view/DCS_func_addGroup

What it should do:
    read ME placed templates for their group groupData
    modify this groupData for TO in different airports
    create missions for them to do
        missions should be based on simpleEwr's information, mainly position and direction of detected targets

]]

simpleCap = {}
simpleCap.debug = true
simpleCap.spawnPoint = {"spawnPoint"}
simpleCap.interceptors = {"Mig-1"}
--simpleCap.groupData = {}
--simpleCap.groupRoute = {}

function simpleCap.getEwrTargets()
    local _targets = simpleEwr.getKnownTargets()
    return _targets
end

function simpleCap.getGroupData(groupName) --seems to work, no figure out how to create missions
	simpleCap.groupData = mist.getGroupData(groupName)
	simpleCap.groupRoute = mist.getGroupRoute(groupName)
	simpleCap.groupData.groupName = "test"
	simpleCap.groupData.route = simpleCap.groupRoute
end

function simpleCap.genInterceptMission ()

end

function simpleCap.spawn()
	mist.dynAdd( simpleCap.groupData )
	--coalition.addGroup(country.id.RUSSIA, Group.Category.AIRPLANE, simpleCap.groupData)
end



--addGroup() test
--[[

local groupData = {
	["visible"] = false,
	["taskSelected"] = true,
	["route"] = 
	{
	}, -- end of ["route"]
	["groupId"] = 2,
	["tasks"] = 
	{
	}, -- end of ["tasks"]
	["hidden"] = false,
	["units"] = 
	{
		[1] = 
		{
			["type"] = "LAV-25",
			["transportable"] = 
			{
				["randomTransportable"] = false,
			}, -- end of ["transportable"]
			["unitId"] = 2,
			["skill"] = "Average",
			["y"] = 616314.28571429,
			["x"] = -288585.71428572,
			["name"] = "Ground Unit1",
			["playerCanDrive"] = true,
			["heading"] = 0.28605144170571,
		}, -- end of [1]
	}, -- end of ["units"]
	["y"] = 616314.28571429,
	["x"] = -288585.71428572,
	["name"] = "Ground Group",
	["start_time"] = 0,
	["task"] = "Ground Nothing",
  } -- end of [1]

  coalition.addGroup(country.id.USA, Group.Category.GROUND, groupData)
]]


  do

	simpleCap.getGroupData(simpleCap.interceptors[1])

	simpleCap.spawn()

	  
	simpleMisc.notify("simpleCap finished loading", 15)
  end