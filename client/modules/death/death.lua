local pedModel = "mp_m_freemode_01"
local bodyParts = {
    head = 31086, neck = 39317, spine = 24816, pelvis = 11816, left_arm = 61163, right_arm = 10706,
    left_hand = 18905, right_hand = 57005, left_leg = 58271, right_leg = 51826, left_foot = 14201, right_foot = 52301
}

local deathDelayMap = {
    ["accident"] = {delay = 30000, details = "You died in an accident."},
    ["action_adverse"] = {delay = 60000, details = "You died due to adverse actions."},
    -- Add other causes of death here with their delays and detailed messages
}

-- Function to check if a ped is of the specified model
local function isTargetPedModel(ped, model)
    return GetEntityModel(ped) == GetHashKey(model)
end

-- Function to get damaged body parts of the specified ped
local function GetDamagedBodyParts(ped)
    local damagedParts = {}
    for part, boneId in pairs(bodyParts) do
        if HasEntityBeenDamagedByAnyObject(ped) or HasEntityBeenDamagedByAnyPed(ped) then
            local isDamaged = IsPedDamaged(ped, boneId)
            damagedParts[part] = isDamaged
        end
    end
    return damagedParts
end

-- Function to check if a specific body part is damaged
function IsPedDamaged(ped, boneId)
    local hit, damage = GetPedLastDamageBone(ped)
    return hit and damage == boneId
end

-- Event to handle damage detection and reporting
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        if isTargetPedModel(ped, pedModel) then
            local damagedParts = GetDamagedBodyParts(ped)
            TriggerServerEvent('RegisterDamage', damagedParts)
        end
    end
end)

-- Function to get player death coordinates
local function getPlayerDeathCoords()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    return { x = coords.x, y = coords.y, z = coords.z }
end

-- Handle player death on the client side
AddEventHandler('baseevents:onPlayerDied', function(killerType, deathCoords)
    local playerId = GetPlayerServerId(PlayerId())
    local deathCoords = getPlayerDeathCoords()
    TriggerServerEvent('playerDied', playerId, killerType, deathCoords)
end)

-- Handle player killed by another player on the client side
AddEventHandler('baseevents:onPlayerKilled', function(killerId, deathData)
    local playerId = GetPlayerServerId(PlayerId())
    local deathCoords = getPlayerDeathCoords()
    TriggerServerEvent('playerKilled', playerId, killerId, deathData, deathCoords)
end)

-- Handle displaying the death message and respawning
RegisterNetEvent('rpz:showDeathMessage')
AddEventHandler('rpz:showDeathMessage', function(deathCause, delay)
    local deathInfo = deathDelayMap[deathCause]
    if deathInfo then
        -- Display death message
        SetNotificationTextEntry("STRING")
        AddTextComponentString(deathInfo.details)
        DrawNotification(false, true)

        -- Respawn after delay
        Citizen.CreateThread(function()
            Citizen.Wait(delay)
            local playerPed = PlayerPedId()
            local respawnCoords = vector3(0, 0, 72) -- Replace with actual respawn coordinates
            SetEntityCoords(playerPed, respawnCoords.x, respawnCoords.y, respawnCoords.z, false, false, false, true)
            NetworkResurrectLocalPlayer(respawnCoords, GetEntityHeading(playerPed), true, false)
        end)
    else
        print("Error: Invalid deathCause provided.")
    end
end)
