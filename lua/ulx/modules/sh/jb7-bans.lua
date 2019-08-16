--[[
    LICENSE: Creative Commons BY-NC-SA 3.0
    CREDIT:
        Ian Murray - ULX Commands for Jailbreak 7 (original)
        Team Ulysses - ULX and ULib source code [ban handling]
]]

local CATEGORY_NAME = "Jailbreak"

-- TODO: Add periodic ban checking
-- TODO: Test all commands and hooks

-- Initialise ban tables
if not sql.TableExists( "ulx_jb7_guardbans" ) then
    sql.Query(
        "CREATE TABLE IF NOT EXISTS ulx_jb7_guardbans ( " ..
        "steamid INTEGER NOT NULL PRIMARY KEY, " ..
        "time INTEGER NOT NULL, " ..
        "unban INTEGER NOT NULL, " ..
        "reason TEXT, " ..
        "name TEXT, " ..
        "admin TEXT, " ..
        "modified_admin TEXT, " ..
        "modified_time INTEGER " ..
        ");"
    )
end

if not sql.TableExists( "ulx_jb7_wardenbans" ) then
    sql.Query(
        "CREATE TABLE IF NOT EXISTS ulx_jb7_wardenbans ( " ..
        "steamid INTEGER NOT NULL PRIMARY KEY, " ..
        "time INTEGER NOT NULL, " ..
        "unban INTEGER NOT NULL, " ..
        "reason TEXT, " ..
        "name TEXT, " ..
        "admin TEXT, " ..
        "modified_admin TEXT, " ..
        "modified_time INTEGER " ..
        ");"
    )
end

-- Helper functions
local function ban( warden, ply, time, reason, admin )
    if not time or type( time ) ~= "number" then time = 0 end

    if ply:IsListenServerHost() then return end

    addBan( ply:SteamID(), time, reason, ply:Nick(), admin )
end

local function escapeOrNull( str )
    if not str then return "NULL"
    else return sql.SQLStr( str ) end
end

local function writeBan( warden, bandata )
    local table_name
    if warden then
        table_name = "ulx_jb7_wardenbans"
    else
        table_name = "ulx_jb7_guardbans"
    end

    sql.Query(
        "REPLACE INTO " .. table_name .. " ( steamid, time, unban, reason, name, admin, modified_admin, modified_time ) " ..
        string.format( "VALUES ( %s, %i, %i, %s, %s, %s, %s, %s )",
            util.SteamIDTo64( bandata.steamID ),
            bandata.time or 0,
            bandata.unban or 0,
            escapeOrNull( bandata.reason ),
            escapeOrNull( bandata.name ),
            escapeOrNull( bandata.admin ),
            escapeOrNull( bandata.modified_admin ),
            escapeOrNull( bandata.modified_time )
        )
    )
end

local function addBan( warden, steamid, time, reason, name, admin )
    if reason == "" then reason = nil end

    local admin_name

    if admin then
        admin_name = "(Console)"

        if admin:IsValid() then
            admin_name = string.format( "%s(%s)", admin:Nick(), admin:SteamID() )
        end
    end

    local t = {}
    local timeNow = os.time()

    if warden then
        if ulx.jb7.wardenbans[ steamid ] then
            t = ulx.jb7.wardenbans[ steamid ]
            t.modified_admin = admin_name
            t.modified_time = timeNow
        else
            t.admin = admin_name
        end
    else
        if ulx.jb7.guardbans[ steamid ] then
            t = ulx.jb7.guardbans[ steamid ]
            t.modified_admin = admin_name
            t.modified_time = timeNow
        else
            t.admin = admin_name
        end
    end

    t.time = t.time or timeNow

    if time > 0 then
        t.unban = ( ( time * 60 ) + timeNow )
    else
        t.unban = 0
    end

    t.reason = reason
    t.name = name
    t.steamID = steamid

    if warden then
        ulx.jb7.wardenbans[ steamid ] = t
    else
        ulx.jb7.guardbans[ steamid ] = t
    end

    local ply = player.GetBySteamID( steamid )
    if warden and ply:GetWarden() then
        ply:RemoveWardenStatus()
        ply:SendNotification( "Banned from warden status" )
    elseif ply:Team() == TEAM_GUARD then
        ply:KillSilent()
        ply:SetTeam( TEAM_PRISONER )
        ply:SendNotification( "Banned from guard team" )
    end

    writeBan( warden, t )
