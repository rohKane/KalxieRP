KRPCore = nil

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

TriggerEvent('es:addGroupCommand', 'spec', "admin", function(source, args, user)
	TriggerClientEvent('krp-spectate:spectate', source, target)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

KRPCore.RegisterServerCallback('krp-spectate:getPlayerData', function(source, cb, id)
	local xPlayer = KRPCore.GetPlayerFromId(id)
	cb(xPlayer)
end)