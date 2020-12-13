local playerInjury = {}

function GetCharsInjuries(source)
    return playerInjury[source]
end

RegisterServerEvent('krp-hospital:server:SyncInjuries')
AddEventHandler('krp-hospital:server:SyncInjuries', function(data)
    playerInjury[source] = data
end)