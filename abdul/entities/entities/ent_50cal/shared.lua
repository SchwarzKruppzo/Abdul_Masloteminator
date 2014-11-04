ENT.Type = "anim"
ENT.PrintName = "50 cal"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.Angles = Angle()

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	local CAL50 = nil
	local Shooting = false 
	local function OnEnterUser( data )
		CAL50 = data:ReadEntity()
		local wep = LocalPlayer():GetActiveWeapon()
		local vm = LocalPlayer():GetViewModel()	
		if not IsValid(wep) then
			if IsValid(vm) then
				vm:SetNoDraw(false)
			end
			return
		end
		if IsValid( CAL50 ) then
			vm:SetNoDraw(true)
		end
	end
	usermessage.Hook( '50CAL_OEU', OnEnterUser )
	local function OnExitUser( data )
		CAL50 = nil
		local wep = LocalPlayer():GetActiveWeapon()
		local vm = LocalPlayer():GetViewModel()	
		if IsValid(vm) then
			vm:SetNoDraw(false)
		end
		if IsValid(wep) then
		wep:SetNextPrimaryFire(math.max(CurTime() + wep:SequenceDuration(), wep:GetNextPrimaryFire()))
		wep:SetNextSecondaryFire(math.max(CurTime() + wep:SequenceDuration(), wep:GetNextSecondaryFire()))
		end
	end
	usermessage.Hook( '50CAL_OXU', OnExitUser )
	
	local function CreateMove( cmd )
		if IsValid( CAL50 ) then
			if cmd:KeyDown(IN_ATTACK) then
				cmd:SetButtons(cmd:GetButtons() - IN_ATTACK)
				if not Shooting then
					Shooting = true
					RunConsoleCommand('50cal_attack', '1')
				end
			elseif Shooting then
				Shooting = false
				RunConsoleCommand('50cal_attack', '0')
			end
			if cmd:KeyDown(IN_ATTACK2) then
				cmd:SetButtons(cmd:GetButtons() - IN_ATTACK2)
			end
		end
	end
	hook.Add('CreateMove', '50CAL_Shooting', CreateMove)
