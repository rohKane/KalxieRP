local CurrentAction, CurrentActionMsg, CurrentActionData = nil, '', {}
local HasAlreadyEnteredMarker, LastHospital, LastPart, LastPartNum
local IsBusy = false
local spawnedVehicles, isInShopMenu = {}, false
local IsDragged                 = false
local CopPed                    = 0
local DragStatus = {}
DragStatus.IsDragged = false

RegisterNetEvent('krp-ambulancejob:drag')
AddEventHandler('krp-ambulancejob:drag', function(copID)

	DragStatus.IsDragged = not DragStatus.IsDragged
	DragStatus.CopId     = tonumber(copID)
	local playerPed
	local targetPed
	playerPed = PlayerPedId()

		if DragStatus.IsDragged then
			targetPed = GetPlayerPed(GetPlayerFromServerId(DragStatus.CopId))

			-- undrag if target is in an vehicle
			if not IsPedSittingInAnyVehicle(targetPed) then
				AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			else
			end
				

		else
			DetachEntity(playerPed, true, false)
		end
end)

RegisterCommand('escort', function()
	local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 3.0 then
		TriggerServerEvent('krp-ambulancejob:drag', GetPlayerServerId(closestPlayer))
	else
		TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
	end
end)

function OpenAmbulanceActionsMenu()
	local elements = {
		--{label = _U('cloakroom'), value = 'cloakroom'}
	}

	if Config.EnablePlayerManagement and KRPCore.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	KRPCore.UI.Menu.CloseAll()

	KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'ambulance_actions', {
		title    = _U('ambulance'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'cloakroom' then
			OpenCloakroomMenu()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('krp-society:openBossMenu', 'ambulance', function(data, menu)
				menu.close()
			end, {wash = false})
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenMobileAmbulanceActionsMenu()

	KRPCore.UI.Menu.CloseAll()

	KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_ambulance_actions', {
		title    = _U('ambulance'),
		align    = 'bottom-right',
		elements = {
			{label = _U('ems_menu'), value = 'citizen_interaction'}
		}
	}, function(data, menu)
		if data.current.value == 'citizen_interaction' then
			KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title    = _U('ems_menu_title'),
				align    = 'bottom-right',
				elements = {
					{label = _U('ems_menu_revive'), value = 'revive'},
					{label = _U('ems_menu_small'), value = 'small'},
					{label = _U('ems_menu_big'), value = 'big'},
					{label = _U('ems_menu_putincar'), value = 'put_in_vehicle'},
					{label = _U('ems_menu_pulloutcar'), value = 'pull_out_vehicle'},
					{label = _U('ems_menu_drag'), value = 'drag_player'},
					{label = "Un-drag player", value = 'un_drag'},

				}
			}, function(data, menu)
				if IsBusy then return end

				local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()

				if closestPlayer == -1 or closestDistance > 2.0 then
					TriggerEvent('DoLongHudText', 'No players nearby', 2)
				else

					if data.current.value == 'revive' then

						IsBusy = true

						KRPCore.TriggerServerCallback('krp-ambulancejob:getItemAmount', function(quantity)
							if quantity > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)

								if IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_a", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_b", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_c", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_d", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_e", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_f", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_g", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_h", 3)then
									local playerPed = PlayerPedId()
									
									TriggerEvent('DoLongHudText', 'Revive is in progress!', 2)

									--[[ local lib, anim = 'amb@medic@standing@tendtodead@base', 'base'

									for i=1, 15, 1 do
										Citizen.Wait(900)
								
										KRPCore.Streaming.RequestAnimDict(lib, function()
											TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
										end)
									end ]]
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('krp-ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('krp-ambulancejob:revive', GetPlayerServerId(closestPlayer))

									-- Show revive award?
									if Config.ReviveReward > 0 then
										
                                        local reward = Config.ReviveReward
                                        local reviveString = "you have revived someone and earned $"..reward.."!"
										TriggerEvent('DoLongHudText', reviveString, 1)
                                    else
                                        local reviveString = "you have revived someone!"
										TriggerEvent('DoLongHudText', reviveString, 1)
                                    end
                                else
									TriggerEvent('DoLongHudText', 'Player not unconscious', 2)
                                end
                            else
								TriggerEvent('DoLongHudText', 'Not enough medikits', 2)
                            end

							IsBusy = false

						end, 'medikit')

					elseif data.current.value == 'small' then

						KRPCore.TriggerServerCallback('krp-ambulancejob:getItemAmount', function(quantity)
							if quantity > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = PlayerPedId()

									IsBusy = true
									TriggerEvent('DoLongHudText', 'You are healing', 1)
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('krp-ambulancejob:removeItem', 'bandage')
									TriggerServerEvent('krp-ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')

									local reviveString = "you have healed someone"
									TriggerEvent('DoLongHudText', reviveString, 1)
									IsBusy = false
								else
									TriggerEvent('DoLongHudText', 'Player not conscious', 2)
								end
							else
								TriggerEvent('DoLongHudText', 'Not enough bandages', 2)
							end
						end, 'bandage')

					elseif data.current.value == 'big' then

						KRPCore.TriggerServerCallback('krp-ambulancejob:getItemAmount', function(quantity)
							if quantity > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = PlayerPedId()

									IsBusy = true
									TriggerEvent('DoLongHudText', 'you are healing!', 1)
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('krp-ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('krp-ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
									local revivePlayer = GetPlayerName(closestPlayer)
									local reviveString = "you have healed "..revivePlayer
									TriggerEvent('DoLongHudText', reviveString, 1)
									IsBusy = false
								else
									TriggerEvent('DoLongHudText', 'That player is not conscious!', 2)
								end
							else
								TriggerEvent('DoLongHudText', 'You dont have a medikit', 2)
							end
						end, 'medikit')

					elseif data.current.value == 'put_in_vehicle' then
						TriggerServerEvent('krp-ambulancejob:putInVehicle', GetPlayerServerId(closestPlayer))
					elseif data.current.value == 'pull_out_vehicle' then
						TriggerServerEvent('krp-ambulancejob:pullOutVehicle', GetPlayerServerId(closestPlayer))
					elseif data.current.value == 'drag_player' then
						TriggerServerEvent('krp-ambulancejob:drag', GetPlayerServerId(closestPlayer))
					elseif data.current.value == 'un_drag' then
						TriggerServerEvent('krp-ambulancejob:undrag', GetPlayerServerId(closestPlayer))
					end
				end
			end, function(data, menu)
				menu.close()
			end)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function FastTravel(coords, heading)
	local playerPed = PlayerPedId()

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Citizen.Wait(500)
	end

	KRPCore.Game.Teleport(playerPed, coords, function()
		DoScreenFadeIn(800)

		if heading then
			SetEntityHeading(playerPed, heading)
		end
	end)
