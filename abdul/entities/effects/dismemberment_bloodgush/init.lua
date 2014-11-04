
function EFFECT:Init(data)
	self.pos = data:GetOrigin()
	self.time = CurTime() + math.random(2, 6)
	self.Emitter = ParticleEmitter(self.pos)
	self.dir = VectorRand() * 0.5 + data:GetNormal() * 0.5
	
	if data:GetFlags() != nil then
		self.goretype = data:GetFlags()
	else
		self.goretype = 1
	end
	
	self.EffectEntity = data:GetEntity()
	self.EffectPhysBone = data:GetAttachment()
	self.EffectBone = data:GetScale()
end

function EFFECT:Think()
	if self.EffectEntity:IsValid() and self.EffectEntity:GetNWBool("boneisgibbed" .. self.EffectBone) then
		if math.random(1, 8) == 1 then
			if self.goretype == 1 then
				ParticleEffect("blood_impact_red_01", self.EffectEntity:GetPhysicsObjectNum(self.EffectPhysBone):GetPos(), self.EffectEntity:GetAngles(), self.EffectEntity)
				self.color = Color(175, 0, 0)
			elseif self.goretype == 2 then
				ParticleEffect("blood_impact_green_01", self.EffectEntity:GetPhysicsObjectNum(self.EffectPhysBone):GetPos(), self.EffectEntity:GetAngles(), self.EffectEntity)
				self.color = Color(math.random(230, 255), math.random(230, 255), 0)
			elseif self.goretype == 3 then
				ParticleEffect("blood_impact_red_01", self.EffectEntity:GetPhysicsObjectNum(self.EffectPhysBone):GetPos(), self.EffectEntity:GetAngles(), self.EffectEntity)
				ParticleEffect("blood_impact_green_01", self.EffectEntity:GetPhysicsObjectNum(self.EffectPhysBone):GetPos(), self.EffectEntity:GetAngles(), self.EffectEntity)
				self.color = Color(160, 235, 25)
			end
			
			if self.Emitter != nil then
				local particle = self.Emitter:Add("effects/blood_puff", self.EffectEntity:GetPhysicsObjectNum(self.EffectPhysBone):GetPos())
					particle:SetColor(self.color.r, self.color.g, self.color.b,255)//175, 0, 0, 255)
					particle:SetVelocity((self.dir * 0.95 + VectorRand() * 0.02) * math.Rand(300, 350))//VectorRand():GetNormal() * 50 -- sprays randomly in a circle //VectorRand() * 80 --sprays randomly
					particle:SetGravity(Vector(0, 0, -600))
					particle:SetStartSize(math.random(2, 5))
					particle:SetEndSize(math.random(2, 8))
					particle:SetDieTime(20)
					particle:SetLighting(true)
			end
		end
	end
	
	if CurTime() < self.time then
		return true
	else
		return false
	end
end

function EFFECT:Render()
end