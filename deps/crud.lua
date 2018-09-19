local util     = require('util')
local json     = require('json')
local Object   = require('core').Object

local isarray  = util.isarray
local deepcopy = util.deepcopy
local issubset = util.issubset

local type         = type
local pairs        = pairs
local time         = os.time
local insert       = table.insert
local remove       = table.remove
local setmetatable = setmetatable


-- generate an iterator.
local function _nextGen(t)
  local i, max = 0, #t
  return function()
    i = i + 1
    return t[i]
  end
end

-- wrap row with meta
local function wrapRow(row)
  local meta = {__index = {
    jsonify = function() return json.encode(row) end
  }}
  return setmetatable(row, meta)
end

-- wrap rows with meta
local function wrapRows(rows)
  local meta = {__index = {
    count = #rows,
    next = _nextGen(rows),
    jsonify = function() return json.encode(rows) end,
  }}
  return setmetatable(rows, meta)
end


-------------------------------------------------------------
-- CURD operations of collections
-------------------------------------------------------------
local _M = Object:extend() 


-- methods in metatable
-- local _meta = {__index = {
--   count = function(self)
--     return #self
--   end,
--   next_gen = (function(self)
--    return _nextGen(self)
--   end)(self),
--   -- for testing
--   json = function(self)
--     return json.encode(self)
--   end,
-- }}

function _M:find(probe)
  if not probe then return end
  local rows = {}
  for i, v in pairs(self) do
    if issubset(probe, v) then
      insert(rows, v)
    end
  end
  return wrapRows(deepcopy(rows))
end

function _M:findOne(probe)
  if not probe then return end
  local row
  for i, v in pairs(self) do
    if issubset(probe, v) then
      row = v break
    end
  end
  local row = deepcopy(row)
  return row and wrapRow(row) or nil
end

function _M:findOneAndUpdate(probe, new)
  local ok, row = false
  if not probe then return ok, row end
  -- findone
  for i, v in pairs(self) do
    if issubset(probe, v) then
      local _new = deepcopy(new)
      _new.update_time = time()
      for key, val in pairs(_new) do
        v[key] = val
      end
      ok, row = true, v
      break
    end
  end
  row = deepcopy(row)
  return ok, ok and wrapRow(row) or nil
end

function _M:update(probe, new)
  if not probe then return false, {} end
  local rows = {}
  -- loop through all rows
  for i, v in pairs(self) do
    if issubset(probe, v) then
      local _new = deepcopy(new)
      _new.update_time = time()
      for key, val in pairs(_new) do
        v[key] = val
      end
      insert(rows, v)
    end
  end
  return #rows>0 and true or false, wrapRows(deepcopy(rows))
end

function _M:insert(rows)
  if not rows then return false, {} end
  -- prevent from distorting data unconsciously
  rows = isarray(rows) and deepcopy(rows) or {deepcopy(rows)}
  -- check data schema // depreacted
  for i, row in pairs(rows) do
    -- attach create time to row if not exists
    row.create_time = row.create_time or time()
    insert(self, row)
  end
  -- return rows
end

function _M:delete(probe)
  if not probe then return false end
  local rows = {}
  for i, v in pairs(self) do
    if issubset(probe, v) then
      insert(rows, remove(self, i))
    end
  end
  return #rows>0 and true or false, wrapRows(rows)
end


-- Return module
-- {
--   find = find,
--   findOne = findOne,
--   findOneAndUpdate = findOneAndUpdate,
--   insert = insert,
--   update = update,
--   delete = delete,
-- }

return _M