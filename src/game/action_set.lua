


local action_set = {}
action_set.__index = action_set


function action_set:new()
    local new_set = {}
    setmetatable(new_set, action_set)
    new_set.actions = {}
    return new_set
end


function action_set:add_key_action(key, action)
    if self.actions[key] == nil then
        self.actions[key] = {}
    end

    table.insert(self.actions[key], action)
end

function action_set:do_all_applicable_actions(key, params)
    if self.actions[key] == nil then
        return
    end

    for _, action in pairs(self.actions[key]) do
        action(unpack(params))
    end
end

return action_set
