if engine.ActiveGamemode() != "fatkid" then
	return
end

print("Wardrobe | Loaded Fat Kid extension!")

SKELETON_MODEL = "models/player/skeleton.mdl"

if CLIENT then
	function OverrideModelSkeletonPlayer(ply, mdl)
		if mdl == SKELETON_MODEL then return true end
	end
	
	function OverrideModelSkeletonRagdoll(rag, mdl)
		if mdl == SKELETON_MODEL then return true end
	end

	hook.Add("Wardrobe_PlayerModelOverride", "wardrobe.extensions.fatkid.playermodel", OverrideModelSkeletonPlayer)
	hook.Add("Wardrobe_RagdollModelOverride", "wardrobe.extensions.fatkid.ragdoll", OverrideModelSkeletonRagdoll)
end