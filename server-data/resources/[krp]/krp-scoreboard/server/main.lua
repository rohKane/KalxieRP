KRPCore = nil
local connectedPlayers = {}
local playerJobs = {}

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj end)

KRPCore.RegisterServerCallback('krp-scoreboard:getConnectedPlayers', function(source, cb)
	cb(connectedPlayers)
end)

AddEventHandler('krp:setJob', function(playerId, job, lastJob)
	connectedPlayers[playerId].job = job.name

	TriggerClientEvent('krp-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
end)

AddEventHandler('krp:playerLoaded', function(playerId, xPlayer)
	AddPlayerToScoreboard(xPlayer, true)
end)

AddEventHandler('krp:playerDropped', function(playerId)
	connectedPlayers[playerId] = nil

	TriggerClientEvent('krp-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		UpdatePing()
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.CreateThread(function()
			Citizen.Wait(1000)
			AddPlayersToScoreboard()
		end)
	end
end)

function AddPlayerToScoreboard(xPlayer, update)
	local playerId = xPlayer.source

	connectedPlayers[playerId] = {}
	connectedPlayers[playerId].ping = GetPlayerPing(playerId)
	connectedPlayers[playerId].id = playerId
	connectedPlayers[playerId].name = xPlayer.getName()
	connectedPlayers[playerId].job = xPlayer.job.name

	if update then
		TriggerClientEvent('krp-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
	end

	if xPlayer.player.getGroup() == 'user' then
		Citizen.CreateThread(function()
			Citizen.Wait(3000)
			TriggerClientEvent('krp-scoreboard:toggleID', playerId, false)
		end)
	end
end

function AddPlayersToScoreboard()
	local players = KRPCore.GetPlayers()

	for i=1, #players, 1 do
		local xPlayer = KRPCore.GetPlayerFromId(players[i])
		AddPlayerToScoreboard(xPlayer, false)
	end

	TriggerClientEvent('krp-scoreboard:updateConnectedPlayers', -1, connectedPlayers)
end

function UpdatePing()
	for k,v in pairs(connectedPlayers) do
		v.ping = GetPlayerPing(k)
	end

	TriggerClientEvent('krp-scoreboard:updatePing', -1, connectedPlayers)
end

TriggerEvent('es:addGroupCommand', 'screfresh', 'admin', function(source, args, user)
	AddPlayersToScoreboard()
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Refresh krp-scoreboard names!"})

TriggerEvent('es:addGroupCommand', 'sctoggle', 'admin', function(source, args, user)
	TriggerClientEvent('krp-scoreboard:toggleID', source)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Toggle ID column on the scoreboard!"})