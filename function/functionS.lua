ServerCallbacks = {}

RegisterNetEvent('trigger_server_callback')
AddEventHandler('trigger_server_callback', function(name, requestId, ...)
    local source = source
    local args = {...}
    if ServerCallbacks[name] then
        -- Utilisation de pcall pour gérer les erreurs et éviter les plantages
        local success, err = pcall(function()
            ServerCallbacks[name](source, function(...)
                TriggerClientEvent('server_callback', source, requestId, ...)
            end, table.unpack(args))
        end)
        if not success then
            print(('Erreur dans l\'exécution du callback %s: %s'):format(name, err))
        end
    else
        print(('Aucun callback trouver pour %s'):format(name))
    end
end)

RegisterServerCallback = function(name, cb)
    ServerCallbacks[name] = cb
end
