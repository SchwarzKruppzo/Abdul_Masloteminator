local d = 0
local c = false
local vignetteAlpha = 0
local alpha = 0
hook.Add( "RenderScreenspaceEffects", "Explosion", function()
    if d == 10 then 
		alpha = 0
        c = false 
    end
	
    if c then
		alpha = 255
        d = d + 5 / 1
		
    else
        d = d - 5 / 2		
    end
    d = math.Clamp(d, 0, 10)
    if d > 0 then
		local tab = {}
		tab[ "$pp_colour_addr" ] 		= 0
		tab[ "$pp_colour_addg" ] 		= 0
		tab[ "$pp_colour_addb" ] 		= 0
		tab[ "$pp_colour_brightness" ] 	= 0
		tab[ "$pp_colour_contrast" ] 	= 1
		tab[ "$pp_colour_colour" ] 		= 1
		tab[ "$pp_colour_mulr" ] 		= 0.25
		tab[ "$pp_colour_mulg" ] 		= 0.25
		tab[ "$pp_colour_mulb" ] 		= 0
		DrawColorModify( tab )
		DrawSharpen( 1, d )
    end
	vignetteAlpha = math.Approach(vignetteAlpha, alpha, FrameTime() * 5600)
	surface.SetDrawColor(255, 255, 255, vignetteAlpha)
	surface.SetMaterial(Material("abdul/vignette.png"))
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end )

net.Receive("ExplosionEffect",function( len )
	d = 0
	c = true
end )