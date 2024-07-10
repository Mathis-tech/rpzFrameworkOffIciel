function TakeDamage(amount)
    RPZ.RF.Health = RPZ.RF.Health - amount
    if RPZ.RF.Health <= 0 then
        Die()
    end
end

function Die()
    -- Afficher un message, jouer un son, etc.
    print("L'utilisateur est mort.")
    -- Réinitialiser la santé ou respawn l'utilisateur
    -- Ici, vous pouvez également appeler NetworkResurrectLocalPlayer pour respawn l'utilisateur
end