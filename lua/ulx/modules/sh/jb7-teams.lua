--[[
    INFO:
        This module is for allowing admins to directly control who is on which team, and who is warden.
    CREDIT:
        Ian Murray - ULX Commands for Jailbreak 7 (original version)
        VulpusMaximus - ULX Commands for Jail Break 7 (new version)
        pepeisdatboi - forcewarden (original version)
        Team Ulysses @ ULX - affected_plys code
        Casual Bananas @ Jail Break 7 - team switching code, and various validity checks to mimic standard JB7 behaviour
]]


local CATEGORY_NAME = "Jail Break"
local ERROR_GAMEMODE = "That command only works in Jail Break!"


-- Helper Functions

-- Team switching code as same as gamemode code
local function swapTeam( ply, team_val )
    -- Swap the player's team
    ply:SetTeam( team_val )

    -- Kill/spawn the player as needed by their new gamemode, and notify them of their new team
    if team_val == TEAM_GUARD then
        ply:KillSilent()
        ply:SendNotification( "Switched to guards" )
    elseif team_val == TEAM_PRISONER then
        ply:KillSilent()
        ply:SendNotification( "Switched to prisoners" )
    elseif team_val == TEAM_SPECTATOR then
        ply:Spawn()
        ply:SendNotification( "Switched to spectator mode" )
    end

    -- Call the team switch hook as if done normally by the gamemode
    hook.Run( "JailBreakPlayerSwitchTeam", ply, ply:Team() )

    -- Reset the player's K/D to zeroes
    ply:SetFrags( 0 )
    ply:SetDeaths( 0 )
end


-- ULX Commands

function ulx.forceguard( calling_ply, target_plys, ignore_limit )
    -- Store list of successfully affected targets
    local affected_plys = {}
    local existguard_plys = {}
    local non_plys = {}

    -- Go through targets, adding them to the un/affected players lists as necessary
    for _, ply in ipairs( target_plys ) do
        if not IsValid( ply ) or not ply:IsPlayer() then -- Target isn't a valid player
            table.insert( non_plys, ply )
        elseif ply:Team() == TEAM_GUARD then -- Player is already a guard
            table.insert( existguard_plys, ply )
        else
            table.insert( affected_plys, ply )
        end
    end

    -- If any targets weren't valid players, tell the player
    if #non_plys > 0 then
        -- Send different format depending on plurality
        if #non_plys > 1 then
            ULib.tsayError( calling_ply, "Multiple targets weren't valid players!", true )
        else
            ULib.tsayError( calling_ply, "A target wasn't a valid player!", true )
        end
    end

    -- If any targets were already guards, tell the player
    if #existguard_plys > 0 then
        -- Generate a comma-separated list of unaffected targets
        local msg = ""
        for k, ply in ipairs( existguard_plys ) do
            if k ~= 1 then
                msg = msg .. "," .. ply:Nick()
            else
                msg = msg .. ply:Nick()
            end
        end

        -- Format message based on if plural or not
        if #existguard_plys > 1 then
            msg = msg .. " are already guards!"
        else
            msg = msg .. " is already a guard!"
        end

        -- Send message
        ULib.tsayError( calling_ply, msg, true )
    end

    -- If no targets were able to be affected, just stop here
    if #affected_plys == 0 then return end

    -- Fail if too many players would be guards, unless ignore_limit=true
    local spaces = JB:GetGuardsAllowed() - #team.GetPlayers( TEAM_GUARD )
    if spaces < #affected_plys and not ignore_limit then
        if spaces == 0 then
            ULib.tsayError( calling_ply, "The guards team is full!", true )
        elseif spaces == 1 then
            ULib.tsayError( calling_ply, "Only 1 space is available on the guard team, so these players can't all be swapped!", true )
        else
            ULib.tsayError( calling_ply, "Only " .. spaces .. " spaces are available on the guard team, so these players can't all be swapped!", true )
        end

        return
    end

    -- Log action - done before actual swap to show original team colors in names
    ulx.fancyLogAdmin( calling_ply, "#A forced #T to guards", affected_plys )

    -- Switch the affected targets' teams
    for _, ply in ipairs( affected_plys ) do
        ply:SendNotification( "Forced to guards" )
        swapTeam( ply, TEAM_GUARD )
    end
