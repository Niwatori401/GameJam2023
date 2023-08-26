
local level_select = require("game.game_logic.game_level_select")
local puzzle_bobble = require("game.game_logic.game_puzzle_bobble")
local splash_screen = require("game.game_logic.game_splash")

local games = {}

games.level_select = level_select
games.puzzle_bobble = puzzle_bobble
games.splash_screen = splash_screen

return games
