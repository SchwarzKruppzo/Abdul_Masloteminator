Plants = {}
Plants["Claymore"] = 6
Plants["50cal"] = 2

local meta = FindMetaTable("Player")

function meta:GetPlantLimit( name )
	if not Plants[ name ] then return 0 end
	return self:GetNWInt( name )
end
function meta:GetPlantLimitMax( name )
	if not Plants[ name ] then return 0 end
	return Plants[ name ]
end
function meta:IsPlantLimit( name )
	if not Plants[ name ] then return end
	if self:GetPlantLimit( name ) < Plants[ name ] then
		return true
	end
end
if SERVER then
	function meta:ResetPlantLimit()
		for k,v in pairs(Plants) do
			if k == "50cal" then continue end
			self:SetNWInt( k, 0 )
		end
	end
	function meta:AddPlantLimit( name )
		if not Plants[ name ] then return end
		if self:IsPlantLimit( name ) then
			self:SetNWInt( name, self:GetPlantLimit( name ) + 1 )
		end
	end
	function meta:RemPlantLimit( name )
		if not Plants[ name ] then return end
		local var = self:GetPlantLimit( name ) - 1 
		var = math.Clamp( var, 0, 1337 )
		self:SetNWInt( name, var )
	end
end