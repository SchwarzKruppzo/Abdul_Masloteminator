aadmin = {}
aadmin.prefix = "[AADMIN]"
aadmin.colors = {}
aadmin.colors.self = Color(110,180,225)
aadmin.colors.target = Color(145,210,65)
aadmin.colors.white = Color(255,255,255)
aadmin.colors.green = Color(0,255,0)
aadmin.colors.gray = Color(200,200,200)
aadmin.colors.red = Color(255,100,100)
aadmin.commands = {}
aadmin.commandprefixes = {">","!",".","/"}
aadmin.usergroups = {
	superadmin = {
		name = "Super Admin",
		color = Color(150,255,150),
		access = 1
	},
	admin = {
		name = "Admin",
		color = Color(255,220,100),
		access = 2
	},
	user = {
		name = "User",
		color = Color(255,255,255),
		access = 3
	},
}
local meta = FindMetaTable("Player")

if SERVER then
	function meta:AADMIN_SetAccess(str)
		self:SetNWString("m_sAccess",str)
		if !self:IsBot() then
			self:SetPData("m_sAccess",str) 
		end
	end
end
function meta:AADMIN_GetAccess() // IT MYST BE SHARED!!1111
	return self:GetNWString("m_sAccess")
end
function aadmin.SetupAccess( ply ) // local because capster
	if ply:AADMIN_GetAccess() == "" then
		if ply:GetPData("m_sAccess") == nil then
			ply:AADMIN_SetAccess("user")
		else
			ply:AADMIN_SetAccess(ply:GetPData("m_sAccess"))
		end
	end
end
hook.Add("PlayerInitialSpawn","AADMIN_LIB_USERGROUP_PIS",aadmin.SetupAccess)

local meta = FindMetaTable("Player")
function meta:IsSuperAdmin()
	if not aadmin then return false end
	if self:AADMIN_GetAccess() == "" then return false end
	
	local access = aadmin.usergroups[self:AADMIN_GetAccess()].access
	if access == 1 then
		return true
	else
		return false
	end
end
function meta:IsAdmin()
	if not aadmin then return false end
	if self:AADMIN_GetAccess() == "" then return false end
	
	local access = aadmin.usergroups[self:AADMIN_GetAccess()].access
	if access == 2 or access == 1 then
		return true
	else
		return false
	end
end
function meta:IsUserGroup( str )
	if not aadmin then return false end
	if self:AADMIN_GetAccess() == str then
		return true
	else
		return false
	end
end

hook.Add("AADMIN_COMMAND_CheckAccess","main.cpp",function( ply, cmd )
	if aadmin.commands[ cmd ] then
		if IsValid( ply ) then
			local currentAccess = aadmin.usergroups[ ply:AADMIN_GetAccess() ].access
			local cmdAccess = aadmin.commands[ cmd ].access
			if currentAccess <= cmdAccess then
				return true,""
			else
				return false,"Access denied"
			end
		end
	end
end)
function aadmin.CreateCommand( str, func, access, desc )
	aadmin.commands = aadmin.commands or {}
	aadmin.commands[str] = { name = str, access = access or 1, func = func, desc = desc }
end
function aadmin.RunCommand( ply, name, args )
	if IsValid(ply) then
		local canRun,reason = hook.Call( "AADMIN_COMMAND_CheckAccess", GAMEMODE, ply, name )
		if canRun then
			aadmin.commands[name].func(ply,args)
		else
			aadmin.SystemNotify(ply,aadmin.colors.red,reason)
		end
	else
		aadmin.commands[name].func(ply,args)
	end
end
function aadmin.RunConCommand(ply, _, args)
	if aadmin.commands[args[1]] then
		local name = args[1]
		table.remove(args, 1)
		aadmin.RunCommand(ply, name, args)
	end
end
function aadmin.RunCommandOnSay( ply, str )
	local prefix = string.Left(str,1)
	if table.HasValue(aadmin.commandprefixes,prefix) then
		local name = string.match(str,prefix.."(.-) ") or string.match(str,prefix.."(.+)") or ""
		local args = string.match(str,prefix..".- (.+)") or ""
		name = string.lower(name) // FOR BIG CHARS MOTHAFUCKA
		local t_args = {}
		if args ~= "" then
			t_args = string.Explode(" ",args)
		end
		if aadmin.commands[name] then // if command with that name is exist then we fuck it.
			aadmin.RunCommand( ply, name, t_args )
			return true
		end
	end
