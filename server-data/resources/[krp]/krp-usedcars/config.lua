vehsales = {}

vehsales.Version = '1.0.10'

TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj; end)
Citizen.CreateThread(function(...)
  while not KRPCore do
    TriggerEvent('krp:getSharedObject', function(obj) KRPCore = obj; end)
    Citizen.Wait(0)
  end
end)