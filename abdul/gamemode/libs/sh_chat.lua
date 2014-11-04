if SERVER then
	util.AddNetworkString("ABDUL_Chat")
	
	local function TalkToTeam( ply, color1, prefix, color2, nick, color3, text)
		local shit = ply:GetNWString("CTeam") 
		if !cteam.IsValid( shit ) then return end
		
		for k,v in pairs( cteam.GetPlayers( shit ) ) do
			net.Start("ABDUL_Chat")
				net.WriteEntity( ply )
				net.WriteTable( color1 )
				net.WriteString( prefix )
				net.WriteTable( color2 )
				net.WriteString( nick )
				net.WriteTable( color3 )
				net.WriteString( text )
			net.Send(v)
		end
	end
	local function TalkToAll( ply, color1, prefix, color2, nick, color3, text)
		net.Start("ABDUL_Chat")
			net.WriteEntity( ply )
			net.WriteTable( color1 )
			net.WriteString( prefix )
			net.WriteTable( color2 )
			net.WriteString( nick )
			net.WriteTable( color3 )
			net.WriteString( text )
		net.Broadcast()
	end
	local function IsTeamChat( text )
		if string.sub(text, 1, 3) == "/t " then
			return true
		end
	end
	local function GetColor( ply )
		local color = team.GetColor( ply:Team() )
		
		if ply:GetNWString("CTeam") != "" then
			color = cteam.GetColor( ply:GetNWString("CTeam") )
		end
		return color
	end
	function GM:PlayerSay( ply, text, team2 )
		if IsTeamChat( text ) then
			TalkToTeam( ply, Color(20,255,20), "[TEAM] ", GetColor( ply ), ply:Nick(), Color(255,255,255), string.sub(text, 4) )
		elseif team2 then
			TalkToTeam( ply, Color(20,255,20), "[TEAM] ", GetColor( ply ), ply:Nick(), Color(255,255,255), text )
		else
			TalkToAll( ply, Color(0,0,0), "", GetColor( ply ), ply:Nick(), Color(255,255,255), text)
		end
		return ""
	end
else
	net.Receive( "ABDUL_Chat", function( len )
		local ply = net.ReadEntity()
		local color1 = net.ReadTable()
		local prefix = net.ReadString()
		local color2 = net.ReadTable()
		local nick = net.ReadString()
		local color3 = net.ReadTable()
		local text = net.ReadString()
		
		local dead1 = Color(0,0,0)
		local dead2 = ""
		if !ply:Alive() then
			dead2 = "*DEAD* "
			dead1 = Color(255,20,20)
		end
		chat.AddText( dead1, dead2,color1, prefix, color2, nick, color3,": " .. text )
	end )
end