

if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Маслобаба"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.UseHands			= true
SWEP.ViewModel			= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"
SWEP.BobScale			= 0.4
SWEP.SwayScale			= 0.2
SWEP.ViewModelFOV		= 35
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CrosshairType		= "auto"
SWEP.CrosshairSize = 8
SWEP.CrosshairGap = 16
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 15
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "shotbuck"

SWEP.NextReloadFinish = 0
SWEP.NextReload = false

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end
function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
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
	owner:AbdulVoice( "abdul/wep4.wav" )
end
function SWEP:EquipAmmo( owner )
	owner:AbdulVoice( "abdul/wep4.wav" )
	owner:GiveAmmo( math.abs(owner:GetAmmoCount(  self.Secondary.Ammo ) - self.Secondary.MaxAmmo ), self.Secondary.Ammo )
end
function SWEP:NearMiss()
	local tracedata = {}

	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 6000000 )
	tracedata.filter = self.Owner
	tracedata.mins = Vector( -3,-3,-3 )
	tracedata.maxs = Vector( 8,8,8 )
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
function SWEP:ShootBullet( damage, num_bullets, aimcone )
	
	local bullet = {}

	bullet.Num 	= num_bullets
	bullet.Src 	= self.Owner:GetShootPos() -- Source
	bullet.Dir 	= self.Owner:GetAimVector() -- Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )	 -- Aim Cone
	bullet.Tracer	= 5 -- Show a tracer on every x bullets 
	bullet.Force	= 1 -- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "shotbuck"
	bullet.Callback = function( ply, tr, dmginfo )
		sound.Play("weapons/fx/rics/ric"..math.random(1,5)..".wav", tr.HitPos,30,100,math.Rand(0.2,0.5))
		dmginfo:SetInflictor( self.Weapon )
	end
	for i=1, num_bullets do
		self:NearMiss()
	end
	self.Owner:FireBullets( bullet )
	
	self:ShootEffects()
	
end
function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	
	if self.NextReload then
		if (self:GetNextPrimaryFire() <= CurTime() + 0.1) then
			self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
			if SERVER then self.Owner:EmitSound("weapons/shotgun/shotgun_cock.wav") end
			self:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() + 0.02 )
			self.NextReload = false
			return
		end
	end
	
	self:NextThink( CurTime() )
	return true
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Up() * 0.1 + ang:Forward() * 5 - ang:Right() * 4
	return pos, ang
end
function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		return
	end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.NextReload = true
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:ViewPunch(Angle(math.Rand(-0.9,0.9),math.Rand(-0.9,0.9),0))
	self:ShootBullet( 3, 12, 0.08 )
	self.Weapon:EmitSound("weapons/shotgun/shotgun_fire7.wav",85,100)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() + 0.03 )
end
function SWEP:SecondaryAttack()
	return false
end