KRPCore = nil

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

AddEventHandler('krp:playerLoaded', function(source)
	TriggerEvent('krp-license:getLicenses', source, function(licenses)
		TriggerClientEvent('krp-dmvschool:loadLicenses', source, licenses)
	end)
end)

RegisterNetEvent('krp-dmvschool:addLicense')
AddEventHandler('krp-dmvschool:addLicense', function(type)
	local _source = source

	TriggerEvent('krp-license:addLicense', _source, type, function()
		TriggerEvent('krp-license:getLicenses', _source, function(licenses)
			TriggerClientEvent('krp-dmvschool:loadLicenses', _source, licenses)
		end)
	end)
end)

RegisterNetEvent('krp-dmvschool:pay')
AddEventHandler('krp-dmvschool:pay', function(price)
	local _source = source
	local xPlayer = KRPCore.GetPlayerFromId(_source)

	xPlayer.removeMoney(price)
	TriggerClientEvent('DoLongHudText', _source, 'You paid $'.. KRPCore.Math.GroupDigits(price) .. ' to the DMV school', 1)
end)
