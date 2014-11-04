function EFFECT:Init(data)
	self.Pos 		= data:GetOrigin()		
	self.DirVec 		= data:GetNormal()
	self.Emitter 		= ParticleEmitter( self.Pos )
	local ang = self.DirVec:Angle()
	for i=1,5 do
		local Flash = self.Emitter:Add( "sprites/light_glow02_add", self.Pos + self.DirVec*3 )
		
		if (Flash) then
			Flash:SetVelocity( self.DirVec )
			Flash:SetAirResistance( 200 )
			Flash:SetDieTime( 0.3 )
			Flash:SetStartAlpha( 255 )
			Flash:SetEndAlpha( 0 )
			Flash:SetStartSize( 64 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(50,150,255)	
		end
	end
	self.Emitter 		= ParticleEmitter( self.Pos )
	for i=1,5 do
		local Flash = self.Emitter:Add( "sprites/heatwave", self.Pos + self.DirVec*3 )
		
		if (Flash) then
			Flash:SetVelocity( self.DirVec )
			Flash:SetAirResistance( 200 )
			Flash:SetDieTime( 0.15 )
			Flash:SetStartAlpha( 255 )
			Flash:SetEndAlpha( 0 )
			Flash:SetStartSize( 64 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(0,200,255)	
		end
	end
	self.Emitter 		= ParticleEmitter( self.Pos )
	for i=1,5 do
		local Flash = self.Emitter:Add( "sprites/light_glow02_add", self.Pos + self.DirVec*3 )
		
		if (Flash) then
			Flash:SetVelocity( self.DirVec )
			Flash:SetAirResistance( 200 )
			Flash:SetDieTime( 0.15 )
			Flash:SetStartAlpha( 255 )
			Flash:SetEndAlpha( 0 )
			Flash:SetStartSize( 128 )
			Flash:SetEndSize( 0 )
			Flash:SetRoll( math.Rand(180,480) )
			Flash:SetRollDelta( math.Rand(-1,1) )
			Flash:SetColor(0,0,100)	
		end
	end
	
	
	
	local dynlight = DynamicLight(0)
		dynlight.Pos = self.Pos
		dynlight.Size = 32
		dynlight.Decay = 24
		dynlight.R = 0
		dynlight.G = 100
		dynlight.B = 255
		dynlight.Brightness = 6
		dynlight.DieTime = CurTime()+1.1
end
function EFFECT:Think( )
	return false
end
function EFFECT:Render()

end