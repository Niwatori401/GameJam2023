local data = require("data")


---@class animation
local animation = {}
animation.__index = animation


---Animation factory
---@param initial number
---@param final number
---@param start_time number
---@param seconds_to_finish number
---@param scheme function
---@param cur_time number
---@param property_to_animate string
---@return table
function animation:new(initial, final, start_time, seconds_to_finish, scheme, cur_time, property_to_animate)
    local result = {}
    setmetatable(result, self)

    result.initial = initial
    result.final = final
    result.start_time = start_time
    result.seconds_to_finish = seconds_to_finish
    result.scheme = scheme
    result.is_stale = false

    result.property_to_animate = property_to_animate

    return result
end


function animation:increment_animation()
    return self:scheme()
end



function animation:scheme_linear_interpolate()

    if (data.game.game_time - self.start_time >= self.seconds_to_finish) then
        return self.final
    end

    local percent_complete = (data.game.game_time - self.start_time) / self.seconds_to_finish

    local new_value = self.initial + percent_complete * (self.final - self.initial)

    return new_value
end


return animation