end
local forceguard


function ulx.forceprisoner( calling_ply, target_plys )
    -- Store list of successfully affected targets
    local affected_plys = {}
    local existprisoner_plys = {}
    local non_plys = {}

    -- Go through targets, adding them to the un/affected players lists as necessary
    for _, ply in ipairs( target_plys ) do
        if not IsValid( ply ) or not ply:IsPlayer() then -- Target isn't a valid player
            table.insert( non_plys, ply )
        elseif ply:Team() == TEAM_PRISONER then -- Player is already a prisoner
            table.insert( existprisoner_plys, ply )
        else
            table.insert( affected_plys, ply )
        end
    end

    -- If any targets weren't valid players, tell the player
    if #non_plys > 0 then
        -- Send different format depending on plurality
        if #non_plys > 1 then
            ULib.tsayError( calling_ply, "Multiple targets weren't valid players!", true )
        else
            ULib.tsayError( calling_ply, "A target wasn't a valid player!", true )
        end
    end

    -- If any targets were already prisoners, tell the player
    if #existprisoner_plys > 0 then
        -- Generate a comma-separated list of unaffected targets
        local msg = ""
        for k, ply in ipairs( existprisoner_plys ) do
            if k ~= 1 then
                msg = msg .. "," .. ply:Nick()
            else
                msg = msg .. ply:Nick()
            end
        end

        -- Format message based on if plural or not
        if #existprisoner_plys > 1 then
            msg = msg .. " are already prisoners!"
        else
            msg = msg .. " is already a prisoner!"
        end

        -- Send message
        ULib.tsayError( calling_ply, msg, true )
    end

    -- If no targets were able to be affected, just stop here
    if #affected_plys == 0 then return end

    -- Log action - done before actual swap to show original team colors in names
    ulx.fancyLogAdmin( calling_ply, "#A forced #T to prisoners", affected_plys )

    -- Switch the affected targets' teams
    for _, ply in ipairs( affected_plys ) do
        ply:SendNotification( "Forced to prisoners" )
        swapTeam( ply, TEAM_PRISONER )
    end
end
local forceprisoner


function ulx.forcespectator( calling_ply, target_plys )
    -- Store list of successfully affected targets
    local affected_plys = {}
    local existspec_plys = {}
    local non_plys = {}

    -- Go through targets, adding them to the un/affected players lists as necessary
    for _, ply in ipairs( target_plys ) do
        if not IsValid( ply ) or not ply:IsPlayer() then -- Target isn't a valid player (e.g. is a bot)
            table.insert( non_plys, ply )
        elseif ply:Team() == TEAM_SPECTATOR then -- Player is already a spectator
            table.insert( existspec_plys, ply )
        else
            table.insert( affected_plys, ply )
        end
    end

    -- If any targets weren't valid players, tell the player
    if #non_plys > 0 then
        -- Send different format depending on plurality
        if #non_plys > 1 then
            ULib.tsayError( calling_ply, "Multiple targets weren't valid players!", true )
        else
            ULib.tsayError( calling_ply, "A target wasn't a valid player!", true )
        end
    end

    -- If any targets couldn't be switched, tell the player
    if #existspec_plys > 0 then
        -- Generate a comma-separated list of unaffected targets
        local msg = ""
        for k, ply in ipairs( existspec_plys ) do
            if k ~= 1 then
                msg = msg .. "," .. ply:Nick()
            else
                msg = msg .. ply:Nick()
            end
        end

        -- Format message based on if plural or not
        if #existspec_plys > 1 then
            msg = msg .. " are already spectators!"
        else
            msg = msg .. " is already a spectator!"
        end

        -- Send message
        ULib.tsayError( calling_ply, msg, true )
    end

    -- If no targets were able to be affected, just stop here
    if #affected_plys == 0 then return end

    -- Log action - done before actual swap to show original team colors in names
    ulx.fancyLogAdmin( calling_ply, "#A forced #T to spectators", affected_plys )

    -- Switch the affected targets' teams
    for _, ply in ipairs( affected_plys ) do
        ply:SendNotification( "Forced to spectators" )
        swapTeam( ply, TEAM_SPECTATOR )
    end
