function GetWiner()
	local last = 0
	local maxi = 0
	for k,v in pairs(player.GetAll()) do
		if v:IsSpectator() then continue end
		if last <= v:Frags() then
			last = v:Frags()
			maxi = k
		end
	end
	return player.GetAll()[maxi]
end
function GetTextWidth( text, font )
	surface.SetFont( font )
	return surface.GetTextSize( text )
end

function DrawShadowText( text, font, x, y, color, z, c )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,math.Clamp(color.a - 55, 0, 255)), z, c )
	draw.SimpleText( text, font, x, y, color, z, c )
end