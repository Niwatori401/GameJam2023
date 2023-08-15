require("utility")
require("data")
require("graphic/sprite_renderer")
require("game/game_manager")


function love.load()
    font:init()
    sprite_renderer:init()
    game_manager:load_level("texas")
    love.graphics.setFont(font.fonts["ArchitectsDaughter"])
end

function love.draw()
    love.graphics.print("Lorem Ipsum")
    sprite_renderer:render()
end


function love.focus(f)

end


function love.quit()
    print("Thanks for playing! Come back soon!")
end
