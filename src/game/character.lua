local data = require("data")
local sprite = require("graphic.sprite")
local animation = require("graphic.animation")


---@class character
local character = {}
character.__index = character



---@param name string | nil
---@param sprite sprite
---@param images table table of images, indexed by normal indices
---@param stages table array of stage numbers from lowest to highest, indexed by normal indices
---@param cur_weight number | nil
---@return character
function character:new(name, sprite, images, stages, cur_weight)
    local new_character = {}
    setmetatable(new_character, self)

    new_character.name = name or "Pea Tear Griffin"
    new_character.images = images or data.defaults.missing_image
    new_character.stages = stages or {0}
    new_character.cur_weight = cur_weight or 120

    new_character.character_sprite = sprite
    new_character:update_sprite_image()

    return new_character
end


---Characters sprites are defined to be the size of the whole screen, though most should be mostly transparent.
function character:draw(layer)
    local s = self.character_sprite

    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y,
            s.rotation,
            s.x_scale * data.window.SCREEN_X / s.image:getWidth(),
            s.y_scale * data.window.SCREEN_Y / s.image:getHeight()
        )
    end
end

---Call to add an animation to the character sprites list
function character:animation_enter_screen()
    self.character_sprite:add_animation(animation:new(
        data.window.SCREEN_Y,
        0,
        data.game.game_time,
        0.5,
        animation.scheme_linear_interpolate,
        data.game.game_time,
        "y"))
end


function character:animation_leave_screen()
    self.character_sprite:add_animation(animation:new(
        0,
        data.window.SCREEN_Y,
        data.game.game_time,
        2.0,
        animation.scheme_linear_interpolate,
        data.game.game_time,
        "y"))
end



---Used to check for the need to update the character sprite with a new image.
function character:update_sprite_image()
    self.character_sprite.image = self.images[self:_get_cur_image_stage_index()]
end


---Used to tell the character to progress its animations
function character:update_animations()
    self:_update_all_animations_for_sprite(self.character_sprite, data.game.game_time)
end


---Given a sprite, update all of its animations by passing in the time since last change.
---@param s sprite
---@param cur_time number
function character:_update_all_animations_for_sprite(s, cur_time)
    for _, animation in pairs(s.animations) do

        local new_value = animation:increment_animation(cur_time)

        s[animation.property_to_animate] = new_value

    end
end

---Gets the index of the sprites for the given character weight
---@return integer
function character:_get_cur_image_stage_index()

    if self.cur_weight >= tonumber(self.stages[#self.stages]) then
        return #self.stages
    end

    local cur_stage_index = 1
    for index, weight in ipairs(self.stages) do
        if self.cur_weight < tonumber(weight) then
            break
        end

        cur_stage_index = index
    end

    return cur_stage_index
end


return character
