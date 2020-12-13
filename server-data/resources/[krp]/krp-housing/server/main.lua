
KRPCore = nil
TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

Citizen.CreateThread(function()
	MySQL.Async.fetchAll("SELECT * FROM `houselocations`", {}, function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				local owned = false
				if tonumber(v.owned) == 1 then
					owned = true
				end
				Config.Houses[v.name] = {
					coords = json.decode(v.coords),
					owned = v.owned,
					price = v.price,
					locked = true,
					adress = v.label, 
					tier = v.tier,
					decorations = {},
				}
			end
		end
		TriggerClientEvent("krp-housing:client:setHouseConfig", -1, Config.Houses)
	end)
end)

local houseowneridentifier = {}
local housekeyholders = {}

RegisterServerEvent('krp-housing:server:setHouses')
AddEventHandler('krp-housing:server:setHouses', function()
	local src = source
	TriggerClientEvent("krp-housing:client:setHouseConfig", src, Config.Houses)
end)

function RandomNumber()
	return math.random(1,9999999)
end

RegisterServerEvent('krp-housing:server:addNewHouse')
AddEventHandler('krp-housing:server:addNewHouse', function(area, coords, price, tier)
	local src = source
	local area = area:gsub("%'", "")
	local price = tonumber(price)
	local tier = tonumber(tier)
	local houseCount = GetHouseStreetCount(area)
	local label = area .. " " .. RandomNumber()
	MySQL.Async.execute('INSERT INTO houselocations (name, label, coords, owned, price, tier) VALUES (@name, @label, @coords, @owned, @price, @tier)', {
		['@name'] = label,
		['@label'] = label,
		['@coords'] = json.encode(coords),
		['@owned'] = 0,
		['@price'] = price,
		['@tier'] = tier
	}, function(result)
		if result then 
			Config.Houses[label] = {
				coords = coords,
				owned = false,
				price = price,
				locked = true,
				adress = label, 
				tier = tier,
			}
			TriggerClientEvent("krp-housing:client:setHouseConfig", -1, Config.Houses)
			TriggerClientEvent('DoLongHudText', src, 'You have added the house: '.. label, 1)
		else
			TriggerClientEvent('DoLongHudText', src, 'YA technical error has occurred, contact an administrator!', 2)
		end
	end)
end)

RegisterServerEvent('krp-housing:server:viewHouse')
AddEventHandler('krp-housing:server:viewHouse', function(house)
	local src     		= source
	local pData 		= KRPCore.GetPlayerFromId(src)
	local houseprice   	= Config.Houses[house].price
	local brokerfee 	= (houseprice / 100 * 5)
	local bankfee 		= (houseprice / 100 * 10) 
	local taxes 		= (houseprice / 100 * 6)

	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = GetPlayerIdentifier(source, 0)
	}, function(pResult)
		if pResult[1].firstname ~= nil then 
			TriggerClientEvent('krp-housing:client:viewHouse', src, houseprice, brokerfee, bankfee, taxes, pResult[1].firstname, pResult[1].lastname)
		else
			print("^5[krp-housing]^0 - ERROR - The player who is trying to buy a house doesn`t have first name")
		end
	end)
end)

RegisterServerEvent('krp-housing:server:buyHouse')
AddEventHandler('krp-housing:server:buyHouse', function(house)
	local src     	= source
	local pData 	= KRPCore.GetPlayerFromId(src)
	local pSteam    = GetPlayerIdentifier(src, 0)
	local price   	= Config.Houses[house].price

	if (pData.getAccount('bank').money >= price) then
		pData.removeBank(price)
		MySQL.Async.execute('INSERT INTO player_houses (house, identifier, keyholders, decorations) VALUES (@house, @identifier, @keyholders, @decorations)', {
			['@house'] = house,
			['@identifier'] = pSteam,
			['@keyholders'] = json.encode(keyyeet),
			['@decorations'] = '[]'
		})
		houseowneridentifier[house] = pSteam
		housekeyholders[house] = {
			[1] = pSteam
		}
		MySQL.Async.execute("UPDATE `houselocations` SET `owned` = 1 WHERE `name` = '"..house.."'")
		TriggerClientEvent('krp-housing:client:SetClosestHouse', src)
		pData.removeAccountMoney('bank', (price * 1.21))
	else
		TriggerClientEvent('DoLongHudText', src, 'You don\'t have enough money!', 2)
	end
end)

RegisterServerEvent('krp-housing:server:lockHouse')
AddEventHandler('krp-housing:server:lockHouse', function(bool, house)
	TriggerClientEvent('krp-housing:client:lockHouse', -1, bool, house)
end)

