local animation = require("graphic.animation")
local data = require("data")
local character = require("game.character")
local sprite = require("graphic.sprite")
local level_manager = require("game.level.level_manager")
local render_layer = require("graphic.render_layer")


---Responsible for rendering all sprites on screen.
---Layers are defined as follows:
---(1, 2, 3 - Stage Backgrounds, 4, 5 - characters, 6 - game area background, 7, 8 - Bobbles, 9 - Effects)
---@class sprite_renderer
sprite_renderer = {}

sprite_renderer.layers = {}
render_layer.STAGE_BG   = 3
render_layer.CHARACTERS = 5
render_layer.GAME_BG    = 6
render_layer.BOBBLES    = 8
render_layer.EFFECTS    = 9


sprite_renderer.current_id = 0


---@param self table
function sprite_renderer:init()

end


function sprite_renderer:render()
    love.graphics.setColor(data.color.COLOR_WHITE)

    -- 1
    -- 2
    -- 3
    level_manager.cur_level.stage:draw(render_layer.STAGE_BG)
    -- 4
    -- 5
    level_manager.cur_level.character:draw(render_layer.CHARACTERS)
    -- 6
    level_manager.cur_level.game:draw(render_layer.GAME_BG)
    -- 7
    -- 8
    -- 9
    level_manager.cur_level.stage:draw(render_layer.EFFECTS)

end


return sprite_renderer
