love.graphics.setDefaultFilter('nearest', 'nearest')

require 'src/Dependencies'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288
BACKGROUND_SCROLL_SPEED = 80

function love.load()
    love.window.setTitle('Match 3')

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
        canvas = true
    })

    gSounds['music']:setLooping(true)
    gSounds['music']:play()
end
