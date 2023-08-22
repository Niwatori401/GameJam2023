
--[[
    File: state_empty.lua
    Descriptions: implments an empty state
--]]
local state = require("src.game.state.state")

---@class empty_state
local empty_state = {}

empty_state.name = "empty"
setmetatable(empty_state, state)

return empty_state
