ENT.Type = "anim"
if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
	function ENT:Initialize()
		local pos = self.Entity:GetPos()
		self.Entity.emitter = ParticleEmitter( pos )
	end
 
	function ENT:Think()

		local pos = self.Entity:GetPos()
			local particle = self.Entity.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + (self.Entity:GetForward() * -64 * i))
			if (particle) then
				particle:SetVelocity((self.Entity:GetForward() * -20) )
				particle:SetDieTime( 1 )
				particle:SetStartAlpha( math.Rand(4,64) )
				particle:SetEndAlpha( 6 )
				particle:SetStartSize( 8 )
				particle:SetEndSize( 12 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-1, 1) )
				particle:SetColor( 190 , 190 , 190 ) 
				particle:SetAirResistance( 500 ) 
			end
		self.Entity:NextThink( CurTime( ) )
		return true
	end
	
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/props_lab/jar01b.mdl" )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		
	end
	function ENT:DoExplode()
		local effectdata = EffectData()
			effectdata:SetOrigin( self.Entity:GetPos() )
			effectdata:SetNormal(Vector(0,0,0))
			util.Effect( "rocket_explosion", effectdata )
		self.Entity:EmitSound(Sound("weapons/explode"..tostring(math.random(3,5))..".wav"),70,150)
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
		local sin,cos,rad = math.sin,math.cos,math.rad;
		local tmp = 0;
	local s,c;
		for i = 1, 8 do
			local X = math.sin((360/8)*i)
			local Y = math.cos((360/8)*i)
			local ent = ents.Create ("ent_shrap");
			local pos = self.Entity:GetPos() + Vector(0,0,10) + Vector(X*2,Y*2,0)
			local vecThrow;
			vecThrow = (self.Entity:GetPos() - pos) * 300;

			ent:SetPos( pos );
			ent:SetAngles( Angle(0,0,0) );
			ent:SetOwner( self.Entity.ThowBy);
			ent.ThowBy = self.Entity.ThowBy
			ent.Time = CurTime() + math.Rand(0.5,1.5)
			ent:Spawn()
			ent:Activate()
			ent:GetPhysicsObject():SetVelocity( vecThrow );
			ent:GetPhysicsObject():AddAngleVelocity( Vector(600,math.random(-1200,1200),0) );
		end
	end
	function ENT:Think()
		if self.Entity.Time <= CurTime() then
			self.Entity:DoExplode()
			self.Entity:Remove()
		end
		self.Entity:NextThink( CurTime( ) )
		return true
	end
end