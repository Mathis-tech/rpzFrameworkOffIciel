local cleanTableModule = {}

function cleanTableModule.cleanTable(tbl)
    for key, value in pairs(tbl) do
        if type(value) == 'string' then
            tbl[key] = value:gsub('[%c%z]', '')
        elseif type(value) == 'table' then
            local success, errMsg = pcall(cleanTable, value)
            if not success then
                print("Erreur lors du nettoyage de la table : " .. errMsg)
                -- Vous pouvez choisir de supprimer la clé ou de laisser la valeur intacte selon vos besoins de sécurité
                tbl[key] = nil  
            end
        elseif type(value) == 'number' then
            if value ~= value or value == math.huge or value == -math.huge then
                tbl[key] = nil
            end
        end
    end
end
return cleanTableModule