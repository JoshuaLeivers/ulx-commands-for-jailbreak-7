--[[
    CREDIT:
        Ian Murray - ULX Commands for Jailbreak 7 (original version)
        VulpusMaximus - ULX Commands for Jailbreak 7 (new version); map information
        pepeisdatboi - opencells (original version); map information
        PN-Owen - stopheli and mancannon (original versions); map information
        Coockie1173 - map information
]]

local CATEGORY_NAME = "Jailbreak"
local ERROR_MAP = "That command does not work on this map!"


-- ULX Commands

--[[
function ulx.opencells( calling_ply, close )
    
end
local opencells = ulx.command( CATEGORY_NAME, "ulx opencells", ulx.opencells, { "!opencells", "!open" }, true )
opencells:addParam{ type=ULib.cmds.BoolArg, invisible=true }
opencells:defaultAccess( ULib.ACCESS_ADMIN )
opencells:help( "Opens all cell doors." )
opencells:setOpposite( "ulx closecells", { _, true }, { "!closecells", "!close" }, true )
--]]

--[[
function ulx.stopheli( calling_ply, start )
    
end
local stopheli = ulx.command( CATEGORY_NAME, "ulx stopheli", ulx.stopheli, { "!stopheli", "!stophelicopter" }, true )
stopheli:addParam{ type=ULib.cmds.BoolArg, invisible=true }
stopheli:defaultAccess( ULib.ACCESS_ADMIN )
stopheli:help( "Shuts down the helicopter on new_summer-based maps.")
stopheli:setOpposite( "ulx startheli", { _, true }, { "!startheli" }, true )
]]

--[[
function ulx.mancannon( calling_ply )
    
end
local mancannon = ulx.command( CATEGORY_NAME, "ulx mancannon", ulx.mancannon, { "!mancannon" }, true )
mancannon:defaultAccess( ULib.ACCESS_ADMIN )
mancannon:help( "Opens the mancannon door on jail_summer-based maps.")
]]


-- Helper Functions
--[[
function canControlDoors( map )

end
]]

