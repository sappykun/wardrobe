if engine.ActiveGamemode() != "zombiesurvival" then
	return
end

print("Wardrobe | Loaded Zombie Survival extension!")

if wardrobe and wardrobe.gui then
	wardrobe.gui.optionsSheetTextColor = Color(255, 255, 255, 255)
end

local zombie_classes = GAMEMODE.ZombieClasses

local zombie_override = {
"models/zombie/classic_legs.mdl",
"models/zombie/classic_torso.mdl",
"models/gibs/fast_zombie_legs.mdl",
"models/zombie/poison.mdl",
"models/zombie/fast_v3.mdl",
}

if CLIENT then
	function OverrideModelZombiePlayer(ply, mdl)
		if ply:Team() == 3 then return true end
	end

	function OverrideModelZombieRagdoll(rag, mdl)
		for k, v in pairs(zombie_classes) do
			if v.Model and mdl == v.Model then return true end
		end
		for i, k in ipairs(zombie_override) do
			if mdl == k then return true end
		end
	end

	hook.Add("Wardrobe_PlayerModelOverride", "wardrobe.extensions.zombiesurvival.playermodel", OverrideModelZombiePlayer)
	hook.Add("Wardrobe_RagdollModelOverride", "wardrobe.extensions.zombiesurvival.ragdoll", OverrideModelZombieRagdoll)
end
