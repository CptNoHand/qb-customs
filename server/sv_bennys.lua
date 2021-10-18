local QBCore = exports['qb-core']:GetCoreObject()

local chicken = vehicleBaseRepairCost

RegisterNetEvent('qb-customs:attemptPurchase', function(type, upgradeLevel)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local balance = nil
    if Player.PlayerData.job.name == "bennys" then
        balance = exports['qb-bossmenu']:GetAccount(Player.PlayerData.job.name)
    else
        balance = Player.Functions.GetMoney(moneyType)
    end
    if type == "repair" then
        if balance >= chicken then
            if Player.PlayerData.job.name == "bennys" then
                TriggerEvent('qb-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name, chicken)
            else
                Player.Functions.RemoveMoney(moneyType, chicken, "bennys")
            end
            TriggerClientEvent('qb-customs:purchaseSuccessful', source)
        else
            TriggerClientEvent('qb-customs:purchaseFailed', source)
        end
    elseif type == "performance" then
        if balance >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('qb-customs:purchaseSuccessful', source)
            if Player.PlayerData.job.name == "bennys" then
                TriggerEvent('qb-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name,
                    vehicleCustomisationPrices[type].prices[upgradeLevel])
            else
                Player.Functions.RemoveMoney(moneyType, vehicleCustomisationPrices[type].prices[upgradeLevel], "bennys")
            end
        else
            TriggerClientEvent('qb-customs:purchaseFailed', source)
        end
    else
        if balance >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('qb-customs:purchaseSuccessful', source)
            if Player.PlayerData.job.name == "bennys" then
                TriggerEvent('qb-bossmenu:server:removeAccountMoney', Player.PlayerData.job.name,
                    vehicleCustomisationPrices[type].price)
            else
                Player.Functions.RemoveMoney(moneyType, vehicleCustomisationPrices[type].price, "bennys")
            end
        else
            TriggerClientEvent('qb-customs:purchaseFailed', source)
        end
    end
end)

RegisterNetEvent('qb-customs:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterNetEvent("updateVehicle", function(myCar)
    local src = source
    if IsVehicleOwned(myCar.plate) then
        exports.oxmysql:execute('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(myCar), myCar.plate})
    end
end)

function IsVehicleOwned(plate)
    local retval = false
    local result = exports.oxmysql:scalarSync('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        retval = true
    end
    return retval
end

QBCore.Commands.Add("setbennys", "Give Someone The Bennys Job", {{
    name = "id",
    help = "ID Of The Player"
}}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if IsAuthorized(Player.PlayerData.citizenid) then
        local TargetId = tonumber(args[1])
        if TargetId ~= nil then
            local TargetData = QBCore.Functions.GetPlayer(TargetId)
            if TargetData ~= nil then
                TargetData.Functions.SetJob("mechanic")
                TriggerClientEvent('QBCore:Notify', TargetData.PlayerData.source,
                    "You Were Hired As An Bennys Employee!")
                TriggerClientEvent('QBCore:Notify', source, "You have (" .. TargetData.PlayerData.charinfo.firstname ..
                    ") Hired As An Bennys Employee!")
            end
        else
            TriggerClientEvent('QBCore:Notify', source, "You Must Provide A Player ID!")
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "You Cannot Do This!", "error")
    end
end)

QBCore.Commands.Add("firebennys", "Fire A Benny Employee", {{
    name = "id",
    help = "ID Of The Player"
}}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if IsAuthorized(Player.PlayerData.citizenid) then
        local TargetId = tonumber(args[1])
        if TargetId ~= nil then
            local TargetData = QBCore.Functions.GetPlayer(TargetId)
            if TargetData ~= nil then
                if TargetData.PlayerData.job.name == "bennys" then
                    TargetData.Functions.SetJob("unemployed")
                    TriggerClientEvent('QBCore:Notify', TargetData.PlayerData.source,
                        "You Were Fired From Bennys!")
                    TriggerClientEvent('QBCore:Notify', source,
                        "You have (" .. TargetData.PlayerData.charinfo.firstname .. ") Fired From Bennys!")
                else
                    TriggerClientEvent('QBCore:Notify', source, "Youre Not An Employee of Bennys!", "error")
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', source, "You Must Provide A Player ID!", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "You Cannot Do This!", "error")
    end
end)