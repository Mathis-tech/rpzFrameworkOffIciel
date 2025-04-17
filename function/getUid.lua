function GetPlayerLicense(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "license:") then
            print("License trouvée pour le joueur : " .. identifier) -- Affiche la license trouvée
            return identifier
        end
    end
    print("Aucune license trouvée pour le joueur : " .. playerId)
    return nil
end

function GetPlayerUID(license, callback)
    if not license then
        print("Debug: License non trouvée")
        if type(callback) == "function" then
            callback(false)
        end
        return
    end

    print("Debug: Identifiant reçu pour la recherche : " .. license)

    -- Requête SQL pour chercher l'UID avec la license GTA
    local query = "SELECT uid FROM rpz_players WHERE fivem_license = @license"
    local params = { ['@license'] = license }

    MySQL.Async.fetchScalar(query, params, function(uid)
        if uid then
            print("Debug: UID trouvé pour l'identifiant : " .. license .. ", UID: " .. uid)
            if type(callback) == "function" then
                callback(uid)
            end
        else
            print("Debug: Aucun UID trouvé pour l'identifiant : " .. license)
            if type(callback) == "function" then
                callback(false)
            end
        end
    end)
end

