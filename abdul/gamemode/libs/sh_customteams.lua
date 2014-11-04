cteam = cteam or {}
cteam.teams = cteam.teams or {}
function cteam.GetAllTeams()
	return cteam.teams
end
function cteam.GetIDByName( name )
	for k,v in pairs( cteam.GetAllTeams() ) do
		if v.name == name then
			return k
		end
	end
end
function cteam.IsValid( name )
	if cteam.GetIDByName( name ) then
		return true
	end
end
function cteam.GetPlayers( name )
	if !cteam.IsValid( name ) then return end
	local id = cteam.GetIDByName( name )
	local team = cteam.GetAllTeams()[id]
	
	return team.players
end
function cteam.IsLeader( ply, name )
	if !cteam.IsValid( name ) then return end
	local id = cteam.GetIDByName( name )
	local team = cteam.GetAllTeams()[id]
	
	if team.leader == ply then
		return true
	end
end
function cteam.IsInvited(ply, name )
	if !cteam.IsValid( name ) then return end
	local id = cteam.GetIDByName( name )
	local team = cteam.GetAllTeams()[id]
	
	if table.HasValue(team.invited,ply) then
		return true
	end
end
function cteam.TotalFrags( name )
	if !cteam.IsValid( name ) then return end
	local id = cteam.GetIDByName( name )
	local frags = 0
	for k,v in pairs( cteam.GetPlayers( name ) ) do
		if IsValid(v) then
			if v:Frags() then
				frags = frags + v:Frags()
			end
		end
	end
	return frags
end
function cteam.TotalDeaths( name )
	if !cteam.IsValid( name ) then return end
	local id = cteam.GetIDByName( name )
	local frags = 0
	for k,v in pairs( cteam.GetPlayers( name ) ) do
		if IsValid(v) then
			frags = frags + v:Deaths()
		end
	end
	return frags
end
function cteam.GetColor( name )
	if !cteam.IsValid( name ) then return end
	local id = cteam.GetIDByName( name )
	local team = cteam.GetAllTeams()[id]
	
	return team.color
end
local function getPlyId( tbl, ent )
	for k,v in pairs( tbl ) do
		if v == ent then
			return k
		end
	end