end

-- Draw markers & Marker logic
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep, isInMarker, hasExited = true, false, false
		local currentHospital, currentPart, currentPartNum
		
		if KRPCore.PlayerData.job and KRPCore.PlayerData.job.name == 'ambulance' then
			
			for hospitalNum,hospital in pairs(Config.Hospitals) do

				-- Ambulance Actions
				for k,v in ipairs(hospital.AmbulanceActions) do
					local distance = GetDistanceBetweenCoords(playerCoords, v, true)

					if distance < Config.DrawDistance then
						DrawMarker(27, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, false, nil, nil, false)
						letSleep = false
					end

					if distance < Config.Marker.x then
						isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'AmbulanceActions', k
					end
				end

				-- Fast Travels
				for k,v in ipairs(hospital.FastTravels) do
					local distance = GetDistanceBetweenCoords(playerCoords, v.From, true)

					if distance < Config.DrawDistance then
						DrawMarker(27, v.From, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, false, nil, nil, false)
						letSleep = false
					end


					if distance < v.Marker.x then
						FastTravel(v.To.coords, v.To.heading)
					end
				end

				-- Fast Travels (Prompt)
				for k,v in ipairs(hospital.FastTravelsPrompt) do
					local distance = GetDistanceBetweenCoords(playerCoords, v.From, true)

					if distance < Config.DrawDistance then
						DrawMarker(27, v.From, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, false, nil, nil, false)
						letSleep = false
					end

					if distance < v.Marker.x then
						isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'FastTravelsPrompt', k
					end
				end

			end

			-- Logic for exiting & entering markers
			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastHospital ~= currentHospital or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then

				if
					(LastHospital ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
					(LastHospital ~= currentHospital or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('krp-ambulancejob:hasExitedMarker', LastHospital, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker, LastHospital, LastPart, LastPartNum = true, currentHospital, currentPart, currentPartNum

				TriggerEvent('krp-ambulancejob:hasEnteredMarker', currentHospital, currentPart, currentPartNum)

			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('krp-ambulancejob:hasExitedMarker', LastHospital, LastPart, LastPartNum)
			end

			if letSleep then
				Citizen.Wait(500)
			end
		end
	end
end)

AddEventHandler('krp-ambulancejob:hasEnteredMarker', function(hospital, part, partNum)
	if KRPCore.PlayerData.job and KRPCore.PlayerData.job.name == 'ambulance' then
		if part == 'AmbulanceActions' then
			CurrentAction = part
			CurrentActionMsg = _U('actions_prompt')
			CurrentActionData = {}
		elseif part == 'FastTravelsPrompt' then
			local travelItem = Config.Hospitals[hospital][part][partNum]

			CurrentAction = part
			CurrentActionMsg = travelItem.Prompt
			CurrentActionData = {to = travelItem.To.coords, heading = travelItem.To.heading}
		end
	end
end)

AddEventHandler('krp-ambulancejob:hasExitedMarker', function(hospital, part, partNum)
	if not isInShopMenu then
		KRPCore.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			KRPCore.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) then

				if CurrentAction == 'AmbulanceActions' then
					OpenAmbulanceActionsMenu()
				elseif CurrentAction == 'FastTravelsPrompt' then
					FastTravel(CurrentActionData.to, CurrentActionData.heading)
				end

				CurrentAction = nil

			end

		elseif KRPCore.PlayerData.job ~= nil and KRPCore.PlayerData.job.name == 'ambulance' and not IsDead then
			--[[ if IsControlJustReleased(0, Keys['F6']) then
				OpenMobileAmbulanceActionsMenu()
			end ]]
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('krp-ambulancejob:putInVehicle')
AddEventHandler('krp-ambulancejob:putInVehicle', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				if IsDragged then
					IsDragged = not IsDragged
				end
			end
		end
	end
end)

RegisterNetEvent('krp-ambulancejob:pullOutVehicle')
AddEventHandler('krp-ambulancejob:pullOutVehicle', function()
	local playerPed = PlayerPedId()

	if not IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	local vehicle = GetVehiclePedIsIn(playerPed, false)
	TaskLeaveVehicle(playerPed, vehicle, 16)
end)

RegisterNetEvent('krp-ambulancejob:drag')
AddEventHandler('krp-ambulancejob:drag', function(cop)
	IsDragged = not IsDragged
	CopPed = tonumber(cop)
end)

RegisterNetEvent('krp-ambulancejob:un_drag')
AddEventHandler('krp-ambulancejob:un_drag', function(cop)
	IsDragged = not IsDragged
	DetachEntity(GetPlayerPed(-1), true, false)
end)




Citizen.CreateThread(function()
	while true do
	  Wait(0)
		if IsDragged then
		  local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
		  local myped = GetPlayerPed(-1)
		  AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
		else
		  --DetachEntity(GetPlayerPed(-1), true, false) --Disabled to fix attatching...
		end
	end
  end)

function OpenCloakroomMenu()
	KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = _U('cloakroom'),
		align    = 'bottom-right',
		elements = {
			{label = _U('ems_clothes_civil'), value = 'citizen_wear'},
			{label = _U('ems_clothes_ems'), value = 'ambulance_wear'},
		}
	}, function(data, menu)
		if data.current.value == 'citizen_wear' then
			KRPCore.TriggerServerCallback('krp-skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'ambulance_wear' then
			KRPCore.TriggerServerCallback('krp-skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
				end
			end)
		end

		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function OpenVehicleSpawnerMenu(hospital, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local elements = {
		{label = _U('garage_storeditem'), action = 'garage'},
		{label = _U('garage_storeitem'), action = 'store_garage'},
		{label = _U('garage_buyitem'), action = 'buy_vehicle'}
	}

	KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
		title    = _U('garage_title'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)

		if data.current.action == 'buy_vehicle' then
			local shopCoords = Config.Hospitals[hospital].Vehicles[partNum].InsideShop
			local shopElements = {}

			local authorizedVehicles = Config.AuthorizedVehicles[KRPCore.PlayerData.job.grade_name]

			if #authorizedVehicles > 0 then
				for k,vehicle in ipairs(authorizedVehicles) do
					table.insert(shopElements, {
						label = ('%s - <span style="color:green;">%s</span>'):format(vehicle.label, _U('shop_item', KRPCore.Math.GroupDigits(vehicle.price))),
						name  = vehicle.label,
						model = vehicle.model,
						price = vehicle.price,
						type  = 'car'
					})
				end
			else
				return
			end

			OpenShopMenu(shopElements, playerCoords, shopCoords)
		elseif data.current.action == 'garage' then
			local garage = {}

			KRPCore.TriggerServerCallback('krp-vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName, props.plate)

						if v.stored then
							label = label .. ('<span style="color:green;">%s</span>'):format(_U('garage_stored'))
						else
							label = label .. ('<span style="color:darkred;">%s</span>'):format(_U('garage_notstored'))
						end

						table.insert(garage, {
							label = label,
							stored = v.stored,
							model = props.model,
							vehicleProps = props
						})
					end

					KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage', {
						title    = _U('garage_title'),
						align    = 'bottom-right',
						elements = garage
					}, function(data2, menu2)
						if data2.current.stored then
							local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(hospital, 'Vehicles', partNum)

							if foundSpawn then
								menu2.close()

								KRPCore.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
									KRPCore.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)

									TriggerServerEvent('krp-vehicleshop:setJobVehicleState', data2.current.vehicleProps.plate, false)

									TriggerEvent('DoLongHudText', 'your vehicle has been released from the garage..', 2)
									SetVehicleMod(vehicle, 12, 2)
	                                SetVehicleMod(vehicle, 13, 3)
	                                SetVehicleMod(vehicle, 16, 2)
	                                SetVehicleMod(vehicle, 17, 4)
	                                SetVehicleExtra(vehicle, 4, 0)
	                                SetVehicleExtra(vehicle, 5, 0)
	                                SetVehicleExtra(vehicle, 9, 0)
	                                SetVehicleExtra(vehicle, 1, 0)
	                                SetVehicleExtra(vehicle, 2, 0)
	                                SetVehicleExtra(vehicle, 11, 0)
									SetVehicleExtra(vehicle, 12, 0)
									SetVehicleDirtLevel(vehicle, 0.1)
								

	                                local plate = GetVehicleNumberPlateText(vehicle)
									TriggerServerEvent('garage:addKeys', plate)
								end)
							end
						else
							TriggerEvent('DoLongHudText', 'your vehicle is not stored in the garage', 2)
						end
					end, function(data2, menu2)
						menu2.close()
					end)

				else
					TriggerEvent('DoLongHudText', 'You dont have any vehicles in your garage', 2)
				end
			end, 'car')

		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		end

	end, function(data, menu)
		menu.close()
	end)

