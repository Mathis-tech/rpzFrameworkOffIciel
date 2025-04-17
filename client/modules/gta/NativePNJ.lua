local Player = PlayerId()

-- Initialiser les paramètres pour ignorer le joueur
SetPoliceIgnorePlayer(Player, true)
SetEveryoneIgnorePlayer(Player, true)
SetPlayerCanBeHassledByGangs(Player, false)
SetIgnoreLowPriorityShockingEvents(Player, true)

-- Fonction optimisée pour appliquer les paramètres passifs aux PNJ
Citizen.CreateThread(function()
    while true do
        -- Récupérer tous les PNJ seulement une fois toutes les 500 ms
        local peds = GetAllPeds()
        for _, pedNpc in ipairs(peds) do
            -- Appliquer les paramètres une seule fois par PNJ si possible
            SetBlockingOfNonTemporaryEvents(pedNpc, true)
            SetPedFleeAttributes(pedNpc, 0, 0)
            SetPedCombatAttributes(pedNpc, 17, true)

            -- Si l'alerte n'est pas à zéro, la réinitialiser
            if GetPedAlertness(pedNpc) ~= 0 then
                SetPedAlertness(pedNpc, 0)
            end
        end
        Citizen.Wait(500)  -- Vérification toutes les 500 ms pour économiser les ressources
    end
end)

-- Fonction pour énumérer les entités avec un coroutine (pas besoin de changer ici)
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
      
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
      
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
      
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

-- Fonction d'énumération des PNJ (pas besoin de changer ici)
function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

-- Fonction pour récupérer tous les PNJ humains (exclut les joueurs)
function GetAllPeds()
    local peds = {}
    for ped in EnumeratePeds() do
        if DoesEntityExist(ped) and not IsEntityDead(ped) and IsEntityAPed(ped) and IsPedHuman(ped) and not IsPedAPlayer(ped) then
            table.insert(peds, ped)
        end
    end
    return peds
end
