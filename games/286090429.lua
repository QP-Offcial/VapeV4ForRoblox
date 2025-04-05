local vape = shared.vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/QP-Offcial/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local old
old = hookfunction(getfenv,function(...)
    if not checkcaller() then
        return getrenv(...)
    end
    return old(...)
end)

run(function()
	local Disabler
	
	Disabler = vape.Categories.Utility:CreateModule({
		Name = 'Disabler',
        Default = true,
		Function = function(callback)
			if callback and not old then
                old = hookfunction(getfenv,function(...)
                    if not checkcaller() then
                        return getrenv(...)
                    end
                    return old(...)
                end)
			else
				if old and restorefunction then
                    restorefunction(old)
                end
			end
		end
	})
end)
