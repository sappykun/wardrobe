local print = wardrobe and wardrobe.dbg or print
local err = wardrobe and wardrobe.err or function(a) ErrorNoHalt(a .. "\n") end

workshop = workshop or {}

workshop.got = {}
workshop.reasons = {}
workshop.fileInfo = workshop.fileInfo or {}
workshop.mounting = workshop.mounting or {}
workshop.mounted = workshop.mounted or {}

workshop.currentQueueSize = 0

WS_NOFILEINFO     = 1
WS_FILETOOBIG     = 2
WS_DOWNLOADFAILED = 3
WS_MISSINGFILE    = 4

workshop.reverseEnum = {
	[-100] = "Unknown", -- TODO: make this less ugly
	"WS_NOFILEINFO",
	"WS_FILETOOBIG",
	"WS_DOWNLOADFAILED",
	"WS_MISSINGFILE",
}

local IGNORE = function() end

function workshop.err(wsid, reason)
	workshop.currentQueueSize = workshop.currentQueueSize - 1

	workshop.got[wsid] = nil
	workshop.reasons[wsid] = reason

	reason_str = workshop.reverseEnum[reason] or gmamalicious.reverseEnum[reason] or reason

	err("Workshop | Error getting '" .. wsid  .. "' (" .. reason_str .. ")")
end

workshop.maxsize = wardrobe and wardrobe.config.maxFileSize or 0
workshop.whitelist = wardrobe and wardrobe.config.whitelistIds or {}

local _fetch
do
	local compare_date = os.time({year = 2020, month = 1, day = 20, hour = 0, min = 0, sec = 0})

	function _fetch(wsid, fileInfo, validate, callback)
		if not fileInfo or not fileInfo.fileid then
			return workshop.err(wsid, WS_NOFILEINFO)
		end

		local maxsz = bit.lshift(workshop.maxsize, 20)

		if math.floor(maxsz) > 0 and (fileInfo.size or 0) > maxsz and not workshop.whitelist[wsid] then
			return workshop.err(wsid, WS_FILETOOBIG)
		end

		local ok, _err = validate(wsid, fileInfo)
		if ok == false then
			return workshop.err(wsid, _err or -100)
		end

		print("Workshop | Downloading", wsid)

		local date = math.max(fileInfo.created or 0, fileInfo.updated or 0)
		if date <= 1 then
			date = math.huge
		end

		if date > compare_date then
			print("Workshop | New addon format, if workshop gives up (hangs on LOADING) then you should too")

			steamworks.DownloadUGC(wsid, function(path, handle)
				if not path then
					return workshop.err(wsid, WS_DOWNLOADFAILED)
				end

				-- if not file.Exists(path, "MOD") then
				-- 	return workshop.err(wsid, WS_MISSINGFILE)
				-- end

				print("Workshop | Path:", path)

				workshop.got[wsid] = nil -- why? BECAUSE IT CANNOT BE REREAD AFTER HANDLE DIES, FUCKING GARBAGE
				workshop.reasons[wsid] = path

				callback(path, fileInfo, false, true, handle)
			end)

			return
		end

		steamworks.Download(fileInfo.fileid, true, function(path)
			if not path then
				return workshop.err(wsid, WS_DOWNLOADFAILED)
			end

			if not file.Exists(path, "MOD") then
				return workshop.err(wsid, WS_MISSINGFILE)
			end

			print("Workshop | Path:", path)

			workshop.got[wsid] = true
			workshop.reasons[wsid] = path

			callback(path, fileInfo, false, false)
		end)
	end
end

local function _getAddon(wsid, validate, callback)
	local dat = workshop.got[wsid]
	local info = workshop.fileInfo[wsid]

	if dat ~= nil then
		if dat then
			callback(workshop.reasons[wsid], info, true)
			return true
		else
			workshop.currentQueueSize = workshop.currentQueueSize - 1
			return false
		end
	end

	print("Workshop | Getting info for ", wsid)

	if info then
		_fetch(wsid, info, validate, callback)
	else
		print("Workshop | Cache not found, finding info for", wsid)

		steamworks.FileInfo(wsid, function(result)
			workshop.fileInfo[wsid] = result
			_fetch(wsid, result, validate, callback)
		end)
	end

	return nil
end

local crashPath = "workshop_crashed_while_mounting.dat"
function workshop.crashed()
	if file.Exists(crashPath, "DATA") then
		local data = file.Read(crashPath, "DATA")
		file.Delete(crashPath)

		return data
	end

	return false
end

function workshop.isWorking()
	return workshop.currentQueueSize > 0
end

local function _mount(wsid, info, path, post)
	local c = workshop.mounted[wsid]
	if c then
		workshop.currentQueueSize = workshop.currentQueueSize - 1
		return post(wsid, info, path, c[1], c[2], c[3])
	end

	workshop.mounting[#workshop.mounting + 1] = {wsid, info, path, post}
end

local function _mountInternal(wsid, info, path, post, handle)
	local gma = gmaparser and gmaparser.open(path, handle)
	if gma then pcall(gma.parse, gma) end

	local t = SysTime()

	local ok, files
	if not (gma and gma:isValid() and gma:alreadyMounted(true)) then
		local last_mod_delta = os.time() - (file.Time(path, "GAME") or 0)
		file.Write(crashPath, "Addon: " .. wsid .. ", Path: " .. path .. "\nTime delta: " .. last_mod_delta)
			ok, files = game.MountGMA(path)
		timer.Simple(1, workshop.crashed) -- Let's be honest, if you crash within 1 second of mounting, I'm pretty sure we know what did you in
	else
		ok = true
		files = gma.fileNames

		print("Workshop | Addon is already mounted! Skipping.")
	end

	local took = SysTime() - t

	post(wsid, info, path, ok or false, files, took, handle)
	workshop.mounted[wsid] = {ok or false, files, took}

	print("Workshop | Mount function for addon took " .. math.Round(took, 3) .. " seconds.")

	return took
end

do
	local nextMount = 0

	local function _performMount()
		if #workshop.mounting == 0 then
			nextMount = CurTime() + 3
			return
		end

		local tbl = table.remove(workshop.mounting, 1)
		if #workshop.mounting == 0 then
			workshop.currentQueueSize = 0
		end

		took = _mountInternal(unpack(tbl))
		nextMount = CurTime() + (took * 10) + 1
	end

	hook.Add("Think", "workshop.mounting", function()
		if CurTime() >= nextMount then _performMount() end
	end)
end

function workshop.get(wsid, validateinfo, validatefile, postmount)
	validateinfo = validateinfo or IGNORE
	validatefile = validatefile or IGNORE
	postmount    = postmount or IGNORE

	workshop.currentQueueSize = workshop.currentQueueSize + 1
	print("Workshop | Attempting to get", wsid)

	return _getAddon(wsid, validateinfo, function(path, info, passedBefore, newFormat, handle)
		print("Workshop | Got, now validating", wsid)
		local ok = validatefile(wsid, info, path, passedBefore, handle)
		if ok ~= false then
			if newFormat then
				print("Workshop | It's a new format addon, we've got to mount it now before that handle dies!")
				workshop.currentQueueSize = workshop.currentQueueSize - 1
				_mountInternal(wsid, info, path, postmount, handle)
			else
				_mount(wsid, info, path, postmount)
			end
		else
			workshop.currentQueueSize = workshop.currentQueueSize - 1
		end
	end)
end

print("loaded workshop downloader")
