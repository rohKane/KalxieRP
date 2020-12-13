
KRPCore = nil

Citizen.CreateThread(function()
	while KRPCore == nil do
		TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('krp:playerLoaded', function (source)
	TriggerEvent("playerSpawned")
end)


RegisterServerEvent('CheckMyLicense')
AddEventHandler('CheckMyLicense', function()
  local _src = source
  local player = KRPCore.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE owner = @owner', {
      ['@owner'] = player.identifier
    }, function (result)
      if result[1] ~= nil then
        if result[1].type == 'weapon'then
        TriggerClientEvent('wtflols',_src, player.getMoney(), 1)
        end
      end
    end)
end)

