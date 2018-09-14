--------------------------------------------------------
-- Structed data keeper
--------------------------------------------------------
local CRUD = require('crud')
local json = require('json')





local _M = CRUD:extend()


local function _iteratorGen(t)
  local i, max = 0, t:count()
  return function()
    i = i + 1
    return t[i]
  end
end

local _meta = {__index = {
  count = function(self)
    return #self
  end,
  next = function(self)
   return _iteratorGen(self)
  end,
  -- for testing
  json = function(self)
    return json.encode(self)
  end,
}}






-- Initialize db
local schema = {schemas = {}}
do
  if not base.db then
    base.db = setmetatable({}, {__index = schema})
  end
end


-- Module declearation
local mmdb = {}

-- Get collections names
function mmdb.getCollectionNames()
  local t = {}
  for k, v in pairs(base.db) do
    if type(v) == 'table'
    then insert(t, k) end
  end
  return t
end

function mmdb.newSchema(sche)
  local _sche = {}
  local _type, _default, _required = "string", {
    string = "null",
    number = -1,
    boolean = false,
    table = {},
  }, false

  if type(sche) ~= "table" then return error("invalid schema!") end
  for k, v in pairs(sche) do
    if type(v) ~= 'table' then return error("invalid schema!") end
    _sche[k] = {}
    _sche[k].type = v.type or _type
    _sche[k].required = v.required or _required
    _sche[k].default = v.default or _default[_sche[k].type]
  end

  _sche.time = {
    type = "number",
    required = false,
    default = -1
  }
  _sche.updateTime = _sche.time

  return _sche
end

function mmdb.model(name, sche)
  schema.schemas[name] = sche

  local col = class(name, crud)
  col._schema = sche
  function col:ctor() end  -- constructor -> do something if possible
  
  local collection = col.new()
  collection.class = nil
  base.db[name] = collection
  return collection
end




-- Return module
return mmdb