end

local function unban( warden, steamid )
    local table_name
    if warden then
        table_name = "ulx_jb7_wardenbans"
        ulx_jb7_wardenbans[ steamid ] = nil
    else
        table_name = "ulx_jb7_guardbans"
        ulx_jb7_guardbans[ steamid ] = nil
    end

    sql.Query( "DELETE FROM " .. table_name .. " WHERE steamid=" .. util.SteamIDTo64( steamid ) )
end

local function nillIfNull( data )
    if data == "NULL" then return nil
    else return data end
end

local function checkBan( warden, steamid )
    if warden then
        if not ulx.jb7.wardenbans[ steamid ] then return false end

        local bandata = ulx.jb7.wardenbans[ steamid ]
        if bandata.unban > os.time() or bandata.unban == 0 then
            return bandata
        else
            unban( true, steamid )
            return false
        end
    else
        if not ulx.jb7.guardbans[ steamid ] then return false end

        local bandata = ulx.jb7.guardbans[ steamid ]
        if bandata.unban > os.time() or bandata.unban == 0 then
            return bandata
        else
            unban( false, steamid )
            return false
        end
    end
end

-- Commands
function ulx.guardban( calling_ply, target_ply, minutes, reason )
    if target_ply:IsListenServerHost() or target_ply:IsBot() then
        ULib.tsayError( calling_ply, "This player is immune to guardbanning", true )
        return
    end

    local time = "for #s"
    if minutes == 0 then time = "permanently" end

    local str = "#A guardbanned #T " .. time
    if reason and reason ~= "" then str = str .. " (#s)" end

    ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )

    ban( false, target_ply, minutes, reason, calling_ply )
end
local guardban = ulx.command( CATEGORY_NAME, "ulx guardban", ulx.guardban, "!guardban", true )
guardban:addParam{ type=ULib.cmds.PlayerArg }
guardban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
guardban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
guardban:defaultAccess( ULib.ACCESS_ADMIN )
guardban:help( "Bans target from guard team." )

function ulx.guardbanid( calling_ply, steamid, minutes, reason )
    steamid = steamid:upper()

    if not ULib.isValidSteamID( steamid ) then
        ULib.tsayError( calling_ply, "Invalid steamid.", true )
        return
    end

    local name, target_ply
    local plys = player.GetAll()
    for i=1, #plys do
        if plys[ i ]:SteamID() == steamid then
            target_ply = plys[ i ]
            name = target_ply:Nick()
            break
        end
    end

    if target_ply and ( target_ply:IsListenServerHost() or target_ply:IsBot() ) then
        ULib.tsayError( calling_ply, "This player is immune to guardbanning", true )
        return
    end

    local time = "for #s"
    if minutes == 0 then time = "permanently" end

    local str = "#A guardbanned steamid #s "

    local displayid = steamid
    if name then
        displayid = displayid .. " (" .. name .. ") "
    end

    str = str .. time
    if reason and reason ~= "" then str = str .. " (#4s)" end

    ulx.fancyLogAdmin( calling_ply, str, displayid, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )

    addBan( false, steamid, minutes, reason, name, calling_ply )
end
local guardbanid = ulx.command( CATEGORY_NAME, "ulx guardbanid", ulx.guardbanid, "!guardbanid", true )
guardbanid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
guardbanid:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
guardbanid:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
guardbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
guardbanid:help( "Bans steamid from guard team." )

function ulx.unguardban( calling_ply, target_ply )
    unban( false, target_ply:SteamID() )

    ulx.fancyLogAdmin( calling_ply, "#A unguardbanned #T", target_ply )
end
local unguardban = ulx.command( CATEGORY_NAME, "ulx unguardban", ulx.unguardban, "!unguardban", true )
unguardban:addParam{ type=ULib.cmds.PlayerArg }
unguardban:defaultAccess( ULib.ACCESS_ADMIN )
unguardban:help( "Unbans target from guard team." )

