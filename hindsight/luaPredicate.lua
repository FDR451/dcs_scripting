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