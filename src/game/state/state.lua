--[[
    File: states.lua
    Purpose: provides some of the interfaces for states that other state files should
        set the meta table for.
--]]

---@class state
local state = {}
state.__index = state
state.actions = {}
state.name = "default"

---@class action
---@field action function
---@field params table

-- consumes action functions for the state to run
---@param action action
function state:add_action(action)
    table.insert(self.actions, action)
end

-- runs the actions in the actions sub table
function state:run_state()
    for _, act in ipairs(self.actions) do
        act.action(unpack(act.params))
    end
end

---@class res
---@field act "exit" | "repeat" | "next"
---@field actval any

--loads additional info into the state
---@param res res
function state:load_state(res)
    
end

---comment
---@param res res
---@return string
function state:next_state(res)

    -- should go to the load level of the level select level
    if res.act ~= nil then
        if res.act == "exit" then
            return self:state_exit(res) -- maybe should have an "exit" state that closes the game
        end
        if res.act == "repeat" then
            return self:state_repeat(res)
        end
        if res.act == "next" then
            return self:state_repeat(res)
        end
    end 

    -- if the res is empty, assume to repeat to self.
    return self.name
end

function state:state_exit(res)
    return self.name
end

function state:state_next(res)
    return self.name
end

function state:state_repeat(res)
    return self.name
end

-- example of a consumable function, takes no arugments for now.
local function action_nothing()
    return nil
end

return state
