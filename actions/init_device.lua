local function initDevice()
    unlockDevice()
    -- setRotationLockEnable(true)
    setAirplaneMode(false)
    local battery = batteryStatus()
    if(battery.charging == 0 and battery.level <= 10)then
        dialog("low power exception!")
        lua_exit(); mSleep(100)
    end
    -- handle the exception of net connection
    while true do
        if getNetTime() ~= 0 then break end
        toast("error with net connection, retrying ..", 10)
        mSleep(60*1000)
    end
    setAutoLockTime(30*60*1000)
    switchTSInputMethod(true)
end

local function markStatus()
  -- pass
  toast('from mark status')
end

return {
  initDevice = {action = initDevice},
  markStatus = {action = markStatus}
}
