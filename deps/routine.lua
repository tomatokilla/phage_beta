--[[
  Author: benmooo
  Date: 2018/07/18
  This module returns a 'routine map' which is a table that represent the 'routine'.
  Caveat:
    each routine in the routine map must be an array. e.g.
    local routineMap = Routine:new({
      routine1 = {
        'have breakfast',
        'have lunch',
        'have dinner',
      },
      routine2 = {
        'foo',
        'bar',
      }, ...
    })
]]

local Object = require('core').Object
local util   = require('util')

local type, pairs, next = 
      type, pairs, next 

local isarray, shuffle = util.isarray, util.shuffle


------------------------------------------------
local _M = Object:extend()

function _M:initialize(map)
  self.map = map
end


function _M:checkMap()
  local map = self.map
  local ok, errMsg = true, 'invalid routine map!'
  if type(map) ~= 'table' or next(map) == nil then
    ok = false
  else
    for k, v in pairs(map) do
      if type(k) ~= 'string' or not isarray(v) then
        ok = false break
      end
    end
  end
  return ok, ok and '' or errMsg
end

function _M:shuffleMapList(listname)
  shuffle(self.map[listname])
end


-- Return
return _M