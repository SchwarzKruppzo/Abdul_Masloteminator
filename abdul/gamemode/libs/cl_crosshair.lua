local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local SetMaterial = surface.SetMaterial
local DrawTexturedRect = surface.DrawTexturedRect
local DrawRect = surface.DrawRect
local CrosshairTypes = {}
surface.CreateFont("GM_SmallNumbers1",{
	font = "Calibri",
	size = 24,
	weight = 1000,
	antialias = true
})

local function DrawDefaultCrosshair( offset, size )
	//local x,y = ScrW()/2,ScrH()/2
	
	local td = {}
	td.start = LocalPlayer():GetShootPos()
	td.endpos = td.start + (LocalPlayer():EyeAngles()):Forward() * 16384
	td.filter = LocalPlayer()
	local tr = util.TraceLine(td)
	local x2 = tr.HitPos:ToScreen()
	local x, y = x2.x, x2.y
	x = math.Round(x,0.5)
	y = math.Round(y,0.5)
	
	SetDrawColor( 255, 255, 255, 200)
	DrawRect(x - 1,y - 1, 2, 2 )	
	SetDrawColor( 255, 0, 0, 200 );
	SetMaterial( Material("sprites/hud/v_crosshair1") );
	DrawTexturedRect( x - 16, y - 16, 32, 32 );
	
	local ent = LocalPlayer():GetEyeTrace().Entity
	if ent:IsPlayer() then
		local col = team.GetColor( ent:Team() )
		if cteam.IsValid(ent:GetNWString("CTeam")) then
			col = cteam.GetColor(ent:GetNWString("CTeam"))
		end
		DrawShadowText( ent:Nick(), "GM_SmallNumbers1", ScrW()/2, y + 28, col, 1, 1 )
	end
end
local function DrawRocketCrosshair( offset, size )
	local td = {}
	td.start = LocalPlayer():GetShootPos()
	td.endpos = td.start + (LocalPlayer():EyeAngles()):Forward() * 16384
	td.filter = LocalPlayer()
	local tr = util.TraceLine(td)
	local x2 = tr.HitPos:ToScreen()
	local x, y = x2.x, x2.y
	x = math.Round(x,0.5)
	y = math.Round(y,0.5)
	
    local gap2 = 0
    local cl = 8 + size
    local gap = 8 + offset
	
    surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(x - 3 - gap2 - cl - gap, y + 2 + gap, 3, cl + 2 + gap2)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawRect(x - 3 - gap2 - cl - gap, y + 1 + gap + cl, cl + 2 + gap2, 3)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawRect(x - 2 - gap2 - cl - gap, y + 3 + gap, 1, cl + gap2)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawRect(x - 2 - gap2 - cl - gap, y + 2 + gap + cl, cl + gap2, 1)
    
    surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(x - 3 - gap2 - cl - gap, y - cl - gap2 - 3 - gap, 3, cl + 2 + gap2)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawRect(x - 3 - gap2 - cl - gap, y - cl - gap2 - 3 - gap, cl + 2 + gap2, 3)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawRect(x - 2 - gap2 - cl - gap, y - cl - gap2 - 2 - gap, 1, cl + gap2)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawRect(x - 2 - gap2 - cl - gap, y - cl - gap2 - 2 - gap, cl + gap2, 1)
    
    surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(x + 1 + gap2 + cl + gap, y + 2 + gap, 3, cl + 2 + gap2)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawRect(x + 2 + gap2 + gap, y + 1 + gap + cl, cl + 2 + gap2, 3)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawRect(x + 2 + gap2 + cl + gap, y + 3 + gap, 1, cl + gap2)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawRect(x + 3 + gap2 + gap, y + 2 + gap + cl, cl + gap2, 1)
    
    surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(x + 1 + gap2 + cl + gap, y - cl - gap2 - 3 - gap, 3, cl + 2 + gap2)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawRect(x + 2 + gap2 + gap, y - cl - gap2 - 3 - gap, cl + 2 + gap2, 3)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawRect(x + 2 + gap2 + cl + gap, y - cl - gap2 - 2 - gap, 1, cl + gap2)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawRect(x + 3 + gap2 + gap, y - cl - gap2 - 2 - gap, cl + gap2, 1)
	
	local ent = LocalPlayer():GetEyeTrace().Entity
	if ent:IsPlayer() then
		local col = team.GetColor( ent:Team() )
		if cteam.IsValid(ent:GetNWString("CTeam")) then
			col = cteam.GetColor(ent:GetNWString("CTeam"))
		end
		DrawShadowText( ent:Nick(), "GM_SmallNumbers1", ScrW()/2, y + 28 + gap, col, 1, 1 )
	end
