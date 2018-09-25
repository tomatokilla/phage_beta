--[[
  Author: benmooo
  Handy stuff for phage
  some snippets of functions was refered from LuaForge@[http://snippets.luacode.org]
]]


local type, setmetatable, getmetatable, pairs, next =
      type, setmetatable, getmetatable, pairs, next
local open = io.open
local random = math.random

-- Deep copies a table into a new table.
-- Tables used as keys are also deep copied, as are metatables
-- @params (orig: table) the table to copy
-- @return (new: table) return s a copy of the input table
local function deepcopy(o)
  local copy
  if type(o) ~= 'table' then
    copy = o
  else
    copy = {}
    for o_key, o_val in next, o, nil do
      copy[deepcopy(o_key)] = deepcopy(o_val)
    end
    setmetatable(copy, deepcopy(getmetatable(o)))
  end
  return copy
end

-- Compare 2 lua values, deeply.
-- It will respect metatable && metamethods if required.
-- @params (t1: *, t2: *[, withmeta: boolean])
-- @return (b: boolean)
local function isequal(t1, t2, withmeta)
  local _ty1, _ty2 = type(t1), type(t2)
  if _ty1 ~= 'table' or _ty2 ~= 'table' then
    return t1 == t2
  end
  if withmeta then
    local mt = getmetatable(t1)
    if mt and mt._eq then return t1 == t2 end
  end
  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not isequal(v1, v2) then return false end
  end
  for k2, v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not isequal(v1, v2) then return false end
  end
  return true
end

-- Check if a table has a value(string or number expected) shallowly
-- @param (t: table, val: string | number)
-- @return (b: boolean)
local function tblhasval(tbl, val)
  -- if type(tbl) ~= 'table' then return false end
  for _, v in pairs(tbl) do
    if v == val then return true end
  end
  return false
end

-- Compare 2 tables, and returns table1 is subset of table2 or not
-- It would not respect the metatable, but it respects arrays
-- @param (t1: table, t2: table)
-- @return (b: boolean)
-- Caveat:
local function issubset(t1, t2)
  local _ty1, _ty2 = type(t1), type(t2)
  if _ty1 ~= _ty2 then return false end
  if _ty1 ~= 'table' then return t1 == t2 end
  for k1, v1 in pairs(t1) do
    local _t, v2 = type(k1), t2[k1]
    if v2 == nil then return false end
    if _t == 'number' then
      if type(v1) == 'table' then return false end
      if not tblhasval(t2, v1) then return false end
    else
      if not issubset(v1, v2) then return false end
    end
  end
  return true
end

-- Compare 2 tables, and check if table1 is subset of table2 or not
-- It will not respect the metatable
-- @param (t1: table, t2: table)
-- @return (b: boolean)
local function tblHasKey(t1, t2)
  if type(t1) ~= 'table' or type(t2) ~= 'table' then
    return false
  end
  for k1, v1 in pairs(t1, t2) do
    local v2 = t2[k1]
    if v2 == nil then return false end
    if type(v1) == 'table' then
      if type(v2) ~= 'table' then return false end
      if not tblhaskey(v1, v2) then return false end
    end
  end
  return true
end


-- Check if a table is an array or not
-- @param (t: table)
-- @return (b: boolean)
local function isarray(t)
  if type(t) ~= 'table' then return false end
  local n = #t
  for k, v in pairs(t) do
    if type(k) ~= 'number' then return false end
    if k > n then return false end
  end
  return true
end

-- Assign value from table1 to table2
-- It will respect the
-- @param (t1: table, t2: table)
-- @return (void)
local function assign(t1, t2)
  for k, v1 in pairs(t1) do
    if type(v1) ~= 'table' then
      t2[k] = v1
    else
      if type(t2[k]) ~= 'table' then t2[k] = {} end
      assign(v1, t2[k])
    end
  end
end

-- local function rawAssign(t1, t2)
-- end

local function shuffle(array)
  local m, i = #array
  while m > 0 do
    i = random(m)
    array[m], array[i] = array[i], array[m]
    m = m - 1
  end
  return array
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

-- read string from local file
-- @param (path: string)
-- @return (cnt: string)
local function readfile(path)
  local f = open(path, 'r')
  if not f then return end
  local cnt = f:read('*a')
  f:close()
  return cnt
end

-- write string to local file
-- @param (path: string, cnt: string[, pat: string['w', 'a']])
-- @return (void)
local function writefile(path, cnt, pat)
  pat = pat or 'a'
  local f = open(path, pat)
  f:write(cnt)
  f:close()
end


-- concate the keys of a table
-- @param (tbl: table, separator: string)
-- @return (string)
local function concateTblKeys(tbl, sep)
  if type(tbl) ~= 'table' then return end
  local s, sep = '', sep or ''
  for k, _ in pairs(tbl) do
    s = s .. k .. sep
  end
  return s:sub(0, -2)
end












-- Return module
return {
  deepcopy    = deepcopy,
  assign      = assign,
  isequal     = isequal,
  shuffle     = shuffle,
  isarray     = isarray,
  issubset    = issubset,
  readfile    = readfile,
  writefile   = writefile,
  tblHasKey   = tblHasKey,
  concateTblKeys = concateTblKeys,
}