end

function StoreNearbyVehicle(playerCoords)
	local vehicles, vehiclePlates = KRPCore.Game.GetVehiclesInArea(playerCoords, 30.0), {}

	if #vehicles > 0 then
		for k,v in ipairs(vehicles) do

			-- Make sure the vehicle we're saving is empty, or else it wont be deleted
			if GetVehicleNumberOfPassengers(v) == 0 and IsVehicleSeatFree(v, -1) then
				table.insert(vehiclePlates, {
					vehicle = v,
					plate = KRPCore.Math.Trim(GetVehicleNumberPlateText(v))
				})
			end
		end
	else
		TriggerEvent('DoLongHudText', 'There is no nearby vehicles', 2)
		return
	end

	KRPCore.TriggerServerCallback('krp-ambulancejob:storeNearbyVehicle', function(storeSuccess, foundNum)
		if storeSuccess then
			local vehicleId = vehiclePlates[foundNum]
			local attempts = 0
			KRPCore.Game.DeleteVehicle(vehicleId.vehicle)
			IsBusy = true

			Citizen.CreateThread(function()
				while IsBusy do
					Citizen.Wait(0)
					drawLoadingText(_U('garage_storing'), 255, 255, 255, 255)
				end
			end)

			-- Workaround for vehicle not deleting when other players are near it.
			while DoesEntityExist(vehicleId.vehicle) do
				Citizen.Wait(500)
				attempts = attempts + 1

				-- Give up
				if attempts > 30 then
					break
				end

				vehicles = KRPCore.Game.GetVehiclesInArea(playerCoords, 30.0)
				if #vehicles > 0 then
					for k,v in ipairs(vehicles) do
						if KRPCore.Math.Trim(GetVehicleNumberPlateText(v)) == vehicleId.plate then
							KRPCore.Game.DeleteVehicle(v)
							break
						end
					end
				end
			end

			IsBusy = false
			TriggerEvent('DoLongHudText', 'The vehicle has been stored in your garage', 1)
		else
			TriggerEvent('DoLongHudText', 'No nearby owned vehicles were found', 1)
		end
	end, vehiclePlates)
