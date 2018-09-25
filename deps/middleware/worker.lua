--[[
  Worker:
]]

local Object = require('core').Object
local util = require('util')
local Collection = require('collection')
local withHandler = require('action_wrapper').withHandler
local handlers = require('handlers')
local popups = require('popups')


-- handle popups
local function handler1(pages)
  return handlers.handlePopups(popups, pages)
end


local _M = Object:extend()

function _M:initialize(job, tasks)
  self.job   = job
  self.tasks = tasks
  self._collection = Collection:new()
end

function _M:wrapTaskActionsWithHandler(handler)
  for i, task in pairs(self.tasks) do
    self[task] = withHandler(handler1)(task.action, task.pages)
  end
end




-----------------------------------------------------
return _M
