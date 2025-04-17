local playersData = {}

-- Function to register player data
function RegisterPlayerData(playerId, data)
    playersData[playerId] = data
end

-- Function to update player data conditionally
function UpdatePlayerData(playerId, newData)
    local currentData = playersData[playerId]
    if currentData then
        local updated = false
        for key, value in pairs(newData) do
            if currentData[key] ~= value then
                currentData[key] = value
                updated = true
            end
        end
        if updated then
            NotifyPlayers(playerId, currentData)
        end
    end
end

-- Function to notify all players of a specific player's data update
function NotifyPlayers(playerId, data)
    for id, _ in pairs(playersData) do
        if id ~= playerId then
            TriggerClientEvent('playerDataUpdated', id, playerId, data)
        end
    end
end

-- Example event handler for when a player connects
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local playerId = source
    deferrals.defer()

    MySQL.Async.fetchAll('SELECT last_position FROM rpz_players WHERE uid = @uid', {
        ['@uid'] = GetPlayerUID(playerId)  -- Assume you have a function to get the player's UID
    }, function(result)
        if result[1] then
            -- Player exists, retrieve the last known position
            local lastPosition = json.decode(result[1].last_position) or nil
            if lastPosition then
                -- Player has a saved position, trigger client event to spawn there
                TriggerClientEvent('rpz:spawnAtPosition', playerId, lastPosition)
            else
                -- No position saved, spawn at default location
                TriggerClientEvent('rpz:spawnAtDefault', playerId)
            end
        else
            -- New player, spawn at default location
            TriggerClientEvent('rpz:spawnAtDefault', playerId)
        end
        deferrals.done()
    end)
end)

-- Event handler for when a player changes position (without saving)
RegisterServerEvent('playerPositionChanged')
AddEventHandler('playerPositionChanged', function(newPosition)
    local playerId = source
    UpdatePlayerData(playerId, {position = newPosition})
end)

-- Event handler for when a player disconnects (without saving)
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    playersData[playerId] = nil
end)