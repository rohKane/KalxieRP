KRPCore = nil
TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)
local chicken = vehicleBaseRepairCost

RegisterServerEvent('krp-bennysmech:attemptPurchase')
AddEventHandler('krp-bennysmech:attemptPurchase', function(type, upgradeLevel)
    local source = source
    local xPlayer = KRPCore.GetPlayerFromId(source)
    if type == "repair" then
        if xPlayer.getMoney() >= chicken then
            xPlayer.removeMoney(chicken)
            TriggerClientEvent('krp-bennysmech:purchaseSuccessful', source)
        else
            TriggerClientEvent('krp-bennysmech:purchaseFailed', source)
        end
    elseif type == "performance" then
        if xPlayer.getMoney() >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('krp-bennysmech:purchaseSuccessful', source)
            xPlayer.removeMoney(vehicleCustomisationPrices[type].prices[upgradeLevel])
        else
            TriggerClientEvent('krp-bennysmech:purchaseFailed', source)
        end
    else
        if xPlayer.getMoney() >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('krp-bennysmech:purchaseSuccessful', source)
            xPlayer.removeMoney(vehicleCustomisationPrices[type].price)
        else
            TriggerClientEvent('krp-bennysmech:purchaseFailed', source)
        end
    end
end)

RegisterServerEvent('krp-bennysmech:updateRepairCost')
AddEventHandler('krp-bennysmech:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterServerEvent('krp-bennysmech:updateVehicle')
AddEventHandler('krp-bennysmech:updateVehicle', function(myCar)
    MySQL.Async.execute('UPDATE `owned_vehicles` SET `vehicle` = @vehicle WHERE `plate` = @plate',
	{
		['@plate']   = myCar.plate,
		['@vehicle'] = json.encode(myCar)
	})
end)