local ESX = exports['es_extended']:getSharedObject()
local menuOpen = false
local testVehicle = nil
local testEndsAt = nil

local function isCatalogVehicle(model)
    for _, category in ipairs(Config.Categories) do
        for _, vehicle in ipairs(category.vehicles) do
            if vehicle.model == model then return true end
        end
    end
    return false
end

local function notify(message)
    ESX.ShowNotification(message)
end

local function loadModel(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then return nil end
    RequestModel(hash)
    local deadline = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do Wait(10) end
    return HasModelLoaded(hash) and hash or nil
end

local function deleteTestVehicle()
    if testVehicle and DoesEntityExist(testVehicle) then
        DeleteVehicle(testVehicle)
    end
    testVehicle = nil
    testEndsAt = nil
end

local function closeMenu()
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openMenu()
    if menuOpen or testVehicle then return end
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', categories = Config.Categories, testSeconds = Config.TestDriveSeconds })
end

local function spawnVehicle(model, spawn, plate)
    local hash = loadModel(model)
    if not hash then return nil end
    if IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 3.0) then
        SetModelAsNoLongerNeeded(hash)
        return nil
    end

    local vehicle = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleNumberPlateText(vehicle, plate)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetModelAsNoLongerNeeded(hash)
    return vehicle
end

RegisterNUICallback('close', function(_, callback)
    closeMenu()
    callback({ ok = true })
end)

RegisterNUICallback('testDrive', function(data, callback)
    closeMenu()
    if type(data.model) ~= 'string' or not isCatalogVehicle(data.model) then
        callback({ ok = false })
        return
    end
    local vehicle = spawnVehicle(data.model, Config.Dealer.testSpawn, Config.TestPlatePrefix .. math.random(100, 999))
    if not vehicle then
        notify('A tesztauto helye foglalt vagy a modell nem elerheto.')
        callback({ ok = false })
        return
    end

    testVehicle = vehicle
    testEndsAt = GetGameTimer() + (Config.TestDriveSeconds * 1000)
    TaskWarpPedIntoVehicle(PlayerPedId(), testVehicle, -1)
    notify(('Tesztvezetes elindult: %s masodperced van.'):format(Config.TestDriveSeconds))
    callback({ ok = true })
end)

RegisterNUICallback('buyVehicle', function(data, callback)
    closeMenu()
    TriggerServerEvent('veteran_dealer:server:buyVehicle', data.model)
    callback({ ok = true })
end)

RegisterNetEvent('veteran_dealer:client:notify', notify)

RegisterNetEvent('veteran_dealer:client:purchaseApproved', function(model, label, plate, price)
    local vehicle = spawnVehicle(model, Config.Dealer.purchaseSpawn, plate)
    if not vehicle then
        notify(('A %s megvasarolva ($%s), de a kiadohely foglalt. A jarmu a garazsodban van.'):format(label, price))
        return
    end
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    notify(('%s megvasarolva $%s ertekben.'):format(label, price))
end)

CreateThread(function()
    local blip = AddBlipForCoord(Config.Dealer.coords.x, Config.Dealer.coords.y, Config.Dealer.coords.z)
    SetBlipSprite(blip, Config.Dealer.blip.sprite)
    SetBlipColour(blip, Config.Dealer.blip.color)
    SetBlipScale(blip, Config.Dealer.blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Dealer.label)
    EndTextCommandSetBlipName(blip)
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local distance = #(GetEntityCoords(PlayerPedId()) - Config.Dealer.coords)
        if distance < Config.Dealer.drawDistance then
            sleep = 0
            DrawMarker(1, Config.Dealer.coords.x, Config.Dealer.coords.y, Config.Dealer.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.15, 1.15, 0.35, 0, 170, 255, 160, false, false, 2, false, nil, nil, false)
            if distance < Config.Dealer.interactionDistance and not testVehicle then
                ESX.ShowHelpNotification('Nyomd meg az ~INPUT_CONTEXT~ gombot az autokereskedes megnyitasahoz.')
                if IsControlJustReleased(0, 38) then openMenu() end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if testVehicle and testEndsAt then
            local secondsLeft = math.max(0, math.ceil((testEndsAt - GetGameTimer()) / 1000))
            SendNUIMessage({ action = 'timer', seconds = secondsLeft })
            if secondsLeft <= 0 then
                deleteTestVehicle()
                notify('Lejart a 2 perces tesztvezetes.')
            end
            Wait(1000)
        else
            Wait(1000)
        end
    end
end)
