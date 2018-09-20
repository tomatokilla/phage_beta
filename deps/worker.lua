--[[
  Worker:
]]

local Object = require('core').Object
local util = require('util')
local withHandler = require('action_wrapper').withHandler


local type, pairs, next =
      type, pairs, next

local _M = Object:extend()

function _M:initialize(job, tasks)
  self.job   = job
  self.tasks = tasks
end

function _M:wrapTaskActionsWithHandler(handler)
  for i, task in pairs(self.tasks) do
    task.action = withHandler(handler)(task.action, task.pages)
  end
end

function _M:checkTasks()
end













-----------------------------------------------------
return _M