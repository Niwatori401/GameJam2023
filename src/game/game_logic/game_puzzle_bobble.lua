local data = require("data")
local game = require("game.game_logic.game")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
local action_set = require("game.action_set")
local bobble = require("game.game_logic.game_puzzle_bobble.bobble")

local game_puzzle_bobble = {}

setmetatable(game_puzzle_bobble, {__index = game})

function game_puzzle_bobble:new(game_data)
    local new_game = setmetatable({}, {__index = game_puzzle_bobble})

    new_game.game_width = 380
    new_game.game_height = 540
    new_game.game_x = 610
    new_game.game_y = 15
    new_game.grid = {}
    new_game:_load_bobble_images(game_data)
    new_game:_set_up_game_rules()
    new_game:_set_initial_bobble_rows()
    new_game:_make_shooter_sprites(game_data)
    new_game:_make_game_bg_sprite(game_data)

    new_game:_define_level_actions()
    new_game:_define_level_inputs()

    return new_game

end


function game_puzzle_bobble:visit(i, j, visited)
    -- TODO: Mark bobbles for popping
    visited[i][j] = 1
end

---@param i any
---@param j any
---@param bobble_color_number integer The integer value in self.grid representing the bobble type
---@param visited table A table of 1's and 0's representing if a tile has been visited yet.
function game_puzzle_bobble:dfs(i, j, bobble_color_number,  visited)

    if i < 1 or j < 1 or i > self.bobbles_per_row or j > self.bobbles_per_row or visited[i][j] == 1 then
        return
    end

    if self.grid[i][j] == bobble_color_number then

        self:visit(i, j, visited)

        self:dfs(i-1, j, bobble_color_number, visited)
        self:dfs(i+1, j, bobble_color_number, visited)
        self:dfs(i, j+1, bobble_color_number, visited)
        self:dfs(i, j-1, bobble_color_number, visited)
    end
end

function game_puzzle_bobble:pop_connected_bobbles(most_recent_bobble)

    local visited = {}

    for _ = 1, self.rows_per_game do
        table.insert(visited, {0, 0, 0, 0, 0, 0, 0, 0})
    end

    local bobble_grid_x = 0
    local bobble_grid_y = 0
    local bobble_color_number = 1

    self:dfs(bobble_grid_x, bobble_grid_y, bobble_color_number, visited)

    -- local popped_count = 0
    -- for i = 1, self.rows_per_game, 1 do
    --     for j = 1, self.bobbles_per_row, 1 do
    --         if
    --     end
    -- end

    local connected = dfs(i, j, bobble_color_number,  visited, {0})
end



--#region game interface functions

function game_puzzle_bobble:update(dt)

    -- update_bobble_position()
    -- if bobble_collision() then
    --      fix_bobble_to_grid()
    -- end

    -- local bobble_pop_count = pop_connected_bobbles()
    -- add_pts_to_character(bobble_pop_count * pts_multiplier)

    ---Returns a count for how many adjacent

    self:_add_rows_periodically(dt)

end



function game_puzzle_bobble:draw(layer)

    --new_game.game_bg
    self:_draw_game_bg(layer)
    self:_draw_arrow_and_base(layer)
    self:_draw_bobbles(layer)
end

function game_puzzle_bobble:handle_events(key)
    self.action_set:do_all_applicable_actions(key, {self})
end

function game_puzzle_bobble:handle_input(dt)

    if love.keyboard.isDown("left") then
        self.input_set:do_all_applicable_actions("left", {self, dt})
    end
    if love.keyboard.isDown("right") then
        self.input_set:do_all_applicable_actions("right", {self, dt})
    end
end

--#endregion

--#region game logic functions
function game_puzzle_bobble:_set_initial_bobble_rows()
    local rows_to_start_with = 3

    for _ = 1, rows_to_start_with, 1 do
        table.insert(self.grid, self:_get_next_bobble_row())
    end
end


function game_puzzle_bobble:_add_rows_periodically(dt)

    if self.time_since_last_row < self.time_to_next_row then
        self.time_since_last_row = self.time_since_last_row + dt
        return
    else
        self.time_since_last_row = 0
    end

    local new_row = self:_get_next_bobble_row()
    self:_trim_and_insert_bobble_row(new_row)

    if self:_is_game_failure() then
        self.level.exit_status = "game_failure"
        self.level:transition_out()
    end