end
if SERVER then
	util.AddNetworkString( "net_CTeamTable" )
	util.AddNetworkString( "net_CreateTeam" )
	util.AddNetworkString( "net_JoinTeam" )
	util.AddNetworkString( "net_LeaveTeam" )
	util.AddNetworkString( "net_KickPlayerTeam" )
	util.AddNetworkString( "net_LeaderPlayerTeam" )
	util.AddNetworkString( "net_InvitePlayerTeam" )
	util.AddNetworkString( "net_ChangeColorTeam" )
	util.AddNetworkString( "net_ChangePassTeam" )
	util.AddNetworkString( "net_RemoveTeam" )
	function CNotify( ply, text )
		Notify( ply, Color(255,100,100),"[",Color(200,50,50),"Teams",Color(255,100,100),"]",Color(255,255,255)," "..text) 
	end
	function cteam.Network_CTeamTable( tbl )
		local ctbl = table.Copy( tbl )
		for k,v in pairs( ctbl ) do
			v.password = nil
		end
		net.Start( "net_CTeamTable" )
			net.WriteTable( ctbl )
		net.Broadcast()
	end
	function cteam.Create( leader, name, color, password )
		if cteam.IsValid( name ) then return end
		local tbl = {
			leader = leader,
			name = name,
			color = color,
			password = password,
			players = {},
			invited = {}
		}
		local id = table.insert( cteam.teams, tbl )
		cteam.Network_CTeamTable( cteam.teams )
		CNotify( leader, "Команда с именем ".. name .. " была успешно создана." )
		Notify(Color(255,120,120),leader:Nick(),Color(255,255,255)," создал команду ",Color(225,225,225,255),name)
	end
	function cteam.Remove( name )
		if !cteam.IsValid( name ) then return end
		local id = cteam.GetIDByName( name )
		for k,v in pairs( cteam.GetPlayers( name ) ) do
			v:SetNWString("CTeam", "" )
		end
		table.remove( cteam.teams, id )
		cteam.Network_CTeamTable( cteam.teams )
	end
	function cteam.RedoLeader( name )
		if !cteam.IsValid( name ) then return end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		team.leader = table.GetFirstValue( team.players )
		if IsValid(team.leader) then
			CNotify( team.leader, "Теперь ты лидер команды ".. name .. "." )
		end
	end
	local meta = FindMetaTable("Player")
	function meta:SetCTeam( name )
		if !cteam.IsValid( name ) then return end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		self:SetNWString("CTeam", name )
		table.insert( team.players, self )
		if table.HasValue(team.invited, self ) then
			table.remove( team.invited, getPlyId( team.invited, self ) )
		end
		cteam.Network_CTeamTable( cteam.teams )
	end
	function meta:InviteCTeam( name )
		if !cteam.IsValid( name ) then return end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		if table.HasValue(team.invited, self ) then return end
		table.insert( team.invited,self )
		cteam.Network_CTeamTable( cteam.teams )
		if IsValid(self) then
			CNotify( self,"Ты был приглашен в команду ".. name .. ". Теперь ты можешь вступить в нее без пароля." )
		end
	end
	function meta:JoinCTeam( name, password )
		if !cteam.IsValid( name ) then return end
		if self:GetNWString("CTeam") != "" then return end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		if team.password == password or table.HasValue(team.invited, self ) then
			self:SetCTeam( name )
			CNotify( self, "Вы присоединились к команде ".. name .. "." )
			return
		else
			CNotify( self, "Неверный пароль." )
			return
		end
	end
	function meta:LeaveCTeam()
		local name = self:GetNWString("CTeam")
		if name == "" then return end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		table.remove( team.players, getPlyId( team.players, self ) )
		if cteam.IsLeader( self, name ) then cteam.RedoLeader( name ) end
		cteam.Network_CTeamTable( cteam.teams )
		self:SetNWString("CTeam", "" )
		if #team.players == 0 then
			Notify(Color(255,255,255),"Команда ",Color(225,225,225,255),name,Color(255,255,255)," расформирована.")

			cteam.Remove( name )
			
		end
	end
	
	net.Receive( "net_CreateTeam", function( len, ply )
		local name = net.ReadString()
		local pass = net.ReadString()
		local color = net.ReadTable()
		if cteam.IsValid( name ) then
			CNotify( ply, "Команда с этим именем уже существует." )
			return 
		end
		cteam.Create( ply, name, color, pass )
		ply:SetCTeam( name )
	end )
	net.Receive( "net_JoinTeam", function( len, ply )
		local name = net.ReadString()
		local pass = net.ReadString()
		if !cteam.IsValid( name ) then
			CNotify( ply, "Такой команды не существует." )
			return 
		end
		ply:JoinCTeam( name, pass )
	end )
	net.Receive( "net_LeaveTeam", function( len, ply )
		CNotify( ply, "Вы вышли из команды " .. ply:GetNWString("CTeam") .. ".")
		ply:LeaveCTeam()
	end )
	net.Receive( "net_KickPlayerTeam", function( len, ply )
		local name = ply:GetNWString("CTeam")
		if !cteam.IsValid( name ) then
			CNotify( ply, "Такой команды не существует." )
			return 
		end
		if !cteam.IsLeader( ply, name ) then 
			CNotify( ply, "У вас нет прав лидера чтобы это сделать." )
			return 
		end
		local ent = NULL
		for k,v in pairs(player.GetAll()) do
			if v:SteamID() == net.ReadString() then
				if v:GetNWString("CTeam") == name then
					ent = v
				end
			end
		end
		if !IsValid(ent) then return end
		if ent == ply then return end
		ent:LeaveCTeam()
		CNotify( ply, "Игрок ".. ent:Nick() .." был изгнат из команды ".. name .."." )
	end )
	net.Receive( "net_LeaderPlayerTeam", function( len, ply )
		local name = ply:GetNWString("CTeam")
		if !cteam.IsValid( name ) then
			CNotify( ply, "Такой команды не существует." )
			return 
		end
		if !cteam.IsLeader( ply, name ) then 
			CNotify( ply, "У вас нет прав лидера чтобы это сделать." )
			return 
		end
		local ent = NULL
		for k,v in pairs(player.GetAll()) do
			if v:SteamID() == net.ReadString() then
				if v:GetNWString("CTeam") == name then
					ent = v
				end
			end
		end
		if !IsValid(ent) then return end
		if ent == ply then return end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		team.leader = ent
		if IsValid(team.leader) then
			CNotify( team.leader, "Теперь ты лидер команды ".. name .. "." )
		end
		cteam.Network_CTeamTable( cteam.teams )
		CNotify( ply, "Игрок ".. ent:Nick() .." теперь лидер команды ".. name .."." )
	end )
	net.Receive( "net_RemoveTeam", function( len, ply )
		local name = ply:GetNWString("CTeam")
		if !cteam.IsValid( name ) then
			CNotify( ply, "Такой команды не существует." )
			return 
		end
		if !cteam.IsLeader( ply, name ) then 
			CNotify( ply, "У вас нет прав лидера чтобы это сделать." )
			return 
		end
		CNotify( ply, "Команда ".. name .." успешно удалена." )
		Notify(Color(255,120,120),ply:Nick(),Color(255,255,255)," удалил команду ",Color(225,225,225,255),name)

		cteam.Remove( name )
		
	end )
	net.Receive( "net_InvitePlayerTeam", function( len, ply )
		local name = ply:GetNWString("CTeam")
		if !cteam.IsValid( name ) then
			CNotify( ply, "Такой команды не существует." )
			return 
		end
		if !cteam.IsLeader( ply, name ) then 
			CNotify( ply, "У вас нет прав лидера чтобы это сделать." )
			return 
		end
		local steamid = net.ReadString()
		local ent = NULL
		for k,v in pairs(player.GetAll()) do
			if v:SteamID() == steamid then
				ent = v
			end
		end
		if !IsValid(ent) then return end
		if ent == ply then return end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		if table.HasValue( team.players, ent ) then return end
		ent:InviteCTeam( name )
		CNotify( ply, "Игрок ".. ent:Nick() .." приглашен в команду ".. name .."." )
	end )
	net.Receive( "net_ChangePassTeam", function( len, ply )
		local name = ply:GetNWString("CTeam")
		local pass = net.ReadString()
		if !cteam.IsValid( name ) then
			CNotify( ply, "Такой команды не существует." )
			return 
		end
		if !cteam.IsLeader( ply, name ) then 
			CNotify( ply, "У вас нет прав лидера чтобы это сделать." )
			return 
		end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		team.password = pass
		cteam.Network_CTeamTable( cteam.teams )
		CNotify( ply, "Пароль команды ".. name .." успешно изменен." )
	end )
	net.Receive( "net_ChangeColorTeam", function( len, ply )
		local name = ply:GetNWString("CTeam")
		local col = net.ReadTable()
		if !cteam.IsValid( name ) then
			CNotify( ply, "Такой команды не существует." )
			return 
		end
		if !cteam.IsLeader( ply, name ) then 
			CNotify( ply, "У вас нет прав лидера чтобы это сделать." )
			return 
		end
		local id = cteam.GetIDByName( name )
		local team = cteam.GetAllTeams()[id]
		team.color = col
		cteam.Network_CTeamTable( cteam.teams )
		CNotify( ply, "Цвет команды ".. name .." успешно изменен." )
	end )
	hook.Add("EntityRemoved","Redoleader",function( ent )
		if ent:IsPlayer() then
			ent:LeaveCTeam()
		end
	end)
	hook.Add("PlayerShouldTakeDamage","FrindlyFire",function( vic, ply )
		if ply:IsPlayer() and vic:IsPlayer() then
			if ply != vic then
				if ply:GetNWString("CTeam") == "" then
					return true
				else
					if ply:GetNWString("CTeam") == vic:GetNWString("CTeam") then
						return false
					end
				end
			end
		end
		return true
	end)
	hook.Add("PlayerInitialSpawn","DataTeams",function( ply )
		cteam.Network_CTeamTable( cteam.teams )
	end)
	hook.Add("PlayerTick","PlyCol", function( ply ) 
		local t = ply:GetNWString("CTeam")
		local color = Color( 0, 0, 0 )
		if t != "" then
			color = cteam.GetColor( t ) or Color( 0,0,0 )
		end
		ply:SetPlayerColor( Vector( color.r/255,color.g/255,color.b/255 ) )
	end)
else
	net.Receive( "net_CTeamTable", function( len )
		cteam.teams = net.ReadTable()
	end )

end