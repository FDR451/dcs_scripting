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
simpleCap.updateFreq = 60

simpleCap.interceptors = {"Mig-1"}

function simpleCap.buildTargets () --takes the output from simpleEwr and adds more data fields, but runs more rarely. This way it should have less performance impact
	local _ewrTargets = simpleEwr.getKnownTargets()
	for id, data in pairs (_ewrTargets) do

		local _args = {
			targetInUse = false,

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
				["id"] = id, --not part of the WP itself, but might be useful later on
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

function simpleCap.repeater()
	simpleCap.buildTargets ()
	simpleCap.buildMissions ()

	s1:getMission() --temp

	simple.debugOutput ("capRepeater: finished")
end

--[[

	squadrons: probably object orientated
	attributes:
	tasking (AA, AG, multi role), homebase, resources (number of aircraft as for a start), airframes


]]

simpleCap.squadron = {
	name = 'default',
	spawnCounter = 1,
	homebase = 3, --home base ID see
	task = 'gci', --general purpse of the squadron
	number = 0, --number of available airframes (spawns)
	template = {"Mig-1"}, --what templates to use
}

function simpleCap.squadron:new (args)
    args = args or {}   -- create object if user does not provide one
    setmetatable(args, self)
    self.__index = self

	simple.debugOutput('New squadron created. Name:' .. args.name .. '; homebase: ' .. args.homebase .. '; tasking: ' .. args.task .. '; number: ' .. args.number .. '; template: ' .. args.template[1])
    return args
end

function simpleCap.squadron:genSpawnCapWp()
	local _spawnPoint = {
		['type'] = "TakeOffParkingHot",
		['form'] = "From Parking Area Hot",
		['action'] = "From Parking Area Hot",
		['airdromeId'] = self.homebase,
		["task"] = {  --task so that the unit does CAP (enroutetask)
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

function simpleCap.squadron:genCapMissionWp()

end

function simpleCap.squadron:getMission()
	if simpleCap.missions ~= {} then --missions are available

		local _mission = {
			[1] = self:genSpawnCapWp(), --spawn WP
			[2] = simpleCap.missions[math.random(#simpleCap.missions)]  --mission WP
		}

		self:spawn(_mission)

	else --no missions available
		simple.debugOutput('no missions found')
	end

end

function simpleCap.squadron:spawn(mission)
	local _groupData = mist.getGroupData(self.template[math.random(#self.template)])
	_groupData.clone = true
	_groupData.groupName = self.name .. "-" .. self.spawnCounter
	self.spawnCounter = self.spawnCounter + 1

	_groupData.route = mission

	simple.dumpTable(_groupData)
	mist.dynAdd(_groupData)
end



do
	local repeater = mist.scheduleFunction (simpleCap.repeater, {}, timer.getTime() + simpleCap.updateFreq, simpleCap.updateFreq ) --starts the repeater

	s1 = simpleCap.squadron:new {name = 'hummus', homebase = 3, task = 'gci', number = 2, template = {"Mig-1"} }

	--mist.scheduleFunction (s1.getMission(), {s1}, timer.getTime() + 180, 180 ) --temp testing

	simple.notify("simpleCap finished loading", 15) --keep at the end of the file
end