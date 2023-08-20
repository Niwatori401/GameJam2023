--[[
    File: machine.lua
    File that contains the basic state machine used for game transistion logic
    refer to states
--]]

local states = require("game.game_machines.states")

--#region Machine
---@class game_machine
local game_machine = {}
game_machine.state = states:empty()
game_machine.next_state = states:empty()

--#endregion

--#region MachineMethods

function game_machine:run()
    self.state:run_state()
end

---@param state state
function game_machine:set_next(state)
    --TODO: needs to verify that state is actually a state before assigning
    self.next_state = state
end

-- makes the next state the current state, sets next state to the empty state
function game_machine:transition_state()
    self.state = self.next_state
    self.next_state = states:empty()
end

--#endregion


return game_machine