else
	AddCSLuaFile()
	function ENT:Initialize()
		self.Entity:SetModel( "models/props_marines/50cal.mdl" )
		self.Entity:PhysicsInitBox( Vector( -10, -10, 0 ), Vector( 10, 10, 10 ) )
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:SetUseType( SIMPLE_USE )
		self:SetEHealth(200)
		self.NextShot = 0
		self:SetPoseParameter('aim_yaw', 0)
		self:SetPoseParameter('aim_pitch', 0)
		self:ResetSequence('idle')
		self.NextIdle = 0
		self.Idle = false
	end
	function ENT:SetupDataTables()
		self:NetworkVar( "Entity", 0, "User" );
		self:NetworkVar( "Float", 1, "EHealth" );
	end
	function ENT:Destruct()
		if IsValid( self:GetUser() ) then
			self:OnExitUser()
		end
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetNormal( Vector(0,0,0) )
		util.Effect( "shrap_explosion", effectdata )
		
		self:EmitSound("npc/manhack/gib.wav",100,100)
		self.Entity.ThowBy:RemPlantLimit( "50cal" )
		self:Remove()
	end
	function ENT:OnTakeDamage(dmg)
		self:TakePhysicsDamage(dmg)
		if dmg:GetDamageType() == 8194 then return end
		if self:GetEHealth() <= 0 then return end
		self:SetEHealth( self:GetEHealth() - dmg:GetDamage() )
		
		if self:GetEHealth() <= 0 then
			self:Destruct()
		end
	end
	function ENT:Use( activator )
		if (activator:GetPos() - self:GetPos()):LengthSqr() > 6000 then
			return
		end
		if IsValid(self:GetUser()) then
			if self:GetUser() == activator then
				self:OnExitUser()
			end	
			return
		end
		self:OnEnterUser( activator )
	end
	local function bearing( originpos, originangle, pos )
		local rad2deg = 180 / math.pi
		pos = WorldToLocal(Vector(pos[1],pos[2],pos[3]),Angle(0,0,0),Vector(originpos[1],originpos[2],originpos[3]),Angle(originangle[1],originangle[2],originangle[3]))
		return rad2deg*-math.atan2(pos.y, pos.x)
	end
	function ENT:AimThink()
		local newAngles = self:GetUser():EyeAngles()
		newAngles.pitch = -math.NormalizeAngle(newAngles.pitch - self:GetAngles().pitch)
		newAngles.yaw = -math.NormalizeAngle(newAngles.yaw - self:GetAngles().yaw)
		local angles = Angle(self:GetPoseParameter('aim_pitch'), self:GetPoseParameter('aim_yaw'), 0)
		local newPitch = math.Clamp(math.AngleDifference(newAngles.pitch, angles.pitch), -1, 1)
		local newYaw = math.Clamp(math.AngleDifference(newAngles.yaw, angles.yaw), -2, 2)	
		self:SetPoseParameter('aim_yaw', math.Clamp(math.NormalizeAngle(angles.yaw + newYaw), -60, 60))
		self:SetPoseParameter('aim_pitch', math.Clamp(math.NormalizeAngle(angles.pitch + newPitch), -25, 30))	
	end
	function ENT:NearMiss( pos, endpos )
	local tracedata = {}

	tracedata.start = pos
	tracedata.endpos = endpos
	tracedata.filter = {self:GetUser(),self.Entity}
	tracedata.mins = Vector( -3,-3,-3 )
	tracedata.maxs = Vector( 3,3,3 )
	tracedata.mask = MASK_SHOT_HULL
	local tr = util.TraceHull( tracedata )
	if IsValid(tr.Entity) then
		if tr.Entity:IsPlayer() then
			local i = math.random(3,14)
			local str = tostring(i)
			if i < 10 then
				str = "0" .. i
			end
			sound.Play("weapons/fx/nearmiss/bulletltor"..str..".wav", tr.Entity:GetPos(),60,100,math.Rand(0.5,1))
		end
	end
	end
	function ENT:ShootThink()
		if CurTime() > self.NextShot and self.Shooting then
			self.Idle = false
			local muzzleTach = self:LookupAttachment('muzzle')
			local attach = self:GetAttachment(muzzleTach)
			local b_pos,b_ang = self:GetBonePosition( 2 )
			local bullet = {}
				bullet.Num = 1
				bullet.Src = attach.Pos
				bullet.Dir = Vector(attach.Ang:Forward().x,attach.Ang:Forward().y,self:GetPoseParameter('aim_pitch')/58) + Vector(math.Rand(-0.01,0.01),math.Rand(-0.01,0.01),math.Rand(-0.01,0.01))
				bullet.Spread = 0
				bullet.Tracer = 1
				bullet.Force = 20
				bullet.Damage = 35
				bullet.Attacker = self:GetUser()
				bullet.Callback = function( ply, tr, dmginfo )
					if self:GetUser():HasPowerUp( "QuadDamage" ) then
						dmginfo:ScaleDamage( 3 )
					end
					local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)		
					effectdata:SetNormal(tr.HitNormal)	
					effectdata:SetStart(Vector(0,1,0))
					effectdata:SetScale(0.8)			
					effectdata:SetRadius(tr.MatType)
					util.Effect("50cal_impact",effectdata)
					sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,math.Rand(50,75),100,math.Rand(0.5,1))
					dmginfo:SetInflictor( self )
				end
			self:NearMiss( attach.Pos,attach.Ang:Forward()*2000000)
			self:FireBullets(bullet)
			local fx 		= EffectData()
			fx:SetEntity(self)
			fx:SetAngles(attach.Ang)
			fx:SetOrigin(attach.Pos + attach.Ang:Forward()*5)
			fx:SetAttachment(muzzleTach)
			util.Effect("50cal_muzzle",fx)
			local ejectTach = self:LookupAttachment('eject')
			local attach = self:GetAttachment(ejectTach)
			local fx 		= EffectData()
			fx:SetAngles(attach.Ang)
			fx:SetOrigin(attach.Pos)
			fx:SetAttachment(ejectTach)
			util.Effect("EjectBrass_9mm",fx)
			sound.Play( Sound("weapons/357/357_fire2.wav"), self:GetPos(), 78, 180,1 )
			sound.Play( Sound("weapons/smg1/smg1_fire1.wav"), self:GetPos(), 78, 100, 1 )
			self.NextShot = CurTime() + 1/(680/60)//+ 0.15
			self:ResetSequence('fire')
			self.NextIdle = CurTime() + self:SequenceDuration() + 0.01
			self.Idle = true
		end
	end
	function ENT:OnExitUser()
		if !IsValid(self:GetUser()) then return end
		umsg.Start( "50CAL_OXU", self:GetUser() )
		umsg.End()
		self:GetUser().CAL50 = nil
		self:SetUser( nil )
		self.Shooting = false
	end
	function ENT:OnEnterUser( ply )
		if IsValid(self:GetUser()) then
			return
		end
		self:EmitSound('Func_Tank.BeginUse')
		ply.CAL50 = self
		self:SetUser( ply )
		umsg.Start( "50CAL_OEU", ply )
			umsg.Entity( self )
		umsg.End()
	end
	function ENT:OnRemove()
		if IsValid(self:GetUser()) then
			self:OnExitUser()
		end
	end
	function ENT:Think()
		if IsValid(self:GetUser()) then
			if not self:GetUser():Alive() or (self:GetUser():GetPos() - self:GetPos()):LengthSqr() > 6000 then
				self:OnExitUser()
			else
				self:ShootThink()
				self:AimThink()
			end
		end
		if IsValid(self.Entity.ThowBy) then 
			if GetGameState() == GS_ROUND_PREPARE then
				self.Owner:SetNWInt( "50cal", 0 )
				self.Entity:Remove() 
			end
			if (self.Entity.ThowBy:GetPos() - self:GetPos()):LengthSqr() < 6000 then
				if self.Entity.ThowBy:KeyDown( IN_RELOAD ) then
					self.Entity.ThowBy:Give( "abdul_50cal" )
					self.Entity.ThowBy:GiveAmmo( 1, "50cals" )
					self:OnExitUser()
					self.Entity.ThowBy:RemPlantLimit( "50cal" )
					self.Entity:Remove()
				end
			end
		elseif !IsValid(self.Entity.ThowBy) then
			self.Entity:Remove() 
		end
		if CurTime() > self.NextIdle and self.Idle then
			self:ResetSequence('idle')
		end
		self.Entity:NextThink( CurTime( ) )
		return true
	end
	local function Attack(ply, cmd, args)
		if not IsValid(ply.CAL50) then
			return
		end
		ply.CAL50.Shooting = args[1] == '1'
	end
	concommand.Add('50cal_attack', Attack)
end