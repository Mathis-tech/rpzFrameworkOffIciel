local registeringPlayers = {}
local playerUIDs = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    loadJobs()
end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local _source = source
    deferrals.defer()
    Wait(0)

    if not _source or _source == 0 then
        print("Error: _source is invalid.")
        deferrals.done("Un problème technique est survenu.")
        return
    end

    print("Debug: Checking for banned words in playerName.")
    if containsBannedWord(playerName) then
        print("Debug: Banned word found in playerName.")
        deferrals.done("Votre nom contient des termes non autorisés.")
        return
    end

    local identifiers = GetPlayerIdentifiers(_source)
    local steamIdentifier, fivemLicense = nil, nil
    
    for _, id in ipairs(identifiers) do
        if string.match(id, "steam:") then
            steamIdentifier = id
        elseif string.match(id, "license:") then
            fivemLicense = id
        end
    end
    
    if not steamIdentifier then
        print("Error: No valid Steam identifier found.")
        deferrals.done("Aucun identifiant Steam valide trouvé.")
        return
    end
    
    if not fivemLicense then
        print("Error: No valid FiveM license found.")
        deferrals.done("Aucun identifiant de licence FiveM valide trouvé.")
        return
    end

    -- Prevent duplicate registration attempts
    if registeringPlayers[steamIdentifier] then
        print("Warning: Duplicate registration attempt detected for Steam identifier: " .. steamIdentifier)
        deferrals.done("Vous êtes déjà en cours d'enregistrement. Veuillez patienter.")
        return
    end

    -- Lock this player for registration
    registeringPlayers[steamIdentifier] = true

    -- Check if the player is already registered
    MySQL.Async.fetchScalar('SELECT uid FROM rpz_players WHERE steam_name = @steam_name', {['@steam_name'] = steamIdentifier}, function(uid)
        if uid then
            print("Debug: Le joueur est déjà enregistré sous UID: " .. tostring(uid))
            playerUIDs[_source] = uid
            registeringPlayers[steamIdentifier] = nil
            deferrals.done()
        else
            print("Debug: Le joueur n'est pas enregistré, enregistrement en cours...")
            local newUID = GenerateUID()
            MySQL.Async.execute([[
                INSERT INTO rpz_players 
                (`uid`, `name`, `steam_name`, `fivem_license`, `discord_id`, `job`, `job_grade`, `inventory`, `keys`, `is_staff`, `staff_rank`, `permission_level`)
                VALUES (@uid, @name, @steam_name, @fivem_license, @discord_id, @job, @job_grade, @inventory, @keys, @is_staff, @staff_rank, @permission_level)
                ON DUPLICATE KEY UPDATE uid=uid
            ]], {
                ['@uid'] = newUID,
                ['@name'] = playerName,
                ['@steam_name'] = steamIdentifier,
                ['@fivem_license'] = fivemLicense or 'default_license',
                ['@discord_id'] = 'default_discord',
                ['@job'] = 'unemployed',
                ['@job_grade'] = 0,
                ['@inventory'] = '{}',
                ['@keys'] = '{}',
                ['@is_staff'] = 0,
                ['@staff_rank'] = 'none',
                ['@permission_level'] = 0
            }, function(affectedRows)
                if affectedRows > 0 then
                    print("Debug: Nouveau joueur enregistré avec UID: " .. newUID)
                    playerUIDs[_source] = newUID
                else
                    print("Debug: Le joueur est déjà enregistré.")
                end
                registeringPlayers[steamIdentifier] = nil
                deferrals.done()
            end)
        end
    end)
end)

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
        uidExists = MySQL.Sync.fetchScalar('SELECT uid FROM rpz_players WHERE uid = @uid', {['@uid'] = uid})
    end
    return uid
end