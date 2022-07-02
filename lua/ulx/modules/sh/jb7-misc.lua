--[[
    INFO:
        This module adds other, miscellaneous commands that there aren't enough to fit in one separate category.
    CREDIT:
        TODO: Add any needed credits - check previous versions
]]


-- ULX Commands

--[[
function ulx.revive( calling_ply, target_plys, reverse )
    
end
local revive


-- Hooks

-- Register commands on GM:Initialize
-- GAMEMODE_NAME isn't initialized at the time ULX modules are loaded, so this is needed
hook.Add( "Initialize", "jb7-ulx_teams_initialize", function()
    if GAMEMODE_NAME == "jailbreak" then
        -- Load revive
        revive = ulx.command( CATEGORY_NAME, "ulx revive", ulx.revive, "!revive", true )
        revive:addParam{ type=ULib.cmds.PlayersArg }
        revive:defaultAccess( ULib.ACCESS_ADMIN )
        revive:help( "Revive target(s)." )
    end
end )
]]