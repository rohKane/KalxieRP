KRPCore = nil
TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)
local chicken = vehicleBaseRepairCost

RegisterServerEvent('krp-bennys:attemptPurchase')
AddEventHandler('krp-bennys:attemptPurchase', function(type, upgradeLevel)
    local source = source
    local xPlayer = KRPCore.GetPlayerFromId(source)
    if type == "repair" then
        if xPlayer.getMoney() >= chicken then
            xPlayer.removeMoney(chicken)
            TriggerClientEvent('krp-bennys:purchaseSuccessful', source)
        else
            TriggerClientEvent('krp-bennys:purchaseFailed', source)
        end
    elseif type == "performance" then
        if xPlayer.getMoney() >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('krp-bennys:purchaseSuccessful', source)
            xPlayer.removeMoney(vehicleCustomisationPrices[type].prices[upgradeLevel])
        else
            TriggerClientEvent('krp-bennys:purchaseFailed', source)
        end
    else
        if xPlayer.getMoney() >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('krp-bennys:purchaseSuccessful', source)
            xPlayer.removeMoney(vehicleCustomisationPrices[type].price)
        else
            TriggerClientEvent('krp-bennys:purchaseFailed', source)
        end
    end
end)

RegisterServerEvent('krp-bennys:updateRepairCost')
AddEventHandler('krp-bennys:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterServerEvent('updateVehicle')
AddEventHandler('updateVehicle', function(myCar)
    MySQL.Async.execute('UPDATE `owned_vehicles` SET `vehicle` = @vehicle WHERE `plate` = @plate',
	{
		['@plate']   = myCar.plate,
		['@vehicle'] = json.encode(myCar)
	})
end)