KRPCore = nil

TriggerEvent('krp:getSharedObject', function(obj)
	KRPCore = obj
end)

RegisterServerEvent('chickenpayment:pay')
AddEventHandler('chickenpayment:pay', function()
local _source = source
local xPlayer = KRPCore.GetPlayerFromId(source)
	xPlayer.addMoney(math.random(55,76))
end)