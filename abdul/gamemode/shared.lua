GM.Name = "Abdul: Masloterminator"
GM.Author = "Schwarz Kruppzo"
GM.Email = ""
GM.Website = ""
DeriveGamemode("base")
include( "player_abdul.lua" )

local fol = GM.FolderName.."/gamemode/libs/"
local files, folders = file.Find(fol .. "*", "LUA")
for k,v in pairs(files) do
	local prefix = string.Explode( "_" , v )[1]
	if prefix == "sv" then
		if SERVER then include(fol.. v) end
	elseif prefix == "sh" then
		if SERVER then AddCSLuaFile(fol.. v) end
		include(fol.. v)
	elseif prefix == "cl" then
		if SERVER then AddCSLuaFile(fol.. v) end
		if CLIENT then include(fol.. v) end
	end
end


GS_WAITING_PLAYERS = 0
GS_ROUND_PREPARE = 1
GS_ROUND_PLAYING = 3
GS_ROUND_END = 4
GS_GAME_OVER = 5

CURRENT_GAME_STATE = 0
CURRENT_ROUND = 0
CURRENT_ROUNDTIME = 0
CURRENT_WINNER = nil
CURRENT_FRAGREMAINING = 0
CURRENT_GAMEMODE = "deathmatch" // "teamdeathmatch"

function GetWinner()
	return CURRENT_WINNER
end
function GetFragsRemaining()
	return CURRENT_FRAGREMAINING
end
function GetRoundTime()
	return CURRENT_ROUNDTIME
end
function GetRound()
	return CURRENT_ROUND
end
function GetGameState()
	return CURRENT_GAME_STATE
end
function GetGameMode()
	return CURRENT_GAMEMODE
end
function IsDeathmatch()
	if CURRENT_GAMEMODE == "deathmatch" then
		return true
	end
end
function IsTeamDeathmatch()
	if CURRENT_GAMEMODE == "teamdeathmatch" then
		return true
	end
end
function GM:GetGameDescription()
	return "Абдуль: Маслотерминатор"
end
if CLIENT then
	local RoundMusic = false
	net.Receive( "game_Round", function( len )
		CURRENT_ROUND = net.ReadInt(32)
	end )
	net.Receive( "game_RoundTime", function( len )
		CURRENT_ROUNDTIME = net.ReadInt(32)
	end )
	net.Receive( "game_State", function( len )
		CURRENT_GAME_STATE = net.ReadInt(32)
	end )
	net.Receive( "game_Winner", function( len )
		CURRENT_WINNER = net.ReadEntity()
	end )
	net.Receive( "game_Winner2", function( len )
		CURRENT_WINNER = net.ReadString()
	end )
	net.Receive( "game_FragRemain", function( len )
		CURRENT_FRAGREMAINING = net.ReadInt(32)
	end )
	net.Receive( "play_RoundStart", function( len )
		local i = net.ReadInt(32)
		if !RoundMusic then
			local sound = "abdul/music/lol"..tostring(i)..".wav"
			LocalPlayer():EmitSound( Sound( sound ), 80, 100 )
			RoundMusic = true
			local time = SoundDuration( sound )
			timer.Create( tostring(LocalPlayer():EntIndex()).."RoundMusic",time, 1, function()
				if IsValid(LocalPlayer()) then RoundMusic = false end
			end)
		end
	end )
	net.Receive( "game_GameMode", function( len )
		CURRENT_GAMEMODE = net.ReadInt(32)
	end )
