local lastSlot = lastSlot or 1
local lifeTime = lifeTime or 0
local deathTime = deathTime or 0

local LIFE_TIME = 4
local DEATH_TIME = 5

function OnSlotChanged()
	lifeTime = CurTime() + LIFE_TIME
	deathTime = CurTime() + DEATH_TIME
end
local function checkAmmo()
	for k, v in SortedPairs(LocalPlayer():GetWeapons()) do
		if (k == lastSlot) then
			if LocalPlayer():GetAmmoCount( v.Secondary.Ammo ) <= 0 then
				lastSlot = lastSlot + 1
				checkAmmo()
			end
		end
	end
end
local function checkAmmo2()
	for k, v in SortedPairs(LocalPlayer():GetWeapons()) do
		if (k == lastSlot) then
			if LocalPlayer():GetAmmoCount( v.Secondary.Ammo ) <= 0 then
				lastSlot = lastSlot - 1
				checkAmmo2()
			end
		end
	end
end
function WeaponSelection_BindPress( client, bind, pressed )
	local weapon = client:GetActiveWeapon()

	if (!client:InVehicle() and (!IsValid(weapon) or weapon:GetClass() != "weapon_physgun" or !client:KeyDown(IN_ATTACK))) then
		bind = string.lower(bind)

		if (string.find(bind, "invprev") and pressed) then
			lastSlot = lastSlot - 1
			if (lastSlot <= 0) then
				lastSlot = #client:GetWeapons()
			end
			checkAmmo2()
			OnSlotChanged()
			return true
		elseif (string.find(bind, "invnext") and pressed) then
			lastSlot = lastSlot + 1
			if (lastSlot > #client:GetWeapons()) then
				lastSlot = 1
			end
			checkAmmo()
			OnSlotChanged()
			return true
		elseif (string.find(bind, "+attack") and pressed) then
			if (CurTime() < deathTime) then
				lifeTime = 0
				deathTime = 0
				for k, v in SortedPairs(LocalPlayer():GetWeapons()) do
					if (k == lastSlot) then
						LocalPlayer():EmitSound("common/wpn_select.wav")
						RunConsoleCommand("abdul_selectwep", v:GetClass())
						return true
					end
				end
			end
		elseif (string.find(bind, "slot")) then
			lastSlot = math.Clamp(tonumber(string.match(bind, "slot(%d)")) or 1, 1, #LocalPlayer():GetWeapons())
			lifeTime = CurTime() + LIFE_TIME
			deathTime = CurTime() + DEATH_TIME
			return true
		end
	end
end
local function GetLongWeap()
	local last = 0
	local maxi = 0
	for k,v in SortedPairs(LocalPlayer():GetWeapons()) do
		if v:GetClass() == "abdul_egon" then continue end
		if last <= #getLanguage( v:GetClass() ) then
			last = #getLanguage( v:GetClass() )
			maxi = k
		end
	end
	return getLanguage( LocalPlayer():GetWeapons()[maxi]:GetClass() )
end
local alpha = 0
function WeaponSelection_HUDPaint()
	if LocalPlayer():IsSpectator() then return end
	local x = ScrW()/1.9
	local w2,h2 = GetTextWidth( "0", "GM_SmallNumbers" )
	for k, v in SortedPairs(LocalPlayer():GetWeapons()) do
		local d = #LocalPlayer():GetWeapons()
		local y = (ScrH()/2.1 -  (d*h2)/2) + (k * (h2))
		local y2 = y
		local w,h = GetTextWidth( getLanguage( v:GetClass() ), "GM_SmallNumbers" )
		local wx,wh = GetTextWidth( GetLongWeap(), "GM_SmallNumbers" )
		
		
		local bg_color = Color(0,0,0,math.Clamp(alpha,0,200))
		local text_color = Color(255, 255, 255,alpha)
		if (k == lastSlot) then
			bg_color = Color(100,100,100,alpha)
			text_color = Color(255, 200, 70,alpha)
		end
		if LocalPlayer():GetAmmoCount( v.Secondary.Ammo ) <= 0 then
			bg_color.r = 100
			bg_color.g = 0
			bg_color.b = 0
			if (k == lastSlot) then
				text_color.r = 255
			else
				text_color.r = 200
			end
			text_color.g = 0
			text_color.b = 0
		end
		alpha = math.Clamp(255 - math.TimeFraction(lifeTime, deathTime, CurTime()) * 255, 0, 255)
		
		draw.RoundedBoxEx(0, x - 5, y, wx + 10,h2, bg_color, true, true, false, false)
		draw.DrawText( getLanguage( v:GetClass() ), "GM_SmallNumbers", x, y, text_color, 0, 0 )
	end
end
hook.Add( "PlayerBindPress", "WeaponSelection_BindPress", WeaponSelection_BindPress)
hook.Add( "HUDPaint", "WeaponSelection_HUDPaint", WeaponSelection_HUDPaint )