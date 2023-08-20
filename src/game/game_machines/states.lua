--[[
    File: states.lua
--]]

---@class state
local state = {}
state.__index = state
state.actions = {}

--empty state, nothing fun here
function state:empty()
    local t = {}
    setmetatable(t, self)

    return t
end

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

-- example of a consumable function, takes no arugments for now.
local function action_nothing()
    return nil
end

return state