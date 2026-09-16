local ESX = exports['es_extended']:getSharedObject()
local activeRentals = {}

local function isNearLocation(xPlayer, location, radius)
    local playerCoords = xPlayer.getCoords(true)
    return playerCoords and #(playerCoords - location.coords) <= radius
end

local function getAccountMoney(xPlayer)
    if Config.PaymentAccount == 'money' then return xPlayer.getMoney() end
    local account = xPlayer.getAccount(Config.PaymentAccount)
    return account and account.money or 0
end

local function removeMoney(xPlayer, amount, reason)
    if Config.PaymentAccount == 'money' then xPlayer.removeMoney(amount, reason)
    else xPlayer.removeAccountMoney(Config.PaymentAccount, amount, reason) end
end

local function addMoney(xPlayer, amount, reason)
    if Config.PaymentAccount == 'money' then xPlayer.addMoney(amount, reason)
    else xPlayer.addAccountMoney(Config.PaymentAccount, amount, reason) end
end

RegisterNetEvent('veteran_roller:server:rent', function(locationId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local location = Config.Locations[tonumber(locationId)]
    if not xPlayer or not location then return end
    if not isNearLocation(xPlayer, location, 5.0) then return end
    if activeRentals[source] then
        TriggerClientEvent('veteran_roller:client:notify', source, 'Mar van aktiv roller berlesed.')
        return
    end

    local total = Config.Price + Config.Deposit
    if getAccountMoney(xPlayer) < total then
        TriggerClientEvent('veteran_roller:client:notify', source, ('Nincs eleg penzed. Szükséges: $%s'):format(total))
        return
    end

    removeMoney(xPlayer, total, 'Roller berles')
    activeRentals[source] = { deposit = Config.Deposit, vehicleNetId = nil }
    TriggerClientEvent('veteran_roller:client:spawnRental', source, tonumber(locationId))
end)

RegisterNetEvent('veteran_roller:server:setVehicle', function(vehicleNetId)
    local rental = activeRentals[source]
    if rental and type(vehicleNetId) == 'number' then rental.vehicleNetId = vehicleNetId end
end)

RegisterNetEvent('veteran_roller:server:cancelRental', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local rental = activeRentals[source]
    if not xPlayer or not rental then return end

    addMoney(xPlayer, Config.Price + rental.deposit, 'Sikertelen roller berles visszaterites')
    activeRentals[source] = nil
end)

RegisterNetEvent('veteran_roller:server:return', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local rental = activeRentals[source]
    if not xPlayer or not rental then
        TriggerClientEvent('veteran_roller:client:notify', source, 'Nincs visszavalthato roller berlesed.')
        return
    end
    local isAtRentalPoint = false
    for _, location in ipairs(Config.Locations) do
        if isNearLocation(xPlayer, location, 15.0) then
            isAtRentalPoint = true
            break
        end
    end
    if not isAtRentalPoint then return end

    addMoney(xPlayer, rental.deposit, 'Roller kaució visszaterites')
    activeRentals[source] = nil
    TriggerClientEvent('veteran_roller:client:rentalReturned', source, rental.deposit)
end)

AddEventHandler('playerDropped', function()
    -- Kilepeskor a kaució nem jar vissza.
    activeRentals[source] = nil
end)