--------------------------------------------------------------

--------------------------------------------------------------

KRPCore.RegisterServerCallback('krp-housing:server:hasKey', function(source, cb, house)
	local src = source
	local xPlayer = KRPCore.GetPlayerFromId(src)
	local Player = KRPCore.GetPlayerFromId(src)
	local retval = false
	if Player ~= nil then 
		local identifier = GetPlayerIdentifier(source, 0)
		if hasKey(identifier, house) then
			retval = true
		elseif xPlayer.job.name == "realestateagent" then
			retval = true
		else
			retval = false
		end
	end
	
	cb(retval)
end)

KRPCore.RegisterServerCallback('krp-housing:server:isOwned', function(source, cb, house)
	if houseowneridentifier[house] ~= nil then
		cb(true)
	else
		cb(false)
	end
end)

KRPCore.RegisterServerCallback('krp-housing:server:getHouseOwner', function(source, cb, house)
    local identifier = GetPlayerIdentifiers(source)[1]
	cb(houseowneridentifier[house])
end)

KRPCore.RegisterServerCallback('krp-housing:server:getHouseKeyHolders', function(source, cb, house)
	local retval = {}
	local Player = KRPCore.GetPlayerFromId(source)
	local PlayerSteam = GetPlayerIdentifier(source, 0)
	if housekeyholders[house] ~= nil then 
		for i = 1, #housekeyholders[house], 1 do
			if PlayerSteam ~= housekeyholders[house][i] then
				MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = '"..housekeyholders[house][i].."'", {}, function(result)
					if result[1] ~= nil then 
						table.insert(retval, {
							firstname = result[1].firstname,
							lastname = result[1].lastname,
							identifier = housekeyholders[house][i],
						})
					end
					cb(retval)
				end)
			end
		end
	else
		cb(nil)
	end
end)

KRPCore.RegisterServerCallback('krp-phone:server:GetPlayerHouses', function(source, cb)
	local src = source
	local Player = KRPCore.GetPlayerFromId(src)
	local MyHouses = {}
	local keyholders = {}

	MySQL.Async.fetchAll('SELECT * FROM player_houses WHERE identifier = @identifier', {
			['@identifier'] = GetPlayerIdentifier(src, 0)
		}, function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				v.keyholders = json.decode(v.keyholders)
				if v.keyholders ~= nil and next(v.keyholders) then
					for f, data in pairs(v.keyholders) do
						MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '"..data.."'", {}, function(keyholderdata)
							if keyholderdata[1] ~= nil then
								keyholders[f] = keyholderdata[1]
							end
						end)
					end
				else
					keyholders[1] = Player.PlayerData
				end

				table.insert(MyHouses, {
					name = v.house,
					keyholders = keyholders,
					owner = v.identifier,
					price = Config.Houses[v.house].price,
					label = Config.Houses[v.house].adress,
					tier = Config.Houses[v.house].tier,
				})
			end
				
			cb(MyHouses)
		end
	end)
end)


function hasKey(identifier, house)
	if houseowneridentifier[house] ~= nil then
		if houseowneridentifier[house] == identifier then
			return true
		else
			if housekeyholders[house] ~= nil then 
				for i = 1, #housekeyholders[house], 1 do
					if housekeyholders[house][i] == identifier then
						return true
					end
				end
			end
		end
	end
	return false
end

RegisterServerEvent('krp-housing:server:giveKey')
AddEventHandler('krp-housing:server:giveKey', function(house, target)
	local pData = KRPCore.GetPlayerFromId(target)
	local pSteam = GetPlayerIdentifier(target, 0)

	table.insert(housekeyholders[house], pSteam)
	MySQL.Async.execute("UPDATE `player_houses` SET `keyholders` = '"..json.encode(housekeyholders[house]).."' WHERE `house` = '"..house.."'")
end)

RegisterServerEvent('krp-housing:server:removeHouseKey')
AddEventHandler('krp-housing:server:removeHouseKey', function(house, citizenData)
	local src = source
	local pSteam = GetPlayerIdentifier(src, 0)
	local newHolders = {}
	if housekeyholders[house] ~= nil then 
		for k, v in pairs(housekeyholders[house]) do
			if housekeyholders[house][k] ~= pSteam then
				table.insert(newHolders, housekeyholders[house][k])
			end
		end
	end
	MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = '"..housekeyholders[house][i].."'", {}, function(result)
		housekeyholders[house] = newHolders
		TriggerClientEvent('DoLongHudText', src, result[1].firstname .. "" .. result[1].lastname .. " keys have been removed.", 1)
	end)
	MySQL.Async.execute("UPDATE `player_houses` SET `keyholders` = '"..json.encode(housekeyholders[house]).."' WHERE `house` = '"..house.."'")
