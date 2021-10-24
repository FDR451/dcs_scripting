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





--test
trigger.action.radioTransmission("l10n/DEFAULT/Soviet_Anthem_Instrumental_1955.ogg" , mist.utils.zoneToVec3("hospitalWpZone-1") , 0 , true , 300000000 , 100 , "beaconTest")

pb.newBeacon("refugeeCampMorse.wav", mist.utils.zoneToVec3("farp_north"), "FM", true, 030000000, 100, "farp2") --r828 testing
--ADFs
pb.newBeacon("refugeeCampMorse.wav", mist.utils.zoneToVec3("hospitalWpZone-1"), "AM", true, 000300000, 100, "refCamp")

pb.newBeacon("beirut_farp.wav", mist.utils.zoneToVec3("BeirutFarpAdf"), "AM", true, 000330000, 100, "beirutFarpAdf")

pb.newBeacon("checkpoint.wav", mist.utils.zoneToVec3("checkpointAdf"), "AM", true, 000451000, 100, "checkpointAdf")

--crocodile
pb.newBeacon("antakya.wav", mist.utils.zoneToVec3("antakya_adf"), "AM", true, 000235000, 100, "antakyaAdf")

pb.newBeacon("355.wav", mist.utils.zoneToVec3("jisr-ash-shughur_adf"), "AM", true, 000355000, 100, "jisrAdf")

pb.newBeacon("438.wav", mist.utils.zoneToVec3("taftanaz_adf"), "AM", true, 000438000, 100, "taftanazAdf")