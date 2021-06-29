--Detection Script by Marc "MBot" Marbot - 8Dec2013

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--	User controll functions. Run these functions in a seperate script *after* executing the Detection Script in order to configure which groups/untis should use it.

--	AddOP(arg1, arg2, arg3, arg4, arg5)			Adds the detection script logic to a group of ground units

--	arg1: group name of group that does visual search; string. Example: "StingerTeam 001"
--	arg2: unit name of unit that provides radar early warning to group above; string. Example: "EWRadar 001". Write inexisting unit name if no ewr should be used. Example: "blabla"
--	arg3: boolean; sets if detection script should controll the ROE of the applied group. Example: true. If set to true, group will only open fire when an aircraft is detected, it will not detect hostile ground units!
--	arg4: boolean; sets if applied group should stop and get off the road when aircraft are detected. Example: true. If set to true, group will always stop moving when hostile aircraft are detected!
--	arg5: boolean; sets if group should concentrate aircraft search on the front sector. Example: true. If set to true, group will more likely detect aircraft approaching from the front and less likely detect aircraft approaching from the rear.

--	Complete example script line: AddOP("Group1", "Unit1", true, false, false)			This lets Group1 search for aircraft with the detection script, Unit1 will provide radar early warning for Group1, Group1 will only fire when aircraft are detected, it will not stop when aircraft are detected, it will evenly search the sky 360°
--	Shortcut: You can use AddOP("GroupName") as a shortcut. This will use the default options of no radar early warning, ROE controlled, no dispersing and 360° search


--	AddEWR(arg1, arg2)			Adds a unit that can act as radar early warning for groups that use the detection script

--	arg1: unit name of unit that provides radar early warning; string. Example: "SearchRadar 001"
--	arg2: boolean; sets if radar passes on target data with an automatic datalink or over voice radio. Example: true. If set to true target data is provided over datalink with a short time delay. If set to false target data is provided over voice radio with a longer time delay.
--
--	Complete example script line: AddEWR("Unit1", true)			This lets Unit1 provide radar early warning with datalink for groups using the Detection Script
--	Shortcut: You can use AddEWR("UnitName") as a shortcut. This will use the default options of no datalink.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


