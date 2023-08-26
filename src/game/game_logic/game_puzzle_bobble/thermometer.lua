local data = require("data")
local animation = require("graphic.animation")

local thermometer = {}

function thermometer:new(sprite, background_image, current_amount, color, stages, thud_sound, crash_sound, broken_container_image, broken_background_image)

    local new_therm = setmetatable({}, {__index = thermometer})

    self.thud_sound = thud_sound
    self.crash_sound = crash_sound
    self.background_image = background_image
    self.background_image_broken = broken_background_image
    self.foreground_image_broken = broken_container_image

    self.lowest_point_amount = stages[1] - 10
    self.sprite = sprite
    self.fluid_color = color
    self.max_amount_index = 3 > #stages and #stages or 3
    self.current_amount = current_amount
    self.stages = stages

    return new_therm
end

function thermometer:draw(layer)

    if self.broken then

    end


    -- Thermometer background
    love.graphics.setColor(self.sprite.color)
    love.graphics.draw(
        self.broken == nil and self.background_image or self.background_image_broken,
        self.sprite.x,
        self.sprite.y,
        0,
        self.sprite.x_scale,
        self.sprite.y_scale)

    -- circle at base
    local circle_center_x = self.sprite.x + 64 * self.sprite.x_scale
    local circle_center_y = self.sprite.y + 957 * self.sprite.y_scale
    local circle_radius = 54 * self.sprite.y_scale
    love.graphics.setColor(self.fluid_color)
    love.graphics.circle("fill", circle_center_x, circle_center_y, circle_radius)

    -- Rectangular fill
    local total_possible_height = 879 * self.sprite.y_scale
    local rectangle_height = total_possible_height * ((self.current_amount - self.lowest_point_amount) / ( self:get_max_amount() - self.lowest_point_amount))
    local rectangle_width = 70 * self.sprite.x_scale
    local rectangle_x = 28 * self.sprite.x_scale + self.sprite.x
    local rectangle_y = self.sprite.y + (914 * self.sprite.y_scale - rectangle_height)

    love.graphics.rectangle("fill", rectangle_x, rectangle_y, rectangle_width, rectangle_height)

    -- Numbers


    for i, stage in ipairs(self.stages) do
        if tonumber(stage) < self:get_max_amount() then
            love.graphics.setColor(data.color.COLOR_BLACK)
            local thermometer_y_offset = 30 -- This is a hacky solution to get the numbers to align right
            local y_coord =
                (1 - ((tonumber(stage) - self.lowest_point_amount) / (self:get_max_amount() - self.lowest_point_amount))) *
                total_possible_height +
                thermometer_y_offset

            local x_coord = 28 * self.sprite.x_scale + self.sprite.x + 4
            love.graphics.rectangle(
                "fill",
                x_coord,
                y_coord,
                rectangle_width / 3,
                5)

            if i == #self.stages then
                love.graphics.setColor(data.color.COLOR_DARK_RED)
                love.graphics.print("MAX", x_coord, y_coord + 3, 0, 1.2, 1.2)
            else
                love.graphics.setColor(data.color.COLOR_BLACK)
                love.graphics.print(stage, x_coord, y_coord + 3, 0, 1, 1)
            end
        end
    end


    -- Thermometer frame

    love.graphics.setColor(self.sprite.color)
    love.graphics.draw(
        self.broken == nil and self.sprite.image or self.foreground_image_broken,
        self.sprite.x,
        self.sprite.y,
        0,
        self.sprite.x_scale,
        self.sprite.y_scale)
end

function thermometer:get_max_amount()
    return self.stages[self.max_amount_index] + 10
end

function thermometer:update(dt)
    for _, a in pairs(self.sprite.animations) do repeat

        if a.property_to_animate == "current_amount" then
            if self.broken then
                break -- continue
            end

            self[a.property_to_animate] = a:increment_animation(data.game.game_time)

            if self.current_amount > tonumber(self.stages[#self.stages]) then
                self.broken = true
                love.audio.play(self.crash_sound)
                self.sprite:add_animation(animation:new(self.sprite.x, self.sprite.x + 5, data.game.game_time, 0.08, animation.scheme_cycle_5, "x"))
            end

            if self.current_amount >= self:get_max_amount() then
                for index, value in ipairs(self.stages) do
                    if self.current_amount < tonumber(value) + 10 then
                        self.max_amount_index = index

                        love.audio.play(self.thud_sound)
                        self.sprite:add_animation(animation:new(self.sprite.x, self.sprite.x + 5, data.game.game_time, 0.08, animation.scheme_cycle_5, "x"))
                        break
                    end
                end
            end
        else
            self.sprite[a.property_to_animate] = a:increment_animation(data.game.game_time)
        end
    until true end
end

-- function thermometer:set_max_amount(amt)
--     self.max_amount = amt
-- end


function thermometer:add_amount_to_current(amt)
    local current_target = nil
    local animation_index = nil
    for key, animation in pairs(self.sprite.animations) do
        if animation.property_to_animate == "current_amount" then
            current_target = animation.final
            animation_index = key
        end
    end

    if current_target ~= nil then
        self.sprite.animations[animation_index] = animation:new(self.current_amount, current_target + amt, data.game.game_time, 1, function (animation)
            return ((2*animation:scheme_root_interpolate() + animation:scheme_linear_interpolate()) / 3)
        end, "current_amount")
    else
        table.insert(self.sprite.animations, animation:new(self.current_amount, self.current_amount + amt, data.game.game_time, 1, function (animation)
            return ((2*animation:scheme_root_interpolate() + animation:scheme_linear_interpolate()) / 3)
        end, "current_amount"))
    end

end


return thermometer
