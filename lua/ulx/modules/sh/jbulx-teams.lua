local error_not_jailbreak = "The current gamemode is not jailbreak!"
local CATEGORY_NAME = "Jailbreak"


function ulx.makeguard(calling_ply,target_plys)
	if GAMEMODE_NAME == "jailbreak" then ULib.tsayError(calling_ply,error_not_jailbreak,true) else
		local affected_plys = {}
		for k,v in pairs(target_plys) do
			if v:Team() == TEAM_GUARD then
				ULib.tsayError(calling_ply,v:Nick().." is already a guard!")
			else
				v:SetTeam(TEAM_GUARD)
				v:KillSilent()
				v:SendNotification("Forced to prisoners")
				table.insert(affected_plys,v)
			end
		end
		ulx.fancyLogAdmin(calling_ply,"#A forced #T to guards",affected_plys)
	end
end
local makeguard = ulx.command(CATEGORY_NAME,"ulx makeguard",ulx.makeguard,{"!makeguard","!forceguard","!fguard","!guard"})
makeguard:defaultAccess(ULib.ACCESS_ADMIN)
makeguard:addParam{type=ULib.cmds.PlayersArg}
makeguard:help("Forces target(s) to guard team.")

function ulx.makeprisoner(calling_ply,target_plys)
	if GAMEMODE_NAME == "jailbreak" then ULib.tsayError(calling_ply,error_not_jailbreak,true) else
		local affected_plys = {}
		for k,v in pairs(target_plys) do
			if v:Team() == TEAM_PRISONER then
				ULib.tsayError(calling_ply,v:Nick().." is already a prisoner!")
			else
				v:SetTeam(TEAM_PRISONER)
				v:KillSilent()
				v:SendNotification("Forced to prisoners")
				table.insert(affected_plys,v)
			end
		end
		ulx.fancyLogAdmin(calling_ply,"#A forced #T to prisoners",affected_plys)
	end
end
local makeprisoner = ulx.command(CATEGORY_NAME,"ulx makeprisoner",ulx.makeprisoner,{"!makeprisoner","!forceprisoner","!fprisoner","!prisoner"})
makeprisoner:defaultAccess(ULib.ACCESS_ADMIN)
makeprisoner:addParam{type=ULib.cmds.PlayersArg}
makeprisoner:help("Forces target(s) to prisoner team.")

function ulx.makespectator(calling_ply,target_plys)
	if GAMEMODE_NAME == "jailbreak" then ULib.tsayError(calling_ply,error_not_jailbreak,true) else
		local affected_plys = {}
		for k,v in pairs(target_plys) do
			if v:Team() == TEAM_SPECTATOR then
				ULib.tsayError(calling_ply,v:Nick().." is already a spectator!")
			else
				v:SetTeam(TEAM_SPECTATOR)
				v:KillSilent()
				v:SendNotification("Forced to spectators")
				table.insert(affected_plys,v)
			end
		end
		ulx.fancyLogAdmin(calling_ply,"#A forced #T to spectators",affected_plys)
	end
end
local makespectator = ulx.command(CATEGORY_NAME,"ulx makespectator",ulx.makespectator,{"!makespectator","!makespec","!forcespec","!fspec","!forcespectator","!spectator"})
makespectator:defaultAccess(ULib.ACCESS_ADMIN)
makespectator:addParam{type=ULib.cmds.PlayersArg}
makespectator:help("Forces target(s) to spectator mode.")

function ulx.makewarden(calling_ply,target_ply,override)
	if GAMEMODE_NAME == "jailbreak" then ULib.tsayError(calling_ply,error_not_jailbreak,true) else
		if ulx.getExclusive(target_ply,calling_ply) then
			ULib.tsayError(calling_ply,ulx.getExclusive(target_ply,calling_ply),true)
		elseif not target_ply:Alive() then
			ULib.tsayError(calling_ply,target_ply:Nick().." is dead",true)
		elseif target_ply:IsFrozen() then
			ULib.tsayError(calling_ply,target_ply:Nick().." is frozen",true)
		elseif IsValid(JB:GetWarden()) and not override then
				ULib.tsayError(calling_ply,"There is already a warden!")
		elseif IsValid(JB:GetWarden()) and override then
			local warden = JB.TRANSMITTER:GetJBWarden()
			if IsValid(warden) then
				warden:RemoveWardenStatus()
			end
		end
		if not target_ply:Alive() or target_ply:Team() != TEAM_GUARD then
			target_ply:SetTeam(TEAM_GUARD)
			target_ply._jb_forceRespawn=true
			target_ply:Spawn()
		end
		target_ply:AddWardenStatus()
		ulx.fancyLogAdmin(calling_ply,"#A forced warden #T",target_ply)
	end
end
local makewarden = ulx.command(CATEGORY_NAME,"ulx makewarden",ulx.makewarden,{"!makewarden","!warden"})
makewarden:addParam{type=ULib.cmds.PlayerArg}
makewarden:defaultAccess(ULib.ACCESS_ADMIN)
makewarden:help("Makes the target the warden.")

function ulx.teleportguards(calling_ply)
	if GAMEMODE_NAME == "jailbreak" then ULib.tsayError(calling_ply,error_not_jailbreak,true) else
		if IsValid(JB:GetWarden()) then
			local warden = JB.TRANSMITTER:GetJBWarden()
			for k,v in pairs(team.GetPlayers(TEAM_GUARD)) do
				v:SetPos(warden:GetPos())
			end
		ulx.fancyLogAdmin(calling_ply,"#A has teleported all guards to the warden")
		else
			ULib.tsayError(calling_ply,"There is no warden to teleport the guards to!")
		end
	end
end
local teleportguards = ulx.command(CATEGORY_NAME,"ulx teleportguards",ulx.teleportguards,{"!tpg","!teleportguards","!tpguards","!teleguards"})
teleportguards:defaultAccess(ULib.ACCESS_ADMIN)
teleportguards:help("Teleport all guards to the warden.")
