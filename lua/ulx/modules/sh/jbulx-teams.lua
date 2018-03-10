local error_not_jailbreak = "The current gamemode is not jailbreak!"


function ulx.makeguard( calling_ply, target_plys )
	if GAMEMODE_NAME == "jailbreak" then
		local affected_plys = {}
		for k,v in pairs(target_plys) do
			v:SetTeam(TEAM_GUARD);
			v:KillSilent();
			v:SendNotification("Forced to guards");
			table.insert(affected_plys,v)
		end
		ulx.fancyLogAdmin(calling_ply,"#A forced #T to guards",affected_plys)
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true);
	end
end
local makeguard = ulx.command("Jailbreak", "ulx makeguard", ulx.makeguard, "!makeguard")
makeguard:defaultAccess( ULib.ACCESS_ADMIN )
makeguard:addParam{ type=ULib.cmds.PlayersArg }
makeguard:help( "Forces target(s) to guard team." )

function ulx.makeprisoner( calling_ply, target_plys )
	if GAMEMODE_NAME == "jailbreak" then
		local affected_plys = {}
		for k,v in pairs(target_plys) do
			v:SetTeam(TEAM_PRISONER);
			v:KillSilent();
			v:SendNotification("Forced to prisoners");
			table.insert(affected_plys,v)
		end
		ulx.fancyLogAdmin(calling_ply,"#A forced #T to prisoners",affected_plys)
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true);
	end
end
local makeprisoner = ulx.command("Jailbreak", "ulx makeprisoner", ulx.makeprisoner, "!makeprisoner" )
makeprisoner:defaultAccess( ULib.ACCESS_ADMIN )
makeprisoner:addParam{ type=ULib.cmds.PlayersArg }
makeprisoner:help( "Forces target(s) to prisoner team." )

function ulx.makespectator( calling_ply, target_plys )
	if GAMEMODE_NAME == "jailbreak" then
		local affected_plys = {}
		for k,v in pairs(target_plys) do
			v:SetTeam(TEAM_SPECTATOR);
			v:KillSilent();
			v:SendNotification("Forced to spectators");
			table.insert(affected_plys,v)
		end
		ulx.fancyLogAdmin(calling_ply,"#A forced #T to spectators",affected_plys)
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true);
	end
end
local makespectator = ulx.command("Jailbreak", "ulx makespectator", ulx.makespectator, {"!makespectator", "!makespec"} )
makespectator:defaultAccess( ULib.ACCESS_ADMIN )
makespectator:addParam{ type=ULib.cmds.PlayerArg }
makespectator:help( "Makes target a spectator." )
