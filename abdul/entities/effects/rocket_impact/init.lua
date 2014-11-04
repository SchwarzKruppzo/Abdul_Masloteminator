function EFFECT:Init(data)
	local dynlight = DynamicLight(0)
		dynlight.Pos = data:GetOrigin()
		dynlight.Size = 500
		dynlight.Decay = 20
		dynlight.R = 255
		dynlight.G = 150
		dynlight.B = 50
		dynlight.Brightness = 5
		dynlight.DieTime = CurTime() + 0.1
end

function EFFECT:Render()

end