do
	local debug = false																				--Activates debug test mode

	OP = {}																							--Array to hold all groups doing visual search
	
	function AddOP(grp, ew, fc, disp, f)
		OP[#OP + 1] = {
			groupname = grp,																		--Group name
			ewr = ew or "none",																		--Name of parent early warning radar. "none" if unspecified
			firecontrol = fc or true,																--Boolean if script controls groups ROE. true if unspecified
			disperse = disp or false,																--Boolean if script controls dispresion on target detection. false if unspecified
			attention_to_front = f or false,														--Boolean if group spends more attention on front sector at expense of rear sector. false if unspecified
			detect = false,
			continue = true,
		}
		if OP[#OP].firecontrol == true then
			local ctrl = Group.getByName(grp):getController()
			ctrl:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.WEAPON_HOLD)			--Set ROE of OP group to hold fire
		end
	end
	
	
	ewr = {}																						--Array that holds all early warning radars

	function AddEWR(unitName, dl)																	--Function to add new early warning radar
		ewr[#ewr + 1] = {
			name = unitName,																		--Unit name
			dlink = dl or false,																	--Boolean, true == has electronic downlink recipients, false == has radio voice contact with recipients, false if unspecified
			target = {}																				--Array to hold detected targets of EWR
		}
	end

	local function EwrSearch()																		--Building of target lists of ewr. Repeats all 3 seconds (one radar search cylce)
		for n = 1, #ewr do
			ewrUnit = Unit.getByName(ewr[n].name)
			if ewrUnit ~= nil then
				ewrCtrl = ewrUnit:getGroup():getController()
				local DetectedTargets = ewrCtrl:getDetectedTargets(RADAR)
				
				for k = 1, #DetectedTargets do
					local targetDesc = DetectedTargets[k].object:getDesc()
					if targetDesc.category == 0 or targetDesc.category == 1 then
						local targetName = DetectedTargets[k].object:getName()
						if #ewr[n].target == 0 then
							ewr[n].target[1] = {
								name = targetName,
								time = {
									[1] = timer.getTime(),												--Time of current radar hit
									[2] = 0,															--No previous radar hit
									[3] = 0																--No previous radar hit
								},
								newtrack = timer.getTime()												--Time of start of new trackfile
							}
						else
							for l = 1, #ewr[n].target do												--Go through target lits of ewr
								if ewr[n].target[l].name == targetName then								--If target already known
									ewr[n].target[l].time[3] = ewr[n].target[l].time[2]					--Time of second last radar hit
									ewr[n].target[l].time[2] = ewr[n].target[l].time[1]					--Time of last radar hit
									ewr[n].target[l].time[1] = timer.getTime()							--Time of current radar hit
									if timer.getTime() > ewr[n].target[l].time[2] + 30 then				--If last hit is older than 30 seconds
										ewr[n].target[l].newtrack = timer.getTime()						--Time of start of new trackfile
									end
									break	
								elseif l == #ewr[n].target then											--If target is unknown
									ewr[n].target[l + 1] = {
										name = targetName,
										time = {
											[1] = timer.getTime(),										--Time of current radar hit
											[2] = 0,													--No previous radar hit
											[3] = 0														--No previous radar hit
										},
										newtrack = timer.getTime()										--Time of start of new trackfile
									}
								end
							end
						end
					end
				end
				--[[if #ewr[n].target > 0 then	--DEBUG
					trigger.action.outText("Name: " .. ewr[n].target[1].name .. "\nT1: " .. ewr[n].target[1].time[1] .. "\nT2: " .. ewr[n].target[1].time[2] .. "\nT3: " .. ewr[n].target[1].time[3] .. "\nTrack Start: " .. ewr[n].target[1].newtrack, 3)	--DEBUG
				]]--end	--DEBUG
			end
		end
		return timer.getTime() + 3
	end
	timer.scheduleFunction(EwrSearch, nil, timer.getTime() + 1)


	local function DisperseGroup(n)
		local ctrl = Group.getByName(OP[n].groupname):getController()
		local op = Group.getByName(OP[n].groupname):getUnit(1)
		local pos = op:getPosition()
		
		Disperse = {
			id = "ControlledTask", 
			params = {
				task = {
					id = 'Mission', 
					params = { 
						route = { 
							points = { 
								[1] = {
									action = "Off Road",
									x = pos.p.x,
									y = pos.p.z,
									speed = 5.55555
								},
								[2] = {
									action = "EchelonR",
									x = pos.p.x + pos.x.x * 20 + pos.z.x * 20,
									y = pos.p.z + pos.x.z * 20 + pos.z.z * 20,
									speed = 5.55555,
								},
								[3] = {
									action = "Off Road",
									x = pos.p.x + pos.x.x * 40 + pos.z.x * 20,
									y = pos.p.z + pos.x.z * 40 + pos.z.z * 20,
									speed = 5.55555,
								}
							} 
						}
					} 
				},
				stopCondition = {condition = "if OP[" .. n .. "].continue == true then return true end"}
			}
		}
		Controller.pushTask(ctrl, Disperse)
		ctrl:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, false)		--Do not disperse under fire when already dispersed
	end

	
	local function Detection(target, n)
		if target:isActive() == true then
			local op = Group.getByName(OP[n].groupname):getUnit(1)
			local opCoal = op:getCoalition()
			local targetCoal = target:getCoalition()
			if opCoal ~= targetCoal then
				local desc = target:getDesc()
				if desc.category == 0 or desc.category == 1 then														--Target is aircraft or helo
					local opPos = op:getPosition()
					local targetPos = target:getPosition()
					if land.isVisible({ x = opPos.p.x, y = opPos.p.y + 1.5, z = opPos.p.z }, targetPos.p) then			--Target is not terrain masked
						if OP[n].detect == false then																	--If OP is not yet aware to a target, do the target detection calculations
							local output = "Observer: '" .. OP[n].groupname .. "'\n"									--Variable to collect output data for debug
							
							local distH = math.sqrt(math.pow(targetPos.p.x - opPos.p.x, 2) + math.pow(targetPos.p.z - opPos.p.z, 2))
							local dist = math.sqrt(math.pow(distH, 2) + math.pow(targetPos.p.y - opPos.p.y, 2))
							local opTargetLine = {																		--Vector from observer to target
								x = targetPos.p.x - opPos.p.x,
								y = targetPos.p.y - opPos.p.y,
								z = targetPos.p.z - opPos.p.z
							}
							
							local hasEwrCuing = false
							local opEWR = Unit.getByName(OP[n].ewr)
							if opEWR ~= nil then																		--Check if EWR unit assigned to observer exists					
								for a = 1, #ewr do																		--Go through all ewr				
									if ewr[a].name == OP[n].ewr then													--If ewr is assigned to observer						
										for b = 1, #ewr[a].target do													--Go through all targets of ewr							
											if ewr[a].target[b].name == target:getName() then							--If visual target is ewr target
												if timer.getTime() < ewr[a].target[b].time[1] + 30 then					--If last radar hit is not older than 30 seconds									
													if ewr[a].target[b].time[1] < ewr[a].target[b].time[2] + 3.1 and ewr[a].target[b].time[2] < ewr[a].target[b].time[3] + 3.1 then	--Target had at least 3 radar hits in a row. Check should correctly be "Time1 == Time2 + 3" but this sometimes fails. Seems to be a bug with the SSE. "Time1 < Time2 + 3.1" is safer. 	
													--<<<<<< why does this fail after 30 seconds??? >>>>>>	
														if ewr[a].dlink == true then									--If ewr passes on data by datalink
															if timer.getTime() > ewr[a].target[b].newtrack + 10 then	--At least 10 seconds have passed since the start of the new track file (6 seconds for building new track file, passing of data is instant due to datalink, 4 seconds for interpretation of data by observer) 
																hasEwrCuing = true
															end
														else															--If ewr passes on data by voice
															if timer.getTime() > ewr[a].target[b].newtrack + 20 then	--At lest 20 seconds have passed since the start of the new track file (6 seconds for building new track file, 10 seconds for ewr operator to interprete data and sending them over voice radio, 4 seconds for interpretation of data by observer)														
																hasEwrCuing = true
															end
														end
													end
												end
												break
											end
										end
										break
									end
								end
							end
							
							local mtd
							if hasEwrCuing == false then
								mtd = math.pow(2, (dist / 750))															--mean time until detection at a given distance and 360° sector
								output = output .. "EWR target cuing: no\n"
							else
								mtd = math.pow(2, (dist / 5000)) * 5													--mean time until detection at a given distance and 30° sector
								output = output .. "EWR target cuing: yes\n"
							end
							
							local p = 1 / mtd																			--Probability per second
							
							output = output .. "Target distance: " .. math.floor(dist).. " m / Mean Time for Detection = " .. math.floor(1/p) .. " s\n"
							
							
							--modify p on target direction
							if OP[n].attention_to_front == true then													--Observer doubles attention to front and halfes attention to rear
								local targetDir = math.deg(math.acos((opTargetLine.x * opPos.x.x + opTargetLine.z * opPos.x.z) / distH))	--Target direction in degrees off the observer's nose
								if targetDir <= 45 then																	--Target in frontal quarter of observer
									p = p * 2																			--Chance to detect target double (equals 45% of total attention)
									output = output .. "Offset: " .. math.floor(targetDir) .. "° front quadrant / Mean Time for Detection = " .. math.floor(1/p) .. " s \n"
								elseif targetDir > 45 and targetDir <= 135 then											--Target in left or right quarter of observer
									p = p																				--Chance to detect target stay the same (equals 22% of total attention for each side)
									output = output .. "Offset: " .. math.floor(targetDir) .. "° side quadrant / Mean Time for Detection = " .. math.floor(1/p) .. " s\n"
								else																					--Target in rear quarter of observer
									p = p / 2																			--Chance to detect target half (equals 11% of total attention)
									output = output .. "Offset: " .. math.floor(targetDir) .. "° rear quadrant / Mean Time for Detection = " .. math.floor(1/p) .. " s\n"
								end
							end
						
					
							--modify p for target elevation
							local elevationAngle = math.deg(math.atan((targetPos.p.y - opPos.p.y) / distH))
							output = output .. "Elevation " .. math.floor(elevationAngle * 10) / 10 .. "° "
							if elevationAngle > 20 then																	--If target is above 20° elevation angle from observer
								p = p / elevationAngle * 20																--Detection propability is reduced
								output = output .. "/ high elevation penality / Mean Time for Detection = " .. math.floor(1/p) .. " s"
							elseif elevationAngle < 1 then																--If target is below 1° elevevation angle from observer, target is in abstracted ground clutter masking
								p = p / ((elevationAngle - 1) * -10)													--Detection propability is reduced
								output = output .. "/ terrain clutter penality / Mean Time for Detection = " .. math.floor(1/p) .. " s"
							end
							output = output .. "\n"
							
					
							--modify p for target background
							if land.getIP({ x = opPos.p.x, y = opPos.p.y + 1, z = opPos.p.z }, opTargetLine, 100000) ~= nil then	--If the target is seen against terrain background
								p = p / 3
								output = output .. "Terrain background penalty / Mean Time for Detection = " .. math.floor(1/p) .. " s\n"
							end
							
						
							--modify p for angular speed
							local targetVelocityVec = target:getVelocity()
							local opTargetLine2 = {																		--Vector from observer to position of target in 1 second
								x = opTargetLine.x + targetVelocityVec.x,
								y = opTargetLine.y + targetVelocityVec.y,
								z = opTargetLine.z + targetVelocityVec.z
							}
							local dist2 = math.sqrt(math.pow(opTargetLine2.x, 2) + math.pow(opTargetLine2.y, 2) + math.pow(opTargetLine2.z, 2))
							local scalar = (opTargetLine.x * opTargetLine2.x ) + (opTargetLine.y * opTargetLine2.y ) + (opTargetLine.z * opTargetLine2.z)
							local alpha = math.deg(math.acos(scalar / (dist * dist2)))									--Alpha is the angle between current target position and target position in 1 second as seen from the observer (angular speed)
							p = p + p * alpha / 14
							output = output .. "Target angular speed: " .. math.floor(alpha * 10) / 10 .. "°/s / Mean Time for Detection = " .. math.floor(1/p) .. " s\n"
							
							
							--modify p on OP group strenght
							local opGroup = Group.getByName(OP[n].groupname):getUnits()
							local opGroupN = #opGroup																	--Number of units in OP group
							p = p * opGroupN																			--More lookers in group increase chance of detection
							output = output .. "Units in group: " .. opGroupN .. " / Mean Time for Detection = " .. math.floor(1/p) .. " s\n"
							
							
							local rando = math.random(0, 1000)
							output = output .. "Probability of detection: " .. math.floor(p * 100 * 100) / 100 .. " %\nRando: " .. rando .. "\n"
							if p * 1000 > rando then
								if OP[n].firecontrol == true then
									local ctrl = Group.getByName(OP[n].groupname):getController()
									ctrl:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.OPEN_FIRE)		--Set ROE of OP group to open fire
								end
								if OP[n].disperse == true then
									OP[n].continue = false
									DisperseGroup(n)
								end
								OP[n].detect = true
								OP[n].lastdetection = timer.getTime()
								output = ouput .. "\nTarget detected."
							else
								output = output .. "\nTarget not detected."
							end
							if debug == true then
								trigger.action.outText(output, 1)
							end
						else																							--Once one target is detected, OP remains aware of all targets within range and LOS
							OP[n].lastdetection = timer.getTime()
							if debug == true then
								trigger.action.outText("'" .. OP[n].groupname .. "' target detected.", 1)
							end
						end
					else
						if debug == true then
							trigger.action.outText("'" .. OP[n].groupname .. "' is terrain masked.", 1)
						end
					end
				end
			end
		end
		return true
	end
	
	
	local function AirSearch()
		for n = 1, #OP do
			local grp = Group.getByName(OP[n].groupname)
			if grp ~= nil then
				local unit = grp:getUnit(1)
				if unit ~= nil then
					if unit:isActive() == true then
						local unitPoint = unit:getPoint()
						local SearchArea = {
							id = world.VolumeType.SPHERE,
							params = {
								point = unitPoint,
								radius = 12000
							}
						}
						world.searchObjects(Object.Category.UNIT, SearchArea, Detection, n)

						if OP[n].detect == true then																			--OP remains detect for 20seconds after last detection of a target until going back to detection mode
							if timer.getTime() > OP[n].lastdetection + 20 then
								local ctrl = Group.getByName(OP[n].groupname):getController()
								if OP[n].firecontrol == true then
									ctrl:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.WEAPON_HOLD)				--Set ROE of OP group to hold fire
								end
								if OP[n].disperse == true then
									OP[n].continue = true
									ctrl:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, true)								--Disperse under fire again
								end
								if debug == true then
									trigger.action.outText("'" .. OP[n].groupname .. "' resumes search.", 1)
								end
								OP[n].detect = false
							end
						end
					end
				end
			end
		end
		return timer.getTime() + 1
	end
	timer.scheduleFunction(AirSearch, nil, timer.getTime() + 1)

end