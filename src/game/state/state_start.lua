
--[[
    File: state_empty.lua
    Descriptions: implments an empty state
--]]
local state = require("game.state.state")

---@class start_state
local start_state = {}
setmetatable(start_state, state)
start_state.name = "start"

function start_state:next_state(res)

    -- something

    -- if nothing to change state in res, return self name
    return self.name
end

return start_state
