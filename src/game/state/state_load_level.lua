---@diagnostic disable: duplicate-set-field
--[[
    File: state_load_level.lua
    Descriptions: implments an empty state
--]]
local state = require("game.state.state_base")
local level_manager = require("game.level.level_manager")


local load_level_state = setmetatable({}, {__index = state})


function load_level_state:new()
    local new_lls = setmetatable({}, {__index = load_level_state})
    new_lls.name = "load"
    return new_lls
end


---@param request request
---@return string
function load_level_state:process_request(request)

    if request.status == "game_success" then
        -- submit scores etc
        level_manager:load_level("_level_select")
    elseif request.status == "unconditional_load" then
        level_manager:load_level(request.payload.level_to_load)

    elseif request.status ==  "game_failure" or request.status == "abort_level" then
        -- return to some menu level without submitting scores
        level_manager:load_level("_level_select")

    elseif  request.status == "reload_level" then
        if request.caller.name ~= nil then
            level_manager:load_level(request.caller.name)
        else
            level_manager:load_level("_level_select")
        end
    end

    return self.name
end


return load_level_state
