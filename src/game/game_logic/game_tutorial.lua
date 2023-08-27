
local game_puzzle_bobble = require("game.game_logic.game_puzzle_bobble")
local animation = require("graphic.animation")
local data = require("data")
local game = require("game.game_logic.game")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
local action_set = require("game.action_set")
local bobble = require("game.game_logic.game_puzzle_bobble.bobble")
local thermometer = require("game.game_logic.game_puzzle_bobble.thermometer")

local game_tutorial = setmetatable({}, {__index = game_puzzle_bobble})


function game_tutorial:new(game_data, level)
    local new_game = setmetatable({}, {__index = game_tutorial})

    new_game.game_width = 380
    new_game.game_height = 540
    new_game.game_x = 610
    new_game.game_y = 15
    new_game.level = level
    new_game.grid = {}
    new_game.current_bobble = nil

    new_game.time_since_last_dialogue_update = 0
    new_game.time_between_dialogue_updates = 5
    new_game.cached_dialogue = nil
    new_game.game_over = false
    new_game.winner = false

    new_game:_load_bobble_images(game_data)
    new_game:_load_food_images(game_data)

    new_game.thermometer = thermometer:new(
        sprite:new(game_data["thermometer_base"],
        450,
        0,
        data.window.SCREEN_Y / game_data["thermometer_base"]:getHeight(),
        data.window.SCREEN_Y / game_data["thermometer_base"]:getHeight(),
        render_layer.GAME_BG,
        0,
        data.color.COLOR_WHITE),
        game_data["thermometer_back"],
        new_game.level.character.points,
        data.color.BERY_NICE_PINK,
        new_game.level.character.stages,
        game_data["thud"],
        game_data["break"],
        game_data["thermometer_base_broken"],
        game_data["thermometer_back_broken"])

    new_game.next_bobble_index = math.random(#new_game.bobble_images)
    new_game:_make_textbox_sprite(game_data)
    new_game:_set_up_game_rules(game_data)
    new_game:_set_initial_bobble_rows()
    new_game:_make_audio_fx(game_data)
    new_game:_make_shooter_sprites(game_data)
    new_game:_make_game_bg_sprite(game_data)
    new_game:_make_win_scene_assets(game_data)
    new_game:_define_level_actions()
    new_game:_define_level_inputs()
    new_game:_define_level_release_actions()

    new_game.started_playing_time = data.game.game_time


    return new_game
end


function game_tutorial:_should_show_text_box()
    return true
end



return game_tutorial
