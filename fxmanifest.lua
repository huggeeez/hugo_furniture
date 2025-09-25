fx_version 'cerulean'
game 'gta5'

description 'Huggeeez Furniture Script'
author 'Huggeeez'
version '1.1.1'

shared_script {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
    
}

lua54 'yes'
