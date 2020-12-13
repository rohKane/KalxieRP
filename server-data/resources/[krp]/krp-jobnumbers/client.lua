local JobCount = {}


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

RegisterNetEvent('krp:setJob')
AddEventHandler('krp:setJob', function(job)
	PlayerData.job = job
	TriggerServerEvent('krp-jobnumbers:setjobs', job)
end)

RegisterNetEvent('krp:playerLoaded')
AddEventHandler('krp:playerLoaded', function(xPlayer)
    TriggerServerEvent('krp-jobnumbers:setjobs', xPlayer.job)
end)


RegisterNetEvent('krp-jobnumbers:setjobs')
AddEventHandler('krp-jobnumbers:setjobs', function(jobslist)
   JobCount = jobslist
end)

function jobonline(joblist)
    for i,v in pairs(Config.MultiNameJobs) do
        for u,c in pairs(v) do
            if c == joblist then
                joblist = i
            end
        end
    end

    local amount = 0
    local job = joblist
    if JobCount[job] ~= nil then
        amount = JobCount[job]
    end

    return amount
end


