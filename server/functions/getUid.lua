function GetPlayerUID(identifier, callback)
    MySQL.Async.fetchScalar("SELECT uid FROM rpz_players WHERE fivem_license = @identifier", {
        ['@identifier'] = identifier
    }, function(uid)
        if uid then
            print("UID found: " .. uid)  -- Débogage lorsque l'UID est trouvé
            callback(uid)
        else
            print("No UID found for identifier: " .. identifier)  -- Débogage si aucun UID n'est trouvé
            callback(nil)
        end
    end)
end
