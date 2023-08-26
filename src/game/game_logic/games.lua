
local level_select = require("game.game_logic.game_level_select")
local puzzle_bobble = require("game.game_logic.game_puzzle_bobble")
local splash_screen = require("game.game_logic.game_splash")
local main_menu = require("game.game_logic.game_main_menu")
local tutorial_game = require("game.game_logic.game_tutorial")


local games = {}

games.level_select = level_select
games.puzzle_bobble = puzzle_bobble
games.splash_screen = splash_screen
games.main_menu = main_menu
games.tutorial = tutorial_game

return games
