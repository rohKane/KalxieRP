local healing = false
local healing2 = false

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

RegisterNetEvent("krp-hospital:items:bandage")
AddEventHandler("krp-hospital:items:bandage", function(item)
    HealSlow2()
end)

RegisterNetEvent("healed:useOxy")
AddEventHandler("healed:useOxy", function()
    ClearPedBloodDamage(PlayerPedId())
    HealSlow()
end)

RegisterNetEvent("healed:useOxy2")
AddEventHandler("healed:useOxy2", function()
    ClearPedBloodDamage(PlayerPedId())
    HealSlow()
end)

RegisterNetEvent("krp-hospital:items:ifak")
AddEventHandler("krp-hospital:items:ifak", function(item)
    loadAnimDict("missheistdockssetup1clipboard@idle_a")
    TaskPlayAnim( PlayerPedId(), "missheistdockssetup1clipboard@idle_a", "idle_a", 3.0, 1.0, -1, 49, 0, 0, 0, 0 ) 
    exports["krp-taskbar"]:taskBar(3500, "Using IFAK")
        local maxHealth = GetEntityMaxHealth(PlayerPedId())
		local health = GetEntityHealth(PlayerPedId())
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 30))
        SetEntityHealth(PlayerPedId(), newHealth)
        TriggerEvent('krp-hospital:client:RemoveBleed')
        ClearPedTasks(PlayerPedId())
end)

function HealSlow()
    if not healing then
        healing = true
    else
        return
    end
    
    local count = 30
    while count > 0 do
        Citizen.Wait(1000)
        count = count - 1
        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 1)
        TriggerEvent('krp-hospital:client:RemoveBleed') 
    end
    healing = false
end

function HealSlow2()
    if not healing2 then
        healing2 = true
    else
        return
    end
    
    local count = 30
    while count > 0 do
        Citizen.Wait(1000)
        count = count - 1
        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 1)
    end
    if math.random(0, 2) then
        TriggerEvent('krp-hospital:client:RemoveBleed')
    end
    healing2 = false
end
