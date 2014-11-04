DEFINE_BASECLASS( "gamemode_base" )


local vignetteAlpha = 0
function GM:HUDPaint()
	local alpha = 180
	local data = {}
		data.start = LocalPlayer():GetPos()
		data.endpos = data.start + Vector(0, 0, 1000)
	local trace = util.TraceLine(data)
	if (!trace.Hit or trace.HitSky) then
		alpha = 125
	end
	vignetteAlpha = math.Approach(vignetteAlpha, alpha, FrameTime() * 125)

	surface.SetDrawColor(255, 255, 255, vignetteAlpha)
	surface.SetMaterial(Material("abdul/vignette.png"))
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end
function GM:PostDrawViewModel( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end

end