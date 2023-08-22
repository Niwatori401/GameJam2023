--[[
    File: state_load_level.lua
    Descriptions: implments an empty state
--]]
local state = require("game.state.state")
local LM = require("game.level.level_manager")

---@class load_level_state
local load_level_state = {}
setmetatable(load_level_state, state)
load_level_state.name = "load"
load_level_state.level = "_level_select"

function load_level_state:load_state(res)
    if res.actval ~= nil then
        load_level_state.level = res.actval
    end
end

function load_level_state:state_exit(res)
    return "start"
end

load_level_state:add_action({action=LM.load_level,params={LM, load_level_state.level}})

return load_level_state