--[[
  Worker:
]]

local Object = require('core').Object
local util = require('util')
local Collection = require('collection')
local withHandler = require('action_wrapper').withHandler


local type, pairs, next =
      type, pairs, next

local _M = Object:extend()

function _M:initialize(job, tasks)
  self.job   = job
  self.tasks = tasks
  self.__collection = Collection:new()
end

function _M:wrapTaskActionsWithHandler(handler)
  for i, task in pairs(self.tasks) do
    self[task] = withHandler(handler)(task.action, task.pages)
  end
end




-----------------------------------------------------
return _M
