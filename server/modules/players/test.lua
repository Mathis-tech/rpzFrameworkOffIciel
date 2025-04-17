RegisterServerCallback('getPlayerData', function(source, callback, playerId)
    -- Simuler la récupération des données du joueur
    local data = {
        name = "PlayerName",
        money = 1000,
        job = "police"
    }
    callback(data)
end)