local getmetatable, setmetatable, error, next, pairs =
      getmetatable, setmetatable, error, next, pairs

--[[
  A table which can not assign data directly, to project data from modified unconscious
]]
local _M = {}

function _M.new(name, description)
  return setmetatable({
    NAME = name,
    DESCRIPTION = description
  }, {
    __index = {
      set = function(self, tbl)
        if type(tbl) ~= 'table' or next(tbl) == nil then
          return
        end
        local meta = getmetatable(self).__index
        for k, v in pairs(tbl) do
          if type(k) ~= 'number' and k ~= 'set' then
            meta[k] = v
          end
        end
      end
    },
    __newindex = function()
      error('cannot modify data directly in a state box, use foo:set(k, v) instead ..')
    end
  })
end


-------------------------------------------------------------------------
return _M