end

function GetAvailableVehicleSpawnPoint(hospital, part, partNum)
	local spawnPoints = Config.Hospitals[hospital][part][partNum].SpawnPoints
	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if KRPCore.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		TriggerEvent('DoLongHudText', 'Please wait until the area is clear', 1)
		return false
	end
end

function OpenHelicopterSpawnerMenu(hospital, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	KRPCore.PlayerData = KRPCore.GetPlayerData()
	local elements = {
		{label = _U('helicopter_garage'), action = 'garage'},
		{label = _U('helicopter_store'), action = 'store_garage'},
		{label = _U('helicopter_buy'), action = 'buy_helicopter'}
	}

	KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'helicopter_spawner', {
		title    = _U('helicopter_title'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)

		if data.current.action == 'buy_helicopter' then
			local shopCoords = Config.Hospitals[hospital].Helicopters[partNum].InsideShop
			local shopElements = {}

			local authorizedHelicopters = Config.AuthorizedHelicopters[KRPCore.PlayerData.job.grade_name]

			if #authorizedHelicopters > 0 then
				for k,helicopter in ipairs(authorizedHelicopters) do
					table.insert(shopElements, {
						label = ('%s - <span style="color:green;">%s</span>'):format(helicopter.label, _U('shop_item', KRPCore.Math.GroupDigits(helicopter.price))),
						name  = helicopter.label,
						model = helicopter.model,
						price = helicopter.price,
						type  = 'helicopter'
					})
				end
			else
				TriggerEvent('DoLongHudText', 'you\'re not authorized to buy helicopters', 2)
				TriggerEvent('DoLongHudText', 'Please wait until the area is clear', 1)
				return
			end

			OpenShopMenu(shopElements, playerCoords, shopCoords)
		elseif data.current.action == 'garage' then
			local garage = {}

			KRPCore.TriggerServerCallback('krp-vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName, props.plate)

						if v.stored then
							label = label .. ('<span style="color:green;">%s</span>'):format(_U('garage_stored'))
						else
							label = label .. ('<span style="color:darkred;">%s</span>'):format(_U('garage_notstored'))
						end

						table.insert(garage, {
							label = label,
							stored = v.stored,
							model = props.model,
							vehicleProps = props
						})
					end

					KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'helicopter_garage', {
						title    = _U('helicopter_garage_title'),
						align    = 'bottom-right',
						elements = garage
					}, function(data2, menu2)
						if data2.current.stored then
							local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(hospital, 'Helicopters', partNum)

							if foundSpawn then
								menu2.close()

								KRPCore.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
									KRPCore.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)

									local plate = GetVehicleNumberPlateText(vehicle)
	                                TriggerServerEvent('garage:addKeys', plate)

									TriggerServerEvent('krp-vehicleshop:setJobVehicleState', data2.current.vehicleProps.plate, false)
                                    TriggerEvent('DoLongHudText', 'Your vehicle has been released from the garage', 1)


								end)
							end
						else
							TriggerEvent('DoLongHudText', 'Your vehicle is not stored in the garage', 1)
						end
					end, function(data2, menu2)
						menu2.close()
					end)

				else
					TriggerEvent('DoLongHudText', 'You dont have any vehicles in your garage', 1)
				end
			end, 'helicopter')

		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		end

	end, function(data, menu)
		menu.close()
	end)

