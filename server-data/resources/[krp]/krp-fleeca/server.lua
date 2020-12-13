KRPCore = nil
TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

RegisterServerEvent("krp-fleeca:startcheck")
AddEventHandler("krp-fleeca:startcheck", function(bank)
    local _source = source
    local copcount = 2
    local Players = KRPCore.GetPlayers()

    for i = 1, #Players, 1 do
        local xPlayer = KRPCore.GetPlayerFromId(Players[i])

        if xPlayer.job.name == "police" then
            copcount = copcount + 2
        end
    end
    local xPlayer = KRPCore.GetPlayerFromId(_source)

    if copcount >= fleeca.mincops then
        if not fleeca.Banks[bank].onaction == true then
            if (os.time() - fleeca.cooldown) > fleeca.Banks[bank].lastrobbed then
                fleeca.Banks[bank].onaction = true
                TriggerClientEvent('inventory:removeItem', _source, 'thermite', 1)
                TriggerClientEvent("krp-fleeca:outcome", _source, true, bank)
                TriggerClientEvent("krp-fleeca:policenotify", -1, bank)
                TriggerClientEvent('krp-dispatch:bankrobbery', -1)
                    return
                else
                    TriggerClientEvent("krp-fleeca:outcome", _source, false, "This bank recently robbed. You need to wait "..math.floor((fleeca.cooldown - (os.time() - fleeca.Banks[bank].lastrobbed)) / 60)..":"..math.fmod((fleeca.cooldown - (os.time() - fleeca.Banks[bank].lastrobbed)), 60))
                end
            else
            TriggerClientEvent("krp-fleeca:outcome", _source, false, "This bank is currently being robbed.")
        end
    else
        TriggerClientEvent("krp-fleeca:outcome", _source, false, "There is not enough police in the city.")
    end
end)

RegisterServerEvent("krp-fleeca:lootup")
AddEventHandler("krp-fleeca:lootup", function(var, var2)
    TriggerClientEvent("krp-fleeca:lootup_c", -1, var, var2)
end)

RegisterServerEvent("krp-fleeca:openDoor")
AddEventHandler("krp-fleeca:openDoor", function(coords, method)
    TriggerClientEvent("krp-fleeca:openDoor_c", -1, coords, method)
end)

RegisterServerEvent("krp-fleeca:startLoot")
AddEventHandler("krp-fleeca:startLoot", function(data, name, players)
    local _source = source

    for i = 1, #players, 1 do
        TriggerClientEvent("krp-fleeca:startLoot_c", players[i], data, name)
    end
    TriggerClientEvent("krp-fleeca:startLoot_c", _source, data, name)
end)

RegisterServerEvent("krp-fleeca:stopHeist")
AddEventHandler("krp-fleeca:stopHeist", function(name)
    TriggerClientEvent("krp-fleeca:stopHeist_c", -1, name)
end)

RegisterServerEvent("krp-fleeca:rewardCash")
AddEventHandler("krp-fleeca:rewardCash", function()
    local xPlayer = KRPCore.GetPlayerFromId(source)
    local reward = math.random(1, 2)
    local mathfunc = math.random(200)
    local payout = math.random(2,4)
    if mathfunc == 15 then
      TriggerClientEvent('player:receiveItem', source, 'goldbar', payout)
    end
    TriggerClientEvent("player:receiveItem", source, "band", reward)
end)

RegisterServerEvent("krp-fleeca:setCooldown")
AddEventHandler("krp-fleeca:setCooldown", function(name)
    fleeca.Banks[name].lastrobbed = os.time()
    fleeca.Banks[name].onaction = false
    TriggerClientEvent("krp-fleeca:resetDoorState", -1, name)
end)

KRPCore.RegisterServerCallback("krp-fleeca:getBanks", function(source, cb)
    cb(fleeca.Banks)
end)