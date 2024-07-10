TriggerServerCallback('getPlayerData', function(data)
    if data then
        print("Player Name: " .. data.name)
        print("Money: " .. data.money)
        print("Job: " .. data.job)
    else
        print("Player not found")
    end
end, GetPlayerServerId(PlayerId()))