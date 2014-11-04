ENT.Type = "anim"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Seed = 1
if CLIENT then
	local matWireframe = Material("models/debug/debugwhite")
	local matWhite = Material("models/props_combine/portalball001_sheet")
	
	local params = {
		["$basetexture"] = "sprites/glow_test02",
		["$additive"] = 1,
		["$translucent"] = 1,
		["$vertexcolor"] = 1,
	}
	local matGlow = CreateMaterial("GlowTest2282","UnlitGeneric",params)
	function ENT:Initialize()
		self.Spin = 0
		self.Point = util.GetPixelVisibleHandle()
		
		
	end
	function ENT:Think()
		self.Dyn = DynamicLight(self.Entity:EntIndex())
		self.Dyn.Pos = self.Entity:GetPos() + self.Entity:GetUp()*16
		self.Dyn.Size = 128
		self.Dyn.Decay = 0
		self.Dyn.R = 255
		self.Dyn.G = 255
		self.Dyn.B = 255
		self.Dyn.Brightness = 5
		self.Dyn.DieTime = CurTime() + 0.01
	end
	function ENT:DrawTranslucent()
		local LightNrm = self.Entity:GetAngles():Up()
		local ViewNormal = self.Entity:GetPos() - EyePos()
		local Distance = ViewNormal:Length()
		ViewNormal:Normalize()
		local ViewDot = 1
		local LightPos = self:GetPos()+ self:GetUp() * 32
		if ( ViewDot >= 0 ) then
			local Visibile	= util.PixelVisible( LightPos, 8, self.Entity.Point )	
			
			if (!Visibile) then return end
			local Size = math.Clamp( Distance * Visibile * ViewDot * 2, 0, 200 )
			Distance = math.Clamp( Distance, 32, 800 )
			local Alpha = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 255 )
			render.SetMaterial(Material("sprites/light_ignorez"))
			render.DrawSprite( self:GetPos()+ self:GetUp() * 32, Size*2,Size*2,Color(50,50,50,Alpha))
			render.DrawSprite( self:GetPos()+ self:GetUp() * 32, Size,Size,Color(255,255,255,Alpha))
		end
		self:SetupBones()
		self:DrawModel()
		self.Spin = self.Spin + 1
		if self.Spin >= 360 then
			self.Spin = -360
		end
		self:SetAngles(Angle(0,self.Spin,0))
		local time = (CurTime() * 1.5 + self.Seed) % 1

		self:DrawModel()

		if time <= 1 and EyePos():Distance(self:GetPos()) <= 1024 then
			local oldscale = self:GetModelScale()
			local normal = self:GetUp()
			local rnormal = normal * -1
			local mins = self:OBBMins()
			local dist = self:OBBMaxs().z - mins.z
			mins.x = 0
			mins.y = 0
			local pos = self:LocalToWorld(mins)

			self:SetModelScale(oldscale * 1.25, 0)

			if render.SupportsVertexShaders_2_0() then
				render.EnableClipping(true)
				render.PushCustomClipPlane(normal, normal:Dot(pos + dist * time * normal))
				render.PushCustomClipPlane(rnormal, rnormal:Dot(pos + dist * time * 1.55 * normal))
			end

			render.SetColorModulation(0.5, 0.5, 0.5)
			render.SuppressEngineLighting(true)

			render.SetBlend(0.5)
			render.ModelMaterialOverride(matWireframe)
			self:DrawModel()
		
			render.SetColorModulation(1, 1, 1)
			for i = 0, 25 do
			render.SetBlend(1)
			render.ModelMaterialOverride(matWhite)
			self:DrawModel()
			end

			render.ModelMaterialOverride(0)
			render.SuppressEngineLighting(false)
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if render.SupportsVertexShaders_2_0() then
				render.PopCustomClipPlane()
				render.PopCustomClipPlane()
				render.EnableClipping(false)
			end
			self:SetModelScale(oldscale, 0)
		end
	end
	function ENT:IsTranslucent()
		return true
	end
else
	AddCSLuaFile()
	function ENT:SpawnFunction(ply, tr)
		if (!tr.Hit) then return end
		local SpawnPos = tr.HitPos + tr.HitNormal
		self.Spawn_angles = ply:GetAngles()
		self.Spawn_angles.pitch = 0
		self.Spawn_angles.roll = 0
		self.Spawn_angles.yaw = self.Spawn_angles.yaw
		local ent = ents.Create("ent_invisibility")
		ent:SetPos(SpawnPos)
		ent:SetAngles(self.Spawn_angles)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/w_invis.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetAngles(Angle(0,90,0))
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:SetModelScale(1.25, 0)
		self.HasRegen = PU_CanSpawnPowerUp("Invisibility")
		self.HasRegenR = true
		self.DefaultTime = 40
		self.DieTime = 0
		self.NextPickup = {}
		self.NoRespawn = false
	end
	function ENT:Think()
		if !self.NoRespawn then
			if PU_CanSpawnPowerUp("Invisibility") then
				if self.RespawnTime and CurTime() >= self.RespawnTime then
					self.HasRegen = PU_CanSpawnPowerUp("Invisibility")
					self.HasRegenR = true
					self.RespawnTime = nil
					self:SetNoDraw(false)
					self:EmitSound("weapons/physcannon/physcannon_claws_close.wav")
				end
			elseif !PU_CanSpawnPowerUp("Invisibility") then
				self.RespawnTime = CurTime() + GetConVar("abdul_powerup_restime"):GetInt()
			end
			for k,v in pairs (player.GetAll()) do
				if v:IsSpectator() then continue end
				if v:GetPos():Distance(self:GetPos()) < 45 and self.HasRegen == true and self.HasRegenR and v:Alive() then
					if CurTime() <= (self.NextPickup[v] or 0) then return end
					if v:IsBerserk() then return end
					if v:HasPowerUpAlready() then
						v:DropPowerUp()
					end
					
					self.HasRegenR = false
					self:SetNoDraw(true)
					self.RespawnTime = CurTime() + GetConVar("abdul_powerup_restime"):GetInt()
					//v:EmitSound("abdul/regeneration.wav",70,100)
					PU_SetPowerUp( "Invisibility", v, self.DefaultTime )
					hook.Call("PlayerPickupPowerup",GAMEMODE,v,"invisibility")
				end
			end
		else
			local tracedata = {}
			tracedata.start = self.Entity:GetPos()
			tracedata.endpos = self.Entity:GetPos() - Vector(0,0,12)
			tracedata.filter = { self }
			local trace = util.TraceLine(tracedata)
			if !trace.Hit then
				self:SetPos(trace.HitPos)
			end
			for k,v in pairs (player.GetAll()) do
				if v:IsSpectator() then continue end
				if v:GetPos():Distance(self:GetPos()) < 45 and v:Alive() then
					if CurTime() <= (self.NextPickup[v] or 0) then return end
					if v:HasPowerUpAlready() then
						v:DropPowerUp()
					end
					
					self:SetNoDraw(true)
					//v:EmitSound("abdul/regeneration.wav",70,100)
					PU_SetPowerUp( "Invisibility", v, self.DefaultTime )
					hook.Call("PlayerPickupPowerup",GAMEMODE,v,"invisibility")
					self:Remove()
				end
			end
			if CurTime() > self.DieTime then
				self:Remove()
			end
		end
		self:NextThink(CurTime())
		return true
	end

end