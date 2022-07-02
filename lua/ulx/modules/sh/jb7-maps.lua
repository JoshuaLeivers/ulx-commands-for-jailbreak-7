--[[
    INFO:
        This module is for allowing admins to control the map, such as cell doors.
    CREDIT:
        Ian Murray - ULX Commands for Jailbreak 7 (original version)
        VulpusMaximus - ULX Commands for Jail Break 7 (new version); map information
        pepeisdatboi - opencells (original version); map information
        PN-Owen - stopheli and mancannon (original versions); map information
        Coockie1173 - map information
]]

local CATEGORY_NAME = "Jail Break"
local ERROR_MAP = "That command does not appear to work on this map!"


-- Cell door control maps and entities

--[[
    Each cell door config takes the following format:
        {["maps"]=LIST_OF_MAP_NAME_REGEX, ["open"]=ARRAY_OF_CELL_OPEN_TARGETS, ["close"]=ARRAY_OF_CELL_CLOSE_TARGETS, ["status"]=ARRAY_OF_CELL_STATUS_TARGETS}
    See below for what each of these things should look like.

    Example ARRAY_OF_MAP_NAME_MATCHES:
        {"jb_lego_RAGE", "jb_lego_jail", "jb_lego_.+_a20"}
    This should just be a list of any regex patterns for matching map names that a config should be valid for.
    For example, the above would match maps like jb_lego_jail_v4. jb_lego_rage_a20, etc.
    This is useful for capturing different versions of the same map, or maybe different maps by the same creator if they stuck with the same format for different maps of theirs.

    Example ARRAY_OF_CELL_OPEN_TARGETS/ARRAY_OF_CELL_CLOSE_TARGETS entry:
        {["name"] = "cell1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}
    The name is the name of an entity, with the input being what is fired at it - see the Valve developer wiki to see what inputs are possible to different types of entities.
    param gives any optional parameters, and in most cases is probably "nil". This might be used if for example you were providing color parameters or something to an entity.
    delay just specifies the delay as taken by Entity:Fire( ... )

    Example ARRAY_OF_CELL_STATUS_TARGETS:
        {
            ["cell1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["iso"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    The key for each item in this array is the entity name of the thing to be checked, e.g. a func_door or whatever.
    Each door_group should be a set of checks that combined say that one set of doors is open/closed. If not all of the checks in one door_group match, that indicates something is wrong.
    If not all the different door_groups match, then only *some* of the cell doors are open, e.g. when two rows of cells have separate door open buttons.
    The different check_types specify what type of entity is being checked, e.g. a func_door. The different currently possible checks are shown in the code for ulx.cellsstatus.
]]
local cell_door_configs = {
    {["maps"] = {"jb_lego_rage_.+"},
        ["open"] = {
            { ["name"] = "cell1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Open main cells' doors
            { ["name"] = "c_g", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Show green light on button
            { ["name"] = "auto_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Disable cell auto_open logic
            { ["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true } -- Open solitary cell door
        },
        ["close"] = {
            { ["name"] = "cell1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Close main cells' doors
            { ["name"] = "c_g", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Hide green light on button
            { ["name"] = "auto_open", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Enable cell auto_open logic (as is done in other versions of this map)
            { ["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true } -- Close solitary cell door
        },
        ["status"] = {
            ["cell1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["iso"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    {["maps"] = {"jb_lego_jail_v[1234]"},
        ["open"] = {
            { ["name"] = "cell1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Open main cells' doors
            { ["name"] = "c_g", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Show green light on open button
            { ["name"] = "auto_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Disable cell auto_open logic
            { ["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }, -- Open solitary cell door
            { ["name"] = "c_r", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false } -- Hide red light on close button
        },
        ["close"] = {
            { ["name"] = "cell1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Open main cells' doors
            { ["name"] = "c_g", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Show green light on open button
            { ["name"] = "auto_open", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Enable cell auto_open logic (as close button does)
            { ["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }, -- Open solitary cell door
            { ["name"] = "c_r", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false } -- Hide red light on close button
        },
        ["status"] = {
            ["cell1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["iso"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    {["maps"] = {"jb_lego_jail_.+"},
        ["open"] = {
            { ["name"] = "c1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Open main cells' doors
            { ["name"] = "c_g", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Show green light on open button
            { ["name"] = "auto_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Disable cell auto_open logic
            { ["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }, -- Open solitary cell door
            { ["name"] = "c_r", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false } -- Hide red light on close button
        },
        ["close"] = {
            { ["name"] = "c1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Open main cells' doors
            { ["name"] = "c_g", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Show green light on open button
            { ["name"] = "auto_open", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Enable cell auto_open logic (as close button does)
            { ["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }, -- Open solitary cell door
            { ["name"] = "c_r", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false } -- Hide red light on close button
        },
        ["status"] = {
            ["c1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["iso"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    {["maps"] = {"jb_carceris_021"},
        ["open"] = {
            { ["name"] = "slider1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "slider2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true } -- This bugs the solitary door button a bit, but the button is unnamed so it can't be targetted directly
        },
        ["close"] = {
            { ["name"] = "slider1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "slider2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["slider1"] = { ["door_group"] = "cells", ["check_type"] = "func_movelinear", ["solitary"] = false },
            ["iso"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    {["maps"] = {"jb_carceris"},
        ["open"] = {
            { ["name"] = "s1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s3", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s4", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s5", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s6", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s7", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s8", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s9", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s10", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s11", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s12", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s13", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s14", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s15", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s16", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "s1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s3", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s4", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s5", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s6", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s7", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s8", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s9", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s10", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s11", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s12", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s13", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s14", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s15", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "s16", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["s1"] = { ["door_group"] = "cells", ["check_type"] = "func_movelinear", ["solitary"] = false },
            ["iso"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    {["maps"] = {"ba_ace_jail_v3"},
        ["open"] = {
            { ["name"] = "door1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "door1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["door1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    {["maps"] = {"ba_ace_jail"},
        ["open"] = {
            { ["name"] = "door1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "door1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["door1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    {["maps"] = {"ba_jail_alcatraz"},
        ["open"] = {
            { ["name"] = "oben", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "unten", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "jail_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "oben", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "unten", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "jail_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["oben"] = { ["door_group"] = "upper", ["check_type"] = "func_door", ["solitary"] = false },
            ["unten"] = { ["door_group"] = "lower", ["check_type"] = "func_door", ["solitary"] = false },
            ["jail_door"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    {["maps"] = {"ba_jail_blackops"},
        ["open"] = {
            { ["name"] = "prisondoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "prisondoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["prisondoor"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    {["maps"] = {"ba_jail_canyondam_v6"},
        ["open"] = {
            { ["name"] = "CLDRS_R_1", ["input"] = "Trigger", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "CLDRS_R_2", ["input"] = "Trigger", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["CellDoors"] = { ["door_group"] = "cells", ["check_type"] = "func_movelinear", ["solitary"] = false }
        }
    },
    {["maps"] = {"ba_jail_canyondam"},
        ["open"] = {
            { ["name"] = "CellDoors_Movelinear", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "CellDoors_Movelinear", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["CellDoors_Movelinear"] = { ["door_group"] = "cells", ["check_type"] = "func_movelinear", ["solitary"] = false }
        }
    },
    {["maps"] = {"ba_jail_electric_aero"},
        ["open"] = {
            { ["name"] = "Cells_OpenButton", ["input"] = "PressIn", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cells_IsoDoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "Cells_OpenButton", ["input"] = "PressOut", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cells_IsoDoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["Cells_ForceFields"] = { ["door_group"] = "cells", ["check_type"] = "func_brush", ["solitary"] = false },
            ["Cells_IsoDoor"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    {["maps"] = {"ba_jail_electric_vip"},
        ["open"] = {
            { ["name"] = "cell_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "solitary_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "cell_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "solitary_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["cell_door"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["solitary_door"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    }
}

local armory_door_configs = {
    {["maps"] = {"jb_lego_jail", "jb_lego_rage_.+"},
        ["open"] = {{ ["name"]="arm1", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="arm1", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    {["maps"] = {"jb_carceris"},
        ["open"] = {{ ["name"]="ar", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="ar", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    {["maps"] = {"ba_ace_jail"},
        ["open"] = {{ ["name"]="amordoor", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="amordoor", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    {["maps"] = {"ba_jail_alcatraz_redux_go"},
        ["open"] = {{ ["name"]="slave1", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="slave1", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    {["maps"] = {"ba_jail_alcatraz"},
        ["open"] = {
            { ["name"] = "door_01", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "door_02", ["input"] = "Open", ["param"] = "nil", ["delay"] = 2.0 },
            { ["name"] = "door_03", ["input"] = "Open", ["param"] = "nil", ["delay"] = 2.0 }
        },
        ["close"] = {
            { ["name"] = "door_01", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "door_02", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "door_03", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    {["maps"] = {"ba_jail_blackops"},
        ["open"] = {{ ["name"]="ctdoorcontroler", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="ctdoorcontroler", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    {["maps"] = {"ba_jail_canyondam"},
        ["open"] = {{ ["name"]="ArmoryDoor", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="ArmoryDoor", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    {["maps"] = {"ba_jail_electric_aero"},
        ["open"] = {
            { ["name"] = "WK_Door_Left_1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "WK_Door_Left_2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "WK_Door_Right_1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "WK_Door_Right_2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "WK_Door_Left_1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "WK_Door_Left_2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "WK_Door_Right_1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "WK_Door_Right_2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    {["maps"] = {"ba_jail_electric_vip$", "ba_jail_electric_vip_v2"},
        ["open"] = {{ ["name"]="armory_door", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="armory_door", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    {["maps"] = {"ba_jail_electric_vip"},
        ["open"] = {
            { ["name"] = "armory_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "door_01", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armory_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "door_01", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    }
}
-- TODO: Add various other maps, including all from the old maps table (and remove the old table from here)
--[[ Old maps table:
local maps = {
    { "summer", { { "cellopen", "Press" } }, { { "cellclose", "Press" } } },
    { "summer", { { "b1", "Press" } }, { { "celldoor", "Close" } } },
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
    { "laser", "celdas.1.puerta", "celdas.2.puerta" },
    { "parabellum", {
        { "cells", "Open" },
        { "cells_relay", "CancelPending" }
    },
    {
        { "cells", "Close" }
    } },
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


-- Helper Functions

local function getPossibleConfigMatches( map, configs )
    local matches = {}

    -- Iterate through configs, adding any that have a match to the list
    for _, config in ipairs( configs ) do

        -- Iterate through map name patterns to find if any match
        for _, pattern in ipairs( config["maps"] ) do
            
            -- If match found, add the config to the list and stop looking for patterns to match
            if map:match( pattern ) then
                table.insert(matches, config)
                break
            end

        end

    end

    return matches
end

local function attemptOpenDoors( config, close, incl_solitary )
    -- Get the right key for the config section based on whether opening or closing
    local opcl = close and "close" or "open"
    
    -- Attempt to fire entities from config
    local success = false
    for _, ent_cf in ipairs ( config[opcl] ) do
        local entities = ents.FindByName( ent_cf["name"] )
        if next( entities ) ~= nil then
            success = true -- Mark that at least one entity was found successfully
            for _, e in ipairs( entities ) do
                if not ent_cf["solitary"] or incl_solitary then -- Don't open solitary cells if not marked to do so
                    e:Fire( ent_cf["input"], ent_cf["param"], ent_cf["delay"] )
                end
            end
        else
            -- The intended entity doesn't exist, so return that this config hasn't worked properly
            return false
        end
    end

    -- If at least one entity was triggered and no target was completely missing, then assume this config has succeeded
    if success then
        return true
    else
        return false
    end
end


-- ULX Commands

function ulx.opencells( calling_ply, incl_solitary, close, armory )
    local map = game.GetMap()

    -- End command with error message to player if unable to find any possibly matching configs
    local configs = getPossibleConfigMatches( map, armory and armory_door_configs or cell_door_configs )
    if configs == {} then
        ULib.tsayError( calling_ply, ERROR_MAP, true )
        return
    end

    -- Attempt each matching config until one works, ending inside here if one does
    for _, config in ipairs( configs ) do
        if attemptOpenDoors( config, close, incl_solitary ) then
            ulx.fancyLogAdmin( calling_ply, "#A " .. ( close and "closed" or "opened" ) .. " the " 
                                .. ( armory and "armory" or "cell" ) .. " doors" )
            return
        end
    end
    
    -- If this hasn't ended by now, no attempted config succeeded, so display an error message to the player about it
    ULib.tsayError( calling_ply, ERROR_MAP, true )
end
local opencells = ulx.command( CATEGORY_NAME, "ulx opencells", ulx.opencells, "!opencells", true )
opencells:addParam{ type=ULib.cmds.BoolArg, hint="Include solitary cells?", default=true, ULib.cmds.optional }
opencells:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
opencells:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
opencells:defaultAccess( ULib.ACCESS_ADMIN )
opencells:help( "Opens all cell doors." )
opencells:setOpposite( "ulx closecells", { _, _, true, _ }, "!closecells", true )


function ulx.openarmory( calling_ply, close )
    ulx.opencells( calling_ply, false, close, true ) -- Open armory code is just open cells but with a different config and log
end
local openarmory = ulx.command( CATEGORY_NAME, "ulx openarmory", ulx.openarmory, { "!openarmory", "!openarmoury" }, true )
openarmory:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
openarmory:defaultAccess( ULib.ACCESS_ADMIN )
openarmory:help( "Opens all armory doors." )
openarmory:setOpposite( "ulx closearmory", { _, true }, { "!closearmory", "!closearmoury" }, true )


function ulx.cellsstatus( calling_ply )
    local map = game.GetMap()

    -- Get all matching cell door configs, and return with error message if none match
    local configs = getPossibleConfigMatches( map, cell_door_configs )
    if next(configs) == nil then
        ULib.tsayError( calling_ply, ERROR_MAP, true )
        return
    end
    
    -- Try to discover cell door status from each config until one works completely
    for _, cfg in ipairs( configs ) do
        local cfg_status = cfg["status"] -- The status section of the config - the only part we care about for the status check

        -- Count the open state + total number of entities per grouping, but skip to the next config if an entity isn't found
        local count = {}
        local valid = true
        for ent_name, ent_cfg in pairs( cfg_status ) do
            local entities = ents.FindByName( ent_name )

            -- If no entities of this name exist, this config is invalid, so stop
            if next( entities ) == nil then
                valid = false
                break
            end

            -- Find out if one of this set of entities is in its open state
            local is_open = false
            local e = entities[1]
            if ent_cfg["check_type"] == "func_door" or ent_cfg["check_type"] == "func_door_rotating" then
                is_open = e:GetInternalVariable( "m_toggle_state" ) == 0
            elseif ent_cfg["check_type"] == "prop_door_rotating" then
                is_open = e:GetInternalVariable( "m_eDoorState" ) ~= 0
            elseif ent_cfg["check_type"] == "func_movelinear" then
                is_open = e:GetInternalVariable( "m_vecPosition1" ) ~= e:GetPos()
            elseif ent_cfg["check_type"] == "func_brush" then
                is_open = e:IsEffectActive( EF_NODRAW )
            end

            -- Update the count depending on whether the entity is "open" or not
            if is_open then
                if count[ ent_cfg[ "door_group" ] ] == nil then
                    count[ ent_cfg[ "door_group" ] ] = { ["total"] = 1, ["open"] = 1, ["solitary"] = ent_cfg["solitary"] }
                else
                    count[ ent_cfg[ "door_group" ] ][ "total" ] = count[ ent_cfg[ "door_group" ] ][ "total" ] + 1
                    count[ ent_cfg[ "door_group" ] ][ "open" ] = count[ ent_cfg[ "door_group" ] ][ "open" ] + 1
                end
            else
                if count[ ent_cfg[ "door_group" ] ] == nil then
                    count[ ent_cfg[ "door_group" ] ] = { ["total"] = 1, ["open"] = 0, ["solitary"] = ent_cfg["solitary"] }
                else
                    count[ ent_cfg[ "door_group" ] ][ "total" ] = count[ ent_cfg[ "door_group" ] ][ "total" ] + 1
                end
            end

            -- A door group must *all* be open or *all* be closed - if this isn't the case then this has failed
            if count[ ent_cfg[ "door_group" ] ]["open"] ~= count[ ent_cfg[ "door_group" ] ]["total"]
                and count[ ent_cfg[ "door_group" ] ]["open"] ~= 0 then
                    valid = false
                    break
            end
        end

        -- If the count didn't fail, report what state the cell doors are in
        if valid then
            local state_cells = -1 -- Fully Closed/Partially Open/Fully Open (0/1/2)
            local state_solitary = -1

            -- Go through the count to find the overall state of normal and solitary cells
            for _, cnt in pairs( count ) do
                if cnt["solitary"] then -- Solitary cells
                    if cnt["total"] == cnt["open"] then -- Door group is open
                        if state_solitary == -1 then state_solitary = 2 -- If none have been checked so far, then all checked so far are open
                        elseif state_solitary == 0 then state_solitary = 1 end -- If all have been closed so far, then it is now partially open
                    else
                        if state_solitary == -1 then state_solitary = 0 -- If none have been checked so far, then all checked so far are closed
                        elseif state_solitary == 2 then state_solitary = 1 end -- If all have been open so far, then it is now only partially open
                    end
                else -- Normal cells
                    if cnt["total"] == cnt["open"] then -- Door group is open
                        if state_cells == -1 then state_cells = 2 -- If none have been checked so far, then all checked so far are open
                        elseif state_cells == 0 then state_cells = 1 end -- If all have been closed so far, then it is now partially open
                    else
                        if state_cells == -1 then state_cells = 0 -- If none have been checked so far, then all checked so far are closed
                        elseif state_cells == 2 then state_cells = 1 end -- If all have been open so far, then it is now only partially open
                    end
                end
            end

            -- Create the message to show to the requesting player
            local msg = ""
            if state_solitary == -1 then
                msg = "The cells are currently "
                    .. ((state_cells == 0 and "closed.") or (state_cells == 1 and "partially open.") or "open.")
            elseif state_cells == state_solitary then
                msg = "Both the main and solitary cells are currently "
                    .. ((state_cells == 0 and "closed.") or (state_cells == 1 and "partially open.") or "open.")
            else
                msg = "The main cells are currently "
                    .. ((state_cells == 0 and "closed") or (state_cells == 1 and "partially open") or "open")
                    .. ", while the solitary cells are currently "
                    .. ((state_solitary == 0 and "closed.") or (state_solitary == 1 and "partially open.") or "open.")
            end

            -- Send the status message to the player
            ULib.tsay( calling_ply, msg, true )

            return
        end
    end

    -- If this is reached, then no valid config was found - tell the player this
    ULib.tsayError( calling_ply, ERROR_MAP, true )
end
local cellsstatus = ulx.command( CATEGORY_NAME, "ulx cellsstatus", ulx.cellsstatus, { "!cellsstatus", "!cellstatus" }, true )
cellsstatus:defaultAccess( ULib.ACCESS_ADMIN ) -- There's no real reason for this to be admin-only, but usually only admins would *need* this
cellsstatus:help( "Tells the player whether the cell doors are currently open or closed." )


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
