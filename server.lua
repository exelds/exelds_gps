ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local GPSList = {}

RegisterServerEvent('exelds:addGPSList')
AddEventHandler('exelds:addGPSList', function(rozetNum)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", { ["@identifier"] = xPlayer.identifier }, function(result)
    local name = string.format("%s %s", result[1].firstname, result[1].lastname)	
	table.insert(GPSList, {_source, name, xPlayer.job.name, rozetNum})
	TriggerClientEvent('exelds:refreshGPS', -1)
    end)  
end)

RegisterServerEvent('exelds:addStolenGPS')
AddEventHandler('exelds:addStolenGPS', function()
	local _source = source
	table.insert(GPSList, {_source, 'Yetkisiz Polis Aracı', 'stolen'})
	TriggerClientEvent('exelds:refreshGPS', -1)
end)

RegisterServerEvent('exelds:removeGPSList')
AddEventHandler('exelds:removeGPSList', function()
	local _source = source
	for i = 1, #GPSList do 
		if GPSList[i] and GPSList[i][1] == _source then
			table.remove(GPSList, i)
		end
	end
	TriggerClientEvent('exelds:refreshGPS', -1)
end)

ESX.RegisterServerCallback('exelds:getGPSList', function(source, cb)
	cb(GPSList)
end)

AddEventHandler('playerDropped', function()
    local _source         = source
    local xPlayer         = ESX.GetPlayerFromId(_source)

    if _source ~= nil then      
        if xPlayer ~= nil and xPlayer.job ~= nil and (xPlayer.job.name == 'police' or xPlayer.job.name == 'offpolice' or xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'offambulance') then
			for i = 1, #GPSList do 
				if GPSList[i] and GPSList[i][1] == _source then
					table.remove(GPSList, i)
				end
			end
        end
    end
end)


ESX.RegisterServerCallback('exelds:getItemCount', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count
    cb(quantity)
end)