end
if SERVER then
	hook.Add("PlayerSay","AADMIN_LIB_COMMAND_PS",aadmin.RunCommandOnSay)
	concommand.Add("aadmin", aadmin.RunConCommand)
	aadmin.CreateCommand( "setaccess", function(ply,args)
		local target,nick = aadmin.FindPlayer( args[1] )
		local rank = args[2]
		if IsValid(target) then
			if target:IsPlayer() then
				if !aadmin.usergroups[rank] then 
					aadmin.SystemNotify(ply,aadmin.colors.red,"No such usergroup found")
					return
				end
				if target:AADMIN_GetAccess() ~= rank then
					target:AADMIN_SetAccess(rank)
					aadmin.CommandNotify(ply," has set ",nick,"",""," access to ",rank)
				end
			end
		end
	end, 2 , "<player name> <usergroup name>" )
end

function aadmin.unpack( table )
	local str = ""
	for k,v in pairs( table ) do
		if type(v) ~= "table" then
			str = str .. v
		end
	end
	return str;
end
local function DestroyColor(...)
	local args = {...}
	for k,v in pairs(args) do
		if type(v) == "table" and v.r then
			table.remove(args, k)
		end
	end
	return args
end
 
function aadmin.Print(...)
	if CLIENT then return error("Calling aadmin.Print from client?") end
	local args = DestroyColor(...)
	MsgC(Color(100, 255, 255), "[",Color(100, 200, 200), "AADMIN",Color(100, 255, 255), "] ")
	print(aadmin.unpack(args))
end
 
function aadmin.PrintServer(...)
	if CLIENT then return error("Calling aadmin.PrintServer from client?") end
	local args = DestroyColor(...)
	MsgC(Color(100, 100, 255), "[",Color(100, 100, 200), "AADMIN - Server",Color(100, 100, 255), "] ")
	print(aadmin.unpack(args))
end
 
 
function aadmin.PrintClient(...)
	if SERVER then return error("Calling aadmin.PrintClient from server?") end
	local args = DestroyColor(...)
	MsgC(Color(255, 100, 100), "[",Color(200, 100, 100), "AADMIN - Client",Color(255, 100, 100), "] ")
	print(aadmin.unpack(args))
end

if ( SERVER ) then
	function aadmin.Notify(...)
		local args = {...}
	 
		if args[1].IsPlayer and args[1]:IsPlayer() then
			ply = args[1]
			table.remove(args, 1)
			return ply:ChatAddText(unpack(args))
		end
		aadmin.Print(unpack(args))
		return ChatAddText(unpack(args))
	end
	function aadmin.SystemNotify( ply,... )
		if IsValid(ply) then
			local args = {...}
			aadmin.Notify(ply,aadmin.colors.green,aadmin.prefix,aadmin.colors.white,">",unpack(args))
		else
			local args = {...}
			aadmin.Print(unpack(args))
		end
	end
	function aadmin.CommandNotify(ply,text,tply,text2,var1,text3,var2)
		local text2 = text2 or ""
		local var1 = var1 or ""
		local text3 = text3 or ""
		local var2 = var2 or ""
		if IsValid(ply) then
			aadmin.Notify(aadmin.colors.self,ply:Nick(),aadmin.colors.white,text,aadmin.colors.target,tply,aadmin.colors.white,text2,aadmin.colors.gray,var1,aadmin.colors.white,text3,aadmin.colors.gray,var2)
		elseif type(ply) == "string" then
			aadmin.Notify(aadmin.colors.self,ply,aadmin.colors.white,text,aadmin.colors.target,tply,aadmin.colors.white,text2,aadmin.colors.gray,var1,aadmin.colors.white,text3,aadmin.colors.gray,var2)
		else
			aadmin.Notify(aadmin.colors.self,"Console",aadmin.colors.white,text,aadmin.colors.target,tply,aadmin.colors.white,text2,aadmin.colors.gray,var1,aadmin.colors.white,text3,aadmin.colors.gray,var2)
		end
	end
end
function aadmin.FindPlayer( name )
	local entity = easylua.FindEntity( name )
	local nick = "unnamed"
	if type(entity) =="table" then
		nick = "all"
	else
		if entity:IsPlayer() then
			nick = entity:Nick()
		end
	end
	return entity,nick