end

function OpenShopMenu(elements, restoreCoords, shopCoords)
	local playerPed = PlayerPedId()
	isInShopMenu = true

	KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = _U('vehicleshop_title'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)

		KRPCore.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop_confirm', {
			title    = _U('vehicleshop_confirm', data.current.name, data.current.price),
			align    = 'bottom-right',
			elements = {
				{ label = _U('confirm_no'), value = 'no' },
				{ label = _U('confirm_yes'), value = 'yes' }
			}
		}, function(data2, menu2)

			if data2.current.value == 'yes' then
				local newPlate = exports['vehicleshop']:GeneratePlate()
				local vehicle  = GetVehiclePedIsIn(playerPed, false)
				local props    = KRPCore.Game.GetVehicleProperties(vehicle)
				props.plate    = newPlate

				KRPCore.TriggerServerCallback('krp-ambulancejob:buyJobVehicle', function (bought)
					if bought then
						KRPCore.ShowNotification(_U('vehicleshop_bought', data.current.name, KRPCore.Math.GroupDigits(data.current.price)))

						isInShopMenu = false
						KRPCore.UI.Menu.CloseAll()
				
						DeleteSpawnedVehicles()
						FreezeEntityPosition(playerPed, false)
						SetEntityVisible(playerPed, true)
				
						KRPCore.Game.Teleport(playerPed, restoreCoords)
					else
						TriggerEvent('DoLongHudText', 'You cannot afford that vehicle', 2)
						menu2.close()
					end
				end, props, data.current.type)
			else
				menu2.close()
			end

		end, function(data2, menu2)
			menu2.close()
		end)

		end, function(data, menu)
		isInShopMenu = false
		KRPCore.UI.Menu.CloseAll()

		DeleteSpawnedVehicles()
		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)

		KRPCore.Game.Teleport(playerPed, restoreCoords)
	end, function(data, menu)
		DeleteSpawnedVehicles()

		WaitForVehicleToLoad(data.current.model)
		KRPCore.Game.SpawnLocalVehicle(data.current.model, shopCoords, 0.0, function(vehicle)
			table.insert(spawnedVehicles, vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
		end)
	end)

	WaitForVehicleToLoad(elements[1].model)
	KRPCore.Game.SpawnLocalVehicle(elements[1].model, shopCoords, 0.0, function(vehicle)
		table.insert(spawnedVehicles, vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isInShopMenu then
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

function DeleteSpawnedVehicles()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		KRPCore.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)

			DisableControlAction(0, Keys['TOP'], true)
			DisableControlAction(0, Keys['DOWN'], true)
			DisableControlAction(0, Keys['LEFT'], true)
			DisableControlAction(0, Keys['RIGHT'], true)
			DisableControlAction(0, 176, true) -- ENTER key
			DisableControlAction(0, Keys['BACKSPACE'], true)

			drawLoadingText(_U('vehicleshop_awaiting_model'), 255, 255, 255, 255)
		end
	end
end

function drawLoadingText(text, red, green, blue, alpha)
	SetTextFont(4)
	SetTextScale(0.0, 0.5)
	SetTextColour(red, green, blue, alpha)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.5, 0.5)
