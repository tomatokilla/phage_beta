--[[
  Author: benmooo
  A table which can not assign data directly, to project data from modified unconsciously
]]

local Object = require('core').Object
local util = require('util')

local rawset, getmetatable, error = rawset, getmetatable, error
local assign, issubset = util.assign, util.issubset




local _M = Object:extend()

function _M:initialize(name, des)
  getmetatable(self).__newindex = function(self, k, v)
    error([[cannot modify data directly in a state box,
        use foo:set({k = v}) or foo:mod({k = v}) instead.]])
  end
  self:set({_NAME = name, _DESCRIPTION = des})
end

function _M:set(t)
  if type(t) ~= 'table' then error('table expected!') end
  if t.set or t.mod then
    error('key words: set | mod was proteced!')
  end
  for k, v in pairs(t) do
    rawset(self, k, v)
  end
end

function _M:mod(t)
  if type(t) ~= 'table' then error('table expected!') end
  if t.set or t.mod then
    error('key words: set | mod was proteced!')
  end
  if not issubset(t, self) then
    error('modify err: the table u provided is not a subset of the origin table!')
  end
  assign(t, self)
end


-------------------------------------------------------------------------
return _M