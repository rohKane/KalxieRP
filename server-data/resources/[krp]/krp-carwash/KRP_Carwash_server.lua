RegisterServerEvent('KRP_Carwash:checkmoney')
AddEventHandler('KRP_Carwash:checkmoney', function ()
		TriggerEvent('es:getPlayerFromId', source, function (user)
			userMoney = user.getMoney()
			if userMoney >= 250 then
				user.removeMoney(250)
				TriggerClientEvent('KRP_Carwash:success', source, 25)
			else
			moneyleft = 250 - userMoney
			TriggerClientEvent('KRP_Carwash:notenoughmoney', source, moneyleft)
		end
	end)
end)