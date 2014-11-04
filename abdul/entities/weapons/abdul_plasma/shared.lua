

if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Maslobich"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.UseHands = true
SWEP.ViewModel			= "models/weapons/c_physcannon.mdl"
SWEP.WorldModel			= "models/weapons/w_physics.mdl"
SWEP.ViewModelFOV = 54
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CrosshairType		= "rocket"
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 15
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "plasma"


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
function SWEP:EquipAmmo( owner )
	owner:AbdulVoice( "abdul/wep5.wav" )
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
	pos = pos - ang:Forward()*2 - ang:Up()*2 - ang:Right()*4
	return pos, ang
end
function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		return
	end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if SERVER then
		local ent = ents.Create ("ent_plasma");
		local aim = self.Owner:GetAimVector()
		local side = aim:Cross(Vector(0,0,1))
		local up = side:Cross(aim)
		local pos = self.Owner:GetShootPos() + side * 6 + up * -5
		
		
		local tracedata = {}
		tracedata.start = self.Owner:GetShootPos()
		tracedata.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 45
		tracedata.filter = { self.Owner }
		tracedata.mask 	= MASK_SHOT + MASK_WATER
		local trace = util.TraceLine(tracedata)
		if trace.Hit then
			pos = self.Owner:GetShootPos() + side * 6 + up * -5 - self.Owner:GetForward() * 60
		end
		
		
		
		 
		ent:SetOwner(self.Owner)
		ent:SetPos(pos)
		ent:SetAngles(aim:Angle())
		ent.ThowBy = self.Owner
		ent:Spawn()
		ent:Activate()
		
	end
	
	self.Weapon:EmitSound(Sound("weapons/physcannon/superphys_launch1.wav"),100,250)
	
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	
	self:SetNextPrimaryFire( CurTime() + 0.6 )
end
function SWEP:SecondaryAttack()
	return false
end