require("data")

minesweeper = {}

minesweeper.map = {}
minesweeper.map_start_pos_x = 100
minesweeper.map_start_pos_y = 200
minesweeper.mapSizeX = 10
minesweeper.mapSizeY = 10

minesweeper.maxWidth = 0
minesweeper.maxHeight = 0

minesweeper.currentlyHeldCellX = -1
minesweeper.currentlyHeldCellY = -1

minesweeper.cell_size = 20
minesweeper.cell_padding = 2


cellstatus = {}
cellstatus.CS_UNCLICKED = 0
cellstatus.CS_GONE = 1
cellstatus.CS_HOVER = 2
cellstatus.CS_HOLD_DOWN = 3





local function get_base_coordinates(self)
    local areaWidth = SCREEN_X * (SCREEN_RATIO)
    local xBorder = SCREEN_X - areaWidth

    local puzzleWidth = (self.cell_size + self.cell_padding) * self.mapSizeX
    local puzzleHeight = (self.cell_size + self.cell_padding) * self.mapSizeY

    return (((areaWidth - puzzleWidth) / 2) + xBorder), ((SCREEN_Y - puzzleHeight) / 2)
end




local function set_cell_size(self)
    local areaWidth = SCREEN_X * (SCREEN_RATIO)
    local mapRatio = self.mapSizeX / self.mapSizeY

    if (areaWidth / SCREEN_Y > mapRatio) then
        -- Allocated area is wider than puzzle, scale by vertical available area
        self.cell_size = SCREEN_Y / self.mapSizeY
    else
        -- Allocated area is thinner than puzzle, scale by horizontal available area
        self.cell_size = areaWidth / self.mapSizeX
    end
end


minesweeper.initialize = function (self, maxWidth, maxHeight, cellsX, cellsY)

    self.map_start_pos_x = 0
    self.map_start_pos_y = 0

    self.mapSizeX = cellsX
    self.mapSizeY = cellsY

    self.maxWidth = maxWidth
    self.maxHeight = maxHeight

    set_cell_size(self)
    self.map_start_pos_x, self.map_start_pos_y = get_base_coordinates(self)

    for i=1, self.mapSizeX do
        self.map[i] = {}
        for j=1, self.mapSizeY do
            self.map[i][j] = cellstatus.CS_UNCLICKED
        end
    end
end


minesweeper.update_current_held_cell = function (self, x,y)
    local relativeX = x - self.map_start_pos_x
    local relativeY = y - self.map_start_pos_y

    local cellNumberX = math.ceil(relativeX / (self.cell_size + self.cell_padding))
    local cellNumberY = math.ceil(relativeY / (self.cell_size + self.cell_padding))

    if (
        cellNumberX > self.mapSizeX or
        cellNumberY > self.mapSizeY or
        cellNumberX < 1 or
        cellNumberY < 1) then

        self.currentlyHeldCellX = -1
        self.currentlyHeldCellY = -1
        return
    end

    self.currentlyHeldCellX = cellNumberX
    self.currentlyHeldCellY = cellNumberY
end

minesweeper.click_cell = function (self, x,y)
    self.currentlyHeldCellX = -1
    self.currentlyHeldCellY = -1

    local relativeX = x - self.map_start_pos_x
    local relativeY = y - self.map_start_pos_y

    local cellNumberX = math.ceil(relativeX / (self.cell_size + self.cell_padding))
    local cellNumberY = math.ceil(relativeY / (self.cell_size + self.cell_padding))

    if (cellNumberX < 1 or
        cellNumberY < 1 or
        cellNumberX > self.mapSizeX or
        cellNumberY > self.mapSizeY or
        self.map[cellNumberX][cellNumberY] == cellstatus.CS_GONE)
    then return end

    self.map[cellNumberX][cellNumberY] = cellstatus.CS_GONE
end

local function get_grid_size(self)
    local width = (self.cell_size + self.cell_padding) * self.mapSizeX
    local height = (self.cell_size + self.cell_padding) * self.mapSizeY

    return width, height
end

local function render_grid(self, cell_sprite)
    for i=1, self.mapSizeX do
        for j=1, self.mapSizeY do

            if (self.map[i][j] == cellstatus.CS_UNCLICKED) then
                love.graphics.setColor(color.COLOR_WHITE)
            elseif (self.map[i][j] == cellstatus.CS_GONE) then
                love.graphics.setColor(color.COLOR_CLEAR)
            end

            love.graphics.draw(
                cell_sprite,
                self.map_start_pos_x + (i - 1) * (self.cell_size + self.cell_padding),
                self.map_start_pos_y + (j - 1) * (self.cell_size + self.cell_padding),
                0,
                self.cell_size / cell_sprite:getWidth(),
                self.cell_size / cell_sprite:getHeight())
        end
    end
end


local function render_clicked_highlight_cell(self)
    if (self.currentlyHeldCellX ~= -1 and
    self.currentlyHeldCellY ~= -1 and
    self.map[self.currentlyHeldCellX][self.currentlyHeldCellY] ~= cellstatus.CS_GONE) then

    love.graphics.setColor(color.COLOR_GRAY_TRANSPARENT)
    love.graphics.rectangle(
        "fill",
        self.map_start_pos_x + (self.currentlyHeldCellX - 1) * (self.cell_size + self.cell_padding),
        self.map_start_pos_y + (self.currentlyHeldCellY - 1)* (self.cell_size + self.cell_padding),
        self.cell_size,
        self.cell_size)
    end
end


local function render_background(self, background)
    local width, height = get_grid_size(self)

    love.graphics.draw(
        background,
        self.map_start_pos_x,
        self.map_start_pos_y,
        0,
        width / background:getWidth(),
        height / background:getHeight())
end


minesweeper.render = function (self, background, cell_sprite)

    render_background(self, background)
    render_grid(self, cell_sprite)
    render_clicked_highlight_cell(self)

end