end

function game_puzzle_bobble:_trim_and_insert_bobble_row(new_row)
    self:_trim_zeroed_rows(self.grid)

    for i = #self.grid, 1, -1 do
        self.grid[i + 1] = self.grid[i]
    end

    self.grid[1] = new_row
end

function game_puzzle_bobble:_trim_zeroed_rows(array2D)

    for i = #array2D, 1, -1 do
        local isZeroRow = true

        for _, value in ipairs(array2D[i]) do
            if value ~= 0 then
                isZeroRow = false
                break
            end
        end

        if isZeroRow then
            table.remove(array2D, i)
        else
            return
        end
    end
end

function game_puzzle_bobble:_is_game_failure()
    return #self.grid > self.rows_per_game
end

function game_puzzle_bobble:_get_next_bobble_row()
    local number_of_bobbles = #self.bobble_images

    local new_row = {}
    for i = 1, self.bobbles_per_row, 1 do
        table.insert(new_row, math.random(number_of_bobbles))
    end

    return new_row
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

function game_puzzle_bobble:_draw_bobbles(layer)

    local s = sprite:new(nil, 0, 0, 1, 1, render_layer.GAME_BG, 0, data.color.COLOR_WHITE)

    for i, row in ipairs(self.grid) do
        for j, bobble_index in ipairs(row) do repeat
            if bobble_index == 0 then
                break
            end

            s.image = self.bobble_images[bobble_index]
            local bobble_width = s.image:getWidth()
            local bobble_height = s.image:getHeight()
            local scale_x = (self.game_width) / (8 * bobble_width)
            local scale_y = (self.game_width) / (8 * bobble_height)

            if layer == s.layer then
                love.graphics.setColor(s.color)
                love.graphics.draw(
                    s.image,
                    self.game_x + (scale_x * bobble_width) / 2 + (j - 1) * (self.game_width/8),
                    self.game_y + (3 * scale_y * bobble_height) / 2 + (i - 1) * (self.game_width/8),
                    s.rotation,
                    scale_x,
                    scale_y,
                    bobble_width / 2,
                    bobble_height / 2
                )
            end


        until true end
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

function game_puzzle_bobble:_set_up_game_rules()
    self.bobbles_per_row = 8
    self.rows_per_game = 7
    self.time_since_last_row = 0
    self.time_to_next_row = 3
end

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

function game_puzzle_bobble:_load_bobble_images(game_data)
    self.bobble_images = {}

    local bobble_data = game_data["bobble_info"]

    for i, line in pairs(bobble_data) do
        self.bobble_images[#self.bobble_images + 1] = game_data[line]
    end
end


function game_puzzle_bobble:_define_level_inputs()
    self.input_set = action_set:new()

    self.input_set:add_key_action("left", function (game, dt)
        game.arrow_sprite.rotation = game.arrow_sprite.rotation - dt * 2

        if game.arrow_sprite.rotation >= game.arrow_sprite.max_rotation_radians then
            game.arrow_sprite.rotation = game.arrow_sprite.max_rotation_radians
        elseif game.arrow_sprite.rotation <= game.arrow_sprite.min_rotation_radians then
            game.arrow_sprite.rotation = game.arrow_sprite.min_rotation_radians
        end
    end)


    self.input_set:add_key_action("right", function (game, dt)
        game.arrow_sprite.rotation = game.arrow_sprite.rotation + dt * 2

        if game.arrow_sprite.rotation >= game.arrow_sprite.max_rotation_radians then
            game.arrow_sprite.rotation = game.arrow_sprite.max_rotation_radians
        elseif game.arrow_sprite.rotation <= game.arrow_sprite.min_rotation_radians then
            game.arrow_sprite.rotation = game.arrow_sprite.min_rotation_radians
        end
    end)


end

function game_puzzle_bobble:_define_level_actions()
    self.action_set = action_set:new()


    self.action_set:add_key_action("escape", function (game)
        game.level.exit_status = "abort_level"
        game.level:transition_out()
    end)
end

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
