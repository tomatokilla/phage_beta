--[[
  Author: benmooo
  Date: 2018/07/18
  This module implement the monitor object of phage.
]]
local Object    = require('core').Object
local writefile = require('util').writefile

local _M = Object:extend()

function _M:initialize(name, des)
  self.NAME = name
  self.DESCRIPTION = des
end

function _M:reportAndLog(reports, pathtolog)
  toast(reports, 1)
  writefile(pathtolog)
end

function _M:report(reports)
  toast(reports)
end