end
if SERVER then
	util.AddNetworkString( "game_Round" )
	util.AddNetworkString( "game_RoundTime" )
	util.AddNetworkString( "game_State" )
	util.AddNetworkString( "game_Winner" )
	util.AddNetworkString( "game_Winner2" )
	util.AddNetworkString( "play_RoundStart" )
	util.AddNetworkString( "game_FragRemain" )
	util.AddNetworkString( "game_GameMode" )
	
	function SetGameRound( i)
		CURRENT_ROUND = i
		net.Start( "game_Round" )
			net.WriteInt( CURRENT_ROUND , 32)
		net.Broadcast()
	end
	function SetGameRoundTime( i )
		CURRENT_ROUNDTIME = i
		net.Start( "game_RoundTime" )
			net.WriteInt( CURRENT_ROUNDTIME , 32 )
		net.Broadcast()
	end
	function SetWinner( ent )
		CURRENT_WINNER = ent
		if type(ent) != "string" and ent:IsPlayer() then
			net.Start( "game_Winner" )
				net.WriteEntity( ent )
			net.Broadcast()
		else
			net.Start( "game_Winner2" )
				net.WriteString( ent )
			net.Broadcast()
		end
	end
	function ResetRounds()
		SetGameRound(0)
		SetGameRoundTime(0)
	end
	function SwitchGameState( i )
		CURRENT_GAME_STATE = i
		net.Start( "game_State" )
			net.WriteInt( CURRENT_GAME_STATE , 32)
		net.Broadcast()
	end
	function FreezeAll()
		for k,v in pairs( player.GetAll() ) do
			if IsValid(v) then
				v:Freeze( true )
				v:SetEyeAngles(Angle(0,0,0))
			end
		end
	end
	function UnFreezeAll()
		for k,v in pairs( player.GetAll() ) do
			if IsValid(v) then
				v:Freeze( false )
				v:SetEyeAngles(Angle(0,0,0))
			end
		end
	end
	function ResetAllPlayers()
		KSAward_Reset()
		PU_ResetPowerUpUserAll()
		for x,c in pairs( ents.FindByClass("ent_weaponspawn_noresp")) do c:Remove() end
		for k,v in pairs( player.GetAll() ) do
			if IsValid(v) then
				v:SetNWBool( "IsBerserk", false )
				v.NextBerserk = nil
				v:WallHack( false )
				v:StripWeapons()
				v:SetHealth(100)
				v:SetArmor(0)
				v:SetFrags(0)
				v:SetEyeAngles(Angle(0,0,0))
				v:SetDeaths(0)
				v:Spawn()
				v:SendLua("RunConsoleCommand('r_cleardecals')")
				hook.Call("PlayerLoadout",GAMEMODE,v)
			end
		end
	end
	game_NextRoundStart = 0
	game_RoundTimer = 0
	game_EndRoundTimer = 0
	game_GameOverTimer = 0
	
	local function GetPlayers()
		local int = 0
		for k,v in pairs(player.GetAll()) do
			if v:IsSpectator() then continue end
			int = int + 1
		end
		return int
	end
	local function HasNoTeam()
		for k,v in pairs(player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetNWString("CTeam") == "" then
				return true
			end
		end
	end
	
	local function GetTeams()
		local tes = {}
		for k,v in pairs(cteam.GetAllTeams()) do
			for z,x in pairs( v.players ) do
				if !x:IsSpectator() then
					if !table.HasValue(tes,v.name) then
						table.insert(tes,v.name)
					end
				end
			end
		end
		return #tes
	end
	local function NewCheck()
		if HasNoTeam() and GetPlayers() > 1 then
			return true
		elseif HasNoTeam() and GetTeams() > 1 and GetPlayers() > 1 then
			return true
		elseif GetTeams() > 1 and GetPlayers() > 1 then
			return true
		elseif GetTeams() <= 1 and !HasNoTeam() then
			return false
		elseif GetPlayers() <= 1 then
			return false
		end
	end
	function GameStateThink()
		if !NewCheck() and GetGameState() ~= GS_WAITING_PLAYERS then
			ResetAllPlayers()
			UnFreezeAll()
			SwitchGameState( GS_WAITING_PLAYERS )
			ResetRounds()
		end
		if GetGameState() == GS_WAITING_PLAYERS then
			if NewCheck() then
				ResetAllPlayers()
				FreezeAll()
				SwitchGameState( GS_ROUND_PREPARE )
				ResetRounds()
				game_NextRoundStart = CurTime() + GetConVar("abdul_roundstart"):GetInt()
			end
		elseif GetGameState() == GS_ROUND_PREPARE then
			if game_NextRoundStart <= CurTime() then
				UnFreezeAll()
				SetGameRound( CURRENT_ROUND + 1)
				SwitchGameState( GS_ROUND_PLAYING )
				game_RoundTimer = CurTime() + GetConVar("abdul_roundtime"):GetInt()
			else
				SetGameRoundTime( game_NextRoundStart - CurTime())
			end
		elseif GetGameState() == GS_ROUND_END then
			if game_EndRoundTimer <= CurTime() then
				UnFreezeAll()
				ResetAllPlayers()
				FreezeAll()
				SwitchGameState( GS_ROUND_PREPARE )
				game_NextRoundStart = CurTime() + GetConVar("abdul_roundstart"):GetInt()
			else
				SetGameRoundTime( game_EndRoundTimer - CurTime())
			end
		end
	end
	local function GetTeamWiner()
		local last = 0
		local maxi = 0

		for k,v in pairs(cteam.GetAllTeams()) do
			if last <= cteam.TotalFrags( v.name ) then
				last = cteam.TotalFrags( v.name )
				maxi = k
			end
		end
		if cteam.GetAllTeams()[maxi] then
			return cteam.GetAllTeams()[maxi].name
		end
	end
	local function GetWiner()
		local last = 0
		local maxi = 0

		for k,v in pairs(player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetNWString("CTeam") != "" then continue end
			if last <= v:Frags() then
				last = v:Frags()
				maxi = k
			end
		end
		return player.GetAll()[maxi]
	end
	local function GetWin()
		local noteam = 0
		if IsValid(GetWiner()) then
			noteam = GetWiner():Frags()
		end
		if cteam.TotalFrags( GetTeamWiner() ) then
			local team = cteam.TotalFrags( GetTeamWiner() )
			if noteam > team then
				return GetWiner()
			end
		else
			return GetWiner()
		end
		return GetTeamWiner()
	end
	function RoundThink()
		if GetGameState() == GS_ROUND_PLAYING then
			local totalfrags = 0
			for k,v in pairs(player.GetAll()) do
				if v:IsSpectator() then continue end
				totalfrags = totalfrags + v:Frags()
			end
			local frags = GetConVar("abdul_fraglimit"):GetInt() - totalfrags
			frags = math.Clamp( frags, 0, GetConVar("abdul_fraglimit"):GetInt() )
			if frags ~= GetFragsRemaining() then
				CURRENT_FRAGREMAINING = frags
				net.Start( "game_FragRemain" )
					net.WriteInt( frags, 32 )
				net.Broadcast()
			end
			
			if game_RoundTimer <= CurTime() then
				if GetRound() >= GetConVar("abdul_maxrounds"):GetInt() then
					FreezeAll()
					game_GameOverTimer = CurTime() + 11
					SwitchGameState( GS_GAME_OVER )
					SetWinner( GetWin() )
					net.Start( "play_RoundStart" )
						net.WriteInt( math.random(1,10) , 32)
					net.Broadcast()
				else
					FreezeAll()
					game_EndRoundTimer = CurTime() + 11
					SwitchGameState( GS_ROUND_END )
					SetWinner( GetWin() )
					net.Start( "play_RoundStart" )
						net.WriteInt( math.random(1,10) , 32)
					net.Broadcast()
				end
			else
				SetGameRoundTime( game_RoundTimer - CurTime())
			end
		end
	end
	function FragsThink()
		if GetGameState() == GS_ROUND_PLAYING then
			local totalfrags = 0
			for k,v in pairs(player.GetAll()) do
				if v:IsSpectator() then continue end
				totalfrags = totalfrags + v:Frags()
			end
			if totalfrags >= GetConVar("abdul_fraglimit"):GetInt() then
				if GetRound() >= GetConVar("abdul_maxrounds"):GetInt() then
					FreezeAll()
					game_GameOverTimer = CurTime() + 11
					SwitchGameState( GS_GAME_OVER )
					SetWinner( GetWin() )
					net.Start( "play_RoundStart" )
						net.WriteInt( math.random(1,10) , 32)
					net.Broadcast()
				else
					FreezeAll()
					game_EndRoundTimer = CurTime() + 11
					SwitchGameState( GS_ROUND_END )
					SetWinner( GetWin() )
					net.Start( "play_RoundStart" )
						net.WriteInt( math.random(1,10) , 32)
					net.Broadcast()
				end					
			end
		end
	end
	
	function GM:Think()
		GameStateThink()
		RoundThink()
		FragsThink()
	end
end