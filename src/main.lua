require("utility")
local machine = require("game.state.machine")
local data = require("data")
local sprite_renderer = require("graphic.sprite_renderer")
local level_manager = require("game.level.level_manager")
local music_set = require("sound.music_set")

function love.load()
    machine:init("start")
    data:init()
    sprite_renderer:init()
    level_manager:load_level("_level_select")
    -- level_manager:load_level("texas")
    love.graphics.setFont(data.font.fonts["ArchitectsDaughter"])


end

function love.update(dt)
    data.game.game_time = data.game.game_time + dt
    level_manager.cur_level:update(dt)
    --level_manager.cur_level.music_set:update_audio()
end

function love.keypressed( key )


    level_manager.cur_level:handle_events(key)

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

    if key == "a" then
        level_manager.cur_level.stage:animation_fade_in(1)
    elseif key == "s" then
        level_manager.cur_level.stage:animation_fade_out(1)
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
