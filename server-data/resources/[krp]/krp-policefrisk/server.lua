KRPCore = nil

TriggerEvent("krp:getSharedObject", function(obj) KRPCore = obj end)

RegisterServerEvent("krp-policefrisk:closestPlayer")
AddEventHandler("krp-policefrisk:closestPlayer", function(closestPlayer)
    _source = source
    target = closestPlayer

    TriggerClientEvent("krp-policefrisk:friskPlayer", target)
end)

RegisterServerEvent("krp-policefrisk:notifyMessage")
AddEventHandler("krp-policefrisk:notifyMessage", function(frisk)
    if frisk == true then
        TriggerClientEvent('chatMessagess', _source, 'Information: ', 4, "I could feel something that reminds of a firearm")
        return
    elseif frisk == false then
        TriggerClientEvent('chatMessagess', _source, 'Information: ', 4, "I could not feel anything")
        return
    end
end)