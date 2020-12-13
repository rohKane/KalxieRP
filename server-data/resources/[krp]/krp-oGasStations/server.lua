KRPCore = nil

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

RegisterServerEvent("carfill:checkmoney")
AddEventHandler("carfill:checkmoney", function(costs,loc)
    local src = source
    local target = KRPCore.GetPlayerFromId(src)

    if not costs
    then
        costs = 0
    end

    if target.get('money') >= costs then
        target.removeMoney(costs)
        TriggerClientEvent("RefuelCarServerReturn", src)
    else
        TriggerEvent("DoLongHudText","You need $",2)
    end
end)