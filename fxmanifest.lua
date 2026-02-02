fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Mike P, Thicc Mike Mods'
description 'Super spec bodycam'
version '0.1.1'

ui_page 'html/index.html'

dependencies {
	"interact-sound"
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/textures/*.png',
    'html/sounds/*.ogg',
    'html/images/*.png'
}

client_scripts {
    'config.lua',
    'cl_bodycam.lua'
}

server_scripts {
    'config.lua',
    'sv_bodycam.lua'
}