local data = require("data")

function love.conf(t)
    t.title = "Game Jam 2023"
    t.version = "11.4"
    t.window.width = data.window.SCREEN_X
    t.window.height = data.window.SCREEN_Y
    t.console = true
end
