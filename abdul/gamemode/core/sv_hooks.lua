DEFINE_BASECLASS( "gamemode_base" )
function GM:GetGameDescription()
	return "Abdul: Masloterminator"
end
function GM:PlayerSpawn( client )
	player_manager.SetPlayerClass( client, "player_abdul" )
	BaseClass.PlayerSpawn( self, client )
	if client:IsSpectator() then
		client:StripWeapons()
		client:Spectate(OBS_MODE_ROAMING)
		return
	end
	client:SetupHands()
end
function GM:PlayerSetHandsModel( ply, ent )
	ent:SetModel( "models/weapons/c_arms_cstrike.mdl" )
	ent:SetSkin( 1 )
	ent:SetBodyGroups( "0100000" )
end
function GM:PlayerInitialSpawn( ply )
	BaseClass.PlayerInitialSpawn( self, ply )
	
	ply:SetTeam(2)
	ply:ConCommand("abdulmenu")
	net.Start( "game_State" )
		net.WriteInt( CURRENT_GAME_STATE , 32)
	net.Send( ply )
	net.Start( "game_Round" )
		net.WriteInt( CURRENT_ROUND , 32)
	net.Send( ply )
	net.Start( "game_RoundTime" )
		net.WriteInt( CURRENT_ROUNDTIME , 32 )
	net.Send( ply )
	net.Start( "game_RoundTime" )
		net.WriteInt( CURRENT_ROUNDTIME , 32 )
	net.Send( ply )
	net.Start( "game_FragRemain" )
		net.WriteInt( CURRENT_FRAGREMAINING , 32 )
	net.Send( ply )
end
function GM:PlayerDeathSound()
	return true
end
function GM:PlayerDeath( victim, infl, attack )
	BaseClass:PlayerDeath(victim, infl, attack)
	for k,v in pairs(ents.FindByClass("ent_claymore")) do
		if v:GetThowBy() == victim then
			v:Remove()
		end
	end
	victim:ResetPlantLimit()
	victim:AbdulVoice( "abdul/death/death"..tostring(math.random(1,35))..".wav" )
	if attack:IsPlayer() then if victim ~= attack then attack:AbdulVoice( "abdul/kill/kill"..tostring(math.random(1,31))..".wav" ) end end 
end
hook.Add("PlayerTick","AbdulCheck",function( ply )
	local p = ply:GetEyeTrace().Entity
	if p:IsPlayer() then
		if not ply.nextCheck then ply.nextCheck = 0 end
		if CurTime() >= ply.nextCheck then
			ply:AbdulVoice( "abdul/check/check"..tostring(math.random(1,20))..".wav" )
			ply.nextCheck = CurTime() + 60
		end
	end
end)
function GM:DoPlayerDeath( ply, attacker, dmg )
	BaseClass:DoPlayerDeath( ply, attacker, dmg)
	if ply:GetActiveWeapon():GetClass() ~= "abdul_machete" and ply:GetActiveWeapon():GetClass() ~= "abdul_turret" then
		local ent = ents.Create("ent_weaponspawn_noresp")
		ent:SetPos(ply:GetPos() + ply:GetUp() * 15)
		ent.Class = ply:GetActiveWeapon():GetClass()
		ent.MDL = ply:GetActiveWeapon().WorldModel
		if ent.Class == "abdul_egon" then
			ent.MDL = "models/w_egonpickup.mdl"
		end
		ent:Spawn()
	end
end
util.AddNetworkString( "GM_Pickup" )
util.AddNetworkString( "GM_PlayerHurt" )
util.AddNetworkString( "ExplosionEffect" )

function GM:PlayerPickupWeapon( ply, class )
	net.Start( "GM_Pickup" )
		net.WriteString( class )
	net.Send( ply )
	for k,v in pairs( ply:GetWeapons()) do
		if IsValid(v) then
			if v:IsWeapon() then
				if v:GetClass() == class then
					v:Equip( ply )
					v:EquipAmmo( ply )
				end
			end
		end
	end
end
function GM:PlayerHurt( ply, attacker )
	net.Start( "GM_PlayerHurt" )
	net.Send( ply )
end
function GM:PlayerPickupAmmo( ply, class )
	net.Start( "GM_Pickup" )
		net.WriteString( class )
	net.Send( ply )
end
function GM:PlayerCanPickupWeapon( ply, wep )
	return true
end
function GM:ShowHelp( ply )
	ply:ConCommand("abdulmenu")
end
local weaponPriority = {
"abdul_turret",
"abdul_machete",
"abdul_claymore",
"abdul_50cal",
"abdul_mp7",
"abdul_shotgun",
"abdul_ak47",
"abdul_impulseminigun",
"abdul_maslachesator",
"abdul_rocketlauncher",
"abdul_plasma",
"abdul_awm",
"abdul_railgun",
"abdul_egon"}
local meta = FindMetaTable("Player")
function meta:SelectWeaponByPriority( class )
	local weapon = self:GetActiveWeapon():GetClass()
	local key = table.KeyFromValue( weaponPriority, weapon )
	local key2 = table.KeyFromValue( weaponPriority, class )
	if key2 >= key then
		self:SelectWeapon( class )
	elseif self:GetAmmoCount( self:GetActiveWeapon().Secondary.Ammo ) <= 0 then
		self:SelectWeapon( class )
	end
end