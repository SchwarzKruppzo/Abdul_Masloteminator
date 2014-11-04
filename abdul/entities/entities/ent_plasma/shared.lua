ENT.Type = "anim"
ENT.RenderGroup 		= RENDERGROUP_BOTH
if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		
	end
	function ENT:DrawTranslucent()
	/*
		print(1)
		local LightNrm = self.Entity:GetAngles():Forward()
		local ViewNormal = self.Entity:GetPos() - EyePos()
		local Distance = ViewNormal:Length()
		ViewNormal:Normalize()
		local ViewDot = 1
		local LightPos = self.Entity:GetPos() + LightNrm * 5
		if ( ViewDot >= 0 ) then
		
			
			local Visibile	= util.PixelVisible( LightPos, 8, self.Entity.PixVis )	
			
			if (!Visibile) then return end
			local Size = math.Clamp( Distance * Visibile * ViewDot * 2, 64, 1256 )
			local Size2 = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 150 )
			local Size3 = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 128 )
			local Size4 = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 1512 )
			local Size5 = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 1024 )
			Distance = math.Clamp( Distance, 32, 800 )
			local Alpha = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 255 )
			local Alpha2 = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 200 )
			local Alpha3 = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 70 )
			render.SetMaterial( Material("sprites/heatwave"))
			render.DrawSprite( LightPos, Size3,Size3/1.5, Color(30,20,0,Alpha))	
			render.SetMaterial( Material("sprites/light_ignorez"))
			render.DrawSprite( LightPos, Size*5, Size*5, Color(255, 255, 255, Alpha3/3), Visibile * ViewDot )
			render.DrawSprite( LightPos, Size, Size, Color(255, 180, 120, Alpha3), Visibile * ViewDot )
			render.DrawSprite( LightPos, Size*2, Size*0.4, Color(255, 180, 120, Alpha3), Visibile * ViewDot )
			render.DrawSprite( LightPos, Size2,Size2, Color(255,0,0,Alpha2))
			render.DrawSprite( LightPos, Size3,Size3, Color(255,150,0,Alpha2))
			render.DrawSprite( LightPos, Size3,Size3, Color(255,255,255,Alpha))
			render.DrawSprite( LightPos, Size2,Size2, Color(255,5,20,Alpha))
			render.DrawSprite( LightPos, Size4,Size2, Color(100,100,100,Alpha))
			render.DrawSprite( LightPos, Size5,Size5, Color(30,20,0,Alpha))	
			
			render.SetMaterial( Material("sprites/light_ignorez"))
		end
		*/
	end
	
	function ENT:Initialize()
		local pos = self.Entity:GetPos()
		self.Entity.emitter = ParticleEmitter( pos )
		self.Entity.PixVis = util.GetPixelVisibleHandle()
		
		self.dynlight = DynamicLight(self:EntIndex())
		self.dynlight.Pos = self:GetPos()
		self.dynlight.Size = 512
		self.dynlight.Decay = 1
		self.dynlight.R = 100
		self.dynlight.G = 255
		self.dynlight.B = 150
		self.dynlight.Brightness = 3
		self.dynlight.DieTime = CurTime()+0.1
	end
 
	function ENT:Think()
		self.dynlight.Pos = self:GetPos()
		self.dynlight.DieTime = CurTime()+0.1
		local pos = self.Entity:GetPos()
		for i=0, (6) do
			local particle = self.Entity.emitter:Add( "effects/select_ring", pos )
			if (particle) then
				particle:SetVelocity(self:GetForward()*1200 )
				particle:SetLifeTime(0)
				particle:SetDieTime( 0.3 )
				particle:SetStartAlpha( math.Rand(4,64) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 12 )
				particle:SetEndSize( 32 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 0 , 250 , 150 ) 
				particle:SetAirResistance( 300 ) 
				particle:SetGravity( Vector( 0, 0, 0 ) ) 	
			end
		end
		for i=0, (5) do
			local particle = self.Entity.emitter:Add( "effects/select_ring", pos )
			if (particle) then
				particle:SetVelocity(self:GetForward()*500 )
				particle:SetLifeTime(0)
				particle:SetDieTime( 0.1 )
				particle:SetStartAlpha( math.Rand(4,64) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 12 )
				particle:SetEndSize( 64 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 0 , 50 , 250 ) 
				particle:SetAirResistance( 300 ) 
				particle:SetGravity( Vector( 0, 0, 0 ) ) 	
			end
		end
		for i=0, (1) do
			local particle = self.Entity.emitter:Add( "effects/fire_cloud"..math.random(1,2), pos )
			if (particle) then
				particle:SetVelocity(self:GetForward()*1200  + VectorRand()*128)
				particle:SetLifeTime(0)
				particle:SetDieTime( 0.5 )
				particle:SetStartAlpha( math.Rand(4,64) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 16 )
				particle:SetEndSize( 32 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 160 , 120 , 255 ) 
				particle:SetAirResistance( 300 ) 
				particle:SetGravity( Vector( 0, 0, 0 ) ) 	
			end
		end
		for i=0, (1) do
			local particle = self.Entity.emitter:Add( "effects/fire_cloud"..math.random(1,2), pos )
			if (particle) then
				particle:SetVelocity(self:GetForward()*200  + VectorRand()*528)
				particle:SetLifeTime(0)
				particle:SetDieTime( 0.9 )
				particle:SetStartAlpha( math.Rand(4,4) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize(64 )
				particle:SetEndSize( 32 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 100, 255 , 255 ) 
				particle:SetAirResistance( 300 ) 
				particle:SetGravity( Vector( 0, 0, 0 ) ) 	
			end
		end
		for i=0, (1) do
			local particle = self.Entity.emitter:Add( "effects/fire_cloud"..math.random(1,2), pos - self:GetForward()*55 )
			if (particle) then
				particle:SetVelocity(self:GetForward()*200  + VectorRand()*64)
				particle:SetLifeTime(0)
				particle:SetDieTime( 0.5 )
				particle:SetStartAlpha( math.Rand(4,24) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 32 )
				particle:SetEndSize( 64 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 5 ,123 , 90 ) 
				particle:SetAirResistance( 300 ) 
				particle:SetGravity( Vector( 0, 0, 0 ) ) 	
			end
		end
		self.Entity:NextThink( CurTime( ) )
		return true
	end
	local alpha = 0
	hook.Add("HUDPaint","PlasmaDamage",function()
		alpha = alpha - 5/1
		alpha = math.Clamp(alpha,0,255)
		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(120,255,150,alpha) )
	end)
	local function PlasmaDamage()
		alpha = 255
	end
	usermessage.Hook( "PlasmaDamage", PlasmaDamage )
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/weapons/w_missile_launch.mdl" )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity.velocity = (self.Entity:GetForward() *2)*14
		self.Entity:SetNoDraw(true)
		self:Think()
	end
	function ENT:DoExplode( trace )
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetNormal( trace.HitNormal )
		util.Effect( "plasma_explosion", effectdata )
		self.Entity:EmitSound(Sound("weapons/mortar/mortar_explode1.wav"),100,80)
		self.Entity:EmitSound(Sound("/ambient/explosions/explode_"..tostring(math.random(7,9))..".wav"),85,100)
		local wep = self.Entity.ThowBy:GetActiveWeapon() and self.Entity
		for k,v in pairs( ents.FindInSphere( self.Entity:GetPos(), 160 ) ) do
			if IsValid(v) then
				if v:IsPlayer() then
					if v == self.Entity.ThowBy then continue end
					if v:GetNWString("CTeam") != "" then
						if v:GetNWString("CTeam") == self.Entity.ThowBy:GetNWString("CTeam") then 
							continue
						end
					end
					v:SetPlasmaEffect( self.Entity.ThowBy )
					local dmginfo = DamageInfo()
					dmginfo:SetDamage(10)
					dmginfo:SetDamageType(DMG_ENERGYBEAM)
					dmginfo:SetAttacker(self.Entity.ThowBy)
					dmginfo:SetInflictor(self)
					dmginfo:SetDamagePosition( self.Entity:GetPos() )
					if self.Entity.ThowBy:HasPowerUp( "QuadDamage" ) then
						dmginfo:ScaleDamage( 3 )
					end
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	end
	function ENT:Think()
		if !IsValid(self.Entity) then self.Entity:Remove() end
		local pos = self.Entity:GetPos()
		local ang = self.Entity:GetAngles()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos + self.Entity.velocity + self.Entity:GetForward()*12
		tracedata.mask = MASK_SHOT
		tracedata.filter = { self.Entity, self.Entity:GetOwner() }
		local trace = util.TraceLine(tracedata)
		if trace.Hit then
			local Pos1 = trace.HitPos + trace.HitNormal
			local Pos2 = trace.HitPos - trace.HitNormal
			util.Decal("scorch", Pos1, Pos2)
			self.Entity:DoExplode( trace )
			self.Entity:Remove()
		else
			self.Entity.Entity:SetPos(self.Entity:GetPos() + self.Entity.velocity)
		end
		self.Entity.velocity = self.Entity.velocity - self.Entity.velocity/14 + self.Entity:GetForward()
		self.Entity:NextThink( CurTime( ) )
		return true
	end
	
	local meta = FindMetaTable("Player")
	function meta:SetPlasmaEffect( ent )
		if !IsValid( ent ) then return end
		
		self.PlasmaEffects = self.PlasmaEffects or {}
		self.PlasmaEffects[ ent ] = { 
			nextPlasmaDamage = CurTime() + 1,
			maxPlasmaDamage = CurTime() + 6,
		}
	end
	
	hook.Add("PlayerTick","PlasmaDamage",function( ply )
		if !ply:Alive() then
			ply.PlasmaEffects = {}
		end
		for k,v in pairs(ply.PlasmaEffects) do
			if !IsValid(k) then 
				ply.PlasmaEffects[k] = nil
			end
			if v.maxPlasmaDamage > CurTime() then
				if v.nextPlasmaDamage < CurTime() then	
					umsg.Start( "PlasmaDamage", ply)
					umsg.End()
					local dmgent = ents.Create("dmg_plasma")
					dmgent:SetPos(ply:GetPos())
					dmgent:Spawn()
					local dmginfo = DamageInfo()
					dmginfo:SetDamage(math.random(3,7))
					dmginfo:SetDamageType(DMG_ENERGYBEAM)
					dmginfo:SetAttacker(k)
					dmginfo:SetInflictor(dmgent)
					dmginfo:SetDamagePosition( ply:GetPos() )
					if k:HasPowerUp( "QuadDamage" ) then
						dmginfo:ScaleDamage( 3 )
					end
					ply:TakeDamageInfo(dmginfo)
					dmgent:Remove()
					v.nextPlasmaDamage = CurTime() + 1
				end
			end
		end
	end)
end