function ulx.unguardbanid( calling_ply, steamid )
    steamid = steamid:upper()

    if not ULib.isValidSteamID( steamid ) then
        ULib.tsayError( calling_ply, "Invalid steamid.", true )
        return
    end

    name = ulx.jb7.guardbans[ steamid ] and ulx.jb7.guardbans[ steamid ].name

    unban( false, steamid )

    if name then
        ulx.fancyLogAdmin( calling_ply, "#A unguardbanned steamid #s", steamid .. " (" .. name .. ")" )
    else
        ulx.fancyLogAdmin( calling_ply, "#A unguardbanned steamid #s", steamid )
    end
end
local unguardbanid = ulx.command( CATEGORY_NAME, "ulx unguardbanid", ulx.unguardbanid, nil, false, false, true )
unguardbanid:addParam{ ULib.cmds.StringArg, hint="steamid" }
unguardbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
unguardbanid:help( "Unbans steamid from guard team." )

function ulx.guardbaninfo( calling_ply, target_ply )
    local bandata = checkBan( false, target_ply:SteamID() )
    if calling_ply:IsValid() then
        if bandata then
            ulx.fancyLog( calling_ply, "#T is guardbanned. Information printed to console.", target_ply )

            if SERVER then
                util.AddNetworkString( "ULXJB7BansTable" )
                net.Start( "ULXJB7BansTable" )
                net.WriteTable( bandata )
                net.Send( calling_ply )
            end

            if CLIENT then
                net.Receive( "ULXJB7BansTable", function()
                    PrintTable( net.ReadTable() )
                )
            end
        else
            ulx.fancyLog( calling_ply, "#T is not guardbanned.", target_ply )
        end
    else
        if bandata then
            PrintTable( bandata )
        else
            Msg( target_ply:Nick() .. " is not guardbanned." )
        end
    end
end
local guardbaninfo = ulx.command( CATEGORY_NAME, "ulx guardbaninfo", ulx.guardbaninfo, "!guardbaninfo", true )
guardbaninfo:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
guardbaninfo:defaultAccess( ULib.ACCESS_ALL ) -- For ideal use, allow all to use on themselves
guardbaninfo:help( "Returns info on a guardban." )

function ulx.guardbaninfoid( calling_ply, steamid )
    local bandata = checkBan( false, steamid )
    local name = bandata.name
    local msg = "(" .. steamid .. ")"

    if name then
        msg = name .. " " .. msg
    end

    if calling_ply:IsValid() then
        if bandata then
            msg = msg .. " is guardbanned. Information printed to console."

            if SERVER then
                util.AddNetworkString( "ULXJB7BansTable" )
                net.Start( "ULXJB7BansTable" )
                net.WriteTable( bandata )
                net.Send( calling_ply )
            end

            if CLIENT then
                net.Receive( "ULXJB7BansTable", function()
                    PrintTable( net.ReadTable() )
                )
            end
        else
            msg = msg .. " is not guardbanned."
        end

        ulx.fancyLog( calling_ply, msg )
    else
        if bandata then
            PrintTable( bandata )
        else
            Msg( msg .. " is not guardbanned." )
        end
    end
end
local guardbaninfoid = ulx.command( CATEGORY_NAME, "ulx guardbaninfoid", ulx.guardbaninfoid, "!guardbaninfoid", true )
guardbaninfoid:addParam{ type=ULib.cmds.StringArg }
guardbaninfoid:defaultAccess( ULib.ACCESS_OPERATOR )
guardbaninfoid:help( "Returns info on a guardban from a SteamID." )

function ulx.wardenban( calling_ply, target_ply, minutes, reason )
    if target_ply:IsListenServerHost() or target_ply:IsBot() then
        ULib.tsayError( calling_ply, "This player is immune to wardenbanning", true )
        return
    end

    local time = "for #s"
    if minutes == 0 then time = "permanently" end

    local str = "#A wardenbanned #T " .. time
    if reason and reason ~= "" then str = str .. " (#s)" end

    ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )

    ban( true, target_ply, minutes, reason, calling_ply )
end
local wardenban = ulx.command( CATEGORY_NAME, "ulx wardenban", ulx.wardenban, "!wardenban", true )
wardenban:addParam{ type=ULib.cmds.PlayerArg }
wardenban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
wardenban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
wardenban:defaultAccess( ULib.ACCESS_ADMIN )
wardenban:help( "Bans target from warden status." )

