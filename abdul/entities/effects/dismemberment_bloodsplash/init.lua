Sounds = {"physics/flesh/flesh_bloody_break.wav",
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav"}

function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	self.time = CurTime() + 20
	
	if data:GetFlags() != nil then
		self.goretype = data:GetFlags()
	else
		self.goretype = 1
	end
	
	local LightColor = render.GetLightColor(Pos) * 255
	LightColor.r = math.Clamp(LightColor.r, 70, 255)
	LightColor.g = math.Clamp(LightColor.g, 70, 255)
	
	self.color = Color(0,0,0,0)
	
	if self.goretype == 1 then
		util.Decal("Blood", Pos + Norm*10, Pos - Norm*10)
		self.color = Color(LightColor.r * 0.5, 0, 0, 255)
	elseif self.goretype == 2 then
		util.Decal("YellowBlood", Pos + Norm*10, Pos - Norm*10)
		self.color = Color(LightColor.r * 0.5, LightColor.g * 0.5, 0, 255)
	elseif self.goretype == 3 then
		util.Decal("Blood", Pos + Norm*10, Pos - Norm*10)
		util.Decal("YellowBlood", Pos + Norm*10, Pos - Norm*10)
		self.color = Color(LightColor.r * 0.5, 0, 0, 255)
	end
		
	local emitter = ParticleEmitter(Pos)
	if emitter != nil then
		local particle = emitter:Add("effects/blood_core", Pos)
			particle:SetVelocity(Norm)
			particle:SetDieTime(math.Rand(1.0, 2.0))
			particle:SetStartAlpha(255)
			particle:SetStartSize(math.Rand(16, 32))
			particle:SetEndSize(math.Rand(32, 64))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetColor(self.color.r, self.color.g, 0)
				
		emitter:Finish()
	end

	//util.Decal("Blood", Pos + Norm*10, Pos - Norm*10)
	
	if math.random(1, 3) == 1 then
		// This sound makes my stomach go funny
		sound.Play(table.Random(Sounds), self:GetPos(), 75, math.Rand(70, 140), 1)
	end

	// If we hit the ceiling drip blood randomly for a while
	if (Norm.z < -0.5) then
		self.DieTime 		= CurTime() + 10
		self.Pos 			= Pos
		self.NextDrip 		= 0;
		self.LastDelay		= 0;
	end
end

function EFFECT:Think()
	if (!self.DieTime) then return false end
	if (self.DieTime < CurTime()) then return false end

	if (self.NextDrip > CurTime()) then return true end
	
	self.LastDelay = self.LastDelay + math.Rand(0.1, 0.2)
	self.NextDrip = CurTime() + self.LastDelay

	local emitter = ParticleEmitter(self.Pos)
	
		local RandVel = VectorRand() * 16
		RandVel.z = 0
		
		if IsValid(emitter) then
			local particle = emitter:Add("effects/blooddrop", self.Pos + RandVel)
			if (particle) then
				particle:SetVelocity(Vector( 0, 0, math.Rand( -300, -150 ) ))
				particle:SetDieTime(1)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(2)
				particle:SetEndSize(0)
				particle:SetColor(self.color.r, self.color.g, 0)
			end
			
			emitter:Finish()
		end

	if CurTime() < self.time then
		return true
	else
		return false
	end
end

function EFFECT:Render()
end