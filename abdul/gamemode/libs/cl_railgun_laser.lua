CreateClientConVar( "cl_railguncolor", "255 0 0", true, true )

local EFFECT = {}
function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	self.Attachment = "1"
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Col = data:GetStart()
	self.Color = Color( self.Col.x, self.Col.y, self.Col.z )
	
	self.EndPos = data:GetOrigin()
	self.alpha = 255
	self:SetRenderBoundsWS(self.Position, self.EndPos)
end

function EFFECT:Think()
	local form = (255/1.5) * FrameTime()
	self.alpha = self.alpha - form
	self.alpha = math.Clamp(self.alpha,0,255)
	self.Color.r = self.Color.r - form
	self.Color.r = math.Clamp(self.Color.r,0,255)
	self.Color.g = self.Color.g - form
	self.Color.g = math.Clamp(self.Color.g,0,255)
	self.Color.b = self.Color.b - form
	self.Color.b = math.Clamp(self.Color.b,0,255)
	
	local al = math.Clamp(self.alpha,0,255)
	if al <= 0 then return false end	
	return true
end

function EFFECT:Render()
	render.SetMaterial(Material("effects/laser1"))
	//render.DrawBeam(self.Position, self.EndPos, 4, 0, 0, Color(self.alpha, self.alpha, self.alpha, self.alpha))
	render.DrawBeam(self.Position, self.EndPos, 32, 0, 0, self.Color)
end

effects.Register( EFFECT, "railgun_laser" )

EFFECT = {}
function EFFECT:Init(data)
	self.StartPos = data:GetNormal()
	self.Col = data:GetStart()
	self.Color = Color( self.Col.x, self.Col.y, self.Col.z )
	
	self.EndPos = data:GetOrigin()
	self.alpha = 255
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)
end

function EFFECT:Think()
	local form = (255/1.5) * FrameTime()
	self.alpha = self.alpha - form
	self.alpha = math.Clamp(self.alpha,0,255)
	self.Color.r = self.Color.r - form
	self.Color.r = math.Clamp(self.Color.r,0,255)
	self.Color.g = self.Color.g - form
	self.Color.g = math.Clamp(self.Color.g,0,255)
	self.Color.b = self.Color.b - form
	self.Color.b = math.Clamp(self.Color.b,0,255)
	
	local al = math.Clamp(self.alpha,0,255)
	if al <= 0 then return false end	
	return true
end

function EFFECT:Render()
	
	render.SetMaterial(Material("effects/laser1"))
	//render.DrawBeam(self.StartPos, self.EndPos, 4, 0, 0, Color(self.alpha, self.alpha, self.alpha, self.alpha))
	render.DrawBeam(self.StartPos, self.EndPos, 32, 0, 0, self.Color)
end

effects.Register( EFFECT, "railgun_laser2" )