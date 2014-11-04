ENT.Type = "anim"
if CLIENT then
	function ENT:Initialize()
		self.OriginPos = self:GetPos()
		self.Spin = 0
	end
	function ENT:Draw()
		self:SetRenderOrigin(self.OriginPos + Vector(0,0,math.abs(math.sin(RealTime() * 1) *5.5)))
		self:SetupBones()
		self:DrawModel()
		self.Spin = self.Spin + 1
		if self.Spin >= 360 then
			self.Spin = -360
		end
		self:SetAngles(Angle(0,self.Spin,0))
	end
	function ENT:IsTranslucent()
		return true
	end
else
	AddCSLuaFile()
	function ENT:SpawnFunction(ply, tr)
		if (!tr.Hit) then return end
		local SpawnPos = tr.HitPos + tr.HitNormal * 35
		self.Spawn_angles = ply:GetAngles()
		self.Spawn_angles.pitch = 0
		self.Spawn_angles.roll = 0
		self.Spawn_angles.yaw = self.Spawn_angles.yaw
		local ent = ents.Create(self.EntName)
		ent:SetPos(SpawnPos)
		ent:SetAngles(self.Spawn_angles)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/healthvial.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetAngles(Angle(0,90,0))
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetModelScale(1.5, 0)
		self.HasHealth = true
	end
	function ENT:Think()
		if self.RespawnTime and CurTime() >= self.RespawnTime then
			self.RespawnTime = nil
			self.HasHealth = true
			self:SetNoDraw(false)
			self:EmitSound("weapons/physcannon/physcannon_claws_close.wav")
		end
		for k,v in pairs (player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetPos():Distance(self:GetPos()) < 50 and self.HasHealth == true and v:Alive() and v:Health() < 100 then
				self.HasHealth = false
				self:SetNoDraw(true)
				self.RespawnTime = CurTime() + GetConVar("abdul_healthvial_restime"):GetInt()
				v:EmitSound("items/medshot4.wav",40,100)
				v:SetHealth( math.Clamp(v:Health() + 5,0,100) )
				hook.Call("PlayerPickupHealth",GAMEMODE,v)
			end
		end
	end

end