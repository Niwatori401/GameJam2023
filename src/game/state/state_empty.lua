
--[[
    File: state_empty.lua
    Descriptions: implments an empty state
--]]
local state = require("game.state.state_base")

local empty_state = setmetatable({}, {__index = state})

function empty_state:new()
    local new_es = setmetatable({}, {__index = empty_state})
    new_es.name = "empty"
    return new_es
end

return empty_state
