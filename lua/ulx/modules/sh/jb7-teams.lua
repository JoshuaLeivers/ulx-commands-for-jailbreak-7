--[[
    CREDIT:
        Ian Murray - ULX Commands for Jail Break 7 (original version)
        VulpusMaximus - ULX Commands for Jailbreak 7 (new version)
        pepeisdatboi - forcewarden (original version)
]]


if GAMEMODE_NAME == "jailbreak" then -- Only enable these commands when loaded in Jail Break gamemode

local CATEGORY_NAME = "Jail Break"

local CONCOMMAND_GUARD = "jb_team_select_guard"
local CONCOMMAND_PRISONER = "jb_team_select_prisoner"
local CONCOMMAND_SPECTATOR = "jb_team_select_spectator"

function ulx.forceguard( calling_ply, target_plys )
    -- Store list of successfully affected targets
    local affected_plys = {}
    local unaffected_plys = {}

    -- Go through targets, changing their team if successful
    for _, ply in ipairs( target_plys ) do
        if ply:Team() == TEAM_GUARD then -- Player is already a guard
            table.insert( unaffected_plys, ply )
        else
            table.insert( affected_plys, ply )
        end
    end

    -- If any targets couldn't be switched, tell the player
    if #unaffected_plys > 0 then
        -- Generate a comma-separated list of unaffected targets
        local msg = ""
        for k, ply in ipairs( unaffected_plys ) do
            if k ~= 1 then
                msg = msg .. "," .. ply:Nick()
            else
                msg = msg .. ply:Nick()
            end
        end

        -- Format message based on if plural or not
        if #unaffected_plys > 1 then
            msg = msg .. " are already guards!"
        else
            msg = msg .. " is already a guard!"
        end

        -- Send message
        ULib.tsayError( calling_ply, msg, true )
    end

    -- If no targets were able to be affected, just stop here
    if #affected_plys == 0 then return end

    -- Fail if too many players would be guards
    local spaces = JB:GetGuardsAllowed() - #team.GetPlayers(TEAM_GUARD)
    if spaces < #affected_plys then
        if spaces == 0 then
            ULib.tsayError( calling_ply, "The guards team is full!", true )
        else
            ULib.tsayError( calling_ply, "Only " .. spaces .. " spaces are available on the guard team, so these players can't all be moved!", true )
        end

        return
    end

    -- Switch the affected targets' teams
    for _, ply in ipairs( affected_plys ) do
        ply:SendNotification( "Admin switched you to guards" )
        ply:ConCommand( CONCOMMAND_GUARD )
    end

    -- Log action
    ulx.fancyLogAdmin( calling_ply, "#A forced #T to guards", affected_plys )
end
local forceguard = ulx.command( CATEGORY_NAME, "ulx forceguard", ulx.forceguard, { "!forceguard", "!fguard" }, true )
forceguard:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forceguard:defaultAccess( ULib.ACCESS_ADMIN )
forceguard:help( "Forces target(s) to guard team." )


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

end -- End of gamemode if-statement
