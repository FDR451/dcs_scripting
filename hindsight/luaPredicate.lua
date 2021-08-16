if simple.isUnitTableInZone("0_BeqaaValley", ctld.transportPilotNames) >= 1 then
    return true
else
    return false
end

if simple.isUnitTableInZone("1_combatTrigger", ctld.transportPilotNames) >= 1 then
    return true
else
    return false
end

if simple.isUnitTableInZone("2_combatTrigger", ctld.transportPilotNames) >= 1 then
    return true
else
    return false
end

if simple.isUnitTableInZone("3_combatTrigger", ctld.transportPilotNames) >= 1 then
    return true
else
    return false
end

--victory
if simple.isGroupTableInZone("hospitalWpZone-1", ctld.extractableGroups) >= 1 then
    return true
else
    return false
end

ctld.createRadioBeaconAtZone("hospitalWpZone-1","blue", 14400,"refugee camp")



pb.newBeacon("refugeeCampMorse.wav", mist.utils.zoneToVec3("hospitalWpZone-1"), "AM", true, 000300000, 100, "refCamp")

--test
trigger.action.radioTransmission("l10n/DEFAULT/Soviet_Anthem_Instrumental_1955.ogg" , mist.utils.zoneToVec3("hospitalWpZone-1") , 0 , true , 300000000 , 100 , "beaconTest")