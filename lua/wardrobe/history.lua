local L = wardrobe.language and wardrobe.language.get or function(s) return s end

wardrobe.history = wardrobe.history or {}

local meta = {}
	meta.add = function(mdl) wardrobe.history[mdl.model] = mdl end
	meta.remove = function(mdl) wardrobe.history[mdl] = nil end
	meta.get = function(mdl) return wardrobe.history[mdl] or nil end
	meta.from = function(json) for k, v in pairs(util.JSONToTable(json)) do wardrobe.history[k] = v end end
	meta.empty = function() wardrobe.history = {} end
	meta.save = function() local d = util.TableToJSON(wardrobe.history, true) if d then file.Write("wardrobe_history.txt", d) end end
	meta.load = function() local d = file.Read("wardrobe_history.txt", "DATA") if d then wardrobe.history.from(d) end end
	meta.last = function()
		last_model = nil
		for k, v in pairs(wardrobe.history) do
			if not last_model or (v.last_used or 0) > (last_model.last_used or 0) then
				last_model = v
			end
		end
		return last_model
	end
setmetatable(wardrobe.history, {__index = meta})
