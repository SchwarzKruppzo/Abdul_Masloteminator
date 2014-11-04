KillingSprees = KillingSprees or {}
KillStreaks = KillStreaks or {}
KillingSprees[5] = { text = "KILLING SPREE", sound = "killingspree.wav" }
KillingSprees[10] = { text = "ADEPT", sound = "adept.wav" }
KillingSprees[15] = { text = "MASLOROJIY", sound = "maslorozii.wav" }
KillingSprees[20] = { text = "MASLOTERMINATOR", sound = "masloterminator.wav" }
KillStreaks[2] = { text = "DOUBLE KILL", sound = "doublekill.wav" }
KillStreaks[3] = { text = "MULTI KILL", sound = "multikill.wav" }
KillStreaks[4] = { text = "MEGA KILL", sound = "megakill.wav" }
KillStreaks[6] = { text = "MONSTER KILL", sound = "monsterkill.wav" }
KillStreaks[7] = { text = "1337xLUDICROUSx228 KILL", sound = "ludicrouskill.wav" }
KillStreaks[8] = { text = "NAMBA WAN ULTRA KILL", sound = "ultrakill.wav" }
KillStreaks[9] = { text = "CHEATS KILL", sound = "unstoppable.wav" }
local meta = FindMetaTable("Player")
if SERVER then
	util.AddNetworkString( "KS_Changed" )
	util.AddNetworkString( "KS_Reset" )
	util.AddNetworkString( "KS_Headshot" )
	function meta:IncreaseKS()
		if not self.KillisngSpree then self.KillisngSpree = 0 end
		if not self.Killstreak then self.Killstreak = 0 end
		if not self.KillstreakNext then self.KillstreakNext = CurTime() + 10 end
		self.KillisngSpree = self.KillisngSpree + 1
		self.Killstreak = self.Killstreak + 1
		self.KillstreakNext = CurTime() + 10
		net.Start( "KS_Changed" )
			net.WriteInt( self.KillisngSpree, 32 )
			net.WriteInt( self.Killstreak, 32 )
		net.Send( self )
		
		local reward = KSAward_SelectAward( self, self.KillisngSpree )
		if reward.id then
			self:SetKSAward( reward.id )
		end
	end
	
	function meta:ResetSpree()
		self.KillisngSpree = 0
		net.Start( "KS_Reset" )
		net.Send( self )
	end
	function meta:ResetStreak()
		self.Killstreak = 0
	end
	function meta:DidHeadshot()
		net.Start( "KS_Headshot" )
		net.Send( self )
	end

	hook.Add("PlayerDeath","KILLINGSPREES_PD",function( victim, inflictor, attacker )
		if attacker != victim then
			if IsValid(attacker) then
				attacker:IncreaseKS()
				if victim.GotHeadshot then
					attacker:DidHeadshot()
				end
			end
			if victim.KillisngSpree > 1 then
				Notify(Color(255,120,120),attacker:Nick(),Color(255,255,255)," прервал серию убийств ("..victim.KillisngSpree..") ",Color(0,200,255,255),victim:Nick())
			end
			
		else
			if victim.KillisngSpree > 1 then
				Notify(Color(255,120,120),victim:Nick(),Color(255,255,255)," прервал свою серию убийств ("..victim.KillisngSpree..")")
			end
		end
		victim:ResetSpree()
		victim:ResetStreak()
	end)
	hook.Add("Think","KILLINGSPREES_T",function()
		for k,v in pairs(player.GetAll()) do
			if v:IsSpectator() then continue end
			if v.KillstreakNext <= CurTime() then
				v:ResetStreak()
			end
		end
	end)
	function HEADSHOT( ply, hitgroup, dmginfo )
		if hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage( 2 )
			ply.GotHeadshot = true
		else
			ply.GotHeadshot = false
		end
	end
 
	hook.Add("ScalePlayerDamage","HEADSHOT",HEADSHOT)
