-- add states from files here
local empty = require("game.state.state_empty")
local load = require("game.state.state_load_level")
local base = require("game.state.state_base")

local states = {}

-- add states to add into the state machine here
states.empty = empty
--states.start = start
states.load = load
--states.game = game
states.base = base

return states
