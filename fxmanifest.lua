lua54 'yes'
fx_version 'cerulean'
game 'gta5'

author 'Erkan Emal'
description 'Standalone NPC Spawner'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

server_script '@oxmysql/lib/MySQL.lua'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

files {
    'npcs.sql'
}
