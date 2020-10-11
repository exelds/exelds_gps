ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local gpsInfo = false

RegisterNetEvent('exelds:GPSStart')
AddEventHandler('exelds:GPSStart', function()
	ESX.TriggerServerCallback('exelds:getItemCount', function (count)
if count > 0 then				
	if PlayerData.job.name == 'police' or PlayerData.job.name == 'offpolice' then		
		ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Rozet Numarası', {
			title = "Rozet Numaranızı Girin",
		}, function (data2, menu)
			--[[local amount = tonumber(data2.value)
			
			if amount == nil then
				exports['mythic_notify']:DoHudText('error', 'Buraya bir sayı yazmanız gerekmektedir!')
			else]]		
				getGPSListforPolice()
				TriggerServerEvent('exelds:addGPSList', data2.value)
				TriggerEvent('exelds:gpsInfo', true)
				gpsInfo = true
				exports['mythic_notify']:SendAlert('inform', data2.value..' rozet numarası ile GPS aktif edildi', 7000, { ['background-color'] = '#0E506C', ['color'] = '#FFFFFF' })
				menu.close()
			--end
		end, function (data2, menu)
			exports['mythic_notify']:DoHudText('error', 'GPS aktif edilemedi!')
			menu.close()
		end)
	elseif PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'offambulance' then
		getGPSListforAmbulance()
		TriggerServerEvent('exelds:addGPSList')
		TriggerEvent('exelds:gpsInfo', true)
		gpsInfo = true
		exports['mythic_notify']:SendAlert('inform', 'GPS aktif edildi', 3000, { ['background-color'] = '#0E506C', ['color'] = '#FFFFFF' })
	end		
else
	exports['mythic_notify']:SendAlert('inform', 'Üzerinde GPS bulunmuyor', 3000, { ['background-color'] = '#CC0000', ['color'] = '#FFFFFF' })
end	
	end, 'gps')
end)

RegisterNetEvent('exelds:GPSStop')
AddEventHandler('exelds:GPSStop', function()
	gpsInfo = false
	TriggerServerEvent('exelds:removeGPSList')
	TriggerEvent('exelds:gpsInfo', false)
	for k, existingBlip in pairs(blipsCops) do
        RemoveBlip(existingBlip)
    end
	blipsCops = {}	
	exports['mythic_notify']:SendAlert('inform', 'GPS devre dışı bırakıldı', 3000, { ['background-color'] = '#0E506C', ['color'] = '#FFFFFF' })
end)

function getGPSListforPolice()
	for k, existingBlip in pairs(blipsCops) do
        RemoveBlip(existingBlip)
    end
	blipsCops = {}		
	ESX.TriggerServerCallback('exelds:getGPSList', function(GPSList)
		for i = 1, #GPSList do 
			local id = GetPlayerFromServerId(GPSList[i][1])
			if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
			local name = GPSList[i][2]
			local job = GPSList[i][3]					
			if job == 'police' or job == 'offpolice' then
				local rozetNum = GPSList[i][4]					
				createBlipLastPD(id, name, rozetNum)
			elseif job == 'ambulance' or job == 'offambulance' then
				createBlipLastEMS(id, name)
			elseif job == 'stolen' then	
				createBlipLastStolen(id, name)
				playAlert()
			end
			end
		end
	end)
end

function getGPSListforAmbulance()
	for k, existingBlip in pairs(blipsCops) do
        RemoveBlip(existingBlip)
    end
	blipsCops = {}	
	ESX.TriggerServerCallback('exelds:getGPSList', function(GPSList)
		for i = 1, #GPSList do 
			local id = GetPlayerFromServerId(GPSList[i][1])
			if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
			local name = GPSList[i][2]
			local job = GPSList[i][3]			
			if job == 'ambulance' or job == 'offambulance' then
				createBlipLastEMS(id, name)
			end
			end
		end
	end)
end

function createBlipLastPD(id, isim, rozetNum)
    local ped = GetPlayerPed(id)
    local blip = GetBlipFromEntity(ped)

    if not DoesBlipExist(blip) then -- Add blip and create head display on player
        blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 57)
        ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
        SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
        SetBlipScale(blip, 0.85) -- set scale
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('[~b~ '..rozetNum..' ~s~] '..isim)
        EndTextCommandSetBlipName(blip)

        table.insert(blipsCops, blip) -- add blip to array so we can remove it later
    end
end

function createBlipLastEMS(id, isim)
    local ped = GetPlayerPed(id)
    local blip = GetBlipFromEntity(ped)

    if not DoesBlipExist(blip) then
        blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 1)
        ShowHeadingIndicatorOnBlip(blip, true)
        SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
        SetBlipScale(blip, 0.85)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('[~r~LSMS~s~] '..isim)
        EndTextCommandSetBlipName(blip)   

        table.insert(blipsCops, blip)
    end
end

function createBlipLastStolen(id, isim)
    local ped = GetPlayerPed(id)
    local blip = GetBlipFromEntity(ped)

    if not DoesBlipExist(blip) then
        blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 1)
        ShowHeadingIndicatorOnBlip(blip, true)
        SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
        SetBlipScale(blip, 0.85)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('~r~[!] '..isim)
        EndTextCommandSetBlipName(blip)   

        table.insert(blipsCops, blip)
    end
end

function playAlert()
	exports['mythic_notify']:SendAlert('inform', 'Sistemde yetkisiz polis aracı algılandı!', 6000, { ['background-color'] = '#CC0000', ['color'] = '#FFFFFF' })
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    Wait(900)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    Wait(900)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
	Wait(900)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
end

RegisterNetEvent('exelds:refreshGPS')
AddEventHandler('exelds:refreshGPS', function()
	if gpsInfo == true then
        if PlayerData.job.name == 'police' or PlayerData.job.name == 'offpolice' then
            getGPSListforPolice()
        elseif PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'offambulance' then
            getGPSListforAmbulance()
		end
	end
end)

local aktif = 0

Citizen.CreateThread(function()
while true do
	Citizen.Wait(5000)
	local playerPed = GetPlayerPed(-1)
	local PlayerData = ESX.GetPlayerData()
	if IsPedInAnyPoliceVehicle(playerPed) and GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed, true), -1) == playerPed and aktif == 0 and PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'offpolice' then
	TriggerServerEvent('exelds:addStolenGPS')
	aktif = 1
	elseif not IsPedInAnyPoliceVehicle(playerPed) and aktif == 1 then
	TriggerServerEvent('exelds:removeGPSList')
	aktif = 0
	end
end
end)