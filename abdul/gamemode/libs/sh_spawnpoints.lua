local WeaponSpawnPoints = {}
local SpawnPoints = {}
local ItemSpawnPoints = {}
local AmmoSpawnPoints = {}

WeaponSpawnPoints["gm_construct"] = {
{ class = "abdul_rocketlauncher", mdl = "models/weapons/w_rocket_launcher.mdl", pos = Vector(1335.302002,-1617.142822,-79.968750) },
{ class = "abdul_railgun", mdl = "models/weapons/w_q3_railgun.mdl", pos = Vector(-2307.999268,-2801.029785,320.031250) },
{ class = "abdul_ak47", mdl = "models/weapons/w_rif_ak47.mdl", pos = Vector(-2090.782959,-1549.306152,-335.450897) },
{ class = "abdul_impulseminigun", mdl = "models/weapons/w_minigun.mdl", pos = Vector(759.866333,4326.182129,32.031250) },
{ class = "abdul_mp7", mdl = "models/weapons/w_smg1.mdl", pos = Vector(1228.869385,779.451782,128.031250) }
}
WeaponSpawnPoints["gm_citywalls"] = {
{ class = "abdul_rocketlauncher", mdl = "models/weapons/w_rocket_launcher.mdl", pos = Vector(1443.1866455078,-629.20361328125,68.03125) },
{ class = "abdul_rocketlauncher", mdl = "models/weapons/w_rocket_launcher.mdl", pos = Vector(-1017.585632,1939.616699,368.031250) },
{ class = "abdul_railgun", mdl = "models/weapons/w_q3_railgun.mdl", pos = Vector(1217.3663330078,623.42102050781,196.03125) },
{ class = "abdul_ak47", mdl = "models/weapons/w_rif_ak47.mdl", pos = Vector(974.54754638672,1604.111328125,68.03125) },
{ class = "abdul_ak47", mdl = "models/weapons/w_rif_ak47.mdl", pos = Vector(-931.253174,1856.240967,668.031250) },
{ class = "abdul_impulseminigun", mdl = "models/weapons/w_minigun.mdl", pos = Vector(-1285.8138427734,50.217510223389,68.03125) },
{ class = "abdul_egon", mdl = "models/w_egonpickup.mdl", pos = Vector(-1061.7274169922,-1025.6323242188,68.03125) },
{ class = "abdul_shotgun", mdl = "models/weapons/w_shotgun.mdl", pos = Vector(1231.241089,-312.897888,68.031250) },
{ class = "abdul_shotgun", mdl = "models/weapons/w_shotgun.mdl", pos = Vector(-1281.151367,320.356415,196.031250) },
{ class = "abdul_shotgun", mdl = "models/weapons/w_shotgun.mdl", pos = Vector(0.272079,-1600.387695,64.031250) },
{ class = "abdul_maslachesator", mdl = "models/weapons/w_combinegl.mdl", pos = Vector(-422.900146,1724.238892,68.031250) },
{ class = "abdul_plasma", mdl = "models/weapons/w_physics.mdl", pos = Vector(1136.298828,621.549622,622) },
{ class = "abdul_claymore", mdl = "models/w_claymore.mdl", pos = Vector(1618.966431,-325.571747,196.031250) },
{ class = "abdul_claymore", mdl = "models/w_claymore.mdl", pos = Vector(1841.099731,-425.285919,68.031250) },
{ class = "abdul_claymore", mdl = "models/w_claymore.mdl", pos = Vector(-1396.319702,-1046.702393,68.031250) },
{ class = "abdul_claymore", mdl = "models/w_claymore.mdl", pos = Vector(1267.452148,625.372620,496.031250) },
{ class = "abdul_awm", mdl = "models/weapons/w_awm.mdl", pos = Vector(1166.933228,-607.131348,324.031250) }

}

