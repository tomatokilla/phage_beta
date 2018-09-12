local json = require "ts".json


local insert = table.insert
local remove = table.remove
local fmt    = string.format
local pairs  = pairs
local type   = type
local error  = error
local open   = io.open
local time   = os.time

-------------------------------------------------------------
-- CURD operations of collections
-------------------------------------------------------------
local crud = {}


-- Func: --> verify that if the given table is an array or not
local function isArray(t)
  if type(t) ~= "table" then return false end

  local n = #t
  for i, v in pairs(t) do
      if type(i) ~= "number" or i > n
      then return false end
  end
  return true 
end

-- func: clone(obj) --> deeply(recursively) copy an obj
local function clone(obj)
    local lookup_tbl = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_tbl[obj] then
            return lookup_tbl[obj]
        end

        local new_tbl = {}
        lookup_tbl[obj] = new_tbl
        for k, v in pairs(obj) do
            new_tbl[_copy(k)] = _copy(v)
        end
        return setmetatable(new_tbl, getmetatable(obj))
    end

    return _copy(obj)
end

-- Func: --> compare 2 lua values, deeply!! which means recursively
-- compare the values of any tables encounterd. Besides, it will 
-- respect metatable && metamethods (i.e. __eq) if required.
local function isEqual(t1, t2, withMeta)
  local _ty1, _ty2 = type(t1), type(t2)
  if _ty1 ~= _ty2 then return false end
  if _ty1 ~= 'table' and _ty2 ~= 'table' then return t1 == t2 end

  if withMeta == true then
    local mt = getmetatable(t1)
    if mt and mt.__eq then return t1 == t2 end
  end

  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not isEqual(v1, v2) then return false end
  end
  for k2, v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not isEqual(v1, v2) then return false end
  end
  return true
end


local function readfile(path)
  local f = open(path, 'r')
  if not f then return end
  local cnt = f:read('*a')
  f:close()
  return cnt
end

local function writefile(path, cnt)
  local f = open(path, 'w')
  f:write(cnt)
  f:close()
end


crud.find = function(collection, probe)
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