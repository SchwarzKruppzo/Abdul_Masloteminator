Define_PowerUps = {}
Define_PowerUps["QuadDamage"] = "ent_quaddamage"
Define_PowerUps["Regeneration"] = "ent_regeneration"
Define_PowerUps["Invisibility"] = "ent_invisibility"

local meta = FindMetaTable("Player")
function meta:HasPowerUp( str )
	if !Define_PowerUps[ str ] then return end
	return self:GetNWBool( "PU_Has"..str)
end
function meta:PowerUpTime( str )
	if !Define_PowerUps[ str ] then return end
	return self:GetNWFloat( "PU_Time"..str)
end
function meta:IsBerserk()
	return self:GetNWBool( "IsBerserk" )
end
function meta:HasPowerUpAlready()
	for k,v in pairs( Define_PowerUps ) do
		if GetGlobalEntity( "PU_USER_"..k ) == self then
			return true
		end
	end
end
function meta:DropPowerUp()
	for z,x in pairs( Define_PowerUps ) do
		if self:HasPowerUp( z ) then
			local ent = ents.Create( x )
			ent:SetPos(self:GetPos() + self:GetUp() * 15 + self:GetForward() * 2)
			ent:Spawn()
			ent.DefaultTime = self:PowerUpTime( z ) - CurTime()
			ent.NoRespawn = true
			ent.DieTime = self:PowerUpTime( z )
			ent.NextPickup[self] = CurTime() + 3 // so if you dropped a powerup and takes new, you can't pickup old powerup for 3 seconds
			PU_ResetPowerUpUser( z )
		end
	end
