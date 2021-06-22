hindsight = {}
hindsight.actRange = 10000 --30km
hindsight.updateRate = 3 --seconds
hindsight.probability = 0.5
hindsight.targetsMax = 3
hindsight.targets = {}
hindsight.playerAircraft = {"Damascus_tester"}

function hindsight.addTargetByName (groupName) --main function for adding units to the table
    if Group.getByName(groupName) then --existing unit
        table.insert(hindsight.targets, groupName)
        simple.debugOutput("addTargetByName: Added " .. groupName .. " to targetUnitList. New table lenght is " .. #hindsight.targets)
    else --unit does not exist
        simple.errorOutput("addTargetByName: Tried to add a group to target table that does not exist. groupname: " .. groupName .. " has not been added to the table!")
    end
end

function hindsight.addTargetByPrefix (prefix)
    for groupName, groupTable in pairs (mist.DBs.groupsByName) do
        local _prefixPos = string.find(groupName, prefix, 1, true)
        if _prefixPos and _prefixPos == 1 then
            if Group.getByName(groupName) then --check if unit exists and is the first one in the group
                hindsight.addTargetByName(groupName)
            end
		end
    end
end

function hindsight.start()
    local counter = 0
    for key, groupName in pairs (hindsight.targets) do
        counter = counter + 1
        mist.scheduleFunction(hindsight.isTargetInRange, {groupName}, timer.getTime() + counter * hindsight.updateRate)
    end
end

function hindsight.isTargetInRange(groupName) --check the distance between the target and all player aircraft, if one is within range activate
    if hindsight.targetsMax > 0 then

        local _targetPos = Group.getByName(groupName):getUnit(1):getPoint()
        for key, value in pairs (hindsight.playerAircraft) do
            local _playerPos = Group.getByName(value):getUnit(1):getPoint()
            local _distance = mist.utils.get2DDist(_targetPos, _playerPos)
            simple.debugOutput(groupName .. " distance: " .. _distance)

            if _distance <= hindsight.actRange then -- in range

                if math.random(0, 1) <= hindsight.probability then --in range but spawning
                    simple.debugOutput(groupName .. ": in range, activating")
                    hindsight.targetsMax = hindsight.targetsMax - 1
                    Group.getByName(groupName):activate()
                else --in range but not spawning
                    simple.debugOutput(groupName .. ": in range, NOT activating")
                end
                break

            else --not in range, reschedule
                simple.debugOutput(groupName .. ": not in range, rescheduling")
                mist.scheduleFunction(hindsight.isTargetInRange, {groupName}, timer.getTime() + #hindsight.targets * hindsight.updateRate)       
            end
        end

    end
end


do
    hindsight.addTargetByPrefix("red_")
    hindsight.start()

    simple.debugOutput("hindsight loaded")
end