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
---@param points number | nil
---@return character
function character:new(name, sprite, images, stages, points, dialogue)
    local new_character = {}
    setmetatable(new_character, self)

    new_character.dialogue = dialogue
    new_character.dialogue_index = {}

    for stage, _ in ipairs(new_character.dialogue) do
        new_character.dialogue_index[stage] = 1
    end


    new_character.name = name or "Pea Tear Griffin"
    new_character.images = images or data.defaults.missing_image
    new_character.stages = stages or {0}
    new_character.points = points or 120
    new_character.max_points = 999999999
    new_character.min_points = 0
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

function character:get_next_dialogue_line()

    local stage_index = self:get_cur_image_stage_index()


    local line_number = self.dialogue_index[stage_index]
    local line_text = self.dialogue[stage_index][line_number]

    if #self.dialogue[stage_index] ~= line_number then
        self.dialogue_index[stage_index] = self.dialogue_index[stage_index] + 1
    end

    return line_text
end


function character:add_points(amount)

    self.points = self.points + amount

    if self.points < self.min_points then
        self.points = self.min_points
    elseif self.points > self.max_points then
        self.points = max_points
    end

    self:update_sprite_image()
end

---Call to add an animation to the character sprites list
function character:animation_enter_screen()
    self.character_sprite:add_animation(animation:new(
        data.window.SCREEN_Y,
        0,
        data.game.game_time,
        0.5,
        animation.scheme_linear_interpolate,
        "y"))
end


function character:animation_leave_screen()
    self.character_sprite:add_animation(animation:new(
        0,
        data.window.SCREEN_Y,
        data.game.game_time,
        2.0,
        animation.scheme_linear_interpolate,
        "y"))
end



---Used to check for the need to update the character sprite with a new image.
function character:update_sprite_image()
    self.character_sprite.image = self.images[self:get_cur_image_stage_index()]
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
function character:get_cur_image_stage_index()

    if self.points >= tonumber(self.stages[#self.stages]) then
        return #self.stages
    end

    local cur_stage_index = 1
    for index, weight in ipairs(self.stages) do
        if self.points < tonumber(weight) then
            break
        end

        cur_stage_index = index
    end

    return cur_stage_index
end


return character