end
if SERVER then
	for k,v in pairs( Define_PowerUps ) do
		SetGlobalEntity( "PU_USER_"..k, GetGlobalEntity( "PU_USER_"..k ) or nil )
	end
	function PU_GetPowerUpEntities( str )
		if !Define_PowerUps[ str ] then return end
		for k,v in pairs( ents.GetAll() ) do
			if IsValid(v) then
				if v:GetClass() == Define_PowerUps[ str ] then
					if v.NoRespawn then
						return true
					end
				end
			end
		end
	end
	function PU_CanSpawnPowerUp( str )
		if !IsValid(GetGlobalEntity( "PU_USER_"..str )) and !PU_GetPowerUpEntities( str ) then
			return true
		end
	end
	function PU_SetPowerUp( str, user, time )
		if !Define_PowerUps[ str ] then return end
		if IsValid(user) then
			if user:IsPlayer() then
				user:SetNWBool( "PU_Has"..str, true )
				user:SetNWFloat( "PU_Time"..str, CurTime() + time )
				user.PU_RegenerationT = 0 // for Regeneration
				SetGlobalEntity( "PU_USER_"..str, user )
			end
		end
	end
	function PU_ResetPowerUpUser( str )
		if !Define_PowerUps[ str ] then return end
		for k,v in pairs( player.GetAll() ) do
			for z,x in pairs(v:GetWeapons()) do
				x:SetRenderMode(RENDERMODE_NORMAL)
				x:SetColor( Color(255, 255, 255, 255 ) )
				x:DrawShadow( true )
			end
			v:SetRenderMode(RENDERMODE_NORMAL)
			v:SetColor( Color(255, 255, 255, 255 ) )
			v:DrawShadow( true )
			v:SetNWBool( "PU_Has"..str, false )
			v:SetNWFloat( "PU_Time"..str, 0 )
		end
		SetGlobalEntity( "PU_USER_"..str, NULL )
	end
	function PU_ResetPowerUpUserAll()
		for z,x in pairs( Define_PowerUps ) do
			for k,v in pairs( player.GetAll() ) do
				v:SetNWBool( "PU_Has"..z, false )
				v:SetNWFloat( "PU_Time"..z, 0 )
			end
			SetGlobalEntity( "PU_USER_"..z, NULL )
		end
	end
	local function Think()
		for k,v in pairs( player.GetAll() ) do
			for z,x in pairs( Define_PowerUps ) do
				if v:HasPowerUp( z )and v:PowerUpTime( z ) and v == GetGlobalEntity( "PU_USER_"..z ) then
					if CurTime() > v:PowerUpTime( z ) or v:IsSpectator() then
						PU_ResetPowerUpUser( z )
					end
				end
			end
		end
	end
	local function RegThink()
		for k,v in pairs( player.GetAll() ) do
			if v:HasPowerUp( "Regeneration" )and v:PowerUpTime( "Regeneration" ) and v == GetGlobalEntity( "PU_USER_Regeneration" ) then
				if CurTime() >= (v.PU_RegenerationT or 0) then
					v:SetHealth( math.Clamp(v:Health() + 5,0,100) )
					v.PU_RegenerationT = CurTime() + 2
				end
			end
			if v:HasPowerUp( "Invisibility" ) then
				for z,x in pairs(v:GetWeapons()) do
					x:SetRenderMode(RENDERMODE_NONE)
					x:SetColor( Color(255, 255, 255, 0 ) )
					x:DrawShadow( false )
				end
			
				v:SetRenderMode(RENDERMODE_NONE)
				v:SetColor( Color(255, 255, 255, 0 ) )
				v:DrawShadow( false )
			end
			

		end
	end
	local function ScalePlayerDamage( ply, hitgroup, dmginfo )
		if ply:HasPowerUp( "QuadDamage" ) and ply == GetGlobalEntity( "PU_USER_QuadDamage" ) then
			dmginfo:ScaleDamage( 3 )
		end
	end
	local function EntityTakeDamage(target, dmginfo, ply, hitgroup)
		if not dmginfo:GetAttacker():IsPlayer() then return end
		local attacker = dmginfo:GetAttacker()
		if target:IsValid() then
			if attacker == target then return end
			if (attacker:IsPlayer()) and target:Health() > 0 then
				if target:Health() < 15 then
					if math.random(1,4) == 2 then
						target:AbdulVoice( "abdul/critical/critical"..tostring(math.random(1,2))..".wav" )
					end
				end
				if attacker:HasPowerUp( "QuadDamage" )  then
					sound.Play("abdul/quad.wav", attacker:GetPos(), 80, 100, 1 )
				end
			end
		end
	end
	local function DoPlayerDeath( ply, attacker, dmg )
		ply:DropPowerUp()
	end
	hook.Add("Think","PU_Think",Think)
	hook.Add("Think","PU_REGENERATION_Think",RegThink)
	hook.Add("ScalePlayerDamage","PU_ScalePlayerDamage",ScalePlayerDamage)
	hook.Add("EntityTakeDamage","PU_EntityTakeDamage",EntityTakeDamage)
	hook.Add("DoPlayerDeath","PU_DoPlayerDeath",DoPlayerDeath)
	
	function GM:PlayerPickupPowerup( ply, class )
		net.Start( "GM_Pickup" )
			net.WriteString( class )
		net.Send( ply )
	end
