
AddEventHandler('playerSpawned', function()
    local playerPed = PlayerPedId()  -- Remplacer GetPlayerPed(-1) par PlayerPedId() (plus propre et recommandé)

    -- Vérifier que le joueur est bien chargé
    while not DoesEntityExist(playerPed) do
        Wait(100)  -- Attendre que le joueur soit complètement chargé
    end

    -- Geler la position du joueur pour éviter tout problème pendant le spawn
    FreezeEntityPosition(playerPed, true)

    -- Définir les coordonnées du joueur au point de spawn principal
    local spawnX = RPZ.ConfigGlobal.spawnPrincipal.X
    local spawnY = RPZ.ConfigGlobal.spawnPrincipal.Y
    local spawnZ = RPZ.ConfigGlobal.spawnPrincipal.Z

    -- Déplacer le joueur au point de spawn
    SetEntityCoords(playerPed, spawnX, spawnY, spawnZ, false, false, false, true)

    -- Débloquer la position du joueur après avoir défini les coordonnées
    FreezeEntityPosition(playerPed, false)

    -- Imprimer pour déboguer
    print("Le joueur est apparu sur le serveur au point de spawn principal.")
end)

RegisterNetEvent('rpz:requestLastPosition')
AddEventHandler('rpz:requestLastPosition', function()
    local playerId = source
    local fivemLicense = GetPlayerIdentifier(playerId, license)

    if fivemLicense then
        GetLastPlayerPosition(fivemLicense, function(position)
            if position then
                TriggerClientEvent('rpz:spawnPlayerAtPosition', playerId, position)
            else
                -- Si aucune position n'existe, renvoyer les coordonnées par défaut
                local defaultPosition = {
                    x = RPZ.ConfigGlobal.spawnPrincipal.X,
                    y = RPZ.ConfigGlobal.spawnPrincipal.Y,
                    z = RPZ.ConfigGlobal.spawnPrincipal.Z
                }
                TriggerClientEvent('rpz:spawnPlayerAtPosition', playerId, defaultPosition)
            end
        end)
    else
        print("ERREUR : Licence non trouvée pour le joueur ID " .. playerId)
    end
end)
