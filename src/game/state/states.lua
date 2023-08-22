-- add states from files here
local empty = require("game.state.state_empty")
local start = require("game.state.state_start")
local load = require("game.state.state_load_level")
local game = require("game.state.state_game")

local states = {}

-- add states to add into the state machine here
states.empty = empty
states.start = start
states.load = load
states.game = game

return states