function ulx.wardenbanid( calling_ply, steamid, minutes, reason )
    steamid = steamid:upper()

    if not ULib.isValidSteamID( steamid ) then
        ULib.tsayError( calling_ply, "Invalid steamid.", true )
        return
    end

    local name, target_ply
    local plys = player.GetAll()
    for i=1, #plys do
        if plys[ i ]:SteamID() == steamid then
            target_ply = plys[ i ]
            name = target_ply:Nick()
            break
        end
    end

    if target_ply and ( target_ply:IsListenServerHost() or target_ply:IsBot() ) then
        ULib.tsayError( calling_ply, "This player is immune to wardenbanning", true )
        return
    end

    local time = "for #s"
    if minutes == 0 then time = "permanently" end

    local str = "#A wardenbanned steamid #s "

    local displayid = steamid
    if name then
        displayid = displayid .. "(" .. name .. ") "
    end

    str = str .. time
    if reason and reason ~= "" then str = str .. " (#4s)" end

    ulx.fancyLogAdmin( calling_ply, str, displayid, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )

    addBan( true, steamid, minutes, reason, name, calling_ply )
end
local wardenbanid = ulx.command( CATEGORY_NAME, "ulx wardenbanid", ulx.wardenbanid, nil, false, false, true )
wardenbanid:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
wardenbanid:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
wardenbanid:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine }
wardenbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
wardenbanid:help( "Bans steamid from warden status." )

function ulx.unwardenban( calling_ply, target_ply )
    unban( false, target_ply:SteamID() )

    ulx.fancyLogAdmin( calling_ply, "#A unwardenbanned #T", target_ply )
end
local unwardenban = ulx.command( CATEGORY_NAME, "ulx unwardenban", ulx.unwardenban, "!unwardenban", true )
unwardenban:addParam{ type=ULib.cmds.PlayerArg }
unwardenban:defaultAccess( ULib.ACCESS_ADMIN )
unwardenban:help( "Unbans target from warden status." )

function ulx.unwardenbanid( calling_ply, steamid )
    steamid = steamid:upper()

    if not ULib.isValidSteamID( steamid ) then
        ULib.tsayError( calling_ply, "Invalid steamid.", true )
        return
    end

    name = ulx.jb7.wardenbans[ steamid ] and ulx.jb7.wardenbans[ steamid ].name

    unban( false, steamid )

    if name then
        ulx.fancyLogAdmin( calling_ply, "#A unwardenbanned steamid #s", steamid .. " (" .. name .. ")" )
    else
        ulx.fancyLogAdmin( calling_ply, "#A unwardenbanned steamid #s", steamid )
    end
end
local unwardenbanid = ulx.command( CATEGORY_NAME, "ulx unwardenbanid", ulx.unwardenbanid, nil, false, false, true )
unwardenbanid:addParam{ ULib.cmds.StringArg, hint="steamid" }
unwardenbanid:defaultAccess( ULib.ACCESS_SUPERADMIN )
unwardenbanid:help( "Unbans steamid from warden status." )

function ulx.wardenbaninfo( calling_ply, target_ply )
    local bandata = checkBan( true, target_ply:SteamID() )
    if calling_ply:IsValid() then
        if bandata then
            ulx.fancyLog( calling_ply, "#T is wardenbanned. Information printed to console.", target_ply )

            if SERVER then
                util.AddNetworkString( "ULXJB7BansTable" )
                net.Start( "ULXJB7BansTable" )
                net.WriteTable( bandata )
                net.Send( calling_ply )
            end

            if CLIENT then
                net.Receive( "ULXJB7BansTable", function()
                    PrintTable( net.ReadTable() )
                )
            end
        else
            ulx.fancyLog( calling_ply, "#T is not wardenbanned.", target_ply )
        end
    else
        if bandata then
            PrintTable( bandata )
        else
            Msg( target_ply:Nick() .. " is not wardenbanned." )
        end
    end
