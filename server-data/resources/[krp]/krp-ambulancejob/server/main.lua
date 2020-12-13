KRPCore = nil
local playersHealing = {}

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

RegisterServerEvent('krp-ambulancejob:revive')
AddEventHandler('krp-ambulancejob:revive', function(target)
	local xPlayer = KRPCore.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		xPlayer.addMoney(Config.ReviveReward)
		TriggerClientEvent('krp-ambulancejob:revive', target)
	else
	end
end)

RegisterServerEvent('krp-ambulancejob:revivePD')
AddEventHandler('krp-ambulancejob:revivePD', function(target)
	local xPlayer = KRPCore.GetPlayerFromId(source)

	if xPlayer.job.name == 'police' then
		TriggerClientEvent('krp-ambulancejob:revive', target)
	else
	end
end)

RegisterServerEvent('admin:revivePlayer')
AddEventHandler('admin:revivePlayer', function(target)
	if target ~= nil then
		TriggerClientEvent('krp-ambulancejob:revive', target)
		TriggerClientEvent('krp-hospital:client:RemoveBleed', target) 
        TriggerClientEvent('krp-hospital:client:ResetLimbs', target)
	end
end)

RegisterServerEvent('admin:healPlayer')
AddEventHandler('admin:healPlayer', function(target)
	if target ~= nil then
		TriggerClientEvent('krp-basicneeds:healPlayer', target)
	end
end)

RegisterServerEvent('krp-ambulancejob:heal')
AddEventHandler('krp-ambulancejob:heal', function(target, type)
	local xPlayer = KRPCore.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' and type == 'small' then
		TriggerClientEvent('krp-ambulancejob:heal', target, type)

		TriggerClientEvent('krp-hospital:client:RemoveBleed', target) 	
	elseif
	xPlayer.job.name == 'ambulance' and type == 'big' then
		TriggerClientEvent('krp-ambulancejob:heal', target, type)
		--TriggerClientEvent('MF_SkeletalSystem:HealBones', target, "all")
		TriggerClientEvent('krp-hospital:client:RemoveBleed', target) 
		TriggerClientEvent('krp-hospital:client:ResetLimbs', target)
	else
	end
end)

RegisterServerEvent('krp-ambulancejob:putInVehicle')
AddEventHandler('krp-ambulancejob:putInVehicle', function(target)
	local xPlayer = KRPCore.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('krp-ambulancejob:putInVehicle', target)
	else
	end
end)

RegisterServerEvent('krp-ambulancejob:pullOutVehicle')
AddEventHandler('krp-ambulancejob:pullOutVehicle', function(target)
	local xPlayer = KRPCore.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('krp-ambulancejob:pullOutVehicle', target)
	else
	end
end)

RegisterServerEvent('krp-ambulancejob:drag')
AddEventHandler('krp-ambulancejob:drag', function(target)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	_source = source
	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('krp-ambulancejob:drag', target, _source)
	else
	end
end)

RegisterServerEvent('krp-ambulancejob:undrag')
AddEventHandler('krp-ambulancejob:undrag', function(target)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	_source = source
	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('krp-ambulancejob:un_drag', target, _source)
	else
	end
end)

TriggerEvent('krp-phone:registerNumber', 'ambulance', _U('alert_ambulance'), true, true)

TriggerEvent('krp-society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})

KRPCore.RegisterServerCallback('krp-ambulancejob:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = KRPCore.GetPlayerFromId(source)

	if Config.RemoveCashAfterRPDeath then
		if xPlayer.getMoney() > 2000 then
			xPlayer.removeMoney(2000)
		end

		if xPlayer.getAccount('black_money').money > 0 then
			xPlayer.setAccountMoney('black_money', 0)
		end
	end

	if Config.RemoveItemsAfterRPDeath then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	local playerLoadout = {}
	if Config.RemoveWeaponsAfterRPDeath then
		for i=1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else -- save weapons & restore em' since spawnmanager removes them
		for i=1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		-- give back wepaons after a couple of seconds
		Citizen.CreateThread(function()
			Citizen.Wait(5000)
			for i=1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end

	cb()
end)

if Config.EarlyRespawnFine then
	KRPCore.RegisterServerCallback('krp-ambulancejob:checkBalance', function(source, cb)
		local xPlayer = KRPCore.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money

		cb(bankBalance >= Config.EarlyRespawnFineAmount)
	end)

	RegisterServerEvent('krp-ambulancejob:payFine')
	AddEventHandler('krp-ambulancejob:payFine', function()
		local xPlayer = KRPCore.GetPlayerFromId(source)
		local fineAmount = Config.EarlyRespawnFineAmount

		TriggerClientEvent('krp:showNotification', xPlayer.source, _U('respawn_bleedout_fine_msg', KRPCore.Math.GroupDigits(fineAmount)))
		xPlayer.removeAccountMoney('bank', fineAmount)
	end)
end

KRPCore.RegisterServerCallback('krp-ambulancejob:getItemAmount', function(source, cb, item)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count
	cb(quantity)
end)

KRPCore.RegisterServerCallback('krp-ambulancejob:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then -- SHOULD ASK IF THE PRICE = THE CORRECT PRICE. I COULD BUY SOMETHING PRICED 1 AND THIS WOULD PASS
		--DISCORD HOOK HERE
		cb(false)
	else
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price)
	
			MySQL.Async.execute('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`) VALUES (@owner, @vehicle, @plate, @type, @job, @stored)', {
				['@owner'] = xPlayer.identifier,
				['@vehicle'] = json.encode(vehicleProps),
				['@plate'] = vehicleProps.plate,
				['@type'] = type,
				['@job'] = xPlayer.job.name,
				['@stored'] = true
			}, function (rowsChanged)
				cb(true)
			end)
		else
			cb(false)
		end
	end
end)

KRPCore.RegisterServerCallback('krp-ambulancejob:storeNearbyVehicle', function(source, cb, nearbyVehicles)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	local foundPlate, foundNum

	for k,v in ipairs(nearbyVehicles) do
		local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = v.plate,
			['@job'] = xPlayer.job.name
		})

		if result[1] then
			foundPlate, foundNum = result[1].plate, k
			break
		end
	end

	if not foundPlate then
		cb(false)
	else
		MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = true WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = foundPlate,
			['@job'] = xPlayer.job.name
		}, function (rowsChanged)
			if rowsChanged == 0 then
				cb(false)
			else
				cb(true, foundNum)
			end
		end)
	end

