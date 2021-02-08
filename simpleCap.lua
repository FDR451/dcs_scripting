--[[
	A simple dispatcher to be used togehter with simpleEwr
	v0.1
]]

simpleCap = {}
simpleCap.targets = {}
simpleCap.missions = {}
simpleCap.updateFreq = 12
simpleCap.ato = {}
simpleCap.repeaterTable = {}

simpleCap.interceptors = {"Mig-1"}

function simpleCap.buildTargets () --takes the output from simpleEwr and adds more data fields, but runs more rarely. This way it should have less performance impact
	local _ewrTargets = simpleEwr.getKnownTargets()
	for id, data in pairs (_ewrTargets) do
		--if data.inZone == true then --only build target list for targets that are in the zone

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
		--end
	end
	--simple.dumpTable(simpleCap.targets)
end

function simpleCap.genAto()
	for id, data in pairs (simpleCap.targets) do
		simple.dumpTable(simpleCap.targets)
		if data.targetInZone == true then

			if simpleCap.ato[id] == nil then --adds a new entry
				local _args = {
					targetId = data.targetId,
					inUse = false,
					status = 'open',
					squadron = '',
					group = ''
				}
				simpleCap.ato[id] = _args
			else --already got an entry

			end

		else --not in Zone anymore
			simpleCap.ato[id] = nil
		end
	end
	simple.debugOutput('genAto: finished')
end

function simpleCap.repeater()
	
	simpleCap.buildTargets ()
	simpleCap.genAto()
	
	for k, v in pairs (simpleCap.repeaterTable) do
		v.func(v.args)
	end
	


	simple.debugOutput ("capRepeater: finished")
end

--[[

	squadrons: probably object orientated
	attributes:
	tasking (AA, AG, multi role), homebase, resources (number of aircraft as for a start), airframe

]]

simpleCap.squadron = {
	name = 'default',
	spawnCounter = 0,
	homebase = 0, --home base ID see
	task = '', --general purpse of the squadron
	ressources = 0, --number of available airframes (spawns)
	template = {}, --what templates to use
}

function simpleCap.squadron:new (args)
    args = args or {}   -- create object if user does not provide one
    setmetatable(args, self)
    self.__index = self

	simple.debugOutput('New squadron created. Name:' .. args.name .. '; homebase: ' .. args.homebase .. '; tasking: ' .. args.task .. '; ressources: ' .. args.ressources .. '; template: ' .. args.template[1])
    return args
end

function simpleCap.squadron:checkIn() --should be part of new, but doesn't want to work...
	simpleCap.repeaterTable[#simpleCap.repeaterTable + 1] = {
		func = self.checkAto,
		args = self,
	}
end

function simpleCap.squadron.checkAto(self)
	if self.ressources >= 1 then
		for id, data in pairs (simpleCap.ato) do
			if data.inUse == false then
				simpleCap.ato[id].inUse = true
				simpleCap.ato[id].status = 'in process'
				simpleCap.ato[id].squadron = self.name

				local _groupName = self:genMission(id)

				simpleCap.ato[id].group = _groupName

				simple.debugOutput('checkAto: ' .. self.name .. '-squadron is generating a mission.')
			elseif data.inUse == true then
				simple.debugOutput('checkAto: ' .. self.name .. '-squadron could NOT find a suitable target.')
			end
		end
	else
		simple.debugOutput('checkAto: ' .. self.name .. '-squadron has ' .. self.ressources .. ' airframes.')
	end
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

function simpleCap.squadron:genCapMissionWp(targetId)
	local _targetWp = {
		["alt"] = 4000, --high enough not to have problems anywhere in DCS
		["x"] = simpleCap.targets[targetId].targetIntPosVec2.x,
		["y"] = simpleCap.targets[targetId].targetIntPosVec2.y,
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
	return _targetWp
end

function simpleCap.squadron:genMission(targetId) --in use does not work, because simpleCap overrides the function again and again, need a better solution
	local _mission = {
		[1] = self:genSpawnCapWp(),
		[2] = self:genCapMissionWp(targetId),
	}

	local _spawnedGroup = self:spawn(_mission)
	self.ressources = self.ressources - 1
	return _spawnedGroup
end

function simpleCap.squadron:spawn(mission)
	local _groupData = mist.getGroupData(self.template[math.random(#self.template)])
	_groupData.clone = true
	_groupData.groupName = self.name .. "-" .. self.spawnCounter
	self.spawnCounter = self.spawnCounter + 1

	_groupData.route = mission

	--simple.dumpTable(_groupData)
	mist.dynAdd(_groupData)
	return _groupData.groupName
end



do
	local repeater = mist.scheduleFunction (simpleCap.repeater, {}, timer.getTime() + simpleCap.updateFreq, simpleCap.updateFreq ) --starts the repeater

	s1 = simpleCap.squadron:new {name = 'Hummus', homebase = 3, task = 'gci', ressources = 2, template = {"Mig-1"} }
	s1:checkIn()
	s2 = simpleCap.squadron:new {name = 'Couscous', homebase = 4, task = 'gci', ressources = 2, template = {"Mig-1"} }
	s2:checkIn()

	simple.notify("simpleCap finished loading", 15) --keep at the end of the file
end