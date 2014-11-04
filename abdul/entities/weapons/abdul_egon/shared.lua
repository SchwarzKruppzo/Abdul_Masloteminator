

if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName			= "Палисан"			
	SWEP.Author				= "SchwarzKruppzo"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 0
end

SWEP.HoldType			= "physgun"
SWEP.Base				= "weapon_base"
SWEP.Category			= "Abdul Weapons"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.UseHands			= false
SWEP.ViewModel			= "models/c_egon.mdl"
SWEP.WorldModel			= "models/w_egonhd.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.CrosshairType		= "rocket"
SWEP.CrosshairSize = -1
SWEP.CrosshairGap = -4
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 100
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "uranium"
SWEP.AttackSound = Sound("WeaponDissolve.Beam")
SWEP.StopSoundc = Sound("WeaponDissolve.Dissolve")
SWEP.NextAttack = 0
SWEP.NextAnim = 0
SWEP.NextAmmo = 0

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self.NextAttack = CurTime()
	self.AttackLoop = CreateSound( self.Weapon, Sound("WeaponDissolve.Beam") )
end
function SWEP:CanAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.NextAttack = CurTime() + 0.1
		return false
	elseif self.NextAttack > CurTime() then return false end
	return true
end
function SWEP:Think()
	if !IsValid(self.Owner) then return end
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end	
	
		if self.Owner:KeyPressed( IN_ATTACK ) then
			if self.NextAttack < CurTime() then
				self:StartAttack()
			end
		elseif self.Owner:KeyDown( IN_ATTACK ) then
			if self.NextAttack < CurTime() then
				self:UpdateAttack()
			end
		elseif self.Owner:KeyReleased( IN_ATTACK ) then
			if !self:CanAttack() then return end
			self:EndAttack( true )
		end
		
end
function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	return true
end


function SWEP:StartAttack()
	if !self:CanAttack() then 
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self:EndAttack( false ) 
		return
	end
	
	if (SERVER) then
		
		if (!self.Beam) then
			self.Beam = ents.Create( "ent_egon" )
			self.Beam:SetPos( self.Owner:GetShootPos() )
			self.Beam:Spawn()
			self.Owner:ViewPunchC(Angle(math.Rand(3,1),math.Rand(-3,3),0))
			self.NextAnim = CurTime() + 0.18
		end
		self.Beam:SetParent( self.Owner )
		self.Beam:SetOwner( self.Owner )
	end
	if !self.AttackLoop:IsPlaying() then
		self.AttackLoop:PlayEx(1,100)
	end
	if self.NextAttack < CurTime() then
		self:UpdateAttack()
	end
end

function SWEP:UpdateAttack()
	if !self:CanAttack() then 
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self:EndAttack( false ) 
		return 
	end
	if SERVER then 
		if (!self.Beam) then
			self.Beam = ents.Create( "ent_egon" )
			self.Beam:SetPos( self.Owner:GetShootPos() )
			self.Beam:Spawn()
			self.Owner:ViewPunchC(Angle(math.Rand(2,0.5),math.Rand(-2,2),0))
			self.NextAnim = CurTime() + 0.18
		end
		self.Beam:SetParent( self.Owner )
		self.Beam:SetOwner( self.Owner )
		self.Owner:ViewPunchC(Angle(math.Rand(-0.25,0.25),math.Rand(-0.25,0.25),0)) 
	end
	if ( self.Timer && self.Timer > CurTime() ) then return end
	if !self.AttackLoop:IsPlaying() then
		self.AttackLoop:PlayEx(1,100)
	end
	self.Timer = CurTime() + 0.05
	self.Owner:LagCompensation( true )
	local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = trace.start + (self.Owner:GetAimVector() * 4096)
		trace.filter = { self.Owner, self.Weapon }
	local tr = util.TraceLine( trace )
	if (SERVER && self.Beam) then
		self.Beam:GetTable():SetEndPos( tr.HitPos )
	end
	if ( !self.NextAnim || self.NextAnim < CurTime() ) then
		//self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.NextAnim = CurTime() + 0.18
	end
	if SERVER then
		for k,v in pairs(ents.FindInSphere( tr.HitPos, 30 ) ) do
			if IsValid( v ) and ( v:IsNPC() or v:IsPlayer() or v:Health() > 0 ) then
				if ( !self.NextDamage || self.NextDamage < CurTime() ) then
					local dmginfo = DamageInfo()
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Weapon )
					//dmginfo:SetDamageForce( self.Owner:GetUp() * 5158 + self.Owner:GetForward() * 10012 )
					dmginfo:SetDamage( math.random(7,13) )
					dmginfo:SetDamagePosition( tr.HitPos )
					if self.Owner:HasPowerUp( "QuadDamage" ) then
						dmginfo:ScaleDamage( 3 )
					end
					v:TakeDamageInfo( dmginfo )
					self.NextDamage = CurTime() + 0.1
				end
			end
		end
		if ( !self.NextAmmo || self.NextAmmo < CurTime() ) then
			self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
			self.NextAmmo = CurTime() + 0.09
		end
	end
	//util.BlastDamage( self.Weapon, self.Owner, tr.HitPos, 80, 10 )
	if IsValid(tr.Entity) and (tr.Entity:IsNPC()) then
		local effectdata = EffectData()
			effectdata:SetEntity( tr.Entity )
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetNormal( tr.HitNormal )
		util.Effect( "BloodImpact", effectdata )
	end
	self.Owner:LagCompensation( false )
end

function SWEP:EndAttack( shutdownsound )

	//self.Weapon:StopSound( self.AttackSound , 75, 100)
	self.AttackLoop:Stop()
	if ( shutdownsound ) then
		self.Weapon:EmitSound( self.StopSoundc , 75, 100)
	end
	if ( CLIENT ) then return end
	if ( !self.Beam ) then return end
	self.Beam:Remove()
	self.Beam = nil
end
function SWEP:Reload()
	return
end
function SWEP:Holster()
	self:EndAttack( false )
	return true
end

function SWEP:OnRemove()
	self:EndAttack( true )
	return true
end
function SWEP:DrawWeaponSelection()
end

function SWEP:PrintWeaponInfo()
end
function SWEP:EquipAmmo( owner )
	owner:GiveAmmo( math.abs(owner:GetAmmoCount(  self.Secondary.Ammo ) - self.Secondary.MaxAmmo ), self.Secondary.Ammo )
end

function SWEP:PrimaryAttack()
	if !self:CanAttack() then return end
	self.AttackLoop:PlayEx(1,100)
	//self.Weapon:EmitSound( self.AttackSound , 75, 100 )
end
function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Forward()*4 - ang:Right()*1 + ang:Up()*5
	return pos, ang
end
function SWEP:SecondaryAttack()
	return false
end
/*





function SWEP:Think()

	self:NextThink( CurTime() )
	return true
end


function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		//self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		//self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		//return
	end
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	
	//self.Weapon:EmitSound(Sound("weapons/railgun/railgf1a.wav"),100,100)
	//self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
	self:SetNextPrimaryFire( CurTime() + 1.6 )
end
*/
