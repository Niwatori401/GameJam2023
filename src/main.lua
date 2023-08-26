require("utility")
local machine = require("game.state.machine")
local data = require("data")
local sprite_renderer = require("graphic.sprite_renderer")
local level_manager = require("game.level.level_manager")
local music_set = require("sound.music_set")
local request = require("game.state.request")


function love.load()
    love.math.setRandomSeed(2, 200)
    math.randomseed(os.time())
    data:init()
    data.game.machine = machine
    machine:init("base")

    --machine:transition_state(request:new(nil, "unconditional_load", {level_to_load = "texas"}))
    machine:transition_state(request:new(nil, "unconditional_load", {level_to_load = "_splash_screen"}))

    sprite_renderer:init()

    love.graphics.setFont(data.font.fonts["ArchitectsDaughter"])


end

function love.update(dt)
    data.game.game_time = data.game.game_time + dt
    level_manager.cur_level:update(dt)
    level_manager.cur_level:handle_input(dt)
end

function love.keyreleased(key)
    level_manager.cur_level:handle_release_events(key)
end

function love.keypressed(key)


    level_manager.cur_level:handle_events(key)

    -- if key == "g" then
    --     level_manager.cur_level:add_points(10)
    --     level_manager.cur_level.game.thermometer:add_amount_to_current(10)
    -- elseif key == "l" then
    --     level_manager.cur_level:add_points(-5)
    --     level_manager.cur_level.game.thermometer:add_amount_to_current(-5)
    -- end

end

function love.draw()
    sprite_renderer:render()
end

function love.focus(f)

end


function love.quit()
    print("Thanks for playing! Come back soon!")
end
