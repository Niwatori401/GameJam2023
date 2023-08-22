require("utility")
local machine = require("src.game.state.machine")
local data = require("data")
local sprite_renderer = require("graphic.sprite_renderer")
local level_manager = require("src.game.level.level_manager")
local music_set = require("sound.music_set")

function love.load()
    machine:init("start")
    data:init()
    sprite_renderer:init()
    level_manager:load_level("texas")
    love.graphics.setFont(data.font.fonts["ArchitectsDaughter"])


end

function love.update(dt)
    data.game.game_time = data.game.game_time + dt
    level_manager.cur_level.character:update_animations()
    level_manager.cur_level.stage:update_animations()
    --level_manager.cur_level.music_set:update_audio()
end

function love.keypressed( key )


    level_manager.cur_level.action_set:do_all_applicable_actions(key, level_manager.cur_level)

    if key == "space" then
        level_manager.cur_level.character:animation_enter_screen()
    elseif key == "lshift" then
        level_manager.cur_level.character:animation_leave_screen()
    end

    if key == "g" then
        level_manager.cur_level.character:add_points(50)
    elseif key == "l" then
        level_manager.cur_level.character:add_points(-50)
    end

    -- if key == "u" then
    --     level_manager:load_level("texas")
    -- elseif key == "j" then
    --     level_manager:load_level("tokyo")
    -- end

    if key == "a" then
        level_manager.cur_level.stage:animation_fade_in()
    elseif key == "s" then
        level_manager.cur_level.stage:animation_fade_out()
    end
end

function love.draw()
    sprite_renderer:render()
end

function love.focus(f)

end


function love.quit()
    print("Thanks for playing! Come back soon!")
end
