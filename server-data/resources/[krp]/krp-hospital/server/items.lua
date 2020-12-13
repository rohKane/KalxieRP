KRPCore               = nil

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

----
KRPCore.RegisterUsableItem('gauze', function(source)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('gauze', 1)

	TriggerClientEvent('krp-hospital:items:gauze', source)
end)

KRPCore.RegisterUsableItem('bandaids', function(source)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('bandaids', 1)

	TriggerClientEvent('krp-hospital:items:bandage', source)
end)

KRPCore.RegisterUsableItem('firstaid', function(source)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('firstaid', 1)

	TriggerClientEvent('krp-hospital:items:firstaid', source)
end)

KRPCore.RegisterUsableItem('vicodin', function(source)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vicodin', 1)

	TriggerClientEvent('krp-hospital:items:vicodin', source)
end)

KRPCore.RegisterUsableItem('ifak', function(source)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('ifak', 1)

	TriggerClientEvent('krp-hospital:items:ifak', source)
end)

KRPCore.RegisterUsableItem('hydrocodone', function(source)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('hydrocodone', 1)

	TriggerClientEvent('krp-hospital:items:hydrocodone', source)
end)

KRPCore.RegisterUsableItem('morphine', function(source)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('morphine', 1)

	TriggerClientEvent('krp-hospital:items:morphine', source)
end)