end
local forcespectator


function ulx.forcewarden( calling_ply, target_ply, replace, ignore_state )
    -- Check if the target is a valid player and fail without any further checks if they aren't
    if not IsValid( target_ply ) or not target_ply:IsPlayer() then
        ULib.tsayError( calling_ply, "The target isn't a valid player!", true )
        return
    end
    
    -- Check if the player can be warden and fail with an error message to the player if not
    local err = ""

    -- If the target isn't a guard, fail
    if target_ply:Team() ~= TEAM_GUARD then
        err = target_ply:Nick() .. " isn't a guard, so they can't be the warden!"
    end

    -- If the target isn't alive, fail
    if not target_ply:Alive() then
        if err ~= "" then err = err .. " " .. target_ply:Nick() .. " is also not alive to be warden!"
        else err = target_ply:Nick() .. " is not alive to be warden!" end
    end

    -- If the player wouldn't normally be able to claim warden here and ignore_state=false, fail
    if not ignore_state then
        -- If not in SETUP state, fail
        if JB.State ~= STATE_SETUP then
            if err ~= "" then err = err .. " The game must also be in the setup stage for a warden to be added."
            else err = "The game must be in the setup stage for a warden to be added." end
        end

        -- If player has already been warden too much, fail
        if target_ply.wardenRounds and target_ply.wardenRounds >= tonumber( JB.Config.maxWardenRounds ) then
            if err == "" then err = target_ply:Nick() .. " has recently been the warden a lot and can't be it again for a while."
            else err = err .. " Also, " .. target_ply:Nick() .. " has recently been the warden a lot and can't be it again for a while." end
        end
    end

    -- If the player is already the warden, or another player is warden and replace=false, fail
    local current_warden = JB:GetWarden()
    if IsValid( current_warden ) then
        if current_warden == target_ply then
            err = target_ply:Nick() .. " is already the warden!"
        elseif not replace then
            if err == "" then
                err = err .. "There is already a warden!"
            else
                err = err .. " There is also already a warden!"
            end
        end
    end
    
    -- Send the error message and stop
    if err ~= "" then -- If an error message has been added, send it and stop
        ULib.tsayError( calling_ply, err, true )
        return
    end


    -- If there is already a warden, remove them, logging that this command was used either way
    if IsValid( current_warden ) then
        -- Remove the current warden
        current_warden:RemoveWardenStatus()
        if current_warden.wardenRounds then current_warden.wardenRounds = current_warden.wardenRounds - 1 end
        current_warden:SendNotification( "Replaced with a different warden" )

        -- Log that this command was used and that it replaced the current warden
        ulx.fancyLogAdmin( calling_ply, "#A forced #T to be warden, replacing #P", target_ply, current_warden )
    else
        -- Log that this command was used
        ulx.fancyLogAdmin( calling_ply, "#A forced #T to be warden", target_ply )
    end

    -- Add the target as the new warden and tell them
    target_ply:AddWardenStatus()
    target_ply:SendNotification( "Forced to warden" )

    -- Update the number of consecutive rounds the target has been warden
    if not target_ply.wardenRounds then
        target_ply.wardenRounds = 1
    else
        target_ply.wardenRounds = target_ply.wardenRounds + 1
    end

    -- Reset the number of consecutive rounds the rest of the guard team have been warden to 0
    for _, guard in pairs( team.GetPlayers( TEAM_GUARD ) ) do
        if IsValid( guard ) and guard ~= target_ply and guard.wardenRounds then
            guard.wardenRounds = 0
        end
    end

    -- Fire the hook as if the warden role was claimed normally
    hook.Run( "JailBreakClaimWarden", target_ply, target_ply.wardenRounds )
