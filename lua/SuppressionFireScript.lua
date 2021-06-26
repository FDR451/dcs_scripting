--Suppression Script by Marc "MBot" Marbot v20Dec2013

do

	local SuppressedGroups = {}	--Table to temporary store data for suppressed groups
	
	--Function to end suppression and let group open fire again
	local function SuppressionEnd(id)
		id.ctrl:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.OPEN_FIRE)
		SuppressedGroups[id.groupName] = nil
		--trigger.action.outText(id.groupName .. " suppression end", 2)	--Info for debug
	end

	--Function to run suppress a group
	local function SuppressGroup(tgt)
		local delay = math.random(15, 45)	--Time in seconds the group of a hit unit will be unable to fire
		
		local id = {
			groupName = tgt:getGroup():getName(),
			ctrl = tgt:getGroup():getController()
		}
		
		if SuppressedGroups[id.groupName] == nil then	--If group is currently not suppressed, add to table.
			SuppressedGroups[id.groupName] = {
				SuppressionEndTime = timer.getTime() + delay,
				SuppressionEndFunc = nil
			}
			SuppressedGroups[id.groupName].SuppressionEndFunc = timer.scheduleFunction(SuppressionEnd, id, SuppressedGroups[id.groupName].SuppressionEndTime)	--Schedule the SuppressionEnd() function	
		else	--If group is already suppressed, update table and increase delay
			local timeleft = SuppressedGroups[id.groupName].SuppressionEndTime - timer.getTime()	--Get how long to the end of the suppression
			local addDelay = (delay / timeleft) * delay	--The longer the suppression is going to last, the smaller it is going to be increased by additional hits
			if timeleft < delay then	--But if the time left is shorter than a complete delay, add another full delay
				addDelay = delay
			end
			SuppressedGroups[id.groupName].SuppressionEndTime = SuppressedGroups[id.groupName].SuppressionEndTime + addDelay
			timer.setFunctionTime(SuppressedGroups[id.groupName].SuppressionEndFunc, SuppressedGroups[id.groupName].SuppressionEndTime)	--Update the execution time of the existing instance of the SuppressionEnd() scheduled function
		end
		
		id.ctrl:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.WEAPON_HOLD)	--Set ROE weapons hold to initate suppression
		--trigger.action.outText(id.groupName .. " suppressed until " .. SuppressedGroups[id.groupName].SuppressionEndTime, 2)	--Info for debug
	end
	
	--Handler to get when units are hit
	SuppressionHandler = {}
	function SuppressionHandler:onEvent(event)
		if event.id == world.event.S_EVENT_HIT then
			local tgt = event.target
			local tgtType = tgt:getTypeName()
			if tgt:hasAttribute("Infantry") or tgt:hasAttribute("Static AAA") or (tgtType == "Ural-375 ZU-23") then	--Check if hit unit is infantry, static or mobile ZU-23
				SuppressGroup(tgt)	--Run suppression of hit unit (group)
			end
		end
	end
	world.addEventHandler(SuppressionHandler)
	
end