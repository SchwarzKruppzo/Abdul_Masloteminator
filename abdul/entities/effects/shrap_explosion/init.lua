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
	p_count4 = 15}
	GraphicTable[2] = {
	p_count1 = 5,
	p_count2 = 10,
	p_count3 = 20,
	p_count4 = 25}
	GraphicTable[3] = {
	p_count1 = 5,
	p_count2 = 25,
	p_count3 = 30,
	p_count4 = 50}
	
	local gt = GraphicTable[GetConVar("abdulgraphic_explosion"):GetInt()]
	if gt == nil then gt = GraphicTable[3] end
	
	if GetConVar("abdulgraphic_explosion"):GetInt() == 0 then
		local explosion = EffectData()
		explosion:SetOrigin( self.Position)
		explosion:SetNormal( self.Normal)
		util.Effect( "HelicopterMegaBomb", explosion )
		return
	end
	for i=1,gt.p_count1 do
		local Flash = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Position  )
		if (Flash) then
			Flash:SetVelocity( self.Normal*100 )
			Flash:SetAirResistance( 200 )
			Flash:SetDieTime( 0.15 )
			Flash:SetStartAlpha( 255 )
			Flash:SetEndAlpha( 0 )
			Flash:SetStartSize( 200 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(255,255,255)	
		end
	end
	
	for i=1, gt.p_count2 do
		local Debris = self.Emitter:Add( "effects/fleck_cement"..math.random(1,2), self.Position )
		if (Debris) then
			Debris:SetVelocity ( self.Normal * math.random(100,510)+ VectorRand():GetNormalized() * math.random(100,520))
			Debris:SetDieTime( math.random( 0.5, 1) )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( 5 )
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
			Whisp:SetVelocity(VectorRand():GetNormalized() * math.random( 200,500) )
			Whisp:SetDieTime( 1  )
			Whisp:SetStartAlpha( math.Rand( 35, 50 ) )
			Whisp:SetEndAlpha( 0 )
			Whisp:SetStartSize( 50 )
			Whisp:SetEndSize( 50 )
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
			Smoke:SetDieTime( math.Rand( 0, 0.8 )  )
			Smoke:SetStartAlpha( math.Rand( 20, 40 ) )
			Smoke:SetEndAlpha( 0 )
			Smoke:SetStartSize( 40 )
			Smoke:SetEndSize( 70 )
			Smoke:SetRoll( math.Rand(0, 360) )
			Smoke:SetRollDelta( math.Rand(-1, 1) )			
			Smoke:SetAirResistance( 200 ) 			 
			Smoke:SetGravity( Vector( math.Rand( -200 , 200 ), math.Rand( -200 , 200 ), math.Rand( 10 , 100 ) ) )			
			Smoke:SetColor( 90,83,68 )
		end
	end
	
	local dynlight = DynamicLight(0)
		dynlight.Pos = data:GetOrigin() + Vector(0,0,5)
		dynlight.Size = 400
		dynlight.Decay = 20
		dynlight.R = 255
		dynlight.G = 150
		dynlight.B = 50
		dynlight.Brightness = 5
		dynlight.DieTime = CurTime() + 0.1
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end