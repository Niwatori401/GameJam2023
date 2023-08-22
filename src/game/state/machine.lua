--[[
    File: machine.lua
    File that contains the basic state machine used for game transistion logic
    refer to states
--]]

local states = require("game.state.state")

--#region Machine
---@class game_machine
local game_machine = {}
game_machine.states = {}
game_machine.current_state = states.start

--#endregion

--#region MachineMethods
---@param start_state string
function game_machine:init(start_state)
    self.current_state = states[start_state]

end

function game_machine:run_single()
    self.state:run_state()
end

-- makes the next state the current state, sets next state to the empty state
function game_machine:transition_state(res)
    self.state = self.states[self.state:next_state(res)]
    self.state:run_state()
end

--#endregion


return game_machine
