local Define_KSAward = {}
Define_KSAward[0] = {id = "Turret", icon = "award3.png", desc = "3 KILLS REWARD: Automatic Turret", kills = 3, func = function( ply ) 
	ply:Give("abdul_turret")
	ply:SelectWeapon("abdul_turret")
	ply:SetAmmo( 1, "turrets" )
end}
Define_KSAward[1] = {id = "WH", icon = "award5.png", desc = "5 KILLS REWARD: Wall Hack for 40 seconds", kills = 5, func = function( ply ) 
	ply:WallHack( true, true )
	ply:TakeKSAward("WH")
end}
Define_KSAward[2] = {id = "Berserk", icon = "award7.png", desc = "7 KILLS REWARD: BERSERKER MODE for 1 minute", kills = 7, func = function( ply ) 
	if ply:HasPowerUpAlready() then
		ply:DropPowerUp()
	end
	ply:DoBerserk()
	ply:TakeKSAward("Berserk")
end}

local meta = FindMetaTable("Player")
function meta:HasKSAward( id )
	if !KSAward_IsExists( id ) then return end
	return self:GetNWBool("KSAward"..id)
end
function KSAward_IsExists( id )
	for k,v in pairs(Define_KSAward) do
		if v.id == id then
			return true
		end
	end
end
function KSAward_GetAward( id )
	for k,v in pairs(Define_KSAward) do
		if v.id == id then
			return Define_KSAward[k]
		end
	end
end

if CLIENT then
	surface.CreateFont("GM_IconNumbers",{
		font = "Calibri",
		size = 24,
		weight = 1000,
		antialias = true
	})
	local text = ""
	local NextHintTime = 0
	local HintShow = false
	net.Receive( "KSAward_Got", function( len )
		text = net.ReadString()
		
		NextHintTime = CurTime() + 4
		HintShow = true
	end)
	local trg = 0
	local cur = 0
	local function KillstreaksHUD()
		if LocalPlayer():IsSpectator() then return end
		local x,y = ScrW(), ScrH()/2
		local size = 64
		
		local siz = ScrW() - (ScrW()/1.052631578947368)
		local sizk = (siz/1.9)
		for k,v in pairs(Define_KSAward) do
			surface.SetDrawColor(Color(0,0,0,90))
			surface.DrawRect( x - siz,y + k*(siz/1.5 + 5),siz,siz/1.5)
			
			
			local ico_x,ico_y,ico_w,ico_h = x - siz + 5,y + 5 + k*(siz/1.5 + 5),sizk,sizk
			surface.SetDrawColor(Color(0,0,0,90))
			surface.DrawRect( ico_x, ico_y, ico_w, ico_h )
			if LocalPlayer():HasKSAward( v.id ) then
				trg = 20 + math.abs( math.sin( RealTime()*5 )*150 )
				cur = Lerp( FrameTime()*12, cur, trg )
				if cur > .1 then
					surface.SetDrawColor( 250,200,80, cur)
					surface.DrawRect( ico_x, ico_y, ico_w, ico_h )
				end
			end
			local alpha = LocalPlayer():HasKSAward( v.id ) and 255 or 20
			surface.SetDrawColor(Color(255,255,255,alpha))
			surface.SetMaterial(Material("abdul/"..v.icon))
			surface.DrawTexturedRect( ico_x, ico_y, ico_w, ico_h )
			local txt = "F2"
			if k == 1 then txt = "F3" elseif k == 2 then txt = "F4" end
			draw.SimpleText( txt, "GM_IconNumbers",  x - siz + sizk + 8,y + 5 + k*(siz/1.5 + 5) + ico_h/2.2, Color(255,255,255,255), 0, 1 )
		
		end
	
	
		if HintShow then
			if NextHintTime > CurTime() then
				local x = ScrW()/2
				local y = ScrH()/7
				DrawShadowText( text, "GM_MedNumbers", x, y, Color(250,200,80,255), 1, 0 )
			else
				HintShow = false
				text = ""
				NextHintTime = 0
			end
		end
	end
	hook.Add("HUDPaint","KILLSAWARD",KillstreaksHUD)
else
	util.AddNetworkString( "KSAward_Got" )
	
	local meta = FindMetaTable("Player")
	function meta:SetKSAward( id )	
		if !KSAward_IsExists( id ) then return end
		net.Start("KSAward_Got")
			net.WriteString( KSAward_GetAward( id ).desc )
		net.Send( self )
		self:SetNWBool("KSAward"..id, true )
	end
	function meta:TakeKSAward( id )
		if !KSAward_IsExists( id ) then return end
		self:SetNWBool("KSAward"..id, false )
	end
	function meta:UseKSAward( id )
		if !KSAward_IsExists( id ) then return end
		if !self:HasKSAward( id ) then return end
	
		self:EmitSound("buttons/blip1.wav")
		KSAward_GetAward( id ).func( self )
		//self:TakeKSAward( id )
	end
	function KSAward_SelectAward( ply, kills )
		for k,v in pairs(Define_KSAward) do
			if kills % v.kills == 0 then
				if !ply:HasKSAward( v.id ) then
					return Define_KSAward[k]
				end
			end
		end
		return {}
	end
	function KSAward_Reset()
		for k,v in pairs(Define_KSAward) do
			for z,x in pairs( player.GetAll() ) do
				if x:HasKSAward( v.id ) then
					x:TakeKSAward( v.id )
				end
			end
		end
	end
	
	function GM:ShowTeam( ply ) // Use 1 gift
		ply:UseKSAward( "Turret" )
	end
	function GM:ShowSpare1( ply ) // Use 2 gift
		ply:UseKSAward( "WH" )
	end
	function GM:ShowSpare2( ply ) // Use 3 gift
		ply:UseKSAward( "Berserk" )
	end
end