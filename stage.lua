stage = {}
stage.minesweeper = {}
stage.graphics = {}
stage.graphics.stage = {}
stage.graphics.minesweeper = {}
stage.graphics.character = {}
stage.graphics.character.stages = {}

local function load_images(self, stage_name)
    self.graphics.stage.stage_bg = love.graphics.newImage("maps/" .. stage_name .. "/stage/stage_bg.png")
    self.graphics.stage.stage_fleck = love.graphics.newImage("maps/" .. stage_name .. "/stage/stage_fleck.png")

    local stages = {}
    for line in love.filesystem.lines("maps/" .. stage_name .. "/character/character_stage_info.txt") do
        stages[#stages + 1] = line
    end

    self.graphics.character.name_graphic = love.graphics.newImage("maps/" .. stage_name .. "/character/name.png")
    self.graphics.character.stages.stage_info = stages
    self.graphics.character.stages.cur_stage_index= 1

    for _, stage_number in pairs(stages) do
        print("Loading character sprite for weight " .. stage_number)
        self.graphics.character.stages[stage_number] =
            love.graphics.newImage("maps/" .. stage_name .. "/character/".. stage_number ..".png")
    end

    self.graphics.minesweeper.minesweeper_bg = love.graphics.newImage("maps/" .. stage_name .. "/minesweeper/ms_bg.png")
    self.graphics.minesweeper.minesweeper_cell = love.graphics.newImage("maps/" .. stage_name .. "/minesweeper/ms_cell.png")
end

local function load_minesweeper_data(self, stage_name)
    local lines = {}
    for line in love.filesystem.lines("maps/" .. stage_name .. "/minesweeper/minesweeper_data.txt") do
        lines[#lines + 1] = line
    end

    self.minesweeper.mine_count = tonumber(string.sub(lines[1], (string.find(lines[1], "=")) + 1))
    self.minesweeper.map_width = tonumber(string.sub(lines[2], (string.find(lines[2], "=")) + 1))
    self.minesweeper.map_height = tonumber(string.sub(lines[3], (string.find(lines[3], "=")) + 1))

    print("Loaded a " .. self.minesweeper.map_width .. "x" .. self.minesweeper.map_height .. " map with " .. self.minesweeper.mine_count .. " bombs")
end


stage.load = function (self, stage_name)
    load_images(self, stage_name)
    load_minesweeper_data(self, stage_name)
end

stage.next_score = function (self)
    local stage_info = self.graphics.character.stages.stage_info
    local cur_index = self.graphics.character.stages.cur_stage_index

    return stage_info[cur_index + 1]
end

stage.get_cur_character_sprite = function (self)
    return self.graphics.character.stages[self.graphics.character.stages.stage_info[self.graphics.character.stages.cur_stage_index]]
end

stage.get_stage_bg = function (self)
    return self.graphics.stage.stage_bg
end

stage.get_stage_fleck = function (self)
    return self.graphics.stage.stage_fleck
end

stage.get_minesweeper_background_image = function (self)
    return self.graphics.minesweeper.minesweeper_bg
end

stage.get_minesweeper_cell_image = function (self)
    return self.graphics.minesweeper.minesweeper_cell
end

stage.get_mine_count = function (self)
    return self.minesweeper.mine_count
end

stage.get_map_size = function (self)
    return self.minesweeper.map_width, self.minesweeper.map_height
end




