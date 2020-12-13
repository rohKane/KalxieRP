KRPCore = nil
TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

local deadPeds = {}

RegisterServerEvent('krp-storerobbery:pedDead')
AddEventHandler('krp-storerobbery:pedDead', function(store)
    if not deadPeds[store] then
        deadPeds[store] = 'deadlol'
        TriggerClientEvent('krp-storerobbery:onPedDeath', -1, store)
        local second = 1000
        local minute = 60 * second
        local hour = 60 * minute
        local cooldown = Config.Shops[store].cooldown
        local wait = cooldown.hour * hour + cooldown.minute * minute + cooldown.second * second
        Wait(wait)
        if not Config.Shops[store].robbed then
            for k, v in pairs(deadPeds) do if k == store then table.remove(deadPeds, k) end end
            TriggerClientEvent('krp-storerobbery:resetStore', -1, store)
        end
    end
end)

RegisterServerEvent('krp-storerobbery:handsUp')
AddEventHandler('krp-storerobbery:handsUp', function(store)
    TriggerClientEvent('krp-storerobbery:handsUp', -1, store)
end)

RegisterServerEvent('krp-storerobbery:pickUp')
AddEventHandler('krp-storerobbery:pickUp', function(store)
    local xPlayer = KRPCore.GetPlayerFromId(source)
    local randomAmount = math.random(Config.Shops[store].money[1], Config.Shops[store].money[2])
    xPlayer.addMoney(randomAmount)
    TriggerClientEvent('DoLongHudText', source, 'You got: $' .. randomAmount, 2) 
    TriggerClientEvent('krp-storerobbery:removePickup', -1, store) 
end)

KRPCore.RegisterServerCallback('krp-storerobbery:canRob', function(source, cb, store)
    local cops = 0
    local xPlayers = KRPCore.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = KRPCore.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            cops = cops + 1
        end
    end
    if cops >= Config.Shops[store].cops then
        if not Config.Shops[store].robbed and not deadPeds[store] then
            cb(true)
        else
            cb(false)
        end
    else
        cb('no_cops')
    end
end)

RegisterServerEvent('krp-storerobbery:notif')
AddEventHandler('krp-storerobbery:notif', function(store)
    local src = source
    local xPlayers = KRPCore.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = KRPCore.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            TriggerClientEvent('krp-storerobbery:msgPolice', src, store)
            return
        end
    end
end)

RegisterServerEvent('krp-storerobbery:rob')
AddEventHandler('krp-storerobbery:rob', function(store)
    local src = source
    Config.Shops[store].robbed = true
    TriggerClientEvent('krp-storerobbery:rob', -1, store)
    Wait(30000)
    TriggerClientEvent('krp-storerobbery:robberyOver', src)

    local second = 1000
    local minute = 60 * second
    local hour = 60 * minute
    local cooldown = Config.Shops[store].cooldown
    local wait = cooldown.hour * hour + cooldown.minute * minute + cooldown.second * second
    Wait(wait)
    Config.Shops[store].robbed = false
    for k, v in pairs(deadPeds) do if k == store then table.remove(deadPeds, k) end end
    TriggerClientEvent('krp-storerobbery:resetStore', -1, store)
end)

Citizen.CreateThread(function()
    while true do
        for i = 1, #deadPeds do TriggerClientEvent('krp-storerobbery:pedDead', -1, i) end -- update dead peds
        Citizen.Wait(500)
    end
end)
