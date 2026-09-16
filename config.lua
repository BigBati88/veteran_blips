Config = {}

Config.Dealer = {
    label = 'Premium Autohaus',
    coords = vector3(-56.71, -1096.72, 26.42),
    purchaseSpawn = vector4(-44.18, -1097.38, 26.42, 70.0),
    testSpawn = vector4(-39.12, -1082.43, 26.42, 70.0),
    interactionDistance = 2.0,
    drawDistance = 20.0,
    returnRadius = 35.0,
    blip = { sprite = 326, color = 3, scale = 0.8 }
}

Config.TestDriveSeconds = 120
Config.TestPlatePrefix = 'TEST'

Config.Categories = {
    { id = 'compacts', label = 'Kompakt', vehicles = {
        { model = 'blista', label = 'Dinka Blista', price = 18000 },
        { model = 'panto', label = 'Benefactor Panto', price = 22000 }
    } },
    { id = 'sports', label = 'Sport', vehicles = {
        { model = 'comet2', label = 'Pfister Comet', price = 125000 },
        { model = 'jester', label = 'Dinka Jester', price = 145000 }
    } },
    { id = 'suv', label = 'SUV', vehicles = {
        { model = 'baller', label = 'Gallivanter Baller', price = 85000 },
        { model = 'rocoto', label = 'Obey Rocoto', price = 72000 }
    } }
}
