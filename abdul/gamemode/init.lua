include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile(GM.FolderName.."/gamemode/core/sh_hooks.lua")
AddCSLuaFile(GM.FolderName.."/gamemode/core/cl_hooks.lua")
AddCSLuaFile(GM.FolderName.."/gamemode/core/sv_hooks.lua")

include(GM.FolderName.."/gamemode/core/sh_hooks.lua")
include(GM.FolderName.."/gamemode/core/sv_hooks.lua")

CreateConVar( "abdul_maxrounds", "3", FCVAR_NOTIFY, "Max Rounds" )
CreateConVar( "abdul_roundtime", "501", FCVAR_NOTIFY, "Round time, in seconds" )
CreateConVar( "abdul_roundstart", "6", FCVAR_NOTIFY, "Round start time" )
CreateConVar( "abdul_fraglimit", "100", FCVAR_NOTIFY, "Frag limit" )
CreateConVar( "abdul_weapon_restime", "35", FCVAR_NOTIFY, "Weapon Respawn Time" )
CreateConVar( "abdul_armor_restime", "50", FCVAR_NOTIFY, "Armor Respawn Time" )
CreateConVar( "abdul_healthvial_restime", "55", FCVAR_NOTIFY, "Health Vial Respawn Time" )
CreateConVar( "abdul_healthkit_restime", "65", FCVAR_NOTIFY, "Health Kit Respawn Time" )
CreateConVar( "abdul_ammo_restime", "75", FCVAR_NOTIFY, "Ammo Respawn Time" )
CreateConVar( "abdul_powerup_restime", "80", FCVAR_NOTIFY, "PowerUp Respawn Time" )
CreateConVar( "abdul_armoryellow_restime", "90", FCVAR_NOTIFY, "Yellow Armor Respawn Time" )
CreateConVar( "abdul_armorred_restime", "120", FCVAR_NOTIFY, "Red Armor Respawn Time" )

resource.AddWorkshop("143280395")
resource.AddWorkshop("321441203")
