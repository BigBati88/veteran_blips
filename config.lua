Config = {}

-- A berles ara es a biztositeki osszeg dollarban.
Config.Price = 250
Config.Deposit = 500
Config.PaymentAccount = 'bank' -- 'bank' vagy 'money'

Config.VehicleModel = 'faggio'
Config.VehicleFuel = 100.0
Config.InteractionDistance = 2.0
Config.DrawDistance = 20.0

Config.Locations = {
    { label = 'Vespucci roller berles', coords = vector3(-1205.54, -1566.86, 4.61), spawn = vector4(-1201.92, -1561.66, 4.61, 35.0), blip = true },
    { label = 'Del Perro roller berles', coords = vector3(-1601.42, -1013.43, 13.02), spawn = vector4(-1597.73, -1015.79, 13.02, 320.0), blip = true }
}

Config.Blip = { sprite = 226, color = 3, scale = 0.75 }
