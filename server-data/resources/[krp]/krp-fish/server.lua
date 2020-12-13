KRPCore = nil

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

RegisterServerEvent('krp-fish:payShit')
AddEventHandler('krp-fish:payShit', function(money)
    local source = source
    local xPlayer  = KRPCore.GetPlayerFromId(source)
    if money ~= nil then
        xPlayer.addMoney(money)
    end
end)

RegisterServerEvent('fish:checkAndTakeDepo')
AddEventHandler('fish:checkAndTakeDepo', function()
local source = source
local xPlayer  = KRPCore.GetPlayerFromId(source)
    xPlayer.removeMoney(500)
end)

RegisterServerEvent('fish:returnDepo')
AddEventHandler('fish:returnDepo', function()
local source = source
local xPlayer  = KRPCore.GetPlayerFromId(source)
    xPlayer.addMoney(500)
end)

RegisterServerEvent('krp-fish:getFish')
AddEventHandler('krp-fish:getFish', function()
local source = source
    TriggerClientEvent('player:receiveItem', source, "fish", math.random(1,2))
end)