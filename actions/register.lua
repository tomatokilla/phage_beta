local pages = require('register_page')


-- local steps = {
--   'openctl',
--   'gotoapplist',
--   'checkifenvexhausted',
--   'buildenv',
--   'opentantan',
--   'tapstartregister',
--   'inputmobile',
--   'inputmobile',
--   'inputvcode',
--   'fillupinfo',
--   'uploadhead',
--   'handlepopups',
-- }


local function openCtl()
  runApp('ctl')
end

local function gotoapplist()
  local page = isPages(pages)
  if page == 'ctl1' then
  elseif page == 'ctl1_1' then
  elseif page == 'ctl2' then
  elseif page == 'ctl2_1' then
  else end
end

local function checkEnv()
  local s = json.decode(readfile(path) or '{}')
  return s.isNot == 1 and {skipCurrentTask = true} or nil
end

local function buildEnv()
  local p = getIconPos({icon = icon})
  tap()
end

local function opentantan()
  runApp('tantan')
end

local function startRegister()
  tap()
end

local function inputMobile()
  local phone = getMobile()
  -- chekc if has text
  if hasphonefieldhastext() then cleartext() end
  inputtext(phone)
end
