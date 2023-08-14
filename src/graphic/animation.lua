

animation = {}

animation.make_animation = function (initial, final, start_time, seconds_to_finish, scheme)
    local result = {}

    result.initial = initial
    result.final = final
    result.start_time = start_time
    result.seconds_to_finish = seconds_to_finish
    result.scheme = scheme
    result.is_stale = false

    return result
end


animation.scheme_linear_interpolate = function (initial, final, start_time, seconds_to_finish, cur_time)
    if (cur_time - start_time >= seconds_to_finish) then
        return final
    end

    local percent_complete = (cur_time - start_time) / seconds_to_finish

    local new_value = initial + percent_complete * (final - initial)

    return new_value
end






