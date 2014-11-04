if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Маслачезатор"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 3
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"
SWEP.UseHands			= false
SWEP.ViewModelFOV		= 75
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_combinegl.mdl"
SWEP.WorldModel			= "models/weapons/w_combinegl.mdl"
SWEP.BobScale			= 0.8
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CrosshairType		= "rocket"
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 10
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "ShrapBomb"

SWEP.At = 0
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	
end
function SWEP:Deploy()
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
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Forward() *2
	return pos, ang
end

function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		return
	end
	
	if SERVER then
		local ent = ents.Create ("ent_shrapbomb");
		local aim = self.Owner:GetAimVector()
		local side = aim:Cross(Vector(0,0,1))
		local up = side:Cross(aim)
		local ang = self.Owner:EyeAngles()
		local pos = self.Owner:GetShootPos() + side * 9 + up * -12
		local vecThrow;
		vecThrow = self.Owner:GetVelocity();
		vecThrow = vecThrow + self.Owner:GetAimVector() * 2000;

		ent:SetPos( pos );
		ent:SetAngles( ang );
		ent:SetOwner( self.Owner );
		ent.ThowBy = self.Owner
		ent.Time = CurTime() + 1
		ent:Spawn()
		ent:Activate()
		ent:GetPhysicsObject():SetVelocity( vecThrow );
		ent:GetPhysicsObject():AddAngleVelocity( Vector(600,math.random(-1200,1200),0) );
	end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:ViewPunch( Angle(-1,-1,0) )
	self.Weapon:EmitSound(Sound("weapons/grenade_launcher1.wav"),80,130)
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	
	self:SetNextPrimaryFire( CurTime() + 1/(70/60) )
end
function SWEP:SecondaryAttack()
	return false
end