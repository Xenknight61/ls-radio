
--===============================================================================
--=== Stworzone przez Alcapone aka suprisex. Zakaz rozpowszechniania skryptu! ===
--===================== na potrzeby LS-Story.pl =================================
--===============================================================================


-- ESX

ESX = nil
local PlayerData                = {}
local radioProp, tab = nil, nil

Citizen.CreateThread(function()
  	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  	PlayerData.job = job
end)

local radioMenu = false
local taksitelsiz = false
local aktifrekans = nil

function enableRadio(enable)
	local ped = GetPlayerPed( -1 )
	if enable then
		RequestAnimDict("cellphone@")
		while not HasAnimDictLoaded("cellphone@") do
			Citizen.Wait(0)
		end
		TaskPlayAnim(ped, "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
		
		radioProp = CreateObject(GetHashKey("prop_cs_hand_radio"), 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	else
		ClearPedTasks(ped)
		if DoesEntityExist(radioProp) then
			DeleteObject(radioProp)
		end
	end

	SetNuiFocus(true, true)
	radioMenu = enable

	SendNUIMessage({
		type = "enableui",
		enable = enable
	})
end

function tAnim()
	local ped = GetPlayerPed( -1 )
	RequestAnimDict("cellphone@")
	while not HasAnimDictLoaded("cellphone@") do
		Citizen.Wait(0)
	end
	TaskPlayAnim(ped, "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
		
	tab = CreateObject(GetHashKey("prop_cs_hand_radio"), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(tab, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	Citizen.Wait(3000)
	ClearPedTasks(ped)
	if DoesEntityExist(tab) then
		DeleteObject(tab)
	end
end

function loadPropDict(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(500)
	end
end

RegisterCommand("rconnect", function(source, args)
	local frekans = ESX.Math.Round(args[1])
	if frekans == nil then
		exports['mythic_notify']:DoHudText('error', "Please Enter Frequency You Will Enter")
	elseif tonumber(frekans) < 1 then
		exports['mythic_notify']:DoHudText('error', "You Cannot Connect to Frequency No Zero!")
	else
		ESX.TriggerServerCallback('gksradio:getItemAmount', function(qtty)
			if qtty > 0 then
				local _source = source
				local PlayerData = ESX.GetPlayerData(_source)
				local playerName = GetPlayerName(PlayerId())
				local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")
				if tonumber(frekans) <= 100 then
					if tonumber(frekans) ~= tonumber(getPlayerRadioChannel) then
						if tonumber(frekans) <= Config.RestrictedChannels then
							if(PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance') then
								tAnim()
								exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
								exports.tokovoip_script:setPlayerData(playerName, "radio:channel", tonumber(frekans), true);
								exports.tokovoip_script:addPlayerToRadio(tonumber(frekans))
								exports['mythic_notify']:DoHudText('inform', frekans .. '.00 MHz '.. Config.messages['joined_to_radio'])
								enableRadio(false)
								SetNuiFocus(false, false)
							elseif not (PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance') then
							--- info że nie możesz dołączyć bo nie jesteś policjantem
								exports['mythic_notify']:DoHudText('error', Config.messages['restricted_channel_error'])
							end
						end
						if tonumber(frekans) > Config.RestrictedChannels then
							tAnim()
							exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
							exports.tokovoip_script:setPlayerData(playerName, "radio:channel", tonumber(frekans), true);
							exports.tokovoip_script:addPlayerToRadio(tonumber(frekans))
							exports['mythic_notify']:DoHudText('inform', Config.messages['joined_to_radio'] .. frekans .. '.00 MHz </b>')
							enableRadio(false)
							SetNuiFocus(false, false)
						end
					else
						exports['mythic_notify']:DoHudText('error', Config.messages['you_on_radio'] .. frekans .. '.00 MHz </b>')
					end
				else
					exports['mythic_notify']:DoHudText('error', "There is No Such Frequency!")
				end
			else
				exports['mythic_notify']:DoHudText('error', "No Radio On It!")
			end
		end, 'radio')
	end
end)

RegisterNUICallback('joinRadio', function(data, cb)
	local _source = source
	local PlayerData = ESX.GetPlayerData(_source)
	local playerName = GetPlayerName(PlayerId())
	local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

	if tonumber(data.channel) ~= tonumber(getPlayerRadioChannel) then
		if tonumber(data.channel) <= Config.RestrictedChannels then
			if(PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance') then
				exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
				exports.tokovoip_script:setPlayerData(playerName, "radio:channel", tonumber(data.channel), true);
				exports.tokovoip_script:addPlayerToRadio(tonumber(data.channel))
				exports['mythic_notify']:DoHudText('inform', data.channel .. '.00 MHz '.. Config.messages['joined_to_radio'])
				enableRadio(false)
				SetNuiFocus(false, false)
			elseif not (PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance') then
				--- info że nie możesz dołączyć bo nie jesteś policjantem
				exports['mythic_notify']:DoHudText('error', Config.messages['restricted_channel_error'])
			end
		end
		if tonumber(data.channel) > Config.RestrictedChannels then
			exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
			exports.tokovoip_script:setPlayerData(playerName, "radio:channel", tonumber(data.channel), true);
			exports.tokovoip_script:addPlayerToRadio(tonumber(data.channel))
			exports['mythic_notify']:DoHudText('inform', Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>')
			enableRadio(false)
			SetNuiFocus(false, false)
		end
	else
		exports['mythic_notify']:DoHudText('error', Config.messages['you_on_radio'] .. data.channel .. '.00 MHz </b>')
	end
	cb('ok')
end)

RegisterNUICallback('leaveRadio', function(data, cb)
	PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	local playerName = GetPlayerName(PlayerId())
	local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

		if getPlayerRadioChannel == "nil" then
			exports['mythic_notify']:DoHudText('inform', Config.messages['not_on_radio'])
		else
			exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
			exports.tokovoip_script:setPlayerData(playerName, "radio:channel", "nil", true)
			exports['mythic_notify']:DoHudText('inform', Config.messages['you_leave'])
		end

	cb('ok')
end)

RegisterCommand("rleave", function()
	ESX.TriggerServerCallback('gksradio:getItemAmount', function(qtty)
		if qtty > 0 then
			local playerName = GetPlayerName(PlayerId())
			local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

			if getPlayerRadioChannel == "nil" then
				exports['mythic_notify']:DoHudText('inform', Config.messages['not_on_radio'])
			else
				exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
				exports.tokovoip_script:setPlayerData(playerName, "radio:channel", "nil", true)
				exports['mythic_notify']:DoHudText('inform', Config.messages['you_leave'])
			end
		end
	end, 'radio')
end)

RegisterNUICallback('escape', function(data, cb)
	enableRadio(false)
	SetNuiFocus(false, false)
	cb('ok')
end)

RegisterNetEvent('ls-radio:use')
AddEventHandler('ls-radio:use', function()
  	enableRadio(true)
end)

RegisterNetEvent('ls-radio:onRadioDrop')
AddEventHandler('ls-radio:onRadioDrop', function(source)
	local playerName = GetPlayerName(PlayerId())
	local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

	if getPlayerRadioChannel ~= "nil" then
		exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
		exports.tokovoip_script:setPlayerData(playerName, "radio:channel", "nil", true)
		exports['mythic_notify']:DoHudText('inform', Config.messages['you_leave'] .. getPlayerRadioChannel .. '.00 MHz </b>')
	end
end)

Citizen.CreateThread(function()
	while true do
		if radioMenu then
			DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
			DisableControlAction(0, 2, guiEnabled) -- LookUpDown
			DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
			DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride

			if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
				SendNUIMessage({type = "click"})
			end
		end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustPressed(0, 56) then 
			ESX.TriggerServerCallback('gksradio:getItemAmount', function(qtty)
				if qtty > 0 then
					enableRadio(true)
				else
					exports['mythic_notify']:DoHudText('error', "No Radio On It!")
				end
			end, 'radio')
		end 
	end
end)  

RegisterNUICallback('sesac', function(data, cb)
	PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	TriggerEvent("TokoVoip:UpVolume")
end)

RegisterNUICallback('seskis', function(data, cb)
	PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	TriggerEvent("TokoVoip:DownVolume")
end)