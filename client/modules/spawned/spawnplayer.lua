-- Fonction pour garantir le bon modèle de ped et le chargement des composants
function EnsureCorrectPed()
    local playerPed = PlayerPedId()
    local currentPedModel = GetEntityModel(playerPed)
    local mpFreemodeMale = GetHashKey(RPZ.PedDefault)

    if currentPedModel ~= mpFreemodeMale then
        print("[Client] Le joueur n'a pas le ped mp_m_freemode_01, chargement en cours...")

        RequestModel(mpFreemodeMale)
        local timer = 0
        local timeout = 5000  -- Délai maximum de 5 secondes

        while not HasModelLoaded(mpFreemodeMale) and timer < timeout do
            Wait(100)
            timer = timer + 100
        end

        if HasModelLoaded(mpFreemodeMale) then
            SetPlayerModel(PlayerId(), mpFreemodeMale)
            SetModelAsNoLongerNeeded(mpFreemodeMale)

            -- Appliquer les composants compatibles
            SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)  -- Chapeau basique
            SetPedComponentVariation(PlayerPedId(), 11, 1, 0, 2) -- Veste simple
            SetPedComponentVariation(PlayerPedId(), 4, 0, 0, 2)  -- Pantalon par défaut
            SetPedComponentVariation(PlayerPedId(), 6, 0, 0, 2)  -- Chaussures par défaut

            print("[Client] Modèle de ped et composants appliqués avec succès.")
        else
            print("[Client] Échec du chargement du modèle de ped.")
        end
    end
end

Citizen.CreateThread(function()
    while true do
        EnsureCorrectPed()
        Wait(15000)  -- Vérifier toutes les 15 secondes pour éviter les conflits
    end
end)


-- Client : recevoir et appliquer le modèle de ped
RegisterNetEvent('rpz:setPlayerSkin')
AddEventHandler('rpz:setPlayerSkin', function(pedModel)
    local playerPed = PlayerPedId()
    local modelHash = GetHashKey(pedModel)

    -- Charger le modèle ped
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end

    -- Appliquer le modèle ped
    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)

    -- Optionnel : remettre les vêtements par défaut après l'application du ped
    -- TriggerEvent('skinchanger:loadDefaultModel', true, cb)
end)


RegisterNetEvent('rpzFramework:applyPedModel')
AddEventHandler('rpzFramework:applyPedModel', function(pedModel)
    local player = PlayerId()
    
    -- Assurez-vous que le joueur est totalement chargé
    while not IsPedFullyLoaded(player) do
        Wait(500)
    end

    local model = GetHashKey(pedModel)

    -- Charger le modèle du ped
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    -- Appliquer le modèle au joueur
    SetPlayerModel(player, model)
    SetModelAsNoLongerNeeded(model)
end)


RegisterNetEvent('rpzFramework:applyPedAndSpawn')
AddEventHandler('rpzFramework:applyPedAndSpawn', function(spawnCoords, pedModel)
    local playerPed = PlayerPedId()
    local model = GetHashKey(pedModel)
    
    print("[Client] Tentative de chargement du modèle : " .. pedModel)
    
    -- Charger le modèle avec vérification
    RequestModel(model)
    local timeout = 5000 -- 5 secondes de délai pour charger le modèle
    local timer = 0

    while not HasModelLoaded(model) and timer < timeout do
        Wait(100)
        timer = timer + 100
        print("[Client] Modèle en cours de chargement... (" .. timer .. " ms)")
    end

    if HasModelLoaded(model) then
        print("[Client] Modèle " .. pedModel .. " chargé avec succès.")
        
        -- Appliquer le modèle
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)

        -- Configurer les vêtements et accessoires
        SetPedComponentVariation(playerPed, 0, 1, 1, 2)  -- Exemple de chapeau
        SetPedComponentVariation(playerPed, 11, 3, 2, 2) -- Exemple de veste
        SetPedComponentVariation(playerPed, 4, 1, 0, 2)  -- Exemple de pantalon

        -- Déplacer le joueur aux coordonnées de spawn
        SetEntityCoords(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)

        -- Geler brièvement pour assurer le rendu
        FreezeEntityPosition(playerPed, true)
        Wait(1000)
        FreezeEntityPosition(playerPed, false)

        print("[Client] Le joueur a spawn avec succès dans le ped : " .. pedModel)
    else
        print("[Client] Échec du chargement du modèle " .. pedModel .. ". Utilisation du modèle de secours.")
        
        -- Charger et appliquer un modèle de secours
        local fallbackPed = "a_m_y_skater_01"
        local fallbackModel = GetHashKey(fallbackPed)
        
        RequestModel(fallbackModel)
        while not HasModelLoaded(fallbackModel) do
            Wait(100)
        end

        SetPlayerModel(PlayerId(), fallbackModel)
        SetModelAsNoLongerNeeded(fallbackModel)
        SetEntityCoords(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)

        print("[Client] Le joueur a été spawn avec le modèle de secours : " .. fallbackPed)
    end
end)


RegisterNetEvent('rpz:saveModifiedPed')
AddEventHandler('rpz:saveModifiedPed', function(newPedModel)
    -- Envoyer le modèle modifié au serveur
    TriggerServerEvent('rpz:savePlayerPed', newPedModel)
end)