--[[
  Author: benmooo
  Date: 2018/07/18
  Returns a function which will wrap the given action(function) with few items:
    1. first check if the 
]]


-- to be improved..
local function withHandler(handler)
  return function(action, pages)
    return function()
      -- local ok, msg = 
      local res = handler(pages)
      if res.ok then action() return {ok = true, ''} end
      return {ok = false, 'err'}
    end
  end
end

local function withMonitor(monitor)
  return function(action, ...)
    monitor(action, ...)
  end
end

return {
  withHandler = withHandler,
  withMonitor = withMonitor,
}