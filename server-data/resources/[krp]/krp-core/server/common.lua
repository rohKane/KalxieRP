KRPCore                      = {}
KRPCore.Players              = {}
KRPCore.UsableItemsCallbacks = {}
KRPCore.Items                = {}
KRPCore.ServerCallbacks      = {}
KRPCore.TimeoutCount         = -1
KRPCore.CancelledTimeouts    = {}
KRPCore.LastPlayerData       = {}
KRPCore.Pickups              = {}
KRPCore.PickupId             = 0
KRPCore.Jobs                 = {}

AddEventHandler('krp:getSharedObject', function(cb)
	cb(KRPCore)
end)

function getSharedObject()
	return KRPCore
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for i=1, #result, 1 do
			KRPCore.Items[result[i].name] = {
				label     = result[i].label,
				limit     = result[i].limit,
				rare      = (result[i].rare       == 1 and true or false),
				canRemove = (result[i].can_remove == 1 and true or false),
			}
		end
	end)

	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result do
		KRPCore.Jobs[result[i].name] = result[i]
		KRPCore.Jobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2 do
		if KRPCore.Jobs[result2[i].job_name] then
			KRPCore.Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
		else
			print(('krp-core: invalid job "%s" from table job_grades ignored!'):format(result2[i].job_name))
		end
	end

	for k,v in pairs(KRPCore.Jobs) do
		if next(v.grades) == nil then
			KRPCore.Jobs[v.name] = nil
			print(('krp-core: ignoring job "%s" due to missing job grades!'):format(v.name))
		end
	end
end)

AddEventHandler('krp:playerLoaded', function(source)
	local xPlayer         = KRPCore.GetPlayerFromId(source)
	local accounts        = {}
	local items           = {}
	local xPlayerAccounts = xPlayer.getAccounts()

	for i=1, #xPlayerAccounts, 1 do
		accounts[xPlayerAccounts[i].name] = xPlayerAccounts[i].money
	end

	KRPCore.LastPlayerData[source] = {
		accounts = accounts,
		items    = items
	}
end)

RegisterServerEvent('krp:clientLog')
AddEventHandler('krp:clientLog', function(msg)
	RconPrint(msg .. "\n")
end)

RegisterServerEvent('krp:triggerServerCallback')
AddEventHandler('krp:triggerServerCallback', function(name, requestId, ...)
	local _source = source

	KRPCore.TriggerServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('krp:serverCallback', _source, requestId, ...)
	end, ...)
end)
