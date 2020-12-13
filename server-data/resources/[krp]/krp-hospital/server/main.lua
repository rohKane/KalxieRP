local beds = {
    { x = 314.589, y = -584.082, z = 44.204, h = 170.0, taken = false, model = 1631638868 },
    { x = 311.1046, y = -583.1647, z = 44.204, h = 170.0, taken = false, model = 1631638868 },
    { x = 317.7204, y = -585.5063, z = 44.204, h = 170.0, taken = false, model = 1631638868 },
    { x = 322.6154, y = -587.3105, z = 44.204, h = 170.0, taken = false, model = 1631638868 },
    { x = 319.4153, y = -580.909, z = 44.204, h = -20.0, taken = false, model = 1631638868 },
    { x = 313.948, y = -578.8614, z = 44.204, h = -20.0, taken = false, model = 1631638868 },
    { x = 309.2876, y = -577.2015, z = 44.204, h = -20.0, taken = false, model = 1631638868 },
}


local bedsTaken = {}
local injuryBasePrice = 50

AddEventHandler('playerDropped', function()
    if bedsTaken[source] ~= nil then
        beds[bedsTaken[source]].taken = false
    end
end)

RegisterServerEvent('krp-hospital:server:RequestBed')
AddEventHandler('krp-hospital:server:RequestBed', function()
    for k, v in pairs(beds) do
        if not v.taken then
            v.taken = true
            bedsTaken[source] = k
            TriggerClientEvent('krp-hospital:client:SendToBed', source, k, v)
            return
        end
    end

    TriggerClientEvent('DoLongHudText',  source, 'No Beds Available', 2)
end)

RegisterServerEvent('krp-hospital:server:RPRequestBed')
AddEventHandler('krp-hospital:server:RPRequestBed', function(plyCoords)
    local foundbed = false
    for k, v in pairs(beds) do
        local distance = #(vector3(v.x, v.y, v.z) - plyCoords)
        if distance < 3.0 then
            if not v.taken then
                v.taken = true
                foundbed = true
                TriggerClientEvent('krp-hospital:client:RPSendToBed', source, k, v)
                return
            else
                TriggerEvent('DoLongHudText', source, 'That bed is taken!', 2)
            end
        end
    end

    if not foundbed then
        TriggerEvent('DoLongHudText', source, 'Not near a hospital bed!', 2)
    end
end)

RegisterServerEvent('krp-hospital:server:EnteredBed')
AddEventHandler('krp-hospital:server:EnteredBed', function()
    local src = source
    local injuries = GetCharsInjuries(src)

    local totalBill = injuryBasePrice

    if injuries ~= nil then
        for k, v in pairs(injuries.limbs) do
            if v.isDamaged then
                totalBill = totalBill + (injuryBasePrice * v.severity)
            end
        end

        if injuries.isBleeding > 0 then
            totalBill = totalBill + (injuryBasePrice * injuries.isBleeding)
        end
    end

	local _source = source
    local xPlayer = KRPCore.GetPlayerFromId(source)
    xPlayer.removeAccountMoney('bank', 50)
    TriggerClientEvent('chatMessagess', source, 'Service: ', 5, 'It was a success, you have been billed for your injuries in the amount of $' .. totalBill ..'.')
    TriggerClientEvent('krp-hospital:client:FinishServices', src)
end)

RegisterServerEvent('krp-hospital:server:LeaveBed')
AddEventHandler('krp-hospital:server:LeaveBed', function(id)
    beds[id].taken = false
end)