end)

function typeof(var)
    local _type = type(var);
    if(_type ~= "table" and _type ~= "userdata") then
        return _type;
    end
    local _meta = getmetatable(var);
    if(_meta ~= nil and _meta._NAME ~= nil) then
        return _meta._NAME;
    else
        return _type;
    end
end

local housesLoaded = false

Citizen.CreateThread(function()
	while true do
		if not housesLoaded then
			MySQL.Async.fetchAll('SELECT * FROM player_houses', {}, function(houses)
				if houses ~= nil then
					for _,house in pairs(houses) do
						houseowneridentifier[house.house] = house.identifier
						housekeyholders[house.house] = json.decode(house.keyholders)
					end
				end
			end)
			housesLoaded = true
		end
		Citizen.Wait(7)
	end
end)

RegisterServerEvent('krp-housing:server:OpenDoor')
AddEventHandler('krp-housing:server:OpenDoor', function(target, house)
    local src = source
    local OtherPlayer = KRPCore.GetPlayerFromId(target)
    if OtherPlayer ~= nil then
        TriggerClientEvent('krp-housing:client:SpawnInApartment', OtherPlayer.source, house)
    end
end)

RegisterServerEvent('krp-housing:server:RingDoor')
AddEventHandler('krp-housing:server:RingDoor', function(house)
    local src = source
    TriggerClientEvent('krp-housing:client:RingDoor', -1, src, house)
end)

RegisterServerEvent('krp-housing:server:savedecorations')
AddEventHandler('krp-housing:server:savedecorations', function(house, decorations)
	local src = source
	MySQL.Async.execute("UPDATE `player_houses` SET `decorations` = '"..json.encode(decorations).."' WHERE `house` = '"..house.."'")
	TriggerClientEvent("krp-housing:server:sethousedecorations", -1, house, decorations)
end)

KRPCore.RegisterServerCallback('krp-housing:server:getHouseDecorations', function(source, cb, house)
	local retval = nil
	MySQL.Async.fetchAll("SELECT * FROM `player_houses` WHERE `house` = '"..house.."'", {}, function(result)
		if result[1] ~= nil then
			retval = json.decode(result[1].decorations)
		else
			retval = nil
		end
		cb(retval)
	end)
end)

KRPCore.RegisterServerCallback('krp-housing:server:getHouseLocations', function(source, cb, house)
	local retval = nil
	MySQL.Async.fetchAll("SELECT * FROM `player_houses` WHERE `house` = '"..house.."'", {}, function(result)
		if result[1] ~= nil then
			retval = result[1]
		end
		cb(retval)
	end)
end)

