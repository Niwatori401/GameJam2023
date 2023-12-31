local animation = require("graphic.animation")
local data = require("data")
local game = require("game.game_logic.game")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
local action_set = require("game.action_set")
local bobble = require("game.game_logic.game_puzzle_bobble.bobble")
local thermometer = require("game.game_logic.game_puzzle_bobble.thermometer")

local game_puzzle_bobble = {}

setmetatable(game_puzzle_bobble, {__index = game})

function game_puzzle_bobble:new(game_data, level)
    local new_game = setmetatable({}, {__index = game_puzzle_bobble})

    new_game.game_width = 380
    new_game.game_height = 540
    new_game.game_x = 610
    new_game.game_y = 15
    new_game.level = level
    new_game.grid = {}
    new_game.current_bobble = nil

    new_game.time_since_last_dialogue_update = 0
    new_game.time_between_dialogue_updates = 5
    new_game.cached_dialogue = nil
    new_game.game_over = false
    new_game.winner = false

    new_game:_load_bobble_images(game_data)
    new_game:_load_food_images(game_data)
    new_game:_make_win_scene_assets(game_data)

    new_game.thermometer = thermometer:new(
        sprite:new(game_data["thermometer_base"],
        450,
        0,
        data.window.SCREEN_Y / game_data["thermometer_base"]:getHeight(),
        data.window.SCREEN_Y / game_data["thermometer_base"]:getHeight(),
        render_layer.GAME_BG,
        0,
        data.color.COLOR_WHITE),
        game_data["thermometer_back"],
        new_game.level.character.points,
        data.color.BERY_NICE_PINK,
        new_game.level.character.stages,
        game_data["thud"],
        game_data["break"],
        game_data["thermometer_base_broken"],
        game_data["thermometer_back_broken"])

    new_game.next_bobble_index = math.random(#new_game.bobble_images)
    new_game:_make_textbox_sprite(game_data)
    new_game:_set_up_game_rules(game_data)
    new_game:_set_initial_bobble_rows()
    new_game:_make_audio_fx(game_data)
    new_game:_make_shooter_sprites(game_data)
    new_game:_make_game_bg_sprite(game_data)

    new_game:_define_level_actions()
    new_game:_define_level_inputs()
    new_game:_define_level_release_actions()

    return new_game

end


--#region game interface functions

function game_puzzle_bobble:update(dt)

    if self.game_over_win then return end

    self.thermometer:update(dt)

    for _, a in pairs(self.text_box.animations) do
        self.text_box[a.property_to_animate] = a:increment_animation()
    end

    if self.current_bobble ~= nil then

        if self:_bobble_should_stop(self.current_bobble) then

            self:_lock_bobble_into_grid(self.current_bobble)
            local popped_count = self:_pop_connected_bobbles(self.current_bobble)

            if popped_count >= 5 then
                love.audio.play(self.audio.pop_5)
            elseif popped_count == 4 then
                love.audio.play(self.audio.pop_4)
            elseif popped_count == 3 then
                love.audio.play(self.audio.pop_3)
            elseif popped_count == 2 then
                love.audio.play(self.audio.pop_2)
            elseif popped_count == 1 then
                love.audio.play(self.audio.pop_1)
            end

            self.current_bobble = nil
            self.next_bobble_index = math.random(#self.bobble_images)
            self.level:add_points(popped_count * self.points_per_bobble)
            self.thermometer:add_amount_to_current(popped_count * self.points_per_bobble)

            if self:_is_game_failure() then

                if self.level.character:get_cur_image_stage_index() == #self.level.character.stages then
                    self.game_over_win = true
                    love.audio.stop()
                    love.audio.play(self.win_sound)
                    self.action_set:add_key_action("escape", function (game)
                        game.level.exit_status = "game_success"
                        game.level:transition_out()
                    end)
                else
                    self.level.exit_status = "game_failure"
                    self.level:transition_out()
                end
            end
        end
        if self.current_bobble ~= nil then
            self:_update_bobble_position(self.current_bobble, dt)
        end

    end

    self.time_since_last_dialogue_update = self.time_since_last_dialogue_update + dt

    self:_add_rows_periodically(dt)
end


function game_puzzle_bobble:draw(layer)
    self:_draw_game_background(layer)
    self:_draw_game_bg(layer)
    self:_draw_box_under_shooter(layer)
    self:_draw_score_and_box(layer)
    self:_draw_time_to_next_row_indicator(layer)
    self:_draw_fail_line(layer)
    self:_draw_arrow_and_base(layer)
    self:_draw_bobbles(layer)
    self:_draw_next_bobble(layer)
    self:_draw_dialogue(layer)
    --self:_draw_upper_bar(layer)

    self.thermometer:draw()

    if self.game_over_win then
        self:_draw_winner_screen()
    end
end

function game_puzzle_bobble:handle_events(key)
    self.action_set:do_all_applicable_actions(key, {self})
end

function game_puzzle_bobble:handle_release_events(key)
    self.action_release_set:do_all_applicable_actions(key, {self})
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


---@param row integer
---@param col integer
---@param bobble_color_number integer The integer value in self.grid representing the bobble type
---@param visited table A table of 1's and 0's representing if a tile has been visited yet.
---@param count table A boxed integer
function game_puzzle_bobble:_mark_for_popping_dfs(row, col, bobble_color_number,  visited, count)

    if row < 1 or col < 1 or row > #self.grid or col > self.bobbles_per_row or visited[row][col] == 1 then
        return
    end

    visited[row][col] = 1

    if self.grid[row][col] ~= 0 and self.grid[row][col].bobble_type == bobble_color_number then

        count[1] = count[1] + 1

        self:_mark_for_popping_dfs(row-1, col, bobble_color_number, visited, count)
        self:_mark_for_popping_dfs(row+1, col, bobble_color_number, visited, count)
        self:_mark_for_popping_dfs(row, col+1, bobble_color_number, visited, count)
        self:_mark_for_popping_dfs(row, col-1, bobble_color_number, visited, count)

        if count[1] >= 3 then
            self.grid[row][col].should_pop = true
        end
    end
end

function game_puzzle_bobble:_mark_as_main_bobble_blob_dfs(row, col, visited)

    if row < 1 or col < 1 or row > #self.grid or col > self.bobbles_per_row or visited[row][col] == 1 or self.grid[row][col] == 0 then
        return
    end

    visited[row][col] = 1

    self:_mark_as_main_bobble_blob_dfs(row-1, col, visited)
    self:_mark_as_main_bobble_blob_dfs(row+1, col, visited)
    self:_mark_as_main_bobble_blob_dfs(row, col+1, visited)
    self:_mark_as_main_bobble_blob_dfs(row, col-1, visited)

end


function game_puzzle_bobble:_pop_connected_bobbles(bobble)

    local visited = {}

    for _ = 1, #self.grid do
        table.insert(visited, {0, 0, 0, 0, 0, 0, 0, 0})
    end

    local bobble_grid_x, bobble_grid_y = self:_convert_pixel_position_to_cell_index(bobble.sprite.x, bobble.sprite.y)
    local dfs_count = {0}
    self:_mark_for_popping_dfs(bobble_grid_y, bobble_grid_x, bobble.bobble_type, visited, dfs_count)

    if dfs_count[1] < 3 then
        return 0
    end

    local popped_count = 0
    for row = 1, #self.grid, 1 do
        for col = 1, self.bobbles_per_row, 1 do
            if self.grid[row][col] ~= 0 and self.grid[row][col].should_pop then
                popped_count = popped_count + 1
                self.grid[row][col]:pop()
                self.grid[row][col] = 0
            end
        end
    end

    visited = {}
    for _ = 1, #self.grid do
        table.insert(visited, {0, 0, 0, 0, 0, 0, 0, 0})
    end

    for col = 1, self.bobbles_per_row do
        if self.grid[1][col] ~= 0 then
            self:_mark_as_main_bobble_blob_dfs(1, col, visited)
        end
    end

    for i, row in ipairs(self.grid) do
        for j, entry in ipairs(row) do
            if visited[i][j] ~= 1 and self.grid[i][j] ~= 0 then
                entry:pop()
                self.grid[i][j] = 0
                popped_count = popped_count + 1
            end
        end
    end

    return popped_count
end

function game_puzzle_bobble:_lock_bobble_into_grid(bobble)
    local x_index, y_index = self:_convert_pixel_position_to_cell_index(bobble.sprite.x, bobble.sprite.y)
    self.grid[y_index][x_index] = bobble
end


function game_puzzle_bobble:_bobble_should_stop(bobble)
    local pixels_per_cell = self.game_width / self.bobbles_per_row
    if bobble.sprite.y + pixels_per_cell /2  < self.game_y then
        return true
    end

    local cell_x_index, cell_y_index = self:_convert_pixel_position_to_cell_index(bobble.sprite.x, bobble.sprite.y)



    local local_x_coord = bobble.sprite.x - self.game_x
    local local_y_coord = bobble.sprite.y - self.game_y

    -- cell local pixel position. Ranges from [0, pixels_per_cell)
    local remainder_x = local_x_coord - ((cell_x_index - 1) * pixels_per_cell)
    local remainder_y = local_y_coord - ((cell_y_index) * pixels_per_cell)


    if remainder_y < pixels_per_cell / 2 then
        if cell_y_index ~= 1 and self.grid[cell_y_index - 1][cell_x_index] ~= 0 then
            return true
        end
    end

    if remainder_x - pixels_per_cell / 3 < 0 then
        if cell_x_index ~= 1 and self.grid[cell_y_index][cell_x_index - 1] ~= 0 then
            return true
        end
    elseif remainder_x - 2 * pixels_per_cell / 3 > 0 then
        if cell_x_index ~= self.bobbles_per_row and self.grid[cell_y_index][cell_x_index + 1] ~= 0 then
            return true
        end
    end

    return false
end


function game_puzzle_bobble:_update_bobble_position(bobble, dt)
    -- Small number to check that it doesnt get "stuck" in a wall when it hits it
    if self:_is_bobble_touching_a_wall(bobble) and
        (bobble.time_of_last_reflection == nil or  data.game.game_time - bobble.time_of_last_reflection > 0.3) then
        bobble.time_of_last_reflection  = data.game.game_time
        bobble.velocity_x = -1 * bobble.velocity_x
    end

    bobble.sprite.x = bobble.sprite.x + dt * bobble.velocity_x
    bobble.sprite.y = bobble.sprite.y - dt * bobble.velocity_y

end

function game_puzzle_bobble:_is_bobble_touching_a_wall(bobble)

    local grid_x = self:_get_starting_position_for_bobbles_grid()

    return bobble.sprite.x - grid_x <= 0 or (bobble.sprite.x - grid_x + self.game_width / self.bobbles_per_row) >= self.game_width
end

function game_puzzle_bobble:_convert_pixel_position_to_cell_index(pos_x, pos_y)

    local x_start = self.game_x
    local y_start = self.game_y


    local x_index = math.ceil((pos_x - x_start) / (self.game_width / self.bobbles_per_row))
    local y_index = math.ceil((pos_y - y_start) / (self.game_width / self.bobbles_per_row))

    if x_index < 1 then
        x_index = 1
    elseif x_index > self.bobbles_per_row then
        x_index = self.bobbles_per_row
    end

    --y_index = y_index - 1

    if y_index < 1 then
        y_index = 1
    end

    return x_index, y_index
end

function game_puzzle_bobble:_set_initial_bobble_rows()
    local rows_to_start_with = self.rows_to_start_with

    function table_shallow_copy(table_to_copy)
        local new_table = {}

        for key, value in pairs(table_to_copy) do
            new_table[key] = value
        end

        return new_table
    end



    for _ = 1, rows_to_start_with, 1 do
        table.insert(self.grid, self:_get_next_bobble_row())
    end

    local blank_rows = {}
    for _ = 1, self.bobbles_per_row, 1 do
        table.insert(blank_rows, 0)
    end

    for _ = 1, self.rows_per_game * 1.5, 1 do
        table.insert(self.grid, table_shallow_copy(blank_rows))
    end

end

function game_puzzle_bobble:_add_rows_periodically(dt)

    if self.time_since_last_row < self.time_to_next_row then
        self.time_since_last_row = self.time_since_last_row + dt
        return
    else
        self.time_to_next_row = self.time_to_next_row - self.decrease_per_row

        if self.time_to_next_row < self.min_time_per_row then
            self.time_to_next_row = self.min_time_per_row
        end

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
    self:_trim_extra_zeroed_rows(self.grid)

    for i = #self.grid, 1, -1 do
        self.grid[i + 1] = self.grid[i]
    end

    self.grid[1] = new_row
end

function game_puzzle_bobble:_trim_extra_zeroed_rows(array2D)

    for i = #array2D, 1, -1 do
        local is_zero_row = true
        if i < self.rows_per_game * 1.5 then
            return
        end

        for _, value in ipairs(array2D[i]) do
            if value ~= 0 then
                is_zero_row = false
                break
            end
        end

        if is_zero_row then
            table.remove(array2D, i)
        else
            return
        end
    end
end


function game_puzzle_bobble:_get_last_nonzero_row_index()
    local row_has_nonzero_entry = false
    for row_index, row in ipairs(self.grid) do
        row_has_nonzero_entry = false

        for entry_index, entry in ipairs(row) do
            if entry ~= 0 then
                row_has_nonzero_entry = true
                break
            end
        end

        if not row_has_nonzero_entry then
           return row_index - 1
        end
    end

    return #self.grid
end

function game_puzzle_bobble:_is_game_failure()
    return self:_get_last_nonzero_row_index() > self.rows_per_game
end

function game_puzzle_bobble:_get_next_bobble_row()
    local number_of_bobbles = #self.bobble_images

    local new_row = {}
    for i = 1, self.bobbles_per_row, 1 do --
        local index = math.random(number_of_bobbles)
        table.insert(new_row, bobble:new(index, self.bobble_images[index], 0, 0, 0, 0))
    end

    return new_row
end

function game_puzzle_bobble:_get_current_line_of_dialogue()

    if self.cached_dialogue == nil or self.time_since_last_dialogue_update >= self.time_between_dialogue_updates then

        local last_cached_line = self.cached_dialogue

        self.cached_dialogue = self.level.character:get_next_dialogue_line()

        if self.cached_dialogue == last_cached_line then
            return "SIG_KILL"
        end
        self.time_since_last_dialogue_update = 0
    end

    return self.cached_dialogue
end

--#endregion

--#region drawing helper fucntion

function game_puzzle_bobble:_draw_winner_screen()
    love.graphics.setColor(data.color.COLOR_WHITE)

    love.graphics.draw(self.win_screen, 0, 0, 0, data.window.SCREEN_X / self.win_screen:getWidth(), data.window.SCREEN_Y / self.win_screen:getHeight())

end

function game_puzzle_bobble:_draw_score_and_box(layer)
    if layer ~= render_layer.GAME_BG then
        return
    end

    local x_offset = 20
    local y_offset = 60
    local width = 70
    local height = 30
    love.graphics.setColor(data.color.COLOR_GRAY)
    love.graphics.rectangle("fill", self.game_x + x_offset, self.game_y + self.game_height - y_offset, width, height)

    local font_scale = 1


    -- Drop shadow
    love.graphics.setColor(data.color.COLOR_DARK_RED)
    love.graphics.printf(
        self.level.character.points,
        data.font.fonts["PublicPixel"],
        self.game_x + x_offset + width / 2,
        self.game_y + self.game_height - y_offset + 10,
        width,
        "center",
        0,
        font_scale,
        font_scale,
        width / 2,
        0)
end

function game_puzzle_bobble:_should_show_text_box()

    if self.started_playing_time == nil then return end

    local cur_time_elapsed = data.game.game_time - self.started_playing_time

    local modulo_cycle = 3
    local cycle_length = self.time_between_dialogue_updates / (modulo_cycle - 1)

    local cycles = math.floor(cur_time_elapsed / cycle_length)

    if cycles % modulo_cycle == 0 then
        return true
    end

    return false
end

function game_puzzle_bobble:_draw_time_to_next_row_indicator(layer)

    if layer ~= render_layer.GAME_BG then
        return
    end


    local circle_radius = 40
    local pos_x = self.game_x + self.game_width - circle_radius - 5
    local pos_y = self.game_y + self.game_height - circle_radius - 5

    love.graphics.setColor(data.color.COLOR_WHITE)
    love.graphics.circle("fill", pos_x, pos_y, circle_radius)
    love.graphics.setColor(data.color.DARK_PINK)
    love.graphics.arc(
        "fill",
        "closed",
        pos_x,
        pos_y,
        circle_radius,
        0,
        2 * math.pi * (self.time_since_last_row / self.time_to_next_row))

end


function game_puzzle_bobble:_draw_dialogue(layer)


    if layer ~= render_layer.GAME_BG or self.started_playing_time == nil then return end

    local line_of_dialogue = self:_get_current_line_of_dialogue()

    if line_of_dialogue == "SIG_KILL" then
        return
    end

    local target_x = 20
    -- This function causes me pain   _:(´ཀ`」 ∠):
    local should_show_textbox = self:_should_show_text_box()
    if self.did_entry and not should_show_textbox then

        self.did_entry = false

        self.text_box:add_animation(animation:new(20, -1 * self.text_box.image:getWidth(), data.game.game_time, 0.5, animation.scheme_linear_interpolate, "x"))
        self.text_box.x = target_x

    elseif should_show_textbox and not self.did_entry then

        self.did_entry = true

        self.text_box:add_animation(animation:new(-1 * self.text_box.image:getWidth(), target_x, data.game.game_time, 0.5, animation.scheme_linear_interpolate, "x"))
        self.text_box.x = -1 * self.text_box.image:getWidth()
    end



    love.graphics.setColor(self.text_box.color)
    love.graphics.draw(
        self.text_box.image,
        self.text_box.x,
        self.text_box.y,
        0,
        1,
        1)


    local offset_x = 0
    local offset_y = 30
    local max_width =  0.8 * self.text_box.image:getWidth()
    local font_scale = 1

    love.graphics.setColor(data.color.COLOR_BLACK)
    love.graphics.printf(
        line_of_dialogue,
        data.font.fonts["ArchitectsDaughter18"],
        self.text_box.x + self.text_box.image:getWidth() / 2 + offset_x,
        self.text_box.y + offset_y,
        max_width,
        "center",
        0,
        font_scale,
        font_scale,
        max_width / 2,
        0)

end

function game_puzzle_bobble:_draw_box_under_shooter(layer)
    if layer == render_layer.GAME_BG then
        love.graphics.setColor(data.color.BERY_NICE_PINK)
        local y_coord = self.game_y + (self.rows_per_game) * (self.game_width / self.bobbles_per_row)
        love.graphics.rectangle(
            "fill",
            self.game_x,
            y_coord,
            self.game_width,
            self.game_height - y_coord + self.game_y)
    end
end

function game_puzzle_bobble:_draw_game_background(layer)
    if layer == render_layer.GAME_BG then
        local outline_size = 4
        love.graphics.setColor(data.color.COLOR_GRAY)
        love.graphics.rectangle(
            "fill",
            self.game_x - outline_size,
            self.game_y - outline_size,
            self.game_width + 2 * outline_size,
            self.game_height + 2 * outline_size)
    end
end

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

function game_puzzle_bobble:_get_starting_position_for_bobbles_grid()
    return self.game_x + self.game_width / (2 * self.bobbles_per_row), self.game_y + (1 * self.game_width) / (2 * self.bobbles_per_row)
end

function game_puzzle_bobble:_draw_next_bobble(layer)
    if self.next_bobble_index == nil then return end

    local s = sprite:new(self.bobble_images[self.next_bobble_index], 0, 0, 1, 1, render_layer.BOBBLES, 0, data.color.COLOR_WHITE)
    local bobble_width = s.image:getWidth()
    local bobble_height = s.image:getHeight()
    local scale_x = (self.game_width) / (self.bobbles_per_row * bobble_width)
    local scale_y = (self.game_width) / (self.bobbles_per_row * bobble_height)
    local x_start = self.game_x
    local y_start = self.game_y

    if layer == s.layer then
        love.graphics.setColor(s.color)
        s.image = self.food_images[self.next_bobble_index]
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            x_start + self.game_width / 2,
            y_start + self.game_height - (self.game_width/self.bobbles_per_row),
            s.rotation,
            0.8 * scale_x * (bobble_width / s.image:getWidth()),
            0.8 * scale_y * (bobble_height / s.image:getHeight()),
            s.image:getWidth() / 2,
            s.image:getHeight() / 2
        )
        s.image = self.bobble_images[self.next_bobble_index]
        love.graphics.draw(
            s.image,
            x_start + self.game_width / 2,
            y_start + self.game_height - (self.game_width/self.bobbles_per_row),
            s.rotation,
            scale_x,
            scale_y,
            bobble_width / 2,
            bobble_height / 2
        )
    end
end

function game_puzzle_bobble:_draw_fail_line(layer)

    if layer == render_layer.GAME_BG then
        love.graphics.setColor(data.color.COLOR_DARK_RED)
        love.graphics.rectangle(
            "fill",
            self.game_x,
            self.game_y + (self.rows_per_game) * (self.game_width / self.bobbles_per_row),
            self.game_width,
            3)
    end

end

function game_puzzle_bobble:_draw_upper_bar(layer)
    if layer == render_layer.GAME_BG then
        love.graphics.setColor(data.color.COLOR_GRAY)
        love.graphics.rectangle("fill", self.game_x, self.game_y, self.game_width, self.game_width / self.bobbles_per_row)
    end
end

function game_puzzle_bobble:_draw_bobbles(layer)

    for i, row in ipairs(self.grid) do

        for j, bobble in ipairs(row) do repeat
            if bobble == 0 then
                break
            end

            local s = sprite:new(nil, 0, 0, 1, 1, render_layer.GAME_BG, 0, data.color.COLOR_WHITE)

            s.image = self.bobble_images[bobble.bobble_type]
            local bobble_width = s.image:getWidth()
            local bobble_height = s.image:getHeight()
            local scale_x = (self.game_width) / (self.bobbles_per_row * bobble_width)
            local scale_y = (self.game_width) / (self.bobbles_per_row * bobble_height)
            local x_start, y_start = self:_get_starting_position_for_bobbles_grid()

            if layer == s.layer then
                s.image = self.food_images[bobble.bobble_type]
                love.graphics.setColor(s.color)
                love.graphics.draw(
                    s.image,
                    x_start + (j - 1) * (self.game_width/self.bobbles_per_row),
                    y_start + (i - 1) * (self.game_width/self.bobbles_per_row),
                    s.rotation,
                    0.8 * scale_x * (bobble_width / s.image:getWidth()),
                    0.8 * scale_y * (bobble_height / s.image:getHeight()),
                    s.image:getWidth() / 2,
                    s.image:getHeight() / 2
                )
                s.image = self.bobble_images[bobble.bobble_type]
                love.graphics.draw(
                    s.image,
                    x_start + (j - 1) * (self.game_width/self.bobbles_per_row),
                    y_start + (i - 1) * (self.game_width/self.bobbles_per_row),
                    s.rotation,
                    scale_x,
                    scale_y,
                    bobble_width / 2,
                    bobble_height / 2
                )
            end


        until true end
    end

    if self.current_bobble ~= nil then
        s = self.current_bobble.sprite

        local bobble_width = s.image:getWidth()
        local bobble_height = s.image:getHeight()
        local scale_x = (self.game_width) / (self.bobbles_per_row * bobble_width)
        local scale_y = (self.game_width) / (self.bobbles_per_row * bobble_height)

        if layer == s.layer then
            love.graphics.setColor(s.color)
            s.image = self.food_images[self.current_bobble.bobble_type]
            love.graphics.setColor(s.color)
            love.graphics.draw(
                s.image,
                s.x,
                s.y,
                s.rotation,
                0.8 * scale_x * (bobble_width / s.image:getWidth()),
                0.8 * scale_y * (bobble_height / s.image:getHeight()),
                s.image:getWidth() / 2,
                s.image:getHeight() / 2
            )
            s.image = self.bobble_images[self.current_bobble.bobble_type]
            love.graphics.draw(
                s.image,
                s.x,
                s.y,
                s.rotation,
                scale_x,
                scale_y,
                bobble_width / 2,
                bobble_height / 2
            )
        end
    end

end

function game_puzzle_bobble:_draw_arrow_and_base(layer)

    local target_width_percentage = 0.5
    local target_height_percentage = 0.3

    local s = self.arrow_base_sprite
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

    target_width_percentage = 0.5
    target_height_percentage = 0.3
    s = self.arrow_sprite
    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y - 60,
            s.rotation,
            target_width_percentage / s.image:getWidth() * self.game_width,
            target_height_percentage / s.image:getHeight() * self.game_height,
            s.image:getWidth() / 2,
            s.image:getHeight() / 2
        )
    end

end

--#endregion

--#region constructor helpers

function game_puzzle_bobble:_make_textbox_sprite(game_data)

    self.text_box = sprite:new(game_data["text_box"], 20, data.window.SCREEN_Y * 0.6, 1, 1, render_layer.GAME_BG, 0, data.color.COLOR_WHITE)
end

function game_puzzle_bobble:_set_up_game_rules(game_data)

    local game_rules = utility.parse_info(game_data["game_rules"])

    self.bobbles_per_row = tonumber(game_rules.bobbles_per_row)
    self.rows_per_game = tonumber(game_rules.rows_to_lose)
    self.time_since_last_row = 0
    self.time_to_next_row = tonumber(game_rules.time_to_first_row)
    self.decrease_per_row = tonumber(game_rules.decrease_in_time_per_row)
    self.min_time_per_row = tonumber(game_rules.min_time_per_row)
    self.rows_to_start_with = tonumber(game_rules.initial_rows)
    self.points_per_bobble = tonumber(game_rules.points_per_bobble)
    self.bobble_speed = tonumber(game_rules.bobble_speed)
    self.rotation_speed_multiplier = 1
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
    self.arrow_sprite.max_rotation_radians = 7 * math.pi / 16
    self.arrow_sprite.min_rotation_radians = -7 * math.pi / 16

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

function game_puzzle_bobble:_load_food_images(game_data)

    self.food_images = {}

    local food_data = game_data["food_info"]

    for i, line in pairs(food_data) do
        self.food_images[#self.food_images + 1] = game_data[line]
    end
end

function game_puzzle_bobble:_make_win_scene_assets(game_data)

    self.win_sound = game_data["victory"]
    self.win_screen = game_data["win"]
end

function game_puzzle_bobble:_define_level_release_actions()
    self.action_release_set = action_set:new()

    self.action_release_set:add_key_action("lshift", function (game)
        game.rotation_speed_multiplier = 1
    end)
end


function game_puzzle_bobble:_define_level_inputs()
    self.input_set = action_set:new()

    self.input_set:add_key_action("left", function (game, dt)
        game.arrow_sprite.rotation = game.arrow_sprite.rotation - dt * 2 * game.rotation_speed_multiplier

        if game.arrow_sprite.rotation >= game.arrow_sprite.max_rotation_radians then
            game.arrow_sprite.rotation = game.arrow_sprite.max_rotation_radians
        elseif game.arrow_sprite.rotation <= game.arrow_sprite.min_rotation_radians then
            game.arrow_sprite.rotation = game.arrow_sprite.min_rotation_radians
        end
    end)


    self.input_set:add_key_action("right", function (game, dt)
        game.arrow_sprite.rotation = game.arrow_sprite.rotation + dt * 2 * game.rotation_speed_multiplier

        if game.arrow_sprite.rotation >= game.arrow_sprite.max_rotation_radians then
            game.arrow_sprite.rotation = game.arrow_sprite.max_rotation_radians
        elseif game.arrow_sprite.rotation <= game.arrow_sprite.min_rotation_radians then
            game.arrow_sprite.rotation = game.arrow_sprite.min_rotation_radians
        end
    end)


end

function game_puzzle_bobble:_define_level_actions()
    self.action_set = action_set:new()

    self.action_set:add_key_action("lshift", function (game)

        game.rotation_speed_multiplier = 0.3

    end)

    self.action_set:add_key_action("up", function (game)
        if game.next_bobble_index == nil then
            return
        end

        if game.started_playing_time == nil then
            self.started_playing_time = data.game.game_time
        end

        local bobble_index = game.next_bobble_index
        game.next_bobble_index = nil
        local total_velocity = game.bobble_speed

        local velocity_x = total_velocity * math.sin(game.arrow_sprite.rotation)
        local velocity_y = total_velocity * math.cos(game.arrow_sprite.rotation)

        game.current_bobble = bobble:new(
            bobble_index,
            self.bobble_images[bobble_index],
            self.game_x + self.game_width / 2,
            self.game_y + self.game_height - (self.game_width/self.bobbles_per_row),
            velocity_x,
            velocity_y
        )

        love.audio.play(self.audio.shoot)

        game.current_bobble.is_flying = true
    end)

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

function game_puzzle_bobble:_make_audio_fx(game_data)

    self.audio = {}
    self.audio.pop_1 = game_data["pop_1"]
    self.audio.pop_2 = game_data["pop_2"]
    self.audio.pop_3 = game_data["pop_3"]
    self.audio.pop_4 = game_data["pop_4"]
    self.audio.pop_5 = game_data["pop_5"]

    self.audio.shoot = game_data["shoot"]
    self.audio.lose = game_data["lose"]

end

--#endregion


return game_puzzle_bobble
