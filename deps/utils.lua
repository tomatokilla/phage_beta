--[[
  Handy stuff for phage
  Author: benmooo
  2018/08/01
]]

local function isArray(t)
  if type(t) ~= 'table' then return false end
  local n = #t
  for k, v in pairs(t) do
    if type(k) ~= 'number' then return false end
    if k > n then return false end
  end
  return true
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












-- Return module
return {
  isArray = isArray,

  StateBox = StateBox,
  TaskMap = TaskMap,
  Routine = Routine,
  Worker = Worker,
  requests = requests,

}