ENT.Type = "anim"
ENT.RenderGroup 		= RENDERGROUP_BOTH
function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Style" )
end
if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		
	end
	local colortable = {}
	
	function ENT:DrawTranslucent()
		local graphic = 2
		if GetConVar("abdulgraphic_rocket"):GetInt() == 0 then
			graphic = 0
		elseif GetConVar("abdulgraphic_rocket"):GetInt() == 2 then
			graphic = 2
		elseif GetConVar("abdulgraphic_rocket"):GetInt() == 1 then
			graphic = 1
		end
	
	
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
			if graphic == 2 then render.DrawSprite( LightPos, Size3,Size3/1.5, Color(30,20,0,Alpha)) end
			render.SetMaterial( Material("sprites/light_ignorez"))
			if self.Entity:GetStyle() != "blue" then
				if graphic == 2 or graphic == 1 then render.DrawSprite( LightPos, Size*5, Size*5, Color(255, 255, 255, Alpha3/3), Visibile * ViewDot ) end
				if graphic == 2 then
					render.DrawSprite( LightPos, Size, Size, Color(255, 180, 120, Alpha3), Visibile * ViewDot )
					render.DrawSprite( LightPos, Size*2, Size*0.4, Color(255, 180, 120, Alpha3), Visibile * ViewDot )
					render.DrawSprite( LightPos, Size2,Size2, Color(255,0,0,Alpha2))
				end
				render.DrawSprite( LightPos, Size3,Size3, Color(255,150,0,Alpha2))
				render.DrawSprite( LightPos, Size3,Size3, Color(255,255,255,Alpha))
				render.DrawSprite( LightPos, Size2,Size2, Color(255,5,20,Alpha))
				if graphic >= 1 then render.DrawSprite( LightPos, Size4,Size2, Color(100,100,100,Alpha)) end
				if graphic == 2 then render.DrawSprite( LightPos, Size5,Size5, Color(30,20,0,Alpha)) end
			else
				if graphic == 2 or graphic == 1 then render.DrawSprite( LightPos, Size*5, Size*5, Color(255, 255, 255, Alpha3/3), Visibile * ViewDot ) end
				if graphic == 2 then
					render.DrawSprite( LightPos, Size, Size, Color(120, 180, 255, Alpha3), Visibile * ViewDot )
					render.DrawSprite( LightPos, Size*2, Size*0.4, Color(120, 180, 255, Alpha3), Visibile * ViewDot )
					render.DrawSprite( LightPos, Size2,Size2, Color(0,0,255,Alpha2))
				end
				render.DrawSprite( LightPos, Size3,Size3, Color(0,150,255,Alpha2))
				render.DrawSprite( LightPos, Size3,Size3, Color(255,255,255,Alpha))
				render.DrawSprite( LightPos, Size2,Size2, Color(20,5,255,Alpha))
				if graphic >= 1 then render.DrawSprite( LightPos, Size4,Size2, Color(100,100,100,Alpha)) end
				if graphic == 2 then render.DrawSprite( LightPos, Size5,Size5, Color(0,20,30,Alpha)) end
			end
			
		end
		local p  = 4
		if graphic == 1 then p = 3 elseif graphic == 0 then p = 2 end
		local pos = self.Entity:GetPos()
		for i=0, (p) do
			local particle = self.Entity.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + (self.Entity:GetForward() * -64 * i))
			if (particle) then
				particle:SetVelocity((self.Entity:GetForward() * -20) )
				particle:SetDieTime( 2 )
				particle:SetStartAlpha( math.Rand(4,64) )
				particle:SetEndAlpha( 6 )
				particle:SetStartSize( 16 )
				particle:SetEndSize( 12 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 190 , 190 , 190 ) 
				particle:SetAirResistance( 200 ) 
				particle:SetGravity( Vector( 100, 0, 0 ) ) 	
			end
		end
	end
	
	function ENT:Initialize()
		local pos = self.Entity:GetPos()
		self.Entity.emitter = ParticleEmitter( pos )
		self.Entity.PixVis = util.GetPixelVisibleHandle()
	end
 
	function ENT:Think()
		self.Entity:NextThink( CurTime( ) )
		return true
	end
	
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/weapons/w_missile_launch.mdl" )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.velocity = (self.Entity:GetForward() *2)*14
		
		self.Entity.SoundLoop = CreateSound( self.Entity, Sound("weapons/rpg/rocket1.wav"))
		self.Entity.SoundLoop:Play()
		self:Think()
	end
	
	function ENT:DoExplode( trace )
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetNormal( trace.HitNormal )
		util.Effect( "rocket_explosion", effectdata )
		self.Entity:EmitSound(Sound("weapons/mortar/mortar_explode1.wav"),100,80)
		self.Entity:EmitSound(Sound("weapons/explode"..tostring(math.random(3,5))..".wav"),70,70)
		for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),100)) do
			if v:IsPlayer() then
				
				local Pos1 = trace.HitPos + trace.HitNormal
				local Pos2 = trace.HitPos - trace.HitNormal
				v:SetVelocity(  ((Pos1/2 - Pos2/2)*280 - v:GetAimVector()*280) )
				
				local Pos = trace.HitPos
				Pos = Pos + Vector(0, 0, -32)
		
				local Force = v:GetPos() - Pos
				local Dist = Force:Length()
				Force:Normalize()
				Force = Force * math.Clamp(600 - Dist, 0, 1024)
				
				v:SetVelocity( Force)	
			end
		end
		for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),200)) do
			if v:IsPlayer() then
				net.Start("ExplosionEffect")
				net.Send(v)
			end
		end
		local wep = self.Entity.ThowBy:GetActiveWeapon() and self.Entity
		local multiple = 1
		if self.Entity.ThowBy:HasPowerUp( "QuadDamage" ) then
			multiple = 3
		end
		util.BlastDamage( wep , self.Entity.ThowBy, self.Entity:GetPos(), 160, math.random(60,100)*multiple )
		self:Remove()
	end
	function ENT:Think()
		if !IsValid(self.Entity) then self.Entity:Remove() end
		local pos = self.Entity:GetPos()
		local ang = self.Entity:GetAngles()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos + self.velocity
		tracedata.filter = { self.Entity, self.Entity.ThowBy }
		tracedata.mask 	= MASK_SHOT + MASK_WATER
		local trace = util.TraceLine(tracedata)
		if trace.Hit then
			self.Entity.SoundLoop:Stop()
			local Pos1 = trace.HitPos + trace.HitNormal
			local Pos2 = trace.HitPos - trace.HitNormal
			util.Decal("scorch", Pos1, Pos2)
			self.Entity:DoExplode( trace )
			self:Remove()
			return true
		end
		if IsValid(self.ThowBy) then
			if self.ThowBy:HasPowerUp( "QuadDamage" ) then
				self.Entity:SetStyle("blue")
			else
				self.Entity:SetStyle("red")
			end
		end
		self.Entity:SetPos(self.Entity:GetPos() + self.velocity)
		self.velocity = self.Entity.velocity - self.velocity/14 + self.Entity:GetForward()*2
		self.Entity:NextThink( CurTime( ) )
		return true
	end
end