local error_not_jailbreak = "The current gamemode is not jailbreak!"
local CATEGORY_NAME = "Jailbreak"


function ulx.respawn( calling_ply, target_plys )
	for k,v in pairs( target_plys ) do
		if GAMEMODE_NAME == "jailbreak" then
			v._jb_forceRespawn=true
		end
		v:Spawn()
	end
	ulx.fancyLogAdmin( calling_ply, "#A respawned #T",  target_plys )
end
local respawn = ulx.command(CATEGORY_NAME, "ulx respawn", ulx.respawn, "!respawn")
respawn:defaultAccess( ULib.ACCESS_ADMIN )
respawn:addParam{ type=ULib.cmds.PlayersArg }
respawn:help( "Respawns target(s)." )

function ulx.revive( calling_ply, target_plys )
	local affected_plys = {}
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
			table.insert(affected_plys,v)
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A revived #T",  affected_plys )
end
local revive = ulx.command(CATEGORY_NAME, "ulx revive", ulx.revive, "!revive")
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
local toggleff = ulx.command(CATEGORY_NAME, "ulx toggleff", ulx.toggleff, "!toggleff")
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
local togglepickup = ulx.command(CATEGORY_NAME, "ulx togglepickup", ulx.togglepickup, "!togglepickup")
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
local demotewarden = ulx.command(CATEGORY_NAME, "ulx demotewarden", ulx.demotewarden, "!demotewarden")
demotewarden:defaultAccess( ULib.ACCESS_ADMIN )
demotewarden:help( "Remove the warden status from the current warden." )

function ulx.slaynr(calling_ply,target_plys,rounds)
	if GAMEMODE_NAME == "jailbreak" then
		local affected_plys = {}
		for k,v in pairs(target_plys) do
			local current_slays = tonumber(v:GetPData("slaynr_slays")) or 0
			local new_slays = current_slays + rounds
			v:SetPData("slaynr_slays",new_slays)
			table.insert(affected_plys,v)
		end
		ulx.fancyLogAdmin(calling_ply,"#A will slay #T for "..rounds.." rounds",affected_plys)
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true)
	end
end
local slaynr = ulx.command(CATEGORY_NAME,"ulx slaynr",ulx.slaynr,"!slaynr")
slaynr:addParam{type=ULib.cmds.PlayersArg}
slaynr:addParam{type=ULib.cmds.NumArg,default=1,min=1,ULib.cmds.optional}
slaynr:defaultAccess(ULib.ACCESS_ADMIN)
slaynr:help("Slay target(s) next round")

function ulx.rslaynr(calling_ply,target_plys,rounds)
	if GAMEMODE_NAME == "jailbreak" then
		local affected_plys = {}
		for k,v in pairs(target_plys) do
			local current_slays = tonumber(v:GetPData("slaynr_slays")) or 0
			if rounds > current_slays then
				ULib.tsayError(calling_ply,v:Nick().." does not have that many slays to remove.")
			else
				local new_slays = current_slays - rounds
				if rounds == 0 or new_slays == 0 then
					v:RemovePData("slaynr_slays")
				else
					v:SetPData("slaynr_slays",new_slays)
				end
				table.insert(affected_plys,v)
			end
		end
		if rounds == 0 then
			ulx.fancyLogAdmin(calling_ply,"#A removed all slays from #T",affected_plys)
		else
			ulx.fancyLogAdmin(calling_ply,"#A removed "..rounds.." slays from #T",affected_plys)
		end
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true)
	end
end
local rslaynr = ulx.command(CATEGORY_NAME,"ulx rslaynr",ulx.rslaynr,"!rslaynr")
rslaynr:addParam{type=ULib.cmds.PlayersArg}
rslaynr:addParam{type=ULib.cmds.NumArg,default=1,min=0,ULib.cmds.optional}
rslaynr:defaultAccess(ULib.ACCESS_ADMIN)
rslaynr:help("Remove slays from target(s)")

function ulx.cslaynr(calling_ply,target_ply)
	if GAMEMODE_NAME == "jailbreak" then
		local slays = tonumber(target_ply:GetPData("slaynr_slays")) or 0
		if slays > 0 then
			ULib.tsay(calling_ply,target_ply:Nick().." has "..slays.." slays remaining")
		else
			ULib.tsay(calling_ply,target_ply:Nick().." has no slays")
		end
	else
		ULib.tsayError(calling_ply, error_not_jailbreak, true)
	end
end
local cslaynr = ulx.command(CATEGORY_NAME,"ulx cslaynr",ulx.cslaynr,"!cslaynr")
cslaynr:addParam{type=ULib.cmds.PlayerArg}
cslaynr:defaultAccess(ULib.ACCESS_ADMIN)
cslaynr:help("Check target's slays")

if GAMEMODE_NAME == "jailbreak" then
	hook.Add("JailBreakRoundStart","JB.SlayNR.RoundStart",function()
		local affected_plys = {}
		for _,v in pairs(player.GetAll()) do
			local slays_left = tonumber(v:GetPData("slaynr_slays")) or 0
			if v:Alive() and slays_left > 0 then
				table.insert(affected_plys,v)
				v:KillSilent()
				local new_slays = slays_left - 1
				if v:Team() == 2 then
					v:ConCommand("jb_team_select_prisoner")
				end
				v:SetPData("slaynr_slays",new_slays)
			end
		end
		local count_plys = 0
		for _ in pairs(affected_plys) do count_plys = count_plys + 1 end
		if count_plys == 1 then
			ulx.fancyLog("#T was slain for their actions in previous rounds",affected_plys)
		elseif count_plys > 1 then
			ulx.fancyLog("#T were slain for their action in previous rounds",affected_plys)
		end
	end)
else
	ULib.tsayError(nil, error_not_jailbreak, true)
end
