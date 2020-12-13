KRPCore = nil
TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)
---------- Pawn Shop --------------

RegisterServerEvent('krp-pawnshop:selljewels')
AddEventHandler('krp-pawnshop:selljewels', function()
local _source = source
local xPlayer = KRPCore.GetPlayerFromId(_source)
	xPlayer.addMoney(50)
end)