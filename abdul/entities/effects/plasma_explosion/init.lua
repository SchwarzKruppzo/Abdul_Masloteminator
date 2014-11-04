function EFFECT:Init( data )
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Emitter = ParticleEmitter( self.Position )
self.Scale = 1.2
	for i=1,5 do
		local Flash = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Position  )
		if (Flash) then
			Flash:SetVelocity( self.Normal*100 )
			Flash:SetAirResistance( 200 )
			Flash:SetDieTime( 0.15 )
			Flash:SetStartAlpha( 255 )
			Flash:SetEndAlpha( 0 )
			Flash:SetStartSize( 400 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(0,255,0)	
		end
	end
	for i=1, 15 do
		local Debris = self.Emitter:Add( "sprites/light_glow02_add", self.Position )
		if (Debris) then
			Debris:SetVelocity ( self.Normal * 100+ VectorRand():GetNormalized() * 300)
			Debris:SetDieTime( math.random( 1, 2) )
			Debris:SetStartAlpha( math.Rand(0,255) )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( math.random(5,34) )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-5, 5) )			
			Debris:SetAirResistance( 40 ) 			 			
			Debris:SetColor( 0,255,0 )
			Debris:SetGravity( Vector( 0, 0, -200) ) 	
		end
	end
	for i=0, 30 do
		local Whisp = self.Emitter:Add( "effects/fire_cloud"..math.random(1,2), self.Position )
		if (Whisp) then
			Whisp:SetVelocity(VectorRand():GetNormalized() * math.random( 200,1200) )
			Whisp:SetDieTime( math.Rand( 1 , 2 )  )
			Whisp:SetStartAlpha( math.Rand( 15, 20 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 120 )
			Whisp:SetEndSize( 100 )
			Whisp:SetRoll( math.Rand(150, 360) )
			Whisp:SetRollDelta( math.Rand(-2, 2) )			
			Whisp:SetAirResistance( 300 ) 			 
			Whisp:SetGravity( Vector( math.random(-40,40), math.random(-40,40), 0 ) ) 			
			Whisp:SetColor( 10,120,130 )
		end
	end
	local Density = 15
	local Angle = self.Normal:Angle()
	for i=0, Density do	
		Angle:RotateAroundAxis(Angle:Forward(), (360/Density))
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "effects/fire_cloud"..math.random(1,2), self.Position )
		if (Smoke) then
			Smoke:SetVelocity( ShootVector * math.Rand(50,1000) )
			Smoke:SetDieTime( math.Rand( 1 , 2 )  )
			Smoke:SetStartAlpha( 60 )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 120 )
			Smoke:SetEndSize( 2 )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-1, 1) )			
			Smoke:SetAirResistance( 300 ) 			 
			Smoke:SetGravity( Vector( math.Rand( -20 , 20 ), math.Rand( -20 , 20 ), math.Rand( 10 , 10 ) ) )			
			Smoke:SetColor( 12,120,15 )
		end
	end
	local Density = 5
	local Angle = self.Normal:Angle()
	for i=0, Density do	
		Angle:RotateAroundAxis(Angle:Forward(), (360/Density))
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "effects/fire_cloud"..math.random(1,2), self.Position )
		if (Smoke) then
			Smoke:SetVelocity( self.Normal * math.random(100,600)+ VectorRand():GetNormalized() * math.random(100,600) )
			Smoke:SetDieTime( math.Rand( 1 , 2 )  )
			Smoke:SetStartAlpha( 10 )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 100 )
			Smoke:SetEndSize( 2 )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-1, 1) )			
			Smoke:SetAirResistance( 300 ) 			 
			Smoke:SetGravity( Vector( 0,0, 0 ) )			
			Smoke:SetColor( 12,0,255 )
		end
	end
	local Angle = self.Normal:Angle()

	for i = 1, 8 do 
		Angle:RotateAroundAxis(Angle:Forward(), (360/15))
		local DustRing = Angle:Up()
		local RanVec = self.Normal*math.Rand(2, 6) + (DustRing*math.Rand(1, 4))	
		local magnit = 5
		for k = 3, magnit do
			local Rcolor = 0
			local particle1 = self.Emitter:Add( "sprites/light_glow02_add", self.Position )				
			particle1:SetVelocity((VectorRand():GetNormalized()*math.Rand(1, 2) * self.Size) + (RanVec*5*k*3.5))	
			particle1:SetDieTime( math.Rand( 0.5, 1 ))	

			particle1:SetStartAlpha( 10 )			
			particle1:SetEndAlpha(0)	
			particle1:SetGravity((VectorRand():GetNormalized()*math.Rand(5, 10)* 5) + Vector(0,0,-50))
			particle1:SetAirResistance( 200+self.Scale*20 ) 		
			particle1:SetStartSize( (5*5)-((k/magnit)*5*3) )	
			particle1:SetEndSize( (20*5)-((k/magnit)*5) )
			particle1:SetRoll( math.random( -500, 500 )/100 )	

			particle1:SetRollDelta( math.random( -0.5, 0.5 ) )	
			particle1:SetColor( math.random(0,1)*120,math.random(0,1)*255,200 )
		end
	end
	self.dynlight = DynamicLight(0)
		self.dynlight.Pos = self:GetPos()
		self.dynlight.Size = 500
		self.dynlight.Decay = 550
		self.dynlight.R = 2
		self.dynlight.G = 255
		self.dynlight.B = 122
		self.dynlight.Brightness = 5
		self.dynlight.DieTime = CurTime()+0.15
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end