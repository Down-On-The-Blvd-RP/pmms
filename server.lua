local Phonographs = {}

RegisterNetEvent('phonograph:start')
RegisterNetEvent('phonograph:init')
RegisterNetEvent('phonograph:pause')
RegisterNetEvent('phonograph:stop')
RegisterNetEvent('phonograph:showControls')

function AddPhonograph(handle, url, title, volume, startTime)
	Phonographs[handle] = {url = url, title = title, volume = volume, startTime = startTime, paused = nil}
	TriggerClientEvent('phonograph:play', -1, handle)
end

function RemovePhonograph(handle)
	Phonographs[handle] = nil
	TriggerClientEvent('phonograph:stop', -1, handle)
end

function PausePhonograph(handle, paused)
	if not Phonographs[handle] then
		return
	end

	if Phonographs[handle].paused then
		Phonographs[handle].startTime = Phonographs[handle].startTime + (paused - Phonographs[handle].paused)
		Phonographs[handle].paused = nil
	else
		Phonographs[handle].paused = paused
	end
end

function ErrorMessage(player, message)
	TriggerClientEvent('chat:addMessage', player, {
		color = {255, 0, 0},
		args = {'Error', message}
	})
end

AddEventHandler('phonograph:start', function(handle, url, volume, offset)
	if IsPlayerAceAllowed(source, 'phonograph.interact') then
		url = Config.Presets[url] and Config.Presets[url].url or (IsPlayerAceAllowed(source, 'phonograph.anyUrl') and url)

		if url then
			TriggerClientEvent('phonograph:start', source, handle, url, volume, offset)
		else
			ErrorMessage(source, 'You must select from one of the pre-defined songs (/phono songs)')
		end
	else
		ErrorMessage(source, 'You do not have permission to play a song on a phonograph')
	end
end)

AddEventHandler('phonograph:init', function(handle, url, title, volume, startTime)
	AddPhonograph(handle, url, title, volume, startTime)
end)

AddEventHandler('phonograph:pause', function(handle, paused)
	if IsPlayerAceAllowed(source, 'phonograph.interact') then
		PausePhonograph(handle, paused)
	else
		ErrorMessage(source, 'You do not have permission to pause/resume phonographs')
	end
end)

AddEventHandler('phonograph:stop', function(handle)
	if IsPlayerAceAllowed(source, 'phonograph.interact') then
		RemovePhonograph(handle)
	else
		ErrorMessage(source, 'You do not have permission to stop phonographs')
	end
end)

AddEventHandler('phonograph:showControls', function()
	TriggerClientEvent('phonograph:showControls', source)
end)

CreateThread(function()
	while true do
		Wait(500)

		for _, playerId in ipairs(GetPlayers()) do
			TriggerClientEvent('phonograph:sync', playerId, Phonographs, IsPlayerAceAllowed(playerId, 'phonograph.fullControls'), IsPlayerAceAllowed(playerId, 'phonograph.anyUrl'))
		end
	end
end)
