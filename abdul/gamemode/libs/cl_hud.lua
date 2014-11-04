//=VARS=================================================
local scr_w = ScrW()
local scr_h = ScrH()
local SetDrawColor = surface.SetDrawColor
local SetTextColor = surface.SetTextColor
local DrawRect = surface.DrawRect
local DrawText = surface.DrawText
local SetFont = surface.SetFont
local SetMaterial = surface.SetMaterial
local DrawTexturedRect = surface.DrawTexturedRect
local DrawPoly = surface.DrawPoly
local SetTextPos = surface.SetTextPos
local SetFont = surface.SetFont
local HealthColorMul = 0

local pp_standard = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}
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
//=FONTS================================================
surface.CreateFont("GM_BigNumbers",{
	font = "Calibri",
	size = ScreenScale(72),
	weight = 1000,
	antialias = true
})
surface.CreateFont("GM_MedNumbers",{
	font = "Calibri",
	size = 68,
	weight = 1000,
	antialias = true
})
surface.CreateFont("GM_Med2Numbers",{
	font = "Calibri",
	size = 32,
	weight = 1000,
	antialias = true
})
surface.CreateFont("GM_SmallNumbers",{
	font = "Calibri",
	size = 24,
	weight = 1000,
	antialias = true
})
surface.CreateFont("GM_EliteNumbers",{
	font = "Calibri",
	size = ScreenScale(24),
	weight = 1000,
	antialias = true
})
surface.CreateFont("GM_EliteNumbers2",{
	font = "Calibri",
	size = ScreenScale(22),
	weight = 800,
	antialias = true
})


//=HUD==================================================

local function HUDCrosshair()
	if LocalPlayer():IsSpectator() then return end
	if GetGameState() == 1 or GetGameState() == 4 or GetGameState() == 5 then
		DrawColorModify( pp_black )
	end
	// lol
end
	

local function HUDHealth()
	if LocalPlayer():IsSpectator() then return end
	local b_w,b_h = GetTextWidth( "0", "GM_BigNumbers" )
	local hudHealthBackground = {
		{ x = ScrW()/3.9, y = ScrH() - b_h + (b_h/4)},
		{ x = ScrW() - ScrW()/3.9, y = ScrH() - b_h + (b_h/4)},
		{ x = ScrW(), y = ScrH() },
		{ x = 0, y = ScrH()}
	}	

	local health = tostring( math.Clamp( LocalPlayer():Health(), 0, 100 ) )
	local armor = tostring( math.Clamp( LocalPlayer():Armor(), 0, 255 ) )
	local colorbg = LocalPlayer():Health() < 25 and Color( 200 + HealthColorMul, 20 + HealthColorMul, 20 + HealthColorMul, 50 ) or Color(250 + HealthColorMul,200 + HealthColorMul,80 + HealthColorMul,10)
	local color = LocalPlayer():Health() < 25 and Color( 200 + HealthColorMul, 20 + HealthColorMul, 20 + HealthColorMul, 255 ) or Color(250 + HealthColorMul,200 + HealthColorMul,80 + HealthColorMul,255)
	local x = ScrW()/3.9
	local y = ScrH() - b_h + 12
	
	SetDrawColor( 0, 0, 0, 100)
	draw.NoTexture()
	DrawPoly( hudHealthBackground )
	
	SetTextColor(colorbg)
	SetTextPos(x + 5,y)
	SetFont("GM_BigNumbers")
	DrawText("000")
	SetTextColor(color)
	SetTextPos(x + 5,y)
	DrawText( health )
	
	local x = ScrW() - ScrW()/3.9 - b_w*3
	local y = ScrH() - b_h + 12
	SetTextColor(250,200,80,10)
	SetTextPos(x - 5,y)
	SetFont("GM_BigNumbers")
	DrawText("000")
	
	SetTextColor(250,200,80,255)
	SetTextPos(x - 5,y)
	DrawText( armor )
	
	HealthColorMul = HealthColorMul - 1
	HealthColorMul = math.Clamp( HealthColorMul, 0, 255 )
