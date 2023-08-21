utility = {}
utility.sleep = function (time_seconds)
    if (love.system.getOS() == "Windows") then
        os.execute("timeout /t " .. time_seconds)
    else
        os.execute("sleep " .. time_seconds)
    end
end


utility.load_text = function (relative_path)
    local text = {}

    for line in love.filesystem.lines(relative_path) do
        text[#text + 1] = line
    end

    return text
end

utility.parse_info = function (text_lines)
    local result = {}

    for _, line in pairs(text_lines) do
        local equal_index = string.find(line, "=")
        local first_half = string.sub(line, 0, equal_index - 1)
        local second_half = string.sub(line, equal_index + 1)

        result[first_half] = second_half
    end

    return result
end

utility.load_image = function (relative_path)
    return love.graphics.newImage(relative_path)
end

utility.load_music = function (relative_path)
    return love.audio.newSource(relative_path, "stream")
end

utility.load_sfx = function (relative_path)
    return love.audio.newSource(relative_path, "static")
end
