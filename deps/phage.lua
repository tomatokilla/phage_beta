--[[
  Author: benmooo
  Date: 2018/07/18
  Phage: This micro project was designed to formalize our codebase of lua script,
  and trying to find a easier, more effient way to construct our project which is
  ...somthing i wont bother to explain. And .. nothing more.

  This module implements the central phage application object.
]]

local Object      = require('core').Object
local Routine     = require('routine')
local Taskmap     = require('taskmap')
local StrictTbl   = require('strict_table')
local Monitor     = require('monitor')
local util        = require('util')

-- local defaultSettings = require('static.config').defaultSettings


-- Global variables
local type, assert =
      type, assert
local fmt = string.format

-- Module
local _M = Object:extend()


function _M:initialize(routine, task, devicetype, app, appversion)
  assert(
    routine and taskmap and devicetype and app,
    'routine & taskmap & devicetype & app must be provided!'
  )
  self.routine  = Routine:new(routine)
  self.task     = Taskmap:new(task)
  self.info     = {
    DEVICETYPE  = devicetype,
    APP         = app,
    APPVERSION  = appversion or '',
  }
  -- data which stored in a strict tbl
  self.settings = StrictTbl:new()
  self.state    = StrictTbl:new()
  self.monitor  = Monitor:new()
  self.workers  = {}
end

-- initilize state
function _M:initState(state)
  self.state:set(state)
end

-- set state
function _M:setState(state)
  self.state:mod(state)
end

function _M:getState(k)
  return self.state[k]
end

-- init settings
function _M:initSettings(settings)
  self.settings:set(settings)
end

-- modify settings
function _M:setSettings(settings)
  self.settings:mod(settings)
end

-- get settings
function _M:getSettings(settings)
  return self.settings[k]
end

function _M:loadWorker(task, worker)
  self.workers[task] = worker
end

function _M:autoLoadWorkers()
  local info = self.info
  for i, item in pairs(self.task.map) do
    self:loadWorker(
      item.taskname,
      require(fmt('phage.%s.%s.workers.%s', info.DEVICETYPE,
                  info.APP, item.taskname))
    )
  end
end


-- shuffle the routine list
function _M:shuffleRoutineMapList(listname)
  self.routine:shuffleMapList(listname)
end


function _M:getProgressProfile()
  local task  = self:getState('currentTask')
  local index = self:getState('currentTask')
  local step  = self.routine.map[task][index]
  local cycle = self:getState('currentTaskCycleIndex')
  local t_cyc = self:getState('currentTaskTotalCycle')
  return {
    current_task  = task,
    current_index = index,
    current_step  = step,
    current_task_cycle = cycle,
    current_task_total_cycle = t_cyc,
  } 
end

function _M:prepare()
end

function _M:getCurrentProgress()
  return self:getState('currentTask'),
         self:getState('currentIndex'),
         self:getState('cycleIndex')
end

function _M:act()
  local task, index, _loop = self:getCurrentProgress()
  local step = self.routine.map[task][index]
  local res = self.workers[task][step]()
  -- check if has error
  if not res.ok then
    self:setState({err = true, errMsg = res.msg})
  end
end

function _M:resolve()
  -- first check if has error 
  -- if 
  -- second check if the times of task is the last cycle
end

function _M:hasErr()
  return self.getState('err')
end



function _M:run()
  while true do
    -- report the flow node
    self.monitor:reportAndlog()
    -- do the current step of task
    self:act()
    -- resolve what to do next
    if self:hasErr() then
      self.monitor:reportAndlog()
    end
    self:resolve()
  end
end





-- Return
return _M
