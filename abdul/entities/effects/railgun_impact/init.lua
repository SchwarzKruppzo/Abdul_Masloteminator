function EFFECT:Init(data)
	self.Col = data:GetStart()
	self.Color = Color( self.Col.x, self.Col.y, self.Col.z )
	local dynlight = DynamicLight(0)
		dynlight.Pos = data:GetOrigin()
		dynlight.Size = 32
		dynlight.Decay = 24
		dynlight.R = self.Color.r
		dynlight.G = self.Color.g
		dynlight.B = self.Color.b
		dynlight.Brightness = 6
		dynlight.DieTime = CurTime()+1.1
end

function EFFECT:Render()

end