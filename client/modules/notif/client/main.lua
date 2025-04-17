RegisterCommand('testnotify', function(source, args)
    local title = args[1] or 'Titre par défaut'
    local subtitle = args[2] or 'Sous-titre par défaut'
    local text = args[3] or 'Texte par défaut'

    TriggerEvent('notification:show', title, subtitle, text)
end, false) -- false pour que cette commande soit accessible à tous les joueurs


AddEventHandler('notification:show', function(title, subtitle, text)
    SendNUIMessage({
        title = title,
        subtitle = subtitle,
        text = text
    })
end)
