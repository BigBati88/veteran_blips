local ESX = exports['es_extended']:getSharedObject()

local function getVehicle(model)
    for _, category in ipairs(Config.Categories) do
        for _, vehicle in ipairs(category.vehicles) do
            if vehicle.model == model then return vehicle end
        end
    end
end

local function isAtDealer(xPlayer)
    local coords = xPlayer.getCoords(true)
    return coords and #(coords - Config.Dealer.coords) <= Config.Dealer.returnRadius
end

local function generatePlate()
    return ('%s%03d'):format(string.char(math.random(65, 90), math.random(65, 90)), math.random(0, 999))
end

RegisterNetEvent('veteran_dealer:server:buyVehicle', function(model)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicle = type(model) == 'string' and getVehicle(model) or nil
    if not xPlayer or not vehicle or not isAtDealer(xPlayer) then return end

    local bank = xPlayer.getAccount('bank')
    if not bank or bank.money < vehicle.price then
        TriggerClientEvent('veteran_dealer:client:notify', source, 'Nincs eleg penz a bankszamladon.')
        return
    end

    local plate = generatePlate()
    local vehicleProps = json.encode({ model = joaat(vehicle.model), plate = plate })
    local inserted = MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
        xPlayer.identifier, plate, vehicleProps
    })

    if not inserted then
        TriggerClientEvent('veteran_dealer:client:notify', source, 'A vasarlas sikertelen volt. Probald ujra.')
        return
    end

    xPlayer.removeAccountMoney('bank', vehicle.price, 'Autovasarlas')
    TriggerClientEvent('veteran_dealer:client:purchaseApproved', source, vehicle.model, vehicle.label, plate, vehicle.price)
end)
