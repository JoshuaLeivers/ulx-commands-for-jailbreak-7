local error_not_jailbreak = "The current gamemode is not jailbreak!"


function ulx.respawn( calling_ply, target_plys )
	for k,v in pairs( target_plys ) do
		if GAMEMODE_NAME == "jailbreak" then
			v._jb_forceRespawn=true
		end
		v:Spawn()
	end
	ulx.fancyLogAdmin( calling_ply, "#A respawned #T",  target_plys )
end
local respawn = ulx.command("Jailbreak", "ulx respawn", ulx.respawn, "!respawn")
respawn:defaultAccess( ULib.ACCESS_ADMIN )
respawn:addParam{ type=ULib.cmds.PlayersArg }
respawn:help( "Respawns target(s)." )

function ulx.revive( calling_ply, target_plys )
	for k,v in pairs( target_plys ) do
		if v:Team() == TEAM_SPECTATOR then
			ULib.tsayError(calling_ply,v:Nick().." is in spectator mode and cannot be targetted.",true)
		elseif v:Alive() then
			ULib.tsayError(calling_ply,v:Nick().." is already alive, so cannot be revived.",true)
		else
			if GAMEMODE_NAME == "jailbreak" then
				v._jb_forceRespawn=true
			end
			v:Spawn()
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A respawned #T",  target_plys )
end
local revive = ulx.command("Jailbreak", "ulx revive", ulx.revive, "!revive")
revive:defaultAccess( ULib.ACCESS_ADMIN )
revive:addParam{ type=ULib.cmds.PlayersArg }
revive:help( "Revives target(s)." )

function ulx.toggleff( calling_ply )
	if GAMEMODE_NAME == "jailbreak" then
		JB.TRANSMITTER:SetJBWarden_PVPDamage(!JB.TRANSMITTER:GetJBWarden_PVPDamage());
		JB:BroadcastNotification("Friendly fire is now "..(JB.TRANSMITTER:GetJBWarden_PVPDamage() and "enabled" or "disabled"));
		ulx.fancyLogAdmin( calling_ply, "#A toggled friendly fire")
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true);
	end
end
local toggleff = ulx.command("Jailbreak", "ulx toggleff", ulx.toggleff, "!toggleff")
toggleff:defaultAccess( ULib.ACCESS_ADMIN )
toggleff:help( "Toggles friendly fire." )

function ulx.togglepickup( calling_ply )
	if GAMEMODE_NAME == "jailbreak" then
		JB.TRANSMITTER:SetJBWarden_ItemPickup(!JB.TRANSMITTER:GetJBWarden_ItemPickup());
		JB:BroadcastNotification("Item pickup is now "..(JB.TRANSMITTER:GetJBWarden_ItemPickup() and "enabled" or "disabled"));
		ulx.fancyLogAdmin( calling_ply, "#A toggled item pickup")
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true);
	end
end
local togglepickup = ulx.command("Jailbreak", "ulx togglepickup", ulx.togglepickup, "!togglepickup")
togglepickup:defaultAccess( ULib.ACCESS_ADMIN )
togglepickup:help( "Toggles item pickup." )

function ulx.demotewarden( calling_ply )
	if GAMEMODE_NAME == "jailbreak" then
		if IsValid(JB.TRANSMITTER:GetJBWarden()) then
			ulx.fancyLogAdmin( calling_ply, "#A removed the warden status from #T", JB.TRANSMITTER:GetJBWarden())
			JB.TRANSMITTER:GetJBWarden():RemoveWardenStatus();
		else
			ULib.tsayError(calling_ply, "There is no warden to demote!", true);
		end
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true);
	end
end
local demotewarden = ulx.command("Jailbreak", "ulx demotewarden", ulx.demotewarden, "!demotewarden")
demotewarden:defaultAccess( ULib.ACCESS_ADMIN )
demotewarden:help( "Remove the warden status from the current warden." )