end

local function HUDAmmo()
	if !IsValid(LocalPlayer():GetActiveWeapon()) then return end
	if LocalPlayer():GetActiveWeapon().Melee then return end
	if LocalPlayer():IsSpectator() then return end
	local at = LocalPlayer():GetActiveWeapon().Secondary.Ammo
	local a = LocalPlayer():GetAmmoCount( at )
	local m_w,m_h = GetTextWidth( "0", "GM_MedNumbers" )
	local b_w,b_h = GetTextWidth( "0", "GM_BigNumbers" )
	local ammo = tostring( a )
	local ammotype = getLanguage(at) or "unknown"
	local w,h = GetTextWidth( "999", "GM_BigNumbers" )
	local x = ScrW()/2
	local y  = ScrH() - b_h + (b_h/4) // m_h/2
	draw.SimpleText( ammo, "GM_MedNumbers", x, y, Color(250,200,80,255), 1, 0 )
	y = y + m_h - (m_h/5)
	draw.SimpleText( ammotype, "GM_SmallNumbers", x, y, Color(250,250,250,255), 1, 0 )
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
	
local B = 0
local function HUDGame()
	local c,v = GetTextWidth( "Round", "GM_SmallNumbers" )
	local c2,v2 = GetTextWidth( "0", "GM_MedNumbers" )
	local c_h = v + v2
	local tet = {
		{ x = ScrW()/3.9, y = 0 },
		{ x = ScrW() - ScrW()/3.9, y = 0 },
		{ x = ScrW() - ScrW()/2.6, y = c_h - (c_h/8) },
		{ x = ScrW()/2.6, y = c_h - (c_h/8)}
	}
	SetDrawColor( 0, 0, 0, 100)
	draw.NoTexture()
	surface.DrawPoly( tet )
	
	
	local x = ScrW()/2
	local y = 5
	draw.SimpleText( "Round", "GM_SmallNumbers", x, y, Color(255,255,255,255), 1, 0 )
	
	y = y + v - (v/2)
	draw.SimpleText( GetRound(), "GM_MedNumbers", x, y, Color(255,255,255,255), 1, 0 )
	
	y = y + 64 + 8
	if GetGameState() == 0 then
		draw.SimpleText( "Nedostatochno maslyat dlya nachala maslorezki.", "GM_Med2Numbers", x, y * 1.5, Color(255,100,100,255), 1, 0 )
	end
	
	
	local w,h = GetTextWidth( "Round", "GM_SmallNumbers" )
	local w2,h2 = GetTextWidth( "Round Time", "GM_SmallNumbers" )
	local x = ScrW()/2 + w + w2/2
	local y = 5
	draw.SimpleText( "Round Time", "GM_SmallNumbers", x, y, Color(255,255,255,255), 1, 0 )
	y = y + h2
	draw.SimpleText( os.date( "%M:%S", GetRoundTime() ), "GM_Med2Numbers", x, y, Color(255,255,255,255), 1, 0 )
	
	
	local w2,h2 = GetTextWidth( "Frags Remaining", "GM_SmallNumbers" )
	local x = ScrW()/2 - w - w2/2
	local y = 5
	draw.SimpleText( "Frags Remaining", "GM_SmallNumbers", x, y, Color(255,255,255,255), 1, 0 )
	y = y + h2
	draw.SimpleText( GetFragsRemaining(), "GM_Med2Numbers", x, y, Color(255,255,255,255), 1, 0 )
	
	local winner = GetWin()
	local win = ""
	if type(winner) != "string" then
		if IsValid(winner) then
			if winner:IsPlayer() then
				win = "Lidiruet " .. winner:Nick()
			end
		end
	else
		win = "Lidiruet komanda " .. winner
	end
	
	if winner then
		draw.SimpleText( win, "GM_SmallNumbers", 3, 3, Color(0,0,0,200), 0, 0 )
		draw.SimpleText( win, "GM_SmallNumbers", 2, 2, Color(255,255,255,255), 0, 0 )
	end
