local json   = require('json')
local util   = require('util')
local Object = require('core').Object

local isarray  = util.isarray
local deepcopy = util.deepcopy
local isequal  = util.isequal

local insert   = table.insert
local remove   = table.remove
local fmt      = string.format
local pairs    = pairs
local type     = type
local error    = error
local open     = io.open
local time     = os.time

-------------------------------------------------------------
-- CURD operations of collections
-------------------------------------------------------------
local _M = Object:extend() 

function _M:find(probe)
  if not probe then return self end
  local res = {}
  for _, v in pairs(self) do
    local matched = true
    for m, n in pairs()
  end
end



_M.find = function(collection, probe)
  if not probe then return collection end

  local res = {}
  for k, v in pairs(collection) do
    local matched = true
    for m, n in pairs(probe) do
      if not isEqual(v[m], n) then matched = false break end
    end
    if matched then insert(res, v) end
  end

  return res
end


crud.findOne = function(collection, probe)
  local res = {}
  if not probe then return res end

  for k, v in pairs(collection) do
    local matched = true
    for m, n in pairs(probe) do
      if not isEqual(v[m], n) then matched = false break end
    end

    if matched then insert(res, v) break end
  end
  return res
end


-- To be improved...
crud.update = function(collection, probe, new)
end


crud.findOneAndUpdate = function(collection, probe, new)
  local status, res
  local _schema = collection._schema

  for k, v in pairs(collection) do
    local matched = true
    for m, n in pairs(probe) do
      if not isEqual(v[m], n) then matched = false break end
    end

    if matched then
      for key, val in pairs(new) do
        if v[key] then
          local _atype, _rtype = type(val), _schema[key].type
          if _atype ~= _rtype then
            return error(fmt("updateErr: type of { %s } in schema is %s, got %s",
                                                           key, _rtype, _atype))
          else
            collection[k][key] = val 
            collection[k]['updateTime'] = time()
          end
        else
          return error(fmt("updateErr: { %s } not defined in schema", key))
        end
      end
      res = collection[k]
      break
    end
  end
  status = (res ~= nil) and true or false
  return status, res
end


crud.insert = function(collection, chunk)
  local _chunk
  local _schema = collection._schema
  if type(chunk) ~= 'table' then
    return error('data inserted must be an array || table') 
  end
  if isArray(chunk) then
    _chunk = clone(chunk)
  else
    _chunk = {clone(chunk)}
  end

  -- checking data type goes here .. 
  -- i.e. diff(chunk, schema) waiting4 improved
  for i, v in pairs(_chunk) do
    local qualified, errMsg = true, ''

    -- checking_section 1 --> required item must be provided
    for m, n in pairs(_schema) do
      if v[m] == nil then
        if n.required then
          errMsg = fmt("{ %s } in schema is required", m)
          qualified = false break
        else
          if m == "time" or m == "updateTime"
          then v[m] = time()
          else v[m] = n.default end
        end
      end
    end
    if not qualified then return error(errMsg) end
    
    -- checking_section 2 --> every item's value must be qualified..
    for key, val in pairs(v) do
      if not _schema[key] then
        errMsg = fmt("undefine items in schema: { %s }", key)
        qualified = false break
      end

      local _atype, _rtype = type(val), _schema[key].type
      if _atype ~= _rtype then
        errMsg = fmt("insertErr: { %s }: %s expected, got %s", key, _rtype, _atype)
        qualified = false break
      end
    end

    if not qualified then return error(errMsg) end
    insert(collection, v)     
  end

  return _chunk
end


crud.delete = function(collection, probe)
  for i, v in pairs(collection) do
    local matched = true
    for m, n in pairs(probe) do
      if not isEqual(v[m], n) then matched = false break end
    end
    if matched then return remove(collection, i) end
  end
end


crud.pop = function(collection, i)
  return remove(collection, i)
end


crud.push = function(collection, piece)
  if isArray(piece) then 
    return error("pushErr: pushed data must be one piece of data")
  end
  return crud.insert(collection, piece)
end

crud.jsonDump = function(collection)
  return json.encode(collection)
end

crud.jsonLoad = function(collection, jf, t)
  local t = t or 'f'
  if t ~= 's' and t ~= 'f' then
    return error('Undefined mode to load data of json')
  end

  local chunk
  if t == 's' then
    chunk = json.decode(jf)
  else
    local s = readfile(jf)
    if not s then return end
    chunk = json.decode(s)
  end

  if not isArray(chunk) then chunk = {chunk} end
  for i, v in pairs(chunk) do
    insert(collection, v)
  end

  return chunk
end

crud.syncToLocal = function(collection, path)
  local json = crud.jsonDump(collection)
  writefile(path, json)
end



-- Return module
return crud