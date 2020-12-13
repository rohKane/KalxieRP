KRPCore = nil

Citizen.CreateThread(function()
	while KRPCore == nil do
		TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)
		Citizen.Wait(0)
	end

	while KRPCore.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = KRPCore.GetPlayerData()
end)

RegisterNetEvent('krp-fines:Anim')
AddEventHandler('krp-fines:Anim', function()
	RequestAnimDict('mp_common')
    while not HasAnimDictLoaded('mp_common') do
        Citizen.Wait(5)
    end
    TaskPlayAnim(PlayerPedId(), "mp_common", "givetake1_a", 8.0, -8, -1, 12, 1, 0, 0, 0)
end)