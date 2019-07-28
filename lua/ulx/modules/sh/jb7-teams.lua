local CATEGORY_NAME = "Jailbreak"
local ERROR_GAMEMODE = "That command only works on Jailbreak!"


function ulx.forceguard( calling_ply, target_plys )
    if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, ERROR_GAMEMODE, true ) else
        local affected_plys = {}

        for k, v in ipairs( target_plys ) do
            if v:Team() == TEAM_GUARD then
                ULib.tsayError( calling_ply, v:Nick() .. " is already a guard!", true )
            else
                v:KillSilent()
                v:SendNotification( "Forced to guards" )
                v:SetTeam( TEAM_GUARD )

                table.insert( affected_plys, v )
            end
        end

        if #affected_plys > 0 then ulx.fancyLogAdmin( calling_ply, "#A forced #T to guards", affected_plys ) end
    end
end
local forceguard = ulx.command( CATEGORY_NAME, "ulx forceguard", ulx.forceguard, { "!forceguard", "!fguard", "!fg" }, true )
forceguard:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forceguard:defaultAccess( ULib.ACCESS_ADMIN )
forceguard:help( "Forces target(s) to guard team." )

function ulx.forceprisoner( calling_ply, target_plys )
    if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, ERROR_GAMEMODE, true ) else
        local affected_plys = {}

        for k, v in ipairs( target_plys ) do
            if v:Team() == TEAM_PRISONER then
                ULib.tsayError( calling_ply, v:Nick() .. " is already a prisoner!", true )
            else
                v:KillSilent()
                v:SetTeam( TEAM_PRISONER )
                v:SendNotification( "Forced to prisoners" )

                table.insert( affected_plys, v )
            end
        end

        if #affected_plys > 0 then ulx.fancyLogAdmin( calling_ply, "#A forced #T to prisoners", affected_plys ) end
    end
end
local forceprisoner = ulx.command( CATEGORY_NAME, "ulx forceprisoner", ulx.forceprisoner, { "!forceprisoner", "!fprisoner", "!fp" }, true )
forceprisoner:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forceprisoner:defaultAccess( ULib.ACCESS_ADMIN )
forceprisoner:help( "Forces target(s) to prisoner team." )

function ulx.forcespectator( calling_ply, target_plys )
    if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, ERROR_GAMEMODE, true ) else
        local affected_plys = {}

        for k, v in ipairs( target_plys ) do
            if v:Team() == TEAM_SPECTATOR then
                ULib.tsayError( calling_ply, v:Nick() .. " is already a spectator!", true )
            else
                v:KillSilent()
                v:SetTeam( TEAM_SPECTATOR )
                v:SendNotification( "Forced to spectators" )

                table.insert( affected_plys, v )
            end
        end

        if #affected_plys > 0 then ulx.fancyLogAdmin( calling_ply, "#A forced #T to prisoners", affected_plys ) end
    end
end
local forcespectator = ulx.command( CATEGORY_NAME, "ulx forcespectator", ulx.forcespectator, { "!forcespectator", "!forcespec", "!fspectator", "!fspec", "!fs" }, true )
forcespectator:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forcespectator:defaultAccess( ULib.ACCESS_ADMIN )
forcespectator:help( "Forces target(s) to spectator team." )

function ulx.forcewarden( calling_ply, target_ply, override )
    if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, ERROR_GAMEMODE, true ) else
        if target_ply:Team() ~= TEAM_GUARD then
            ULib.tsayError( calling_ply, target_ply:Nick() .. " isn't a guard!", true )

            return
        elseif not target_ply:Alive() then
            ULib.tsayError( calling_ply, target_ply:Nick() .. " is dead!", true )

            return
        elseif IsValid( JB:GetWarden() ) then
            if not override then
                ULib.tsayError( calling_ply, "There is already a warden!", true )

                return
            else
                JB:GetWarden():RemoveWardenStatus()
            end
        end

        target_ply:AddWardenStatus()

        ulx.fancyLogAdmin( calling_ply, "#A forced #T to warden", target_ply )
    end
end
local forcewarden = ulx.command( CATEGORY_NAME, "ulx forcewarden", ulx.forcewarden, { "!forcewarden", "!fwarden", "!fw" }, true )
forcewarden:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
forcewarden:addParam{ type=ULib.cmds.BoolArg, hint="override", ULib.cmds.optional }
forcewarden:defaultAccess( ULib.ACCESS_ADMIN )
forcewarden:help( "Forces the target to warden role." )

function ulx.demotewarden( calling_ply )
    if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, ERROR_GAMEMODE, true ) else
        local warden = JB:GetWarden()

        if IsValid( warden ) then
            warden:RemoveWardenStatus()

            ulx.fancyLogAdmin( calling_ply, "#A demoted #T from warden", warden )

            warden:SendNotification( "Demoted from warden" )
        else
            ULib.tsayError( calling_ply, "There is no warden to demote!", true )
        end
    end
end
local demotewarden = ulx.command( CATEGORY_NAME, "ulx demotewarden", ulx.demotewarden, { "!demotewarden", "!dwarden", "!dw" }, true )
demotewarden:defaultAccess( ULib.ACCESS_ADMIN )
demotewarden:help( "Removes the warden status from the current warden." )

function ulx.rebel( calling_ply, target_plys, reverse )
    if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, ERROR_GAMEMODE, true ) else
        if calling_ply == JB:GetWarden() and calling_ply:Alive() then
            local affected_plys = {}

            for k, v in ipairs( target_plys ) do
                if v:Team() ~= TEAM_PRISONER then
                    ULib.tsayError( calling_ply, v:Nick() .. " isn't a prisoner!", true )

                    return
                elseif not v:Alive() then
                    ULib.tsayError( calling_ply, v:Nick() .. " isn't alive!", true )

                    return
                elseif not reverse then
                    if v:GetRebel() then
                        ULib.tsayError( calling_ply, v:Nick() .. " is already a rebel!", true )

                        return
                    else
                        v:AddRebelStatus()

                        table.insert( affected_plys, v )
                    end
                else
                    if not v:GetRebel() then
                        ULib.tsayError( calling_ply, v:Nick() .. " isn't a rebel.", true )
                    else
                        v:RemoveRebelStatus()

                        JB:BroadcastNotification( v:Nick() .. " has been pardoned!" )

                        table.insert( affected_plys, v )
                    end
                end
            end

            if not reverse then
                if #affected_plys > 1 then
                    ulx.fancyLogAdmin( calling_ply, "#A declared #T rebels!", affected_plys )
                elseif #affected_plys > 0 then
                    ulx.fancyLogAdmin( calling_ply, "#A declared #T a rebel!", affected_plys )
                end
            else
                if #affected_plys > 0 then
                    ulx.fancyLogAdmin( calling_ply, "#A pardoned #T!", affected_plys )
                end
            end
        else
            ULib.tsayError( calling_ply, "You aren't the warden.", affected_plys, true )
        end
    end
end
local rebel = ulx.command( CATEGORY_NAME, "ulx rebel", ulx.rebel, "!rebel", true )
rebel:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.ignoreCanTarget }
rebel:addParam{ type=ULib.cmds.BoolArg, invisible=true }
rebel:defaultAccess( ULib.ACCESS_ALL )
rebel:help( "Declare target(s) as rebel(s).")
rebel:setOpposite( "ulx pardon", { _, _, true }, "!pardon", true )
