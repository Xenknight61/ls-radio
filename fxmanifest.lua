fx_version 'bodacious'
game 'gta5'

client_script {
  'client/client.lua',
  'config.lua'
}

server_script {
  'server/server.lua',
  'config.lua'
}

ui_page('html/ui.html')

files {
    'html/ui.html',
    'html/js/script.js',
    'html/css/style.css',
    'html/img/cursor.png',
    'html/img/radio.png',
    'html/font/digital7-1e1z-webfont.woff',
    'html/font/digital7-1e1z-webfont.woff2',
}