end

local fight_i = 0
local vicface_int = 0
local function DrawHolyShit1()
	surface.SetDrawColor(Color(255,255,255,255))
	vicface_int = vicface_int + 1/2
	local X = math.sin(vicface_int)*ScrW()
	local Y = math.cos(vicface_int)*ScrH()/3
	surface.SetMaterial(Material("abdul/yougotfrag.png"))
	surface.DrawTexturedRect( 20 + X,20 - Y,586/1.2,552/1.2)
	surface.SetDrawColor(Color(255,0,0,255))
	surface.SetMaterial(Material("abdul/face1.png"))
	surface.DrawTexturedRect( 20 + X/20,20 - Y/20,787/1.2,720/1.2)
	surface.SetDrawColor(Color(255,255,255,255))
	local X2 = ScrW()/1.3
	local Y2 = ScrH()/2 - (583/2)
	surface.SetMaterial(Material("abdul/coolface.png"))
	surface.DrawTexturedRect( X2,Y2,409/1.2,583/1.2)	
	local X2 = 0
	local Y2 = 0
	surface.SetMaterial(Material("abdul/420noscope.png"))
	surface.DrawTexturedRect( X2,Y2,867/1.2,635/1.2)	
end
local function DrawHolyShit2()
	surface.SetDrawColor(Color(255,255,255,255))
	vicface_int = vicface_int + 1/2
	local X = math.sin(vicface_int)*ScrW()
	local Y = math.cos(vicface_int)*ScrH()/3
	surface.SetMaterial(Material("abdul/face1.png"))
	surface.DrawTexturedRect( 20 + X,20 - Y,787/1.2,720/1.2)
	surface.SetDrawColor(Color(255,255,255,255))
	local X2 = ScrW()/1.3
	local Y2 = ScrH()/2 - (583/2)
	surface.SetMaterial(Material("abdul/face1.png"))
	surface.DrawTexturedRect( X2,Y2,409/1.2,583/1.2)	
	local X2 = math.sin(vicface_int)*100
	local Y2 = math.cos(vicface_int)*50
	surface.SetMaterial(Material("abdul/face2.png"))
	surface.DrawTexturedRect( X2,Y2,400,400)	
	draw.SimpleText( "ETO WIN CHUVAKI"..math.random(0,5), "GM_BigNumbers", ScrW()/2+ X/200, 120 + Y/200, Color(255,math.random(0,255),0,255), 0, 0 )
	draw.SimpleText( "00000000000000000000"..math.random(0,5), "GM_BigNumbers", X/20, 120 + Y, Color(0,0,0,255), 0, 0 )
	draw.SimpleText( "00000000000000000000"..math.random(0,5), "GM_BigNumbers", 120 + X, 120 + Y, Color(0,255,0,255), 0, 0 )
	draw.SimpleText( "228 SWAG"..math.random(0,5), "GM_BigNumbers", ScrW()/2 , ScrH() - 128, Color(0,255,0,255), 0, 0 )
	draw.SimpleText( "OMG OMG NO!!1", "GM_BigNumbers", 0, 0, Color(255,0,0,255), 0, 0 )
	draw.SimpleText( "SHIT", "GM_BigNumbers", 120, 120, Color(255,0,0,255), 0, 0 )
	draw.SimpleText( math.Rand(0,100000), "GM_BigNumbers", 120, ScrH()/2, Color(255,math.random(0,255),math.random(0,255),255), 0, 0 )
	draw.SimpleText( "BATTLEFIELD "..math.random(0,5), "GM_BigNumbers", 120, ScrH()/1.5, Color(0,math.random(0,255),math.random(0,255),255), 0, 0 )
	local X2 = ScrW()/2
	local Y2 = 0
	surface.SetMaterial(Material("abdul/callofduty.png"))
	surface.DrawTexturedRect( X2,Y2,322,241)	
	local X2 = X/128
	local Y2 = ScrH()/2 + X/128
	surface.SetMaterial(Material("abdul/doritos.png"))
	surface.DrawTexturedRect( X2,Y2,420,240)	
