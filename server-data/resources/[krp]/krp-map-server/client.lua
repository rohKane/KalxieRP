Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1)
		if IsPedOnFoot(GetPlayerPed(-1)) then 
			SetRadarZoom(1100)
		elseif IsPedInAnyVehicle(GetPlayerPed(-1), true) then
			SetRadarZoom(1100)
		end
    end
end)

blips = {
    {id = "green", x= -72.41, y = -1567.95, z = 31.1, width = 300.0, height = 100.0, color = 2, rotation = 200.4},
    {id = "ballas", x= 7.95, y = -1860.03, z = 24.84, width = 100.0, height = 345.0, color = 7, rotation = 195.88},
    {id = "vagos", x= 327.0, y = -2033.47, z = 20.94, width = 250.0, height = 250.0, color = 46, rotation = 195.78}
}

Citizen.CreateThread(function()
    for i = 1, #blips, 1 do
        local blip = AddBlipForArea(blips[i].x, blips[i].y, blips[i].z, blips[i].width, blips[i].height)
        SetBlipAlpha(blip, 75)
        SetBlipColour(blip, blips[i].color)
        SetBlipRotation(blip, blips[i].rotation)
        SetBlipDisplay(blip, 3)
        SetBlipAsShortRange(blip, true)
    end
end)

--cloudfivem.com