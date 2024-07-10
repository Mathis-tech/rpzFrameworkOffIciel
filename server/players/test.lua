RegisterServerCallback('getPlayerData', function(source, cb, playerId)
    -- Simuler la récupération des données du joueur
    local data = {
        name = "PlayerName",
        money = 1000,
        job = "police"
    }
    cb(data)
end)