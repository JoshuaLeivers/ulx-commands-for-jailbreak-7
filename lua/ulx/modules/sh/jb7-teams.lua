--[[
    CREDIT:
        Ian Murray - ULX Commands for Jailbreak 7 (original version)
        VulpusMaximus - ULX Commands for Jailbreak 7 (new version)
        pepeisdatboi - forcewarden (original version)
]]

local CATEGORY_NAME = "Jailbreak"
local ERROR_GAMEMODE = "That command only works on Jailbreak!"


--[[
function ulx.forceguard( calling_ply, target_plys )
    
end
local forceguard = ulx.command( CATEGORY_NAME, "ulx forceguard", ulx.forceguard, { "!forceguard", "!fguard" }, true )
forceguard:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forceguard:defaultAccess( ULib.ACCESS_ADMIN )
forceguard:help( "Forces target(s) to guard team." )
]]

--[[
function ulx.forceprisoner( calling_ply, target_plys )
    
end
local forceprisoner = ulx.command( CATEGORY_NAME, "ulx forceprisoner", ulx.forceprisoner, { "!forceprisoner", "!fprisoner" }, true )
forceprisoner:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forceprisoner:defaultAccess( ULib.ACCESS_ADMIN )
forceprisoner:help( "Forces target(s) to prisoner team." )
]]

--[[
function ulx.forcespectator( calling_ply, target_plys )
    
end
local forcespectator = ulx.command( CATEGORY_NAME, "ulx forcespectator", ulx.forcespectator, { "!forcespectator", "!forcespec", "!fspectator", "!fspec", }, true )
forcespectator:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forcespectator:defaultAccess( ULib.ACCESS_ADMIN )
forcespectator:help( "Forces target(s) to spectator team." )
]]

--[[
function ulx.forcewarden( calling_ply, target_ply, override )

end
local forcewarden = ulx.command( CATEGORY_NAME, "ulx forcewarden", ulx.forcewarden, { "!forcewarden", "!fwarden" }, true )
forcewarden:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
forcewarden:addParam{ type=ULib.cmds.BoolArg, hint="override", ULib.cmds.optional }
forcewarden:defaultAccess( ULib.ACCESS_ADMIN )
forcewarden:help( "Forces target to warden role." )
]]

--[[
function ulx.demotewarden( calling_ply )
    
end
local demotewarden = ulx.command( CATEGORY_NAME, "ulx demotewarden", ulx.demotewarden, { "!demotewarden", "!dwarden", "!dw" }, true )
demotewarden:defaultAccess( ULib.ACCESS_ADMIN )
demotewarden:help( "Removes the warden status from the current warden." )
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