end
local function DrawBulletCrosshair( offset, size )
    local td = {}
	td.start = LocalPlayer():GetShootPos()
	td.endpos = td.start + (LocalPlayer():EyeAngles()):Forward() * 16384
	td.filter = LocalPlayer()
	local tr = util.TraceLine(td)
	local x2 = tr.HitPos:ToScreen()
	local x, y = x2.x, x2.y
	x = math.Round(x,0.5)
	y = math.Round(y,0.5)
	
    local gap2 = 0
    local cl = 8 + size
    local gap = 12 + offset
	
	SetDrawColor(0,0,0,255)
    DrawRect(x - 3 - gap2 - cl - gap, y - 1, cl + 2 + gap2, 3)
    SetDrawColor(255,255,255,255)
    DrawRect(x - 2 - gap2 - cl - gap, y, cl + gap2, 1)
    
    SetDrawColor(0,0,0,255)
	DrawRect(x + 2 + gap, y - 1, cl + 2 + gap2, 3)
	SetDrawColor(255,255,255,255)
	DrawRect(x + 3 + gap, y, cl + gap2, 1)

	SetDrawColor(0,0,0,255)
	DrawRect(x - 1, y + 2 + gap, 3, cl + 2 + gap2)
	SetDrawColor(255,255,255,255)
	DrawRect(x, y + 3 + gap, 1, cl + gap2)
				
	SetDrawColor(0,0,0,255)
	DrawRect(x - 1, y - cl - gap2 - 3 - gap, 3, cl + 2 + gap2)
	SetDrawColor(255,255,255,255)
	DrawRect(x, y - cl - gap2 - 2 - gap, 1, cl + gap2)
	
	local ent = LocalPlayer():GetEyeTrace().Entity
	if ent:IsPlayer() then
		local col = team.GetColor( ent:Team() )
		if cteam.IsValid(ent:GetNWString("CTeam")) then
			col = cteam.GetColor(ent:GetNWString("CTeam"))
		end
		DrawShadowText( ent:Nick(), "GM_SmallNumbers1", ScrW()/2, y + 28 + gap, col, 1, 1 )
	end
end


CrosshairTypes["default"] = DrawDefaultCrosshair
CrosshairTypes["auto"] = DrawBulletCrosshair
CrosshairTypes["rocket"] = DrawRocketCrosshair
local pp_black = {
	[ "$pp_colour_addr" ] = 0.5,
	[ "$pp_colour_addg" ] = 0.5,
	[ "$pp_colour_addb" ] = 0.5,
	[ "$pp_colour_brightness" ] = -0.7,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 0.2,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}
local function DrawCrosshairs()
	if LocalPlayer():IsSpectator() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if !IsValid(wep) then return end
	if CrosshairTypes[wep.CrosshairType] then
		local offset = wep.CrosshairGap or 0
		local size = wep.CrosshairSize or 0
		CrosshairTypes[wep.CrosshairType]( offset, size)
	else
		DrawDefaultCrosshair()
	end

	
end
hook.Add("HUDPaint","CHUDCrosshair",DrawCrosshairs)