end


function WarpPedInClosestVehicle(ped)
	local coords = GetEntityCoords(ped)

	local vehicle, distance = KRPCore.Game.GetClosestVehicle(coords)

	if distance ~= -1 and distance <= 5.0 then
		local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

		for i=maxSeats - 1, 0, -1 do
			if IsVehicleSeatFree(vehicle, i) then
				freeSeat = i
				break
			end
		end

		if freeSeat then
			TaskWarpPedIntoVehicle(ped, vehicle, freeSeat)
		end
	else
		TriggerEvent('DoLongHudText', 'No vehicles nearby', 2)
		TriggerEvent('DoLongHudText', 'Please wait until the area is clear', 1)
	end
end

RegisterNetEvent('krp-ambulancejob:heal')
AddEventHandler('krp-ambulancejob:heal', function(healType)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)

    if healType == 'small' then
        local health = GetEntityHealth(playerPed)
        local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 10))
        SetEntityHealth(playerPed, newHealth)
        TriggerEvent('krp-hospital:client:RemoveBleed')
	elseif healType == 'big' then
		local health = GetEntityHealth(playerPed)
        local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 10))
        SetEntityHealth(playerPed, newHealth)
        TriggerEvent('krp-hospital:client:RemoveBleed')
        TriggerEvent('krp-hospital:client:ResetLimbs')
    end

	TriggerEvent('DoLongHudText', 'You have been healed!', 1)
