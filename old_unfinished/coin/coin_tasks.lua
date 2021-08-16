tasks = {}

tasks.allTasks = {
    FireAtPoint = { 
        id = 'FireAtPoint', 
        params = { 
          point = Vec2,
          radius = 500, 
          expendQty = 1e10,
          expendQtyEnabled = true, 
          --weaponType = number, --might not be needed
        }
       },
}

function tasks.moveToVec3(groupName, vec3)
	local _groupVec3  = Group.getByName(groupName):getUnit(1):getPoint()
	local _vec3GL = mist.utils.makeVec3GL(vec3)
	local path = {}
	path[#path + 1] = mist.ground.buildWP (_groupVec3)
	path[#path + 1] = mist.ground.buildWP (_vec3GL)
	
	mist.goRoute(groupName, path)

	--debugNotify("moveToVec3 func finished")
end

function tasks.moveToVec3onRoad(groupName, vec3, speed)
	local _groupVec3  = Group.getByName(groupName):getUnit(1):getPoint()
	local _vec3GL = mist.utils.makeVec3GL(vec3)
	local path = {}
	path[#path + 1] = mist.ground.buildWP (_groupVec3, "On Road", speed)
	path[#path + 1] = mist.ground.buildWP (_vec3GL, "On Road", speed)
	
	mist.goRoute(groupName, path)

	--debugNotify("moveToVec3onRoad func finished")
end


function tasks.retreatGroup(zoneNumber) --doesn't work for immoveable (mortar units maybe?)
	mist.scheduleFunction (deleteGroup, {zoneNumber}, timer.getTime() + destTimer)
	tasks.moveToVec3(zoneTable[zoneNumber].inUse, zoneTable[zoneNumber].retreatVec3)
	debugNotify ( zoneTable[zoneNumber].inUse .. " is retreating" )

	--test:
	--tasks.getAmmoNumber(zoneNumber)
end

function tasks.getAmmoNumber(zoneNumber) --retruns the amount of ammo for the main gun
	local _ammo = 0
	local _group = Group.getByName(zoneTable[zoneNumber].inUse)	
	if _group:getUnit(1):getAmmo() then --dcs "removes" weapon [1] once it is out of ammo... W H Y ?
		_ammo = _group:getUnit(1):getAmmo()[1]["count"] --works
	end
	--debugNotify("Ammo: " .. _ammo)
	return _ammo
end

function tasks.readDcsTable(zoneNumber) --purely for information, not useful in a mission. 
	local _searchTable = Group.getByName(zoneTable[zoneNumber].inUse):getUnit(1):getAmmo()
	debugNotify("________________________________________________")

	for k, v in pairs (_searchTable[1].desc) do
		debugNotify("k: " .. tostring(k) .. "; v: " .. tostring(v))
	end

	debugNotify("________________________________________________")
end

function tasks.fireAtVec3 (groupName, vec3, zoneNumber) --works in testing
	local _controller = Group.getByName(groupName):getController()
	local _task = tasks.allTasks.FireAtPoint

	local _targetVec2 = mist.utils.makeVec2 ( vec3 )

	_task.params.point = _targetVec2
	_controller:pushTask(_task)

	repeatTable[zoneNumber] = {
		args = { groupName = groupName, vec3 = vec3, zoneNumber = zoneNumber },
		func = tasks.repCheckAmmo
	}
	debugNotify("fireAtVec3 finished")
end

function tasks.repCheckAmmo (args)
	--debugNotify("checkAmmoStart")
	local _ammo = tasks.getAmmoNumber(args.zoneNumber)
	if _ammo ~= 0 then --out of ammo --nil testing
		debugNotify(_ammo .. " rounds remaining")
	else
		tasks.retreatGroup (args.zoneNumber)
		repeatTable[args.zoneNumber] = nil --to avoid unnecessary checks
		debugNotify(_ammo .. " rounds remaining. Out of ammonition")
	end
end

--[[
	suicide car bomb task
]]

function tasks.suicideBomb (groupName, vec3, zoneNumber) --works
	tasks.moveToVec3onRoad(groupName, vec3, 50)

	repeatTable[zoneNumber] = { --starts the repeated check to see if it is close to the objective
		args = {groupName = groupName, vec3 = vec3, zoneNumber = zoneNumber},
		func = tasks.repSuicideBombCheck,
	}

	debugNotify("suicide bomb finished")
end

function tasks.repSuicideBombCheck (args)
	local groupVec3 = Group.getByName(args.groupName):getUnit(1):getPoint()
	local dist = mist.utils.get3DDist ( groupVec3 , args.vec3 )
	if dist <= math.random (100, 400) then

		trigger.action.explosion(groupVec3 , 1000)
		deleteGroup (args.zoneNumber)
		debugNotify("boom :)")
	else 
		debugNotify("notboom :( distance: " .. dist)
	end
end

--[[
	general attack task
]]

function tasks.attackPosition (groupName, vec3, zoneNumber)

	--check if it can attack a position from it's current pos
	--if not move closer, then check again
	--maybe check to find a suitable attack position
	--repeat until it can attack

end