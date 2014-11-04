if CLIENT then
	local alpha = 255

	function ShowHitmarker()
		if not LocalPlayer():IsValid() then return end
		
		local data = {}

		local dmg = net.ReadFloat()
		local dmgtype = net.ReadUInt(32)
		

		local bHitSound = true
		local x
		local y
		local ulti = 1
		alpha = 255
		
		hook.Add( "HUDPaint", "HitMarker", function()
			if ( bHitSound ) then
				surface.PlaySound( "hit.wav" )
				bHitSound = false
				ulti = 1
			end
			if not ( ulti == 1) then
				alpha = 0
			end
			if !LocalPlayer():Alive() then alpha = 0 return end
			
			alpha = alpha - (255/0.5) * FrameTime()
			alpha = math.Clamp( alpha, 0, 255 )
			if alpha == 0 then ulti = 0 end
			x = ScrW() / 2
			y = ScrH() / 2
			surface.SetDrawColor( 255, 255, 255, alpha )
			surface.DrawLine( x - 7, y - 6, x - 12, y - 11 )
			surface.DrawLine( x + 6, y - 6, x + 11, y - 11 )
			surface.DrawLine( x - 7, y + 6, x - 12, y + 11 )
			surface.DrawLine( x + 6, y + 6, x + 11, y + 11 )
		end )
	end

	net.Receive( "hit_marker", ShowHitmarker)
else
	util.AddNetworkString( "hit_marker" )

	function HitMarker(target, dmginfo, ply, hitgroup)
		if not dmginfo:GetAttacker():IsPlayer() then return end
		local attacker = dmginfo:GetAttacker()
		if target:IsValid() then
			if attacker == target then return end
			if (attacker:IsPlayer()) and target:Health() > 0 then
				local team = attacker:GetNWString("CTeam")
				local team2 = target:GetNWString("CTeam")
				if team != "" then
					if team == team2 then return end
				end
				net.Start("hit_marker")
					net.WriteFloat(dmginfo:GetDamage())
					net.WriteUInt(dmginfo:GetDamageType(), 32)
				net.Send(attacker)
			end
		end
	end
	hook.Add("EntityTakeDamage", "HitMarker", HitMarker)
end
