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
  local task   = self.task.map[1].taskname
  local total  = self.task.map[1].times
  local length = #self.routine.map[task]
  self.state:set({
    hasErr                = false,
    errMsg                = '',
    isTerminal            = false,
    hasFatalErr           = false,
    fatalErrMsg           = '',
    currentStep           = '',
    currentTask           = task,
    currentIndex          = 0,
    currentTaskId         = 1,
    currentTaskLength     = length,
    currentTaskCycleIndex = 1,
    currentTaskTotalCycle = total,
  })
  self.state:set(state)
end

-- set state
function _M:setState(state)
  self.state:set(state)
end

function _M:updateState(state)
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
function _M:set(settings)
  self.settings:set(settings)
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
      require(fmt(
        'phage.%s.%s.workers.%s',
        info.DEVICETYPE, info.APP, item.taskname
      ))
    )
  end
end


-- shuffle the routine list
function _M:shuffleRoutineMapList(listname)
  self.routine:shuffleMapList(listname)
end


function _M:getCurrentProgressProfile()
  return {
    hasErr       = self:getState('hasErr'),
    isTerminal   = self:getState('isTermial'),
    hasFatalErr  = self:getState('hasFatalErr'),
    currentTask  = self:getState('currentTask'),
    currentStep  = self:getState('currentStep'),
    currentIndex = self:getState('currentIndex'),
    currentTaskId         = self:getState('currentTaskId'),
    currentTaskLength     = self:getState('currentTaskLength'),
    currentTaskCycleIndex = self:getState('currentTaskCycleIndex'),
    currentTaskTotalCycle = self:getState('currentTaskTotalCycle'),
  }
end

function _M:prepare()
  local ok, msg
  -- check routine map
  ok, msg = self.routine:checkMap()
  if not ok then
    self:updateState({
      hasFatalErr = true,
      fatalErrMsg = msg})
    return
  end
  -- check task map
  ok, msg = self.task:checkMap()
  if not ok then
    self:updateState({
      hasFatalErr = true,
      fatalErrMsg = msg})
    return
  end
  -- check routine map & task map
  for i, task in pairs(self.task.map) do
    if not self.routine.map[task.taskname] then
      self:updateState({
        hasFatalErr = true,
        fatalErrMsg = 'map of task do not match that in routine!'
      })
      return
    end
  end
  -- check workers
  for _, task in pairs(self.task.map) do
    for i, step in pairs(self.routine.map[task.taskname]) do
      if type(self.workers[task.taskname][step]) ~= 'function' then
        self:updateState({
          hasFatalErr = true,
          fatalErrMsg = 'workers loaded to phage do not match the taskmap'
        })
        return
      end
    end
  end
end


function _M:act()
  local pp = self:getCurrentProgressProfile()
  local res = self.workers[pp.currentTask][pp.currentStep]()
  -- check if has error
  if not res.ok then
    self:setState({hasErr = true, errMsg = res.msg})
  end
end

--[[
  This method will check current state and resolve to what to do next.
  The logic of resolving:
    1. check if has err
      if haserr:
        if isthelastCycle:
          if isthelasttask:
            isterminal!
          else:
            nexttask
        else:
          next cycle
      else:
        if isthelaststep:
          if isthelastCycle:
            if isthelast task:
              isterminal!
            else:
              nexttask
          else:
            nextcycle
        else:
          next index|step
]]
-- it seems that it is a complicated work to figure out what to do next
function _M:resolve()
  local taskmap = self.task.map
  local nextTask,nextCycle, nextIndex, nextStep, isTermial, res
  local pp = self:getCurrentProgressProfile()
  if pp.isTermial or pp.hasFatalErr then return end
  local isthelaststep  = pp.currentIndex == pp.currentTaskLength
  local isthelastcycle = pp.currentTaskCycleIndex ==
                         pp.currentTaskTotalCycle
  local isthelasttask  = #taskmap == pp.currentTaskId
  local function commonResolve()
    if isthelastcycle then
      if isthelasttask then
        isTerminal = true
      else nextTask = true end
    else nextCycle = true end
  end
  if not pp.hasErr then
    if isthelaststep then
      commonResolve()
    else nextIndex = true end
  else commonResolve() end

  return {
    isTermial = isTermial,
    nextTask = nextTask,
    nextCycle = nextCycle,
    nextIndex = nextIndex,
  }
end

function _M:interpretResolve(res)
  local state
  local pp = self:getCurrentProgressProfile()
  local _index = pp.currentIndex
  local _taskId = pp.currentTaskId
  local _task = pp.currentTask
  local _cycle = pp.currentTaskCycleIndex
  if res.isTermial then
    state = {isterminal = true}
  elseif res.nextTask then
    local index, taskId, cycle = 1, _taskId + 1, 1
    local task = self.task.map[taskId].taskname
    local step = self.routine.map[task][index]
    local length = #self.routine.map[task]
    state = {
      hasErr = false,
      currentTask = task,
      currentIndex = index,
      currentStep = step,
      currentTaskId = taskId,
      currentTaskLength = length,
      currentTaskCycleIndex = cycle,
      currentTaskTotalCycle = total,
    }
  elseif res.nextCycle then
    local index, cycle = 1, _cycle + 1
    local step = self.routine.map[_task][index]
    state = {
      hasErr = false,
      currentIndex = index,
      currentStep = step,
      currentTaskCycleIndex = cycle,
    }
  elseif res.nextIndex then
    local index = _index + 1
    state = {
      hasErr = false,
      currentIndex = index,
      currentStep = self.routine.map[_task][index]
    }
  end
  return state
end


function _M:shouldExit()
  local pp = self:getCurrentProgressProfile()
  return pp.isTermial or pp.hasFatalErr
end


function _M:run()
  while true do
    -- update state
    self:updateState(self:interpretResolve(self:resolve()))
    self.monitor:reportAndlog()
    -- check if is terminal of the process or has fatal err
    if self:shouldExit() then break end
    -- do the current step of task
    self:act()
  end
end



-------------------------------------------------------------------------
-- Return
return _M
