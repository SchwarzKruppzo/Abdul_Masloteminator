include( "shared.lua" )
include(GM.FolderName.."/gamemode/core/sh_hooks.lua")
include(GM.FolderName.."/gamemode/core/cl_hooks.lua")

DEFINE_BASECLASS( "gamemode_base" )

function GM:Initialize()
	BaseClass.Initialize( self )
end
function GM:InitPostEntity()
	BaseClass.InitPostEntity( self )
	LocalPlayer():EmitSound(Sound("abdul/welcome.wav"))
end
function GM:HUDDrawTargetID()
     return false
end
local hudtohide = {"CHudHealth","CHudBattery","CHudCrosshair","CHudAmmo","CHudZoom","CHudSecondaryAmmo"}
function GM:HUDShouldDraw( name )
	if table.HasValue( hudtohide, name ) then return false end
	return true
end
local function CalcRoll( ang, vel, fl, speed )
	if LocalPlayer():IsSpectator() then return 0 end
	local sign;
    local side;
    local value;
	
	local forward = ang:Forward()
	local right = ang:Right()
	local up = ang:Up()

    side = vel:DotProduct( right )
	
    sign = side < 0 and -1 or 1
    side = math.abs(side)
    
	value = fl;
    if ( side < speed ) then
		side = side * value / speed;
    else
		side = value;
	end
    return side*sign;
end
function GM:PlayerTick( ply, cmd )
	BaseClass.PlayerTick( ply, cmd )
	
	local lim = 35
	local speed = 1.05
	if IsValid(ply:GetActiveWeapon()) then
		if ply:GetActiveWeapon():GetClass() == "abdul_awm" then
			lim = 65
			speed = 0.8
		end
	end
	if ply:KeyDown( IN_ATTACK2 ) then
		if !ply.zoomfov then ply.zoomfov = 0 end
		ply.zoomfov = ply.zoomfov + 1/speed
		ply.zoomfov = math.Clamp( ply.zoomfov, 0, lim )
	elseif !ply:KeyDown( IN_ATTACK2 ) then
		if !ply.zoomfov then ply.zoomfov = 0 end
		ply.zoomfov = ply.zoomfov - 1/speed
		ply.zoomfov = math.Clamp( ply.zoomfov, 0, lim )
	end
end
function GM:CalcView( ply, pos, ang, fov, nearZ, farZ )
	if !ply.zoomfov then ply.zoomfov = 0 end
    local view = {}
	local side = CalcRoll( ply:GetAngles(), ply:GetVelocity(), 3, 300 );
    view.origin = pos
	ang:RotateAroundAxis(ang:Forward(),side)
    view.angles = ang
    view.fov = 90 - ply.zoomfov
    return view
end
function AntiViewModelPunch( wep, vm, oldPos, oldAng, pos, ang )
	local pang = LocalPlayer():GetPunchAngle()
    ang.p = ang.p - pang.p
    ang.y = ang.y - pang.y
    ang.r = ang.r - pang.r	
end
hook.Add("CalcViewModelView","AntiViewModelPunch",AntiViewModelPunch)


function GM:OnPlayerChat( ply, strText, bTeamOnly, bPlayerIsDead )
	local tab = {}
 
	if ( bPlayerIsDead ) then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end
 
	if ( bTeamOnly ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
	end
 
	if ( IsValid( ply ) ) then
		local col = team.GetColor( ply:Team() )
		if cteam.IsValid(ply:GetNWString("CTeam")) then
			col = cteam.GetColor(ply:GetNWString("CTeam"))
		end
		table.insert( tab, col )
		table.insert( tab, ply:GetName() )
	else
		table.insert( tab, "Console" )
	end
 
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": "..strText )
	chat.AddText( unpack(tab) )
 
	return true
 
end

CreateClientConVar( "abdulgraphic_explosion", "3", true, true )
CreateClientConVar( "abdulgraphic_impact", "3", true, true )
CreateClientConVar( "abdulgraphic_rocket", "2", true, true )
CreateClientConVar( "abdulgraphic_beam", "3", true, true )
CreateClientConVar( "abdulgraphic_gore", "2", true, true )