else
	local rt_Store		= render.GetScreenEffectTexture( 0 )

	local function RenderQuad()
		local OldRT = render.GetRenderTarget()
		render.CopyRenderTargetToTexture( rt_Store )
		cam.Start3D( EyePos(), EyeAngles() )
			cam.IgnoreZ( false )
			render.OverrideDepthEnable( true, false )
			render.SetStencilEnable( true )
			render.SetStencilFailOperation( STENCILOPERATION_KEEP )
			render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
			render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
			render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
			render.SetStencilWriteMask( 1 )
			render.SetStencilReferenceValue( 1 )
			render.SetBlend( 0 )
			for k, v in pairs( player.GetAll() ) do
				if !IsValid( v ) then continue end
				if !IsValid( v:GetActiveWeapon() ) then continue end
				if !v:HasPowerUpAlready() then continue end
				if v:HasPowerUp("Invisibility") then continue end
				
				v:DrawModel()
				v:GetActiveWeapon():DrawModel()
			end
		cam.End3D()	
		
		cam.Start3D( EyePos(), EyeAngles() )
			for i = 0, 15 do
				render.MaterialOverride( Material( "models/debug/debugwhite" ) )
				
				cam.IgnoreZ( false )
				
				render.SetStencilEnable( true )
				render.SetStencilWriteMask( 0 )
				render.SetStencilReferenceValue( 0 )
				render.SetStencilTestMask( 1 )
				render.SetStencilFailOperation( STENCILOPERATION_KEEP )
				render.SetStencilPassOperation( STENCILOPERATION_KEEP )
				render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
				render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL )
				
				for k, v in pairs( player.GetAll() ) do
					if !IsValid( v ) then continue end
					if !IsValid( v:GetActiveWeapon() ) then continue end
					if !v:HasPowerUpAlready() then continue end
					if v:HasPowerUp("Invisibility") then continue end
					
					local r,g,b = 0,0,0
					if v:HasPowerUp( "QuadDamage" ) then
						r = 0
						g = 0.5
						b = 1
					elseif v:HasPowerUp( "Regeneration" ) then
						r = 0
						g = 1
						b = 0
					end
					render.SetColorModulation( r, g, b )
					render.SetBlend( 0.3 )
					v:DrawModel()
					v:GetActiveWeapon():DrawModel()
				end
					
				render.MaterialOverride( nil )
				render.SetStencilEnable( false )
			end
			for i = 0, 15 do
				render.MaterialOverride( Material( "models/props_combine/portalball001_sheet" ) )
				
				cam.IgnoreZ( false )
				
				render.SetStencilEnable( true )
				render.SetStencilWriteMask( 0 )
				render.SetStencilReferenceValue( 0 )
				render.SetStencilTestMask( 1 )
				render.SetStencilFailOperation( STENCILOPERATION_KEEP )
				render.SetStencilPassOperation( STENCILOPERATION_KEEP )
				render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
				render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL )
				
				for k, v in pairs( player.GetAll() ) do
					if !IsValid( v ) then continue end
					if !IsValid( v:GetActiveWeapon() ) then continue end
					if !v:HasPowerUpAlready() then continue end
					if v:HasPowerUp("Invisibility") then continue end
					
					local r,g,b = 0,0,0
					if v:HasPowerUp( "QuadDamage" ) then
						r = 0
						g = 0.6
						b = 1
					elseif v:HasPowerUp( "Regeneration" ) then
						r = 0
						g = 1
						b = 0
					end
					render.SetColorModulation( r, g, b )
					render.SetBlend( 1 )
					v:DrawModel()
					v:GetActiveWeapon():DrawModel()
					
				end
					
				render.MaterialOverride( nil )
				render.SetStencilEnable( false )
			end
		cam.End3D()
		render.SetRenderTarget( OldRT )
		render.SetColorModulation( 1, 1, 1 )
		render.SetStencilEnable( false )
		render.SetStencilWriteMask( 0 )
		render.SetStencilReferenceValue( 0 )
		render.SetStencilTestMask( 0 )
		render.SetStencilEnable( false )
		render.OverrideDepthEnable( false )
		

		render.SetBlend( 1 )
	end
	local function Think()
		for k,v in pairs( player.GetAll() ) do
			if v:HasPowerUpAlready() or v:IsBerserk() then
				local r,g,b = 0,0,0
				if v:HasPowerUp( "QuadDamage") then
					r = 0
					g = 100
					b = 255
				elseif v:HasPowerUp( "Regeneration") then
					r = 0
					g = 255
					b = 0
				elseif v:IsBerserk() then
					r = 255
					g = 0
					b = 0
				end
				v.QuadLight = DynamicLight(v:EntIndex())
				v.QuadLight.Pos = v:GetPos() + v:GetUp()* 32
				v.QuadLight.Size = 128
				v.QuadLight.R = r
				v.QuadLight.G = g
				v.QuadLight.B = b
				v.QuadLight.Decay = 2
				v.QuadLight.Brightness = 6
				v.QuadLight.DieTime = CurTime() + 0.1
			else
				if IsValid(v.QuadLight) then v.QuadLight:Remove() end
			end
		end
	end
	local DrawPoly = surface.DrawPoly
	local SetDrawColor = surface.SetDrawColor
	surface.CreateFont("GM_Small2Numbers",{
		font = "Calibri",
		size = (ScrW() - (ScrW() - ScrW() + (ScrW() - ScrH() / 7)))/2.6,
		weight = 1000,
		antialias = true
	})
	local function HUD()
		if LocalPlayer():IsSpectator() then return end
		local x,y = ScrW() - ScrW() + (ScrW() - ScrH() / 7), ScrH() / 1.28
		local size = (ScrW() - (ScrW() - ScrW() + (ScrW() - ScrH() / 7)))
		local m_w,m_h = GetTextWidth( "60", "GM_Small2Numbers" )
		
		surface.SetDrawColor(Color(0,0,0,90))
		surface.DrawRect( x,y,size,size/2 + 10)
		surface.SetDrawColor(Color(0,0,0,90))
		surface.DrawRect( x + 5,y + 5,size/2,size/2)
		
		if LocalPlayer():HasPowerUp( "QuadDamage" ) then
			surface.SetDrawColor(Color(0,200,255,50))
			surface.DrawRect( x + 5,y + 5,size/2 + 1,size/2 + 1)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/ico_quad.png"))
			surface.DrawTexturedRect( x + 5,y + 5,size/2 + 1,size/2 + 1)
			
			local time = math.floor(LocalPlayer():PowerUpTime( "QuadDamage" ) -  CurTime())
			time = math.Clamp(time,0,70)
			draw.SimpleText( time, "GM_Small2Numbers", x + 10 + size/2, y + 10, Color(255,255,255,255), 0, 0 )
		elseif LocalPlayer():HasPowerUp( "Regeneration" ) then
			surface.SetDrawColor(Color(0,255,0,50))
			surface.DrawRect( x + 5,y + 5,size/2 + 1,size/2 + 1)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/ico_regen.png"))
			surface.DrawTexturedRect( x + 5,y + 5,size/2,size/2)
			
			local time = math.floor(LocalPlayer():PowerUpTime( "Regeneration" ) -  CurTime())
			time = math.Clamp(time,0,70)
			draw.SimpleText( time, "GM_Small2Numbers", x + 10 + size/2, y + 10, Color(255,255,255,255), 0, 0 )
		elseif LocalPlayer():HasPowerUp( "Invisibility" ) then
			surface.SetDrawColor(Color(255,255,255,50))
			surface.DrawRect( x + 5,y + 5,size/2 + 1,size/2 + 1)
			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(Material("abdul/ico_invis.png"))
			surface.DrawTexturedRect( x + 5,y + 5,size/2 + 1,size/2 + 1)
			
			local time = math.floor(LocalPlayer():PowerUpTime( "Invisibility" ) -  CurTime())
			time = math.Clamp(time,0,70)
			draw.SimpleText( time, "GM_Small2Numbers", x + 10 + size/2, y + 10, Color(255,255,255,255), 0, 0 )
		end
	end
	hook.Add("HUDPaint","PU_HUD",HUD)
	hook.Add("Think","PU_Think",Think)
	hook.Add("PostDrawEffects","PU_PostDrawEffects",function() RenderQuad() end)
	hook.Add("PreDrawViewModel","PU_PreDrawViewModel",function()
		if LocalPlayer():HasPowerUp( "QuadDamage" ) then
			render.SetColorModulation( 0, 0.6, 1 )
			render.MaterialOverride( Material( "models/props_combine/portalball001_sheet" ) )
		elseif LocalPlayer():HasPowerUp( "Invisibility" ) then
			render.SetBlend(0.5)
		end
	end)
end