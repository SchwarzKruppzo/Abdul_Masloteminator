surface.CreateFont("BMAS_HostName",{font = "Trebuchet MS",size = 32,weight = 1000})
surface.CreateFont("BMAS_Group",{font = "Trebuchet MS",size = 20,weight = 1000,antialias = true})
surface.CreateFont("BMAS_Player",{font = "Trebuchet MS",size = 20,weight = 800,antialias = true})

local PANEL = {}
function PANEL:Init()
    self.Avatar = vgui.Create( "AvatarImage", self )
    self.Avatar:SetSize(24, 24)
    self.Avatar:SetMouseInputEnabled(false)
    self.Mute = vgui.Create( "DImageButton", self )
    self.Mute:SetWidth(24)
    self.Mute:SetColor(Color(180,180,180,220))
    self.Mute:Dock(RIGHT)
    self.Mute:DockMargin(2,0,2,0)
    self.Mute:SetImage("icon32/unmuted.png")
    self:SetText("")
    self.Player = nil
    self.Ping = "0"
    self.Frags = "0"
    self.Deaths = "0"
    self:SetCursor( "hand" )
end
function PANEL:DoClick( w )
    self.Player:ShowProfile() 
    GAMEMODE:ScoreboardHide()
end
function PANEL:SetPlayer( ply )
    self.Player = ply
    self.Avatar:SetPlayer(ply)
    self.Mute.DoClick = function()
        if IsValid(ply) and ply != LocalPlayer() then
            ply:SetMuted(not ply:IsMuted())
        end
    end
