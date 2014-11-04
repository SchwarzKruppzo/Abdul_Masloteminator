local meta = FindMetaTable("Player")
function meta:AbdulVoice( sound )
	if !self.Speaking then
		self:EmitSound( Sound( sound ), 80, 100 )
		self.Speaking = true
		local time = SoundDuration( sound )
		timer.Create( tostring(self:EntIndex()).."Speak",time, 1, function()
			if IsValid(self) then self.Speaking = false end
		end)
	end
end