-- File: newplayer.lua
RPZ = RPZ or {}
RPZ.Player = RPZ.Player or {}
local registeringPlayers = {}  -- Table pour suivre les joueurs qui sont en cours d'enregistrement
local playerUIDs = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    loadJobs()
end)

RPZ.Player.Login = function(playerSource, uid)
    print("Logging in player with UID: " .. uid)
    
    -- Charger les données du joueur depuis la base de données
    MySQL.Async.fetchAll('SELECT player_data FROM rpz_players WHERE uid = @uid', {['@uid'] = uid}, function(result)
        if result[1] then
            local playerData = json.decode(result[1].player_data)

            -- Forcer l'apparence du joueur avec le ped par défaut
            if playerData.ped then
                TriggerClientEvent('setPlayerModel', playerSource, playerData.ped)
            else
                TriggerClientEvent('setPlayerModel', playerSource, RPZ.PedDefault)  -- Utiliser le modèle par défaut si non défini
            end
        else
            TriggerClientEvent('setPlayerModel', playerSource, RPZ.PedDefault)
        end
    end)
end

function GenerateUID()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local length = 8
    local uid = ''
    local uidExists = true
    while uidExists do
        uid = ''
        for i = 1, length do
            local rand = math.random(#chars)
            uid = uid .. chars:sub(rand, rand)
        end
        -- Vérifier si l'UID existe déjà
        uidExists = MySQL.Sync.fetchScalar('SELECT uid FROM rpz_players WHERE uid = @uid', {['@uid'] = uid})
    end
    return uid
end


function CreateNewPlayer(playerName, identifiers, callback)
    local fivemLicense = nil
    local steamIdentifier = nil
    local discordIdentifier = nil

    -- Parcourir les identifiants pour trouver Steam, FiveM License et Discord
    for _, id in ipairs(identifiers) do
        if string.match(id, "steam:") then
            steamIdentifier = id
        elseif string.match(id, "license:") then
            fivemLicense = id
        elseif string.match(id, "discord:") then
            discordIdentifier = id
        end
    end

    -- Vérifier si le joueur existe déjà dans la base de données
    MySQL.Async.fetchScalar('SELECT uid FROM rpz_players WHERE steam_name = @steam_name', {
        ['@steam_name'] = steamIdentifier
    }, function(existingUID)
        if existingUID then
            print("Le joueur avec le Steam ID " .. steamIdentifier .. " existe déjà. UID : " .. existingUID)
            -- Vous pouvez choisir de mettre à jour les informations du joueur ici, ou simplement retourner l'UID existant.
            callback(existingUID)
        else
            -- Générer un UID unique pour le joueur s'il n'existe pas déjà
            local newUID = GenerateUID()

            -- Construire les données à stocker dans la colonne `player_data`
            local playerData = {
                ped = RPZ.PedDefault or "mp_m_freemode_01",  -- Utiliser une valeur par défaut si RPZ.PedDefault est nil
                health = 100,          -- Exemple de données : la santé du joueur
                hunger = 100,          -- Exemple de données : la faim
                thirst = 100           -- Exemple de données : la soif
            }

            local encodedPlayerData = json.encode(playerData)

            -- Insérer le nouveau joueur dans la base de données
            MySQL.Async.execute([[
                INSERT INTO rpz_players 
                (uid, name, steam_name, fivem_license, discord_id, player_data)
                VALUES (@uid, @name, @steam_name, @fivem_license, @discord_id, @player_data)
            ]], {
                ['@uid'] = newUID,
                ['@name'] = playerName,
                ['@steam_name'] = steamIdentifier,
                ['@fivem_license'] = fivemLicense,
                ['@discord_id'] = discordIdentifier,
                ['@player_data'] = encodedPlayerData
            }, function(affectedRows)
                if affectedRows > 0 then
                    print("Nouveau joueur enregistré avec UID : " .. newUID)
                    callback(newUID)
                else
                    print("Erreur lors de la création du nouveau joueur.")
                    callback(false)
                end
            end)
        end
    end)
end




AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local identifiers = GetPlayerIdentifiers(source)
    local fivemLicense = nil

    -- Parcourir les identifiants pour récupérer la licence FiveM
    for _, id in ipairs(identifiers) do
        if string.match(id, "license:") then
            fivemLicense = id
        end
    end

    -- Vérification dans la base de données si le joueur existe déjà
    MySQL.Async.fetchScalar("SELECT uid FROM rpz_players WHERE fivem_license = @fivem_license", {
        ['@fivem_license'] = fivemLicense
    }, function(uid)
        if uid then
            print("Debug: Le joueur avec la licence " .. fivemLicense .. " est déjà enregistré.")
            deferrals.done()  -- Le joueur est déjà enregistré, pas besoin de créer un nouveau compte
        else
            print("Debug: Le joueur n'est pas enregistré, création du profil.")
            -- Appeler la fonction pour créer un nouveau joueur
            CreateNewPlayer(playerName, identifiers, function(newUID)
                if newUID then
                    print("Nouveau joueur créé avec UID : " .. newUID)
                    deferrals.done()
                else
                    setKickReason("Erreur lors de la création du profil.")
                    deferrals.done("Erreur lors de la création du profil.")
                end
            end)
        end
    end)
end)

RegisterNetEvent('rpz:playerLoaded')
AddEventHandler('rpz:playerLoaded', function(playerId, xPlayer)
    -- Récupérer les données du joueur depuis la base de données
    local result = MySQL.Sync.fetchAll('SELECT player_data FROM rpz_players WHERE uid = @uid', {
        ['@uid'] = xPlayer.identifier
    })

    if result[1] ~= nil and result[1].player_data ~= nil then
        local playerData = json.decode(result[1].player_data)

        -- Appliquer le ped stocké dans la base de données ou le ped par défaut
        if playerData.ped ~= nil then
            TriggerClientEvent('rpz:setPlayerSkin', playerId, playerData.ped)
        else
            TriggerClientEvent('rpz:setPlayerSkin', playerId, 'mp_m_freemode_01')
        end
    else
        -- Appliquer le ped par défaut si aucune donnée n'est trouvée
        TriggerClientEvent('rpz:setPlayerSkin', playerId, 'mp_m_freemode_01')
    end
end)



AddEventHandler('playerDropped', function(reason)
    local _source = source
    local uid = playerUIDs[_source]
    if uid then
        print("Debug: Player disconnected. UID: " .. uid .. " Reason: " .. reason)
        RPZ.Player.Logout(_source)  -- Appeler la fonction Logout
        playerUIDs[_source] = nil
    end
end)