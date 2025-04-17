

-- Fonction pour sauvegarder les données d'un joueur dans la base de données
function SavePlayerToDatabase(playerId, data)
    local playerPos = data.position or {x = 0, y = 0, z = 0}
    local playerData = data.playerData or {}

    -- Mise à jour de la position dans la base de données
    MySQL.Async.execute('UPDATE rpz_players SET last_position = @position WHERE uid = @uid', {
        ['@position'] = json.encode(playerPos),
        ['@uid'] = data.uid
    }, function(affectedRows)
        if affectedRows > 0 then
            print("Position saved for player UID: " .. data.uid .. " at X: " .. playerPos.x .. ", Y: " .. playerPos.y .. ", Z: " .. playerPos.z)
        else
            print("Failed to save position for player UID: " .. data.uid)
        end
    end)

    -- Mise à jour des autres données du joueur (vie, faim, soif) dans la colonne player_data
    local playerDetails = {
        health = playerData.health or 100,
        hunger = playerData.hunger or 100,
        thirst = playerData.thirst or 100
    }

    MySQL.Async.execute('UPDATE rpz_players SET player_data = @data WHERE uid = @uid', {
        ['@data'] = json.encode(playerDetails),
        ['@uid'] = data.uid
    }, function(affectedRows)
        if affectedRows > 0 then
            print("Player data saved for UID: " .. data.uid .. " | Health: " .. playerDetails.health .. ", Hunger: " .. playerDetails.hunger .. ", Thirst: " .. playerDetails.thirst)
        else
            print("Failed to save player data for UID: " .. data.uid)
        end
    end)
end

-- Fonction pour récupérer les données en jeu du joueur
function GetPlayerDataInGame(playerId)
    local playerPed = GetPlayerPed(playerId)
    local coords = GetEntityCoords(playerPed)
    local health = GetEntityHealth(playerPed)  -- Récupérer la santé du joueur

    -- Simuler la récupération des données de faim et soif
    local hunger = 100  -- À remplacer par la vraie méthode pour récupérer la faim du joueur
    local thirst = 100  -- À remplacer par la vraie méthode pour récupérer la soif du joueur

    return {
        position = {x = coords.x, y = coords.y, z = coords.z},
        playerData = {
            health = health,
            hunger = hunger,
            thirst = thirst
        }
    }
end

-- Fonction de sauvegarde périodique des données de tous les joueurs
function PeriodicSavePlayersData()
    for _, playerId in ipairs(GetPlayers()) do
        local fivem_license = GetPlayerLicense(playerId)

        -- Vérifiez que la license GTA est bien récupérée
        if fivem_license then
            print("License récupérée pour le joueur ID " .. playerId .. " : " .. fivem_license)

            -- Appeler `GetPlayerUID` avec la license directement
            GetPlayerUID(fivem_license, function(uid)
                if uid then
                    -- Récupérer la position, la santé, la faim et la soif du joueur
                    local playerData = GetPlayerDataInGame(playerId)
                    playerData.uid = uid

                    -- Sauvegarder les données dans la base de données
                    SavePlayerToDatabase(playerId, playerData)
                else
                    print("UID not found for player: " .. playerId)
                end
            end)
        else
            print("No license found for player: " .. playerId)
        end
    end

    -- Reprogrammer la boucle toutes les 10 secondes
    SetTimeout(10000, PeriodicSavePlayersData)
end


-- Démarrer la boucle de sauvegarde des données des joueurs
PeriodicSavePlayersData()
