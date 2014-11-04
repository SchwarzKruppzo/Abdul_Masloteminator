if SERVER then
	AddCSLuaFile()
end
if CLIENT then
    SWEP.PrintName = "M18 Claymore"
    SWEP.Slot = 3
    SWEP.SlotPos = 4
end
SWEP.HoldType			= "slam"
SWEP.Category = "Abdul Weapons"
SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true
SWEP.ViewModel = "models/weapons/v_smg1.mdl"
SWEP.WorldModel   = "models/w_claymore.mdl"
SWEP.Primary.ClipSize	= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.MaxAmmo		= 4
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "claymore"
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
	owner:AbdulVoice( "abdul/wep3.wav" )
	owner:GiveAmmo( math.abs(owner:GetAmmoCount(  self.Secondary.Ammo ) - self.Secondary.MaxAmmo ), self.Secondary.Ammo )
end
function SWEP:DrawWeaponSelection()
end
function SWEP:PrintWeaponInfo()
end
local function FindMines( pos )
	for k,v in pairs(ents.FindInSphere(pos,1)) do	
		if v:GetClass() == "ent_claymore" then
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
		local curangle = Angle(0,angle.y - 90,0)
		local shootpos = self.Owner:GetShootPos()
		local aimvector = self.Owner:GetAimVector()
		local up = self.Owner:GetUp()
		local right = self.Owner:GetRight()
		local forward = self.Owner:GetForward()
		local pos = shootpos + aimvector * 42
		
		local trMain = util.TraceLine({
			start = shootpos,
			endpos = pos,
			filter = self.Owner
		})
		local trMain2 = util.TraceLine({
			start = trMain.HitPos,
			endpos = trMain.HitPos + trMain.Normal,
			filter = self.Owner
		})
		local trRight = util.TraceLine({
			start = trMain.HitPos,
			endpos = trMain.HitPos + right * 6,
			filter = self.Owner
		})
		local trLeft = util.TraceLine({
			start = trMain.HitPos,
			endpos = trMain.HitPos - right * 6,
			filter = self.Owner
		})
		local trForward = util.TraceLine({
			start = trMain.HitPos + up * 3,
			endpos = trMain.HitPos + up * 3 + forward,
			filter = self.Owner
		})
		local trBack = util.TraceLine({
			start = trMain.HitPos + up * 3,
			endpos = trMain.HitPos + up * 3 - forward,
			filter = self.Owner
		})
		if trMain.Hit and !trBack.Hit and !trForward.Hit and !trRight.Hit and !trLeft.Hit and !FindMines( trMain.HitPos ) and self.Owner:IsPlantLimit( "Claymore" ) then
			self:SetCanPlant(true)
		elseif trMain.Hit and !trBack.Hit and trForward.Hit and !trRight.Hit and !trLeft.Hit and !FindMines( trMain.HitPos ) and self.Owner:IsPlantLimit( "Claymore" ) then
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
		local curangle = Angle(0,angle.y - 90,0)
		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 42,
			filter = self.Owner
		})
		if !IsValid(self.GhostEntity) then
			self.GhostEntity = ents.CreateClientProp()
			self.GhostEntity:SetModel("models/w_claymore_legs.mdl")
			self.GhostEntity:SetPos( tr.HitPos )
			self.GhostEntity:SetAngles( curangle )
			self.GhostEntity:SetMaterial("models/props_combine/statisshield_sheet")
		else
			if self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0 then	
				self.GhostEntity:SetNoDraw(true)
			else
				self.GhostEntity:SetNoDraw(false)
			end
			self.GhostEntity:SetPos( tr.HitPos )
			self.GhostEntity:SetAngles( curangle )
			if self:GetCanPlant() then
				self.GhostEntity:SetColor(Color(255,255,255,255))
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

		local pos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 42
		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = pos,
			filter = self.Owner
		})
		local angle = self.Owner:EyeAngles()
		local curangle = Angle(0,angle.y - 90,0)
		//if !tr2.Hit and !tr3.Hit and tr4.Hit and !FindMines( pos ) and self.Owner.Claymores < 6 then
		if self:GetCanPlant() then
			local ent = ents.Create ("ent_claymore");
			ent:SetPos( tr.HitPos );
			ent:SetAngles( curangle );
			ent:SetThowBy( self.Owner )
			ent:Spawn()
			ent:Activate()
			ent:EmitSound(Sound("weapons/slam/mine_mode.wav"),85,130)
			self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self:SetNextPrimaryFire( CurTime() + 1/(70/60) )
			self.Owner:AddPlantLimit("Claymore")
		end
	end
	
	
	
end
function SWEP:SecondaryAttack()
	return false
end