local randomTapInRec = require('common.util').randomTapInRec
local keyback        = require('common.util').keyback
local appMoveTowards = require('common.util').appMoveTowards


local function imitateKeyback()
  keyback() mSleep(2*1000)
end


local function newVersionPopup()
  imitateKeyback()
end

local function verifyingHeadPopup()
  -- randomTapInRec()
end

local function likeManageTab()
  -- randomTapInRec()
end

--local function lastTenFlipPopup()
--  randomTapInRec({646,1333,912,1369})
--end

-- local function like() end

local function rlikePopTab()
  randomTapInRec({831,1312,906,1344})
end

local function pingfen()
  -- imitateKeyback()
  randomTapInRec({832, 1293, 930, 1314}, 1)
end

local function begainMove()
  randomTapInRec({122,1391,952,1515})
end

local function viplinePopTap()
  -- randomTapInRec({})
  for i = 1, 4 do
    appMoveTowards(132,453,916,1245,160,200,700,900,49)
    mSleep(2*1000)
  end
  randomTapInRec({124,1318,948,1438})
end

local function lnolikePopTab()
  randomTapInRec({831,1312,906,1344})
end

-- local function newuimsgTab()
--   randomTap(868,1111,8)
--   mSleep(2*1000)
-- end

local function opentipPopTab()
  randomTapInRec({458, 1337, 632, 1380})
  imitateKeyback()
end

local function OldUIMoreFace()
  randomTapInRec({211,1697,867,1793})
end

local function studentPopTab()
  randomTap(532,1490,20)
  mSleep(2*1000)
end

local function openMsgPopTab()
  randomTapInRec({456,1264,616,1302})
end

local function wholikeme()
  randomTapInRec({483, 1295, 607, 1354})
  randomTapInRec({523, 1472, 610, 1494})
end

local function vipPopTab()
  imitateKeyback()
end

local function signVIPpopup2()
  imitateKeyback()
end

local function locationAuthorizationPopup()
  randomTapInRec({703, 1155, 746, 1176})
end

local function firstBatchTrailUsersPopup()
  randomTapInRec({871, 1056, 912, 1071})
end

local function signVIPpopup()
  imitateKeyback()
end

local function firstLeftFlipPopup()
  randomTapInRec({868, 1244, 914, 1263})
end

local function firstRightFlipPopup()
  randomTapInRec({871, 1268, 913, 1287})
end

local function androidSystemWebViewTerminationPopup()
  randomTapInRec({289, 1106, 355, 1128})
end


---------------------------------------------------
return {
  newVersionPopup = newVersionPopup,
  verifyingHeadPopup = verifyingHeadPopup,
  likeManageTab = likeManageTab,
  --lastTenFlipPopup = lastTenFlipPopup,
  rlikePopTab = rlikePopTab,
  pingfen = pingfen,
  begainMove = begainMove,
  viplinePopTap = viplinePopTap,
  lnolikePopTab = lnolikePopTab,
  -- newuimsgTab = newuimsgTab,
  opentipPopTab = opentipPopTab,
  OldUIMoreFace = OldUIMoreFace,
  studentPopTab = studentPopTab,
  openMsgPopTab = openMsgPopTab,
  wholikeme = wholikeme,
  signVIPgolden = imitateKeyback,
  vipPopTab = vipPopTab,
  signVIPpopup = signVIPpopup,
  signVIPpopup2 = signVIPpopup2,
  locationAuthorizationPopup = locationAuthorizationPopup,
  firstBatchTrailUsersPopup = firstBatchTrailUsersPopup,
  firstLeftFlipPopup = firstLeftFlipPopup,
  firstRightFlipPopup = firstRightFlipPopup,
  androidSystemWebViewTerminationPopup = androidSystemWebViewTerminationPopup,
}
