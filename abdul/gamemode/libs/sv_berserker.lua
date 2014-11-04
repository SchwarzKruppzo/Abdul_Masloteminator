local meta = FindMetaTable("Player")
function meta:DoBerserk()
	self:SetHealth( 1000 )
	self:SetRunSpeed( 600 )
	self:SetWalkSpeed( 600 )
	self.WeaponCache = {}
	for k,v in pairs(self:GetWeapons()) do
		table.insert(self.WeaponCache,v:GetClass())
	end
	self:StripWeapons()
	self:Give("abdul_machete")
	self:SetNWBool( "IsBerserk", true )
	self.NextBerserk = CurTime() + 60
	Notify( ply, Color(255,255,255),"-Режим Берсеркера запущен на 1 минуту." )
end
function meta:IsBerserk()
	return self:GetNWBool( "IsBerserk" )
end
hook.Add("PlayerTick","_BSRemove",function( ply )
	if ply:IsBerserk() then
		if ply.NextBerserk then
			if CurTime() > ply.NextBerserk then
				ply:SetHealth( 100 )
				ply:SetRunSpeed( 450 )
				ply:SetWalkSpeed( 450 )
				ply:StripWeapons()
				for k,v in pairs(ply.WeaponCache) do
					ply:Give(v)
				end
				Notify( ply, Color(255,255,255),"-Режим Берсеркера закончился." )
				ply:SetNWBool( "IsBerserk", false )
				ply.NextBerserk = nil
			end
		end
	end
end)