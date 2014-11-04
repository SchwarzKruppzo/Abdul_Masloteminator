-- Not using script .txt files anymore, manual reload sound set-up

local RS = {}
RS["Weapon_awm.Boltlock"] = "weapons/awm/awm_boltlock.wav" 
RS["Weapon_awm.Boltback"] = "weapons/awm/awm_boltback.wav" 
RS["Weapon_awm.Boltpush"] = "weapons/awm/awm_boltpush.wav" 
RS["Weapon_awm.draw"] = "weapons/awm/awm_deploy.wav" 
RS["Weapon_awm.Clipout"] = "weapons/awm/awm_clipout.wav" 
RS["Weapon_awm.Clipin"] = "weapons/awm/awm_clipin.wav"
RS["Weapon_awm.Cliptap"] = "weapons/awm/awm_cliptap.wav"

local tbl = {channel = CHAN_STATIC,
	volume = 1,
	soundlevel = 70,
	pitchstart = 100,
	pitchend = 100}
	
for k, v in pairs(RS) do
	tbl.name = k
	tbl.sound = v
	
	sound.Add(tbl)
end

local wowgarry = sound.Add -- why am I doing this? because apparently sound.Add doesn't work otherwise what the fuck

tbl = {channel = CHAN_STATIC,
	volume = 1,
	soundlevel = 70,
	pitchstart = 100,
	pitchend = 100}
	
function AddReloadSound(event, sound)
	tbl.name = event
	tbl.sound = sound
	
	wowgarry(tbl)
end