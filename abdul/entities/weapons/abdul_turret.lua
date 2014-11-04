if SERVER then
	AddCSLuaFile()
end
if CLIENT then
    SWEP.PrintName = "Turret"
    SWEP.Slot = 3
    SWEP.SlotPos = 5
end
SWEP.HoldType			= "slam"
SWEP.Category = "Abdul Weapons"
SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true
SWEP.ViewModel = "models/weapons/v_smg1.mdl"
SWEP.WorldModel   = "models/weapons/w_toolgun.mdl"
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 1
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "turrets"
function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "CanPlant" )
end
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end
function SWEP:Deploy()	
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetHoldType( self.HoldType )
	self:SetNextPrimaryFire(CurTime() + 0.8)
	return true
end
function SWEP:Reload()
	return
end
function SWEP:EquipAmmo( owner )
end
function SWEP:DrawWeaponSelection()
end
function SWEP:PrintWeaponInfo()
end
local function FindMines( pos )
	for k,v in pairs(ents.FindInSphere(pos,1)) do	
		if v:GetClass() == "ent_turret" then
			return true
		end
	end
	return false
end
function SWEP:Think()
	if self.Owner:GetAmmoCount( self.Secondary.Ammo ) > self.Secondary.MaxAmmo then
		self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Secondary.Ammo ) - self.Secondary.MaxAmmo, self.Secondary.Ammo );
	end
	if SERVER then
		local angle = self.Owner:EyeAngles()
		local curangle = Angle(0,angle.y,0)
		local shootpos = self.Owner:GetShootPos()
		local aimvector = self.Owner:GetAimVector()
		local up = self.Owner:GetUp()
		local right = self.Owner:GetRight()
		local forward = self.Owner:GetForward()
		local pos = shootpos + aimvector * 70
		
		local trMain = util.TraceLine({
			start = shootpos,
			endpos = pos,
			filter = self.Owner
		})
		local trRight = util.TraceLine({
			start = trMain.HitPos,
			endpos = trMain.HitPos - right * 8,
			filter = self.Owner
		})
		local trLeft = util.TraceLine({
			start = trMain.HitPos,
			endpos = trMain.HitPos + right * 8,
			filter = self.Owner
		})
		local trForward = util.TraceLine({
			start = trMain.HitPos + up * 5,
			endpos = trMain.HitPos + up * 5 + forward * 8,
			filter = self.Owner
		})
		local trBack = util.TraceLine({
			start = trMain.HitPos + up * 5,
			endpos = trMain.HitPos + up * 5 - forward * 6.5,
			filter = self.Owner
		})
		if trMain.Hit and !trRight.Hit and !trLeft.Hit and !trForward.Hit and !trBack.Hit and !FindMines( pos ) then
			self:SetCanPlant(true)
		else
			self:SetCanPlant(false)
		end
	end
end
function SWEP:Holster()
	if CLIENT then 
		if IsValid(self.GhostEntity) then self.GhostEntity:Remove() end
	end
	return true
end
function SWEP:OnRemove()
	if CLIENT then 
		if IsValid(self.GhostEntity) then self.GhostEntity:Remove() end
	end
	return true
end
function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Forward() *22228
	return pos, ang
end
function SWEP:DrawHUD()
	if CLIENT then
		local angle = LocalPlayer():EyeAngles()
		local curangle = Angle(0,angle.y,0)
		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 70,
			filter = self.Owner
		})
		if !IsValid(self.GhostEntity) then
			self.GhostEntity = ents.CreateClientProp()
			self.GhostEntity:SetModel("models/Combine_turrets/Floor_turret.mdl")
			self.GhostEntity:SetPos( tr.HitPos )
			self.GhostEntity:SetAngles( curangle )
			self.GhostEntity:SetMaterial("models/wireframe")
		else
			if self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 then	
				self.GhostEntity:SetNoDraw(true)
			else
				self.GhostEntity:SetNoDraw(false)
			end
			self.GhostEntity:SetPos( tr.HitPos )
			self.GhostEntity:SetAngles( curangle )
			if self:GetCanPlant() then
				self.GhostEntity:SetColor(Color(0,255,0,255))
			else
				self.GhostEntity:SetColor(Color(255,0,0,255))
			end
		end
		
	end
end
function SWEP:PrimaryAttack()
	if ( self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 ) then
		self.Weapon:EmitSound( Sound( "Weapon_SMG1.Empty" ) );
		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		return
	end
	if SERVER then
		local pos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 70
		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = pos,
			filter = self.Owner
		})
		local angle = self.Owner:EyeAngles()
		local curangle = Angle(0,angle.y,0)
		if self:GetCanPlant() then
			local ent = ents.Create ("ent_turret")
			ent:SetPos( tr.HitPos )
			ent:SetAngles( curangle )
			ent:Spawn()
			ent:SetObjectOwner( self.Owner )
			ent:Activate()
			ent:EmitSound(Sound("weapons/slam/mine_mode.wav"),85,130)
			self.Owner:RemoveAmmo( 1, self.Secondary.Ammo )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self.Owner:TakeKSAward( "Turret" )
			self:SetNextPrimaryFire( CurTime() + 1/(70/60) )
		end
	end
end
function SWEP:SecondaryAttack()
	return false
end