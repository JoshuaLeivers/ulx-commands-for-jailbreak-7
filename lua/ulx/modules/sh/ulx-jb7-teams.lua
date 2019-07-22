local error_not_jailbreak = "The current gamemode is not Jailbreak!"
local CATEGORY_NAME = "Jailbreak"


function ulx.forceguard( calling_ply, target_plys )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		local affected_plys = {}
		for k, v in pairs( target_plys ) do
			if v:Team() == TEAM_GUARD then
				ULib.tsayError( calling_ply, v:Nick() .. " is already a guard!" )
			else
				v:SetTeam( TEAM_GUARD )
				v:KillSilent()
				v:SendNotification( "Forced to prisoners" )
				table.insert( affected_plys, v )
			end
		end
		ulx.fancyLogAdmin( calling_ply, "#A forced #T to guards", affected_plys )
	end
end
local forceguard = ulx.command( CATEGORY_NAME, "ulx forceguard", ulx.forceguard, { "!forceguard", "!makeguard", "!guard", "!fguard" } )
forceguard:defaultAccess( ULib.ACCESS_ADMIN )
forceguard:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forceguard:help( "Forces target(s) to guard team." )

function ulx.forceprisoner( calling_ply, target_plys )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		local affected_plys = {}
		for k, v in pairs( target_plys ) do
			if v:Team() == TEAM_PRISONER then
				ULib.tsayError( calling_ply, v:Nick() .. " is already a prisoner!" )
			else
				v:SetTeam( TEAM_PRISONER )
				v:KillSilent()
				v:SendNotification( "Forced to prisoners" )
				table.insert( affected_plys, v )
			end
		end
		ulx.fancyLogAdmin( calling_ply, "#A forced #T to prisoners", affected_plys )
	end
end
local forceprisoner = ulx.command( CATEGORY_NAME, "ulx forceprisoner", ulx.forceprisoner, { "!forceprisoner", "!makeprisoner", "!fprisoner", "!prisoner" } )
forceprisoner:defaultAccess( ULib.ACCESS_ADMIN )
forceprisoner:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forceprisoner:help( "Forces target(s) to prisoner team." )

function ulx.forcespectator( calling_ply, target_plys )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		local affected_plys = {}
		for k,v in pairs( target_plys ) do
			v:SetTeam( TEAM_SPECTATOR );
			v:KillSilent();
			v:SendNotification( "Forced to spectators" );
			table.insert( affected_plys, v )
		end
		ulx.fancyLogAdmin( calling_ply, "#A forced #T to spectators", affected_plys )
	end
end
local forcespectator = ulx.command( CATEGORY_NAME, "ulx forcespectator", ulx.forcespectator, { "!forcespectator", "!spectator", "!makespectator", "!makespec", "!forcespec", "!fspec" } )
forcespectator:defaultAccess( ULib.ACCESS_ADMIN )
forcespectator:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
forcespectator:help( "Forces target(s) to spectator mode." )

