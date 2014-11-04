

if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Пушка Нубика"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0
end

SWEP.HoldType			= "smg"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/razorswep/weapons/v_smg_mp7.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"
SWEP.BobScale			= 0.4
SWEP.SwayScale			= 0.2
SWEP.ViewModelFOV		= 60
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CrosshairType		= "auto"
SWEP.CSMuzzleFlashes    = true
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 100
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "mp7"


function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end
function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() )
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
function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	self:NextThink( CurTime() )
	return true
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Up() * 1 + ang:Forward() 
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
	self.Owner:ViewPunch(Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),0))
	local bullet = {} 
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = (self.Owner:GetAimVector():Angle() + self.Owner:GetPunchAngle()):Forward()
		bullet.Spread = Vector(math.Clamp(math.Rand(-0.05,0.05),0.0000,1),math.Clamp(math.Rand(-0.05,0.05),0.0000,1),0)
		bullet.Tracer = 1 
		bullet.Force = 200
		bullet.Damage = math.random(5,8)
		bullet.AmmoType = "mp7"
		bullet.Callback = function( ply, tr, dmginfo )
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)		
			effectdata:SetNormal(tr.HitNormal)	
			effectdata:SetStart(Vector(0,1,0))
			effectdata:SetScale(0.4)			
			effectdata:SetRadius(tr.MatType)
			util.Effect("50cal_impact",effectdata)
			sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,math.Rand(50,75),100,math.Rand(0.5,1))
			dmginfo:SetInflictor( self.Weapon )
			
			if math.random(1,3) == 1 then
				self:Penetrate( ply, tr, dmginfo)
			end
		end
		self:NearMiss()
		self.Owner:FireBullets( bullet );
	self.Weapon:EmitSound(Sound("weapons/smg1/smg1_fire1.wav"),85,170)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	self:SetNextPrimaryFire( CurTime() + 1/(700/60) )
end
function SWEP:Penetrate( attacker, tracedata, dmginfo )

	local Dir = tracedata.Normal * math.random(5,13)
	
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
	bullet.Damage = dmginfo:GetDamage()/1.3
	bullet.AmmoType = "mp7"
	bullet.Callback = function( ply, tr, dmginfo )
		if self.Owner:HasPowerUp( "QuadDamage" ) then
			dmginfo:ScaleDamage( 3 )
		end
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)		
		effectdata:SetNormal(tr.HitNormal)	
		effectdata:SetStart(Vector(0,1,0))
		effectdata:SetScale(0.4)			
		effectdata:SetRadius(tr.MatType)
		util.Effect("50cal_impact",effectdata)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.StartPos)		
		effectdata:SetNormal(-tr.HitNormal)	
		effectdata:SetStart(Vector(0,1,0))
		effectdata:SetScale(0.4)			
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
function SWEP:SecondaryAttack()
	return false
end