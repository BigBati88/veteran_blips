fx_version 'cerulean'
game 'gta5'

author 'veteran_blips'
description 'Egyedi ESX Legacy autokereskedes tesztvezetessel'
version '2.0.0'

shared_script 'config.lua'

client_script 'client.lua'
server_script 'server.lua'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}

dependencies {
    'es_extended',
    'oxmysql'
}
