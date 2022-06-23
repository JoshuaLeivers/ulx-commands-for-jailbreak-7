--[[
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
    Format:
        {maps=ARRAY_OF_MAP_NAME_MATCHES, open=ARRAY_OF_CELL_OPEN_TARGETS, close=ARRAY_OF_CELL_CLOSE_TARGETS}
    Example ARRAY_OF_MAP_NAME_MATCHES:
        {"jb_lego_RAGE", "jb_lego_jail", "jb_lego_.+_a20"}
    Format ARRAY_OF_CELL_OPEN_TARGETS/ARRAY_OF_CELL_CLOSE_TARGETS entry:
        {["name"]="cell_open_butt", ["input"]="Trigger", ["param"]="nil", ["delay"]=0}
    Example ARRAY_OF_CELL_OPEN_TARGETS/ARRAY_OF_CELL_CLOSE_TARGETS entry:
        {["name"] = "cell1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}
]]
local cell_door_configs = {
    {["maps"] = {"jb_lego_rage_.+"},
        ["open"] = {
            {["name"] = "cell1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}, -- Open main cells' doors
            {["name"] = "c_g", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0}, -- Show green light on button
            {["name"] = "auto_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0}, -- Disable cell auto_open logic
            {["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0} -- Open solitary cell door
        },
        ["close"] = {
            {["name"] = "cell1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0}, -- Close main cells' doors
            {["name"] = "c_g", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0}, -- Hide green light on button
            {["name"] = "auto_open", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0}, -- Enable cell auto_open logic (as is done in other versions of this map)
            {["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0} -- Close solitary cell door
        },
        ["status"] = {["name"] = "cell1", ["var"] = "m_toggle_state", ["openval"] = 0}
    },
    {["maps"] = {"jb_lego_jail_v[1234]"},
        ["open"] = {
            {["name"] = "cell1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}, -- Open main cells' doors
            {["name"] = "c_g", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0}, -- Show green light on open button
            {["name"] = "auto_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0}, -- Disable cell auto_open logic
            {["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}, -- Open solitary cell door
            {["name"] = "c_r", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0} -- Hide red light on close button
        },
        ["close"] = {
            {["name"] = "cell1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0}, -- Open main cells' doors
            {["name"] = "c_g", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0}, -- Show green light on open button
            {["name"] = "auto_open", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0}, -- Enable cell auto_open logic (as close button does)
            {["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0}, -- Open solitary cell door
            {["name"] = "c_r", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0} -- Hide red light on close button
        },
        ["status"] = {["name"] = "cell1", ["var"] = "m_toggle_state", ["openval"] = 0}
    },
    {["maps"] = {"jb_lego_jail_.+"},
        ["open"] = {
            {["name"] = "c1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}, -- Open main cells' doors
            {["name"] = "c_g", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0}, -- Show green light on open button
            {["name"] = "auto_open", ["input"] = "Disable", ["param"] = "nil", ["delay"] = 0}, -- Disable cell auto_open logic
            {["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}, -- Open solitary cell door
            {["name"] = "c_r", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0} -- Hide red light on close button
        },
        ["close"] = {
            {["name"] = "c1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0}, -- Open main cells' doors
            {["name"] = "c_g", ["input"] = "HideSprite", ["param"] = "nil", ["delay"] = 0}, -- Show green light on open button
            {["name"] = "auto_open", ["input"] = "Enable", ["param"] = "nil", ["delay"] = 0}, -- Enable cell auto_open logic (as close button does)
            {["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0}, -- Open solitary cell door
            {["name"] = "c_r", ["input"] = "ShowSprite", ["param"] = "nil", ["delay"] = 0} -- Hide red light on close button
        },
        ["status"] = {["name"] = "c1", ["var"] = "m_toggle_state", ["openval"] = 0}
    },
    {["maps"] = {"jb_carceris_021"},
        ["open"] = {
            {["name"] = "slider1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "slider2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}
        },
        ["close"] = {
            {["name"] = "slider1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "slider2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0}
        },
        ["status"] = {["name"] = "slider1", ["var"] = "m_toggle_state", ["openval"] = 0} -- This doesn't work because these are func_movelinear - TODO
    },
    {["maps"] = {"jb_carceris"},
        ["open"] = {
            {["name"] = "s1", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s2", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s3", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s4", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s5", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s6", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s7", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s8", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s9", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s10", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s11", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s12", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s13", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s14", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s15", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s16", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "iso", ["input"] = "Open", ["param"] = "nil", ["delay"] = 0}
        },
        ["close"] = {
            {["name"] = "s1", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s2", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s3", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s4", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s5", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s6", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s7", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s8", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s9", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s10", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s11", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s12", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s13", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s14", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s15", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "s16", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0},
            {["name"] = "iso", ["input"] = "Close", ["param"] = "nil", ["delay"] = 0}
        },
        ["status"] = {["name"] = "s1", ["var"] = "m_toggle_state", ["openval"] = 0}
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
    }
}

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


-- ULX Commands

function ulx.opencells( calling_ply, close, armory )
    local map = game.GetMap()

    -- End command with error message to player if unable to find any possibly matching configs
    local configs = getPossibleConfigMatches( map, armory and armory_door_configs or cell_door_configs )
    if configs == {} then
        ULib.tsayError( calling_ply, ERROR_MAP, true )
        return
    end

    -- Attempt each matching config until one works, ending inside here if one does
    for _, config in ipairs( configs ) do
        if attemptOpenDoors( config, close ) then
            ulx.fancyLogAdmin( calling_ply, "#A " .. ( close and "closed" or "opened" ) .. " the " 
                                .. ( armory and "armory" or "cell" ) .. " doors" )
            return
        end
    end
    
    -- If this hasn't ended by now, no attempted config succeeded, so display an error message to the player about it
    ULib.tsayError( calling_ply, ERROR_MAP, true )
end
local opencells = ulx.command( CATEGORY_NAME, "ulx opencells", ulx.opencells, "!opencells", true )
opencells:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
opencells:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
opencells:defaultAccess( ULib.ACCESS_ADMIN )
opencells:help( "Opens all cell doors." )
opencells:setOpposite( "ulx closecells", { _, true, _ }, "!closecells", true )


function ulx.openarmory( calling_ply, close )
    ulx.opencells( calling_ply, close, true ) -- Open armory code is just open cells but with a different config and log
end
local openarmory = ulx.command( CATEGORY_NAME, "ulx openarmory", ulx.openarmory, "!openarmory", true )
openarmory:addParam{ type=ULib.cmds.BoolArg, invisible=true, default=false, ULib.cmds.optional }
openarmory:defaultAccess( ULib.ACCESS_ADMIN )
openarmory:help( "Opens all armory doors." )
openarmory:setOpposite( "ulx closearmory", { _, true }, "!closearmory", true )


function ulx.cellsstatus( calling_ply )
    local map = game.GetMap()

    -- Get all matching cell door configs, and return with error message if none match
    local configs = getPossibleConfigMatches( map, cell_door_configs )
    if next(configs) == nil then
        ULib.tsayError( calling_ply, ERROR_MAP, true )
        return
    end
    
    -- Attempt to find status from all matching configs
    for _, config in ipairs( configs ) do
        local cf_status = config["status"]
        local entities = ents.FindByName( cf_status["name"] )
        
        -- If there is a matching entity, use its status and we have succeeded
        if next(entities) ~= nil then
            -- Doesn't matter which of this name - this should always be valid for any of this name
            print(dump(entities[1]:GetSaveTable(true)))
            local status = entities[1]:GetInternalVariable( cf_status["var"] ) == cf_status["openval"] and "open" or "closed"
            ULib.tsay( calling_ply, "The cell doors are currently " .. status .. "." )
            return
        end
    end

    -- If here is reached, command failed, so inform player
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


-- Helper Functions

function getPossibleConfigMatches( map, configs )
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

function attemptOpenDoors( config, close )
    -- Get the right key for the config section based on whether opening or closing
    local opcl = close and "close" or "open"
    
    -- Attempt to fire entities from config
    for _, ent_cf in ipairs ( config[opcl] ) do
        local entities = ents.FindByName( ent_cf["name"] )
        if entities ~= nil then
            for _, e in ipairs( entities ) do
                e:Fire( ent_cf["input"], ent_cf["param"], ent_cf["delay"] )
            end
        else
            -- The intended entity doesn't exist, so return that this config hasn't worked
            return false
        end
    end

    -- All entities came back valid, so this should have succeeded
    return true
end
