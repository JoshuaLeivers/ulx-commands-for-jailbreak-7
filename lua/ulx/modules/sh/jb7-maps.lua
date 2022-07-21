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
local ERROR_DOOR_GROUP = "One of the doors aren't behaving as expected, so this command doesn't work right now!"

local HOOK_ADDCMD = "ULX-JB7_AddCmd"

local GBOOL_INCL_ARMORY = "ulx-jb7_incl_armory"
local GBOOL_INCL_CELLS = "ulx-jb7_incl_cells"
local GBOOL_INCL_STOPHELI = "ulx-jb7_incl_stopheli"
local GBOOL_INCL_MANCANNON = "ulx-jb7_incl_mancannon"
local GBOOL_INCL_CONTROLDISCO = "ulx-jb7_incl_controldisco"

local GSTR_CONFIG_CONTROLDISCO = "ulx-jb7_config_controldisco"
local GSTR_CONFIG_CELLS = "ulx-jb7_config_cells"
local GSTR_CONFIG_ARMORY = "ulx-jb7_config_armory"


-- Cell door control maps and entities

--[[
    Each cell door config takes the following format:
        {["maps"]=LIST_OF_MAP_NAME_REGEX, ["open"]=ARRAY_OF_CELL_OPEN_TARGETS, ["close"]=ARRAY_OF_CELL_CLOSE_TARGETS, ["status"]=ARRAY_OF_CELL_STATUS_TARGETS}
    See below for what each of these things should look like.

    Example ARRAY_OF_MAP_NAME_MATCHES:
        {"jb_lego_rage", "jb_lego_jail", "jb_lego_.+_a20"}
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
    ["jb_lego_rage"] = {["maps"] = {"jb_lego_rage_.+"},
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
    ["jb_lego_jail_v1 to v4"] = {["maps"] = {"jb_lego_jail_v[1234]"},
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
    ["jb_lego_jail_v5+"] = {["maps"] = {"jb_lego_jail_.+"},
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
    ["jb_carceris_021"] = {["maps"] = {"jb_carceris_021"},
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
    ["jb_carceris"] = {["maps"] = {"jb_carceris"},
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
    ["ba_ace_jail_v3"] = {["maps"] = {"ba_ace_jail_v3"},
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
    ["ba_ace_jail"] = {["maps"] = {"ba_ace_jail"},
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
    ["ba_jail_alcatraz"] = {["maps"] = {"ba_jail_alcatraz"},
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
    ["ba_jail_blackops"] = {["maps"] = {"ba_jail_blackops"},
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
    ["ba_jail_canyondam_v6"] = {["maps"] = {"ba_jail_canyondam_v6"},
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
    ["ba_jail_canyondam"] = {["maps"] = {"ba_jail_canyondam"},
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
    ["ba_jail_electric_aero"] = {["maps"] = {"ba_jail_electric_aero"},
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
    ["ba_jail_electric_vip"] = {["maps"] = {"ba_jail_electric_vip"},
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
    },
    ["ba_jail_hellsgamers"] = {["maps"] = { "ba_jail_hellsgamers" },
        ["open"] = {
            { ["name"] = "celldoor_vip_left", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celldoor_vip_right", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celldoors_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "isolatedoor", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "isolatedoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "celldoor_vip", ["input"] = "SetAnimation", ["param"] = "open", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "celldoor_vip_left", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celldoor_vip_right", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celldoors_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "isolatedoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "isolatedoor", ["input"] = "Lock", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "celldoor_vip", ["input"] = "SetAnimation", ["param"] = "close", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["celldoors_door"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["isolatedoor"] = { ["door_group"] = "solitary", ["check_type"] = "prop_door_rotating", ["solitary"] = true }
        }
    },
    ["ba_jail_ishimura"] = {["maps"] = { "ba_jail_ishimura" },
        ["open"] = {
            { ["name"] = "switchprison", ["input"] = "PressIn", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "switchprison2", ["input"] = "PressIn", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "switchprison", ["input"] = "PressOut", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "switchprison2", ["input"] = "PressOut", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["PrisonDoor"] = { ["door_group"] = "cells", ["check_type"] = "func_brush", ["solitary"] = false }
        }
    },
    ["ba_jail_new_campus"] = {["maps"] = { "ba_jail_new_campus" },
        ["open"] = {
            { ["name"] = "cells", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cagedoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true } -- This isn't really a solitary cell, but can act like one so it's here anyway
        },
        ["close"] = {
            { ["name"] = "cells", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cagedoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["cells"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["Cagedoor"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["ba_jail_nightprison"] = {["maps"] = { "ba_jail_nightprison" },
        ["open"] = {
            { ["name"] = "zd1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zd2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zd3", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zd4", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "zd1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zd2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zd3", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zd4", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["zd1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["ba_jail_sand"] = {["maps"] = { "ba_jail_sand" },
        ["open"] = {
            { ["name"] = "JailDoors", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "JailDoors", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["JailDoors"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["ba_mario_party"] = {["maps"] = { "ba_mario_party" },
        ["open"] = {
            { ["name"] = "tube_cells", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cell_breakable", ["input"] = "Break", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- These cells aren't really closable, so there's no close config for them
            { ["name"] = "isolation_doors", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "tube_cells", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "isolation_doors", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["tube_cells"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["isolation_doors"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["ba_nova_prospect"] = {["maps"] = { "ba_nova_prospect" },
        ["open"] = {
            { ["name"] = "cells", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cellsmain", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "cells", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cellsmain", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["cells"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["cellsmain"] = { ["door_group"] = "cells_outer", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_8bit"] = {["maps"] = { "jb_8bit_" },
        ["open"] = {
            { ["name"] = "cell_doors", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "cell_doors", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["cell_doors"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_clouds"] = {["maps"] = { "jb_clouds" },
        ["open"] = {
            { ["name"] = "zelle_iso_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "zelle_door2_garderobe", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door2_1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zelle_door2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zelle_door1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door2_2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0.5, ["solitary"] = false },
            { ["name"] = "door2_3", ["input"] = "Open", ["param"] = "nil", ["delay"] = 1.0, ["solitary"] = false },
            { ["name"] = "door2_4", ["input"] = "Open", ["param"] = "nil", ["delay"] = 1.5, ["solitary"] = false },
            { ["name"] = "door2_5", ["input"] = "Open", ["param"] = "nil", ["delay"] = 2.0, ["solitary"] = false },
            { ["name"] = "door2_6", ["input"] = "Open", ["param"] = "nil", ["delay"] = 2.5, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "zelle_iso_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "zelle_door2_garderobe", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door2_1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zelle_door2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "zelle_door1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door2_2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0.5, ["solitary"] = false },
            { ["name"] = "door2_3", ["input"] = "Close", ["param"] = "nil", ["delay"] = 1.0, ["solitary"] = false },
            { ["name"] = "door2_4", ["input"] = "Close", ["param"] = "nil", ["delay"] = 1.5, ["solitary"] = false },
            { ["name"] = "door2_5", ["input"] = "Close", ["param"] = "nil", ["delay"] = 2.0, ["solitary"] = false },
            { ["name"] = "door2_6", ["input"] = "Close", ["param"] = "nil", ["delay"] = 2.5, ["solitary"] = false }
        },
        ["status"] = {
            ["zelle_iso_door"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true },
            ["zelle_door2_garderobe"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_iceworld"] = {["maps"] = { "jb_iceworld" },
        ["open"] = {
            { ["name"] = "door", ["input"] = "Kill", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            -- The doors on this map are just Killed and so can't be closed again or otherwise interacted with
        },
        ["status"] = {
            ["door"] = { ["door_group"] = "cells", ["check_type"] = "exists", ["solitary"] = false }
        }
    },
    ["jb_italia_beta/revamp"] = {["maps"] = { "jb_italia_revamp", "jb_italia_beta[1234]" },
        ["open"] = {
            { ["name"] = "door cells", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "door cells", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["door cells"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_italia"] = {["maps"] = { "jb_italia" },
        ["open"] = {
            { ["name"] = "door cells", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door t room sliding 1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door t room sliding 2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "door cells", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["door cells"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_kliffside"] = {["maps"] = { "jb_kliffside" },
        ["open"] = {
            { ["name"] = "cellblock_celldoors_1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "cellblock_celldoors_1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
            -- There is also a button that ideally this would PressOut, but it is unnamed so can't be interacted with without significantly changing this module, and shouldn't be too big of a deal
        },
        ["status"] = {
            ["cellblock_celldoors_1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_lego_mini"] = {["maps"] = { "jb_lego_mini" },
        ["open"] = {
            { ["name"] = "cells_up", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cells_down", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door_kammer", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "cells_up", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cells_down", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door_kammer", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["cells_up"] = { ["door_group"] = "upper_cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["cells_down"] = { ["door_group"] = "lower_cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["door_kammer"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["jb_mars"] = {["maps"] = { "ba_jail_mars", "jb_mars" },
        ["open"] = {
            { ["name"] = "door_jail", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door_solitary", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "sound_alert", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "door_jail", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "door_solitary", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "sound_alert", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["door_jail"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["door_solitary"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["jb_minecraft_nightfall"] = {["maps"] = { "jb_minecraft_daylight_", "jb_minecraft_nightfall_" },
        ["open"] = {
            { ["name"] = "cell_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "cell_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["cell_door"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_mlcastle"] = {["maps"] = { "ba_mlcastle", "jb_mlcastle" },
        ["open"] = {
            { ["name"] = "cell_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "cell_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["cell_door"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_minecraft_kis"] = {["maps"] = { "jb_minecraft_kis_" },
        ["open"] = {
            { ["name"] = "cellblock_door", ["input"] = "Break", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cellblock_door_secret", ["input"] = "Break", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- This isn't a secret door, it's just a regular cell door that has a way to break out early
            { ["name"] = "cellblock_music", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "isolation_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "isolation_door2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            -- The main cell doors can't be closed, as the map "opens" then by doing Break, so the entities no longer exist after that - the doors are just func_breakables
            { ["name"] = "isolation_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "isolation_door2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["cellblock_door"] = { ["door_group"] = "cells", ["check_type"] = "exists", ["solitary"] = false },
            ["cellblock_door_secret"] = { ["door_group"] = "early_breakout_cell", ["check_type"] = "exists", ["solitary"] = false },
            ["isolation_door"] = { ["door_group"] = "solitary_corridor_left", ["check_type"] = "func_door_rotating", ["solitary"] = true },
            ["isolation_door2"] = { ["door_group"] = "solitary_corridor_right", ["check_type"] = "func_door_rotating", ["solitary"] = true }
        }
    },
    ["ba_jail_summer09"] = {["maps"] = { "ba_jail_summer09" },
        ["open"] = {
            { ["name"] = "jail", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "jail", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["jail"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["ba_jail_summer"] = {["maps"] = { "ba_jail_summer" },
        ["open"] = {
            { ["name"] = "celldoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "celldoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["celldoor"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_new_summer"] = {["maps"] = { "jb_summer_xmas", "jb_new_summer", "jb_summer_jail" },
        ["open"] = {
            { ["name"] = "cellopen", ["input"] = "Press", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "cellclose", ["input"] = "Press", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["cells"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    }, -- jb_summer_redux maps use func_wall_toggle and no named buttons, so they could only be toggled
    ["jb_overcooked"] = {["maps"] = { "jb_overcooked" },
        ["open"] = {
            { ["name"] = "cell_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "isolator_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "cell_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "isolator_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["cell_door"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["isolator_door"] = { ["door_group"] = "game_box", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["jb_parabellum_xg"] = {["maps"] = { "_parabellum_xg" },
        ["open"] = {
            { ["name"] = "cells", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "cells", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["cells"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_prison_architect"] = {["maps"] = { "jb_prison_architect" },
        ["open"] = {
            { ["name"] = "cell_open_but", ["input"] = "Press", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "isol", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "cells", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- Cell close button is unlabelled, so this just copies its functions
            { ["name"] = "cell_sp1", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cell_sp2", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "isol", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["cells"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["isol"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["jb_spy_vs_spy"] = {["maps"] = { "jb_spy_vs_spy" },
        ["open"] = {
            { ["name"] = "cell_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "cell_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["cell_door"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_underrock"] = {["maps"] = { "jb_underrock_" },
        ["open"] = {
            { ["name"] = "cellblock_celldoors_1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "solitary_door_1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_sound", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "cellblock_celldoors_1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "solitary_door_1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["cellblock_celldoors_1"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["solitary_door_1"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["jb_vipinthemix"] = {["maps"] = { "jb_vipinthemix" },
        ["open"] = {
            { ["name"] = "Vipcel_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip3", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip4", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip5", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip6", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip7", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip8", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip9", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip10", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "bjail_off", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "bjail_on", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "bigjail_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "Iso_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "Vipcel_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip3", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip4", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip5", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip6", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip7", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip8", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip9", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Jaildoor_clip10", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "bjail_off", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "bjail_on", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "bigjail_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "Iso_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["Jaildoor_clip1"] = { ["door_group"] = "cells", ["check_type"] = "func_movelinear", ["solitary"] = false },
            ["Iso_door"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true },
            ["bigjail_door"] = { ["door_group"] = "big_jail", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["ba_jail_minecraft_beach"] = {["maps"] = { "ba_jail_minecraft_beach" },
        ["open"] = {
            { ["name"] = "celldoors_closed", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celldoors_open", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celldoors_button", ["input"] = "Lock", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "celldoors_closed", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celldoors_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celldoors_button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["celldoors_open"] = { ["door_group"] = "cells", ["check_type"] = "func_brush enabled", ["solitary"] = false }
        }
    },
    ["ba_jail_laser early"] = {["maps"] = { "ba_jail_laser" }, -- v1 uses this, not sure about v2
        ["open"] = {
            { ["name"] = "jail_1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "jail_2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "hoyo", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "hoguera", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "pecera", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "jail_1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "jail_2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "hoyo", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "hoguera", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "pecera", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["jail_1"] = { ["door_group"] = "cells_left", ["check_type"] = "func_door", ["solitary"] = false },
            ["jail_2"] = { ["door_group"] = "cells_right", ["check_type"] = "func_door", ["solitary"] = false },
            ["hoyo"] = { ["door_group"] = "deathcell_fall", ["check_type"] = "func_door", ["solitary"] = true },
            ["hoguera"] = { ["door_group"] = "deathcell_explosion", ["check_type"] = "func_door", ["solitary"] = true },
            ["pecera"] = { ["door_group"] = "deathcell_water", ["check_type"] = "func_door", ["solitary"] = true }
        }
    }, -- Both versions of the map have a solitary cell that uses a func_wall_toggle, which can only be toggled
    ["ba_jail_laser later"] = {["maps"] = { "ba_jail_laser" }, -- v3/4 use this, not sure about v2
        ["open"] = {
            { ["name"] = "celdas.1.puerta", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celdas.2.puerta", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "hoyo.puerta", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "horno.puerta", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "pecera.puerta", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "camaleon.puerta", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "celdas.1.puerta", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "celdas.2.puerta", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "hoyo.puerta", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "horno.puerta", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "pecera.puerta", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "camaleon.puerta", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["celdas.1.puerta"] = { ["door_group"] = "cells_left", ["check_type"] = "func_door", ["solitary"] = false },
            ["celdas.2.puerta"] = { ["door_group"] = "cells_right", ["check_type"] = "func_door", ["solitary"] = false },
            ["hoyo.puerta"] = { ["door_group"] = "deathcell_fall", ["check_type"] = "func_door", ["solitary"] = true },
            ["horno.puerta"] = { ["door_group"] = "deathcell_explosion", ["check_type"] = "func_door", ["solitary"] = true },
            ["pecera.puerta"] = { ["door_group"] = "deathcell_water", ["check_type"] = "func_door", ["solitary"] = true },
            ["camaleon.puerta"] = { ["door_group"] = "cell_aquarium", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["ba_jail_sylvan"] = {["maps"] = { "ba_jail_sylvan" },
        ["open"] = {
            { ["name"] = "Cell_Doors_1_Full", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cell_Door_Button", ["input"] = "Lock", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cell_Doors_1_Broken", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "solitary_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }, -- This is a solitary cell, but is operated by the same button as the rest, so isn't marked as one for these purposes
            { ["name"] = "Cell_Sparks", ["input"] = "StartSpark", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "CellSOUNDS", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cell_Doors_2_Full", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cell_Doors_2_Broken", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["close"] = {
            { ["name"] = "Cell_Doors_1_Full", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cell_Door_Button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cell_Doors_1_Broken", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "solitary_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "CellSOUNDS", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cell_Doors_2_Full", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Cell_Doors_2_Broken", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false }
        },
        ["status"] = {
            ["Cell_Doors_1_Full"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false }
        }
    },
    ["jb_castleguarddev"] = {["maps"] = { "jb_castleguarddev" },
        ["open"] = {
            { ["name"] = "Cell_Door_Main", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Solitary_Confine_CellDoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "OutsideSolitary_Confine_CellDoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "Cell_Door_Main", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "Solitary_Confine_CellDoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "OutsideSolitary_Confine_CellDoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["Cell_Door_Main"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["Solitary_Confine_CellDoor"] = { ["door_group"] = "solitary_indoors", ["check_type"] = "func_door", ["solitary"] = true },
            ["OutsideSolitary_Confine_CellDoor"] = { ["door_group"] = "solitary_outdoors", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["jb_heat"] = {["maps"] = { "jb_heat_" },
        ["open"] = {
            { ["name"] = "jd", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "jd", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }
        },
        ["status"] = {
            ["jd"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["iso"] = { ["door_group"] = "solitary", ["check_type"] = "func_door", ["solitary"] = true }
        }
    },
    ["jb_kittens"] = {["maps"] = { "jb_kittens_" },
        ["open"] = {
            { ["name"] = "cell_door_t", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cell_light_sprite", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cell_prop_light", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cell_prop_light_on", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "solitary_blastdoor_black_bottom", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }, -- From here, the buried super-secure cell's various locks and stuff
            { ["name"] = "solitary_blastdoor_black_top", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_orange_bottom", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_orange_top", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_button", ["input"] = "Lock", ["param"] = "nil", ["delay"] = 0.01, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_black", ["input"] = "Open", ["param"] = "nil", ["delay"] = 3.0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_orange", ["input"] = "Open", ["param"] = "nil", ["delay"] = 3.0, ["solitary"] = true },
            { ["name"] = "solitary_motor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 8.0, ["solitary"] = true },
            { ["name"] = "solitary_sound", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 8.0, ["solitary"] = true },
            { ["name"] = "solitary_spotlight", ["input"] = "LightOn", ["param"] = "nil", ["delay"] = 13.5, ["solitary"] = true },
            { ["name"] = "solitary_door_cageside_button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 13.5, ["solitary"] = true },
            { ["name"] = "solitary_secret_button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 13.5, ["solitary"] = true },
            { ["name"] = "solitary_door_armoryside_button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 13.5, ["solitary"] = true },
            { ["name"] = "solitary_door_cellside_button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 13.5, ["solitary"] = true },
            { ["name"] = "solitary_door_dumpsterside_button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 13.5, ["solitary"] = true },
            { ["name"] = "solitary_trigger", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 13.5, ["solitary"] = true },
            { ["name"] = "solitary_sound", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 14.0, ["solitary"] = true },
            { ["name"] = "solitary_door_dumpsterside", ["input"] = "Open", ["param"] = "nil", ["delay"] = 14.5, ["solitary"] = true },
            { ["name"] = "solitary_door_armoryside", ["input"] = "Open", ["param"] = "nil", ["delay"] = 14.5, ["solitary"] = true },
            { ["name"] = "solitary_door_cageside", ["input"] = "Open", ["param"] = "nil", ["delay"] = 14.5, ["solitary"] = true },
            { ["name"] = "solitary_door_cellside", ["input"] = "Open", ["param"] = "nil", ["delay"] = 14.5, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 15.0, ["solitary"] = true }
        },
        ["close"] = {
            { ["name"] = "cell_door_t", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cell_light_sprite", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cell_prop_light", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "cell_prop_light_on", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0, ["solitary"] = false },
            { ["name"] = "solitary_spotlight", ["input"] = "LightOff", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_sound", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_door_dumpsterside", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_door_dumpsterside_button", ["input"] = "Lock", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_door_armoryside", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_door_cageside", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_motor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_secret_button", ["input"] = "Lock", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_door_armoryside_button", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_door_cageside_button", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true },
            { ["name"] = "solitary_door_cellside_button", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0, ["solitary"] = true }, -- The cellside door isn't actually closed here, but the map itself doesn't do that, either
            { ["name"] = "solitary_blastdoor_button", ["input"] = "Lock", ["param"] = "nil", ["delay"] = 0.01, ["solitary"] = true },
            { ["name"] = "solitary_trigger", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 2.0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_black", ["input"] = "Close", ["param"] = "nil", ["delay"] = 6.0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_orange", ["input"] = "Close", ["param"] = "nil", ["delay"] = 6.0, ["solitary"] = true },
            { ["name"] = "solitary_sound", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 6.0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_orange_bottom", ["input"] = "Close", ["param"] = "nil", ["delay"] = 9.0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_orange_top", ["input"] = "Close", ["param"] = "nil", ["delay"] = 9.0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_black_bottom", ["input"] = "Close", ["param"] = "nil", ["delay"] = 9.0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_black_top", ["input"] = "Close", ["param"] = "nil", ["delay"] = 9.0, ["solitary"] = true },
            { ["name"] = "solitary_blastdoor_button", ["input"] = "Unlock", ["param"] = "nil", ["delay"] = 15.0, ["solitary"] = true }
        },
        ["status"] = {
            ["cell_door_t"] = { ["door_group"] = "cells", ["check_type"] = "func_door", ["solitary"] = false },
            ["solitary_blastdoor_black_bottom"] = { ["door_group"] = "solitary_outer", ["check_type"] = "func_door", ["solitary"] = true }, -- These two are for the same cell, but it has multiple parts and "partially open" could be true for it alone.
            ["solitary_door_cageside"] = { ["door_group"] = "solitary_inner", ["check_type"] = "func_door", ["solitary"] = true } -- This means that it will always detect partially open unless this specific side door is open. Technically true, but ideally door_group needs a rework to work the opposite to what it currently does.
        }
    }
}

local armory_door_configs = {
    ["jb_lego_jail"] = {["maps"] = {"jb_lego_jail", "jb_lego_rage_.+"},
        ["open"] = {{ ["name"]="arm1", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="arm1", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    ["jb_carceris"] = {["maps"] = {"jb_carceris"},
        ["open"] = {{ ["name"]="ar", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="ar", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    ["ba_ace_jail"] = {["maps"] = {"ba_ace_jail"},
        ["open"] = {{ ["name"]="amordoor", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="amordoor", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    ["ba_jail_alcatraz_redux"] = {["maps"] = {"ba_jail_alcatraz_redux_go"},
        ["open"] = {{ ["name"]="slave1", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="slave1", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    ["ba_jail_alcatraz"] = {["maps"] = {"ba_jail_alcatraz"},
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
    ["ba_jail_blackops"] = {["maps"] = {"ba_jail_blackops"},
        ["open"] = {{ ["name"]="ctdoorcontroler", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="ctdoorcontroler", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    ["ba_jail_canyondam"] = {["maps"] = {"ba_jail_canyondam"},
        ["open"] = {{ ["name"]="ArmoryDoor", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="ArmoryDoor", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    ["ba_jail_electric_aero"] = {["maps"] = {"ba_jail_electric_aero"},
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
    ["ba_jail_electric_vip"] = {["maps"] = {"ba_jail_electric_vip$", "ba_jail_electric_vip_v2"},
        ["open"] = {{ ["name"]="armory_door", ["input"]="Open", ["param"]="nil", ["delay"]=0 }},
        ["close"] = {{ ["name"]="armory_door", ["input"]="Close", ["param"]="nil", ["delay"]=0 }}
    },
    ["ba_jail_electric_vip_v3+"] = {["maps"] = {"ba_jail_electric_vip"},
        ["open"] = {
            { ["name"] = "armory_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "door_01", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armory_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "door_01", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_jail_hellsgamers"] = {["maps"] = { "ba_jail_hellsgamers" },
        ["open"] = {
            { ["name"] = "doorport002", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "doorport002", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_jail_nightprison"] = {["maps"] = { "ba_jail_nightprison" },
        ["open"] = {
            { ["name"] = "ctdoor1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "ctdoor1.1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "ctdoor2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "ctdoor1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "ctdoor1.1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "ctdoor2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_jail_sand"] = {["maps"] = { "ba_jail_sand" },
        ["open"] = {
            { ["name"] = "armorydoor1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "armorydoor2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armorydoor1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "armorydoor2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_nova_prospect"] = {["maps"] = { "ba_nova_prospect" },
        ["open"] = {
            { ["name"] = "door1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "door1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_8bit"] = {["maps"] = { "jb_8bit_" },
        ["open"] = {
            { ["name"] = "armorydoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armorydoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_clouds"] = {["maps"] = { "jb_clouds" },
        ["open"] = {
            { ["name"] = "armory_button", ["input"] = "Press", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "door_wk_brush", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "door_wk1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 3.0 },
            { ["name"] = "door_wk2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 3.5 },
            { ["name"] = "door_wk_brush", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 3.75 },
            { ["name"] = "door_wk3", ["input"] = "Close", ["param"] = "nil", ["delay"] = 4.0 },
            { ["name"] = "door_wk4", ["input"] = "Close", ["param"] = "nil", ["delay"] = 4.5 },
            { ["name"] = "door_wk5", ["input"] = "Close", ["param"] = "nil", ["delay"] = 5.0 }
        }
    },
    ["jb_minecraft_nightfall"] = {["maps"] = { "jb_minecraft_daylight_", "jb_minecraft_nightfall_" },
        ["open"] = {
            { ["name"] = "armory_doors", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armory_doors", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_mlcastle"] = {["maps"] = { "ba_mlcastle", "jb_mlcastle" },
        ["open"] = {
            { ["name"] = "arm_dr", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "arm_dr", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_minecraft_kis"] = {["maps"] = { "jb_minecraft_kis_" },
        ["open"] = {
            { ["name"] = "armoury_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armoury_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "isolation_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "isolation_door2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_jail_summer09"] = {["maps"] = { "ba_jail_summer09" },
        ["open"] = {
            { ["name"] = "door_weapons", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "door_weapons", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_prison_architect"] = {["maps"] = { "jb_prison_architect" },
        ["open"] = {
            { ["name"] = "daa1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "daa2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "da5", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "daa1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "daa2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "da5", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_spy_vs_spy"] = {["maps"] = { "jb_spy_vs_spy" },
        ["open"] = {
            { ["name"] = "armoury_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armoury_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_vipinthemix"] = {["maps"] = { "jb_vipinthemix" },
        ["open"] = {
            { ["name"] = "Armory_door1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "Armory_door2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "Armory_door1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "Armory_door2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_jail_minecraft_beach"] = {["maps"] = { "ba_jail_minecraft_beach" },
        ["open"] = {
            { ["name"] = "armorydoor_closed", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "armorydoor_open", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "armorydoor_teleport", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "armorydoor_closed", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 4.0 }, -- Close door after 4 seconds
            { ["name"] = "armorydoor_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 4.0 },
            { ["name"] = "armorydoor_teleport", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 4.0 }
        },
        ["close"] = {
            { ["name"] = "armorydoor_closed", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "armorydoor_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "armorydoor_teleport", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_jail_laser early"] = {["maps"] = { "ba_jail_laser" },
        ["open"] = {
            { ["name"] = "armeria", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armeria", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_jail_laser later"] = {["maps"] = { "ba_jail_laser" },
        ["open"] = {
            { ["name"] = "armeria.puerta", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armeria.puerta", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["ba_jail_sylvan"] = {["maps"] = { "ba_jail_sylvan" },
        ["open"] = {
            { ["name"] = "ArmoryDoor", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "ArmoryDoor", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_castleguarddev"] = {["maps"] = { "jb_castleguarddev" },
        ["open"] = {
            { ["name"] = "Armory_Door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "Armory_Door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_heat"] = {["maps"] = { "jb_heat_" },
        ["open"] = {
            { ["name"] = "arm", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "arm", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_kittens"] = {["maps"] = { "jb_kittens_" },
        ["open"] = {
            { ["name"] = "armory_door", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0 }
        },
        ["close"] = {
            { ["name"] = "armory_door", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0 }
        }
    }
}


--[[
    These configs take the format of:
        ["config_id"] = { ["maps"] = ARRAY_OF_MAP_NAME_MATCHES, ["stop music"] = ARRAY_OF_ENTITY_FIRES, ... }
    Any item other than "maps" within each config will be added as an option for the command when loaded.
    "stop music" should be included as the config to stop all disco music, and any others should do things like play specific tracks, control the lights, etc.
    Each option should have a short, descriptive name, such as "stop music", "play trackname_here", "play track 1", "reset lights", "turn off lights", etc.

    Each ARRAY_OF_ENTITY_FIRES should be the following format, as with the cell/armory door configs above:
        { ["name"] = "entity_name", ["input"] = "Fire_input", ["param"] = "nil/parameters", ["delay"] = 0/as needed }
]]
local controldisco_configs = {
    ["jb_carceris_021"] = {
        ["maps"] = { "jb_carceris_021" },
        ["stop music"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 1"] = {
            { ["name"] = "song01", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 2"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 3"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 4"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 5"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 6"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 }
        }
    },
    ["jb_carceris"] = {
        ["maps"] = { "jb_carceris" },
        ["stop music"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song07", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 1"] = {
            { ["name"] = "song01", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song07", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 2"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song07", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 3"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song07", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 4"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song07", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 5"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song07", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 6"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song07", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 }
        },
        ["play track 7"] = {
            { ["name"] = "song01", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song02", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song03", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song04", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song05", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song06", ["input"] = "StopSound", ["param"] = "nil", ["delay"] = 0 },
            { ["name"] = "song07", ["input"] = "PlaySound", ["param"] = "nil", ["delay"] = 0 }
        }
    }
}


-- Helper Functions

-- Return all possible matching configs based on the map regexes
local function getPossibleConfigMatches( map, configs )
    local matches = {}

    -- Iterate through configs, adding any that have a match to the list
    for cfg_id, config in pairs( configs ) do

        -- Iterate through map name patterns to find if any match
        for _, pattern in ipairs( config["maps"] ) do
            
            -- If match found, add the config to the list and stop looking for patterns to match
            if map:match( pattern ) then
                matches[ cfg_id ] = config
                break
            end

        end

    end

    return matches
end

--[[
    Attempt to Fire each entity config from a door config until an entity isn't found, then try the next config until none are left.
    Returns true/false based on whether any configs succeeded.
]]
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
        elseif ent_cf["input"] ~= "Break" and ent_cf["input"] ~= "Kill" then -- If using Break/Kill, the entity won't exist after the first open
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
    for _, config in pairs( configs ) do
        if attemptOpenDoors( config, close, incl_solitary ) then
            ulx.fancyLogAdmin( calling_ply, "#A " .. ( close and "closed" or "opened" ) .. " the " 
                                .. ( armory and "armory" or "cell" ) .. " doors" )
            return
        end
    end
    
    -- If this hasn't ended by now, no attempted config succeeded, so display an error message to the player about it
    ULib.tsayError( calling_ply, ERROR_MAP, true )
end
local opencells
SetGlobalBool( GBOOL_INCL_CELLS, false ) -- Mark to not include this command by default


function ulx.openarmory( calling_ply, close )
    ulx.opencells( calling_ply, false, close, true ) -- Open armory code is just open cells but with a different config and log
end
local openarmory
SetGlobalBool( GBOOL_INCL_ARMORY, false ) -- Mark to not include this command by default


function ulx.cellsstatus( calling_ply )
    -- Get the status section of the cell doors config - the only section we care about for this command
    local cfg_status = cell_door_configs[ GetGlobalString( GSTR_CONFIG_CELLS ) ][ "status" ]

    -- Check the status based on the entities in the config
    local count = {}
    for ent_name, ent_cfg in pairs( cfg_status ) do
        -- Get all the entities with the given name
        local entities = ents.FindByName( ent_name )

        -- Find out if one of this set of entities is in its open state
        local is_open = false

        --[[
            If there are no entities with that name and that is the check type, the door is open.
            The entity should never not exist otherwise, or the command shouldn't have been added - an error would be the intended response.
        ]]
        if next( entities ) == nil and ent_cfg["check_type"] == "exists" then
            is_open = true
        end

        -- Check whether the door is open based on the check type specified
        local e = entities[1]
        if ent_cfg["check_type"] == "exists" and next( entities ) ~= nil then
            -- If here is reached then the entity *does* exist
            is_open = false
        elseif ent_cfg["check_type"] == "func_door" or ent_cfg["check_type"] == "func_door_rotating" then
            is_open = e:GetInternalVariable( "m_toggle_state" ) == 0
        elseif ent_cfg["check_type"] == "prop_door_rotating" then
            is_open = e:GetInternalVariable( "m_eDoorState" ) ~= 0
        elseif ent_cfg["check_type"] == "func_movelinear" then
            is_open = e:GetInternalVariable( "m_vecPosition1" ) ~= e:GetPos()
        elseif ent_cfg["check_type"] == "func_brush" then
            is_open = e:IsEffectActive( EF_NODRAW )
        elseif ent_cfg["check_type"] == "func_brush enabled" then
            is_open = e:IsSolid()
        end

        -- Update the door group open counts depending on whether the entity is "open" or not
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
    end

    -- Calculate the state that the cell doors are in
    local state_cells = -1 -- Fully Closed/Partially Open/Fully Open (0/1/2)
    local state_solitary = -1

    -- Go through the count to find the overall state of normal and solitary cells
    for _, cnt in pairs( count ) do
        if cnt["solitary"] then -- Solitary cells
            if cnt["total"] == cnt["open"] then -- Door group is open
                if state_solitary == -1 then state_solitary = 2 -- If none have been checked so far, then all checked so far are open
                elseif state_solitary == 0 then state_solitary = 1 end -- If all have been closed so far, then it is now partially open
            elseif cnt["open"] == 0 then
                if state_solitary == -1 then state_solitary = 0 -- If none have been checked so far, then all checked so far are closed
                elseif state_solitary == 2 then state_solitary = 1 end -- If all have been open so far, then it is now only partially open
            else
                -- The door group isn't consistent - there's something wrong with the door, so stop the check.
                ULib.tsayError( calling_ply, ERROR_DOOR_GROUP, true )
                return
            end
        else -- Normal cells
            if cnt["total"] == cnt["open"] then -- Door group is open
                if state_cells == -1 then state_cells = 2 -- If none have been checked so far, then all checked so far are open
                elseif state_cells == 0 then state_cells = 1 end -- If all have been closed so far, then it is now partially open
            elseif cnt["open"] == 0 then
                if state_cells == -1 then state_cells = 0 -- If none have been checked so far, then all checked so far are closed
                elseif state_cells == 2 then state_cells = 1 end -- If all have been open so far, then it is now only partially open
            else
                -- The door group isn't consistent - there's something wrong with the door, so stop the check.
                ULib.tsayError( calling_ply, ERROR_DOOR_GROUP, true )
                return
            end
        end
    end

    -- Create the message to show to the requesting player based on the calculated states
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
local cellsstatus


function ulx.stopheli( calling_ply, start )
    -- No need to check if the entity exists, as otherwise this command wouldn't have been added
    
    -- Turn on/off the helicopter depending on if using opposite command
    if start then
        local onbutt = ents.FindByName( "helibut1" )[1]
        onbutt:Fire( "Unlock" )
        onbutt:Fire( "Press" )

        ulx.fancyLogAdmin( calling_ply, "#A started the helicopter" )
    else
        local offbutt = ents.FindByName( "helibut2" )[1]
        offbutt:Fire( "Unlock" )
        offbutt:Fire( "Press" )

        ulx.fancyLogAdmin( calling_ply, "#A turned off the helicopter" )
    end
end
local stopheli
SetGlobalBool( GBOOL_INCL_STOPHELI, false ) -- Marks whether clients should add this command


--[[
    This exists as otherwise players can hide or get stuck in the mancannon, prolonging rounds.
    Once this is used, the door can be opened freely, but the trap only locks the door the first time, anyway, so this is consistent with the map's design.
]]
function ulx.mancannon( calling_ply )
    -- No need to check if the entity exists, as otherwise this command wouldn't be added by the hook

    -- Unlock and open the mancannon's door
    local door = ents.FindByName( "suicideD1" )[1]
    door:Fire( "Unlock" )
    door:Fire( "Open" )

    ulx.fancyLogAdmin( calling_ply, "#A opened the mancannon door" )
end
local mancannon
SetGlobalBool( GBOOL_INCL_MANCANNON, false ) -- Marks whether clients should add this command


function ulx.controldisco( calling_ply, option )
    --[[
        The code to add this command only does so once it has fully checked that all of the named entities exist,
        so there is no need to check for them here.
        
        The command is also marked to only allow autocompletes as arguments, so there is no need to check
        the option parameter, as it will always be a valid config option.
    ]]

    -- Iterate through the selected option of the config, firing all configured entity inputs
    for _, cfg in ipairs( controldisco_configs[ GetGlobalString( GSTR_CONFIG_CONTROLDISCO ) ][ option ] ) do
        -- Iterate through all entities with the given name, firing the configured input
        local entities = ents.FindByName( cfg["name"] )
        for _, ent in ipairs( entities ) do
            ent:Fire( cfg["input"], cfg["param"], cfg["delay"] )
        end
    end

    ulx.fancyLogAdmin( calling_ply, "#A made the disco '#s'", option )
end
local controldisco
SetGlobalBool( GBOOL_INCL_CONTROLDISCO, false )
SetGlobalString( GSTR_CONFIG_CONTROLDISCO, "" )



-- Functions for adding conditional commands

-- Add the mancannon command to the client or server
local function addCmdMancannon()
    mancannon = ulx.command( CATEGORY_NAME, "ulx mancannon", ulx.mancannon, { "!mancannon" }, true )
    mancannon:defaultAccess( ULib.ACCESS_ADMIN )
    mancannon:help( "Opens the mancannon door on ba_jail_summer-based maps." )
end

-- Add the stopheli/startheli command to the client or server
local function addCmdStopHeli()
    stopheli = ulx.command( CATEGORY_NAME, "ulx stopheli", ulx.stopheli, { "!stopheli", "!stophelicopter" }, true )
    stopheli:addParam{ type=ULib.cmds.BoolArg, invisible=true }
    stopheli:defaultAccess( ULib.ACCESS_ADMIN )
    stopheli:help( "Shuts down the helicopter on new_summer-based maps." )
    stopheli:setOpposite( "ulx startheli", { _, true }, { "!startheli", "!starthelicopter" }, true )
end

-- Check that a table of entities given from a config all exist in the current map
local function checkValidEntities( config, option )
    -- Check that all of the entities in the option exist, failing if any don't
    for _, ent_cfg in ipairs( config[ option ] ) do
        -- If the current entity doesn't exist (and that isn't expected to be possible), fail this config and stop looking
        if ( next( ents.FindByName( ent_cfg["name"] ) ) == nil and config[ "status" ] and config[ "status" ][ ent_cfg[ "name" ] ][ "check_type" ] ~= "exists") then
            return false
        end
    end

    -- If here is reached, no entity was missing, so this is valid
    return true
end

-- Add the opencells and cellsstatus commands to the client or server
local function addCmdsCells( configs )
    -- If running serverside, find if there is a valid config. If there isn't, mark to not add the command.
    if ( configs and SERVER ) then
        -- Iterate through all the configs, checking if any work
        for id, cfg in pairs( configs ) do
            -- Check all entities for both open and close options
            if ( checkValidEntities( cfg, "open" ) and checkValidEntities( cfg, "close" ) ) then
                -- The open and close configs worked, so check the status config
                local failed = false
                for ent_name, ent_cfg in pairs( cfg["status"] ) do
                    -- If there are no entities by this name, fail the config
                    if ( next( ents.FindByName( ent_name ) ) == nil ) and ent_cfg["check_type"] ~= "exists" then
                        failed = true
                        break
                    end
                end

                -- If no entities failed, mark this config as the correct one
                if not failed then
                    SetGlobalString( GSTR_CONFIG_CELLS, id )
                    SetGlobalBool( GBOOL_INCL_CELLS, true )
                end
            end
        end
    end

    -- If marked to do so, add the commands
    if ( GetGlobalBool( GBOOL_INCL_CELLS ) ) then
        -- Add the opencells commands
        opencells = ulx.command( CATEGORY_NAME, "ulx opencells", ulx.opencells, "!opencells", true )
        opencells:addParam{ type=ULib.cmds.BoolArg, hint="Include solitary cells?", default=true, ULib.cmds.optional }
        opencells:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
        opencells:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
        opencells:defaultAccess( ULib.ACCESS_ADMIN )
        opencells:help( "Opens all cell doors." )
        opencells:setOpposite( "ulx closecells", { _, _, true, _ }, "!closecells", true )

        -- Add the cellsstatus command
        cellsstatus = ulx.command( CATEGORY_NAME, "ulx cellsstatus", ulx.cellsstatus, { "!cellsstatus", "!cellstatus" }, true )
        cellsstatus:defaultAccess( ULib.ACCESS_ADMIN )
        cellsstatus:help( "Tells the player whether the cell doors are currently open or closed." )
    end
end

-- Add the openarmory command to the client or server
local function addCmdOpenArmory( configs )
    -- If being done serverside, figure out which config works and mark it to be used. If none do, don't add the command.
    if ( configs and SERVER ) then
        -- Iterate through all the configs, checking if any work
        for id, cfg in pairs( configs ) do
            -- Check all entities for both open and close options
            if ( checkValidEntities( cfg, "open" ) and checkValidEntities( cfg, "close" ) ) then
                -- All entities exist, so use this config
                SetGlobalString( GSTR_CONFIG_ARMORY, id )
                SetGlobalBool( GBOOL_INCL_ARMORY, true )
            end
        end
    end

    -- If marked to include this command, do so
    if ( GetGlobalBool( GBOOL_INCL_ARMORY ) ) then
        openarmory = ulx.command( CATEGORY_NAME, "ulx openarmory", ulx.openarmory, { "!openarmory", "!openarmoury" }, true )
        openarmory:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
        openarmory:defaultAccess( ULib.ACCESS_ADMIN )
        openarmory:help( "Opens all armory doors." )
        openarmory:setOpposite( "ulx closearmory", { _, true }, { "!closearmory", "!closearmoury" }, true )
    end
end

-- Add the controldisco command to the client or server
local function addCmdControlDisco( configs )
    -- If being done serverside, figure out which config works and mark that to be used. If none do, return false and don't add the command.
    local options = {}
    if ( configs and SERVER ) then
        -- Iterate through all possible configs, checking if each one works, and stopping if the right one is found
        for id, cfg in pairs( configs ) do
            -- Iterate through all options in the config, checking that all of the entities named are there
            local failed = false
            for opt_name, opt_cfg in pairs( cfg ) do
                -- If this isn't the maps list, check if all named entities in this option's config exist, failing if any don't
                if ( opt_name ~= "maps" ) then
                    -- Iterate through all entities in this option, failing this config if any don't exist in the current map
                    for _, ent_cfg in ipairs( opt_cfg ) do
                        -- Check if the named entity exists, and fail the config if not
                        if ( next( ents.FindByName( ent_cfg["name"] ) ) == nil ) then
                            failed = true
                            options = {}
                            break
                        end
                    end

                    -- If any entities weren't found, no need to continue looking. Otherwise, add this option to the list of possible ones.
                    if ( failed ) then break
                    else
                        table.insert( options, opt_name )
                    end
                end
            end

            -- If this config works, save its ID as the config to use for this map, and add the command
            SetGlobalString( GSTR_CONFIG_CONTROLDISCO, id )
            SetGlobalBool( GBOOL_INCL_CONTROLDISCO, true )
        end
    end

    -- If there is actually a valid config to use, add the command
    if ( GetGlobalBool( GBOOL_INCL_CONTROLDISCO ) ) then
        -- If on clientside, get all the config options
        if ( CLIENT ) then
            options = {}
            for opt, _ in pairs( controldisco_configs[ GetGlobalString( GSTR_CONFIG_CONTROLDISCO ) ] ) do
                if opt ~= "maps" then table.insert( options, opt ) end
            end
        end

        -- Add command
        controldisco = ulx.command( CATEGORY_NAME, "ulx controldisco", ulx.controldisco, { "!controldisco", "!disco" }, true )
        controldisco:addParam{ type=ULib.cmds.StringArg, completes=options, default="stop music", ULib.cmds.restrictToCompletes, ULib.cmds.takeRestOfLine } -- Only allow the config's options as possible command options
        controldisco:defaultAccess( ULib.ACCESS_ADMIN )
        controldisco:help( "Controls the map's disco or similar music and lights." )
    end
end



-- Hooks

--[[
    Add map-specific commands only if that map is loaded.
    Client can only see entities within its view, so server must check and notify clients.
]]
hook.Add( "InitPostEntity", "jb7-ulx_maps_initpostentity", function()
    if ( SERVER ) then
        -- Serverside setup and configuration setting

        local map = game.GetMap()

        -- If on jb_new_summer_v2-based maps, add stopheli command
        if ( next( ents.FindByName( "helibut1" ) ) ~= nil and next( ents.FindByName( "helibut2" ) ) ~= nil and map:find( "_summer" ) ) then
            -- This is a valid map for stopheli, so add it to the server
            addCmdStopHeli()

            -- Mark for the client to also add the command
            SetGlobalBool( GBOOL_INCL_STOPHELI, true )
        end

        -- If the mancannon door exists on a map with "_summer" in the name, add the mancannon command
        if ( next( ents.FindByName( "suicideD1" ) ) ~= nil and map:find( "_summer" ) ) then
            -- Add command to server
            addCmdMancannon()

            -- Mark that this command should be added by clients
            SetGlobalBool( GBOOL_INCL_MANCANNON, true )
        end

        -- If there are any possible configs, attempt to add the cell door commands (sets globals internally)
        local configs = getPossibleConfigMatches( map, cell_door_configs )
        if ( next( configs ) ~= nil ) then
            addCmdsCells( configs )
        end

        -- If there are any possible configs, attempt to add the openarmory commands (sets globals internally)
        local configs = getPossibleConfigMatches( map, armory_door_configs )
        if ( next( configs ) ~= nil ) then
            addCmdOpenArmory( configs )
        end

        -- If there are any possible configs, attempt to add the controldisco command (sets globals internally)
        local configs = getPossibleConfigMatches( map, controldisco_configs )
        if ( next( configs ) ~= nil ) then
            addCmdControlDisco( configs )
        end
    elseif ( CLIENT ) then
        -- Clientside setup, using configuration set by server code above

        -- Add various commands if they have been marked to be so
        if ( GetGlobalBool( GBOOL_INCL_STOPHELI ) ) then
            addCmdStopHeli()
        end
        
        if ( GetGlobalBool( GBOOL_INCL_MANCANNON ) ) then
            addCmdMancannon()
        end

        if ( GetGlobalBool( GBOOL_INCL_CELLS ) ) then
            addCmdsCells()
        end
        
        if ( GetGlobalBool( GBOOL_INCL_ARMORY ) ) then
            addCmdOpenArmory()
        end

        if ( GetGlobalBool( GBOOL_INCL_CONTROLDISCO ) ) then
            addCmdControlDisco()
        end
    end
end )
