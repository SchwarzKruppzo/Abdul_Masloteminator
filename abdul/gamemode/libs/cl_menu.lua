surface.CreateFont("TeamSelect",{font = "Trebuchet MS",size = 20,weight = 800,antialias = true})
surface.CreateFont("MOTD_big",{font = "Trebuchet MS",size = 32,weight = 1000,antialias = true})
surface.CreateFont("MOTD_text",{font = "Calibri",size = 21,weight = 1000,antialias = true})
surface.CreateFont("Title_big",{font = "Trebuchet MS",size = 36,weight = 1000,antialias = true})
surface.CreateFont("Title_s",{font = "Trebuchet MS",size = 16,weight = 1500,antialias = true})


local SKIN = {}
function SKIN:PaintListViewLine( panel, w, h )
	if ( panel:IsSelected() ) then
		draw.RoundedBox( 0, 0, 0, w, h, Color(160,40,20) )
	elseif ( panel.Hovered ) then
		draw.RoundedBox( 0, 0, 0, w, h, Color(240,130,110) )
	elseif ( panel.m_bAlt ) then
		draw.RoundedBox( 0, 0, 0, w, h, Color(230,120,100) )
	end
end
function SKIN:PaintTextEntry( panel, w, h )
	if ( panel.m_bBackground ) then
		draw.RoundedBox( 0, 0, 0, w, h, Color(120,120,120) )
		if ( panel:GetDisabled() ) then
			draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color(255,255,255) )
		elseif ( panel:HasFocus() ) then
			draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color(255,230,220) )
		else
			draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color(255,255,255) )
		end
	end
	panel:DrawTextEntryText( panel.m_colText, Color(160,50,30), panel.m_colCursor )
end
function SKIN:PaintButton( panel, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(120,120,120) )
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color(230,150,130) )
end
function SKIN:PaintListView( panel, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(120,120,120) )
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color(255,255,255) )
end
derma.DefineSkin( "Nambavan", "Nambavan", SKIN )



local clr = {}
clr.main = Color(100, 30, 20)
clr.titlemain = Color(200, 56, 30)
clr.workmain = Color(230, 222, 220)
clr.button = Color(130, 36, 20)
clr.buttonlight = Color(160, 66, 40)
clr.panel = Color(215, 210, 206)
clr.buttongray = Color(120, 80, 70)

local clr = {}
clr.main = Color(100, 30, 20)
clr.titlemain = Color(200, 56, 30)
clr.workmain = Color(230, 222, 220)
clr.button = Color(130, 36, 20)
clr.buttonlight = Color(160, 66, 40)
clr.panel = Color(215, 210, 206)
clr.buttongray = Color(120, 80, 70)

local PANEL = {}
function PANEL:Init()
    self.Avatar = vgui.Create( "AvatarImage", self )
    self.Avatar:SetSize(24, 24)
    self.Avatar:SetMouseInputEnabled(false)
    self:SetText("")
    self.Selected = false
    self.Player = nil
    self.Ping = "0"
    self.Frags = "0"
    self.Deaths = "0"
    self:SetCursor( "hand" )
end
function PANEL:SetPlayer( ply )
    self.Player = ply
    self.Avatar:SetPlayer(ply)
