fx_version 'cerulean'
game 'gta5'

author 'Erkan Emal'
description 'Admin NPC Menu using ox_lib'
version '1.0.0'

shared_script 'client/config.lua'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'oxmysql',
    'ox_lib',
    'ox_target'
}
