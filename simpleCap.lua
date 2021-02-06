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
simpleCap.missions = {}
simpleCap.interceptors = {"Mig-1"}
simpleCap.capCounter = 1
--simpleCap.groupData = {}
--simpleCap.groupRoute = {}

function simpleCap.getEwrTargets()
    local _targets = simpleEwr.getKnownTargets()
    return _targets
end

function simpleCap.start ()
	simpleCap.getGroupData(simpleCap.interceptors[1])
	simpleCap.buildInteceptMission()

	simpleCap.buildMissions ()

	simpleCap.spawn()
end

function simpleCap.buildMissions ()
	local _targets = simpleEwr.getKnownTargets()
	for id, data in pairs (_targets) do

		local _unitPosVec2 = mist.utils.makeVec2 (data.unitPosVec3)
		local _mission ={
			target = data.unitName,
			
			["alt"] = 2000,
			["x"] = _unitPosVec2.x,
			["action"] = "Turning Point",
			["alt_type"] = "BARO",
			--["speed"] = 138.88888888889,
			["form"] = "Turning Point",
			["type"] = "Turning Point",
			["y"] = _unitPosVec2.y,
		}

		table.insert(simpleCap.missions, _mission)

		simple.dumpTable(simpleCap.missions)
		


	end
end

function simpleCap.getTargetPos()
	local _targets = simpleCap.getEwrTargets()
	for k, v in pairs (_targets) do
		local _vec3 = v.unitPosVec3
		local _vec2 = mist.utils.makeVec2(_vec3)
		return _vec2
	end
end

function simpleCap.getGroupData(groupName) --seems to work, no figure out how to create missions
	simpleCap.groupData = mist.getGroupData(groupName)
	--simpleCap.groupRoute = mist.getGroupRoute(groupName)
	
	simpleCap.groupData.groupName = "test" .. simpleCap.capCounter
	simpleCap.capCounter = simpleCap.capCounter + 1
	

	simpleCap.groupData.route = {}
	simpleCap.groupData.route[1] = {}
	simpleCap.groupData.route[1].type = "TakeOffParking"
	simpleCap.groupData.route[1].form = "From Parking Area"
	simpleCap.groupData.route[1].airdromeId = 3

	simpleCap.groupData.clone = true
	simpleCap.groupData.groupId = simpleCap.capCounter + 1

	simpleCap.buildInteceptMission()
end

function simpleCap.buildInteceptMission()
	local _targetVec2 = simpleCap.getTargetPos()

	simpleCap.groupData.route[2] = { 
		["alt"] = 2000,
		["x"] = _targetVec2.x,
		["action"] = "Turning Point",
		["alt_type"] = "BARO",
		--["speed"] = 138.88888888889,
		["form"] = "Turning Point",
		["type"] = "Turning Point",
		["y"] = _targetVec2.y,
	}
end

function simpleCap.spawn()
	mist.dynAdd( simpleCap.groupData )
	simple.dumpTable(simpleCap.groupData)
	--coalition.addGroup(country.id.RUSSIA, Group.Category.AIRPLANE, simpleCap.groupData)
end


  do

	  
	simple.notify("simpleCap finished loading", 15)
  end