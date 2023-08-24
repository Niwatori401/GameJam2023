
local bobble = {}



function bobble:new(pos_x, pos_y, velocity_x, velocity_y)
    local new_bobble = setmetatable({}, {__index = bobble})

    new_bobble.pos_x = pos_x
    new_bobble.pos_y = pos_y
    new_bobble.velocity_x = velocity_x
    new_bobble.velocity_y = velocity_y

    return new_bobble
end





return bobble
