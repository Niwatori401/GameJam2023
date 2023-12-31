local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
local data = require("data")

local bobble = {}



function bobble:new(bobble_type, bobble_image, pos_x, pos_y, velocity_x, velocity_y)
    local new_bobble = setmetatable({}, {__index = bobble})

    new_bobble.bobble_type = bobble_type
    new_bobble.should_pop = false

    new_bobble.sprite = sprite:new(
        bobble_image,
        pos_x,
        pos_y,
        1,
        1,
        render_layer.BOBBLES,
        0,
        data.color.COLOR_WHITE)


    new_bobble.velocity_x = velocity_x
    new_bobble.velocity_y = velocity_y

    return new_bobble
end

function bobble:draw()

end


function bobble:pop()

end




return bobble
