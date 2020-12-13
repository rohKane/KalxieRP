KRPCore               = nil

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

KRPCore.RegisterUsableItem('binoculars', function(source)
    local xPlayer = KRPCore.GetPlayerFromId(source)
    local drill = xPlayer.getInventoryItem('binoculars')

    TriggerClientEvent('binoculars:Activate', source)
end)