--[[
    INFO:
        This module is to add extra tools for the warden to use.
        These might be better off as additions to the gamemode itself, but for now they are here.
]]

--[[
function ulx.rebel( calling_ply, target_plys, reverse )
    
end
local rebel = ulx.command( CATEGORY_NAME, "ulx rebel", ulx.rebel, "!rebel", true )
rebel:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.ignoreCanTarget }
rebel:addParam{ type=ULib.cmds.BoolArg, invisible=true }
rebel:defaultAccess( ULib.ACCESS_ALL )
rebel:help( "Declare target(s) as rebel(s).")
rebel:setOpposite( "ulx pardon", { _, _, true }, "!pardon", true )
]]