end

timer.Simple(.1,function()
aadmin.lBanTime = {}
aadmin.lBanReason = {}
aadmin.lBanTime[0] = " permently"
aadmin.lBanTime[1] = " for %s minutes"
aadmin.lBanReason[""] = " without reason."
aadmin.lBanReason["1"] = " with reason %s"

local meta = FindMetaTable("Player")
function meta:IsBanned()
	if !file.Exists( "aadmin_bans.txt", "DATA" ) then return end
	local read = luadata.ReadFile( "aadmin_bans.txt" )
	if read[ self:SteamID() ] then
		return true,read[ self:SteamID() ].r
	else
		return false,""
	end
end
function aadmin.Ban( steamid, time, reason, banner )
	local nick = "Console"
	if banner:IsPlayer() then
		nick = banner:Nick() // cheat 228
	end
	
	local save = {}
	save[steamid] = {t = time,r = reason, comid = util.SteamIDTo64( steamid ), banner = nick}
	local str = util.TableToJSON( save )
	
	if !file.Exists( "aadmin_bans.txt", "DATA" ) then
		luadata.WriteFile( "aadmin_bans.txt", save )
	else
		local read = luadata.ReadFile( "aadmin_bans.txt" )
		read[steamid] = {t = time,r = reason, comid = util.SteamIDTo64( steamid ), banner = nick}
		luadata.WriteFile( "aadmin_bans.txt", read )
	end
end
function aadmin.UnBan( steamid )
	if !file.Exists( "aadmin_bans.txt", "DATA" ) then return end
	local read = luadata.ReadFile( "aadmin_bans.txt" )
	if read[ steamid ] then
		read[ steamid ].banner = nil
		read[ steamid ].comid = nil
		read[ steamid ].t = nil
		read[ steamid ].r = nil
		read[ steamid ] = nil
		luadata.WriteFile( "aadmin_bans.txt", read )
	end
end
function aadmin.IsBanned( comid )
	if !file.Exists( "aadmin_bans.txt", "DATA" ) then return end
	local read = luadata.ReadFile( "aadmin_bans.txt" )
	for k,v in pairs(read) do
		if v.comid == comid then
			return true,"You are banned by "..v.banner.." with reason "..v.r
		end
	end
	return false,""
end
function aadmin.IsBannedSteamID( steamid )
	if !file.Exists( "aadmin_bans.txt", "DATA" ) then return end
	local read = luadata.ReadFile( "aadmin_bans.txt" )
	if read[ steamid ] then
		return true
	else
		return false
	end
end
if SERVER then
	connect_manager = {}

	function connect_manager.Join(...)
		MsgC(Color(0,255,0), "[")
		MsgC(Color(0,200,0), "Join")
		MsgC(Color(0,255,0), "] ")
		print(...)
	end

	function connect_manager.WrongPass(...)
		MsgC(Color(255,0,0), "[")
		MsgC(Color(200,0,0), "WrongPass")
		MsgC(Color(255,0,0), "] ")
		print(...)
	end

	function connect_manager.Banned(...)
		MsgC(Color(255,0,0), "[")
		MsgC(Color(200,0,0), "Banned")
		MsgC(Color(255,0,0), "] ")
		print(...)
	end

	function connect_manager.Disconnect(...)
		MsgC(Color(200,200,200), "[")
		MsgC(Color(150,150,150), "Disconnect")
		MsgC(Color(200,200,200), "] ")
		print(...)
	end
	gameevent.Listen( "player_disconnect" )
	
	function aadmin.CheckBan(steamID, ipAdderss, svPass, clPass, strName)
		connect_manager.Join("Nick: "..strName..". Steam Profile: http://steamcommunity.com/profiles/" .. steamID.." IP Address: "..ipAdderss )
		local ban,reason = aadmin.IsBanned( steamID  )
		if ban then
			connect_manager.Banned("Kick: "..strName)
			return false, reason
		end
		if svPass != "" then
			if svPass != clPass then
				connect_manager.WrongPass("Kick: "..strName)
				return false, "#GameUI_ServerRejectBadPassword"
			end
		end
	end
	
	-- hooks
	hook.Add("CheckPassword","AADMIN_LIB_CHECKBAN",aadmin.CheckBan)
	hook.Add( "player_disconnect", "AADMIN_LIB_DISCONNECT", function( data )
		connect_manager.Disconnect(data.name.." ("..data.reason..")")
	end)
	
	aadmin.CreateCommand( "rcon", function( ply, args )
		if args[1] == nil then
			aadmin.SystemNotify( ply, aadmin.colors.red, "Bad argument #1: commands expected, got shit." )
			return
		else
			RunConsoleCommand( unpack(args))
		end
	end, 1 , "<commands>" )
	
	aadmin.CreateCommand( "kick", function( ply, args )	
		local t_ply,nick = aadmin.FindPlayer( args[1] )
		local reason = args[2] or ""
		if IsValid( t_ply ) then
			if reason ~= "" then
				aadmin.CommandNotify(ply," has kicked ",nick,"",""," with reason ",reason)
			else
				aadmin.CommandNotify(ply," has kicked ",nick,"",""," without reason.")
			end
			t_ply:Kick( reason )
		end
	end, 2 , "<player name> [reason]" )
	aadmin.CreateCommand( "ban", function( ply, args )	
		local t_ply,nick = aadmin.FindPlayer( args[1] )
		local time = args[2] or 0
		local reason = table.concat( args, " ", 3)
		if IsValid( t_ply ) then
			local correct_time = 0
			if tonumber(time) ~= nil then
				correct_time = tonumber(time)
			end
			
			if correct_time ~= 0 then
				aadmin.Ban( t_ply:SteamID(), tostring( os.time() + correct_time*60 ), reason, ply)
			elseif correct_time <= 0 then
				aadmin.Ban( t_ply:SteamID(), 0,  reason, ply)
			end
			
			local langID_time = 0
			local langID_reason = ""
			if correct_time > 0 then  langID_time   =  1  end
			if reason ~= ""     then  langID_reason = "1" end
			local m_sReason = string.format( aadmin.lBanReason[ langID_reason ], reason )
			local m_sTime = string.format( aadmin.lBanTime[ langID_time ], correct_time )
			aadmin.CommandNotify(ply," has banned ",nick,m_sTime,"",m_sReason)
			
			t_ply:Kick( reason )
		end
	end, 2 , "<player name> [time minutes] [reason]" )	
	aadmin.CreateCommand( "banid", function( ply, args )	
		local steamID = args[1]
		local time = args[2] or 0
		local reason = table.concat( args, " ", 3 )
		if !string.match( steamID, "STEAM_[0-5]:[0-9]:[0-9]+" ) then
			aadmin.SystemNotify( ply, aadmin.colors.red, "Bad argument #1: SteamID expected, got shit." )
			return
		elseif aadmin.IsBannedSteamID( steamID ) then
			aadmin.SystemNotify( ply, aadmin.colors.red, "This SteamID is already banned." )
			return
		else
			local correct_time = 0
			if tonumber(time) ~= nil then
				correct_time = tonumber(time)
			end
			if correct_time ~= 0 then
				aadmin.Ban( steamID, tostring( os.time() + correct_time*60 ), reason, ply)
			elseif correct_time <= 0 then
				aadmin.Ban( steamID, 0,  reason, ply)
			end
			
			local langID_time = 0
			local langID_reason = ""
			if correct_time > 0 then  langID_time   =  1  end
			if reason ~= ""     then  langID_reason = "1" end
			local m_sReason = string.format( aadmin.lBanReason[ langID_reason ], reason )
			local m_sTime = string.format( aadmin.lBanTime[ langID_time ], correct_time )
			aadmin.CommandNotify(ply," has banned SteamID ",steamID,m_sTime,"",m_sReason)

			for k,v in pairs(player.GetAll()) do
				if v:SteamID() == steamID then
					v:Kick( reason )
				end
			end
		end
	end, 2 , "<steamid> [time minutes] [reason]")	
	aadmin.CreateCommand( "unban", function( ply, args )	
		local steamID = args[1]
		if !string.match( steamID, "STEAM_[0-5]:[0-9]:[0-9]+" ) then
			aadmin.SystemNotify( ply, aadmin.colors.red, "Bad argument #1: SteamID expected, got shit." )
			return
		elseif not aadmin.IsBannedSteamID( steamID ) then
			aadmin.SystemNotify( ply, aadmin.colors.red, "This SteamID is already unbanned." )
			return
		else
			aadmin.UnBan( steamID )
			aadmin.CommandNotify(ply," has unbanned SteamID ",steamID,"","","")
		end
	end, 1 , "<steamid>" )
	aadmin.CreateCommand( "banlist", function( ply, args )
		if !file.Exists( "aadmin_bans.txt", "DATA" ) then return end
		local read = luadata.ReadFile( "aadmin_bans.txt" )
		if table.GetFirstKey(read) == nil then 
			aadmin.SystemNotify( ply,aadmin.colors.red, "No such bans found. " )
			return
		else
			aadmin.SystemNotify( ply,aadmin.colors.white, "Ban list: " )
		end
		for k,v in pairs( read ) do
			aadmin.SystemNotify( ply, aadmin.colors.white,"STEAMID: ", aadmin.colors.gray, k , aadmin.colors.white," Reason: ", aadmin.colors.gray, v.r , aadmin.colors.white," Banned by: ", aadmin.colors.gray, v.banner )
		end
	end, 3 , "<none>" )
	aadmin.CreateCommand( "goto", function( ply, args )	
		local t_ply,nick = aadmin.FindPlayer( args[1] )
		if IsValid(t_ply) then
			ply:SetPos(t_ply:GetPos()-t_ply:GetForward()*50)
			aadmin.CommandNotify(ply," has teleported to ",nick,"","","")
		end
	end, 2 , "<player name>" )	
	aadmin.CreateCommand( "bring", function( ply, args )	
		local t_ply,nick = aadmin.FindPlayer( args[1] )
		local t2_ply,nick2 = aadmin.FindPlayer( args[1] )
		if IsValid(t_ply) then
			if IsValid(t2_ply) then
				t_ply:SetPos(t2_ply:GetPos()+t2_ply:GetForward()*50)
				aadmin.CommandNotify(ply," has bring ",nick," to ",nick2,"")
			else
				t_ply:SetPos(ply:GetPos()+ply:GetForward()*50)
				aadmin.CommandNotify(ply," has bring ",nick," to ","self","")
			end
		end
	end, 2 , "<player name> [player2 name]" )	
	aadmin.CreateCommand( "slay", function( ply, args )	
		local t_ply,nick = aadmin.FindPlayer( args[1] )
		if IsValid(t_ply) then
			t_ply:Kill()
			aadmin.CommandNotify(ply," has slayed ",nick,"","","")
		end
	end, 1 , "<player name>" )	
	timer.Create("AADMIN_UNBAN",5,0,function()
		if file.Exists( "aadmin_bans.txt", "DATA" ) then
			local read = luadata.ReadFile( "aadmin_bans.txt" )
			for k,v in pairs(read) do
				if os.time() >= tonumber(v.t) then
					if tonumber(v.t) ~= 0 then
						aadmin.Notify(aadmin.colors.gray,k,aadmin.colors.white," is unbanned (Ban time is reached)")
						read[ k ] = nil
						luadata.WriteFile( "aadmin_bans.txt", read )
					end
				end
			end
		end
	end)
	aadmin.CreateCommand( "cmds", function( ply, args )	
		aadmin.SystemNotify( ply,aadmin.colors.white, "Available commands: " )
		for k,v in pairs( aadmin.commands ) do
			local canRun,reason = hook.Call( "AADMIN_COMMAND_CheckAccess", GAMEMODE, ply, k )
			local color
			if canRun then
				color = aadmin.colors.gray
			else
				color = aadmin.colors.red
			end
			aadmin.SystemNotify( ply, color, k, aadmin.colors.white, " "..v.desc )
		end
	end, 3 , "<none>" )
	aadmin.CreateCommand( "cleardecals", function( ply, args )	
		for k,v in pairs( player.GetAll() ) do
			v:ConCommand('r_cleardecals 1')
		end
		aadmin.CommandNotify(ply," has removed all decals.","")
	end, 2 , "<none>" )
	aadmin.CreateCommand( "restartround", function( ply, args )	
		UnFreezeAll()
		ResetAllPlayers()
		FreezeAll()
		SwitchGameState( GS_ROUND_PREPARE )
		game_NextRoundStart = CurTime() + GetConVar("abdul_roundstart"):GetInt()
			
		aadmin.CommandNotify(ply," has restarted rounds.","")
	end, 2 , "<none>" )
end
end)