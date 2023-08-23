--[[
    File: machine.lua
    File that contains the basic state machine used for game transistion logic
    refer to states
--]]

local states = require("game.state.states")

--#region Machine
---@class game_machine
local game_machine = {}
game_machine.states = {}
game_machine.current_state = states.load

--#endregion

--#region MachineMethods
---@param start_state string
function game_machine:init(start_state)
    self.current_state = states[start_state]
end


---Selects appropriate state to handle request, then processes request
---@param request request
function game_machine:transition_state(request)
    if request ~= nil then
        self.current_state = states[self.current_state:next_state(request)]
        self.current_state:process_request(request)
    end
end

--#endregion


return game_machine
