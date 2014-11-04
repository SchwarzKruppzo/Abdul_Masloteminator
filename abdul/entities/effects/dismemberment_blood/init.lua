function EFFECT:Init(data)
	self.pos = data:GetOrigin()
	self.time = CurTime() + 125
	
	local Dir = VectorRand() * 0.5 + data:GetNormal() * 0.5
	local Speed = math.Rand(1000, 1500)
	
	if data:GetFlags() != nil then
		self.goretype = data:GetFlags()
	else
		self.goretype = 1
	end
	
	if self.goretype == 1 then
		self.color = Color(175, 0, 0)
	elseif self.goretype == 2 then
		self.color = Color(math.random(230, 255), math.random(230, 255), 0)
	elseif self.goretype == 3 then
		self.color = Color(160, 230, 0)
	end
	
	local emitter = ParticleEmitter(self.pos, true)
	
	if emitter != nil then
		for i = 1, math.random(5, 10) do
			local particle = emitter:Add("effects/blood_puff", self.pos)
				particle:SetColor(self.color.r, self.color.g, self.color.b, 255)
				particle:SetVelocity((Dir * 0.95 + VectorRand() * 0.02) * (Speed * (i /40)))//VectorRand():GetNormal() * 50 -- sprays randomly in a circle //VectorRand() * 80 --sprays randomly
				particle:SetGravity(Vector(0, 0, -600))
				particle:SetStartSize(math.random(2, 5))
				particle:SetEndSize(math.random(2, 8))
				particle:SetCollide(true)
				particle:SetCollideCallback(Collide)
				particle:SetDieTime(20)
				particle:SetLighting(true)
				particle:SetStartAlpha(math.random(240,250))
				particle:SetEndAlpha(math.random(200,220))
				particle:SetRoll(math.random(-80,80))
				particle:SetRollDelta(.4)
				particle:SetStartLength(1)
				particle:SetEndLength(5)
				particle.goretype = self.goretype
		end
	else
		print("Particle Overflow!!! Too many particles to spawn new ones. Reloading your game should fix this.")
	end
end

function Collide(particle, hitpos, hitnorm)
	if math.random(1,5) == 1 then
		if particle.goretype == 1 then
			util.Decal("Blood", hitpos + hitpos:GetNormal(), hitpos - hitpos:GetNormal())
		elseif particle.goretype == 2 then
			util.Decal("YellowBlood", hitpos + hitpos:GetNormal(), hitpos - hitpos:GetNormal())
		elseif particle.goretype == 3 then
			util.Decal("Blood", hitpos + hitpos:GetNormal(), hitpos - hitpos:GetNormal())
			util.Decal("YellowBlood", hitpos + hitpos:GetNormal(), hitpos - hitpos:GetNormal())
		end
	end
	local ang = hitnorm:Angle()
	
	if ang.r == 0 && ang.p == 270 then
		ang.y = math.random(0, 359)
	end

	particle:SetAngleVelocity(Angle(0,0,0))
	particle:SetAngles(ang)
	particle:SetVelocity(Vector(0,0,0))
	particle:SetGravity(Vector(0,0,0))
	particle:SetPos(hitpos + hitnorm)
	particle:SetDieTime(100)
end

function EFFECT:Think()
	if CurTime() < self.time then
		return true
	else
		return false
	end
end

function EFFECT:Render()
end



