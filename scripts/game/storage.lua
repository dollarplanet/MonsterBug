local M = {}

local FILE = "save"
local VERSION = 1

local function path()
	return sys.get_save_file("monster_bug", FILE)
end

function M.load()
	local ok, data = pcall(sys.load, path())
	if not ok or type(data) ~= "table" then
		return nil
	end
	if data.version ~= VERSION then
		return nil
	end
	return data
end

function M.save(data)
	data = data or {}
	data.version = VERSION
	local ok, err = pcall(sys.save, path(), data)
	if not ok then
		print("MonsterBug save failed: " .. tostring(err))
	end
	return ok
end

return M
