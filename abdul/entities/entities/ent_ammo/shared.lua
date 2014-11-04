ENT.Type = "anim"
ENT.Colors = {}
ENT.Colors["rail"] = Color(20,200,20)
ENT.Colors["uranium"] = Color(100,100,255)
ENT.Colors["RPG_Round"] = Color(200,0,0)
ENT.Colors["PulseCell"] = Color(120,180,255)
ENT.Colors["ak47"] = Color(255,100,0)
ENT.Colors["shotbuck"] = Color(100,100,50)
ENT.Colors["mp7"] = Color(255,255,255)
ENT.Colors["ShrapBomb"] = Color(127,50,0)
ENT.Colors["awm"] = Color(127,50,220)
ENT.Colors["plasma"] = Color(0,0,220)

if CLIENT then
	surface.CreateFont("ENTAMMO",{font = "Calibri",size = 128,weight = 1000})
	function ENT:Initialize()
		self.OriginPos = self:GetPos()
		self.Spin = 0
	end
	function ENT:Draw()
		self:SetRenderOrigin(self.OriginPos + Vector(0,0,math.abs(math.sin(RealTime() * 1) *5.5)))
		self:SetupBones()
		self:DrawModel()
		self.Spin = self.Spin + 0.4
		if self.Spin >= 360 then
			self.Spin = -360
		end
		self:SetAngles(Angle(0,self.Spin,0))
		
		local ang = self:GetAngles()
		ang:RotateAroundAxis( ang:Forward(),90 )
		local pos = self:GetPos() + self:GetUp() * 13 + self:GetRight()*14
		cam.Start3D2D( pos, ang, 0.035 )
				draw.RoundedBox(0,-345,-165,200*3.65,200*2.6,Color(40,40,40,255))
                draw.DrawText(getLanguage( self:GetAmmoTyp() ), "ENTAMMO", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
        cam.End3D2D()
		
		local ang = self:GetAngles()
		ang:RotateAroundAxis( ang:Forward(),90 )
		ang:RotateAroundAxis( ang:Right(),180 )
		local pos = self:GetPos() + self:GetUp() * 13 - self:GetRight()*12.5 + self:GetForward()*1.2
		cam.Start3D2D( pos, ang, 0.035 )
				draw.RoundedBox(0,-345,-165,200*3.65,200*2.6,Color(40,40,40,255))
                draw.DrawText(getLanguage( self:GetAmmoTyp() ), "ENTAMMO", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
        cam.End3D2D()
	end
	function ENT:IsTranslucent()
		return true
	end
else
	AddCSLuaFile()
	function ENT:SpawnFunction(ply, tr)
		if (!tr.Hit) then return end
		local SpawnPos = tr.HitPos + tr.HitNormal * 35
		self.Spawn_angles = ply:GetAngles()
		self.Spawn_angles.pitch = 0
		self.Spawn_angles.roll = 0
		self.Spawn_angles.yaw = self.Spawn_angles.yaw
		local ent = ents.Create(self.EntName)
		ent:SetPos(SpawnPos)
		ent:SetAngles(self.Spawn_angles)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/Items/item_item_crate_dynamic.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetAngles(Angle(0,90,0))
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetModelScale(0.8, 0)
		self.HasAmmo = true
		if self.Colors[self:GetAmmoTyp()] then
			self:SetColor(self.Colors[self:GetAmmoTyp()])
		end
	end
	function ENT:Think()
		if self.RespawnTime and CurTime() >= self.RespawnTime then
			self.RespawnTime = nil
			self.HasAmmo = true
			self:SetNoDraw(false)
			self:EmitSound("weapons/physcannon/physcannon_claws_close.wav")
		end
		for k,v in pairs (player.GetAll()) do
			if v:IsSpectator() then continue end
			if v:GetPos():Distance(self:GetPos()) < 50 and self.HasAmmo == true then
				//if v:GetAmmoCount( self:GetAmmoTyp() ) < self.MaxAmmo then
					self.HasAmmo = false
					self:SetNoDraw(true)
					self.RespawnTime = CurTime() + GetConVar("abdul_ammo_restime"):GetInt()
					self:EmitSound("items/ammo_pickup.wav",70,100)
					v:GiveAmmo( self.MaxAmmo, self:GetAmmoTyp() );
					hook.Call("PlayerPickupAmmo",GAMEMODE,v,self:GetAmmoTyp())
				//end
			end
		end
	end

end
function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "AmmoTyp" );
end