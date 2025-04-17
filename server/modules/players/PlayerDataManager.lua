local PlayerDataManager = {}

-- Cache avec un timestamp pour chaque joueur
local playerCache = {}
local cacheTimeout = 300 -- Expiration du cache après 5 minutes (300 secondes)


RegisterNetEvent('rpzFramework:GetPlayerData')
AddEventHandler('rpzFramework:GetPlayerData', function(playerId, callback)
    -- Requête pour récupérer les données du joueur à partir de la base de données
    MySQL.Async.fetchAll([[
        SELECT * FROM rpz_players WHERE fivem_license = @fivem_license
    ]], {
        ['@fivem_license'] = playerId
    }, function(result)
        if #result > 0 then
            local playerData = result[1]
            if playerData.player_data then
                playerData.player_data = json.decode(playerData.player_data)
            end
            callback(playerData)
        else
            callback(nil)
        end
    end)
end)

RegisterNetEvent('rpzFramework:ClearPlayerCache')
AddEventHandler('rpzFramework:ClearPlayerCache', function(playerId)
    -- Nettoyer le cache du joueur ici (si nécessaire)
end)

-- Récupérer les données d'un joueur à partir de la base de données ou du cache
function PlayerDataManager.GetPlayerData(playerId, callback)
    local currentTime = os.time()

    -- Vérifier si les données sont dans le cache et qu'elles ne sont pas expirées
    if playerCache[playerId] and (currentTime - playerCache[playerId].timestamp < cacheTimeout) then
        callback(playerCache[playerId].data)
    else
        -- Si pas dans le cache ou expiré, on va les chercher dans la base de données
        MySQL.Async.fetchAll([[
            SELECT * FROM rpz_players WHERE fivem_license = @fivem_license
        ]], {
            ['@fivem_license'] = playerId
        }, function(result)
            if #result > 0 then
                local playerData = result[1]

                -- Décoder les données JSON si nécessaire
                if playerData.player_data then
                    playerData.player_data = json.decode(playerData.player_data)
                end

                if playerData.last_position then
                    playerData.last_position = json.decode(playerData.last_position)
                end

                -- Mettre à jour le cache avec un timestamp
                playerCache[playerId] = {
                    data = playerData,
                    timestamp = currentTime
                }

                -- Retourner les données
                callback(playerData)
            else
                -- Aucun joueur trouvé
                callback(nil)
            end
        end)
    end
end

-- Sauvegarder les données d'un joueur dans la base de données
function PlayerDataManager.SavePlayerData(playerId)
    local playerPed = GetPlayerPed(playerId)
    local coords = GetEntityCoords(playerPed)
    local health = GetEntityHealth(playerPed)

    -- Simuler la récupération des données de faim et soif
    local hunger = 100  -- À remplacer par votre propre logique
    local thirst = 100  -- À remplacer par votre propre logique

    -- Créer une table de données à sauvegarder
    local dataToSave = {
        health = health,
        hunger = hunger,
        thirst = thirst
    }

    -- Stocker la position et les autres données du joueur
    local playerData = {
        last_position = json.encode({x = coords.x, y = coords.y, z = coords.z}),
        player_data = json.encode(dataToSave)
    }

    -- Sauvegarder dans la base de données
    MySQL.Async.execute([[
        UPDATE rpz_players SET last_position = @last_position, player_data = @player_data WHERE fivem_license = @fivem_license
    ]], {
        ['@last_position'] = playerData.last_position,
        ['@player_data'] = playerData.player_data,
        ['@fivem_license'] = playerId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("Les données du joueur " .. playerId .. " ont été sauvegardées.")

            -- Mettre à jour le cache après la sauvegarde avec un nouveau timestamp
            playerCache[playerId] = {
                data = playerData,
                timestamp = os.time()
            }
        end
    end)
end


function PlayerDataManager.GetPlayerInventory(playerId, callback)
    -- Supposons que l'inventaire soit stocké dans une colonne 'inventory' en JSON dans la base de données
    MySQL.Async.fetchAll([[
        SELECT inventory FROM rpz_players WHERE fivem_license = @fivem_license
    ]], {
        ['@fivem_license'] = playerId
    }, function(result)
        if #result > 0 then
            local inventory = json.decode(result[1].inventory)
            callback(inventory)
        else
            callback(nil)
        end
    end)
end

-- Sauvegarder l'inventaire d'un joueur
function PlayerDataManager.SavePlayerInventory(playerId, inventory)
    local inventoryJson = json.encode(inventory)

    -- Mettre à jour l'inventaire dans la base de données
    MySQL.Async.execute([[
        UPDATE rpz_players SET inventory = @inventory WHERE fivem_license = @fivem_license
    ]], {
        ['@inventory'] = inventoryJson,
        ['@fivem_license'] = playerId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("L'inventaire du joueur " .. playerId .. " a été sauvegardé.")
        end
    end)
end


function PlayerDataManager.GetPlayerStats(playerId, callback)
    -- Requête pour récupérer les statistiques du joueur dans la base de données
    MySQL.Async.fetchAll([[
        SELECT stats FROM rpz_players WHERE fivem_license = @fivem_license
    ]], {
        ['@fivem_license'] = playerId
    }, function(result)
        if #result > 0 then
            local stats = json.decode(result[1].stats)
            callback(stats)
        else
            callback(nil)
        end
    end)
end


function PlayerDataManager.SavePlayerStats(playerId, stats)
    local statsJson = json.encode(stats)

    -- Mettre à jour les statistiques dans la base de données
    MySQL.Async.execute([[
        UPDATE rpz_players SET stats = @stats WHERE fivem_license = @fivem_license
    ]], {
        ['@stats'] = statsJson,
        ['@fivem_license'] = playerId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("Les statistiques du joueur " .. playerId .. " ont été sauvegardées.")
        end
    end)
end

function GetPlayerData(playerId, callback)
    -- Requête pour récupérer les données du joueur à partir de la base de données
    MySQL.Async.fetchAll([[
        SELECT * FROM rpz_players WHERE fivem_license = @fivem_license
    ]], {
        ['@fivem_license'] = playerId
    }, function(result)
        if #result > 0 then
            local playerData = result[1]
            if playerData.player_data then
                playerData.player_data = json.decode(playerData.player_data)
            end
            callback(playerData)
        else
            callback(nil)
        end
    end)
end

exports('GetPlayerData', GetPlayerData)
exports('ClearPlayerCache', ClearPlayerCache)

-- Nettoyer le cache lorsque le joueur quitte
function PlayerDataManager.ClearPlayerCache(playerId)
    playerCache[playerId] = nil
end

return PlayerDataManager



