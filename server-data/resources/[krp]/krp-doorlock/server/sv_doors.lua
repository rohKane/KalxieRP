local steamIds = {
    ["steam:11000010aa15521"] = true --kevin
}

local KRPCore = nil
-- KRPCore
TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

RegisterServerEvent('krp-doors:alterlockstate2')
AddEventHandler('krp-doors:alterlockstate2', function()
    --krp.DoorCoords[10]["lock"] = 0

    TriggerClientEvent('krp-doors:alterlockstateclient', source, krp.DoorCoords)

end)

RegisterServerEvent('krp-doors:alterlockstate')
AddEventHandler('krp-doors:alterlockstate', function(alterNum)
    print('lockstate:', alterNum)
    krp.alterState(alterNum)
end)

RegisterServerEvent('krp-doors:ForceLockState')
AddEventHandler('krp-doors:ForceLockState', function(alterNum, state)
    krp.DoorCoords[alterNum]["lock"] = state
    TriggerClientEvent('krp:Door:alterState', -1,alterNum,state)
end)

RegisterServerEvent('krp-doors:requestlatest')
AddEventHandler('krp-doors:requestlatest', function()
    local src = source 
    local steamcheck = KRPCore.GetPlayerFromId(source).identifier
    if steamIds[steamcheck] then
        TriggerClientEvent('doors:HasKeys',src,true)
    end
    TriggerClientEvent('krp-doors:alterlockstateclient', source,krp.DoorCoords)
end)

function isDoorLocked(door)
    if krp.DoorCoords[door].lock == 1 then
        return true
    else
        return false
    end
end