end)

function getPriceFromHash(hashKey, jobGrade, type)
	if type == 'helicopter' then
		local vehicles = Config.AuthorizedHelicopters[jobGrade]

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	elseif type == 'car' then
		local vehicles = Config.AuthorizedVehicles[jobGrade]

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	end

	return 0
end

RegisterServerEvent('krp-ambulancejob:giveItem')
AddEventHandler('krp-ambulancejob:giveItem', function(itemName)
	local xPlayer = KRPCore.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'ambulance' then
		return
	elseif (itemName ~= 'medikit' and itemName ~= 'bandage' and itemName ~= 'medkit' and itemName ~= 'firstaid' and itemName ~= 'gauze' and itemName ~= 'vicodin' and itemName ~= 'hydrocodone' and itemName ~= 'morphine') then
		return
	end

	local xItem = xPlayer.getInventoryItem(itemName)
	local count = 1

	if xItem.limit ~= -1 then
		count = xItem.limit - xItem.count
	end

	if xItem.count < xItem.limit then
		xPlayer.addInventoryItem(itemName, count)
	else
		TriggerClientEvent('krp:showNotification', source, _U('max_item'))
	end
end)

TriggerEvent('es:addGroupCommand', 'revive', 'admin', function(source, args, user)
	if args[1] ~= nil then
		if GetPlayerName(tonumber(args[1])) ~= nil then
			TriggerClientEvent('krp-ambulancejob:revive', tonumber(args[1]))
			--TriggerClientEvent('MF_SkeletalSystem:HealBones', tonumber(args[1]), "all")
			TriggerClientEvent('krp-hospital:client:RemoveBleed', tonumber(args[1])) 
		    TriggerClientEvent('krp-hospital:client:ResetLimbs', tonumber(args[1]))
		end
	else
		TriggerClientEvent('krp-ambulancejob:revive', source)
		TriggerClientEvent('krp-_hospital:client:RemoveBleed', source) 
		TriggerClientEvent('krp-hospital:client:ResetLimbs', source)
		--TriggerClientEvent('MF_SkeletalSystem:HealBones', source, "all")
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessagess', source, 'SYSTEM: ', 3, 'Insufficient Permissions.')
end, { help = _U('revive_help'), params = {{ name = 'id' }} })


KRPCore.RegisterServerCallback('krp-ambulancejob:getDeathStatus', function(source, cb)
	local identifier = GetPlayerIdentifiers(source)[1]

	MySQL.Async.fetchScalar('SELECT is_dead FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(isDead)
		if isDead then
			--print(('krp-ambulancejob: %s attempted combat logging!'):format(identifier))
		end

		cb(isDead)
	end)
end)

RegisterServerEvent('krp-ambulancejob:drag')
AddEventHandler('krp-ambulancejob:drag', function(target)
	local xPlayer = KRPCore.GetPlayerFromId(source)
	TriggerClientEvent('krp-ambulancejob:drag', target, source)
end)

RegisterServerEvent('krp-ambulancejob:setDeathState')
AddEventHandler('krp-ambulancejob:setDeathState', function(isDead)
	local identifier = GetPlayerIdentifiers(source)[1]

	if type(isDead) ~= 'boolean' then
		return
	end

	MySQL.Sync.execute('UPDATE users SET is_dead = @isDead WHERE identifier = @identifier', {
		['@identifier'] = identifier,
		['@isDead'] = isDead
	})
end)