else
	local killtext = ""
	local killsound = ""
	local NextHintTime = 0
	local HintShow = false
	net.Receive( "KS_Changed", function( len )
		local spree = net.ReadInt(32)
		local streak = net.ReadInt(32)
		
		local Table1 = KillingSprees[spree]
		local Table2 = KillStreaks[streak]
		
		if Table1 then
			if Table1.text then killtext = Table1.text end
			if Table1.sound then killsound = Table1.sound end
		elseif Table2 then
			if Table2.text then killtext = Table2.text end
			if Table2.sound then killsound = Table2.sound end
		end
		surface.PlaySound("abdul/sprees/"..killsound)
		NextHintTime = CurTime() + 2
		HintShow = true
	end)
	net.Receive( "KS_Headshot", function( len )
		killtext = "HEADSHOT"
		surface.PlaySound("abdul/sprees/headshot.wav")
		NextHintTime = CurTime() + 2
		HintShow = true
	end)
	local vicface_int = 0
	local function Epilepsy( text )
		if text == "DOUBLE KILL" then
			vicface_int = vicface_int + 1/2
			local X = math.sin(vicface_int)*ScrW()
			local Y = math.cos(vicface_int)*ScrH()/3
			local X2 = X/128
			local Y2 = ScrH()/2 + X/128
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/doritos.png"))
			surface.DrawTexturedRect( X2,Y2,420,240)	
			draw.SimpleText( "00000000000000000000"..math.random(0,5), "GM_BigNumbers", X/20, 120 + Y, Color(0,0,0,255), 0, 0 )
			draw.SimpleText( "gosha 228", "GM_BigNumbers", ScrW()/3, ScrH()/2, Color(0,255,0,255), 0, 0 )
			draw.SimpleText( "ваще затащил масленок", "GM_MedNumbers", 50, 0, Color(255,255,0,255), 0, 0 )
			draw.SimpleText( "вся страна ваще смеялась", "GM_MedNumbers", ScrH()/3,ScrH()/3, Color(100,50,255,255), 0, 0 )
			local X2 = ScrW()/2
			local Y2 = 0
			surface.SetMaterial(Material("abdul/callofduty.png"))
			surface.DrawTexturedRect( X2,Y2,322,241)
			local X2 = ScrW() - 400 + math.Rand(0,50)
			local Y2 = ScrH() - 200 + math.Rand(0,50)
			surface.SetMaterial(Material("abdul/battlefield.png"))
			surface.DrawTexturedRect( X2,Y2,382,215)
		elseif text == "MULTI KILL" or text == "CHEATS KILL" then
			vicface_int = vicface_int + 1/2
			local X = math.sin(vicface_int)*ScrW()
			local Y = math.cos(vicface_int)*ScrH()/3
			local X2 = ScrW() - 400 + math.Rand(0,50)
			local Y2 = ScrH() - 200 + math.Rand(0,50)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/battlefield.png"))
			surface.DrawTexturedRect( X2,Y2,382,215)
			draw.SimpleText( "CHEATS!!11", "GM_BigNumbers", ScrH()/3,ScrH()/3, Color(255,50,0,255), 0, 0 )
			draw.SimpleText( "FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU", "GM_BigNumbers", X,0, Color(0,50,0,255), 0, 0 )
			draw.SimpleText( "FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU", "GM_BigNumbers", X,Y, Color(0,50,0,255), 0, 0 )
			draw.SimpleText( "FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU", "GM_BigNumbers", X,Y*2, Color(0,50,0,255), 0, 0 )
			draw.SimpleText( "ваще затащил масленок", "GM_MedNumbers", 50, 0, Color(255,255,0,255), 0, 0 )
			local X2 = ScrW()/1.3
			local Y2 = ScrH()/2 - (583/2)
			surface.SetMaterial(Material("abdul/face1.png"))
			surface.DrawTexturedRect( X2,Y2,409/1.2,583/1.2)	
			surface.SetDrawColor(Color(255,0,0,255))
			surface.DrawRect(X,Y,200,200)
			surface.SetDrawColor(Color(0,255,0,255))
			surface.DrawRect(X*2,Y,200,200)
			surface.SetDrawColor(Color(0,0,255,255))
			surface.DrawRect(X,Y*2,200,200)
			draw.SimpleText( "РГБ КВАДРАТИКИ ХЕЛП", "GM_BigNumbers", ScrW()/4, ScrH()/2, Color(255,0,0,255), 0, 0 )
			draw.SimpleText( "228 SWAG"..math.random(0,5), "GM_BigNumbers", ScrW()/2 , ScrH() - 128, Color(0,255,0,255), 0, 0 )
			local X2 = math.sin(vicface_int)*100
			local Y2 = math.cos(vicface_int)*50
			surface.SetMaterial(Material("abdul/face2.png"))
			surface.DrawTexturedRect( X2,Y2,400,400)	
			surface.SetDrawColor(Color(255,255,255,255))
			local X2 = ScrW()/3
			local Y2 = 0
			surface.SetMaterial(Material("abdul/coolface.png"))
			surface.DrawTexturedRect( X2,Y2,409/1.2,583/1.2)	

		elseif text == "KILLING SPREE" then
			vicface_int = vicface_int + 1/2
			local X = math.sin(vicface_int)*ScrW()
			local Y = math.cos(vicface_int)*ScrH()/3
			local X2 = ScrW()/5
			local Y2 = 120
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/number1.png"))
			surface.DrawTexturedRect( X2 + X/228,Y2,806/1.2,428/1.2)	
			local X2 = ScrW()/2
			local Y2 = ScrH()/2
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/sky.png"))
			surface.DrawTexturedRect( X2,Y2+ Y/128,129*2,72*2)
			draw.SimpleText( "228 SWAG"..math.random(0,5), "GM_BigNumbers", ScrW()/2 , ScrH() - 128, Color(0,255,0,255), 0, 0 )
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/yougotfrag.png"))
			surface.DrawTexturedRect( 20 + X,20 - Y,586/1.2,552/1.2)
			local X2 = 0
			local Y2 = 0
			surface.SetMaterial(Material("abdul/420noscope.png"))
			surface.DrawTexturedRect( X2,Y2,867/1.2,635/1.2)	
			local X2 = X/128
			local Y2 = ScrH()/2 + X/128
			surface.SetMaterial(Material("abdul/doritos.png"))
			surface.DrawTexturedRect( X2,Y2,420,240)	
			draw.SimpleText( "00000000000000000000"..math.random(0,5), "GM_BigNumbers", X/20, 120 + Y, Color(0,0,0,255), 0, 0 )
			local X2 = ScrW()/2
			local Y2 = 0
			surface.SetMaterial(Material("abdul/callofduty.png"))
			surface.DrawTexturedRect( X2,Y2,322,241)
		elseif text == "MEGA KILL" or text == "ADEPT" then
			vicface_int = vicface_int + 1/2
			local X = math.sin(vicface_int)*ScrW()
			local Y = math.cos(vicface_int)*ScrH()/3
			draw.SimpleText( "вся страна ваще смеялась", "GM_MedNumbers", ScrH()/3,ScrH()/3, Color(100,50,255,255), 0, 0 )
			local X2 = ScrW()/2
			local Y2 = ScrH()/2
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/sky.png"))
			surface.DrawTexturedRect( X2 + Y,Y2+ Y,129*2,72*2)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/yougotfrag.png"))
			surface.DrawTexturedRect( 20 + X,20 - Y,586/1.2,552/1.2)
			local Y2 = ScrH() - 450/1.5
			surface.SetMaterial(Material("abdul/ubi.png"))
			surface.DrawTexturedRect( X2,Y2,697/1.5,450/1.5)
			draw.SimpleText( "ITS TRIPLE, GUY", "GM_BigNumbers", 0, 0, Color(255,255,0,255), 0, 0 )
			local X2 = ScrW() - 400 + math.Rand(0,50)
			local Y2 = ScrH() - 200 + math.Rand(0,50)
			surface.SetMaterial(Material("abdul/battlefield.png"))
			surface.DrawTexturedRect( X2,Y2,382,215)
			surface.SetDrawColor(Color(255,255,255,math.random(0,50)))
			surface.SetMaterial(Material("abdul/bf4.png"))
			surface.DrawTexturedRect( 0,0,ScrW(),ScrH())
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/evilface.png"))
			surface.DrawTexturedRect( X2,0,184 + math.random(0,100),184 + math.random(0,100))
		elseif text == "MONSTER KILL" or text == "MASLOROJIY" then
			vicface_int = vicface_int + 1/2
			local X = math.sin(vicface_int)*ScrW()
			local Y = math.cos(vicface_int)*ScrH()/3
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/evilface.png"))
			surface.DrawTexturedRect( X,0,184 + math.random(0,500),184 + math.random(0,500))
			draw.SimpleText( "228 SWAG"..math.random(0,5), "GM_BigNumbers", ScrW()/2 , ScrH() - 128, Color(0,255,0,255), 0, 0 )
			local X2 = ScrW()/1.3
			local Y2 = ScrH()/2 - (583/2)
			surface.SetMaterial(Material("abdul/face1.png"))
			surface.DrawTexturedRect( X2,Y2,409/1.2,583/1.2)	
			surface.SetDrawColor(Color(255,0,0,255))
			surface.DrawRect(X,Y,200,200)
			surface.SetDrawColor(Color(0,255,0,255))
			surface.DrawRect(X*2,Y,200,200)
			surface.SetDrawColor(Color(0,0,255,255))
			surface.DrawRect(X,Y*2,200,200)
			draw.SimpleText( "CHEATS!!11", "GM_BigNumbers", ScrH()/3,ScrH()/3, Color(255,50,0,255), 0, 0 )
			draw.SimpleText( "ваще масленок читерский", "GM_MedNumbers", 50, 0, Color(255,255,0,255), 0, 0 )
			surface.SetDrawColor(Color(255,255,255,math.random(0,250)))
			surface.SetMaterial(Material("abdul/bf4.png"))
			surface.DrawTexturedRect( 0,0,ScrW()/3,ScrH()/3)
			local X2 = 0
			local Y2 = 0
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/420noscope.png"))
			surface.DrawTexturedRect( X2,Y2,867/1.2,635/1.2)
			draw.SimpleText( "FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU", "GM_BigNumbers", X,0, Color(0,50,0,255), 0, 0 )
			draw.SimpleText( "Я АБДУЛЬ Я АБДУЛЬ", "GM_MedNumbers", X/64 + ScrW()/2,Y, Color(0,255,0,255), 0, 0 )
			local X2 = X/128
			local Y2 = ScrH()/2 + X/128
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/doritos.png"))
			surface.DrawTexturedRect( X2,Y2,420,240)	
			local X2 = ScrW()/2
			local Y2 = 0
			surface.SetMaterial(Material("abdul/callofduty.png"))
			surface.DrawTexturedRect( X2,Y2,322,241)
		elseif text == "1337xLUDICROUSx228 KILL" or text == "MASLOTERMINATOR" then
			vicface_int = vicface_int + 1/2
			local X = math.sin(vicface_int)*ScrW()
			local Y = math.cos(vicface_int)*ScrH()/3
			draw.SimpleText( "читсы офф", "GM_MedNumbers", 50, 0, Color(255,255,0,255), 0, 0 )
			draw.SimpleText( "масленок блин ваще", "GM_MedNumbers", 50, ScrH()/2, Color(255,255,0,255), 0, 0 )
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/watchdogs.png"))
			surface.DrawTexturedRect( ScrW()/3,ScrH()/3,219,157)	
			local X2 = ScrW() - 400 + math.Rand(0,50)
			local Y2 = ScrH() - 200 + math.Rand(0,50)
			surface.SetMaterial(Material("abdul/battlefield.png"))
			local X2 = ScrW()/3
			local Y2 = 0
			surface.SetMaterial(Material("abdul/face4.png"))
			surface.DrawTexturedRect( ScrW()/1.5 + X/228,Y/228,309/1.2,383/1.2)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/evilface.png"))
			surface.DrawTexturedRect( X,0,184 + math.random(0,500),184 + math.random(0,500))
			draw.SimpleText( "228 SWAG"..math.random(0,5), "GM_BigNumbers", ScrW()/2 , ScrH() - 128, Color(0,255,0,255), 0, 0 )
			surface.SetMaterial(Material("abdul/yougotfrag.png"))
			surface.DrawTexturedRect( 20 + X,20 - Y,586/1.2,552/1.2)
			local X2 = ScrW()/2
			local Y2 = 0
			surface.SetMaterial(Material("abdul/callofduty.png"))
			surface.DrawTexturedRect( X2,Y2,322,241)
			local X2 = ScrW()/5
			local Y2 = 120
			surface.SetDrawColor(Color(255,255,255,100))
			surface.SetMaterial(Material("abdul/number1.png"))
			surface.DrawTexturedRect( X2 + X/228,Y2,806/1.2,428/1.2)	
			for i=1,10 do
				surface.SetDrawColor(Color(math.random(0,1)*255,math.random(0,1)*255,math.random(0,1)*255,255))
				surface.DrawRect(X,Y*math.random(-50,50),200,200)
			end
			draw.SimpleText( "РГБ КВАДРАТИКИ ХЕЛП", "GM_BigNumbers", ScrW()/4, ScrH()/2, Color(255,0,0,255), 0, 0 )
			local X2 = ScrW()/3
			local Y2 = 0
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/coolface2.png"))
			surface.DrawTexturedRect( 0,ScrH()/5,201/1.1,315/1.1)
		elseif text == "HEADSHOT" then
			local X2 = 0
			local Y2 = 0
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/420noscope.png"))
			surface.DrawTexturedRect( X2,Y2,867/1.2,635/1.2)	
		end
		
	end
	local function Test( killtext )
		Epilepsy( killtext )
		local x = ScrW()/2
		local y = ScrH()/4.5
		x = x + math.Rand(-8,8)
		y = y + math.Rand(-8,8)
		DrawShadowText( killtext, "GM_EliteNumbers", x, y, Color(255,0,0,150), 1, 0 )
		x = ScrW()/2
		y = ScrH()/4.5
		DrawShadowText( killtext, "GM_EliteNumbers", x, y, Color(255,0,0,255), 1, 0 )
	end
	local function KillstreaksHUD()
		//Test( "KILLING SPREE" )
		if HintShow then
			if NextHintTime > CurTime() then
				Epilepsy( killtext )
				local x = ScrW()/2
				local y = ScrH()/4.5
				x = x + math.Rand(-8,8)
				y = y + math.Rand(-8,8)
				DrawShadowText( killtext, "GM_EliteNumbers", x, y, Color(255,0,0,150), 1, 0 )
				x = ScrW()/2
				y = ScrH()/4.5
				DrawShadowText( killtext, "GM_EliteNumbers", x, y, Color(255,0,0,255), 1, 0 )
			else
				HintShow = false
				killtext = ""
				killsound = ""
				NextHintTime = 0
			end
		end
	end
	hook.Add("HUDPaint","KILLSTREAKS",KillstreaksHUD)
end

