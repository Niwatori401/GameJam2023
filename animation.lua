

animation = {}


animation.linear_interpolate = function (initial, final, start_time, seconds_to_finish, cur_time)
    if (cur_time - start_time >= seconds_to_finish) then
        return final
    end

    local percent_complete = (cur_time - start_time) / seconds_to_finish

    local new_value = initial + percent_complete * (final - initial)

    return new_value
end




