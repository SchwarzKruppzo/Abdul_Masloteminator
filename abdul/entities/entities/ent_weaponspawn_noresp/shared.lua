ENT.Type = "anim"
if CLIENT then
	function ENT:Initialize()
		self.Spin = 0
	end
	function ENT:Draw()
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
		self:SetModel(self.MDL)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetAngles(Angle(0,90,0))
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetModelScale(1.4, 0)
		self.HasGun = true
	end
	function ENT:Think()
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = self:GetPos() - self:GetUp() * 20
		tracedata.filter = { self }
		local trace = util.TraceLine(tracedata)
		if !trace.Hit then
			self:SetPos(trace.HitPos)
		end
		for k,v in pairs (player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetPos():Distance(self:GetPos()) < 75 and self.HasGun == true and v:Alive() then
				if v:IsBerserk() then continue end
				self.HasGun = false
				self:SetNoDraw(true)
				self.RespawnTime = CurTime() + GetConVar("abdul_weapon_restime"):GetInt()
				v:EmitSound("items/ammo_pickup.wav",100,100)
				v:Give(self.Class)
				v:SelectWeaponByPriority( self.Class )
				hook.Call("PlayerPickupWeapon",GAMEMODE,v,self.Class)
				self:Remove()
			end
		end
		self:NextThink(CurTime())
		return true
	end

end