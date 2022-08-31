hook.Add("OnPlayerChat", "WardrobeChatCommand", function(ply, str)
	if ply ~= LocalPlayer() then return end

	str = str:Trim()
	local f = str:find((wardrobe.config.commandPrefix or "[!|/]") .. (wardrobe.config.command or "wardrobe"))
	if f == 1 then
		wardrobe.openMenu()
		if str:sub(1, 1):find(wardrobe.config.commandPrefixHide) == 1 then
			return true
		end
	end
end)