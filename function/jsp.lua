-- init.lua

RPZ = {}
RPZ.RF = {
    Spawned = false,
    Source = nil,
    License = nil,
    Job = {},
    Org = {},
    Group = nil,
    Account = {},
    Inv = {},
    Weight = 40.0,
    Name = nil,
    Token = nil
}

RF = {
    Health = 100,
    Hunger = 100,
    Thirst = 100,
    Death = false
}

local function sendNuiInitializationMessage()
    SendNUIMessage({
        first = true,
        money = RPZ.RF.Account.money,
        dirty = RPZ.RF.Account.black,
        bank = RPZ.RF.Account.bank,
        job = (RPZ.RF.Job.name or "N/A") .. " - " .. (RPZ.RF.Job.label or "No Label"),
        job2 = (RPZ.RF.Org.name or "N/A") .. " - " .. (RPZ.RF.Org.label or "No Label")
    })
end

local function initializePlayer(object)
    DoScreenFadeOut(2000)
    Wait(2000)
    DoScreenFadeIn(1000)
    SetEntityCoordsNoOffset(PlayerPedId(), object.position.x, object.position.y, object.position.z, 0, 0, 0)
    RPZ.RF.Source = object.source
    RPZ.RF.License = object.License
    RPZ.RF.Group = object.group
    RPZ.RF.Account = {money = object.account.money, bank = object.account.bank, black = object.account.black}
    RPZ.RF.Inv = object.inventory
    RPZ.RF.Weight = object.weight
    RPZ.RF.Spawned = true
    RPZ.RF.Token = object.token
    RPZ.RF.Job = {name = object.job.job, grade = object.job.grade, label = object.job.grade_label, boss = object.job.boss}
    RPZ.RF.Org = {name = object.org.org, grade = object.org.grade, label = object.org.grade_label, boss = object.org.boss}
    sendNuiInitializationMessage()
    if not RF.Death then
        NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, false) 
    end
end

RegisterNetEvent("Initialisation:Client")
AddEventHandler("Initialisation:Client", initializePlayer)

local function validateJobObject(object)
    return object.job and object.grade and object.grade_label and object.boss
end

local function validateOrgObject(object)
    return object.org and object.grade and object.grade_label and object.boss
end

RegisterNetEvent("rpzFramework:handlerjob")
AddEventHandler("rpzFramework:handlerjob", function(type, object)
    if type == "job" then
        if validateJobObject(object) then
            RPZ.RF.Job.name = object.job
            RPZ.RF.Job.grade = object.grade
            RPZ.RF.Job.label = object.grade_label
            RPZ.RF.Job.boss = object.boss
        else
            print("Erreur: Objet 'job' incomplet.")
        end
    elseif type == "job2" then
        if validateOrgObject(object) then
            RPZ.RF.Org.name = object.org
            RPZ.RF.Org.grade = object.grade
            RPZ.RF.Org.label = object.grade_label
            RPZ.RF.Org.boss = object.boss
        else
            print("Erreur: Objet 'job2' incomplet.")
        end
    end
end)

local function logEvent(eventType, details)
    print(string.format("[%s] %s: %s", os.date("%Y-%m-%d %H:%M:%S"), eventType, details))
end

RegisterNetEvent("rpzFramework:handlermoney")
AddEventHandler("rpzFramework:handlermoney", function(object, type, amount)
    SendNUIMessage({
        addmoney = true,
        type = type,
        count = amount,
    })
    RPZ.RF.Account = {money = object.money, bank = object.bank, black = object.black}
    logEvent("MoneyUpdate", string.format("Type: %s, Amount: %d", type, amount))
end)

RegisterNetEvent("rpzFramework:handlerInv")
AddEventHandler("rpzFramework:handlerInv", function(inv, weight)
    RPZ.RF.Inv = inv
    RPZ.RF.Weight = weight
end)

RegisterNetEvent("rpzFramework:TokenRecup")
AddEventHandler("rpzFramework:TokenRecup", function(cb)
    CreateThread(function() 
        while RPZ.RF.Token == nil do 
            Wait(10)
        end 
        cb(RPZ.RF.Token)
    end)
end)

RegisterCommand("info", function()
    print("Money: " .. (RPZ.RF.Account.money or "N/A"))
    print("Bank: " .. (RPZ.RF.Account.bank or "N/A"))
    print("Dirty: " .. (RPZ.RF.Account.black or "N/A"))
    print("Weight: " .. (RPZ.RF.Weight or "N/A") .. "/40")
    print("Job: " .. (RPZ.RF.Job.label or "No Label") .. " - Grade: " .. (RPZ.RF.Job.grade or "No Grade"))
    print("Org: " .. (RPZ.RF.Org.label or "No Label") .. " - Grade: " .. (RPZ.RF.Org.grade or "No Grade"))
    print(" -----------     Inventaire     -----------")
    -- Ensure RPZ.RF.Inv is not nil before attempting to encode it.
    if RPZ.RF.Inv then
        print(json.encode(RPZ.RF.Inv))
    else
        print("No Inventory")
    end
end)
