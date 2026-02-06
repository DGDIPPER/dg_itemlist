fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dg_giveite'
author 'DGDIPPER'
description 'Qbox ox inventory item menu with search'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx_core'
}
