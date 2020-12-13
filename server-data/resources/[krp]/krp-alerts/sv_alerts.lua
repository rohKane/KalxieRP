RegisterServerEvent("krp-alerts:teenA")
AddEventHandler("krp-alerts:teenA",function(targetCoords)
    TriggerClientEvent('krp-alerts:policealertA', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:teenB")
AddEventHandler("krp-alerts:teenB",function(targetCoords)
    TriggerClientEvent('krp-alerts:policealertB', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:teenpanic")
AddEventHandler("krp-alerts:teenpanic",function(targetCoords)
    TriggerClientEvent('krp-alerts:panic', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:fourA")
AddEventHandler("krp-alerts:fourA",function(targetCoords)
    TriggerClientEvent('krp-alerts:tenForteenA', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:fourB")
AddEventHandler("krp-alerts:fourB",function(targetCoords)
    TriggerClientEvent('krp-alerts:tenForteenB', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:downperson")
AddEventHandler("krp-alerts:downperson",function(targetCoords)
    TriggerClientEvent('krp-alerts:downalert', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:sveh")
AddEventHandler("krp-alerts:sveh",function(targetCoords)
    TriggerClientEvent('krp-alerts:vehiclesteal', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:shoot")
AddEventHandler("krp-alerts:shoot",function(targetCoords)
    TriggerClientEvent('krp-outlawalert:gunshotInProgress', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:figher")
AddEventHandler("krp-alerts:figher",function(targetCoords)
    TriggerClientEvent('krp-outlawalert:combatInProgress', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:storerob")
AddEventHandler("krp-alerts:storerob",function(targetCoords)
    TriggerClientEvent('krp-alerts:storerobbery', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:houserob")
AddEventHandler("krp-alerts:houserob",function(targetCoords)
    TriggerClientEvent('krp-alerts:houserobbery', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:tbank")
AddEventHandler("krp-alerts:tbank",function(targetCoords)
    TriggerClientEvent('krp-alerts:banktruck', -1, targetCoords)
	return
end)

RegisterServerEvent("krp-alerts:robjew")
AddEventHandler("krp-alerts:robjew",function()
    TriggerClientEvent('krp-alerts:jewelrobbey', -1)
	return
end)

RegisterServerEvent("krp-alerts:bjail")
AddEventHandler("krp-alerts:bjail",function()
    TriggerClientEvent('krp-alerts:jewelrobbey', -1)
	return
end)