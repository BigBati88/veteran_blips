# Premium Autohaus – ESX Legacy

Egyedi, NUI-alapú autókereskedés FiveM **ESX Legacy** szerverekhez. A játékosok a katalógusból kiválaszthatják az autót, **2 percig tesztvezethetik**, majd a járművet közvetlenül a bankszámlájukról vásárolhatják meg.

## Függőségek

- `es_extended` (ESX Legacy)
- `oxmysql`
- Az alap ESX `owned_vehicles` tábla (`owner`, `plate`, `vehicle` oszlopokkal)

## Telepítés

1. Másold a resource-ot a szerver `resources/[local]/veteran_blips` mappájába.
2. Az `server.cfg`-ben az `oxmysql` és az `es_extended` indítása után add hozzá:
   ```cfg
   ensure veteran_blips
   ```
3. Indítsd újra a resource-ot vagy a szervert.

## Beállítás

A `config.lua` fájlban módosítható a kereskedés koordinátája, a vásárlási és tesztvezetési spawn, a tesztvezetés hossza (alapérték: `120` másodperc), valamint a teljes autókatalógus és az árak.

## Használat

Menj a térképen **Premium Autohaus** néven jelölt ponthoz, majd nyomd meg az **E** gombot. A „Tesztvezetés” egy időzített, 2 perces próbakört indít. A „Megveszem” gomb kizárólag a játékos **bank** számlájáról vonja le a konfigurált összeget, majd elmenti a járművet az `owned_vehicles` táblába.
