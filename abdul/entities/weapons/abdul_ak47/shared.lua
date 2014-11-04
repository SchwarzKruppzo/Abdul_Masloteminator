

if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Калаш"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_ark7.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"
SWEP.BobScale			= 0.4
SWEP.SwayScale			= 0.2
SWEP.ViewModelFOV		= 60
SWEP.Weight				= 5
SWEP.CrosshairType		= "auto"
SWEP.CrosshairSize = 1
SWEP.CrosshairGap = -6
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CSMuzzleFlashes    = true
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 100
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "ak47"
SWEP.RecoilUP	=	0
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() ) 
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
	owner:AbdulVoice( "abdul/wep"..math.random(1,2)..".wav" )
end
function SWEP:EquipAmmo( owner )
	owner:AbdulVoice( "abdul/wep"..math.random(1,2)..".wav" )
	owner:GiveAmmo( math.abs(owner:GetAmmoCount(  self.Secondary.Ammo ) - self.Secondary.MaxAmmo ), self.Secondary.Ammo )
end
function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) > 0 ) then
		if self.Owner:KeyDown( IN_ATTACK ) then
			if self.RecoilUP > -1.5 then
				self.RecoilUP = self.RecoilUP - 0.5/25
			end
		elseif self.Owner:KeyReleased( IN_ATTACK ) then
			if self.RecoilUP <= 0 then
				self.RecoilUP = self.RecoilUP + 1
				self.RecoilUP = math.Clamp( self.RecoilUP, -1000, 0 )
			end
		end
	end
	self:NextThink( CurTime() )
	return true
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Up() * 1 - ang:Forward() * 5
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
	self.Owner:ViewPunch(Angle(self.RecoilUP,math.Rand(-0.25,0.25),0))
	local bullet = {} 
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = (self.Owner:GetAimVector():Angle() + self.Owner:GetPunchAngle()):Forward()
		bullet.Spread = Vector(math.Clamp(math.Rand(-0.01,0.012),0.0000,1),math.Clamp(math.Rand(-0.01,0.01),0.0000,1),0)
		bullet.Tracer = 1 
		bullet.Force = 200
		bullet.Damage = math.random(7,12)
		bullet.AmmoType = "ak47"
		bullet.Callback = function( ply, tr, dmginfo )
			if self.Owner:HasPowerUp( "QuadDamage" ) then
				dmginfo:ScaleDamage( 3 )
			end
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)		
			effectdata:SetNormal(tr.HitNormal)	
			effectdata:SetStart(Vector(0,1,0))
			effectdata:SetScale(0.5)			
			effectdata:SetRadius(tr.MatType)
			util.Effect("50cal_impact",effectdata)
			sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,math.Rand(50,75),100,math.Rand(0.5,1))
			dmginfo:SetInflictor( self.Weapon )
			self:Penetrate( ply, tr, dmginfo)
		end
		self:NearMiss()
		self.Owner:FireBullets( bullet );
	self.Weapon:EmitSound(Sound("weapons/ak47/ak47-1.wav"),85,103)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	self:SetNextPrimaryFire( CurTime() + 1/(560/60) )
end
function SWEP:Penetrate( attacker, tracedata, dmginfo )

	local Dir = tracedata.Normal * 22
	
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
	bullet.AmmoType = "ak47"
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