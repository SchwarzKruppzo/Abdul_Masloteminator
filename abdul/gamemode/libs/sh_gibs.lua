if CLIENT then
	CreateClientConVar( "abdulgraphic_gore", "2", true, true )
	GibsEnts = {}
	GibsModels = {}
	GibsBigModels = {}
	GibsModels[1] = {
		model = "models/props_junk/garbage_bag001a.mdl",
		min = Vector(-5,-5,-5),
		max = Vector(5,5,5)
	}
	GibsModels[2] = {
		model = "models/props_debris/concrete_chunk04a.mdl",
		min = Vector(-2,-2,-2),
		max = Vector(2,2,2)
	}
	GibsModels[3] = {
		model = "models/props_debris/concrete_chunk03a.mdl",
		min = Vector(-3,-3,-3),
		max = Vector(3,3,3)
	}
	GibsModels[4] = {
		model = "models/props_debris/concrete_chunk09a.mdl",
		min = Vector(-3,-3,-4),
		max = Vector(3,3,4)
	}
	GibsBigModels[1] = {
		model = "models/props_debris/concrete_column001a_chunk02.mdl",
		min = Vector(-4,-4,-1),
		max = Vector(4,4,25)
	}
	GibsBigModels[2] = {
		model = "models/props_debris/concrete_column001a_chunk06.mdl",
		min = Vector(-5,-5,-10),
		max = Vector(5,5,1)
	}

	local rand = math.random
	function q3_GibExplode(pos)
		sound.Play("physics/body/body_medium_break2.wav", pos, 70, 100, 1)
		// Do a small shit
		for i=1,2 do
			for k,v in pairs(GibsModels) do
				local gib = ClientsideModel(v.model,RENDERGROUP_OPAQUE)
				gib:SetPos(pos+Vector(0,0,5))
				gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				gib:PhysicsInitBox(v.min,v.max)
				gib:GetPhysicsObject():SetVelocity(Vector(rand(-200,200),rand(-200,200),rand(200,450)))
				gib:SetMaterial("models/flesh")
				gib:GetPhysicsObject():SetMaterial( "zombieflesh" )
				table.insert(GibsEnts,gib)
				gib.paint = 0
				gib.impact = 0
				gib.EffectTimer = CurTime() + math.random(2, 6)
				gib.RemoveTimer = CurTime() + math.random(5,10)
			end
			sound.Play("physics/body/body_medium_break4.wav", pos, 50, 100, 1)
		end
		for k,v in pairs(GibsBigModels) do
			local gib = ClientsideModel(v.model,RENDERGROUP_OPAQUE)
			gib:SetModelScale(0.5,0)
			gib:SetPos(pos+Vector(0,0,45))
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:PhysicsInitBox(v.min,v.max)
			gib:GetPhysicsObject():SetVelocity(Vector(rand(-200,200),rand(-200,200),rand(200,450)))
			gib:SetMaterial("models/flesh")
			gib:GetPhysicsObject():SetMaterial( "zombieflesh" )
			table.insert(GibsEnts,gib)    
			
			gib.paint = 0
			gib.impact = 0
			gib.EffectTimer = CurTime() + math.random(2, 6)
			gib.RemoveTimer = CurTime() + math.random(5,10)
		end
			local gib = ClientsideModel("models/Gibs/HGIBS.mdl",RENDERGROUP_OPAQUE)
			gib:SetPos(pos+Vector(0,0,45))
			gib:PhysicsInitBox(Vector(-3,-3,-3),Vector(3,3,3))
			gib:GetPhysicsObject():SetVelocity(Vector(rand(-200,200),rand(-200,200),rand(200,450)))
			table.insert(GibsEnts,gib)    
			
			gib.paint = 0
			gib.impact = 0
			gib.EffectTimer = CurTime() + math.random(2, 6)
			gib.RemoveTimer = CurTime() + math.random(5,30)
		
		local p = 20
		if GetConVar("abdulgraphic_gore"):GetInt() == 1 then p = 10 elseif GetConVar("abdulgraphic_gore"):GetInt() == 0 then p = 5 end
		for i = 0, p do
			local effectdata = EffectData()
			effectdata:SetOrigin(pos+Vector(0,0,rand(100,60))) --set effect pos
			effectdata:SetFlags(1)
			util.Effect("dismemberment_bloodstream", effectdata)
		end
		sound.Play("physics/flesh/flesh_bloody_break.wav", pos, 90, 100, 1)     
	end
	local m_iDecalTime = 15
	local m_iImpactTime = 20
	local graph = GetConVar("abdulgraphic_gore"):GetInt()
	if graph == nil then graph = 2 end
	
	if graph <= 1 then 
		m_iImpactTime = 40
		m_iDecalTime = 35
	end
		
	hook.Add("Think","Q3Gibs",function()
		for k,v in pairs(GibsEnts) do
			if CurTime() < v.EffectTimer then
				if v:GetPhysicsObject():GetVelocity():Length() > 30 then
					if v.paint < m_iDecalTime then
						v.paint = math.Approach(v.paint,m_iDecalTime,1)
					elseif v.paint == m_iDecalTime then
						local tracedata = {}
						tracedata.startpos = v:GetPos()
						tracedata.endpos = v:GetPos() - v:GetUp()*5
						local trace = util.TraceLine(tracedata)
						util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
						local tracedata = {}
						tracedata.startpos = v:GetPos()
						tracedata.endpos = v:GetPos() + v:GetUp()*5
						local trace = util.TraceLine(tracedata)
						util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
						local tracedata = {}
						tracedata.startpos = v:GetPos()
						tracedata.endpos = v:GetPos() - v:GetRight()*5
						local trace = util.TraceLine(tracedata)
						util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
						v.paint = 0
					end
				end
				if GetConVar("abdulgraphic_gore"):GetInt() > 0 then
					if v.impact < m_iImpactTime then
						v.impact = math.Approach(v.impact,m_iImpactTime,1)
					elseif v.impact == m_iImpactTime then
						ParticleEffect("blood_impact_red_01",v:GetPos(),v:GetAngles(),self)
						v.impact = 0
					end
				end
			end
			if CurTime() > v.RemoveTimer then
				v:Remove()
				table.remove(GibsEnts,k)
			end
		end
	end)
	net.Receive( "q3_gibs", function( length )
		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local z = net.ReadFloat()
		q3_GibExplode(Vector(x,y,z))
	end )
