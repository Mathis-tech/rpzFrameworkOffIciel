fx_version 'adamant'

game 'gta5'
lua54 'yes'

ui_page 'client/notif/web/index.html'

files {
    'client/notif/web/index.html',
    'client/notif/web/app.js',
    'client/notif/web/app.css'
}
client_scripts {
    "function/function.lua",
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
    "client/utils/*.lua",
    "client/items/*.lua",
    "client/event/*.lua",
    "client/modules/*.lua",
    "client/players/*.lua",
    "client/spawned/*.lua",
    "client/status/*.lua",
    "ui/client/*.lua",
    "client/notif/client/main.lua",
    "client/notif/web/app.js",


}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'function/init.lua',
    'function/*.lua',
    'server/functions/death.lua',
    "server/modules/*.lua",
    "server/players/NewPlayer.lua",
    "server/players/*.lua",
    'data/loadDB.lua',
    "server/event/*.lua",
    "server/spawned/*.lua",
    "server/players/*.lua",
    "server/status/*.lua",
    "ui/server/*.lua",

}

shared_script {
    'data/global_server.lua',
}

exports {"Draw3DTextPermanent", "Draw3DText", "Draw3DTextTimeout"}