AmmoSpawnPoints["gm_citywalls"] = {
{ ammo = "RPG_Round", maxammo = 15, pos = Vector(95.899887,-1311.929321,64.031250) },
{ ammo = "PulseCell", maxammo = 250, pos = Vector(-95.972694,-1312.025879,64.031250) },
{ ammo = "mp7", maxammo = 100, pos = Vector(367.667084,1472.127563,64.031250) },
{ ammo = "shotbuck", maxammo = 15, pos = Vector(177.015076,1472.073853,64.031250) },
{ ammo = "uranium", maxammo = 100, pos = Vector(-1045.453125,383.931244,68.031250) },
{ ammo = "shotbuck", maxammo = 10, pos = Vector(-1045.453125,-400,68.031250) },
{ ammo = "RPG_Round", maxammo = 15, pos = Vector(-1183.807251,904.422791,64.031250) },
{ ammo = "rail", maxammo = 10, pos = Vector(-1183.807251,1004.929504,64.031265) },
{ ammo = "ak47", maxammo = 100, pos = Vector(-1280.472168,1004.929504,64.031250) },
{ ammo = "ShrapBomb", maxammo = 10, pos = Vector(-1280.472168,904.422791,64.031250) },
{ ammo = "ak47", maxammo = 100, pos = Vector(1559.772583,-1016.391663,68.031250) },
{ ammo = "ShrapBomb", maxammo = 10, pos = Vector(1493.416016,-1016.391663,68.031250) },
{ ammo = "mp7", maxammo = 100, pos = Vector(1131.605957,-219.478104,68.031250) },
{ ammo = "PulseCell", maxammo = 250, pos = Vector(1407.697021,-215.179901,68.031250) },
{ ammo = "uranium", maxammo = 100, pos = Vector(1132.531494,-426.313416,196.031250) },
{ ammo = "shotbuck", maxammo = 15, pos = Vector(1132.531494,-220.696411,196.031250) },
{ ammo = "uranium", maxammo = 100, pos = Vector(1474.383301,624.935059,68.031250) },
{ ammo = "ShrapBomb", maxammo = 10, pos = Vector(1534.234253,688.062805,68.031250) },
{ ammo = "RPG_Round", maxammo = 15, pos = Vector(1936.353882,635.818481,196.031250) },
{ ammo = "rail", maxammo = 10, pos = Vector(1938.171997,508.035400,196.031250) },
{ ammo = "rail", maxammo = 10, pos = Vector(-600.800293,2147.796631,668.031250) },
{ ammo = "RPG_Round", maxammo = 15, pos = Vector(-941.610535,2254.128418,668.031250) },
{ ammo = "mp7", maxammo = 100, pos = Vector(-1643.528076,1910.415161,368.031250) },
{ ammo = "PulseCell", maxammo = 250, pos = Vector(-1753.543579,1569.592896,368.031250) },
{ ammo = "shotbuck", maxammo = 15, pos = Vector(-600.893005,2151.968750,68.031250) },
{ ammo = "ShrapBomb", maxammo = 10, pos = Vector(-937.301208,2257.573486,68.031265) },
{ ammo = "awm", maxammo = 20, pos = Vector(1483.734009,-1028.706665,196.031250) },
{ ammo = "awm", maxammo = 20, pos = Vector(-1362.093140,-306.252167,196.031250) },
{ ammo = "awm", maxammo = 20, pos = Vector(987.640991,1816.148804,68.031250) },
{ ammo = "awm", maxammo = 20, pos = Vector(1396.115723,-1042.439209,68.031250) },
{ ammo = "plasma", maxammo = 15, pos = Vector(1950.296021,-212.354568,324.031250) },
{ ammo = "plasma", maxammo = 15, pos = Vector(1122.974121,-758.474915,196.031250) },
{ ammo = "plasma", maxammo = 15, pos = Vector(-1179.196045,-457.433044,196.031250) },
{ ammo = "plasma", maxammo = 15, pos = Vector(-281.791748,1474.368164,668.031250) }
}





