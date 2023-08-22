--[[
    File: state_load_level.lua
    Descriptions: implments an empty state
--]]
local state = require("src.game.state.state")

---@class load_level_state
local load_level_state = {}
setmetatable(load_level_state, state)
load_level_state.name = "start"

function load_level_state:next_state(res)

    -- something

    -- if nothing to change state in res, return self name
    return self.name
end

return load_level_state