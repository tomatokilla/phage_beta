local Object = require('core').Object
local Box = require('statebox')

local type, next, setmetatable, getmetatable, pairs, rawget, rawset = 
      type, next, setmetatable, getmetatable, pairs, rawget, rawset

--[[
  Flow objects:
    1. director 
    2. toggler
    3. resolve
    4. state container
]]
local flow = Object:extend()

--[[
  Initialize the flow obj
    caveat:
      routines must be a list, and sub_routine must be an array which means
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
          'bar',
          ...
        }
      }
]]
function flow:initialize(routines, index, statebox)
  if routines == nil then
    self.routines = {}
    self.index    = 1
    self.statebox = {}
  elseif index == nil then
    self.routines = routines
    self.index    = 1
    self.statebox = {}
  elseif state
  end
end

function flow:resetRoutine(list)
  if type(list) ~= 'table' or next(list) == nil then
    return
  end
  self.routine = list
end

-- insert one step to the routine or subroutine at the given index
function flow:addStep(subRoutine, index, step)
  if subRoutine == nil then return end
  if index == nil then
    step = subRoutine
    return insert(self.routine, step)
  end
  if step == nil then
    step = index
    return insert(self.routine[subRoutine], step)
  end
  return insert(self.routine[subRoutine], index, step)
end

-- Remove an element by value
local function removeByValue(tbl, val)
  if type(tbl) ~= 'table' or next(tbl) == nil or not val then
    return
  end
  for i, v in pairs(tbl) do
    if v == val then
      tbl[i] = nil
    end
  end
end


function flow:removeStep(subRoutine, step)
  if subRoutine == nil then return end
  if step == nil then
    step = subRoutine
    return remove(self.routine)
  end
end











function flow:run()
end

function flow:toggler()
end














---------------------------------------------------------------------
return flow