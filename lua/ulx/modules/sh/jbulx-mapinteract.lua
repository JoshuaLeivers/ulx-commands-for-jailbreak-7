local cellDoorMap = {

  ["jb_new_summer_v2"] = {"cells"},

  ["ba_jail_sand_v3"] = {"JailDoors"},

  ["ba_jail_blackops"] = {"prisondoor"},
  
  ["jb_new_summer_v3"] = {"cells"},

  ["jb_lego_jail_v4"] = {"cell1"},
  
  ["jb_lego_jail_pre_v6-2"] = {"c1"},

  ["jb_italia_beta4"] = {"door cells"},

  ["jb_italia_final"] = {"door cells"},

  ["ba_jail_electric_aero_v1_1"] = {"Cells_ForceFieldEmitter","Cells_ForceFields"},

  ["jb_carceris"] = {"s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16"},

  ["jb_carceris_final_fixed"] = {"s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16"},

  ["ba_jail_laser_v4b"] = {"celdas.1.puerta","celdas.2.puerta"},

  ["jb_parabellum_xg_2"] = {"cells"},

  ["jb_parabellum_xg_v1-1"] = {"cells"},

  ["jb_vipinthemix_v1_2"] = {
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

function ulx.togglecells(calling_ply)
	for map,door in pairs(cellDoorMap[game.GetMap()]) do
		if game.GetMap():find("jb%_carceris") then
			for _,v in ipairs(ents.FindByName(door)) do
				v:Fire("Open",1)
			end
		else
			for _,v in ipairs(ents.FindByName(door)) do
				v:Fire("Toggle",1)
			end
		end
	end
	if game.GetMap():find("jb%_carceris") then
		ULib.tsayError(calling_ply,"[INFO] Cells can only be opened on this map.")
	end
	ulx.fancyLogAdmin(calling_ply,"#A toggled cell doors")
end
local togglecells = ulx.command(CATEGORY_NAME,"ulx togglecells",ulx.togglecells,{"!togglecells","!cells"})
togglecells:defaultAccess(ULib.ACCESS_ADMIN)
togglecells:help("Toggle whether the cell doors are open")