else
	util.AddNetworkString( "q3_gibs" )
	local function PlayerDeath(ply, attacker, dmg)
		if ply.highdamage then
			if IsValid(ply:GetRagdollEntity()) then
				ply:GetRagdollEntity():Remove()
			end
			net.Start( "q3_gibs" )
				net.WriteFloat(ply:GetPos()[1])
				net.WriteFloat(ply:GetPos()[2])
				net.WriteFloat(ply:GetPos()[3])
			net.Broadcast() 
		end
	end
	hook.Add("PlayerDeath", "q3gibs", PlayerDeath)

	local function EntityTakeDamage(ply,dmginfo)
		if ply:IsPlayer() then
			if !dmginfo:IsExplosionDamage() then
				if dmginfo:GetDamage() > ply:Health()+100 then
					ply.highdamage = true         
				else
					ply.highdamage = false
				end	
			else
				if dmginfo:GetDamage() > ply:Health() then
					ply.highdamage = true          
				else
					ply.highdamage = false
				end
			end
			if dmginfo:IsFallDamage() then
				if dmginfo:GetDamage() > ply:Health()+50 then
					ply.highdamage = true          
				else
					ply.highdamage = false
				end
			end
		end
	end
	hook.Add("EntityTakeDamage", "q3gibs", EntityTakeDamage)
end