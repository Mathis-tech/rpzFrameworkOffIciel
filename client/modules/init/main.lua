RPZ = RPZ or {}

-- Initialisation des sous-modules ou fonctionnalités
RPZ.PlayerData = {}
RPZ.Game = {}
RPZ.Utils = {}

-- Exemple de fonction dans RPZ
function RPZ.ShowNotification(message)
    -- Code pour afficher une notification
    print("[RPZ Notification] " .. message)
end

function GetRPZ()
    return RPZ
end

exports('GetRPZ', GetRPZ)