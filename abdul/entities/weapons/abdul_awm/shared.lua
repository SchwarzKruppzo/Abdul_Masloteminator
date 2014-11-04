

if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "a"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 4
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.UseHands			= false
SWEP.ViewModel			= "models/weapons/v_cstm_awm.mdl"
SWEP.WorldModel			= "models/weapons/w_awm.mdl"
SWEP.ViewModelFlip = false
SWEP.BobScale			= 0.6
SWEP.SwayScale			= 0.4
SWEP.ViewModelFOV		= 70
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CrosshairType		= "auto"
SWEP.CrosshairSize = 2
SWEP.CrosshairGap = -8
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 15
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "awm"

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end
function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() + 0.05 )
	return true
end
function SWEP:Reload()
	return
end
function SWEP:DrawWeaponSelection()
end

function SWEP:PrintWeaponInfo()
end
function SWEP:Equip( owner )
	owner:GiveAmmo( math.abs(owner:GetAmmoCount(  self.Secondary.Ammo ) - self.Secondary.MaxAmmo ), self.Secondary.Ammo )
end
function SWEP:AdjustMouseSensitivity()
	if self.Owner:KeyDown( IN_ATTACK2 ) then
		return 0.3
	end
end
function SWEP:ShootBullet( damage, num_bullets, aimcone )
	
	local bullet = {}

	bullet.Num 	= num_bullets
	bullet.Src 	= self.Owner:GetShootPos() -- Source
	bullet.Dir 	= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )	 -- Aim Cone
	bullet.Tracer	= 1 -- Show a tracer on every x bullets 
	bullet.Force	= 1 -- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "awm"
	bullet.Callback = function( ply, tr, dmginfo )
		if self.Owner:HasPowerUp( "QuadDamage" ) then
			dmginfo:ScaleDamage( 3 )
		end
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)		
		effectdata:SetNormal(tr.HitNormal)	
		effectdata:SetStart(Vector(0,1,0))
		effectdata:SetScale(1)			
		effectdata:SetRadius(tr.MatType)
		util.Effect("50cal_impact",effectdata)
		sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,75,math.Rand(80,120),math.Rand(0.5,1))
		dmginfo:SetInflictor( self.Weapon )
		
		self:Penetrate( ply, tr, dmginfo)
	end
	self:NearMiss()
	self.Owner:FireBullets( bullet )
	
	self:ShootEffects()
	
end
function SWEP:Penetrate( attacker, tracedata, dmginfo )

	local Dir = tracedata.Normal * 28
	
	local trace 	= {}
	trace.endpos 	= tracedata.HitPos
	trace.start 	= tracedata.HitPos + Dir
	trace.mask 		= MASK_SHOT
	trace.filter 	= {self.Owner}
	   
	local trace 	= util.TraceLine(trace) 
	if (trace.StartSolid or trace.Fraction >= 1.0 or tracedata.Fraction <= 0.0) then return false end
	local bullet = {} 
	bullet.Num = 1
	bullet.Src = trace.HitPos
	bullet.Dir = tracedata.Normal	
	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 1 
	bullet.Force = 5
	bullet.Damage = dmginfo:GetDamage()/1.4
	bullet.AmmoType = "awm"
	bullet.Callback = function( ply, tr, dmginfo )
		if self.Owner:HasPowerUp( "QuadDamage" ) then
			dmginfo:ScaleDamage( 3 )
		end
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)		
		effectdata:SetNormal(tr.HitNormal)	
		effectdata:SetStart(Vector(0,1,0))
		effectdata:SetScale(0.8)			
		effectdata:SetRadius(tr.MatType)
		util.Effect("50cal_impact",effectdata)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.StartPos)		
		effectdata:SetNormal(-tr.HitNormal)	
		effectdata:SetStart(Vector(0,1,0))
		effectdata:SetScale(0.8)			
		effectdata:SetRadius(tr.MatType)
		util.Effect("50cal_impact",effectdata)
		sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,math.Rand(50,75),100,math.Rand(0.5,1))
		dmginfo:SetInflictor( self.Weapon )
	end
	if IsValid( attacker ) then
		attacker:FireBullets( bullet )
	end
	return true
end
function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	
	
	self:NextThink( CurTime() )
	return true
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Up() * 0.2 - ang:Forward() * 0.1 - ang:Right() *1
	return pos, ang
end
function SWEP:NearMiss()
	local tracedata = {}

	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 6000000 )
	tracedata.filter = self.Owner
	tracedata.mins = Vector( -6,-6,-6 )
	tracedata.maxs = Vector( 6,6,6 )
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
function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		return
	end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	if SERVER then self.Owner:LagCompensation(true) end
	self.Owner:ViewPunch(Angle(math.Rand(-2,1),math.Rand(-0.5,0.5),math.Rand(-0.5,0.5)))
	local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment("1")
		util.Effect("awm_muzzle",fx)
	local x = 0 
	if self.Owner:GetVelocity():Length() > 0 then
		//x = self.Owner:GetVelocity():Length()/2000
	end
	self:ShootBullet( math.random(50,72), 1, x  )
	self.Weapon:EmitSound("weapons/awm/awm1.wav",95,100)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	if SERVER then self.Owner:LagCompensation(false) end
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() + 0.05 )
end
function SWEP:SecondaryAttack()
	return false
end