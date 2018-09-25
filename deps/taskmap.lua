local Object = require('core').Object
local isarray = require('util').isarray

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

local function isValidTaskMap(map)
  if not isarray(map) then return false end
  for i, v in pairs(map) do
    if type(v) ~= 'table' then return false end
    if v.taskname == nil then return false end
  end
  return true
end


local _M = Object:extend()


function _M:initialize(map)
  self.map = map
end


function _M:checkMap()
  local ok, errmsg = true, 'invalid taskmap schema!'
  local map = self.map
  if not isValidTaskMap(map) then
    ok = false
  else
    for i, v in pairs(map) do
      map[i] = {
        id = i,
        taskname = v.taskname,
        times = v.times or 1,
        descrption = v.descrption or 'null'
      }
    end
  end
  return ok, ok and '' or errmsg
end


------------------------------------------------------
return _M
