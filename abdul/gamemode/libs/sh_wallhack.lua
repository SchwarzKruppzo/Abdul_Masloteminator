if CLIENT then
	local whstate = whstate or false
	net.Receive( "WallCheats228Award", function( len )
		whstate = tobool(net.ReadString())
	end)
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
	local function HUDWH()
		if !whstate then return end
		for _,v in pairs(player.GetAll()) do
			tracedata.start = LocalPlayer():GetShootPos()
			tracedata.endpos = v:GetPos()+v:OBBCenter()
			if v == LocalPlayer() then continue end
			if v:GetNWString("CTeam") != "" then
				if v:GetNWString("CTeam") == LocalPlayer():GetNWString("CTeam") then continue end
			end
			if v:IsSpectator() then continue end
			if !v:Alive() then continue end
			func_DrawName(v, Color(230,100, 100))
		end
	end
	hook.Add("HUDPaint","WallHackScan",HUDWH)
else
	util.AddNetworkString( "WallCheats228Award" )
	local meta = FindMetaTable("Player")
	function meta:WallHack( t, n )
		net.Start("WallCheats228Award")
			net.WriteString( tostring(t) )
		net.Send( self )
		
		if t then
			self:SetNWBool("WHUsing",true)
			self.NextWallHackScan = CurTime() + 40
		else
			self:SetNWBool("WHUsing",false)
			self.NextWallHackScan = nil
		end
		if n then
			if t then
				for k,v in pairs(player.GetAll()) do
					if v == self then continue end
					if self:GetNWString("CTeam") != "" then
						if self:GetNWString("CTeam") == v:GetNWString("CTeam") then continue end
					end
					Notify( v, Color(255,255,255),"-Обнаружен вражеский сканер карты." )
				end
				Notify( self, Color(255,255,255),"-Сканирование карты в действии на 40 секунд." )
			else
				for k,v in pairs(player.GetAll()) do
					if v == self then continue end
					if self:GetNWString("CTeam") != "" then
						if self:GetNWString("CTeam") == v:GetNWString("CTeam") then continue end
					end
					Notify( v, Color(255,255,255),"-Вражеский сканер не обнаружен." )
				end
				Notify( self, Color(255,255,255),"-Сканирование карты завершено." )
			end
		end
		
	end
	hook.Add("Think","_WHRemove",function()
		for k,v in pairs(player.GetAll()) do
			if v:GetNWBool("WHUsing") then
				if v.NextWallHackScan then
					if CurTime() > v.NextWallHackScan then
						v:WallHack( false, true )
					end
				end
			end
		end
	end)
end