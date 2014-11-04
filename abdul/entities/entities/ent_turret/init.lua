AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_turrets/Floor_turret.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(50)
		phys:EnableMotion(false)
		phys:Wake()
	end
	self:SetEHealth(300)
	self:SetPoseParameter("aim_yaw", 0)
	self:SetPoseParameter("aim_pitch", 0)
end
local function BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValid() then
		if attacker:GetObjectOwner():HasPowerUp( "QuadDamage" ) then
			dmginfo:ScaleDamage( 3 )
		end
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)		
		effectdata:SetNormal(tr.HitNormal)	
		effectdata:SetStart(Vector(0,1,0))
		effectdata:SetScale(0.1)			
		effectdata:SetRadius(tr.MatType)
		util.Effect("50cal_impact",effectdata)
		sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,math.Rand(50,75),100,math.Rand(0.5,1))
		dmginfo:SetAttacker(attacker:GetObjectOwner())
		dmginfo:SetInflictor( attacker )
	end
end

function ENT:FireTurret(src, dir, numbullets)
	if self:GetNextFire() <= CurTime() then
		self:SetNextFire(CurTime() + 0.1)
		local fx 		= EffectData()
		fx:SetEntity(self)
		fx:SetAngles(Angle(0,0,0))
		fx:SetOrigin(src + dir*5)
		util.Effect("50cal_muzzle",fx)
		sound.Play( Sound("weapons/357/357_fire2.wav"), self:GetPos(), 78, 180,1 )
		sound.Play( Sound("weapons/smg1/smg1_fire1.wav"), self:GetPos(), 78, 100, 1 )
		self:FireBullets({Num = numbullets or 1, Src = src, Dir = dir, Spread = Vector(0.05, 0.05, 0), Tracer = 1, Force = 1.3, Damage = 10, Callback = BulletCallback})
	end
end

function ENT:AimThink()
local owner = self:GetObjectOwner()
	if not owner:IsValid() or self:GetMaterial() ~= "" then
		self:Remove() 
	end
	local target = self:GetTarget()
	if target:IsValid() then
		local ang = self:GetLocalAnglesToTarget(target)
		self.PoseYaw = math.Approach(self.PoseYaw, math.Clamp(math.NormalizeAngle(ang.yaw), -60, 60), FrameTime() * 140)
		self.PosePitch = math.Approach(self.PosePitch, math.Clamp(math.NormalizeAngle(ang.pitch), -15, 15), FrameTime() * 100)
	else
		local ct = CurTime()*2
		self.PoseYaw = math.Approach(self.PoseYaw, math.sin(ct) * 30, 2)
		self.PosePitch = math.Approach(self.PosePitch, math.cos(ct * 4) * 30, 1)
	end
	
	self:SetPoseParameter("aim_yaw", self.PoseYaw)
	self:SetPoseParameter("aim_pitch",  self.PosePitch)
end
function ENT:Think()
	if self.Destroyed then
		self:Remove()
		return
	end

	self:AimThink()
	
	
	local owner = self:GetObjectOwner()
	if owner:IsValid() and self:GetMaterial() == "" then
		if self:GetFiring() then self:SetFiring(false) end
		local target = self:GetTarget()
		if target:IsValid() then
			if self:IsValidTarget(target) then
				local shootpos = self:ShootPos()
				self:FireTurret(shootpos, (self:GetTargetPos(target) - shootpos):GetNormalized())
			else
				self:ClearTarget()
				self:EmitSound("npc/turret_floor/deploy.wav")
			end
		else
			local target = self:SearchForTarget()
			if target then
				self:SetTarget(target)
				self:SetTargetReceived(CurTime())
				self:EmitSound("npc/turret_floor/active.wav")
			end
		end
	elseif self:GetFiring() then
		self:SetFiring(false)
	end
	if owner:IsValid() then 
		if GetGameState() == GS_ROUND_PREPARE then
			self:SetNWBool("KSAwardTurret", false )
			self:Remove() 
		end
		if (owner:GetPos() - self:GetPos()):LengthSqr() < 6000 then
			if !owner:HasKSAward( "Turret" ) then
				if owner:KeyDown( IN_RELOAD ) then
					owner:Give( "abdul_turret" )
					owner:GiveAmmo( 1, "turrets" )
					owner:SetNWBool("KSAwardTurret", true )
					self:Remove()
				end
			end
		end
	elseif !owner:IsValid() then
		self:Remove() 
	end
	
	self:NextThink(CurTime())
	return true
	
end

function ENT:Use(activator, caller)
	if self.Removing or not activator:IsPlayer() or self:GetMaterial() ~= "" then return end
	if !self:GetObjectOwner():IsValid() then
		self:SetObjectOwner(activator)
	end
end
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	if (attacker:IsValid() and attacker:IsPlayer()) and attacker != self:GetObjectOwner() then
		if attacker:GetNWString("CTeam") != "" then
			if attacker:GetNWString("CTeam") == self:GetObjectOwner():GetNWString("CTeam") then
				return
			end
		end
		self:SetEHealth(self:GetEHealth() - dmginfo:GetDamage())
		if self:GetEHealth() <= 0 and not self.Destroyed then
			self.Destroyed = true
			local pos = self:LocalToWorld(self:OBBCenter())
			local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			effectdata:SetNormal( Vector(0,0,0) )
			util.Effect( "shrap_explosion", effectdata )
		end
	end
end
