local util = require('util')
local handlePopup = require('handle_popup')

local isPages      = util.isPages
local tblHasVal    = util.tblHasVal
local getIconPos   = util.getIconPos
-- local mySnapshot   = util.mySnapshot


-- popup handler
local function verifyPopups(popups, destination, timeout, inter)
  timeout, inter = timeout or 30, inter or 2
  local i, popup = 0
  repeat
    local d = isPages(destination)
    if d then popup = d break end
    local pup = isPages(popups)
    if pup then popup = pup break end
    local p = getIconPos({icon = popups.newversionpopup})
    if p.x ~= -1 then popup = 'newversionpopup' break end
    i = i + i
    mSleep(inter*1000)
  until i*inter >= timeout
  return popup
end


local function handlePopups(popups, destination, timeout, inter)
  if destination == nil then return {ok = true, page = 'null'} end
  local popup = verifyPopups(popups, destination, timeout, inter)
  if not popup then
    return {ok = false, page = 'null'}
  else
    if tblHasVal(specialPopups, popup) then
      return {ok = true, page = popup}
    else
      handlePopup[popup]()
      return isPages(destination) and
        {ok = true, page = popup} or
        handlePopups(popups, destination, timeout, inter)
    end
  end
end



-- other handler




-- return
return {
  handlePopups = handlePopups,
}
