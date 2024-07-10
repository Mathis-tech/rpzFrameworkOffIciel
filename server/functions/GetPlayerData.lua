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
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    return {x = coords.x, y = coords.y, z = coords.z, heading = heading}
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