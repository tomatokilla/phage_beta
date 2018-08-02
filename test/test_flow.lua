
local routine = {
  initDevice = {
    'checkingFoo',
    'checkingBar',
    '...'
  },

  register = {
    'opennzt'
    'tapfoo',
    'tapbar',
  },
  
  browse = {
    'matching',
    'chat',
    'randomMatch&Chat'
  }
}

local taskMap = {
  {
    task = 'initDevice',
  },
  {
    task = 'register'
  },
}

local labours = {}

local f = flow:new(routine)
f:checkRoutine()
f:initIndex()
f:mountLabours(labours)
f:prepare()
f:run()
