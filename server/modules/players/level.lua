--  function GetPlayerIdentifier(source)
--      local identifiers = GetPlayerIdentifiers(source)
--      for _, id in ipairs(identifiers) do
--          print("Checking identifier: " .. id)  -- Débogage de chaque identifiant
--          if string.match(id, "license:") then
--              print("Fivem license found: " .. id)  -- Débogage lorsque la licence est trouvée
--              return id
--          end
--      end
--      print("No valid license identifier found for source: " .. source)  -- Débogage si aucun identifiant valide n'est trouvé
--      return nil
--  end



-- function AddPlayerXP(source, xpAmount)
--     local identifier = GetPlayerIdentifier(source)
--     if identifier then  -- S'assure que l'identifiant n'est pas nil
--         GetPlayerUID(identifier, function(uid)
--             if uid then
--                 print("Adding XP: UID=" .. uid .. ", XP Amount=" .. tostring(xpAmount))
--                 MySQL.Async.fetchAll("SELECT xp, level FROM rpz_players WHERE uid = @uid", {
--                     ['@uid'] = uid
--                 }, function(results)
--                     if results and results[1] then
--                         local currentXP = results[1].xp + xpAmount
--                         local currentLevel = results[1].level
--                         local nextLevelXP = RPZ.Levels[currentLevel] and RPZ.Levels[currentLevel].xpRequired or nil
--                         print("Current Level: " .. currentLevel .. ", Current XP: " .. currentXP)

--                         if nextLevelXP and currentXP >= nextLevelXP then
--                             currentLevel = currentLevel + 1
--                             currentXP = currentXP - nextLevelXP
--                             print("Level Up! New Level: " .. currentLevel .. ", Reset XP: " .. currentXP)
--                         end

--                         MySQL.Async.execute("UPDATE rpz_players SET xp = @xp, level = @level WHERE uid = @uid", {
--                             ['@xp'] = currentXP,
--                             ['@level'] = currentLevel,
--                             ['@uid'] = uid
--                         })
--                     else
--                         print("No XP data found for UID: " .. uid)
--                     end
--                 end)
--             else
--                 print("UID not found for identifier: " .. identifier)
--             end
--         end)
--     else
--         print("Identifier not found for player.")  -- Imprime une erreur si aucun identifiant n'est trouvé
--     end
-- end


-- function RemovePlayerXP(source, xpAmount)
--     AddPlayerXP(source, -xpAmount)
-- end

-- function IsValidXPAmount(xpAmount)
--     return type(xpAmount) == "number" and xpAmount ~= 0
-- end

-- RegisterCommand("addxp", function(source, args, rawCommand)
--     local targetId = tonumber(args[1])
--     local xpToAdd = tonumber(args[2])
--     print("Received command from source: " .. tostring(source) .. " to add XP to targetId: " .. tostring(targetId) .. " with xpToAdd: " .. tostring(xpToAdd))

--     if targetId and IsValidXPAmount(xpToAdd) then
--         local targetPlayer = GetPlayerPed(targetId)
--         if targetPlayer ~= 0 then
--             local identifier = GetPlayerIdentifier(targetPlayer)
--             if identifier then
--                 GetPlayerUID(identifier, function(uid)
--                     if uid then
--                         AddPlayerXP(targetPlayer, xpToAdd)
--                         TriggerClientEvent('chat:addMessage', targetId, {
--                             color = {255, 0, 0},
--                             args = {"Server", "Vous avez ajouté " .. xpToAdd .. " XP"}
--                         })
--                     else
--                         print("Joueur UID non trouvé pour l'ID donné.")
--                     end
--                 end)
--             else
--                 print("No valid identifier found for the given player ID.")
--             end
--         else
--             print("Invalid player ped for the given target ID.")
--         end
--     else
--         print("Invalid command usage or parameters.")
--     end
-- end, false)
