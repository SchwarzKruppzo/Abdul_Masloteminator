if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Сониблядский Миниган"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 2
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_deat_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_minigun.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CrosshairType		= "rocket"
SWEP.CrosshairSize = -1
SWEP.CrosshairGap = -4
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 250
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "PulseCell"

SWEP.At = 0
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	
end
function SWEP:Deploy()
	if IsValid(self.Owner) then
		if SERVER then self.Owner:AbdulVoice("abdul/deploy2.wav") end
	end
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire(CurTime() + 0.8)
	return true
end
function SWEP:Reload()
	return
end
function SWEP:DrawWeaponSelection()
end

function SWEP:PrintWeaponInfo()
end
function SWEP:EquipAmmo( owner )
	owner:GiveAmmo( math.abs(owner:GetAmmoCount(  self.Secondary.Ammo ) - self.Secondary.MaxAmmo ), self.Secondary.Ammo )
end

function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) > 0 ) then
		if self.Owner:KeyDown( IN_ATTACK ) then
			if self.At == 0 then
				self.At = CurTime() + 0.09
				self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			elseif self.At < CurTime() then
				self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
				self.At = CurTime() + 0.09
			end
			
		end
	end
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Forward()*2 - ang:Up()*2 - ang:Right()*5
	return pos, ang
end

function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		return
	end
	local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment("1")
		util.Effect("pulse_muzzle",fx)
	if SERVER then
		self.Owner:LagCompensation(true)
		
		local ent = ents.Create ("ent_pulsebullet");
		local aim = self.Owner:GetAimVector()+(VectorRand()*math.Rand(0,0.01))
		local pos = self.Owner:GetShootPos()
	
		ent:SetOwner(self.Owner)
		ent:SetPos(pos)
		ent:SetAngles(aim:Angle())
		ent.ThowBy = self.Owner
		ent:Spawn()
		ent:Activate()
		
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:ViewPunch( Angle(math.Rand( -0.8,0.5),math.Rand( -0.5,0.5),math.Rand( -0.5,0.5)) )
		self.Owner:LagCompensation(false) 
	end
	self:EmitSound(Sound("weapons/ar2/fire1.wav"),80,70)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	
	self:SetNextPrimaryFire( CurTime() + 1/(500/60) )
end
function SWEP:SecondaryAttack()
	return false
end