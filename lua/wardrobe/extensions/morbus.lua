if engine.ActiveGamemode() != "morbusgame" then
	return
end

print("Wardrobe | Loaded Morbus extension!")

if CLIENT then
	function OverrideModelAlien(ply, mdl)
		if mdl == "models/player/verdugo/verdugo.mdl" then return true end
		if mdl == "models/morbus/swarm/enhancedslasher.mdl" then return true end
	end

	hook.Add("Wardrobe_PlayerModelOverride", "wardrobe.extensions.morbus.playermodel", OverrideModelAlien)
	hook.Add("Wardrobe_RagdollModelOverride", "wardrobe.extensions.morbus.ragdoll", OverrideModelAlien)
end
--