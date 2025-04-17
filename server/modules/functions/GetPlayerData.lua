
local function logEvent(eventType, message)
    print(string.format("[%s] %s", eventType, message))
end

local playerConnectionTimes = {}
local playerUIDs = {} -- This should be declared here to be accessible in this script

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local playerId = source
    local connectTime = os.time()
    playerConnectionTimes[playerId] = connectTime
    local uid = playerUIDs[playerId] or "Unknown UID"
    logEvent("PlayerConnect", string.format("Le joueur %s s'est connecté à %s", uid, os.date("%Y-%m-%d %H:%M:%S", connectTime)))
end)

AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local disconnectTime = os.time()
    local uid = playerUIDs[playerId] or "Unknown UID"
    logEvent("PlayerDisconnect", string.format("Le joueur (UID: %s, ID: %d) s'est déconnecté à %s. Raison: %s", uid, playerId, os.date("%Y-%m-%d %H:%M:%S", disconnectTime), reason))
    playerConnectionTimes[playerId] = nil
    playerUIDs[playerId] = nil
end)

function GetPlayerLastConnection(playerId)
    return playerConnectionTimes[playerId] or os.time()
end

function GetCurrentItemInHand(playerId)
    local ped = GetPlayerPed(playerId)
    local currentWeapon = GetSelectedPedWeapon(ped)
    
    if currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
        return currentWeapon
    else
        return nil  -- No weapon or item in hand
    end
end

function GetPlayerPosition(playerId)
    local playerPed = GetPlayerPed(playerId)
    local coords = GetEntityCoords(playerPed)
    return {x = coords.x, y = coords.y, z = coords.z}
end

function SaveAllPlayerPositions()
    for _, playerId in ipairs(GetPlayers()) do
        local position = GetPlayerPosition(playerId)
        local uid = GetPlayerUID(playerId)  -- Assume this function gets the player's unique ID
        
        -- Save position to database
        MySQL.Async.execute('UPDATE rpz_players SET last_position = @position WHERE uid = @uid', {
            ['@position'] = json.encode(position),
            ['@uid'] = uid
        })
    end
end

function StartPeriodicSave()
    SetTimeout(5000, function()
        SaveAllPlayerPositions()
        StartPeriodicSave()  -- Recursive call to keep the loop running
    end)
end

function GetPlayerInventory(playerId)
    print("Soon to be able to see the inventory content")
end

function GetPlayerCurrentItem(playerId)
    return GetCurrentItemInHand(playerId)
end

function GetPlayerJobs(playerId)
    print("Soon to know the job")
end

function GetPlayerCash(playerId)
    local playerMoney = { cash = 0, bank = 0 }
    
    MySQL.Async.fetchAll("SELECT cash FROM rpz_players WHERE fivem_license = @playerId", {
        ['@playerId'] = playerId
    }, function(result)
        if result[1] then
            playerMoney.cash = result[1].cash
        else
            print("Erreur : Aucun enregistrement trouvé pour le joueur avec l'ID " .. playerId)
        end
    end)

    return playerMoney
end


function GetPlayerBank(playerId)
    local playerMoney = { cash = 0, bank = 0 }
    
    MySQL.Async.fetchAll("SELECT bank FROM rpz_players WHERE fivem_license = @playerId", {
        ['@playerId'] = playerId
    }, function(result)
        if result[1] then
            playerMoney.bank = result[1].bank
        else    
            print("Erreur : Aucun enregistrement trouvé pour le joueur avec l'ID " .. playerId)
        end
    end)

    return playerMoney
end


function GetPlayerMoney(playerId)
    return {
        cash = GetPlayerCash(playerId),
        bank = GetPlayerBank(playerId)
    }
end

function GetPlayerConnectionInfo(playerId)
    return {
        ip = GetPlayerEndpoint(playerId),
        fivemLicense = GetPlayerIdentifier(playerId, 0),
        steam = GetPlayerIdentifier(playerId, 1)
    }
end

function GetPlayerLastLogin(playerId)
    return os.date("%Y-%m-%d %H:%M:%S", GetPlayerLastConnection(playerId))
end

RegisterCommand('getplayerinfo', function(source, args, rawCommand)
    local playerId = tonumber(args[1]) or source
    local playerInfo = GetPlayerInfo(playerId)
    if source > 0 then
        if args[1] then
            local targetPlayerId = tonumber(args[1])
            if targetPlayerId then
                local playerData = {
                    position = GetPlayerPosition(targetPlayerId),
                    inventory = GetPlayerInventory(targetPlayerId),
                    currentItem = GetPlayerCurrentItem(targetPlayerId),
                    jobs = GetPlayerJobs(targetPlayerId),
                    money = GetPlayerMoney(targetPlayerId),
                    connectionInfo = GetPlayerConnectionInfo(targetPlayerId),
                    lastLogin = GetPlayerLastLogin(targetPlayerId)
                }
                print("Info: Player data: " .. json.encode(playerData))
                TriggerClientEvent("receivePlayerInfo", playerId, playerInfo)

            else
                print("Error: Invalid player ID.")
            end
        else
            print("Error: Please specify a player ID.")
        end
    else
        print("This command cannot be executed from the server console.")
    end
end, true)


function GetPlayerInfo(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    local playerInfo = {
        license = nil,
        fivem_id = playerId,
        discord = nil,
        steam = nil
    }

    -- Parcourir les identifiants du joueur
    for _, id in ipairs(identifiers) do
        if id:find("license:") then
            playerInfo.license = id
        elseif id:find("discord:") then
            playerInfo.discord = id:gsub("discord:", "")  -- Supprime le préfixe "discord:"
        elseif id:find("steam:") then
            playerInfo.steam = id:gsub("steam:", "")      -- Supprime le préfixe "steam:"
        end
    end

    -- Debug: Affichage des informations du joueur récupérées
    print("Debug: Informations pour le joueur ID " .. playerId)
    print(" - License: " .. tostring(playerInfo.license))
    print(" - Discord ID: " .. tostring(playerInfo.discord))
    print(" - Steam ID: " .. tostring(playerInfo.steam))
    print(" - FiveM ID: " .. tostring(playerInfo.fivem_id))

    return playerInfo
end


StartPeriodicSave()
