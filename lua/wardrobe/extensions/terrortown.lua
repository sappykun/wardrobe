if engine.ActiveGamemode() != "terrortown" then
	return
end

print("Wardrobe | Loaded Trouble in Terrorist Town extension!")

if SERVER then
	hook.Add("PlayerSetModel", "wardrobe.extensions.terrortown.PlayerSetModel", function(ply)
	   local mdl = GAMEMODE.playermodel or "models/player/phoenix.mdl"

	   if ply.wardrobe and util.IsValidModel(ply.wardrobe) then
		  mdl = ply.wardrobe
	   end

	   util.PrecacheModel(mdl)
	   ply:SetModel(mdl)

	   -- Always clear color state, may later be changed in TTTPlayerSetColor
	   -- We can't override this or else custom models take no damage
	   ply:SetColor(COLOR_WHITE)
	   
	   -- Prevents vanilla TTT from setting the playermodel
	   return true
	end)
end
