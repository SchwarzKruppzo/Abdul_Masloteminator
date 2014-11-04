include("shared.lua")

function ENT:Initialize()
	self.BeamColor = Color(255, 0, 0, 255)
	self.ScanningSound = CreateSound(self, "npc/turret_wall/turret_loop1.wav")
	local size = self.SearchDistance + 32
	local nsize = -size
	self:SetRenderBounds(Vector(nsize, nsize, nsize * 0.25), Vector(size, size, size * 0.25))
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.NextEmit = 0
end

function ENT:Think()
	if self:GetObjectOwner():IsValid() and self:GetMaterial() == "" then
		self.ScanningSound:PlayEx(0.55, 100 + math.sin(CurTime()))
	else
		self.ScanningSound:Stop()
	end
	if IsValid(self.Emitter) then
		self.Emitter:SetPos(self:GetPos())
	end
end

function ENT:OnRemove()
	self.ScanningSound:Stop()
	if IsValid(self.Emitter) then
		self.Emitter:Finish()
	end
end

function ENT:SetTurretHealth(health)
	self:SetDTFloat(3, health)
end

local smokegravity = Vector(0, 0, 200)
local aScreen = Angle(0, 270, 60)
local vScreen = Vector(0, -2, 45)
function ENT:Draw()

	self:DrawModel()
	local healthpercent = self:GetEHealth() / 300

	if healthpercent <= 0.5 and CurTime() >= self.NextEmit then
		self.NextEmit = CurTime() + 0.05

		local particle = self.Emitter:Add("particles/smokey", self:DefaultPos())
		particle:SetStartAlpha(180)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(8, 32))
		local sat = healthpercent * 360
		particle:SetColor(sat, sat, sat)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(8, 64))
		particle:SetGravity(smokegravity)
		particle:SetDieTime(math.Rand(0.8, 1.6))
		particle:SetAirResistance(150)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-4, 4))
		particle:SetCollide(true)
		particle:SetBounce(0.2)
	end
end

local matBeam = Material("effects/laser1")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	if self:GetMaterial() ~= "" then return end
	local colBeam = self.BeamColor
	local rate = FrameTime() * 200
	colBeam.r = math.Approach(colBeam.r, 255, rate)
	colBeam.g = math.Approach(colBeam.g, 0, rate)
	colBeam.b = math.Approach(colBeam.b, 0, rate)

	
	local attach = ""
	local attachid = self:LookupAttachment("light")
	if attachid then
		attach = self:GetAttachment(attachid)
	end
	
	
	
	local tabSearch = {mask = MASK_SHOT}
	local shootpos = self:ShootPos()
	tabSearch.start = attach.Pos
	tabSearch.endpos = attach.Pos + attach.Ang:Forward() * self.SearchDistance
	tabSearch.filter = self:GetCachedScanFilter()
	local tr = util.TraceLine(tabSearch)
	
	
	render.SetMaterial(matBeam)
	render.DrawBeam(tr.StartPos, tr.HitPos, 4, 0, 1, colBeam)
	render.SetMaterial(matGlow)
	render.DrawSprite(tr.StartPos + attach.Ang:Forward() * 2, 16, 16, colBeam)
	render.DrawSprite(tr.HitPos, 8, 8, colBeam)
end
