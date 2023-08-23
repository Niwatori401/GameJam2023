--[[
    File: states.lua
    Purpose: provides some of the interfaces for states that other state files should
        set the meta table for.
--]]

local response = require("game.state.request")

---@class state
local state = {}
state.__index = state
state.actions = {}
state.name = "default"



--- Intelligently chooses the next state based on context from the request. It should look at the request, and either
--- take it itself, or pass it to a new state with the parameter given
---@param request request
---@return string
function state:process_request(request)
    return self.name
end


function state:next_state(request)
    if request.status == "game_success" or
    request.status == "game_failure" or
    request.status == "abort_level" or
    request.status == "unconditional_load" or
    request.status == "reload_level" then
        return "load"
    end

    return "empty"
end



return state
