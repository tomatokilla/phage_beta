--[[
  Worker:
]]

local Object = require('core').Object
local util = require('util')
local withHandler = require('action_wrapper').withHandler


local type, pairs, next =
      type, pairs, next

local _M = Object:extend()

function _M:initialize(job, actions, handler)
  self.job = job
  self.actions = actions
  self.handler = handler
  self.hooks = {}
  self.state   = StateBox.new()
end

function _M:initState(_state)
  self.state:set(_state)
end

-- Return a function that wraps the func of actions
local function wrap(identify, func)
  return function(...)
    -- check if th
    local ok, err = identify(...)
    if not ok then return ok, err end
    -- hooks goes here
    func()
  end
end

-- action hooks
function _M:willAct()
  local ok, errMsg = true
  -- function goes here
  return ok, errMsg
end

function _M:didAct()
  local ok, errMsg = true
  -- function goes here
  return ok, errMsg
end

function _M:exe(task, step)
  
end

















-----------------------------------------------------
return _M