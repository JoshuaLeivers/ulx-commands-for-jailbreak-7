local cellDoorMap = {

  ["jb%_new%_summer"] = {"cells"},

  ["ba%_jail%_sand"] = {"JailDoors"},

  ["ba%_jail%_blackops"] = {"prisondoor"},
  
  ["jb%_lego%_jail%_pre%_v6%-2"] = {"c1"},

  ["jb%_lego%_jail"] = {"cell1"},

  ["jb%_italia"] = {"door cells"},

  ["ba%_jail%_electric%_aero"] = {"Cells_ForceFieldEmitter","Cells_ForceFields"},

  ["jb%_carceris"] = {"s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16"},

  ["ba%_jail%_laser"] = {"celdas.1.puerta","celdas.2.puerta"},

  ["ba%_jail%_ishimura"] = {"PrisonDoor"},

  ["ba%_jail%_alcatraz"] = {"oben","unten"},

  ["jb%_parabellum"] = {"cells"},
  
  ["jb%_vipinthemix"] = {
"Jaildoor_clip1",
"Jaildoor_clip2",
"Jaildoor_clip3",
"Jaildoor_clip4",
"Jaildoor_clip5",
"Jaildoor_clip6",
"Jaildoor_clip7",
"Jaildoor_clip8",
"Jaildoor_clip9",
"Jaildoor_clip10",
"Vipcel_door"
}

}



local CATEGORY_NAME = "Jailbreak"

function ulx.helicopter(calling_ply)
    if game.GetMap():find("jb%_new%_summer") then
        for k,v in ipairs(ents.FindByName("huey_blade")) do
            v:Fire("Stop",1)
        end
        for k,v in ipairs(ents.FindByName("helidoor")) do
            v:Fire("Close",1)
        end
        ulx.fancyLogAdmin(calling_ply,"#A stopped the helicopter")
    else
        ULib.tsayError(calling_ply,"That command only works on new_summer!")
    end
end
local helicopter = ulx.command(CATEGORY_NAME,"ulx helicopter",ulx.helicopter,{"!choppa","!heli","!helicopter"})
helicopter:defaultAccess(ULib.ACCESS_ADMIN)
helicopter:help("Shuts down the helicopter on new_summer")

function ulx.mancannon(calling_ply)
    if game.GetMap():find("jb%_new%_summer") then
        for k,v in ipairs(ents.FindByName("suicideD1")) do
            v:Fire("Unlock",1)
            v:Fire("Open",1)
        end
    else
        ULib.tsayError(calling_ply,"That command only works on new_summer!")
    end
    ulx.fancyLogAdmin(calling_ply,"#A opened the mancannon door")
end
local mancannon = ulx.command(CATEGORY_NAME,"ulx mancannon",ulx.mancannon,{"!omc","!openmc","!mancannon","!openmancannon"})
mancannon:defaultAccess(ULib.ACCESS_ADMIN)
mancannon:help("Open the mancannon on new_summer")

function ulx.opencells(calling_ply)
  local doorsopened = false
	for map,doors in pairs(cellDoorMap) do
		if game.GetMap():find(map) then
			for k,door in pairs(cellDoorMap[map]) do
				for _,v in ipairs(ents.FindByName(door)) do
                    v:Fire("Open",1)
                    v:Fire("Disable",1)
        end
      end
      ulx.fancyLogAdmin(calling_ply,"#A opened cell doors")
      return
		end
	end
    ULib.tsayError(calling_ply,"This command does not work on this map!",true)
end
local opencells = ulx.command(CATEGORY_NAME,"ulx opencells",ulx.opencells,{"!opencells","!cells"})
opencells:defaultAccess(ULib.ACCESS_ADMIN)
opencells:help("Opens the cell doors")
