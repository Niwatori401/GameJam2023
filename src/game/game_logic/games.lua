local main_menu = require("game.game_logic.main_menu")
local level_select = require("game.game_logic.game_level_select")
local puzzle_bobble = require("game.game_logic.game_puzzle_bobble")


local games = {}

games.main_menu = main_menu
games.level_select = level_select
games.puzzle_bobble = puzzle_bobble

return games
