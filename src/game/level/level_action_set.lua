


local level_action_set = {}
level_action_set.__index = level_action_set


function level_action_set:new()
    local new_set = {}
    setmetatable(new_set, level_action_set)
    new_set.actions = {}
    return new_set
end


function level_action_set:add_key_action(key, action)
    if self.actions[key] == nil then
        self.actions[key] = {}
    end

    table.insert(self.actions[key], action)
end

function level_action_set:do_all_applicable_actions(key, level)
    if self.actions[key] == nil then
        return
    end

    for _, action in pairs(self.actions[key]) do
        action(level)
    end
end

return level_action_set