end
local wardenbaninfo = ulx.command( CATEGORY_NAME, "ulx wardenbaninfo", ulx.wardenbaninfo, "!wardenbaninfo", true )
wardenbaninfo:addParam{ type=ULib.cmds.PlayerArg, default="^", ULib.cmds.optional }
wardenbaninfo:defaultAccess( ULib.ACCESS_ALL ) -- For ideal use, allow all to use on themselves
wardenbaninfo:help( "Returns info on a wardenban." )

function ulx.wardenbaninfoid( calling_ply, steamid )
    local bandata = checkBan( true, steamid )
    local name = bandata.name
    local msg = "(" .. steamid .. ")"

    if name then
        msg = name .. " " .. msg
    end

    if calling_ply:IsValid() then
        if bandata then
            msg = msg .. " is wardenbanned. Information printed to console."

            if SERVER then
                util.AddNetworkString( "ULXJB7BansTable" )
                net.Start( "ULXJB7BansTable" )
                net.WriteTable( bandata )
                net.Send( calling_ply )
            end

            if CLIENT then
                net.Receive( "ULXJB7BansTable", function()
                    PrintTable( net.ReadTable() )
                )
            end
        else
            msg = msg .. " is not wardenbanned."
        end

        ulx.fancyLog( calling_ply, msg )
    else
        if bandata then
            PrintTable( bandata )
        else
            Msg( msg .. " is not wardenbanned." )
        end
    end
end
local wardenbaninfoid = ulx.command( CATEGORY_NAME, "ulx wardenbaninfoid", ulx.wardenbaninfoid, "!wardenbaninfoid", true )
wardenbaninfoid:addParam{ type=ULib.cmds.StringArg }
wardenbaninfoid:defaultAccess( ULib.ACCESS_OPERATOR )
wardenbaninfoid:help( "Returns info on a wardenban from a SteamID." )

-- Hooks
hook.Add( "Initialize", "ULXJB7LoadBans", function()
    local results_guard = sql.Query( "SELECT * FROM ulx_jb7_guardbans" )
    local results_warden = sql.Query( "SELECT * FROM ulx_jb7_wardenbans" )

    ulx.jb7.guardbans = {}
    ulx.jb7.wardenbans = {}

    if results_guard then
        for i=1, #results_guard do
            local r = results_guard[ i ]

            r.steamID = util.SteamIDFrom64( r.steamid )
            r.steamid = nil
            r.reason = nillIfNull( r.reason )
            r.name = nillIfNull( r.name )
            r.admin = nillIfNull( r.admin )
            r.modified_admin = nillIfNull( r.modified_admin )
            r.modified_time = nillIfNull( r.modified_time )

            ulx.jb7.guardbans[ r.steamID ] = r

            checkBan( false, r.steamID )
        end
    end

    if results_warden then
        for i=1, #results_warden do
            local r = results_warden[ i ]

            r.steamID = util.SteamIDFrom64( r.steamid )
            r.steamid = nil
            r.reason = nillIfNull( r.reason )
            r.name = nillIfNull( r.name )
            r.admin = nillIfNull( r.admin )
            r.modified_admin = nillIfNull( r.modified_admin )
            r.modified_time = nillIfNull( r.modified_time )

            ulx.jb7.wardenbans[ r.steamID ] = r

            checkBan( true, r.steamID )
        end
    end
end, HOOK_MONITOR_HIGH )

hook.Add( "JailBreakPlayerSwitchTeam", "ULXJB7GuardBanCheck", function( ply, team )
    if checkBan( false, ply:SteamID() ) then
        ply:KillSilent()
        ply:SetTeam( TEAM_PRISONER )
        ply:SendNotification( "Banned from guard team" )

        ULib.tsayError( ply, "You are banned from joining the guard team.", true )

        ulx.fancyLog( true, "#T attempted to become a guard while guardbanned", ply )
    end
)

hook.Add( "JailBreakClaimWarden", "ULXJB7WardenBanCheck", function( ply )
    if checkBan( true, ply:SteamID() ) then
        ply:RemoveWardenStatus()
        ply:SendNotification( "Banned from warden status" )

        ULib.tsayError( ply, "You are banned from becoming warden.", true )

        ulx.fancyLog( true, "#T attempted to claim warden while wardenbanned", ply )
    end
)