end)

RegisterNetEvent("tp:emsRevive")
AddEventHandler("tp:emsRevive", function()

    local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > 2.0 then
		TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
    else
                    
    local closestPlayerPed = GetPlayerPed(closestPlayer)
 
    if IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_a", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_b", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_c", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_d", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_e", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_f", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_g", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_h", 3)then
        local playerPed = PlayerPedId()
               
		TriggerEvent('DoLongHudText', 'Revive In Progress', 1)
 
            TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
            Citizen.Wait(10000)
            ClearPedTasks(playerPed)
 
            TriggerServerEvent('krp-ambulancejob:revive', GetPlayerServerId(closestPlayer))
 
        if Config.ReviveReward > 0 then
			TriggerEvent('DoLongHudText', 'You have revived '.. GetPlayerName(closestPlayer)..' and earned $'..Config.ReviveReward, 1)
        else
			TriggerEvent('DoLongHudText', 'You have successfully revived player', 1)
        end
    else
		TriggerEvent('DoLongHudText', 'Player is conscious please take them to pillbox to get further treatment!', 2)
        end
    end
end)

RegisterCommand('cure', function()
    local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > 2.0 then
		TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
    else
                    
    local closestPlayerPed = GetPlayerPed(closestPlayer)
 
    if IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_a", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_b", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_c", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_d", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_e", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_f", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_g", 3) or IsEntityPlayingAnim(closestPlayerPed, "dead", "dead_h", 3)then
        local playerPed = PlayerPedId()

		TriggerEvent('DoLongHudText', 'Revive In Progress', 1)
 
            TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
            Citizen.Wait(10000)
            ClearPedTasks(playerPed)
 
            TriggerServerEvent('krp-ambulancejob:revive', GetPlayerServerId(closestPlayer))
 
        if Config.ReviveReward > 0 then
			TriggerEvent('DoLongHudText', 'You have revived '.. GetPlayerName(closestPlayer)..' and earned $'..Config.ReviveReward, 1)
        else
            TriggerEvent('DoLongHudText', 'You have successfully revived player', 1)
        end
    else
        TriggerEvent('DoLongHudText', 'Player is conscious please take them to pillbox to get further treatment!', 2)
        end
    end
end)

RegisterNetEvent("tp:emssmallheal")
AddEventHandler("tp:emssmallheal", function()
	if IsBusy then return end

    local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > 2.0 then
        TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
	else
					
    		IsBusy = true
 
			local closestPlayerPed = GetPlayerPed(closestPlayer)
			local health = GetEntityHealth(closestPlayerPed)

			if health > 0 then
				local playerPed = PlayerPedId()
	
				IsBusy = true
				TriggerEvent('DoLongHudText', 'Small Healing In Progress', 1)
				TriggerEvent("animation:PlayAnimation","layspike")
				Citizen.Wait(2000)
				ClearPedTasks(playerPed)
	
				TriggerServerEvent('krp-ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')

				TriggerEvent('DoLongHudText', 'You have successfully healed player', 1)
				IsBusy = false
			else
				TriggerEvent('DoLongHudText', 'Player is conscious please take them to pillbox to get further treatment!', 2)
			end
	end
end)

