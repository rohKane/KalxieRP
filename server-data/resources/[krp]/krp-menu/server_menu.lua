KRPCore = nil

TriggerEvent('krp:getSharedObject', function(obj)
    KRPCore = obj
end)

RegisterServerEvent('krp-interactions:putInVehicle')
AddEventHandler('krp-interactions:putInVehicle', function(target)
    TriggerClientEvent('krp-interactions:putInVehicle', target)
end)

RegisterServerEvent('krp-interactions:outOfVehicle')
AddEventHandler('krp-interactions:outOfVehicle', function(target)
    TriggerClientEvent('krp-interactions:outOfVehicle', target)
end)
