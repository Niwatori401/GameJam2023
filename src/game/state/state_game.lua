--[[
    File: state_game.lua
    Descriptions: implements sitting in the game state
--]]
local state = require("game.state.state")

---@class game_state
local game_state = {}
setmetatable(game_state, state)
game_state.name = "game"

function game_state:state_exit(res)
    return "start"
end

return game_state