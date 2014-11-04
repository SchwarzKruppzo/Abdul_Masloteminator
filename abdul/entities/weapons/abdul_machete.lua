if SERVER then
	AddCSLuaFile()
end
if CLIENT then
    SWEP.PrintName = "Мачета рубить маслят"
    SWEP.Slot = 0
    SWEP.SlotPos = 0
end
SWEP.Category = "Abdul Weapons"
SWEP.SwayScale 			= 1.5
SWEP.BobScale 			= 1
SWEP.ViewModelFOV    = 60
SWEP.ViewModelFlip    = false
SWEP.HoldType = "melee2"
SWEP.Sounds = {
	Miss = {
		"weapons/crowbar/crowbar_swing_miss1.wav",
		"weapons/crowbar/crowbar_swing_miss2.wav",
	},
	Impact_Flesh = {
		"physics/body/body_medium_break2.wav",
		"physics/body/body_medium_break3.wav",
		"physics/body/body_medium_break4.wav",
	},
	Impact_World = {
		"weapons/crowbar/crowbar_impact_world1.wav",
		"weapons/crowbar/crowbar_impact_world2.wav",
	},
}
SWEP.Spawnable            = true
SWEP.AdminSpawnable        = false

SWEP.UseHands	= true
--SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.ViewModel = "models/weapons/v_machete.mdl"
SWEP.WorldModel   = "models/weapons/w_machete.mdl"

SWEP.HitDecal = "Impact.Concrete"

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic       = true    
SWEP.Primary.Ammo             = "none"
SWEP.Melee = true


function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.HitDistance = 48
	self.PushDistance = 48
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
end

function SWEP:Deploy()	
	if IsValid(self.Owner) then
		if SERVER then self.Owner:AbdulVoice("abdul/deploy1.wav") end
	end
	self:SetHoldType(self.HoldType)
	self:SendWeaponAnim(ACT_VM_DRAW)
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


function SWEP:Think()
	if self.TurnToIdle and self.TurnToIdle < CurTime() then
		self.TurnToIdle = nil
		self:SendWeaponAnim( ACT_VM_IDLE )
	end
end

function SWEP:DealDamage()
	self.Owner:LagCompensation(true)
	
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner
	})

	if not IsValid( tr.Entity ) then 
		tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8)
		})
	end

	if tr.Hit then
		if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			if tr.MatType == MAT_FLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_ALIENFLESH or tr.MatType == MAT_BLOODYFLESH then
				self:EmitSound(table.Random(self.Sounds.Impact_Flesh), 70, 100)
				ParticleEffect("blood_impact_red_01", tr.HitPos, tr.HitNormal:Angle(), tr.Entity)
			end
		else
			local tr2 = self.Owner:GetEyeTrace()
			
			util.Decal(self.HitDecal, tr2.HitPos + tr2.HitNormal, tr2.HitPos - tr2.HitNormal)
			
			self:EmitSound(table.Random(self.Sounds.Impact_World), 70, 105)
		end
		self:SendWeaponAnim( ACT_VM_HITCENTER )

	else
		self:EmitSound(table.Random(self.Sounds.Miss), 80, math.random(95, 105))
		self:SendWeaponAnim( ACT_VM_MISSCENTER )
	
	end
	self.Owner:ViewPunch(Angle(math.Rand(-1,1), math.Rand(-1, 1), math.Rand(-1, 1)))
	local hit = false

	if SERVER and IsValid( tr.Entity ) and ( tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0 ) then
		local dmginfo = DamageInfo()
	
		dmginfo:SetAttacker( self.Owner )
		dmginfo:SetInflictor( self.Weapon )
		dmginfo:SetDamageForce( self.Owner:GetUp() * 5158 + self.Owner:GetForward() * 10012 )
		dmginfo:SetDamage( math.random( 30, 44 ) )
		if self.Owner:HasPowerUp( "QuadDamage" ) then
			dmginfo:ScaleDamage( 3 )
		end
		tr.Entity:TakeDamageInfo( dmginfo )
		hit = true

	end

	if SERVER and IsValid( tr.Entity )  then
		local phys = tr.Entity:GetPhysicsObject()
		if IsValid( phys ) then
			phys:ApplyForceOffset( self.Owner:GetAimVector() * 80 * phys:GetMass(), tr.HitPos )
		end
	end

	self.Owner:LagCompensation( false )
end

function SWEP:PrimaryAttack()	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:DealDamage()
	
	self:SetNextPrimaryFire( CurTime() + 0.4 )
	self.TurnToIdle = CurTime() + self:SequenceDuration()
end

function SWEP:SecondaryAttack()
	return false
end