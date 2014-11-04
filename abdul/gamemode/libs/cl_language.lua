GM_Language = {}

function languageAdd( str, str2 )
	GM_Language[str] = str2
end
function getLanguage( str )
	return GM_Language[str] or "unknown"
end

languageAdd( "abdul_rocketlauncher", "Maslorocketnica" )
languageAdd( "RPG_Round", "Rockets" )

languageAdd( "abdul_impulseminigun", "Sonyblyadskiy Minigan" )
languageAdd( "PulseCell", "Pulse Cells" )

languageAdd( "abdul_ak47", "Kalash" )
languageAdd( "ak47", "Kalash Clip" )

languageAdd( "abdul_railgun", "Raschlenitel Maslyat" )
languageAdd( "rail", "Slugs" )

languageAdd( "abdul_mp7", "Nubogun" )
languageAdd( "mp7", "MP-7 Clip" )

languageAdd( "abdul_shotgun", "'Maslobaba'" )
languageAdd( "shotbuck", "Buckshot" )

languageAdd( "abdul_maslachesator", "Maslachezator" )
languageAdd( "ShrapBomb", "Shrap Bombs" )

languageAdd( "abdul_machete", "Machete" )

languageAdd( "abdul_egon", "Palisan" )
languageAdd( "uranium", "Palisanki" )

languageAdd( "abdul_claymore", "M18 Claymore" )
languageAdd( "claymore", "M18 Claymore" )

languageAdd( "abdul_50cal", "M3 Browning" )
languageAdd( "50cals", "M3 Browning" )

languageAdd( "abdul_turret", "AWARD: Automatic Turret" )
languageAdd( "turrets", "Automatic Turret" )

languageAdd( "abdul_awm", "420noscoper" )
languageAdd( "awm", "Homing Bullet" )

languageAdd( "abdul_plasma", "BomBom" )
languageAdd( "plasma", "Plasma Round" )

languageAdd( "quaddamage", "PowerUp: BIBORAN" )
languageAdd( "regeneration", "PowerUp: REGENERATION" )
languageAdd( "invisibility", "PowerUp: INVISIBILITY" )

languageAdd( "armorred", "Mega Armor" )
languageAdd( "armoryellow", "Super Armor" )
