-- server.lua

local deathDelayMap = {
    ["accident"] = {delay = 30000, details = "You died in an accident."},
    ["action_adverse"] = {delay = 60000, details = "You died due to adverse actions."},
    -- Add other causes of death here with their delays and detailed messages
}

local pedBodyParts = {
    head = "Head",
    neck = "Neck",
    spine = "Spine",
    pelvis = "Pelvis",
    left_arm = "Left Arm",
    right_arm = "Right Arm",
    left_hand = "Left Hand",
    right_hand = "Right Hand",
    left_leg = "Left Leg",
    right_leg = "Right Leg",
    left_foot = "Left Foot",
    right_foot = "Right Foot"
}

local playerDamageData = {}

-- Function to print detailed death information
local function printDeathDetails(deathCause)
    local deathInfo = deathDelayMap[deathCause]
    if deathInfo then
        print(deathInfo.details)
    else
        print("Unknown cause of death: ", deathCause)
    end
end

-- Function to update the player's death status in the database
local function updatePlayerDeathStatus(playerId, isDead)
    local deathStatus = isDead and 1 or 0
    local query = "UPDATE rpz_players SET death = ? WHERE id = ?"
    MySQL.Async.execute(query, {deathStatus, playerId}, function(affectedRows)
        if affectedRows > 0 then
            print(string.format("Player %d death status updated to %d", playerId, deathStatus))
        else
            print(string.format("Failed to update death status for player %d", playerId))
        end
    end)
end

local function checkAndUpdatePlayerDeathStatus(playerId, isDead)
    local deathStatus = isDead and 1 or 0
    local checkQuery = "SELECT id FROM rpz_players WHERE id = ?"
    
    MySQL.Async.fetchAll(checkQuery, {playerId}, function(result)
        if result and #result > 0 then
            local updateQuery = "UPDATE rpz_players SET death = ? WHERE id = ?"
            
            -- Debugging: Print the query and parameters
            print("Executing query: ", updateQuery)
            print("Parameters: ", deathStatus, playerId)
            
            MySQL.Async.execute(updateQuery, {deathStatus, playerId}, function(affectedRows)
                -- Debugging: Print the number of affected rows
                print("Affected Rows: ", affectedRows)
                
                if affectedRows > 0 then
                    print(string.format("Player %d death status updated to %d", playerId, deathStatus))
                else
                    print(string.format("Failed to update death status for player %d", playerId))
                end
            end)
        else
            print(string.format("Player %d does not exist in rpz_players", playerId))
        end
    end)
end


-- Function to check the player's death status from the database
local function checkPlayerDeathStatus(playerId, callback)
    local query = "SELECT death FROM rpz_players WHERE id = ?"
    MySQL.Async.fetchAll(query, {playerId}, function(result)
        if result and result[1] then
            callback(result[1].death == 1)
        else
            callback(false)
        end
    end)
end

-- Function called when the player dies
function OnPlayerDeath(deathCause, victimPlayer)
    print("OnPlayerDeath called with cause:", deathCause, "and player ID:", victimPlayer)
    local deathInfo = deathDelayMap[deathCause]

    if deathInfo then
        printDeathDetails(deathCause)
        checkAndUpdatePlayerDeathStatus(victimPlayer, true)  -- Updated function call
        TriggerClientEvent('rpz:showDeathMessage', victimPlayer, deathCause, deathInfo.delay)

        local damagedParts = GetPlayerDamageData(victimPlayer)
        if damagedParts then
            for part, isDamaged in pairs(damagedParts) do
                if isDamaged then
                    print(string.format("Player %d had damage on: %s", victimPlayer, pedBodyParts[part]))
                end
            end
        end
    else
        print("Unknown cause of death: ", deathCause)
    end
end

-- Function to be used in other scripts to check if the player is dead
function IsPlayerDead(playerId, callback)
    checkPlayerDeathStatus(playerId, callback)
end

-- Handle the event when a player dies
RegisterServerEvent('playerDied')
AddEventHandler('playerDied', function(playerId, killerType, deathCoords)
    if deathCoords and deathCoords.x and deathCoords.y and deathCoords.z then
        print(string.format("Player %d has died. Death coordinates: x=%.2f, y=%.2f, z=%.2f", playerId, deathCoords.x, deathCoords.y, deathCoords.z))
        OnPlayerDeath("accident", playerId)
    else
        print("Error: Invalid deathCoords received from client.")
    end
end)

-- Handle the event when a player is killed by another player
RegisterServerEvent('playerKilled')
AddEventHandler('playerKilled', function(playerId, killerId, deathData, deathCoords)
    local killerName = GetPlayerName(killerId)
    local victimName = GetPlayerName(playerId)
    local weaponHash = deathData.weaponHash
    local weaponName = GetWeaponNameFromHash(weaponHash)

    if deathCoords and deathCoords.x and deathCoords.y and deathCoords.z then
        print(string.format("Player %s (ID: %d) was killed by %s (ID: %d) with weapon: %s. Death coordinates: x=%.2f, y=%.2f, z=%.2f",
            victimName, playerId, killerName, killerId, weaponName,
            deathCoords.x, deathCoords.y, deathCoords.z))
        OnPlayerDeath("action_adverse", playerId)
    else
        print("Error: Invalid deathCoords received from client.")
    end
end)

-- Custom function to get weapon name from weapon hash
function GetWeaponNameFromHash(hash)
    local weapons = {
        [-1716189206] = "Knife",
        [1737195953] = "Nightstick",
        [1317494643] = "Hammer",
        -- Add other weapon hashes and their corresponding names here
    }

    return weapons[hash] or "Unknown Weapon"
end

-- Event to register damage data sent from the client
RegisterNetEvent('RegisterDamage')
AddEventHandler('RegisterDamage', function(damagedParts)
    local playerId = source
    if not playerDamageData[playerId] then
        playerDamageData[playerId] = {}
    end
    for part, isDamaged in pairs(damagedParts) do
        playerDamageData[playerId][part] = isDamaged
    end
    print("Updated damage data for player " .. playerId)
end)

-- Function to get damage data for a specific player
function GetPlayerDamageData(playerId)
    return playerDamageData[playerId] or {}
end
