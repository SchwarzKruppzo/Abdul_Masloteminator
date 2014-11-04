function EFFECT:Init(data)
	if not IsValid(data:GetEntity()) then return end
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	local att = self.WeaponEnt:GetAttachment( self.Attachment )
	if !att then
		att = {Ang = Angle(0,0,0), Pos = self.WeaponEnt:GetPos()}
	end
	local angle = att.Ang
	local AddVel = Vector(0,0,0)
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		
		
		
		
		for i=0,2 do
			local particle = emitter:Add("particle/smokesprites_000"..math.random(1,9), self.Position)
			particle:SetVelocity(100*i*angle:Forward())
			particle:SetDieTime(math.Rand(0.05,0.3))
			particle:SetStartAlpha(math.Rand(20,25))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.random(6,22))
			particle:SetEndSize(math.Rand(25,64))
			particle:SetRoll(math.Rand(180,480))
			particle:SetRollDelta(math.Rand(-3,3))
			particle:SetColor(170,170,170)
			particle:SetAirResistance(350)
		end
		for i=-1,2 do 
			local particle = emitter:Add("particle/smokesprites_000"..math.random(1,9), self.Position)
			particle:SetVelocity(100*i*angle:Up())
			particle:SetDieTime(math.Rand(0.2,0.3))
			particle:SetStartAlpha(math.Rand(20,40))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.random(2,3))
			particle:SetEndSize(math.Rand(14,16))
			particle:SetRoll(math.Rand(180,480))
			particle:SetRollDelta(math.Rand(-1,1))
			particle:SetColor(200,200,200)
			particle:SetAirResistance(160)
		end
		for i=0,2 do 
			local particle = emitter:Add("effects/muzzleflash"..math.random(1,4), self.Position+(angle:Forward()*i*2))
			particle:SetVelocity((angle:Forward()*i*5))
			particle:SetDieTime(0.05)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(32-i)
			particle:SetEndSize(12-i)
			particle:SetRoll(math.Rand(180,480))
			particle:SetRollDelta(math.Rand(-1,1))
			particle:SetColor(255,255,255)	
		end
		
		local Ang2 = Vector(0,0,0):Angle()
		self.Scale = 0.01
		self.Size = 0.01
		local pos = self.WeaponEnt:GetPos()
		for i = 1,5 do 
			Ang2:RotateAroundAxis(Ang2:Forward(), (360/5))
			local DustRing = Ang2:Up()
			local RanVec = Vector(0,0,0)*math.Rand(2, 6) + (DustRing*math.Rand(1, 4))	
			local magnit = 5
			for k = 3, magnit do
				local Rcolor = math.random(-20,20)
				local particle1 = emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos )				
				particle1:SetVelocity((VectorRand():GetNormalized()*math.Rand(1, 4) * 5) + (RanVec*5*k*3.5))	
				particle1:SetDieTime( math.Rand( 0.5, 1 ))	

				particle1:SetStartAlpha( math.Rand( 10, 15 ) )			
				particle1:SetEndAlpha(0)	
				particle1:SetGravity((VectorRand():GetNormalized()*math.Rand(5, 10)* 2) + Vector(0,0,-50))
				particle1:SetAirResistance( 200+self.Scale*20 ) 		
				particle1:SetStartSize( (5*5)-((k/magnit)*5*3) )	
				particle1:SetEndSize( (20*5)-((k/magnit)*5) )
				particle1:SetRoll( math.random( -500, 500 )/100 )	

				particle1:SetRollDelta( math.random( -0.5, 0.5 ) )	
				particle1:SetColor( 140+Rcolor,130+Rcolor,120+Rcolor )
			end
		end
		emitter:Finish()
	end
	local dynlight = DynamicLight(0)
		dynlight.Pos = self.Position
		dynlight.Size = 200
		dynlight.Decay = 500
		dynlight.R = 255
		dynlight.G = 150
		dynlight.B = 50
		dynlight.Brightness = 3
		dynlight.DieTime = CurTime() + 0.1
end


function EFFECT:Think()

	return false
end


function EFFECT:Render()
end