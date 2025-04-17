function RPZ.Streaming.RequestAnimDict(animDict, cb)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)

        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end

    if cb ~= nil then
        cb()
    end
end