RegisterCommand('healsmall', function()
	if IsBusy then return end

    local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > 2.0 then
        TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
	else
					
    		IsBusy = true

			local closestPlayerPed = GetPlayerPed(closestPlayer)
			local health = GetEntityHealth(closestPlayerPed)

			if health > 0 then
				local playerPed = PlayerPedId()
	
				IsBusy = true
				TriggerEvent('DoLongHudText', 'Small Healing In Progress', 1)
				TriggerEvent("animation:PlayAnimation","layspike")
				Citizen.Wait(2000)
				ClearPedTasks(playerPed)
	
				TriggerServerEvent('krp-ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
	
				TriggerEvent('DoLongHudText', 'You have successfully healed '..GetPlayerName(closestPlayer), 1)
				IsBusy = false
			else
				TriggerEvent('DoLongHudText', 'Player is unconscious please take them to pillbox to get further treatment!', 2)
			end
	end
end)

RegisterNetEvent("tp:emsbigheal")
AddEventHandler("tp:emsbigheal", function()
	if IsBusy then return end

                local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 2.0 then
                    TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
				else
					
    IsBusy = true
 
			local closestPlayerPed = GetPlayerPed(closestPlayer)
			local health = GetEntityHealth(closestPlayerPed)

			if health > 0 then
				local playerPed = PlayerPedId()
	
				IsBusy = true
				TriggerEvent('DoLongHudtext', 'Big Healing In Progress', 1)
				TriggerEvent("animation:PlayAnimation","layspike")
				Citizen.Wait(2000)
				ClearPedTasks(playerPed)
	
				TriggerServerEvent('krp-ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
	
				TriggerEvent('DoLongHudtext', 'You have successfully healed '..GetPlayerName(closestPlayer), 1)
				IsBusy = false
			else
				TriggerEvent('DoLongHudtext', 'Player is unconscious please take them to pillbox to get further treatment!', 2)
			end
	end
end)

RegisterCommand('healbig', function()
	if IsBusy then return end

                local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 2.0 then
                    TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
				else
					
    IsBusy = true

			local closestPlayerPed = GetPlayerPed(closestPlayer)
			local health = GetEntityHealth(closestPlayerPed)

			if health > 0 then
				local playerPed = PlayerPedId()
	
				IsBusy = true
				TriggerEvent('DoLongHudtext', 'Big Healing In Progress', 1)
				TriggerEvent("animation:PlayAnimation","layspike")
				Citizen.Wait(2000)
				ClearPedTasks(playerPed)
	
				TriggerServerEvent('krp-ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
	
				TriggerEvent('DoLongHudtext', 'You have successfully healed '..GetPlayerName(closestPlayer), 1)
				IsBusy = false
			else
				TriggerEvent('DoLongHudtext', 'Player is unconscious please take them to pillbox to get further treatment!', 2)
			end
	end
end)

RegisterNetEvent("tp:emsputinvehicle")
AddEventHandler("tp:emsputinvehicle", function()
    local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('krp-ambulancejob:putInVehicle', GetPlayerServerId(closestPlayer))
    else
		TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
    end
end)

RegisterNetEvent("tp:emstakeoutvehicle")
AddEventHandler("tp:emstakeoutvehicle", function()
    local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('krp-ambulancejob:pullOutVehicle', GetPlayerServerId(closestPlayer))
    else
		TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
    end
end)

RegisterNetEvent("tp:emsdrag")
AddEventHandler("tp:emsdrag", function()
    local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('krp-ambulancejob:drag', GetPlayerServerId(closestPlayer))
    else
		TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
    end
end)

RegisterNetEvent("tp:emsundrag")
AddEventHandler("tp:emsundrag", function()
    local closestPlayer, closestDistance = KRPCore.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        TriggerServerEvent('krp-ambulancejob:undrag', GetPlayerServerId(closestPlayer))
    else
		TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
    end
end)