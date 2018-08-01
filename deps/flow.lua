local Object = require('core').Object
local Box = require('statebox')

local type, next, setmetatable, getmetatable, pairs, rawget, rawset, error = 
      type, next, setmetatable, getmetatable, pairs, rawget, rawset, error
local insert, remove = table.insert, table.remove
local format = string.format

--[[
  Flow objects:
    1. routine = {list1 = {...}, list2 = {...}, ...}
    2. index
    3. statebox
]]
local flow = Object:extend()

--[[
  Initialize the flow obj
    caveat:
      routine must be a dict, and sub_routine must be an array
      schema of routine like this:
      routine = {
        subroutine1 = {
          'have breakfast',
          'have lunch',
          'have supper'
        },
        subroutine2 = {
          'foo',
          'bar'
        }
      }
]]
function flow:initialize(routine, taskMap, worker)
  self.routine = routine
  self.taskMap = taskMap
  self.worker  = worker
  self.state   = StateBox.new('FLow', 'status container of flow')
end

-- Initialize the index of task list, default to 1
function flow:initState()
  local this = self
  local state = self.state
  state:set({
    currentTask = '',
    currentIndex = 1,
    flowState = 'ok',
    flowErr = {
      routineErr = '',
      taskMapErr  = '',
      workerErr  = '',
    },
    workerReport = this.worker.report,
  })
end

-- shortcut to mod flow state 
function flow:modFlowState(flowstatus, flowerr)
  local state = self.state
  state:mod({
    flowState = flowstatus,
    flowErr = flowerr
  })
end

-- 4 Test: check the schema of routine is valid
function flow:checkRoutine()
  local ok, errMsg = true
  local _err, _errMsg = false, 'invalid routine'
  local routine, state = self.routine, self.state
  if type(routine) ~= 'table' or next(routine) == nil then
    _err = true
  else  
    for k, v in pairs(routine) do
      if type(k) ~= 'string' or not isArray(v) then
        _err = true break
      end
    end
  end
  if _err then
    ok, errMsg = false, _errMsg
  end
  return ok,errMsg
end

-- Check if the taskMap is valid
function flow:checkTaskMap()
  local ok, errMsg = true
  local _err = false
  local _errMsg = 'invalid taskmap or do not match routine'
  local routine, taskMap, state = self.routine, self.taskMap, self.state
  if type(taskMap) ~= 'table' or not isArray(taskMap) then
    _err = true
  else
    for _, v in pairs(taskMap) do
      if type(v) ~= 'table' then
        _err = true break
      end
      if not (v.id and v.task and routine[v.task]) then
        _err = true break
      end
    end
  end
  if _err then
    ok, errMsg = false, _errMsg
  end
  return ok, errMsg
end

-- Check if the worker matches routine & task
function flow:checkWorker()
  local ok, errMsg = true
  local _err, _errMsg = false, 'worker & (task || routine) do not match!'
  local routine, worker, state = self.routine, self.worker, self.state
  if type(worker) ~= 'table' then
    _err = true
  else
    for k, v in pairs(routine) do
      if type(worker[k]) ~= 'table' then
        _err = true break
      end
      for i, step in pairs(v) do
        if type(worker[k][step]) ~= 'function' then
          _err = true break
        end
      end
    end
  end
  if _err then
    ok, errMsg = false, _errMsg
  end
  return ok, errMsg
end

-- Reset Routine
function flow:resetRoutine(routine)
  self.routine = routine or {}
end

-- insert one step to the list at the given index
function flow:addStep(task, index, step)
  if self.routine[task] == nil then return end
  if task == nil or index == nil then return end
  if step == nil then
    step  = index
    index = #task + 1
  end
  return insert(self.routine[task], index, step)
end

function flow:appendStep(task, step)
  return self:addStep(task, step)
end

-- Remove one step from the task list
function flow:removeStep(task, step)
  if step == nil or self.routine[task] == nil then
    return
  end
  return removeByValue(self.routine[task], step)
end

function flow:removeAllStep(task)
  if not task or self.routine[task] == nil then
    return
  end
  self.routine[task] = {}
end

-- Resolve what to do next --> 2be optimized // should be resolved by a
-- jump map which is a definition that control the flow routine when an unexpectd
-- exception occured
function flow:resolve(jumpMap)
  local state = self.state
  local workerReport = state.workerReport
  local task = state.currentTask
  local step = #self.routine[task] == state.currentIndex and
                1 or state.currentIndex + 1
  -- (jump) an indicator which implies the order which step to jump2
  if workerReport.gonnaJump then
    task = workerReport.jumpTo.task
    step = workerReport.jumpTo.step
    -- reset the indicator
    workerReport:mod({
      gonnaJump = false,
      jumpTo = {
        task = '',
        step = ''
      }
    })
  end
  return task, step
end

-- toggle flow index according to state
function flow:toggleIndex(task, index)
  
  self.state:mod({
    currentTask = task,
    currentIndex = index
  })
end

-- Return ok, flow instance if everything is ok, return err, errMsg otherwise
function flow:prepare()
  local state = self.state
  local status, obj, errTbl
  local _flowstate, _flowerr = 'ok', {}
  -- initialize state box
  self:initState()
  -- check stuff
  local ok1, errMsg1 = self:checkRoutine()
  local ok2, errMsg2 = self:checkTaskMap()
  local ok3, errMsg3 = self:checkWorker()

  if not (ok1 and ok2 and ok3) then
    _flowstate = 'err'
    if not ok1 then _flowerr.routineErr = errMsg1 end
    if not ok2 then _flowerr.taskMapErr = errMsg2 end
    if not ok3 then _flowerr.workerErr  = errMsg3 end
  end

  -- update flow state
  if _flowstate ~= 'ok' then
    self:modFlowState(_flowstate, _flowerr)
  end

  if state == 'ok' then
    status, obj = true, self
  else
    status, errTbl = false, state.flowErr
  end
  return status, obj, errTbl
end






function flow:run()
end











---------------------------------------------------------------------
return flow

local routine = {
  initDevice = {
    'checkingFoo',
    'checkingBar',
    '...'
  },

  register = {
    'opennzt'
    'tapfoo',
    'tapbar',
  },
  
  browse = {
    'matching',
    'chat',
    'randomMatch&Chat'
  }
}

local taskMap = {
  {
    task = 'initDevice',
    description = 'initDevice'
  },
  {
    task = 'register'
  },
}

local labours = {}

local f = flow:new(routine)
f:checkRoutine()
f:initIndex()
f:mountLabours(labours)
f:prepare()