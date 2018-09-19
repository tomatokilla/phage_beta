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
end

function _M:autoLoadWorker()
  local info = self.info
  for taskname, _ in self.task.map do
    self:mountWorker(taskname, require(fmt('phage.%s.%s.worker',
                      info.DEVICETYPE, info.APP)))
  end
end


-- shuffle the routine list
function _M:shuffleRoutineMapList(listname)
  self.routine:shuffleMapList(listname)
end

function _M:prepare()
end








-- Return
return _M
