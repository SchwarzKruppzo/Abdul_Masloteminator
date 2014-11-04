ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
if CLIENT then
	function ENT:Draw()
		cam.Start3D(EyePos(),EyeAngles())
			render.SetMaterial( Material("sprites/light_glow02_add") )
			render.DrawSprite( self:GetPos() - self:GetForward(),32,32, Color(0,200,255,200))
			render.DrawSprite( self:GetPos() - self:GetForward(), 16,16, Color(255,255,255,200))
		cam.End3D()
	end
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/error.mdl" )
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_NONE)
		self.Entity:SetSolid(SOLID_NONE)
		self.Entity:DrawShadow(false)
		self.Entity.Trail = util.SpriteTrail(self.Entity, 0, Color(0,200,255), false, 32, 1, 0.5, 1/(15+1)*0.5, "trails/laser.vmt")
		self.velocity = self.Entity:GetForward()*((180*52.5)/66)
		self:Think()
	end
	function ENT:DoExplode( trace, ent )
		
		local impact = EffectData()
		impact:SetEntity(self.Entity)
		impact:SetOrigin(trace.HitPos)
		impact:SetNormal(trace.HitNormal)
		netEffect( "pulse_impact", impact )
		
		self.Entity:EmitSound(Sound("weapons/stunstick/alyx_stunner"..tostring(math.random(1,2))..".wav"),80,math.random(50,130))
		local wep = self.Entity.ThowBy:GetActiveWeapon()
		if IsValid(ent) then
			if ent:IsPlayer() then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(math.random(5,15))
				dmginfo:SetDamageType(DMG_ENERGYBEAM)
				dmginfo:SetAttacker(self.Entity.ThowBy)
				dmginfo:SetInflictor(wep or self)
				dmginfo:SetDamagePosition( trace.HitPos )
				if self.Entity.ThowBy:HasPowerUp( "QuadDamage" ) then
					dmginfo:ScaleDamage( 4 )
				end
				ent:TakeDamageInfo(dmginfo)
			end
		end
	end
	function ENT:Think()
		for k,v in pairs( ents.FindInSphere( self.Entity:GetPos(), 40 ) ) do
			if IsValid(v) then
				if v:IsPlayer() then
					if v == self.Entity.ThowBy then continue end
					if v:Alive() then
						local wep = self.Entity.ThowBy:GetActiveWeapon() or self.Entity
						v:TakeDamage( math.random(1,3), self.Entity.ThowBy, wep )
					end
				end
			end
		end
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
			netDecal("fadingscorch", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
			self.Entity:DoExplode( trace, trace.Entity )
			self:Remove()
			return true
		end
		self.Entity:SetPos(self.Entity:GetPos() + self.velocity)
		//self.velocity = self.Entity.velocity - self.velocity/64 + self.Entity:GetForward()*2
		self.velocity = self.velocity - self.velocity/70 + (VectorRand():GetNormalized()*0.25) + Vector(0,0,-0.0025)

		self.Entity:NextThink( CurTime( ) )
		return true
	end
end