local Object = require('core').Object
local Box = require('statebox')

local type, next, setmetatable, getmetatable, pairs, rawget, rawset, error = 
      type, next, setmetatable, getmetatable, pairs, rawget, rawset, error
local insert, remove = table.insert, table.remove
local format = string.format

--[[
  Flow objects:
    1. routines = {list1 = {...}, list2 = {...}, ...}
    2. index
    3. statebox
]]
local flow = Object:extend()

--[[
  Initialize the flow obj
    caveat:
      routines must be a dict, and sub_routine must be an array which means
      no sub_sub_routine:
      schema of routines like this:
      routines = {
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
function flow:initialize(routines, taskMap, labours)
  self.routines = routines
  self.taskMap  = taskMap
  self.labours  = labours
  self.state    = Box.new('FLow', 'status container of flow')
end

-- Initialize the index of task list, default to 1
function flow:initState()
  local this = self
  local state = self.state
  state:set({
    currentTask = this.taskMap[1],
    currentIndex = 1,
    flowState = 'ok',
    flowErr = {
      routinesErr = '',
      taskMapErr  = '',
      laboursErr  = '',
    },
    laboursReport = this.labours.state,
  })
end

-- 4 Test: check the schema of routines is valid
local function isArray(t)
  if type(t) ~= 'table' then return false end
  local n = #t
  for k, v in pairs(t) do
    if type(k) ~= 'number' then return false end
    if k > n then return false end
  end
  return true
end
function flow:checkRoutines()
  if self.routines == nil then
    error('fatal err: flow got no routines')
  end
  for k, v in pairs(self.routines) do
    if type(k) ~= 'string' then
      error('routines must be a dict!')
    end
    if not isArray(v) then
      error(format("subroutine: { %s } isn't an array!"))
    end
  end
end

-- Check if the taskMap is valid
function flow:checkTaskMap()
end

-- Reset Routines
function flow:resetRoutines(routines)
  if type(list) ~= 'table' or next(list) == nil then
    return
  end
  self.routines = routines
end

-- insert one step to the list at the given index
function flow:addStep(list, index, step)
  if self.routines[list] == nil then return end
  if list == nil or index == nil then return end
  if step == nil then
    step  = index
    index = #list + 1
  end
  return insert(self.routines[list], index, step)
end

function flow:appendStep(list, step)
  return self:addStep(list, step)
end

-- Remove one step from the task list
-- Caveat: the tbl must be an array
local function removeByValue(tbl, val)
  if type(tbl) ~= 'table' or next(tbl) == nil or not val then
    return
  end
  for i, v in pairs(tbl) do
    if v == val then
      return remove(tbl, i)
    end
  end
end
function flow:removeStep(list, step)
  if step == nil or self.routines[list] == nil then
    return
  end
  return removeByValue(self.routines[list], step)
end

function flow:removeAllStep(list)
  if not list or self.routines[list] == nil then
    return
  end
  self.routines[list] = {}
end

-- Resolve what to do next
function flow:resolve(...)
  local task, step
  local state = self.state
  local laboursReport = state.laboursReport
  if laboursReport.

  return task, step
end

-- toggle flow index according to state
function flow:toggleIndex()
  local this = self
  this.state:set({
    currentTask = 
    currentIndex = 
  })
end

-- 4 Testing: Check if the labours matches routines
function flow:checkLabours()
  local routines, labours = self.routines, self.labours
  local err
  for k, v in pairs(routines) do
    if err then break end
    if type(labours[k]) ~= 'table' then
      err = true break
    end
    for i, step in pairs(v) do
      if type(labour[k][step]) ~= 'function' then
        err = true break
      end
    end
  end
  if err then error('labours do not matches flow routine!')
end

-- Return ok, flow instance if everything is ok, return err, errMsg otherwise
function flow:prepare()
  local stat, obj, errTbl
  -- initialize state box
  self:initState()
  -- check stuff
  self:checkRoutines()
  self:checkTaskMap()
  self:checkLabours()

  if self.state.flowState == 'ok' then
    stat, obj = true, self
  else
    stat, errTbl = false, self.state.flowErr
  end
  return stat, obj, errTbl
end






function flow:run()
end











---------------------------------------------------------------------
return flow

local routines = {
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

local f = flow:new(routines)
f:checkRoutines()
f:initIndex()
f:mountLabours(labours)
f:prepare()