--[[
  Collecting data while worker is working
]]

local Object = require('core').Object

local pairs, type = 
      pairs, type

local _M = Object:extend()

function _M:initialize(...)
  local bags = {...}
  for _, bag in pairs(bags) do
    self[bag] = {}
  end
end

function _M:createBag(bag)
  if type(bag) == 'string' then
    self[bag] = {}
  end
end

function _M:getBag(bag)
  return self[bag]
end

-- This will override original data if the key in bag already exist
function _M:pickUpScrap(bag, scrap)
  if type(scrap) ~= 'table' then return end
  for k, v in pairs(scrap) do
    self[bag][k] = v
  end
end

function _M:clearBag(...)
  local bags = {...}
  for _, bag in pairs(bags) do
    self[bag] = {}
  end
end

-- 2Be improved..
function _M:peddle(bag, recyclebin)
  local _bag = self[bag]
  self:clearBag(bag)
  recyclebin[bag] = _bag
end


--Return module
return _M