end
local function DrawHolyShit3()
	surface.SetDrawColor(Color(255,255,255,255))
	vicface_int = vicface_int + 1/2
	local X = math.sin(vicface_int)*ScrW()
	local Y = math.cos(vicface_int)*ScrH()/3
	surface.SetMaterial(Material("abdul/yougotfrag.png"))
	surface.DrawTexturedRect( 20 + X,20 - Y,586/1.2,552/1.2)
	surface.SetDrawColor(Color(255,0,0,255))
	surface.SetMaterial(Material("abdul/face3.png"))
	surface.DrawTexturedRect( 20 + X/20000,20 - Y/20,332,362)
	surface.SetDrawColor(Color(255,255,255,255))
	local X2 = ScrW()/1.3
	local Y2 = ScrH()/2 - (583/2)
	surface.SetMaterial(Material("abdul/coolface.png"))
	surface.DrawTexturedRect( X2,Y2,409/1.2,583/1.2)	
	local X2 = X/128
	local Y2 = ScrH()/2 + X/128
	surface.SetMaterial(Material("abdul/doritos.png"))
	surface.DrawTexturedRect( X2,Y2,420,240)	
	draw.SimpleText( "00000000000000000000"..math.random(0,5), "GM_BigNumbers", X/20, 120 + Y, Color(0,0,0,255), 0, 0 )
	local X2 = 0
	local Y2 = 0
	surface.SetMaterial(Material("abdul/420noscope.png"))
	surface.DrawTexturedRect( X2,Y2,867/1.2,635/1.2)
	local X2 = ScrW()/2
	local Y2 = ScrH() - 450/1.5
	surface.SetMaterial(Material("abdul/ubi.png"))
	surface.DrawTexturedRect( X2,Y2,697/1.5,450/1.5)
	draw.SimpleText( "ITS TRIPLE, GUY", "GM_BigNumbers", 0, 0, Color(255,255,0,255), 0, 0 )
	local X2 = ScrW() - 400 + math.Rand(0,50)
	local Y2 = ScrH() - 200 + math.Rand(0,50)
	surface.SetMaterial(Material("abdul/battlefield.png"))
	surface.DrawTexturedRect( X2,Y2,382,215)
	local X2 = ScrW()/2
	local Y2 = 0
	surface.SetMaterial(Material("abdul/callofduty.png"))
	surface.DrawTexturedRect( X2,Y2,322,241)	
	draw.SimpleText( "228 SWAG"..math.random(0,5), "GM_BigNumbers", 0 , ScrH() - 128, Color(0,255,0,255), 0, 0 )
	draw.SimpleText( "WE ARE PULLING OUT GUYS", "GM_BigNumbers", 0 , ScrH()/2, Color(0,0,255,255), 0, 0 )
	draw.SimpleText( "HOLY CRAP NO", "GM_BigNumbers", ScrW()/2 , ScrH()/2.5, Color(255,0,0,255), 0, 0 )
end
local function HUDGameState()
	local x = ScrW()/2
	local y = ScrH()/3.2
	local winner = GetWin()
	local win = ""
	if type(winner) != "string" then
		if IsValid(winner) then
			if winner:IsPlayer() then
				win = winner:Nick().." zatashil"
			end
		end
	else
		win = "Komanda ".. winner .." pobedila"
	end
	
	local w2,h2 = GetTextWidth( "0", "GM_EliteNumbers" )
	if GetGameState() == GS_ROUND_PREPARE then
		
		DrawShadowText( "Maslorezka nachnetsa cherez "..tostring(CURRENT_ROUNDTIME), "GM_EliteNumbers", x, y, Color(255,255,255,255), 1, 0 )
		fight_i = CurTime() + 1
	elseif GetGameState() == GS_ROUND_PLAYING then
		if fight_i > CurTime() then
			DrawHolyShit1()
			local y = ScrH()/2.5
			DrawShadowText( "FIGHT!", "GM_BigNumbers", x, y, Color(255,255,255,255), 1, 0 )
		end
	elseif GetGameState() == GS_ROUND_END then
		DrawHolyShit3()
		DrawShadowText( "Round "..GetRound().." okonchen suka bleat", "GM_EliteNumbers", x, y, Color(255,255,255,255), 1, 0 )
		local y = ScrH()/3.2 + h2 - 16
		DrawShadowText( win, "GM_EliteNumbers2", x, y, Color(220,255,220,255), 1, 0 )
	elseif GetGameState() == GS_GAME_OVER then
		DrawHolyShit2()
		DrawShadowText( "Vse roundi okoncheni", "GM_EliteNumbers", x, y, Color(255,255,255,255), 1, 0 )
		local y = ScrH()/3.2 + h2 - 16
		DrawShadowText( win, "GM_EliteNumbers2", x, y, Color(220,255,220,255), 1, 0 )
	end
