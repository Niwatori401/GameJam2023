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

-- consumes action functions for the state to run
---@param action function
function state:add_action(action)
    table.insert(self.actions, action)
end

-- runs the actions in the actions sub table
function state:run_state()
    for _, act in ipairs(self.actions) do
        act()
    end
end

function state:next_state(res)
    return self.name
end

-- example of a consumable function, takes no arugments for now.
local function action_nothing()
    return nil
end

return state