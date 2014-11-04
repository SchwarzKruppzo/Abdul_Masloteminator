local DrawPoly = surface.DrawPoly
local SetDrawColor = surface.SetDrawColor

local function HUDClaymore()
	if LocalPlayer():IsSpectator() then return end
	if !IsValid(LocalPlayer():GetWeapon("abdul_claymore")) then return end
	local b_w,b_h = GetTextWidth( "0", "GM_BigNumbers" )
	//local size = (ScrH() - b_h + (b_h/4)) - (ScrH() - b_h + (b_h/4) - (b_h + (b_h/4))/3)
	local size =  (ScrH() - b_h + (b_h/4)) - (ScrH() - b_h + (b_h/4) - (b_h + (b_h/4))/3)
	local offset = ScrW()/3.5 + ((size - 14 ) * 6)
	local hudHealthBackground = {
		{ x = ScrW()/3.5, y = ScrH() - b_h + (b_h/4) - (b_h + (b_h/4))/3},
		{ x = offset, y = ScrH() - b_h + (b_h/4) - (b_h + (b_h/4))/3},
		{ x = offset + ScrW()/3.5 - ScrW()/3.9, y = ScrH() - b_h + (b_h/4) },
		{ x = ScrW()/3.9, y = ScrH() - b_h + (b_h/4) }
	}
	local x = ScrW()/3.5
	local y = ScrH() - b_h + (b_h/4) - (b_h + (b_h/4))/3
	
	SetDrawColor( 0, 0, 0, 100)
	draw.NoTexture()
	DrawPoly( hudHealthBackground )
	for i=0, 5 do
		local c = i
		surface.SetDrawColor(Color(255,210,100,255))
		if i < LocalPlayer():GetPlantLimit( "Claymore" ) then surface.SetDrawColor(Color(0,0,0,150)) end
		surface.SetMaterial(Material("abdul/claymore.png"))
		surface.DrawTexturedRect( x + (size - 14 )* c,y + 7,size - 14,size - 14)
	end
end
local function HUDPlants()
	HUDClaymore()
end
hook.Add("HUDPaint","HUDStatic",HUDPlants)

