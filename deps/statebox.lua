local getmetatable, setmetatable, error, next, pairs =
      getmetatable, setmetatable, error, next, pairs

--[[
  A table which can not assign data directly, to project data from modified unconscious
]]
local _M = {}

-- check if one table is an sub table of another table, deeply, of course.
local function canModify(t1, t2)
  local _ty1, _ty2 = type(t1), type(t2)
  if _ty1 ~= 'table' or _ty2 ~= 'table' then
    return false
  end
  local function _issub(t1, t2)
    for k1, v1 in pairs(t1) do
      local v2 = t2[k1]
      if v2 == nil then return false end
      if type(v1) == 'table' then
        if type(v2) ~= 'table' then return false end
        if not _issub(v1, v2) then return false end
      end
    end
    return true
  end
  return _issub(t1, t2)
end

-- assign value from t1 --> t2
local function assign(t1, t2)
  for k, v1 in pairs(t1, t2) do
    if type(v1) ~= 'table' then
      t2[k] = v1
    else
      local v2 = t2[k]
      assign(v1, v2)
    end
  end
end

function _M.new(name, description)
  return setmetatable({
    NAME = name,
    DESCRIPTION = description
  }, {
    __index = {
      -- override all data to the given key
      set = function(self, tbl)
        if type(tbl) ~= 'table' or next(tbl) == nil then
          return
        end
        local meta = getmetatable(self).__index
        for k, v in pairs(tbl) do
          if type(k) ~= 'number' and k ~= 'set' and k ~= 'modify' then
            meta[k] = v
          end
        end
      end,

      -- modify data that which key is already exists
      modify = function(self, tbl)
        if type(tbl) ~= 'table' or next(tbl) == nil then
          return
        end
        local meta = getmetatable(self).__index
        -- check if the top level key of tbl is valid
        for k, v in pairs(tbl) do
          if type(k) == 'number' or k == 'set' or k == 'modify' then
            return
          end
        end
        -- check if self can modify or not
        if not canModify(tbl, meta) then
          error('modify err: invaild or unexpected key!')
        end
        assign(tbl, meta)
      end
    },
    __newindex = function()
      error([[cannot modify data directly in a state box,
            use foo:set({k = v}) or foo:modify({k = v}) instead.]])
    end
  })
end


-------------------------------------------------------------------------
return _M