function ulx.forcewarden( calling_ply, target_ply, override )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		if ulx.getExclusive( target_ply, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		elseif not target_ply:Alive() then
			ULib.tsayError( calling_ply, target_ply:Nick() .. " is dead", true )
		elseif target_ply:IsFrozen() then
			ULib.tsayError( calling_ply, target_ply:Nick() .. " is frozen", true )
		elseif IsValid( JB:GetWarden() ) and not override then
				ULib.tsayError( calling_ply, "There is already a warden!" )
		elseif IsValid( JB:GetWarden() ) and override then
			local warden = JB.TRANSMITTER:GetJBWarden()
			if IsValid( warden ) then
				warden:RemoveWardenStatus()
			end
		end
		if not target_ply:Alive() or target_ply:Team() ~= TEAM_GUARD then
			target_ply:SetTeam( TEAM_GUARD )
			target_ply._jb_forceRespawn = true
			target_ply:Spawn()
		end
		target_ply:AddWardenStatus()
		ulx.fancyLogAdmin( calling_ply, "#A forced warden #T", target_ply )
	end
end
local forcewarden = ulx.command( CATEGORY_NAME, "ulx forcewarden", ulx.forcewarden, { "!forcewarden", "!makewarden", "!warden" } )
forcewarden:addParam{ type=ULib.cmds.PlayerArg }
forcewarden:defaultAccess( ULib.ACCESS_ADMIN )
forcewarden:help( "Makes the target the warden." )

function ulx.teleportguards( calling_ply )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		if IsValid( JB:GetWarden() ) then
			local warden = JB.TRANSMITTER:GetJBWarden()
			for k, v in pairs( team.GetPlayers( TEAM_GUARD ) ) do
				v:SetPos( warden:GetPos() )
			end
		ulx.fancyLogAdmin( calling_ply, "#A has teleported all guards to the warden" )
		else
			ULib.tsayError( calling_ply, "There is no warden to teleport the guards to!" )
		end
	end
end
local teleportguards = ulx.command( CATEGORY_NAME, "ulx teleportguards", ulx.teleportguards, { "!tpg", "!teleportguards", "!tpguards", "!teleguards" } )
teleportguards:defaultAccess( ULib.ACCESS_ADMIN )
teleportguards:help( "Teleport all guards to the warden." )

function ulx.guardban( calling_ply, target_ply, banlength, unban )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		if banlength == 0 then
			if unban then
				if tonumber( target_ply:GetPData( "guardbanned", 0) ) > os.time() or tobool( target_ply:GetPData( "guardbanned_perm", false ) ) then
					target_ply:RemovePData( "guardbanned" )
					target_ply:RemovePData( "guardbanned_perm" )
					target_ply:RemovePData( "guardbanned_on" )
					target_ply:RemovePData( "guardbanned_by" )
					ulx.fancyLogAdmin( calling_ply, "#A unbanned #T from guards", target_ply )
				else
					ULib.tsayError( calling_ply, "That player is not guardbanned!", true )
				end
			else
				target_ply:SetPData( "guardbanned_perm", true )
				target_ply:SetPData( "guardbanned_on", os.time() )
				target_ply:SetPData( "guardbanned_by", string.format( "%s (%s)", calling_ply:Name(), calling_ply:SteamID() ) )
				ulx.fancyLogAdmin( calling_ply, "#A banned #T from guards permanently", target_ply )
			end
		else
			target_ply:SetPData( "guardbanned", os.time() + banlength * 60 )
			target_ply:SetPData( "guardbanned_on", os.time() )
			target_ply:SetPData( "guardbanned_by", string.format( "%s (%s)", calling_ply:Name(), calling_ply:SteamID() ) )
			ulx.fancyLogAdmin( calling_ply, "#A banned #T from guards for " .. banlength .. " minutes", target_ply )
		end
		if not unban and target_ply:Team() == TEAM_GUARD then
			target_ply:SetTeam( TEAM_PRISONER )
			target_ply:KillSilent()
			target_ply:SendNotification( "Forced to prisoners" )
		end
	end
end
local guardban = ulx.command( CATEGORY_NAME, "ulx guardban", ulx.guardban, { "!guardban", "!gb", "!banguard" } )
guardban:defaultAccess( ULib.ACCESS_ADMIN )
guardban:addParam{ type=ULib.cmds.PlayerArg }
guardban:addParam{ type=ULib.cmds.NumArg, min=0, default=960, hint="ban length, 0 for permanent", ULib.cmds.optional }
guardban:addParam{ type=ULib.cmds.BoolArg, invisible=true }
guardban:setOpposite( "ulx unguardban", { _, _, 0, true }, { "!unguardban", "!guardunban", "!ungb", "!unbanguard" } )
guardban:help( "Bans target from guards." )

function ulx.wardenban( calling_ply, target_ply, banlength, unban )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		if banlength == 0 then
			if unban then
				if tonumber( target_ply:GetPData( "wardenbanned", 0 ) ) > os.time() or tobool( target_ply:GetPData( "wardenbanned_perm", false ) ) then
					target_ply:RemovePData( "wardenbanned" )
					target_ply:RemovePData( "wardenbanned_perm" )
					target_ply:RemovePData( "wardenbanned_on" )
					target_ply:RemovePData( "wardenbanned_by" )
					ulx.fancyLogAdmin( calling_ply, "#A unbanned #T from warden", target_ply )
				else
					ULib.tsayError( calling_ply, "That player is not wardenbanned!", true )
				end
			else
				target_ply:SetPData( "wardenbanned_perm", true )
				target_ply:SetPData( "wardenbanned_on", os.time() )
				target_ply:SetPData( "wardenbanned_by", string.format( "%s (%s)", calling_ply:Name(), calling_ply:SteamID() ) )
				ulx.fancyLogAdmin( calling_ply, "#A banned #T from warden permanently", target_ply )
			end
		else
			target_ply:SetPData( "wardenbanned", os.time() + banlength * 60 )
			target_ply:SetPData( "wardenbanned_on", os.time() )
			target_ply:SetPData( "wardenbanned_by", string.format( "%s (%s)", calling_ply:Name(), calling_ply:SteamID() ) )
			ulx.fancyLogAdmin( calling_ply, "#A banned #T from warden for " .. banlength .. " minutes", target_ply )
		end
		target_ply:RemoveWardenStatus()
	end
end
local wardenban = ulx.command( CATEGORY_NAME, "ulx wardenban", ulx.wardenban, { "!wardenban", "!wb", "!banwarden" } )
wardenban:defaultAccess( ULib.ACCESS_ADMIN )
wardenban:addParam{ type=ULib.cmds.PlayerArg }
wardenban:addParam{ type=ULib.cmds.NumArg, min=0, default=960, hint="ban length, 0 for permanent", ULib.cmds.optional }
wardenban:addParam{ type=ULib.cmds.BoolArg, invisible=true }
wardenban:setOpposite( "ulx unwardenban", { _, _, 0, true }, { "!unwardenban", "!wardenunban", "!unwb", "!unbanwarden" } )
wardenban:help( "Ban target from warden" )

function ulx.guardbaninfo( calling_ply, target_ply )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		if tobool(target_ply:GetPData( "guardbanned_perm", false) ) then
			ULib.tsay( calling_ply, target_ply:Name() .. " was guardbanned permanently by " .. target_ply:GetPData( "guardbanned_by", "an unknown person" ) .. "." )
			ULib.tsay( calling_ply, "The ban was issued about " .. math.Round( (os.time() - target_ply:GetPData( "guardbanned_on", 0 ) ) / 60 ) .. " minutes ago." )
		elseif tonumber( target_ply:GetPData( "guardbanned", 0 ) ) > os.time() then
			ULib.tsay( calling_ply, target_ply:Name() .. " was guardbanned by " .. target_ply:GetPData( "guardbanned_by", "an unknown person" ) .. "." )
			ULib.tsay( calling_ply, "The ban was issued about " .. math.Round( (os.time() - target_ply:GetPData( "guardbanned_on", 0 ) ) / 60 ) .. " minutes ago and will expire in about " .. math.Round( ( target_ply:GetPData( "guardbanned", 0 ) - os.time() ) / 60 ) .. " minutes." )
		else
			ULib.tsayError( calling_ply, target_ply:Name() .. " is not guardbanned!" )
		end
	end
end
local guardbaninfo = ulx.command( CATEGORY_NAME, "ulx guardbaninfo", ulx.guardbaninfo, { "!guardbaninfo", "!gbinfo" }, true )
guardbaninfo:defaultAccess( ULib.ACCESS_ADMIN ) --Allow all to use this command on themself and staff on others for desired results
guardbaninfo:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
guardbaninfo:help( "Prints info about a guardban." )

function ulx.wardenbaninfo( calling_ply, target_ply )
	if GAMEMODE_NAME ~= "jailbreak" then ULib.tsayError( calling_ply, error_not_jailbreak, true ) else
		if tobool( target_ply:GetPData( "wardenbanned_perm", false ) ) then
			ULib.tsay( calling_ply, target_ply:Name() .. " was wardenbanned permanently by " .. target_ply:GetPData( "wardenbanned_by", "an unknown person" ) .. "." )
			ULib.tsay( calling_ply, "The ban was issued about " .. math.Round( ( os.time() - target_ply:GetPData( "wardenbanned_on", 0 ) ) / 60 ) .. " minutes ago." )
		elseif tonumber( target_ply:GetPData( "wardenbanned", 0 ) ) > os.time() then
			ULib.tsay( calling_ply, target_ply:Name() .. " was wardenbanned by " .. target_ply:GetPData( "wardenbanned_by", "an unknown person" ) .. "." )
			ULib.tsay( calling_ply, "The ban was issued about " .. math.Round( ( os.time() - target_ply:GetPData( "wardenbanned_on", 0 ) ) / 60 ) .. " minutes ago and will expire in about " .. math.Round( ( target_ply:GetPData( "wardenbanned", 0 ) - os.time() ) / 60 ) .. " minutes." )
		else
			ULib.tsayError( calling_ply, target_ply:Name() .. " is not wardenbanned!" )
		end
	end
end
local wardenbaninfo = ulx.command( CATEGORY_NAME, "ulx wardenbaninfo", ulx.wardenbaninfo, { "!wardenbaninfo", "!wbinfo" }, true )
wardenbaninfo:defaultAccess( ULib.ACCESS_ADMIN ) --Allow all to use this command on themself and staff on others for desired results
wardenbaninfo:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
wardenbaninfo:help( "Prints info about a wardenban." )


hook.Add( "JailBreakPlayerSwitchTeam", "JB.ulx-jb7.SwitchTeam.GuardBan", function( player, team )
	if ( tonumber( player:GetPData( "guardbanned", 0 ) ) > os.time() or ( tobool( player:GetPData( "guardbanned_perm", false ) ) ) ) and team == TEAM_GUARD then
		player:SetTeam( TEAM_PRISONER )
		player:KillSilent()
		player:SendNotification( "Forced to prisoners" )
		if tobool(player:GetPData( "guardbanned_perm", false ) ) then
			ULib.tsayError( player, "You are permanently banned from joining guards!" )
		else
			ULib.tsayError( player, "You are banned from joining guards! You will be unbanned in about " .. math.Round( ( player:GetPData( "guardbanned", 0 ) - os.time() ) / 60 ) .. " minutes." )
		end
		ulx.fancyLog( true, "#T attemped to join guards while guardbanned.", { player } )
	end
end)

hook.Add( "JailBreakClaimWarden", "JB.ulx-jb7.ClaimWarden.WardenBan", function( player )
	if tonumber( player:GetPData( "wardenbanned", 0 ) ) > os.time() or ( tobool( player:GetPData( "wardenbanned_perm", false ) ) ) then
		player:RemoveWardenStatus()
		player:SendNotification( "Demoted from warden" )
		if tobool( player:GetPData( "wardenbanned_perm", false ) ) then
			ULib.tsayError( player, "You are permanently banned from becoming warden!" )
		else
			ULib.tsayError( player, "You are banned from becoming warden! You will be unbanned in about " .. math.Round( ( player:GetPData( "wardenbanned", 0 ) - os.time() ) / 60 ) .. " minutes." )
		end
		ulx.fancyLog( true, "#T attemped to become warden while wardenbanned.", { player } )
	end
end)
