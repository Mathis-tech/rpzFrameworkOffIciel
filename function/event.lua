-- ServerCallbacks = {}

-- RegisterNetEvent('trigger_server_callback')
-- AddEventHandler('trigger_server_callback', function(name, requestId, ...)
--     local source = source
--     local args = {...}
--     if ServerCallbacks[name] then
--         -- Utilisation de pcall pour gérer les erreurs et éviter les plantages
--         local success, err = pcall(function()
--             ServerCallbacks[name](source, function(...)
--                 TriggerClientEvent('server_callback', source, requestId, ...)
--             end, table.unpack(args))
--         end)
--         if not success then
--             print(('Erreur dans l\'exécution du callback %s: %s'):format(name, err))
--         end
--     else
--         print(('Aucun callback trouver pour %s'):format(name))
--     end
-- end)

-- RegisterServerCallback = function(name, cb)
--     ServerCallbacks[name] = cb
-- end



ServerCallbacks = {}

-- Fonction pour enregistrer un callback serveur
RegisterServerCallback = function(name, cb)
    if type(name) ~= 'string' or type(cb) ~= 'function' then
        print(('[Erreur] Impossible d\'enregistrer le callback : Nom ou fonction invalide (%s).'):format(name))
        return
    end

    if ServerCallbacks[name] then
        print(('[Attention] Le callback "%s" existe déjà. Il sera remplacé.'):format(name))
    end

    ServerCallbacks[name] = cb
    print(('[Info] Callback "%s" enregistré avec succès.'):format(name))
end

-- Événement client -> serveur pour exécuter un callback
RegisterNetEvent('trigger_server_callback')
AddEventHandler('trigger_server_callback', function(name, requestId, ...)
    local source = source -- ID du joueur appelant
    local args = {...}

    -- Validation du nom du callback
    if type(name) ~= 'string' or not ServerCallbacks[name] then
        print(('[Erreur] Callback inconnu ou nom invalide : "%s".'):format(tostring(name)))
        TriggerClientEvent('server_callback_error', source, requestId, 'Callback inconnu ou non enregistré.')
        return
    end

    -- Exécution sécurisée du callback avec gestion des erreurs
    local success, err = pcall(function()
        ServerCallbacks[name](source, function(...)
            TriggerClientEvent('server_callback', source, requestId, ...)
        end, table.unpack(args))
    end)

    -- Gestion des erreurs
    if not success then
        print(('[Erreur] Échec du callback "%s" : %s'):format(name, err))
        TriggerClientEvent('server_callback_error', source, requestId, 'Erreur interne lors du traitement du callback.')
    end
end)