ItemSpawnPoints["gm_citywalls"] = {
	{ class = "ent_armor", pos = Vector(114.939857,2582.826416,64.031250), dir = Vector(0,-1,0), count = 6},
	{ class = "ent_armor", pos = Vector(1219.691162,2601.419922,64.031250), dir = Vector(0,-1,0), count = 6},
	
	{ class = "ent_armor", pos = Vector(1152.061401,-1727.775146,64.031250), dir = Vector(0,1,0), count = 6},
	{ class = "ent_armor", pos = Vector(544.519714,-1728.044678,64.031250), dir = Vector(0,1,0), count = 6},
	{ class = "ent_armor", pos = Vector(-543.878540,-1727.980103,64.031250), dir = Vector(0,1,0), count = 6},
	{ class = "ent_armor", pos = Vector(-1151.970337,-1728.134033,64.031258), dir = Vector(0,1,0), count = 6},
	
	{ class = "ent_healthkit", pos = Vector(-1374.924316,-90.300522,68.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_healthkit", pos = Vector(-1374.924316,191.362274,68.031250), dir = Vector(0,0,0), count = 1},
	
	{ class = "ent_healthvial", pos = Vector(-1364.026978,2285.066162,368.031250), dir = Vector(1,0,0), count = 6},
	
	{ class = "ent_healthkit", pos = Vector(-1300.092163,1863.336426,68.031235), dir = Vector(0,0,0), count = 1},
	{ class = "ent_healthvial", pos = Vector(-1300.092163,1543.604004,68.031235), dir = Vector(0,0,0), count = 1},
	{ class = "ent_healthvial", pos = Vector(-1300.092163,2185.125977,68.031265), dir = Vector(0,0,0), count = 1},
	
	{ class = "ent_armor", pos = Vector(-246.473404,2265.004883,668.031250), dir = Vector(0,-1,0), count = 6},
	
	{ class = "ent_healthvial", pos = Vector(1120.479492,1039.691284,68.031258), dir = Vector(1,0,0), count = 6},
	{ class = "ent_healthvial", pos = Vector(2002.569946,436.114258,72.031250), dir = Vector(0,1,0), count = 6},
	{ class = "ent_healthvial", pos = Vector(2002.569946,-777.684570,72.031250), dir = Vector(0,1,0), count = 6},
	{ class = "ent_healthkit", pos = Vector(1134.437866,1835.962402,68.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_healthkit", pos = Vector(1339.423340,1835.962402,68.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_armor", pos = Vector(1093.503906,1374.842163,68.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_armor", pos = Vector(877.820068,1374.169678,68.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_healthvial", pos = Vector(1958.215454,-588.232178,68.031250), dir = Vector(0,-1,0), count = 6},
	{ class = "ent_quaddamage", pos = Vector(12,10,70), dir = Vector(0,0,0), count = 1},
	{ class = "ent_armoryellow", pos = Vector(1743.418335,-952.401306,196.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_armoryellow", pos = Vector(-1023.305359,1550,368.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_armorred", pos = Vector(-1289.638672,311.436646,68.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_regeneration", pos = Vector(-1018.933350,-1072.522095,196.031250), dir = Vector(0,0,0), count = 1},
	{ class = "ent_invisibility", pos = Vector(938.655396,1634.029053,196.031250), dir = Vector(0,0,0), count = 1}
}













SpawnPoints["gm_construct"] = {
{pos = Vector(1307.268188,-2264.881836,-79.968750)},
{pos = Vector(-5177.489746,-3647.778076,320.031250)},
{pos = Vector(-2958.692871,-1449.744995,112.031250)},
{pos = Vector(1583.998535,977.601013,-79.968750)},
{pos = Vector(-1669.347534,1977.155640,37.854698)}
}
SpawnPoints["gm_citywalls"] = {
{pos = Vector(1975.5047607422,2035.2124023438,64.03125)},
{pos = Vector(2163.4047851563,-1616.7824707031,64.03125)},
{pos = Vector(-1936.2360839844,-1113.5766601563,64.03125)},
{pos = Vector(-1184.3168945313,904.19750976563,64.03125)},
{pos = Vector(175.35925292969,1363.1287841797,64.03125)},
{pos = Vector(-305.79119873047,2249.8918457031,368.03125)},
{pos = Vector(1239.7005615234,-915.08465576172,68.03125)},
{pos = Vector(-321.26986694336,1493.9940185547,968.03125)}
}
if SERVER then
	hook.Add("Initialize","SpawnPoints",function()
		for k,v in pairs(WeaponSpawnPoints) do
			if k == game.GetMap() then
				for z,x in pairs(v) do
					local ent = ents.Create("ent_weaponspawn2")
					ent:SetPos(x.pos + ent:GetUp() * 15)
					ent.Class = x.class
					ent.MDL = x.mdl
					ent:Spawn()
				end
			end
		end
		for k,v in pairs(SpawnPoints) do
			if k == game.GetMap() then
				for z,x in pairs(v) do
					local ent = ents.Create("info_player_abdul")
					ent:SetPos(x.pos)
					ent:Spawn()
				end
			end
		end
		for k,v in pairs(ItemSpawnPoints) do
			if k == game.GetMap() then
				for z,x in pairs(v) do
					for i = 1,x.count do
						local ent = ents.Create(x.class)
						local c = i - 1
						if i == 1 then 
							ent:SetPos(x.pos + x.dir * c * 0)
						else
							ent:SetPos(x.pos + x.dir * c * 30)
						end
						ent:Spawn()
					end
				end
			end
		end
		for k,v in pairs(AmmoSpawnPoints) do
			if k == game.GetMap() then
				for z,x in pairs(v) do
					local ent = ents.Create("ent_ammo")
					ent:SetPos(x.pos)
					ent:SetAmmoTyp(x.ammo)
					ent.MaxAmmo = x.maxammo
					ent:Spawn()
				end
			end
		end
	end)
	function GM:PlayerSelectSpawn( ply )
		local spawns = ents.FindByClass( "info_player_abdul" )
		local random_entry = math.random(#spawns)
		return spawns[random_entry]
	end
end