
include('shared.lua')

local matBeam		 		= Material( "effects/laser1" )
local matLight 				= Material( "sprites/light_ignorez" )
local matRefraction			= Material( "sprites/bluelaser1" )

function ENT:Initialize()		
	self.Size = 0
	self.Muzzle1 = util.GetPixelVisibleHandle()
	self.Muzzle2 = util.GetPixelVisibleHandle()
	self.Impact1 = util.GetPixelVisibleHandle()
end

function ENT:Think()
	self.Entity:SetRenderBoundsWS( self.Entity:GetEndPos(), self.Entity:GetPos(), Vector()*8 )
	self.Entity.Size = math.Approach( self.Entity.Size, 1, 10*FrameTime() )
end


function ENT:DrawMainBeam( StartPos, EndPos, Angle)
	local TexOffset = CurTime() * -2.0
	render.SetMaterial( Material("particle/bendibeam") )
	render.DrawBeam( StartPos, EndPos, 38,TexOffset, TexOffset, Color(0,30,255) )	
	local TexOffset = CurTime() * 2.0
	render.DrawBeam( StartPos, EndPos, 16,TexOffset, TexOffset, Color(0,0,255) )	
end

function ENT:DrawCurlyBeam( StartPos, EndPos, Angle )
	local graphic = GetConVar("abdulgraphic_beam"):GetInt()
	if graphic > 3 then graphic = 3 end
	if graphic < 0 then graphic = 0 end
	local StepTable = {}
	StepTable[0] = 80
	StepTable[1] = 64
	StepTable[2] = 32
	StepTable[3] = 16
	local Forward	= Angle:Forward()
	local Right 	= Angle:Right()
	local Up 		= Angle:Up()
	local LastPos
	local Distance = StartPos:Distance( EndPos )
	local StepSize = StepTable[graphic] or 16
	
	local RingTightness = 0.02
	render.SetMaterial( Material("particle/bendibeam") )
	for i=0, Distance, StepSize do
		local sin = math.sin( CurTime() * -30 + i * RingTightness )
		local cos = math.cos( CurTime() * -30 + i * RingTightness )
		local Pos = StartPos + (Forward * i) + (Up * sin * 8) + (Right * cos * 8)
		if (LastPos) then
			render.DrawBeam( LastPos, Pos, (math.sin( i*0.002 )+1) * 16, 0, 0, Color( 40, 40, 255 ) )	 
		end		 
		LastPos = Pos
	end
end
local function DrawSprite( ent, pixvis, pos, x, y, color )
	local ViewNormal = pos - EyePos()
	local Distance = ViewNormal:Length()
	ViewNormal:Normalize()
	local ViewDot = 1
	local LightPos = pos
	
	local Visibile	= util.PixelVisible( LightPos, 8, pixvis )	
	if (!Visibile) then return end
	local SizeX = math.Clamp( Distance * Visibile * ViewDot * 2, 0, x )
	local SizeY = math.Clamp( Distance * Visibile * ViewDot * 2, 0, y )
	Distance = math.Clamp( Distance, 32, 800 )
	local Alpha = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, color.a )
	render.DrawSprite( LightPos, SizeX,SizeY, Color(color.r,color.g,color.b,Alpha))	
end

function ENT:Draw()

	local Owner = self.Entity:GetOwner()
	//if (!Owner || Owner == NULL) then return end
	local StartPos 		= self.Entity:GetPos()
	local EndPos 		= self.Entity:GetEndPos()
	local ViewModel 	= !LocalPlayer():ShouldDrawLocalPlayer()
	local own			= Owner == LocalPlayer()
	local trace = {}
	local Angle = Owner:EyeAngles()
	if ( ViewModel and own) then
		local vm = Owner:GetViewModel()
		if !IsValid( vm ) then return end
		local attachment = vm:GetAttachment( 1 )
		StartPos = attachment.Pos + vm:GetForward()*10
		trace.start = Owner:EyePos()
	else
		local vm = Owner:GetActiveWeapon()
		if !IsValid( vm ) then return end 
		StartPos = vm:GetPos() + vm:GetForward() * 18 + vm:GetUp() * 4 + vm:GetRight() * 6
		trace.start = Owner:EyePos()
	end
	trace.endpos = trace.start + (Owner:EyeAngles():Forward() * 4096)
	trace.filter = { Owner, Owner:GetActiveWeapon() }	
	local tr = util.TraceLine( trace )
	EndPos = tr.HitPos
	local Distance = EndPos:Distance( StartPos ) * self.Entity.Size
	Angle = (EndPos - StartPos):Angle()
	local Normal 	= Angle:Forward()
	render.SetMaterial( Material("sprites/light_glow02_add") )
	render.DrawQuadEasy( EndPos + tr.HitNormal, tr.HitNormal, 64 * self.Entity.Size/2, 64 * self.Entity.Size/2, color_white )
	render.DrawQuadEasy( EndPos + tr.HitNormal, tr.HitNormal, math.Rand(32, 128) * self.Entity.Size, math.Rand(32, 128) * self.Entity.Size, Color(100,155,255) )
	render.SetMaterial( matLight )
	DrawSprite( self.Entity, self.Entity.Impact1, EndPos + tr.HitNormal, 90, 90, Color( 100, 150, 255, self.Entity.Size * 200 ) )
	DrawSprite( self.Entity, self.Entity.Impact1, EndPos + tr.HitNormal, 128*4, 128*4, Color( 0, 100, 255, self.Entity.Size *10 ) )
	cam.Start3D(EyePos(),EyeAngles())
		if ViewModel and own then cam.IgnoreZ( true ) end
		self.Entity:DrawMainBeam( StartPos, StartPos + Normal * Distance, Angle )
		self.Entity:DrawCurlyBeam( StartPos, StartPos + Normal * Distance, Angle )
		if ViewModel and own then cam.IgnoreZ( false ) end
	cam.End3D()
	render.SetMaterial( matLight )
	DrawSprite( self.Entity, self.Entity.Muzzle1, StartPos, 100, 100, Color( 100, 150, 255,  self.Entity.Size * 255) )
	DrawSprite( self.Entity, self.Entity.Muzzle2, StartPos + Normal * 16, 64, 64, Color( 100, 150, 255, self.Entity.Size * 255) )
	if ( !self.Entity.LastDecal || self.Entity.LastDecal < CurTime() ) then
		util.Decal( "fadingscorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal  )
		self.Entity.LastDecal = CurTime() + 0.02
	end
	 
end
function ENT:IsTranslucent()
	return true
end
