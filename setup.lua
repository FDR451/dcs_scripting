--[[
    moved setup stuff here to make it easier to explain and test stuff, instead of keeping it split accross all files
]]

do
    --simpleEwr

    simpleEwr.addEwrByPrefix("EWR")
    simpleEwr.setDetectionZone("poly")
    simpleEwr.setSafeAltitude(1000)
    simpleEwr.setTimeInMemory (60)

    --simpleCap

    s1 = simpleCap.squadron:new {name = 'Hummus', homebase = 3, task = 'gci', ressources = 2, template = {"Mig-1"} }
	s1:checkIn()
	s2 = simpleCap.squadron:new {name = 'Couscous', homebase = 4, task = 'gci', ressources = 3, template = {"Mig-1"} }
	s2:checkIn()
	simpleCap.setUpdateRate (12)

end