local lastVehicle = nil
local vehicleDamage = {}

function DrawText3Ds(x, y, z, text)
    -- Votre fonction pour dessiner du texte en 3D
end

function CheckVehicleDamage(vehicle)
    if not vehicleDamage[vehicle] then
        vehicleDamage[vehicle] = true -- Marquer le véhicule comme touché
        -- Ajoutez ici la logique pour sauvegarder les informations spécifiques sur les impacts de balle
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if IsEntityAVehicle(vehicle) then
            if HasEntityBeenDamagedByAnyObject(vehicle) or HasEntityBeenDamagedByAnyPed(vehicle) or HasEntityBeenDamagedByAnyVehicle(vehicle) then
                CheckVehicleDamage(vehicle)
            end
        end

        if IsPlayerFreeAiming(PlayerId()) then
            local hit, coords, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

            if hit and IsEntityAVehicle(entity) then
                lastVehicle = entity -- Enregistre le dernier véhicule visé
            elseif lastVehicle and not hit then
                if vehicleDamage[lastVehicle] then
                    local x, y, z = table.unpack(GetEntityCoords(lastVehicle))
                    DrawText3Ds(x, y, z + 1.0, "9mm Impact Area") -- Modifier pour positionner correctement le texte
                    -- Dessinez ici des textes supplémentaires pour les autres impacts si nécessaire
                end
            end
        end

        -- Réinitialiser le marqueur de dommage si nécessaire
        if lastVehicle and not DoesEntityExist(lastVehicle) then
            vehicleDamage[lastVehicle] = nil
            lastVehicle = nil
        end
    end
end)
