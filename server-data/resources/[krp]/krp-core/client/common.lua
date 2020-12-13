AddEventHandler('krp:getSharedObject', function(cb)
	cb(KRPCore)
end)

function getSharedObject()
	return KRPCore
end