end
function PANEL:Paint( w, h )
    if not IsValid(self.Player) then return end
	local color = Color(255,255,255)
	local ce = self.entered and 30 or 0
	local colorply = self.Selected and Color(250,100,50) or Color(255,255,255)
	local colorply2 = Color( colorply.r - ce,colorply.g - ce,colorply.b - ce)
	local colordead =  Color(255 - ce ,100 - ce,100 - ce)
	local colorspectator = Color(colorply.r - 40 - ce,colorply.g - 40 - ce,colorply.b - 40 - ce)
	color = colorply2
    draw.RoundedBox( 0, 0, 0, w, h, color )
    surface.SetFont("BMAS_Player")
    local fw, fh = surface.GetTextSize( self.Player:Name() )
    local c = (24 / 2) - (fh / 2)
    draw.SimpleTextOutlined( self.Player:Name(), "BMAS_Player", 24 + 5, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
end
function PANEL:Think()
    if not IsValid(self.Player) then return end
end
function PANEL:OnCursorEntered()
    self.entered = true
end
function PANEL:OnCursorExited()
    self.entered = false
end
function PANEL:PerformLayout()
   self:SetSize(self:GetWide(),24 )
end
function PANEL:ApplySchemeSettings()
end
vgui.Register( "plyButton", PANEL, "Button" )

PANEL = {}
function PANEL:Init()
    self.Players = {}
    self.Selected = NULL
end
function PANEL:Paint( w, h )
end
function PANEL:GetPlayer( ply )
    if self.Players[ ply:SteamID() ] then 
        return self.Players[ ply:SteamID() ] 
    end
end
function PANEL:GetInfo()
    if IsValid(self.Selected) then
        return self.Selected.Player
    end
end
function PANEL:Think()
    for k,v in pairs(self.Players) do 
        if !IsValid(v.ply) then
            if v.panel then
                v.panel:Remove()
            end
            self.Players[k] = nil
        else
            if self.Selected != v.Selected then
                v.Selected = false
            end
        end
    end
end
function PANEL:AddPlayer( ply, onclick )
 if self.Players[ ply:SteamID() ] then return end
	local tbl = vgui.Create("plyButton")
	tbl:SetPlayer( ply )
	tbl.DoClick = function()
    self.Selected = tbl
    tbl.Selected = true
 end
 self.Players[ ply:SteamID() ] = {ply = ply, panel = tbl}
	self:AddItem( tbl )
end
vgui.Register( "plySheet", PANEL, "DPanelList" )

PANEL = {}
function PANEL:Init()
	local w,h = self:GetParent():GetWide(),self:GetParent():GetTall()
	self:SetPos(w/2 - (w/2)/2,15)
	self:SetSize(w/2,h - 30)
	self.SelectedPly = NULL
	self.List = vgui.Create("plySheet", self)
	self.List:SetPos(2,24)
	self.List:SetSize( self:GetWide() - 4, self:GetTall() - 28*2 - 2 )
	self.Slt = vgui.Create("fButton", self )
	self.Slt:SetText("Select")
	self.Slt:SetTall( 28 )
	self.Slt:SetWide( self:GetWide()/2 - 4)
	self.Slt:SetPos( 2,self:GetTall() - 28 - 2)
	self.Slt.DoClick = function( s )
		self:Remove()
		self:GetParent().CurrentWindow = NULL
	end
	self.Cnc = vgui.Create("fButton", self )
	self.Cnc:SetText("Cancel")
	self.Cnc:SetTall( 28 )
	self.Cnc:SetWide( self:GetWide()/2 - 2)
	self.Cnc:SetPos( self:GetWide()/2,self:GetTall() - 28 - 2)
	self.Cnc.DoClick = function( s )
		self:Remove()
		self:GetParent().CurrentWindow = NULL
	end
end
function PANEL:DoSelect()
end
function PANEL:GetSelected()
    if IsValid(self.List:GetInfo()) then
        return self.List:GetInfo()
    end
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, clr.workmain )
	draw.RoundedBox( 0, 0, 0, w, 22, clr.titlemain )
	draw.SimpleText(self.Title,"Title_s",5,22/2,Color(255,255,255),0,1)
	if self.type != "team" then
		for k,v in pairs(player.GetAll()) do
			if v:GetNWString("CTeam") != "" then
				if v:GetNWString("CTeam") == LocalPlayer():GetNWString("CTeam") then
					continue
				end
			end
			self.List:AddPlayer( v, function() end )
		end
	else
		for k,v in pairs(cteam.GetPlayers( LocalPlayer():GetNWString("CTeam")) or {}) do
			self.List:AddPlayer( v, function() end )
		end
	end
	self.Slt.DoClick = function( s )
		self.DoSelect()
	end
end
function PANEL:Think()
end
function PANEL:PerformLayout()
end
vgui.Register( "mSelect", PANEL, "EditablePanel" )

local PANEL = {}
function PANEL:Init()
	local w,h = self:GetParent():GetWide(),self:GetParent():GetTall()
	self:SetPos(w/2 - (w/1.5)/2,h/2 - 50)
	self:SetSize(w/1.5,80)
	
	self.Yes = vgui.Create("fButton", self )
	self.Yes:SetText("Yes")
	self.Yes:SetTall( 28 )
	self.Yes:SetWide( self:GetWide()/2 - 2)
	self.Yes:SetPos(self:GetWide()/2 - self:GetWide()/2 + 2,self:GetTall() - 28 - 2)
	self.Yes.DoClick = self.DoYes
	self.No = vgui.Create("fButton", self )
	self.No:SetText("No")
	self.No:SetTall( 28 )
	self.No:SetWide( self:GetWide()/2 - 4)
	self.No:SetPos(self:GetWide()/2 + 2,self:GetTall() - 28 - 2)
	self.No.DoClick = function( s )
		self:Remove()
		self:GetParent().CurrentWindow = NULL
	end
end
function PANEL:DoYes()
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, clr.workmain )
	draw.RoundedBox( 0, 0, 0, w, 22, clr.titlemain )
	draw.SimpleText("Confirm action","Title_s",5,22/2,Color(255,255,255),0,1)
	draw.SimpleText("Are you sure?","DermaDefault",5,22 + 14,Color(0,0,0),0,1)
	self.Yes.DoClick = function()
		self.DoYes()
		self:Remove()
		self:GetParent().CurrentWindow = NULL
	end
	
