hook.Add("OnPlayerChat", "WardrobeChatCommand", function(ply, str)
	if ply ~= LocalPlayer() then return end

	str = str:Trim()
	for i, cmd in ipairs(wardrobe.config.command) do
		if str:find((wardrobe.config.commandPrefix) .. (cmd) .. "$") == 1 then
			wardrobe.openMenu()
			if str:sub(1, 1):find(wardrobe.config.commandPrefixHide) == 1 then
				return true
			end
			break
		end
	end
end)