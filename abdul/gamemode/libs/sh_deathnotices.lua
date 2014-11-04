if SERVER then
	util.AddNetworkString( "net_Deathnotice" )
	hook.Add("PlayerDeath","net_Deathnotice",function( victim, inflictor, attacker )
		net.Start( "net_Deathnotice" )
			net.WriteString(victim:Nick())
			net.WriteString(inflictor:GetClass())
			if !IsValid( attacker ) then 
				net.WriteString("")
			else
				net.WriteString(attacker:Nick())
			end
			
			net.WriteBit(victim.GotHeadshot or false)
		net.Broadcast()
	end)
else
	surface.CreateFont("GM_Deathnotice",{
		font = "Calibri",
		size = 22,
		weight = 1000,
		antialias = true
	})
	Deathnotices = Deathnotices or {}
	local Deathreason = {}
	Deathreason["player"] = " ubilsa "
	Deathreason["abdul_mp7"] = " [%sMP7] "
	Deathreason["abdul_railgun"] = " [%sRAILGUN] "
	Deathreason["abdul_shotgun"] = " [%sMASLOBABA] "
	Deathreason["abdul_rocketlauncher"] = " [%sMASLOROCETNICA] "
	Deathreason["ent_rocket"] = " [%sMASLOROCETNICA] "
	Deathreason["ent_shrap"] = " [%sMASLOCHEZATOR] "
	Deathreason["ent_shrapbomb"] = " [%sMASLOCHEZATOR] "
	Deathreason["abdul_machete"] = " [%sMACHETE] "
	Deathreason["abdul_ak47"] = " [%sKALASH] "
	Deathreason["abdul_impulseminigun"] = " [%sMINIGUN] "
	Deathreason["abdul_egon"] = " [%sPALISAN] "
	Deathreason["abdul_claymore"] = " [%sM18 CLAYMORE] "
	Deathreason["ent_claymore"] = " [%sM18 CLAYMORE] "
	Deathreason["ent_50cal"] = " [%sM3 BROWNING] "
	Deathreason["ent_turret"] = " [%sTURRET] "
	Deathreason["abdul_awm"] = " [%s420noscoper] "
	Deathreason["abdul_plasma"] = " [%sBOMBOM] "
	Deathreason["dmg_plasma"] = " [%sBOMBOM] "
	Deathreason["ent_plasma"] = " [%sBOMBOM] "
	
	net.Receive( "net_Deathnotice", function( len )
		local victim = net.ReadString()
		local inflictor = net.ReadString()
		local attacker = net.ReadString()
		local gotheadshot = net.ReadBit()
		local tbl = {victim = victim, inflictor = inflictor, attacker = attacker, head = gotheadshot}
		table.insert( Deathnotices, tbl )
	end)
	
	
	local function HUDDeathnotices()
		local x = ScrW() - 10
		local y = 0
		for k,v in ipairs( Deathnotices ) do
			if not v.fade then 
				v.fade = CurTime() + 4
			end
			if not v.alpha then v.alpha = 255 end
			if v.fade < CurTime() then
				v.alpha = v.alpha - 64 / 20;
				v.alpha = math.Clamp( v.alpha, 0, 255 );
			end
			if k > 1 then 
				local text2_w,text2_h = GetTextWidth( "[", "GM_Deathnotice" )
				y = y + text2_h
			end
			
			
			if v.alpha ~= 0 then
				local weapon = Deathreason[v.inflictor] or Deathreason["player"]
				if weapon == Deathreason["player"] then
					local text1_w,text1_h = GetTextWidth( v.victim, "GM_Deathnotice" )
					local text2_w,text2_h = GetTextWidth( weapon, "GM_Deathnotice" )
					DrawShadowText(v.victim,"GM_Deathnotice",x - text2_w, y,Color(255,120,120,v.alpha),2,0)
					DrawShadowText(weapon,"GM_Deathnotice",x, y,Color(255,255,255,v.alpha),2,0)
				else
					if v.head == 1 then
						weapon = string.format( weapon, "HEAD - " )
					else
						weapon = string.format( weapon, "" )
					end
					local text1_w,text1_h = GetTextWidth( v.attacker, "GM_Deathnotice" )
					local text2_w,text2_h = GetTextWidth( weapon, "GM_Deathnotice" )
					local text3_w,text3_h = GetTextWidth( v.victim, "GM_Deathnotice" )
					DrawShadowText(v.attacker,"GM_Deathnotice",x - text2_w - text3_w,y,Color(255,120,120,v.alpha),2,0)
					DrawShadowText(weapon,"GM_Deathnotice",x - text3_w, y,Color(255,255,255,v.alpha),2,0)
					DrawShadowText(v.victim,"GM_Deathnotice",x,y,Color(0,200,255,v.alpha),2,0)
				end
				
			else

				table.remove(Deathnotices,k)
			end
		end
	end
	hook.Add("HUDPaint","Deathnotices",HUDDeathnotices)
end