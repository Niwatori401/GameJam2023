local data = {}

local color = {}
color.COLOR_PINK = {255 / 255, 182 / 255, 193 / 255}
color.COLOR_BLACK = {0 / 255, 0 / 255, 0 / 255}
color.COLOR_GRAY = {230 / 255, 230 / 255, 230 / 255}
color.COLOR_DARK_GRAY = {160 / 255, 160 / 255, 160 / 255}

color.COLOR_GRAY_TRANSPARENT = {230 / 255, 230 / 255, 230 / 255, 0.4}
color.BERY_NICE_PINK = {255 / 255, 198 / 255, 243 / 255}
color.COLOR_DARK_RED = {255/ 255, 0, 42 /255}
color.COLOR_CLEAR = {0,0,0,0}
color.COLOR_WHITE = {1,1,1,1}

local window = {}
window.SCREEN_X = 1024
window.SCREEN_Y = 576
window.SCREEN_RATIO = 3/8

local defaults = {}
function defaults:init()
    if self.initialized ~= nil and self.initialized == true then
        return
    end
    self.initialized = true
    defaults.transparent = love.graphics.newImage("data/_meta/transparent.png")
    defaults.missing_image = love.graphics.newImage("data/_meta/default.png")
    defaults.black_image = love.graphics.newImage("data/_meta/black.png")

    defaults.silence = love.audio.newSource("data/_meta/silence.ogg", "static")
end

local game = {}
game.game_time = 0

local font = {}
function font:init()
    if self.initialized ~= nil and self.initialized == true then
        return
    end

    self.initialized = true


    self.fonts = {}
    self.fonts["Crosterian"] = love.graphics.newFont("data/_meta/_fonts/Crosterian.ttf")
    self.fonts["ArchitectsDaughter"] = love.graphics.newFont("data/_meta/_fonts/ArchitectsDaughter.ttf")
    self.fonts["Graziano"] = love.graphics.newFont("data/_meta/_fonts/Graziano.ttf")
    self.fonts["Nicolas_Frespech"] = love.graphics.newFont("data/_meta/_fonts/Nicolas_Frespech.ttf")
end


data.color = color
data.defaults = defaults
data.font = font
data.game = game
data.window = window

function data:init()
    data.defaults:init()
    data.font:init()
end

return data
