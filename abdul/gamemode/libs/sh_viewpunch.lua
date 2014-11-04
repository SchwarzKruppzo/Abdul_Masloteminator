if CLIENT then
	local vecPunchAngle = vecPunchAngle or Angle()
	local vecPunchAngleVel = vecPunchAngleVel or Angle()
	function ViewPunch( angle )
		vecPunchAngleVel = vecPunchAngleVel + angle * 2
	end
	function GetPunch()
		return vecPunchAngle
	end
	local function QAngleLength( angle )
		return angle.p * angle.p + angle.y * angle.y + angle.r * angle.r
	end
	local function DetectChange( out, res )
		if out ~= res then
			out = res
		end
	end
	local function SetP( ang, p )
		DetectChange( ang.p, p )
	end
	local function SetY( ang, y )
		DetectChange( ang.y, y )
	end
	local function SetR( ang, r )
		DetectChange( ang.r, r )
	end
	local function QAngleInit( angle, p, y, r )
		SetP( angle, p )
		SetY( angle, y )
		SetR( angle, r )
	end
	local function DecayPunchAngle()
		if QAngleLength( vecPunchAngle ) > 0.001 or QAngleLength( vecPunchAngleVel ) > 0.001 then
			vecPunchAngle.p = Lerp( (FrameTime() * 16)/2.25, vecPunchAngle.p, vecPunchAngleVel.p )
			vecPunchAngle.y = Lerp( (FrameTime() * 16)/2.25, vecPunchAngle.y, vecPunchAngleVel.y )
			vecPunchAngle.r = Lerp( (FrameTime() * 16)/2.25, vecPunchAngle.r, vecPunchAngleVel.r )
			vecPunchAngleVel = vecPunchAngleVel - vecPunchAngle * (31.982/360)
			//LocalPlayer():ChatPrint(tostring(vecPunchAngleVel))
			QAngleInit( vecPunchAngle, math.Clamp( vecPunchAngle.p, -90, 90 ), math.Clamp( vecPunchAngle.y, -180, 180 ),  math.Clamp( vecPunchAngle.r, -90, 90 ))

		else
			QAngleInit( vecPunchAngle, 0, 0, 0 )
			QAngleInit( vecPunchAngleVel, 0, 0, 0 )
		end

	end
	hook.Add("Think","ClientSideViewPunch",function()
		DecayPunchAngle()
	end)
	hook.Add("CalcView","ClientSideViewPunch",function( ply, pos, ang, fov, nearZ, farZ )
		ang.p = ang.p + vecPunchAngle.p
		ang.y = ang.y + vecPunchAngle.y
		ang.r = ang.r + vecPunchAngle.r
	end)
	hook.Add("CalcViewModelView","ClientSideViewPunch",function( wep, vm, oldPos, oldAng, pos, ang )
		ang.p = ang.p - vecPunchAngle.p
		ang.y = ang.y - vecPunchAngle.y
		ang.r = ang.r - vecPunchAngle.r
	end)
	
	net.Receive( "ViewPunch", function( len )
		local p = net.ReadFloat()
		local y = net.ReadFloat()
		local r = net.ReadFloat()
		ViewPunch( Angle(p,y,r) )
	end )
	
else
	util.AddNetworkString( "ViewPunch" )
	
	local meta = FindMetaTable("Player")
	function meta:ViewPunchC( angle )
		net.Start( "ViewPunch" )
			net.WriteFloat( angle.p )
			net.WriteFloat( angle.y )
			net.WriteFloat( angle.r )
		net.Send( self )
	end
end