local data = require "data"

---@class sprite
sprite = {}
sprite.__index = sprite

---@param image love.Image
---@param x number
---@param y number
---@param scale_x number
---@param scale_y number
---@param layer number Can be between 1-9
---@param rotation number
---@param color table In format {R,G,B,A}
---@return table
function sprite:new(image, x, y, scale_x, scale_y, layer, rotation, color)
    local result = {}
    setmetatable(result, sprite)

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

---The prefered way to add animations to sprites
---It will remove sprites that are already in the sprite if they animate the same property
---Additionally, it will check for and remove stale sprites upon adding a new one
---@param animation animation
function sprite:add_animation(animation)
    table.insert(self.animations, animation)
    self:remove_duplicate_animations(data.game.game_time, animation)
    self:remove_stale_animations(data.game.game_time)
end


function sprite:remove_stale_animations(cur_time)
    local any_stale = false
    for _, a in pairs(self.animations) do
        if (cur_time - a.start_time >= a.seconds_to_finish) then
            any_stale = true
            a.is_stale = true
        end
    end

    if not any_stale then
        return
    end

    local new_animations = {}
    for _, a in pairs(self.animations) do
        if not a.is_stale then
            table.insert(new_animations, a)
        end
    end

    self.animations = new_animations
end

---Removes animations which have a tag shared with the tag_param
---@param cur_time number
---@param tag_param any
function sprite:remove_duplicate_animations(cur_time, animation)
    local tag_param = animation.property_to_animate
    local animation_id = animation.id
    local any_bad_anims = false
    for _, a in pairs(self.animations) do
        if (a.property_to_animate == tag_param and a.id ~= animation_id) then
            any_bad_anims = true
            a.is_stale = true
        end
    end

    if not any_bad_anims then
        return
    end

    local new_animations = {}
    for _, a in pairs(self.animations) do
        if not a.is_stale then
            table.insert(new_animations, a)
        end
    end

    self.animations = new_animations
end


return sprite
