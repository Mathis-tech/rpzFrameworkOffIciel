local playerTokens = {}

-- Function to generate a secure token for the player
local function GenerateTokenForPlayer(playerId)
    local randomString = playerId .. os.time() .. math.random()
    local token = string.sub(tostring(math.abs(math.random(1000000000, 9999999999))), 1, 10)  -- Generate a 10-character hash
    playerTokens[playerId] = token
    TriggerClientEvent('ReceiveToken', playerId, token)
end

-- Event handler for player connection
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local playerId = source
    GenerateTokenForPlayer(playerId)
end)

-- Function to verify the player's token
local function VerifyPlayerToken(playerId, tokenReceived)
    return playerTokens[playerId] == tokenReceived
end

-- Event handler for secure events
RegisterNetEvent('secureEvent')
AddEventHandler('secureEvent', function(tokenReceived, data)
    local playerId = source
    if VerifyPlayerToken(playerId, tokenReceived) then
        print("Token valide pour l'événement sécurisé.")
        -- Process the secure event here
    else
        print("Token invalide, accès refusé.")
        DropPlayer(playerId, "Token invalide.")
    end
end)