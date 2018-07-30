local Object = require('core').Object

local type, error, pairs = type, error, pairs

--[[
  Return a qualified task map for Flow
  local map = _M:new({
    {task = 'foo'},
    {task = 'bar'},
    {task = 'baz'},
  })
  and then:
    map => {
      {id = 1, task = 'foo', descrption = 'null'},
    }
]]
local _M = Object:extend()

local function isArray(t)
  if type(t) ~= 'table' then return false end
  local n = #t
  for k, v in pairs(t) do
    if type(k) ~= 'number' then return false end
    if k > n then return false end
  end
  return true
end

local function isValidMap(map)
  if not isArray(map) then
    return false
  end
  for i, v in pairs(map) do
    if type(v) ~= 'table' then return false end
    if v.task == nil then return false end
  end
  return true
end

function _M:initialize(map)
  if not isValidMap(map) then
    error([[invalid map schema or the key {task} didnot provided!]])
  end
  for i, v in pairs(map) do
    self[i] = {
      id = i,
      task = v.task,
      descrption = v.descrption or "null"
    }
  end
end


------------------------------------------------------
return _M