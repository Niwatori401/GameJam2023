
require("minesweeper")
require("data")
require("stage")
require("globals")
require("character_renderer")

function love.load()
    love.graphics.setBackgroundColor(color.COLOR_PINK)

    love.window.setMode( SCREEN_X, SCREEN_Y )

    stage:load("test_stage")

    local mapWidth, mapHeight = stage:get_map_size()
    minesweeper:initialize(
        SCREEN_X * (SCREEN_RATIO),
        SCREEN_Y,
        mapWidth,
        mapHeight)
    --image = love.graphics.newImage("cake.jpg")
    love.graphics.setNewFont(12)
end


function love.update(dt)
    GAME_TIME = GAME_TIME + dt

 end


function love.draw()
    love.graphics.setColor(color.COLOR_WHITE)

    -- Background
    local bg_image = stage:get_stage_bg()
    local bg_image_scale_x = SCREEN_X / bg_image:getWidth()
    local bg_image_scale_y = SCREEN_Y / bg_image:getHeight()
    love.graphics.draw(bg_image, 0, 0, 0, bg_image_scale_x, bg_image_scale_y)

    -- Character sprite
    character_renderer:render(stage:get_cur_character_sprite())


    -- Minesweeper Board
    minesweeper:render(stage:get_minesweeper_background_image(), stage:get_minesweeper_cell_image())
end


function love.mousemoved(x, y, dx, dy, istouch)
    if (love.mouse.isDown(1)) then
        minesweeper:update_current_held_cell(x,y)
    end
end


function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        minesweeper:update_current_held_cell(x,y)
    end
end


function love.mousereleased(x, y, button, istouch)
    if button == 1 then
        minesweeper:click_cell(x,y);
    end
end

function love.focus(f)
    if not f then
      print("LOST FOCUS")
    else
      print("GAINED FOCUS")
    end
end


function love.quit()
    print("Thanks for playing! Come back soon!")
end
