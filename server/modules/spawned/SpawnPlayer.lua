RegisterNetEvent('rpzFramework:spawnPlayer')
AddEventHandler('rpzFramework:spawnPlayer', function(playerId)
    print("[Serveur] Tentative de spawn du joueur avec mp_m_freemode_01")
    TriggerClientEvent('rpzFramework:applyPedModel', playerId, "mp_m_freemode_01")
end)



RegisterNetEvent('rpzFramework:applyDefaultPed')
AddEventHandler('rpzFramework:applyDefaultPed', function(playerId)
    -- Récupérer les données du joueur
    GetPlayerData(playerId, function(playerData)
        if playerData then
            -- Si le joueur a déjà des données, appliquer le ped stocké dans player_data
            TriggerClientEvent('rpzFramework:applyPedModel', playerId, playerData.player_data.ped)
        else
            -- Si le joueur est nouveau, lui appliquer le modèle ped par défaut
            local defaultPed = "mp_m_freemode_01"  -- Utiliser un modèle par défaut
            TriggerClientEvent('rpzFramework:applyPedModel', playerId, defaultPed)

            -- Sauvegarder ce nouveau joueur avec le modèle par défaut dans la base de données
            SaveNewPlayerWithDefaultPed(playerId, defaultPed)
        end
    end)
end)

-- Fonction pour forcer le ped par défaut pour un nouveau joueur
function SaveNewPlayerWithDefaultPed(playerId, pedModel)
    -- Récupérer les informations nécessaires et sauvegarder le joueur dans la base de données
    local playerData = {
        ped = pedModel,
        health = 100,  -- Données par défaut
        hunger = 100,
        thirst = 100
    }

    MySQL.Async.execute([[
        INSERT INTO rpz_players (fivem_license, player_data)
        VALUES (@fivem_license, @player_data)
    ]], {
        ['@fivem_license'] = GetPlayerIdentifier(playerId, 'license'),
        ['@player_data'] = json.encode(playerData)
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("Nouveau joueur sauvegardé avec ped par défaut : " .. pedModel)
        else
            print("Erreur lors de la sauvegarde du joueur.")
        end
    end)
end


AddEventHandler('playerDropped', function(reason)
    local playerId = source

    -- Utiliser l'événement pour récupérer les données du joueur
    TriggerEvent('rpzFramework:GetPlayerData', playerId, function(playerData)
        if playerData then
            -- Mettre à jour les données avant la déconnexion (santé, position, etc.)
            playerData.health = GetEntityHealth(GetPlayerPed(playerId))

            -- Sauvegarder les modifications dans la base de données
            MySQL.Async.execute([[
                UPDATE rpz_players
                SET player_data = @player_data
                WHERE fivem_license = @fivem_license
            ]], {
                ['@fivem_license'] = GetPlayerIdentifier(playerId, 'license'),
                ['@player_data'] = json.encode(playerData.player_data)
            }, function(affectedRows)
                print("Les données du joueur ont été sauvegardées avant la déconnexion.")
            end)
        end

        -- Utiliser l'événement pour nettoyer le cache
        TriggerEvent('rpzFramework:ClearPlayerCache', playerId)
    end)
end)


RegisterNetEvent('rpz:savePlayerPed')
AddEventHandler('rpz:savePlayerPed', function(newPedModel)
    local playerId = source
    GetPlayerDataFromDB(playerId, function(playerData)
        if playerData then
            -- Mettre à jour les données du ped
            playerData.player_data.ped = newPedModel

            -- Sauvegarder les nouvelles données dans la base de données
            MySQL.Async.execute([[
                UPDATE rpz_players
                SET player_data = @player_data
                WHERE fivem_license = @fivem_license
            ]], {
                ['@fivem_license'] = playerId,
                ['@player_data'] = json.encode(playerData.player_data)
            }, function(affectedRows)
                if affectedRows > 0 then
                    print("Les données du ped ont été mises à jour.")
                else
                    print("Erreur lors de la mise à jour des données du ped.")
                end
            end)
        else
            print("Aucun joueur trouvé pour mettre à jour les données.")
        end
    end)
end)

function GetPlayerDataFromDB(playerId, callback)
    -- Requête pour récupérer les données du joueur à partir de sa licence FiveM
    MySQL.Async.fetchAll([[
        SELECT * FROM rpz_players WHERE fivem_license = @fivem_license
    ]], {
        ['@fivem_license'] = playerId  -- Associer l'ID joueur (fivem_license) à la variable SQL
    }, function(result)
        -- Vérifier si nous avons trouvé un joueur
        if #result > 0 then
            -- Le joueur a été trouvé, retourner ses données
            local playerData = result[1]
            
            -- Convertir les champs JSON (player_data, last_position) en table Lua si nécessaire
            if playerData.player_data then
                playerData.player_data = json.decode(playerData.player_data)
            end
            
            if playerData.last_position then
                playerData.last_position = json.decode(playerData.last_position)
            end

            -- Appeler le callback avec les données du joueur
            if type(callback) == "function" then
                callback(playerData)
            end
        else
            -- Aucun joueur trouvé, appeler le callback avec 'nil'
            if type(callback) == "function" then
                callback(nil)
            end
        end
    end)
end
