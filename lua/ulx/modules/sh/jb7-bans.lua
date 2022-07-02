--[[
    INFO:
        This module is for allowing admins to ban/unban players from different roles in JB7.
    CREDIT:
        Ian Murray - ULX Commands for Jailbreak 7 (original version)
        VulpusMaximus - ULX Commands for Jail Break 7 (new version)
]]

local CATEGORY_NAME = "Jailbreak"

--Commands
--[[
function ulx.guardban( calling_ply, target_ply, minutes, reason )
    
end
local guardban = ulx.command( CATEGORY_NAME, "ulx guardban", ulx.guardban, "!guardban", true )
guardban:addParam{ type=ULib.cmds.PlayerArg }
guardban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
guardban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
guardban:defaultAccess( ULib.ACCESS_ADMIN )
guardban:help( "Bans target from guard team." )
]]

--[[
function ulx.guardbanid( calling_ply, steamid, minutes, reason )
    
end
local guardbanid = ulx.command( CATEGORY_NAME, "ulx guardbanid", ulx.guardbanid, "!guardbanid", true )
guardbanid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
guardbanid:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
guardbanid:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
guardbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
guardbanid:help( "Bans steamid from guard team." )
]]

--[[
function ulx.unguardban( calling_ply, target_ply )

end
local unguardban = ulx.command( CATEGORY_NAME, "ulx unguardban", ulx.unguardban, "!unguardban", true )
unguardban:addParam{ type=ULib.cmds.PlayerArg }
unguardban:defaultAccess( ULib.ACCESS_ADMIN )
unguardban:help( "Unbans target from guard team." )
]]

--[[
function ulx.unguardbanid( calling_ply, steamid )
    
end
local unguardbanid = ulx.command( CATEGORY_NAME, "ulx unguardbanid", ulx.unguardbanid, nil, false, false, true )
unguardbanid:addParam{ ULib.cmds.StringArg, hint="steamid" }
unguardbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
unguardbanid:help( "Unbans steamid from guard team." )
]]

--[[
function ulx.guardbaninfo( calling_ply, target_ply )
    
end
local guardbaninfo = ulx.command( CATEGORY_NAME, "ulx guardbaninfo", ulx.guardbaninfo, "!guardbaninfo", true )
guardbaninfo:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
guardbaninfo:defaultAccess( ULib.ACCESS_ALL ) -- For ideal use, allow all to use on themselves
guardbaninfo:help( "Returns info on a guardban." )
]]

--[[
function ulx.guardbaninfoid( calling_ply, steamid )
    
end
local guardbaninfoid = ulx.command( CATEGORY_NAME, "ulx guardbaninfoid", ulx.guardbaninfoid, "!guardbaninfoid", true )
guardbaninfoid:addParam{ type=ULib.cmds.StringArg }
guardbaninfoid:defaultAccess( ULib.ACCESS_OPERATOR )
guardbaninfoid:help( "Returns info on a guardban from a SteamID." )
]]

--[[
function ulx.wardenban( calling_ply, target_ply, minutes, reason )
    
end
local wardenban = ulx.command( CATEGORY_NAME, "ulx wardenban", ulx.wardenban, "!wardenban", true )
wardenban:addParam{ type=ULib.cmds.PlayerArg }
wardenban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
wardenban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
wardenban:defaultAccess( ULib.ACCESS_ADMIN )
wardenban:help( "Bans target from warden status." )
]]

--[[
function ulx.wardenbanid( calling_ply, steamid, minutes, reason )
    
end
local wardenbanid = ulx.command( CATEGORY_NAME, "ulx wardenbanid", ulx.wardenbanid, nil, false, false, true )
wardenbanid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
wardenbanid:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
wardenbanid:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
wardenbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
wardenbanid:help( "Bans steamid from warden status." )
]]

--[[
function ulx.unwardenban( calling_ply, target_ply )
    
end
local unwardenban = ulx.command( CATEGORY_NAME, "ulx unwardenban", ulx.unwardenban, "!unwardenban", true )
unwardenban:addParam{ type=ULib.cmds.PlayerArg }
unwardenban:defaultAccess( ULib.ACCESS_ADMIN )
unwardenban:help( "Unbans target from warden status." )
]]

--[[
function ulx.unwardenbanid( calling_ply, steamid )
    
end
local unwardenbanid = ulx.command( CATEGORY_NAME, "ulx unwardenbanid", ulx.unwardenbanid, nil, false, false, true )
unwardenbanid:addParam{ ULib.cmds.StringArg, hint="steamid" }
unwardenbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
unwardenbanid:help( "Unbans steamid from warden status." )
]]

--[[
function ulx.wardenbaninfo( calling_ply, target_ply )
    
end
local wardenbaninfo = ulx.command( CATEGORY_NAME, "ulx wardenbaninfo", ulx.wardenbaninfo, "!wardenbaninfo", true )
wardenbaninfo:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
wardenbaninfo:defaultAccess( ULib.ACCESS_ALL ) -- For ideal use, allow all to use on themselves
wardenbaninfo:help( "Returns info on a wardenban." )
]]

--[[
function ulx.wardenbaninfoid( calling_ply, steamid )
    
end
local wardenbaninfoid = ulx.command( CATEGORY_NAME, "ulx wardenbaninfoid", ulx.wardenbaninfoid, "!wardenbaninfoid", true )
wardenbaninfoid:addParam{ type=ULib.cmds.StringArg }
wardenbaninfoid:defaultAccess( ULib.ACCESS_OPERATOR )
wardenbaninfoid:help( "Returns info on a wardenban from a SteamID." )
]]

-- Hooks
