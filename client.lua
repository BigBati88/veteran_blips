local ESX = exports['es_extended']:getSharedObject()
local rentalVehicle = nil

local function notify(message)
    ESX.ShowNotification(message)
end

local function drawText3D(coords, label)
    local visible, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not visible then return end
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(label)
    DrawText(x, y)
    DrawRect(x, y + 0.012, (string.len(label) + 1) / 370, 0.03, 0, 0, 0, 95)
end

local function loadModel(model)
    RequestModel(model)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(10) end
    return HasModelLoaded(model)
end

RegisterNetEvent('veteran_roller:client:notify', notify)

RegisterNetEvent('veteran_roller:client:spawnRental', function(locationId)
    local location = Config.Locations[locationId]
    if not location or rentalVehicle then return end
    local model = joaat(Config.VehicleModel)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) or not loadModel(model) then
        notify('A roller modell nem toltheto be. A penz vissza lett fizetve.')
        TriggerServerEvent('veteran_roller:server:cancelRental')
        return
    end

    local spawn = location.spawn
    if IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 2.5) then
        notify('A roller helye foglalt. A teljes összeg vissza lett fizetve.')
        SetModelAsNoLongerNeeded(model)
        TriggerServerEvent('veteran_roller:server:cancelRental')
        return
    end

    rentalVehicle = CreateVehicle(model, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
    SetVehicleOnGroundProperly(rentalVehicle)
    SetVehicleDirtLevel(rentalVehicle, 0.0)
    SetVehicleFuelLevel(rentalVehicle, Config.VehicleFuel)
    SetEntityAsMissionEntity(rentalVehicle, true, true)
    SetModelAsNoLongerNeeded(model)
    TriggerServerEvent('veteran_roller:server:setVehicle', NetworkGetNetworkIdFromEntity(rentalVehicle))
    TaskWarpPedIntoVehicle(PlayerPedId(), rentalVehicle, -1)
    notify(('Roller berelve! Visszaadaskor $%s kauciót kapsz vissza.'):format(Config.Deposit))
end)

RegisterNetEvent('veteran_roller:client:rentalReturned', function(deposit)
    if rentalVehicle and DoesEntityExist(rentalVehicle) then DeleteVehicle(rentalVehicle) end
    rentalVehicle = nil
    notify(('$%s kaució visszafizetve. Köszönjük, hogy nalunk bereltel!'):format(deposit))
end)

CreateThread(function()
    for _, location in ipairs(Config.Locations) do
        if location.blip then
            local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
            SetBlipSprite(blip, Config.Blip.sprite)
            SetBlipColour(blip, Config.Blip.color)
            SetBlipScale(blip, Config.Blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(location.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        for index, location in ipairs(Config.Locations) do
            local distance = #(playerCoords - location.coords)
            if distance < Config.DrawDistance then
                sleep = 0
                DrawMarker(1, location.coords.x, location.coords.y, location.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.1, 1.1, 0.35, 0, 180, 255, 160, false, false, 2, false, nil, nil, false)
                if distance < Config.InteractionDistance then
                    local action = rentalVehicle and 'visszaadása' or ('bérlése ($%s + $%s kaució)'):format(Config.Price, Config.Deposit)
                    drawText3D(location.coords + vector3(0.0, 0.0, 0.35), ('[E] Roller %s'):format(action))
                    if IsControlJustReleased(0, 38) then
                        if rentalVehicle then
                            if #(GetEntityCoords(rentalVehicle) - location.coords) > 12.0 then
                                notify('A rollert a berlo pont kozelebe kell visszahoznod.')
                            else
                                TriggerServerEvent('veteran_roller:server:return')
                            end
                        else
                            TriggerServerEvent('veteran_roller:server:rent', index)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