end
function PANEL:PerformLayout()
end
vgui.Register( "mWindow", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
	self.CurrentWindow = NULL
	
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
	
	self.Pnl1 = vgui.Create("fPanel", self )
	self.Pnl1:SetPos( 2, 2 )
	self.Pnl1:SetWide( self:GetWide()/2 - 4)
	self.Pnl1:SetTall( self:GetTall() - 4)
	self.Pnl2 = vgui.Create("fPanel", self )
	self.Pnl2:SetPos( self:GetWide()/2, 2 )
	self.Pnl2:SetWide( self:GetWide()/2 - 2)
	self.Pnl2:SetTall( self:GetTall() - 4)
	
	self.btnColor = vgui.Create("fButton", self.Pnl2 )
	self.btnColor:Dock( TOP )
	self.btnColor:DockMargin( 0, 0, 0,2 )
	self.btnColor:SetText("Save new color")
	self.btnColor:SetTall( 35 )
	self.btnColor.DoClick = function( s )
		local rgb = self.mixColor:GetColor()
		net.Start("net_ChangeColorTeam")
			net.WriteTable( rgb )
		net.SendToServer()
	end
	self.btnPass = vgui.Create("fButton", self.Pnl2 )
	self.btnPass:Dock( TOP )
	self.btnPass:DockMargin( 0, 0, 0,2 )
	self.btnPass:SetText("Save new password")
	self.btnPass:SetTall( 35 )
	self.btnPass.DoClick = function( s )
		net.Start("net_ChangePassTeam")
			net.WriteString( self.txtPass:GetValue() )
		net.SendToServer()
	end
	self.btnLeader = vgui.Create("fButton", self.Pnl2 )
	self.btnLeader:Dock( TOP )
	self.btnLeader:DockMargin( 0, 0, 0,2 )
	self.btnLeader:SetText("Change leader")
	self.btnLeader:SetTall( 35 )
	self.btnLeader.DoClick = function( s )
		if IsValid(self.CurrentWindow) then self.CurrentWindow:Remove() end
		local panel = vgui.Create("mSelect", self)
		panel.type = "team"
		panel.Title = "Give leader access to..."
		panel.DoSelect = function()
			net.Start("net_LeaderPlayerTeam")
				net.WriteString( panel:GetSelected():SteamID() )
			net.SendToServer()
			panel:Remove()
			self.CurrentWindow = NULL
			self:GetParent().CurrentPanel:Remove()
			self:GetParent().CurrentPanel = NULL
		end
		self.CurrentWindow = panel
	end
	self.btnInvite = vgui.Create("fButton", self.Pnl2 )
	self.btnInvite:Dock( TOP )
	self.btnInvite:DockMargin( 0, 0, 0,2 )
	self.btnInvite:SetText("Invite player")
	self.btnInvite:SetTall( 35 )
	self.btnInvite.DoClick = function( s )
		if IsValid(self.CurrentWindow) then self.CurrentWindow:Remove() end
		local panel = vgui.Create("mSelect", self)
		panel.Title = "Invite player"
		panel.DoSelect = function()
			net.Start("net_InvitePlayerTeam")
				net.WriteString( panel:GetSelected():SteamID() )
			net.SendToServer()
			panel:Remove()
			self.CurrentWindow = NULL
			self:GetParent().CurrentPanel:Remove()
			self:GetParent().CurrentPanel = NULL
		end
		self.CurrentWindow = panel
	end
	self.btnKick = vgui.Create("fButton", self.Pnl2 )
	self.btnKick:Dock( TOP )
	self.btnKick:DockMargin( 0, 0, 0,2 )
	self.btnKick:SetText("Kick player")
	self.btnKick:SetTall( 35 )
	self.btnKick.DoClick = function( s )
		if IsValid(self.CurrentWindow) then self.CurrentWindow:Remove() end
		local panel = vgui.Create("mSelect", self)
		panel.type = "team"
		panel.Title = "Kick player"
		panel.DoSelect = function()
			net.Start("net_KickPlayerTeam")
				net.WriteString( panel:GetSelected():SteamID() )
			net.SendToServer()
			panel:Remove()
			self.CurrentWindow = NULL
		end
		self.CurrentWindow = panel
	end
	self.btnDelete = vgui.Create("fButton", self.Pnl2 )
	self.btnDelete:Dock( TOP )
	self.btnDelete:DockMargin( 0, 0, 0,2 )
	self.btnDelete:SetText("Abandon Team")
	self.btnDelete:SetTall( 35 )
	self.btnDelete.DoClick = function( s )
		if IsValid(self.CurrentWindow) then self.CurrentWindow:Remove() end
		local panel = vgui.Create("mWindow", self)
		panel.DoYes = function()
			net.Start("net_RemoveTeam")
			net.SendToServer()
			self:GetParent().CurrentPanel:Remove()
			self:GetParent().CurrentPanel = NULL
		end
		self.CurrentWindow = panel
	end
	
	self.lblPass = vgui.Create("DLabel", self.Pnl1)
	self.lblPass:Dock( TOP )
	self.lblPass:DockMargin( 2, 0, 0,2 )
	self.lblPass:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.lblPass:SetText("Change Password")
	self.txtPass = vgui.Create("DTextEntry", self.Pnl1)
	self.txtPass:Dock( TOP )
	self.txtPass:SetSkin("Nambavan")
	self.txtPass:DockMargin( 2, 0, 0,2 )
	self.lblCol = vgui.Create("DLabel", self.Pnl1)
	self.lblCol:SetText("Change Color")
	self.lblCol:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.lblCol:Dock( TOP )
	self.lblCol:DockMargin( 2, 0, 0,2 )
	self.mixColor = vgui.Create( "DColorMixer", self.Pnl1)
	self.mixColor:Dock( TOP )
	self.mixColor:SetPalette( false )
	self.mixColor:SetAlphaBar( false ) 
	self.mixColor:SetWangs( true )
	self.mixColor:DockMargin( 2, 0, 0,2 )
	self.mixColor:SetTall( self.Pnl1:GetWide() )
end
function PANEL:Paint( w, h )
end
function PANEL:PerformLayout()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
end
vgui.Register( "pManageTeam", PANEL, "Panel" )
PANEL = {}
function PANEL:Init()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
	local w = self:GetWide()
	local h = self:GetTall()
	self.lblName = vgui.Create("fLabel", self)
	self.lblName:SetText("Team Name")
	self.lblName:Dock(TOP)
	self.lblName:DockMargin(2,0,0,0)
	self.txtName = vgui.Create("DTextEntry", self)
	self.txtName:Dock(TOP)
	self.txtName:DockMargin(2,0,w/1.5,0)
	self.txtName:SetSkin("Nambavan")
	self.lblPass = vgui.Create("fLabel", self)
	self.lblPass:SetText("Team Password")
	self.lblPass:Dock(TOP)
	self.lblPass:DockMargin(2,0,0,0)
	self.txtPass = vgui.Create("DTextEntry", self)
	self.txtPass:Dock(TOP)
	self.txtPass:DockMargin(2,0,w/1.5,0)
	self.txtPass:SetSkin("Nambavan")
	self.lblColor = vgui.Create("fLabel", self)
	self.lblColor:SetText("Team Color")
	self.lblColor:Dock(TOP)
	self.lblColor:DockMargin(2,0,0,0)
	self.mixColor = vgui.Create( "DColorMixer", self )
	//self.mixColor:Dock( TOP )
	self.mixColor:SetPalette( false )
	self.mixColor:SetAlphaBar( false ) 
	self.mixColor:SetWangs( true )
	
	self.btnCreate = vgui.Create("fButton", self )
	self.btnCreate:SetPos( 2, h - 48 - 2 )
	self.btnCreate:SetText("Create Team")
	self.btnCreate:SetTall( 48 )
	self.btnCreate:SetWide( w - 4 )
	self.btnCreate.DoClick = function( s )
		local name = self.txtName:GetValue()
		local pass = self.txtPass:GetValue()
		local color = self.mixColor:GetColor()
		if cteam.IsValid( name ) then
			return
		end
		net.Start("net_CreateTeam")
			net.WriteString( name )
			net.WriteString( pass )
			net.WriteTable( color )
		net.SendToServer()
		self:GetParent().CurrentPanel:Remove()
		self:GetParent().CurrentPanel = NULL
	end
	local x1,y1 = self.txtPass:GetPos()
	
	local x2,y2 = self.btnCreate:GetPos()
	local d = math.Dist(0, self:GetTall()/6, 0, y2)
	self.mixColor:SetPos(2,0)
	self.mixColor:SetWide( self:GetWide() - 4 )
	self.mixColor:SetTall(d)
	self.mixColor:MoveAbove( self.btnCreate, 2)
end
function PANEL:Paint( w, h )
	if #self.txtName:GetValue() <= 1 then
		if !self.btnCreate:GetDisabled() then
			self.btnCreate:SetDisabled( true )
		end
	else
		if self.btnCreate:GetDisabled() then
			self.btnCreate:SetDisabled( false )
		end
	end
end
function PANEL:PerformLayout()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
end
vgui.Register( "pCreateTeam", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
	self.mdl = vgui.Create("DModelPanel", self)
	self.mdl:SetFOV( 36 )
	self.mdl:SetCamPos( Vector( 0, 0, 0 ) )
	self.mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	self.mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	self.mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
	self.mdl:SetAnimated( true )
	self.mdl.Angles = Angle( 0, 0, 0 )
	self.mdl:SetLookAt( Vector( -100, 0, -22 ) )
	self.mdl:Dock( TOP )
	self.mdl:DockMargin( 2, 2, self:GetWide()/2, 2 )
	self.mdl:SetTall( self:GetTall())
	
	self.Pnl1 = vgui.Create("fPanel", self )
	self.Pnl1:SetPos( self:GetWide()/2, 2 )
	self.Pnl1:SetWide( self:GetWide()/2 - 2)
	self.Pnl1:SetTall( self:GetTall() - 4 )
	self.ControlsLbl = vgui.Create("DLabel", self.Pnl1)
	self.ControlsLbl:SetText( "Player color" )
	self.ControlsLbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.ControlsLbl:Dock( TOP )
	self.ControlsLbl:DockMargin( 2, 0, 0,0 )
	self.plycol = vgui.Create("DColorMixer", self.Pnl1)
	self.plycol:SetAlphaBar( false )
	self.plycol:SetPalette( false )
	self.plycol:Dock( FILL )
	self.plycol:DockMargin( 2, 0, 70,2 )
	self.gamemodesRailCol = vgui.Create("DRGBPicker", self.Pnl1)
	self.gamemodesRailCol:Dock( BOTTOM )
	self.gamemodesRailCol:SetTall( 70 )
	self.gamemodesRailCol:DockMargin( 0, 0, 0,0 )
	self.gamemodesRailLbl = vgui.Create("DLabel", self.Pnl1)
	self.gamemodesRailLbl:SetText( "Railgun Color" )
	self.gamemodesRailLbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.gamemodesRailLbl:Dock( BOTTOM )
	self.gamemodesRailLbl:DockMargin( 2, 0, 0,0 )
	self.PanelSelect = vgui.Create("DPanelSelect", self.Pnl1)
	self.PanelSelect:Dock( BOTTOM )
	self.PanelSelect:SetTall( self.Pnl1:GetWide()/1.5)
	for name, model in SortedPairs( player_manager.AllValidModels() ) do
		local icon = vgui.Create( "SpawnIcon" )
		icon:SetModel( model )
		icon:SetSize( 64, 64 )
		icon:SetTooltip( name )
		icon.playermodel = name
		self.PanelSelect:AddPanel( icon, { cl_playermodel = name } )
	end
	local function UpdateFromConvars()
		local model = LocalPlayer():GetInfo( "cl_playermodel" )
		local modelname = player_manager.TranslatePlayerModel( model )
		util.PrecacheModel( modelname )
		self.mdl:SetModel( modelname )
		self.mdl.Entity.GetPlayerColor = function() return Vector( GetConVarString( "cl_playercolor" ) ) end
		self.mdl.Entity:SetPos( Vector( -100, 0, -61 ) )
			
		local color = string.Explode( " ", GetConVarString("cl_railguncolor"))
		self.plycol:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) )
		self.gamemodesRailCol:SetRGB( Color( color[1], color[2], color[3] ) )
	end
	UpdateFromConvars()
	self.plycol.ValueChanged = function( self, color )
		RunConsoleCommand( "cl_playercolor", tostring( self:GetVector() ) )
	end
	self.gamemodesRailCol.OnChange = function( color )
		local col = self.gamemodesRailCol:GetRGB()
		RunConsoleCommand( "cl_railguncolor", tostring( col.r.." "..col.g.." "..col.b ) )
	end
	self.PanelSelect.OnActivePanelChanged = function( old, new )
		timer.Simple( 0.1, function() UpdateFromConvars() end )
	end
