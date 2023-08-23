local data = require("data")
local game = require("game.game_logic.game")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
local action_set = require("game.action_set")

local game_puzzle_bobble = {}

setmetatable(game_puzzle_bobble, {__index = game})

function game_puzzle_bobble:new(game_data)
    local new_game = setmetatable({}, {__index = game_puzzle_bobble})

    new_game.game_width = 380
    new_game.game_height = 540
    new_game.game_x = 610
    new_game.game_y = 15

    new_game:_make_shooter_sprites(game_data)
    new_game:_make_game_bg_sprite(game_data)
    new_game:_define_level_actions()

    return new_game

end

--#region game interface functions

function game_puzzle_bobble:update(dt)


end


function game_puzzle_bobble:draw(layer)

    --new_game.game_bg
    self:_draw_game_bg(layer)
    self:_draw_arrow_and_base(layer)
end

function game_puzzle_bobble:handle_events(key)
    self.action_set:do_all_applicable_actions(key, self)
end

--#endregion

--#region game logic functions

function game_puzzle_bobble:_get_next_bobble_row()

end

function game_puzzle_bobble:_pop_appropriate_bobbles()

end

--#endregion

--#region drawing helper fucntion

function game_puzzle_bobble:_draw_game_bg(layer)
    local s = self.game_bg

    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y,
            s.rotation,
            s.x_scale,
            s.y_scale
        )
    end
end


function game_puzzle_bobble:_draw_arrow_and_base(layer)

    local target_width_percentage = 0.5
    local target_height_percentage = 0.3

    local s = self.arrow_sprite
    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y,
            s.rotation,
            target_width_percentage / s.image:getWidth() * self.game_width,
            target_height_percentage / s.image:getHeight() * self.game_height,
            s.image:getWidth() / 2,
            s.image:getHeight()
        )
    end

    s = self.arrow_base_sprite
    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y,
            s.rotation,
            target_width_percentage / s.image:getWidth() * self.game_width,
            target_height_percentage / s.image:getHeight() * self.game_height,
            s.image:getWidth() / 2,
            s.image:getHeight()
        )
    end

end


--#endregion




--#region constructor helpers

function game_puzzle_bobble:_make_shooter_sprites(game_data)
    local arrow_image = game_data["shoot_arrow"]
    self.arrow_sprite = sprite:new(
        arrow_image,
        self.game_x + self.game_width / 2,
        self.game_y + self.game_height,
        self.game_width / arrow_image:getWidth(),
        self.game_height / arrow_image:getHeight(),
        render_layer.GAME_BG,
        0,
        data.color.COLOR_WHITE)
    self.arrow_sprite.max_rotation_radians = math.pi / 4
    self.arrow_sprite.min_rotation_radians = -math.pi / 4

    local arrow_base_image = game_data["shoot_base"]
    self.arrow_base_sprite = sprite:new(
        arrow_base_image,
        self.game_x + self.game_width / 2,
        self.game_y + self.game_height,
        self.game_width / arrow_base_image:getWidth(),
        self.game_height / arrow_base_image:getHeight(),
        render_layer.GAME_BG,
        0,
        data.color.COLOR_WHITE)
end


--- Mutates class, returns nothing
function game_puzzle_bobble:_define_bobbles(game_data)

end


--- Mutates class, returns nothing
function game_puzzle_bobble:_define_grid(game_data)
    self.grid = {}
    for i = 1, 13, 1 do
        table.insert({0, 0, 0, 0, 0, 0, 0, 0})
    end
end


--- Mutates class, returns nothing
function game_puzzle_bobble:_define_level_actions()
    self.action_set = action_set:new()

    self.action_set:add_key_action("left", function (game)
        self.arrow_sprite.rotation = self.arrow_sprite.rotation + 0.1

        if self.arrow_sprite.rotation >= self.arrow_sprite.max_rotation_radians then
            self.arrow_sprite.rotation = self.arrow_sprite.max_rotation_radians
        elseif self.arrow_sprite.rotation <= self.arrow_sprite.min_rotation_radians then
            self.arrow_sprite.rotation = self.arrow_sprite.min_rotation_radians
        end
    end)


    self.action_set:add_key_action("right", function (game)
        self.arrow_sprite.rotation = self.arrow_sprite.rotation - 0.1

        if self.arrow_sprite.rotation >= self.arrow_sprite.max_rotation_radians then
            self.arrow_sprite.rotation = self.arrow_sprite.max_rotation_radians
        elseif self.arrow_sprite.rotation <= self.arrow_sprite.min_rotation_radians then
            self.arrow_sprite.rotation = self.arrow_sprite.min_rotation_radians
        end
    end)


    self.action_set:add_key_action("escape", function (game)
        game.level.exit_status = "abort_level"
        game.level:transition_out()
    end)
end

--- Mutates class, returns nothing
function game_puzzle_bobble:_make_game_bg_sprite(game_data)

    local game_bg_image = game_data["game_bg"]
    self.game_bg = sprite:new(
        game_bg_image,
        self.game_x,
        self.game_y,
        self.game_width / game_bg_image:getWidth(),
        self.game_height / game_bg_image:getHeight(),
        render_layer.GAME_BG,
        0,
        data.color.COLOR_WHITE)
end

--#endregion


return game_puzzle_bobble