function mysplit (inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end

	return t
end

KRPCore.RegisterServerCallback('krp-phone:server:GetHouseKeys', function(source, cb)
	local src = source
	local pData = KRPCore.GetPlayerFromId(src)
end)

KRPCore.RegisterServerCallback('krp-housing:server:getOwnedHouses', function(source, cb)
	local src = source
	local pData = KRPCore.GetPlayerFromId(src)

	if pData then
		MySQL.Async.fetchAll('SELECT * FROM player_houses WHERE identifier = @identifier', {
			['@identifier'] = GetPlayerIdentifier(src, 0)
		}, function(houses)
			local ownedHouses = {}

			for i=1, #houses, 1 do
				table.insert(ownedHouses, houses[i].house)
			end

			if houses ~= nil then
				cb(ownedHouses)
			else
				cb(nil)
			end
		end)
	end
end)

KRPCore.RegisterServerCallback('krp-housing:server:getSavedOutfits', function(source, cb)
	local src = source
	local pData = KRPCore.GetPlayerFromId(src)

	if pData then
		MySQL.Async.fetchAll('SELECT * FROM player_outfits WHERE identifier = @identifier', {
			['@identifier'] = GetPlayerIdentifier(source, 0)
		}, function(result)
			if result[1] ~= nil then
				cb(result)
			else
				cb(nil)
			end
		end)
	end
end)

RegisterCommand('decorate', function(source, args, rawCommand)
	TriggerClientEvent("krp-housing:client:decorate", source)
end)

function GetHouseStreetCount(street)
	local count = 1
	MySQL.Async.fetchAll("SELECT * FROM `houselocations` WHERE `name` LIKE '%"..street.."%'", {}, function(result)
		if result[1] ~= nil then 
			for i = 1, #result, 1 do
				count = count + 1
			end
		end
		return count
	end)
	return count
end

RegisterServerEvent('krp-housing:server:LogoutLocation')
AddEventHandler('krp-housing:server:LogoutLocation', function()
	local src = source
	-- QBCore.Player.Logout(src)
	-- Citizen.Wait(100)
    TriggerClientEvent('qb-multicharacter:client:chooseChar', src) -- Here you put the multicharacter trigger of your server
end)

RegisterServerEvent('krp-housing:server:giveHouseKey')
AddEventHandler('krp-housing:server:giveHouseKey', function(target, house)
	local src = source
	local tPlayer = KRPCore.GetPlayerFromId(target)
	local tSteam = GetPlayerIdentifier(target, 0)
	
	if tPlayer ~= nil then
		if housekeyholders[house] ~= nil then
			for _, tSteam2 in pairs(housekeyholders[house]) do
				if tSteam2 == tSteam then
					TriggerClientEvent('DoLongHudText', src, "This person already has the keys to your house.", 2)
					return
				end
			end		
			table.insert(housekeyholders[house], tSteam)
			MySQL.Async.execute("UPDATE `player_houses` SET `keyholders` = '"..json.encode(housekeyholders[house]).."' WHERE `house` = '"..house.."'")
			TriggerClientEvent('krp-housing:client:refreshHouse', tPlayer.source)
			TriggerClientEvent('DoLongHudText', tPlayer.source, "You have received the keys to the house: ".. Config.Houses[house].adress, 1)
		else
			local sourceTarget = KRPCore.GetPlayerFromId(src)
			housekeyholders[house] = {
				[1] = GetPlayerIdentifier(sourceTarget, 0)
			}
			table.insert(housekeyholders[house], tSteam)
			MySQL.Async.execute("UPDATE `player_houses` SET `keyholders` = '"..json.encode(housekeyholders[house]).."' WHERE `house` = '"..house.."'")
			TriggerClientEvent('krp-housing:client:refreshHouse', tPlayer.source)
			TriggerClientEvent('DoLongHudText', tPlayer.source, "You have received the keys to the house: ".. Config.Houses[house].adress, 1)
		end
	else
		TriggerClientEvent('DoLongHudText', src, "This player is offline!", 2)
	end
end)

RegisterServerEvent('test:test')
AddEventHandler('test:test', function(msg)

end)

RegisterServerEvent('krp-housing:server:logoutServer')
AddEventHandler('krp-housing:server:logoutServer', function(message)
	DropPlayer(source, message)
end)

RegisterServerEvent('krp-housing:server:setLocation')
AddEventHandler('krp-housing:server:setLocation', function(coords, house, type)
	local src = source
	local Player = KRPCore.GetPlayerFromId(src)

	if type == 1 then
		MySQL.Async.execute("UPDATE `player_houses` SET `stash` = '"..json.encode(coords).."' WHERE `house` = '"..house.."'")
	elseif type == 2 then
		MySQL.Async.execute("UPDATE `player_houses` SET `outfit` = '"..json.encode(coords).."' WHERE `house` = '"..house.."'")
	elseif type == 3 then
		MySQL.Async.execute("UPDATE `player_houses` SET `logout` = '"..json.encode(coords).."' WHERE `house` = '"..house.."'")
	elseif type == 4 then
		MySQL.Async.execute("UPDATE `player_houses` SET `stash2` = '"..json.encode(coords).."' WHERE `house` = '"..house.."'")
	end

	TriggerClientEvent('krp-housing:client:refreshLocations', -1, house, json.encode(coords), type)
end)

RegisterCommand('createhouse', function(source, args, rawCommand)
	TriggerClientEvent("krp-housing:client:createHouses", source, tonumber(args[1]), tonumber(args[2]))
end)

RegisterCommand('setlocation', function(source, args, rawCommand)
	if args[1] ~= nil then 

		if args[1] == 'stash' then 
			TriggerClientEvent('krp-housing:client:setLocation', source, 'stash')
		end

		if args[1] == 'outfit' then 
			TriggerClientEvent('krp-housing:client:setLocation', source, 'outift')
		end

		if args[1] == 'logout' then 
			TriggerClientEvent('krp-housing:client:setLocation', source, 'logout')
		end
		
		if args[1] == 'stash2' then 
			TriggerClientEvent('krp-housing:client:setLocation', source, 'stash2')
		end
	else
		--
	end
end)