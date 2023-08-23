

---@class request
---@field type string
local request = {}
---@param caller any
---@param status "game_success" | "game_failure" | "abort_level" | "reload_level" | "unconditional_load"
---@param payload table | nil
function request:new(caller, status, payload)
    local new_request = setmetatable({}, {__index = request})
    new_request.status = status
    new_request.caller = caller
    new_request.payload = payload
    return new_request
end


return request
