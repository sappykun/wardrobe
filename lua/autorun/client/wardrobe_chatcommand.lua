hook.Add("OnPlayerChat", "WardrobeChatCommand", function(ply, str)
	local valid = false
	local hide = false
	str = str:Trim()

	for i, cmd in ipairs(wardrobe.config.command) do
		if str:find((wardrobe.config.commandPrefix) .. (cmd) .. "$") == 1 then
			valid = true
			if str:sub(1, 1):find(wardrobe.config.commandPrefixHide) == 1 then
				hide = true
			end
			break
		end
	end

	if ply == LocalPlayer() and valid then
		wardrobe.openMenu()
	end

	if hide then
		return true
	end
end)