end




surface.CreateFont( "BFName",
{
 font  = "Calibri",
 size  = 18,
 weight  = 800
})
surface.CreateFont( "BFNameBlur",
{
 font  = "Calibri",
 size  = 18,
 weight  = 800,
 blursize = 1
})
function draw.BlurredText(t, f, bf, x, y, bos, fc, bfc, xa, ya)
	draw.SimpleText(t, bf, x + bos, y + bos, bfc, (xa and xa or TEXT_ALIGN_CENTER), (ya and ya or TEXT_ALIGN_CENTER))
	draw.SimpleText(t, f, x, y, fc, (xa and xa or TEXT_ALIGN_CENTER), (ya and ya or TEXT_ALIGN_CENTER))
end
local function func_DrawName(ent,color)
	local dist=ent:GetPos():Distance(LocalPlayer():GetPos())
	local len=math.Round((dist*0.75)*0.0254)
	local headpos=ent:GetBonePosition( ent:LookupBone("ValveBiped.Bip01_Head1") )
	dist=math.Clamp( dist, 0, 300)
	local pos=(headpos+Vector(0,0,8+dist*0.05)):ToScreen()
	draw.BlurredText(ent:GetName(), "BFName", "BFNameBlur", pos.x, pos.y, 0, color, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)   
	draw.BlurredText( len.." m", "BFName", "BFNameBlur", pos.x, pos.y+12, 0, color, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)   
end
local tracedata = {}
tracedata.filter = LocalPlayer()
local function HUDTeamMates()
	for _,v in pairs(player.GetAll()) do
		tracedata.start = LocalPlayer():GetShootPos()
		tracedata.endpos = v:GetPos()+v:OBBCenter()
		if v == LocalPlayer() then continue end
		if v:GetNWString("CTeam") == "" then continue end
		if v:GetNWString("CTeam") != LocalPlayer():GetNWString("CTeam") then continue end
		if v:IsSpectator() then continue end
		func_DrawName(v, Color(156, 230, 97))
	end
end




local function HUDSpawns()
	cam.Start3D(EyePos(),EyeAngles())
		for k,v in pairs(ents.FindByClass("ent_weaponspawn2")) do
			local trace = {}
			trace.start = v:GetPos()
			trace.endpos = v:GetPos() - Vector(0,0,1)*100000
			trace.mask = CONTENTS_SOLID
			local tr = util.TraceLine( trace )
			
			render.SetMaterial( Material("sprites/physg_glow1") )
			render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, 128, 128, Color(55,200,255) )
			render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, 64, 64, color_white )
		end
	cam.End3D()
end
hook.Add("PostDrawOpaqueRenderables","SPAWN",HUDSpawns)
net.Receive( "GM_PlayerHurt", function( length )
	HealthColorMul = 45
end)
//=INIT=HUD=============================================

function BasicHUD()
	HUDCrosshair()
	HUDHealth()
	HUDAmmo()
	HUDGame()
	HUDGameState()
	HUDTeamMates()
	//HUDSpawns()
end
hook.Add("HUDPaint","GamemodeHUD",BasicHUD)
