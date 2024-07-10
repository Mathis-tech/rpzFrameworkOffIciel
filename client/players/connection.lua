

AddEventHandler('playerSpawned', function()
    local playerPed = GetPlayerPed(-1)
    SetEntityCoords(playerPed, RPZ.ConfigGlobal.spawnPrincipal.X, RPZ.ConfigGlobal.spawnPrincipal.Y, RPZ.ConfigGlobal.spawnPrincipal.Z, false, false, false, true)
    print("Le joueur est apparu sur le serveur.")
end)
