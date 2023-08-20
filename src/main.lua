require("utility")
local data = require("data")
local sprite_renderer = require("graphic.sprite_renderer")


function love.load()
    data:init()
    sprite_renderer:init()
    --game_manager:load_level("texas")
    love.graphics.setFont(data.font.fonts["ArchitectsDaughter"])
end

function love.update(dt)
    data.game.game_time = data.game.game_time + dt
    sprite_renderer.characters[1]:update_animations()
end

function love.keypressed( key )
    if key == "space" then
        sprite_renderer.characters[1]:animation_enter_screen()
    elseif key == "lshift" then
        sprite_renderer.characters[1]:animation_leave_screen()
    end
end

function love.draw()
    love.graphics.print("test")
    sprite_renderer:render()
end

function love.focus(f)

end


function love.quit()
    print("Thanks for playing! Come back soon!")
end
