KRPCore = nil

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

RegisterServerEvent('krp-uberkdshfksksdhfskdjjob:pay')
AddEventHandler('krp-uberkdshfksksdhfskdjjob:pay', function(amount)
	local _source = source
	local xPlayer = KRPCore.GetPlayerFromId(_source)
	xPlayer.addMoney(tonumber(amount))
	TriggerClientEvent('chatMessagess', _source, '', 4, 'You got payed $' .. amount)
end)
