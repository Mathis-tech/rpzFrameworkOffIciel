fx_version 'adamant'

game 'gta5'
lua54 'yes'

ui_page ''

files {

}
client_scripts {
    "client/modules/init/main.lua",
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
    "client/modules/weapon/weapon.lua",
    "client/modules/gta/NativePNJ.lua",
    "client/modules/utils/*.lua",
    "client/modules/game/*.lua",
    "client/modules/items/*.lua",
    "client/modules/*.lua",
    "client/modules/players/*.lua",
    "client/modules/spawned/*.lua",
    "client/modules/status/*.lua",
    "client/modules/notif/client/main.lua",
    "client/modules/notif/web/app.js",


}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/modules/init/main.lua",
    'function/jsp.lua',
    'function/*.lua',
    'server/modules/functions/death.lua',
    "server/modules/functions/GetPlayerData.lua",
    "server/modules/functions/death.lua",
    "server/modules/functions/GetHealth.lua",
    "server/modules/players/NewPlayer.lua",
    "server/modules/players/PlayerDataManager.lua",
    "server/modules/players/SavePlayers.lua",
    "server/modules/players/sync.lua",
    "server/modules/spawned/SpawnPlayer.lua",
    'data/loadDB.lua',
    "server/modules/spawned/*.lua",
    "server/modules/status/*.lua"


}

shared_script {
    'data/global_server.lua',
}

exports {"RPZ", "Draw3DTextPermanent", "Draw3DText", "Draw3DTextTimeout", "GetPlayerUID", "RegisterServerCallback"}
