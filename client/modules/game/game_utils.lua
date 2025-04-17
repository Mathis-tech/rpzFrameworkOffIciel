RPZ = RPZ or {}
RPZ.Game = {}
function RPZ.Game.GetClosestPlayer()
    local players = RPZ.Game.GetActivePlayers(true)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer = -1
    local closestDistance = -1

    for _, otherPlayer in ipairs(players) do
        local otherPed = GetPlayerPed(otherPlayer)
        local otherCoords = GetEntityCoords(otherPed)
        local distance = #(playerCoords - otherCoords)

        if closestDistance == -1 or distance < closestDistance then
            closestPlayer = otherPlayer
            closestDistance = distance
        end
    end

    return closestPlayer, closestDistance
end

-- Fonction pour obtenir les joueurs actifs dans votre framework
function RPZ.Game.GetActivePlayers(excludeSelf)
    local players = {}
    local localPlayerId = PlayerId()

    for _, playerId in ipairs(GetActivePlayers()) do
        if not excludeSelf or playerId ~= localPlayerId then
            table.insert(players, playerId)
        end
    end

    return players
end