-- Cell door control maps and entities
--[[
local maps = {
    { "summer", { { "cellopen", "Press" } }, { { "cellclose", "Press" } } },
    { "summer", { { "b1", "Press" } }, { { "celldoor", "Close" } } },
    { "sand", { { "JailDoors", "Open" } }, { { "JailDoors", "Close" } } },
    { "blackops", { { "prisondoor", "Open" } }, { { "prisondoor", "Close" } } },
    { "lego_jail_v4", {
        { "cell1", "Open" },
        { "c_r", "HideSprite" },
        { "c_g", "ShowSprite" },
        { "auto_open", "Disable" }
    },
    {
        { "cell1", "Close" },
        { "c_r", "ShowSprite" },
        { "c_g", "HideSprite" },
        { "auto_open", "Enable" }
    } },
    { "lego", {
        { "c1", "Open" },
        { "c_r", "HideSprite" },
        { "c_g", "ShowSprite" },
        { "auto_open", "Disable" }
    },
    {
        { "c1", "Close" },
        { "c_r", "ShowSprite" },
        { "c_g", "HideSprite" },
        { "auto_open", "Enable" }
    } },
    { "italia", { { "door cells", "Open" } }, { { "door cells", "Close" } } },
    { "electric", { { "Cells_AllOpen", "Trigger" } }, { { "Cells_AllClose", "Trigger" } } },
    { "castleguarddev", { { "Cell_Door_Main", "Open" } }, { { "Cell_Door_Main", "Close" } } },
    { "heat", { { "jd", "Open" } }, { { "jd", "Close" } } },
    { "kittens", {
        { "cell_door_t", "Unlock" },
        { "cell_door_t", "Open" },
        { "cell_light_sprite", "ShowSprite" },
        { "cell_prop_light", "Disable" },
        { "cell_prop_light_on", "Enable" }
    },
    {
        { "cell_door_t", "Unlock" },
        { "cell_door_t", "Close" },
        { "cell_light_sprite", "HideSprite" },
        { "cell_prop_light", "Enable"},
        { "cell_prop_light_on", "Disable" }
    } },
    { "carceris", {
        { "s1", "Open" },
        { "s2", "Open" },
        { "s3", "Open" },
        { "s4", "Open" },
        { "s5", "Open" },
        { "s6", "Open" },
        { "s7", "Open" },
        { "s8", "Open" },
        { "s9", "Open" },
        { "s10", "Open" },
        { "s11", "Open" },
        { "s12", "Open" },
        { "s13", "Open" },
        { "s14", "Open" },
        { "s15", "Open" },
        { "s16", "Open" }
    },
    {
        { "s1", "Close" },
        { "s2", "Close" },
        { "s3", "Close" },
        { "s4", "Close" },
        { "s5", "Close" },
        { "s6", "Close" },
        { "s7", "Close" },
        { "s8", "Close" },
        { "s9", "Close" },
        { "s10", "Close" },
        { "s11", "Close" },
        { "s12", "Close" },
        { "s13", "Close" },
        { "s14", "Close" },
        { "s15", "Close" },
        { "s16", "Close" }
    } },
    { "laser", "celdas.1.puerta", "celdas.2.puerta" },
    { "ishimura", { { "switchprison", "PressIn" } }, { { "switchprison", "PressOut" } } },
    { "alcatraz", {
        { "oben", "Open" },
        { "unten", "Open" }
    },
    {
        { "oben", "Close" },
        { "unten", "Close" }
    } },
    { "parabellum", {
        { "cells", "Open" },
        { "cells_relay", "CancelPending" }
    },
    {
        { "cells", "Close" }
    } },
    { "canyondam", { { "CLDRS_R_1", "Trigger" } }, { { "CLDRS_R_2", "Trigger" } } },
    { "minecraft_beach", {
        { "celldoors_closed", "Disable" },
        { "celldoors_open", "Enable" },
        { "celldoors_button", "Lock" }
    },
    {
        { "celldoors_button", "Unlock" },
        { "celldoors_open", "Disable" },
        { "celldoors_closed", "Enable" }
    } },
    { "sylvan", {
        { "Cell_Doors_1_Full", "Open" },
        { "Cell_Door_Button", "Lock" },
        { "Cell_Doors_1_Broken", "Open" },
        { "solitary_door", "Open" },
        { "CellSOUNDS", "Open" },
        { "Cell_Doors_2_Full", "Open" },
        { "Cell_Doors_2_Broken", "Open" }
    },
    {
        { "Cell_Door_Button", "Unlock" },
        { "Cell_Doors_1_Broken", "Close" },
        { "Cell_Doors_1_Full", "Close" },
        { "solitary_door", "Close" },
        { "CellSOUNDS", "Close" },
        { "Cell_Doors_2_Broken", "Close" },
        { "Cell_Doors_2_Full", "Close" }
    } },
    { "vipinthemix", {
        { "Jaildoor_clip1", "Open" },
        { "Jaildoor_clip2", "Open" },
        { "Jaildoor_clip3", "Open" },
        { "Jaildoor_clip4", "Open" },
        { "Jaildoor_clip5", "Open" },
        { "Jaildoor_clip6", "Open" },
        { "Jaildoor_clip7", "Open" },
        { "Jaildoor_clip8", "Open" },
        { "Jaildoor_clip9", "Open" },
        { "Jaildoor_clip10", "Open" },
        { "Vipcel_door", "Open" }
    },
    {
        { "Jaildoor_clip1", "Close" },
        { "Jaildoor_clip2", "Close" },
        { "Jaildoor_clip3", "Close" },
        { "Jaildoor_clip4", "Close" },
        { "Jaildoor_clip5", "Close" },
        { "Jaildoor_clip6", "Close" },
        { "Jaildoor_clip7", "Close" },
        { "Jaildoor_clip8", "Close" },
        { "Jaildoor_clip9", "Close" },
        { "Jaildoor_clip10", "Close" },
        { "Vipcel_door", "Close" }
    } },
    { "paradise", {
        { "rorating", "Start" },
        { "rorating2", "Start" },
        { "doorjail", "Open"},
        { "trackjail", "StartForward" },
        { "gtgrg", "Toggle" } --This map uses func_wall_toggle, which can only be toggled, not disabled
    },
    {
        { "rorating", "Stop" },
        { "rorating2", "Stop" },
        { "doorjail", "Close" },
        { "trackjail", "StartBackward" }
    } }
}
]]