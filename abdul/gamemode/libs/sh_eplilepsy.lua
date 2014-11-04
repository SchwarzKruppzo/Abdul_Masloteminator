if SERVER then
	util.AddNetworkString( "EP_YouFragged" )
	hook.Add("PlayerDeath","EP_YouFragged",function( victim, inflictor, attacker )
		if victim ~= attacker then
			net.Start( "EP_YouFragged" )
				net.WriteString(victim:Nick())
				net.WriteString(inflictor:GetClass())
			net.Send( attacker )
		end
	end)
else
	local YouFraggedShowTime = 0
	local YouFraggedShow = false
	local fragged = nil
	local NextHintTime = 0
	local HintShow = false
	local weapon = nil
	net.Receive( "EP_YouFragged", function( len )
		YouFraggedShow = true
		YouFraggedShowTime = CurTime() + 0.5
		fragged = net.ReadString()
		weapon = net.ReadString()
		NextHintTime = CurTime() + 8
		HintShow = true
	end)
	local coolface_int = 0
	local vicface_int = 0
	local function GetPlace()
		local plys = {}
		for k,v in ipairs( player.GetAll() ) do
			table.insert( plys, { player = v, kills = v:Frags() } )
		end	
		table.SortByMember( plys, "kills" )
		if LocalPlayer() == plys[1].player then
			return 1
		elseif LocalPlayer() == plys[2].player then
			return 2
		elseif LocalPlayer() == plys[3].player then
			return 3
		else
			return 0
		end
	end
	local function GetTextWidth( text, font )
		surface.SetFont( font )
		return surface.GetTextSize( text )
	end
	local placecolor = Color(255,255,255,255)
	local function YouFraggedHUD()
		if GetGameState() ~= GS_ROUND_PLAYING then return end
		local w2,h2 = GetTextWidth( "0", "GM_EliteNumbers" )
		if YouFraggedShow then
			if YouFraggedShowTime > CurTime() then
				surface.SetDrawColor(Color(255,255,255,255))
				vicface_int = vicface_int + 1/2
				local X = math.sin(vicface_int)*ScrW()
				local Y = math.cos(vicface_int)*ScrH()/3
				surface.SetMaterial(Material("abdul/yougotfrag.png"))
				surface.DrawTexturedRect( 20 + X,20 - Y,586/1.2,552/1.2)
				
				coolface_int = coolface_int + 1/5
				local X = math.sin(coolface_int)*50
				local Y = math.cos(coolface_int)*100
				surface.SetMaterial(Material("abdul/coolface.png"))
				surface.DrawTexturedRect( ScrW()/2 + X,100 + Y,409/1.2,583/1.2)
				if weapon == "abdul_machete" then
					surface.SetDrawColor(Color(255,255,255,255))
					surface.SetMaterial(Material("abdul/killedwithmachete.png"))
					surface.DrawTexturedRect( 0,0,475,262)
				end
			else
				YouFraggedShow = false
			end
		end
		if HintShow then
			if NextHintTime > CurTime() then
				local place = GetPlace() or 0
				if place == 1 then
					placecolor = Color(100,225,100,255)
				elseif place == 2 then
					placecolor = Color(225,100,100,255)
				elseif place == 3 then
					placecolor = Color(225,225,100,255)
				else
					placecolor = Color(225,255,255,255)
				end
				
				local x = ScrW()/2
				local y = ScrH()/3.2				
				DrawShadowText( "Ti zamochil maslenka "..fragged, "GM_EliteNumbers", x, y, Color(255,255,255,255), 1, 0 )
				local y = y + h2
				DrawShadowText( "Ti na "..place.." meste so schetom ".. LocalPlayer():Frags(), "GM_EliteNumbers2", x, y, placecolor, 1, 0 )
			else
				HintShow = false
			end
		end
	end
	
	local function EpilepsyHUD()
		YouFraggedHUD()
	end
	hook.Add("HUDPaint","EP_HUD",EpilepsyHUD)
end