end
function PANEL:Paint( w, h )
    if not IsValid(self.Player) then return end
	
	local color = Color(255,255,255)
	local ce = self.entered and 30 or 0
	local colorply = aadmin.usergroups[self.Player:AADMIN_GetAccess()].color or Color(255,255,255)
	local colorply2 = Color( colorply.r - ce,colorply.g - ce,colorply.b - ce)
	local colordead =  Color(255 - ce ,100 - ce,100 - ce)
	local colorspectator = Color(colorply.r - 40 - ce,colorply.g - 40 - ce,colorply.b - 40 - ce)
	
	
	color = colorply2
	
	
	if !self.Player:Alive() then
		color = colordead
	end
	if self.Player:IsSpectator() then
		color = colorspectator
	end
	
    local c = self.Player:IsSpectator() and 220 or 255
	local c2 = self.Player:IsSpectator() and 200 or 220
    local kolor = self.entered and c2 or c
    local r = self.Player:Alive() and 0 or 100
	
    draw.RoundedBox( 0, 0, 0, w, h, color )
    
    surface.SetFont("BMAS_Player")
    local fw, fh = surface.GetTextSize( self.Player:Name() )
    local c = (24 / 2) - (fh / 2)
    draw.SimpleTextOutlined( self.Player:Name(), "BMAS_Player", 24 + 5, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
    local ping = string.sub( self.Ping, 1, 5)
	local fw, fh = surface.GetTextSize( "0" )
    local c = (24 / 2) - (fh / 2)
    draw.SimpleTextOutlined(ping,"BMAS_Player", w * 0.88, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
   
	if self.Player:IsSpectator() then return end
	
    local frags = string.sub( self.Frags, 1, 10)
    local deaths = string.sub( self.Deaths, 1, 10)
    
     draw.SimpleTextOutlined(frags,"BMAS_Player", w * 0.45, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
    draw.SimpleTextOutlined(deaths,"BMAS_Player", w * 0.6, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))

end
function PANEL:Think()
    if not IsValid(self.Player) then return end
    
    self.Ping = tostring( self.Player:Ping() )
    self.Frags = tostring( self.Player:Frags() )
    self.Deaths = tostring( self.Player:Deaths() ) 
    if self.Player != LocalPlayer() then
        local muted = self.Player:IsMuted()
        self.Mute:SetImage(muted and "icon32/muted.png" or "icon32/unmuted.png")
    else
        self.Mute:Hide()
    end 
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
vgui.Register( "ABDUL_Player", PANEL, "Button" )

PANEL = {}
function PANEL:Init()
    self.Name = "Test"
    self.Color = Color(0,0,0,255)
    self.Players = {}
end
function PANEL:SetInfo( name, color, group )
    self.Name = name
    self.Color = color
    self.team = group
end
local function CanSort( panel )
	for k,v in pairs( panel.Players ) do
		if IsValid(v.ply) then
			return true
		end
	end
end
function PANEL:AddPlayer( ply )
	for k,v in pairs( self.Players ) do
		if v.ply == ply then
			return
		end
	end
   // if not self.Players[ply] then
	local plypanel = vgui.Create("ABDUL_Player", self)
	plypanel:SetPlayer( ply )
        //self.Players[ply] = plypanel
	table.insert( self.Players, { panel = plypanel, ply = ply } )
	self:PerformLayout()
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, 28, self.Color )
    
    surface.SetFont("BMAS_Group")
    local fw, fh = surface.GetTextSize( self.Name )
    local c = (28 / 2) - (fh / 2)
    draw.SimpleTextOutlined(self.Name, "BMAS_Group", 5, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
	
end
function PANEL:Think()
    for k,v in pairs(self.Players) do
        if !IsValid( v.ply ) then
            local pnl = v.panel
            if ValidPanel(pnl) then
                v.panel:Remove()
            end
            self.Players[k] = nil
        else
			if v.ply:Team() ~= self.team then
				local pnl = v.panel
				if ValidPanel(pnl) then
					v.panel:Remove()
				end
				self.Players[k] = nil
			end
		end
    end
	
	self:InvalidateLayout()
end
function PANEL:PerformLayout()
    if table.Count(self.Players) < 1 then
        self:SetVisible( false )
        return
    end
    local y = 28
    for k, v in pairs(self.Players) do
        v.panel:SetPos(32, y)
        v.panel:SetSize(self:GetWide() - 32, v.panel:GetTall())

        y = y + v.panel:GetTall()-- + 1
    end
    self:SetSize(self:GetWide(), 28 + (y - 28))
end

vgui.Register( "ABDUL_AccessOLD", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
    self.Name = "Test"
    self.Color = Color(0,0,0,255)
    self.Players = {}
end
function PANEL:SetInfo( name, color, group )
    self.Name = name
    self.Color = color
    self.team = group
end
function PANEL:AddPlayer( ply )
	for k,v in pairs( self.Players ) do
		if v.ply == ply then
			return
		end
	end
	local plypanel = vgui.Create("ABDUL_Player", self)
	plypanel:SetPlayer( ply )
	table.insert( self.Players, { panel = plypanel, ply = ply, kills = ply:Frags() } )
	table.SortByMember( self.Players, "kills")
	self:PerformLayout()
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, 28, cteam.GetColor( self.Name ) or Color(200,200,200))
    
    surface.SetFont("BMAS_Group")
    local fw, fh = surface.GetTextSize( self.Name )
    local c = (28 / 2) - (fh / 2)
	
	local text = self.Name
	if text == "" then text = "No Team" end
    draw.SimpleTextOutlined(text, "BMAS_Group", 5, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
	if self.Name == "" then return end
	
	draw.SimpleTextOutlined(cteam.TotalFrags( self.Name ),"BMAS_Player", w * 0.45, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
    draw.SimpleTextOutlined(cteam.TotalDeaths( self.Name ),"BMAS_Player", w * 0.6, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
    
end
function PANEL:Think()
	for z,x in pairs(player.GetAll()) do
		if x:IsSpectator() then continue end
		local t = x:GetNWString("CTeam")
		if self.Name == t then
			self:AddPlayer( x )
		end
	end
    for k,v in pairs(self.Players) do
        if !IsValid( v.ply ) then
            local pnl = v.panel
            if ValidPanel(pnl) then
                v.panel:Remove()
            end
			self.Players[k].kills = 0
            self.Players[k] = nil
			table.SortByMember( self.Players, "kills")
        else
			local t = v.ply:GetNWString("CTeam")
			if t ~= self.Name or v.ply:IsSpectator() then
				local pnl = v.panel
				if ValidPanel(pnl) then
					v.panel:Remove()
				end
				self.Players[k].kills = 0
				self.Players[k] = nil
				table.SortByMember( self.Players, "kills")
			end
			if v.ply:Frags() != v.kills then
				v.kills = v.ply:Frags()
				table.SortByMember( self.Players, "kills")
			end
		end
    end
	self:InvalidateLayout()
end
function PANEL:PerformLayout()
	if table.Count(self.Players) < 1 then
        self:SetVisible( false )
		self:Remove()
        return
    end
    local y = 28
    for k, v in pairs(self.Players) do
        v.panel:SetPos(15, y)
        v.panel:SetSize(self:GetWide() - 15, v.panel:GetTall())
        y = y + v.panel:GetTall()-- + 1
    end
    self:SetSize(self:GetWide(), 28 + (y - 28))
end

vgui.Register( "ABDUL_Team", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
    self.Name = "Test"
    self.Color = Color(0,0,0,255)
    self.Teams = {}
	self.Players = {}
	
end
function PANEL:SetInfo( name, color, group )
    self.Name = name
    self.Color = color
    self.team = group
end
function PANEL:AddTeam( name )
	if self.team == 2 then return end
	for k,v in pairs( self.Teams ) do
		if v.name == name then
			return
		end
	end
	local team = vgui.Create( "ABDUL_Team", self )
	team:SetInfo( name, Color(55,255,0), 0)
	local totalkills = 0
	if name != "" then
		totalkills = cteam.TotalFrags( name )
	else
		totalkills = 0
	end
	table.insert( self.Teams, { panel = team, name = name, totalkills = totalkills } )
	self:PerformLayout()
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, 28, self.Color )
    
    surface.SetFont("BMAS_Group")
    local fw, fh = surface.GetTextSize( self.Name )
    local c = (28 / 2) - (fh / 2)
    draw.SimpleTextOutlined(self.Name, "BMAS_Group", 5, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
   
end
function PANEL:Think()
	for k, v in pairs(self.Teams) do
		if !cteam.IsValid( v.name) and v.name != "" then
			v.panel:Remove()
			table.remove( self.Teams, k )
			table.SortByMember( self.Teams, "totalkills")
			self:PerformLayout()
		end
		if v.totalkills != cteam.TotalFrags( v.name ) then
			v.totalkills = cteam.TotalFrags( v.name )
			table.SortByMember( self.Teams, "totalkills")
			self:PerformLayout()
		end
	end
	self:InvalidateLayout()
end
function PANEL:PerformLayout()
    local y = 28
    for k, v in pairs(self.Teams) do
		if !IsValid(v.panel) then
			table.remove( self.Teams, k)
			table.SortByMember( self.Teams, "totalkills")
		else
			v.panel:SetPos(32, y)
			v.panel:SetSize(self:GetWide() - 28, 28 )
			y = y + v.panel:GetTall()
			for z,x in pairs(v.panel.Players) do
				x.panel:SetPos(0, y)
				x.panel:SetSize(self:GetWide() - 24, 24 )
				y = y + x.panel:GetTall()
			end
		end
    end
    self:SetSize(self:GetWide(), 28 + (y - 28))
end

vgui.Register( "ABDUL_Access", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
   self.pnlCanvas  = vgui.Create( "Panel", self )
   self.YOffset = 0

   self.scroll = vgui.Create("DVScrollBar", self)
   self.scroll.Paint = function( s, w, h )
      surface.SetDrawColor( Color(225,225,225,255))
      surface.DrawRect( 0, 0, w, h )
   end
   self.scroll.btnUp.Paint = function( s, w, h ) 
      surface.SetDrawColor( Color(225, 225, 225) )
      surface.DrawRect( 0, 0, w, h )
   end
   self.scroll.btnDown.Paint = function( s, w, h ) 
      surface.SetDrawColor( Color(225, 225, 225) )
      surface.DrawRect( 0, 0, w, h )
   end
   self.scroll.btnGrip.Paint = function( s, w, h )
      surface.SetDrawColor( Color(180, 180, 180) )
      surface.DrawRect( 0, 0, w -   1, h )
   end
end

function PANEL:GetCanvas() return self.pnlCanvas end

function PANEL:OnMouseWheeled( dlta )
   self.scroll:AddScroll(dlta * -2)

   self:InvalidateLayout()
end

function PANEL:SetScroll(st)
   self.scroll:SetEnabled(st)
end

function PANEL:PerformLayout()
   self.pnlCanvas:SetVisible(self:IsVisible())

   -- scrollbar
   scrollOnBarSize = 16
   self.scroll:SetPos(self:GetWide() - 16, 0)
   self.scroll:SetSize(scrollOnBarSize, self:GetTall())

   scrollOnFlag = self.scroll.Enabled
   self.scroll:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
   self.scroll:SetEnabled(scrollOnFlag) -- setup mangles enabled state

   self.YOffset = self.scroll:GetOffset()

   self.pnlCanvas:SetPos( 0, self.YOffset )
   self.pnlCanvas:SetSize( self:GetWide() - (self.scroll.Enabled and 16 or 0), self.pnlCanvas:GetTall() )
end
vgui.Register( "ABDUL_Frame", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
    self.HostName = vgui.Create("DLabel",self)
    self.HostName:SetText( GetHostName() )
    self.HostName:SetColor(Color(255,255,255))
    self.HostName:Dock(TOP)
    self.HostName:DockMargin(30,5,30,0)
    
    self.Main = vgui.Create( "ABDUL_Frame",self )
    self.teams = {}
	local team = vgui.Create( "ABDUL_Access", self.Main:GetCanvas() )
	team:Dock( TOP )
	team:SetInfo( "Players", Color(100,150,220), 1) 
	self.teams[1] = team
	local team2 = vgui.Create( "ABDUL_AccessOLD", self.Main:GetCanvas() )
	team2:Dock( TOP )
	team2:SetInfo( "Spectators", Color(150,150,150), 2) 
	self.teams[2] = team2		
	self:PerformLayout() 
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,100) )
    draw.RoundedBox( 0, 5, 5, w - 10, 64, Color(0,0,0,140) )
    draw.RoundedBox( 0, 5, 64 + 15, w - 10, h - 84, Color(0,0,0,140) )
end
function PANEL:PerformLayout()
    local u = 0
    for k,v in pairs(self.teams) do
        if ValidPanel( v ) then
			if k == 1 then
				if table.Count(v.Teams) > 0 then
					v:SetVisible(true)
					u = u + v:GetTall() + 5
				else
				   v:SetVisible(false)
				end
			else
				if table.Count(v.Players) > 0 then
					v:SetVisible(true)
					u = u + v:GetTall() + 5
				else
				   v:SetVisible(false)
				end
			end
        end
    end
    local w = math.max(ScrW() * 0.5, 640)
    local h = ScrH() * 0.8
    self:SetSize(w,math.Clamp(64 + 20 + self.Main:GetCanvas():GetTall(),0,h))
    self:SetPos( (ScrW() - w) / 2, (ScrH() - (math.Clamp(64 + 20 + self.Main:GetCanvas():GetTall(),0,h))) / 2 )
    if ( 64 + 20 + self.Main:GetCanvas():GetTall() ) > h then
        self.Main:SetScroll(true)
    else
        self.Main:SetScroll(false)
    end
    self.HostName:SetSize( self:GetWide(), 64 )
    self.Main:GetCanvas():SetSize(self.Main:GetCanvas():GetWide(), u)
    self.Main:SetPos( 5, 64 + 15 )
    self.Main:SetSize( self:GetWide() - 10, self:GetTall() - 64 - 20    )
end
function PANEL:Think()
	if self.HostName:GetText() ~= GetHostName() then
		self.HostName:SetText( GetHostName() )
	end
    for k, p in pairs(cteam.GetAllTeams()) do
		self.teams[1]:AddTeam( p.name )
		self:PerformLayout() 
    end
	for k, p in pairs(player.GetAll()) do
		if !p:IsSpectator() then
			if p:GetNWString("CTeam") == "" then
				self.teams[1]:AddTeam( "" )
			end
		end
        if !p:IsSpectator() then continue end
        if self.teams[2].Players[p] == nil then
            self.teams[2]:AddPlayer( p )
        end
    end
	
	self:PerformLayout() 
end
function PANEL:ApplySchemeSettings()
    self.HostName:SetFont( "BMAS_HostName" )
end
vgui.Register( "ABDULScoreboard", PANEL, "Panel" )

local function ScoreboardRemove()
   if sboard then
      sboard:Remove()
      sboard = nil
   end
end
ScoreboardRemove()

local function ScoreboardCreate()
   sboard = vgui.Create("ABDULScoreboard")
end
hook.Add("ScoreboardShow","ShowScoreboard_ABDUL",function() 
	if not sboard then
		ScoreboardCreate()
	end
	gui.EnableScreenClicker(true)
	sboard:SetVisible(true)
	return false 
end)
hook.Add("ScoreboardHide","HideScoreboard_ABDUL",function()
	gui.EnableScreenClicker(false)

	if sboard then
		sboard:SetVisible(false)
	end
	return false 
end)