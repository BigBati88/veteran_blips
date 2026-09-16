# veteran_blips

Egyszerű, önálló rollerbérlő resource **FiveM ESX Legacy** szerverekhez. A játékos egy bérlőpontnál felvesz egy `faggio` robogót, a bérleti díjat és a kauciót a beállított számláról fizeti, majd a kauciót a roller visszaadásakor visszakapja.

## Telepítés

1. Másold ezt a mappát a szervered `resources/[local]/veteran_blips` könyvtárába.
2. Az `server.cfg` fájlban, az `es_extended` után add hozzá:
   ```cfg
   ensure veteran_blips
   ```
3. Indítsd újra a resource-ot vagy a szervert.

## Beállítás

A `config.lua` fájlban módosítható:

- `Config.Price`: a nem visszatérítendő bérleti díj.
- `Config.Deposit`: a visszaadáskor visszafizetett kaució.
- `Config.PaymentAccount`: `bank` vagy `money`.
- `Config.VehicleModel`: a kiadott jármű modellneve.
- `Config.Locations`: bérlőpontok, spawn helyek és blipek.

## Használat

Menj egy térképen jelölt rollerbérlő ponthoz, majd nyomd meg az **E** gombot. A rollert bármelyik beállított bérlőpont közelében lehet visszaadni. Egyszerre egy aktív bérlés lehet játékosonként; kilépés esetén a kaució elveszik.
