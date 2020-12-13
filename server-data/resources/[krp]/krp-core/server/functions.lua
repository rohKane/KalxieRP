KRPCore.Trace = function(str)
	if Config.EnableDebug then
		print('KRPCore> ' .. str)
	end
end

KRPCore.SetTimeout = function(msec, cb)
	local id = KRPCore.TimeoutCount + 1

	SetTimeout(msec, function()
		if KRPCore.CancelledTimeouts[id] then
			KRPCore.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	KRPCore.TimeoutCount = id

	return id
end

KRPCore.ClearTimeout = function(id)
	KRPCore.CancelledTimeouts[id] = true
end

KRPCore.RegisterServerCallback = function(name, cb)
	KRPCore.ServerCallbacks[name] = cb
end

KRPCore.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if KRPCore.ServerCallbacks[name] ~= nil then
		KRPCore.ServerCallbacks[name](source, cb, ...)
	else
		print('krp-core: TriggerServerCallback => [' .. name .. '] does not exist')
	end
end

KRPCore.SavePlayer = function(xPlayer, cb)
	local asyncTasks = {}
	xPlayer.setLastPosition(xPlayer.getCoords())

	-- User accounts
	for i=1, #xPlayer.accounts, 1 do
		if KRPCore.LastPlayerData[xPlayer.source].accounts[xPlayer.accounts[i].name] ~= xPlayer.accounts[i].money then
			table.insert(asyncTasks, function(cb)
				MySQL.Async.execute('UPDATE user_accounts SET money = @money WHERE identifier = @identifier AND name = @name', {
					['@money']      = xPlayer.accounts[i].money,
					['@identifier'] = xPlayer.identifier,
					['@name']       = xPlayer.accounts[i].name
				}, function(rowsChanged)
					cb()
				end)
			end)

			KRPCore.LastPlayerData[xPlayer.source].accounts[xPlayer.accounts[i].name] = xPlayer.accounts[i].money
		end
	end
	
	-- Job, loadout and position
	table.insert(asyncTasks, function(cb)
		MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @job_grade, loadout = @loadout, position = @position WHERE identifier = @identifier', {
			['@job']        = xPlayer.job.name,
			['@job_grade']  = xPlayer.job.grade,
			['@loadout']    = json.encode(xPlayer.getLoadout()),
			['@position']   = json.encode(xPlayer.getLastPosition()),
			['@identifier'] = xPlayer.identifier
		}, function(rowsChanged)
			cb()
		end)
	end)

	Async.parallel(asyncTasks, function(results)
		RconPrint('\27[32m[krp-core] [Saving Player]\27[0m ' .. xPlayer.name .. "^7\n")

		if cb ~= nil then
			cb()
		end
	end)
end

KRPCore.SavePlayers = function(cb)
	local asyncTasks = {}
	local xPlayers   = KRPCore.GetPlayers()

	for i=1, #xPlayers, 1 do
		table.insert(asyncTasks, function(cb)
			local xPlayer = KRPCore.GetPlayerFromId(xPlayers[i])
			KRPCore.SavePlayer(xPlayer, cb)
		end)
	end

	Async.parallelLimit(asyncTasks, 8, function(results)
		RconPrint('\27[32m[krp-core] [Saving All Players]\27[0m' .. "\n")

		if cb ~= nil then
			cb()
		end
	end)
end

KRPCore.StartDBSync = function()
	function saveData()
		KRPCore.SavePlayers()
		SetTimeout(10 * 60 * 1000, saveData)
	end

	SetTimeout(10 * 60 * 1000, saveData)
end

KRPCore.GetPlayers = function()
	local sources = {}

	for k,v in pairs(KRPCore.Players) do
		table.insert(sources, k)
	end

	return sources
end


KRPCore.GetPlayerFromId = function(source)
	return KRPCore.Players[tonumber(source)]
end

KRPCore.GetPlayerFromIdentifier = function(identifier)
	for k,v in pairs(KRPCore.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

KRPCore.RegisterUsableItem = function(item, cb)
	KRPCore.UsableItemsCallbacks[item] = cb
end

KRPCore.UseItem = function(source, item)
	KRPCore.UsableItemsCallbacks[item](source)
end

KRPCore.GetItemLabel = function(item)
	if KRPCore.Items[item] ~= nil then
		return KRPCore.Items[item].label
	end
end

KRPCore.CreatePickup = function(type, name, count, label, player)
	local pickupId = (KRPCore.PickupId == 65635 and 0 or KRPCore.PickupId + 1)

	KRPCore.Pickups[pickupId] = {
		type  = type,
		name  = name,
		count = count
	}

	TriggerClientEvent('krp:pickup', -1, pickupId, label, player)
	KRPCore.PickupId = pickupId
end

KRPCore.DoesJobExist = function(job, grade)
	grade = tostring(grade)

	if job and grade then
		if KRPCore.Jobs[job] and KRPCore.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end