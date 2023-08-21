
--[[
    File: state_empty.lua
    Descriptions: implments an empty state
--]]
local state = require("game.state")

---@class empty_state
local empty_state = {}

empty_state.name = "empty"
setmetatable(empty_state, state)

return empty_state