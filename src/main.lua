require("utility")
local data = require("data")
local sprite_renderer = require("graphic.sprite_renderer")
local level_manager = require("game.level_manager")

function love.load()
    data:init()
    sprite_renderer:init()
    level_manager:load_level("texas")
    love.graphics.setFont(data.font.fonts["ArchitectsDaughter"])
end

function love.update(dt)
    data.game.game_time = data.game.game_time + dt
    level_manager.cur_level.character:update_animations()
    level_manager.cur_level.stage:update_animations()
end

function love.keypressed( key )
    if key == "space" then
        level_manager.cur_level.character:animation_enter_screen()
    elseif key == "lshift" then
        level_manager.cur_level.character:animation_leave_screen()
    end

    if key == "a" then
        level_manager.cur_level.stage:animation_fade_in()
    elseif key == "s" then
        level_manager.cur_level.stage:animation_fade_out()
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
