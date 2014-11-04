ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true

ENT.SearchDistance = 800
ENT.MinimumAimDot = -0.8
ENT.PosePitch = 0
ENT.PoseYaw = 0

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Target" )
	self:NetworkVar( "Bool", 0, "Firing" )
	self:NetworkVar( "Float", 0, "TargetReceived" )
	self:NetworkVar( "Float", 1, "TargetLost" )
	self:NetworkVar( "Entity", 1, "ObjectOwner" )
	self:NetworkVar( "Float", 2, "NextFire" )
	self:NetworkVar( "Float", 3, "EHealth" )
end

function ENT:GetLocalAnglesToTarget(target)
	return self:WorldToLocalAngles(self:GetAnglesToTarget(target))
end

function ENT:GetAnglesToTarget(target)
	return self:GetAnglesToPos(self:GetTargetPos(target))
end

function ENT:GetLocalAnglesToPos(pos)
	return self:WorldToLocalAngles(self:GetAnglesToPos(pos))
end

function ENT:GetAnglesToPos(pos)
	return (pos - self:ShootPos()):Angle()
end
function TrueVisible(posa, posb,filter)
	local filt = {filter}
	filt = table.Add(filt, player.GetAll())

	return not util.TraceLine({start = posa, endpos = posb, filter = filt}).Hit
end
function ENT:IsValidTarget(target)
	return target:IsPlayer() and target:Alive() and self:GetForward():Dot(self:GetAnglesToTarget(target):Forward()) >= self.MinimumAimDot and TrueVisible(self:ShootPos(), self:GetTargetPos(target), self)
end
local meta = FindMetaTable("Player")
function meta:TraceLine(distance, _mask)
	local vStart = self:GetShootPos()
	return util.TraceLine({start=vStart, endpos = vStart + self:GetAimVector() * distance, filter = self, mask = _mask})
end
function ENT:GetManualTrace()
	local owner = self:GetObjectOwner()
	local filter = {}
	table.insert(filter, self)
	return owner:TraceLine(4096, MASK_SOLID, filter)
end
function ENT:GetScanFilter()
	local filter = {self:GetObjectOwner()}
	if self:GetObjectOwner():GetNWString("CTeam") != "" then
		for k,v in pairs(cteam.GetPlayers( self:GetObjectOwner():GetNWString("CTeam") )) do
			table.insert(filter,v)
		end
	end
	filter[#filter + 1] = self
	return filter
end
ENT.NextCache = 0
function ENT:GetCachedScanFilter()
	if CurTime() < self.NextCache and self.CachedFilter then return self.CachedFilter end

	self.CachedFilter = self:GetScanFilter()
	self.NextCache = CurTime() + 1

	return self.CachedFilter
end

local tabSearch = {mask = MASK_SHOT}
function ENT:SearchForTarget()
	local shootpos = self:ShootPos()

	tabSearch.start = shootpos
	tabSearch.endpos = shootpos + self:GetGunAngles():Forward() * self.SearchDistance
	tabSearch.filter = self:GetCachedScanFilter()
	local tr = util.TraceLine(tabSearch)
	local ent = tr.Entity
	if ent and ent:IsValid() and self:IsValidTarget(ent) then
		return ent
	end
end
function ENT:GetTargetPos( target )
	local boneid = target:GetHitBoxBone(HITGROUP_HEAD, 0)
	if boneid and boneid > 0 then
		local p, a = target:GetBonePosition(boneid)
		if p then
			return p
		end
	end

	return target:LocalToWorld(target:OBBCenter())
end
function ENT:DefaultPos()
	return self:GetPos() + self:GetUp() * 55
end
function ENT:ShootPos()
	local attachid = self:LookupAttachment("eyes")
	if attachid then
		local attach = self:GetAttachment(attachid)
		if attach then return attach.Pos end
	end

	return self:DefaultPos()
end
function ENT:LaserPos()
	local attachid = self:LookupAttachment("light")
	if attachid then
		local attach = self:GetAttachment(attachid)
		if attach then return attach.Pos end
	end

	return self:DefaultPos()
end
ENT.LightPos = ENT.LaserPos
function ENT:GetGunAngles()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), -self.PosePitch)
	ang:RotateAroundAxis(ang:Up(), self.PoseYaw)
	return ang
end
function ENT:SetTarget(ent)
	if ent:IsValid() then
		self:SetTargetReceived(CurTime())
	else
		self:SetTargetLost(CurTime())
	end
	self:SetDTEntity(0, ent)
end
function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end
function ENT:ClearTarget()
	self:SetTarget(NULL)
end

util.PrecacheSound("npc/turret_floor/die.wav")
util.PrecacheSound("npc/turret_floor/active.wav")
util.PrecacheSound("npc/turret_floor/deploy.wav")
util.PrecacheSound("npc/turret_floor/shoot1.wav")
util.PrecacheSound("npc/turret_floor/shoot2.wav")
util.PrecacheSound("npc/turret_floor/shoot3.wav")
