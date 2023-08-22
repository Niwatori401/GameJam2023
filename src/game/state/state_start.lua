--[[
    File: state_start.lua
    Descriptions: implments a start state
--]]
local state = require("game.state.state")

---@class start_state
local start_state = {}
setmetatable(start_state, state)
start_state.name = "start"

function start_state:state_next(res)

    if res.act ~= nil then
    
    end

    return "load"
end

return start_state
