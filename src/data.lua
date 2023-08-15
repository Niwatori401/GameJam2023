color = {}

color.COLOR_PINK = {255 / 255, 182 / 255, 193 / 255}
color.COLOR_BLACK = {0 / 255, 0 / 255, 0 / 255}
color.COLOR_GRAY = {230 / 255, 230 / 255, 230 / 255}
color.COLOR_GRAY_TRANSPARENT = {230 / 255, 230 / 255, 230 / 255, 0.4}
color.COLOR_CLEAR = {0,0,0,0}
color.COLOR_WHITE = {1,1,1,1}

window = {}
window.SCREEN_X = 1024
window.SCREEN_Y = 576
window.SCREEN_RATIO = 3/8

game = {}
game.game_time = 0

font = {}
font.init = function (self)
    if self.initialized ~= nil and self.initialized == true then
        print("Didnt init")
        return
    end

    self.initialized = true

    self.fonts = {}
    self.fonts["ArchitectsDaughter"] = love.graphics.newFont("data/_meta/_fonts/ArchitectsDaughter.ttf")
    self.fonts["Graziano"] = love.graphics.newFont("data/_meta/_fonts/Graziano.ttf")
    self.fonts["Nicolas_Frespech"] = love.graphics.newFont("data/_meta/_fonts/Nicolas_Frespech.ttf")
end
