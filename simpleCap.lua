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
simpleCap.targets = {}
simpleCap.missions = {}
simpleCap.updateFreq = 120

simpleCap.interceptors = {"Mig-1"}
simpleCap.capCounter = 1
--simpleCap.groupData = {}
--simpleCap.groupRoute = {}

function simpleCap.buildTargets () --takes the output from simpleEwr and adds more data fields, but runs more rarely. This way it should have less performance impact
	local _ewrTargets = simpleEwr.getKnownTargets()
	for id, data in pairs (_ewrTargets) do

		local _args = {
			targetId = data.objectId,
			targetName = data.unitName,
			targetType = Unit.getByName(data.unitName):getDesc().displayName,
			targetInZone = data.inZone,

			targetPosVec3 = data.unitPosVec3,
			targetPosVec2 = mist.utils.makeVec2 (data.unitPosVec3),
			targetVelVec3 = data.unitVelVec3,

			targetSpeed = mist.vec.mag( data.unitVelVec3 ),
			targetHdg = math.atan2 (data.unitVelVec3.x, data.unitVelVec3.z),
			targetIntPosVec2 = mist.utils.makeVec2 (data.unitPosVec3), --temp --interception point
			targetPrio = 1, --maybe for later
		}

		simpleCap.targets[id] = _args

	end
	simple.dumpTable(simpleCap.targets)
end

function simpleCap.buildMissions () --just WPs on the interception point for now proof of concept
	simpleCap.missions = {}

	for id, data in pairs (simpleCap.targets) do
		if data.targetInZone == true then --only build missions for targets in the zone

			local _argsWp = {
				["id"] = id,
				["alt"] = data.targetPosVec3.y,
				["x"] = data.targetIntPosVec2.x,
				["y"] = data.targetIntPosVec2.y,

				["action"] = "Turning Point",
				["alt_type"] = "BARO",
				["speed"] = 900,
				["form"] = "Turning Point",
				["type"] = "Turning Point",

				["task"] = { 
					["id"] = 'ComboTask',
					["params"] = { 
						["tasks"] = { 
						},
					},
				},

			}

			table.insert(simpleCap.missions, _argsWp)

		end
	end
	simple.dumpTable(simpleCap.missions)
end

function simpleCap.buildSpawnPoint() --temp
	local _spawnPoint = {
		type = "TakeOffParkingHot",
		form = "From Parking Area Hot",
		action = "From Parking Area Hot",
		airdromeId = 3,
		["task"] = {  --task so that the unit does CAP
			["id"] = 'ComboTask',
			["params"] = { 
				["tasks"] = { 
					[1] = { 
						["enabled"] = true,
						["key"] = 'CAP',
						["id"] = 'EngageTargets',
						["number"] = 1,
						["auto"] = true,
						["params"] = { 
							["targetTypes"] = { 
								[1] = 'Air',
							},
						["priority"] = 0,
						},
					},
				},
			},
		},
	}
	return _spawnPoint
end

function spawnTemp(groupName) --temp just to see if it all works.
	local _args = mist.getGroupData(groupName)

	_args.clone = true
	_args.groupName = "ceptor-" .. simpleCap.capCounter
	simpleCap.capCounter = simpleCap.capCounter + 1

	_args.route = {
		[1] = simpleCap.buildSpawnPoint(),
		[2] = simpleCap.missions[math.random(#simpleCap.missions)],
	}

	simple.dumpTable(_args)
	mist.dynAdd(_args)
end

function simpleCap.repeater()
	simpleCap.buildTargets ()
	simpleCap.buildMissions ()

	spawnTemp(simpleCap.interceptors[1]) --works

	simple.debugOutput ("capRepeater: finished")
end

do
	local repeater = mist.scheduleFunction (simpleCap.repeater, {}, timer.getTime() + simpleCap.updateFreq, simpleCap.updateFreq )
 
	simple.notify("simpleCap finished loading", 15)
end