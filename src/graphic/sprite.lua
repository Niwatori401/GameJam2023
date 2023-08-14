
sprite = {}


---@param image drawable
---@param x number
---@param y number
---@param scale_x number
---@param scale_y number
---@param layer number Can be between 1-9
---@param rotation number
---@param color table In format {R,G,B,A}
---@return table
sprite.make_sprite = function (image, x, y, scale_x, scale_y, layer, rotation, color)
    local result = {}

    result.image = image
    result.x = x
    result.y = y
    result.x_scale = scale_x
    result.y_scale = scale_y
    result.layer = layer
    result.animations = {}
    result.rotation = rotation
    result.color = color


    return result
end

---@param sprite sprite
---@param animation animation
sprite.add_animation_to_sprite = function (sprite, animation)
    table.insert(sprite.animations, animation)
end


---@param sprite sprite
---@param cur_time number
sprite.remove_stale_animations = function(sprite, cur_time)
    local any_stale = false
    for _, a in pairs(sprite.animations) do
        if (cur_time - a.start_time >= a.seconds_to_finish) then
            any_stale = true
            a.is_stale = true
        end
    end

    if not any_stale then
        return
    end

    local new_animations
    for _, a in pairs(sprite.animations) do
        if not a.is_stale then
            table.insert(new_animations, a)
        end
    end

    sprite.animations = new_animations
end
