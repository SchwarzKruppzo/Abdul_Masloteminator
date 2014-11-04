team.SetUp(1,"Player",Color(100,150,220))
team.SetUp(2,"Spectator",Color(100,100,100,255))


local meta = FindMetaTable("Player")
function meta:IsSpectator()
	return (self:Team() == 0 or self:Team() == 2)
end


function GM:CanPlayerSuicide(ply)
	if GetGameState() == GS_ROUND_PREPARE then
		return false
	else
		return (!ply:IsSpectator())
	end
end
function GM:PlayerSwitchFlashlight(ply, on)
   if not IsValid(ply) then return false end
   if (not on) or !ply:IsSpectator() then
      if on then
         ply:AddEffects(EF_DIMLIGHT)
      else
         ply:RemoveEffects(EF_DIMLIGHT)
      end
   end
   return false
end
function GM:PlayerSpray(ply)
   if not IsValid(ply) or !ply:IsSpectator() then
      return true 
   end
end
function GM:PlayerUse(ply, ent)
   return !ply:IsSpectator()
end


if SERVER then
	local function GetPlayersAlive()
		local int = {}
		for k,v in pairs(player.GetAll()) do
			if v:IsSpectator() then continue end
			table.insert(int,v)
		end
		return int
	end
	local function GetNextPlayerAlive(ply)
	   local alive = GetPlayersAlive()
	   if #alive < 1 then return nil end
	   local prev = nil
	   local choice = nil
	   if IsValid(ply) then
		  for k,p in pairs(alive) do
			 if prev == ply then
				choice = p
			 end
			 prev = p
		  end
	   end
	   if not IsValid(choice) then
		  choice = alive[1]
	   end
	   return choice
	end
	
	
	function GM:KeyPress(ply, key)
	   if not IsValid(ply) then return end
	   if ply:IsSpectator() then

		  if key == IN_ATTACK then
			 ply:Spectate(OBS_MODE_ROAMING)
			 ply:SetEyeAngles(Angle())
			 ply:SpectateEntity(nil)

			 local alive = GetPlayersAlive()

			 if #alive < 1 then return end

			 local target = table.Random(alive)
			 if IsValid(target) then
				ply:SetPos(target:EyePos())
				ply:SetEyeAngles(target:EyeAngles())
			 end
		  elseif key == IN_ATTACK2 then
			 local target = GetNextPlayerAlive(ply:GetObserverTarget())

			 if IsValid(target) then
				ply:Spectate(ply.specmode or OBS_MODE_CHASE)
				ply:SpectateEntity(target)
			 end
		  elseif key == IN_DUCK then
			 local pos = ply:GetPos()
			 local ang = ply:EyeAngles()
			 local target = ply:GetObserverTarget()
			 if IsValid(target) and target:IsPlayer() then
				pos = target:EyePos()
				ang = target:EyeAngles()
			 end
			 ply:Spectate(OBS_MODE_ROAMING)
			 ply:SpectateEntity(nil)
			 ply:SetPos(pos)
			 ply:SetEyeAngles(ang)
			 return true
		  elseif key == IN_JUMP then
			 if not (ply:GetMoveType() == MOVETYPE_NOCLIP) then
				ply:SetMoveType(MOVETYPE_NOCLIP)
			 end
		  elseif key == IN_RELOAD then
			 local tgt = ply:GetObserverTarget()
			 if not IsValid(tgt) or not tgt:IsPlayer() then return end
			 if not ply.specmode or ply.specmode == OBS_MODE_CHASE then
				ply.specmode = OBS_MODE_IN_EYE
			 elseif ply.specmode == OBS_MODE_IN_EYE then
				ply.specmode = OBS_MODE_CHASE
			 end
			 ply:Spectate(ply.specmode)
		  end
	   end

	end
	
	
	concommand.Add("teamspec",function(ply)
		ply:SetTeam(2)
		ply:Spawn()
	end)
	concommand.Add("teamgame",function(ply)
		ply:SetTeam(1)
		ply:Spawn()
	end)
end