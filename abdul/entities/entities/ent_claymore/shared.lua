ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
		local color = Color( 100, 0, 0 )
		local colorspr = Color( 200, 0, 0 )
		if self.Entity:GetThowBy() == LocalPlayer() then
			color = Color( 0, 100, 0 )
			colorspr = Color( 0, 200, 0 )
		end
		if LocalPlayer():GetNWString("CTeam") != "" then
			if LocalPlayer():GetNWString("CTeam") == self.Entity:GetThowBy():GetNWString("CTeam") then
				color = Color( 0, 100, 0 )
				colorspr = Color( 0, 200, 0 )
			end
		end
		render.SetMaterial( Material( "effects/laser1" ) )
		local pos = self.Entity:GetPos() + self.Entity:GetUp()*9.5 + self.Entity:GetForward() * 2.3 - self.Entity:GetRight() * 1
		local pos2 = pos - self.Entity:GetRight() * 15 + self.Entity:GetForward() * 6 + self.Entity:GetUp()
		render.DrawBeam( pos, pos2,4, 0, 0, color )	
		render.SetMaterial(Material( "sprites/light_glow02_add" ))
		render.DrawSprite( pos, 2,2,colorspr)
		render.SetMaterial( Material( "effects/laser1" ) )
		local pos = self.Entity:GetPos() + self.Entity:GetUp()*9.5 - self.Entity:GetForward() * 2.3 - self.Entity:GetRight() * 1
		local pos2 = pos - self.Entity:GetRight() * 15 - self.Entity:GetForward() * 6 + self.Entity:GetUp()
		render.DrawBeam( pos, pos2,4, 0, 0, color )	
		render.SetMaterial(Material( "sprites/light_glow02_add" ))
		render.DrawSprite( pos, 2,2,colorspr)
	end
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/w_claymore_legs.mdl" )
		self.Entity:PhysicsInitBox( Vector( -2, -5, 0 ), Vector( 2, 5, 10 ) )
		self.Entity:SetCollisionBounds( Vector( -2, -5, 0 ), Vector( 2, 5, 10 ) )
		//self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_BBOX )
		self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self.Entity.DoExp = true
	end
	
	function ENT:DoExplode( attacker )
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetNormal( Vector(0,0,0) )
		util.Effect( "claymore_explosion", effectdata )
		for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(),200)) do
			if v:IsPlayer() then
				net.Start("ExplosionEffect")
				net.Send(v)
			end
		end
		local wep = self.Entity
		local multiple = 1
		if attacker:HasPowerUp( "QuadDamage" ) then
			multiple = 3
		end
		util.BlastDamage( wep , attacker, self.Entity:GetPos(), 160, math.random(100,300)*multiple )
		self.Entity:EmitSound("weapons/shotgun/shotgun_empty.wav",80,150)
		self.Entity:GetThowBy():RemPlantLimit("Claymore")
		if self.DoExp then
			for k,v in pairs( ents.FindInSphere( self.Entity:GetPos(), 160) ) do // cheat 
				if v:GetClass() == "ent_claymore" then
					if v == self.Entity then continue end
					v.DoExp = false
					v:DoExplode( attacker )
				end
			end
		end
		self.Entity:Remove()
	end
	function ENT:Find()
		local pos = self.Entity:GetPos()
		local forward = -self.Entity:GetRight()
		local right = self.Entity:GetForward()
		local up = self.Entity:GetUp()
		local pos = self.Entity:GetPos() + up*5
		local traces = {}
		local Center = util.TraceLine({
			start = pos,
			endpos = pos + forward*130,
			filter = self.Entity
		})
		table.insert(traces,Center)
		local Right = util.TraceLine({
			start = pos,
			endpos = pos + forward*100 + right*55,
			filter = self.Entity
		})
		table.insert(traces,Right)
		local Left = util.TraceLine({
			start = pos,
			endpos = pos + forward*100 - right*55,
			filter = self.Entity
		})
		table.insert(traces,Left)
		local Up = util.TraceLine({
			start = pos,
			endpos = pos + forward*100 + up*30,
			filter = self.Entity
		})
		table.insert(traces,Up)
		local Down = util.TraceLine({
			start = pos,
			endpos = pos + forward*100 - up*30,
			filter = self.Entity
		})	
		table.insert(traces,Down)
		for k,v in pairs(traces) do
			if v.Entity:IsPlayer() then
				if v.Entity == self.Entity:GetThowBy() then continue end
				if v.Entity:GetNWString("CTeam") != "" then
					if v.Entity:GetNWString("CTeam") == self.Entity:GetThowBy():GetNWString("CTeam") then continue end
				end
				self:DoExplode( self.Entity:GetThowBy() )
			end
		end
	end
	function ENT:Think()
		local pos = self.Entity:GetPos()
		if SERVER then self.Entity:Find() end
		if GetGameState() == GS_ROUND_PREPARE and IsValid(self.Entity:GetThowBy()) then 
			self.Entity:GetThowBy():RemPlantLimit("Claymore")
			self.Entity:Remove() 
		elseif !IsValid(self.Entity:GetThowBy()) then
			self.Entity:Remove() 
		end
		self.Entity:NextThink( CurTime( ) )
		return true
	end
	function ENT:OnTakeDamage(dmg)
		if !self.Entity.DoExp then return end
		self.Entity:TakePhysicsDamage( dmg )
		
		if dmg:GetAttacker():IsPlayer() and dmg:GetInflictor():GetClass() != self.Entity:GetClass() then
			self:DoExplode( dmg:GetAttacker() )
		end
	end
end
function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "ThowBy" );
end