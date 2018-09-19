--[[
  Author: benmooo
  Date: 2018/07/18
  Structed data keeper
]]

local CRUD = require('crud')
local json = require('json')
local util = require('util')

local readfile, writefile = util.readfile, util.writefile


local _M = CRUD:extend()

-- dump collection table to json string
function _M:jsonDump()
  return json.encode(self)
end

-- insert the json string(--> table) to collection
function _M:jsonLoad(jsonString)
  local rows = json.decode(jsonString)
  self:insert(rows)
end

-- write the collection to local in json format
function _M:syncToLocal(path, pat)
  local cnt = self:jsonDump()
  writefile(path, cnt, pat)
end

-- insert json string to collection from file
function _M:jsonLoadFromFile(path)
  local cnt = readfile(path)
  self:jsonLoad(cnt)
end



-- Return module
return _M