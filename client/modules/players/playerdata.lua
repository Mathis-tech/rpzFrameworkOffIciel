PlayerData = {
    inventory = {},
    accounts = {},
    maxWeight = 50,
    skin = {},
    loadout = {}
}

function PlayerData:LoadData(data)
    self.inventory = data.inventory or {}
    self.accounts = data.accounts or {}
    self.maxWeight = data.maxWeight or 50
    self.skin = data.skin or {}
    self.loadout = data.loadout or {}
end

RegisterNetEvent('rpzFramework:loadPlayerData')
AddEventHandler('rpzFramework:loadPlayerData', function(data)
    PlayerData:LoadData(data)
end)

function SendPlayerPositionToServer()
    local playerPed = GetPlayerPed(-1)
    local coords = GetEntityCoords(playerPed)
    local position = {x = coords.x, y = coords.y, z = coords.z}
    
    -- Trigger server event to save the position
    TriggerServerEvent('rpz:savePlayerPosition', position)
end

-- Start a loop to constantly track and send position to the server
Citizen.CreateThread(function()
    while true do
        SendPlayerPositionToServer()
        Citizen.Wait(5000)  -- Update every 5 seconds
    end
end)