end
function PANEL:PerformLayout()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
end
vgui.Register( "pSetting", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
	
	self.expLbl = vgui.Create("DLabel", self)
	self.expLbl:SetText( "Explosions Quality" )
	self.expLbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.expLbl:Dock( TOP )
	self.expLbl:DockMargin( 4, 0, 0,0 )
	
	self.expBox = vgui.Create( "DComboBox", self)
	self.expBox:SetSize( 100, 20 )
	self.expBox:Dock( TOP )
	self.expBox:DockMargin( 2, 0, 2,0 )
	self.expBox:AddChoice( "Very Low" )
	self.expBox:AddChoice( "Low" )
	self.expBox:AddChoice( "Medium" )
	self.expBox:AddChoice( "High" )
	
	
	self.impLbl = vgui.Create("DLabel", self)
	self.impLbl:SetText( "Impacts Quality" )
	self.impLbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.impLbl:Dock( TOP )
	self.impLbl:DockMargin( 4, 0, 0,0 )
	
	self.impBox = vgui.Create( "DComboBox", self)
	self.impBox:SetSize( 100, 20 )
	self.impBox:Dock( TOP )
	self.impBox:DockMargin( 2, 0, 2,0 )
	self.impBox:AddChoice( "Very Low" )
	self.impBox:AddChoice( "Low" )
	self.impBox:AddChoice( "Medium" )
	self.impBox:AddChoice( "High" )
	
	
	self.rocLbl = vgui.Create("DLabel", self)
	self.rocLbl:SetText( "Rocket Quality" )
	self.rocLbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.rocLbl:Dock( TOP )
	self.rocLbl:DockMargin( 4, 0, 0,0 )
	self.rocBox = vgui.Create( "DComboBox", self)
	self.rocBox:SetSize( 100, 20 )
	self.rocBox:Dock( TOP )
	self.rocBox:DockMargin( 2, 0, 2,0 )
	self.rocBox:AddChoice( "Low" )
	self.rocBox:AddChoice( "Medium" )
	self.rocBox:AddChoice( "High" )
	
	self.beamLbl = vgui.Create("DLabel", self)
	self.beamLbl:SetText( "Palisan Beam Quality" )
	self.beamLbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.beamLbl:Dock( TOP )
	self.beamLbl:DockMargin( 4, 0, 0,0 )
	self.beamBox = vgui.Create( "DComboBox", self)
	self.beamBox:SetSize( 100, 20 )
	self.beamBox:Dock( TOP )
	self.beamBox:DockMargin( 2, 0, 2,0 )
	self.beamBox:AddChoice( "Very Low" )
	self.beamBox:AddChoice( "Low" )
	self.beamBox:AddChoice( "Medium" )
	self.beamBox:AddChoice( "High" )
	
	self.goreLbl = vgui.Create("DLabel", self)
	self.goreLbl:SetText( "Gore Quality" )
	self.goreLbl:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.goreLbl:Dock( TOP )
	self.goreLbl:DockMargin( 4, 0, 0,0 )
	self.goreBox = vgui.Create( "DComboBox", self)
	self.goreBox:SetSize( 100, 20 )
	self.goreBox:Dock( TOP )
	self.goreBox:DockMargin( 2, 0, 2,0 )
	self.goreBox:AddChoice( "Low" )
	self.goreBox:AddChoice( "Medium" )
	self.goreBox:AddChoice( "High" )
	self.expBox.OnSelect = function( panel, index, value )
		local id = index - 1
		RunConsoleCommand( "abdulgraphic_explosion", tostring( id ) )
	end
	self.impBox.OnSelect = function( panel, index, value )
		local id = index - 1
		RunConsoleCommand( "abdulgraphic_impact", tostring( id ) )
	end
	self.rocBox.OnSelect = function( panel, index, value )
		local id = index - 1
		RunConsoleCommand( "abdulgraphic_rocket", tostring( id ) )
	end
	self.beamBox.OnSelect = function( panel, index, value )
		local id = index - 1
		RunConsoleCommand( "abdulgraphic_beam", tostring( id ) )
	end
	self.goreBox.OnSelect = function( panel, index, value )
		local id = index - 1
		RunConsoleCommand( "abdulgraphic_gore", tostring( id ) )
	end
	local function UpdateFromConvars()
		local exp = GetConVar("abdulgraphic_explosion"):GetInt()
		local imp = GetConVar("abdulgraphic_impact"):GetInt()
		local roc = GetConVar("abdulgraphic_rocket"):GetInt()
		local beam = GetConVar("abdulgraphic_beam"):GetInt()
		local gore = GetConVar("abdulgraphic_gore"):GetInt()
	
		self.expBox:ChooseOptionID( exp + 1 )
		self.impBox:ChooseOptionID( imp + 1 )
		self.rocBox:ChooseOptionID( roc + 1 )
		self.beamBox:ChooseOptionID( beam + 1 )
		self.goreBox:ChooseOptionID( gore + 1 )
	end
	UpdateFromConvars()
end
function PANEL:PerformLayout()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
end
vgui.Register( "pSettingGraph", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
	
	self.btnJoinNoTeam = vgui.Create("fButton", self )
	self.btnJoinNoTeam:Dock( TOP )
	self.btnJoinNoTeam:DockMargin( 2, 1, 2,0 )
	self.btnJoinNoTeam:SetText("Join without Team")
	self.btnJoinNoTeam:SetTall( 40 )
	self.btnJoinNoTeam.DoClick = function( s )
		RunConsoleCommand("teamgame")
		RunConsoleCommand("abdulmenu")
	end
	self.btnJoinSpec = vgui.Create("fButton", self )
	self.btnJoinSpec:Dock( TOP )
	self.btnJoinSpec:DockMargin( 2, 2, 2,5 )
	self.btnJoinSpec:SetText("Join Spectators")
	self.btnJoinSpec:SetTall( 40 )
	self.btnJoinSpec.DoClick = function( s )
		RunConsoleCommand("teamspec")
		RunConsoleCommand("abdulmenu")
	end
	self.lblTeam = vgui.Create("DLabel", self)
	self.lblTeam:SetText( "Or join already exists team:" )
	self.lblTeam:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.lblTeam:Dock( TOP )
	self.lblTeam:DockMargin( 2, 0, 0,0 )
	local h = s_h - s_h/7
	self.TeamList = vgui.Create("DListView", self)
	self.TeamList:Dock(TOP)
	self.TeamList:SetMultiSelect(false)
	self.TeamList:SetSkin("Nambavan")
	self.TeamList:AddColumn("Name")
	self.TeamList:DockMargin( 2, 0, self:GetWide()/2,0 )
	self.TeamList:StretchToParent( 0, 40*2 + 32, 0, 0 ) 
	self.Teams = cteam.GetAllTeams()
	for k,v in pairs(self.Teams) do
		self.TeamList:AddLine(v.name) 
	end
	self.SelectedTeam = ""
	self.TeamList.OnRowSelected = function(parent, line)
		self.SelectedTeam = self.TeamList:GetLine(line):GetValue(1)
	end
	
	self.Pnl1 = vgui.Create("fPanel", self )
	local x,y = self.TeamList:GetPos()
	self.Pnl1:SetPos( self:GetWide()/2 + 2,y - 3 )
	self.Pnl1:SetWide( self:GetWide()/2 - 4)
	self.Pnl1:StretchToParent( self:GetWide()/2 + 2, 40*2 + 32 - 3, 2, 2 ) 
	
	self.lblPass = vgui.Create("DLabel", self.Pnl1)
	self.lblPass:SetText("Password")
	self.lblPass:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.lblPass:Dock(TOP)
	self.lblPass:DockMargin(2,0,0,0)
	self.txtPass = vgui.Create("DTextEntry", self.Pnl1)
	self.txtPass:Dock(TOP)
	self.txtPass:SetSkin("Nambavan")
	self.txtPass:DockMargin(2,0,2,2)
	self.btnJoinTeam = vgui.Create("fButton", self.Pnl1 )
	self.btnJoinTeam:Dock( TOP )
	self.btnJoinTeam:DockMargin( 0, 2, 0,2 )
	self.btnJoinTeam:SetText("Join Team")
	self.btnJoinTeam:SetTall( 40 )
	self.btnJoinTeam.DoClick = function( s )
		local pass = self.txtPass:GetValue()
		if !cteam.IsValid( self.SelectedTeam ) then
			return
		end
		net.Start("net_JoinTeam")
			net.WriteString( self.SelectedTeam )
			net.WriteString( pass )
		net.SendToServer()
	end
	self.btnLeaveTeam = vgui.Create("fButton", self.Pnl1 )
	self.btnLeaveTeam:Dock( TOP )
	self.btnLeaveTeam:DockMargin( 0, 0, 0,0 )
	self.btnLeaveTeam:SetText("Leave Team")
	self.btnLeaveTeam:SetTall( 40 )
	self.btnLeaveTeam.DoClick = function( s )
		net.Start("net_LeaveTeam")
		net.SendToServer()
	end
end
function PANEL:Paint( w, h )
	if self.Teams != cteam.GetAllTeams() then
		self.Teams = cteam.GetAllTeams()
		self.TeamList:Clear()
		for k,v in pairs(self.Teams) do
			self.TeamList:AddLine(v.name) 
		end
	end
	if #cteam.GetAllTeams() == 0 or LocalPlayer():GetNWString("CTeam") != "" or self.SelectedTeam == LocalPlayer():GetNWString("CTeam") then
		if !self.btnJoinTeam:GetDisabled() then
			self.btnJoinTeam:SetDisabled( true )
		end
	else
		if self.btnJoinTeam:GetDisabled() then
			self.btnJoinTeam:SetDisabled( false )
		end
	end
	if LocalPlayer():GetNWString("CTeam") == "" then
		if !self.btnLeaveTeam:GetDisabled() then
			self.btnLeaveTeam:SetDisabled( true )
		end
	else
		if self.btnLeaveTeam:GetDisabled() then
			self.btnLeaveTeam:SetDisabled( false )
		end
	end
	if !LocalPlayer():IsSpectator() or LocalPlayer():GetNWString("CTeam") != "" then
		if !self.btnJoinNoTeam:GetDisabled() then
			self.btnJoinNoTeam:SetDisabled( true )
		end
	else
		if self.btnJoinNoTeam:GetDisabled() then
			self.btnJoinNoTeam:SetDisabled( false )
		end
	end
	if LocalPlayer():IsSpectator() then
		if !self.btnJoinSpec:GetDisabled() then
			self.btnJoinSpec:SetDisabled( true )
		end
	else
		if self.btnJoinSpec:GetDisabled() then
			self.btnJoinSpec:SetDisabled( false )
		end
	end
end
function PANEL:PerformLayout()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
end
vgui.Register( "pJoinGame", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
	
	
	self.Title = vgui.Create("DLabel", self)
	self.Title:SetText( "Welcome to the Abdul: Masloterminator" )
	self.Title:SetFont("MOTD_big")
	self.Title:SetTextColor( Color( 100,30,10 ) )
	self.Title:Dock( TOP )
	self.Title:DockMargin( 5, 10,0,10 )
	self.Text = vgui.Create("DTextEntry", self)
	self.Text:SetText( [[Abdul: Masloterminator is a deathmatch gamemode for Garry's mod. 
The gamemode currently is in development by Schwarz Kruppzo (also known as swarchkruppzo).

Karochi bleat. Pomnite - BOMZ NE ZAKON, YA ZAKON. Gasi vseh, ubivai maslyat, razsheplyai ih na atomi ili razrivai na kusochki, ob'edinyaisa v komandi i viigrivai vmeste!
Ah da. I ewe koe-chto. CHITAITE BIBORAN! ANSHA ABDUL!]])
	self.Text:SetFont("MOTD_text")
	self.Text:SetMultiline(true)
	self.Text:SetEditable( false )
	self.Text:SetTextColor( Color( 90,30,10 ) )
	self.Text:SetDrawBorder( false )
	self.Text:SetDrawBackground(false)
	self.Text:Dock( FILL )
	self.Text:DockMargin( 5, 5, 0,0 )
	self.Text:SetWide( s_w - s_w/3.7 )
end
function PANEL:Paint( w, h )
	//draw.DrawText("Welcome to Abdul: Masloterminator","MOTD_big",5,0,Color(100,100,100))
end
function PANEL:PerformLayout()
	local s_w, s_h = self:GetParent():GetWide(), self:GetParent():GetTall()
	self:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
	self:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
end
vgui.Register( "pMain", PANEL, "Panel" )






PANEL = {}
function PANEL:Init()
	self:SetColor(Color(50,50,50))
end
vgui.Register( "fLabel", PANEL, "DLabel" )

PANEL = {}
function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, clr.panel )
end
vgui.Register( "fPanel", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
	self:SetContentAlignment( 5 )
	self:SetTall( 22 )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	self:SetCursor( "hand" )
	self:SetFont( "TeamSelect" )
	self.InRadius = false
end
function PANEL:IsDown()
	return self.Depressed
end
function PANEL:Paint( w, h )
	local col = clr.button
	if self.InRadius then
		col = clr.buttonlight
	end
	if self.m_bDisabled then
		col = clr.buttongray
	end
	draw.RoundedBox( 0, 0, 0, w, h, col )
end
function PANEL:PerformLayout()
	if ( IsValid( self.m_Image ) ) then
		self.m_Image:SetPos( 4, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
		self:SetTextInset( self.m_Image:GetWide() + 16, 0 )
	end
	DLabel.PerformLayout( self )
end
function PANEL:SetDisabled( bDisabled )
	self.m_bDisabled = bDisabled
	self:InvalidateLayout()
end
function PANEL:SetEnabled( bEnabled )
	self.m_bDisabled = !bEnabled
	self:InvalidateLayout()
end
function PANEL:OnMousePressed( mousecode )
	return DLabel.OnMousePressed( self, mousecode )
end
function PANEL:OnMouseReleased( mousecode )
	return DLabel.OnMouseReleased( self, mousecode )
end
function PANEL:OnCursorEntered( )
	self.InRadius = true
end
function PANEL:OnCursorExited()
	self.InRadius = false
end
vgui.Register( "fButton", PANEL, "DLabel" )

PANEL = {}
function PANEL:Init()
	self.Buttons = {}
end
function PANEL:Paint( w, h )

end
function PANEL:GetButton( id )
	if self.Buttons[id] then
		return self.Buttons[id]
	end
end
function PANEL:AddButton( id, name, onClick )
	local tbl = vgui.Create("fButton")
	tbl:SetText( name )
	tbl:SetTall(self.Siz)
	tbl.DoClick = onClick
	self.Buttons[id] = tbl
	self:AddItem( tbl )
end
vgui.Register( "aSheet", PANEL, "DPanelList" )

PANEL = {}
function PANEL:Init()
	local s_w, s_h = self:GetWide(), self:GetTall()
	local panel = vgui.Create("pMain", self)
	self.CurrentPanel = panel
	
	
	self.Sheet = vgui.Create( "aSheet", self )
	self.Sheet:SetSpacing( 2 ) 
	self.Sheet.Siz = (s_w - s_w/7)/1.3
	self.Sheet:AddButton("main","Main", function()
		if IsValid(self.CurrentPanel) then self.CurrentPanel:Remove() end
		local panel = vgui.Create("pMain", self)
		self.CurrentPanel = panel
	end)
	self.Sheet:AddButton("settings","Settings", function()
		if IsValid(self.CurrentPanel) then self.CurrentPanel:Remove() end
		local panel = vgui.Create("pSetting", self)
		self.CurrentPanel = panel
	end)
	self.Sheet:AddButton("settings2","Graphic settings", function()
		if IsValid(self.CurrentPanel) then self.CurrentPanel:Remove() end
		local panel = vgui.Create("pSettingGraph", self)
		self.CurrentPanel = panel
	end)
	self.Sheet:AddButton("join","Join Game", function()
		if IsValid(self.CurrentPanel) then self.CurrentPanel:Remove() end
		local panel = vgui.Create("pJoinGame", self)
		self.CurrentPanel = panel
	end)
	self.Sheet:AddButton("create","Create Team", function()
		if IsValid(self.CurrentPanel) then self.CurrentPanel:Remove() end
		local panel = vgui.Create("pCreateTeam", self)
		self.CurrentPanel = panel
	end)
	self.Sheet:AddButton("manage","Manage Team", function()
		if IsValid(self.CurrentPanel) then self.CurrentPanel:Remove() end
		local panel = vgui.Create("pManageTeam", self)
		self.CurrentPanel = panel
	end)
	
	self.CloseBt = vgui.Create("fButton", self )
	self.CloseBt:SetText( "Close" )
	self.CloseBt:SetTall(24)
	self.CloseBt.DoClick = function()
		RunConsoleCommand("abdulmenu")
	end
	
end
function PANEL:Paint( w, h )
	local title_h = h/7
	local work_w = w/3.7
    draw.RoundedBox( 0, 0, 0, w, h, clr.main )
	draw.RoundedBox( 0, 0, 0, w, title_h, clr.titlemain )
	draw.RoundedBox( 0, work_w, title_h, w - work_w, h - title_h, clr.workmain )
	draw.SimpleText("Abdul: Masloterminator v1.1","Title_big",16,title_h/2,Color(255,255,255),0,1)
end
function PANEL:Think()
	if LocalPlayer():GetNWString("CTeam") != "" then
		if LocalPlayer():IsSpectator() then
			if !self.Sheet:GetButton( "create" ):GetDisabled() then
				self.Sheet:GetButton( "create" ):SetDisabled( true )
			end
		else
			if !self.Sheet:GetButton( "create" ):GetDisabled() then
				self.Sheet:GetButton( "create" ):SetDisabled( true )
			end
		end
		if cteam.IsLeader( LocalPlayer(), LocalPlayer():GetNWString("CTeam") ) then
			if self.Sheet:GetButton( "manage" ):GetDisabled() then
				self.Sheet:GetButton( "manage" ):SetDisabled( false )
			end
		else
			if !self.Sheet:GetButton( "manage" ):GetDisabled() then
				self.Sheet:GetButton( "manage" ):SetDisabled( true )
			end
		end
	else
		if LocalPlayer():IsSpectator() then
			if !self.Sheet:GetButton( "create" ):GetDisabled() then
				self.Sheet:GetButton( "create" ):SetDisabled( true )
			end
		else
			if self.Sheet:GetButton( "create" ):GetDisabled() then
				self.Sheet:GetButton( "create" ):SetDisabled( false )
			end
		end
		if !self.Sheet:GetButton( "manage" ):GetDisabled() then
			self.Sheet:GetButton( "manage" ):SetDisabled( true )
		end
	end
end
function PANEL:PerformLayout()
    local w = ScrW() - ScrW()/3
    local h = ScreenScale( 300 )
    local x = (ScrW()/2) - (w/2)
    local y = (ScrH()/2) - (h/2)
    self:SetSize(w,h)
    self:SetPos(x,y)
	self.CloseBt:SetPos( self:GetWide() - self.CloseBt:GetWide(),0)
	local s_w, s_h = self:GetWide(), self:GetTall()
	local sh_w = (s_w/3.7)
	self.Sheet:SetPos( 1, s_h/7 + 1 )
	self.Sheet:SetSize( sh_w, s_w - s_w/7 )
	
	if IsValid(self.CurrentPanel) then
		self.CurrentPanel:SetPos( s_w/3.7 + 1, s_h/7 + 1 )
		self.CurrentPanel:SetSize( s_w - s_w/3.7, s_h - s_h/7 )
	end
	
end
vgui.Register( "GM_Menu", PANEL, "EditablePanel" )

concommand.Add("abdulmenu", function()
	if not CGamemodeMenu then
		CGamemodeMenu = vgui.Create("GM_Menu")
		CGamemodeMenu:MakePopup()
		gui.EnableScreenClicker(true)
	else
		if CGamemodeMenu:IsVisible() then
			CGamemodeMenu:SetVisible(false)
			gui.EnableScreenClicker(false)
		else
			CGamemodeMenu:SetVisible(true)
			gui.EnableScreenClicker(true)
		end
	end
end)