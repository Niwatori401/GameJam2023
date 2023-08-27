local data = require("data")

function love.conf(t)
    t.title = "Game Jam 2023"
    t.version = "11.4"
    t.window.width = data.window.SCREEN_X
    t.window.height = data.window.SCREEN_Y
    t.console = false
    t.window.borderless = false
    t.window.fullscreen = false         -- Enable fullscreen (boolean)
    t.window.fullscreentype = "exclusive" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
    t.window.vsync = 1                  -- Vertical sync mode (number)
    t.window.msaa = 2

    t.identity = "GameJam_2023_BobbleGame"
end
