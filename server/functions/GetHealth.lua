function GetPlayerHealth(playerId)
    local ped = GetPlayerPed(playerId)
    return GetEntityHealth(ped)
end