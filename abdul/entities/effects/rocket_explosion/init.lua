function EFFECT:Init( data )
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Emitter = ParticleEmitter( self.Position )
	self.Scale = 1.2
	
	
	local GraphicTable = {}
	GraphicTable[1] = {
	p_count1 = 5,
	p_count2 = 5,
	p_count3 = 10,
	p_count4 = 15,
	p_count5 = 2}
	GraphicTable[2] = {
	p_count1 = 5,
	p_count2 = 10,
	p_count3 = 20,
	p_count4 = 25,
	p_count5 = 5}
	GraphicTable[3] = {
	p_count1 = 5,
	p_count2 = 25,
	p_count3 = 30,
	p_count4 = 50,
	p_count5 = 10}
	
	local gt = GraphicTable[GetConVar("abdulgraphic_explosion"):GetInt()]
	if gt == nil then gt = GraphicTable[3] end
	
	if GetConVar("abdulgraphic_explosion"):GetInt() == 0 then
		local explosion = EffectData()
		explosion:SetOrigin( self.Position)
		explosion:SetNormal( self.Normal)
		util.Effect( "Explosion", explosion )
		return
	end
	sound.Play( "weapons/explode" .. math.random(3, 5) .. ".wav", self.Position, 85, 100 )
	for i=1,gt.p_count1 do
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
			Flash:SetColor(255,255,255)	
		end
	end
	for i=1, gt.p_count2 do
		local Debris = self.Emitter:Add( "effects/fleck_cement"..math.random(1,2), self.Position )
		if (Debris) then
			Debris:SetVelocity ( self.Normal * math.random(100,600)+ VectorRand():GetNormalized() * math.random(100,600))
			Debris:SetDieTime( math.random( 1, 3) )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( math.random(5,10) )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-5, 5) )			
			Debris:SetAirResistance( 40 ) 			 			
			Debris:SetColor( 70,70,70 )
			Debris:SetGravity( Vector( 0, 0, -600) ) 	
		end
	end
	for i=0, gt.p_count3 do
		local Whisp = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Position )
		if (Whisp) then
			Whisp:SetVelocity(VectorRand():GetNormalized() * math.random( 200,1200) )
			Whisp:SetDieTime( math.Rand( 1 , 5 )  )
			Whisp:SetStartAlpha( math.Rand( 35, 50 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 150 )
			Whisp:SetEndSize( 100 )
			Whisp:SetRoll( math.Rand(150, 360) )
			Whisp:SetRollDelta( math.Rand(-2, 2) )			
			Whisp:SetAirResistance( 300 ) 			 
			Whisp:SetGravity( Vector( math.random(-40,40), math.random(-40,40), 0 ) ) 			
			Whisp:SetColor( 120,120,120 )
		end
	end
	local Density = gt.p_count4
	local Angle = self.Normal:Angle()
	for i=0, Density do	
		Angle:RotateAroundAxis(Angle:Forward(), (360/Density))
		local ShootVector = Angle:Up()
		local Smoke = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Position )
		if (Smoke) then
			Smoke:SetVelocity( ShootVector * math.Rand(50,1000) )
			Smoke:SetDieTime( math.Rand( 1 , 4 )  )
			Smoke:SetStartAlpha( math.Rand( 90, 120 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 40 )
			Smoke:SetEndSize( 70 )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-1, 1) )			
			Smoke:SetAirResistance( 300 ) 			 
			Smoke:SetGravity( Vector( math.Rand( -20 , 20 ), math.Rand( -20 , 20 ), math.Rand( 10 , 10 ) ) )			
			Smoke:SetColor( 90,83,68 )
		end
	end
	local Angle = self.Normal:Angle()

	for i = 1, gt.p_count5 do 
		Angle:RotateAroundAxis(Angle:Forward(), (360/15))
		local DustRing = Angle:Up()
		local RanVec = self.Normal*math.Rand(2, 6) + (DustRing*math.Rand(1, 4))	
		local magnit = 5
		for k = 3, magnit do
			local Rcolor = math.random(-20,20)
			local particle1 = self.Emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.Position )				
			particle1:SetVelocity((VectorRand():GetNormalized()*math.Rand(1, 2) * self.Size) + (RanVec*5*k*3.5))	
			particle1:SetDieTime( math.Rand( 0.5, 4 ))	

			particle1:SetStartAlpha( math.Rand( 90, 100 ) )			
			particle1:SetEndAlpha(0)	
			particle1:SetGravity((VectorRand():GetNormalized()*math.Rand(5, 10)* 5) + Vector(0,0,-50))
			particle1:SetAirResistance( 200+self.Scale*20 ) 		
			particle1:SetStartSize( (5*5)-((k/magnit)*5*3) )	
			particle1:SetEndSize( (20*5)-((k/magnit)*5) )
			particle1:SetRoll( math.random( -500, 500 )/100 )	

			particle1:SetRollDelta( math.random( -0.5, 0.5 ) )	
			particle1:SetColor( 90+Rcolor,83+Rcolor,68+Rcolor )
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end