end
local forcewarden


function ulx.demotewarden( calling_ply, restore_limit )
    -- Fail and tell player if there isn't a warden to demote
    local warden = JB:GetWarden()
    if not IsValid( warden ) then
        ULib.tsayError( calling_ply, "There isn't a warden to demote!", true )
        return
    end

    -- Remove the player from the warden position
    warden:RemoveWardenStatus()
    warden:SendNotification( "Demoted by admin" )

    -- If command was called with arg to restore the warden's consecutive limit to before they were warden, do so
    if warden.wardenRounds and warden.wardenRounds > 0 and restore_limit then
        warden.wardenRounds = warden.wardenRounds - 1
    end

    -- Announce/log command
    ulx.fancyLogAdmin( calling_ply, "#A demoted the warden (#P)", warden )
end
local demotewarden



-- Hooks


--[[
    These commands are only registered if the gamemode is actually Jail Break, otherwise they wouldn't work anyway.
    This has to be done at least at GM:Initialize, as GAMEMODE_NAME isn't initialised until then.
]]
hook.Add( "Initialize", "jb7-ulx_teams_initialize", function()
    if GAMEMODE_NAME == "jailbreak" then
        -- Load forceguard
        forceguard = ulx.command( CATEGORY_NAME, "ulx forceguard", ulx.forceguard, { "!forceguard", "!fguard" }, true )
        forceguard:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
        forceguard:addParam{ type=ULib.cmds.BoolArg, default=false, hint="Ignore team size limit?", ULib.cmds.optional }
        forceguard:defaultAccess( ULib.ACCESS_ADMIN )
        forceguard:help( "Forces target(s) to guard team." )

        -- Load forceprisoners
        forceprisoner = ulx.command( CATEGORY_NAME, "ulx forceprisoner", ulx.forceprisoner, { "!forceprisoner", "!fprisoner" }, true )
        forceprisoner:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
        forceprisoner:defaultAccess( ULib.ACCESS_ADMIN )
        forceprisoner:help( "Forces target(s) to prisoner team." )

        -- Load forcespectator command
        forcespectator = ulx.command( CATEGORY_NAME, "ulx forcespectator", ulx.forcespectator, { "!forcespectator", "!forcespec", "!fspectator", "!fspec", }, true )
        forcespectator:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
        forcespectator:defaultAccess( ULib.ACCESS_ADMIN )
        forcespectator:help( "Forces target(s) to spectator team." )

        -- Load forcewarden command
        forcewarden = ulx.command( CATEGORY_NAME, "ulx forcewarden", ulx.forcewarden, { "!forcewarden", "!fwarden" }, true )
        forcewarden:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
        forcewarden:addParam{ type=ULib.cmds.BoolArg, hint="Replace current warden?", default=false, ULib.cmds.optional }
        forcewarden:addParam{ type=ULib.cmds.BoolArg, hint="Ignore round state?", default=true, ULib.cmds.optional }
        forcewarden:defaultAccess( ULib.ACCESS_ADMIN )
        forcewarden:help( "Forces target to warden role." )

        -- Load demotewarden command
        demotewarden = ulx.command( CATEGORY_NAME, "ulx demotewarden", ulx.demotewarden, { "!demotewarden", "!dwarden", "!dw" }, true )
        demotewarden:addParam{ type=ULib.cmds.BoolArg, default=true, hint="Restore the warden's streak?", ULib.cmds.optional }
        demotewarden:defaultAccess( ULib.ACCESS_ADMIN )
        demotewarden:help( "Removes the warden position from the current warden." )
    end
end )
