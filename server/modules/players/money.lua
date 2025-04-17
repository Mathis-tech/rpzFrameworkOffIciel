-- Exemple de fonctions à implémenter selon votre base de données ou gestion du serveur
function GetPlayerMoney(xPlayer)
    local playerId = xPlayer.getIdentifier()
    local playerMoney = { cash = 0, bank = 0 }

    MySQL.Async.fetchAll("SELECT cash, bank FROM rpz_players WHERE identifier = @identifier", {
        ['@identifier'] = playerId
    }, function(results)
        if results[1] then
            playerMoney.cash = results[1].cash
            playerMoney.bank = results[1].bank
        end
    end)

    return playerMoney
end



function GetPlayerMoney(xPlayer)
    if not hasPermission(xPlayer, "money.view") then
        error("Permission denied")
        return
    end

    local playerId = xPlayer.getIdentifier()
    local playerMoney = { cash = 0, bank = 0 }

    MySQL.Async.fetchAll("SELECT cash, bank FROM rpz_players WHERE identifier = @identifier", {
        ['@identifier'] = playerId
    }, function(results)
        if results[1] then
            playerMoney.cash = results[1].cash
            playerMoney.bank = results[1].bank
        end
    end)

    return playerMoney
end

function RemoveMoney(xPlayer, amount)
    if not ValidateAmount(amount) or not hasPermission(xPlayer, "money.remove") then
        error("Invalid operation")
        return
    end

    local playerId = xPlayer.getIdentifier()
    MySQL.Async.execute("UPDATE rpz_players SET cash = cash - @amount WHERE identifier = @identifier AND cash >= @amount", {
        ['@amount'] = amount,
        ['@identifier'] = playerId
    })
end

function AddMoney(xPlayer, amount)
    if not ValidateAmount(amount) or not hasPermission(xPlayer, "money.add") then
        error("Invalid operation")
        return
    end

    local playerId = xPlayer.getIdentifier()
    MySQL.Async.execute("UPDATE rpz_players SET cash = cash + @amount WHERE identifier = @identifier", {
        ['@amount'] = amount,
        ['@identifier'] = playerId
    })
end

function TransferMoney(fromPlayer, toPlayer, amount)
    if not ValidateAmount(amount) or not hasPermission(fromPlayer, "money.transfer") then
        error("Invalid operation")
        return
    end

    local fromId = fromPlayer.getIdentifier()
    local toId = toPlayer.getIdentifier()

    -- Utilisation de transactions pour garantir l'atomicité
    MySQL.Async.execute("UPDATE rpz_players SET cash = cash - @amount WHERE identifier = @identifier AND cash >= @amount", {
        ['@amount'] = amount,
        ['@identifier'] = fromId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            MySQL.Async.execute("UPDATE rpz_players SET cash = cash + @amount WHERE identifier = @identifier", {
                ['@amount'] = amount,
                ['@identifier'] = toId
            })
        else
            print("Transaction échouée : fonds insuffisants.")
        end
    end)
end

-- Fonction auxiliaire pour vérifier les permissions
function hasPermission(xPlayer, perm)

end